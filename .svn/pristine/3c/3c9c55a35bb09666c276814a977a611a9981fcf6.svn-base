select	',',
	transport_agent_id			as 	transagentid, ',',
	REPLACE(transport_mode_id, ',', ' ')	as	servicename, ',',
	REPLACE(transport_mode_id, ',', ' ')	as	transporttype, ',',
	REPLACE(transport_mode_id, ',', ' ')	as	transportmode, ',',
	',',
	'A'					as 	syncind, ',',
	',',
	REPLACE(transport_mode_desc, ',', ' ') 	as	description, ',',
	',',
	',', ',', ',', ',', ',',
	',', ',', ',', ',', ',',
	',', 
	',', 
	',', 
	'0'					as	maxloadvolume, ',',
	',',
	',',
	'0'					as	maxloadweight

from amd_transport_modes
where action_code != 'D'
