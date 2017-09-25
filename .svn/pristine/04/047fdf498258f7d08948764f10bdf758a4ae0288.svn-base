/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   20 May 2008 14:30:48  $
    $Workfile:   loadActiveNiins.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadActiveNiins.sql.-arc  $
/*   
/*      Rev 1.0   20 May 2008 14:30:48   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec amd_owner.mta_truncate_table('active_niins','reuse storage');

insert into active_niins
(
	niin
)
select niin 
from 
	wecm_active_niins_v ;

exit 
