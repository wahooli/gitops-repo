#!/usr/bin/env bash
HELM_RELEASES="${HELM_RELEASES:-$1}"
DEBUG_STORAGE="${DEBUG_STORAGE:-false}"
DEBUG_LOGS="${DEBUG_LOGS:-false}"
DEBUG_LOGS_NAMESPACES="${DEBUG_LOGS_NAMESPACES:-default cert-manager internal-dns}"
DESCRIBE_PODS_NAMESPACES="${DESCRIBE_PODS_NAMESPACES:-default cert-manager monitoring}"

echo "::group::Describe all cluster nodes"
kubectl describe nodes -A
echo "::endgroup::"

echo "::group::flux-system GitRepository definition"
kubectl get gitrepository -n flux-system flux-system -o yaml
echo "::endgroup::"

echo "::group::All in flux-system namespace"
kubectl -n flux-system get all
echo "::endgroup::"

echo "::group::FluxCD source-controller logs"
kubectl -n flux-system logs deploy/source-controller
echo "::endgroup::"

echo "::group::FluxCD kustomize-controller logs"
kubectl -n flux-system logs deploy/kustomize-controller
echo "::endgroup::"

echo "::group::FluxCD helm-controller logs"
kubectl -n flux-system logs deploy/helm-controller
echo "::endgroup::"

echo "::group::All FluxCD resources"
flux get all --all-namespaces
echo "::endgroup::"

echo "::group::Pods in all namespaces"
kubectl get pods --all-namespaces
echo "::endgroup::"

for namespace in ${DESCRIBE_PODS_NAMESPACES}; do
    echo "::group::Describe pods in ${namespace} namespace"
    kubectl describe pods -n ${namespace}
    echo "::endgroup::"
done

if [ "$DEBUG_LOGS" = true ]; then
    for namespace in ${DEBUG_LOGS_NAMESPACES}; do
        echo "::group::Logs for pods in ${namespace} namespace"
        pods=$(kubectl get pods -n $namespace -o jsonpath='{.items[*].metadata.name}')
        for pod in $pods; do
            echo "::group::Logs for pod $pod"
            kubectl logs -n $namespace $pod
            echo "::endgroup::"
        done
        echo "::endgroup::"
    done
fi

if [ "$DEBUG_STORAGE" = true ]; then
    echo "::group::All PVCs"
    kubectl get pvc -A
    echo "::endgroup::"

    echo "::group::Describe all PVCs"
    kubectl describe pvc -A
    echo "::endgroup::"

    echo "::group::Get all PVs"
    kubectl get pv -A
    echo "::endgroup::"

    echo "::group::Describe all PVs"
    kubectl describe pv
    echo "::endgroup::"

    echo "::group::Describe all StorageClasses"
    kubectl describe sc
    echo "::endgroup::"

    echo "::group::local-path-provisioner logs"
    kubectl logs -n local-path-storage deploy/local-path-provisioner
    echo "::endgroup::"

    echo "::group::local-path-storage namespaced events"
    kubectl events -n local-path-storage
    echo "::endgroup::"
fi


IFS=","
for helmrelease in $HELM_RELEASES; do
    echo "::group::Describe HelmRelease $helmrelease"
    kubectl describe helmrelease -n flux-system $helmrelease
    echo "::endgroup::"

    echo "::group::Events for HelmRelease $helmrelease"
    kubectl events -n flux-system --for HelmRelease/$helmrelease
    echo "::endgroup::"

    echo "::group::flux logs for HelmRelease $helmrelease"
    flux logs --kind=HelmRelease --name=$helmrelease
    echo "::endgroup::"
done