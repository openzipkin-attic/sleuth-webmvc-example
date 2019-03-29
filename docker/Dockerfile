FROM circleci/openjdk:8-jdk

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl

COPY . /code
WORKDIR /code

ENTRYPOINT ["./docker/run.sh"]
