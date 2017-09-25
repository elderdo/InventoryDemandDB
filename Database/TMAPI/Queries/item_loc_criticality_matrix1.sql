select
	ansi.nsn	as	item_id, ',',
	asn.loc_id	as	location_id, ',',
	'CRITICALITY_MATRIX_ID_1'	as criticality_matrix_id
from 	amd_national_stock_items ansi,
	amd_part_locs apl,
	amd_spare_networks asn

where	ansi.nsi_sid = apl.nsi_sid	and
	apl.loc_sid = asn.loc_sid	and
	ansi.action_code != 'D'		and
	asn.action_code != 'D'		and
	apl.action_code != 'D'

