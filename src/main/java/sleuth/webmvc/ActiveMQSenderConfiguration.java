package sleuth.webmvc;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import zipkin2.Span;
import zipkin2.reporter.AsyncReporter;
import zipkin2.reporter.Reporter;
import zipkin2.reporter.Sender;
import zipkin2.reporter.beans.ActiveMQSenderFactoryBean;

import static org.springframework.cloud.sleuth.zipkin2.ZipkinAutoConfiguration.REPORTER_BEAN_NAME;
import static org.springframework.cloud.sleuth.zipkin2.ZipkinAutoConfiguration.SENDER_BEAN_NAME;

/**
 * Configuration for how to send spans to ActiveMQ. Temporary until supported by Sleuth natively
 *
 * <p> See https://cloud.spring.io/spring-cloud-static/spring-cloud-sleuth/2.1.2.RELEASE/single/spring-cloud-sleuth.html#_overriding_the_auto_configuration_of_zipkin
 */
@Configuration
class ActiveMQSenderConfiguration {

  @Bean(REPORTER_BEAN_NAME)
  Reporter<Span> customReporter() throws Exception {
    return AsyncReporter.create(customSender());
  }

  @Bean(SENDER_BEAN_NAME)
  Sender customSender() throws Exception {
    return (Sender) senderFactory().getObject();
  }

  @Bean ActiveMQSenderFactoryBean senderFactory() {
    ActiveMQSenderFactoryBean result = new ActiveMQSenderFactoryBean();
    result.setUrl("failover:tcp://localhost:61616");
    return result;
  }
}
