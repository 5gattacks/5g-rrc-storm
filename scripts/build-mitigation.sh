#!/usr/bin/env bash
set -e

REPO_DIR=~/openairinterface5g
PATCH_DIR=~/5g-rrc-storm

if [ ! -d "$REPO_DIR" ]; then
  git clone https://gitlab.eurecom.fr/oai/openairinterface5g.git "$REPO_DIR"
fi

cd "$REPO_DIR"
git checkout 92980ceb725a94dbfe97c509d16f1313eee083e0
git apply "$PATCH_DIR/storm-mitigation.patch"

cd cmake_targets

sudo ./build_oai -I

sudo apt install -y libforms-dev libforms-bin

./build_oai -w USRP --ninja --nrUE --gNB --build-lib "nrscope" -C
