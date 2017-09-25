SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_ATTRIBUTE_V;

/* Formatted on 2008/11/05 07:59 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_lp_attribute_v (LOCATION,
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
                                                         TIMESTAMP
                                                        )
AS
   SELECT amd_utils.getspolocation (loc_sid) LOCATION, factors.part_no part,
          factors.cmdmd_rate condemnation_rate, factors.pass_up_rate,
          pref.criticality criticality, 1 variance_to_mean_ratio,
          NULL demand_forecast_type, NULL attribute_1, NULL attribute_2,
          NULL attribute_3, NULL attribute_4, NULL attribute_5,
          NULL attribute_6, NULL attribute_7, NULL attribute_8,
          NULL attribute_9, NULL attribute_10, NULL attribute_11,
          NULL attribute_12, NULL attribute_13, NULL attribute_14,
          NULL attribute_15, NULL attribute_16, NULL attribute_17,
          NULL attribute_18, NULL attribute_19, NULL attribute_20,
          NULL attribute_21, NULL attribute_22, NULL attribute_23,
          NULL attribute_24, NULL attribute_25, NULL attribute_26,
          NULL attribute_27, NULL attribute_28, NULL attribute_29,
          NULL attribute_30, NULL attribute_31, NULL attribute_32,
          factors.last_update_dt TIMESTAMP
     FROM amd_part_factors factors,
          amd_spare_parts parts,
          amd_preferred_v pref
    WHERE parts.is_spo_part = 'Y'
      AND parts.part_no = parts.spo_prime_part_no
      AND parts.part_no = factors.part_no
      AND parts.part_no = pref.part_no
      AND (   factors.cmdmd_rate <> 0
           OR factors.pass_up_rate <> 0
           OR pref.criticality <> 0
          );


DROP PUBLIC SYNONYM X_LP_ATTRIBUTE_V;

CREATE PUBLIC SYNONYM X_LP_ATTRIBUTE_V FOR AMD_OWNER.X_LP_ATTRIBUTE_V;


GRANT SELECT ON AMD_OWNER.X_LP_ATTRIBUTE_V TO AMD_READER_ROLE;


