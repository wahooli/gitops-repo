#!/usr/bin/env bash
set -euo pipefail

# Verify authentik blueprint-apply deployment.
# Exits 0 immediately if the deployment does not exist (optional step).
# If it exists: tails init container logs, then checks pod reaches Running.

NAMESPACE="${BLUEPRINT_NAMESPACE:-authentik}"
DEPLOYMENT="${BLUEPRINT_DEPLOYMENT:-authentik-apply-blueprints}"
INIT_CONTAINER="${BLUEPRINT_INIT_CONTAINER:-apply-blueprints}"
TIMEOUT="${BLUEPRINT_VERIFY_TIMEOUT:-600}"

CONTEXT_ARGS=()
if [[ -n "${CONTEXT:-}" ]]; then
  CONTEXT_ARGS=(--context "$CONTEXT")
fi

group_start() { [[ -n "${GITHUB_ACTIONS:-}" ]] && echo "::group::$1" || echo "--- $1 ---"; }
group_end() { [[ -n "${GITHUB_ACTIONS:-}" ]] && echo "::endgroup::" || true; }

# Check if deployment exists
if ! kubectl "${CONTEXT_ARGS[@]}" -n "$NAMESPACE" get deployment "$DEPLOYMENT" &>/dev/null; then
  echo "Deployment $NAMESPACE/$DEPLOYMENT not found, skipping."
  exit 0
fi

echo "Found deployment $NAMESPACE/$DEPLOYMENT"

# Wait for a pod to appear
echo "Waiting for pod..."
elapsed=0
pod=""
while [[ $elapsed -lt $TIMEOUT ]]; do
  pod=$(kubectl "${CONTEXT_ARGS[@]}" -n "$NAMESPACE" get pods \
    -l "app=$DEPLOYMENT" --field-selector=status.phase!=Succeeded \
    -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
  [[ -n "$pod" ]] && break
  sleep 3
  elapsed=$((elapsed + 3))
done

if [[ -z "$pod" ]]; then
  echo "ERROR: No pod appeared for deployment $DEPLOYMENT within ${TIMEOUT}s"
  exit 1
fi

echo "Pod: $pod"

# Wait for init container to leave Waiting state
echo "Waiting for init container '$INIT_CONTAINER' to start..."
elapsed=0
while [[ $elapsed -lt $TIMEOUT ]]; do
  running=$(kubectl "${CONTEXT_ARGS[@]}" -n "$NAMESPACE" get pod "$pod" \
    -o jsonpath="{.status.initContainerStatuses[?(@.name=='$INIT_CONTAINER')].state.running}" 2>/dev/null || true)
  terminated=$(kubectl "${CONTEXT_ARGS[@]}" -n "$NAMESPACE" get pod "$pod" \
    -o jsonpath="{.status.initContainerStatuses[?(@.name=='$INIT_CONTAINER')].state.terminated}" 2>/dev/null || true)
  if [[ -n "$running" || -n "$terminated" ]]; then
    break
  fi
  sleep 3
  elapsed=$((elapsed + 3))
done

# Tail init container logs (follows until container exits)
group_start "Blueprint apply logs ($INIT_CONTAINER)"
kubectl "${CONTEXT_ARGS[@]}" -n "$NAMESPACE" logs "$pod" -c "$INIT_CONTAINER" -f 2>/dev/null || true
group_end

# Check init container exit code
exit_code=$(kubectl "${CONTEXT_ARGS[@]}" -n "$NAMESPACE" get pod "$pod" \
  -o jsonpath="{.status.initContainerStatuses[?(@.name=='$INIT_CONTAINER')].state.terminated.exitCode}" 2>/dev/null || true)

if [[ "$exit_code" != "0" ]]; then
  echo "ERROR: Init container '$INIT_CONTAINER' failed (exit code: ${exit_code:-unknown})"
  reason=$(kubectl "${CONTEXT_ARGS[@]}" -n "$NAMESPACE" get pod "$pod" \
    -o jsonpath="{.status.initContainerStatuses[?(@.name=='$INIT_CONTAINER')].state.terminated.reason}" 2>/dev/null || true)
  [[ -n "$reason" ]] && echo "Reason: $reason"
  exit 1
fi

echo "Init container completed successfully."

# Verify pod reaches Running (pause container started)
echo "Verifying pod reaches Running state..."
if kubectl "${CONTEXT_ARGS[@]}" -n "$NAMESPACE" wait pod "$pod" \
  --for=condition=Ready --timeout=60s &>/dev/null; then
  echo "Pod $pod is Running."
else
  phase=$(kubectl "${CONTEXT_ARGS[@]}" -n "$NAMESPACE" get pod "$pod" \
    -o jsonpath='{.status.phase}' 2>/dev/null || true)
  echo "WARNING: Pod did not reach Ready state. Phase: ${phase:-unknown}"
  exit 1
fi
