package sleuth.webmvc;

import java.util.Date;
import org.springframework.amqp.core.Message;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.context.annotation.Bean;

@EnableAutoConfiguration
public class Backend {

  @RabbitListener(queues = "backend")
  public void onMessage(Message message) {
    System.err.println(new Date().toString());
  }

  @Bean Queue queue() {
    return new Queue("backend", false);
  }

  public static void main(String[] args) {
    SpringApplication.run(Backend.class,
        "--spring.application.name=backend",
        "--server.port=9000"
    );
  }
}
