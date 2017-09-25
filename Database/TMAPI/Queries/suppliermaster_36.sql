/* 02/14/02 accomodate null for mfgr */
select 	',',
	loc_id	as 	supplierid, ',',
	',',
	''	as	priority, ',',
	',',
	'A'	as	syncind, ',',
	REPLACE(location_name, ',', ' ') as suppliername, ',',
	REPLACE(location_name, ',', ' ') as supplierdesc, ',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	nvl(calendar_name, '5 DAY WORK WEEK')	as calendarname
from amd_spare_networks 
where loc_type = 'VEN'
and action_code != 'D'

union

select 	',',
	nvl(mfgr, 'UNKNOWN')	as 	supplierid, ',',
	',',
	''	as	priority, ',',
	',',
	'A'	as	syncind, ',',
	nvl(mfgr, 'UNKNOWN')	as suppliername, ',',
	nvl(mfgr, 'UNKNOWN')	as	supplierdesc, ',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	'5 DAY WORK WEEK'	as calendarname
from amd_spare_parts
where nvl(mfgr, 'UNKNOWN') not in (select loc_id from amd_spare_networks)
and action_code != 'D'
