/*   				
       $Author:   zf297a  $
     $Revision:   1.1  $
         $Date:   16 Jun 2008 12:51:36  $
     $Workfile:   x_lp_backorder_v.sql  $
	  $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Views\x_lp_backorder_v.sql.-arc  $
/*   
/*      Rev 1.1   16 Jun 2008 12:51:36   zf297a
/*   Added checks for if a parts is repairable or consumable and if it is valid for the SPO system.
/*   
/*      Rev 1.0   14 May 2008 15:55:30   zf297a
/*   Initial revision.
*/

SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_BACKORDER_V;

/* Formatted on 2008/06/16 12:50 (Formatter Plus v4.8.8) */
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
    WHERE action_code <> 'D'
      AND amd_utils.getspolocation (loc_sid) IS NOT NULL
      AND (   (    amd_utils.ispartrepairableyorn (spo_prime_part_no) = 'Y'
               AND a2a_pkg.ispartvalidyorn (spo_prime_part_no) = 'Y'
              )
           OR (    amd_utils.ispartconsumableyorn (spo_prime_part_no) = 'Y'
               AND a2a_consumables_pkg.ispartvalidyorn (spo_prime_part_no) =
                                                                           'Y'
              )
          );


DROP PUBLIC SYNONYM X_LP_BACKORDER_V;

CREATE PUBLIC SYNONYM X_LP_BACKORDER_V FOR AMD_OWNER.X_LP_BACKORDER_V;


GRANT SELECT ON AMD_OWNER.X_LP_BACKORDER_V TO AMD_READER_ROLE;


