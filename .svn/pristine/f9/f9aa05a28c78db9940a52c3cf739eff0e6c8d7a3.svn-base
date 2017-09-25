select alldata.* from (

select 	'CRITICALITY_CODE'	as attribute_id, 	',',
	data.attribute_value 	as attribute_value, 	',',
	'MTBF'			as measure_id, 		',',
	data.upper_bound	as upper_bound,		',',
	'MTBF'			as group_type,		',',
	asn.loc_id 		as siteid, 		',',
	data.lower_bound	as lower_bound,		',',
	data.group_id		as group_id,		',',
	data.measure_range_id	as measure_range_id
from 	amd_spare_networks asn, 
	(select 'C' as attribute_value, 999999 as upper_bound, 15000 as lower_bound, 
		'C_PFC3' as group_id, 3 as measure_range_id from dual
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
where asn.loc_type not in ('OBR', 'STR', 'ALL')
union
select 	'CRITICALITY_CODE'	as attribute_id, 	',',
	data.attribute_value 	as attribute_value, 	',',
	'MTBF'			as measure_id, 		',',
	data.upper_bound	as upper_bound,		',',
	'MTBF'			as group_type,		',',
	asn.loc_id || '_DIFM'  	as siteid, 	',',
	data.lower_bound	as lower_bound,		',',
	data.group_id		as group_id,		',',
	data.measure_range_id	as measure_range_id
from 	amd_spare_networks asn, 
	(select 'C' as attribute_value, 999999 as upper_bound, 15000 as lower_bound, 
		'C_PFC3' as group_id, 3 as measure_range_id from dual
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
where 	asn.loc_type in ('FSL', 'MOB')


) alldata
order by alldata.siteid, alldata.attribute_value, alldata.lower_bound

