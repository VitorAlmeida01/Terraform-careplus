package com.careplus.mensageria.domain.port.out;

/**
 * Output Port - Define o contrato de envio de mensagens WhatsApp.
 * A implementação concreta fica na camada de infraestrutura.
 */
public interface EnviarMensagemWhatsappPort {

    void enviar(String numeroDestino, String mensagem);
}
