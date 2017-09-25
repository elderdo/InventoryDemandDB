SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_DEMAND_FORECAST_V;

/* Formatted on 2009/02/06 12:12 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.x_lp_demand_forecast_v (location,
                                                               part,
                                                               demand_forecast_type,
                                                               period,
                                                               period_year,
                                                               quantity,
                                                               part_type,
                                                               timestamp
                                                              )
as
   select spo_location location, parts.spo_prime_part_no part,
          'External' demand_forecast_type,
          amd_demand.getcalendardate
                                  (amd_demand.getfiscalperiod (SYSDATE)
                                  ) period,
          amd_demand.getfiscalperiod (SYSDATE) period_year,
          dmnd.demand_forecast quantity, 'Consumable' part_type,
          dmnd.last_update_dt timestamp
     from amd_dmnd_frcst_consumables dmnd,
          amd_owner.amd_national_stock_items items,
          amd_spare_parts parts,
          amd_spare_networks ntwks
    where dmnd.action_code <> 'D'
      and dmnd.nsn = items.nsn
      and items.prime_part_no = parts.part_no
      and parts.is_spo_part = 'Y'
      and parts.part_no = parts.spo_prime_part_no
      and parts.is_consumable = 'Y'
      and parts.spo_prime_part_no is not null
      and dmnd.sran = ntwks.loc_id
      and dmnd.period = amd_demand.getfiscalperiod (SYSDATE)
   union
   select spo_location location, parts.spo_prime_part_no part,
          'External' demand_forecast_type,
          ADD_MONTHS
             (amd_demand.getcalendardate (amd_demand.getfiscalperiod (SYSDATE)),
              1
             ) period,
          amd_demand.getfiscalperiod (SYSDATE) period_year,
          dmnd.demand_forecast quantity, 'Consumable' part_type,
          dmnd.last_update_dt timestamp
     from amd_dmnd_frcst_consumables dmnd,
          amd_owner.amd_national_stock_items items,
          amd_spare_parts parts,
          amd_spare_networks ntwks
    where dmnd.action_code <> 'D'
      and dmnd.nsn = items.nsn
      and items.prime_part_no = parts.part_no
      and parts.is_spo_part = 'Y'
      and parts.part_no = parts.spo_prime_part_no
      and parts.is_consumable = 'Y'
      and parts.spo_prime_part_no is not null
      and dmnd.sran = ntwks.loc_id
      and dmnd.period = amd_demand.getfiscalperiod (SYSDATE)
   union
   select amd_utils.getspolocation (frcst.loc_sid) location,
          frcst.part_no part, 'External' demand_forecast_type,
          amd_demand.getcalendardate
                                  (amd_demand.getfiscalperiod (SYSDATE)
                                  ) period,
          amd_demand.getfiscalperiod (SYSDATE) period_year,
          frcst.forecast_qty quantity, 'Repairable' part_type,
          frcst.last_update_dt timestamp
     from amd_part_loc_forecasts frcst, amd_spare_parts parts
    where frcst.action_code <> 'D'
      and frcst.part_no = parts.part_no
      and parts.is_spo_part = 'Y'
      and parts.part_no = parts.spo_prime_part_no
      and parts.is_repairable = 'Y'
      and parts.spo_prime_part_no is not null
   union
   select amd_utils.getspolocation (frcst.loc_sid) location,
          frcst.part_no part, 'External' demand_forecast_type,
          ADD_MONTHS
             (amd_demand.getcalendardate (amd_demand.getfiscalperiod (SYSDATE)),
              1
             ) period,
          amd_demand.getfiscalperiod (SYSDATE) current_period_year,
          frcst.forecast_qty quantity, 'Repairable' part_type,
          frcst.last_update_dt timestamp
     from amd_part_loc_forecasts frcst, amd_spare_parts parts
    where frcst.action_code <> 'D'
      and frcst.part_no = parts.part_no
      and parts.is_spo_part = 'Y'
      and parts.part_no = parts.spo_prime_part_no
      and parts.is_repairable = 'Y'
      and parts.spo_prime_part_no is not null;


DROP PUBLIC SYNONYM X_LP_DEMAND_FORECAST_V;

CREATE PUBLIC SYNONYM X_LP_DEMAND_FORECAST_V FOR AMD_OWNER.X_LP_DEMAND_FORECAST_V;


GRANT SELECT ON AMD_OWNER.X_LP_DEMAND_FORECAST_V TO AMD_READER_ROLE;


