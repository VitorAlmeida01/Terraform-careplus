package com.careplus.mensageria.domain.port.in;

import com.careplus.mensageria.domain.entity.Consulta;
import java.util.List;

/**
 * Input Port (Use Case) - Define a operacao de negocio.
 * Na arquitetura hexagonal, o Use Case e uma porta de entrada.
 */
public interface ProcessarNotificacaoConsultaUseCase {

    /**
     * Processa a notificacao de consultas criadas.
     *
     * @param consultas lista de consultas a serem notificadas
     */
    void executar(List<Consulta> consultas);
}
