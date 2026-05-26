package com.careplus.mensageria.application.adapter.out.console;

import com.careplus.mensageria.domain.port.out.EnviarMensagemWhatsappPort;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

/**
 * Output Adapter - Exibe a mensagem no console (uso em testes/desenvolvimento).
 */
@Profile("console")
@Component
public class ConsoleWhatsappAdapter implements EnviarMensagemWhatsappPort {

    @Override
    public void enviar(String numeroDestino, String mensagem) {
        System.out.println("[ConsoleWhatsappAdapter] Destinatário: +" + numeroDestino);
    }
}
