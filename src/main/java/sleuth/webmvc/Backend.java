package sleuth.webmvc;

import brave.SpanCustomizer;
import io.opentracing.Tracer;
import java.util.Date;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@EnableAutoConfiguration
@RestController
public class Backend {
  @Autowired Tracer tracer; // available by depending on 'io.opentracing.brave:brave-opentracing'
  @Autowired SpanCustomizer customizer; // available by default

  @RequestMapping("/api") public String printDate() {
    // the following are equivalent means to add a lookup tag to the current span
    tracer.activeSpan().setTag("user-id", "abcd");
    customizer.tag("user-name", "robby");
    return new Date().toString();
  }

  public static void main(String[] args) {
    SpringApplication.run(Backend.class,
        "--spring.application.name=backend",
        "--server.port=9000"
    );
  }
}
