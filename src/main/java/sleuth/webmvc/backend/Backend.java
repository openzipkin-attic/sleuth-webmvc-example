package sleuth.webmvc.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Date;

@SpringBootApplication
@RestController
public class Backend {

  @RequestMapping("/api")
  public String printDate() {
    return new Date().toString();
  }

  /** The spring application name is used for the Zipkin service name */
  public static void main(String[] args) {
    SpringApplication.run(Backend.class,
        "--spring.application.name=backend", "--server.port=9000");
  }
}
