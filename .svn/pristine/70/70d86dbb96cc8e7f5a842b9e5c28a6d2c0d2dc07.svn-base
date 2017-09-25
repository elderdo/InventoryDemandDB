SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_DEMAND_FORECAST_V;

/* Formatted on 2009/05/11 14:15 (Formatter Plus v4.8.8) */
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
          'External' demand_forecast_type, begin_date period,
          calendar_year_number period_year, dmnd.demand_forecast quantity,
          'Consumable' part_type, dmnd.last_update_dt timestamp
     from amd_dmnd_frcst_consumables dmnd,
          amd_owner.amd_national_stock_items items,
          amd_spare_parts parts,
          amd_spare_networks ntwks,
          amd_current_period_v
    where dmnd.action_code <> 'D'
      and dmnd.nsn = items.nsn
      and items.prime_part_no = parts.part_no
      and parts.is_spo_part = 'Y'
      and parts.part_no = parts.spo_prime_part_no
      and parts.is_consumable = 'Y'
      and parts.spo_prime_part_no is not null
      and dmnd.sran = ntwks.loc_id
      and dmnd.period = calendar_year_number
   union
   select spo_location location, parts.spo_prime_part_no part,
          'External' demand_forecast_type, spo_period_v.begin_date period,
          spo_period_v.calendar_year_number period_year,
          dmnd.demand_forecast quantity, 'Consumable' part_type,
          dmnd.last_update_dt timestamp
     from amd_dmnd_frcst_consumables dmnd,
          amd_owner.amd_national_stock_items items,
          amd_spare_parts parts,
          amd_spare_networks ntwks,
          spo_period_v,
          amd_current_period_v
    where dmnd.action_code <> 'D'
      and dmnd.nsn = items.nsn
      and items.prime_part_no = parts.part_no
      and parts.is_spo_part = 'Y'
      and parts.part_no = parts.spo_prime_part_no
      and parts.is_consumable = 'Y'
      and parts.spo_prime_part_no is not null
      and dmnd.sran = ntwks.loc_id
      and spo_period_v.id = amd_current_period_v.id + 1
   union
   select amd_utils.getspolocation (frcst.loc_sid) location,
          frcst.part_no part, 'External' demand_forecast_type,
          begin_date period, calendar_year_number period_year,
          frcst.forecast_qty quantity, 'Repairable' part_type,
          frcst.last_update_dt timestamp
     from amd_part_loc_forecasts frcst,
          amd_spare_parts parts,
          amd_current_period_v
    where frcst.action_code <> 'D'
      and frcst.part_no = parts.part_no
      and parts.is_spo_part = 'Y'
      and parts.part_no = parts.spo_prime_part_no
      and parts.is_repairable = 'Y'
      and parts.spo_prime_part_no is not null
   union
   select amd_utils.getspolocation (frcst.loc_sid) location,
          frcst.part_no part, 'External' demand_forecast_type,
          spo_period_v.begin_date period,
          spo_period_v.calendar_year_number current_period_year,
          frcst.forecast_qty quantity, 'Repairable' part_type,
          frcst.last_update_dt timestamp
     from amd_part_loc_forecasts frcst,
          amd_spare_parts parts,
          spo_period_v,
          amd_current_period_v
    where frcst.action_code <> 'D'
      and frcst.part_no = parts.part_no
      and parts.is_spo_part = 'Y'
      and parts.part_no = parts.spo_prime_part_no
      and parts.is_repairable = 'Y'
      and parts.spo_prime_part_no is not null
      and spo_period_v.id = amd_current_period_v.id + 1;


DROP PUBLIC SYNONYM X_LP_DEMAND_FORECAST_V;

CREATE PUBLIC SYNONYM X_LP_DEMAND_FORECAST_V FOR AMD_OWNER.X_LP_DEMAND_FORECAST_V;


GRANT SELECT ON AMD_OWNER.X_LP_DEMAND_FORECAST_V TO AMD_READER_ROLE;


