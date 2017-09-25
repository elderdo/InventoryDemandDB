
select
	',',
	',',
	',',
	'A'		as	syncind, ',',
	calendar_name	as	calendarname, ',',
	'ACTIVE'	as 	calendartype, ',',
	'0'		as 	shiftnumber, ',',
	TO_CHAR(exception_date, 'YY-MM-DD') || ' 00:00'	as	exceptiondate
from amd_calendar_exceptions
where action_code != 'D'
