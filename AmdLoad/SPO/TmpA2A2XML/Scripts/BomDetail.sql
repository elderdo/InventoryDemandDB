SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'002' as tran_priority,
'BOM_DETAIL' as tran_type,
'I' as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
part_no,
included_part,
included_cage,
quantity,
bom,
'19930614000000'as begin_date,
'20131231000000' as end_date
FROM 
tmp_a2a_bom_detail
WHERE
action_code in ('A','C')
