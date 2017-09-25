CREATE OR REPLACE PACKAGE amd_effectivity_pkg as
/*
      $Author:   zf297a  $
    $Revision:   1.1  $
	    $Date:   Nov 30 2005 12:24:06  $
    $Workfile:   amd_effectivity_pkg.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_effectivity_pkg.pks-arc  $
/*   
/*      Rev 1.1   Nov 30 2005 12:24:06   zf297a
/*   added PVCS keywords
*/	
	--
	-- SCCSID: amd_effectivity_pkg.sql  1.15  Modified: 09/04/02 14:55:03
	--
	-- Date      By            History
	-- --------  ------------  -------------------------------------------
	-- 05/16/02  Fernando F.   Initial Implementation
	-- 06/18/02  Fernando F.   Added derived colunn to cur_loc_distribs.
	-- 06/20/02  Fernando F.   Fixed updating of by-fleet.
	-- 06/25/02  Fernando F.   Added generation of default cur_loc_dis recs.
	-- 07/01/02  Fernando F.   Fixed update so acld.user_defined isn't updated.
	-- 07/10/02  Fernando F.   Added updateAssetMgmtStatus().
	-- 07/25/02  Fernando F.   Added genDistribution() functions.
	-- 07/26/02  Fernando F.   Fixed rebuildChild() to qualify queries with
	--                         tail_no liked to a_l_f_s_m table.
	-- 08/01/02  Fernando F.   Fixed genFlyingByShip to qualify tails against
	--                         a_l_f_s_m.
	-- 08/05/02  Fernando F.   Moved genFlyingAltus() to the spec.
	-- 08/06/02  Fernando F.   Fixed genCapableByShip() to add as capable
	--                         correctly for 'limited' interchangeability.
	-- 08/06/02  Fernando F.   Added batchProcess() to run everything.
	-- 08/14/02  Fernando F.   Moved genFlyingAltus() to the body and
	--                         fixed genAsCapable().
	-- 08/15/02  Fernando F.   Fixed genAsCapable() to handle Altus differently.
	--                         Added update of fsl's asCapable.
	-- 08/19/02  Fernando F.   Fixed genAsCapable() by adding FOREVER constant
	--                         to the nvl statement.
	-- 08/29/02  Fernando F.   Fixed rebuildchild() to update ansi table
	--                         with effect_by='F' when updating for fleet.
	--                         Also to update effect_by of child.
	-- 09/04/02  Fernando F.   Fixed rebuildChild() to update effect_by_attrb
	--                         and added isOrphan() and updateOrphanStatus().
	-- 09/04/02  Fernando F.   Trim the userid to 8 characters.
	--

	procedure rebuildChild(
							pChildSid number,
							pType varchar2 default 'S');
	procedure rebuildChildren(
							pParentSid number);
	--
	-- pType is 'F'lying or 'C'apable or 'A'ltus AsFlying.
	--
	procedure genDistribution(
							pType varchar2);
	procedure genDistribution(
							pNsn varchar2,
							pType varchar2);
	procedure genDistribution(
							pNsiSid number,
							pType varchar2);
	procedure buildTimePeriods(
							pCount number);
	procedure updateAssetMgmtStatus(
							pGroupSid number);
	procedure batchProcess;
end;
/
