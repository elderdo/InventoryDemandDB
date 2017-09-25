SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_CONFIRMED_REQUEST_V;

/* Formatted on 2009/06/09 14:22 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.x_confirmed_request_v (name,
                                                              request_type,
                                                              timestamp
                                                             )
as
   select order_no name, repair_request request_type,
          in_repair.last_update_dt timestamp
     from amd_in_repair in_repair, amd_spare_parts parts, amd_spo_types_v
    where in_repair.action_code <> 'D'
      and in_repair.part_no = parts.part_no
      and parts.is_spo_part = 'Y'
      and parts.is_repairable = 'Y'
      and amd_utils.getspolocation (loc_sid) is not null
      and in_repair.last_update_dt =
             (select max (last_update_dt)
                from amd_in_repair r
               where r.order_no = in_repair.order_no and r.action_code <> 'D')
   union
   select gold_order_number name, new_buy_request request_type,
          on_order.last_update_dt timestamp
     from amd_on_order on_order, amd_spare_parts parts, amd_spo_types_v
    where on_order.action_code <> 'D'
      and on_order.part_no = parts.part_no
      and parts.is_spo_part = 'Y'
      and amd_utils.getspolocation (loc_sid) is not null
      and on_order.last_update_dt =
             (select max (last_update_dt)
                from amd_on_order o
               where o.gold_order_number = on_order.gold_order_number
                 and o.action_code <> 'D');


DROP PUBLIC SYNONYM X_CONFIRMED_REQUEST_V;

CREATE PUBLIC SYNONYM X_CONFIRMED_REQUEST_V FOR AMD_OWNER.X_CONFIRMED_REQUEST_V;


GRANT SELECT ON AMD_OWNER.X_CONFIRMED_REQUEST_V TO AMD_READER_ROLE;

