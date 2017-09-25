DROP VIEW AMD_OWNER.PGOLD_ITEM_V;

/* Formatted on 7/9/2012 4:24:33 PM (QP5 v5.163.1008.3004) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_ITEM_V
(
   ITEM_ID,
   RECEIVED_ITEM_ID,
   SC,
   PART,
   PRIME,
   CONDITION,
   STATUS_DEL_WHEN_GONE,
   STATUS_SERVICABLE,
   STATUS_NEW_ORDER,
   STATUS_ACCOUNTABLE,
   STATUS_AVAIL,
   STATUS_FROZEN,
   STATUS_ACTIVE,
   STATUS_MAI,
   STATUS_RECEIVING_SUSP,
   STATUS_2,
   STATUS_3,
   LAST_CHANGED_DATETIME,
   STATUS_1,
   CREATED_DATETIME,
   VENDOR_CODE,
   QTY,
   ORDER_NO,
   RECEIPT_ORDER_NO
)
AS
   SELECT TRIM (item_id),
          TRIM (received_item_id),
          TRIM (sc),
          TRIM (part),
          TRIM (prime),
          TRIM (condition),
          status_del_when_gone,
          status_servicable,
          status_new_order,
          status_accountable,
          status_avail,
          status_frozen,
          status_active,
          status_mai,
          status_receiving_susp,
          status_2,
          status_3,
          last_changed_datetime,
          status_1,
          created_datetime,
          TRIM (vendor_code),
          qty,
          TRIM (order_no),
          TRIM (receipt_order_no)
     FROM item@amd_pgoldlb_link
    WHERE status_1 != 'D' AND condition NOT IN ('LDD')
          AND (last_changed_datetime IS NOT NULL
               OR created_datetime IS NOT NULL);


DROP PUBLIC SYNONYM PGOLD_ITEM_V;

CREATE OR REPLACE PUBLIC SYNONYM PGOLD_ITEM_V FOR AMD_OWNER.PGOLD_ITEM_V;


GRANT SELECT ON AMD_OWNER.PGOLD_ITEM_V TO AMD_READER_ROLE;
