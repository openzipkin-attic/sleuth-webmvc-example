package sleuth.webmvc;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@EnableAutoConfiguration
@RestController
@CrossOrigin // So that javascript can be hosted elsewhere
public class Frontend {
  final WebClient webClient;

  @Autowired Frontend(WebClient.Builder webClientBuilder) {
    this.webClient = webClientBuilder.build();
  }

  @GetMapping("/") public Mono<String> callBackend() {
    return webClient.get().uri("").retrieve().bodyToMono(String.class);
  }

  @Bean static WebClient.Builder webClientBuilder(
      @Value("${spring.example.backendBaseUrl:http://127.0.0.1:9000}/api") String backendEndpoint) {
    return WebClient.builder().baseUrl(backendEndpoint);
  }

  public static void main(String[] args) {
    SpringApplication.run(Frontend.class,
        "--spring.application.name=frontend",
        "--server.port=8081"
    );
  }
}
