/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   20 Feb 2009 09:21:08  $
    $Workfile:   loadMils.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadMils.sql.-arc  $
/*   
/*      Rev 1.1   20 Feb 2009 09:21:08   zf297a
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

exec amd_owner.mta_truncate_table('mils','reuse storage');

define link = &1

insert into mils
(
	mils_id,rec_types,created_datetime,status_line,part,default_name
)
select
	trim(mils_id),trim(rec_types),created_datetime,trim(status_line),trim(part),trim(default_name)
from mils@&&link
where
	default_name = 'A0E';
	

exit 
