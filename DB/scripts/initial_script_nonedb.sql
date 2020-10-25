-- Role: "developer"

-- DROP ROLE developer;

CREATE ROLE developer
  NOSUPERUSER INHERIT CREATEDB CREATEROLE;

-- Role: "login"

-- DROP ROLE "login";


-- Role: "michal"

-- DROP ROLE michal;

CREATE ROLE michal LOGIN
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE;
GRANT developer TO michal;

-- Database: nonedb

-- DROP DATABASE nonedb;

CREATE DATABASE nonedb
  WITH OWNER = michal
       ENCODING = 'UTF8'
       LC_COLLATE = 'Czech, Czech Republic'
       LC_CTYPE = 'Czech, Czech Republic'
       CONNECTION LIMIT = -1;
GRANT CONNECT, TEMPORARY ON DATABASE nonedb TO public;
--GRANT ALL ON DATABASE nonedb TO michal;
--GRANT ALL ON DATABASE nonedb TO developer WITH GRANT OPTION;

create schema nonedb;

CREATE LANGUAGE plpgsql;

commit;
