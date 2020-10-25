--drop table none_sys.work_notes;

create table none_sys.work_notes(
	id_rec	serial primary key,
	notes_id  integer not null,
	notes_type integer not null,
	notes_import integer not null,
	notes_from	date,
	notes_to	date,
	notes_name	varchar(50) not null,
	notes_text	text,
	created_by character varying(15),
	created_when date,
	update_by character varying(15),
	update_when date,
	arch	varchar(2) default null
	);
comment on table none_sys.work_notes is 'Hlavni tabulka pro záznam úkolù, poznámek a ostatních dùležitých informací.';