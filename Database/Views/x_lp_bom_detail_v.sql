SET DEFINE OFF;
DROP VIEW AMD_OWNER.X_LP_BOM_DETAIL_V;

/* Formatted on 2008/08/14 13:22 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.x_lp_bom_detail_v (part,
                                                          included_part,
                                                          bom,
                                                          quantity,
                                                          begin_date,
                                                          end_date,
                                                          TIMESTAMP
                                                         )
AS
   SELECT part_no part, spo_prime_part_no included_part, 'C17', '1',
          NULL begin_date, NULL end_date, transaction_date TIMESTAMP
     FROM amd_sent_to_a2a
    WHERE action_code <> 'D'
      AND (   (    amd_utils.ispartrepairableyorn (part_no) = 'Y'
               AND a2a_pkg.ispartvalidyorn (part_no) = 'Y'
              )
           OR (    amd_utils.ispartconsumableyorn (part_no) = 'Y'
               AND a2a_consumables_pkg.ispartvalidyorn (part_no) = 'Y'
              )
          );


DROP PUBLIC SYNONYM X_LP_BOM_DETAIL_V;

CREATE PUBLIC SYNONYM X_LP_BOM_DETAIL_V FOR AMD_OWNER.X_LP_BOM_DETAIL_V;


GRANT SELECT ON AMD_OWNER.X_LP_BOM_DETAIL_V TO AMD_READER_ROLE;


