CREATE OR REPLACE TRIGGER AMD_OWNER.tmp_a2a_loc_part_overraft_trig
AFTER DELETE OR INSERT OR UPDATE
ON AMD_OWNER.tmp_a2a_loc_part_override
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
THE_TABLE_NAME constant amd_log.table_name%type := 'tmp_a2a_loc_part_override' ;
action_code varchar2(1) ;
theKey varchar2(80) ;
last_update_dt date := sysdate ;


/******************************************************************************
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   Oct 18 2006 14:14:36  $
    $Workfile:   tmp_a2a_loc_part_overraft_trig.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\tmp_a2a_loc_part_overraft_trig.trg.-arc  $
/*   
/*      Rev 1.0   Oct 18 2006 14:14:36   zf297a
/*   Initial revision.
******************************************************************************/
BEGIN
   if inserting then
   	  	 action_code := amd_defaults.INSERT_ACTION ;
		 theKey := :new.part_no || :new.site_location ;
   elsif updating then
   		 action_code := amd_defaults.UPDATE_ACTION ;
		 theKey := :old.part_no || :old.site_location ;
   else
   	   theKey := :old.part_no || :old.site_location ;
	   insert into amd_log
	   (table_name, action_code, column_name, last_update_dt, the_key)
		 values (THE_TABLE_NAME, amd_defaults.DELETE_ACTION, 'PART_NO/SITE_LOCATION', last_update_dt, theKey) ;
		 return ;
   end if ;

   if amd_utils.isDiff(:old.override_type, :new.override_type)  then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'OVERRIDE_TYPE', :old.override_type, last_update_dt, theKey) ;
   end if ;
   if amd_utils.isDiff(:old.override_quantity,:new.override_quantity) then
    insert into amd_log
    (table_name, action_code, column_name, number_ind, num_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'OVERRIDE_QUANTITY',  'Y', :old.override_quantity, last_update_dt, theKey) ;
   end if ;
   if amd_utils.isDiff(:old.override_reason ,:new.override_reason) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'OVERRIDE_REASON',  :old.override_reason, last_update_dt, theKey) ;
   end if ;
   if amd_utils.isDiff(:old.override_user, :new.override_user) then
    insert into amd_log
    (table_name, action_code, column_name, char_value,  last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'OVERRIDE_USER',  :old.override_user, last_update_dt, theKey) ;
   end if ;
   if amd_utils.isDiff(:old.begin_date, :new.begin_date) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'BEGIN_DATE',  to_char(:old.begin_date,'MM/DD/YYYY HH:MI:SS'), last_update_dt, theKey) ;
   end if ;
   if amd_utils.isDiff(:old.end_date, :new.end_date) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'END_DATE',  to_char(:old.end_date,'MM/DD/YYYY HH:MI:SS'), last_update_dt, theKey) ;
   end if ;
   if amd_utils.isDiff(:old.action_code, :new.action_code) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'ACTION_CODE',  :old.action_code, last_update_dt, theKey) ;
   end if ;
   if amd_utils.isDiff(:old.last_update_dt, :new.last_update_dt) then
    insert into amd_log
    (table_name, action_code, column_name, char_value, last_update_dt, the_key)
    values (THE_TABLE_NAME, action_code, 'LAST_UPDATE_DT',  to_char(:old.last_update_dt,'MM/DD/YYYY HH:MI:SS'), last_update_dt, theKey) ;
   end if ;

   EXCEPTION
     WHEN OTHERS then
       -- Consider logging the error and) then re-raise
       RAISE;
END tmp_a2a_loc_part_overraft_trig ;
/
