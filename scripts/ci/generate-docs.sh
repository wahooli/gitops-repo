#!/usr/bin/env bash
# generate-docs.sh — Generate LLM-powered documentation for the GitOps repo.
# Intended to run in GitHub Actions with GitHub Models API access.
#
# Uses flux build kustomization --dry-run to render fully resolved manifests
# per component, enriches with helm template output for public charts, extracts
# dependency graphs, and calls the GitHub Models API to generate documentation.
#
# Required environment variables:
#   GITHUB_TOKEN — GitHub token with models:read scope
#
# Optional environment variables:
#   MODEL           — Model to use (default: openai/gpt-4o-mini)
#   DOCS_DIR        — Output directory (default: docs)
#   MAX_TOKENS      — Max completion tokens per request (default: 4096)
#   TEMPERATURE     — Model temperature (default: 0.2)
#   DRY_RUN         — If "true", print prompts instead of calling the API
#   REQUEST_DELAY   — Seconds between API calls for rate limiting (default: 2)
#   MODE            — Generation mode: "all" (default), "missing" (only missing docs)
#   FILTER_PATHS    — Space/newline-separated changed file paths to limit generation
#                     When empty, no filtering is applied (generates everything).
#   BATCH_SIZE      — Number of API calls per batch before pausing (default: 0 = no batching)
#   BATCH_PAUSE     — Seconds to pause between batches (default: 60)
#   PROMPTS_DIR     — Directory containing prompt template files (default: scripts/ci/prompts)
#
# Required tools: flux, yq, jq, curl, helm, crane

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DOCS_DIR="${DOCS_DIR:-${REPO_ROOT}/docs}"
MODEL="${MODEL:-openai/gpt-4o-mini}"
MAX_TOKENS="${MAX_TOKENS:-4096}"
TEMPERATURE="${TEMPERATURE:-0.2}"
DRY_RUN="${DRY_RUN:-false}"
API_URL="https://models.inference.ai.azure.com/chat/completions"
REQUEST_DELAY="${REQUEST_DELAY:-2}"
MODE="${MODE:-all}"
FILTER_PATHS="${FILTER_PATHS:-}"
BATCH_SIZE="${BATCH_SIZE:-0}"
BATCH_PAUSE="${BATCH_PAUSE:-60}"
CLUSTERS_DIR="${REPO_ROOT}/clusters"

request_count=0

# Directories that contain shared/supporting config, not individual components
SUPPORT_DIRS="shared services imagerepositories vmservicescrape rules templates vmalertmanagerconfig config ci-excluded .config"

# HelmRepository name → URL mapping (populated per-component from rendered YAML)
declare -A REPO_URL_MAP
declare -A FILTER_COMPONENTS  # resolved component paths to generate
declare -A FILTER_CLUSTERS    # clusters that have matching components
docs_generated=0

###############################################################################
# Output helpers
###############################################################################
if [ -n "${GITHUB_ACTIONS:-}" ]; then
  group()   { echo "::group::$1"; }
  endgroup(){ echo "::endgroup::"; }
  log()     { echo "$1"; }
  warn()    { echo "::warning::$1"; }
else
  group()   { printf '\n\033[1;34m── %s ──\033[0m\n' "$1"; }
  endgroup(){ :; }
  log()     { echo "$1"; }
  warn()    { printf '\033[1;33mWARN: %s\033[0m\n' "$1"; }
fi

###############################################################################
# API call wrapper
###############################################################################
call_model() {
  local system_prompt="$1"
  local user_prompt="$2"

  if [ "$DRY_RUN" = "true" ]; then
    log "[DRY RUN] System: ${system_prompt:0:100}..."
    log "[DRY RUN] User prompt length: ${#user_prompt} chars"
    echo "(dry run — no output generated)"
    return 0
  fi

  if [ -z "${GITHUB_TOKEN:-}" ]; then
    warn "GITHUB_TOKEN not set, skipping API call"
    return 1
  fi

  # Rate limiting / batch pausing
  if [ "$request_count" -gt 0 ]; then
    if [ "$BATCH_SIZE" -gt 0 ] && [ $((request_count % BATCH_SIZE)) -eq 0 ]; then
      log "Batch limit reached (${BATCH_SIZE} calls), pausing ${BATCH_PAUSE}s..."
      sleep "$BATCH_PAUSE"
    else
      sleep "$REQUEST_DELAY"
    fi
  fi
  request_count=$((request_count + 1))

  local payload
  payload=$(jq -n \
    --arg model "$MODEL" \
    --arg system "$system_prompt" \
    --arg user "$user_prompt" \
    --argjson max_tokens "$MAX_TOKENS" \
    --argjson temperature "$TEMPERATURE" \
    '{
      model: $model,
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $user }
      ],
      max_tokens: $max_tokens,
      temperature: $temperature
    }')

  local response
  response=$(curl -s --fail-with-body \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "$payload" \
    "$API_URL") || {
      warn "API call failed (request #${request_count}): $(echo "$response" | head -5)"
      return 1
    }

  echo "$response" | jq -r '.choices[0].message.content // empty'
}

