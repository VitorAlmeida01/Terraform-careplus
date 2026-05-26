package com.careplus.mensageria.application.adapter.in.rabbit.dto;

import java.util.List;

/**
 * DTO - Evento recebido do RabbitMQ com as consultas criadas.
 */
public class EventoConsultaCriadaDto {

    private int totalConsultasCriadas;
    private int totalFalhas;
    private List<ConsultaCriadaDto> consultasCriadas;
    private List<String> datasComConflito;

    public int getTotalConsultasCriadas() {
        return totalConsultasCriadas;
    }

    public void setTotalConsultasCriadas(int totalConsultasCriadas) {
        this.totalConsultasCriadas = totalConsultasCriadas;
    }

    public int getTotalFalhas() {
        return totalFalhas;
    }

    public void setTotalFalhas(int totalFalhas) {
        this.totalFalhas = totalFalhas;
    }

    public List<ConsultaCriadaDto> getConsultasCriadas() {
        return consultasCriadas;
    }

    public void setConsultasCriadas(List<ConsultaCriadaDto> consultasCriadas) {
        this.consultasCriadas = consultasCriadas;
    }

    public List<String> getDatasComConflito() {
        return datasComConflito;
    }

    public void setDatasComConflito(List<String> datasComConflito) {
        this.datasComConflito = datasComConflito;
    }
}

