SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_PART_CAUSAL_TYPE_V;

/* Formatted on 2009/07/08 16:46 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.x_part_causal_type_v (part,
                                                             causal_type,
                                                             quantity,
                                                             last_modified
                                                            )
as
   select parts.part_no part, flight_hours_causal causal_type, 1 quantity,
          parts.last_update_dt last_modified
     from amd_spare_parts parts, amd_spo_types_v
    where parts.is_spo_part = 'Y';


DROP PUBLIC SYNONYM X_PART_CAUSAL_TYPE_V;

CREATE PUBLIC SYNONYM X_PART_CAUSAL_TYPE_V FOR AMD_OWNER.X_PART_CAUSAL_TYPE_V;


GRANT SELECT ON AMD_OWNER.X_PART_CAUSAL_TYPE_V TO AMD_READER_ROLE;

