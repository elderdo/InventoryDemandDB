select 	',' ,
	loc_type 	as organizationid, ',',
	loc_id		as siteid, ',',
	',' ,
	',' ,
	'A' 		as syncind	

from amd_spare_networks
where loc_type not in ('OBR', 'STR', 'ALL')
and action_code != 'D'

union

select 	',' ,
	loc_type  			as organizationid, ',',
	loc_id || '_DIFM'		as siteid, ',',
	',' ,
	',' ,
	'A' 				as syncind	

from amd_spare_networks
where loc_type in ('FSL', 'MOB')
and action_code != 'D'
