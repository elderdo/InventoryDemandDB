/* aplf.forecast_qty		as	fcstqty */
select 	',',
	'DEMAND'				as	forecastname, ',',
	',',
	',',
	TO_CHAR(aplf.time_period_start, 'YY-MM-DD') || ' 00:00'	as	effstartdate, ',',
	ansi.nsn				as	item, ',',
	',',
	',',
	asn.loc_id			as	siteid, ',',
	',',
	',',
	',',
	',',
	',',
	'A'				as	syncind, ',',
	TO_CHAR(aplf.time_period_end + 1, 'YY-MM-DD') || ' 00:00'	as	effenddate, ',',
	',',
	',',
	amd_tmapi_pkg.GetCarryFwdRoundQty(aplf.forecast_name, aplf.nsi_sid, aplf.loc_sid, aplf.time_period_start) as	fcstqty
			

from 	amd_part_loc_forecasts aplf,
	amd_spare_networks asn,
	amd_national_stock_items ansi

where	aplf.loc_sid = asn.loc_sid and
	aplf.nsi_sid = ansi.nsi_sid and
	aplf.action_code != 'D' and
	ansi.action_code != 'D'
