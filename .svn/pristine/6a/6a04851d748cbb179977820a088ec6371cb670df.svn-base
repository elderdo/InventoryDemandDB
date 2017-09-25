/* db changed to disband foreign key constraint to amd_part_locs.  amd_part_locs only holds
CWH, FSL, MOB, ROR => amd_substitute may hold other locations like cod */
select
	',',
	ansi.nsn	as	item_id, ',',
	ansiSub.nsn	as	substitute_item_id, ',',
	''		as	organizationid, ',',
	asn.loc_id	as	location_id, ',',
	',',
	',',
	',',
	'A'		as	syncind, ',',
	',',
	ais.priority	as	priority, ',',
	ais.substitution_ratio		as	substituteratio, ',',
	to_char(ais.effective_start_date, 'YY-MM-DD') || ' 00:00'	as	effstartdate, ',',
	to_char(ais.effective_end_date, 'YY-MM-DD') || ' 00:00'	as	effenddate, ',',
	',',
	''				as	sublmtprcnt

from 	amd_item_substitute	  ais,
	amd_part_locs		  apl,
	amd_spare_networks	  asn,
	amd_national_stock_items  ansi,
	amd_national_stock_items  ansiSub

where	asn.loc_type in ('CWH', 'FSL', 'MOB', 'ROR') and
	ais.loc_sid = apl.loc_sid 	and
	ais.nsi_sid = apl.nsi_sid	and
	ais.loc_sid = asn.loc_sid 	and
	ais.nsi_sid = ansi.nsi_sid 	and
	ais.substitute_nsi_sid = ansiSub.nsi_sid and 
	ansi.action_code != 'D' and
	ansiSub.action_code != 'D'


union

select
	',',
	ansi.nsn	as	item_id, ',',
	ansiSub.nsn	as	substitute_item_id, ',',
	''		as	organizationid, ',',
	asn.loc_id	as	location_id, ',',
	',',
	',',
	',',
	'A'		as	syncind, ',',
	',',
	ais.priority	as	priority, ',',
	ais.substitution_ratio		as	substituteratio, ',',
	to_char(ais.effective_start_date, 'YY-MM-DD') || ' 00:00'	as	effstartdate, ',',
	to_char(ais.effective_end_date, 'YY-MM-DD') || ' 00:00'	as	effenddate, ',',
	',',
	''				as	sublmtprcnt

from 	amd_item_substitute	  ais,
	amd_spare_networks	  asn,
	amd_national_stock_items  ansi,
	amd_national_stock_items  ansiSub

where	asn.loc_type not in ('CWH', 'FSL', 'MOB', 'ROR') and
	ais.loc_sid = asn.loc_sid 	and
	ais.nsi_sid = ansi.nsi_sid 	and
	ais.substitute_nsi_sid = ansiSub.nsi_sid and 
	ansi.action_code != 'D' and
	ansiSub.action_code != 'D'
