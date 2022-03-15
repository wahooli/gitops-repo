#!/bin/bash

IMAGETAG="provisioner:latest"

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
docker run --rm -it \
    -e TF_VAR_key_fp=${TF_VAR_key_fp} \
    -e TF_VAR_proxmox_api_token_id=${TF_VAR_proxmox_api_token_id} \
    -e TF_VAR_github_token=${TF_VAR_github_token} \
    -e TF_VAR_proxmox_api_token_secret=${TF_VAR_proxmox_api_token_secret} \
    -v ${WORKDIR}:/workdir \
    -v ${GNUPG_DIR}:/home/docker/.gnupg \
    --workdir /workdir/terraform \
    $IMAGETAG \
    "$@"
