CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_ON_ORDER_BEF_INS_TRIG
BEFORE INSERT
ON AMD_OWNER.AMD_ON_ORDER 
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
/***
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   22 Jan 2007 10:35:22  $
    $Workfile:   AMD_ON_ORDER_BEF_INS_TRIG.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\AMD_ON_ORDER_BEF_INS_TRIG.trg.-arc  $
/*   
/*      Rev 1.0   22 Jan 2007 10:35:22   zf297a
/*   Initial revision.
*/
maxLine NUMBER;
BEGIN

   begin
       select max(line) into maxLine 
       from amd_on_order 
       where gold_order_number = :NEW.gold_order_number ; 
   exception when standard.no_data_found then
        maxLine := 0 ;
   end ;
   
   :NEW.line := maxLine + 1 ;

END AMD_ON_ORDER_BEF_TRIG;
/

