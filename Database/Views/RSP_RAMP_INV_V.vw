DROP VIEW AMD_OWNER.RSP_RAMP_INV_V;

/* Formatted on 8/23/2017 3:57:21 PM (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.RSP_RAMP_INV_V
(
   PART_NO,
   LOC_SID,
   RSP_INV,
   RSP_LEVEL
)
AS
   SELECT asp.part_no part_no,
          DECODE (n.loc_type, 'TMP', asn2.loc_sid, n.loc_sid) loc_sid,
            NVL (r.spram_balance, 0)
          + NVL (r.hpmsk_balance, 0)
          + NVL (r.wrm_balance, 0)
             rsp_inv,
            NVL (r.spram_level, 0)
          + NVL (r.wrm_level, 0)
          + NVL (r.hpmsk_level_qty, 0)
             rsp_level
     FROM RAMP r,
          (SELECT asp.part_no,
                  amd_utils.formatNsn (asp.nsn, 'GOLD') dashed_nsn
             FROM AMD_SPARE_PARTS asp,
                  AMD_NATIONAL_STOCK_ITEMS ansi,
                  AMD_NSI_PARTS anp
            WHERE     icp_ind = amd_defaults.getIcpInd
                  AND asp.part_no = anp.part_no
                  AND anp.prime_ind = 'Y'
                  AND UNASSIGNMENT_DATE IS NULL
                  AND asp.nsn = ansi.nsn
                  AND asp.action_code != 'D') asp,
          AMD_SPARE_NETWORKS n,
          AMD_SPARE_NETWORKS asn2
    WHERE     R.CURRENT_STOCK_NUMBER = asp.dashed_nsn
          AND n.loc_id = SUBSTR (r.sc(+), 8, 6)
          AND n.loc_type IN ('MOB',
                             'FSL',
                             'UAB',
                             'KIT')
          AND SUBSTR (r.sc, 8, 2) LIKE 'FB%'
          AND n.mob = asn2.loc_id(+)
          AND (     NVL (r.spram_balance, 0)
                  + NVL (r.hpmsk_balance, 0)
                  + NVL (r.wrm_balance, 0) > 0
               OR   NVL (r.spram_level, 0)
                  + NVL (r.wrm_level, 0)
                  + NVL (r.hpmsk_level_qty, 0) > 0);


GRANT SELECT ON AMD_OWNER.RSP_RAMP_INV_V TO AMD_READER_ROLE;
