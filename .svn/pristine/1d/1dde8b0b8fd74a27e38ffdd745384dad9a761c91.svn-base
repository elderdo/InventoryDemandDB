set echo off
set feedback off
set heading off
set pagesize 0
set linesize 100
spool &1/tmpA2ALocPartLeadTime.csv
Select
'PART_NO'
||','||'LEAD_TIME_TYPE'
||','||'LEAD_TIME'
||','||'ACTION_CODE'
||','||'LAST_UPDATE_DT'
||','||'SITE_LOCATION'
from dual
/
Select
PART_NO
||','||LEAD_TIME_TYPE
||','||LEAD_TIME
||','||ACTION_CODE
||','||to_char(LAST_UPDATE_DT,'MM-DD-YYYY HH24:MI:SS')
||','||SITE_LOCATION
from amd_owner.tmp_a2a_loc_part_lead_time
/
spool off
set feedback on
set heading on
set pagesize 20
