#!/bin/bash
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
        echo "Added $tenant to array"
        test_matrix+="{\"tenant\": \"$tenant\", \"helmreleases\": []}, "
    fi
done
test_matrix=${test_matrix%%, }
test_matrix+="]"
echo "::endgroup::"
echo "test_matrix=$test_matrix" >> "$GITHUB_OUTPUT"