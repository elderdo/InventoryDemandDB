/* ??? service name column */
select	',',
	in_transit_sid	as	distributionorderid, ',',
	''		as	distorderlineid, ',',
	''		as	shipmentid, ',',
	''		as	shipunitid, ',',
	',',
	'A'		as	syncind, ',',
	asn.loc_id	as	fromsiteid, ',',
	asnToLocSid.loc_id 	as	tositeid, ',',
	ansi.nsn	as	item, ',',
	',',
	ait.quantity	as	shipmentqty, ',',
	TO_CHAR(ait.scheduled_delivery_date, 'YY-MM-DD HH:MI') 	as	scheduleddeliverydate, ',',
	ait.transport_agent_id		as	transagentid, ',',
	',',
	ait.transport_mode_id		as	transportmode, ',',
	''				as	transporttype, ',',
	ait.transport_mode_id		as	servicename

from 	amd_in_transits ait,
	amd_spare_networks asn,
	amd_spare_networks asnToLocSid,
	amd_national_stock_items ansi

where 	ait.from_loc_sid = asn.loc_sid and
	ait.nsi_sid	= ansi.nsi_sid and
	ait.to_loc_sid = asnToLocSid.loc_sid and
	ait.action_code != 'D'		and
	ansi.action_code != 'D'		and
	asn.action_code != 'D'		and
	asnToLocSid.action_code != 'D'
