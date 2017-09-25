DROP VIEW AMD_OWNER.AMD_WARNER_ROBINS_BAD_NSN_V;

/* Formatted on 8/31/2017 2:51:49 PM (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_WARNER_ROBINS_BAD_NSN_V
(
   EXCEL_ROW,
   SOURCE_CODE,
   TRANSACTION_DATE,
   TRAN_DATE_YYDDD,
   NSN,
   DOC_NO,
   DEMAND_QUANTITY,
   LAST_UPDATE_DT,
   FILENAME
)
   BEQUEATH DEFINER
AS
   SELECT excel_row,
          source_code,
          transaction_date,
          TO_CHAR (TRANSACTION_dATE, 'RRDDD') tran_date_yyddd,
          NSN,
          DOC_NO,
          DEMAND_QUANTITY,
          last_update_dt,
          filename
     FROM amd_warner_robins_files
    WHERE nsn NOT IN (SELECT n.nsn
                        FROM amd_nsns n, amd_national_stock_items i
                       WHERE n.nsi_sid = i.nsi_sid AND i.action_code <> 'D');


GRANT SELECT ON AMD_OWNER.AMD_WARNER_ROBINS_BAD_NSN_V TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.AMD_WARNER_ROBINS_BAD_NSN_V TO AMD_WRITER_ROLE;
