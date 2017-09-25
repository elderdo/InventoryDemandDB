DROP VIEW AMD_OWNER.PGOLD_POI1_V;

/* Formatted on 7/9/2012 4:25:01 PM (QP5 v5.163.1008.3004) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_POI1_V
(
   ORDER_NO,
   SEQ,
   ITEM,
   QTY,
   ITEM_LINE,
   EXT_PRICE,
   PART,
   CCN,
   DELIVERY_DATE
)
AS
   SELECT TRIM (order_no),
          TRIM (seq),
          TRIM (item),
          TRIM (qty),
          TRIM (item_line),
          TRIM (ext_price),
          TRIM (part),
          TRIM (ccn),
          TRIM (delivery_date)
     FROM poi1@amd_pgoldlb_link
    WHERE ext_price IS NOT NULL;


DROP PUBLIC SYNONYM PGOLD_POI1_V;

CREATE OR REPLACE PUBLIC SYNONYM PGOLD_POI1_V FOR AMD_OWNER.PGOLD_POI1_V;


GRANT SELECT ON AMD_OWNER.PGOLD_POI1_V TO AMD_READER_ROLE;