###############################################################################
# Helpers
###############################################################################

is_support_dir() {
  local name="$1"
  for skip in $SUPPORT_DIRS; do
    [ "$name" = "$skip" ] && return 0
  done
  return 1
}

# Resolve a single changed file path to component filter entries
resolve_changed_path() {
  local changed_path="$1"
  changed_path="${changed_path%/}"

  # Strip to directory if it's a file
  if [ -f "${REPO_ROOT}/${changed_path}" ]; then
    changed_path=$(dirname "$changed_path")
  fi

  # apps/base/<component>/... → fan out to all clusters with that component
  if [[ "$changed_path" =~ ^apps/base/([^/]+) ]]; then
    local component="${BASH_REMATCH[1]}"
    for cluster_dir in "${REPO_ROOT}/apps"/*/; do
      local c
      c=$(basename "$cluster_dir")
      [[ "$c" == "base" || "$c" == _* ]] && continue
      if [ -d "${REPO_ROOT}/apps/${c}/${component}" ]; then
        FILTER_COMPONENTS["apps/${c}/${component}"]=1
        FILTER_CLUSTERS["$c"]=1
      fi
    done

  # apps/<cluster>/<component>/...
  elif [[ "$changed_path" =~ ^apps/([^/]+)/([^/]+) ]]; then
    local cluster="${BASH_REMATCH[1]}"
    local component="${BASH_REMATCH[2]}"
    if [[ "$cluster" != _* ]]; then
      FILTER_COMPONENTS["apps/${cluster}/${component}"]=1
      FILTER_CLUSTERS["$cluster"]=1
    fi

  # infrastructure/base/<component>/... → fan out across all layers and clusters
  elif [[ "$changed_path" =~ ^infrastructure/base/([^/]+) ]]; then
    local component="${BASH_REMATCH[1]}"
    for layer_dir in "${REPO_ROOT}/infrastructure"/*/; do
      local layer
      layer=$(basename "$layer_dir")
      [[ "$layer" == "base" || "$layer" == _* || "$layer" == "ci-excluded" ]] && continue
      for cluster_dir in "${layer_dir}"/*/; do
        [ -d "$cluster_dir" ] || continue
        local c
        c=$(basename "$cluster_dir")
        [[ "$c" == "base" || "$c" == _* ]] && continue
        if [ -d "${cluster_dir}/${component}" ]; then
          FILTER_COMPONENTS["infrastructure/${layer}/${c}/${component}"]=1
          FILTER_CLUSTERS["$c"]=1
        fi
      done
    done

  # infrastructure/<layer>/base/<component>/... → fan out to all clusters in that layer
  elif [[ "$changed_path" =~ ^infrastructure/([^/]+)/base/([^/]+) ]]; then
    local layer="${BASH_REMATCH[1]}"
    local component="${BASH_REMATCH[2]}"
    for cluster_dir in "${REPO_ROOT}/infrastructure/${layer}"/*/; do
      [ -d "$cluster_dir" ] || continue
      local c
      c=$(basename "$cluster_dir")
      [[ "$c" == "base" || "$c" == _* ]] && continue
      if [ -d "${REPO_ROOT}/infrastructure/${layer}/${c}/${component}" ]; then
        FILTER_COMPONENTS["infrastructure/${layer}/${c}/${component}"]=1
        FILTER_CLUSTERS["$c"]=1
      fi
    done

  # infrastructure/<layer>/<cluster>/<component-or-support-dir>/...
  elif [[ "$changed_path" =~ ^infrastructure/([^/]+)/([^/]+)/([^/]+) ]]; then
    local layer="${BASH_REMATCH[1]}"
    local cluster="${BASH_REMATCH[2]}"
    local component="${BASH_REMATCH[3]}"
    if [[ "$cluster" != "base" && "$cluster" != _* ]]; then
      if is_support_dir "$component" || [ ! -d "${REPO_ROOT}/infrastructure/${layer}/${cluster}/${component}" ]; then
        FILTER_COMPONENTS["infrastructure/${layer}/${cluster}"]=1
      else
        FILTER_COMPONENTS["infrastructure/${layer}/${cluster}/${component}"]=1
      fi
      FILTER_CLUSTERS["$cluster"]=1
    fi

  # infrastructure/<layer>/<cluster> (standalone files at layer level)
  elif [[ "$changed_path" =~ ^infrastructure/([^/]+)/([^/]+)$ ]]; then
    local layer="${BASH_REMATCH[1]}"
    local cluster="${BASH_REMATCH[2]}"
    if [[ "$cluster" != "base" && "$cluster" != _* ]]; then
      FILTER_COMPONENTS["infrastructure/${layer}/${cluster}"]=1
      FILTER_CLUSTERS["$cluster"]=1
    fi

  # clusters/<cluster>/... → cluster overview
  elif [[ "$changed_path" =~ ^clusters/([^/]+) ]]; then
    local cluster="${BASH_REMATCH[1]}"
    if [[ "$cluster" != _* && "$cluster" != "flux-system" ]]; then
      FILTER_COMPONENTS["clusters/${cluster}"]=1
      FILTER_CLUSTERS["$cluster"]=1
    fi
  fi

  return 0
}

