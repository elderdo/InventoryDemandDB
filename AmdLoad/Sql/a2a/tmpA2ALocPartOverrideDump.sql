set echo off
set feedback off
set heading off
set pagesize 0
set linesize 140
spool &1/tmpA2ALocPartOverride.csv
Select
'PART_NO'
||','||'SITE_LOCATION'
||','||'OVERRIDE_TYPE'
||','||'OVERRIDE_QUANTITY'
||','||'OVERRIDE_REASON'
||','||'OVERRIDE_USER'
||','||'BEGIN_DATE'
||','||'END_DATE'
||','||'ACTION_CODE'
||','||'LAST_UPDATE_DT'
from dual
/
Select
PART_NO
||','||SITE_LOCATION 
||','||OVERRIDE_TYPE
||','||OVERRIDE_QUANTITY 
||','||OVERRIDE_REASON
||','||OVERRIDE_USER
||','||to_char(BEGIN_DATE,'MM-DD-YYYY HH24:MI:SS')
||','||to_char(END_DATE,'MM-DD-YYYY HH24:MI:SS')
||','||ACTION_CODE
||','||to_char(LAST_UPDATE_DT,'MM-DD-YYYY HH24:MI:SS')
from amd_owner.tmp_a2a_loc_part_override
/
spool off
set feedback on
set heading on
set pagesize 20
