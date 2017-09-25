SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_ATTRIBUTE_V;

/* Formatted on 2009/07/08 15:47 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.x_lp_attribute_v (location,
                                                         part,
                                                         condemnation_rate,
                                                         passup_rate,
                                                         criticality,
                                                         variance_to_mean_ratio,
                                                         demand_forecast_type,
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
                                                         last_modified
                                                        )
as
   select ntwks.spo_location location, factors.part_no part,
          factors.cmdmd_rate condemnation_rate, factors.pass_up_rate,
          pref.criticality criticality, 1 variance_to_mean_ratio,
          null demand_forecast_type, null attribute_1, null attribute_2,
          null attribute_3, null attribute_4, null attribute_5,
          null attribute_6, null attribute_7, null attribute_8,
          null attribute_9, null attribute_10, null attribute_11,
          null attribute_12, null attribute_13, null attribute_14,
          null attribute_15, null attribute_16, null attribute_17,
          null attribute_18, null attribute_19, null attribute_20,
          null attribute_21, null attribute_22, null attribute_23,
          null attribute_24, null attribute_25, null attribute_26,
          null attribute_27, null attribute_28, null attribute_29,
          null attribute_30, null attribute_31, null attribute_32,
          factors.last_update_dt last_modified
     from amd_part_factors factors,
          amd_spare_parts parts,
          amd_preferred_v pref,
          amd_spare_networks ntwks
    where parts.is_spo_part = 'Y'
      and parts.is_repairable = 'Y'
      and parts.part_no = parts.spo_prime_part_no
      and parts.part_no = factors.part_no
      and factors.action_code <> 'D'
      and parts.part_no = pref.part_no
      and factors.cmdmd_rate is not null
      and factors.pass_up_rate is not null
      and factors.rts is not null
      and factors.cmdmd_rate + factors.pass_up_rate + factors.rts = 1
      and factors.loc_sid = ntwks.loc_sid
      and ntwks.loc_id = ntwks.spo_location;


DROP PUBLIC SYNONYM X_LP_ATTRIBUTE_V;

CREATE PUBLIC SYNONYM X_LP_ATTRIBUTE_V FOR AMD_OWNER.X_LP_ATTRIBUTE_V;


GRANT SELECT ON AMD_OWNER.X_LP_ATTRIBUTE_V TO AMD_READER_ROLE;

