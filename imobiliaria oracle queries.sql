/* ============================================================================
   IMOBILIÁRIA VENÂNCIO & FILHOS, LDA. - SISTEMA DE GESTÃO IMOBILIÁRIA
   Script Oracle com todas as queries extraídas do projecto
   Projecto de Base de Dados - Laboratório de Administração Oracle
   Universidade Joaquim Chissano - Maputo, Agosto 2026

   Conteúdo:
     1. Normalização (1FN, 2FN, 3FN)
     2. Criação de tabelas, chaves e restrições (DDL final)
     3. Sequências
     4. Trigger
     5. Dados de teste (INSERT)
     6. Procedimento armazenado
     7. Backup e Recovery (RMAN)
   ============================================================================ */

SET DEFINE OFF;
SET SERVEROUTPUT ON;


/* ============================================================================
   1. NORMALIZAÇÃO
   ============================================================================ */

-- ----------------------------------------------------------------------------
-- 1.1. PRIMEIRA FORMA NORMAL (1FN)
--      Cada campo contém apenas um valor.
-- ----------------------------------------------------------------------------

CREATE TABLE PROPRIETARIO_1FN (
    proprietario_id NUMBER(10) PRIMARY KEY,
    nome VARCHAR2(120) NOT NULL,
    telefone VARCHAR2(30) NOT NULL,
    email VARCHAR2(120),
    documento_numero VARCHAR2(40)
);

CREATE TABLE IMOVEL_1FN (
    imovel_id NUMBER(10) PRIMARY KEY,
    proprietario_id NUMBER(10),
    tipo VARCHAR2(40) NOT NULL,
    endereco VARCHAR2(200) NOT NULL,
    finalidade VARCHAR2(15),
    preco_base NUMBER(14,2),
    estado VARCHAR2(20)
);

CREATE TABLE CLIENTE_1FN (
    cliente_id NUMBER(10) PRIMARY KEY,
    nome VARCHAR2(120) NOT NULL,
    telefone VARCHAR2(30) NOT NULL,
    email VARCHAR2(120),
    tipo_cliente VARCHAR2(15)
);

CREATE TABLE CORRETOR_1FN (
    corretor_id NUMBER(10) PRIMARY KEY,
    nome VARCHAR2(120) NOT NULL,
    telefone VARCHAR2(30) NOT NULL,
    email VARCHAR2(120),
    estado VARCHAR2(15)
);

CREATE TABLE ANUNCIO_1FN (
    anuncio_id NUMBER(10) PRIMARY KEY,
    imovel_id NUMBER(10),
    corretor_id NUMBER(10),
    modalidade VARCHAR2(15),
    preco NUMBER(14,2),
    estado VARCHAR2(15)
);

CREATE TABLE VISITA_1FN (
    visita_id NUMBER(10) PRIMARY KEY,
    anuncio_id NUMBER(10),
    cliente_id NUMBER(10),
    corretor_id NUMBER(10),
    data_hora TIMESTAMP,
    estado VARCHAR2(15)
);

CREATE TABLE PROPOSTA_1FN (
    proposta_id NUMBER(10) PRIMARY KEY,
    anuncio_id NUMBER(10),
    cliente_id NUMBER(10),
    valor NUMBER(14,2),
    data_proposta DATE,
    estado VARCHAR2(15)
);

CREATE TABLE CONTRATO_1FN (
    contrato_id NUMBER(10) PRIMARY KEY,
    proposta_id NUMBER(10),
    tipo_contrato VARCHAR2(20),
    data_inicio DATE,
    data_fim DATE,
    valor_total NUMBER(14,2)
);

-- ----------------------------------------------------------------------------
-- 1.2. SEGUNDA FORMA NORMAL (2FN)
--      Todos os atributos dependem da chave primária completa da tabela.
-- ----------------------------------------------------------------------------

CREATE TABLE PROPRIETARIO_2FN (
    proprietario_id NUMBER(10) PRIMARY KEY,
    nome VARCHAR2(120) NOT NULL,
    telefone VARCHAR2(30) NOT NULL,
    email VARCHAR2(120),
    documento_numero VARCHAR2(40) UNIQUE
);

