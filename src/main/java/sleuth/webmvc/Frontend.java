package sleuth.webmvc;

import java.util.Date;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@EnableAutoConfiguration
@RestController
@CrossOrigin // So that javascript can be hosted elsewhere
public class Frontend {

  @Autowired KafkaTemplate<String, String> kafkaTemplate;

  @RequestMapping("/")
  public CompletableFuture<String> callBackend() {
    String messageId = UUID.randomUUID().toString();
    return kafkaTemplate.send("hello", messageId)
        .completable()
        .thenApply(r -> "sent " + messageId);
  }

  public static void main(String[] args) {
    SpringApplication.run(Frontend.class,
        "--spring.application.name=frontend",
        "--server.port=8081"
    );
  }
}
