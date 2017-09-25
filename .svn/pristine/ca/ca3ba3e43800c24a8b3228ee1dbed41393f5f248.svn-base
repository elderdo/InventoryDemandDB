set echo off
set feedback off
set heading off
set pagesize 0
set linesize 100
spool &1/tmpA2AExtForecast.csv
Select
'DUPLICATE'
||','||'PART_NO'
||','||'LOCATION'
||','||'DEMAND_FORECAST_TYPE'
||','||'PERIOD'
||','||'QUANTITY'
||','||'ACTION_CODE'
||','||'LAST_UPDATE_DT'
from dual
/
Select
DUPLICATE
||','||PART_NO
||','||LOCATION
||','||DEMAND_FORECAST_TYPE
||','||to_char(PERIOD,'MM-DD-YYYY HH24:MI:SS')
||','||QUANTITY
||','||ACTION_CODE
||','||to_char(LAST_UPDATE_DT,'MM/DD/YYYY HH:MI:SS PM')
from amd_owner.tmp_a2a_ext_forecast
/
spool off
set feedback on
set heading on
set pagesize 20
