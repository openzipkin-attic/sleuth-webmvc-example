#!/usr/bin/env bash

[[ -z "${ROOT}" ]] && ROOT=`pwd`

docker-compose -f "${ROOT}/docker/docker-compose.yml" kill
