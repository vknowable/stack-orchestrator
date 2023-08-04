#!/usr/bin/env bash
# Build cerc/go-opera
source ${CERC_CONTAINER_BASE_DIR}/build-base.sh

# NAMADA_TAG=${NAMADA_TAG:-v0.17.5}
# if [ -z "$NAMADA_TAG" ]; then
#   echo "Please specify Namada repo git tag or commit to build with variable NAMADA_TAG"
#   exit 1
# fi

# git -C ${CERC_REPO_BASE_DIR}/namada checkout ${NAMADA_TAG}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "Using git tag: $NAMADA_TAG"
#docker build -t cerc/namada:local -f ${SCRIPT_DIR}/Dockerfile ${build_command_args} ${CERC_REPO_BASE_DIR}/namada
