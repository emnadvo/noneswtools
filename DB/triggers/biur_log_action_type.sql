create or replace function trg_log_action_audit() returns trigger as $trg_log_action_audit$
declare 
	lv_act_user 	nonedb.log_action.created_by%type;
	lv_act_date 	nonedb.log_action.created_when%type;
begin
	if (tg_op = 'INSERT') then
		update nonedb.log_action
		set created_by = user,
		    created_when = now()
		where rec_id = new.rec_id;		
	elsif (tg_op = 'UPDATE') then
		update nonedb.log_action
		set updated_by = user,
		    updated_when = now()
		where rec_id = old.rec_id;		
	end if;
	
	return new;
end;
$trg_log_action_audit$ language plpgsql;


-- Trigger: biu_log_action_type on nonedb.log_action

-- DROP TRIGGER biu_log_action_type ON nonedb.log_action;

CREATE TRIGGER biu_log_action_type
  AFTER INSERT OR UPDATE
  ON nonedb.log_action
  FOR EACH ROW
  EXECUTE PROCEDURE trg_log_action_audit();
