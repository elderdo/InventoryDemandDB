set echo off
set feedback off
set heading off
set pagesize 0
set linesize 80
spool &1/tmpA2ASiteRespAssetMgr.csv
Select
'SITE_RESP_ASSET_MGR'
||','||'TOOL_LOGON_ID'
||','||'DATA_SOURCE'
||','||'ACTION_CODE'
||','||'LAST_UPDATE_DT'
from dual 
/
Select
SITE_RESP_ASSET_MGR
||','||TOOL_LOGON_ID
||','||DATA_SOURCE
||','||ACTION_CODE
||','||to_char(LAST_UPDATE_DT,'MM-DD-YYYY HH24:MI:SS')
from amd_owner.tmp_a2a_site_resp_asset_mgr
/
spool off
set feedback on
set heading on
set pagesize 20
