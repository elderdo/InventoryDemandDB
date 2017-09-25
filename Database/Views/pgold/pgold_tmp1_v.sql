DROP VIEW AMD_OWNER.PGOLD_TMP1_V;

/* Formatted on 7/9/2012 4:25:21 PM (QP5 v5.163.1008.3004) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.PGOLD_TMP1_V
(
   QTY_DUE,
   RETURNED_VOUCHER,
   STATUS,
   TCN,
   FROM_SC,
   TO_SC,
   FROM_DATETIME,
   TEMP_OUT_ID,
   FROM_PART,
   EST_RETURN_DATE
)
AS
   SELECT qty_due,
          TRIM (returned_voucher),
          status,
          TRIM (tcn),
          TRIM (from_sc),
          TRIM (to_sc),
          from_datetime,
          TRIM (temp_out_id),
          TRIM (from_part),
          est_return_date
     FROM tmp1@amd_pgoldlb_link
    WHERE returned_voucher IS NULL AND status = 'O' AND tcn IN ('LNI', 'LBR');


DROP PUBLIC SYNONYM PGOLD_TMP1_V;

CREATE OR REPLACE PUBLIC SYNONYM PGOLD_TMP1_V FOR AMD_OWNER.PGOLD_TMP1_V;


GRANT SELECT ON AMD_OWNER.PGOLD_TMP1_V TO AMD_READER_ROLE;
