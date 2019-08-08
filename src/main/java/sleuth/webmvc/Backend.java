package sleuth.webmvc;

import javax.jms.Message;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.jms.annotation.EnableJms;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.web.bind.annotation.RestController;

@EnableAutoConfiguration
@EnableJms
public class Backend {

  @JmsListener(destination = "backend")
  public void onMessage(Message m) {
    System.err.println(m);
  }

  public static void main(String[] args) {
    SpringApplication.run(Backend.class,
        "--spring.application.name=backend",
        // startup without any web framework
        "--spring.main.web-environment=false",
        "--server.port=9000" // set port for actuator
    );
  }
}
