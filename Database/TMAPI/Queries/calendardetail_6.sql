/* effstartdate will need to be updated for first working day for that calendar year, jan 02 for 2001  */
select 	',',
	',',
	',',
	'A'		as	syncind, ',',
	calendar_name	as	calendarname, ',',
	'ACTIVE'	as	calendartype, ',',
	'0'		as	shiftnumber, ',',
	TO_CHAR(sysdate, 'YY') || '-01-02 00:00'	
			as	effstartdate, ',',
	TO_CHAR( ADD_MONTHS(SYSDATE, 36), 'YY-MM-DD HH:MI') 
			as	effenddate, ',',
	',',
	',',
	working_sunday	as	workingsunday, ',',
	working_monday	as	workingmonday, ',',
	working_tuesday	as	workingtuesday, ',',
	working_wednesday as	workingwednesday, ',',
	working_thursday  as	workingthursday, ',',
	working_friday	  as	workingfriday, ',',
	working_saturday  as	workingsaturday, ',',
	',',
	',',
	''		as	value, ',',
	''		as	valueuom
from amd_calendars
where action_code != 'D'
