-- Role: "admin"

-- DROP ROLE "admin";

CREATE ROLE "admin"
  SUPERUSER INHERIT NOCREATEDB CREATEROLE;
UPDATE pg_authid SET rolcatupdate=false WHERE rolname='admin';
COMMENT ON ROLE "admin" IS 'Administrátor databáze.';
