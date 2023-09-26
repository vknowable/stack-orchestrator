#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
REPO_DIR=${SCRIPT_DIR}/..

# get installed python version
PYTHON3_VERSION=$(python3 --version 2>&1 | awk '{split($2, a, "."); print a[1]"."a[2]}')

sudo apt update
sudo apt upgrade -y
#sudo apt install python3-pip python3.10-venv -y
sudo apt install python3-pip python${PYTHON3_VERSION}-venv -y

# install stack-orchestrator dependencies
sudo ${REPO_DIR}/scripts/quick-install-ubuntu.sh -y
sudo ${REPO_DIR}/scripts/developer-mode-setup.sh

# remove downloaded s-o binary (out of date) and link to the one from this repo
rm -f $HOME/bin/laconic-so
sudo rm -f /usr/local/bin/laconic-so
sudo ln -s ${REPO_DIR}/venv/bin/laconic-so /usr/local/bin/laconic-so

sudo usermod -aG docker $USER
source ~/.profile
