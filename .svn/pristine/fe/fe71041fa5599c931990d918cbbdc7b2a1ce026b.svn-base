select 	distinct
	ansi.nsn			as	item, ',',		
	''				as	itemgroup, ',',
	asn.loc_id			as	siteid, ',',
	''				as	organizationid, ',',
	',',
	',',
	',',
	'A'				as	syncind, ',',
	',',
	'1'				as	orderpolicy, ',',
	''				as	presentationstock, ',',
	''				as	maxexcessonhand
from 	amd_part_loc_time_periods apltp,
	amd_spare_networks	asn,
	amd_national_stock_items ansi,
	amd_part_locs	apl

where	apltp.loc_sid = asn.loc_sid	and
	apltp.nsi_sid = ansi.nsi_sid	and
	apltp.nsi_sid = apl.nsi_sid 	and
	apltp.loc_sid = apl.loc_sid	and
	ansi.action_code != 'D'		and
	asn.action_code != 'D'		and
	apl.action_code != 'D'

order by nsn, loc_id
