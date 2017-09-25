SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_LP_IN_TRANSIT_V;

/* Formatted on 2009/07/08 17:20 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_lp_in_transit_v (location,
                                                            part,
                                                            in_transit_type,
                                                            quantity,
                                                            last_modified
                                                           )
as
   select "LOCATION", "PART", "IN_TRANSIT_TYPE", "QUANTITY", last_modified
     from spoc17v2.v_lp_in_transit@stl_escm_link;


DROP PUBLIC SYNONYM SPO_LP_IN_TRANSIT_V;

CREATE PUBLIC SYNONYM SPO_LP_IN_TRANSIT_V FOR AMD_OWNER.SPO_LP_IN_TRANSIT_V;


GRANT SELECT ON AMD_OWNER.SPO_LP_IN_TRANSIT_V TO AMD_READER_ROLE;

