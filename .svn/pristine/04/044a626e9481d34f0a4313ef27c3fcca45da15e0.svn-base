select 	',',
	min(ar.req_id)	as	salesorderid, ',',
	'1'		as	solinenum, ',',
	',',
	'A'		as	syncind, ',',
	ansi.nsn	as	item, ',',
	',',
	',',
	',',
	''		as	qtyordered, ',',
	',',
	''		as	qtyopen, ',',
	sum(ar.quantity_ordered)		as	qtybackordered, ',',
	',',
	''		as	scheduledshipdate, ',',
	''			as	actualdeliverydate, ',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	asn.loc_id		as	siteid, ',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	''			as	priority
from
	amd_national_stock_items ansi,
	amd_spare_networks asn,
	amd_reqs ar

where 	ansi.nsi_sid = ar.nsi_sid and
	asn.loc_sid = ar.loc_sid  and
	ar.need_date < SYSDATE	and

	asn.action_code != 'D'	and
	ansi.action_code != 'D'	and
	ar.action_code != 'D'

group by ansi.nsn, asn.loc_id

	
	
