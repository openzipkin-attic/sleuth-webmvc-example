package sleuth.webmvc;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.sleuth.Sampler;
import org.springframework.cloud.sleuth.sampler.AlwaysSampler;
import org.springframework.context.annotation.Bean;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@SpringBootApplication
@RestController
@CrossOrigin // So that javascript clients can originate the trace
public class Frontend {

  @Autowired RestTemplate template;

  @RequestMapping("/")
  public String callBackend() {
    return template.getForObject("http://localhost:9000/api", String.class);
  }

  /** Sleuth automatically adds trace interceptors when in the classpath */
  @Bean
  public RestTemplate restTemplate() {
    return new RestTemplate();
  }

  /** Sleuth won't start a trace unless a sampler bean is configured */
  @Bean
  public Sampler defaultSampler() {
    return new AlwaysSampler();
  }

  /** The spring application name is used for the Zipkin service name */
  public static void main(String[] args) {
    SpringApplication.run(Frontend.class, "--spring.application.name=frontend", "--server.port=8081");
  }
}
