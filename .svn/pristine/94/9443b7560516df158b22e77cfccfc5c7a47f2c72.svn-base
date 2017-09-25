select 	',',
	tactical_bucket_name	as	bucketname, ',',
	tactical_bucket_id	as	bucketid, ',',
	',',
	'A'			as	syncind, ',',
	TO_CHAR(time_period_start, 'YY-MM-DD HH:MM')	as 	startdate, ',',
	TO_CHAR(time_period_end, 'YY-MM-DD HH:MM')	as 	enddate
from 	amd_time_periods
where 	action_code != 'D'
