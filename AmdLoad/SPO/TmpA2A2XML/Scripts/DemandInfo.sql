SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'002' as tran_priority,
'DEMAND_INFO' as tran_type,
'I'  as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
part_no as part,
site as site_location,
docno, 
to_char(demand_date, 'YYYYMMDDHH24MISS') as demand_date,
qty, 
status,
demand_level,
demand_type,
upper(buno) as buno
from tmp_a2a_demands
where action_code in ('A','C')
and site not in ('FB4454','FB4455','FB4412','FB4490','FB4491')
