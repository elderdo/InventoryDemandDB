select	',',
	',',
	',',
	'A' 			as 		syncind, ',',
	'PLANNER'		as 		hierarchyname, ',',
	planner_code 		as 		employeeid, ',',
	supervisor_code		as 		supervisorid  
from amd_planners
where 	action_code != 'D' and 
	planner_code != supervisor_code and 
	supervisor_code is not null