CREATE TABLE IMOVEL_2FN (
    imovel_id NUMBER(10) PRIMARY KEY,
    proprietario_id NUMBER(10),
    tipo VARCHAR2(40) NOT NULL,
    endereco VARCHAR2(200) NOT NULL,
    finalidade VARCHAR2(15),
    preco_base NUMBER(14,2),
    estado VARCHAR2(20),
    CONSTRAINT FK_IMOVEL_PROP_2FN
        FOREIGN KEY (proprietario_id)
        REFERENCES PROPRIETARIO_2FN(proprietario_id)
);

CREATE TABLE CLIENTE_2FN (
    cliente_id NUMBER(10) PRIMARY KEY,
    nome VARCHAR2(120) NOT NULL,
    telefone VARCHAR2(30) NOT NULL,
    email VARCHAR2(120),
    tipo_cliente VARCHAR2(15)
);

CREATE TABLE CORRETOR_2FN (
    corretor_id NUMBER(10) PRIMARY KEY,
    nome VARCHAR2(120) NOT NULL,
    telefone VARCHAR2(30) NOT NULL,
    email VARCHAR2(120) UNIQUE,
    estado VARCHAR2(15)
);

CREATE TABLE ANUNCIO_2FN (
    anuncio_id NUMBER(10) PRIMARY KEY,
    imovel_id NUMBER(10),
    corretor_id NUMBER(10),
    modalidade VARCHAR2(15),
    preco NUMBER(14,2),
    estado VARCHAR2(15),
    CONSTRAINT FK_ANUNCIO_IMOVEL_2FN
        FOREIGN KEY (imovel_id)
        REFERENCES IMOVEL_2FN(imovel_id),
    CONSTRAINT FK_ANUNCIO_CORRETOR_2FN
        FOREIGN KEY (corretor_id)
        REFERENCES CORRETOR_2FN(corretor_id)
);

CREATE TABLE VISITA_2FN (
    visita_id NUMBER(10) PRIMARY KEY,
    anuncio_id NUMBER(10),
    cliente_id NUMBER(10),
    corretor_id NUMBER(10),
    data_hora TIMESTAMP,
    estado VARCHAR2(15),
    CONSTRAINT FK_VISITA_ANUNCIO_2FN
        FOREIGN KEY (anuncio_id)
        REFERENCES ANUNCIO_2FN(anuncio_id),
    CONSTRAINT FK_VISITA_CLIENTE_2FN
        FOREIGN KEY (cliente_id)
        REFERENCES CLIENTE_2FN(cliente_id),
    CONSTRAINT FK_VISITA_CORRETOR_2FN
        FOREIGN KEY (corretor_id)
        REFERENCES CORRETOR_2FN(corretor_id)
);

CREATE TABLE PROPOSTA_2FN (
    proposta_id NUMBER(10) PRIMARY KEY,
    anuncio_id NUMBER(10),
    cliente_id NUMBER(10),
    valor NUMBER(14,2),
    data_proposta DATE,
    estado VARCHAR2(15),
    CONSTRAINT FK_PROPOSTA_ANUNCIO_2FN
        FOREIGN KEY (anuncio_id)
        REFERENCES ANUNCIO_2FN(anuncio_id),
    CONSTRAINT FK_PROPOSTA_CLIENTE_2FN
        FOREIGN KEY (cliente_id)
        REFERENCES CLIENTE_2FN(cliente_id)
);

CREATE TABLE CONTRATO_2FN (
    contrato_id NUMBER(10) PRIMARY KEY,
    proposta_id NUMBER(10) UNIQUE,
    tipo_contrato VARCHAR2(20),
    data_inicio DATE,
    data_fim DATE,
    valor_total NUMBER(14,2),
    CONSTRAINT FK_CONTRATO_PROPOSTA_2FN
        FOREIGN KEY (proposta_id)
        REFERENCES PROPOSTA_2FN(proposta_id)
);

