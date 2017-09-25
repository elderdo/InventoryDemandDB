SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_PREFERRED_V;

/* Formatted on 2008/08/13 18:42 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.amd_preferred_v (part_no,
                                                        part_last_update_dt,
                                                        add_increment,
                                                        amc_base_stock,
                                                        amc_days_expericence,
                                                        amc_demand,
                                                        capability_requirement,
                                                        condemn_avg,
                                                        cost_to_repair_off_base,
                                                        criticality,
                                                        current_backorder,
                                                        dla_demand,
                                                        fedc_cost,
                                                        item_type,
                                                        mic_code_lowest,
                                                        mtbdr,
                                                        nomenclature,
                                                        nrts_avg,
                                                        order_lead_time,
                                                        order_uom,
                                                        planner_code,
                                                        rts_avg,
                                                        ru_ind,
                                                        smr_code,
                                                        unit_cost,
                                                        prime_part_no,
                                                        stk_item_last_update_dt
                                                       )
AS
   SELECT part_no, parts.last_update_dt part_last_update_dt,
          amd_preferred_pkg.getpreferredvalue
                                  (items.add_increment_cleaned,
                                   add_increment
                                  ) add_increment,
          amd_preferred_pkg.getpreferredvalue
                                (items.amc_base_stock_cleaned,
                                 amc_base_stock
                                ) amc_base_stock,
          amd_preferred_pkg.getpreferredvalue
                      (items.amc_days_experience_cleaned,
                       amc_days_experience
                      ) amc_days_experience,
          amd_preferred_pkg.getpreferredvalue
                                        (items.amc_demand_cleaned,
                                         amc_demand
                                        ) amc_demand,
          amd_preferred_pkg.getpreferredvalue
                (items.capability_requirement_cleaned,
                 capability_requirement
                ) capability_requirement,
          amd_preferred_pkg.getpreferredvalue
                                      (items.condemn_avg_cleaned,
                                       condemn_avg
                                      ) condemn_avg,
          amd_preferred_pkg.getpreferredvalue
               (items.cost_to_repair_off_base_cleand,
                cost_to_repair_off_base
               ) cost_to_repair_off_base,
          amd_preferred_pkg.getpreferredvalue
                                      (items.criticality_cleaned,
                                       criticality
                                      ) criticality,
          amd_preferred_pkg.getpreferredvalue
                          (items.current_backorder_cleaned,
                           current_backorder
                          ) current_backorder,
          amd_preferred_pkg.getpreferredvalue
                                        (items.dla_demand_cleaned,
                                         dla_demand
                                        ) dla_demand,
          amd_preferred_pkg.getpreferredvalue
                                          (items.fedc_cost_cleaned,
                                           fedc_cost
                                          ) fedc_cost,
          amd_preferred_pkg.getpreferredvalue
                                          (items.item_type_cleaned,
                                           item_type
                                          ) item_type,
          amd_preferred_pkg.getpreferredvalue
                              (items.mic_code_lowest_cleaned,
                               mic_code_lowest
                              ) mic_code_lowest,
          amd_preferred_pkg.getpreferredvalue (items.mtbdr_cleaned,
                                               items.mtbdr_computed,
                                               items.mtbdr
                                              ) mtbdr,
          amd_preferred_pkg.getpreferredvalue
                                    (items.nomenclature_cleaned,
                                     parts.nomenclature
                                    ) nomenclature,
          amd_preferred_pkg.getpreferredvalue
                                           (items.nrts_avg_cleaned,
                                            items.nrts_avg,
                                            items.nrts_avg_defaulted
                                           ) nrts_avg,
          amd_preferred_pkg.getpreferredvalue
                             (items.order_lead_time_cleaned,
                              parts.order_lead_time,
                              parts.order_lead_time_defaulted
                             ) order_lead_time,
          amd_preferred_pkg.getpreferredvalue
                                         (items.order_uom_cleaned,
                                          parts.order_uom,
                                          parts.order_uom_defaulted
                                         ) order_uom,
          amd_preferred_pkg.getpreferredvalue
                         (items.planner_code_cleaned,
                          items.planner_code,
                          amd_defaults.getplannercode (parts.nsn)
                         ) planner_code,
          amd_preferred_pkg.getpreferredvalue (items.rts_avg_cleaned,
                                               items.rts_avg
                                              ) rts_avg,
          amd_preferred_pkg.getpreferredvalue (items.ru_ind_cleaned,
                                               items.ru_ind
                                              ) ru_ind,
          amd_preferred_pkg.getpreferredvalue
                                            (items.smr_code_cleaned,
                                             items.smr_code
                                            ) smr_code,
          amd_preferred_pkg.getpreferredvalue
                                         (items.unit_cost_cleaned,
                                          parts.unit_cost,
                                          parts.unit_cost_defaulted
                                         ) unit_cost,
          prime_part_no, items.last_update_dt item_last_update_dt
     FROM amd_national_stock_items items, amd_spare_parts parts
    WHERE parts.nsn = items.nsn
      AND parts.action_code <> 'D'
      AND items.action_code <> 'D';


DROP PUBLIC SYNONYM AMD_PREFERRED_V;

CREATE PUBLIC SYNONYM AMD_PREFERRED_V FOR AMD_OWNER.AMD_PREFERRED_V;


GRANT SELECT ON AMD_OWNER.AMD_PREFERRED_V TO AMD_READER_ROLE;


