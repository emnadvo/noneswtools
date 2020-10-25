create or replace function trg_c_address_type_audit() returns trigger as $trg_c_address_type_audit$
begin
	if (tg_op = 'INSERT') then
		new.created_by := current_user;
		new.created_when := current_timestamp;--),'DD/MM/YYYY HH24:MI:SS');
	elsif (tg_op = 'UPDATE') then
		new.updated_by := current_user;
		new.updated_when := current_timestamp;--),'DD/MM/YYYY HH24:MI:SS');
	end if;	
	return new;
end;
$trg_c_address_type_audit$ language plpgsql;

-- Trigger: biu_c_address_type on nonedb.c_address_type

-- DROP TRIGGER biu_c_address_type ON nonedb.c_address_type;

--Trigger
CREATE TRIGGER biu_c_address_type
  BEFORE INSERT OR UPDATE
  ON nonedb.c_address_type
  FOR EACH ROW
  EXECUTE PROCEDURE trg_c_address_type_audit();

--GRANT EXECUTE ON FUNCTION trg_c_address_type_audit() TO dev; 
