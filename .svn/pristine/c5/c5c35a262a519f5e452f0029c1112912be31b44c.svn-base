select 	',',
	',',
	',',
	'A'		as	syncind, ',',
	calendar_name	as	calendarname, ',',
	'ACTIVE'	as	calendartype, ',',
	'0'		as	shiftnumber, ',',
	TO_CHAR(sysdate, 'YY') || '-01-01 00:00'	
			as	effstartdate, ',',
	TO_CHAR(
		ADD_MONTHS(
			TRUNC(
				TO_DATE( 
					TO_CHAR(sysdate, 'YY') || '-01-01', 'YY-MM-DD')), 36), 'YY-MM-DD HH:MM') 
			as	effenddate, ',',
	working_sunday	as	workingsunday, ',',
	working_monday	as	workingmonday, ',',
	working_tuesday	as	workingtuesday, ',',
	working_wednesday as	workingwednesday, ',',
	working_thursday  as	workingthursday, ',',
	working_friday	  as	workingfriday, ',',
	working_saturday  as	workingsaturday, ',',
	''		as	value, ',',
	''		as	valueuom
from amd_calendars
where action_code != 'D'
