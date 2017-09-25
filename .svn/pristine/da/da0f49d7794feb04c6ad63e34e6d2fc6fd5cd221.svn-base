/*
	  $Author:   zf297a  $
	$Revision:   1.1  $
	    $Date:   17 Aug 2007 15:35:04  $
	$Workfile:   ReplicateWesm.sql  $
	     $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\ReplicateWesm.sql.-arc  $
/*   
/*      Rev 1.1   17 Aug 2007 15:35:04   zf297a
/*   Added source_of_supply, boeing_base_max_level, and boeing_base_min_level
/*   
/*      Rev 1.0   15 Aug 2007 13:06:14   zf297a
/*   Initial revision.


*/

SET ECHO ON TERMOUT ON AUTOCOMMIT ON TIME ON	

exec amd_owner.mta_truncate_table('l11','reuse storage');
exec amd_owner.mta_truncate_table('active_niins','reuse storage');


insert into active_niins
(
	niin
)
select niin 
from 
	wecm_active_niins;


insert into l11
(
	l11_id,fsc,dic,sran,niin,part,noun,nsn, source_of_supply, boeing_base_max_level, boeing_base_min_level
)
select 
	l11_id,trim(fsc),trim(dic),trim(sran),trim(niin),trim(part),trim(noun),concat(fsc,niin)nsn, trim(source_of_supply) source_of_supply, boeing_base_max_level, boeing_base_min_level
from wecm_l11
where upper(trim(source_of_supply)) = 'F77';

exit;
