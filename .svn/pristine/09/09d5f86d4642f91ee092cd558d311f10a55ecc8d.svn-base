CREATE OR REPLACE TRIGGER AMD_OWNER.amd_spare_networks_bef_ins_upd
BEFORE INSERT OR UPDATE
ON AMD_OWNER.AMD_SPARE_NETWORKS
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
/******************************************************************************
      $Author:   zf297a  $
    $Revision:   1.3  $
	    $Date:   May 23 2006 10:10:26  $
    $Workfile:   AMD_SPARE_NETWORKS_BEF_INS_UPD.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\AMD_SPARE_NETWORKS_BEF_INS_UPD.trg.-arc  $
/*   
/*      Rev 1.3   May 23 2006 10:10:26   zf297a
/*   Make sure last_update_dt gets filled in
/*   
/*      Rev 1.2   May 16 2006 09:49:16   zf297a
/*   Added trim for all varchar2 fields to prevent erroneous leading spaces and to remove unnecessary trailing spaces.
/*   
/*   
/*   
/*      Rev 1.1   Apr 10 2006 08:33:46   zf297a
/*   Trigger automatically removes blanks from all spo_location fields.  So, if the field contains one or more blanks, then the field gets a null value
/*   
/*      Rev 1.0   Apr 07 2006 12:42:22   zf297a
/*   Initial revision.
   PURPOSE: Make sure the spo_location is never a blank and gets rid of leading or trailing spaces   
   			      
******************************************************************************/
BEGIN
	 :new.location_name := trim(:new.location_name) ;
     :new.loc_id := trim(:new.loc_id) ;
  	 :new.loc_type := trim(:new.loc_type) ;
  	 :new.mob := trim(:new.mob) ;
  	 :new.repair_flag := trim(:new.repair_flag) ;
  	 :new.command := trim(:new.command) ;
  	 :new.sub_command := trim(:new.sub_command) ;
  	 :new.icao := trim(:new.icao) ;
  	 :new.calendar_name := trim(:new.calendar_name) ;
	 :new.spo_location := trim(:new.spo_location) ;
	 :new.last_update_dt := sysdate ;
END amd_spare_networks_bef_ins_upd;
/
/
