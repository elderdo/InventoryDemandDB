SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_IN_TRANSIT_V;

/* Formatted on 2008/09/22 23:08 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_lp_in_transit_v (LOCATION,
                                                          part,
                                                          in_transit_type,
                                                          quantity,
                                                          TIMESTAMP
                                                         )
AS
   SELECT site_location LOCATION, transits.part_no part,
          DECODE (serviceable_flag,
                  'Y', 'General',
                  'N', 'Defective',
                  serviceable_flag
                 ) in_transit_type,
          quantity, transits.last_update_dt TIMESTAMP
     FROM amd_in_transits_sum transits, amd_spare_parts parts
    WHERE transits.action_code <> 'D'
      AND transits.part_no = parts.part_no
      AND parts.is_spo_part = 'Y';


DROP PUBLIC SYNONYM X_LP_IN_TRANSIT_V;

CREATE PUBLIC SYNONYM X_LP_IN_TRANSIT_V FOR AMD_OWNER.X_LP_IN_TRANSIT_V;


GRANT SELECT ON AMD_OWNER.X_LP_IN_TRANSIT_V TO AMD_READER_ROLE;


