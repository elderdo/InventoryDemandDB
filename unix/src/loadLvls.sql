/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   20 Feb 2009 09:40:54  $
    $Workfile:   loadLvls.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadLvls.sql.-arc  $
/*   
/*      Rev 1.1   20 Feb 2009 09:40:54   zf297a
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

exec amd_owner.mta_truncate_table('lvls','reuse storage');

define link = &1

insert into lvls
(
	niin, sran, nsn, lvl_document_number, document_datetime, current_stock_number, compatibility_code, date_lvl_loaded,
	reorder_point, economic_order_qty, approved_lvl_qty
)
select 
	trim(niin), trim(sran), replace(substr(trim(current_stock_number),1,16),'-',''), trim(lvl_document_number), document_datetime, substr(trim(current_stock_number),1,16), trim(compatibility_code),
	to_date(date_lvl_loaded,'yyddd')date_lvl_loaded, reorder_point, economic_order_qty, approved_lvl_qty
from lvls@&&link ;

exit 
