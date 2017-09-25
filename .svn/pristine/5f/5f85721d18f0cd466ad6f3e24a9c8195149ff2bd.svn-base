CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_ON_ORDER_AFT_INSUPDT_TRIG
AFTER INSERT or UPDATE
ON AMD_OWNER.AMD_ON_ORDER REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
/***
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   06 Mar 2007 09:17:50  $
    $Workfile:   AMD_ON_ORDER_AFT_INSUPDT_TRIG.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\AMD_ON_ORDER_AFT_INSUPDT_TRIG.trg.-arc  $
/*   
/*      Rev 1.1   06 Mar 2007 09:17:50   zf297a
/*   Used amd_on_order.sched_receipt_date
/*   
/*      Rev 1.0   06 Mar 2007 09:11:56   zf297a
/*   Initial revision.
*/
    order_qty number ;
BEGIN

    if :NEW.action_code = amd_defaults.DELETE_ACTION then
        order_qty := 0 ;
    else
        order_qty := :NEW.order_qty ;
    end if ;
    A2a_Pkg.insertTmpA2AOrderInfoLine(:NEW.gold_order_number,
          :NEW.loc_sid,
          :NEW.order_date,
          :NEW.part_no,
          order_qty,
          :NEW.sched_receipt_date,
          :NEW.action_code,
          :NEW.line) ;

END AMD_ON_ORDER_AFT_INSUPD_TRIG;
/
