# This is replaced by https://github.com/openzipkin/brave-example


# Basic example showing distributed tracing across Spring Boot apps
This is an example app where two Spring Boot (Java) services collaborate on an http request. Notably, timing of these requests are recorded into [Zipkin](http://zipkin.io/), a distributed tracing system. This allows you to see the how long the whole operation took, as well how much time was spent in each service.

Here's an example of what it looks like
<img width="995" alt="Zipkin Screenshot" src="https://user-images.githubusercontent.com/64215/75970720-bd188080-5f0b-11ea-99c5-1c3108994827.png">

This example was initially made for a [Distributed Tracing Webinar on June 30th, 2016](https://spring.io/blog/2016/05/24/webinar-understanding-microservice-latency-an-introduction-to-distributed-tracing-and-zipkin). There's probably room to enroll if it hasn't completed, yet, and you are interested in the general topic.

# Implementation Overview

Web requests are served by [Spring MVC](https://spring.io/guides/gs/rest-service/) controllers, and tracing is automatically performed for you by [Spring Cloud Sleuth](https://cloud.spring.io/spring-cloud-sleuth/).

This example intentionally avoids advanced topics like async and load balancing, even though Spring Cloud Sleuth supports that, too. Once you get familiar with things, you can play with more interesting [Spring Cloud](http://projects.spring.io/spring-cloud/) components.

# Running the example
This example has two services: frontend and backend. They both report trace data to Zipkin. To setup the demo, you need to start Frontend, Backend and Zipkin.

Once the services are started, open http://localhost:8081/
* This will call the backend (http://localhost:9000/api) and show the result, which defaults to a formatted date.

Next, you can view traces that went through the backend via http://localhost:9411/?serviceName=backend
* This is a locally run Zipkin service which keeps traces in memory

## Starting the Services
In a separate tab or window, start each of [sleuth.webmvc.Frontend](/src/main/java/sleuth/webmvc/Frontend.java) and [sleuth.webmvc.Backend](/src/main/java/sleuth/webmvc/Backend.java):
```bash
$ ./mvnw compile exec:java -Dexec.mainClass=sleuth.webmvc.Backend
$ ./mvnw compile exec:java -Dexec.mainClass=sleuth.webmvc.Frontend
```

Next, run [Zipkin](https://zipkin.io/), which stores and queries traces reported by the above services.

```bash
curl -sSL https://zipkin.io/quickstart.sh | bash -s
java -jar zipkin.jar
```

## Configuration tips
* The service name in the Zipkin UI defaults to the application name
  * `spring.application.name=frontend`
* All incoming requests are sampled and that decision is honored downstream.
  * `spring.sleuth.sampler.probability=1.0`
* The below pattern adds trace and span identifiers into log output
  * `logging.pattern.level=%d{ABSOLUTE} [%X{traceId}/%X{spanId}] %-5p [%t] %C{2} - %m%n`
* If you pass the header `user_name` Brave will automatically propagate it to the backend!
  * `curl -s localhost:8081 -H'user_name: JC'`

# Going further
A distributed trace will only include connections that are configured (instrumented). You may be using
some libraries that aren't automatically configured.

Here are a few small examples that showcase how to stitch-in commonly requested features.

## Spring WebFlux Tracing
```bash
git checkout add-webflux-tracing
```
[This](https://github.com/openzipkin/sleuth-webmvc-example/compare/add-webflux-tracing) changes the
example to serve requests with reactive `Mono` controllers, using `WebClient` instead of
`RestTemplate` to make the call from the frontend to the backend.

## Apache Http Client Tracing
```bash
git checkout add-apachehc-tracing
```
[This](https://github.com/openzipkin/sleuth-webmvc-example/compare/add-apachehc-tracing) changes the
example to use Apache `HttpClient` instead of `RestTemplate` to make the
call from the frontend to the backend.

https://github.com/openzipkin/brave/tree/master/instrumentation/httpclient

## MySQL Tracing
```bash
git checkout add-mysql-tracing
```
[This](https://github.com/openzipkin/sleuth-webmvc-example/compare/add-mysql-tracing) changes the example to read the timestamp from MySQL instead of
the Spring Boot Process. It adds a brave tracing interceptor to add
details to the existing trace.

https://github.com/openzipkin/brave/tree/master/instrumentation/mysql8

## RabbitMQ Tracing
```bash
git checkout add-rabbit-tracing
```
[This](https://github.com/openzipkin/sleuth-webmvc-example/compare/add-rabbit-tracing) changes the example to invoke the backend with RabbitMQ
instead of WebMVC. Sleuth automatically configures Brave's
spring-rabbit to add trace details.

https://github.com/openzipkin/brave/tree/master/instrumentation/spring-rabbit

## Kafka Tracing
```bash
git checkout add-kafka-tracing
```
[This](https://github.com/openzipkin/sleuth-webmvc-example/compare/add-kafka-tracing) changes the example to invoke the backend with Kafka
instead of WebMVC. Sleuth automatically configures Brave's
kafka-clients instrumentation when spring-kafka is present.

https://github.com/openzipkin/brave/tree/master/instrumentation/kafka-clients
https://github.com/spring-cloud/spring-cloud-sleuth/blob/v2.1.1.RELEASE/spring-cloud-sleuth-core/src/main/java/org/springframework/cloud/sleuth/instrument/messaging/TraceMessagingAutoConfiguration.java#L110

## JMS Tracing
[This](https://github.com/openzipkin/sleuth-webmvc-example/compare/add-jms-tracing) changes the example to invoke the backend with ActiveMQ instead of WebMVC. Sleuth automatically configures Spring JmsTemplate and JmsListener to add trace details.

## Dubbo Tracing
```bash
git checkout add-dubbo-tracing
```
[This](https://github.com/openzipkin/sleuth-webmvc-example/compare/add-dubbo-tracing) changes the example to call a Dubbo backend instead of WebMVC.
It uses Brave's RPC filter to add details to the existing trace.

https://github.com/openzipkin/brave/tree/master/instrumentation/dubbo-rpc

## Java Flight Recorder
```bash
git checkout add-jfr-context
```
[This](https://github.com/openzipkin/sleuth-webmvc-example/compare/add-jfr-context) changes the example to add trace IDs to Java Flight recorder "Zipkin/Scope" events.

https://github.com/openzipkin/brave/tree/master/context/jfr

## Customizing with OpenTracing
```bash
git checkout add-opentracing
```
[This](https://github.com/openzipkin/sleuth-webmvc-example/compare/add-opentracing) changes the example to add a lookup tag using the default
`SpanCustomizer` and OpenTracing's Tracer api. Users can choose which
api makes most sense for them to expose to business code.

Under the covers, this uses the brave-opentracing bridge:

https://github.com/openzipkin-contrib/brave-opentracing

## Docker

A docker image containing the example can be built using

```bash
$ docker build -t openzipkin/example-sleuth-webmvc -f docker/Dockerfile .
```

The backend can be started with a command similar to

```bash
$ docker run -it --rm -p 9000:9000 openzipkin/example-sleuth-webmvc backend
```

The frontend can be started with a command similar to
            
```bash
$ docker run -it --rm -p 8081:8081 openzipkin/example-sleuth-webmvc frontend
```

## Need something else not here?

Sleuth layers on the [Brave](https://github.com/openzipkin/brave) project, so can re-use any code that
works with brave. It can also use transports besides http to send data to a Zipkin compatible service.

Contact us on [gitter](https://gitter.im/openzipkin/zipkin) if you need more help!
