-- Role: "dev"

-- DROP ROLE dev;

CREATE ROLE dev
  NOSUPERUSER INHERIT CREATEDB NOCREATEROLE;
COMMENT ON ROLE dev IS 'Role pro vývoj databáze.';
