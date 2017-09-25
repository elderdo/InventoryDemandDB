select	',',
	',',
	',', 
	'A' 			as 		syncind, ',',
	planner_code 		as 		employeeid, ',',
	REPLACE(planner_description, ',', ' ') 	as 		employeename
from 	amd_planners
where action_code != 'D'
order by planner_code
