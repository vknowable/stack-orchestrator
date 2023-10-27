#!/usr/bin/env bash
# Build cerc/relayer
source ${CERC_CONTAINER_BASE_DIR}/build-base.sh

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "build_command_args: $build_command_args"

git -C ${CERC_REPO_BASE_DIR}/relayer checkout v2.4.2

docker build -t cerc/relayer:local -f ${SCRIPT_DIR}/Dockerfile ${build_command_args} ${CERC_REPO_BASE_DIR}/relayer
