package sleuth.webmvc;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@SpringBootApplication
@RestController
@CrossOrigin // So that javascript clients can originate the trace
public class Frontend {

  @RequestMapping("/")
  public String callBackend() {
    return restTemplate().getForObject("http://localhost:9000/api", String.class);
  }

  /** Sleuth automatically adds trace interceptors when in the classpath */
  @Bean
  RestTemplate restTemplate() {
    return new RestTemplate();
  }

  public static void main(String[] args) {
    SpringApplication.run(Frontend.class,
        // The spring application name is used for the Zipkin service name.
        "--spring.application.name=frontend",
        // All incoming requests will be sampled. That decision is honored downstream
        "--spring.sleuth.sampler.percentage=1.0",
        "--server.port=8081"
    );
  }
}
