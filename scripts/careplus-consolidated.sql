-- ================================================
-- CarePlus - Consolidated Schema + Data
-- Executar TUDO nessa ordem: schema, então inserts
-- Data: 2026-05-02 - São Paulo, Brasil
-- ================================================


SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;
SET time_zone = '-03:00';

CREATE DATABASE IF NOT EXISTS careplus_novo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE careplus_novo;

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;
SET character_set_client = utf8mb4;
SET character_set_connection = utf8mb4;
SET character_set_results = utf8mb4;
SET collation_connection = utf8mb4_unicode_ci;

-- ===== SCHEMA =====

DROP TABLE IF EXISTS notificacao;
DROP TABLE IF EXISTS classificacao_doencas;
DROP TABLE IF EXISTS material;
DROP TABLE IF EXISTS medicacao;
DROP TABLE IF EXISTS fichaclinica;
DROP TABLE IF EXISTS consulta_funcionario;
DROP TABLE IF EXISTS consulta_prontuario;
DROP TABLE IF EXISTS cuidador;
DROP TABLE IF EXISTS funcionario_roles;
DROP TABLE IF EXISTS role;
DROP TABLE IF EXISTS funcionario;
DROP TABLE IF EXISTS responsavel;
DROP TABLE IF EXISTS paciente;
DROP TABLE IF EXISTS endereco;

