#!/bin/bash

set -eou pipefail

CLASS_NAME="$1"; shift
./mvnw exec:java -Dexec.mainClass=sleuth.webmvc.$CLASS_NAME -Dlogging.level.org.springframework.cloud.sleuth=DEBUG -Dspring.zipkin.baseUrl=http://zipkin:9411 -Dspring.example.backendBaseUrl=http://backend:9000
