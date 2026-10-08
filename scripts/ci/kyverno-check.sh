#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TENANT="${1:?usage: kyverno-check.sh <tenant>}"
KYVERNO_VERSION="${KYVERNO_VERSION:-v1.19.1}"

if ! command -v kyverno >/dev/null 2>&1 || [[ "$(kyverno version 2>/dev/null)" != *"${KYVERNO_VERSION#v}"* ]]; then
  bin_dir="${RUNNER_TEMP:-/tmp}/kyverno-${KYVERNO_VERSION}"
  mkdir -p "$bin_dir"
  curl -sSfL "https://github.com/kyverno/kyverno/releases/download/${KYVERNO_VERSION}/kyverno-cli_${KYVERNO_VERSION}_linux_x86_64.tar.gz" \
    | tar xz -C "$bin_dir" kyverno
  export PATH="$bin_dir:$PATH"
fi

python3 -c 'import yaml' 2>/dev/null || python3 -m pip install --quiet --user pyyaml

python3 "$SCRIPT_DIR/kyverno-check.py" "$TENANT"
