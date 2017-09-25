SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_LP_DEMAND_V;

/* Formatted on 2008/08/14 12:52 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.spo_lp_demand_v (transaction_id,
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
   SELECT "TRANSACTION_ID", "LOCATION", "PART", "CONTRACT", "DEMAND_TYPE",
          "DEMAND_DATE", "CUSTOMER_LOCATION", "PRODUCT_SERIAL_NUMBER",
          "QUANTITY", "TIMESTAMP"
     FROM spoc17v2.v_lp_demand@stl_escm_link;


DROP PUBLIC SYNONYM SPO_LP_DEMAND_V;

CREATE PUBLIC SYNONYM SPO_LP_DEMAND_V FOR AMD_OWNER.SPO_LP_DEMAND_V;


GRANT SELECT ON AMD_OWNER.SPO_LP_DEMAND_V TO AMD_READER_ROLE;


