DROP VIEW AMD_OWNER.RSP_ALL_ITEM_INV_V;

/* Formatted on 8/23/2017 3:57:13 PM (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.RSP_ALL_ITEM_INV_V
(
   PART_NO,
   LOC_SID,
   INV_QTY,
   RSP_LEVEL
)
AS
     SELECT asp.part_no part_no,
            DECODE (asn.loc_type, 'TMP', asnLink.loc_sid, asn.loc_sid) loc_sid,
            SUM (invQ.inv_qty) inv_qty,
            SUM (invQ.standard_level) rsp_level
       FROM (SELECT part_no,
                    loc_id,
                    inv_date,
                    inv_type,
                    inv_qty,
                    standard_level
               FROM rsp_item_inv_v
             UNION ALL
             SELECT part_no,
                    loc_id,
                    inv_date,
                    inv_type,
                    inv_qty,
                    standard_level
               FROM RSP_ITEMSA_INV_V) invQ,
            AMD_SPARE_NETWORKS asn,
            AMD_SPARE_PARTS asp,
            AMD_SPARE_NETWORKS asnLink
      WHERE     asp.part_no = invQ.part_no
            AND asn.loc_id = invQ.loc_id
            AND asn.loc_type = 'KIT'
            AND asp.action_code != 'D'
            AND asn.mob = asnLink.loc_id(+)
   GROUP BY asp.part_no,
            DECODE (asn.loc_type, 'TMP', asnLink.loc_sid, asn.loc_sid),
            invQ.inv_date
     HAVING SUM (invQ.inv_qty) > 0 OR SUM (invQ.standard_level) > 0;


GRANT SELECT ON AMD_OWNER.RSP_ALL_ITEM_INV_V TO AMD_READER_ROLE;
