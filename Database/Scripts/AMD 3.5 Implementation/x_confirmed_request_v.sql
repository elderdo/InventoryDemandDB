SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_CONFIRMED_REQUEST_V;

/* Formatted on 2008/11/04 14:00 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_confirmed_request_v (NAME,
                                                              request_type,
                                                              TIMESTAMP
                                                             )
AS
   SELECT order_no NAME, 'REPAIR' request_type,
          in_repair.last_update_dt TIMESTAMP
     FROM amd_in_repair in_repair, amd_spare_parts parts
    WHERE in_repair.action_code <> 'D'
      AND in_repair.part_no = parts.part_no
      AND parts.is_spo_part = 'Y'
      AND amd_utils.getspolocation (loc_sid) IS NOT NULL
   UNION
   SELECT gold_order_number NAME, 'NEW-BUY',
          on_order.last_update_dt TIMESTAMP
     FROM amd_on_order on_order, amd_spare_parts parts
    WHERE on_order.action_code <> 'D'
      AND on_order.part_no = parts.part_no
      AND parts.is_spo_part = 'Y'
      AND amd_utils.getspolocation (loc_sid) IS NOT NULL;


DROP PUBLIC SYNONYM X_CONFIRMED_REQUEST_V;

CREATE PUBLIC SYNONYM X_CONFIRMED_REQUEST_V FOR AMD_OWNER.X_CONFIRMED_REQUEST_V;


GRANT SELECT ON AMD_OWNER.X_CONFIRMED_REQUEST_V TO AMD_READER_ROLE;


