#!/usr/bin/env bash
# Build cerc/agd
source ${CERC_CONTAINER_BASE_DIR}/build-base.sh

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "build_command_args: $build_command_args"

git -C ${CERC_REPO_BASE_DIR}/agoric-sdk checkout agoric-upgrade-11

docker build -t cerc/agd:local -f ${SCRIPT_DIR}/Dockerfile ${build_command_args} ${CERC_REPO_BASE_DIR}/agoric-sdk