# Resolve all FILTER_PATHS into FILTER_COMPONENTS entries
resolve_filter_paths() {
  local path
  while IFS= read -r path; do
    path=$(echo "$path" | xargs)
    [ -z "$path" ] && continue
    resolve_changed_path "$path"
  done <<< "${FILTER_PATHS// /$'\n'}"

  log "Resolved ${#FILTER_COMPONENTS[@]} component paths for ${#FILTER_CLUSTERS[@]} cluster(s)"
  for key in "${!FILTER_COMPONENTS[@]}"; do
    log "  - ${key}"
  done
}

# Check whether a component should be documented based on MODE and FILTER_PATHS
should_generate() {
  local component_path="$1"
  local output_file="$2"

  # Check path filter (when active)
  if [ -n "$FILTER_PATHS" ]; then
    [ "${FILTER_COMPONENTS[$component_path]:-}" != "1" ] && return 1
  fi

  # Check missing mode — skip if output file exists
  if [ "$MODE" = "missing" ] && [ -f "$output_file" ]; then
    return 1
  fi

  return 0
}

# Check whether a cluster should be processed at all
should_process_cluster() {
  local cluster_name="$1"

  # In 'missing' mode without filter, process all clusters
  if [ "$MODE" = "missing" ] && [ -z "$FILTER_PATHS" ]; then
    return 0
  fi

  # If filter paths set, only process matching clusters
  if [ -n "$FILTER_PATHS" ]; then
    [ "${FILTER_CLUSTERS[$cluster_name]:-}" = "1" ] && return 0
    return 1
  fi

  return 0
}

# Render manifests for a component path using flux build kustomization --dry-run
flux_build_component() {
  local ks_name="$1"
  local ks_file="$2"
  local component_path="$3" # relative to REPO_ROOT

  flux build kustomization "$ks_name" \
    --dry-run \
    --kustomization-file "$ks_file" \
    --path "${REPO_ROOT}/${component_path}" 2>/dev/null || true
}

