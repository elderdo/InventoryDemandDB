select	',',
	decode(amd_preferred_pkg.GetItemType(nsn), 'R', 'REPAIRABLES', 'C', 'CONSUMABLES')
			as 	itemgroup, ',',
	nsn		as 	item, ',',
	',',
	''		as	siteid, ',',
	',',
	'A'		as 	syncind, ',',
	',',
	''		as	itemorganizationgroup
	
from amd_national_stock_items ansi
where 	action_code != 'D' and
nvl(amd_preferred_pkg.GetItemType(nsn), 'NONE') != 'NONE'
