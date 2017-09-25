SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'005' as tran_priority,
'SPO_USER' as tran_type,
'I' as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
to_number(bems_id) bems_id,
email,
name,
decode(action_code, 'C','A',action_code) active
FROM tmp_a2a_spo_users
where action_code != 'D'
