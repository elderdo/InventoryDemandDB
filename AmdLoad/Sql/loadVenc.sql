/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   20 Feb 2009 09:12:44  $
    $Workfile:   loadVenc.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadVenc.sql.-arc  $
/*   
/*      Rev 1.1   20 Feb 2009 09:12:44   zf297a
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

exec amd_owner.mta_truncate_table('venc','reuse storage');

define link=&1

insert into venc 
(
	part,seq,vendor_code,user_ref1
)
select 
	trim(part),seq,trim(vendor_code),trim(user_ref1) 
from venc@&&link
where 
	seq=1;

exit 
