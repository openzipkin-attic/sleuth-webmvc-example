package sleuth.webmvc;

import java.time.LocalDate;
import java.util.Optional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

@EnableAutoConfiguration
@RestController
public class Backend {

  @GetMapping("/api")
  public Mono<String> printDate(@RequestHeader("user_name") Optional<String> username) {
    LoggerFactory.getLogger(getClass()).info("user name "+username);
    return Mono.fromSupplier(() -> {
      String date = LocalDate.now().toString();
      return username.map(u -> date + " " + u).orElse(date);
    });
  }

  public static void main(String[] args) {
    SpringApplication.run(Backend.class,
        "--spring.application.name=backend",
        "--server.port=9000"
    );
  }
}
