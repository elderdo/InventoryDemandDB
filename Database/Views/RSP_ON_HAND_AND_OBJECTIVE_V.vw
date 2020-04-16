DROP VIEW AMD_OWNER.RSP_ON_HAND_AND_OBJECTIVE_V;

/* Formatted on 4/16/2020 4:39:20 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.RSP_ON_HAND_AND_OBJECTIVE_V
(
   NSN,
   SRAN,
   RSP_ON_HAND,
   RSP_OBJECTIVE
)
   BEQUEATH DEFINER
AS
     SELECT nsn,
            NVL (NEW_VALUE, asn.loc_id) sran,
            SUM (rsp_inv)             rsp_on_hand,
            SUM (rsp_level)           rsp_objective
       FROM amd_rsp                r,
            amd_spare_networks     asn,
            amd_national_stock_items ansi,
            amd_substitutions      subs
      WHERE     r.action_code != 'D'
            AND R.PART_NO = ANSI.PRIME_PART_NO
            AND ANSI.ACTION_CODE != 'D'
            AND r.loc_sid = asn.loc_sid
            AND subs.substitution_name(+) = 'RSP_On_Hand_and_Objective'
            AND subs.substitution_type(+) = 'SRAN'
            AND subs.original_value(+) = loc_id
            AND subs.action_code(+) <> 'D'
   GROUP BY ansi.nsn, NVL (NEW_VALUE, asn.loc_id)
     HAVING SUM (rsp_inv) > 0 OR SUM (rsp_level) > 0;


DROP PUBLIC SYNONYM RSP_ON_HAND_AND_OBJECTIVE_V;

CREATE PUBLIC SYNONYM RSP_ON_HAND_AND_OBJECTIVE_V FOR AMD_OWNER.RSP_ON_HAND_AND_OBJECTIVE_V;


GRANT SELECT ON AMD_OWNER.RSP_ON_HAND_AND_OBJECTIVE_V TO AMD_READER_ROLE;
