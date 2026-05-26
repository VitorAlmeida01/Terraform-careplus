package com.careplus.mensageria.domain.service;

import com.careplus.mensageria.domain.entity.Consulta;
import com.careplus.mensageria.domain.entity.Paciente;
import com.careplus.mensageria.domain.exception.RegraDeNegocioException;
import com.careplus.mensageria.domain.port.in.ProcessarNotificacaoConsultaUseCase;
import com.careplus.mensageria.domain.port.out.EnviarMensagemWhatsappPort;

import java.util.ArrayList;
import java.util.List;

/**
 * Domain Service - Implementa o Use Case de processamento de consultas.
 * Contém a lógica de negócio para validar e agrupar consultas recebidas via RabbitMQ.
 */
public class NotificacaoService implements ProcessarNotificacaoConsultaUseCase {

    private final FormatadorMensagemService formatadorMensagem;
    private final EnviarMensagemWhatsappPort whatsappPort;

    public NotificacaoService(FormatadorMensagemService formatadorMensagem,
                              EnviarMensagemWhatsappPort whatsappPort) {
        this.formatadorMensagem = formatadorMensagem;
        this.whatsappPort = whatsappPort;
    }

    @Override
    public void executar(List<Consulta> consultas) {
        validarEntradaDeConsultas(consultas);

        List<List<Consulta>> gruposDeConsultasPorPaciente = agruparConsultasPorPacienteEmGrupos(consultas);

        for (List<Consulta> grupo : gruposDeConsultasPorPaciente) {
            Consulta primeiraConsulta = grupo.get(0);
            notificarResponsavel(primeiraConsulta.getPaciente(), grupo);
        }

        System.out.println("[NotificacaoService] Lote processado com sucesso. totalConsultas="
                + consultas.size() + ", totalPacientes=" + gruposDeConsultasPorPaciente.size());
    }

    private void validarEntradaDeConsultas(List<Consulta> consultas) {
        if (consultas == null || consultas.isEmpty()) {
            throw new RegraDeNegocioException("A lista de consultas não pode ser vazia para processamento.");
        }
    }

    private List<List<Consulta>> agruparConsultasPorPacienteEmGrupos(List<Consulta> consultas) {
        List<List<Consulta>> grupos = new ArrayList<>();

        for (Consulta consulta : consultas) {
            boolean encontrouGrupo = false;

            for (List<Consulta> grupo : grupos) {
                Consulta primeiraConsulta = grupo.get(0);
                if (primeiraConsulta.getPaciente().equals(consulta.getPaciente())) {
                    grupo.add(consulta);
                    encontrouGrupo = true;
                    break;
                }
            }

            if (!encontrouGrupo) {
                List<Consulta> novoGrupo = new ArrayList<>();
                novoGrupo.add(consulta);
                grupos.add(novoGrupo);
            }
        }

        return grupos;
    }

    private void notificarResponsavel(Paciente paciente, List<Consulta> consultas) {
        String mensagem = formatadorMensagem.formatar(paciente, consultas);
        String separador = "────────────────────────────────────────────────────────────";

        System.out.println("\n" + separador + "\n" + mensagem + "\n" + separador);

        if (paciente.getResponsavel() != null && paciente.getResponsavel().getTelefone() != null) {
            String numero = paciente.getResponsavel().getTelefone().getNumeroComDDI();
            whatsappPort.enviar(numero, mensagem);
        } else {
            System.out.println("[NotificacaoService] Responsável sem telefone — mensagem não enviada via WhatsApp.");
        }
    }
}
