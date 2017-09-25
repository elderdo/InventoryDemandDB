SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_PART_CAUSAL_TYPE_V;

/* Formatted on 2008/09/22 22:55 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_part_causal_type_v (part,
                                                             causal_type,
                                                             quantity,
                                                             TIMESTAMP
                                                            )
AS
   SELECT parts.part_no part, 'Flight Hours' causal_type, 1 quantity,
          parts.last_update_dt TIMESTAMP
     FROM amd_spare_parts parts
    WHERE parts.is_spo_part = 'Y';


DROP PUBLIC SYNONYM X_PART_CAUSAL_TYPE_V;

CREATE PUBLIC SYNONYM X_PART_CAUSAL_TYPE_V FOR AMD_OWNER.X_PART_CAUSAL_TYPE_V;


GRANT SELECT ON AMD_OWNER.X_PART_CAUSAL_TYPE_V TO AMD_READER_ROLE;


