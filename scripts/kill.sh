#!/usr/bin/env bash

[[ -z "${ROOT}" ]] && ROOT=`pwd`

pkill -9 -f sleuth.webmvc.Frontend
pkill -9 -f sleuth.webmvc.Backend
docker-compose -f "${ROOT}/docker/docker-compose.yml" kill