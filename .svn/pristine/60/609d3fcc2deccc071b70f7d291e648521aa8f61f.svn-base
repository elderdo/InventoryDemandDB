SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_LP_BACKORDER_V;

/* Formatted on 2008/05/16 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.spo_lp_backorder_v (LOCATION,
                                                           part,
                                                           backorder_type,
                                                           quantity,
                                                           TIMESTAMP
                                                          )
AS
   SELECT LOCATION, part, backorder_type, quantity, TIMESTAMP
     FROM spoc17v2.v_lp_backorder@stl_escm_link;


DROP PUBLIC SYNONYM SPO_LP_BACKORDER_V;

CREATE PUBLIC SYNONYM SPO_LP_BACKORDER_V FOR AMD_OWNER.SPO_LP_BACKORDER_V;


GRANT SELECT ON AMD_OWNER.SPO_LP_BACKORDER_V TO AMD_READER_ROLE;


