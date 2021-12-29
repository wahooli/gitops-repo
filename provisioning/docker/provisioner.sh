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

if [[ "$(docker images -q ${IMAGETAG} 2> /dev/null)" == "" ]]; then
    docker build $SCRIPT_DIR -t $IMAGETAG
fi

docker run -it \
    -e TF_VAR_key_fp=${TF_VAR_key_fp} \
    -e TF_VAR_github_token=${TF_VAR_github_token} \
    -e TF_VAR_proxmox_api_token_secret=${TF_VAR_proxmox_api_token_secret} \
    -v ${WORKDIR}:/workdir \
    -v ~/.gnupg:/home/docker/.gnupg \
    --workdir /workdir/terraform \
    $IMAGETAG \
    "$@"
