SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'008' as tran_priority,
'ORDER_INFO_LINE' as tran_type,
ord.action_code as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS')  as tran_date,
gold_order_number ORDER_NO,
amd_utils.GETSITELOCATION(loc_sid) SITE_LOCATION,
to_char(ord.order_DATE, 'YYYYMMDDHH24MISS') as CREATED_DATE,
'O' STATUS,
parts.mfgr CAGE_CODE,
ord.part_no,
ord.line,
0 qty_ordered,
0 qty_received,
to_char(ord.SCHED_RECEIPT_DATE, 'YYYYMMDDHH24MISS') as due_date
FROM amd_on_order ord, amd_spare_parts parts 
where ord.action_code = 'D'
and ord.PART_NO = parts.part_no

