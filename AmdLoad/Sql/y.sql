set heading off
set feedback off
set tab off 
set newpage none
set pagesize 0

select 
	substr(o.prime,1,20) || chr(9) ||
	to_char(completed_docdate,'mm/dd/yyyy HH:MM:SS AM') || chr(9) ||
	to_char(created_docdate,'mm/dd/yyyy HH:MM:SS AM') || chr(9) ||
	action_taken
from
	cat1 c, ord1 o
where
	c.source_code = 'F77'
	and c.part = o.prime
	and action_taken = 'D'  
order by
	substr(o.prime,1,20);
quit
