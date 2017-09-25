SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_CONFIRMED_REQUEST_LINE_V;

/* Formatted on 2009/07/08 15:42 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.x_confirmed_request_line_v (confirmed_request,
                                                                   line,
                                                                   location,
                                                                   part,
                                                                   proposed_request,
                                                                   request_date,
                                                                   due_date,
                                                                   quantity_ordered,
                                                                   quantity_received,
                                                                   request_status,
                                                                   supplier_location,
                                                                   last_modified,
                                                                   attribute_1,
                                                                   attribute_2,
                                                                   attribute_3,
                                                                   attribute_4,
                                                                   attribute_5,
                                                                   attribute_6,
                                                                   attribute_7,
                                                                   attribute_8,
                                                                   data_source
                                                                  )
as
   select gold_order_number confirmed_request, line,
          amd_utils.getspolocation (loc_sid) location, on_order.part_no part,
          null proposed_request, order_date request_date,
          case
             when sched_receipt_date is not null
                then sched_receipt_date
             else a2a_pkg.getduedate (on_order.part_no, order_date)
          end due_date,
          order_qty quantity, 0 quantity_received, 'O' request_status,
          null supplier_location, on_order.last_update_dt last_modified,
          null attribute_1, null attribute_2, null attribute_3,
          null attribute_4, null attribute_5, null attribute_6,
          null attribute_7, null attribute_8, 'AMD_ON_ORDER' data_source
     from amd_on_order on_order, amd_spare_parts parts, x_confirmed_request_v
    where gold_order_number = name
      and amd_utils.getspolocation (loc_sid) is not null
      and on_order.action_code <> 'D'
      and on_order.part_no = parts.part_no
      and parts.is_spo_part = 'Y'
   union
   select order_no confirmed_request, ROWNUM line,
          amd_utils.getspolocation (loc_sid) location, in_repair.part_no part,
          null proposed_request, repair_date request_date,
          case
             when repair_need_date is not null
                then repair_need_date
             else a2a_pkg.getduedate (in_repair.part_no,
                                      repair_date)
          end due_date,
          repair_qty quantity, 0 quantity_received, 'O' request_status,
          null supplier_location, in_repair.last_update_dt last_modified,
          null attribute_1, null attribute_2, null attribute_3,
          null attribute_4, null attribute_5, null attribute_6,
          null attribute_7, null attribute_8, 'AMD_IN_REPAIR' data_source
     from amd_in_repair in_repair,
          amd_spare_parts parts,
          x_confirmed_request_v
    where order_no = name
      and amd_utils.getspolocation (loc_sid) is not null
      and in_repair.action_code <> 'D'
      and in_repair.part_no = parts.part_no
      and parts.is_spo_part = 'Y'
      and parts.is_repairable = 'Y';


DROP PUBLIC SYNONYM X_CONFIRMED_REQUEST_LINE_V;

CREATE PUBLIC SYNONYM X_CONFIRMED_REQUEST_LINE_V FOR AMD_OWNER.X_CONFIRMED_REQUEST_LINE_V;


GRANT SELECT ON AMD_OWNER.X_CONFIRMED_REQUEST_LINE_V TO AMD_READER_ROLE;

