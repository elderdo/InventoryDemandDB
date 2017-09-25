select 	',',
	''				as	forecastgroupname, ',',
	',',
	',',
	TO_CHAR(aplf.time_period_start, 'YY-MM-DD HH:MM')	as	effstartdate, ',',
	',',
	',',
	',',
	asn.loc_id			as	siteid, ',',
	',',
	',',
	',',
	',',
	',',
	'A'				as	syncind, ',',
	TO_CHAR(aplf.time_period_end, 'YY-MM-DD HH:MM')	as	effenddate, ',',
	aplf.forecast_qty		as	fcstqty, ',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	aplf.forecast_name		as	forecastname


from 	amd_part_loc_forecasts aplf,
	amd_spare_networks asn,
	amd_national_stock_items ansi

where	aplf.loc_sid = asn.loc_sid and
	aplf.nsi_sid = ansi.nsi_sid and
	aplf.action_code != 'D' and
	ansi.tactical = 'Y' and
	ansi.action_code != 'D'


