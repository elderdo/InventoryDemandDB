/*
	$Author:   zf297a  $
      $Revision:   1.1  $
          $Date:   16 Jun 2008 12:53:18  $
      $Workfile:   x_lp_in_transit_v.sql  $
           $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Views\x_lp_in_transit_v.sql.-arc  $
/*   
/*      Rev 1.1   16 Jun 2008 12:53:18   zf297a
/*   Added checks for if a parts is repairable or consumable and if it is valid for the SPO system.
*/

SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_IN_TRANSIT_V;

/* Formatted on 2008/06/16 12:51 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_lp_in_transit_v (LOCATION,
                                                          part,
                                                          in_transit_type,
                                                          quantity,
                                                          TIMESTAMP
                                                         )
AS
   SELECT site_location LOCATION, part_no part,
          DECODE (serviceable_flag,
                  'Y', 'General',
                  'N', 'Defective',
                  serviceable_flag
                 ) in_transit_type,
          quantity, last_update_dt TIMESTAMP
     FROM amd_in_transits_sum
    WHERE action_code <> 'D'
      AND (   (    amd_utils.ispartrepairableyorn (part_no) = 'Y'
               AND a2a_pkg.ispartvalidyorn (part_no) = 'Y'
              )
           OR (    amd_utils.ispartconsumableyorn (part_no) = 'Y'
               AND a2a_consumables_pkg.ispartvalidyorn (part_no) = 'Y'
              )
          );


DROP PUBLIC SYNONYM X_LP_IN_TRANSIT_V;

CREATE PUBLIC SYNONYM X_LP_IN_TRANSIT_V FOR AMD_OWNER.X_LP_IN_TRANSIT_V;


GRANT SELECT ON AMD_OWNER.X_LP_IN_TRANSIT_V TO AMD_READER_ROLE;


