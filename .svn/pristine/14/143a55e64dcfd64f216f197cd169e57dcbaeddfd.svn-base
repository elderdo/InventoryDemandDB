SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_PART_MTBF_V;

/* Formatted on 2009/06/09 15:35 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.x_part_mtbf_v (part,
                                                      mtbf_type,
                                                      quantity,
                                                      timestamp
                                                     )
as
   select pref.part_no part, engineering_flight_hours_mtbf mtbf_type,
          pref.mtbdr quantity, part_last_update_dt timestamp
     from amd_preferred_v pref, amd_spare_parts parts, amd_spo_types_v
    where pref.mtbdr is not null
      and parts.part_no = pref.part_no
      and parts.is_spo_part = 'Y';


DROP PUBLIC SYNONYM X_PART_MTBF_V;

CREATE PUBLIC SYNONYM X_PART_MTBF_V FOR AMD_OWNER.X_PART_MTBF_V;


GRANT SELECT ON AMD_OWNER.X_PART_MTBF_V TO AMD_READER_ROLE;

