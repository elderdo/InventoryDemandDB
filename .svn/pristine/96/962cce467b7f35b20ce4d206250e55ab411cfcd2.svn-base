select 	',',
	ansi.nsn		as	item, 	',',
	asn.loc_id		as	siteid, ',',
	',',
	'A'			as 	syncind,',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	''			as 	lotsizemax, ',',
	''			as 	lotsizemin, ',',
	',',
	',',
	',',
	',',
	'"FI"'			as	sourcetype, ',',
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
	',',
	',',
	',',
	',',
	',',
	',',
	''			as	releasefence, ',',
	''			as	lotsizeincrement

from 	amd_part_locs apl, 
	amd_national_stock_items ansi,
	amd_spare_networks asn 

where	apl.nsi_sid = ansi.nsi_sid	and
	apl.loc_sid = asn.loc_sid	and 
	ansi.tactical = 'Y'		and
	ansi.action_code != 'D'		and
	asn.loc_type not in ('ROR', 'OBR', 'ALL', 'STR')

union

select 	',',
	ansi.nsn	as	item, 	',',
	asn.loc_id	as	siteid, ',',
	',',
	'A'		as 	syncind,',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	''		as 	lotsizemax, ',',
	''		as 	lotsizemin, ',',
	',',
	',',
	',',
	',',
	'"FI"'	as	sourcetype, ',',
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
	',',
	',',
	',',
	',',
	',',
	',',
	''		as	releasefence, ',',
	''		as	lotsizeincrement
from 	amd_part_locs apl, 
	amd_national_stock_items ansi,
	amd_spare_networks asn 
where	ansi.item_type	= 'R' 		and
	apl.nsi_sid = ansi.nsi_sid	and
	apl.loc_sid = asn.loc_sid	and 
	ansi.tactical = 'Y'		and
	ansi.action_code != 'D'		and
	asn.loc_type in ('ROR')

union	

select 	',',
	ansi.nsn		as	item, 	',',
	asn.loc_id || '_DIFM'	as	siteid, ',',
	',',
	'A'		as 	syncind,',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	''		as 	lotsizemax, ',',
	''		as 	lotsizemin, ',',
	',',
	',',
	',',
	',',
	'"FI"'	as	sourcetype, ',',
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
	',',
	',',
	',',
	',',
	',',
	',',
	''		as	releasefence, ',',
	''		as	lotsizeincrement
from 	amd_part_locs apl, 
	amd_national_stock_items ansi,
	amd_spare_networks asn 
where	ansi.item_type	= 'R' 		and
	apl.nsi_sid = ansi.nsi_sid	and
	apl.loc_sid = asn.loc_sid	and 
	ansi.tactical = 'Y'		and
	ansi.action_code != 'D'		and
	asn.loc_type in ('FSL', 'MOB')

union

select 	',',
	ansi.nsn		as	item, 	',',
	ansi.prime_mfgr 	as	siteid, ',',
	',',
	'A'		as 	syncind,',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	''		as 	lotsizemax, ',',
	''		as 	lotsizemin, ',',
	',',
	',',
	',',
	',',
	'"FI"'	as	sourcetype, ',',
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
	',',
	',',
	',',
	',',
	',',
	',',
	''		as	releasefence, ',',
	''		as	lotsizeincrement
from 	
	amd_national_stock_items ansi

where	
	ansi.tactical = 'Y'		and
	ansi.action_code != 'D'

union

select 	',',
	ansi.nsn		as	item, 	',',
	codcwh.loc_id		as	siteid, ',',
	',',
	'A'			as 	syncind,',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	''			as 	lotsizemax, ',',
	''			as 	lotsizemin, ',',
	',',
	',',
	',',
	',',
	'"FI"'			as	sourcetype, ',',
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
	',',
	',',
	',',
	',',
	',',
	',',
	''			as	releasefence, ',',
	''			as	lotsizeincrement

from
	amd_national_stock_items ansi,
	(select loc_id from amd_spare_networks where loc_type in ('COD', 'CWH') and action_code != 'D') codcwh

where
	ansi.tactical = 'Y'		and
	ansi.action_code != 'D'
