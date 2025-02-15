#!/bin/bash
TENANT="${TENANT:-$1}"
KUSTOMIZATIONS="${KUSTOMIZATIONS:-$1}"
KUSTOMIZATION_TIMEOUT="${KUSTOMIZATION_TIMEOUT:-10m}"

function validate_kustomization() {
    local kustomization_file="$1"
    local strict="$2"
    if [ ! -f "$kustomization_file" ]; then
        echo "$kustomization_file doesn't exist!"
        exit 1
    fi
    kustomization=$(yq -r 'select(.kind == "Kustomization") | .metadata.name' $kustomization_file)
    if [ -z "$kustomization" ] && [ "true" == "$strict" ]; then
        echo "$kustomization_file is not Kustomization kind!"
        exit 1
    elif [ ! -z "$kustomization" ]; then
        path=$(yq -r ".spec.path" $kustomization_file)
        namespace=$(yq -r ".metadata.namespace" $kustomization_file)
        
        echo "::group::Kustomization $kustomization"

        echo "kustomization file path: $kustomization_file"

        echo -n "flux build kustomization $kustomization"
        flux build kustomization $kustomization -n $namespace --kustomization-file $kustomization_file --path $path > /dev/null && echo ": success!" || (echo ": failure!" && exit 1)
        
        echo "flux reconcile"
        flux reconcile kustomization $kustomization -n $namespace --timeout=${KUSTOMIZATION_TIMEOUT} || exit 1

        echo "kubectl wait"
        kubectl -n $namespace wait kustomization/$kustomization  --for=condition=ready --timeout=${KUSTOMIZATION_TIMEOUT} || exit 1

        echo "::endgroup::"
    fi
}

if [ ! -d "clusters/${TENANT}" ] || [ -z "$TENANT" ]; then
    echo "Tenant '$TENANT' not found!"
    exit 1
fi


if [ -z "$KUSTOMIZATIONS" ]; then
    echo "Iterating files in clusters/${TENANT}"
    for file in $(cd clusters/${TENANT} && ls -dv1 *); do
        kustomization_file="clusters/${TENANT}/${file}"
        [[ -f $kustomization_file ]] && validate_kustomization "${kustomization_file}"
    done
else
    IFS=","
    for kustomization in $KUSTOMIZATIONS; do
        kustomization_file="clusters/${TENANT}/${kustomization}.yaml"
        validate_kustomization "${kustomization_file}" "true"
    done
fi

exit 0