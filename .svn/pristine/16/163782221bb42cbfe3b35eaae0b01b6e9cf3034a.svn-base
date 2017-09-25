SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'002' as tran_priority,
'IN_TRANSIT' as tran_type,
'I' as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
part_no,
rtrim(SITE_LOCATION) SITE_LOCATION,
QTY,
decode(TYPE, 'Y','General','N','Defective', TYPE) TYPE
FROM 
tmp_a2a_in_transits
WHERE
action_code in ('A','C')
