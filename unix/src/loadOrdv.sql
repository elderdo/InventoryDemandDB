/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   20 Feb 2009 09:29:12  $
    $Workfile:   loadOrdv.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadOrdv.sql.-arc  $
/*   
/*      Rev 1.1   20 Feb 2009 09:29:12   zf297a
/*   Added link variable
/*   
/*      Rev 1.0   20 May 2008 14:30:52   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec amd_owner.mta_truncate_table('ordv','reuse storage');

define link = &1

insert into ordv
(
	order_no, site_code, vendor_est_cost, vendor_est_ret_date 
)
select 
	trim(order_no), site_code, vendor_est_cost, vendor_est_ret_date
from ordv@&&link ;

exit 
