SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_BACKORDER_V;

/* Formatted on 2008/05/16 12:13 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_lp_backorder_v (LOCATION,
                                                         part,
                                                         backorder_type,
                                                         quantity,
                                                         TIMESTAMP
                                                        )
AS
   SELECT amd_utils.getspolocation (loc_sid) LOCATION, spo_prime_part_no part,
          'General' backorder_type, qty, last_update_dt TIMESTAMP
     FROM amd_backorder_sum
    WHERE action_code <> 'D' AND amd_utils.getspolocation (loc_sid) IS NOT NULL;


DROP PUBLIC SYNONYM X_LP_BACKORDER_V;

CREATE PUBLIC SYNONYM X_LP_BACKORDER_V FOR AMD_OWNER.X_LP_BACKORDER_V;


GRANT SELECT ON AMD_OWNER.X_LP_BACKORDER_V TO AMD_READER_ROLE;


