/* 02/13/02 replaced use of amd_tmapi_pkg.GetPriority because it was too slow.
last outer layer not required but makes rownums sequential */
/* 02/14/02 accomodate null for mfgr */
/* 02/26/02 removed # from part_no */
/*	
	priority is visible in spp product, using amd_tmapi_pkg.ResetSequence 
	changed to renumber starting with 1	
	for lowest priority per nsn group (as opposed to rownum).
	for spp highest priority has highest number with prime always
	being the highest priority and others chosen by order of unit cost.
*/

select 
	nsn				as 	item_id, ',',
	REPLACE(REPLACE(part_no, ',', ' '), '#', '')	as	child_item_id, ',',
	amd_tmapi_pkg.ResetSequence(unitCost, -1)	as	priority, ',',	
	nvl(mfgr, 'UNKNOWN')		as	vendor_id, ',',
	REPLACE(REPLACE(part_no, ',', ' '), '#', '')	as	vendor_item_id
from
	(select nsn, part_no, mfgr,rownum, unitCost
		from
			(select
				asp.nsn,
	  			asp.part_no,
				asp.mfgr,
				decode(ansi.prime_part_no, asp.part_no, -1,
					  	decode(asp.unit_cost, null, asp.unit_cost_defaulted, asp.unit_cost)) as unitCost
			 from
				amd_spare_parts asp, amd_national_stock_items ansi
	 		 where
				ansi.nsn = asp.nsn	and
				ansi.action_code != 'D' and
				asp.action_code != 'D'
			 order by unitCost desc)		
	order by nsn, rownum)
order by nsn, rownum



