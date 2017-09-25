DROP VIEW AMD_OWNER.PGOLD_ORD1_V;

/* Formatted on 10/23/2012 2:38:15 PM (QP5 v5.163.1008.3004) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_ORD1_V
(
   ORDER_NO,
   ORDER_TYPE,
   SC,
   PART,
   COMPLETED_DOCDATE,
   COMPLETED_DATETIME,
   CREATED_DOCDATE,
   ACTION_TAKEN,
   ORIGINAL_LOCATION,
   QTY_DUE,
   QTY_COMPLETED,
   NEED_DATE,
   CREATED_DATETIME,
   CONDITION,
   ECD,
   VENDOR_CODE,
   ACCOUNTABLE_YN,
   USER_REF4,
   STATUS
)
AS
   SELECT TRIM (order_no),
          order_type,
          TRIM (sc),
          TRIM (part),
          completed_docdate,
          completed_datetime,
          created_docdate,
          action_taken,
          TRIM (original_location),
          qty_due,
          qty_completed,
          need_date,
          created_datetime,
          TRIM (condition),
          ecd,
          TRIM (vendor_code),
          accountable_yn,
          user_ref4,
          status
     FROM ord1@amd_pgoldlb_link;


DROP PUBLIC SYNONYM PGOLD_ORD1_V;

CREATE OR REPLACE PUBLIC SYNONYM PGOLD_ORD1_V FOR AMD_OWNER.PGOLD_ORD1_V;


GRANT SELECT ON AMD_OWNER.PGOLD_ORD1_V TO AMD_READER_ROLE;

