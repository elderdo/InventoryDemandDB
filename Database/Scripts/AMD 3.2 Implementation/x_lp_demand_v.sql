SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_DEMAND_V;

/* Formatted on 2008/09/24 15:32 (Formatter Plus v4.8.8) */
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
   SELECT doc_no transaction_id, loc_sid LOCATION, prime_part_no part,
          1001 contract, 1001 demand_type, doc_date demand_date, NULL, NULL,
          quantity, ad.last_update_dt TIMESTAMP
     FROM amd_demands ad, amd_national_stock_items ansi
    WHERE ad.nsi_sid = ansi.nsi_sid
      AND ansi.action_code <> 'D'
      AND ad.action_code <> 'D';


DROP PUBLIC SYNONYM X_LP_DEMAND_V;

CREATE PUBLIC SYNONYM X_LP_DEMAND_V FOR AMD_OWNER.X_LP_DEMAND_V;


GRANT SELECT ON AMD_OWNER.X_LP_DEMAND_V TO AMD_READER_ROLE;


