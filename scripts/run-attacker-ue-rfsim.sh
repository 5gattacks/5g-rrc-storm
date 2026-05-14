#!/usr/bin/env bash
set -e

cd ~/rrc-storm-attack/cmake_targets/ran_build/build

sudo ./nr-uesoftmodem \
  --C 3619200000 \
  -r 106 \
  --numerology 1 \
  --ssb 516 \
  -E \
  --band 78 \
  --ue-fo-compensation \
  --rfsim
