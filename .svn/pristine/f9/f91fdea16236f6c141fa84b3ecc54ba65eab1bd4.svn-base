whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on
set serveroutput on size 1000000


spool ../log/sparePartCount.txt

declare
cnt number ;
begin
select count(*) into cnt from amd_spare_parts where action_code <> 'D' ;
dbms_output.put_line('cnt=' || cnt) ;
end ;
/

spool off

quit
