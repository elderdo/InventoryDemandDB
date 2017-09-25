/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   20 Feb 2009 09:27:08  $
    $Workfile:   loadIsgp.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadIsgp.sql.-arc  $
/*   
/*      Rev 1.1   20 Feb 2009 09:27:08   zf297a
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

exec amd_owner.mta_truncate_table('amd_isgp','reuse storage');

define link = &1

insert into amd_isgp
(
	sc,part,group_no,sequence_no,group_priority
)
select 
	trim(sc),trim(part),trim(group_no),sequence_no,trim(group_priority)
from isgp@&&link ;



exit 