# Read standalone YAML files from a directory (excluding kustomize config files)
read_standalone_yamls() {
  local dir="$1"
  local context=""

  for f in "${dir}"/*.yaml; do
    [ -f "$f" ] || continue
    local bname
    bname=$(basename "$f")
    case "$bname" in
      kustomization.yaml|kustomizeconfig.yaml) continue ;;
    esac
    context+="--- ${bname} ---"$'\n'
    context+="$(cat "$f")"$'\n\n'
  done

  echo "$context"
}

# Populate REPO_URL_MAP from HelmRepository resources in rendered YAML
populate_repo_urls() {
  local rendered="$1"
  local repo_name repo_url

  while IFS='|' read -r repo_name repo_url; do
    repo_name=$(echo "$repo_name" | xargs)
    repo_url=$(echo "$repo_url" | xargs)
    [ -n "$repo_name" ] && [ -n "$repo_url" ] && REPO_URL_MAP["$repo_name"]="$repo_url"
  done < <(echo "$rendered" | yq -r 'select(.kind == "HelmRepository") | .metadata.name + "|" + .spec.url' 2>/dev/null | grep -v '^---$' || true)
}

# Extract all HelmRelease info from rendered YAML.
# Outputs lines: name|chart|version|repoName|releaseName|targetNs|interval|deps
extract_helmreleases() {
  local rendered="$1"

  echo "$rendered" | yq -r '
    select(.kind == "HelmRelease") |
    .metadata.name + "|" +
    .spec.chart.spec.chart + "|" +
    (.spec.chart.spec.version // "") + "|" +
    (.spec.chart.spec.sourceRef.name // "") + "|" +
    (.spec.releaseName // .metadata.name) + "|" +
    (.spec.targetNamespace // .metadata.namespace // "") + "|" +
    (.spec.interval // "") + "|" +
    ([.spec.dependsOn[]?.name] | join(","))
  ' 2>/dev/null | grep -v '^---$' || true
}

# Extract merged Helm values for a HelmRelease from its valuesFrom ConfigMaps.
# Writes merged values to a temp file and echoes the path.
extract_helm_values() {
  local rendered="$1"
  local hr_name="$2"
  local tmpdir="$3"

  # Get valuesFrom ConfigMap references
  local cm_refs
  cm_refs=$(echo "$rendered" | yq -r "
    select(.kind == \"HelmRelease\" and .metadata.name == \"${hr_name}\") |
    .spec.valuesFrom[]? |
    select(.kind == \"ConfigMap\") |
    .name + \"|\" + (.valuesKey // \"values.yaml\")
  " 2>/dev/null | grep -v '^---$' || true)

  [ -z "$cm_refs" ] && return 0

  # Also get inline values
  local inline_values
  inline_values=$(echo "$rendered" | yq -r "
    select(.kind == \"HelmRelease\" and .metadata.name == \"${hr_name}\") |
    select(.spec.values != null) | .spec.values | to_yaml
  " 2>/dev/null | grep -v '^---$' || true)

  local merged_file="${tmpdir}/${hr_name}-values.yaml"
  : > "$merged_file"

  while IFS='|' read -r cm_name values_key; do
    [ -z "$cm_name" ] && continue
    local cm_values
    cm_values=$(echo "$rendered" | yq -r "
      select(.kind == \"ConfigMap\" and .metadata.name == \"${cm_name}\") |
      .data[\"${values_key}\"] // \"\"
    " 2>/dev/null || true)
    [ -n "$cm_values" ] && echo "$cm_values" >> "$merged_file"
  done <<< "$cm_refs"

  # Append inline values
  if [ -n "$inline_values" ] && [ "$inline_values" != "{}" ] && [ "$inline_values" != "null" ]; then
    echo "$inline_values" >> "$merged_file"
  fi

  [ -s "$merged_file" ] && echo "$merged_file"
}

# Resolve the latest version for an OCI chart using crane.
# Echoes the resolved version or empty string on failure.
resolve_oci_version() {
  local registry_url="$1" # e.g. oci://ghcr.io/wahooli/charts
  local chart="$2"

  # Strip oci:// prefix to get registry path
  local registry_path="${registry_url#oci://}"

  crane ls "${registry_path}/${chart}" 2>/dev/null | sort -V | tail -1
}

# Run helm template for a HelmRelease.
# Handles both HTTP and OCI repos, resolves floating versions for OCI charts.
# Returns the rendered manifests or empty string.
helm_template_release() {
  local chart="$1"
  local version="$2"
  local repo_name="$3"
  local release_name="$4"
  local target_ns="$5"
  local values_file="$6"

  local repo_url="${REPO_URL_MAP[$repo_name]:-}"

  # Skip if no repo URL found
  if [ -z "$repo_url" ]; then
    log "    Skipping helm template: repo '${repo_name}' URL not found" >&2
    return 0
  fi

  local helm_args=()
  local resolved_version="$version"

  if [[ "$repo_url" == oci://* ]]; then
    # OCI repo: resolve floating versions, use oci:// URL directly
    if [[ "$version" == ">="* ]] || [[ "$version" == ">"* ]] || [ -z "$version" ]; then
      resolved_version=$(resolve_oci_version "$repo_url" "$chart")
      if [ -z "$resolved_version" ]; then
        log "    Skipping helm template: could not resolve version for ${repo_url}/${chart}" >&2
        return 0
      fi
      log "    Resolved ${chart} version: ${version} → ${resolved_version}" >&2
    fi
    helm_args=(template "$release_name" "${repo_url}/${chart}"
      --version "$resolved_version"
      --no-hooks
    )
  else
    # HTTP repo: omit --version for floating/empty versions (uses latest from repo index)
    helm_args=(template "$release_name" "$chart"
      --repo "$repo_url"
      --no-hooks
    )
    if [ -n "$resolved_version" ] && [[ "$resolved_version" != ">="* ]] && [[ "$resolved_version" != ">"* ]]; then
      helm_args+=(--version "$resolved_version")
    fi
  fi

  [ -n "$target_ns" ] && helm_args+=(--namespace "$target_ns")
  [ -n "$values_file" ] && [ -f "$values_file" ] && helm_args+=(-f "$values_file")

  local version_display="${resolved_version:-latest}"
  log "    Running: helm template ${release_name} ${chart} (${version_display})" >&2
  helm "${helm_args[@]}" 2>/dev/null || {
    warn "    helm template failed for ${chart}@${version_display}" >&2
    return 0
  }
}

# Format version string for display
format_version() {
  local version="$1"
  local repo_name="$2"
  local repo_url="${REPO_URL_MAP[$repo_name]:-}"

  if [[ "$version" == ">="* ]] || [[ "$version" == ">"* ]] || [ -z "$version" ]; then
    echo "latest (floating: ${version:-unset})"
  else
    echo "$version"
  fi
}

###############################################################################
# Prompt template helpers
###############################################################################
PROMPTS_DIR="${PROMPTS_DIR:-${REPO_ROOT}/scripts/ci/prompts}"

# Load a prompt template file verbatim.
# Falls back to empty string with a warning if the file doesn't exist.
load_prompt() {
  local template_file="${PROMPTS_DIR}/${1}.txt"
  if [ ! -f "$template_file" ]; then
    warn "Prompt template not found: ${template_file}"
    echo ""
    return 0
  fi
  cat "$template_file"
}

###############################################################################
# Doc generators
###############################################################################

# Generate enriched doc for a component
generate_component_doc() {
  local ks_name="$1"
  local ks_file="$2"
  local component_path="$3"
  local component_name="$4"
  local cluster_name="$5"
  local output_file="$6"

  log "  Building: ${component_path}"

  local rendered
  rendered=$(flux_build_component "$ks_name" "$ks_file" "$component_path")

  if [ -z "$rendered" ]; then
    warn "flux build produced no output for ${component_path}, reading files directly"
    rendered=$(read_standalone_yamls "${REPO_ROOT}/${component_path}")
  fi

  if [ -z "$rendered" ]; then
    warn "No content for ${component_name}, skipping"
    return 0
  fi

  # Populate repo URL map from rendered YAML
  populate_repo_urls "$rendered"

  # Extract all HelmReleases in this component
  local hr_lines
  hr_lines=$(extract_helmreleases "$rendered")

  local tmpdir
  tmpdir=$(mktemp -d)

  # Build enrichment context per HelmRelease
  local hr_context=""
  local dep_context=""
  local hr_count=0

  if [ -n "$hr_lines" ]; then
    while IFS='|' read -r hr_name chart version repo_name release_name target_ns interval deps; do
      [ -z "$hr_name" ] && continue
      hr_count=$((hr_count + 1))

      local display_version
      display_version=$(format_version "$version" "$repo_name")
      local repo_url="${REPO_URL_MAP[$repo_name]:-unknown}"
      local repo_type="HTTP"
      [[ "$repo_url" == oci://* ]] && repo_type="OCI"

      hr_context+="### HelmRelease: ${hr_name}"$'\n'
      hr_context+="- Chart: ${chart}"$'\n'
      hr_context+="- Version: ${display_version}"$'\n'
      hr_context+="- Repository: ${repo_name} (${repo_url}) [${repo_type}]"$'\n'
      hr_context+="- Release Name: ${release_name}"$'\n'
      hr_context+="- Target Namespace: ${target_ns}"$'\n'
      hr_context+="- Reconciliation Interval: ${interval}"$'\n'

      if [ -n "$deps" ]; then
        hr_context+="- Dependencies: ${deps}"$'\n'
        dep_context+="- ${hr_name} depends on: ${deps}"$'\n'
      fi
      hr_context+=$'\n'

      # Extract values and run helm template for public charts
      local values_file
      values_file=$(extract_helm_values "$rendered" "$hr_name" "$tmpdir")

      local helm_output
      helm_output=$(helm_template_release "$chart" "$version" "$repo_name" \
        "$release_name" "$target_ns" "$values_file")

      if [ -n "$helm_output" ]; then
        # Write helm output to temp file to avoid SIGPIPE with large outputs
        local helm_tmp="${tmpdir}/${hr_name}-helm-output.yaml"
        echo "$helm_output" > "$helm_tmp"

        # Summarize the Kubernetes resources created by helm template
        local resource_summary
        resource_summary=$(grep '^kind:' "$helm_tmp" | sed 's/kind: //' | sort | uniq -c | sort -rn | \
          awk '{print "  - " $2 " (" $1 ")"}')

        hr_context+="#### Rendered Kubernetes Resources (via helm template):"$'\n'
        hr_context+="${resource_summary}"$'\n'

        # Include truncated helm template output (first 300 lines to avoid token limits)
        local template_lines
        template_lines=$(wc -l < "$helm_tmp")
        if [ "$template_lines" -gt 300 ]; then
          hr_context+=$'\n'"<helm-template-output lines=\"${template_lines}\" truncated=\"true\">"$'\n'
          hr_context+="$(head -300 "$helm_tmp")"$'\n'
          hr_context+="... (truncated, ${template_lines} total lines)"$'\n'
          hr_context+="</helm-template-output>"$'\n'
        else
          hr_context+=$'\n'"<helm-template-output lines=\"${template_lines}\">"$'\n'
          hr_context+="${helm_output}"$'\n'
          hr_context+="</helm-template-output>"$'\n'
        fi
        hr_context+=$'\n'
      fi

    done <<< "$hr_lines"
  fi

  # List all resource kinds in the flux build output
  local all_kinds
  all_kinds=$(echo "$rendered" | grep '^kind:' | sed 's/kind: //' | sort | uniq -c | sort -rn | \
    awk '{print $2 " (" $1 ")"}' | tr '\n' ', ' | sed 's/,$//')

  # Build user prompt: data context + instructions from template
  local user_prompt
  user_prompt="Generate documentation for component '${component_name}' deployed in cluster '${cluster_name}'.

=== Flux Build Output (Kustomize-rendered manifests) ===
${rendered}

"

  if [ -n "$hr_context" ]; then
    user_prompt+="=== HelmRelease Details (${hr_count} release(s)) ===
${hr_context}
"
  fi

  if [ -n "$dep_context" ]; then
    user_prompt+="=== Dependency Graph ===
${dep_context}
"
  fi

  user_prompt+="=== Resource Summary ===
All Kubernetes resource kinds in this component: ${all_kinds}

"

  user_prompt+="$(load_prompt "component-user")"

  local system_prompt
  system_prompt=$(load_prompt "component-system")

  local result
  result=$(call_model "$system_prompt" "$user_prompt") || {
    rm -rf "$tmpdir"
    return 1
  }

  rm -rf "$tmpdir"
  mkdir -p "$(dirname "$output_file")"
  echo "$result" > "$output_file"
  docs_generated=$((docs_generated + 1))
  log "  Generated: ${output_file#${REPO_ROOT}/}"
}

# Generate doc for standalone resources (layer-level YAML files without kustomization.yaml)
generate_resources_doc() {
  local layer_path="$1"
  local layer_name="$2"
  local cluster_name="$3"
  local output_file="$4"

  local context
  context=$(read_standalone_yamls "$layer_path")

  [ -z "$context" ] && return 0

  local system_prompt
  system_prompt=$(load_prompt "resources-system")

  local user_prompt
  user_prompt="Generate documentation for the standalone resources in the '${layer_name}' infrastructure layer for cluster '${cluster_name}'.

Kubernetes resource manifests:
${context}

$(load_prompt "resources-user")"

  local result
  result=$(call_model "$system_prompt" "$user_prompt") || return 1

  mkdir -p "$(dirname "$output_file")"
  echo "$result" > "$output_file"
  docs_generated=$((docs_generated + 1))
  log "  Generated: ${output_file#${REPO_ROOT}/}"
}

# Generate cluster overview from Flux Kustomization entrypoints
generate_cluster_overview() {
  local cluster_name="$1"
  local output_file="$2"
  local cluster_dir="${CLUSTERS_DIR}/${cluster_name}"

  local context=""
  for f in "${cluster_dir}"/*.yaml; do
    [ -f "$f" ] || continue
    context+="--- $(basename "$f") ---"$'\n'
    context+="$(cat "$f")"$'\n\n'
  done

  local apps=""
  if [ -d "${REPO_ROOT}/apps/${cluster_name}" ]; then
    apps=$(ls "${REPO_ROOT}/apps/${cluster_name}" 2>/dev/null \
      | grep -v '\.config' | grep -v '^ci-excluded$' \
      | tr '\n' ', ' | sed 's/,$//')
  fi

  local system_prompt
  system_prompt=$(load_prompt "overview-system")

  local user_prompt
  user_prompt="Generate an overview for cluster '${cluster_name}'.

Flux Kustomization entrypoints:
${context}

Applications deployed: ${apps:-none}

$(load_prompt "overview-user")"

  local result
  result=$(call_model "$system_prompt" "$user_prompt") || return 1

  mkdir -p "$(dirname "$output_file")"
  echo "$result" > "$output_file"
  docs_generated=$((docs_generated + 1))
  log "  Generated: ${output_file#${REPO_ROOT}/}"
}

# Generate the index page from the generated docs tree
generate_index() {
  local output_file="${DOCS_DIR}/index.md"

  # Build structure summary by scanning generated docs
  local structure=""
  local cluster
  for cluster_dir in "${DOCS_DIR}"/*/; do
    [ -d "$cluster_dir" ] || continue
    cluster=$(basename "$cluster_dir")

    structure+="### ${cluster}"$'\n'
    structure+="- [Cluster overview](${cluster}/overview.md)"$'\n'

    if [ -d "${cluster_dir}/apps" ]; then
      structure+=$'\n'"**Apps:**"$'\n'
      local name
      for f in "${cluster_dir}"/apps/*.md; do
        [ -f "$f" ] || continue
        name=$(basename "$f" .md)
        structure+="- [${name}](${cluster}/apps/${name}.md)"$'\n'
      done
    fi

    if [ -d "${cluster_dir}/infrastructure" ]; then
      local layer
      for layer_dir in "${cluster_dir}/infrastructure"/*/; do
        [ -d "$layer_dir" ] || continue
        layer=$(basename "$layer_dir")
        structure+=$'\n'"**Infrastructure / ${layer}:**"$'\n'
        local name
        for f in "${layer_dir}"/*.md; do
          [ -f "$f" ] || continue
          name=$(basename "$f" .md)
          structure+="- [${name}](${cluster}/infrastructure/${layer}/${name}.md)"$'\n'
        done
      done
    fi

    structure+=$'\n'
  done

  local system_prompt
  system_prompt=$(load_prompt "index-system")

  local user_prompt
  user_prompt="Generate an index page for this GitOps repository documentation.

The repo manages multiple Kubernetes clusters using Flux CD, Cilium, Kustomize + Helm.

Documentation structure with links:
${structure}

$(load_prompt "index-user")"

  local result
  result=$(call_model "$system_prompt" "$user_prompt") || return 1

  mkdir -p "$(dirname "$output_file")"
  echo "$result" > "$output_file"
  log "  Generated: ${output_file#${REPO_ROOT}/}"
}

###############################################################################
# Process a Flux Kustomization — discover and document its components
###############################################################################
process_kustomization() {
  local cluster_name="$1"
  local ks_file="$2"

  local ks_name ks_path
  ks_name=$(yq -r 'select(.kind == "Kustomization") | .metadata.name' "$ks_file" 2>/dev/null)
  ks_path=$(yq -r 'select(.kind == "Kustomization") | .spec.path' "$ks_file" 2>/dev/null | sed 's|^\./||')

  [ -z "$ks_name" ] || [ -z "$ks_path" ] && return 0

  local full_path="${REPO_ROOT}/${ks_path}"
  [ -d "$full_path" ] || return 0

  # Derive docs category: apps/nas → apps, infrastructure/core/nas → infrastructure/core
  local docs_category
  docs_category=$(echo "$ks_path" | sed "s|/${cluster_name}$||")

  log "Processing: ${ks_name} (${ks_path})"

  # Find component subdirectories (have kustomization.yaml, are not support dirs)
  local has_components=false
  local component_name
  for component_dir in "${full_path}"/*/; do
    [ -d "$component_dir" ] || continue
    component_name=$(basename "$component_dir")

    is_support_dir "$component_name" && continue
    [ -f "${component_dir}/kustomization.yaml" ] || continue

    has_components=true
    local component_path="${ks_path}/${component_name}"
    local output_file="${DOCS_DIR}/${cluster_name}/${docs_category}/${component_name}.md"

    if ! should_generate "$component_path" "$output_file"; then
      continue
    fi

    generate_component_doc "$ks_name" "$ks_file" "$component_path" \
      "$component_name" "$cluster_name" "$output_file"
  done

  if [ "$has_components" = "true" ]; then
    # Also document standalone YAML files at the layer level (e.g. vmagent.yaml)
    local resources_output="${DOCS_DIR}/${cluster_name}/${docs_category}/resources.md"
    if should_generate "${ks_path}" "$resources_output"; then
      local layer_name
      layer_name=$(basename "$docs_category")
      generate_resources_doc "$full_path" "$layer_name" "$cluster_name" "$resources_output"
    fi
  else
    # No component subdirs — render the whole layer as one doc
    local layer_name
    layer_name=$(basename "$docs_category")
    local output_file="${DOCS_DIR}/${cluster_name}/${docs_category}/${layer_name}.md"

    if should_generate "${ks_path}" "$output_file"; then
      generate_component_doc "$ks_name" "$ks_file" "$ks_path" \
        "$layer_name" "$cluster_name" "$output_file"
    fi
  fi
}

