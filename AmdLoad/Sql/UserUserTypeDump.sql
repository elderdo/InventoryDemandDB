whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set echo off
set feedback off
set heading off
set pagesize 0
set linesize 80
spool /apps/CRON/AMD/data/UserUserTypeDump.csv
Select
'SPO_USER'
||','||'USER_TYPE'
||','||'LAST_MODIFIED'
from dual
/
Select
SPO_USER
||','||USER_TYPE
||','||to_char(LAST_MODIFIED,'MM-DD-YYYY HH24:MI:SS')
from spoc17v2.user_user_type
/
spool off
set feedback on
set heading on
set pagesize 20

quit
