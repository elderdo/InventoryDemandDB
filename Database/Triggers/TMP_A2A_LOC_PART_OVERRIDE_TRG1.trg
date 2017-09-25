CREATE OR REPLACE TRIGGER AMD_OWNER.tmp_a2a_loc_part_override_trg1
BEFORE INSERT OR UPDATE
ON AMD_OWNER.tmp_a2a_loc_part_override
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
/******************************************************************************
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   Sep 25 2006 08:34:44  $
    $Workfile:   TMP_A2A_LOC_PART_OVERRIDE_TRG1.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\TMP_A2A_LOC_PART_OVERRIDE_TRG1.trg.-arc  $
/*   
/*      Rev 1.1   Sep 25 2006 08:34:44   zf297a
/*   Make sure the last_update_dt gets updated.
/*   
/*      Rev 1.0   Aug 23 2006 09:35:44   zf297a
/*   Initial revision.

******************************************************************************/
BEGIN
   if :new.site_location = Amd_Location_Part_Override_Pkg.THE_WAREHOUSE
	and amd_utils.isPartRepairable(:new.part_no) then
	:new.override_quantity := 0 ;
	:new.last_update_dt := sysdate ;
  end if ;
END tmp_a2a_loc_part_override_trg1 ;
/
/
