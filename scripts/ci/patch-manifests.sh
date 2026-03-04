#!/usr/bin/env bash
set -euo pipefail

# Patches YAML files in apps/ and infrastructure/ using configurable yq rules
# so workloads can schedule on a single CI node.
# Rules are defined in patch-manifests.yaml.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG="$SCRIPT_DIR/patch-manifests.yaml"

rule_count=$(yq '.rules | length' "$CONFIG")
# Use compact sequence indentation (-c) to match yamllint indent-sequences: false
YQ_OPTS=(-I2 -c)
patched=0

for file in $(find "$REPO_ROOT/apps" "$REPO_ROOT/infrastructure" -type f \( -name '*.yaml' -o -name '*.yml' \)); do
  # Capture comment-stripped snapshot to detect semantic changes only
  # (yq round-tripping reformats comments/blank lines, causing false positives)
  before=$(yq eval "${YQ_OPTS[@]}" '... comments=""' "$file" 2>/dev/null) || continue

  # Process rules through a temp file to handle error_tolerant rules individually
  tmpfile=$(mktemp)
  cp "$file" "$tmpfile"

  for (( i=0; i<rule_count; i++ )); do
    expression=$(yq ".rules[$i].expression" "$CONFIG")
    error_tolerant=$(yq ".rules[$i].error_tolerant // false" "$CONFIG")

    if [ "$error_tolerant" = "true" ]; then
      yq eval "${YQ_OPTS[@]}" "$expression" -i "$tmpfile" 2>/dev/null || true
    else
      yq eval "${YQ_OPTS[@]}" "$expression" -i "$tmpfile"
    fi
  done

  after=$(yq eval "${YQ_OPTS[@]}" '... comments=""' "$tmpfile")
  if [ "$after" != "$before" ]; then
    cp "$tmpfile" "$file"
    patched=$((patched + 1))
    echo "Patched: ${file#"$REPO_ROOT/"}"
  fi
  rm -f "$tmpfile"
done

echo "Done. Patched $patched file(s)."
