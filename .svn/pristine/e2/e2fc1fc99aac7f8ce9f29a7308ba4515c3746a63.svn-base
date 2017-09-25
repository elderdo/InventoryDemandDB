select 	',',
	ansi.nsn 		as item, ',',
	',',
	'A'			as syncind, ',',
       	decode(ansi.nomenclature_cleaned, NULL, REPLACE(asp.nomenclature, ',', ' '), REPLACE(ansi.nomenclature_cleaned, ',', ' ')) as itemdesc,',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	decode(ansi.distrib_uom, NULL, ansi.distrib_uom_defaulted, ansi.distrib_uom)  	as uom, ',',
	decode(asp.shelf_life, NULL, asp.shelf_life_defaulted, asp.shelf_life)		as shelflife, ',', 
	',',
	',',
	',',
	''			as listprice, ',',
	decode(ansi.unit_cost_cleaned, NULL, 
		decode(asp.unit_cost, NULL, asp.unit_cost_defaulted, asp.unit_cost), ansi.unit_cost_cleaned)	as unitcost, ',', 
	',',
	',',
	',',
	',',
	''			as effstartdate, ',', 
	''			as effenddate, ',',
	',',
	',',
	decode(asp.unit_volume, NULL, asp.unit_volume_defaulted, asp.unit_volume)	as volume, ',',
	',',
	',',
	''			as netweight, ',',
	',',
	',',
	''			as palletunit, ',', 
	',',
	''			as stackheight, ',', 
	',',
	',',
	',',
	',',
	',',
	',',
	decode(ansi.criticality_cleaned, NULL, 
		('NAME=:CRITICALITY_CODE=' || decode(sign(nvl(ansi.criticality,0) - .67), 1, 'C', 
						decode(sign(nvl(ansi.criticality,0) - .33), 1, 'D', 'M')) || ';'),
		('NAME=:CRITICALITY_CODE=' || decode(sign(nvl(ansi.criticality_cleaned,0) - .67), 1, 'C', 
						decode(sign(nvl(ansi.criticality_cleaned,0) - .33), 1, 'D', 'M')) || ';'), 
				as property, ',',
	',',
	''			as depletionstart, ',',
	''			as ucl,	',',
	''			as lcl, ',',
	''			as storageclassid, ',',
	decode(ansi.planner_code_cleaned, NULL, ansi.planner_code, ansi.planner_code_cleaned)	as plannercode


from 	amd_national_stock_items ansi,
	amd_spare_parts asp

where
	asp.icp_ind 	= 'F77' 		and
	asp.part_no 	= ansi.prime_part_no 	and
	asp.mfgr	= ansi.prime_mfgr	and
	ansi.tactical = 'Y' 			and
	ansi.action_code != 'D' 		and
	asp.action_code != 'D'
	
