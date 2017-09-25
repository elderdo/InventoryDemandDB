SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'002' as tran_priority,
'LOCATION_PART_LEAD_TIME' as tran_type,
'I' as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
'' as CAGE_CODE,
PART_NO,
SITE_LOCATION,
LEAD_TIME_TYPE,
LEAD_TIME
FROM tmp_a2a_loc_part_lead_time
where action_code in ('A','C')
