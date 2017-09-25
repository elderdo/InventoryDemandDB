CREATE OR REPLACE TRIGGER AMD_OWNER.tmp_a2a_part_info_trg1
BEFORE INSERT OR UPDATE
ON AMD_OWNER.TMP_A2A_PART_INFO REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
/******************************************************************************
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   21 Jun 2007 15:34:30  $
    $Workfile:   TMP_A2A_PART_INFO_TRG1.trg  $
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
