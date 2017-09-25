select 	
	',',
	asn.loc_id 		as siteid, 	',',
	',',
	'A'			as syncind,	',',
	REPLACE(asn.location_name, ',', ' ') 	 as sitename, ',',
	asn.loc_type				 as sitetype, ',',
	',',
	',',
	',',
	''			as priority,	',',
	',', ',', ',', ',', ',', ',',
	',', ',', ',', ',', ',', ',',
	',',
	',',
	',',
	',',
	''			as reviewfence
from amd_spare_networks asn
where asn.loc_type not in ('VEN', 'STR', 'ALL')
and asn.action_code != 'D'
