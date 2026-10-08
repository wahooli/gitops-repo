#!/usr/bin/env bash

set -euo pipefail

VARS_DIR="$REPO_ROOT/local-clusters/$CLUSTER_NAME/bootstrap"
[[ -d "$VARS_DIR" ]] || exit 0

mapfile -t HOST_PATHS < <(python3 - "$VARS_DIR" "$REPO_ROOT" <<'EOF'
import base64
import glob
import json
import os
import re
import subprocess
import sys

vars_dir, repo = sys.argv[1], sys.argv[2]
variables = {}
for f in glob.glob(os.path.join(vars_dir, "**", "*.y*ml"), recursive=True):
    out = subprocess.run(["yq", "-o=json", "-I=0", 'select(.kind == "Secret" or .kind == "ConfigMap")', f],
                         capture_output=True, text=True).stdout
    for line in out.splitlines():
        if not line.strip():
            continue
        doc = json.loads(line)
        variables.update(doc.get("stringData") or {})
        for k, v in (doc.get("data") or {}).items():
            variables[k] = base64.b64decode(v).decode() if doc["kind"] == "Secret" else v

template = re.compile(r'^\s*path:\s*"?(\S*\$\{[_a-zA-Z][_a-zA-Z0-9]*\}\S*?)"?\s*$')
var = re.compile(r"\$\{([_a-zA-Z][_a-zA-Z0-9]*)\}")
paths = set()
for root in ("apps", "infrastructure"):
    for f in glob.glob(os.path.join(repo, root, "**", "*.yaml"), recursive=True):
        for line in open(f):
            m = template.match(line)
            if not m or not all(name in variables for name in var.findall(m.group(1))):
                continue
            path = var.sub(lambda v: variables[v.group(1)], m.group(1))
            if path.startswith("/"):
                paths.add(path)
print("\n".join(sorted(paths)))
EOF
)

[[ ${#HOST_PATHS[@]} -gt 0 && -n "${HOST_PATHS[0]}" ]] || exit 0

for node in $(docker ps --filter "name=k3d-$CLUSTER_NAME-" --format "{{.Names}}" | grep -E -- '-(server|agent)-'); do
  echo "  Creating ${#HOST_PATHS[@]} writable hostPath directories in $node"
  docker exec "$node" sh -c 'for p in "$@"; do mkdir -p "$p" && chmod a+rwx "$p"; done' sh "${HOST_PATHS[@]}"
done
