SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_BOM_DETAIL_V;

/* Formatted on 2009/07/08 16:53 (Formatter Plus v4.8.8) */
create or replace force view amd_owner.x_bom_detail_v (part,
                                                       included_part,
                                                       bom,
                                                       quantity,
                                                       begin_date,
                                                       end_date,
                                                       last_modified
                                                      )
as
   select name part, attribute_28 included_part, 'C17', 1,
          to_date ('06/14/1993', 'MM/DD/YYYY') begin_date,
          to_date ('12/31/2013', 'MM/DD/YYYY') end_date, last_modified
     from x_part_v
    where attribute_28 = name;


DROP PUBLIC SYNONYM X_BOM_DETAIL_V;

CREATE PUBLIC SYNONYM X_BOM_DETAIL_V FOR AMD_OWNER.X_BOM_DETAIL_V;


GRANT SELECT ON AMD_OWNER.X_BOM_DETAIL_V TO AMD_READER_ROLE;

