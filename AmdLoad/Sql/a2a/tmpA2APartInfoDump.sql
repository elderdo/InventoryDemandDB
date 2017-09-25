set echo off
set feedback off
set heading off
set pagesize 0
set linesize 700
spool &1/tmpA2APartInfo.csv
Select
'SOURCE_SYSTEM'
||','||'CAGE_CODE'
||','||'PART_NO'
||','||'UNIT_ISSUE'
||','||'NOUN'
||','||'RCM_IND'
||','||'HAZMAT_CODE'
||','||'SHELF_LIFE'
||','||'EQUIPMENT_TYPE'
||','||'NSN_COG'
||','||'NSN_MCC'
||','||'NSN_FSC'
||','||'NSN_NIIN'
||','||'NSN_SMIC_MMAC'
||','||'NSN_ACTY'
||','||'ESSENTIALITY_CODE'
||','||'RESP_ASSET_MGR'
||','||'UNIT_PACK_CUBE'
||','||'UNIT_PACK_QTY'
||','||'UNIT_PACK_WEIGHT'
||','||'UNIT_PACK_WEIGHT_MEASURE'
||','||'ELECTRO_STATIC_DISCHARGE'
||','||'PERF_BASED_LOG_INFO'
||','||'PLANNED_PART'
||','||'THIRD_PARTY_FLAG'
||','||'MTBF'
||','||'MTBF_TYPE'
||','||'SHELF_LIFE_ACTION_CODE'
||','||'PREFERRED_SMRCODE'
||','||'DECAY_RATE'
||','||'INDENTURE'
||','||'LAST_UPDATE_DT'
||','||'ACTION_CODE'
||','||'IS_EXEMPT'
||','||'IGNORE_WEIGHT_AND_VOLUME'
||','||'IS_ORDER_POLICY_REQ_BASE'
||','||'PRICE'
from dual
/
Select
SOURCE_SYSTEM
||','||CAGE_CODE
||','||PART_NO
||','||UNIT_ISSUE
||',"'||NOUN || '"'
||','||RCM_IND
||','||HAZMAT_CODE
||','||SHELF_LIFE
||','||EQUIPMENT_TYPE
||','||NSN_COG
||','||NSN_MCC
||','||NSN_FSC
||','||NSN_NIIN
||','||NSN_SMIC_MMAC
||','||NSN_ACTY
||','||ESSENTIALITY_CODE
||','||RESP_ASSET_MGR
||','||UNIT_PACK_CUBE
||','||UNIT_PACK_QTY
||','||UNIT_PACK_WEIGHT
||','||UNIT_PACK_WEIGHT_MEASURE
||','||ELECTRO_STATIC_DISCHARGE
||','||PERF_BASED_LOG_INFO
||','||PLANNED_PART
||','||THIRD_PARTY_FLAG
||','||MTBF
||','||MTBF_TYPE
||','||SHELF_LIFE_ACTION_CODE
||','||PREFERRED_SMRCODE
||','||DECAY_RATE
||','||INDENTURE
||','||to_char(LAST_UPDATE_DT,'MM-DD-YYYY HH24:MI:SS')
||','||ACTION_CODE
||','||IS_EXEMPT
||','||IGNORE_WEIGHT_AND_VOLUME
||','||IS_ORDER_POLICY_REQ_BASE
||','||PRICE
from amd_owner.tmp_a2a_part_info
/
spool off
set feedback on
set heading on
set pagesize 20
