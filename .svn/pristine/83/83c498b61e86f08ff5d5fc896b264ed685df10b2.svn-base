SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_LP_BACKORDER_V;

/* Formatted on 2009/07/08 17:18 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.spo_lp_backorder_v (location,
                                                           part,
                                                           backorder_type,
                                                           quantity,
                                                           last_modified
                                                          )
as
   select location, part, backorder_type, quantity, last_modified
     from spoc17v2.v_lp_backorder@stl_escm_link;


DROP PUBLIC SYNONYM SPO_LP_BACKORDER_V;

CREATE PUBLIC SYNONYM SPO_LP_BACKORDER_V FOR AMD_OWNER.SPO_LP_BACKORDER_V;


GRANT SELECT ON AMD_OWNER.SPO_LP_BACKORDER_V TO AMD_READER_ROLE;

