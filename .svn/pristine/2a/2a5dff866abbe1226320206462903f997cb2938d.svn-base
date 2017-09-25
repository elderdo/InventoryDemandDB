/* 02/14/02 accomodate null for mfgr */
select 	',' ,
	loc_type 	as organizationid, ',',
	loc_id		as siteid, ',',
	',' ,
	',' ,
	'A' 		as syncind	

from amd_spare_networks
where loc_type not in ('STR', 'ALL')
and action_code != 'D'

union

select 	distinct ',',
	'VENDOR' 	as organizationid, ',',
 	nvl(mfgr, 'UNKNOWN')	as siteid, ',',
	',' ,
	',' ,
	'A' 		as syncind	
from 	amd_spare_parts asp
where action_code != 'D' and
nvl(mfgr, 'UNKNOWN') not in (select loc_id from amd_spare_networks)
