CREATE OR REPLACE PACKAGE amd_effectivity_tcto_pkg
as
/*
      $Author:   zf297a  $
    $Revision:   1.1  $
	    $Date:   Nov 30 2005 12:24:06  $
    $Workfile:   amd_effectivity_tcto_pkg.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_effectivity_tcto_pkg.pks-arc  $
/*   
/*      Rev 1.1   Nov 30 2005 12:24:06   zf297a
/*   added PVCS keywords
*/	
  --
	-- SCCSID: amd_effectivity_tcto_pkg.sql  1.3  Modified: 08/28/02 16:08:38
	--
	-- Date      By            History
	-- --------  ------------  -------------------------------------------
	-- 05/31/02  kcs		   Initial Implementation
    -- 08/19/02	 kcs		   move function getNsiLocDistribs here for performance

  TYPE ref_cursor IS REF CURSOR;
  procedure updateAnsiAudit(pNsiSid amd_national_stock_items.nsi_sid%type);
  procedure updateAsFlyAsCapable(pTcto amd_retrofit_schedules.tcto_number%type, pTailNo amd_retrofit_schedules.tail_no%type, pDate date);
  procedure updateAsFlyAsCapable(pFieldName varchar2, pFieldValue varchar2, pTailNo amd_aircrafts.tail_no%type, pDate date);
  function getAcAssignLocSid(pTailNo amd_ac_assigns.tail_no%type, pDate date) return amd_spare_networks.loc_sid%type;
  function getNsiLocDistribs(pNsiSid integer) return ref_cursor;
  pragma restrict_references(getAcAssignLocsid, WNDS);
end amd_effectivity_tcto_pkg;
/
