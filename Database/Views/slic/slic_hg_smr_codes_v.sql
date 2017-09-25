DROP VIEW AMD_OWNER.SLIC_HG_SMR_CODES_V;

/* Formatted on 7/9/2012 4:34:50 PM (QP5 v5.163.1008.3004) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.SLIC_HG_SMR_CODES_V
(
   PART_NO,
   MFGR,
   SMR_CODE
)
AS
   SELECT refnumha part_no, cagecdxh mfgr, smrcodhg smr_code
     FROM (  SELECT cagecdxh,
                    refnumha,
                    smrcodhg,
                    ROW_NUMBER ()
                    OVER (
                       PARTITION BY cagecdxh, refnumha
                       ORDER BY
                          COUNT (smrcodhg) + LENGTH (TRIM (smrcodhg)) DESC,
                          smrcodhg DESC)
                       rnk
               FROM pslms_hg@amd_pslms_link.boeingdb
              WHERE smrcodhg <> '  '
           GROUP BY cagecdxh, refnumha, smrcodhg)
    WHERE rnk = 1;


DROP PUBLIC SYNONYM SLIC_HG_SMR_CODES_V;

CREATE OR REPLACE PUBLIC SYNONYM SLIC_HG_SMR_CODES_V FOR AMD_OWNER.SLIC_HG_SMR_CODES_V;


GRANT SELECT ON AMD_OWNER.SLIC_HG_SMR_CODES_V TO AMD_READER_ROLE;