-- ----------------------------------------------------------------------------
-- 1.3. TERCEIRA FORMA NORMAL (3FN)
--      Não existem dependências transitivas relevantes.
--
--      NOTA: as tabelas da 3FN têm os mesmos nomes das tabelas finais da
--      secção 2 (PROPRIETARIO, IMOVEL, ...). Por isso este bloco está
--      comentado, para evitar o erro ORA-00955 (nome já utilizado).
--      Para executar apenas a 3FN, descomente este bloco e não execute a
--      secção 2 (a secção 2 é a versão final, com CONSTRAINTS nomeadas e CHECK).
-- ----------------------------------------------------------------------------

/*
CREATE TABLE PROPRIETARIO (
    proprietario_id NUMBER(10) PRIMARY KEY,
    nome VARCHAR2(120) NOT NULL,
    telefone VARCHAR2(30) NOT NULL,
    email VARCHAR2(120),
    documento_numero VARCHAR2(40) UNIQUE
);

CREATE TABLE IMOVEL (
    imovel_id NUMBER(10) PRIMARY KEY,
    proprietario_id NUMBER(10) NOT NULL,
    tipo VARCHAR2(40) NOT NULL,
    endereco VARCHAR2(200) NOT NULL,
    finalidade VARCHAR2(15),
    preco_base NUMBER(14,2),
    estado VARCHAR2(20),
    CONSTRAINT FK_IMOVEL_PROPRIETARIO
        FOREIGN KEY (proprietario_id)
        REFERENCES PROPRIETARIO(proprietario_id)
);

CREATE TABLE CLIENTE (
    cliente_id NUMBER(10) PRIMARY KEY,
    nome VARCHAR2(120) NOT NULL,
    telefone VARCHAR2(30) NOT NULL,
    email VARCHAR2(120),
    tipo_cliente VARCHAR2(15)
);

CREATE TABLE CORRETOR (
    corretor_id NUMBER(10) PRIMARY KEY,
    nome VARCHAR2(120) NOT NULL,
    telefone VARCHAR2(30) NOT NULL,
    email VARCHAR2(120) UNIQUE,
    estado VARCHAR2(15)
);

CREATE TABLE ANUNCIO (
    anuncio_id NUMBER(10) PRIMARY KEY,
    imovel_id NUMBER(10) NOT NULL,
    corretor_id NUMBER(10) NOT NULL,
    modalidade VARCHAR2(15),
    preco NUMBER(14,2) NOT NULL,
    estado VARCHAR2(15),
    CONSTRAINT FK_ANUNCIO_IMOVEL
        FOREIGN KEY (imovel_id)
        REFERENCES IMOVEL(imovel_id),
    CONSTRAINT FK_ANUNCIO_CORRETOR
        FOREIGN KEY (corretor_id)
        REFERENCES CORRETOR(corretor_id)
);

CREATE TABLE VISITA (
    visita_id NUMBER(10) PRIMARY KEY,
    anuncio_id NUMBER(10) NOT NULL,
    cliente_id NUMBER(10) NOT NULL,
    corretor_id NUMBER(10) NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    estado VARCHAR2(15),
    CONSTRAINT FK_VISITA_ANUNCIO
        FOREIGN KEY (anuncio_id)
        REFERENCES ANUNCIO(anuncio_id),
    CONSTRAINT FK_VISITA_CLIENTE
        FOREIGN KEY (cliente_id)
        REFERENCES CLIENTE(cliente_id),
    CONSTRAINT FK_VISITA_CORRETOR
        FOREIGN KEY (corretor_id)
        REFERENCES CORRETOR(corretor_id)
);

CREATE TABLE PROPOSTA (
    proposta_id NUMBER(10) PRIMARY KEY,
    anuncio_id NUMBER(10) NOT NULL,
    cliente_id NUMBER(10) NOT NULL,
    valor NUMBER(14,2) NOT NULL,
    data_proposta DATE NOT NULL,
    estado VARCHAR2(15),
    CONSTRAINT FK_PROPOSTA_ANUNCIO
        FOREIGN KEY (anuncio_id)
        REFERENCES ANUNCIO(anuncio_id),
    CONSTRAINT FK_PROPOSTA_CLIENTE
        FOREIGN KEY (cliente_id)
        REFERENCES CLIENTE(cliente_id)
);

CREATE TABLE CONTRATO (
    contrato_id NUMBER(10) PRIMARY KEY,
    proposta_id NUMBER(10) UNIQUE NOT NULL,
    tipo_contrato VARCHAR2(20) NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    valor_total NUMBER(14,2) NOT NULL,
    CONSTRAINT FK_CONTRATO_PROPOSTA
        FOREIGN KEY (proposta_id)
        REFERENCES PROPOSTA(proposta_id)
);
*/


