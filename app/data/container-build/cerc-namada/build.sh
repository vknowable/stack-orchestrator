#!/usr/bin/env bash
# Build cerc/go-opera
source ${CERC_CONTAINER_BASE_DIR}/build-base.sh

# checkout latest tagged release
# git -C ${CERC_REPO_BASE_DIR}/namada fetch --all
# LATEST_RELEASE=$(curl -s "https://api.github.com/repos/anoma/namada/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
LATEST_RELEASE=v0.18.1
git -C ${CERC_REPO_BASE_DIR}/namada checkout ${LATEST_RELEASE}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# use modified dockerfile
docker build -t cerc/namada:local -f ${SCRIPT_DIR}/Dockerfile ${build_command_args} ${CERC_REPO_BASE_DIR}/namada
