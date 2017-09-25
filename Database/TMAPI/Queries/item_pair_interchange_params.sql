/* db changed to disband foreign key constraint to amd_part_locs.  amd_part_locs only holds
CWH, FSL, MOB, ROR => amd_item_pair_interchg_parms may hold other locations like cod */

select
	asn.loc_id	as	location_id, ',',
	ansi.nsn	as	item_id, ',',
	ansiSub.nsn	as	substitute_item_id, ',',
	to_char(aipip.effective_start_date, 'YY-MM-DD') || ' 00:00' as effective_start_date, ',',
	to_char(aipip.effective_end_date, 'YY-MM-DD') || ' 00:00' as	effective_end_date, ',',
	aipip.theoretical_overlap_percent  	as 	theoretical_overlap_percent

from 	
	amd_item_pr_interchg_parm aipip,
	amd_part_locs	apl,
	amd_spare_networks	  asn,
	amd_national_stock_items  ansi,
	amd_national_stock_items  ansiSub

where	asn.loc_type in ('CWH', 'FSL', 'MOB', 'ROR') and
	aipip.nsi_sid = apl.nsi_sid	and
	aipip.loc_sid = apl.loc_sid	and
	aipip.loc_sid = asn.loc_sid 	and
	aipip.nsi_sid = ansi.nsi_sid	and
	aipip.substitute_nsi_sid = ansiSub.nsi_sid and
	aipip.action_code != 'D'	and
	ansi.action_code != 'D'		and
	ansiSub.action_code != 'D'	and
	asn.action_code != 'D'

union

select
	asn.loc_id	as	location_id, ',',
	ansi.nsn	as	item_id, ',',
	ansiSub.nsn	as	substitute_item_id, ',',
	to_char(aipip.effective_start_date, 'YY-MM-DD') || ' 00:00' as effective_start_date, ',',
	to_char(aipip.effective_end_date, 'YY-MM-DD') || ' 00:00' as	effective_end_date, ',',
	aipip.theoretical_overlap_percent  	as 	theoretical_overlap_percent

from 	
	amd_item_pr_interchg_parm aipip,
	amd_spare_networks	  asn,
	amd_national_stock_items  ansi,
	amd_national_stock_items  ansiSub

where	asn.loc_type not in ('CWH', 'FSL', 'MOB', 'ROR') and
	aipip.loc_sid = asn.loc_sid 	and
	aipip.nsi_sid = ansi.nsi_sid	and
	aipip.substitute_nsi_sid = ansiSub.nsi_sid and
	aipip.action_code != 'D'	and
	ansi.action_code != 'D'		and
	ansiSub.action_code != 'D'	and
	asn.action_code != 'D'
