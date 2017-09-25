SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_LP_ATTRIBUTE_V;

/* Formatted on 2008/10/07 14:53 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.spo_lp_attribute_v (LOCATION,
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
   SELECT "LOCATION", "PART", "CONDEMNATION_RATE", "PASSUP_RATE",
          "CRITICALITY", "VARIANCE_TO_MEAN_RATIO", "DEMAND_FORECAST_TYPE",
          "ATTRIBUTE_1", "ATTRIBUTE_2", "ATTRIBUTE_3", "ATTRIBUTE_4",
          "ATTRIBUTE_5", "ATTRIBUTE_6", "ATTRIBUTE_7", "ATTRIBUTE_8",
          "ATTRIBUTE_9", "ATTRIBUTE_10", "ATTRIBUTE_11", "ATTRIBUTE_12",
          "ATTRIBUTE_13", "ATTRIBUTE_14", "ATTRIBUTE_15", "ATTRIBUTE_16",
          "ATTRIBUTE_17", "ATTRIBUTE_18", "ATTRIBUTE_19", "ATTRIBUTE_20",
          "ATTRIBUTE_21", "ATTRIBUTE_22", "ATTRIBUTE_23", "ATTRIBUTE_24",
          "ATTRIBUTE_25", "ATTRIBUTE_26", "ATTRIBUTE_27", "ATTRIBUTE_28",
          "ATTRIBUTE_29", "ATTRIBUTE_30", "ATTRIBUTE_31", "ATTRIBUTE_32",
          "TIMESTAMP"
     FROM spoc17v2.v_lp_attribute@stl_escm_link;


DROP PUBLIC SYNONYM SPO_LP_ATTRIBUTE_V;

CREATE PUBLIC SYNONYM SPO_LP_ATTRIBUTE_V FOR AMD_OWNER.SPO_LP_ATTRIBUTE_V;


GRANT SELECT ON AMD_OWNER.SPO_LP_ATTRIBUTE_V TO AMD_READER_ROLE;


