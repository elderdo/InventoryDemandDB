set echo off
set feedback off
set heading off
set pagesize 0
set linesize 80
spool &1/tmpA2APartAltRelDelete.csv
Select
'PART_NO'
||','||'CAGE_CODE'
||','||'PRIME_PART'
||','||'PRIME_CAGE'
||','||'LAST_UPDATE_DT'
from dual
/
Select
PART_NO
||','||CAGE_CODE
||','||PRIME_PART
||','||PRIME_CAGE
||','||to_char(LAST_UPDATE_DT,'MM-DD-YYYY HH24:MI:SS')
from amd_owner.tmp_a2a_part_alt_rel_delete
/
spool off
set feedback on
set heading on
set pagesize 20
