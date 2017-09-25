DROP VIEW AMD_OWNER.AMD_WARNER_ROBINS_FILES_V;

/* Formatted on 8/31/2017 2:51:07 PM (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_WARNER_ROBINS_FILES_V
(
   EXCEL_ROW,
   TRANSACTION_DATE,
   TRAN_DATE_YYDDD,
   NSN,
   DOC_NO,
   DEMAND_QUANTITY,
   FILENAME,
   LAST_UPDATE_DT,
   DATE_LOADED_TO_DEMANDS
)
   BEQUEATH DEFINER
AS
     SELECT excel_row,
            transaction_date,
            TO_CHAR (transaction_date, 'RRDDD') tran_date_yyddd,
            nsn,
            doc_no,
            demand_quantity,
            filename,
            last_update_dt,
            date_loaded_to_demands
       FROM amd_warner_robins_files
   ORDER BY filename, excel_row;


GRANT SELECT ON AMD_OWNER.AMD_WARNER_ROBINS_FILES_V TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.AMD_WARNER_ROBINS_FILES_V TO AMD_WRITER_ROLE;
