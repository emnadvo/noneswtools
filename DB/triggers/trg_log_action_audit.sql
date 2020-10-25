create or replace function trg_log_action_audit() returns trigger as $trg_log_action_audit$
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
$trg_log_action_audit$ language plpgsql;

commit;

-- Trigger: biu_log_action_type on nonedb.log_action

 DROP TRIGGER biu_log_action_type ON nonedb.log_action;

CREATE TRIGGER biu_log_action_type
  BEFORE INSERT OR UPDATE
  ON nonedb.log_action
  FOR EACH ROW
  EXECUTE PROCEDURE trg_log_action_audit();


select current_timestamp;--,'DD/MM/YYYY HH24:MI:SS');