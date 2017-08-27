# Basic example showing distributed tracing across Spring Boot apps
This is an example app where two Spring Boot (Java) services collaborate on an http request. Notably, timing of these requests are recorded into [Zipkin](http://zipkin.io/), a distributed tracing system. This allows you to see the how long the whole operation took, as well how much time was spent in each service.

Here's an example of what it looks like
<img width="972" alt="zipkin screen shot" src="https://cloud.githubusercontent.com/assets/64215/16300537/ff858dd6-3972-11e6-8e4c-4f7f4a6c707a.png">

This example was initially made for a [Distributed Tracing Webinar on June 30th, 2016](https://spring.io/blog/2016/05/24/webinar-understanding-microservice-latency-an-introduction-to-distributed-tracing-and-zipkin). There's probably room to enroll if it hasn't completed, yet, and you are interested in the general topic.

# Implementation Overview

Web requests are served by [Spring MVC](https://spring.io/guides/gs/rest-service/) controllers, and tracing is automatically performed for you by [Spring Cloud Sleuth](https://cloud.spring.io/spring-cloud-sleuth/).

This example intentionally avoids advanced topics like async and load balancing, eventhough Spring Cloud Sleuth supports that, too. Once you get familiar with things, you can play with more interesting [Spring Cloud](http://projects.spring.io/spring-cloud/) components.

# Running the example
This example has two services: frontend and backend. They both report trace data to zipkin. To setup the demo, you need to start Frontend, Backend and Zipkin.

Once the services are started, open http://localhost:8081/
* This will call the backend (http://localhost:9000/api) and show the result, which defaults to a formatted date.

Next, you can view traces that went through the backend via http://localhost:9411/?serviceName=backend
* This is a locally run zipkin service which keeps traces in memory

## Starting the Services
In a separate tab or window, start each of [sleuth.webmvc.Frontend](/src/main/java/sleuth/webmvc/Frontend.java) and [sleuth.webmvc.Backend](/src/main/java/sleuth/webmvc/Backend.java):
```bash
$ ./mvnw compile exec:java -Dexec.mainClass=sleuth.webmvc.Frontend
$ ./mvnw compile exec:java -Dexec.mainClass=sleuth.webmvc.Backend
```

Next, run [Zipkin](http://zipkin.io/), which stores and queries traces reported by the above services.

```bash
wget -O zipkin.jar 'https://search.maven.org/remote_content?g=io.zipkin.java&a=zipkin-server&v=LATEST&c=exec'
java -jar zipkin.jar
```

## Configuration tips
* The service name in the Zipkin UI defaults to the application name
  * `spring.application.name=frontend`
* All incoming requests are sampled and that decision is honored downstream.
  * `spring.sleuth.sampler.percentage=1.0`
* The below pattern adds trace and span identifiers into log output
  * `logging.pattern.level=%d{ABSOLUTE} [%X{X-B3-TraceId}/%X{X-B3-SpanId}] %-5p [%t] %C{2} - %m%n`
