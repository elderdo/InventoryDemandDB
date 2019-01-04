/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   20 Feb 2009 09:26:22  $
    $Workfile:   loadNsn1.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadNsn1.sql.-arc  $
/*   
/*      Rev 1.1   20 Feb 2009 09:26:22   zf297a
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

exec amd_owner.mta_truncate_table('nsn1','reuse storage');

define link = &1

insert into nsn1
(
	nsn,nsn_smic
)
select
	trim(nsn),trim(nsn_smic)
from nsn1@&&link
where length(nsn) <= 16;

exit 
