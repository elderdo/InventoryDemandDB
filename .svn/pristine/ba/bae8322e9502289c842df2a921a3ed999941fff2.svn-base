SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_ON_HAND_V;

/* Formatted on 2008/09/22 23:03 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_lp_on_hand_v (LOCATION,
                                                       part,
                                                       on_hand_type,
                                                       quantity,
                                                       TIMESTAMP
                                                      )
AS
   SELECT spo_location LOCATION, invs.part_no part, 'General' on_hand_type,
          qty_on_hand quantity, invs.last_update_dt TIMESTAMP
     FROM amd_on_hand_invs_sum invs, amd_spare_parts parts
    WHERE invs.action_code <> 'D'
      AND invs.part_no = parts.part_no
      AND parts.is_spo_part = 'Y'
   UNION
   SELECT site_location LOCATION, invs.part_no part, 'Defective' on_hand_type,
          qty_on_hand quantity, invs.last_update_dt TIMESTAMP
     FROM amd_repair_invs_sum invs, amd_spare_parts parts
    WHERE invs.action_code <> 'D'
      AND invs.part_no = parts.part_no
      AND parts.is_spo_part = 'Y';


DROP PUBLIC SYNONYM X_LP_ON_HAND_V;

CREATE PUBLIC SYNONYM X_LP_ON_HAND_V FOR AMD_OWNER.X_LP_ON_HAND_V;


GRANT SELECT ON AMD_OWNER.X_LP_ON_HAND_V TO AMD_READER_ROLE;


