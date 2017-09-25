DROP VIEW AMD_OWNER.AMD_WARNER_ROBINS_DUPMLTFILE_V;

/* Formatted on 8/31/2017 2:51:51 PM (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_WARNER_ROBINS_DUPMLTFILE_V
(
   NSN,
   DOC_NO,
   DEMAND_QUANTITY,
   TRANSACTION_DATE,
   FILENAME,
   EXCEL_ROW,
   NUMBER_OF_DUPLICATES
)
   BEQUEATH DEFINER
AS
     SELECT f.nsn,
            f.doc_no,
            f.demand_quantity,
            f.transaction_date,
            f.filename,
            f.excel_row,
            duplicates.number_of_duplicates
       FROM amd_warner_robins_files f,
            (  SELECT NSN,
                      DOC_NO,
                      SUM (DEMAND_QUANTITY_SUMMED) demand_quantity_summed,
                      SUM (NUMBER_OF_DUPLICATES) number_of_duplicates
                 FROM amd_warner_robins_dups_v
             GROUP BY nsn, doc_no
               HAVING COUNT (*) > 1) duplicates
      WHERE f.nsn = duplicates.nsn AND f.doc_no = duplicates.doc_no
   ORDER BY f.nsn,
            f.doc_no,
            f.filename,
            f.excel_row;


GRANT SELECT ON AMD_OWNER.AMD_WARNER_ROBINS_DUPMLTFILE_V TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.AMD_WARNER_ROBINS_DUPMLTFILE_V TO AMD_WRITER_ROLE;
