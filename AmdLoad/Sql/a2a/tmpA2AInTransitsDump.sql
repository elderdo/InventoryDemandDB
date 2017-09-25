set echo off
set feedback off
set heading off
set pagesize 0
set linesize 100
spool &1/tmpA2AInTransits.csv
Select
'PART_NO'
||','||'SITE_LOCATION'
||','||'QTY'
||','||'TYPE'
||','||'ACTION_CODE'
||','||'LAST_UPDATE_DT'
from dual
/
Select
PART_NO
||','||SITE_LOCATION
||','||QTY
||','||TYPE
||','||ACTION_CODE
||','||to_char(LAST_UPDATE_DT,'MM-DD-YYYY HH24:MI:SS')
from amd_owner.tmp_a2a_in_transits
/
spool off
set feedback on
set heading on
set pagesize 20
