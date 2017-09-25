DROP VIEW AMD_OWNER.PGOLD_LVLS_V;

/* Formatted on 7/9/2012 4:24:36 PM (QP5 v5.163.1008.3004) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_LVLS_V
(
   NIIN,
   SRAN,
   NSN,
   LVL_DOCUMENT_NUMBER,
   DOCUMENT_DATETIME,
   CURRENT_STOCK_NUMBER,
   COMPATIBILITY_CODE,
   DATE_LVL_LOADED,
   REORDER_POINT,
   ECONOMIC_ORDER_QTY,
   APPROVED_LVL_QTY
)
AS
   SELECT TRIM (niin),
          TRIM (sran),
          REPLACE (SUBSTR (TRIM (current_stock_number), 1, 16), '-', ''),
          TRIM (lvl_document_number),
          document_datetime,
          SUBSTR (TRIM (current_stock_number), 1, 16),
          TRIM (compatibility_code),
          TO_DATE (date_lvl_loaded, 'yyddd') date_lvl_loaded,
          reorder_point,
          economic_order_qty,
          approved_lvl_qty
     FROM lvls@amd_pgoldlb_link;


DROP PUBLIC SYNONYM PGOLD_LVLS_V;

CREATE OR REPLACE PUBLIC SYNONYM PGOLD_LVLS_V FOR AMD_OWNER.PGOLD_LVLS_V;


GRANT SELECT ON AMD_OWNER.PGOLD_LVLS_V TO AMD_READER_ROLE;
