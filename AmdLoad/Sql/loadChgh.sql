/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   20 Feb 2009 09:21:52  $
    $Workfile:   loadChgh.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadChgh.sql.-arc  $
/*   
/*      Rev 1.1   20 Feb 2009 09:21:52   zf297a
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

exec amd_owner.mta_truncate_table('chgh','reuse storage');

define link = &1

insert into chgh
(
	chgh_id,
	key_value1,"TO",field,"FROM"
)
select 
	trim(chgh_id),
	key_value1,"TO",field,"FROM"
from chgh@&&link
where 
	field= 'NSN';
	

exit 
