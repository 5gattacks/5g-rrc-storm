#!/usr/bin/env bash
set -e

cd ~/openairinterface5g/cmake_targets/ran_build/build

sudo ./nr-softmodem \
  -O ../../../targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb.sa.band78.fr1.106PRB.usrpb210.conf \
  --gNBs.[0].min_rxtxtime 6 \
  -E \
  --continuous-tx \
  | grep --line-buffered -E "detected|TA bucket|TAC|DL frequency|absoluteFrequencySSB|Initializing frame parms|ended" \
  | tee ../../../gnb.logs
