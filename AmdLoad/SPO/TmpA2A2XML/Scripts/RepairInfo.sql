SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'002' as tran_priority,
'REPAIR_INFO' as tran_type,
'I' as tran_action,
to_char(sysdate,'YYYYMMDDHH24MISS') as tran_date,
part_no,
SITE_LOCATION,
DOC_NO,
to_char(REPAIR_DATE,'YYYYMMDDHH24MISS') as REPAIR_DATE,
STATUS,
to_char(EXPECTED_COMPLETION_DATE,'YYYYMMDDHH24MISS') as EXPECTED_COMPLETION_DATE,
QUANTITY
FROM tmp_a2a_repair_info
WHERE action_code in ('A','C')
