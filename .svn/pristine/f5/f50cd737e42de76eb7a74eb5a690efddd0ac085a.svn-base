set echo off
set feedback off
set heading off
set pagesize 0
set linesize 110 
spool &1/tmpA2APartEffectivity.csv
Select
'PART_NO'
||','||'MDL'
||','||'SERIES'
||','||'EFFECTIVITY_TYPE'
||','||'RANGE_FROM'
||','||'RANGE_TO'
||','||'RANGE_FLAG'
||','||'QPEI'
||','||'CUSTOMER'
||','||'ACTION_CODE'
||','||'LAST_UPDATE_DT'
from dual
/
Select
PART_NO
||','||MDL
||','||SERIES
||','||EFFECTIVITY_TYPE
||','||RANGE_FROM
||','||RANGE_TO
||','||RANGE_FLAG
||','||QPEI
||','||CUSTOMER
||','||ACTION_CODE
||','||to_char(LAST_UPDATE_DT,'MM-DD-YYYY HH24:MI:SS')
from amd_owner.tmp_a2a_part_effectivity
/
spool off
set feedback on
set heading on
set pagesize 20
