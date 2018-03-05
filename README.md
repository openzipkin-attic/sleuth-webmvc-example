# Basic example showing distributed tracing across Spring Boot apps
This is an example app where two Spring Boot (Java) services collaborate on an http request. Notably, timing of these requests are recorded into [Zipkin](http://zipkin.io/), a distributed tracing system. This allows you to see the how long the whole operation took, as well how much time was spent in each service.

Here's an example of what it looks like
<img width="964" alt="zipkin screen shot" src="https://user-images.githubusercontent.com/64215/37188958-e22f4154-238c-11e8-91de-42a77420a122.png">

This example was initially made for a [Distributed Tracing Webinar on June 30th, 2016](https://spring.io/blog/2016/05/24/webinar-understanding-microservice-latency-an-introduction-to-distributed-tracing-and-zipkin). There's probably room to enroll if it hasn't completed, yet, and you are interested in the general topic.

# Implementation Overview

Web requests are served by [Spring MVC](https://spring.io/guides/gs/rest-service/) controllers, and tracing is automatically performed for you by [Spring Cloud Sleuth](https://cloud.spring.io/spring-cloud-sleuth/).
Backend requests are served by [Dubbo RPC](http://dubbo.io/)

This example intentionally avoids advanced topics like async and load balancing, eventhough Spring Cloud Sleuth supports that, too. Once you get familiar with things, you can play with more interesting [Spring Cloud](http://projects.spring.io/spring-cloud/) components.

# Running the example
This example has two services: frontend and backend. They both report trace data to zipkin. To setup the demo, you need to start Frontend, Backend and Zipkin.

Once the services are started, open http://localhost:8081/
* This will call the backend (dubbo://localhost:9000/api/printdate) and show the result, which defaults to a formatted date.

Next, you can view traces that went through the backend via http://localhost:9411/?serviceName=backend
* This is a locally run zipkin service which keeps traces in memory

## Starting the Services
In a separate tab or window, start each of [sleuth.webmvc.Frontend](/src/main/java/sleuth/webmvc/Frontend.java) and [sleuth.webmvc.Backend](/src/main/java/sleuth/webmvc/Backend.java):
```bash
$ ./mvnw compile exec:java -Dexec.mainClass=sleuth.webmvc.Backend
$ ./mvnw compile exec:java -Dexec.mainClass=sleuth.webmvc.Frontend
```

Next, run [Zipkin](http://zipkin.io/), which stores and queries traces reported by the above services.

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
  * `logging.pattern.level=%d{ABSOLUTE} [%X{X-B3-TraceId}/%X{X-B3-SpanId}] %-5p [%t] %C{2} - %m%n`

# Going further
Sleuth layers on the [Brave](https://github.com/openzipkin/brave) project, so can re-use any code that
works with brave. It can also use transports besides http to send data to a Zipkin compatible service.
Here are a few small examples that showcase commonly requested features:

## MySQL Tracing
[This](https://github.com/openzipkin/sleuth-webmvc-example/compare/add-mysql-tracing) changes the example to read the timestamp from MySQL instead of
the Spring Boot Process. It adds a brave tracing interceptor to add
details to the existing trace.

https://github.com/openzipkin/brave/tree/master/instrumentation/mysql

## RabbitMQ Tracing
[This](https://github.com/openzipkin/sleuth-webmvc-example/compare/add-rabbit-tracing) changes the example to invoke the backend with RabbitMQ
instead of WebMVC. Sleuth automatically configures Brave's
spring-rabbit to add trace details.

https://github.com/openzipkin/brave/tree/master/instrumentation/spring-rabbit

## Dubbo Tracing
[This](https://github.com/openzipkin/sleuth-webmvc-example/compare/add-dubbo-tracing) changes the example to call a Dubbo backend instead of WebMVC.
It uses Brave's RPC filter to add details to the existing trace.

https://github.com/openzipkin/brave/tree/master/instrumentation/dubbo-rpc

## Customizing with OpenTracing
[This](https://github.com/openzipkin/sleuth-webmvc-example/compare/add-opentracing) changes the example to add a lookup tag using the default
`SpanCustomizer` and OpenTracing's Tracer api. Users can choose which
api makes most sense for them to expose to business code.

Under the covers, this uses the brave-opentracing bridge:

https://github.com/openzipkin-contrib/brave-opentracing
