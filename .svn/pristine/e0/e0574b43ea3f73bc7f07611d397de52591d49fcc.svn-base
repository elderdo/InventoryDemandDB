DROP VIEW AMD_OWNER.AMD_WARNER_ROBINS_SUMMED_V;

/* Formatted on 9/13/2017 3:23:31 PM (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.AMD_WARNER_ROBINS_SUMMED_V
(
   DOC_NO,
   LOC_ID,
   LOC_SID,
   NSN,
   NSI_SID,
   QUANTITY,
   CREATED_DATETIME,
   PRIME_PART_NO
)
   BEQUEATH DEFINER
AS
   SELECT doc_no,
          'EY1746' loc_id,
          amd_utils.getLocSid ('EY1746') loc_sid,
          stkItems.nsn,
          nsi_sid,
          quantity,
          created_datetime,
          prime_part_no
     FROM amd_national_stock_items stkItems,
          (  SELECT items.nsn nsn,
                    doc_no,
                    SUM (demand_quantity) quantity,
                    MIN (transaction_date) created_datetime
               FROM amd_warner_robins_files wr,
                    amd_nsns nsns,
                    amd_national_stock_items items
              WHERE     bad_nsn IS NULL
                    AND wr.action_code IS NULL
                    AND wr.nsn = nsns.nsn
                    AND nsns.nsi_sid = items.nsi_sid
           GROUP BY items.nsn, doc_no) wr
    WHERE wr.nsn = stkItems.nsn AND stkItems.action_code <> 'D';


GRANT SELECT ON AMD_OWNER.AMD_WARNER_ROBINS_SUMMED_V TO AMD_READER_ROLE;
