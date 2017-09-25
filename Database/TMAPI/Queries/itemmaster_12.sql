/* condemn cost */
/* 02/26/02 removed # from part_no */
select 	',',
	ansi.nsn 		as item, ',',
	',',
	'A'			as syncind, ',',
	',',
       	REPLACE(amd_preferred_pkg.GetNomenclature(ansi.nsi_sid), ',', ' ') as itemdesc,',',
	',',
	',',
	',',
	',',
	',',
	',',
	'0'			as category, ',',
	amd_preferred_pkg.GetOrderUom(ansi.prime_part_no) as uom, ',',
	amd_preferred_pkg.GetShelfLife(ansi.prime_part_no) as shelflife, ',',
	',',
	',',
	',',
	''			as listprice, ',',
	amd_preferred_pkg.GetUnitCost(ansi.nsi_sid) as unitcost, ',', 
	',',
	',',
	',',
	',',
	''			as effstartdate, ',', 
	''			as effenddate, ',',
	',',
	',',
	''			as storageclassid, ',',
	amd_preferred_pkg.GetUnitVolume(ansi.prime_part_no)	as volume, ',',
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
	ansi.condemn_cost	as condemncost, ',',
	',',
	''			as lcl, ',',
	''			as ucl,	',',
	''			as depletionstart, ',',
	''   			as property, ',',
	',',
	amd_preferred_pkg.GetPlannerCode(ansi.nsi_sid) as  plannercode, ',',
	decode(amd_preferred_pkg.GetItemType(ansi.nsi_sid), 'R', ansi.nsn||'-JOB', '')	as brokenitem, ',',
	'N'			as fcignore
	
from 	amd_national_stock_items ansi,
	amd_spare_parts asp

where
	asp.icp_ind 	= 'F77' 		and
	asp.part_no 	= ansi.prime_part_no 		and
	ansi.action_code != 'D' 		and
	asp.action_code != 'D'

union


select 	',',
	REPLACE(REPLACE(asp.part_no, ',', ' '), '#', '')	as item, ',',
	',',
	'A'				as syncind, ',',
	',',
       	REPLACE(decode(amd_preferred_pkg.GetNomenclature(asp.part_no), null, amd_preferred_pkg.GetNomenclature(ansi.nsi_sid), amd_preferred_pkg.GetNomenclature(asp.part_no)), ',', ' ') as itemdesc,',',
	',',
	',',
	',',
	',',
	',',
	',',
	'1'			as category, ',',
	amd_preferred_pkg.GetOrderUom(asp.part_no) as uom, ',',
	amd_preferred_pkg.GetShelfLife(asp.part_no) as shelflife, ',',
	',',
	',',
	',',
	''			as listprice, ',',
	amd_preferred_pkg.GetUnitCostByPart(asp.part_no) as unitcost, ',', 
	',',
	',',
	',',
	',',
	''			as effstartdate, ',', 
	''			as effenddate, ',',
	',',
	',',
	''			as storageclassid, ',',
	amd_preferred_pkg.GetUnitVolume(asp.part_no)	as volume, ',',
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
	to_number(null)		as condemncost, ',',
	',',
	''			as lcl, ',',
	''			as ucl,	',',
	''			as depletionstart, ',',
	''		  	as property, ',',
	',',
	amd_preferred_pkg.GetPlannerCode(ansi.nsi_sid) as  plannercode, ',',
	''		as brokenitem, ',',
	'N'			as fcignore
	


from 	amd_national_stock_items ansi,
	amd_spare_parts asp

where
	asp.icp_ind 	= 'F77' 		and
	asp.nsn 	= ansi.nsn 		and
	ansi.action_code != 'D' 		and
	asp.action_code != 'D'

union

select 	',',
	ansi.nsn || '-JOB' 		as item, ',',
	',',
	'A'			as syncind, ',',
	',',
       	REPLACE(amd_preferred_pkg.GetNomenclature(ansi.nsi_sid), ',', ' ') as itemdesc,',',
	',',
	',',
	',',
	',',
	',',
	',',
	'0'			as category, ',',
	amd_preferred_pkg.GetOrderUom(ansi.prime_part_no) as uom, ',',
	amd_preferred_pkg.GetShelfLife(ansi.prime_part_no) as shelflife, ',',
	',',
	',',
	',',
	''			as listprice, ',',
	amd_preferred_pkg.GetUnitCost(ansi.nsi_sid) as unitcost, ',', 
	',',
	',',
	',',
	',',
	''			as effstartdate, ',', 
	''			as effenddate, ',',
	',',
	',',
	''			as storageclassid, ',',
	amd_preferred_pkg.GetUnitVolume(ansi.prime_part_no)	as volume, ',',
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
	ansi.condemn_cost	as condemncost, ',',
	',',
	''			as lcl, ',',
	''			as ucl,	',',
	''			as depletionstart, ',',
	''			as property, ',',
	',',
	amd_preferred_pkg.GetPlannerCode(ansi.nsi_sid) as  plannercode, ',',
	''			as brokenitem, ',',
	'N'			as fcignore
	
from 	amd_national_stock_items ansi,
	amd_spare_parts asp

where
	asp.icp_ind 	= 'F77' 		and
	asp.part_no 	= ansi.prime_part_no 		and
	ansi.action_code != 'D' 		and
	asp.action_code != 'D' and
	amd_preferred_pkg.GetItemType(ansi.nsi_sid) = 'R'
