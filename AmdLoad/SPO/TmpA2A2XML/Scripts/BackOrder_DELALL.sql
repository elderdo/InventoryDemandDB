select 'LBC17' as program,
'BATCH' as tran_source,
'002' as tran_priority,
'BACKORDER_INFO' as tran_type,
'D' as tran_action,
to_char(sysdate,'YYYYMMDDHH24MISS') as tran_date,
part as part_no,
site_location,as qty,
'General' as BACKORDER_TYPE  
from escmc17v2.backorder bo,
escmc17v2.location loc,
escmc17v2.part pt
where 
bo.LOCATION_ID = loc.LOCATION_ID
and bo.PART_ID = pt.PART_ID

