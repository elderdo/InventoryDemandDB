CREATE OR REPLACE TRIGGER AMD_OWNER.amd_site_asset_mgr_before_TRIG
before INSERT
ON AMD_OWNER.AMD_SITE_ASSET_MGR REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
/***
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   05 Nov 2008 09:50:04  $
    $Workfile:   AMD_SITE_ASSET_MGR_BEFORE_TRIG.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\AMD_SITE_ASSET_MGR_BEFORE_TRIG.trg.-arc  $
/*   
/*      Rev 1.0   05 Nov 2008 09:50:04   zf297a
/*   Initial revision.

*/         
wk_bems_id amd_people_all_v.bems_id%type ;
BEGIN
    select bems_id into wk_bems_id from amd_people_all_v
    where :new.bems_id = amd_people_all_v.bems_id;
exception when standard.no_data_found then     
    raise_application_error(-20900,'bems_id ' || :new.bems_id || ' does not exist in amd_people_all_v.') ;
END ;
/
