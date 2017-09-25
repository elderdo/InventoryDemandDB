/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   20 Feb 2009 09:25:32  $
    $Workfile:   loadMlit.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadMlit.sql.-arc  $
/*   
/*      Rev 1.1   20 Feb 2009 09:25:32   zf297a
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

exec amd_owner.mta_truncate_table('mlit','reuse storage');

define link = &1

insert into mlit
(
	document_id, customer, mils_activity, mils_ownership_code,
	mils_profile, 
	in_tran_from, in_tran_to, in_tran_type,  
	part, abbr_part, create_date, ship_date,
	receipt_date, start_date_time, create_qty, ship_qty, 
	receipt_qty, mils_condition, status_ind 
)
select
	trim(document_id), trim(customer), trim(mils_activity), trim(mils_ownership_code),  
	trim(mils_profile), trim(in_tran_from), trim(in_tran_to), trim(in_tran_type), 
	trim(part), trim(abbr_part), create_date, ship_date,
	receipt_date, start_date_time, create_qty, ship_qty,	
	receipt_qty, mils_condition, status_ind 
from mlit@&&link
where 
	trim(part) != trim(abbr_part)
	and status_ind = 'I'
	or trim(abbr_part) is null
	and status_ind = 'I';

exit 
