#!/usr/bin/env bash
set -e

cd ~/oai-cn5g
docker logs -f oai-amf 2>&1 | tee ~/oai-cn5g/amf.logs
