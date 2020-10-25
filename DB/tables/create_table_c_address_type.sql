create table nonedb.c_address_type
(
	address_type smallint primary key not null,
	address_descr 	varchar(50),
	created_by character varying(50),
	created_when timestamp without time zone,
	updated_by character varying(50),
	updated_when timestamp without time zone,
	arch character varying(1) DEFAULT NULL::character varying	
);

comment on table nonedb.c_address_type is 'Ciselnik typu adres';
comment on column nonedb.c_address_type.address_type is 'Ciselny typ adresy';
comment on column nonedb.c_address_type.address_descr is 'Popis typu adresy';
comment on column nonedb.c_address_type.created_by is 'Vytvoril kdo';
comment on column nonedb.c_address_type.created_when is 'Vytvoril kdy';
comment on column nonedb.c_address_type.updated_by is 'Upravil kdo';
comment on column nonedb.c_address_type.updated_when is 'Upravil kdy';
comment on column nonedb.c_address_type.arch is 'Priznak platnosti';

commit;
