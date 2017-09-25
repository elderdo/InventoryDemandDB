SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_CONFIRMED_REQUEST_V;

/* Formatted on 2008/05/16 12:15 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_confirmed_request_v (NAME,
                                                              request_type,
                                                              TIMESTAMP
                                                             )
AS
   SELECT order_no NAME, 'REPAIR' request_type, last_update_dt TIMESTAMP
     FROM amd_in_repair
    WHERE action_code <> 'D'
   UNION
   SELECT gold_order_number NAME, 'NEW-BUY', last_update_dt TIMESTAMP
     FROM amd_on_order
    WHERE action_code <> 'D';


DROP PUBLIC SYNONYM X_CONFIRMED_REQUEST_V;

CREATE PUBLIC SYNONYM X_CONFIRMED_REQUEST_V FOR AMD_OWNER.X_CONFIRMED_REQUEST_V;


GRANT SELECT ON AMD_OWNER.X_CONFIRMED_REQUEST_V TO AMD_READER_ROLE;


