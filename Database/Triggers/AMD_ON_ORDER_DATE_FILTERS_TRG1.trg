CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_ON_ORDER_DATE_FILTERS_TRG1
BEFORE INSERT OR UPDATE
ON AMD_OWNER.AMD_ON_ORDER_DATE_FILTERS
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
voucher varchar2(2) ;
/******************************************************************************
      $Author:   zf297a  $
    $Revision:   1.3  $
	    $Date:   Aug 24 2006 10:31:14  $
    $Workfile:   AMD_ON_ORDER_DATE_FILTERS_TRG1.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\AMD_ON_ORDER_DATE_FILTERS_TRG1.trg.-arc  $
/*   
/*      Rev 1.3   Aug 24 2006 10:31:14   zf297a
/*   Do not allow create_order_date and the scheduled_receipt_date range to be entered at the same time.
/*   
/*      Rev 1.2   Aug 22 2006 09:44:00   zf297a
/*   Added check to make sure that any order_create_date is greater than the scheduled_receipt_date_to if it is entered.
/*   
/*      Rev 1.1   May 17 2006 14:51:36   zf297a
/*   removed start_date - column is not needed
/*   
/*      Rev 1.0   May 17 2006 12:00:34   zf297a
/*   Initial revision.

******************************************************************************/
BEGIN
   if inserting then
   	  begin
   	  	   select distinct substr(gold_order_number,1,2) into voucher from amd_on_order where substr(gold_order_number,1,2) = :new.voucher_prefix ;
	  exception when standard.no_data_found then
		   RAISE_APPLICATION_ERROR(-20000, 'The voucher prefix does not exist in amd_on_order.');
	  end ;	 
   else
   	   :new.last_update_dt := sysdate ;
	   :new.oracle_userid := user ; 
   end if ;
   if :new.calendar_days is not null then
   	  if :new.calendar_days < 0 then
	  	 RAISE_APPLICATION_ERROR(-20001, 'calendar_days must be positive.');
	  end if ;
   	  if :new.scheduled_receipt_date_from is not null then
	  	 RAISE_APPLICATION_ERROR(-20002, 'Cannot have scheduled_receipt_date_from with calendar_days.');
	  elsif :new.scheduled_receipt_date_to is not null then
	  	 RAISE_APPLICATION_ERROR(-20003, 'Cannot have scheduled_receipt_date_to with calendar_days.');
	  end if ;
   else
   	   if :new.scheduled_receipt_date_from is not null then
	   	  if :new.scheduled_receipt_date_to is null then
		  	 RAISE_APPLICATION_ERROR(-20004, 'You must enter scheduled_receipt_date_to.');
		  end if ;
	   else
	   	   if :new.scheduled_receipt_date_to is not null then
		  	 RAISE_APPLICATION_ERROR(-20005, 'You must enter scheduled_receipt_date_from.');
		   end if ;
	   end if ;
	   if :new.scheduled_receipt_date_from > :new.scheduled_receipt_date_to then
		  	 RAISE_APPLICATION_ERROR(-20006, 'scheduled_receipt_date_from must be <= scheduled_receipt_date_to.');
	   else
	   	   :new.calendar_days := null ; -- the calendar days are no longer needed
	   end if ;
   end if ;
   if :new.order_create_date is not null 
   and (:new.scheduled_receipt_date_from is not null or :new.scheduled_receipt_date_to is not null) then
	  	 RAISE_APPLICATION_ERROR(-20007, 'Cannot have both order_create_date and scheduled_receipt_date range.');
   end if ;
   EXCEPTION
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END AMD_ON_ORDER_DATE_FILTERS_TRG1;
/
/
