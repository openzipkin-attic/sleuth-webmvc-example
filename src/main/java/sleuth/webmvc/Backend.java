package sleuth.webmvc;

import com.alibaba.dubbo.config.annotation.Service;
import com.alibaba.dubbo.spring.boot.annotation.EnableDubboConfiguration;
import java.util.Date;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;

@EnableAutoConfiguration
@EnableDubboConfiguration
@Service(interfaceClass = Api.class)
public class Backend implements Api {

  @Override public String printDate() {
    return new Date().toString();
  }

  public static void main(String[] args) {
    SpringApplication.run(Backend.class,
        "--spring.application.name=backend",
        // These args allow dubbo to start without any web framework
        "--spring.main.web-environment=false",
        "--spring.dubbo.server=true",
        "--spring.dubbo.registry=N/A",
        "--spring.dubbo.protocol.port=9000"
    );
  }
}
