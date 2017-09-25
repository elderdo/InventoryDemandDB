SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_OVERRIDE_V;

/* Formatted on 2008/03/19 12:01 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_lp_override_v (LOCATION,
                                                        part,
                                                        override_type,
                                                        quantity,
                                                        override_reason,
                                                        override_user,
                                                        begin_date,
                                                        end_date,
                                                        TIMESTAMP
                                                       )
AS
   SELECT amd_utils.getspolocation (loc_sid) LOCATION, part_no,
          'TSL Fixed' override_type,
          CASE
             WHEN amd_utils.getspolocation (loc_sid) =
                     amd_location_part_override_pkg.getthe_warehouse
             AND amd_utils.ispartrepairableyorn (part_no) = 'Y'
                THEN 0
             ELSE tsl_override_qty
          END quantity,
          'Fixed TSL Load' override_reason,
          TO_CHAR (TO_NUMBER (tsl_override_user)) override_user,
          last_update_dt begin_date, NULL end_date, last_update_dt TIMESTAMP
     FROM amd_location_part_override
    WHERE action_code <> 'D'
   UNION
   SELECT rsp_location LOCATION, part_no, override_type, rop_or_roq quantity,
          'Fixed TSL Load' override_reason,
          TO_CHAR
             (TO_NUMBER
                 (amd_location_part_override_pkg.getfirstlogonidforpart
                                       (amd_utils.getnsisidfrompartno (part_no)
                                       )
                 )
             ) override_user,
          last_update_dt begin_date, NULL end_date, last_update_dt TIMESTAMP
     FROM amd_owner.amd_rsp_sum_consumables_v
    WHERE action_code <> 'D'
   UNION
   SELECT rsp_location LOCATION, part_no, override_type, rsp_level quantity,
          'Fixed TSL Load' override_reason,
          TO_CHAR
             (TO_NUMBER
                 (amd_location_part_override_pkg.getfirstlogonidforpart
                                       (amd_utils.getnsisidfrompartno (part_no)
                                       )
                 )
             ) override_user,
          last_update_dt begin_date, NULL end_date, last_update_dt TIMESTAMP
     FROM amd_owner.amd_rsp_sum_repairables_v
    WHERE action_code <> 'D'
   UNION
   SELECT spo_location, part_no, tsl_override_type, tsl_override_qty,
          'Fixed TSL Load' override_reason,
          TO_CHAR (TO_NUMBER (tsl_override_user)), last_update_dt begin_date,
          NULL end_date, last_update_dt TIMESTAMP
     FROM amd_locpart_overid_consumables
    WHERE action_code <> 'D' AND spo_location NOT LIKE '%_RSP';


DROP PUBLIC SYNONYM X_LP_OVERRIDE_V;

CREATE PUBLIC SYNONYM X_LP_OVERRIDE_V FOR AMD_OWNER.X_LP_OVERRIDE_V;


GRANT SELECT ON AMD_OWNER.X_LP_OVERRIDE_V TO AMD_READER_ROLE;


