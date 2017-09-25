DROP VIEW AMD_OWNER.AMD_WARNER_ROBINS_DUPS_DET_V;

/* Formatted on 8/31/2017 2:51:53 PM (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_WARNER_ROBINS_DUPS_DET_V
(
   FILENAME,
   EXCEL_ROW,
   NUMBER_OF_DUPLICATES,
   NSN,
   DOC_NO,
   DEMAND_QUANTITY,
   SOURCE_CODE,
   TRANSACTION_DATE,
   TRAN_DATE_YYDDD,
   LAST_UPDATE_DT
)
   BEQUEATH DEFINER
AS
     SELECT w.filename,
            excel_row,
            d.number_of_duplicates,
            w.NSN,
            w.DOC_NO,
            DEMAND_QUANTITY,
            source_code,
            transaction_date,
            TO_CHAR (transaction_date, 'RRDDD') tran_date_yyddd,
            last_update_dt
       FROM amd_warner_robins_files w, amd_warner_robins_dups_v d
      WHERE w.nsn = d.nsn AND w.doc_no = d.doc_no AND w.filename = d.filename
   ORDER BY w.nsn,
            w.doc_no,
            w.filename,
            excel_row;


GRANT SELECT ON AMD_OWNER.AMD_WARNER_ROBINS_DUPS_DET_V TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.AMD_WARNER_ROBINS_DUPS_DET_V TO AMD_WRITER_ROLE;
