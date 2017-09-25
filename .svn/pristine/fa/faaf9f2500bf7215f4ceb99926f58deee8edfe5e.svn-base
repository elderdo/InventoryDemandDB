DROP VIEW AMD_OWNER.AMD_WARNER_ROBINS_DUPS_V;

/* Formatted on 8/31/2017 2:51:54 PM (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_WARNER_ROBINS_DUPS_V
(
   NSN,
   DOC_NO,
   DEMAND_QUANTITY_SUMMED,
   NUMBER_OF_DUPLICATES,
   FILENAME
)
   BEQUEATH DEFINER
AS
     SELECT NSN,
            DOC_NO,
            SUM (demand_quantity),
            COUNT (*) number_of_duplicates,
            FILENAME
       FROM amd_warner_robins_files
      WHERE nsn IN (SELECT n.nsn
                      FROM amd_nsns n, amd_national_stock_items i
                     WHERE n.nsi_sid = i.nsi_sid AND i.action_code <> 'D')
   GROUP BY nsn, doc_no, filename
     HAVING COUNT (*) > 1
   ORDER BY nsn, doc_no;


GRANT SELECT ON AMD_OWNER.AMD_WARNER_ROBINS_DUPS_V TO AMD_READER_ROLE;

GRANT DELETE, INSERT, SELECT, UPDATE ON AMD_OWNER.AMD_WARNER_ROBINS_DUPS_V TO AMD_WRITER_ROLE;
