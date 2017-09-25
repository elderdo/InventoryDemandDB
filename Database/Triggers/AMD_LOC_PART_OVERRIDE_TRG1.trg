CREATE OR REPLACE TRIGGER AMD_OWNER.amd_loc_part_override_trg1
BEFORE INSERT OR UPDATE
ON AMD_OWNER.amd_location_part_override
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
/******************************************************************************
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   Sep 25 2006 08:31:42  $
    $Workfile:   AMD_LOC_PART_OVERRIDE_TRG1.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\AMD_LOC_PART_OVERRIDE_TRG1.trg.-arc  $
/*   
/*      Rev 1.0   Sep 25 2006 08:31:42   zf297a
/*   Initial revision.

******************************************************************************/
BEGIN
   if :new.loc_sid = Amd_Location_Part_Override_Pkg.THE_WAREHOUSE_LOC_SID
	and amd_utils.isPartRepairable(:new.part_no) then
	:new.tsl_override_qty := 0 ;
	:new.last_update_dt := sysdate ;
  end if ;
END amd_loc_part_override_trg1 ;
/
/
