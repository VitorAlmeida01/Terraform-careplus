package com.careplus.mensageria.domain.service;

import com.careplus.mensageria.domain.entity.Consulta;
import com.careplus.mensageria.domain.entity.Paciente;
import com.careplus.mensageria.domain.entity.Profissional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Domain Service - Responsavel por formatar mensagens amigaveis.
 */
public class FormatadorMensagemService {

    private static final DateTimeFormatter HORA_FORMATTER =
        DateTimeFormatter.ofPattern("HH:mm");
    private static final DateTimeFormatter DATA_DISPLAY_FORMATTER =
        DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final Locale PT_BR = Locale.of("pt", "BR");

    public String formatar(Paciente paciente, List<Consulta> consultas) {
        StringBuilder sb = new StringBuilder();

        String nomeResponsavel = paciente.getResponsavel() != null
            ? paciente.getResponsavel().getNome()
            : paciente.getPrimeiroNome();

        sb.append("Bem vindo, ").append(nomeResponsavel).append("! 😊\n\n");
        sb.append("Segue a agenda semanal do: *").append(paciente.getNome()).append("*\n\n");

        Map<LocalDate, List<Consulta>> consultasPorDia = agruparPorDia(consultas);

        consultasPorDia.forEach((dia, consultasDoDia) -> {
            formatarDia(sb, dia, consultasDoDia);
        });

        sb.append("Caso precise reagendar, entre em contato conosco.\n");
        sb.append("Ate logo! 💙");

        return sb.toString();
    }

    private Map<LocalDate, List<Consulta>> agruparPorDia(List<Consulta> consultas) {
        Map<LocalDate, List<Consulta>> consultasPorDia = new LinkedHashMap<>();

        for (Consulta consulta : consultas) {
            LocalDate dia = consulta.getDataHora().toLocalDate();
            consultasPorDia
                .computeIfAbsent(dia, k -> new ArrayList<>())
                .add(consulta);
        }

        return consultasPorDia;
    }

    private void formatarDia(StringBuilder sb, LocalDate dia, List<Consulta> consultasDoDia) {
        String diaSemana = dia.getDayOfWeek().getDisplayName(TextStyle.FULL, PT_BR);
        String diaSemanaCapitalizado = diaSemana.substring(0, 1).toUpperCase() + diaSemana.substring(1);

        sb.append("📅 *").append(diaSemanaCapitalizado)
          .append(", ").append(dia.format(DATA_DISPLAY_FORMATTER)).append("*\n");

        for (Consulta consulta : consultasDoDia) {
            sb.append("   🕐 ").append(consulta.getDataHora().format(HORA_FORMATTER))
              .append(" — ").append(consulta.getTipo()).append("\n");

            for (Profissional profissional : consulta.getProfissionais()) {
                sb.append("      👤 ").append(profissional.getNome())
                  .append(" (").append(profissional.getEspecialidade()).append(")\n");
            }
        }
        sb.append("\n");
    }
}
