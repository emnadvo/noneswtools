--DROP TABLE addresses;

create table nonedb.addresses
(	
	address_id	serial primary key NOT NULL,
	address_type	smallint,
	client_id		integer NOT NULL,
	addr_lineA	varchar(30) NOT NULL,
	addr_lineB	varchar(30),
	addr_lineC	varchar(30),
	addr_city	varchar(30),
	addr_postcode	varchar(10),
	addr_statecode	smallint,
	created_by character varying(50),
	created_when timestamp without time zone,
	updated_by character varying(50),
	updated_when timestamp without time zone,
	arch character varying(1) DEFAULT NULL::character varying
);

comment on table nonedb.addresses is 'Tabulka pro adresy';

comment on column nonedb.addresses.address_id is 'id adresy';
comment on column nonedb.addresses.address_type is 'typ adresy';
comment on column nonedb.addresses.client_id is 'ID klienta';
comment on column nonedb.addresses.addr_lineA is 'ulice A adresy';
comment on column nonedb.addresses.addr_lineB is 'ulice B adresy';
comment on column nonedb.addresses.addr_lineC is 'ulice C adresy';
comment on column nonedb.addresses.addr_city is 'mesto adresy';
comment on column nonedb.addresses.addr_postcode is 'kod mista (PSC)';
comment on column nonedb.addresses.addr_statecode is 'kod zeme';
comment on column nonedb.addresses.created_by is 'Vytvoril kdo';
comment on column nonedb.addresses.created_when is 'Vytvoril kdy';
comment on column nonedb.addresses.updated_by is 'Upravil kdo';
comment on column nonedb.addresses.updated_when is 'Upravil kdy';
comment on column nonedb.addresses.arch is 'Priznak platnosti';
	
alter table nonedb.addresses add constraint fk_address_type 
FOREIGN KEY (address_type) REFERENCES nonedb.c_address_type(address_type) MATCH FULL;

commit;
