-- Trigger: biu_addresses on nonedb.log_action

-- DROP TRIGGER biu_addresses ON nonedb.addresses;

create or replace function trg_addresses_audit() returns trigger as $trg_addresses_audit$
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
$trg_addresses_audit$ language plpgsql;

--Trigger
CREATE TRIGGER biu_addresses
  BEFORE INSERT OR UPDATE
  ON nonedb.addresses
  FOR EACH ROW
  EXECUTE PROCEDURE trg_addresses_audit();

--GRANT execute on function trg_addresses_type_audit() to dev;
