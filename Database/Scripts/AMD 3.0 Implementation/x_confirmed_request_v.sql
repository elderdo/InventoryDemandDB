/*
	$Author:   zf297a  $
      $Revision:   1.1  $
          $Date:   16 Jun 2008 12:48:40  $
      $Workfile:   x_confirmed_request_v.sql  $
           $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Views\x_confirmed_request_v.sql.-arc  $
/*   
/*      Rev 1.1   16 Jun 2008 12:48:40   zf297a
/*   Added checks for if a parts is repairable or consumable and if it is valid for the SPO system.
/*   
/*      Rev 1.0   14 May 2008 15:55:30   zf297a
/*   Initial revision.
*/

SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_CONFIRMED_REQUEST_V;

/* Formatted on 2008/06/16 12:43 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_confirmed_request_v (NAME,
                                                              request_type,
                                                              TIMESTAMP
                                                             )
AS
   SELECT order_no NAME, 'REPAIR' request_type, last_update_dt TIMESTAMP
     FROM amd_in_repair
    WHERE action_code <> 'D'
      AND (   (    amd_utils.ispartrepairableyorn (part_no) = 'Y'
               AND a2a_pkg.ispartvalidyorn (part_no) = 'Y'
              )
           OR (    amd_utils.ispartconsumableyorn (part_no) = 'Y'
               AND a2a_consumables_pkg.ispartvalidyorn (part_no) = 'Y'
              )
          )
   UNION
   SELECT gold_order_number NAME, 'NEW-BUY', last_update_dt TIMESTAMP
     FROM amd_on_order
    WHERE action_code <> 'D'
      AND (   (    amd_utils.ispartrepairableyorn (part_no) = 'Y'
               AND a2a_pkg.ispartvalidyorn (part_no) = 'Y'
              )
           OR (    amd_utils.ispartconsumableyorn (part_no) = 'Y'
               AND a2a_consumables_pkg.ispartvalidyorn (part_no) = 'Y'
              )
          );


DROP PUBLIC SYNONYM X_CONFIRMED_REQUEST_V;

CREATE PUBLIC SYNONYM X_CONFIRMED_REQUEST_V FOR AMD_OWNER.X_CONFIRMED_REQUEST_V;


GRANT SELECT ON AMD_OWNER.X_CONFIRMED_REQUEST_V TO AMD_READER_ROLE;


