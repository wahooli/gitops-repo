#!/usr/bin/env bash
HELM_RELEASES="${HELM_RELEASES:-$1}"
DEBUG_STORAGE="${DEBUG_STORAGE:-false}"
DEBUG_LOGS="${DEBUG_LOGS:-false}"
DEBUG_LOGS_EXCLUDE_NS="${DEBUG_LOGS_EXCLUDE_NS:-kube-system kube-public kube-node-lease local-path-storage flux-system}"
DEBUG_NODES="${DEBUG_NODES:-false}"

# Run a command inside a collapsible group, suppressing stderr.
# Uses GitHub Actions syntax when on CI, plain headers locally.
# Usage: group "Title" command [args...]
group() {
  local title="$1"; shift
  if [ -n "$GITHUB_ACTIONS" ]; then
    echo "::group::${title}"
    "$@" 2>/dev/null || true
    echo "::endgroup::"
  else
    printf '\n\033[1;34m── %s ──\033[0m\n' "$title"
    "$@" 2>/dev/null || true
  fi
}

# shellcheck disable=SC2016
unhealthy_pod_filter='$4 != "Running" && $4 != "Completed" && $4 != "Succeeded"'

# ── 1. Failure Summary ──────────────────────────────────────────────

# flux get columns (tab-separated): NAMESPACE NAME REVISION SUSPENDED READY MESSAGE
# shellcheck disable=SC2016
group "Failure Summary: Flux Kustomizations" \
  bash -c 'flux get kustomization -A 2>/dev/null | awk -F"\t" "NR==1 || \$5 ~ /False/" || echo "All kustomizations ready"'

# shellcheck disable=SC2016
group "Failure Summary: HelmReleases" \
  bash -c 'flux get helmrelease -A 2>/dev/null | awk -F"\t" "NR==1 || (\$5 ~ /False/ && \$6 !~ /waiting to be reconciled/)" || echo "All HelmReleases ready"'

group "Failure Summary: Unhealthy Pods" \
  bash -c "kubectl get pods -A --no-headers 2>/dev/null | awk '${unhealthy_pod_filter}' || echo 'All pods healthy'"

group "Failure Summary: Recent Warning Events (last 30)" \
  bash -c 'kubectl events -A --types=Warning --sort-by=lastTimestamp 2>/dev/null | tail -n 30'

# ── 2. Unhealthy Pod Details ────────────────────────────────────────

kubectl get pods -A --no-headers 2>/dev/null \
  | awk "${unhealthy_pod_filter} { print \$1, \$2, \$4 }" \
  | while IFS=' ' read -r ns pod status; do
      group "Describe unhealthy pod: ${ns}/${pod} (${status})" \
        kubectl describe pod -n "$ns" "$pod"

      group "Logs for unhealthy pod: ${ns}/${pod}" \
        kubectl logs -n "$ns" "$pod" --tail=100

      if [ "$status" = "CrashLoopBackOff" ] || [ "$status" = "Error" ]; then
        group "Previous logs for: ${ns}/${pod}" \
          kubectl logs -n "$ns" "$pod" --previous --tail=100
      fi
    done

# ── 3. Failed HelmRelease Details ──────────────────────────────────

IFS=","
for helmrelease in $HELM_RELEASES; do
  group "Describe HelmRelease $helmrelease" \
    kubectl describe helmrelease -n flux-system "$helmrelease"

  group "Events for HelmRelease $helmrelease" \
    kubectl events -n flux-system --for "HelmRelease/$helmrelease"

  group "Flux logs for HelmRelease $helmrelease" \
    flux logs --kind=HelmRelease --name="$helmrelease"
done
unset IFS

# ── 4. Flux Controller Error Logs ──────────────────────────────────

for controller in kustomize-controller helm-controller; do
  group "${controller} errors" bash -c "
    errors=\$(kubectl -n flux-system logs deploy/${controller} 2>/dev/null | grep 'level=error')
    if [ -n \"\$errors\" ]; then
      echo \"\$errors\"
    else
      echo 'No error-level logs found, showing last 50 lines:'
      kubectl -n flux-system logs deploy/${controller} --tail=50 2>/dev/null
    fi
  "
done

# ── 5. Conditional Verbose Sections ────────────────────────────────

if [ "$DEBUG_STORAGE" = true ]; then
  group "All PVCs"              kubectl get pvc -A
  group "Describe all PVCs"     kubectl describe pvc -A
  group "All PVs"               kubectl get pv -A
  group "Describe all PVs"      kubectl describe pv
  group "All StorageClasses"    kubectl describe sc
  group "local-path-provisioner logs"   kubectl logs -n local-path-storage deploy/local-path-provisioner
  group "local-path-storage events"     kubectl events -n local-path-storage
fi

if [ "$DEBUG_LOGS" = true ]; then
  exclude_pattern=$(echo "$DEBUG_LOGS_EXCLUDE_NS" | tr ' ' '\n' | sed 's/^/^/;s/$/$/' | paste -sd '|')
  namespaces=$(kubectl get ns --no-headers -o custom-columns=':metadata.name' 2>/dev/null \
    | grep -Ev "$exclude_pattern" || true)

  for namespace in $namespaces; do
    group "${namespace} pod logs" bash -c "
      for pod in \$(kubectl get pods -n '$namespace' -o jsonpath='{.items[*].metadata.name}' 2>/dev/null); do
        printf '\n--- %s ---\n' \"\$pod\"
        kubectl logs -n '$namespace' \"\$pod\" 2>/dev/null || true
      done
    "
  done
fi

if [ "$DEBUG_NODES" = true ]; then
  group "Describe all cluster nodes" kubectl describe nodes -A
fi
