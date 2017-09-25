DROP VIEW AMD_OWNER.RSP_WHSE_INV_V;

/* Formatted on 8/23/2017 3:57:23 PM (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.RSP_WHSE_INV_V
(
   PART_NO,
   LOC_SID,
   RSP_LEVEL
)
AS
     SELECT w.part part_no,
            ntwks.loc_sid loc_sid,
            SUM (NVL (stock_level, 0)) rsp_level
       FROM whse w, active_parts_v a, amd_spare_networks ntwks
      WHERE     w.part = a.part_no
            AND SUBSTR (sc, 8, 6) = ntwks.loc_id
            AND SUBSTR (sc, 8, 3) = 'KIT'
   GROUP BY w.part, ntwks.loc_sid
   ORDER BY part, loc_sid;


GRANT SELECT ON AMD_OWNER.RSP_WHSE_INV_V TO AMD_READER_ROLE;
