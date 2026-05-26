package com.careplus.mensageria.application.adapter.in.rabbit.dto;

public class PacienteDto {

    private Long id;
    private String nome;
    private ResponsavelDto responsavel;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public ResponsavelDto getResponsavel() {
        return responsavel;
    }

    public void setResponsavel(ResponsavelDto responsavel) {
        this.responsavel = responsavel;
    }
}

