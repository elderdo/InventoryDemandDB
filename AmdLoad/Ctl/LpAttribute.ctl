--      $Author:   zf297a  $
--    $Revision:   1.2  $
--        $Date:   08 Jul 2009 14:26:58  $
--    $Workfile:   LpAttribute.ctl  $
--    Load data to the SPO import tables for the 
--    target table spoc17v2.lp_attribute

LOAD DATA
infile '/apps/CRON/AMD/data/LpAttribute.csv'
Append INTO TABLE spoc17v2.X_IMP_LP_ATTRIBUTE
fields terminated by "," optionally enclosed by '"'
(LOCATION,
 PART,
 condemnation_rate nullif (condemnation_rate="null"),
 passup_rate nullif (passup_rate="null"),
 criticality nullif (criticality="null"),
 variance_to_mean_ratio,
 ATTRIBUTE_1 NULLIF (ATTRIBUTE_1="null"),
 ATTRIBUTE_2 NULLIF (ATTRIBUTE_2="null"),
 ATTRIBUTE_3 NULLIF (ATTRIBUTE_3="null"),
 ATTRIBUTE_4 NULLIF (ATTRIBUTE_4="null"),
 ATTRIBUTE_5 NULLIF (ATTRIBUTE_5="null"),
 ATTRIBUTE_6 NULLIF (ATTRIBUTE_6="null"),
 ATTRIBUTE_7 NULLIF (ATTRIBUTE_7="null"),
 ATTRIBUTE_8 NULLIF (ATTRIBUTE_8="null"),
 ATTRIBUTE_9 NULLIF (ATTRIBUTE_9="null"),
 ATTRIBUTE_10 NULLIF (ATTRIBUTE_10="null"),
 ATTRIBUTE_11 NULLIF (ATTRIBUTE_11="null"),
 ATTRIBUTE_12 NULLIF (ATTRIBUTE_12="null"),
 ATTRIBUTE_13 NULLIF (ATTRIBUTE_13="null"),
 ATTRIBUTE_14 NULLIF (ATTRIBUTE_14="null"),
 ATTRIBUTE_15 NULLIF (ATTRIBUTE_15="null"),
 ATTRIBUTE_16 NULLIF (ATTRIBUTE_16="null"),
 ATTRIBUTE_17 NULLIF (ATTRIBUTE_17="null"),
 ATTRIBUTE_18 NULLIF (ATTRIBUTE_18="null"),
 ATTRIBUTE_19 NULLIF (ATTRIBUTE_19="null"),
 ATTRIBUTE_20 NULLIF (ATTRIBUTE_20="null"),
 ATTRIBUTE_21 NULLIF (ATTRIBUTE_21="null"),
 ATTRIBUTE_22 NULLIF (ATTRIBUTE_22="null"),
 ATTRIBUTE_23 NULLIF (ATTRIBUTE_23="null"),
 ATTRIBUTE_24 NULLIF (ATTRIBUTE_24="null"),
 ATTRIBUTE_25 NULLIF (ATTRIBUTE_25="null"),
 ATTRIBUTE_26 NULLIF (ATTRIBUTE_26="null"),
 ATTRIBUTE_27 NULLIF (ATTRIBUTE_27="null"),
 ATTRIBUTE_28 NULLIF (ATTRIBUTE_28="null"),
 ATTRIBUTE_29 NULLIF (ATTRIBUTE_29="null"),
 ATTRIBUTE_30 NULLIF (ATTRIBUTE_30="null"),
 ATTRIBUTE_31 NULLIF (ATTRIBUTE_31="null"),
 ATTRIBUTE_32 NULLIF (ATTRIBUTE_32="null"),
 demand_forecast_type NULLIF (demand_forecast_type="null"),
 ACTION,
 BATCH,
 LAST_MODIFIED  SYSDATE,
 INTERFACE_SEQUENCE  SEQUENCE(MAX, 1)
)
