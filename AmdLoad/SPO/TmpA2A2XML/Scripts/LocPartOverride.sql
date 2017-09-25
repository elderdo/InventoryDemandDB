SELECT 
'LBC17' as site_program,
'BATCH' as tran_source,
'001' as tran_priority,
'LOCATION_PART_OVERRIDE' as tran_type,
'I' as tran_action,
to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date,
SITE_LOCATION,
'' as CAGE_CODE,
PART_NO,
OVERRIDE_TYPE,
case when override_type = 'ROQ Fixed' and override_quantity = 0 then
    1
     when override_type = 'ROP Fixed' and override_quantity < 0 then
    -1    
     else OVERRIDE_QUANTITY
end override_quantity,
OVERRIDE_REASON,
to_number(replace(OVERRIDE_USER, ';')) OVERRIDE_USER,
to_char(BEGIN_DATE, 'YYYYMMDDHH24MISS') as BEGIN_DATE,
to_char(END_DATE, 'YYYYMMDDHH24MISS') as END_DATE
FROM tmp_a2a_loc_part_override tmp
where action_code in ('A','C')
and not exists (select null from tmp_a2a_loc_part_override
where part_no = tmp.part_no and site_location = tmp.site_location
AND OVERRIDE_TYPE IN ('TSL Fixed', 'ROP Fixed', 'ROQ Fixed')
group by part_no, site_location
having sum(override_quantity) = 0)

