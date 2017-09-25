CREATE OR REPLACE TRIGGER ToAmdBase_trigger after insert or update or delete on bssm_base_parts
for each row
declare
		 bRec bssm_base_parts%rowtype := null;
begin
if inserting or updating then
	if (:new.lock_sid = '2') then
		bRec.lock_sid := :new.lock_sid;
		bRec.nsn := :new.nsn;
		bRec.sran := :new.sran;
		bRec.replacement_indicator := :new.replacement_indicator;
		bRec.repair_indicator := :new.repair_indicator;
		bRec.rsp_on_hand := :new.rsp_on_hand;
  		bRec.rsp_objective 	:= :new.rsp_objective;
		bRec.order_cost := :new.order_cost;
		bRec.holding_cost := :new.holding_cost;
		bRec.backorder_fixed_cost := :new.backorder_fixed_cost;
		bRec.backorder_variable_cost := :new.backorder_variable_cost;
		bRec.setflag := :new.setflag;
		amd_cleaned_from_bssm_pkg.UpdateAmdBaseByTrigger(bRec);
	end if;
elsif deleting then
	if (:old.lock_sid = '2') then
		bRec.lock_sid := :old.lock_sid;
		bRec.nsn := :old.nsn;
		bRec.sran := :old.sran;
		bRec.replacement_indicator := :old.replacement_indicator;
		bRec.repair_indicator := :old.repair_indicator;
		bRec.rsp_on_hand := :old.rsp_on_hand;
  		bRec.rsp_objective 	:= :old.rsp_objective;
		bRec.order_cost := :old.order_cost;
		bRec.holding_cost := :old.holding_cost;
		bRec.backorder_fixed_cost := :old.backorder_fixed_cost;
		bRec.backorder_variable_cost := :old.backorder_variable_cost;
		bRec.setflag := :old.setflag;
		amd_cleaned_from_bssm_pkg.OnBaseResetByTrigger(bRec);
	end if;
end if;
end ToAmdBase_trigger;
/ 
