CREATE OR REPLACE PACKAGE AMD_OWNER.amd_demand as
/*
      $Author:   zf297a  $
    $Revision:   1.23
        $Date:   22 Aug 2017
    $Workfile:   amd_demand.sql  $

       Rev 1.23 DSE 8/22/17 added loadWarnerRobinsDemands
       
       Rev 1.22 DSE 2/11/14 added get/set for doWarnings boolean flag

       Rev 1.21 DSE 2/11/14 Made CalcQuantity and CalcBadQuantity public for easy testing
       
      Rev 1.20  Renamed loadAmdDemands to loadAmdBssmSourceTmpAmdDemands

      Rev 1.19   Renamed amd_demand_a2a to load_amd_demands_table
   
      Rev 1.18   Added Procedure LoadFmsDemand per ClearQuest # LBPSS00002393 by Laurie Compton.
   
      Rev 1.17   11 Sep 2009 12:43:30   zf297a
     Added getVersion, setDebug, and getDebugYorN and added pragma for ErrorMsg 
   
      Rev 1.16   11 Sep 2009 12:39:48   zf297a
   Added interfaces getVersion, setDebug, and getDebugYorN
   
      Rev 1.15   24 Feb 2009 14:13:28   zf297a
   Removed a2a code
   
      Rev 1.14   03 Oct 2007 13:24:28   zf297a
   Changed interface getCurrentPeriod to getCalendarDate for a given period.
   Added interface getFiscalPeriod.
   
      Rev 1.13   20 Aug 2007 09:29:30   zf297a
   Merged branch 1.11.1.1 changes + added interface for procedure loadAllA2A
   
      Rev 1.11.1.1   01 Aug 2007 13:32:28   zf297a
   added duplicate to the doDmndFrcstConsumablesDiff.  Added interfaces for getCurrentPeriod and genDuplicateForConsumables.
   
      Rev 1.12   23 May 2007 00:11:54   zf297a
   Added interface for doDmndFrcstConsumablesDiff and added exception badActionCode.
   
      Rev 1.11   Jun 09 2006 12:51:12   zf297a
   added interface version

      Rev 1.10   Jul 27 2005 11:56:20   zf297a
   Modified by Dean Hoang for a2a transactions
*/

	--
	-- SCCSID: amd_demand.sql  1.9  Modified: 11/23/04 09:05:30
	--
	-- -------------------------------------------------------------------
	-- This program loads demand data into amd_af_reqs table.
	--
	-- Prior to execution of this procedure, we assume that the lcf data
	-- have been successfully loaded into tmp_lcf_raw table.
	--
	-- The temporary table amd_l67_tmp and tmp_lcf_icp should be truncated
	-- prior to the execution of the procedure.
	-- -------------------------------------------------------------------
	--
	-- Date     By     History
	-- 10/12/01 FF     Initial implementation
	-- 10/25/01 FF     Removed DedupL67() and moved into InsertL67TmpLcfIcp()
	-- 10/28/01 FF     Added LoadBascUkDemands().
	-- 11/21/01 FF     Removed use of mfgr, manuf_cage as part of key when
	--                 accessing data from amd_spare_parts
	-- 11/26/01 FF     Changed action_code to use defaults package.
	-- 12/13/01 FF     Added logic in Insertl67TmpLcfIcp() to handle 15-char
	--                 nsn's. MMC is added to NSN if numeric.
	-- 08/06/01 FF     Removed use of CalcReqDate(). Using trans_date instead.
	-- 10/23/02 FF     Added translation of loc_type='TMP' srans to its MOB val.
	-- 11/04/04 TP	   Added EY1213 to Request Id field.
	--

	badActionCode             EXCEPTION ;

	procedure loadAmdBssmSourceTmpAmdDemands;
    procedure LoadFmsDemands;
	procedure LoadBascUkDemands;
    procedure loadSanAntonioDemands;    
    procedure loadWarnerRobinsDemands;
    procedure unloadWarnerRobinsDemands;

	procedure load_amd_demands_table;
	procedure prime_part_change (old_part_no amd_national_stock_items.prime_part_no%TYPE,
                                new_part_no amd_national_stock_items.prime_part_no%TYPE);

    -- added by dse 5/22/2007
	FUNCTION doDmndFrcstConsumablesDiff(
			 nsn	IN VARCHAR2,
			 sran       IN VARCHAR2,
			 period		     IN NUMBER,
			 demand_forecast IN NUMBER,
             duplicate in NUMBER,
			 action_code IN VARCHAR2) RETURN NUMBER ;
							
	-- added 6/9/2006 by dse
	procedure version ;
    -- added 7/31/2007 by dse
    
    procedure genDuplicateForConsumables ;
    function getCalendarDate(period in number) return date ;
    function getFiscalPeriod(aDate in date) return number ;

	function getVersion return varchar2 ;
    function getDebugYorN return varchar2 ;
	procedure setDebug(switch in varchar2) ;
    
    function getDoWarningsYorN return varchar2 ;
    procedure setDoWarnings(switch varchar2) ;


    FUNCTION CalcQuantity(
                            pDocNo VARCHAR2,
                            pNsn varchar2,
                            pDic VARCHAR2) RETURN NUMBER;
                            
    FUNCTION CalcBadQuantity(
                            pDocNo VARCHAR2,
                            pNsn varchar2,
                            pDic VARCHAR2) RETURN NUMBER;


end amd_demand;
/