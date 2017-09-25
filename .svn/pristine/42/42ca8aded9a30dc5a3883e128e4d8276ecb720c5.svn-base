CREATE OR REPLACE TRIGGER AMD_OWNER.amd_spare_parts_after_trig
AFTER DELETE OR INSERT OR UPDATE
ON AMD_OWNER.AMD_SPARE_PARTS REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
THE_TABLE_NAME constant amd_log.table_name%type := 'AMD_SPARE_PARTS' ;
action_code varchar2(1) ;
last_update_dt date := sysdate ;
/******************************************************************************
      $Author:   zf297a  $
    $Revision:   1.9  $
        $Date:   28 Apr 2009 10:03:04  $
    $Workfile:   AMD_SPARE_PARTS_AFTER_TRIG.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\AMD_SPARE_PARTS_AFTER_TRIG.trg.-arc  $
/*   
/*      Rev 1.9   28 Apr 2009 10:03:04   zf297a
/*   Added is_repairable, is_consumable, is_spo_part, and spo_prime_part_no
/*   
/*      Rev 1.8   Oct 06 2006 23:05:26   zf297a
/*   Make sure action_code is used for the data source not :old.action_code.
/*   
/*      Rev 1.7   Sep 25 2006 14:56:38   zf297a
/*   Use :new.part_no when the :old.part_no is null - this will occur when inserting a row in the table.
/*   
/*      Rev 1.6   Sep 18 2006 13:25:24   zf297a
/*   Added isDiff boolean function to handle nulls
/*   
/*      Rev 1.5   Jun 01 2006 15:13:18   zf297a
/*   enabled trigger
/*   
/*      Rev 1.4   Jun 01 2006 15:02:20   zf297a
/*   added recording of  the_key for each table
/*   
/*      Rev 1.3   Jun 01 2006 14:34:10   zf297a
/*   made year's 4 digits
/*   
/*      Rev 1.2   Jun 01 2006 13:56:16   zf297a
/*   make log of the :old field since the :new field will always be the current value
/*   
/*      Rev 1.1   Jun 01 2006 13:30:06   zf297a
/*   Fixed name
/*   
/*      Rev 1.0   Jun 01 2006 13:27:28   zf297a
/*   Initial revision.
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
	 (table_name, action_code, column_name, last_update_dt, the_key)
	 values (THE_TABLE_NAME, amd_defaults.DELETE_ACTION, 'PART_NO', last_update_dt, nvl(:old.part_no,:new.part_no)) ;
	 return ;
   end if ;

   if amd_utils.isDiff(:old.mfgr, :new.mfgr) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'MFGR', :old.mfgr, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.date_icp, :new.date_icp) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'DATE_ICP', to_char(:old.date_icp,'MM/DD/YYYY HH:MI:SS AM'), last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.disposal_cost, :new.disposal_cost) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'DISPOSAL_COST',  'Y', :old.disposal_cost, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.disposal_cost_defaulted, :new.disposal_cost_defaulted) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'DISPOSAL_COST_DEFAULTED',  'Y', :old.disposal_cost, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.erc, :new.erc) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'ERC', :old.erc, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.erc, :new.erc) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'ERC', :old.erc, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.icp_ind, :new.icp_ind) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'ICP_IND', :old.icp_ind, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.nomenclature, :new.nomenclature) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'NOMENCLATURE', :old.nomenclature, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.order_lead_time, :new.order_lead_time) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'ORDER_LEAD_TIME',  'Y', :old.order_lead_time, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.order_lead_time_defaulted, :new.order_lead_time_defaulted) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'ORDER_LEAD_TIME_DEFAULTED',  'Y', :old.order_lead_time_defaulted, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.order_uom, :new.order_uom) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'ORDER_UOM', :old.order_uom, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.order_uom_defaulted, :new.order_uom_defaulted) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'ORDER_UOM_DEFAULTED', :old.order_uom_defaulted, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.scrap_value, :new.scrap_value) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'SCRAP_VALUE',  'Y', :old.scrap_value, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.scrap_value_defaulted, :new.scrap_value_defaulted) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'SCRAP_VALUE_DEFAULTED',  'Y', :old.scrap_value_defaulted, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.serial_flag, :new.serial_flag) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'SERIAL_FLAG', :old.serial_flag, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.shelf_life, :new.shelf_life) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'SHELF_LIFE',  'Y', :old.shelf_life, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.shelf_life_defaulted, :new.shelf_life_defaulted) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'SHELF_LIFE_DEFAULTED',  'Y', :old.shelf_life_defaulted, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.unit_cost, :new.unit_cost) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'UNIT_COST',  'Y', :old.unit_cost, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.unit_cost_defaulted, :new.unit_cost_defaulted) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'UNIT_COST_DEFAULTED',  'Y', :old.unit_cost_defaulted, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.unit_volume, :new.unit_volume) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'UNIT_VOLUME',  'Y', :old.unit_volume, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.unit_volume_defaulted, :new.unit_volume_defaulted) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'UNIT_VOLUME_DEFAULTED',  'Y', :old.unit_volume_defaulted, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.nsn, :new.nsn) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'NSN', :old.nsn, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.tactical, :new.tactical) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'TACTICAL', :old.tactical, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(action_code, :new.action_code) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'ACTION_CODE', action_code, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.last_update_dt, :new.last_update_dt) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'LAST_UPDATE_DT', to_char(:old.last_update_dt,'MM/DD/YYYY HH:MI:SS AM'), last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.process_bypass, :new.process_bypass) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'PROCESS_BYPASS', :old.process_bypass, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.acquisition_advice_code, :new.acquisition_advice_code) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'ACQUISITION_ADVICE_CODE', :old.acquisition_advice_code, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.unit_of_issue, :new.unit_of_issue ) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'UNIT_OF_ISSUE', :old.unit_of_issue, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;
   if amd_utils.isDiff(:old.is_repairable,:new.is_repairable) then
    insert into amd_log
    (table_name,action_code,column_name,char_value,last_update_dt,the_key)
    values(THE_TABLE_NAME, action_code, 'IS_REPAIRABLE',:old.is_repairable, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;    
   if amd_utils.isDiff(:old.is_consumable,:new.is_consumable) then
    insert into amd_log
    (table_name,action_code,column_name,char_value,last_update_dt,the_key)
    values(THE_TABLE_NAME, action_code, 'IS_CONSUMABLE',:old.is_consumable, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;    
   if amd_utils.isDiff(:old.is_spo_part,:new.is_spo_part) then
    insert into amd_log
    (table_name,action_code,column_name,char_value,last_update_dt,the_key)
    values(THE_TABLE_NAME, action_code, 'IS_SPO_PART',:old.is_spo_part, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;    
   if amd_utils.isDiff(:old.spo_prime_part_no,:new.spo_prime_part_no) then
    insert into amd_log
    (table_name,action_code,column_name,char_value,last_update_dt,the_key)
    values(THE_TABLE_NAME, action_code, 'SPO_PRIME_PART_NO',:old.spo_prime_part_no, last_update_dt, nvl(:old.part_no,:new.part_no)) ;
   end if ;    
   EXCEPTION
     WHEN OTHERS  then
       -- Consider logging the error and )) then re-raise
       RAISE;
END amd_spare_parts_after_trig;
/
