/* version 1.2 */
/* ??? need 3 years for production instead of 730 */
/* include 'ROR' in list for offbase */

select 	ansi.nsn		as 	item_id, ',',
	asn.loc_id	as	location_id, ',',
	'BASELINE_FORECAST'	as demand_measure_id, ',',
	'N_A'		as	returns_measure_id, ',',
	'N_A'		as	bom_demand_measure_id, ',',
	730		as	days_to_explode, ',',
	''		as	admin_buckets

from 	amd_part_locs apl,
	amd_national_stock_items ansi,
	amd_spare_networks asn

where	apl.loc_sid = asn.loc_sid 	and
	apl.nsi_sid = ansi.nsi_sid	and
	asn.loc_type in ('MOB', 'FSL', 'ROR')	and
	amd_preferred_pkg.GetItemType(ansi.nsn) = 'R' and
	apl.action_code != 'D'		and
	ansi.action_code != 'D'		and
	asn.action_code != 'D'
