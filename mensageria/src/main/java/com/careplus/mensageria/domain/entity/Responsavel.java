package com.careplus.mensageria.domain.entity;

import com.careplus.mensageria.domain.valueobject.Telefone;

public class Responsavel {

    private final String nome;
    private final Telefone telefone;

    public Responsavel(String nome, Telefone telefone) {
        this.nome = nome;
        this.telefone = telefone;
    }

    public String getNome() {
        return nome;
    }

    public Telefone getTelefone() {
        return telefone;
    }
}
