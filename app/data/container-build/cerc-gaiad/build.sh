#!/usr/bin/env bash
# Build cerc/gaiad
source ${CERC_CONTAINER_BASE_DIR}/build-base.sh

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

git -C ${CERC_REPO_BASE_DIR}/gaia checkout v13.0.0

echo "build_command_args: $build_command_args"

docker build -t cerc/gaiad:local -f ${SCRIPT_DIR}/Dockerfile ${build_command_args} ${CERC_REPO_BASE_DIR}/gaia
