#!/usr/bin/env bash

echo "::group::Creating JSON array of cluster parameter"
tenants="${@:1}"
test_matrix="["
IFS=","
for tenant in $tenants; do
    # trim extra whitespace from value
    tenant=$(echo "$tenant" | xargs) 
    if [ ! -d "clusters/${tenant}" ]; then
        echo "$tenant doesn't exist!"
    elif [[ "$test_matrix" != *"\"$tenant\""* ]] && [ ! -z "$tenant" ]; then
        local flux_components_file="clusters/${tenant}/flux-system/gotk-components.yaml"
        # Defaults to "latest" version
        local flux_version="latest"
        if [ -f $flux_components_file ]; then
            flux_version=$(yq -r 'select(.kind == "Namespace") | .metadata.labels."app.kubernetes.io/version"' $flux_components_file 2>/dev/null)
        fi
        echo "Added $tenant to array"
        test_matrix+="{\"tenant\": \"$tenant\", \"flux_version\": \"$flux_version\", \"helmreleases\": []}, "
    fi
done
test_matrix=${test_matrix%%, }
test_matrix+="]"
echo "::endgroup::"
echo "test_matrix=$test_matrix" >> "$GITHUB_OUTPUT"