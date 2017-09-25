SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_LP_DEMAND_FORECAST_V;

/* Formatted on 2008/10/03 11:35 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.spo_lp_demand_forecast_v (LOCATION,
                                                                 part,
                                                                 demand_forecast_type,
                                                                 period,
                                                                 quantity,
                                                                 TIMESTAMP
                                                                )
AS
   SELECT "LOCATION", "PART", "DEMAND_FORECAST_TYPE", "PERIOD", "QUANTITY",
          "TIMESTAMP"
     FROM spoc17v2.v_lp_demand_forecast@stl_escm_link;


DROP PUBLIC SYNONYM SPO_LP_DEMAND_FORECAST_V;

CREATE PUBLIC SYNONYM SPO_LP_DEMAND_FORECAST_V FOR AMD_OWNER.SPO_LP_DEMAND_FORECAST_V;


GRANT SELECT ON AMD_OWNER.SPO_LP_DEMAND_FORECAST_V TO AMD_READER_ROLE;