###############################################################################
# Main
###############################################################################
main() {
  log "Generating documentation with model: ${MODEL}"
  log "Output directory: ${DOCS_DIR}"
  log "Mode: ${MODE}"
  [ -n "$FILTER_PATHS" ] && log "Filter paths provided"
  [ "$BATCH_SIZE" -gt 0 ] 2>/dev/null && log "Batch size: ${BATCH_SIZE}, pause: ${BATCH_PAUSE}s"
  log ""

  # Check required tools
  for cmd in flux yq jq curl helm crane; do
    if ! command -v "$cmd" &>/dev/null; then
      warn "Required command not found: ${cmd}"
      exit 1
    fi
  done

  # Write Jekyll config if not present (for GitHub Pages rendering)
  mkdir -p "$DOCS_DIR"
  if [ ! -f "${DOCS_DIR}/_config.yml" ]; then
    log "Writing Jekyll _config.yml"
    cat > "${DOCS_DIR}/_config.yml" << 'JEKYLL'
title: GitOps Repository Documentation
description: Auto-generated documentation for the multi-cluster Kubernetes GitOps repository
remote_theme: just-the-docs/just-the-docs

color_scheme: dark
search_enabled: true

# Apply default layout to all pages
defaults:
- scope:
    path: ""
  values:
    layout: default

# Exclude non-doc files from processing
exclude:
- _config.yml
- Gemfile
- Gemfile.lock
JEKYLL
  fi

  # Resolve filter paths if provided
  if [ -n "$FILTER_PATHS" ]; then
    resolve_filter_paths
    if [ ${#FILTER_COMPONENTS[@]} -eq 0 ]; then
      log "No matching components found for filter paths, nothing to generate"
      return 0
    fi
  fi

  # Process each cluster
  local cluster_name
  for cluster_dir in "${CLUSTERS_DIR}"/*/; do
    cluster_name=$(basename "$cluster_dir")
    [[ "$cluster_name" == _* ]] && continue
    [ "$cluster_name" = "flux-system" ] && continue

    if ! should_process_cluster "$cluster_name"; then
      continue
    fi

    group "Cluster: ${cluster_name}"

    # Reset repo URL map per cluster
    REPO_URL_MAP=()

    # Pre-populate repo URL map from sources/HelmRepository definitions.
    # HelmRepositories may be defined in components separate from the HelmReleases
    # that reference them (e.g. vector repo in vector-lb, referenced by vector-agent).
    for ks_file in "${cluster_dir}"/*.yaml; do
      [ -f "$ks_file" ] || continue
      local ks_name_pre ks_path_pre
      ks_name_pre=$(yq -r 'select(.kind == "Kustomization") | .metadata.name' "$ks_file" 2>/dev/null)
      ks_path_pre=$(yq -r 'select(.kind == "Kustomization") | .spec.path' "$ks_file" 2>/dev/null | sed 's|^\./||')
      [ -z "$ks_name_pre" ] || [ -z "$ks_path_pre" ] && continue
      local full_pre="${REPO_ROOT}/${ks_path_pre}"
      [ -d "$full_pre" ] || continue
      # Build the whole kustomization to get all HelmRepository definitions
      local pre_rendered
      pre_rendered=$(flux build kustomization "$ks_name_pre" \
        --dry-run \
        --kustomization-file "$ks_file" \
        --path "$full_pre" 2>/dev/null || true)
      [ -n "$pre_rendered" ] && populate_repo_urls "$pre_rendered"
    done
    log "  Pre-populated ${#REPO_URL_MAP[@]} HelmRepository URLs"

    # Cluster overview
    local overview_file="${DOCS_DIR}/${cluster_name}/overview.md"
    if should_generate "clusters/${cluster_name}" "$overview_file"; then
      generate_cluster_overview "$cluster_name" "$overview_file"
    fi

    # Process each Flux Kustomization entrypoint
    for ks_file in "${cluster_dir}"/*.yaml; do
      [ -f "$ks_file" ] || continue
      process_kustomization "$cluster_name" "$ks_file"
    done

    endgroup
  done

  # Generate index from the docs tree (only if docs were generated)
  if [ "$docs_generated" -gt 0 ]; then
    group "Generating index"
    generate_index
    endgroup
  fi

  local total
  total=$(find "${DOCS_DIR}" -name '*.md' 2>/dev/null | wc -l)
  log ""
  log "Documentation generation complete: ${docs_generated} generated, ${total} total files in ${DOCS_DIR#${REPO_ROOT}/}"
}

main "$@"
