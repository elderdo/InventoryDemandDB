SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_ON_HAND_V;

/* Formatted on 2008/05/16 12:14 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_lp_on_hand_v (LOCATION,
                                                       part,
                                                       on_hand_type,
                                                       quantity,
                                                       TIMESTAMP
                                                      )
AS
   SELECT spo_location LOCATION, part_no part, 'General' on_hand_type,
          qty_on_hand quantity, last_update_dt TIMESTAMP
     FROM amd_on_hand_invs_sum
    WHERE action_code <> 'D'
   UNION
   SELECT site_location LOCATION, part_no part, 'Defective' on_hand_type,
          qty_on_hand quantity, last_update_dt TIMESTAMP
     FROM amd_repair_invs_sum
    WHERE action_code <> 'D';


DROP PUBLIC SYNONYM X_LP_ON_HAND_V;

CREATE PUBLIC SYNONYM X_LP_ON_HAND_V FOR AMD_OWNER.X_LP_ON_HAND_V;


GRANT SELECT ON AMD_OWNER.X_LP_ON_HAND_V TO AMD_READER_ROLE;


