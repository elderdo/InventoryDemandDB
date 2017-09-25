SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_BOM_DETAIL_V;

/* Formatted on 2008/09/24 14:59 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_bom_detail_v (part,
                                                       included_part,
                                                       bom,
                                                       quantity,
                                                       begin_date,
                                                       end_date,
                                                       TIMESTAMP
                                                      )
AS
   SELECT NAME part, attribute_28 included_part, 'C17', 1,
          TO_DATE ('06/14/1993', 'MM/DD/YYYY') begin_date,
          TO_DATE ('12/31/2013', 'MM/DD/YYYY') end_date, TIMESTAMP TIMESTAMP
     FROM x_part_v
    WHERE attribute_28 = NAME;


DROP PUBLIC SYNONYM X_BOM_DETAIL_V;

CREATE PUBLIC SYNONYM X_BOM_DETAIL_V FOR AMD_OWNER.X_BOM_DETAIL_V;


GRANT SELECT ON AMD_OWNER.X_BOM_DETAIL_V TO AMD_READER_ROLE;


