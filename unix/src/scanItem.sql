whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on
set serveroutput on size UNLIMITED

define link = &1


declare
cnt number := 0 ;
cursor noDates is
select 
	trim(item_id) item_id,
	trim(received_item_id) received_item_id,
	trim(sc) sc,trim(part) part,
	trim(prime),trim(condition),status_del_when_gone,
	status_servicable,status_new_order,status_accountable,status_avail,
	status_frozen,status_active,status_mai,status_receiving_susp,
	status_2,status_3,
	last_changed_datetime,status_1,
	created_datetime,trim(vendor_code),
	qty,trim(order_no),trim(receipt_order_no)
from item@&&link  
where
	status_1 != 'D' 
	and condition not in ('LDD')
	and last_changed_datetime is null
	and created_datetime is null ;
begin
	for rec in noDates loop
		Amd_warnings_pkg.insertWarningMsg (
			pData_line_no => 5555,
			pData_line    => 'item',
			pKey_1 => rec.part,
			pKey_2 => rec.item_id,
			pKey_3 => substr(rec.sc,8,6),
			pKey_4 => 'status_2' || rec.status_2,
			pKey_5 => 'status_3' || rec.status_3,
			pWarning => 'Item does not have a created_datetime nor a last_changed_datetime') ;
		cnt := cnt + 1 ;
	end loop ;
	dbms_output.put_line('There were ' || cnt || ' bad date warnings for items@&&link') ;
end ;
/
