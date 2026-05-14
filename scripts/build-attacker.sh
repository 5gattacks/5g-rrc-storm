#!/usr/bin/env bash
set -e

REPO_DIR=~/rrc-storm-attack
PATCH_DIR=~/5g-rrc-storm

if [ ! -d "$REPO_DIR" ]; then
  git clone https://gitlab.eurecom.fr/oai/openairinterface5g.git "$REPO_DIR"
fi

cd "$REPO_DIR"
git checkout 92980ceb725a94dbfe97c509d16f1313eee083e0
git apply "$PATCH_DIR/storm-attack.patch"

cd cmake_targets
./build_oai -I

# nrscope dependencies
sudo apt install -y libforms-dev libforms-bin

./build_oai -w USRP --ninja --nrUE --gNB --build-lib "nrscope" -C

