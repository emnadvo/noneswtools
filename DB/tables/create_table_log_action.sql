-- Table: nonedb.log_action

-- DROP TABLE nonedb.log_action;

CREATE TABLE nonedb.log_action
(
  rec_id serial NOT NULL,
  action_type character varying(20),
  action_desc character varying(1000),
  log_section character varying(100),
  created_by character varying(50),
  created_when date,
  updated_by character varying(50),
  updated_when date,
  arch character varying(1) default null,
  CONSTRAINT log_action_pkey PRIMARY KEY (rec_id)
);

--WITH (
--  OIDS=FALSE
--);

comment on table nonedb.log_action is 'Logovaci tabulka - pro vyvoj';

comment on column nonedb.log_action.rec_id is 'ID záznamu';
comment on column nonedb.log_action.action_type is 'Typ operace (napr. DEBUG, INFO)';
comment on column nonedb.log_action.action_desc is 'Popis operace - log zpráva';
comment on column nonedb.log_action.log_section is 'Sekce logu (napr. PROCEDURE, SCRIPT';
comment on column nonedb.log_action.created_by is 'Vytvořeno kým';
comment on column nonedb.log_action.created_when is 'Vytvořeno kdy';
comment on column nonedb.log_action.updated_by is 'Upraveno kým';
comment on column nonedb.log_action.updated_when is 'Upraveno kdy'
comment on column nonedb.log_action.arch is 'Příznak pro archivaci - N'

commit;
