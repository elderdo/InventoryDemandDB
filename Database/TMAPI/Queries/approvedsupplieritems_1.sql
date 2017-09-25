/* ??? process by pass FI
	asp.process_bypass			as gobbypass, ',',
	'FI'		as gobbypass, ',',
 */
/* 02/14/02 accomodate null for mfgr */
/* 02/26/02 removed # from part_no */
select 
	ansi.nsn 	as item, ',',
	',',
	',',
	''		as supplierid, ',',
	',',
	',',
	',',
	',',
	',',
	'A'		as syncind, ',',
	',', ',', ',', ',', ',', ',', ',', ',', ',', ',',
	',', ',', ',', ',', ',', ',', ',', ',', 
	''		as minlotsize, ',',
	''		as maxlotsize, ',',
	''		as lotsizeincrement, ',',
	',', ',', ',', ',', ',', ',', ',', ',', ',', ',',
	''		as constrainttype, ',',
	'0'		as subitem, ',',
	'0'		as loadingpriority, ',',
	'0'		as goweight, ',',
	'0'		as fixedorderqty, ',',
	''		as gobbypass, ',',
	'PO_GROUP_' || nvl(mfgr,'UNKNOWN') || '_CTLATL'	as suppliergroupid
from 
	amd_spare_parts asp,
	amd_national_stock_items ansi
where 	
	asp.part_no = ansi.prime_part_no and	
	asp.action_code != 'D' and 
	ansi.action_code != 'D' 

union

select 
	REPLACE(REPLACE(asp.part_no, ',', ' '), '#', '') as item, ',',
	',',
	',',
	nvl(asp.mfgr, 'UNKNOWN')	as supplierid, ',',
	',',
	',',
	',',
	',',
	',',
	'A'		as syncind, ',',
	',', ',', ',', ',', ',', ',', ',', ',', ',', ',',
	',', ',', ',', ',', ',', ',', ',', ',', 
	''		as minlotsize, ',',
	''		as maxlotsize, ',',
	''		as lotsizeincrement, ',',
	',', ',', ',', ',', ',', ',', ',', ',', ',', ',',
	''		as constrainttype, ',',
	''		as subitem, ',',
	''		as loadingpriority, ',',
	''		as goweight, ',',
	''		as fixedorderqty, ',',
	'FI'			as gobbypass, ',',
	''	as suppliergroupid
from 
	amd_spare_parts asp
where 	
	action_code != 'D' 

