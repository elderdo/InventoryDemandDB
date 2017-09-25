SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_FX_LP_DEMAND_FORECAST_V;

/* Formatted on 2009/07/08 17:15 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_fx_lp_demand_forecast_v (location,
                                                                    part,
                                                                    demand_forecast_type,
                                                                    period,
                                                                    quantity,
                                                                    last_modified
                                                                   )
as
   select "LOCATION", "PART", "DEMAND_FORECAST_TYPE", "PERIOD", "QUANTITY",
          last_modified
     from spoc17v2.v_fx_lp_demand_forecast@stl_escm_link;


DROP PUBLIC SYNONYM SPO_FX_LP_DEMAND_FORECAST_V;

CREATE PUBLIC SYNONYM SPO_FX_LP_DEMAND_FORECAST_V FOR AMD_OWNER.SPO_FX_LP_DEMAND_FORECAST_V;


GRANT SELECT ON AMD_OWNER.SPO_FX_LP_DEMAND_FORECAST_V TO AMD_READER_ROLE;

