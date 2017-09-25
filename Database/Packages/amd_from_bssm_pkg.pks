/* Formatted on 1/25/2017 2:47:24 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE AMD_OWNER.AMD_FROM_BSSM_PKG
AS
   /*
         $Author:   Douglas S Elder
       $Revision:   1.9
        $Date:      25 Jan 2017
       $Workfile:   amd_from_bssm_pkg.pks  $

         Rev 1.9   25 Jan 2017 DSE reformatted code
      Added interface for getVersion

         Rev 1.8   Sep 2, 2015   zf297a
      Added interface for getVersion

         Rev 1.7   Jun 09 2006 10:46:00   zf297a
      Added interface for version

         Rev 1.6   Nov 30 2005 12:26:02   zf297a
      added pvcs keywords
   */


   -------------------------------------------------------------------
   --  Date       By   History
   --  ----     --   -------
   --  10/10/01    ks   initial implementation
   --  04/02/02    ks   mic_code_lowest will not come from bssm anymore
   -------------------------------------------------------------------


   -- those values where bssm is currently the only source
   PROCEDURE LoadAmdPartFromBssmRaw;

   PROCEDURE LoadAmdBaseFromBssmRaw;

   PROCEDURE LoadAmdPartFromBssmRaw (pNsn bssm_parts.nsn%TYPE);

   PROCEDURE LoadAmdBaseFromBssmRaw (pNsn     bssm_base_parts.nsn%TYPE,
                                     pSran    bssm_base_parts.sran%TYPE);

   PROCEDURE LoadAmdPartLocTimePeriods;

   PROCEDURE UpdateAmdNsi (pBssmPartsRec bssm_parts%ROWTYPE);

   PROCEDURE UpdateAmdPartLocs (pBssmBaseRec bssm_base_parts%ROWTYPE);

   FUNCTION GetCurrentBssmNsn (pNsn bssm_parts.nsn%TYPE)
      RETURN bssm_parts.nsn%TYPE;

   FUNCTION ConvertCriticality (pCriticality bssm_parts.criticality%TYPE)
      RETURN VARCHAR2;

   FUNCTION ConvertItemType (pItemType bssm_parts.item_type%TYPE)
      RETURN amd_national_stock_items.item_type%TYPE;

   FUNCTION GetLocSid (pLocId amd_spare_networks.loc_id%TYPE)
      RETURN amd_spare_networks.loc_sid%TYPE;

   PROCEDURE version;

   FUNCTION getVersion
      RETURN VARCHAR2;

   AMD_WAREHOUSE_LOCID   CONSTANT VARCHAR2 (30) := 'CTLATL';
   BSSM_WAREHOUSE_SRAN   CONSTANT VARCHAR2 (1) := 'W';
END AMD_FROM_BSSM_PKG;
/