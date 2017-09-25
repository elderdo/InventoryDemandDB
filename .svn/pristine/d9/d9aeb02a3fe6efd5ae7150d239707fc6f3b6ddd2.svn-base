SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'008' as tran_priority,
'ORDER_INFO_LINE' as tran_type,
ol.action_code as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS')  as tran_date,
ol.ORDER_NO,
ol.SITE_LOCATION,
to_char(ol.CREATED_DATE, 'YYYYMMDDHH24MISS') as CREATED_DATE,
ol.STATUS,
CAGE_CODE,
ol.PART_NO part_no,
line,
qty_ordered,
qty_received,
to_char(due_date, 'YYYYMMDDHH24MISS') as due_date
FROM  tmp_a2a_order_info_line ol 
where ol.action_code = 'D'
