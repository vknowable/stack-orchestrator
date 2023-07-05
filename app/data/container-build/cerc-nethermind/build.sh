#!/usr/bin/env bash
# Build cerc/go-opera
source ${CERC_CONTAINER_BASE_DIR}/build-base.sh

# checkout latest tagged release
LATEST_RELEASE=$(curl -s "https://api.github.com/repos/NethermindEth/nethermind/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
git -C ${CERC_REPO_BASE_DIR}/nethermind checkout ${LATEST_RELEASE}

# build fails without Buildkit
DOCKER_BUILDKIT=1 docker build -t cerc/nethermind:local ${build_command_args} ${CERC_REPO_BASE_DIR}/nethermind
