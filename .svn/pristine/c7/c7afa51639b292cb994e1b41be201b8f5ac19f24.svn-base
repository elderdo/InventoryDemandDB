    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 23 2005 11:40:38  $
     $Workfile:   amd_part_ids.sql  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\Views\amd_part_ids.sql-arc  $
/*   
/*      Rev 1.0   May 23 2005 11:40:38   c970183
/*   Initial revision.
*/
SELECT
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

