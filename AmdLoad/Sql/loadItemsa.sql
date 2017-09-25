/*
      $Author:   zf297a  $
    $Revision:   1.3  $
        $Date:   30 Nov 2012
    $Workfile:   loadItemsa.sql  $
/*   
/*      Rev 1.3   30 Nov 2012 zf297a
        use view goldsa_item_v as the source
/*      Rev 1.2   29 Nov 2012 zf297a
 *       Add segregation code 
/*      Rev 1.1   20 Feb 2009 09:38:26   zf297a
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

variable program_id varchar2(30);

begin
select amd_defaults.getProgramId into :program_id from dual;
end;
/

print :program_id

exec amd_owner.mta_truncate_table('itemsa','reuse storage');


insert into itemsa
(
	item_id,received_item_id,sc,part,prime,condition,location,status_del_when_gone,
	status_servicable,status_new_order,status_accountable,status_avail,
	status_frozen,status_active,status_mai,status_receiving_susp,status_2,status_3,
	last_changed_datetime,status_1,
	created_datetime,vendor_code,
	qty,order_no,receipt_order_no
)
select
	trim(item_id),trim(received_item_id),trim(sc),trim(part),trim(prime),condition,location,status_del_when_gone,
	status_servicable,status_new_order,status_accountable,status_avail,
	status_frozen,status_active,status_mai,status_receiving_susp,status_2,status_3,
	last_changed_datetime,status_1,
	created_datetime,vendor_code,
	qty,trim(order_no),trim(receipt_order_no)
from goldsa_item_v
where status_1 != 'D'
      and condition not in ('LDD', 'B170-ATL')
      and sc in ( :program_id || 'PCAG', 'SATCAA0001' || :program_id || 'G') ;

exit 
