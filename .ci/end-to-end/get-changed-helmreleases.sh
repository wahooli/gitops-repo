#!/bin/bash

PREV_IFS=$IFS

FILES="${@:1}"
CLUSTERS_PATH="clusters/"
APPS_PATH="apps/"
INFRASTRUCTURE_PATH="infrastructure/"
CRDS_PATH="crds/"
REPO_PATHS=("clusters/" "apps/" "infrastructure/" "crds/")

function find_helmrelease_name() {
    local file=$1
    local kustomization=$2
    local kustomization_file=$3
    local selector=$4
    local max_depth=$(yq -r ".spec.path" $kustomization_file)
    current_dir=$file
    # this function iterates directories relative to repository root
    # if there's no slashes in current_dir or somehow this while has iterated into repo root or system root, this should break
    while [ "$current_dir" != "/" ] && [ "$current_dir" != "." ] && [[ $current_dir == *"/"* ]]; do
        local kustomization_build=""
        if [ -d $current_dir ]; then
            kustomization_build=$(flux build kustomization $kustomization --kustomization-file $kustomization_file --path $current_dir --dry-run 2>/dev/null | yq -r "${selector}")
        elif [ -f $current_dir ]; then
            kustomization_build=$(yq -r "${selector}" $current_dir)
        fi
        # if yq selector finds non empty string result, break loop and echo result
        if [ -n "$kustomization_build" ]; then
            echo $kustomization_build
            break
        else
            current_dir=$(dirname "$current_dir")
            # break if current dir equals to path defined in kustomization
            [[ $current_dir -ef $max_depth ]] && break
        fi
    done
}


function find_kustomization_file() {
    local tenant=$1
    local kustomization=$2
    local key="${tenant}_${kustomization}"
    if [[ ! -v KUSTOMIZATION_FILES[$key] ]]; then
        # iterate files under clusters/[tenant]
        local kustomization_file=""
        for filename in clusters/$tenant/*; do
            # not file
            [ ! -f "$filename" ] && continue

            found_kustomization=$(yq -r 'select(.kind == "Kustomization") | .metadata.name' $filename 2>/dev/null)
            if [ ! -z $found_kustomization ] && [ "$found_kustomization" == "$kustomization" ]; then
                kustomization_file=$filename
                break
            fi
        done
        # set even empty result to prevent unnecessary looping
        KUSTOMIZATION_FILES[$key]="$kustomization_file"
    fi
    echo "${KUSTOMIZATION_FILES[$key]}"
}

function add_helmreleases_for_tenant() {
    local key="$1"
    local new_values=("${@:2}")  # Get all arguments starting from the second one
    # Check if the key exists in the associative array
    if [[ -v HELM_RELEASES[$key] ]]; then
        # If the key exists, append new values to the nested array
        local current_values="${HELM_RELEASES[$key]}"
        current_values+=" ${new_values[*]}"
        HELM_RELEASES[$key]="$current_values"
    else
        # If the key doesn't exist, create a new nested array with the new values
        HELM_RELEASES[$key]="${new_values[*]}"
    fi
}

declare -A HELM_RELEASES
declare -A KUSTOMIZATION_FILES
IFS=" "
for file in $FILES; do
    tenant=$file
    for path in "${REPO_PATHS[@]}"; do
        tenant=${tenant#"$path"}
    done
    tenant=${tenant%%"/"*}
    kustomization=${file%%"/"*}
    IFS=$PREV_IFS
    kustomization_file=""
    base_helmrelease=""
    helmreleases=""
    echo "::group::File $file"
    if [[ "base" = "$tenant" ]]; then
        # this overrides tenant variable if modifications were done in base overlay
        for tenant in $(find $kustomization -mindepth 1 -maxdepth 1 -type d \( ! -name 'base' \) -printf '%f '); do
            kustomization_file=$(find_kustomization_file $tenant $kustomization)
            # continue loop if empty value is returned
            [ ! -f $kustomization_file ] && continue
            base_helmrelease=$(find_helmrelease_name $file $kustomization $kustomization_file 'select(.kind == "HelmRelease") | .metadata.annotations."homelab.wahoo.li/base-helmrelease"')
            if [ ! -n "$base_helmrelease" ] || [ "null" = "$base_helmrelease" ] ; then
                echo "Could not determine base helmrelease!"
                # break whole loop if base helmrelease could not be determined
                break
            fi
            tenant_kustomization_path=$(yq -r ".spec.path" $kustomization_file)
            helmreleases=$(find_helmrelease_name $tenant_kustomization_path $kustomization $kustomization_file 'select(.kind == "HelmRelease" and .metadata.annotations."homelab.wahoo.li/base-helmrelease" == "'$base_helmrelease'") | .metadata.name')
            helmreleases=("${helmreleases[@]/---}")
            if [ -z "${helmreleases[*]}" ]; then
                echo "Tenant: $tenant; Didn't find any helmreleases with base helmrelease: $base_helmrelease"
                # skip this tenant if helmreleases could not be determined
                continue
            fi
            add_helmreleases_for_tenant $tenant "${helmreleases[*]}"
            echo "Tenant: $tenant, Added helmreleases: ${helmreleases[*]}"
        done
    else
        kustomization_file=$(find_kustomization_file "$tenant" "$kustomization")
        if [ -f $kustomization_file ]; then
            helmreleases=($(find_helmrelease_name "$file" "$kustomization" "$kustomization_file" 'select(.kind == "HelmRelease") | .metadata.name'))
            helmreleases=( "${helmreleases[@]/---}" )
            if [ -n "${helmreleases[*]}" ]; then
                add_helmreleases_for_tenant $tenant "${helmreleases[*]}"
                echo "Tenant: $tenant, Added helmreleases: ${helmreleases[*]}"
            fi
        fi
    fi
    echo "::endgroup::"
    IFS=" "
done
IFS=$PREV_IFS

helmreleases_out="["
for key in "${!HELM_RELEASES[@]}"; do
    releases_unique=$(echo "${HELM_RELEASES[$key]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
    releases_unique=${releases_unique## }
    releases_unique=${releases_unique%% }
    helmreleases_out+="{\"tenant\": \"$key\", \"helmreleases\": [\""
    helmreleases_out+=${releases_unique// /'", "'}
    helmreleases_out+="\"]}, "
done
helmreleases_out=${helmreleases_out%%, }
helmreleases_out+="]"

echo "test_matrix=$helmreleases_out" >> "$GITHUB_OUTPUT"
