#!/usr/bin/env bash

[[ -z "${ROOT}" ]] && ROOT=`pwd`

pkill -9 -f sleuth.webmvc.Frontend
pkill -9 -f sleuth.webmvc.Backend
docker-compose -f "${ROOT}/docker/docker-compose.yml" kill || echo "Oops"
docker ps -a -q | xargs -n 1 -P 8 -I {} docker stop {} > /dev/null || echo "Oops"
