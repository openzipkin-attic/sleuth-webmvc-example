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
@CrossOrigin // So that javascript can be hosted elsewhere
public class Frontend {

  @RequestMapping("/") public String callBackend() {
    return restTemplate().getForObject("http://localhost:9000/api", String.class);
  }

  @Bean RestTemplate restTemplate() {
    return new RestTemplate();
  }

  public static void main(String[] args) {
    SpringApplication.run(Frontend.class,
        "--spring.application.name=frontend",
        "--server.port=8081"
    );
  }
}
