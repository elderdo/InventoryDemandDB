CREATE OR REPLACE TRIGGER AMD_OWNER.ams_spare_parts_after_trig
AFTER DELETE OR INSERT OR UPDATE
ON AMD_OWNER.AMD_SPARE_PARTS
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
THE_TABLE_NAME constant amd_log.table_name%type := 'AMD_SPARE_PARTS' ;
action_code varchar2(1) ;
last_update_dt date := sysdate ;
/******************************************************************************
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   Jun 01 2006 13:21:32  $
    $Workfile:   AMS_SPARE_PARTS_AFTER_TRIG.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\AMS_SPARE_PARTS_AFTER_TRIG.trg.-arc  $
/*   
/*      Rev 1.0   Jun 01 2006 13:21:32   zf297a
/*   Initial revision.
******************************************************************************/
BEGIN
   if inserting then
   	  	 action_code := amd_defaults.INSERT_ACTION ;
   elsif updating then
   		 action_code := amd_defaults.UPDATE_ACTION ;
   else
	 insert into amd_log
	 (table_name, action_code, column_name, char_value, last_update_dt)
	 values (THE_TABLE_NAME, amd_defaults.DELETE_ACTION, 'PART_NO', :old.part_no, last_update_dt) ;
	 return ;
   end if ;

   if :new.mfgr <> :old.mfgr then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt)
    values (THE_TABLE_NAME, action_code, 'MFGR', :new.mfgr, last_update_dt) ;
   end if ;
   if :new.date_icp <> :old.date_icp then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt)
    values (THE_TABLE_NAME, action_code, 'DATE_ICP', to_char(:new.date_icp,'MM/DD/YY HH:MI:SS AM'), last_update_dt) ;
   end if ;
   if :new.disposal_cost <> :old.disposal_cost then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt)
    values (THE_TABLE_NAME, action_code, 'DISPOSAL_COST',  'Y', :new.disposal_cost, last_update_dt) ;
   end if ;
   if :new.disposal_cost_defaulted <> :old.disposal_cost_defaulted then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt)
    values (THE_TABLE_NAME, action_code, 'DISPOSAL_COST_DEFAULTED',  'Y', :new.disposal_cost, last_update_dt) ;
   end if ;
   if :new.erc <> :old.erc then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt)
    values (THE_TABLE_NAME, :new.action_code, 'ERC', :new.erc, last_update_dt) ;
   end if ;
   if :new.erc <> :old.erc then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt)
    values (THE_TABLE_NAME, :new.action_code, 'ERC', :new.erc, last_update_dt) ;
   end if ;
   if :new.icp_ind <> :old.icp_ind then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt)
    values (THE_TABLE_NAME, :new.action_code, 'ICP_IND', :new.icp_ind, last_update_dt) ;
   end if ;
   if :new.nomenclature <> :old.nomenclature then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt)
    values (THE_TABLE_NAME, :new.action_code, 'NOMENCLATURE', :new.nomenclature, last_update_dt) ;
   end if ;
   if :new.order_lead_time <> :old.order_lead_time then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt)
    values (THE_TABLE_NAME, action_code, 'ORDER_LEAD_TIME',  'Y', :new.order_lead_time, last_update_dt) ;
   end if ;
   if :new.order_lead_time_defaulted <> :old.order_lead_time_defaulted then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt)
    values (THE_TABLE_NAME, action_code, 'ORDER_LEAD_TIME_DEFAULTED',  'Y', :new.order_lead_time_defaulted, last_update_dt) ;
   end if ;
   if :new.order_uom <> :old.order_uom then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt)
    values (THE_TABLE_NAME, :new.action_code, 'ORDER_UOM', :new.order_uom, last_update_dt) ;
   end if ;
   if :new.order_uom_defaulted <> :old.order_uom_defaulted then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt)
    values (THE_TABLE_NAME, :new.action_code, 'ORDER_UOM_DEFAULTED', :new.order_uom_defaulted, last_update_dt) ;
   end if ;
   if :new.scrap_value <> :old.scrap_value then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt)
    values (THE_TABLE_NAME, action_code, 'SCRAP_VALUE',  'Y', :new.scrap_value, last_update_dt) ;
   end if ;
   if :new.scrap_value_defaulted <> :old.scrap_value_defaulted then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt)
    values (THE_TABLE_NAME, action_code, 'SCRAP_VALUE_DEFAULTED',  'Y', :new.scrap_value_defaulted, last_update_dt) ;
   end if ;
   if :new.serial_flag <> :old.serial_flag then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt)
    values (THE_TABLE_NAME, :new.action_code, 'SERIAL_FLAG', :new.serial_flag, last_update_dt) ;
   end if ;
   if :new.shelf_life <> :old.shelf_life then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt)
    values (THE_TABLE_NAME, action_code, 'SHELF_LIFE',  'Y', :new.shelf_life, last_update_dt) ;
   end if ;
   if :new.shelf_life_defaulted <> :old.shelf_life_defaulted then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt)
    values (THE_TABLE_NAME, action_code, 'SHELF_LIFE_DEFAULTED',  'Y', :new.shelf_life_defaulted, last_update_dt) ;
   end if ;
   if :new.unit_cost <> :old.unit_cost then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt)
    values (THE_TABLE_NAME, action_code, 'UNIT_COST',  'Y', :new.unit_cost, last_update_dt) ;
   end if ;
   if :new.unit_cost_defaulted <> :old.unit_cost_defaulted then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt)
    values (THE_TABLE_NAME, action_code, 'UNIT_COST_DEFAULTED',  'Y', :new.unit_cost_defaulted, last_update_dt) ;
   end if ;
   if :new.unit_volume <> :old.unit_volume then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt)
    values (THE_TABLE_NAME, action_code, 'UNIT_VOLUME',  'Y', :new.unit_volume, last_update_dt) ;
   end if ;
   if :new.unit_volume_defaulted <> :old.unit_volume_defaulted then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt)
    values (THE_TABLE_NAME, action_code, 'UNIT_VOLUME_DEFAULTED',  'Y', :new.unit_volume_defaulted, last_update_dt) ;
   end if ;
   if :new.nsn <> :old.nsn then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt)
    values (THE_TABLE_NAME, :new.action_code, 'NSN', :new.nsn, last_update_dt) ;
   end if ;
   if :new.tactical <> :old.tactical then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt)
    values (THE_TABLE_NAME, :new.action_code, 'TACTICAL', :new.tactical, last_update_dt) ;
   end if ;
   if :new.action_code <> :old.action_code then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt)
    values (THE_TABLE_NAME, :new.action_code, 'ACTION_CODE', :new.action_code, last_update_dt) ;
   end if ;
   if :new.last_update_dt <> :old.last_update_dt then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt)
    values (THE_TABLE_NAME, :new.action_code, 'LAST_UPDATE_DT', to_char(:new.last_update_dt,'MM/DD/YY HH:MI:SS AM'), last_update_dt) ;
   end if ;
   if :new.process_bypass <> :old.process_bypass then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt)
    values (THE_TABLE_NAME, :new.action_code, 'PROCESS_BYPASS', :new.process_bypass, last_update_dt) ;
   end if ;
   if :new.acquisition_advice_code <> :old.acquisition_advice_code then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt)
    values (THE_TABLE_NAME, :new.action_code, 'ACQUISITION_ADVICE_CODE', :new.acquisition_advice_code, last_update_dt) ;
   end if ;
   if :new.unit_of_issue <> :old.unit_of_issue then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt)
    values (THE_TABLE_NAME, :new.action_code, 'UNIT_OF_ISSUE', :new.unit_of_issue, last_update_dt) ;
   end if ;

   EXCEPTION
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END ams_spare_parts_after_trig;
/
/
