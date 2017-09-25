SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_LP_LEAD_TIME_V;

/* Formatted on 2009/02/09 15:05 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_lp_lead_time_v (location,
                                                           part,
                                                           lead_time_type,
                                                           quantity,
                                                           timestamp
                                                          )
as
   select "LOCATION", "PART", "LEAD_TIME_TYPE", "QUANTITY", "TIMESTAMP"
     from spoc17v2.v_lp_lead_time@stl_escm_link;


DROP PUBLIC SYNONYM SPO_LP_LEAD_TIME_V;

CREATE PUBLIC SYNONYM SPO_LP_LEAD_TIME_V FOR AMD_OWNER.SPO_LP_LEAD_TIME_V;


GRANT SELECT ON AMD_OWNER.SPO_LP_LEAD_TIME_V TO AMD_READER_ROLE;


