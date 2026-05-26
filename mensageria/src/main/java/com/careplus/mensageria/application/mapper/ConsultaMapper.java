package com.careplus.mensageria.application.mapper;

import com.careplus.mensageria.application.adapter.in.rabbit.dto.ConsultaCriadaDto;
import com.careplus.mensageria.application.adapter.in.rabbit.dto.PacienteDto;
import com.careplus.mensageria.application.adapter.in.rabbit.dto.ProfissionalDto;
import com.careplus.mensageria.application.adapter.in.rabbit.dto.ResponsavelDto;
import com.careplus.mensageria.domain.entity.Consulta;
import com.careplus.mensageria.domain.entity.Paciente;
import com.careplus.mensageria.domain.entity.Profissional;
import com.careplus.mensageria.domain.entity.Responsavel;
import com.careplus.mensageria.domain.valueobject.Telefone;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class ConsultaMapper {

    private static final DateTimeFormatter DATETIME_FORMATTER_COM_SEGUNDOS =
        DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    private static final DateTimeFormatter DATETIME_FORMATTER_SEM_SEGUNDOS =
        DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    public List<Consulta> toDomain(List<ConsultaCriadaDto> dtos) {
        return dtos.stream()
                   .map(this::toDomain)
                   .collect(Collectors.toList());
    }

    public Consulta toDomain(ConsultaCriadaDto dto) {
        Paciente paciente = toDomain(dto.getPaciente());
        List<Profissional> profissionais = dto.getProfissionais() == null
            ? List.of()
            : dto.getProfissionais().stream().map(this::toDomain).collect(Collectors.toList());
        LocalDateTime dataHora = parseDataHora(dto.getDataHora());

        return new Consulta(
            dto.getId(),
            paciente,
            profissionais,
            dataHora,
            dto.getTipo()
        );
    }

    private Paciente toDomain(PacienteDto dto) {
        Responsavel responsavel = null;
        ResponsavelDto responsavelDto = dto.getResponsavel();
        if (responsavelDto != null) {
            Telefone telefone = new Telefone(responsavelDto.getTelefone());
            responsavel = new Responsavel(responsavelDto.getNome(), telefone);
        }
        return new Paciente(dto.getId(), dto.getNome(), responsavel);
    }

    private Profissional toDomain(ProfissionalDto dto) {
        return new Profissional(
            dto.getId(),
            dto.getNome(),
            dto.getEspecialidade(),
            dto.getTipoAtendimento()
        );
    }

    private LocalDateTime parseDataHora(String dataHora) {
        if (dataHora == null || dataHora.isBlank()) {
            throw new IllegalArgumentException("Data/hora da consulta é obrigatória.");
        }

        try {
            return LocalDateTime.parse(dataHora, DATETIME_FORMATTER_COM_SEGUNDOS);
        } catch (Exception ex) {
            try {
                return LocalDateTime.parse(dataHora, DATETIME_FORMATTER_SEM_SEGUNDOS);
            } catch (Exception ex2) {
                return LocalDateTime.parse(dataHora);
            }
        }
    }
}
