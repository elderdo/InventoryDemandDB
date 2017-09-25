/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   20 Feb 2009 09:39:20  $
    $Workfile:   loadUims.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadUims.sql.-arc  $
/*   
/*      Rev 1.1   20 Feb 2009 09:39:20   zf297a
/*   Added link variable
/*   
/*      Rev 1.0   20 May 2008 14:30:54   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec amd_owner.mta_truncate_table('uims','reuse storage');

define link = &1

insert into uims
(
	userid,designator_code,alt_ims_des_code_b,alt_es_des_code_b,alt_sup_des_code_b
)
select
	trim(userid),designator_code,alt_ims_des_code_b,alt_es_des_code_b,alt_sup_des_code_b
from  uims@&&link ;

exit 






