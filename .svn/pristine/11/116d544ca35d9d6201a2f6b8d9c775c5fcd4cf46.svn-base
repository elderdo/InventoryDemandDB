-- run at the begining of post processing

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set heading off
set linesize 200
set term off
set feedback off

spool /tmp/enableUsers.sql
-- for Windows spool C:\TEMP\enableUsers.sql

select 'update spoc17v2.user_login set is_active = ''T'', last_modified = sysdate, last_modified_by = 0 where spo_user = ''' || spo_user || ''';'  
from spoc17v2.user_login 
where is_active = 'T'
and spo_user not in (0,1001)
order by spo_user ;
/

spool off

update spoc17v2.user_login
set is_active = 'F',
last_modified = sysdate,
last_modified_by = 0
where is_active = 'T'
and spo_user not in (0,1001) ;


exit
