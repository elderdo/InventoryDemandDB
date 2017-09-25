SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'008' as tran_priority,
'ORG_FLIGHT_ACTY_FORECAST' as tran_type,
action_code as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
upper(buno) as buno,
to_char(period, 'YYYYMMDDHH24MISS') as period,
causal_type,
causal_value,
base_name
FROM tmp_a2a_org_flight_acty_frecst
where action_code = 'D'
