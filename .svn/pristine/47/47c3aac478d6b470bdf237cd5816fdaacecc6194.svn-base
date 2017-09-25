/* 12/10/01 added requirement for vendor parts to ctlatl ??? item type*/
/* 02/14/02 accomodated null for mfgr and defaults for order lead time 
   if 'T' => 270 
   if 'P' or 'N' => 540
   if null => 540
*/
/* 02/19/02 added priority to individual item query */
/* 02/26/02 removed # from part_no */
select 	
	',',
	''			as	bodname, ',',
	asn.loc_id		as	fromsiteid, ',',
	asnToLocSid.loc_id	as	tositeid, ',',
	ab.bod_subject		as	itemgroup, ',',
	''			as	item, ',',
	',',
	',',
	ab.transport_agent_id	as	transagentid, ',',
	ab.transport_mode_id	as	servicename, ',',
	ab.transport_mode_id	as	transportmode, ',',
	ab.transport_mode_id	as	transporttype, ',',
	',',
	',',
	'A'			as	syncind, ',',
	ab.sourcing_priority		as	supplypercent, ',',
	to_number(null), ',',
	',',
	ab.bod_time		as	transittime, ',',
	',',
	'0'			as	transcost, ',',
	',',
	'0'			as	transcostper, ',',
	'SEQUENTIAL'		as	sourcingpolicy, ',',
	''			as	loadgroup, ',',
	asn.calendar_name	as	calendarname, ',',
	'O'			as 	calendarusage, ',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	''			as 	lanetype

from 	amd_bods ab,
	amd_spare_networks asn,
	amd_spare_networks asnToLocSid

where 	ab.from_loc_sid = asn.loc_sid 	and
	ab.to_loc_sid = asnToLocSid.loc_sid  and
	ab.action_code != 'D' and
	asnToLocSid.action_code != 'D' and
	asn.action_code != 'D'

union

select 	
	',',
	''			as	bodname, ',',
	nvl(asp.mfgr,'UNKNOWN')		as	fromsiteid, ',',
	'CTLATL'		as	tositeid, ',',
	''			as	itemgroup, ',',
	REPLACE(REPLACE(part_no, ',', ' '), '#', '')	as	item, ',',
	',',
	',',
	'Courier Land'		as	transagentid, ',',
	'LAND'			as	servicename, ',',
	'LAND'			as	transportmode, ',',
	'LAND'			as	transporttype, ',',
	',',
	',',
	'A'			as	syncind, ',',
	to_number(null), ',',
	to_number(50)		as	priority, ',',
	',',
	nvl(amd_preferred_pkg.GetOrderLeadTimeByPart(asp.part_no), 
		decode(substr(amd_preferred_pkg.GetSmrCode(asp.nsn),6,1), 'T', 540, 270))  	
		as	transittime, ',',
	',',
	'0'			as	transcost, ',',
	',',
	'0'			as	transcostper, ',',
	'SEQUENTIAL'		as	sourcingpolicy, ',',
	''			as	loadgroup, ',',
	nvl(asn.calendar_name, '5 DAY WORK WEEK')	as	calendarname, ',',
	'O'			as 	calendarusage, ',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	''			as 	lanetype

from 	
	amd_spare_parts asp, amd_spare_networks asn
where 
	asp.mfgr = asn.loc_id (+) and
	asn.action_code (+) != 'D' and
	asp.action_code != 'D' 

