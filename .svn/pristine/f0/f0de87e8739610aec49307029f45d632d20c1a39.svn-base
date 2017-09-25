/* ??? need to resolve question on transit_time for mob -> OFFBASE, tony suggested might be 11 */

select 	ansi.nsn	as	item_id, ',',
	asn.loc_id	as	from_location_id, ',',
	asn.mob		as	to_location_id, ',',
	''		as	effective_start, ',',
	''		as	effective_end, ',',
	'1'		as	transit_rate, ',',
	'6'		as	transit_time

from	amd_part_locs apl,
	amd_national_stock_items ansi,
	amd_spare_networks asn

where 	apl.loc_sid = asn.loc_sid 	and
	apl.nsi_sid = ansi.nsi_sid	and
	asn.loc_type = 'FSL'		and
	apl.action_code != 'D'		and
	asn.action_code != 'D'		and
	ansi.action_code != 'D'



union

select 	ansi.nsn	as	item_id, ',',
	asn.loc_id	as	from_location_id, ',',
	'OFFBASE'	as	to_location_id, ',',
	''		as	effective_start, ',',
	''		as	effective_end, ',',
	'1'		as	transit_rate, ',',
	'11'		as	transit_time

from	amd_part_locs apl,
	amd_national_stock_items ansi,
	amd_spare_networks asn

where 	apl.loc_sid = asn.loc_sid 	and
	apl.nsi_sid = ansi.nsi_sid	and
	asn.loc_type = 'MOB'		and
	apl.action_code != 'D'		and
	asn.action_code != 'D'		and
	ansi.action_code != 'D'

