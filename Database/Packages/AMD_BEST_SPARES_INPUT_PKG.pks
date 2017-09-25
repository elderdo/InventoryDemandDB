CREATE OR REPLACE PACKAGE amd_best_spares_input_pkg as
/*
      $Author:   zf297a  $
    $Revision:   1.1  $
	    $Date:   Nov 30 2005 12:20:50  $
    $Workfile:   AMD_BEST_SPARES_INPUT_PKG.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_BEST_SPARES_INPUT_PKG.pks-arc  $
/*   
/*      Rev 1.1   Nov 30 2005 12:20:50   zf297a
/*   added PVCS keywords
*/	
	-- SCCSID: amd_best_spares_input_pkg.sql  1.1  Modified: 08/28/02 16:05:06
	--
	-- Date      By            History
	-- --------  ------------  -------------------------------------------
	-- 08/28/02  kcs		   Initial Implementation
	--
	--
	procedure getAsCapablePercent(pDate date DEFAULT sysdate);
	procedure getBliss;
	procedure getUpGradeable;
end amd_best_spares_input_pkg;
/
