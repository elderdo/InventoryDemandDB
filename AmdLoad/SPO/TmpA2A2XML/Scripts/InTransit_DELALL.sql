SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'007' as tran_priority,
'IN_TRANSIT' as tran_type,
'D' as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
part as part_no,
SITE_LOCATION,
quantity as QTY,
ty.VALUE as TYPE
FROM 
escmc17v2.in_transit intr,
escmc17v2.location loc,
escmc17v2.part pt,
escmc17v2.type ty 
WHERE
intr.location_id = loc.location_id
and intr.part_id = pt.part_id
and intr.IN_TRANSIT_TYPE_ID = ty.type_id 

