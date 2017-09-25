SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_DEMAND_FORECAST_V;

/* Formatted on 2008/11/13 12:29 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_lp_demand_forecast_v (LOCATION,
                                                               part,
                                                               demand_forecast_type,
                                                               period,
                                                               period_year,
                                                               quantity,
                                                               part_type,
                                                               TIMESTAMP
                                                              )
AS
   SELECT spo_location LOCATION, parts.spo_prime_part_no part,
          'External' demand_forecast_type,
          amd_demand.getcalendardate
                                  (amd_demand.getfiscalperiod (SYSDATE)
                                  ) period,
          amd_demand.getfiscalperiod (SYSDATE) period_year,
          dmnd.demand_forecast quantity, 'Consumable' part_type,
          dmnd.last_update_dt TIMESTAMP
     FROM amd_dmnd_frcst_consumables dmnd,
          amd_owner.amd_national_stock_items items,
          amd_spare_parts parts,
          amd_spare_networks ntwks
    WHERE dmnd.action_code <> 'D'
      AND dmnd.nsn = items.nsn
      AND items.prime_part_no = parts.part_no
      AND parts.is_spo_part = 'Y'
      AND parts.is_consumable = 'Y'
      AND parts.spo_prime_part_no IS NOT NULL
      AND dmnd.sran = ntwks.loc_id
      AND dmnd.period = amd_demand.getfiscalperiod (SYSDATE)
   UNION
   SELECT spo_location LOCATION, parts.spo_prime_part_no part,
          'External' demand_forecast_type,
          ADD_MONTHS
             (amd_demand.getcalendardate (amd_demand.getfiscalperiod (SYSDATE)),
              1
             ) period,
          amd_demand.getfiscalperiod (SYSDATE) period_year,
          dmnd.demand_forecast quantity, 'Consumable' part_type,
          dmnd.last_update_dt TIMESTAMP
     FROM amd_dmnd_frcst_consumables dmnd,
          amd_owner.amd_national_stock_items items,
          amd_spare_parts parts,
          amd_spare_networks ntwks
    WHERE dmnd.action_code <> 'D'
      AND dmnd.nsn = items.nsn
      AND items.prime_part_no = parts.part_no
      AND parts.is_spo_part = 'Y'
      AND parts.is_consumable = 'Y'
      AND parts.spo_prime_part_no IS NOT NULL
      AND dmnd.sran = ntwks.loc_id
      AND dmnd.period = amd_demand.getfiscalperiod (SYSDATE)
   UNION
   SELECT amd_utils.getspolocation (frcst.loc_sid) LOCATION,
          frcst.part_no part, 'External' demand_forecast_type,
          amd_demand.getcalendardate
                                  (amd_demand.getfiscalperiod (SYSDATE)
                                  ) period,
          amd_demand.getfiscalperiod (SYSDATE) period_year,
          frcst.forecast_qty quantity, 'Repairable' part_type,
          frcst.last_update_dt TIMESTAMP
     FROM amd_part_loc_forecasts frcst, amd_spare_parts parts
    WHERE frcst.action_code <> 'D'
      AND frcst.part_no = parts.part_no
      AND parts.is_spo_part = 'Y'
      AND parts.is_repairable = 'Y'
      AND parts.spo_prime_part_no IS NOT NULL
      AND amd_demand.getfiscalperiod (frcst.last_update_dt) =
                                          amd_demand.getfiscalperiod (SYSDATE)
   UNION
   SELECT amd_utils.getspolocation (frcst.loc_sid) LOCATION,
          frcst.part_no part, 'External' demand_forecast_type,
          ADD_MONTHS
             (amd_demand.getcalendardate (amd_demand.getfiscalperiod (SYSDATE)),
              1
             ) period,
          amd_demand.getfiscalperiod (SYSDATE) current_period_year,
          frcst.forecast_qty quantity, 'Repairable' part_type,
          frcst.last_update_dt TIMESTAMP
     FROM amd_part_loc_forecasts frcst, amd_spare_parts parts
    WHERE frcst.action_code <> 'D'
      AND frcst.part_no = parts.part_no
      AND parts.is_spo_part = 'Y'
      AND parts.is_repairable = 'Y'
      AND parts.spo_prime_part_no IS NOT NULL
      AND amd_demand.getfiscalperiod (frcst.last_update_dt) =
                                          amd_demand.getfiscalperiod (SYSDATE);


DROP PUBLIC SYNONYM X_LP_DEMAND_FORECAST_V;

CREATE PUBLIC SYNONYM X_LP_DEMAND_FORECAST_V FOR AMD_OWNER.X_LP_DEMAND_FORECAST_V;


GRANT SELECT ON AMD_OWNER.X_LP_DEMAND_FORECAST_V TO AMD_READER_ROLE;


