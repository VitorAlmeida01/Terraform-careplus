package com.careplus.mensageria.domain.valueobject;

import com.careplus.mensageria.domain.exception.RegraDeNegocioException;

/**
 * Value Object - Telefone.
 * Encapsula validação e normalização de números de telefone.
 */
public class Telefone {

    private final String numero;

    public Telefone(String numero) {
        if (numero == null || numero.isBlank()) {
            throw new RegraDeNegocioException("O telefone do responsável não pode ser vazio.");
        }
        this.numero = numero;
    }

    /**
     * Retorna o número original (ex: "(31) 91234-8765").
     */
    public String getNumero() {
        return numero;
    }

    /**
     * Retorna apenas os dígitos do telefone (ex: "31912348765").
     * Útil para integração com APIs externas como WhatsApp.
     */
    public String getNumeroNormalizado() {
        return numero.replaceAll("\\D", "");
    }

    /**
     * Retorna o número com DDI do Brasil (ex: "5531912348765").
     */
    public String getNumeroComDDI() {
        return "55" + getNumeroNormalizado();
    }

    @Override
    public String toString() {
        return numero;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Telefone telefone = (Telefone) o;
        return getNumeroNormalizado().equals(telefone.getNumeroNormalizado());
    }

    @Override
    public int hashCode() {
        return getNumeroNormalizado().hashCode();
    }
}

