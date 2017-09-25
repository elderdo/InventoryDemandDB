/* 02/26/02 removed # from part_no */
select
	REPLACE(REPLACE(asp.part_no, ',', ' '), '#', '')	as	item_id, ',',
	asn.loc_id	as	location_id, ',',
	'CRITICALITY_MATRIX_ID_1'	as criticality_matrix_id
from 	amd_national_stock_items ansi,
	amd_spare_parts asp, 
	amd_part_locs apl,
	amd_spare_networks asn

where
	apl.nsi_sid = ansi.nsi_sid	and
	apl.loc_sid = asn.loc_sid	and
	asp.nsn	    = ansi.nsn		and
	asp.action_code != 'D'		and
	ansi.action_code != 'D'		and
	asn.action_code != 'D'		and
	apl.action_code != 'D'
