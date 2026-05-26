package com.careplus.mensageria.domain.entity;

public class Profissional {

    private final Long id;
    private final String nome;
    private final String especialidade;
    private final String tipoAtendimento;

    public Profissional(Long id, String nome, String especialidade, String tipoAtendimento) {
        this.id = id;
        this.nome = nome;
        this.especialidade = especialidade;
        this.tipoAtendimento = tipoAtendimento;
    }

    public Long getId() {
        return id;
    }

    public String getNome() {
        return nome;
    }

    public String getEspecialidade() {
        return especialidade;
    }

    public String getTipoAtendimento() {
        return tipoAtendimento;
    }
}

