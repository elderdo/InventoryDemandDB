select 	',',
	''			as	bodname, ',',
	asn.loc_id		as	fromsiteid, ',',
	asnToLocSid.loc_id	as	tositeid, ',',
	ab.bod_subject		as	itemgroup, ',',
	''			as	item, ',',
	',',
	',',
	ab.transport_agent_id	as	transagentid, ',',
	',',
	ab.transport_mode_id	as	transportmode, ',',
	''			as	transporttype, ',',
	',',
	',',
	'A'			as	syncind, ',',
	ab.sourcing_priority		as	supplypercent, ',',
	',',
	',',
	ab.bod_time		as	transittime, ',',
	',',
	'0'			as	transcost, ',',
	',',
	'0'			as	transcostper, ',',
	'SEQUENTIAL'		as	sourcingpolicy, ',',
	''			as	loadgroup, ',',
	asn.calendar_name	as	calendarname, ',',
	'O'			as 	calendarusage

from 	amd_bods ab,
	amd_spare_networks asn,
	(select to_loc_sid, loc_id
	 from amd_spare_networks asn2, amd_bods ab2 
	 where loc_sid = to_loc_sid and asn2.action_code != 'D' and ab2.action_code != 'D') asnToLocSid

where 	ab.from_loc_sid = asn.loc_sid 		and
	asnToLocSid.to_loc_sid = ab.to_loc_sid	and
	ab.action_code != 'D' and
	asn.action_code != 'D'
		
