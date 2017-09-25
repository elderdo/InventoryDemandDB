SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_LP_ON_HAND_V;

/* Formatted on 2008/08/20 09:01 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.spo_lp_on_hand_v (LOCATION,
                                                         part,
                                                         on_hand_type,
                                                         TIMESTAMP,
                                                         quantity
                                                        )
AS
   SELECT "LOCATION", "PART", "ON_HAND_TYPE", "TIMESTAMP", "QUANTITY"
     FROM spoc17v2.v_lp_on_hand@stl_escm_link;


DROP PUBLIC SYNONYM SPO_LP_ON_HAND_V;

CREATE PUBLIC SYNONYM SPO_LP_ON_HAND_V FOR AMD_OWNER.SPO_LP_ON_HAND_V;


GRANT SELECT ON AMD_OWNER.SPO_LP_ON_HAND_V TO AMD_READER_ROLE;


