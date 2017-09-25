SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_FIXED_CURRENT_PERIOD_V;

/* Formatted on 2009/05/11 13:15 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_fixed_current_period_v (period,
                                                                   timestamp
                                                                  )
as
   select "PERIOD", "TIMESTAMP"
     from spoc17v2.current_period@stl_escm_link;


DROP PUBLIC SYNONYM SPO_FIXED_CURRENT_PERIOD_V;

CREATE PUBLIC SYNONYM SPO_FIXED_CURRENT_PERIOD_V FOR AMD_OWNER.SPO_FIXED_CURRENT_PERIOD_V;


GRANT SELECT ON AMD_OWNER.SPO_FIXED_CURRENT_PERIOD_V TO AMD_READER_ROLE;


