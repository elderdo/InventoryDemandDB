DROP VIEW AMD_OWNER.RSP_ITEMSA_INV_V;

/* Formatted on 8/23/2017 3:57:16 PM (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.RSP_ITEMSA_INV_V
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
            DECODE (i.sc,  'C17PCAG', 'EY1746',  'SATCAA0001C17G', 'EY1746')
               loc_id,
            TRUNC (
               DECODE (i.created_datetime,
                       NULL, i.last_changed_datetime,
                       i.created_datetime))
               inv_date,
            '1' inv_type,
            SUM (NVL (i.qty, 0)) inv_qty,
            SUM (NVL (i.standard_level, 0)) standard_level
       FROM ITEMSA i
      WHERE     i.status_3 != 'I'
            AND i.status_servicable = 'Y'
            AND i.status_new_order = 'N'
            AND i.status_accountable = 'Y'
            AND i.status_active = 'Y'
            AND i.status_mai = 'N'
            AND i.condition != 'B170-ATL'
            AND NOT EXISTS
                   (SELECT 1
                      FROM ITEMSA ii
                     WHERE     ii.status_avail = 'N'
                           AND NVL (ii.receipt_order_no, '-1') = '-1'
                           AND ii.item_id = i.item_id)
   GROUP BY part,
            DECODE (i.sc,  'C17PCAG', 'EY1746',  'SATCAA0001C17G', 'EY1746'),
            TRUNC (
               DECODE (i.created_datetime,
                       NULL, i.last_changed_datetime,
                       i.created_datetime));


GRANT SELECT ON AMD_OWNER.RSP_ITEMSA_INV_V TO AMD_READER_ROLE;
