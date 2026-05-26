package com.careplus.mensageria.application.adapter.in.rabbit.dto;

import java.util.List;

/**
 * DTO - Representa uma consulta criada dentro do evento RabbitMQ.
 */
public class ConsultaCriadaDto {

    private Long id;
    private PacienteDto paciente;
    private List<ProfissionalDto> profissionais;
    private String dataHora;
    private String tipo;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public PacienteDto getPaciente() {
        return paciente;
    }

    public void setPaciente(PacienteDto paciente) {
        this.paciente = paciente;
    }

    public List<ProfissionalDto> getProfissionais() {
        return profissionais;
    }

    public void setProfissionais(List<ProfissionalDto> profissionais) {
        this.profissionais = profissionais;
    }

    public String getDataHora() {
        return dataHora;
    }

    public void setDataHora(String dataHora) {
        this.dataHora = dataHora;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }
}

