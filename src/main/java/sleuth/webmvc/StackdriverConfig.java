package sleuth.webmvc;

import com.google.auth.Credentials;
import com.google.auth.oauth2.GoogleCredentials;
import io.grpc.CallOptions;
import io.grpc.auth.MoreCallCredentials;
import java.io.IOException;
import java.util.Collections;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import zipkin2.Span;
import zipkin2.codec.BytesEncoder;
import zipkin2.reporter.Sender;
import zipkin2.reporter.stackdriver.StackdriverEncoder;
import zipkin2.reporter.stackdriver.StackdriverSender;

@Configuration
class StackdriverConfig {

  // reads env GOOGLE_APPLICATION_CREDENTIALS just for testing
  @Bean Credentials googleCredentials() throws IOException {
    return GoogleCredentials.getApplicationDefault()
        .createScoped(Collections.singletonList("https://www.googleapis.com/auth/trace.append"));
  }

  @Bean Sender stackdriverSender(Credentials credentials) {
    return StackdriverSender.newBuilder()
        .projectId("zipkin-demo")
        .callOptions(CallOptions.DEFAULT.withCallCredentials(MoreCallCredentials.from(credentials)))
        .build();
  }

  @Bean BytesEncoder<Span> spanBytesEncoder() {
    return StackdriverEncoder.V1;
  }
}
