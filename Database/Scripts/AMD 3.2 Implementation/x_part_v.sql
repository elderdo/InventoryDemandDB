SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_PART_V;

/* Formatted on 2008/09/22 21:14 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_part_v (NAME,
                                                 part_type,
                                                 description,
                                                 COST,
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
                                                 TIMESTAMP,
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
                                                 partial_one_way_supersession
                                                )
AS
   SELECT parts.part_no NAME, 'AIRPLANE' AS part_type, parts.nomenclature,
          CASE
             WHEN unit_cost_cleaned IS NOT NULL
                THEN unit_cost_cleaned
             WHEN unit_cost IS NOT NULL
                THEN unit_cost
             ELSE 0
          END unit_cost,
          nsi.assignment_date begin_date, NULL end_date,
          NULL holding_cost_rate, NULL fixed_order_cost,
          CASE
             WHEN SUBSTR
                    (CASE
                        WHEN smr_code_cleaned IS NOT NULL
                           THEN smr_code_cleaned
                        ELSE smr_code
                     END,
                     6,
                     1
                    ) = 'T'
                THEN 'F'
             ELSE 'T'
          END is_order_policy_roq_based,
          CASE
             WHEN amd_utils.isrepairablesmrcodeyorn
                    (CASE
                        WHEN smr_code_cleaned IS NOT NULL
                           THEN smr_code_cleaned
                        ELSE smr_code
                     END
                    ) = 'Y'
                THEN 'T'
             ELSE 'F'
          END is_reparable,
          NULL repair_cost, 0 decay_rate, 'T' generate_new_buy,
          'F' generate_repair, 'T' generate_allocation,
          'T' generate_transshipment, NULL max_qty_allowance,
          NULL max_total_tsl, parts.last_update_dt TIMESTAMP, 'T' is_planned,
          NULL attribute_1, NULL attribute_2, NULL attribute_3,
          NULL attribute_4, NULL attribute_5, NULL attribute_6,
          NULL attribute_7, NULL attribute_8, NULL attribute_9,
          CASE
             WHEN smr_code_cleaned IS NOT NULL
                THEN smr_code_cleaned
             ELSE smr_code
          END attribute_10,
          items.nsn attribute_11, NULL attribute_12, NULL attribute_13,
          amd_preferred_pkg.getpreferredvalue
                         (planner_code_cleaned,
                          planner_code,
                          amd_defaults.getplannercode (parts.nsn)
                         ) attribute_14,
          NULL attribute_15, NULL attribute_16, NULL attribute_17,
          NULL attribute_18, parts.mfgr attribute_19,
          CASE
             WHEN SUBSTR
                    (CASE
                        WHEN smr_code_cleaned IS NOT NULL
                           THEN smr_code_cleaned
                        ELSE smr_code
                     END,
                     6,
                     1
                    ) IN ('P', 'N')
                THEN 'F'
             WHEN SUBSTR
                     (CASE
                         WHEN smr_code_cleaned IS NOT NULL
                            THEN smr_code_cleaned
                         ELSE smr_code
                      END,
                      6,
                      1
                     ) = 'T'
                THEN 'T'
             ELSE NULL
          END attribute_20,
          NULL attribute_21, NULL attribute_22, NULL attribute_23,
          NULL attribute_24, NULL attribute_25, NULL attribute_26,
          NULL attribute_27, items.prime_part_no attribute_28,
          CASE
             WHEN items.wesm_indicator IS NULL
                THEN NULL
             ELSE 'WESM Part'
          END attribute_29,
          CASE
             WHEN bsi.nsn IS NULL
                THEN NULL
             ELSE 'Bench Stock Item'
          END attribute_30, NULL attribute_31, NULL attribute_32,
          NULL material_class, NULL weight, NULL volume, 'T' is_exempt,
          'T' ignore_weight_and_volume, 'F' is_seasonal,
          'F' is_cannibalizable, 'F' partial_one_way_supersession
     FROM amd_spare_parts parts,
          amd_national_stock_items items,
          amd_bench_stock_items_v bsi,
          amd_nsi_parts nsi
    WHERE parts.nsn = items.nsn
      AND (parts.action_code <> 'D' AND items.action_code <> 'D')
      AND parts.is_spo_part = 'Y'
      AND items.nsn = bsi.nsn(+)
      AND parts.part_no = nsi.part_no
      AND nsi.unassignment_date IS NULL;


DROP PUBLIC SYNONYM X_PART_V;

CREATE PUBLIC SYNONYM X_PART_V FOR AMD_OWNER.X_PART_V;


GRANT SELECT ON AMD_OWNER.X_PART_V TO AMD_READER_ROLE;


