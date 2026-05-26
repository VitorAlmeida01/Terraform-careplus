package com.careplus.mensageria.domain.exception;

/**
 * Exceção de domínio para violações de regras de negócio.
 * Pertence ao Domain — não depende de nenhum framework.
 */
public class RegraDeNegocioException extends RuntimeException {

    public RegraDeNegocioException(String mensagem) {
        super(mensagem);
    }

    public RegraDeNegocioException(String mensagem, Throwable causa) {
        super(mensagem, causa);
    }
}

