select 	ansi.nsn			as	item, ',',		
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
	amd_national_stock_items ansi

where	apltp.loc_sid = asn.loc_sid	and
	apltp.nsi_sid = ansi.nsi_sid	and
	ansi.action_code != 'D'		and
	ansi.tactical = 'Y'		and
	asn.action_code != 'D'

