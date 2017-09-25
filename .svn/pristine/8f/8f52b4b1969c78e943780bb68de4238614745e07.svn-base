SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_CONFIRMED_REQUEST_LINE_V;

/* Formatted on 2008/09/22 23:26 (Formatter Plus v4.8.8) */
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
          amd_utils.getspolocation (loc_sid) LOCATION, on_order.part_no part,
          NULL proposed_request, order_date request_date,
          CASE
             WHEN sched_receipt_date IS NOT NULL
                THEN sched_receipt_date
             ELSE a2a_pkg.getduedate (on_order.part_no, order_date)
          END due_date,
          order_qty quantity, 0 quantity_received, 'O' request_status,
          NULL supplier_location, on_order.last_update_dt TIMESTAMP,
          NULL attribute_1, NULL attribute_2, NULL attribute_3,
          NULL attribute_4, NULL attribute_5, NULL attribute_6,
          NULL attribute_7, NULL attribute_8
     FROM amd_on_order on_order, amd_spare_parts parts
    WHERE amd_utils.getspolocation (loc_sid) IS NOT NULL
      AND on_order.action_code <> 'D'
      AND on_order.part_no = parts.part_no
      AND parts.is_spo_part = 'Y'
   UNION
   SELECT order_no confirmed_request, 1 line,
          amd_utils.getspolocation (loc_sid) LOCATION, in_repair.part_no part,
          NULL proposed_request, repair_date request_date,
          CASE
             WHEN repair_need_date IS NOT NULL
                THEN repair_need_date
             ELSE a2a_pkg.getduedate (in_repair.part_no,
                                      repair_date)
          END due_date,
          repair_qty quantity, 0 quantity_received, 'O' request_status,
          NULL supplier_location, in_repair.last_update_dt TIMESTAMP,
          NULL attribute_1, NULL attribute_2, NULL attribute_3,
          NULL attribute_4, NULL attribute_5, NULL attribute_6,
          NULL attribute_7, NULL attribute_8
     FROM amd_in_repair in_repair, amd_spare_parts parts
    WHERE amd_utils.getspolocation (loc_sid) IS NOT NULL
      AND in_repair.action_code <> 'D'
      AND in_repair.part_no = parts.part_no
      AND parts.is_spo_part = 'Y';


DROP PUBLIC SYNONYM X_CONFIRMED_REQUEST_LINE_V;

CREATE PUBLIC SYNONYM X_CONFIRMED_REQUEST_LINE_V FOR AMD_OWNER.X_CONFIRMED_REQUEST_LINE_V;


GRANT SELECT ON AMD_OWNER.X_CONFIRMED_REQUEST_LINE_V TO AMD_READER_ROLE;


