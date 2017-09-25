CREATE OR REPLACE TRIGGER AMD_OWNER.amd_rbl_pairs_aft_trig
AFTER DELETE OR INSERT OR UPDATE
ON AMD_OWNER.AMD_RBL_PAIRS
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
THE_TABLE_NAME constant amd_log.table_name%type := 'AMD_RBL_PAIRS' ;
action_code varchar2(1) ;
last_update_dt date := sysdate ;
/******************************************************************************
      $Author:   zf297a  $
    $Revision:   1.2  $
        $Date:   Sep 25 2006 14:33:34  $
    $Workfile:   AMD_RBL_PAIRS_AFT_TRIG.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\AMD_RBL_PAIRS_AFT_TRIG.trg.-arc  $
/*   
/*      Rev 1.2   Sep 25 2006 14:33:34   zf297a
/*   Use the :new.old_nsn for the key when the :old.old_nsn key is null.
/*   
/*      Rev 1.1   Sep 18 2006 13:29:36   zf297a
/*   Added boolean function amd_utils.isDiff to handle nulls
/*   
/*      Rev 1.0   Sep 14 2006 01:14:28   zf297a
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
	 values (THE_TABLE_NAME, amd_defaults.DELETE_ACTION, 'OLD_NSN', last_update_dt, nvl(to_char(:old.old_nsn),to_char(:new.old_nsn))) ;
	 return ;
   end if ;

   if :new.new_nsn <> :old.new_nsn then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'NEW_NSN', :old.new_nsn, last_update_dt, nvl(:old.old_nsn,:new.old_nsn)) ;
   end if ;
   if amd_utils.isDiff(:old.subgroup_code, :new.subgroup_code) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'SUBGROUP_CODE',   :old.subgroup_code, last_update_dt, nvl(:old.old_nsn,:new.old_nsn)) ;
   end if ;
   if amd_utils.isDiff(:old.part_pref_code, :new.part_pref_code) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'PART_PREF_CODE',  :old.part_pref_code, last_update_dt, nvl(:old.old_nsn,:new.old_nsn)) ;
   end if ;

   EXCEPTION
     WHEN OTHERS then
       -- Consider logging the error and) then re-raise
       RAISE;
END amd_spare_parts_after_trig;
/
/
