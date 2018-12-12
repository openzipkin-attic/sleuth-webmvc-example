package sleuth.webmvc;

import brave.context.jfr.JfrScopeDecorator;
import brave.propagation.CurrentTraceContext.ScopeDecorator;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration class JfrConfiguration {
  @Bean ScopeDecorator jfrScopeDecorator() {
    return JfrScopeDecorator.create();
  }
}
