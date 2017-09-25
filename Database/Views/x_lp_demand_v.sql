SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_DEMAND_V;

/* Formatted on 2008/11/14 11:06 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_lp_demand_v (transaction_id,
                                                      LOCATION,
                                                      part,
                                                      contract,
                                                      demand_type,
                                                      demand_date,
                                                      customer_location,
                                                      product_serial_number,
                                                      quantity,
                                                      TIMESTAMP
                                                     )
AS
   SELECT doc_no transaction_id, amd_utils.getspolocation (loc_sid) LOCATION,
          parts.spo_prime_part_no part, 'C17' contract, 'General' demand_type,
          doc_date demand_date, NULL customoer_location,
          NULL product_serial_number, quantity, dmnd.last_update_dt TIMESTAMP
     FROM amd_demands dmnd,
          amd_national_stock_items items,
          amd_spare_parts parts
    WHERE dmnd.action_code <> 'D'
      AND dmnd.nsi_sid = items.nsi_sid
      AND items.prime_part_no = parts.part_no
      AND parts.is_spo_part = 'Y';


DROP PUBLIC SYNONYM X_LP_DEMAND_V;

CREATE PUBLIC SYNONYM X_LP_DEMAND_V FOR AMD_OWNER.X_LP_DEMAND_V;


GRANT SELECT ON AMD_OWNER.X_LP_DEMAND_V TO AMD_READER_ROLE;


