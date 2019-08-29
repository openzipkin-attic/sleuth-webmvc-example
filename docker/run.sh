#!/bin/bash

case "$1" in
  f|frontend|Frontend )
    CLASS_NAME=Frontend
    ;;
  b|backend|Backend )
    CLASS_NAME=Backend
    ;;
  * )
    echo "No command specified. Run the docker image with either the frontend or backend command, e.g.,
    docker run -it --rm -p 8081:8081 openzipkin/example-sleuth-webmvc frontend
    docker run -it --rm -p 9000:9000 openzipkin/example-sleuth-webmvc backend"
    exit 1
esac

java -cp target/sleuth-webmvc-*-exec.jar -Dlogging.level.org.springframework.cloud.sleuth=DEBUG \
  -Dspring.zipkin.baseUrl=http://zipkin:9411 -Dspring.example.backendBaseUrl=http://backend:9000 \
  -Dloader.main=sleuth.webmvc.$CLASS_NAME $JAVA_OPTS org.springframework.boot.loader.PropertiesLauncher
