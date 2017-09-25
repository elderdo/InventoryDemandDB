CREATE OR REPLACE package AmdDPPkg as
/*
      $Author:   c970183  $
    $Revision:   1.0  $
	    $Date:   May 17 2005 11:25:40  $
    $Workfile:   AMDDPPKG.pks  $
         $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\Packages\AMDDPPKG.pks-arc  $
/*   
/*      Rev 1.0   May 17 2005 11:25:40   c970183
/*   Initial revision.
*/
	--
	-- SCCSID: amddppkg.sql  1.5  Modified: 09/24/01 17:38:58
	--
	-- Date      By    History
	-- --------  ----  ----------------------------------------------------
	-- 09/10/01  FF    Initial
	-- 09/18/01  FF    changed loc_id to loc_sid
	-- 09/21/01  FF    Changed allocation query
	-- 09/21/01  FF    Changed allocation query
	-- 09/24/01  FF    Changed landing's allocation query
	--

	procedure ProcessFlightData;

end;
/
