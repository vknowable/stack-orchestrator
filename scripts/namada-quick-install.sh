#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
REPO_DIR=${SCRIPT_DIR}/..

# install stack-orchestrator dependencies
sudo ${REPO_DIR}/quick-install-ubuntu.sh
sudo ${REPO_DIR}/developer-mode-setup.sh

# remove downloaded s-o binary (out of date) and link to the one from this repo
rm -rf $HOME/bin/laconic-so
sudo ln -s ${REPO_DIR}/venv/bin/laconic-so /usr/local/bin/laconic-so
