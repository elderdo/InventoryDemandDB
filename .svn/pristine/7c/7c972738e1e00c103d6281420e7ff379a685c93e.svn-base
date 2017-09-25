set echo off
set feedback off
set heading off
set pagesize 0
set linesize 100
spool &1/tmpA2AInvInfo.csv
Select
'SITE_LOCATION'
||','||'QTY_ON_HAND'
||','||'ACTION_CODE'
||','||'LAST_UPDATE_DT'
||','||'REORDER_POINT'
||','||'STOCK_LEVEL'
||','||'CAGE_CODE'
||','||'PART_NO'
from dual
/
Select
SITE_LOCATION
||','||QTY_ON_HAND
||','||ACTION_CODE
||','||to_char(LAST_UPDATE_DT,'MM-DD-YYYY HH24:MI:SS')
||','||REORDER_POINT
||','||STOCK_LEVEL
||','||CAGE_CODE
||','||PART_NO
from amd_owner.tmp_a2a_inv_info
/
spool off
set feedback on
set heading on
set pagesize 20
