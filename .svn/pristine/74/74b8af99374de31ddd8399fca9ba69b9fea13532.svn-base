DROP VIEW C17DEVLPR.AMD_LP_OVERRIDE_V;

/* Formatted on 2007/10/03 10:57 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW C17DEVLPR.amd_lp_override_v (part,
                                                          LOCATION,
                                                          override_type,
                                                          quantity,
                                                          override_reason,
                                                          override_user,
                                                          begin_date,
                                                          end_date,
                                                          TIMESTAMP
                                                         )
AS
   SELECT "PART", "LOCATION", "OVERRIDE_TYPE", "QUANTITY", "OVERRIDE_REASON",
          "OVERRIDE_USER", "BEGIN_DATE", "END_DATE", "TIMESTAMP"
     FROM amd_owner.x_lp_override_v@LGB_AMD_LINK;


DROP PUBLIC SYNONYM AMD_LP_OVERRIDE_V;

CREATE PUBLIC SYNONYM AMD_LP_OVERRIDE_V FOR C17DEVLPR.AMD_LP_OVERRIDE_V;


GRANT SELECT ON C17DEVLPR.AMD_LP_OVERRIDE_V TO C17V2_DEVELOPER;

GRANT SELECT ON C17DEVLPR.AMD_LP_OVERRIDE_V TO SPOC17V2_DEVELOPER;

