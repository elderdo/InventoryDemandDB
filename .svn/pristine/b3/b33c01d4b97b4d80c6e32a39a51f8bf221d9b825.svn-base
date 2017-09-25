set echo off
set feedback off
set heading off
set pagesize 0
set linesize 130
spool &1/tmpA2ARepairInfo.csv
Select
'PART_NO'
||','||'SITE_LOCATION'
||','||'DOC_NO'
||','||'REPAIR_DATE'
||','||'STATUS'
||','||'RECEIPT_DATE'
||','||'EXPECTED_COMPLETION_DATE'
||','||'QUANTITY'
||','||'ACTION_CODE'
||','||'LAST_UPDATE_DT'
from dual
/
Select
PART_NO
||','||SITE_LOCATION
||','||DOC_NO
||','||to_char(REPAIR_DATE,'MM-DD-YYYY HH24:MI:SS')
||','||STATUS
||','||to_char(RECEIPT_DATE,'MM-DD-YYYY HH24:MI:SS')
||','||to_char(EXPECTED_COMPLETION_DATE,'MM-DD-YYYY HH24:MI:SS')
||','||QUANTITY
||','||ACTION_CODE
||','||to_char(LAST_UPDATE_DT,'MM-DD-YYYY HH24:MI:SS')
from amd_owner.tmp_a2a_repair_info
/
spool off
set feedback on
set heading on
set pagesize 20
