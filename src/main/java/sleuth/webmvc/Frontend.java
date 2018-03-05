package sleuth.webmvc;

import com.alibaba.dubbo.config.annotation.Reference;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@EnableAutoConfiguration
@RestController
@CrossOrigin // So that javascript can be hosted elsewhere
public class Frontend {

  @Reference(url = "dubbo://127.0.0.1:9000") Api api;

  @RequestMapping("/") public String callBackend() {
    return api.printDate();
  }

  public static void main(String[] args) {
    SpringApplication.run(Frontend.class,
        "--spring.application.name=frontend",
        // redundant https://github.com/apache/incubator-dubbo-spring-boot-project/issues/321
        "--dubbo.application.name=backend",
        "--server.port=8081"
    );
  }
}
