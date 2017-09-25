DROP VIEW AMD_OWNER.PGOLD_MLIT_V;

/* Formatted on 7/9/2012 4:24:43 PM (QP5 v5.163.1008.3004) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_MLIT_V
(
   DOCUMENT_ID,
   CUSTOMER,
   MILS_ACTIVITY,
   MILS_OWNERSHIP_CODE,
   MILS_PROFILE,
   IN_TRAN_FROM,
   IN_TRAN_TO,
   IN_TRAN_TYPE,
   PART,
   ABBR_PART,
   CREATE_DATE,
   SHIP_DATE,
   RECEIPT_DATE,
   START_DATE_TIME,
   CREATE_QTY,
   SHIP_QTY,
   RECEIPT_QTY,
   MILS_CONDITION,
   STATUS_IND
)
AS
   SELECT TRIM (document_id),
          TRIM (customer),
          TRIM (mils_activity),
          TRIM (mils_ownership_code),
          TRIM (mils_profile),
          TRIM (in_tran_from),
          TRIM (in_tran_to),
          TRIM (in_tran_type),
          TRIM (part),
          TRIM (abbr_part),
          create_date,
          ship_date,
          receipt_date,
          start_date_time,
          create_qty,
          ship_qty,
          receipt_qty,
          mils_condition,
          status_ind
     FROM mlit@amd_pgoldlb_link
    WHERE TRIM (part) != TRIM (abbr_part) AND status_ind = 'I'
          OR TRIM (abbr_part) IS NULL AND status_ind = 'I';


DROP PUBLIC SYNONYM PGOLD_MLIT_V;

CREATE OR REPLACE PUBLIC SYNONYM PGOLD_MLIT_V FOR AMD_OWNER.PGOLD_MLIT_V;


GRANT SELECT ON AMD_OWNER.PGOLD_MLIT_V TO AMD_READER_ROLE;
