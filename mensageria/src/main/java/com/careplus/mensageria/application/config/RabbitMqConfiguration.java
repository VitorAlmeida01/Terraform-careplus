package com.careplus.mensageria.application.config;

import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.DirectExchange;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.rabbit.config.SimpleRabbitListenerContainerFactory;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMqConfiguration {

    @Value("${app.rabbitmq.exchange.consultas-criadas:consultas.criadas.exchange}")
    private String exchangeName;

    @Value("${app.rabbitmq.queue.consultas-criadas:consultas.criadas.queue}")
    private String queueName;

    @Value("${app.rabbitmq.routing-key.consultas-criadas:consultas.criadas}")
    private String routingKey;

    @Bean
    public DirectExchange consultasCriadasExchange() {
        return new DirectExchange(exchangeName, true, false);
    }

    @Bean
    public Queue consultasCriadasQueue() {
        return new Queue(queueName, true);
    }

    @Bean
    public Binding consultasCriadasBinding(Queue consultasCriadasQueue, DirectExchange consultasCriadasExchange) {
        return BindingBuilder
                .bind(consultasCriadasQueue)
                .to(consultasCriadasExchange)
                .with(routingKey);
    }

    @Bean
    public Jackson2JsonMessageConverter jackson2JsonMessageConverter() {
        return new Jackson2JsonMessageConverter();
    }

    @Bean
    public SimpleRabbitListenerContainerFactory rabbitListenerContainerFactory(
            ConnectionFactory connectionFactory,
            Jackson2JsonMessageConverter messageConverter
    ) {
        SimpleRabbitListenerContainerFactory factory = new SimpleRabbitListenerContainerFactory();
        factory.setConnectionFactory(connectionFactory);
        factory.setMessageConverter(messageConverter);
        factory.setConcurrentConsumers(1);
        factory.setMaxConcurrentConsumers(5);
        return factory;
    }
}
