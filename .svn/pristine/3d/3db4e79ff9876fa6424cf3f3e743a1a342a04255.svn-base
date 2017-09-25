set echo off
set feedback off
set heading off
set pagesize 0
set linesize 80
spool &1/tmpA2ABackorderInfo.csv
Select
'PART_NO'
||','||'SITE_LOCATION'
||','||'QTY'
||','||'ACTION_CODE'
||','||'LAST_UPDATE_DT'
||','||'LOC_SID'
from dual
/
Select
PART_NO
||','||SITE_LOCATION
||','||QTY
||','||ACTION_CODE
||','||to_char(LAST_UPDATE_DT,'MM-DD-YYYY HH24:MI:SS')
||','||LOC_SID
from amd_owner.tmp_a2a_backorder_info
/
spool off
set feedback on
set heading on
set pagesize 20
