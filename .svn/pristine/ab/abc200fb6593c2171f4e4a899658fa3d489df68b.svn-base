CREATE OR REPLACE TRIGGER bssm_parts_toAmdPart_trig after insert or update or delete on bssm_parts
for each row
declare
	bRec bssm_parts%rowtype := null;
begin
	if inserting or updating then
	    if (:new.lock_sid = '2') then
		    bRec.lock_sid := :new.lock_sid;
			bRec.nsn := :new.nsn;
			bRec.part_no := :new.part_no;
			bRec.amc_base_stock := :new.amc_base_stock;
			bRec.amc_days_experience := :new.amc_days_experience;
			bRec.amc_demand := :new.amc_demand;
			bRec.capability_requirement := :new.capability_requirement;
			bRec.user_comment := :new.user_comment;
			bRec.condemn := :new.condemn;
			bRec.criticality := :new.criticality;
			bRec.dla_demand := :new.dla_demand;
			bRec.dla_warehouse_stock := :new.dla_warehouse_stock;
		--	bRec.gold_mfgr_cage := :new.gold_mfgr_cage;
			bRec.add_increment := :new.add_increment;
			bRec.item_type := :new.item_type;
		--	bRec.mfgr := :new.mfgr;
			bRec.mtbdr := :new.mtbdr;
			bRec.mic_code := :new.mic_code;
			bRec.min_purchase_quantity := :new.min_purchase_quantity;
			bRec.modflag1 := :new.modflag1;
			bRec.modflag2 := :new.modflag2;
		--	bRec.setflag1 := :new.setflag1;
		--	bRec.setflag2 := :new.setflag2;
			bRec.nomenclature := :new.nomenclature;
		--	bRec.nongold_flag := :new.nongold_flag;
			bRec.nrts := :new.nrts;
			bRec.off_base_repair_cost := :new.off_base_repair_cost;
			bRec.off_base_turnaround := :new.off_base_turnaround;
			bRec.on_base_turnaround := :new.on_base_turnaround;
			bRec.order_lead_time := :new.order_lead_time;
			bRec.order_uom := :new.order_uom;
			bRec.planner_code := :new.planner_code;
		--	bRec.old_planner_code := :new.old_planner_code;
		--	bRec.planner_code_date := :new.planner_code_date;
			bRec.rts := :new.rts;
			bRec.ru_ind := :new.ru_ind;
			bRec.smr_code := :new.smr_code;
			bRec.transport_cost := :new.transport_cost;
			bRec.unit_cost := :new.unit_cost;
			bRec.fedc_cost := :new.fedc_cost;
		--	bRec.wuc := :new.wuc;
			bRec.demand_variance := :new.demand_variance;
			bRec.demand_average := :new.demand_average;
			bRec.acquisition_advice_code := :new.acquisition_advice_code;
		--	bRec.noncomp_flag := :new.noncomp_flag;
		    amd_cleaned_from_bssm_pkg.UpdateAmdPartByTrigger(bRec);
		end if;
	elsif deleting then
		if (:old.lock_sid = '2') then
		    bRec.lock_sid := :old.lock_sid;
			bRec.nsn := :old.nsn;
			bRec.part_no := :old.part_no;
			bRec.amc_base_stock := :old.amc_base_stock;
			bRec.amc_days_experience := :old.amc_days_experience;
			bRec.amc_demand := :old.amc_demand;
			bRec.capability_requirement := :old.capability_requirement;
			bRec.user_comment := :old.user_comment;
			bRec.condemn := :old.condemn;
			bRec.criticality := :old.criticality;
			bRec.dla_demand := :old.dla_demand;
			bRec.dla_warehouse_stock := :old.dla_warehouse_stock;
		--	bRec.gold_mfgr_cage := :old.gold_mfgr_cage;
			bRec.add_increment := :old.add_increment;
			bRec.item_type := :old.item_type;
		--	bRec.mfgr := :old.mfgr;
			bRec.mtbdr := :old.mtbdr;
			bRec.mic_code := :old.mic_code;
			bRec.min_purchase_quantity := :old.min_purchase_quantity;
			bRec.modflag1 := :old.modflag1;
			bRec.modflag2 := :old.modflag2;
		--	bRec.setflag1 := :old.setflag1;
		--	bRec.setflag2 := :old.setflag2;
			bRec.nomenclature := :old.nomenclature;
			bRec.nongold_flag := :old.nongold_flag;
			bRec.nrts := :old.nrts;
			bRec.off_base_repair_cost := :old.off_base_repair_cost;
			bRec.off_base_turnaround := :old.off_base_turnaround;
			bRec.on_base_turnaround := :old.on_base_turnaround;
			bRec.order_lead_time := :old.order_lead_time;
			bRec.order_uom := :old.order_uom;
			bRec.planner_code := :old.planner_code;
		--	bRec.old_planner_code := :old.old_planner_code;
		--	bRec.planner_code_date := :old.planner_code_date;
			bRec.rts := :old.rts;
			bRec.ru_ind := :old.ru_ind;
			bRec.smr_code := :old.smr_code;
			bRec.transport_cost := :old.transport_cost;
			bRec.unit_cost := :old.unit_cost;
			bRec.fedc_cost := :old.fedc_cost;
		--	bRec.wuc := :old.wuc;
			bRec.demand_variance := :old.demand_variance;
			bRec.demand_average := :old.demand_average;
			bRec.acquisition_advice_code := :old.acquisition_advice_code;
		--	bRec.noncomp_flag := :old.noncomp_flag;
			amd_cleaned_from_bssm_pkg.OnPartResetByTrigger(bRec);
		end if;
	end if;
end bssm_parts_toAmdPart_trig;

/ 
