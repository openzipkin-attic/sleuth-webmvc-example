package sleuth.webmvc;

import brave.http.HttpTracing;
import brave.httpclient.TracingHttpClientBuilder;
import java.io.IOException;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.BasicResponseHandler;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@EnableAutoConfiguration
@RestController
@CrossOrigin // So that javascript can be hosted elsewhere
public class Frontend {

  @Autowired HttpClient httpClient;

  String backendBaseUrl = System.getProperty("spring.example.backendBaseUrl", "http://localhost:9000");

  @RequestMapping("/") public String callBackend() throws IOException {
    HttpResponse response = httpClient.execute(new HttpGet(backendBaseUrl + "/api"));
    return new BasicResponseHandler().handleResponse(response);
  }

  /** Apache HC clients aren't traced by default. This creates a traced instance. */
  @Bean HttpClient httpClient(HttpTracing httpTracing) {
    return TracingHttpClientBuilder.create(httpTracing).build();
  }

  public static void main(String[] args) {
    SpringApplication.run(Frontend.class,
        "--spring.application.name=frontend",
        "--server.port=8081"
    );
  }
}
