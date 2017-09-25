/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   20 Feb 2009 09:23:12  $
    $Workfile:   loadRsv1.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadRsv1.sql.-arc  $
/*   
/*      Rev 1.1   20 Feb 2009 09:23:12   zf297a
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

exec amd_owner.mta_truncate_table('rsv1','reuse storage');

define link = &1

insert into rsv1
(
	reserve_id,
	form_required_yn,
	remark_move_only_yn,
	created_docdate,
	to_sc,
	item_id,
	status
)
select 
	trim(reserve_id),
	form_required_yn,
	remark_move_only_yn,
	created_docdate,
	trim(to_sc),
	trim(item_id),
	status
from rsv1@&&link ;
	

exit 
