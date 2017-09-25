select 	asn.loc_id	as	location_id, ',',
	ansi.nsn	as	item_id, ',',	 
	amd_preferred_pkg.GetQpeiWeighted(ansi.nsi_sid)
			as	num_per_asset, ',',
	
	amd_preferred_pkg.GetMtbdr(ansi.nsi_sid)
			as	mtbr

from	amd_part_locs apl,
	amd_national_stock_items ansi,
	amd_spare_networks asn

where	apl.loc_sid = asn.loc_sid 	and
	apl.nsi_sid = ansi.nsi_sid	and
	ansi.action_code != 'D'		and
	asn.action_code != 'D'		
	