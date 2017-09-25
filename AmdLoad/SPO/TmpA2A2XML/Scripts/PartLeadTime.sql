SELECT 
distinct 'LBC17' as site_program,
'BATCH' as tran_source,
'002' as tran_priority,
'PART_LEAD_TIME' as tran_type,
'I' as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
SOURCE_SYSTEM,
LEAD_TIME_TYPE,
LEAD_TIME,
CAGE_CODE,
spo_prime_part_no part_no
FROM tmp_a2a_part_lead_time time,  amd_sent_to_a2a sent
where time.action_code in ('A','C')
and sent.spo_prime_part_no = time.part_no 
and sent.spo_prime_part_no is not null
and sent.action_code != 'D' order by part_no, lead_time_type

