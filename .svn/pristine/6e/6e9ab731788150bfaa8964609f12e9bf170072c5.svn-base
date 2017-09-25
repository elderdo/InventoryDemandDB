select
'LBC17' as site_program,
'BATCH' as tran_source,
'002' as tran_priority,
'BOM_DETAIL' as tran_type,
'D' as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
P1.PART as part_no,
P2.PART as included_par,
P2.CAGE as included_cage,
BD.Quantity as quantity,
'C17' as BOM,
to_char(BD.BEGIN_DATE,'YYYYMMDDHH24MISS') as begin_date,
to_char(BD.END_DATE,'YYYYMMDDHH24MISS') as end_date
FROM escmc17v2.BOM_DETAIL BD, escmc17v2.BOM B, escmc17v2.PART P1, escmc17v2.PART P2
WHERE BD.PART_ID = P1.PART_ID
AND BD.INCLUDED_PART_ID = P2.PART_ID
AND BD.BOM_ID = B.BOM_ID
and trunc(bd.timestamp) < trunc(to_date('11/09/2006','MM/DD/YYYY')) 

