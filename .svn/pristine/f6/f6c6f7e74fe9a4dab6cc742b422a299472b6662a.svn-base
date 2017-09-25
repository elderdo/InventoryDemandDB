SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'007' as tran_priority,
'BACKORDER_INFO' as tran_type,
'D' as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
amd_utils.getSpoPrimePartNo(part_no) part_no,
SITE_LOCATION,
sum(QTY) qty,
'General' as BACKORDER_TYPE
FROM 
tmp_a2a_backorder_info
WHERE
action_code = 'D' and qty is not null
group by amd_utils.getSpoPrimePartNo(part_no), site_location