CREATE TABLE endereco (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cep VARCHAR(255),
    logradouro VARCHAR(255),
    numero VARCHAR(255),
    complemento VARCHAR(255),
    bairro VARCHAR(255),
    cidade VARCHAR(255),
    estado VARCHAR(255)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE paciente (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255),
    email VARCHAR(255),
    cpf VARCHAR(255),
    telefone VARCHAR(255),
    dt_nascimento DATE,
    convenio VARCHAR(255),
    data_inicio DATE,
    foto VARCHAR(255),
    ativo TINYINT(1) NOT NULL DEFAULT 1
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE responsavel (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255),
    email VARCHAR(255),
    telefone VARCHAR(255),
    dt_nascimento DATE,
    cpf VARCHAR(255),
    id_endereco INT,
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT fk_responsavel_endereco FOREIGN KEY (id_endereco) REFERENCES endereco(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE funcionario (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255),
    email VARCHAR(255),
    senha VARCHAR(255),
    supervisor_id BIGINT,
    cargo VARCHAR(255),
    especialidade VARCHAR(255),
    tipo_atendimento VARCHAR(45),
    telefone VARCHAR(45),
    documento VARCHAR(45),
    foto VARCHAR(255),
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT fk_funcionario_supervisor FOREIGN KEY (supervisor_id) REFERENCES funcionario(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE role (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE funcionario_roles (
    funcionario_id BIGINT,
    role_id BIGINT,
    PRIMARY KEY (funcionario_id, role_id),
    CONSTRAINT fk_fr_funcionario FOREIGN KEY (funcionario_id) REFERENCES funcionario(id),
    CONSTRAINT fk_fr_role FOREIGN KEY (role_id) REFERENCES role(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE consulta_prontuario (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    paciente_id BIGINT,
    data DATE,
    horario_inicio TIME,
    horario_fim TIME,
    tipo VARCHAR(255),
    observacoes_comportamentais VARCHAR(2000),
    presenca TINYINT,
    confirmada TINYINT,
    recorrencia_id VARCHAR(55),
    CONSTRAINT fk_consulta_paciente FOREIGN KEY (paciente_id) REFERENCES paciente(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE consulta_funcionario (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    funcionario_id BIGINT NOT NULL,
    consulta_id BIGINT NOT NULL,
    CONSTRAINT uq_cf_consulta_funcionario UNIQUE (consulta_id, funcionario_id),
    CONSTRAINT fk_cf_funcionario FOREIGN KEY (funcionario_id) REFERENCES funcionario(id),
    CONSTRAINT fk_cf_consulta FOREIGN KEY (consulta_id) REFERENCES consulta_prontuario(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE fichaclinica (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    paciente_id BIGINT,
    desfraldado TINYINT,
    hiperfoco VARCHAR(255),
    anamnese VARCHAR(2000),
    diagnostico VARCHAR(255),
    resumo_clinico VARCHAR(2000),
    nivel_agressividade INT,
    CONSTRAINT fk_fichaClinica_paciente FOREIGN KEY (paciente_id) REFERENCES paciente(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE classificacao_doencas (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cid VARCHAR(255),
    dt_modificacao DATE,
    prontuario_id BIGINT,
    CONSTRAINT fk_classificacao_prontuario FOREIGN KEY (prontuario_id) REFERENCES fichaclinica(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE medicacao (
    id_medicacao BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome_medicacao VARCHAR(255),
    data_inicio DATE,
    data_fim DATE,
    ativo TINYINT,
    data_modificacao DATETIME,
    prontuario_id BIGINT,
    CONSTRAINT fk_medicacao_prontuario FOREIGN KEY (prontuario_id) REFERENCES fichaclinica(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE cuidador (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    paciente_id BIGINT,
    responsavel_id BIGINT,
    parentesco VARCHAR(255),
    CONSTRAINT fk_cuidador_paciente FOREIGN KEY (paciente_id) REFERENCES paciente(id),
    CONSTRAINT fk_cuidador_responsavel FOREIGN KEY (responsavel_id) REFERENCES responsavel(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE material (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    item VARCHAR(255),
    data_implementacao DATE,
    fk_consulta BIGINT,
    CONSTRAINT fk_material_consulta FOREIGN KEY (fk_consulta) REFERENCES consulta_prontuario(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE notificacao (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    paciente_id BIGINT NOT NULL,
    recorrencia_id VARCHAR(60) NOT NULL,
    profissional_nome VARCHAR(255),
    especialidade VARCHAR(255),
    horario_inicio TIME,
    horario_fim TIME,
    tipo VARCHAR(255),
    dias_semana VARCHAR(20),
    data_fim DATE NOT NULL,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_notificacao_recorrencia_id (recorrencia_id),
    CONSTRAINT fk_notificacao_paciente FOREIGN KEY (paciente_id) REFERENCES paciente(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ===== USERS E ROLES =====

CREATE USER IF NOT EXISTS 'careplus_user'@'%' IDENTIFIED BY 'SenhaForte123!';
GRANT ALL PRIVILEGES ON careplus_novo.* TO 'careplus_user'@'%';
FLUSH PRIVILEGES;

-- ===== DATA (INSERTS) =====

INSERT INTO endereco (id, cep, logradouro, numero, complemento, bairro, cidade, estado) VALUES
(1,'01310-100','Avenida Paulista','1578','Apartamento 42','Bela Vista','São Paulo','SP'),
(2,'029891712','Rua das Flores','123','','Paulista','São Paulo','SP'),
(3,'03928090','logradouro_9b248d9dfa6f','numero_5bf79a305363','complemento_6a920f3c1e3c','bairro_ba3946537bb6','cidade_f01caf541f4c','estado_c09d4e91f03e');

INSERT INTO paciente (id, nome, email, cpf, telefone, dt_nascimento, convenio, data_inicio, foto, ativo) VALUES
(1,'Lucas Silva','lucas.silva@email.com','123.456.789-00','11 91234-5678','2014-05-15','Bradesco','2025-12-05', NULL, 1),
(2,'Mariana Costa','mariana.costa@email.com','987.654.321-00','21 99876-5432','2014-11-22','Bradesco','2025-12-05', NULL, 1),
(3,'Pedro Oliveira','pedro.oliveira@email.com','456.789.123-11','31 91234-8765','2014-02-10','Unimed','2025-12-05', NULL, 1),
(7,'Maria Santos','maria.santos@email.com','98765432100','11988887777','2014-05-15','Bradesco','2026-01-16', NULL, 1),
(8,'João Pereira','joao.pereira@email.com','11122233344','11990000001','2014-03-12','Unimed','2026-02-01',NULL,1),
(9,'Carla Mendes','carla.mendes@email.com','11122233345','11990000002','2015-07-25','Bradesco','2026-02-01',NULL,1),
(10,'Rafael Gomes','rafael.gomes@email.com','11122233346','11990000003','2015-09-10','Sul America','2026-02-01',NULL,1),
(11,'Patrícia Lima','patricia.lima@email.com','11122233347','11990000004','2015-01-30','Unimed','2026-02-01',NULL,1),
(12,'Bruno Rocha','bruno.rocha@email.com','11122233348','11990000005','2015-12-05','Unimed','2026-02-01',NULL,1),
(13,'Fernanda Alves','fernanda.alves@email.com','11122233349','11990000006','2015-06-18','Amil','2026-02-01',NULL,1),
(14,'Diego Barros','diego.barros@email.com','11122233350','11990000007','2015-04-22','Unimed','2026-02-01',NULL,1),
(15,'Juliana Duarte','juliana.duarte@email.com','11122233351','11990000008','2015-11-11','Bradesco','2026-02-01',NULL,1),
(16,'Lucas Martins','lucas.martins@email.com','11122233352','11990000009','2015-08-09','Sul America','2026-02-01',NULL,1),
(17,'Amanda Freitas','amanda.freitas@email.com','11122233353','11990000010','2016-02-14','Amil','2026-02-01',NULL,1),
(18,'Gustavo Ribeiro','gustavo.ribeiro@email.com','11122233354','11990000011','2016-05-20','Unimed','2026-02-01',NULL,1),
(19,'Beatriz Carvalho','beatriz.carvalho@email.com','11122233355','11990000012','2016-07-03','Bradesco','2026-02-01',NULL,1),
(20,'Thiago Nogueira','thiago.nogueira@email.com','11122233356','11990000013','2016-10-27','Amil','2026-02-01',NULL,1),
(21,'Larissa Teixeira','larissa.teixeira@email.com','11122233357','11990000014','2016-03-08','Bradesco','2026-02-01',NULL,1),
(22,'Felipe Batista','felipe.batista@email.com','11122233358','11990000015','2016-09-15','Unimed','2026-02-01',NULL,1),
(23,'Camila Azevedo','camila.azevedo@email.com','11122233359','11990000016','2016-12-01','Sul America','2026-02-01',NULL,1),
(24,'Eduardo Pires','eduardo.pires@email.com','11122233360','11990000017','2016-06-06','Amil','2026-02-01',NULL,1),
(25,'Renata Correia','renata.correia@email.com','11122233361','11990000018','2017-11-19','Bradesco','2026-02-01',NULL,1),
(26,'Vinícius Farias','vinicius.farias@email.com','11122233362','11990000019','2017-01-01','Unimed','2026-02-01',NULL,1),
(27,'Tatiane Moura','tatiane.moura@email.com','11122233363','11990000020','2017-05-05','Amil','2026-02-01',NULL,1),
(28,'Rodrigo Cardoso','rodrigo.cardoso@email.com','11122233364','11990000021','2017-08-18','Amil','2026-02-01',NULL,1),
(29,'Aline Barbosa','aline.barbosa@email.com','11122233365','11990000022','2017-02-22','Sul America','2026-02-01',NULL,1),
(30,'Daniel Tavares','daniel.tavares@email.com','11122233366','11990000023','2017-07-07','Unimed','2026-02-01',NULL,1),
(31,'Priscila Lopes','priscila.lopes@email.com','11122233367','11990000024','2017-12-30','Bradesco','2026-02-01',NULL,1),
(32,'André Castro','andre.castro@email.com','11122233368','11990000025','2017-09-09','Amil','2026-02-01',NULL,1),
(33,'Simone Rezende','simone.rezende@email.com','11122233369','11990000026','2018-04-14','Unimed','2026-02-01',NULL,1),
(34,'Leandro Peixoto','leandro.peixoto@email.com','11122233370','11990000027','2018-10-10','Sul America','2026-02-01',NULL,1),
(35,'Vanessa Guedes','vanessa.guedes@email.com','11122233371','11990000028','2018-01-17','Bradesco','2026-02-01',NULL,1),
(36,'Paulo Queiroz','paulo.queiroz@email.com','11122233372','11990000029','2018-06-25','Sul America','2026-02-01',NULL,1),
(37,'Cláudia Santana','claudia.santana@email.com','11122233373','11990000030','2018-03-03','Amil','2026-02-01',NULL,1),
(38,'Ricardo Neves','ricardo.neves@email.com','11122233374','11990000031','2018-11-11','Unimed','2026-02-01',NULL,1),
(39,'Débora Monteiro','debora.monteiro@email.com','11122233375','11990000032','2018-08-08','Sul America','2026-02-01',NULL,1),
(40,'Marcelo Dantas','marcelo.dantas@email.com','11122233376','11990000033','2018-02-02','Bradesco','2026-02-01',NULL,1),
(41,'Luciana Prado','luciana.prado@email.com','11122233377','11990000034','2018-07-21','Unimed','2026-02-01',NULL,1),
(42,'Sérgio Pacheco','sergio.pacheco@email.com','11122233378','11990000035','2018-05-29','Amil','2026-02-01',NULL,1),
(43,'Elaine Borges','elaine.borges@email.com','11122233379','11990000036','2018-12-12','Unimed','2026-02-01',NULL,1),
(44,'Fábio Macedo','fabio.macedo@email.com','11122233380','11990000037','2018-09-09','Sul America','2026-02-01',NULL,1),
(45,'Kelly Ramos','kelly.ramos@email.com','11122233381','11990000038','2018-06-06','Bradesco','2026-02-01',NULL,1),
(46,'Igor Medeiros','igor.medeiros@email.com','11122233382','11990000039','2018-01-15','Unimed','2026-02-01',NULL,1),
(47,'Natália Figueiredo','natalia.figueiredo@email.com','11122233383','11990000040','2018-04-04','Amil','2026-02-01',NULL,1),
(48,'Maria Oliveira','maria.oliveira@email.com','22233344401','11990000041','2014-02-02','Unimed','2026-02-10',NULL,1),
(49,'Maria Souza','maria.souza@email.com','22233344402','11990000042','2015-05-10','Bradesco','2026-02-10',NULL,1),
(50,'Maria Pereira','maria.pereira@email.com','22233344403','11990000043','2016-08-18','Amil','2026-02-10',NULL,1),
(51,'João Silva','joao.silva@email.com','22233344404','11990000044','2017-01-01','Unimed','2026-02-10',NULL,1),
(52,'João Santos','joao.santos@email.com','22233344405','11990000045','2017-03-22','Sul America','2026-02-10',NULL,1),
(53,'João Ferreira','joao.ferreira@email.com','22233344406','11990000046','2017-07-30','Bradesco','2026-02-10',NULL,1),
(54,'Ana Lima','ana.lima@email.com','22233344407','11990000047','2018-11-11','Amil','2026-02-10',NULL,1),
(55,'Ana Rocha','ana.rocha@email.com','22233344408','11990000048','2018-04-04','Unimed','2026-02-10',NULL,1),
(56,'Carlos Mendes','carlos.mendes@email.com','22233344409','11990000049','2016-06-15','Bradesco','2026-02-10',NULL,1),
(57,'Carlos Alves','carlos.alves@email.com','22233344410','11990000050','2017-09-09','Sul America','2026-02-10',NULL,1);

INSERT INTO role (id, nome) VALUES
(1,'ADMIN'),
(2,'USER'),
(3,'MANAGER'),
(4,'SCHEDULER'),
(5, 'VIEWER');

INSERT INTO funcionario (id, nome, email, senha, supervisor_id, cargo, especialidade, tipo_atendimento, telefone, documento, foto, ativo) VALUES
(1,'Dra. Helena Castro','helena.castro@clinica.com','$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC',NULL,'Supervisor(a)',NULL,'TO','11940028922','40028922','fotoPerfil.png',1),
(13,'Roberto Santos','roberto.santos@clinica.com','$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC',NULL,'Gerente',NULL,'TO','11941100019','50001009','fotoPerfil.png',1),
(2,'Juliana Almeida','admin@clinica.com','$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC',1,'Funcionário',NULL,'TO','11940028923','40028923','fotoPerfil.png',1),
(3,'Marcos Ribeiro','marcos.ribeiro@clinica.com','$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC',1,'Estagiário','Fonoaudiologia','ABA','11940028924','40028924','fotoPerfil.png',1),
(4,'Vitor Almeida','vitor.almeida@clinica.com','$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC',1,'Funcionário',NULL,'ABA','11940028925','40028925','fotoPerfil.png',1),
(5,'Ana Paula Ferreira','ana.ferreira@clinica.com','$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC',1,'Supervisor(a)',NULL,'ABA','11941100001','50001001',NULL,1),
(6,'Beatriz Souza','beatriz.souza@clinica.com','$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC',13,'Funcionário','Terapia Ocupacional','TO','11941100002','50001002',NULL,1),
(7,'Camila Rocha','camila.rocha@clinica.com','$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC',13,'Funcionário','Psicopedagogia','ABA','11941100003','50001003',NULL,1),
(8,'Diego Martins','diego.martins@clinica.com','$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC',13,'Funcionário','Nutricionista','TO','11941100004','50001004',NULL,1),
(9,'Fernanda Lima','fernanda.lima@clinica.com','$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC',1,'Funcionário','Fisioterapia','TO','11941100005','50001005',NULL,1),
(10,'Gabriel Costa','gabriel.costa@clinica.com','$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC',1,'Funcionário','Psicomotricidade','ABA','11941100006','50001006',NULL,1),
(11,'Isabela Nunes','isabela.nunes@clinica.com','$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC',13,'Funcionário','Musicoterapia','TO','11941100007','50001007',NULL,1),
(12,'Michele Alves','michele.alves@clinica.com','$2a$10$0/TKTGxdREbWaWjWYhwf6e9P1fPOAMMNqEnZgOG95jnSkHSfkkIrC',13,'Terceirizada',NULL,NULL,'11941100018','50001008',NULL,1);

INSERT INTO funcionario_roles (funcionario_id, role_id) VALUES
(1,3),(2,1),(3,2),(4,4),
(5,3),(6,2),(7,2),(8,2),(9,2),(10,2),(11,2),(12,5),(13,3);

INSERT INTO fichaclinica (id, paciente_id, desfraldado, hiperfoco, anamnese, diagnostico, resumo_clinico, nivel_agressividade) VALUES
(1, 1, 1, 'Brinquedos', 'Histórico de atraso de fala', 'TEA leve', 'Paciente comunicativo com apoio', 2),
(2, 2, 1, 'Desenhos', 'Dificuldade de interação social', 'TEA moderado', 'Boa evolução clínica', 3),
(3, 3, 0, 'Movimentos repetitivos', 'Atraso cognitivo', 'TDAH', 'Necessita acompanhamento contínuo', 4),
(4, 7, 1, 'Música', 'Ansiedade frequente', 'Transtorno de Ansiedade', 'Responde bem à terapia', 1);

INSERT INTO consulta_prontuario (id, paciente_id, data, horario_inicio, horario_fim, tipo, observacoes_comportamentais, presenca, confirmada) VALUES
(2, 2, '2026-01-12', '10:30:00', '11:30:00', 'Sessão Regular', 'Paciente não compareceu', 0, 1),
(3, 3, '2026-02-05', '14:00:00', '15:00:00', 'Sessão Regular', NULL, NULL, 1),
(4, 7, '2026-02-10', '15:30:00', '16:30:00', 'Sessão Regular', NULL, NULL, 0);

INSERT INTO consulta_funcionario (id, consulta_id, funcionario_id) VALUES
(2, 2, 7),
(3, 3, 3),
(4, 4, 3);

INSERT INTO responsavel (id, nome, email, telefone, dt_nascimento, cpf, id_endereco, ativo) VALUES
(1,'Clara','clara.responsavel@gmail.com','11955001001','2002-01-16','30099988877',3,1),
(2,'Vinicius Dias','vinicius@gmail.com','11955001002','1990-01-16','40011122233',2,1);

INSERT INTO classificacao_doencas (id, cid, dt_modificacao, prontuario_id) VALUES
(1, 'F84.0', '2026-01-10', 1),
(2, 'F84.1', '2026-01-12', 2),
(3, 'F90.0', '2026-01-15', 3),
(4, 'F41.1', '2026-01-16', 4);

INSERT INTO medicacao (id_medicacao, nome_medicacao, data_inicio, data_fim, ativo, data_modificacao, prontuario_id) VALUES
(1, 'Risperidona', '2025-12-01', NULL, 1, NOW(), 1),
(2, 'Melatonina', '2025-11-10', '2026-01-10', 0, NOW(), 2),
(3, 'Metilfenidato', '2026-01-05', NULL, 1, NOW(), 3);

INSERT INTO cuidador (id, paciente_id, responsavel_id, parentesco) VALUES
(1,1,1,'Mãe'),
(2,2,1,'Tia'),
(3,7,1,'Responsável Legal'),
(4,3,1,'Responsável Legal'),
(5,8,1,'Responsável Legal'),
(6,9,1,'Responsável Legal'),
(7,10,1,'Responsável Legal'),
(8,11,1,'Responsável Legal'),
(9,12,1,'Responsável Legal'),
(10,13,1,'Responsável Legal'),
(11,14,1,'Responsável Legal'),
(12,15,1,'Responsável Legal'),
(13,16,1,'Responsável Legal'),
(14,17,1,'Responsável Legal'),
(15,18,1,'Responsável Legal'),
(16,19,1,'Responsável Legal'),
(17,20,1,'Responsável Legal'),
(18,21,1,'Responsável Legal'),
(19,22,1,'Responsável Legal'),
(20,23,1,'Responsável Legal'),
(21,24,1,'Responsável Legal'),
(22,25,1,'Responsável Legal'),
(23,26,1,'Responsável Legal'),
(24,27,1,'Responsável Legal'),
(25,28,1,'Responsável Legal'),
(26,29,1,'Responsável Legal'),
(27,30,1,'Responsável Legal'),
(28,31,1,'Responsável Legal'),
(29,32,1,'Responsável Legal'),
(30,33,1,'Responsável Legal'),
(31,34,1,'Responsável Legal'),
(32,35,1,'Responsável Legal'),
(33,36,1,'Responsável Legal'),
(34,37,1,'Responsável Legal'),
(35,38,1,'Responsável Legal'),
(36,39,1,'Responsável Legal'),
(37,40,1,'Responsável Legal'),
(38,41,1,'Responsável Legal'),
(39,42,1,'Responsável Legal'),
(40,43,1,'Responsável Legal'),
(41,44,1,'Responsável Legal'),
(42,45,1,'Responsável Legal'),
(43,46,1,'Responsável Legal'),
(44,47,1,'Responsável Legal'),
(45,48,1,'Responsável Legal'),
(46,49,1,'Responsável Legal'),
(47,50,1,'Responsável Legal'),
(48,51,1,'Responsável Legal'),
(49,52,1,'Responsável Legal'),
(50,53,1,'Responsável Legal'),
(51,54,1,'Responsável Legal'),
(52,55,1,'Responsável Legal'),
(53,56,1,'Responsável Legal'),
(54,57,1,'Responsável Legal');

INSERT INTO material (id, item, data_implementacao, fk_consulta) VALUES
(2, 'Jogos Sensoriais', '2026-01-12', 2),
(3, 'Espelho Terapêutico', '2026-02-05', 3);


-- ===================================================
-- CONSULTAS PADRONIZADAS - Recorrência Diária (Mariana)
-- Período  : 27/04/2026 a 31/05/2026 (25 dias úteis)
-- Frequência: segunda a sexta | Paciente: Mariana (id=2)
-- Datas passadas (< 04/05/2026): presenca=1, confirmada=1
-- ===================================================

INSERT INTO consulta_prontuario (id, paciente_id, data, horario_inicio, horario_fim, tipo, observacoes_comportamentais, presenca, confirmada, recorrencia_id) VALUES
-- 09:00 | Marcos Ribeiro
(721,2,'2026-04-27','09:00:00','10:00:00','Sessão Regular',NULL,1,1,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(722,2,'2026-04-28','09:00:00','10:00:00','Sessão Regular',NULL,1,1,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(723,2,'2026-04-29','09:00:00','10:00:00','Sessão Regular',NULL,1,1,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(724,2,'2026-04-30','09:00:00','10:00:00','Sessão Regular',NULL,1,1,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(725,2,'2026-05-01','09:00:00','10:00:00','Sessão Regular',NULL,1,1,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(726,2,'2026-05-04','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(727,2,'2026-05-05','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(728,2,'2026-05-06','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(729,2,'2026-05-07','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(730,2,'2026-05-08','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(731,2,'2026-05-11','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(732,2,'2026-05-12','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(733,2,'2026-05-13','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(734,2,'2026-05-14','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(735,2,'2026-05-15','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(736,2,'2026-05-18','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(737,2,'2026-05-19','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(738,2,'2026-05-20','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(739,2,'2026-05-21','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(740,2,'2026-05-22','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(741,2,'2026-05-25','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(742,2,'2026-05-26','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(743,2,'2026-05-27','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(744,2,'2026-05-28','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
(745,2,'2026-05-29','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000009-19-06-2026'),
-- 11:00 | Gabriel Costa
(746,2,'2026-04-27','11:00:00','12:00:00','Sessão Regular',NULL,1,1,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(747,2,'2026-04-28','11:00:00','12:00:00','Sessão Regular',NULL,1,1,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(748,2,'2026-04-29','11:00:00','12:00:00','Sessão Regular',NULL,1,1,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(749,2,'2026-04-30','11:00:00','12:00:00','Sessão Regular',NULL,1,1,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(750,2,'2026-05-01','11:00:00','12:00:00','Sessão Regular',NULL,1,1,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(751,2,'2026-05-04','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(752,2,'2026-05-05','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(753,2,'2026-05-06','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(754,2,'2026-05-07','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(755,2,'2026-05-08','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(756,2,'2026-05-11','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(757,2,'2026-05-12','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(758,2,'2026-05-13','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(759,2,'2026-05-14','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(760,2,'2026-05-15','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(761,2,'2026-05-18','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(762,2,'2026-05-19','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(763,2,'2026-05-20','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(764,2,'2026-05-21','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(765,2,'2026-05-22','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(766,2,'2026-05-25','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(767,2,'2026-05-26','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(768,2,'2026-05-27','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(769,2,'2026-05-28','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000011-19-06-2026'),
(770,2,'2026-05-29','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'bb000000-0000-0000-0000-000000000011-19-06-2026');

INSERT INTO consulta_funcionario (id, consulta_id, funcionario_id) VALUES
-- 09:00 Mariana (ids 721–745) → func 3 Marcos Ribeiro
(721,721,3),(722,722,3),(723,723,3),(724,724,3),(725,725,3),(726,726,3),(727,727,3),(728,728,3),(729,729,3),(730,730,3),(731,731,3),(732,732,3),(733,733,3),(734,734,3),(735,735,3),(736,736,3),(737,737,3),(738,738,3),(739,739,3),(740,740,3),(741,741,3),(742,742,3),(743,743,3),(744,744,3),(745,745,3),
-- 11:00 Mariana (ids 746–770) → func 10 Gabriel Costa
(746,746,10),(747,747,10),(748,748,10),(749,749,10),(750,750,10),(751,751,10),(752,752,10),(753,753,10),(754,754,10),(755,755,10),(756,756,10),(757,757,10),(758,758,10),(759,759,10),(760,760,10),(761,761,10),(762,762,10),(763,763,10),(764,764,10),(765,765,10),(766,766,10),(767,767,10),(768,768,10),(769,769,10),(770,770,10);

-- ===================================================
-- RECORRÊNCIAS DE TESTE — Vencendo semana 08–13/06/2026
-- Formato recorrencia_id: {UUID}-DD-MM-YYYY
-- Cron roda e detecta: dataFim extrai últimos 10 chars
-- ===================================================

-- Recorrência A — URGENTE (vence seg 08/06) | Paciente: Pedro (3) | Psicopedagogia (func 7)
INSERT INTO consulta_prontuario (id, paciente_id, data, horario_inicio, horario_fim, tipo, observacoes_comportamentais, presenca, confirmada, recorrencia_id) VALUES
(2001,3,'2026-06-08','10:00:00','11:00:00','Sessão Regular',NULL,NULL,0,'cc000000-0000-0000-0000-000000000001-19-06-2026');

INSERT INTO consulta_funcionario (id, consulta_id, funcionario_id) VALUES
(2001,2001,7);

-- Recorrência B — ATENÇÃO (vence qua 10/06) | Paciente: Mariana (2) | Fisioterapia (func 9)
INSERT INTO consulta_prontuario (id, paciente_id, data, horario_inicio, horario_fim, tipo, observacoes_comportamentais, presenca, confirmada, recorrencia_id) VALUES
(2002,2,'2026-06-08','14:00:00','15:00:00','Sessão Regular',NULL,NULL,0,'cc000000-0000-0000-0000-000000000002-19-06-2026'),
(2003,2,'2026-06-09','14:00:00','15:00:00','Sessão Regular',NULL,NULL,0,'cc000000-0000-0000-0000-000000000002-19-06-2026'),
(2004,2,'2026-06-10','14:00:00','15:00:00','Sessão Regular',NULL,NULL,0,'cc000000-0000-0000-0000-000000000002-19-06-2026');

INSERT INTO consulta_funcionario (id, consulta_id, funcionario_id) VALUES
(2002,2002,9),(2003,2003,9),(2004,2004,9);

-- Recorrência C — ESTA SEMANA (vence sex 13/06) | Paciente: Maria Santos (7) | Musicoterapia (func 11)
INSERT INTO consulta_prontuario (id, paciente_id, data, horario_inicio, horario_fim, tipo, observacoes_comportamentais, presenca, confirmada, recorrencia_id) VALUES
(2005,7,'2026-06-08','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'cc000000-0000-0000-0000-000000000003-19-06-2026'),
(2006,7,'2026-06-10','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'cc000000-0000-0000-0000-000000000003-19-06-2026'),
(2007,7,'2026-06-12','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'cc000000-0000-0000-0000-000000000003-19-06-2026');

INSERT INTO consulta_funcionario (id, consulta_id, funcionario_id) VALUES
(2005,2005,11),(2006,2006,11),(2007,2007,11);

-- ===================================================
-- CONSULTAS MARIANA COSTA — Nova série recorrente
-- Período  : 08/06/2026 a 19/06/2026 (data_fim=19/06/2026)
-- Frequência: segunda, quarta e sexta
-- Horários  : 08h-12h (uma consulta por hora)
-- Especialidades: 08h=Fonoaudiologia(func3), 09h=Psicopedagogia(func7),
--                 10h=Psicomotricidade(func10), 11h=Fisioterapia(func9),
--                 12h=Nutricionista(func8)
-- ===================================================

INSERT INTO consulta_prontuario (id, paciente_id, data, horario_inicio, horario_fim, tipo, observacoes_comportamentais, presenca, confirmada, recorrencia_id) VALUES
-- 08h | Fonoaudiologia | Marcos Ribeiro (func 3)
(2008,2,'2026-06-08','08:00:00','09:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000008-19-06-2026'),
(2013,2,'2026-06-10','08:00:00','09:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000008-19-06-2026'),
(2018,2,'2026-06-12','08:00:00','09:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000008-19-06-2026'),
(2023,2,'2026-06-15','08:00:00','09:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000008-19-06-2026'),
(2028,2,'2026-06-17','08:00:00','09:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000008-19-06-2026'),
(2033,2,'2026-06-19','08:00:00','09:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000008-19-06-2026'),
-- 09h | Psicopedagogia | Camila Rocha (func 7)
(2009,2,'2026-06-08','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000009-19-06-2026'),
(2014,2,'2026-06-10','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000009-19-06-2026'),
(2019,2,'2026-06-12','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000009-19-06-2026'),
(2024,2,'2026-06-15','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000009-19-06-2026'),
(2029,2,'2026-06-17','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000009-19-06-2026'),
(2034,2,'2026-06-19','09:00:00','10:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000009-19-06-2026'),
-- 10h | Psicomotricidade | Gabriel Costa (func 10)
(2010,2,'2026-06-08','10:00:00','11:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000010-19-06-2026'),
(2015,2,'2026-06-10','10:00:00','11:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000010-19-06-2026'),
(2020,2,'2026-06-12','10:00:00','11:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000010-19-06-2026'),
(2025,2,'2026-06-15','10:00:00','11:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000010-19-06-2026'),
(2030,2,'2026-06-17','10:00:00','11:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000010-19-06-2026'),
(2035,2,'2026-06-19','10:00:00','11:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000010-19-06-2026'),
-- 11h | Fisioterapia | Fernanda Lima (func 9)
(2011,2,'2026-06-08','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000011-19-06-2026'),
(2016,2,'2026-06-10','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000011-19-06-2026'),
(2021,2,'2026-06-12','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000011-19-06-2026'),
(2026,2,'2026-06-15','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000011-19-06-2026'),
(2031,2,'2026-06-17','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000011-19-06-2026'),
(2036,2,'2026-06-19','11:00:00','12:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000011-19-06-2026'),
-- 12h | Nutricionista | Diego Martins (func 8)
(2012,2,'2026-06-08','12:00:00','13:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000012-19-06-2026'),
(2017,2,'2026-06-10','12:00:00','13:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000012-19-06-2026'),
(2022,2,'2026-06-12','12:00:00','13:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000012-19-06-2026'),
(2027,2,'2026-06-15','12:00:00','13:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000012-19-06-2026'),
(2032,2,'2026-06-17','12:00:00','13:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000012-19-06-2026'),
(2037,2,'2026-06-19','12:00:00','13:00:00','Sessão Regular',NULL,NULL,0,'dd000000-0000-0000-0000-000000000012-19-06-2026');

INSERT INTO consulta_funcionario (id, consulta_id, funcionario_id) VALUES
-- 08h Fonoaudiologia (ids 2008,2013,2018,2023,2028,2033) → func 3 Marcos Ribeiro
(2008,2008,3),(2013,2013,3),(2018,2018,3),(2023,2023,3),(2028,2028,3),(2033,2033,3),
-- 09h Psicopedagogia (ids 2009,2014,2019,2024,2029,2034) → func 7 Camila Rocha
(2009,2009,7),(2014,2014,7),(2019,2019,7),(2024,2024,7),(2029,2029,7),(2034,2034,7),
-- 10h Psicomotricidade (ids 2010,2015,2020,2025,2030,2035) → func 10 Gabriel Costa
(2010,2010,10),(2015,2015,10),(2020,2020,10),(2025,2025,10),(2030,2030,10),(2035,2035,10),
-- 11h Fisioterapia (ids 2011,2016,2021,2026,2031,2036) → func 9 Fernanda Lima
(2011,2011,9),(2016,2016,9),(2021,2021,9),(2026,2026,9),(2031,2031,9),(2036,2036,9),
-- 12h Nutricionista (ids 2012,2017,2022,2027,2032,2037) → func 8 Diego Martins
(2012,2012,8),(2017,2017,8),(2022,2022,8),(2027,2027,8),(2032,2032,8),(2037,2037,8);
