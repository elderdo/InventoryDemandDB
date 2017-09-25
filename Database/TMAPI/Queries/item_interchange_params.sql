/* db changed to disband foreign key constraint to amd_part_locs.  amd_part_locs only holds
CWH, FSL, MOB, ROR => amd_item_interchg_parms may hold other locations like cod */

select	asn.loc_id	as 	location_id, ',',
	ansi.nsn	as	item_id, ',',
	to_char(aiip.effective_start_date, 'YY-MM-DD') || ' 00:00'	as	effective_start_date, ',',
	to_char(aiip.effective_end_date, 'YY-MM-DD') || ' 00:00'	as	effective_end_date, ',',
	aiip.theoretical_percent as	theoretical_percent, ',',
	aiip.actual_percent	as	actual_percent
from 	amd_item_interchg_parms aiip,
	amd_spare_networks	asn,
	amd_national_stock_items ansi,
	amd_part_locs apl

where	asn.loc_type in ('CWH', 'FSL', 'MOB', 'ROR') and
	aiip.loc_sid = apl.loc_sid	and
	aiip.nsi_sid = apl.nsi_sid	and
	aiip.loc_sid = asn.loc_sid 	and
	aiip.nsi_sid = ansi.nsi_sid	and
	asn.action_code != 'D'		and
	ansi.action_code != 'D'		and
	aiip.action_code != 'D'

union

select	asn.loc_id	as 	location_id, ',',
	ansi.nsn	as	item_id, ',',
	to_char(aiip.effective_start_date, 'YY-MM-DD') || ' 00:00'	as	effective_start_date, ',',
	to_char(aiip.effective_end_date, 'YY-MM-DD') || ' 00:00'	as	effective_end_date, ',',
	aiip.theoretical_percent as	theoretical_percent, ',',
	aiip.actual_percent	as	actual_percent
from 	amd_item_interchg_parms aiip,
	amd_spare_networks	asn,
	amd_national_stock_items ansi

where	asn.loc_type not in ('CWH', 'FSL', 'MOB', 'ROR') and
	aiip.loc_sid = asn.loc_sid 	and
	aiip.nsi_sid = ansi.nsi_sid	and
	asn.action_code != 'D'		and
	ansi.action_code != 'D'		and
	aiip.action_code != 'D'
