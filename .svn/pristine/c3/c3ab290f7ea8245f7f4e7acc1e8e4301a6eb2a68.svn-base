/* ??? supervisor  */
select	',',
	',',
	',', 
	'A' 			as 		syncind, ',',
	planner_code 		as 		employeeid, ',',
	nvl(REPLACE(planner_description, ',', ' '), planner_code) 	as 		employeename
from 	amd_planners
where action_code != 'D'

union

select	',',
	',',
	',', 
	'A' 			as 		syncind, ',',
	'Supervisor' 		as 		employeeid, ',',
	'Supervisor'		as		employeename
from 	dual
