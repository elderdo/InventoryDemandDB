/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   20 Feb 2009 09:40:14  $
    $Workfile:   loadCgvt.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadCgvt.sql.-arc  $
/*   
/*      Rev 1.1   20 Feb 2009 09:40:14   zf297a
/*   Added link variable
/*   
/*      Rev 1.0   20 May 2008 14:30:48   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec amd_owner.mta_truncate_table('cgvt','reuse storage');

define link = &1

insert into cgvt
(
	service_code, stock_number, isg_master_stock_number, isg_oou_code
)
select 
	service_code, stock_number, isg_master_stock_number, isg_oou_code
from cgvt@&&link 
where  stock_number is not null
and isg_master_stock_number is not null;

exit 
