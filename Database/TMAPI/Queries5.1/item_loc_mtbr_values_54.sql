select 	asn.loc_id	as	location_id, ',',
	ansi.nsn	as	item_id, ',',	 
	decode(ansi.qpei_weighted, null, ansi.qpei_weighted_defaulted, ansi.qpei_weighted)
			as	num_per_asset, ',',
	decode(ansi.mtbdr_cleaned, null, ansi.mtbdr, ansi.mtbdr_cleaned)
			as	mtbr

from	amd_part_locs apl,
	amd_national_stock_items ansi,
	amd_spare_networks asn

where	apl.loc_sid = asn.loc_sid 	and
	apl.nsi_sid = ansi.nsi_sid	and
	ansi.tactical = 'Y'		and
	ansi.action_code != 'D'		and
	asn.action_code != 'D'
		

	
