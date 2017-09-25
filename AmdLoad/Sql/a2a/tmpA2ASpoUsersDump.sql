set echo off
set feedback off
set heading off
set pagesize 0
set linesize 80
spool &1/tmpA2ASpoUsers.csv
Select
'BEMS_ID'
||','||'EMAIL'
||','||'NAME'
||','||'PHONE'
||','||'DEPT'
||','||'ACTIVE'
||','||'ACTION_CODE'
||','||'LAST_UPDATE_DT'
from dual
/
Select
BEMS_ID
||','||EMAIL
||','||NAME
||','||PHONE
||','||DEPT
||','||ACTIVE
||','||ACTION_CODE
||','||to_char(LAST_UPDATE_DT,'MM-DD-YYYY HH24:MI:SS')
from amd_owner.tmp_a2a_spo_users
/
spool off
set feedback on
set heading on
set pagesize 20
