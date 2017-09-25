/*   				
       $Author:   zf297a  $
     $Revision:   1.1  $
         $Date:   16 Jun 2008 12:54:34  $
     $Workfile:   x_lp_on_hand_v.sql  $
	  $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Views\x_lp_on_hand_v.sql.-arc  $
/*   
/*      Rev 1.1   16 Jun 2008 12:54:34   zf297a
/*   Added checks for if a parts is repairable or consumable and if it is valid for the SPO system.
/*   
/*      Rev 1.0   14 May 2008 15:57:22   zf297a
/*   Initial revision.
*/

SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_ON_HAND_V;

/* Formatted on 2008/06/16 12:53 (Formatter Plus v4.8.8) */
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
      AND (   (    amd_utils.ispartrepairableyorn (part_no) = 'Y'
               AND a2a_pkg.ispartvalidyorn (part_no) = 'Y'
              )
           OR (    amd_utils.ispartconsumableyorn (part_no) = 'Y'
               AND a2a_consumables_pkg.ispartvalidyorn (part_no) = 'Y'
              )
          )
   UNION
   SELECT site_location LOCATION, part_no part, 'Defective' on_hand_type,
          qty_on_hand quantity, last_update_dt TIMESTAMP
     FROM amd_repair_invs_sum
    WHERE action_code <> 'D'
      AND (   (    amd_utils.ispartrepairableyorn (part_no) = 'Y'
               AND a2a_pkg.ispartvalidyorn (part_no) = 'Y'
              )
           OR (    amd_utils.ispartconsumableyorn (part_no) = 'Y'
               AND a2a_consumables_pkg.ispartvalidyorn (part_no) = 'Y'
              )
          );


DROP PUBLIC SYNONYM X_LP_ON_HAND_V;

CREATE PUBLIC SYNONYM X_LP_ON_HAND_V FOR AMD_OWNER.X_LP_ON_HAND_V;


GRANT SELECT ON AMD_OWNER.X_LP_ON_HAND_V TO AMD_READER_ROLE;


