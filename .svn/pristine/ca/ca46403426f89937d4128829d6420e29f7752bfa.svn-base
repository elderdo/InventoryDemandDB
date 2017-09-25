select 	',',
	nsn		as	item, ',',
	'CATEGORY'	as	attribute, ',',
	',',	
	'A'		as	syncind, ',',	
	',',	
	',',	
	',',	
	decode(amd_preferred_pkg.GetItemType(nsi_sid), 'C', 'CONSUMABLE', 'R', 'REPAIRABLE') 
			as attributetestringval

from 	amd_national_stock_items ansi
where 	action_code != 'D'

union

select 	',',
	nsn			as	item, ',',
	'CRITICALITY_CODE'	as	attribute, ',',
	',',	
	'A'		as	syncind, ',',	
	',',	
	',',	
	',',	
	nvl(amd_preferred_pkg.GetCriticality(nsi_sid), 'M') as attributetestringval

from 	amd_national_stock_items ansi
where 	action_code != 'D'
