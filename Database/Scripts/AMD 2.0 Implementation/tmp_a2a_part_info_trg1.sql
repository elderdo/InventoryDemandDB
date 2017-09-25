 /*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   23 Aug 2007 10:41:26  $
    $Workfile:   tmp_a2a_part_info_trg1.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Scripts\AMD 2.0 Implementation\tmp_a2a_part_info_trg1.sql.-arc  $
/*   
/*      Rev 1.0   23 Aug 2007 10:41:26   zf297a
/*   Initial revision.
*/

set define off

DROP TRIGGER AMD_OWNER.TMP_A2A_PART_INFO_TRG1;

CREATE OR REPLACE TRIGGER AMD_OWNER.tmp_a2a_part_info_trg1
BEFORE INSERT OR UPDATE
ON AMD_OWNER.TMP_A2A_PART_INFO REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
/******************************************************************************
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   23 Aug 2007 10:41:26  $
    $Workfile:   tmp_a2a_part_info_trg1.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\TMP_A2A_PART_INFO_TRG1.trg.-arc  $
/*   
/*      Rev 1.1   21 Jun 2007 15:34:30   zf297a
/*   Changed name of constant from REPAIRABLE to RCM_REPAIRABLE.
/*   
/*      Rev 1.0   18 Jun 2007 14:31:46   zf297a
/*   Initial revision.

******************************************************************************/
BEGIN
   if :new.rcm_ind = a2a_pkg.RCM_REPAIRABLE then
    :new.is_order_policy_req_base := 'F' ; -- repairable
   else
    :new.is_order_policy_req_base := 'T' ; -- consumable
  end if ;
END tmp_a2a_part_info_trg1 ;
/
SHOW ERRORS;



