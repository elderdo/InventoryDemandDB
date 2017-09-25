SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'001' as tran_priority,
'PART_ALT_REL_DEL' as tran_type,
'D' as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
'' as CAGE_CODE,
PART_NO,
'' as PRIME_CAGE,
PRIME_PART
FROM tmp_a2a_part_alt_rel_delete
