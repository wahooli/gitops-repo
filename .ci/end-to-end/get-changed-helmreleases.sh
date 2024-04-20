#!/bin/bash
OUTPUT_MODE=${OUTPUT_MODE:-github_json}
ORIG_IFS=$IFS
HEAD_BRANCH=main
SOURCE_BRANCH=flux-image-updates
FILES="${FILES}"
if [ -z "$FILES" ]; then
    FILES="${@:1}"
fi
CLUSTERS_PATH="clusters/"
APPS_PATH="apps/"
INFRASTRUCTURE_PATH="infrastructure/"
CRDS_PATH="crds/"
REPO_PATHS=("clusters/" "apps/" "infrastructure/" "crds/")

function msg() {
    if [[ "github_json" == $OUTPUT_MODE ]]; then
        echo "$1"
    fi
}

function debug() {
    local messages="${*@Q}"
    if [ "$DEBUG" = true ]; then
        local prev_ifs=$IFS
        echo "--DEBUG--" >> /dev/stderr
        IFS=$ORIG_IFS
        for msg in $messages; do
            echo ${msg//\'/} >> /dev/stderr
        done
        IFS=$prev_ifs
        echo -e "--DEBUG--\n" >> /dev/stderr
    fi
}

function find_helmrelease_name() {
    local file=$1
    local kustomization=$2
    local kustomization_file=$3
    local selector=$4
    local debug=$5
    local max_depth=$(yq -r ".spec.path" $kustomization_file)
    current_dir=$file
    local previous_debug=$DEBUG
    if [ "$debug" = true ]; then
        DEBUG=$debug
    fi
    debug "file: $file" \
        "kustomization: $kustomization" \
        "kustomization_file: $kustomization_file" \
        "selector: $selector" \
        "max_depth: $max_depth"
    # this function iterates directories relative to repository root
    # if there's no slashes in current_dir or somehow this while has iterated into repo root or system root, this should break
    while [ "$current_dir" != "/" ] && [ "$current_dir" != "." ] && [[ $current_dir == *"/"* ]]; do
        local kustomization_build=""
        if [ -d $current_dir ]; then
            kustomization_build=$(flux build kustomization $kustomization --kustomization-file $kustomization_file --path $current_dir --dry-run 2>/dev/null | yq -r "${selector}")
        elif [ -f $current_dir ]; then
            kustomization_build=$(yq -r "${selector}" $current_dir)
        fi
        debug "current_dir: $current_dir"
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
    DEBUG=$previous_debug
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
IFS=$'\n '
for file in $FILES; do
    tenant=$file
    for path in "${REPO_PATHS[@]}"; do
        tenant=${tenant#"$path"}
    done
    [[ $file == $tenant ]] && continue
    tenant=${tenant%%"/"*}
    kustomization=${file%%"/"*}
    IFS=$ORIG_IFS
    kustomization_file=""
    base_helmrelease=""
    helmreleases=""
    msg "::group::File $file"
    if [[ "base" = "$tenant" ]]; then
        # this overrides tenant variable if modifications were done in base overlay
        for tenant in $(find $kustomization -mindepth 1 -maxdepth 1 -type d \( ! -name 'base' \) -printf '%f '); do
            kustomization_file=$(find_kustomization_file $tenant $kustomization)
            # continue loop if empty value is returned
            [ ! -f $kustomization_file ] && continue
            base_helmrelease=$(find_helmrelease_name $file $kustomization $kustomization_file 'select(.kind == "HelmRelease") | .metadata.annotations."homelab.wahoo.li/base-helmrelease"')
            if [ ! -n "$base_helmrelease" ] || [ "null" = "$base_helmrelease" ] ; then
                msg "Could not determine base helmrelease!"
                # break whole loop if base helmrelease could not be determined
                break
            fi
            tenant_kustomization_path=$(yq -r ".spec.path" $kustomization_file)
            helmreleases=$(find_helmrelease_name $tenant_kustomization_path $kustomization $kustomization_file 'select(.kind == "HelmRelease" and .metadata.annotations."homelab.wahoo.li/base-helmrelease" == "'$base_helmrelease'") | .metadata.name')
            helmreleases=("${helmreleases[@]/---}")
            if [ -z "${helmreleases[*]}" ]; then
                msg "Tenant: $tenant; Didn't find any helmreleases with base helmrelease: $base_helmrelease"
                # skip this tenant if helmreleases could not be determined
                continue
            fi
            add_helmreleases_for_tenant $tenant "${helmreleases[*]}"
            msg "Tenant: $tenant, Added helmreleases: ${helmreleases[*]}"
        done
    else
        kustomization_file=$(find_kustomization_file "$tenant" "$kustomization")
        if [ -f $kustomization_file ]; then
            helmreleases=($(find_helmrelease_name "$file" "$kustomization" "$kustomization_file" 'select(.kind == "HelmRelease") | .metadata.name'))
            helmreleases=( "${helmreleases[@]/---}" )
            if [ -n "${helmreleases[*]}" ]; then
                add_helmreleases_for_tenant $tenant "${helmreleases[*]}"
                msg "Tenant: $tenant, Added helmreleases: ${helmreleases[*]}"
            fi
        fi
    fi
    msg "::endgroup::"
    IFS=" "
done
IFS=$ORIG_IFS

if [[ "github_json" == $OUTPUT_MODE ]]; then
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
    
elif [[ "pr_description" == $OUTPUT_MODE ]]; then
    affected_helmreleases=()
    for key in "${!HELM_RELEASES[@]}"; do
        affected_helmreleases+=("### Tenant: $key")
        releases_unique=$(echo "${HELM_RELEASES[$key]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
        for release in $releases_unique; do
            affected_helmreleases+=("- $release")
        done
    done
    if (( ${#affected_helmreleases[@]} )); then
        echo "## Affected HelmReleases"
        printf '%s\n' "${affected_helmreleases[@]}"
        echo ""
    fi

    IFS=$'\n'
    git_log=$(git log origin/${HEAD_BRANCH}..${SOURCE_BRANCH} --format="%B")
    changed_images=()
    parsing_images=false
    debug ${git_log[*]}
    for line in $git_log; do
        if [ -f "$line" ]; then
            parsing_images=false
        elif [[ "Images:" == $line ]]; then
            parsing_images=true
        elif [ "$parsing_images" = true ]; then
            # if line starts with dash, images are being parsed from commit message
            [[ $line = -* ]] && changed_images+=($line)|| parsing_images=false  
        fi
    done

    if (( ${#changed_images[@]} )); then
        echo "## Updated images"
        printf '%s\n' "${changed_images[@]}"
        echo ""
    fi
    
    IFS=$'\n '
    echo "## Changed files"
    for file in $FILES; do 
        echo "- $file"
    done
fi
