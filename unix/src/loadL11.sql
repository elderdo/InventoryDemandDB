/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   20 May 2008 14:30:50  $
    $Workfile:   loadL11.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadL11.sql.-arc  $
/*   
/*      Rev 1.0   20 May 2008 14:30:50   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec amd_owner.mta_truncate_table('l11','reuse storage');

insert into l11
(
	l11_id,fsc,dic,sran,niin,part,noun,nsn, source_of_supply, boeing_base_max_level, boeing_base_min_level
)
select 
	l11_id,trim(fsc),trim(dic),trim(sran),trim(niin),trim(part),trim(noun),concat(fsc,niin)nsn, trim(source_of_supply) source_of_supply, boeing_base_max_level, boeing_base_min_level
from wecm_l11_v
where upper(trim(source_of_supply)) = 'F77';

exit 
