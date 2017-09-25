select 	'CRITICALITY_MATRIX_ID_1'	as criticality_matrix_id, ',',
	data.item_attribute_value 	as item_attribute_value, 	',',
	data.range_id			as range_id, 		',',
	data.lower_bound		as lower_bound,		',',
	data.upper_bound		as upper_bound,		',',
	data.item_loc_group		as item_loc_group
from 	(select 'C' as item_attribute_value, 
		999999 as upper_bound, 
		15000 as lower_bound, 
		'C_PFC3' as item_loc_group, 
		3 as range_id from dual

	union
	select 'C',  14999,  5000, 'C_PFC2', 2 from dual
	union
	select 'C',   4999,     0, 'C_PFC1', 1 from dual
	union
	select 'D', 999999, 15000, 'D_PFC3', 3 from dual
	union
	select 'D',  14999,  5000, 'D_PFC2', 2 from dual
	union
	select 'D',   4999,     0, 'D_PFC1', 1 from dual
	union
	select 'M', 999999, 15000, 'M_PFC3', 3 from dual
	union
	select 'M',  14999,  5000, 'M_PFC2', 2 from dual
	union
	select 'M',   4999,     0, 'M_PFC1', 1 from dual) data
