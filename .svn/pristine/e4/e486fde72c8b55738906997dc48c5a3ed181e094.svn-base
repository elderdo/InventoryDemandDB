DROP VIEW AMD_OWNER.PGOLD_TRHI_V;

/* Formatted on 7/9/2012 4:25:25 PM (QP5 v5.163.1008.3004) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_TRHI_V
(
   TRAN_ID,
   CREATED_DATETIME,
   DOCUMENT_DATETIME,
   QTY,
   PART,
   CREATED_USERID,
   SC,
   MINUS_DATETIME,
   ITEM_ID,
   ORDER_NO,
   RECEIVED_ITEM_ID,
   FT_FROM_LOCATION,
   TCN,
   CHANGE_TYPE,
   VOUCHER
)
AS
   SELECT TRIM (tran_id),
          TO_CHAR (trhi.created_datetime),
          document_datetime,
          trhi.qty,
          TRIM (trhi.part),
          TRIM (trhi.created_userid),
          TRIM (sc),
          TO_CHAR (minus_datetime),
          TRIM (item_id),
          TRIM (order_no),
          TRIM (received_item_id),
          TRIM (ft_from_location),
          TRIM (tcn),
          TRIM (change_type),
          TRIM (voucher)
     FROM trhi@amd_pgoldlb_link trhi, cat1@amd_pgoldlb_link cat1
    WHERE     trhi.tcn = 'DII'
          AND trhi.part = cat1.part
          AND trhi.minus_datetime IS NULL
          AND cat1.source_code = 'F77';


DROP PUBLIC SYNONYM PGOLD_TRHI_V;

CREATE OR REPLACE PUBLIC SYNONYM PGOLD_TRHI_V FOR AMD_OWNER.PGOLD_TRHI_V;


GRANT SELECT ON AMD_OWNER.PGOLD_TRHI_V TO AMD_READER_ROLE;
