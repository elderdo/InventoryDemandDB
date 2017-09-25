DROP VIEW AMD_OWNER.RSP_RAMP_ITEM_V;

/* Formatted on 8/23/2017 3:57:22 PM (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.RSP_RAMP_ITEM_V
(
   PART_NO,
   LOC_SID,
   RSP_INV,
   RSP_LEVEL
)
AS
   SELECT part_no, loc_sid, rsp_inv, rsp_level FROM rsp_ramp_inv_v
   UNION ALL
   SELECT part_no,
          loc_sid,
          inv_qty,
          rsp_level
     FROM (  SELECT part_no,
                    loc_sid,
                    SUM (inv_qty) inv_qty,
                    SUM (rsp_level) rsp_level
               FROM rsp_all_item_inv_v
           GROUP BY part_no, loc_sid)
   ORDER BY part_no, loc_sid;


GRANT SELECT ON AMD_OWNER.RSP_RAMP_ITEM_V TO AMD_READER_ROLE;
