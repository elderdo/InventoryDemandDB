SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_LP_ON_HAND_V;

/* Formatted on 2009/07/08 17:21 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_lp_on_hand_v (location,
                                                         part,
                                                         on_hand_type,
                                                         last_modified,
                                                         quantity
                                                        )
as
   select "LOCATION", "PART", "ON_HAND_TYPE", last_modified, "QUANTITY"
     from spoc17v2.v_lp_on_hand@stl_escm_link;


DROP PUBLIC SYNONYM SPO_LP_ON_HAND_V;

CREATE PUBLIC SYNONYM SPO_LP_ON_HAND_V FOR AMD_OWNER.SPO_LP_ON_HAND_V;


GRANT SELECT ON AMD_OWNER.SPO_LP_ON_HAND_V TO AMD_READER_ROLE;

