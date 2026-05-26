package com.careplus.mensageria.application.config;

import com.careplus.mensageria.domain.port.in.ProcessarNotificacaoConsultaUseCase;
import com.careplus.mensageria.domain.port.out.EnviarMensagemWhatsappPort;
import com.careplus.mensageria.domain.service.FormatadorMensagemService;
import com.careplus.mensageria.domain.service.NotificacaoService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class DomainConfiguration {

    @Bean
    public FormatadorMensagemService formatadorMensagemService() {
        return new FormatadorMensagemService();
    }

    @Bean
    public ProcessarNotificacaoConsultaUseCase processarNotificacaoConsultaUseCase(
        FormatadorMensagemService formatadorMensagem,
        EnviarMensagemWhatsappPort whatsappPort
    ) {
        return new NotificacaoService(formatadorMensagem, whatsappPort);
    }
}
