SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_PART_V;

/* Formatted on 2009/09/17 15:56 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.x_part_v (name,
                                                 part_type,
                                                 description,
                                                 cost,
                                                 begin_date,
                                                 end_date,
                                                 holding_cost_rate,
                                                 fixed_order_cost,
                                                 is_order_policy_roq_based,
                                                 is_reparable,
                                                 repair_cost,
                                                 decay_rate,
                                                 generate_new_buy,
                                                 generate_repair,
                                                 generate_allocation,
                                                 generate_transshipment,
                                                 max_qty_allowance,
                                                 max_total_tsl,
                                                 last_modified,
                                                 is_planned,
                                                 attribute_1,
                                                 attribute_2,
                                                 attribute_3,
                                                 attribute_4,
                                                 attribute_5,
                                                 attribute_6,
                                                 attribute_7,
                                                 attribute_8,
                                                 attribute_9,
                                                 attribute_10,
                                                 attribute_11,
                                                 attribute_12,
                                                 attribute_13,
                                                 attribute_14,
                                                 attribute_15,
                                                 attribute_16,
                                                 attribute_17,
                                                 attribute_18,
                                                 attribute_19,
                                                 attribute_20,
                                                 attribute_21,
                                                 attribute_22,
                                                 attribute_23,
                                                 attribute_24,
                                                 attribute_25,
                                                 attribute_26,
                                                 attribute_27,
                                                 attribute_28,
                                                 attribute_29,
                                                 attribute_30,
                                                 attribute_31,
                                                 attribute_32,
                                                 material_class,
                                                 weight,
                                                 volume,
                                                 is_exempt,
                                                 ignore_weight_and_volume,
                                                 is_seasonal,
                                                 is_cannibalizable,
                                                 partial_one_way_supersession,
                                                 is_new,
                                                 like_part,
                                                 new_buy_lead_time,
                                                 repair_lead_time,
                                                 new_buy_lead_time_variance,
                                                 repair_lead_time_variance,
                                                 forecast_risk_multiplier
                                                )
as
   select parts.part_no name, 'AIRPLANE' as part_type, parts.nomenclature,
          NVL (pref.unit_cost, 0) unit_cost, nsi.assignment_date begin_date,
          null end_date, null holding_cost_rate, null fixed_order_cost,
          case
             when parts.is_repairable = 'Y'
                then 'F'
             else 'T'
          end is_order_policy_roq_based,
          case
             when parts.is_repairable = 'Y'
                then 'T'
             else 'F'
          end is_reparable, null repair_cost, 0 decay_rate,
          'T' generate_new_buy, 'F' generate_repair, 'T' generate_allocation,
          'T' generate_transshipment, null max_qty_allowance,
          null max_total_tsl, parts.last_update_dt last_modified,
          'T' is_planned, null attribute_1, null attribute_2,
          null attribute_3, null attribute_4, null attribute_5,
          null attribute_6, null attribute_7, null attribute_8,
          null attribute_9, pref.smr_code attribute_10,
          items.nsn attribute_11, pref.criticality attribute_12,
          null attribute_13, pref.planner_code attribute_14,
          null attribute_15, null attribute_16, null attribute_17,
          null attribute_18, parts.mfgr attribute_19,
          case
             when parts.is_repairable = 'N'
                then 'F'
             when parts.is_repairable = 'Y'
                then 'T'
             else null
          end attribute_20,
          null attribute_21, null attribute_22, null attribute_23,
          null attribute_24, null attribute_25, null attribute_26,
          null attribute_27, parts.spo_prime_part_no attribute_28,
          case
             when items.wesm_indicator is null
                then null
             else 'WESM Part'
          end attribute_29,
          case
             when bsi.nsn is null
                then null
             else 'Bench Stock Item'
          end attribute_30, null attribute_31, null attribute_32,
          null material_class, null weight, null volume, 'T' is_exempt,
          'T' ignore_weight_and_volume, 'F' is_seasonal,
          'F' is_cannibalizable, 'F' partial_one_way_supersession,
          case
             when parts.action_code = 'A'
             and items.action_code = 'A'
             and TRUNC (parts.last_update_dt) = TRUNC (SYSDATE)
                then 'T'
             else 'F'
          end is_new,
          null like_part, pref.order_lead_time new_buy_lead_time,
          pref.time_to_repair_off_base repair_lead_time,
          0 new_buy_lead_time_variance, 0 repair_lead_time_variance,
          1 forecast_risk_factor
     from amd_spare_parts parts,
          amd_national_stock_items items,
          amd_bench_stock_items_v bsi,
          amd_nsi_parts nsi,
          amd_preferred_v pref
    where parts.nsn = items.nsn
      and (parts.action_code <> 'D' and items.action_code <> 'D')
      and parts.is_spo_part = 'Y'
      and items.nsn = bsi.nsn(+)
      and parts.part_no = nsi.part_no
      and parts.part_no = pref.part_no
      and nsi.unassignment_date is null;


DROP PUBLIC SYNONYM X_PART_V;

CREATE PUBLIC SYNONYM X_PART_V FOR AMD_OWNER.X_PART_V;


GRANT SELECT ON AMD_OWNER.X_PART_V TO AMD_READER_ROLE;

