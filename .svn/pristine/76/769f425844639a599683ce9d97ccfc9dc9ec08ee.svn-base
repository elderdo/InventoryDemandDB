DROP VIEW AMD_OWNER.RSP_ITEM_INV_V;

/* Formatted on 8/23/2017 3:57:18 PM (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.RSP_ITEM_INV_V
(
   PART_NO,
   LOC_ID,
   INV_DATE,
   INV_TYPE,
   INV_QTY,
   STANDARD_LEVEL
)
AS
     SELECT part part_no,
            SUBSTR (i.sc, 8, 6) loc_id,
            TRUNC (
               DECODE (i.created_datetime,
                       NULL, i.last_changed_datetime,
                       i.created_datetime))
               inv_date,
            '1' inv_type,
            SUM (NVL (i.qty, 0)) inv_qty,
            SUM (NVL (I.STANDARD_LEVEL, 0)) standard_level
       FROM ITEM i
      WHERE     i.status_3 != 'I'
            AND SUBSTR (i.sc, 1, 3) = 'C17'
            AND SUBSTR (i.sc, LENGTH (i.sc), 1) IN ('G')
            AND i.status_servicable = 'Y'
            AND i.status_new_order = 'N'
            AND i.status_accountable = 'Y'
            AND i.status_active = 'Y'
            AND i.status_mai = 'N'
            AND i.condition != 'B170-ATL'
            AND NOT EXISTS
                   (SELECT 1
                      FROM ITEM ii
                     WHERE     ii.status_avail = 'N'
                           AND NVL (ii.receipt_order_no, '-1') = '-1'
                           AND ii.item_id = i.item_id)
   GROUP BY part,
            SUBSTR (i.sc, 8, 6),
            TRUNC (
               DECODE (i.created_datetime,
                       NULL, i.last_changed_datetime,
                       i.created_datetime));


GRANT SELECT ON AMD_OWNER.RSP_ITEM_INV_V TO AMD_READER_ROLE;
