#!/bin/bash

set -eou pipefail

CLASS_NAME="$1"; shift
java -cp "target/dependency/*:target/*" -Dlogging.level.org.springframework.cloud.sleuth=DEBUG -Dspring.zipkin.baseUrl=http://zipkin:9411 -Dspring.example.backendBaseUrl=http://backend:9000 sleuth.webmvc.$CLASS_NAME
