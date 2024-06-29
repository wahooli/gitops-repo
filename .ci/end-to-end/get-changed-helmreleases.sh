#!/usr/bin/env bash
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
REPO_PATHS=("${CLUSTERS_PATH}" "${APPS_PATH}" "${INFRASTRUCTURE_PATH}" "${CRDS_PATH}")

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

function longest_common_prefix()
{
    declare -a names
    declare -a parts
    declare i=0

    names=("$@")
    name="$1"
    while x=$(dirname "$name"); [ "$x" != "/" ]
    do
        parts[$i]="$x"
        i=$(($i + 1))
        name="$x"
    done

    for prefix in "${parts[@]}" /
    do
        for name in "${names[@]}"
        do
            if [ "${name#$prefix/}" = "${name}" ]
            then continue 2
            fi
        done
        echo "$prefix"
        break
    done
}

function find_helmrelease_name() {
    local file=$1
    local kustomization=$2
    local kustomization_file=$3
    local selector=$4
    local debug=$5
    local max_depth=$(realpath $(yq -r ".spec.path" $kustomization_file))
    current_dir=$(realpath $file)
    local common_max_depth=$(longest_common_prefix $max_depth $current_dir)
    local previous_debug=$DEBUG
    if [ "$debug" = true ]; then
        DEBUG=$debug
    fi
    debug "file: $file" \
        "kustomization: $kustomization" \
        "kustomization_file: $kustomization_file" \
        "selector: $selector" \
        "max_depth: $max_depth" \
        "common_max_depth: $common_max_depth"
    
    local error=""
    # this function iterates directories relative to repository root
    # if there's no slashes in current_dir or somehow this while has iterated into repo root or system root, this should break
    while [ "$current_dir" != "/" ] && [ "$current_dir" != "." ] && [[ $current_dir == *"/"* ]]; do
        local kustomization_build=""
        if [ -d $current_dir ]; then
            kustomization_build=$(flux build kustomization $kustomization --kustomization-file $kustomization_file --path $current_dir --dry-run 2>/dev/null | yq -r "${selector}")
            if [ ! -n "$kustomization_build" ]; then
                error=$(flux build kustomization $kustomization --kustomization-file $kustomization_file --path $current_dir --dry-run 2>&1 >/dev/null)
                [ -n "$error" ] && error+="\n[ command: flux build kustomization $kustomization --kustomization-file $kustomization_file --path $current_dir --dry-run ]"
            fi
        # elif [ -f $current_dir ]; then
        #     kustomization_build=$(yq -r "${selector}" $current_dir)
        #     if [ ! -n "$kustomization_build" ]; then
        #         error=$(yq -r "${selector}" $current_dir 2>&1 >/dev/null)
        #         [ -n "$error" ] && error+="\n[ command: yq -r \"${selector}\" $current_dir ]"
        #     fi
        fi
        debug "current_dir: $current_dir"
        # if yq selector finds non empty string result, break loop and echo result
        if [ -n "$error" ]; then
            break
        elif [ -n "$kustomization_build" ]; then
            echo $kustomization_build
            break
        else
            current_dir=$(dirname "$current_dir")
            # break if current dir equals to path defined in kustomization
            [[ $current_dir -ef $max_depth ]] && break
            [[ $current_dir -ef $common_max_depth ]] && break
            (! [[ $common_max_depth -ef $max_depth ]]) && [[ $(dirname $current_dir) -ef $common_max_depth ]] && break
        fi
    done
    DEBUG=$previous_debug
    if [ -n "$error" ]; then
        echo -e "Error in function \"find_helmrelease_name\":\n( $error )" > /dev/stderr
        exit 1
    fi
}

function get_cluster_flux_version() {
    local $tenant=$1
    if [[ ! -v FLUX_VERSIONS[$tenant] ]]; then
        local filename="${CLUSTERS_PATH}${tenant}/flux-system/gotk-components.yaml"
        # Defaults to "latest" version
        local flux_version="latest"
        if [ -f $filename ]; then
            flux_version=$(yq -r 'select(.kind == "Namespace") | .metadata.labels."app.kubernetes.io/version"' $filename 2>/dev/null)
        fi
        FLUX_VERSIONS[$tenant]="$flux_version"
    fi
    echo "${FLUX_VERSIONS[$tenant]}"
}

function find_kustomization_file() {
    local tenant=$1
    local kustomization=$2
    local key="${tenant}_${kustomization}"
    if [[ ! -v KUSTOMIZATION_FILES[$key] ]]; then
        # iterate files under clusters/[tenant]
        local kustomization_file=""
        for filename in ${CLUSTERS_PATH%/}/$tenant/*; do
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
declare -A FLUX_VERSIONS
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
        for tenant in $(find $kustomization -mindepth 1 -maxdepth 1 -type d \( ! -name 'base' \) \( ! -name '.config' \) -printf '%f '); do
            kustomization_file=$(find_kustomization_file $tenant $kustomization)
            exit_status=$?
            if [ ${exit_status} -ne 0 ]; then
                echo "We have error - finding kustomization file failed!"
                exit "${exit_status}"
            fi
            # continue loop if empty value is returned
            [ ! -f $kustomization_file ] && continue
            base_helmrelease=$(find_helmrelease_name $file $kustomization $kustomization_file 'select(.kind == "HelmRelease") | .metadata.annotations."homelab.wahoo.li/base-helmrelease"')
            exit_status=$?
            if [ ${exit_status} -ne 0 ]; then
                echo "We have error - finding base helmreleases failed for tenant \"$tenant\"!"
                exit "${exit_status}"
            fi
            if [ ! -n "$base_helmrelease" ] || [ "null" = "$base_helmrelease" ] ; then
                msg "Could not determine base helmrelease!"
                # break whole loop if base helmrelease could not be determined
                break
            fi
            tenant_kustomization_path=$(yq -r ".spec.path" $kustomization_file)
            helmreleases=$(find_helmrelease_name $tenant_kustomization_path $kustomization $kustomization_file 'select(.kind == "HelmRelease" and .metadata.annotations."homelab.wahoo.li/base-helmrelease" == "'$base_helmrelease'") | .metadata.name')
            exit_status=$?
            if [ ${exit_status} -ne 0 ]; then
                echo "We have error - finding tenant helmreleases failed for tenant \"$tenant\"!"
                exit "${exit_status}"
            fi
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
            exit_status=$?
            if [ ${exit_status} -ne 0 ]; then
                echo "We have error - finding tenant helmreleases failed for tenant \"$tenant\"!"
                exit "${exit_status}"
            fi
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
        flux_version=$(get_cluster_flux_version $key)
        helmreleases_out+="{\"tenant\": \"$key\", \"flux_version\": \"$flux_version\", \"helmreleases\": [\""
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