/* ============================================================================
   2. CRIAÇÃO DE TABELAS, CHAVES E RESTRIÇÕES (DDL FINAL)
   ============================================================================ */

-- 2.1. Tabela PROPRIETARIO
CREATE TABLE proprietario (
    proprietario_id NUMBER(10) CONSTRAINT pk_proprietario PRIMARY KEY,
    nome VARCHAR2(120) CONSTRAINT nn_prop_nome NOT NULL,
    telefone VARCHAR2(30) CONSTRAINT nn_prop_tel NOT NULL,
    email VARCHAR2(120),
    documento_numero VARCHAR2(40) CONSTRAINT unq_prop_doc UNIQUE
);

-- 2.2. Tabela IMOVEL
CREATE TABLE imovel (
    imovel_id NUMBER(10) CONSTRAINT pk_imovel PRIMARY KEY,
    proprietario_id NUMBER(10) CONSTRAINT nn_imovel_prop NOT NULL,
    tipo VARCHAR2(40) CONSTRAINT nn_imovel_tipo NOT NULL,
    endereco VARCHAR2(200) CONSTRAINT nn_imovel_end NOT NULL,
    finalidade VARCHAR2(15) CONSTRAINT ck_imovel_fin CHECK (finalidade IN ('VENDA', 'ARRENDAMENTO')),
    preco_base NUMBER(14,2) CONSTRAINT ck_imovel_preco CHECK (preco_base >= 0),
    estado VARCHAR2(20) CONSTRAINT ck_imovel_estado CHECK (estado IN ('DISPONIVEL', 'RESERVADO', 'NEGOCIADO')),
    CONSTRAINT fk_imovel_proprietario FOREIGN KEY (proprietario_id) REFERENCES proprietario(proprietario_id)
);

-- 2.3. Tabela CLIENTE
CREATE TABLE cliente (
    cliente_id NUMBER(10) CONSTRAINT pk_cliente PRIMARY KEY,
    nome VARCHAR2(120) CONSTRAINT nn_cli_nome NOT NULL,
    telefone VARCHAR2(30) CONSTRAINT nn_cli_tel NOT NULL,
    email VARCHAR2(120),
    tipo_cliente VARCHAR2(15) CONSTRAINT ck_cli_tipo CHECK (tipo_cliente IN ('COMPRADOR', 'INQUILINO'))
);

-- 2.4. Tabela CORRETOR
CREATE TABLE corretor (
    corretor_id NUMBER(10) CONSTRAINT pk_corretor PRIMARY KEY,
    nome VARCHAR2(120) CONSTRAINT nn_corr_nome NOT NULL,
    telefone VARCHAR2(30) CONSTRAINT nn_corr_tel NOT NULL,
    email VARCHAR2(120) CONSTRAINT unq_corr_email UNIQUE,
    estado VARCHAR2(15) CONSTRAINT ck_corr_estado CHECK (estado IN ('ATIVO', 'INATIVO'))
);

-- 2.5. Tabela ANUNCIO
CREATE TABLE anuncio (
    anuncio_id NUMBER(10) CONSTRAINT pk_anuncio PRIMARY KEY,
    imovel_id NUMBER(10) CONSTRAINT nn_anunc_imovel NOT NULL,
    corretor_id NUMBER(10) CONSTRAINT nn_anunc_corr NOT NULL,
    modalidade VARCHAR2(15) CONSTRAINT ck_anunc_mod CHECK (modalidade IN ('VENDA', 'ARRENDAMENTO')),
    preco NUMBER(14,2) CONSTRAINT nn_anunc_preco NOT NULL,
    estado VARCHAR2(15) CONSTRAINT ck_anunc_estado CHECK (estado IN ('ATIVO', 'ENCERRADO')),
    CONSTRAINT fk_anuncio_imovel FOREIGN KEY (imovel_id) REFERENCES imovel(imovel_id),
    CONSTRAINT fk_anuncio_corretor FOREIGN KEY (corretor_id) REFERENCES corretor(corretor_id)
);

