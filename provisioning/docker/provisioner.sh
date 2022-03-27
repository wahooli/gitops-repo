#!/bin/bash

IMAGETAG="provisioner:latest"
CONTAINER_NAME="provisioner"
RECREATE_CONTAINER=${RECREATE_CONTAINER:-false}
if [ "$RECREATE_CONTAINER" != "false" ]; then
    docker rm -f $CONTAINER_NAME 2> /dev/null
fi

if [ ! "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=${CONTAINER_NAME})" ]; then
        # cleanup
        docker rm -f $CONTAINER_NAME 
    fi
    if [ -z "$TF_VAR_key_fp" ]; then
        echo "env TF_VAR_key_fp not set!"
        exit 1
    fi
    if [ -z "$TF_VAR_github_token" ]; then
        echo "env TF_VAR_github_token not set!"
        exit 1
    fi
    if [ -z "$TF_VAR_proxmox_api_token_secret" ]; then
        echo "env TF_VAR_proxmox_api_token_secret not set!"
        exit 1
    fi

    SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    WORKDIR=$(dirname ${SCRIPT_DIR})
    GNUPG_DIR=$(realpath ~/.gnupg)

    if [[ "$OSTYPE" == "cygwin" ]]; then
        SCRIPT_DIR=$(cygpath -w "${SCRIPT_DIR}")
        WORKDIR=$(cygpath -w "${WORKDIR}")
        GNUPG_DIR=$(cygpath -w "${GNUPG_DIR}")
    fi

    if [[ "$(docker images -q ${IMAGETAG} 2> /dev/null)" == "" ]]; then
        docker build $SCRIPT_DIR -t $IMAGETAG
    fi

    TF_VAR_proxmox_api_token_id=${TF_VAR_proxmox_api_token_id:-terraform@pve!terraform-token}
    docker run --name="${CONTAINER_NAME}" -d \
        -e TF_VAR_key_fp=${TF_VAR_key_fp} \
        -e TF_VAR_proxmox_api_token_id=${TF_VAR_proxmox_api_token_id} \
        -e TF_VAR_github_token=${TF_VAR_github_token} \
        -e TF_VAR_proxmox_api_token_secret=${TF_VAR_proxmox_api_token_secret} \
        --workdir /workdir/terraform \
        -v ${WORKDIR}:/workdir \
        -v ${GNUPG_DIR}:/home/docker/.gnupg \
        --entrypoint sleep \
        $IMAGETAG \
        infinity
fi

docker exec -it $CONTAINER_NAME "$@"