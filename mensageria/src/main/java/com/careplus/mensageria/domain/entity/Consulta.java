package com.careplus.mensageria.domain.entity;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Entidade de domínio - Consulta.
 * Representa uma consulta agendada entre um paciente e um ou mais profissionais.
 */
public class Consulta {

    private final Long id;
    private final Paciente paciente;
    private final List<Profissional> profissionais;
    private final LocalDateTime dataHora;
    private final String tipo;

    public Consulta(Long id, Paciente paciente, List<Profissional> profissionais,
                    LocalDateTime dataHora, String tipo) {
        this.id = id;
        this.paciente = paciente;
        this.profissionais = profissionais;
        this.dataHora = dataHora;
        this.tipo = tipo;
    }

    public Long getId() {
        return id;
    }

    public Paciente getPaciente() {
        return paciente;
    }

    public List<Profissional> getProfissionais() {
        return profissionais;
    }

    public LocalDateTime getDataHora() {
        return dataHora;
    }

    public String getTipo() {
        return tipo;
    }
}
