CREATE OR REPLACE TRIGGER AMD_OWNER.tmp_loc_part_override_trg1
BEFORE INSERT OR UPDATE
ON AMD_OWNER.TMP_AMD_LOCATION_PART_OVERRIDE REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
/******************************************************************************
      $Author:   zf297a  $
    $Revision:   1.3  $
        $Date:   25 Jul 2013
    $Workfile:   TMP_LOC_PART_OVERRIDE_TRG1.trg  $
         
         Rev 1.3 use  repairables_pkg. instead of a2a_pkg.
         
/*      Rev 1.2   07 Jun 2007 14:38:28   zf297a
/*   Make sure an inactive part gets a DELETE action_code and a zero tsl_quantity.
/*   
/*      Rev 1.1   Sep 25 2006 08:30:22   zf297a
/*   Make sure that the last_update_dt gets the updated
/*   
/*      Rev 1.0   Aug 24 2006 10:09:44   zf297a
/*   Initial revision.

******************************************************************************/
BEGIN
   if :new.loc_sid = Amd_Location_Part_Override_Pkg.THE_WAREHOUSE_LOC_SID
	and amd_utils.isPartRepairable(:new.part_no) then
	:new.tsl_override_qty := 0 ;
	:new.last_update_dt := sysdate ;
  end if ;
  -- make sure that an inactive part gets a delete action and zero qty
  if not repairables_pkg.ISPARTACTIVE(:new.part_no) then
    :new.tsl_override_qty := 0 ;
    :new.action_code := amd_defaults.DELETE_ACTION ;
    :new.last_update_dt := sysdate ;  
  end if ;
  
END tmp_loc_part_override_trg1 ;
/