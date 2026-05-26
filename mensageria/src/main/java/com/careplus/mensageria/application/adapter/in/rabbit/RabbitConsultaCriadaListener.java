package com.careplus.mensageria.application.adapter.in.rabbit;

import com.careplus.mensageria.application.adapter.in.rabbit.dto.EventoConsultaCriadaDto;
import com.careplus.mensageria.application.mapper.ConsultaMapper;
import com.careplus.mensageria.domain.entity.Consulta;
import com.careplus.mensageria.domain.port.in.ProcessarNotificacaoConsultaUseCase;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class RabbitConsultaCriadaListener {

    private final ProcessarNotificacaoConsultaUseCase useCase;
    private final ConsultaMapper mapper;

    public RabbitConsultaCriadaListener(ProcessarNotificacaoConsultaUseCase useCase,
                                        ConsultaMapper mapper) {
        this.useCase = useCase;
        this.mapper = mapper;
    }

    @RabbitListener(queues = "${app.rabbitmq.queue.consultas-criadas:consultas.criadas.queue}")
    public void consumir(EventoConsultaCriadaDto evento) {
        System.out.println("╔════════════════════════════════════════════════════════════╗");
        System.out.println("║        Mensagem recebida da fila de consultas criadas     ║");
        System.out.println("╚════════════════════════════════════════════════════════════╝");
        System.out.println("[RabbitConsultaCriadaListener] Total de consultas recebidas: " + evento.getTotalConsultasCriadas());

        try {
            List<Consulta> consultas = mapper.toDomain(evento.getConsultasCriadas());
            useCase.executar(consultas);

            System.out.println("[RabbitConsultaCriadaListener] Evento processado com sucesso. Total de consultas: "
                    + evento.getTotalConsultasCriadas());

        } catch (Exception ex) {
            System.out.println("[RabbitConsultaCriadaListener] Erro ao processar mensagem do RabbitMQ: " + ex.getMessage());
            ex.printStackTrace(System.out);
        }
    }
}
