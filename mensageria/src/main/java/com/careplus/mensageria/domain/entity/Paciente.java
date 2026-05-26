package com.careplus.mensageria.domain.entity;

public class Paciente {

    private final Long id;
    private final String nome;
    private final Responsavel responsavel;

    public Paciente(Long id, String nome, Responsavel responsavel) {
        this.id = id;
        this.nome = nome;
        this.responsavel = responsavel;
    }

    public Long getId() {
        return id;
    }

    public String getNome() {
        return nome;
    }

    public String getPrimeiroNome() {
        return nome != null ? nome.split(" ")[0] : "";
    }

    public Responsavel getResponsavel() {
        return responsavel;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Paciente paciente = (Paciente) o;
        if (id != null && paciente.id != null) return id.equals(paciente.id);
        return nome != null && nome.equals(paciente.nome);
    }

    @Override
    public int hashCode() {
        return id != null ? id.hashCode() : (nome != null ? nome.hashCode() : 0);
    }
}
