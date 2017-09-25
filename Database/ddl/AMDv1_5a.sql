SPOOL AMDv1_5a.log;
SET ECHO ON;
/*+========================================================================+*/
/*| FILE: AMDv1_5a.sql                                                     |*/
/*|------------------------------------------------------------------------|*/
/*| Who | Date       | Description                                         |*/
/*|------------------------------------------------------------------------|*/
/*| PAB | Aug 19, 04 | Add PART_IDS view.                                  |*/
/*+========================================================================+*/

CREATE OR REPLACE VIEW AMD_OWNER.AMD_PART_IDS (
    PART_NO,
    MFGR_CAGE,
    CURRENT_PRIME_PART_NO,
    CURRENT_NSN,
    BEST_NOMENCLATURE)
  AS SELECT
    SP.PART_NO,
    SP.MFGR,
    NSI.PRIME_PART_NO,
    NSI.NSN,
    CASE WHEN (NSI.PRIME_PART_NO = SP.PART_NO AND NSI.NOMENCLATURE_CLEANED IS NOT NULL)
      THEN NSI.NOMENCLATURE_CLEANED
      ELSE SP.NOMENCLATURE
      END
  FROM AMD_OWNER.AMD_NATIONAL_STOCK_ITEMS NSI,
    AMD_OWNER.AMD_NSI_PARTS NP,
    AMD_OWNER.AMD_SPARE_PARTS SP 
  WHERE NSI.NSI_SID = NP.NSI_SID
    AND NP.PART_NO = SP.PART_NO
    AND NP.UNASSIGNMENT_DATE IS NULL
;

exec MTA_PRC_GRANT( 'G', 'SELECT', 'AMD_OWNER', 'AMD_PART_IDS', 'AMD_READER_ROLE' );

exec MTA_PRC_PUB_SYN( 'C', 'AMD_OWNER', 'AMD_PART_IDS');

SPOOL OFF;
SET ECHO OFF; 