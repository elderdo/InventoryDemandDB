/*   				
       $Author:   zf297a  $
     $Revision:   1.0  $
         $Date:   20 Feb 2008 14:06:20  $
     $Workfile:   x_lp_override_v.sql  $
	  $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Views\x_lp_override_v.sql.-arc  $
/*   
/*      Rev 1.0   20 Feb 2008 14:06:20   zf297a
/*   Initial revision.
*/

SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_OVERRIDE_V;

/* Formatted on 2008/02/20 11:10 (Formatter Plus v4.8.8) */
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
   SELECT rsp_location LOCATION, part_no, override_type,
          CASE
             WHEN rsp_location =
                     amd_location_part_override_pkg.getthe_warehouse
             AND amd_utils.ispartrepairableyorn (part_no) = 'Y'
                THEN 0
             ELSE rsp_level
          END quantity,
          'Fixed TSL Load' override_reason,
          TO_CHAR
             (TO_NUMBER
                 (amd_location_part_override_pkg.getfirstlogonidforpart
                                       (amd_utils.getnsisidfrompartno (part_no)
                                       )
                 )
             ) override_user,
          last_update_dt begin_date, NULL end_date, last_update_dt TIMESTAMP
     FROM amd_rsp_sum
    WHERE action_code <> 'D' AND amd_utils.ispartconsumableyorn (part_no) =
                                                                           'N'
   UNION
   SELECT rsp_location LOCATION, part_no,
          amd_lp_override_consumabl_pkg.getroq_type override_type,
          amd_defaults.getroq quantity, 'Fixed TSL Load' override_reason,
          TO_CHAR
             (TO_NUMBER
                 (amd_location_part_override_pkg.getfirstlogonidforpart
                                       (amd_utils.getnsisidfrompartno (part_no)
                                       )
                 )
             ) override_user,
          last_update_dt begin_date, NULL end_date, last_update_dt TIMESTAMP
     FROM amd_rsp_sum
    WHERE action_code <> 'D' AND amd_utils.ispartconsumableyorn (part_no) =
                                                                           'N'
   UNION
   SELECT spo_location, part_no, tsl_override_type, tsl_override_qty,
          'Fixed TSL Load' override_reason,
          TO_CHAR (TO_NUMBER (tsl_override_user)), last_update_dt begin_date,
          NULL end_date, last_update_dt TIMESTAMP
     FROM amd_locpart_overid_consumables
    WHERE action_code <> 'D';


DROP PUBLIC SYNONYM X_LP_OVERRIDE_V;

CREATE PUBLIC SYNONYM X_LP_OVERRIDE_V FOR AMD_OWNER.X_LP_OVERRIDE_V;


GRANT SELECT ON AMD_OWNER.X_LP_OVERRIDE_V TO AMD_READER_ROLE;


