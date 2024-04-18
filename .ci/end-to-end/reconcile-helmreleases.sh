#!/bin/bash
HELM_RELEASES="${HELM_RELEASES:-$1}"
RECONCILED=()
ORIG_IFS=$IFS
IFS=","

function fail() {
    local helmrelease=$1
    local message=$2
    if [ -n "${message}" ]; then
        echo $message
    fi
    echo "failing_helmrelease=$helmrelease" >> "$GITHUB_OUTPUT"
    exit 1;
}

function reconcile() {
    local helmrelease=$1
    # check helmrelease actually exists
    check_exists=$(flux get helmrelease $helmrelease 2>/dev/null || true)
    if [ -n "${check_exists}" ]; then
        dependencies=$(kubectl get -n flux-system helmrelease/$helmrelease -o yaml | yq -e -r '[ .spec.dependsOn[].name ] | join(",")' 2>/dev/null || true)

        if [ -n "${dependencies}" ]; then
            echo "Reconciling dependencies..."
            for dependency in $dependencies; do
                reconcile "$dependency"
            done
        fi
        IFS=$ORIG_IFS
        if [[ " ${RECONCILED[*]} " =~ [[:space:]]${helmrelease}[[:space:]] ]]; then
            echo "$helmrelease previously reconciled, skipping"
        else
            IFS=","
            echo "Reconciling $helmrelease"
            echo "test_matrix=$helmreleases_out" >> "$GITHUB_OUTPUT"
            flux reconcile helmrelease $helmrelease --timeout=15m || fail "$helmrelease" "Failed reconciling helmrelease: $helmrelease";
            kubectl -n flux-system wait helmrelease/$helmrelease --for=condition=ready --timeout=15m || fail "$helmrelease" "Failed ready condition for helmrelease: $helmrelease";
            RECONCILED+=($helmrelease)
        fi
        IFS=","
    else
        echo "$helmrelease doesn't exist. skipping"
    fi
}

for helmrelease in $HELM_RELEASES; do
    echo "::group::HelmRelease $helmrelease"
    reconcile "$helmrelease"
    echo "::endgroup::"
done
