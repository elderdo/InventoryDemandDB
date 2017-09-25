select 	ansi.nsn			as	item, ',',		
	',',
	asn.loc_id			as	siteid, ',',
	',',
	',',
	TO_CHAR(apltp.time_period_start, 'YY-MM-DD') || ' 00:00'	as	effstartdate, ',',
	',',
	'A'				as syncind, ',',
	TO_CHAR(apltp.time_period_end + 1, 'YY-MM-DD') || ' 00:00'	as	effenddate, ',',
	''				as	minonhand, ',',
	',',
	',',
	',',
	apltp.reorder_point		as	ropqty, ',',	
	apltp.reorder_quantity		as	reorderqty, ',',	
	''				as	orderupto, ',',
	',',
	''				as	roptimesupply, ',',
	''				as	outltimesupply, ',',
	',',
	''				as	orderinterval, ',',
	',',
	',',
	',',
	',',
	',',
	',',
	''				as	mintime

from 	amd_part_loc_time_periods apltp,
	amd_spare_networks	asn,
	amd_national_stock_items ansi

where	apltp.loc_sid = asn.loc_sid	and
	apltp.nsi_sid = ansi.nsi_sid	and
	ansi.action_code != 'D' 	and
	asn.action_code != 'D'		and
	apltp.action_code != 'D'
