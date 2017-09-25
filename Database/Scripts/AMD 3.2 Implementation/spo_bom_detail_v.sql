SET DEFINE OFF;
DROP VIEW AMD_OWNER.SPO_BOM_DETAIL_V;

/* Formatted on 2008/08/14 12:51 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.spo_bom_detail_v (part,
                                                         included_part,
                                                         bom,
                                                         quantity,
                                                         begin_date,
                                                         end_date,
                                                         parent_included_part,
                                                         TIMESTAMP
                                                        )
AS
   SELECT part, included_part, bom, quantity, begin_date, end_date,
          parent_included_part, TIMESTAMP
     FROM spoc17v2.v_bom_detail@stl_escm_link;


DROP PUBLIC SYNONYM SPO_BOM_DETAIL_V;

CREATE PUBLIC SYNONYM SPO_BOM_DETAIL_V FOR AMD_OWNER.SPO_BOM_DETAIL_V;


GRANT SELECT ON AMD_OWNER.SPO_BOM_DETAIL_V TO AMD_READER_ROLE;


