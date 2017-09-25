 SELECT 
'LBC17' AS site_program,
'BATCH' AS tran_source,
'002' AS tran_priority,
'INV_INFO' AS tran_type,
 'I'  AS tran_action,
TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') AS tran_date,
part_no,
site_location,
qty_on_hand,
'General' on_hand_type
FROM TMP_A2A_INV_INFO
WHERE action_code IN ('A','C')
UNION 
SELECT 
'LBC17' AS site_program,
'BATCH' AS tran_source,
'002' AS tran_priority,
'INV_INFO' AS tran_type,
 'I'  AS tran_action,
TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') AS tran_date,
part_no,
site_location,
qty_on_hand,
'Defective' on_hand_type
FROM TMP_A2A_REPAIR_INV_INFO
WHERE action_code IN ('A','C')
