SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'001' as tran_priority,
'EXT_FORECAST' as tran_type,
'I' as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
LOCATION as SITE_LOCATION,
'' as CAGE_CODE,
PART_NO,
DEMAND_FORECAST_TYPE,
to_char(period, 'YYYYMMDDHH24MISS') as period,
QUANTITY,
DUPLICATE
FROM tmp_a2a_ext_forecast
where action_code in ('A','C')
and location <> 'FD2090'
