/*
	$Author:   zf297a  $
      $Revision:   1.1  $
          $Date:   16 Jun 2008 12:50:16  $
      $Workfile:   x_confirmed_request_line_v.sql  $
           $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Views\x_confirmed_request_line_v.sql.-arc  $
/*   
/*      Rev 1.1   16 Jun 2008 12:50:16   zf297a
/*   Added checks for if a part is repairable or consumable and if the parts is valid for the SPO system.
/*   
/*      Rev 1.0   14 May 2008 15:55:30   zf297a
/*   Initial revision.
*/

SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_CONFIRMED_REQUEST_LINE_V;

/* Formatted on 2008/06/16 12:48 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_confirmed_request_line_v (confirmed_request,
                                                                   line,
                                                                   LOCATION,
                                                                   part,
                                                                   proposed_request,
                                                                   request_date,
                                                                   due_date,
                                                                   quantity_ordered,
                                                                   quantity_received,
                                                                   request_status,
                                                                   supplier_location,
                                                                   TIMESTAMP,
                                                                   attribute_1,
                                                                   attribute_2,
                                                                   attribute_3,
                                                                   attribute_4,
                                                                   attribute_5,
                                                                   attribute_6,
                                                                   attribute_7,
                                                                   attribute_8
                                                                  )
AS
   SELECT gold_order_number confirmed_request, line,
          amd_utils.getspolocation (loc_sid) LOCATION, part_no part,
          NULL proposed_request, order_date request_date,
          CASE
             WHEN sched_receipt_date IS NOT NULL
                THEN sched_receipt_date
             ELSE a2a_pkg.getduedate (part_no, order_date)
          END due_date,
          order_qty quantity, 0 quantity_received, 'O' request_status,
          NULL supplier_location, last_update_dt TIMESTAMP, NULL attribute_1,
          NULL attribute_2, NULL attribute_3, NULL attribute_4,
          NULL attribute_5, NULL attribute_6, NULL attribute_7,
          NULL attribute_8
     FROM amd_on_order
    WHERE amd_utils.getspolocation (loc_sid) IS NOT NULL
      AND action_code <> 'D'
      AND (   (    amd_utils.ispartrepairableyorn (part_no) = 'Y'
               AND a2a_pkg.ispartvalidyorn (part_no) = 'Y'
              )
           OR (    amd_utils.ispartconsumableyorn (part_no) = 'Y'
               AND a2a_consumables_pkg.ispartvalidyorn (part_no) = 'Y'
              )
          )
   UNION
   SELECT order_no confirmed_request, 1 line,
          amd_utils.getspolocation (loc_sid) LOCATION, part_no part,
          NULL proposed_request, repair_date request_date,
          CASE
             WHEN repair_need_date IS NOT NULL
                THEN repair_need_date
             ELSE a2a_pkg.getduedate (part_no, repair_date)
          END due_date,
          repair_qty quantity, 0 quantity_received, 'O' request_status,
          NULL supplier_location, last_update_dt TIMESTAMP, NULL attribute_1,
          NULL attribute_2, NULL attribute_3, NULL attribute_4,
          NULL attribute_5, NULL attribute_6, NULL attribute_7,
          NULL attribute_8
     FROM amd_in_repair
    WHERE amd_utils.getspolocation (loc_sid) IS NOT NULL
      AND action_code <> 'D'
      AND (   (    amd_utils.ispartrepairableyorn (part_no) = 'Y'
               AND a2a_pkg.ispartvalidyorn (part_no) = 'Y'
              )
           OR (    amd_utils.ispartconsumableyorn (part_no) = 'Y'
               AND a2a_consumables_pkg.ispartvalidyorn (part_no) = 'Y'
              )
          );


DROP PUBLIC SYNONYM X_CONFIRMED_REQUEST_LINE_V;

CREATE PUBLIC SYNONYM X_CONFIRMED_REQUEST_LINE_V FOR AMD_OWNER.X_CONFIRMED_REQUEST_LINE_V;


GRANT SELECT ON AMD_OWNER.X_CONFIRMED_REQUEST_LINE_V TO AMD_READER_ROLE;


