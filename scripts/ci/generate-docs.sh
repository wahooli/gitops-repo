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
#   MODEL           — Model to use (default: gpt-4o-mini)
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
MODEL="${MODEL:-gpt-4o-mini}"
MAX_TOKENS="${MAX_TOKENS:-4096}"
TEMPERATURE="${TEMPERATURE:-0.2}"
DRY_RUN="${DRY_RUN:-false}"
API_URL="https://models.inference.ai.azure.com/chat/completions"
REQUEST_DELAY="${REQUEST_DELAY:-2}"
MODE="${MODE:-all}"
FILTER_PATHS="${FILTER_PATHS:-}"
BATCH_SIZE="${BATCH_SIZE:-0}"
BATCH_PAUSE="${BATCH_PAUSE:-60}"
# Budget for input prompt in characters (~4 chars/token, 8000 token limit, minus headroom)
MAX_INPUT_CHARS="${MAX_INPUT_CHARS:-28000}"
CLUSTERS_DIR="${REPO_ROOT}/clusters"

request_count=0

# Directories that contain shared/supporting config, not individual components
SUPPORT_DIRS="shared services imagerepositories vmservicescrape rules templates vmalertmanagerconfig config ci-excluded .config"

# HelmRepository name → URL mapping (populated per-component from rendered YAML)
declare -A REPO_URL_MAP
declare -A FILTER_COMPONENTS  # resolved component paths to generate
declare -A FILTER_CLUSTERS    # clusters that have matching components
docs_generated=0
skipped_too_large=()

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

  # Write prompts and payload to temp files to avoid shell ARG_MAX limits
  local payload_file system_file user_file
  payload_file=$(mktemp)
  system_file=$(mktemp)
  user_file=$(mktemp)
  printf '%s' "$system_prompt" > "$system_file"
  printf '%s' "$user_prompt" > "$user_file"
  jq -n \
    --arg model "$MODEL" \
    --rawfile system "$system_file" \
    --rawfile user "$user_file" \
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
    }' > "$payload_file" || {
    warn "Failed to build API payload" >&2
    rm -f "$payload_file" "$system_file" "$user_file"
    return 1
  }
  rm -f "$system_file" "$user_file"

  local response_file
  response_file=$(mktemp)
  local http_code
  http_code=$(curl -s -w '%{http_code}' -o "$response_file" \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "@${payload_file}" \
    "$API_URL") || true
  rm -f "$payload_file"

  if [ "$http_code" -ge 400 ] 2>/dev/null || [ -z "$http_code" ]; then
    warn "API call failed (request #${request_count}, HTTP ${http_code})" >&2
    warn "Response: $(cat "$response_file")" >&2
    # Return 2 for payload too large (HTTP 413 or tokens_limit_reached) — caller can skip
    if [ "$http_code" = "413" ] || grep -q "tokens_limit_reached" "$response_file" 2>/dev/null; then
      rm -f "$response_file"
      return 2
    fi
    rm -f "$response_file"
    return 1
  fi

  jq -r '.choices[0].message.content // empty' "$response_file"
  rm -f "$response_file"
}

###############################################################################
# Model call wrapper with error handling
# On success: sets _model_result, returns 0
# On payload too large (rc=2): warns, records skip, returns 1
# On other errors: aborts the script
###############################################################################
_model_result=""

call_model_or_abort() {
  local name="$1"
  local system_prompt="$2"
  local user_prompt="$3"

  _model_result=""
  local rc=0
  _model_result=$(call_model "$system_prompt" "$user_prompt") || rc=$?
  if [ "$rc" -eq 2 ]; then
    warn "Skipping ${name}: payload too large for model"
    skipped_too_large+=("$name")
    return 1
  elif [ "$rc" -ne 0 ]; then
    warn "API call failed for ${name}, aborting"
    exit 1
  fi
}

###############################################################################
# Navigation / frontmatter helpers
###############################################################################

# Format a docs category path as a nav title
# apps → Apps, infrastructure/core → Infrastructure / Core
format_category_title() {
  local path="$1"
  local result=""
  local IFS='/'
  for part in $path; do
    [ -n "$result" ] && result+=" / "
    result+="${part^}"
  done
  echo "$result"
}

# Write a doc file with Jekyll frontmatter prepended
# Usage: write_doc output_file content "key: value" "key: value" ...
write_doc() {
  local output_file="$1"
  local content="$2"
  shift 2
  mkdir -p "$(dirname "$output_file")"
  {
    echo "---"
    printf '%s\n' "$@"
    echo "---"
    echo ""
    echo "$content"
  } > "$output_file"
}

