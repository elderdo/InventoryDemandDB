SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_PART_LEAD_TIME_V;

/* Formatted on 2008/09/22 21:28 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_part_lead_time_v (part,
                                                           lead_time_type,
                                                           quantity,
                                                           VARIANCE,
                                                           TIMESTAMP
                                                          )
AS
   SELECT pref.part_no part, 'NEW-BUY' lead_time_type,
          pref.order_lead_time quantity, 0 VARIANCE,
          part_last_update_dt TIMESTAMP
     FROM amd_preferred_v pref, amd_spare_parts parts
    WHERE pref.part_no = parts.part_no
      AND parts.action_code <> 'D'
      AND parts.is_spo_part = 'Y'
   UNION
   SELECT pref.part_no part, 'REPAIR' lead_time_type,
          pref.cost_to_repair_off_base quantity, 0 VARIANCE,
          part_last_update_dt TIMESTAMP
     FROM amd_preferred_v pref, amd_spare_parts parts
    WHERE pref.part_no = parts.part_no
      AND parts.action_code <> 'D'
      AND parts.is_spo_part = 'Y';


DROP PUBLIC SYNONYM X_PART_LEAD_TIME_V;

CREATE PUBLIC SYNONYM X_PART_LEAD_TIME_V FOR AMD_OWNER.X_PART_LEAD_TIME_V;


GRANT SELECT ON AMD_OWNER.X_PART_LEAD_TIME_V TO AMD_READER_ROLE;


