/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   20 Feb 2009 09:17:28  $
    $Workfile:   loadVenn.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadVenn.sql.-arc  $
/*   
/*      Rev 1.1   20 Feb 2009 09:17:28   zf297a
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

exec amd_owner.mta_truncate_table('venn','reuse storage');

define link = &1

insert into venn
(
	vendor_code,vendor_name,cage_code,user_ref1
) 
select 
	trim(vendor_code),trim(vendor_name),trim(cage_code),trim(user_ref1) 
from venn@&&link ;

exit ;

