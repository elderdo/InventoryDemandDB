select	',',
	decode(item_type_cleaned, NULL, 
		decode(item_type, 'R', 'REPAIRABLES', 'C', 'CONSUMABLES'),	
		decode(item_type_cleaned, 'R', 'REPAIRABLES', 'C', 'CONSUMABLES'))	
			as 	itemgroup, ',',
	nsn		as 	item, ',',
	',',
	''		as	siteid, ',',
	',',
	'A'		as 	syncind, ',',
	',',
	''		as	itemorganizationgroup
	
from amd_national_stock_items
where 	action_code != 'D' and
	tactical = 'Y'

