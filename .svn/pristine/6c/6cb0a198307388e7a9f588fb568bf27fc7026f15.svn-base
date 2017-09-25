select
	ansi.nsn	as	item_id, ',',
	asn.loc_id	as	location_id, ',',
	'CRITICALITY_MATRIX_ID_1'	as criticality_matrix_id

from	amd_national_stock_items ansi,
	(select loc_id from amd_spare_networks where loc_type in ('OBR', 'COD') or loc_id = 'CTL-ATL' and action_code != 'D') asn
where 	ansi.action_code != 'D'

