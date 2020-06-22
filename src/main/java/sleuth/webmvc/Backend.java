package sleuth.webmvc;

import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.kafka.annotation.KafkaListener;

@EnableAutoConfiguration
@EnableKafka
public class Backend {

  @KafkaListener(topics = "hello")
  public void onMessage(ConsumerRecord<String, String> message) {
    System.err.println("hello " + message.value());
  }

  public static void main(String[] args) {
    SpringApplication.run(Backend.class,
        "--spring.application.name=backend",
        "--server.port=9000"
    );
  }
}
