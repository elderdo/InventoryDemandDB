SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_PART_MTBF_V;

/* Formatted on 2008/09/22 22:50 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_part_mtbf_v (part,
                                                      mtbf_type,
                                                      quantity,
                                                      TIMESTAMP
                                                     )
AS
   SELECT pref.part_no part, 'Engineering Flight Hours' mtbf_type,
          pref.mtbdr quantity, part_last_update_dt TIMESTAMP
     FROM amd_preferred_v pref, amd_spare_parts parts
    WHERE pref.mtbdr IS NOT NULL
      AND parts.part_no = pref.part_no
      AND parts.is_spo_part = 'Y';


DROP PUBLIC SYNONYM X_PART_MTBF_V;

CREATE PUBLIC SYNONYM X_PART_MTBF_V FOR AMD_OWNER.X_PART_MTBF_V;


GRANT SELECT ON AMD_OWNER.X_PART_MTBF_V TO AMD_READER_ROLE;


