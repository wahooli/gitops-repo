#!/usr/bin/env bash
HELM_RELEASES="${HELM_RELEASES:-$1}"
DEBUG_STORAGE="${DEBUG_STORAGE:-false}"
DEBUG_LOGS="${DEBUG_LOGS:-false}"
DEBUG_LOGS_EXCLUDE_NS="${DEBUG_LOGS_EXCLUDE_NS:-kube-system kube-public kube-node-lease local-path-storage flux-system}"
DEBUG_NODES="${DEBUG_NODES:-false}"
DEBUG_DNS="${DEBUG_DNS:-false}"
DEBUG_DNS_NAMES="${DEBUG_DNS_NAMES:-kubernetes.default.svc.cluster.local github.com acme-v02.api.letsencrypt.org}"
DEBUG_DNS_IMAGE="${DEBUG_DNS_IMAGE:-busybox:1.37}"
DEBUG_K3S_LOG_SINCE="${DEBUG_K3S_LOG_SINCE:-2h}"

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

# Print tab-separated stdin as aligned columns when column(1) is available
table() {
  if command -v column >/dev/null; then column -t -s $'\t'; else cat; fi
}

# Names of a pod's containers (init containers included) that have restarted
restarted_containers() {
  kubectl get pod -n "$1" "$2" -o json 2>/dev/null | jq -r '
    ((.status.initContainerStatuses // []) + (.status.containerStatuses // []))[]
    | select(.restartCount > 0) | .name'
}

# Current logs of every container in a pod, then the previous logs of restarted ones
pod_logs() {
  local ns="$1" pod="$2"; shift 2
  kubectl logs -n "$ns" "$pod" --all-containers=true --prefix --timestamps "$@" 2>/dev/null || true
  for container in $(restarted_containers "$ns" "$pod"); do
    printf -- '--- %s/%s (previous) ---\n' "$pod" "$container"
    kubectl logs -n "$ns" "$pod" -c "$container" --previous --timestamps "$@" 2>/dev/null || true
  done
}

# Usage: namespace_logs <namespace> [label-selector]
namespace_logs() {
  local ns="$1" selector=()
  [ -n "${2:-}" ] && selector=(-l "$2")
  for pod in $(kubectl get pods -n "$ns" "${selector[@]}" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null); do
    printf '\n--- %s ---\n' "$pod"
    pod_logs "$ns" "$pod"
  done
}

not_ready_flux_objects() {
  for kind in kustomizations.kustomize.toolkit.fluxcd.io helmreleases.helm.toolkit.fluxcd.io; do
    kubectl get "$kind" -A -o json 2>/dev/null | jq -r '
      .items[]
      | ((.status.conditions // []) | map(select(.type == "Ready")) | .[0]) as $ready
      | select(($ready.status // "Unknown") != "True")
      | "\(.kind) \(.metadata.namespace)/\(.metadata.name)\(if .spec.suspend then " (suspended)" else "" end)"
        + " [\($ready.reason // "no status")]: \(($ready.message // "-") | gsub("\n"; " | "))"'
  done
}

restarted_containers_table() {
  {
    printf 'NAMESPACE\tPOD\tCONTAINER\tRESTARTS\tLAST REASON\tEXIT\tSTARTED\tFINISHED\n'
    kubectl get pods -A -o json 2>/dev/null | jq -r '
      .items[] | .metadata.namespace as $ns | .metadata.name as $pod
      | ((.status.initContainerStatuses // []) + (.status.containerStatuses // []))[]
      | select(.restartCount > 0)
      | [$ns, $pod, .name, (.restartCount | tostring),
         (.lastState.terminated.reason // "-"), ((.lastState.terminated.exitCode // "-") | tostring),
         (.lastState.terminated.startedAt // "-"), (.lastState.terminated.finishedAt // "-")] | @tsv'
  } | table
}

# ── DNS helpers ─────────────────────────────────────────────────────

# label=ip for every resolver worth asking: port-53 Services in kube-system and
# internal-dns, the pods behind them, and a public resolver as a reference
dns_servers() {
  local ns
  for ns in kube-system internal-dns; do
    kubectl -n "$ns" get svc -o json 2>/dev/null | jq -r --arg ns "$ns" '
      .items[] | select(.spec.clusterIP and .spec.clusterIP != "None")
      | select(any(.spec.ports[]?; .port == 53))
      | "svc/\($ns)/\(.metadata.name)=\(.spec.clusterIP)"'
    kubectl -n "$ns" get endpointslices -o json 2>/dev/null | jq -r --arg ns "$ns" '
      .items[] | select(any(.ports[]?; .port == 53)) | .endpoints[]?
      | "pod/\($ns)/\(.targetRef.name // "unknown")\(if .conditions.ready == false then "(not-ready)" else "" end)=\(.addresses[0])"'
  done | sort -u
  echo "public/1.1.1.1=1.1.1.1"
}

dns_configuration() {
  local cm
  for cm in $(kubectl -n kube-system get deploy coredns \
      -o jsonpath='{.spec.template.spec.volumes[*].configMap.name}' 2>/dev/null); do
    echo "### ConfigMap kube-system/${cm}"
    kubectl -n kube-system get configmap "$cm" -o json 2>/dev/null \
      | jq -r '.data // {} | to_entries[] | "--- \(.key) ---\n\(.value)"'
  done
  echo "### Resolver Services and EndpointSlices"
  kubectl -n kube-system get svc,endpointslices -l k8s-app=kube-dns -o wide 2>/dev/null
  kubectl -n internal-dns get svc,endpointslices -o wide 2>/dev/null
}

# Ask every resolver from dns_servers for each name in DEBUG_DNS_NAMES from a
# throwaway pod, one line per resolver and name: OK <address>, FAIL <rcode>, TIMEOUT
# shellcheck disable=SC2016
dns_probe_script='
check() {
  out=$(timeout 4 nslookup -type=a "$2" "$1" 2>&1)
  ans=$(printf "%s\n" "$out" | sed -n "/^Name:/,\$s/^Address: *//p" | head -n 1)
  if [ -n "$ans" ]; then res="OK $ans"
  else
    err=$(printf "%s\n" "$out" | grep -o "can.t find .*" | head -n 1)
    if [ -n "$err" ]; then res="FAIL ${err##*: }"
    elif [ -z "$out" ] || printf "%s" "$out" | grep -q "timed out"; then res="TIMEOUT"
    else res="ERROR $(printf "%s" "$out" | tr "\n" " " | cut -c1-80)"; fi
  fi
  printf "%-64s %-40s %s\n" "$3" "$2" "$res"
}
i=0
for server in "$@"; do
  i=$((i + 1))
  ( for name in $NAMES; do check "${server#*=}" "$name" "${server%%=*} (${server#*=})"; done ) > "/tmp/result.$i" 2>/dev/null &
done
wait
j=1
while [ "$j" -le "$i" ]; do cat "/tmp/result.$j"; j=$((j + 1)); done
'

dns_probe() {
  local servers=()
  mapfile -t servers < <(dns_servers)
  kubectl -n kube-system delete pod debug-dns-probe --ignore-not-found --wait=true >/dev/null 2>&1
  timeout 180 kubectl -n kube-system run debug-dns-probe \
    --image="$DEBUG_DNS_IMAGE" --image-pull-policy=IfNotPresent --restart=Never \
    --rm -i --quiet --pod-running-timeout=2m --env="NAMES=${DEBUG_DNS_NAMES}" \
    --command -- sh -c "$dns_probe_script" probe "${servers[@]}" 2>&1
  kubectl -n kube-system delete pod debug-dns-probe --ignore-not-found --wait=false >/dev/null 2>&1
}

# ── Node helpers ────────────────────────────────────────────────────

node_containers() {
  command -v docker >/dev/null || return 0
  kubectl get nodes -o jsonpath='{.items[*].metadata.name}' 2>/dev/null
}

host_resources() {
  uptime
  free -m
  df -h / /var/lib/docker 2>/dev/null
  if command -v docker >/dev/null; then
    docker stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.PIDs}}'
    for node in $(node_containers); do
      docker inspect -f '{{.Name}} restarts={{.RestartCount}} started={{.State.StartedAt}} oomKilled={{.State.OOMKilled}}' "$node"
    done
  fi
  echo "### Kernel OOM kills"
  sudo -n dmesg -T 2>/dev/null | grep -iE 'out of memory|oom-kill|killed process' | tail -n 30 || echo "dmesg unavailable"
}

k3s_server_logs() {
  local node t action code
  for node in $(node_containers); do
    echo "### ${node}: container die/oom/kill events"
    timeout 20 docker events --since "$DEBUG_K3S_LOG_SINCE" --until "$(date +%s)" --filter "container=${node}" \
        --filter event=die --filter event=oom --filter event=kill \
        --format '{{.Time}} {{.Action}} {{index .Actor.Attributes "exitCode"}}{{index .Actor.Attributes "signal"}}' \
      | while read -r t action code; do
          echo "$(date -u -d "@${t}" +%Y-%m-%dT%H:%M:%SZ) ${action} ${code:+(exit code/signal ${code})}"
        done
    echo "### ${node}: last 80 log lines before each k3s restart"
    docker logs --since "$DEBUG_K3S_LOG_SINCE" "$node" 2>&1 | awk '
      /msg="Starting k3s v/ {
        if (starts++) {
          print "--- before start #" starts " ---"
          for (i = (c > 80 ? c - 79 : 1); i <= c; i++) print buf[i % 80]
        }
        c = 0
      }
      { buf[++c % 80] = $0 }'
    echo "### ${node}: fatal, leader election and startup lines"
    docker logs --since "$DEBUG_K3S_LOG_SINCE" "$node" 2>&1 \
      | grep -E '^F[0-9]{4} |level=fatal|leaderelection|lost lease|apiserver not ready|msg="Starting k3s v|Shutting down|signal'
    echo "### ${node}: errors (last 150)"
    docker logs --since "$DEBUG_K3S_LOG_SINCE" "$node" 2>&1 | grep -E '^E[0-9]{4} |level=error' | tail -n 150
  done
}

dns_conntrack() {
  for node in $(node_containers); do
    echo "### ${node}: UDP/TCP port 53 flows"
    docker exec "$node" sh -c 'cat /proc/net/nf_conntrack 2>/dev/null || conntrack -L 2>/dev/null' \
      | grep -E 'dport=53 ' | head -n 120
  done
}

# Top containers by memory working set, from the kubelet's CRI stats on each node
container_usage() {
  for node in $(node_containers); do
    echo "### ${node}"
    docker exec "$node" crictl stats -o json 2>/dev/null | jq -r '
      [.stats[] | {
        ns: (.attributes.labels["io.kubernetes.pod.namespace"] // "-"),
        pod: (.attributes.labels["io.kubernetes.pod.name"] // "-"),
        container: (.attributes.metadata.name // "-"),
        mem: ((.memory.workingSetBytes.value // "0") | tonumber),
        cpu: ((.cpu.usageNanoCores.value // "0") | tonumber)
      }]
      | "total: \(map(.mem) | add / 1048576 | floor) MiB in \(length) containers",
        "MiB\tmCPU\tNAMESPACE\tPOD\tCONTAINER",
        (sort_by(-.mem)[:30][] | "\(.mem / 1048576 | floor)\t\(.cpu / 1000000 | floor)\t\(.ns)\t\(.pod)\t\(.container)")' \
      | { read -r total && echo "$total" && table; } || docker exec "$node" crictl stats 2>/dev/null
  done
}

cilium_state() {
  if command -v cilium >/dev/null; then
    cilium status 2>&1 | head -n 40
  fi
  echo "### Service frontends on port 53"
  kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg service list 2>/dev/null \
    | awk 'NR == 1 { print; next } $2 ~ /:/ { show = ($2 ~ /:53\//) } show'
  echo "### Non-zero drop counters"
  kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg metrics list 2>/dev/null \
    | grep -E '^cilium_drop_(count|bytes)_total' | awk '$NF + 0 > 0'
  echo "### Agent warnings and errors (last 100)"
  kubectl -n kube-system logs ds/cilium -c cilium-agent --timestamps 2>/dev/null \
    | grep -iE 'level=(warn|warning|error|fatal)' | tail -n 100
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

group "Failure Summary: Not-ready Flux objects (full messages)" not_ready_flux_objects

group "Failure Summary: Unhealthy Pods" \
  bash -c "kubectl get pods -A --no-headers 2>/dev/null | awk '${unhealthy_pod_filter}' || echo 'All pods healthy'"

group "Failure Summary: Restarted containers" restarted_containers_table

group "Failure Summary: Recent Warning Events (last 50, without PolicyViolation)" \
  bash -c 'kubectl events -A --types=Warning 2>/dev/null | grep -v PolicyViolation | tail -n 50'

group "Failure Summary: API server readiness" \
  bash -c 'kubectl get --raw="/readyz?verbose" 2>&1 | grep -vE "^\[\+\]"'

group "Failure Summary: Kyverno policies" \
  kubectl get validatingpolicies.policies.kyverno.io,mutatingpolicies.policies.kyverno.io

# ── 2. Unhealthy Pod Details ────────────────────────────────────────

kubectl get pods -A --no-headers 2>/dev/null \
  | awk "${unhealthy_pod_filter} { print \$1, \$2, \$4 }" \
  | while IFS=' ' read -r ns pod status; do
      group "Describe unhealthy pod: ${ns}/${pod} (${status})" \
        kubectl describe pod -n "$ns" "$pod"

      group "Logs for unhealthy pod: ${ns}/${pod}" \
        pod_logs "$ns" "$pod" --tail=100
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

for controller in source-controller kustomize-controller helm-controller; do
  group "${controller} errors" bash -c "
    errors=\$(kubectl -n flux-system logs deploy/${controller} 2>/dev/null | grep -E '\"level\":\"error\"|level=error' | tail -n 100)
    if [ -n \"\$errors\" ]; then
      echo \"\$errors\"
    else
      echo 'No error-level logs found, showing last 50 lines:'
      kubectl -n flux-system logs deploy/${controller} --tail=50 2>/dev/null
    fi
  "
done

# ── 5. Conditional Verbose Sections ────────────────────────────────

if [ "$DEBUG_DNS" = true ]; then
  group "DNS: CoreDNS configuration and resolver endpoints" dns_configuration
  group "DNS: probe of every resolver" dns_probe
  group "DNS: CoreDNS logs" namespace_logs kube-system k8s-app=kube-dns
  group "DNS: conntrack entries for port 53 on the nodes" dns_conntrack
fi

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
    group "${namespace} pod logs" namespace_logs "$namespace"
  done
fi

if [ "$DEBUG_NODES" = true ]; then
  group "Describe all cluster nodes" kubectl describe nodes -A
  group "Node: host resources and node container state" host_resources
  group "Node: k3s restarts, fatal and error lines" k3s_server_logs
  group "Node: top containers by memory" container_usage
  group "Node: Cilium state" cilium_state
fi
