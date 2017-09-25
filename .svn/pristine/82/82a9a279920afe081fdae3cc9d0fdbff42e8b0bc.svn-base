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
	',',
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
	ansi.nsn             , ',',
	to_number(null) TP     , ',',
	'FORECAST_BUCKET'
from
	amd_national_stock_items ansi,
	amd_demands ad,
	amd_spare_networks asn

where
	ansi.nsi_sid = ad.nsi_sid and
	ad.loc_sid = asn.loc_sid and
	ad.action_code != 'D' and
	ansi.tactical = 'Y' and
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
	',',
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
	ansi.nsn             , ',',
	months_between(trunc(ad.doc_date,'mm'),
		trunc(to_date('19961001','yyyymmdd'),'mm'))+1 TP   , ',',
	null             
from
	amd_national_stock_items ansi,
	amd_demands ad,
	amd_spare_networks asn

where
	ansi.nsi_sid = ad.nsi_sid and
	ad.loc_sid = asn.loc_sid and
	ad.action_code != 'D' and
	ansi.tactical = 'Y' and
	ansi.action_code != 'D'

group by
	nsn,
	loc_id,
	trunc(ad.doc_date,'mm')
order by
	measuretype,
	nsn, 
	loc_id,
	tp