# Create a category index page for the nav hierarchy (idempotent)
ensure_category_page() {
  local cluster_name="$1"
  local docs_category="$2"
  local category_title="$3"

  local page="${DOCS_DIR}/${cluster_name}/${docs_category}/index.md"
  [ -f "$page" ] && return 0

  write_doc "$page" "" \
    "title: \"${category_title}\"" \
    "parent: \"${cluster_name}\"" \
    "has_children: true"
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
  local category_title="${7:-}"

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
  # Split into metadata (small, always included) and helm templates (large, budget-dependent)
  local hr_metadata=""
  local hr_templates=""
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

      hr_metadata+="### HelmRelease: ${hr_name}"$'\n'
      hr_metadata+="- Chart: ${chart}"$'\n'
      hr_metadata+="- Version: ${display_version}"$'\n'
      hr_metadata+="- Repository: ${repo_name} (${repo_url}) [${repo_type}]"$'\n'
      hr_metadata+="- Release Name: ${release_name}"$'\n'
      hr_metadata+="- Target Namespace: ${target_ns}"$'\n'
      hr_metadata+="- Reconciliation Interval: ${interval}"$'\n'

      if [ -n "$deps" ]; then
        hr_metadata+="- Dependencies: ${deps}"$'\n'
        dep_context+="- ${hr_name} depends on: ${deps}"$'\n'
      fi
      hr_metadata+=$'\n'

      # Extract values and run helm template for public charts
      local values_file
      values_file=$(extract_helm_values "$rendered" "$hr_name" "$tmpdir")

      local helm_output
      helm_output=$(helm_template_release "$chart" "$version" "$repo_name" \
        "$release_name" "$target_ns" "$values_file")

      if [ -n "$helm_output" ]; then
        local helm_tmp="${tmpdir}/${hr_name}-helm-output.yaml"
        echo "$helm_output" > "$helm_tmp"

        # Resource summary goes in metadata (small and useful)
        local resource_summary
        resource_summary=$(grep '^kind:' "$helm_tmp" | sed 's/kind: //' | sort | uniq -c | sort -rn | \
          awk '{print "  - " $2 " (" $1 ")"}')
        hr_metadata+="#### Rendered Kubernetes Resources (via helm template):"$'\n'
        hr_metadata+="${resource_summary}"$'\n\n'

        # Full helm template output is separate (large, may be omitted)
        local template_lines
        template_lines=$(wc -l < "$helm_tmp")
        hr_templates+="<helm-template-output release=\"${hr_name}\" lines=\"${template_lines}\">"$'\n'
        if [ "$template_lines" -gt 200 ]; then
          hr_templates+="$(head -200 "$helm_tmp")"$'\n'
          hr_templates+="... (truncated, ${template_lines} total lines)"$'\n'
        else
          hr_templates+="${helm_output}"$'\n'
        fi
        hr_templates+="</helm-template-output>"$'\n\n'
      fi

    done <<< "$hr_lines"
  fi

  # List all resource kinds in the flux build output
  local all_kinds
  all_kinds=$(echo "$rendered" | grep '^kind:' | sed 's/kind: //' | sort | uniq -c | sort -rn | \
    awk '{print $2 " (" $1 ")"}' | tr '\n' ', ' | sed 's/,$//')

  local system_prompt
  system_prompt=$(load_prompt "component-system")
  local instructions
  instructions=$(load_prompt "component-user")

  # Build user prompt: assemble core sections first, then add helm templates if within budget
  local user_prompt
  user_prompt="Generate documentation for component '${component_name}' deployed in cluster '${cluster_name}'.

=== Flux Build Output (Kustomize-rendered manifests) ===
${rendered}

"

  if [ -n "$hr_metadata" ]; then
    user_prompt+="=== HelmRelease Details (${hr_count} release(s)) ===
${hr_metadata}
"
  fi

  if [ -n "$dep_context" ]; then
    user_prompt+="=== Dependency Graph ===
${dep_context}
"
  fi

  user_prompt+="=== Resource Summary ===
All Kubernetes resource kinds in this component: ${all_kinds}

${instructions}"

  # Add helm template output if within token budget
  if [ -n "$hr_templates" ]; then
    local prompt_len=$(( ${#system_prompt} + ${#user_prompt} + 500 ))
    local remaining=$((MAX_INPUT_CHARS - prompt_len))
    if [ "$remaining" -gt 1000 ]; then
      if [ "${#hr_templates}" -le "$remaining" ]; then
        user_prompt+=$'\n\n'"=== Helm Template Output ==="$'\n'"${hr_templates}"
      else
        log "    Truncating helm template output to fit token limit"
        user_prompt+=$'\n\n'"=== Helm Template Output (truncated) ==="$'\n'"${hr_templates:0:$remaining}"$'\n'"... (truncated to fit token limit)"
      fi
    else
      log "    Omitting helm template output to fit within token limit"
    fi
  fi

  # Final safety: truncate entire prompt if still over budget
  local total_len=$(( ${#system_prompt} + ${#user_prompt} + 500 ))
  if [ "$total_len" -gt "$MAX_INPUT_CHARS" ]; then
    local budget=$((MAX_INPUT_CHARS - ${#system_prompt} - 500))
    log "    Truncating prompt from ${#user_prompt} to ${budget} chars"
    user_prompt="${user_prompt:0:$budget}"$'\n'"... (truncated to fit token limit)"
  fi

  call_model_or_abort "$component_name" "$system_prompt" "$user_prompt" || {
    rm -rf "$tmpdir"
    return 0
  }

  rm -rf "$tmpdir"
  local fm_args=("title: \"${component_name}\"")
  if [ -n "$category_title" ]; then
    fm_args+=("parent: \"${category_title}\"" "grand_parent: \"${cluster_name}\"")
  fi
  write_doc "$output_file" "$_model_result" "${fm_args[@]}"
  docs_generated=$((docs_generated + 1))
  log "  Generated: ${output_file#"${REPO_ROOT}"/}"
}

# Generate doc for standalone resources (layer-level YAML files without kustomization.yaml)
generate_resources_doc() {
  local layer_path="$1"
  local layer_name="$2"
  local cluster_name="$3"
  local output_file="$4"
  local category_title="${5:-}"

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

  call_model_or_abort "${layer_name} resources" "$system_prompt" "$user_prompt" || return 0

  local fm_args=("title: \"${layer_name} resources\"")
  if [ -n "$category_title" ]; then
    fm_args+=("parent: \"${category_title}\"" "grand_parent: \"${cluster_name}\"")
  fi
  write_doc "$output_file" "$_model_result" "${fm_args[@]}"
  docs_generated=$((docs_generated + 1))
  log "  Generated: ${output_file#"${REPO_ROOT}"/}"
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
    local app_list=()
    for d in "${REPO_ROOT}/apps/${cluster_name}"/*/; do
      [ -d "$d" ] || continue
      local name
      name=$(basename "$d")
      case "$name" in *.config|ci-excluded) continue ;; esac
      app_list+=("$name")
    done
    apps=$(IFS=,; echo "${app_list[*]}")
  fi

  local system_prompt
  system_prompt=$(load_prompt "overview-system")

  local user_prompt
  user_prompt="Generate an overview for cluster '${cluster_name}'.

Flux Kustomization entrypoints:
${context}

Applications deployed: ${apps:-none}

$(load_prompt "overview-user")"

  call_model_or_abort "${cluster_name} overview" "$system_prompt" "$user_prompt" || return 0

  write_doc "$output_file" "$_model_result" \
    "title: \"${cluster_name}\"" \
    "has_children: true"
  docs_generated=$((docs_generated + 1))
  log "  Generated: ${output_file#"${REPO_ROOT}"/}"
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
        [ "$name" = "index" ] && continue
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
          [ "$name" = "index" ] && continue
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

  call_model_or_abort "index" "$system_prompt" "$user_prompt" || return 0

  write_doc "$output_file" "$_model_result" \
    "title: \"Home\"" \
    "nav_order: 0"
  log "  Generated: ${output_file#"${REPO_ROOT}"/}"
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
  docs_category="${ks_path%/"${cluster_name}"}"

  local category_title
  category_title=$(format_category_title "$docs_category")

  log "Processing: ${ks_name} (${ks_path}) → ${category_title}"

  # Ensure category nav page exists
  ensure_category_page "$cluster_name" "$docs_category" "$category_title"

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
      "$component_name" "$cluster_name" "$output_file" "$category_title"
  done

  if [ "$has_components" = "true" ]; then
    # Also document standalone YAML files at the layer level (e.g. vmagent.yaml)
    local resources_output="${DOCS_DIR}/${cluster_name}/${docs_category}/resources.md"
    if should_generate "${ks_path}" "$resources_output"; then
      local layer_name
      layer_name=$(basename "$docs_category")
      generate_resources_doc "$full_path" "$layer_name" "$cluster_name" "$resources_output" "$category_title"
    fi
  else
    # No component subdirs — render the whole layer as one doc
    local layer_name
    layer_name=$(basename "$docs_category")
    local output_file="${DOCS_DIR}/${cluster_name}/${docs_category}/${layer_name}.md"

    if should_generate "${ks_path}" "$output_file"; then
      generate_component_doc "$ks_name" "$ks_file" "$ks_path" \
        "$layer_name" "$cluster_name" "$output_file" "$category_title"
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

  # Copy Jekyll config and any other static pages assets
  mkdir -p "$DOCS_DIR"
  local pages_dir="${REPO_ROOT}/scripts/ci/pages"
  if [ -d "$pages_dir" ]; then
    cp -a "${pages_dir}/." "$DOCS_DIR/"
    log "Copied pages assets from ${pages_dir#"${REPO_ROOT}"/}"
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
  log "Documentation generation complete: ${docs_generated} generated, ${total} total files in ${DOCS_DIR#"${REPO_ROOT}"/}"

  if [ "${#skipped_too_large[@]}" -gt 0 ]; then
    warn "Skipped ${#skipped_too_large[@]} component(s) due to payload size limits:"
    for name in "${skipped_too_large[@]}"; do
      warn "  - ${name}"
    done
  fi
}

main "$@"
