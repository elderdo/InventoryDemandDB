/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   20 Feb 2009 09:20:18  $
    $Workfile:   loadItem.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadItem.sql.-arc  $
/*   
/*      Rev 1.1   20 Feb 2009 09:20:18   zf297a
/*   Added link variable
/*   
/*      Rev 1.0   20 May 2008 14:30:50   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec amd_owner.mta_truncate_table('item','reuse storage');

define link = &1

insert into item 
(
	item_id,received_item_id,sc,part,prime,condition,status_del_when_gone,
	status_servicable,status_new_order,status_accountable,status_avail,
	status_frozen,status_active,status_mai,status_receiving_susp,status_2,status_3,
	last_changed_datetime,status_1,
	created_datetime,vendor_code,
	qty,order_no,receipt_order_no
)
select 
	trim(item_id),trim(received_item_id),trim(sc),trim(part),trim(prime),trim(condition),status_del_when_gone,
	status_servicable,status_new_order,status_accountable,status_avail,
	status_frozen,status_active,status_mai,status_receiving_susp,status_2,status_3,
	last_changed_datetime,status_1,
	created_datetime,trim(vendor_code),
	qty,trim(order_no),trim(receipt_order_no)
from item@&&link  
where
	status_1 != 'D' 
	and condition not in ('LDD')
	and (last_changed_datetime is not null
		or created_datetime is not null) ;


@@scanItem.sql &&link

exit 
