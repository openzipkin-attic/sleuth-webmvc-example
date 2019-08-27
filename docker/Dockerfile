FROM maven:3-jdk-11-slim

ADD . /code

RUN cd /code && mvn -B --no-transfer-progress package -DskipTests=true

FROM gcr.io/distroless/java:11-debug

RUN ["/busybox/sh", "-c", "adduser -g '' -h /zipkin -D zipkin"]

WORKDIR /zipkin

USER zipkin

COPY --from=0 /code /zipkin
ADD docker/run.sh /zipkin

EXPOSE 8081
EXPOSE 9000

ENTRYPOINT ["/busybox/sh", "/zipkin/run.sh"]
