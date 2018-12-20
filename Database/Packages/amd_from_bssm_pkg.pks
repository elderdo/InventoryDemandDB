DROP PACKAGE AMD_OWNER.AMD_FROM_BSSM_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.AMD_FROM_BSSM_PKG AS
/*
      $Author:   zf297a  $
    $Revision:   1.7  $
	    $Date:   Jun 09 2006 10:46:00  $
    $Workfile:   amd_from_bssm_pkg.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_from_bssm_pkg.pks-arc  $

      Rev 1.7   Jun 09 2006 10:46:00   zf297a
   Added interface for version

      Rev 1.6   Nov 30 2005 12:26:02   zf297a
   added pvcs keywords
*/

   	   -------------------------------------------------------------------
	   --  Date	  		  By			History
	   --  ----			  --			-------
	   --  10/10/01		  ks			initial implementation
	   --  04/02/02		  ks			mic_code_lowest will not come from bssm anymore
	   -------------------------------------------------------------------


 	   	 -- those values where bssm is currently the only source
	   procedure LoadAmdPartFromBssmRaw;
	   procedure LoadAmdBaseFromBssmRaw;
	   procedure LoadAmdPartFromBssmRaw(pNsn bssm_parts.nsn%type);
   	   procedure LoadAmdBaseFromBssmRaw(pNsn bssm_base_parts.nsn%type,pSran bssm_base_parts.sran%type);
	   procedure LoadAmdPartLocTimePeriods;
	   procedure UpdateAmdNsi(pBssmPartsRec bssm_parts%rowtype);
	   procedure UpdateAmdPartLocs (pBssmBaseRec bssm_base_parts%rowtype);
	   function GetCurrentBssmNsn(pNsn bssm_parts.nsn%type) return bssm_parts.nsn%type;
       function ConvertCriticality(pCriticality bssm_parts.criticality%type) return varchar2;
	   function ConvertItemType(pItemType bssm_parts.item_type%type) return amd_national_stock_items.item_type%type;
	   function GetLocSid(pLocId amd_spare_networks.loc_id%type) return amd_spare_networks.loc_sid%type;
	   procedure version ;
	   AMD_WAREHOUSE_LOCID constant varchar2(30) := 'CTLATL';
	   BSSM_WAREHOUSE_SRAN constant varchar2(1) := 'W';
END AMD_FROM_BSSM_PKG;
 
/


DROP PUBLIC SYNONYM AMD_FROM_BSSM_PKG;

CREATE PUBLIC SYNONYM AMD_FROM_BSSM_PKG FOR AMD_OWNER.AMD_FROM_BSSM_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_FROM_BSSM_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_FROM_BSSM_PKG TO AMD_WRITER_ROLE;
