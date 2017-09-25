DROP VIEW AMD_OWNER.RSP_ON_HAND_AND_OBJECTIVE_V;

/* Formatted on 8/23/2017 3:57:19 PM (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.RSP_ON_HAND_AND_OBJECTIVE_V
(
   NSN,
   SRAN,
   RSP_ON_HAND,
   RSP_OBJECTIVE
)
AS
     SELECT TO_CHAR (ansi.nsn) nsn,
            NVL (VALUE, asn.loc_id) sran,
            SUM (rsp_inv) rsp_on_hand,
            SUM (rsp_level) rsp_object
       FROM amd_rsp r,
            amd_national_stock_items ansi,
            amd_spare_networks asn
            LEFT OUTER JOIN name_value_pairs
               ON asn.loc_id = name AND namespace = 'RSP_ON_HAND'
      WHERE     r.action_code != 'D'
            AND R.PART_NO = ANSI.PRIME_PART_NO
            AND ANSI.ACTION_CODE != 'D'
            AND r.loc_sid = asn.loc_sid
   GROUP BY ansi.nsn, NVL (VALUE, asn.loc_id)
     HAVING SUM (rsp_inv) > 0 AND SUM (rsp_level) > 0;


DROP PUBLIC SYNONYM RSP_ON_HAND_AND_OBJECTIVE_V;

CREATE PUBLIC SYNONYM RSP_ON_HAND_AND_OBJECTIVE_V FOR AMD_OWNER.RSP_ON_HAND_AND_OBJECTIVE_V;


GRANT SELECT ON AMD_OWNER.RSP_ON_HAND_AND_OBJECTIVE_V TO AMD_READER_ROLE;
