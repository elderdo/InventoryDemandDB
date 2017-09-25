
select
	',',
	'HISTORY'           , ',',
	',',
	asn.loc_id         , ',',
	',',
	',',
	',',
	',',
	',',
	',',
	ansi.nsn             , ',',
	',',
	',',
	',',
	',',
	',',
	'A'                 , ',',
	'BK ASSIGN' MEASURETYPE         , ',',
	to_number(null)     , ',',
	',',
	',',
	',',
	(null) TP     , ',',
	'FORECAST_BUCKET'
from
	amd_national_stock_items ansi,
	amd_demands ad,
	amd_spare_networks asn
where
	ansi.nsi_sid = ad.nsi_sid and
	ad.loc_sid = asn.loc_sid and
	ad.action_code != 'D' and
	ansi.action_code != 'D'

union


select
	',',
	'HISTORY'           , ',',
	',',
	asn.loc_id         , ',',
	',',
	',',
	',',
	',',
	',',
	',',
	ansi.nsn             , ',',
	',',
	',',
	',',
	',',
	',',
	'A'                 , ',',
	'BUCKETED' MEASURETYPE         , ',',
	sum(ad.quantity)        , ',',
	',',
	',',
	',',
	atp.tactical_bucket_id, ',',
	null             
from
	amd_national_stock_items ansi,
	amd_demands ad,
	amd_spare_networks asn,
	amd_time_periods atp
where
	ansi.nsi_sid = ad.nsi_sid and
	ad.loc_sid = asn.loc_sid and
	ad.action_code != 'D' and
	ansi.action_code != 'D'
	and ad.doc_date >= atp.time_period_start 
	and ad.doc_date <  atp.time_period_end
	and ad.doc_date <= sysdate

group by
	nsn,
	loc_id,
	atp.tactical_bucket_id


union


select
	',',
	'BASELINE_FORECAST', ',',
	',',
	asn.loc_id, ',',
	',',
	',',
	',',
	',',
	',',
	',',
	ansi.nsn, ',',
	',',
	',',
	',',
	',',
	',',
	'A'                 , ',',
	'BK ASSIGN' MEASURETYPE         , ',',
	to_number(null)     , ',',
	',',
	',',
	',',
	(null) TP     , ',',
	'FORECAST_BUCKET'
from 	
	amd_part_loc_forecasts aplf,
	amd_national_stock_items ansi,
	amd_spare_networks asn

where
	aplf.nsi_sid = ansi.nsi_sid and
	aplf.loc_sid = asn.loc_sid and
	amd_preferred_pkg.GetItemType(ansi.nsi_sid) = 'R' and
	aplf.action_code != 'D' and
	ansi.action_code != 'D' and
	asn.action_code != 'D' 

union


select
	',',
	'BASELINE_FORECAST'           , ',',
	',',
	asn.loc_id         , ',',
	',',
	',',
	',',
	',',
	',',
	',',
	ansi.nsn             , ',',
	',',
	',',
	',',
	',',
	',',
	'A'                 , ',',
	'BUCKETED' MEASURETYPE         , ',',
	amd_tmapi_pkg.GetCarryFwdRoundQty(aplf.forecast_name, aplf.nsi_sid, aplf.loc_sid, aplf.time_period_start) as quantity, ',',
	',',
	',',
	',',
	atp.tactical_bucket_id, ',',
	null             
from 	
	amd_time_periods atp,
	amd_part_loc_forecasts aplf,
	amd_national_stock_items ansi,
	amd_spare_networks asn

where		
	aplf.nsi_sid = ansi.nsi_sid and
	aplf.loc_sid = asn.loc_sid and
	trunc(aplf.time_period_start) = trunc(atp.time_period_start)   and
	trunc(aplf.time_period_end)   = trunc(atp.time_period_end)  and
	amd_preferred_pkg.GetItemType(ansi.nsi_sid) = 'R' and
	aplf.action_code != 'D' and
	ansi.action_code != 'D' and
	asn.action_code != 'D' 
