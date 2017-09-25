set echo off
set feedback off
set heading off
set pagesize 0
set linesize 110 
spool &1/tmpA2APartFactors.csv
Select
'BASE_NAME'
||','||'CRITICALITY_CODE'
||','||'ACTION_CODE'
||','||'LAST_UPDATE_DT'
||','||'PART_NO'
||','||'SOURCE_SYSTEM'
||','||'MTBDR'
||','||'MTTR'
||','||'RTS'
||','||'NRTS'
||','||'CMDMD_RATE'
from dual
/
Select
BASE_NAME
||','||CRITICALITY_CODE
||','||ACTION_CODE
||','||to_char(LAST_UPDATE_DT,'MM-DD-YYYY HH24:MI:SS')
||','||PART_NO
||','||SOURCE_SYSTEM
||','||MTBDR
||','||MTTR
||','||RTS
||','||NRTS
||','||CMDMD_RATE
from amd_owner.tmp_a2a_part_factors
/
spool off
set feedback on
set heading on
set pagesize 20