-- 2.6. Tabela VISITA
CREATE TABLE visita (
    visita_id NUMBER(10) CONSTRAINT pk_visita PRIMARY KEY,
    anuncio_id NUMBER(10) CONSTRAINT nn_vis_anunc NOT NULL,
    cliente_id NUMBER(10) CONSTRAINT nn_vis_cli NOT NULL,
    corretor_id NUMBER(10) CONSTRAINT nn_vis_corr NOT NULL,
    data_hora TIMESTAMP CONSTRAINT nn_vis_data NOT NULL,
    estado VARCHAR2(15) CONSTRAINT ck_vis_estado CHECK (estado IN ('AGENDADA', 'REALIZADA', 'CANCELADA')),
    CONSTRAINT fk_visita_anuncio FOREIGN KEY (anuncio_id) REFERENCES anuncio(anuncio_id),
    CONSTRAINT fk_visita_cliente FOREIGN KEY (cliente_id) REFERENCES cliente(cliente_id),
    CONSTRAINT fk_visita_corretor FOREIGN KEY (corretor_id) REFERENCES corretor(corretor_id)
);

-- 2.7. Tabela PROPOSTA
CREATE TABLE proposta (
    proposta_id NUMBER(10) CONSTRAINT pk_proposta PRIMARY KEY,
    anuncio_id NUMBER(10) CONSTRAINT nn_prop_anunc NOT NULL,
    cliente_id NUMBER(10) CONSTRAINT nn_prop_cli NOT NULL,
    valor NUMBER(14,2) CONSTRAINT nn_prop_val NOT NULL,
    data_proposta DATE CONSTRAINT nn_prop_data NOT NULL,
    estado VARCHAR2(15) CONSTRAINT ck_prop_estado CHECK (estado IN ('SUBMETIDA', 'ACEITE', 'REJEITADA')),
    CONSTRAINT fk_proposta_anuncio FOREIGN KEY (anuncio_id) REFERENCES anuncio(anuncio_id),
    CONSTRAINT fk_proposta_cliente FOREIGN KEY (cliente_id) REFERENCES cliente(cliente_id)
);

-- 2.8. Tabela CONTRATO
CREATE TABLE contrato (
    contrato_id NUMBER(10) CONSTRAINT pk_contrato PRIMARY KEY,
    proposta_id NUMBER(10) CONSTRAINT nn_contrato_prop NOT NULL,
    tipo_contrato VARCHAR2(20) CONSTRAINT ck_contrato_tipo CHECK (tipo_contrato IN ('COMPRA', 'ARRENDAMENTO')),
    data_inicio DATE CONSTRAINT nn_contrato_inicio NOT NULL,
    data_fim DATE,
    valor_total NUMBER(14,2) CONSTRAINT nn_contrato_val NOT NULL,
    CONSTRAINT fk_contrato_proposta FOREIGN KEY (proposta_id) REFERENCES proposta(proposta_id),
    CONSTRAINT unq_contrato_proposta UNIQUE (proposta_id)
);


/* ============================================================================
   3. CRIAÇÃO DE SEQUÊNCIAS
   ============================================================================ */

CREATE SEQUENCE seq_proprietario START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_imovel START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_cliente START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_corretor START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_anuncio START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_visita START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_proposta START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_contrato START WITH 1 INCREMENT BY 1;


/* ============================================================================
   4. TRIGGER
   ============================================================================ */

-- Trigger para a tabela PROPRIETARIO
CREATE OR REPLACE TRIGGER trg_proprietario_bi
BEFORE INSERT ON proprietario
FOR EACH ROW
BEGIN
  IF :NEW.proprietario_id IS NULL THEN
    SELECT seq_proprietario.NEXTVAL INTO :NEW.proprietario_id FROM DUAL;
  END IF;
