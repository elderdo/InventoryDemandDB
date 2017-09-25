CREATE OR REPLACE TRIGGER AMD_OWNER.amd_national_stkitms_aft_trig
AFTER DELETE OR INSERT OR UPDATE
ON AMD_OWNER.AMD_NATIONAL_STOCK_ITEMS REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
THE_TABLE_NAME constant amd_log.table_name%type := 'AMD_NATIONAL_STOCK_ITEMS' ;
action_code varchar2(1) ;
last_update_dt date := sysdate ;


/******************************************************************************
      $Author:   zf297a  $
    $Revision:   1.5  $
        $Date:   28 Apr 2009 10:09:46  $
    $Workfile:   AMD_NATIONAL_STKITMS_AFT_TRIG.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\AMD_NATIONAL_STKITMS_AFT_TRIG.trg.-arc  $
/*   
/*      Rev 1.5   28 Apr 2009 10:09:46   zf297a
/*   Added wesm_indicator
/*   
/*      Rev 1.4   Sep 25 2006 14:53:24   zf297a
/*   Use :new.nsi_sid for the key if the :old.nsi_sid is null - this would occur when inserting a row - all the :old fields would be null.
/*   
/*      Rev 1.3   Sep 18 2006 13:17:20   zf297a
/*   Added boolean function isDiff to handle null's
/*   
/*      Rev 1.2   Jun 01 2006 15:09:48   zf297a
/*   enabled trigger
/*   
/*      Rev 1.1   Jun 01 2006 15:02:22   zf297a
/*   added recording of  the_key for each table
/*   
/*      Rev 1.0   Jun 01 2006 14:39:32   zf297a
/*   Initial revision.
******************************************************************************/
BEGIN
   if inserting then
   	  	 action_code := amd_defaults.INSERT_ACTION ;
   elsif updating then
   		 action_code := amd_defaults.UPDATE_ACTION ;
   else
	 insert into amd_log
	 (table_name, action_code, column_name, last_update_dt, the_key)
	 values (THE_TABLE_NAME, amd_defaults.DELETE_ACTION, 'NSI_SID', last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
	 return ;
   end if ;

   if amd_utils.isDiff(:old.nsn, :new.nsn)  then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'NSN', :old.nsn, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.add_increment,:new.add_increment) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'ADD_INCREMENT',  'Y', :old.add_increment, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.add_increment_cleaned ,:new.add_increment_cleaned) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'ADD_INCREMENT_CLEANED',  'Y', :old.add_increment_cleaned, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.amc_base_stock, :new.amc_base_stock) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'AMC_BASE_STOCK',  'Y', :old.amc_base_stock, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.amc_base_stock_cleaned, :new.amc_base_stock_cleaned) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'AMC_BASE_STOCK_CLEANED',  'Y', :old.amc_base_stock_cleaned, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.amc_days_experience, :new.amc_days_experience) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'AMC_DAYS_EXPERIENCE',  'Y', :old.amc_days_experience, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.amc_days_experience_cleaned, :new.amc_days_experience_cleaned) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'AMC_DAYS_EXPERIENCE_CLEANED',  'Y', :old.amc_days_experience_cleaned, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.amc_demand, :new.amc_demand) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'AMC_DEMAND',  'Y', :old.amc_demand, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.amc_demand_cleaned, :new.amc_demand_cleaned) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'AMC_DEMAND_CLEANED',  'Y', :old.amc_demand_cleaned, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.capability_requirement, :new.capability_requirement) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'CAPABILITY_REQUIREMENT', :old.capability_requirement, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.capability_requirement_cleaned, :new.capability_requirement_cleaned) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'CAPABILITY_REQUIREMENT_CLEANED', :old.capability_requirement_cleaned, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.criticality, :new.criticality) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'CRITICALITY',  'Y', :old.criticality, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.criticality_cleaned, :new.criticality_cleaned) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'CRITICALITY_CLEANED',  'Y', :old.criticality_cleaned, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.distrib_uom, :new.distrib_uom) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'DISTRIB_UOM', :old.distrib_uom, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.distrib_uom_defaulted, :new.distrib_uom_defaulted) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'DISTRIB_UOM_DEFAULTED', :old.distrib_uom_defaulted, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.dla_demand, :new.dla_demand) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'DLA_DEMAND',  'Y', :old.dla_demand, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.dla_demand_cleaned, :new.dla_demand_cleaned) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'DLA_DEMAND_CLEANED',  'Y', :old.dla_demand_cleaned, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.current_backorder, :new.current_backorder) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'CURRENT_BACKORDER',  'Y', :old.current_backorder, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.current_backorder_cleaned, :new.current_backorder_cleaned) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'CURRENT_BACKORDER_CLEANED',  'Y', :old.current_backorder_cleaned, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.fedc_cost, :new.fedc_cost) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'FEDC_COST',  'Y', :old.fedc_cost, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.fedc_cost_cleaned, :new.fedc_cost_cleaned) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'FEDC_COST_CLEANED',  'Y', :old.fedc_cost_cleaned, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.item_type, :new.item_type) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'ITEM_TYPE', :old.item_type, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.item_type_cleaned, :new.item_type_cleaned) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'ITEM_TYPE_CLEANED', :old.item_type_cleaned, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.mic_code_lowest, :new.mic_code_lowest) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'MIC_CODE_LOWEST', :old.mic_code_lowest, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.mic_code_lowest_cleaned, :new.mic_code_lowest_cleaned) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'MIC_CODE_LOWEST_CLEANED', :old.mic_code_lowest_cleaned, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.mtbdr, :new.mtbdr) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'MTBDR',  'Y', :old.mtbdr, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.mtbdr_cleaned, :new.mtbdr_cleaned) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'MTBDR_CLEANED',  'Y', :old.mtbdr_cleaned, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.nomenclature_cleaned, :new.nomenclature_cleaned) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'nomenclature_cleaned', :old.nomenclature_cleaned, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.order_lead_time_cleaned, :new.order_lead_time_cleaned) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'ORDER_LEAD_TIME_CLEANED',  'Y', :old.order_lead_time_cleaned, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.order_quantity, :new.order_quantity) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'ORDER_QUANTITY',  'Y', :old.order_quantity, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.order_quantity_defaulted, :new.order_quantity_defaulted) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'ORDER_QUANTITY_DEFAULTED',  'Y', :old.order_quantity_defaulted, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.order_uom_cleaned, :new.order_uom_cleaned) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'ORDER_UOM_CLEANED', :old.order_uom_cleaned, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.planner_code, :new.planner_code) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'PLANNER_CODE', :old.planner_code, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.planner_code_cleaned, :new.planner_code_cleaned) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'PLANNER_CODE_CLEANED', :old.planner_code_cleaned, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.prime_part_no, :new.prime_part_no) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'PRIME_PART_NO', :old.prime_part_no, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.qpei_weighted, :new.qpei_weighted) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'QPEI_WEIGHTED',  'Y', :old.qpei_weighted, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.qpei_weighted_defaulted, :new.qpei_weighted_defaulted) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'QPEI_WEIGHTED_DEFAULTED',  'Y', :old.qpei_weighted_defaulted, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.ru_ind, :new.ru_ind) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'RU_IND', :old.ru_ind, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.ru_ind_cleaned, :new.ru_ind_cleaned) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'RU_IND_CLEANED', :old.ru_ind_cleaned, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.smr_code, :new.smr_code) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'SMR_CODE', :old.smr_code, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.smr_code_defaulted, :new.smr_code_defaulted) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'SMR_CODE_defaulted', :old.smr_code_defaulted, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.unit_cost_cleaned, :new.unit_cost_cleaned) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'UNIT_COST_CLEANED',  'Y', :old.unit_cost_cleaned, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.user_comment, :new.user_comment) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'USER_COMMENT', :old.user_comment, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.condemn_avg, :new.condemn_avg) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'CONDEMN_AVG',  'Y', :old.condemn_avg, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.condemn_avg_defaulted, :new.condemn_avg_defaulted) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'CONDEMN_AVG_DEFAULTED',  'Y', :old.condemn_avg_defaulted, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.condemn_avg_cleaned, :new.condemn_avg_cleaned) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'CONDEMN_AVG_CLEANED',  'Y', :old.condemn_avg_cleaned, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.nrts_avg, :new.nrts_avg) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'NRTS_AVG',  'Y', :old.nrts_avg, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.nrts_avg_defaulted, :new.nrts_avg_defaulted) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'NRTS_AVG_DEFAULTED',  'Y', :old.nrts_avg_defaulted, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.nrts_avg_cleaned, :new.nrts_avg_cleaned) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'NRTS_AVG_CLEANED',  'Y', :old.nrts_avg_cleaned, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.rts_avg, :new.rts_avg) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'RTS_AVG',  'Y', :old.rts_avg, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.rts_avg_defaulted, :new.rts_avg_defaulted) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'RTS_AVG_DEFAULTED',  'Y', :old.rts_avg_defaulted, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.rts_avg_cleaned, :new.rts_avg_cleaned) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'RTS_AVG_CLEANED',  'Y', :old.rts_avg_cleaned, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.cost_to_repair_off_base_cleand, :new.cost_to_repair_off_base_cleand) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'COST_TO_REPAIR_OFF_BASE_CLEAND',  'Y', :old.cost_to_repair_off_base_cleand, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.time_to_repair_off_base_cleand, :new.time_to_repair_off_base_cleand) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'TIME_TO_REPAIR_OFF_BASE_CLEAND',  'Y', :old.time_to_repair_off_base_cleand, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.time_to_repair_on_base_avg, :new.time_to_repair_on_base_avg) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'TIME_TO_REPAIR_ON_BASE_AVG',  'Y', :old.time_to_repair_on_base_avg, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.time_to_repair_on_base_avg_df, :new.time_to_repair_on_base_avg_df) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'TIME_TO_REPAIR_ON_BASE_AVG_DF',  'Y', :old.time_to_repair_on_base_avg_df, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.time_to_repair_on_base_avg_cl, :new.time_to_repair_on_base_avg_cl) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'TIME_TO_REPAIR_ON_BASE_AVG_CL',  'Y', :old.time_to_repair_on_base_avg_cl, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.min_purchase_quantity, :new.min_purchase_quantity) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'MIN_PURCHASE_QUANTITY',  'Y', :old.min_purchase_quantity, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.demand_variance, :new.demand_variance) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'DEMAND_VARIANCE',  'Y', :old.demand_variance, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.tactical, :new.tactical) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'TACTICAL', :old.tactical, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.action_code, :new.action_code) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'ACTION_CODE', :old.action_code, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.tactical_replan, :new.tactical_replan) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'TACTICAL_REPLAN', :old.tactical_replan, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.condemn_cost, :new.condemn_cost) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'CONDEMN_COST',  'Y', :old.condemn_cost, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.forecast_ignore, :new.forecast_ignore) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'FORECAST_IGNORE', :old.forecast_ignore, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.depletion_start_date, :new.depletion_start_date) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'depletion_start_date', to_char(:old.depletion_start_date,'MM/DD/YYYY HH:MI:SS AM'), last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.effect_last_update_id, :new.effect_last_update_id) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'EFFECT_LAST_UPDATE_ID', :old.effect_last_update_id, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.effect_last_update_dt, :new.effect_last_update_dt) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'EFFECT_LAST_UPDATE_DT', to_char(:old.effect_last_update_dt,'MM/DD/YYYY HH:MI:SS AM'), last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.effect_by, :new.effect_by) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'EFFECT_BY', :old.effect_by, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.asset_mgmt_status, :new.asset_mgmt_status) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'ASSET_MGMT_STATUS', :old.asset_mgmt_status, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.latest_config, :new.latest_config) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'LATEST_CONFIG', :old.latest_config, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.spare_start_date, :new.spare_start_date) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'SPARE_START_DATE', to_char(:old.spare_start_date,'MM/DD/YYYY HH:MI:SS AM'), last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.nsi_group_sid, :new.nsi_group_sid) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'NSI_GROUP_SID',  'Y', :old.nsi_group_sid, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.mmac, :new.mmac) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'MMAC', :old.mmac, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.criticality_changed, :new.criticality_changed) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'CRITICALITY_CHANGED', :old.criticality_changed, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.nrts_avg_changed, :new.nrts_avg_changed) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'NRTS_AVG_CHANGED', :old.nrts_avg_changed, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.rts_avg_changed, :new.rts_avg_changed) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'RTS_AVG_CHANGED', :old.rts_avg_changed, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.condemn_avg_changed, :new.condemn_avg_changed) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'CONDEMN_AVG_CHANGED', :old.condemn_avg_changed, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.spo_total_inventory, :new.spo_total_inventory) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'SPO_TOTAL_INVENTORY',  'Y', :old.spo_total_inventory, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.cost_to_repair_off_base, :new.cost_to_repair_off_base) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'COST_TO_REPAIR_OFF_BASE',  'Y', :old.cost_to_repair_off_base, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.time_to_repair_off_base, :new.time_to_repair_off_base) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'TIME_TO_REPAIR_OFF_BASE',  'Y', :old.time_to_repair_off_base, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.cost_to_repair_off_base_chged, :new.cost_to_repair_off_base_chged) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'COST_TO_REPAIR_OFF_BASE_CHGED', :old.cost_to_repair_off_base_chged, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.time_to_repair_off_base_chged, :new.time_to_repair_off_base_chged) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'TIME_TO_REPAIR_OFF_BASE_CHGED', :old.time_to_repair_off_base_chged, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.mtbdr_computed, :new.mtbdr_computed) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'MTBDR_COMPUTED',  'Y', :old.mtbdr_computed, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   if amd_utils.isDiff(:old.wesm_indicator, :new.wesm_indicator) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'WESM_INDICATOR',  :old.wesm_indicator, last_update_dt, to_char(nvl(:old.nsi_sid,:new.nsi_sid))) ;
   end if ;
   

   EXCEPTION
     WHEN OTHERS then
       -- Consider logging the error and) then re-raise
       RAISE;
END amd_spare_parts_after_trig;
/
