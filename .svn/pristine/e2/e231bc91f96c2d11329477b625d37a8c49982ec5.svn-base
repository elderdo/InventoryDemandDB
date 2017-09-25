set echo off
set feedback off
set heading off
set pagesize 0
set linesize 100
spool &1/tmpA2APartPricing.csv
Select
'SOURCE_SYSTEM'
||','||'PART_NO'
||','||'PRICE_FISCAL_YEAR'
||','||'PRICE_TYPE'
||','||'PRICE'
||','||'PRICE_DATE'
||','||'ACTION_CODE'
||','||'LAST_UPDATE_DT'
from dual
/
Select
SOURCE_SYSTEM
||','||PART_NO
||','||PRICE_FISCAL_YEAR
||','||PRICE_TYPE
||','||PRICE
||','||to_char(PRICE_DATE,'MM-DD-YYYY HH24:MI:SS')
||','||ACTION_CODE
||','||to_char(LAST_UPDATE_DT,'MM-DD-YYYY HH24:MI:SS')
from amd_owner.tmp_a2a_part_pricing
/
spool off
set feedback on
set heading on
set pagesize 20