END;
/


/* ============================================================================
   5. DADOS DE TESTE (INSERT)
   ============================================================================ */

-- Inserir Proprietários
INSERT INTO proprietario (proprietario_id, nome, telefone, email, documento_numero)
VALUES (seq_proprietario.NEXTVAL, 'Alberto Venâncio', '+258821234567', 'alberto.venancio@email.com', '110100234567A');

INSERT INTO proprietario (proprietario_id, nome, telefone, email, documento_numero)
VALUES (seq_proprietario.NEXTVAL, 'Maria Cossa', '+258849876543', 'maria.cossa@email.com', '110200987654B');

-- Inserir Imóveis
INSERT INTO imovel (imovel_id, proprietario_id, tipo, endereco, finalidade, preco_base, estado)
VALUES (seq_imovel.NEXTVAL, 1, 'Moradia T3', 'Av. Julius Nyerere, KaMaxaquene, Maputo', 'VENDA', 7500000.00, 'DISPONIVEL');

INSERT INTO imovel (imovel_id, proprietario_id, tipo, endereco, finalidade, preco_base, estado)
VALUES (seq_imovel.NEXTVAL, 2, 'Apartamento T2', 'Bairro Polana Cimento, Maputo', 'ARRENDAMENTO', 45000.00, 'DISPONIVEL');

-- Inserir Clientes
INSERT INTO cliente (cliente_id, nome, telefone, email, tipo_cliente)
VALUES (seq_cliente.NEXTVAL, 'Carlos Mondlane', '+258871112233', 'carlos.mondlane@email.com', 'COMPRADOR');

-- Inserir Corretores
INSERT INTO corretor (corretor_id, nome, telefone, email, estado)
VALUES (seq_corretor.NEXTVAL, 'Helena Sitoe', '+258823334455', 'helena.sitoe@imobiliaria.com', 'ATIVO');

-- Inserir Anúncios
INSERT INTO anuncio (anuncio_id, imovel_id, corretor_id, modalidade, preco, estado)
VALUES (seq_anuncio.NEXTVAL, 1, 1, 'VENDA', 7500000.00, 'ATIVO');

COMMIT;


/* ============================================================================
   6. PROCEDIMENTO ARMAZENADO
   ============================================================================ */

CREATE OR REPLACE PROCEDURE prc_aceitar_proposta (
    p_proposta_id IN NUMBER
) AS
    v_imovel_id NUMBER;
BEGIN
    -- 1. Atualizar o estado da proposta para ACEITE
    UPDATE proposta
    SET estado = 'ACEITE'
    WHERE proposta_id = p_proposta_id;

    -- 2. Obter o imovel_id associado à proposta através do anúncio
    SELECT a.imovel_id INTO v_imovel_id
    FROM proposta p
    JOIN anuncio a ON p.anuncio_id = a.anuncio_id
    WHERE p.proposta_id = p_proposta_id;

    -- 3. Atualizar o estado do imóvel para NEGOCIADO
    UPDATE imovel
    SET estado = 'NEGOCIADO'
    WHERE imovel_id = v_imovel_id;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Erro ao aceitar proposta: ' || SQLERRM);
END;
/


/* ============================================================================
   7. BACKUP E RECOVERY (RMAN)
   ATENÇÃO: estes comandos reiniciam a base de dados e devem ser executados
   apenas por um DBA, em ambiente de teste. Estão comentados de propósito.
   ============================================================================ */

-- 7.1. Activar o modo ARCHIVELOG (SQL*Plus, ligado como SYSDBA)
/*
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;
*/

-- 7.2. Teste de Restore e Recovery - simulação de recuperação (executar no RMAN)
/*
RMAN> SHUTDOWN IMMEDIATE;
RMAN> STARTUP MOUNT;
RMAN> RESTORE DATABASE;
RMAN> RECOVER DATABASE;
RMAN> ALTER DATABASE OPEN;
*/
