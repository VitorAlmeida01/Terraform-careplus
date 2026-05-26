package com.careplus.mensageria.application.adapter.out.twilio;

import com.careplus.mensageria.domain.port.out.EnviarMensagemWhatsappPort;
import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

/**
 * Output Adapter - Envia mensagens WhatsApp via Twilio.
 */
@Profile("twilio")
@Component
public class TwilioWhatsappAdapter implements EnviarMensagemWhatsappPort {

    private final String from;

    public TwilioWhatsappAdapter(
        @Value("${twilio.account-sid}") String accountSid,
        @Value("${twilio.auth-token}") String authToken,
        @Value("${twilio.whatsapp.from}") String from
    ) {
        Twilio.init(accountSid, authToken);
        this.from = from;
    }

    @Override
    public void enviar(String numeroDestino, String mensagem) {
        Message message = Message.creator(
            new PhoneNumber("whatsapp:+" + numeroDestino),
            new PhoneNumber(from),
            mensagem
        ).create();

        System.out.println("[TwilioWhatsappAdapter] Mensagem enviada. SID: " + message.getSid());
    }
}
