DROP VIEW AMD_OWNER.X_CONFIRMED_REQUEST_LINE_V;

/* Formatted on 7/3/2012 1:47:20 AM (QP5 v5.163.1008.3004) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.X_CONFIRMED_REQUEST_LINE_V
(
   CONFIRMED_REQUEST,
   LINE,
   LOCATION,
   PART,
   PROPOSED_REQUEST,
   REQUEST_DATE,
   DUE_DATE,
   QUANTITY_ORDERED,
   QUANTITY_RECEIVED,
   REQUEST_STATUS,
   SUPPLIER_LOCATION,
   LAST_MODIFIED,
   ATTRIBUTE_1,
   ATTRIBUTE_2,
   ATTRIBUTE_3,
   ATTRIBUTE_4,
   ATTRIBUTE_5,
   ATTRIBUTE_6,
   ATTRIBUTE_7,
   ATTRIBUTE_8,
   DATA_SOURCE
)
AS
   SELECT gold_order_number confirmed_request,
          line,
          amd_utils.getspolocation (loc_sid) location,
          on_order.part_no part,
          NULL proposed_request,
          order_date request_date,
          CASE
             WHEN sched_receipt_date IS NOT NULL THEN sched_receipt_date
             ELSE amd_owner.getduedate (on_order.part_no, order_date)
          END
             due_date,
          order_qty quantity,
          0 quantity_received,
          'O' request_status,
          NULL supplier_location,
          on_order.last_update_dt last_modified,
          NULL attribute_1,
          NULL attribute_2,
          NULL attribute_3,
          NULL attribute_4,
          NULL attribute_5,
          NULL attribute_6,
          NULL attribute_7,
          NULL attribute_8,
          'AMD_ON_ORDER' data_source
     FROM amd_on_order on_order, amd_spare_parts parts, x_confirmed_request_v
    WHERE     gold_order_number = name
          AND amd_utils.getspolocation (loc_sid) IS NOT NULL
          AND on_order.action_code <> 'D'
          AND on_order.part_no = parts.part_no
          AND parts.is_spo_part = 'Y'
   UNION
   SELECT order_no confirmed_request,
          ROWNUM line,
          amd_utils.getspolocation (loc_sid) location,
          in_repair.part_no part,
          NULL proposed_request,
          repair_date request_date,
          CASE
             WHEN repair_need_date IS NOT NULL THEN repair_need_date
             ELSE amd_owner.getduedate (in_repair.part_no, repair_date)
          END
             due_date,
          repair_qty quantity,
          0 quantity_received,
          'O' request_status,
          NULL supplier_location,
          in_repair.last_update_dt last_modified,
          NULL attribute_1,
          NULL attribute_2,
          NULL attribute_3,
          NULL attribute_4,
          NULL attribute_5,
          NULL attribute_6,
          NULL attribute_7,
          NULL attribute_8,
          'AMD_IN_REPAIR' data_source
     FROM amd_in_repair in_repair,
          amd_spare_parts parts,
          x_confirmed_request_v
    WHERE     order_no = name
          AND amd_utils.getspolocation (loc_sid) IS NOT NULL
          AND in_repair.action_code <> 'D'
          AND in_repair.part_no = parts.part_no
          AND parts.is_spo_part = 'Y'
          AND parts.is_repairable = 'Y';


DROP PUBLIC SYNONYM X_CONFIRMED_REQUEST_LINE_V;

CREATE OR REPLACE PUBLIC SYNONYM X_CONFIRMED_REQUEST_LINE_V FOR AMD_OWNER.X_CONFIRMED_REQUEST_LINE_V;


GRANT SELECT ON AMD_OWNER.X_CONFIRMED_REQUEST_LINE_V TO AMD_READER_ROLE;

