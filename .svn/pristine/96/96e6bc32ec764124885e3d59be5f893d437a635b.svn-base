SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'008' as tran_priority,
'EXT_FORECAST' as tran_type,
'D' as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
location.site_location as site_location,
'' as CAGE_CODE,
part.part as PART_NO,
type.value as DEMAND_FORECAST_TYPE,
to_char(period, 'YYYYMMDDHH24MISS') as period,
QUANTITY,
1 as DUPLICATE
from escmc17v2.external_forecast extForecast,
escmc17v2.type type,
escmc17v2.location location,
escmc17v2.part part
where extForecast.PART_ID = part.PART_ID
and extForecast.demand_forecast_type_id = type.type_id
and extForecast.location_id = location.location_id

