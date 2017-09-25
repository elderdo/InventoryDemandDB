set define off
CREATE OR REPLACE PACKAGE AMD_OWNER.AMD_PARTPRIME_PKG AS
/*
      $Author:   zf297a  $
    $Revision:   1.2  $
     $Date:   30 Jan 2007 14:26:26  $
    $Workfile:   AMD_PARTPRIME_PKG.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_PARTPRIME_PKG.pks.-arc  $
/*   
/*      Rev 1.2   30 Jan 2007 14:26:26   zf297a
/*   added interface for updatePlannerCodesForSubParts
/*   
/*      Rev 1.1   Jun 09 2006 12:07:00   zf297a
/*   added interface version
/*   
/*      Rev 1.0   Dec 01 2005 09:41:48   zf297a
/*   Initial revision.
*/
   	  /* The following "getSuperPrime" functions
	  	 first checks for a super relationship in bssm_rbl_pairs.
		 if super relationship not available or super relationship part does not meet
		 minimum a2a requirement (i.e. exists in AMD_SENT_TO_A2A with action_code != 'D')
		 it will use the prime in amd_national_stock_items - however at this point
		 it does not check if the prime in amd_national_stock_items meets minimum a2a requirement */
	   FUNCTION getSuperPrimePart(pPart VARCHAR2) RETURN VARCHAR2 ;
   	   FUNCTION getSuperPrimePartByNsiSid(pNsiSid NUMBER) RETURN VARCHAR2 ;
	   FUNCTION getSuperPrimeNsiSid(pPart VARCHAR2) RETURN NUMBER ;
	   FUNCTION getSuperPrimeNsiSidByNsn(pNsn VARCHAR2) RETURN NUMBER ;
   	   FUNCTION getSuperPrimeNsiSidByNsiSid(pNsiSid NUMBER) RETURN NUMBER ;


	   -- The following takes into account if returned value also meets minimum a2a requirments
	   FUNCTION getSuperPrimeNsiSidByNsn_A2A(pNsn VARCHAR2) RETURN NUMBER ;

	   PROCEDURE DiffPartToPrime ;
	   -- added 11/11/05 dse
	   FUNCTION getPrimePartAMD(pNsn VARCHAR2)
		 RETURN VARCHAR2 ;

	   FUNCTION getNsn(pPart VARCHAR2)
		 RETURN VARCHAR2 ;

		 -- added 6/9/2006 by dse
		 procedure version ;

        -- added 1/30/2007 by dse
        procedure updatePlannerCodesForSubParts ;
    
END ;
/

show errors


CREATE OR REPLACE PACKAGE AMD_OWNER.AMD_PART_LOC_FORECASTS_PKG AS
 /*
      $Author:   zf297a  $
	$Revision:   1.9  $
        $Date:   Nov 01 2006 11:37:44  $
    $Workfile:   AMD_PART_LOC_FORECASTS_PKG.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_PART_LOC_FORECASTS_PKG.pks.-arc  $
/*   
/*      Rev 1.9   Nov 01 2006 11:37:44   zf297a
/*   Added interfaces for hasValidDate and hasValidDateYorN
/*   
/*      Rev 1.8   Aug 18 2006 15:44:40   zf297a
/*   Added interface doExtforecast and made insertTmpA2A_EF_AllPeriods public.
/*   
/*      Rev 1.7   Jul 26 2006 10:10:42   zf297a
/*   Made getLatestRblRunBssm public.  Made getCurrentPeriod, setCurrentPeriod, getLatestRblRunAmd, and setLatestRblRunAmd public.
/*   
/*      Rev 1.6   Jul 26 2006 09:43:34   zf297a
/*   Made getCurrentPeriod a public routine.
/*   
/*      Rev 1.5   Jun 09 2006 12:16:58   zf297a
/*   added interface version
/*   
/*      Rev 1.4   May 12 2006 14:38:56   zf297a
/*   added action_code to type partLocForecastsRec.
/*   
/*      Rev 1.3   Feb 15 2006 21:52:10   zf297a
/*   Added a ref cursor, a type, and a common process routine.
/*   
/*      Rev 1.1   Jan 03 2006 07:56:40   zf297a
/*   Added procedure loadA2AByDate
/*   
/*      Rev 1.0   Dec 01 2005 09:44:12   zf297a
/*   Initial revision.
*/
	PARAMS_LATEST_RBL_RUN_DATE VARCHAR2(50) := 'ext_forecast_last_rbl_run_date' ;
	PARAMS_CURRENT_PERIOD_DATE VARCHAR2(50) := 'ext_forecast_current_period' ;
	ROLLING_PERIOD_MONTHS CONSTANT NUMBER := 60 ;
	PARAM_USER VARCHAR2(50) := 'bsrm_loader' ;
	DEMAND_FORECAST_TYPE VARCHAR2(10) := 'External' ;
	-- decimal precision for forecast_qty --
	DP CONSTANT NUMBER := 4 ;
	
	SUCCESS							CONSTANT NUMBER := 0 ;
	FAILURE							CONSTANT NUMBER := 4 ;
	type partLocForecastsRec is record (
		 part_no amd_part_loc_forecasts.PART_NO%type, 
		 spo_location amd_spare_networks.SPO_LOCATION%type, 
		 forecast_qty amd_part_loc_forecasts.FORECAST_QTY%type,
		 action_code amd_part_loc_forecasts.action_code%type
	) ;
	type partLocForecastsCur is ref cursor return partLocForecastsRec ;
	procedure processPartLocForecasts(partLocForecasts in partLocForecastsCur) ;
	
	FUNCTION getLatestRblRunBssm(lockName in bssm_locks.NAME%type) RETURN DATE ;
	
	FUNCTION getLatestRblRunAmd RETURN DATE ;
	PROCEDURE setLatestRblRunAmd(pRblRunDate DATE) ;
	
	FUNCTION getCurrentPeriod RETURN DATE ;
	PROCEDURE setCurrentPeriod(pCurrentPeriodDate DATE) ;
	
	FUNCTION GetFirstDateOfMonth(pDate DATE) RETURN DATE ;
	pragma restrict_references(GetFirstDateOfMonth, WNDS) ;
	
	/*
	 returns 1 if not empty, 0 if empty, -1 if any problem e.g.table not oracle table
	*/
	-- FUNCTION IsTableEmpty(pTableName VARCHAR2) RETURN NUMBER  ;
	
	FUNCTION InsertRow(
			pPartNo                     amd_part_loc_forecasts.part_no%TYPE,
			pLocSid                     amd_part_loc_forecasts.loc_sid%TYPE,
			pForecastQty				amd_part_loc_forecasts.forecast_qty%TYPE )
			return NUMBER ;
	
	FUNCTION Updaterow(
			pPartNo                     amd_part_loc_forecasts.part_no%TYPE,
			pLocSid                     amd_part_loc_forecasts.loc_sid%TYPE,
			pForecastQty				amd_part_loc_forecasts.forecast_qty%TYPE )
			RETURN NUMBER ;
	
	
	FUNCTION DeleteRow(
			pPartNo                     amd_part_loc_forecasts.part_no%TYPE,
			pLocSid                     amd_part_loc_forecasts.loc_sid%TYPE,
			pForecastQty				amd_part_loc_forecasts.forecast_qty%TYPE )
			RETURN NUMBER ;
	
	PROCEDURE LoadAllA2A ;
	PROCEDURE LoadInitial ;
	
	PROCEDURE LoadLatestRblRun ;
	PROCEDURE LoadTmpAmdPartLocForecasts_Add ;
	procedure loadA2AByDate(from_dt in date := a2a_pkg.start_dt, to_dt in date := sysdate) ;
	-- added 8/17/2006
	procedure doExtForecast ;
	-- added 8/18/2006
	PROCEDURE InsertTmpA2A_EF_AllPeriods(pPartNo VARCHAR2, pLocation VARCHAR2, pStartPeriod DATE, pQty NUMBER, pActionCode VARCHAR2, pLastUpdateDt DATE ) ;
	
	-- added 6/9/2006 by dse
	procedure version ;
	
	-- added 11/1/2006 by dse
	FUNCTION hasValidDate(lockName in bssm_locks.NAME%type) RETURN boolean ;
	-- added 11/1/2006 by dse
	function hasValidDateYorN(lockName in bssm_locks.NAME%type) RETURN varchar2 ;


END AMD_PART_LOC_FORECASTS_PKG ;
/

show errors

CREATE OR REPLACE PACKAGE AMD_OWNER.Amd_Location_Part_Override_Pkg AS
 /*
      $Author:   zf297a  $
	$Revision:   1.14  $
        $Date:   26 Jan 2007 09:47:16  $
    $Workfile:   AMD_LOCATION_PART_OVERRIDE_PKG.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_LOCATION_PART_OVERRIDE_PKG.pks.-arc  $
/*   
/*      Rev 1.14   26 Jan 2007 09:47:16   zf297a
/*   Added procedure interface for deleteRspTslA2A
/*   
/*      Rev 1.13   Dec 13 2006 12:00:16   zf297a
/*   Added interfaces isTmpA2AOkay and isTmpA2AOkayYorN
/*   
/*      Rev 1.12   Dec 05 2006 14:53:46   zf297a
/*   Changed interface for processTsl - removed unnessary paramater pDoAllA2A since the cursor has already done the filtering.
/*   
/*      Rev 1.11   Oct 25 2006 10:53:04   zf297a
/*   Defined constants with anchored declarations using the %type attribute.  Made loadOverrideUsers a public procedure.
/*   
/*      Rev 1.10   Aug 24 2006 10:33:28   zf297a
/*   Added a constant for the loc_sid warehouse value
/*   
/*      Rev 1.9   Jun 09 2006 11:55:42   zf297a
/*   added interface version
/*   
/*      Rev 1.8   Apr 28 2006 13:15:54   zf297a
/*   Added the interface for loadRspZeroTslA2A
/*   
/*      Rev 1.7   Apr 21 2006 13:50:40   zf297a
/*   Added isInTmpA2A, isInTmpA2AYorN, loadZeroTslByDate, and InsertTmpA2ALPO
/*   
/*      Rev 1.6   Feb 24 2006 15:08:32   zf297a
/*   Modified the interfaces for some TSL procedures and load procedures.
/*   
/*      Rev 1.5   Feb 15 2006 21:22:54   zf297a
/*   Added ref cursor's, type's and common process routines.
/*   
/*      Rev 1.4   Jan 03 2006 12:56:26   zf297a
/*   Added date range to procedures loadZeroTslA2AByDate and loadA2AByDate
/*   
/*      Rev 1.3   Jan 03 2006 09:13:06   zf297a
/*   Changed name from loadByDate to loadA2AByDate
/*   
/*      Rev 1.2   Dec 30 2005 01:20:08   zf297a
/*   add loadByDate
/*
/*      Rev 1.1   Nov 10 2005 11:10:46   zf297a
/*   Added interfaces getInsertCnt, getDeleteCnt, and getUpdateCnt.  Changed the interface for LoadAllA2A to have an optional boolean argument that can control the use of "test data".
/*
/*      Rev 1.0   Oct 18 2005 19:12:48   c394547
/*   Initial revision.
		 */

	OVERRIDE_TYPE 	  	 	 CONSTANT tmp_a2a_loc_part_override.OVERRIDE_TYPE%type := 'TSL Fixed' ;
	OVERRIDE_REASON 		 CONSTANT tmp_a2a_loc_part_override.OVERRIDE_REASON%type := 'Fixed TSL Load' ;
	THE_WAREHOUSE 			 CONSTANT amd_spare_networks.spo_location%type := 'FD2090' ;
	THE_WAREHOUSE_LOC_SID 	 CONSTANT amd_spare_networks.LOC_SID%type := 256 ;
	
	BULKLIMIT CONSTANT NUMBER := 100000 ;
	COMMITAFTER CONSTANT NUMBER := 100000 ;
	SUCCESS							CONSTANT NUMBER := 0 ;
	FAILURE							CONSTANT NUMBER := 4 ;
	
	
	TYPE locPartOverrideRec IS RECORD (
		 part_no AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
		 site_location AMD_SPARE_NETWORKS.SPO_LOCATION%TYPE,
		 override_type VARCHAR2(32),
	     override_quantity AMD_LOCATION_PART_OVERRIDE.TSL_OVERRIDE_QTY%TYPE,
		 override_reason VARCHAR2(64),
		 tsl_override_user AMD_LOCATION_PART_OVERRIDE.TSL_OVERRIDE_USER%TYPE,
		 begin_date DATE,
		 end_date DATE,
		 action_code AMD_LOCATION_PART_OVERRIDE.ACTION_CODE%TYPE,
		 last_update_dt AMD_LOCATION_PART_OVERRIDE.LAST_UPDATE_DT%TYPE
	) ;
	
	TYPE tslRec IS RECORD (
		 spo_prime_part_no AMD_SENT_TO_A2A.SPO_PRIME_PART_NO%TYPE,
		 action_code AMD_SENT_TO_A2A.ACTION_CODE%TYPE,
		 transaction_date AMD_SENT_TO_A2A.TRANSACTION_DATE%TYPE,
		 spo_location AMD_SPARE_NETWORKS.SPO_LOCATION%TYPE,
		 nsn AMD_NATIONAL_STOCK_ITEMS.nsn%TYPE,
		 nsi_sid AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE,
		 override_quantity AMD_LOCATION_PART_OVERRIDE.TSL_OVERRIDE_QTY%TYPE
	) ;
	
	TYPE locPartOverrideCur IS REF CURSOR RETURN locPartOverrideRec ;
	TYPE tslCur IS REF CURSOR RETURN tslRec ;
	
	PROCEDURE processLocPartOverride(locPartOverride IN locPartOverrideCur) ;
	PROCEDURE processTsl(tsl IN tslCur) ;
	
	PROCEDURE LoadInitial ;
	PROCEDURE loadA2AByDate( from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE) ;
	PROCEDURE LoadAllA2A (useTestData IN BOOLEAN := FALSE, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE) ;
	PROCEDURE LoadZeroTslA2A(doAllA2A IN BOOLEAN := FALSE, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE) ;
	PROCEDURE LoadTmpAmdLocPartOverride ;
	PROCEDURE LoadZeroTslA2A(pDoAllA2A BOOLEAN, pSpoLocation VARCHAR2, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE)   ;
	
	
	FUNCTION InsertRow(
			pPartNo                      AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			pLocSid                      AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			pTslOverrideQty				 AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE ,
			pTslOverrideUser			 AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE )
			RETURN NUMBER ;
	
	FUNCTION Updaterow(
			pPartNo                      AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			pLocSid                      AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			pTslOverrideQty				 AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE ,
			pTslOverrideUser			 AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE )
			RETURN NUMBER ;
	
	
	
	FUNCTION DeleteRow(
			pPartNo                      AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			pLocSid                      AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			pTslOverrideQty				 AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE ,
			pTslOverrideUser			 AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE )
			RETURN NUMBER ;
	
			-- return Y or N
	FUNCTION IsNumeric(pString VARCHAR2) RETURN VARCHAR2 ;
	PRAGMA RESTRICT_REFERENCES(IsNumeric, WNDS) ;
	
	-- testing
	FUNCTION GetFirstLogonIdForPart(pNsiSid AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE) RETURN AMD_PLANNER_LOGONS.logon_id%TYPE ;
	-- added 11/7/05 dse
	FUNCTION getInsertCnt RETURN NUMBER ;
	FUNCTION getUpdateCnt RETURN NUMBER ;
	FUNCTION getDeleteCnt RETURN NUMBER ;
	
	-- added 02/23/2006 dse
	-- these functions allow  stand alone SQL to use the package constants
	FUNCTION getOVERRIDE_TYPE RETURN VARCHAR2 ;
	FUNCTION getOVERRIDE_REASON RETURN VARCHAR2 ;
	FUNCTION getBULKLIMIT RETURN NUMBER ;
	FUNCTION getCOMMITAFTER RETURN NUMBER ;
	FUNCTION getSUCCESS RETURN NUMBER ;
	FUNCTION getFAILURE RETURN NUMBER ;
	FUNCTION getTHE_WAREHOUSE RETURN VARCHAR2 ;
	FUNCTION isInTmpA2AYorN(part_no IN TMP_A2A_LOC_PART_OVERRIDE.part_no%TYPE, site_location IN TMP_A2A_LOC_PART_OVERRIDE.SITE_LOCATION%TYPE) RETURN VARCHAR2 ;
	FUNCTION isInTmpA2A(part_no IN TMP_A2A_LOC_PART_OVERRIDE.part_no%TYPE, site_location IN TMP_A2A_LOC_PART_OVERRIDE.SITE_LOCATION%TYPE) RETURN BOOLEAN ;
	 
	PROCEDURE loadZeroTslA2APartsWithNoTsls(doAllA2A IN BOOLEAN := FALSE, useTestData IN BOOLEAN := FALSE ) ;
	PROCEDURE loadRspZeroTslA2A(doAllA2A IN BOOLEAN := FALSE, useTestData in boolean := false) ;
    PROCEDURE deleteRspTslA2A ;
	PROCEDURE loadZeroTslA2A4DelSpoPrimParts(doAllA2A IN BOOLEAN := FALSE, useTestData IN BOOLEAN := FALSE) ;
	PROCEDURE loadTslA2AWarehouseParts(doAllA2A IN BOOLEAN := FALSE, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE) ;
	
	PROCEDURE loadZeroTslA2AByDate(pDoAllA2A IN BOOLEAN, 
			  from_dt IN DATE, to_dt IN DATE, pSpolocation IN VARCHAR2) ;
	
	FUNCTION insertedTmpA2ALPO (
				  pPartNo			TMP_A2A_LOC_PART_OVERRIDE.part_no%TYPE,
				  pBaseName			TMP_A2A_LOC_PART_OVERRIDE.site_location%TYPE,
				  pOverrideType		TMP_A2A_LOC_PART_OVERRIDE.override_type%TYPE,
				  pTslOverrideQty	TMP_A2A_LOC_PART_OVERRIDE.override_quantity%TYPE,
				  pOverrideReason	TMP_A2A_LOC_PART_OVERRIDE.override_reason%TYPE,
				  pTslOverrideUser	TMP_A2A_LOC_PART_OVERRIDE.override_user%TYPE,
				  pBeginDate		TMP_A2A_LOC_PART_OVERRIDE.begin_date%TYPE,
				  pActionCode		TMP_A2A_LOC_PART_OVERRIDE.action_code%TYPE,
				  pLastUpdateDt		TMP_A2A_LOC_PART_OVERRIDE.last_update_dt%TYPE
				  ) RETURN BOOLEAN ;
	
	-- added 6/9/2006 by dse
	procedure version ;
	
	-- added 9/1/2006 by dse		
	procedure LoadOverrideUsers ;
	
	-- added 12/5/2006 by dse
	function isTmpA2AOkay return boolean ;
	function isTmpA2AOkayYorN return varchar2 ;

		
END Amd_Location_Part_Override_Pkg ;
/


show errors

CREATE OR REPLACE PACKAGE AMD_OWNER.amd_load as
    /*
	    PVCS Keywords

       $Author:   c402417  $
     $Revision:   1.17  $
         $Date:   Jan 17 2007 16:23:08  $
     $Workfile:   amd_load.pks  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_load.pks-arc  $
   
      Rev 1.17   Jan 17 2007 16:23:08   c402417
   Added Procedure LoadRblPairs right after  Procedure LoadGold .
   
      Rev 1.16   Oct 31 2006 14:45:08   zf297a
   added interface validatePartStructure
   
      Rev 1.15   Jun 09 2006 11:44:42   zf297a
   added interface version

      Rev 1.14   Mar 20 2006 08:57:00   zf297a
   Added  "Future use" comments

      Rev 1.13   Mar 16 2006 15:07:46   zf297a
   Added exception no_active_job

      Rev 1.12   Mar 16 2006 10:36:08   zf297a
   Exposed functions and procedures to allow for easy unit testing.

      Rev 1.11   Mar 05 2006 21:19:14   zf297a
   Added interfaces for loadGoldPsmsMain, preProcess, postProcess, postDiffProcess, prepAmdDatabase, disableAmdConstraints, truncateAmdTables, and enableAmdConstraints to simplify the amd_loader.ksh script.

      Rev 1.10   Aug 16 2005 14:12:30   zf297a
   removed loadCurrentBackorder

      Rev 1.9   Aug 04 2005 13:34:44   zf297a
   Added interfaces for Users diff.

      Rev 1.8   Aug 04 2005 07:06:14   zf297a
   Made functions 	GetOffBaseRepairCost and GetOffBaseTurnAround public.

      Rev 1.7   Jul 26 2005 12:31:44   zf297a
   added function getBemsId.  This function will return a bems_id for an employee_no as defined in amd_use1.  The function will remove any semi colon or trailing alpha character.  If the the employee_no is the 'clock number' it will retrieve the bems_id via the emp_id of the amd_people_all_v.

      Rev 1.6   Jul 19 2005 14:22:50   zf297a
   added procedure loadUsers - populates the amd_users table and sends inserts, updates, and deletes via the a2a_pgk.spoUser procedure.

      Rev 1.5   Jun 09 2005 14:58:58   c970183
   Added insert, update, and delete routines for the amd_planners diff and the amd_planner_logons diff.

      Rev 1.4   May 17 2005 10:20:14   c970183
   Added PVCS keywords
*/
	--
	-- SCCSID: amd_load.sql  1.21  Modified: 10/25/04 10:35:34
	--
	-- Date     By     History
	-- -------- -----  ---------------------------------------------------
	-- 09/28/01 FF     Initial implementation
	-- 10/22/01 FF     Removed references to venc, venn from LoadGold().
	-- 10/23/01 FF     Changed exception in LoadTempNsns() and passed GOLD
	--                 smr_code if nothing else.
	-- 10/30/01 FF     Fixed getPrime() to look at all records for a '17P','17B'
	--                 match.
	-- 11/02/01 FF     Fixed logic in LoadTempNsns() to include GetPrime() and
	--                 associate logic.
	-- 11/12/01 FF     Fixed LoadGold() to use the part as prime for ANY NSL
	--                 that gets an nsn from BSSM other than of the form NSL#.
	-- 11/15/01 FF     Mod LoadGold() and LoadMain() to let equiv parts get
	--                 values from prime for item_type,order_quantity,
	--                 planner_code and smr_code.
	-- 11/19/01 FF     Mod LoadTempNsns to ignore the last 2 char's of the nsn
	--                 if they are not numeric.
	-- 11/21/01 FF     Removed references to gold_mfgr_cage.
	-- 11/29/01 FF     Fixed LoadTempNsns() and added lock_sid=0 condition
	--                 to cursor in LoadTempNsns().
	-- 12/10/01 FF     Fixed cursor in LoadTempNsns() to link with
	--                 amd_spare_parts.
	-- 12/21/01 FF     Added acquisition_advice_code.
	-- 01/28/02 FF     Added "FROM" column as temp nsns to LoadTempNsns().
	-- 02/19/02 FF     Added logic for manuf_cage to GetPrime().
	-- 02/25/02 FF     Fixed GetPrime() priority logic.
	-- 03/05/02 FF     Added logic to unit_cost code to look at po's with 9
	--                 characters only.
	-- 03/18/02 FF     The noun field is no longer truncated.
	-- 04/03/02 FF     Populated mic in tmp_amd_spare_parts.
	-- 06/04/02 FF     Removed debug record limiter.
	-- 06/14/02 FF     Changed references to PSMS to use synonyms.
	-- 07/05/02 FF     Changed references to PSMV to use synonyms.
	-- 10/14/02 FF     Mod'ed loadGold() to blindly assign the part as a prime
	--                 only if sequenceTheNsl() returned an nsn of type NSL.
	-- 11/05/02 FF     Get unit_cost from gold.prc1 instead of tmp_main. This
	--                 is now done in loadGold() instead of loadMain().
	-- 02/21/03 FF     Added performLogicalDelete() to allow NSL's to get
	--                 their own sid.
	-- 09/22/04 TP	   Changed how we pull SMR Code from PSMS to GOLD .
	--

	-- expose the following functions and procedures to allow for easy routine validation and unit testing
	no_active_job exception ;

	FUNCTION  IsValidSmr(pSmrCode VARCHAR2) RETURN BOOLEAN;
	FUNCTION  GetSmr(pPsmsInst VARCHAR2, pPart VARCHAR2, pCage VARCHAR2) RETURN VARCHAR2;
	FUNCTION  GetPrime(pNsn CHAR) RETURN VARCHAR2;
	FUNCTION  getMic(pNsn VARCHAR2) RETURN VARCHAR2;
	FUNCTION  getUnitCost(pPartNo VARCHAR2) RETURN NUMBER;
	FUNCTION  GetPsmsInstance (pPart VARCHAR2, pCage VARCHAR2) RETURN VARCHAR2;
	FUNCTION  GetItemType(pSmrCode VARCHAR2) RETURN VARCHAR2;
	FUNCTION  getMmac(pNsn VARCHAR2) RETURN VARCHAR2;
	FUNCTION  onNsl(pPartNo VARCHAR2) RETURN BOOLEAN;

	procedure getOriginalBssmData(nsn in amd_nsns.nsn%type,
		 part_no in bssm_owner.bssm_parts.PART_NO%type,
		 condemn_avg out amd_national_stock_items.condemn_avg%type,
		 criticality out amd_national_stock_items.criticality%type,
		 mtbdr_computed out amd_national_stock_items.mtbdr_computed%type,
		 nrts_avg out amd_national_stock_items.nrts_avg%type,
		 rts_avg out amd_national_stock_items.rts_avg%type) ;

	procedure getCleanedBssmData(nsn in amd_nsns.nsn%type,
		part_no 				in bssm_owner.bssm_parts.part_no%type,
		condemn_avg_cleaned 	out amd_national_stock_items.condemn_avg_cleaned%type,
		criticality_cleaned 	out amd_national_stock_items.criticality_cleaned%type,
		mtbdr_cleaned 			out amd_national_stock_items.mtbdr_cleaned%type,
		nrts_avg_cleaned 		out amd_national_stock_items.nrts_avg_cleaned%type,
		rts_avg_cleaned 		out amd_national_stock_items.rts_avg_cleaned%type,
		order_lead_time_cleaned out amd_national_stock_items.order_lead_time_cleaned%type,
		planner_code_cleaned 	out amd_national_stock_items.planner_code_cleaned%type,
		smr_code_cleaned 		out amd_national_stock_items.smr_code_cleaned%type,
		unit_cost_cleaned 		out amd_national_stock_items.unit_cost_cleaned%type,
		cost_to_repair_off_base_cleand out amd_national_stock_items.cost_to_repair_off_base_cleand%type,
		time_to_repair_off_base_cleand out amd_national_stock_items.time_to_repair_off_base_cleand%type) ;

	PROCEDURE getRmadsData (part_no in amd_rmads_source_tmp.part_no%type, qpei_weighted out amd_rmads_source_tmp.QPEI_WEIGHTED%type,
		mtbdr out amd_rmads_source_tmp.MTBDR%type) ;

	PROCEDURE GetPsmsData(pPartNo VARCHAR2, pCage VARCHAR2, pPsmsInst VARCHAR2,
			  pSlifeDay OUT NUMBER, pUnitVol  OUT NUMBER, pSmrCode  OUT VARCHAR2);


	procedure LoadGold;
	procedure LoadRblPairs;
	procedure LoadPsms;
	procedure LoadMain;
	procedure LoadTempNsns;
	procedure loadUsers ;

	-- For future use
	-- The following procedures: loadGoldPsmsMain, preProcess, postProcess, & postDiffProcess,
	-- may be used to replace the bulky sql scripts currently used by amd_loader.ksh
	procedure loadGoldPsmsMain(startStep in number := 1, endStep in number := 3) ;
	procedure preProcess(startStep in number := 1, endStep in number := 3) ;
	procedure postProcess(startStep in number := 1, endStep in number := 18) ;
	procedure postDiffProcess(startStep in number := 1, endStep in number := 3) ;
	-- For future use
	-- The following procedures: prepAmdDatabase, disableAmdConstraints, truncateAmdTables, &
	-- enableAmdConstraints can be be used in conjunction with the above procedures
	procedure prepAmdDatabase ;
	procedure disableAmdConstraints ;
	procedure truncateAmdTables ;
	procedure enableAmdConstraints ;


	SUCCESS constant number := 0 ;
	FAILURE constant number := 4 ;

	-- for amd_planners diff
	function insertRow(planner_code in varchar2) return number ;
	function updateRow(planner_code in varchar2) return number ;
	function deleteRow(planner_code in varchar2) return number ;

	-- for amd_planner_logons diff
	function insertplannerlogons(planner_code in varchar2, logon_id in varchar2, data_source in varchar2) return number ;
	function updatePlannerLogons(planner_code in varchar2, logon_id in varchar2, data_source in varchar2) return number ;
	function deletePlannerLogons(planner_code in varchar2, logon_id in varchar2, data_source in varchar2) return number ;

	function getBemsId(employeeNo in amd_use1.EMPLOYEE_NO%type) return amd_users.BEMS_ID%type ;

	function GetOffBaseRepairCost(pPartNo char) return amd_part_locs.cost_to_repair%type ;
	function GetOffBaseTurnAround (pPartno char) return amd_part_locs.time_to_repair%type ;

	type resultSetCursor is REF cursor ;
	function getNewUsers return resultSetCursor ;
	function insertUsersRow(bems_id in varchar2, stable_email in varchar2, last_name in varchar2, first_name in varchar2) return number ;
	function updateUsersRow(bems_id in varchar2, stable_email in varchar2, last_name in varchar2, first_name in varchar2) return number ;
	function deleteUsersRow(bems_id in varchar2) return number ;
	
	-- added 6/9/2006 by DSE
	procedure version ;
	
	-- added 10/30/2006 by DSE
	procedure validatePartStructure ;

end amd_load;
/

show errors

CREATE OR REPLACE PACKAGE AMD_OWNER.Amd_Inventory AS
	--
	-- SCCSID: %M%  %I%  Modified: %G% %U%
	--
	-- Date     By     History
	-- -------- -----  ---------------------------------------------------
	-- 10/14/01 FF     Initial implementation
	-- 11/01/01 FF     Changed LoadGoldInventory() to accept parameter as
	--                 char to match item.prime char datatype.
	-- 11/07/01 FF     Implemented WWA mod. Removed GetLocSid().
	-- 11/21/01 FF     Removed references to gold_mfgr_cage.
	-- 11/26/01 FF     Changed action_code to use defaults package.
	-- 01/04/02 FF     Removed "tactical" check from select criteria.
	-- 01/23/02 FF     Added "distinct" keyword to partCur cursor.
	-- 02/20/02 FF     Modified load to be by part not roll up to prime.
	-- 03/05/02 FF     Fixed conditions for insert and rtrim()ed the join
	--                 to the ord1 table.
	-- 09/25/02 FF     Qualified all amd_spare_parts refereneces with
	--                 action_code != 'D'
	-- 10/23/02 FF     Added translation of loc_type='TMP' srans to its MOB val.
	-- 11/18/02 FF     Added exception handler to rampCur.
	-- 06/13/03 TP     Changed order_no prefixes from ord1 table.
	-- 04/05/04 TP	   Removed 'TC' as a valid order prefix for including a
	--                 cap order in inventory.
	-- 05/13/04 TP	   Changed LoadGoldInventory() in On Hand and in Repair .
	-- 06/16/04 TP	   Added conditions in the OnHand and Repair types.
	--
	-- 07/26/04 TL    Added constant numbers for debugging purposes.
   --                Added implementations for insertRow, updateRow, and deleteRow on amd_on_order table
    /*
	    PVCS Keywords

       $Author:   zf297a  $
     $Revision:   1.28  $
         $Date:   Jun 09 2006 11:39:14  $
     $Workfile:   amd_inventory.pks  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_inventory.pks-arc  $
   
      Rev 1.28   Jun 09 2006 11:39:14   zf297a
   added interface version
   
      Rev 1.27   Apr 28 2006 12:37:32   c402417
   Added amd_rsp diff function.
   
      Rev 1.26   Dec 06 2005 12:28:20   zf297a
   Changed deleteRow interface for amd_on_order - passed in additional parameters: part_no, loc_sid, and order_date (gold_order_number was the only parameter previously).

      Rev 1.25   Nov 03 2005 09:35:54   c402417
   Have Procedure UpdateSpoTotalInventory execute after all the Procedure load amd tables .

      Rev 1.24   Oct 13 2005 11:04:52   c402417
   Added fucntion doRepairInvsSumDiff.

      Rev 1.23   Sep 13 2005 12:43:04   zf297a
   added interface for the isVoucher boolean function

      Rev 1.22   Sep 12 2005 11:36:18   zf297a
   added interfaces for one get and one set procedure for all the on order date parameters for a given voucher.

      Rev 1.21   Sep 09 2005 10:56:34   zf297a
   For amd_on_hand_inv_sums changed the site_location column to be the spo_location column.  The spo_location comes from amd_spare_networks.spo_location.

      Rev 1.20   Sep 07 2005 21:00:00   zf297a
   added sched_receipt_date_exception when the from date is 42; than the to date.

      Rev 1.19   Sep 02 2005 15:49:34   zf297a
   Added interfaces for getOrderCreateDate, setOrderCreateDate, getScdeduledReceiptDateFrom, getScdeduledReceiptDateTo, setScheduledReceiptDate, and setScheduledReceiptDateCalDays

      Rev 1.18   Aug 26 2005 12:15:38   zf297a
   Added interfaces for doOnHandInvsSumDiff, loadOnHandInvs, and loadInRepair.

      Rev 1.17   Aug 04 2005 08:04:46   zf297a
   Made insertRow and updateRow for amd_on_order unique for the jdbc interface.

      Rev 1.15   Jul 11 2005 09:30:34   zf297a
   made the loading of tmp_amd_in_transits a separate procedure

      Rev 1.14   Jul 11 2005 09:17:40   zf297a
   made the loading of tmp_amd_on_order a separate procedure

      Rev 1.13   Jul 06 2005 09:30:44   zf297a
   Changed deleteRow for in_repair to have a unique name.

      Rev 1.12   20 Sep 2004 10:17:40   c970183
   Fixed site_location for insertRow of in_transits - it must be varchar(20)

      Rev 1.11   06 Aug 2004 14:09:56   c970183
   removed repair_type

      Rev 1.8   Aug 02 2004 08:08:36   c970183
   Removed inv_date from insertRow, updateRow, and deleteRow for amd_on_hand_invs since diff is done on the summarized qty.  Also, changed parameter names so they would not conflict with the column names.

      Rev 1.7   Jul 30 2004 12:04:56   c970183
   added pvcs comments with keywords
	 */

	 -- added 9/7/2005
	sched_receipt_date_exception EXCEPTION ;

	SUCCESS                   CONSTANT NUMBER :=  0;
	FAILURE                   CONSTANT NUMBER :=  4;

	PROCEDURE LoadGoldInventory;

	PROCEDURE loadOnOrder ;

	PROCEDURE loadInTransits ;
	
	PROCEDURE loadRsp ;
	

	/* amd_on_order diff functions */
	FUNCTION InsertOnOrderRow(
							PART_NO             IN VARCHAR2,
  							LOC_SID             IN NUMBER,
							ORDER_DATE			IN DATE,
  							ORDER_QTY           IN NUMBER,
  							GOLD_ORDER_NUMBER   IN VARCHAR2,
							SCHED_RECEIPT_DATE IN  DATE) RETURN NUMBER ;

	FUNCTION UpdateOnOrderRow(
							PART_NO             IN VARCHAR2,
  							LOC_SID             IN NUMBER,
							ORDER_DATE  		IN DATE,
  							ORDER_QTY           IN NUMBER,
  							GOLD_ORDER_NUMBER   IN VARCHAR2,
							SCHED_RECEIPT_DATE IN  DATE) RETURN NUMBER ;

	FUNCTION deleterow(part_no IN VARCHAR2, 
			 loc_sid IN NUMBER, 
			 gold_order_number IN VARCHAR2, 
			 order_date IN DATE) RETURN NUMBER ;

	/* amd_on_hand_invs diff functions */
	FUNCTION doOnHandInvsSumDiff(
			 part_no IN VARCHAR2,
			 spo_location VARCHAR2,
			 qty_on_hand IN NUMBER,
			 action_code IN VARCHAR2) RETURN NUMBER ;

	FUNCTION InsertRow(
			 		   		 part_no         IN VARCHAR2,
  							 loc_sid         IN NUMBER,
  							 inv_qty         IN NUMBER) RETURN NUMBER ;
	FUNCTION UpdateRow(
			 		   		 part_no         IN VARCHAR2,
  							 loc_sid         IN NUMBER,
  							 inv_qty         IN NUMBER) RETURN NUMBER ;
	FUNCTION DeleteRow(
			 		   		 part_no         IN VARCHAR2,
  							 loc_sid         IN NUMBER) RETURN NUMBER;
							 
							 
	/* amd_rsp diff functions */
	FUNCTION doRspSumDiff(
			 part_no 	IN VARCHAR2,
			 rsp_location  VARCHAR2,
			 qty_on_hand		IN NUMBER,
			 rsp_level			   IN NUMBER,
			 action_code IN VARCHAR2) RETURN NUMBER;  
			 
	FUNCTION RspInsertRow(
			 		   PART_NO IN VARCHAR2,
					   LOC_SID IN NUMBER,
					   RSP_INV IN NUMBER,
					   RSP_LEVEL IN NUMBER) RETURN NUMBER;
					   
	FUNCTION RspUpdateRow(
			 		   PART_NO IN VARCHAR2,
					   LOC_SID IN NUMBER,
					   RSP_INV IN NUMBER,
					   RSP_LEVEL IN NUMBER) RETURN NUMBER;
					 
	FUNCTION RspDeleteRow(
			 			  PART_NO	IN VARCHAR2,
						  LOC_SID  IN NUMBER)RETURN NUMBER; 
						  

    /* amd_in_repair diff functions */
	FUNCTION doRepairInvsSumDiff(
			 part_no IN VARCHAR2,
			 site_location IN VARCHAR2,
			 qty_on_hand IN NUMBER,
			 action_code IN VARCHAR2) RETURN NUMBER ;

	FUNCTION InsertRow(
			 		   PART_NO         IN VARCHAR2,
  					   LOC_SID         IN NUMBER,
  					   REPAIR_DATE     IN DATE,
  					   REPAIR_QTY      IN NUMBER,
  					   ORDER_NO       IN VARCHAR2,
					   REPAIR_NEED_DATE	 IN DATE) RETURN NUMBER ;
	FUNCTION UpdateRow(
			 		   PART_NO         IN VARCHAR2,
  					   LOC_SID         IN NUMBER,
  					   REPAIR_DATE     IN DATE,
  					   REPAIR_QTY      IN NUMBER,
  					   ORDER_NO       IN VARCHAR2,
					   REPAIR_NEED_DATE IN DATE) RETURN NUMBER ;
	FUNCTION inRepairDeleteRow(
			 		   PART_NO         IN VARCHAR2,
  					   LOC_SID         IN NUMBER,
  					   ORDER_NO		   IN VARCHAR2) RETURN NUMBER ;


	/* amd_in_transits diff functions */
	FUNCTION InsertRow(
				 	   TO_LOC_SID	  		IN NUMBER,
					   QUANTITY				IN NUMBER,
					   DOCUMENT_ID			IN VARCHAR2,
					   PART_NO				IN VARCHAR2,
					   FROM_LOCATION		IN VARCHAR2,
					   IN_TRANSIT_DATE		IN DATE,
					   SERVICEABLE_FLAG		IN VARCHAR2) RETURN NUMBER ;
	FUNCTION UpdateRow(
				 	   TO_LOC_SID			IN NUMBER,
					   QUANTITY				IN NUMBER,
					   DOCUMENT_ID			IN VARCHAR2,
					   PART_NO				IN VARCHAR2,
					   FROM_LOCATION		IN VARCHAR2,
					   IN_TRANSIT_DATE		IN DATE,
					   SERVICEABLE_FLAG		IN VARCHAR2) RETURN NUMBER ;
	FUNCTION DeleteRow(
				 	   DOCUMENT_ID			IN VARCHAR2,
					   PART_NO				IN VARCHAR2,
					   TO_LOC_SID			IN NUMBER) RETURN NUMBER ;


	/* amd_in_transits_sum diff function */
	FUNCTION InsertRow(
				 	   PART_NO			   	IN VARCHAR2,
					   SITE_LOCATION			IN VARCHAR2,
					   QUANTITY				IN NUMBER,
					   SERVICEABLE_FLAG		IN VARCHAR2) RETURN NUMBER ;

	FUNCTION UpdateRow(
				 	   PART_NO				IN VARCHAR2,
					   SITE_LOCATION			IN VARCHAR2,
					   QUANTITY				IN NUMBER,
					   SERVICEABLE_FLAG		IN VARCHAR2) RETURN NUMBER ;

	FUNCTION DeleteRow(
				 	   PART_NO				IN VARCHAR2,
					   SITE_LOCATION			IN VARCHAR2,
					   SERVICEABLE_FLAG		IN VARCHAR2) RETURN NUMBER ;


	PROCEDURE loadOnHandInvs ;

	PROCEDURE loadInRepair ;

	PROCEDURE updateSpoTotalInventory;

	-- added 9/2/2005 by dse
	FUNCTION getOrderCreateDate(voucher IN VARCHAR2) RETURN DATE ;
	PROCEDURE setOrderCreateDate(voucher IN VARCHAR2, orderCreateDate IN DATE) ;
	FUNCTION getScdeduledReceiptDateFrom(voucher IN VARCHAR2) RETURN DATE ;
	FUNCTION getScdeduledReceiptDateTo(voucher IN VARCHAR2) RETURN DATE ;
	PROCEDURE setScheduledReceiptDate(voucher IN VARCHAR2, fromDate IN DATE, toDate DATE) ;
	PROCEDURE setScheduledReceiptDateCalDays(voucher IN VARCHAR2, days IN NUMBER) ;
	-- added 9/8/2005 by dse
	FUNCTION getScheduledReceiptDateCalDays(voucher IN VARCHAR2) RETURN NUMBER ;

	-- added 9/10/2005 by dse
	PROCEDURE getOnOrderParams(voucher IN VARCHAR2,
			  orderCreateDate 		  OUT DATE,
			  schedReceiptDateFrom 	  OUT DATE,
			  schedReceiptDateTo 	  OUT DATE,
			  schedReceiptCalDays 	  OUT NUMBER) ;
	PROCEDURE setOnOrderParams(voucher IN VARCHAR2,
			  orderCreateDate 		   IN DATE,
			  schedReceiptDateFrom 	   IN DATE,
			  schedReceiptDateTo 	   IN DATE,
			  schedReceiptCalDays 	   IN NUMBER) ;
	FUNCTION isVoucher(voucher IN VARCHAR2) RETURN BOOLEAN ;
	PROCEDURE clearOnOrderParams ;
	FUNCTION numberOfOnOrderParams RETURN NUMBER ;
	TYPE ref_cursor IS REF CURSOR ;
	FUNCTION getVouchers RETURN ref_cursor ;
	-- added 6/9/2006 by dse
	procedure version ;


END Amd_Inventory;
/

show errors

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.AMD_PART_LOC_FORECASTS_PKG AS
 /*
      $Author:   zf297a  $
	$Revision:   1.26  $
        $Date:   31 Jan 2007 12:01:26  $
    $Workfile:   AMD_PART_LOC_FORECASTS_PKG.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_PART_LOC_FORECASTS_PKG.pkb.-arc  $
/*   
/*      Rev 1.26   31 Jan 2007 12:01:26   zf297a
/*   Modified hasValidDate to insist on a full month name beginning at the begining of the column NAME - ie MONTH DD, DDDD where DD is a two digit day and DDDD is a two digit year.
/*   
/*      Rev 1.25   19 Jan 2007 14:02:44   zf297a
/*   Made the "duplicates" a single CONSTANT to gaurantee that the value is the same for every location it is used within the package.
/*   
/*      Rev 1.24   17 Jan 2007 14:43:10   zf297a
/*   Chaned the pDuplicate value from 60 to 66.
/*   
/*      Rev 1.23   Nov 28 2006 14:46:10   zf297a
/*   fixed insertTmpA2A_EF - for INSERT_ACTION or UPDATE_ACTION check to see if the part is in amd_sent_to_a2a with action_code <> DELETE_ACTION then insert it into tmp_a2a_ext_forecast.  For DELETE_ACTION's check to see if the part is in amd_sent_to_a2a with any action_code then insert it into tmp_a2a_ext_forecast.
/*   
/*      Rev 1.22   Nov 01 2006 11:39:12   zf297a
/*   Implemented hasValidDate and hasValidDateYorN.  Used these new functions to filter out bad date formats in the name column of bssm_locks.
/*   
/*      Rev 1.21   Sep 26 2006 16:22:12   zf297a
/*   Fixed insert into amd_bssm__s_base_part_periods
/*   
/*      Rev 1.20   Sep 14 2006 10:07:30   zf297a
/*   Raise an applicaton error when no date is found for the latest Rbl Run from BSSM.
/*   
/*      Rev 1.19   Sep 05 2006 12:52:00   zf297a
/*   Added dbms_output to version
/*   
/*      Rev 1.18   Aug 18 2006 15:45:10   zf297a
/*   Implemented doExtForecast.
/*   
/*      Rev 1.17   Aug 14 2006 14:13:50   zf297a
/*   Fixed code to generated ExtForecast deletes.
/*   
/*      Rev 1.16   Aug 01 2006 12:15:00   zf297a
/*   Removed redundant getLatestRblRunBssm from for loop
/*   
/*      Rev 1.15   Aug 01 2006 12:01:00   zf297a
/*   Fixed LoadLatestRblRun so that it will use the most recent date contained in the name field of bssm_locks.  Used Raise_Application_Error when no date is found in the name field.
/*   
/*      Rev 1.14   Jul 26 2006 10:11:40   zf297a
/*   Implemented function getLatestRblRunBssm
/*   
/*      Rev 1.13   Jul 26 2006 09:34:10   zf297a
/*   Made duplicate field a required field for all tmp_a2a's
/*   
/*      Rev 1.12   Jun 12 2006 13:10:42   zf297a
/*   Fixed error messages.  Resequenced pError_location.  Enhanced use of writeMsg.  Fixed to_char format for minutes MI.
/*   
/*      Rev 1.11   Jun 09 2006 12:17:28   zf297a
/*   implemented version
/*   
/*      Rev 1.10   Jun 04 2006 21:47:58   zf297a
/*   Make sure LoadTmpAmdPartLocForecasts uses non-null spo_prime_part_no
/*   
/*      Rev 1.9   Jun 01 2006 12:20:38   zf297a
/*   switched from dbms_output to amd_utils.writeMsg.
/*   
/*      Rev 1.8   May 12 2006 14:41:56   zf297a
/*   Changed all loadAll routines to use all action_codes and to use the action_code data to create the A2A transactions.  Also use the SendAllData property of the a2a_pkg in conjunction with the isPartValid and the wasPartSent functions.
/*   
/*      Rev 1.7   Apr 05 2006 12:42:38   zf297a
/*   Limitied loop of 60 periods to just 1 with a duplicate value of 60.
/*   
/*      Rev 1.6   Feb 15 2006 21:52:08   zf297a
/*   Added a ref cursor, a type, and a common process routine.
/*   
/*      Rev 1.4   Jan 03 2006 07:56:40   zf297a
/*   Added procedure loadA2AByDate
/*   
/*      Rev 1.3   Dec 16 2005 14:29:38   zf297a
/*   Moved the truncate of tmp_a2a_ext_forecast from LoadTmpAmdPartLocForecast to LoadTmpAmdPartLocForecasts_Add.
/*   
/*      Rev 1.2   Dec 15 2005 12:11:00   zf297a
/*   Added truncate of tmp_a2a_ext_forecast to LoadTmpAmdPartLocForecasts
/*   
/*      Rev 1.1   Dec 06 2005 10:36:52   zf297a
/*   Fixed display of sysdate in errorMsg - changed to MM/DD/YYYY HH:MM:SS
/*   
/*      Rev 1.0   Dec 01 2005 09:44:12   zf297a
/*   Initial revision.
*/

-- will need to constantly diff after all to check for new and deleted parts --

	PKGNAME CONSTANT VARCHAR2(30) := 'AMD_PART_LOC_FORECASTS_PKG' ;
    DUPLICATES CONSTANT NUMBER := 66 ; 
	
	-- REALLY_OLD_DATE CONSTANT DATE := TO_DATE('06/10/1965', 'MM/DD/YYYY') ;
	
		procedure writeMsg(
					pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
					pError_location IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
					pKey1 IN VARCHAR2 := '',
					pKey2 IN VARCHAR2 := '',
					pKey3 IN VARCHAR2 := '',
					pKey4 in varchar2 := '',
					pData IN VARCHAR2 := '',
					pComments IN VARCHAR2 := '')  IS
		BEGIN
			Amd_Utils.writeMsg (
					pSourceName => 'amd_part_loc_forecasts_pkg',	
					pTableName  => pTableName,
					pError_location => pError_location,
					pKey1 => pKey1,
					pKey2 => pKey2,
					pKey3 => pKey3,
					pKey4 => pKey4,
					pData    => pData,
					pComments => pComments);
		end writeMsg ;
	
	FUNCTION ErrorMsg(
				pSourceName in amd_load_status.SOURCE%type,
				pTableName in amd_load_status.TABLE_NAME%type,
				pError_location in amd_load_details.DATA_LINE_NO%type,
				pReturn_code in number,			
				pKey1 in varchar2 := '',
				pKey2 in varchar2 := '',
				pKey3 in varchar2 := '',
				pData in varchar2 := '',
				pComments in varchar2 := '') return number is
	BEGIN
		ROLLBACK; -- rollback may not be complete if running with mDebug set to true
		amd_utils.InsertErrorMsg (
				pLoad_no => amd_utils.GetLoadNo(pSourceName => pSourceName,	pTableName  => pTableName),
				pData_line_no => pError_location,
				pData_line    => pData,
				pKey_1 => substr(pKey1,1,50),
				pKey_2 => substr(pKey2,1,50),			
				pKey_3 => pKey3,
				pKey_4 => to_char(pReturn_code),
				pKey_5 => to_char(sysdate,'MM/DD/YYYY HH:MI:SS'),
				pComments => 'sqlcode('||sqlcode||') sqlerrm('||sqlerrm||') ' || pComments);
		COMMIT;
		RETURN pReturn_code;
	END ;
	
	/*
	FUNCTION IsTableEmpty(pTableName VARCHAR2) RETURN NUMBER IS
		  returnCode NUMBER ;
		  sql_stmt varchar2(1000) ;
	BEGIN	  
		  IF pTableName IS NULL THEN
		  	 returnCode := -1 ;
		  END IF ;
		  sql_stmt := 'SELECT count(*) FROM ' || pTableName || ' where rownum < 2' ;
		  EXECUTE IMMEDIATE sql_stmt INTO returnCode ;
		  RETURN returnCode ;	  
	EXCEPTION WHEN OTHERS THEN
		  RETURN -1 ;	  
	END ;
	*/  
	
	
	FUNCTION GetFirstDateOfMonth(pDate DATE) RETURN DATE IS
	BEGIN
		 IF ( pDate IS null ) THEN
		 	RETURN null ;
	 	 END IF ;	
	  	 RETURN ( last_day(add_months(pDate, -1)) + 1 );
	END GetFirstDateOfMonth ;
	
	FUNCTION getLatestRblRunBssm(lockName in bssm_locks.NAME%type) RETURN DATE IS
			 str VARCHAR2(100) ;
	begin
	 		 /* spec denotes specific format of month Mon DD, YYYY  that will be in best spares
			 	text field */
			 str := lockName ;
		   	 IF owa_pattern.match(str, '(\w \d{2}, \d{4})(.*)') THEN
		   	  	  owa_pattern.CHANGE(str, '(\w \d{2}, \d{4})(.*)', '\1') ;
		   		  return to_date(str, 'Mon DD, YYYY') ;
		   	 END IF ;
			 raise_application_error(-20001,'No date found for the latest RBL Run.') ;
	end getLatestRblRunBssm ;
	
	FUNCTION hasValidDate(lockName in bssm_locks.NAME%type) RETURN boolean is
			 str VARCHAR2(100) ;
			 theDate date ;
			 result boolean ;
             sp number ;
	begin
	 		 /* spec denotes specific format of month Mon DD, YYYY  that will be in best spares
			 	text field */
			 result := false ;
			 str := trim(lockName) ;
			 
               sp := instr(str,' ') ;
               if sp > 1 then
                    if substr(upper(str),1,sp - 1) in ('JANUARY', 'FEBRUARY', 'MARCH', 
                            'APRIL','MAY','JUNE','JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER',
                            'DECEMBER') then  
        		   	    IF owa_pattern.match(str, '(\w \d{2}, \d{4})(.*)') THEN
        		   	  	    owa_pattern.CHANGE(str, '(\w \d{2}, \d{4})(.*)', '\1') ;
        				    begin
		   		  	            theDate := to_date(str, 'MONTH DD, YYYY') ;
					            result := true ;
                            exception when others then
                                result := false ;				  		
                            end ;
                        end if ;
                    end if ;
		   	 END IF ;
			 return result ;
	end hasValidDate ;
	
	function hasValidDateYorN(lockName in bssm_locks.NAME%type) RETURN varchar2 is
	begin
		 if hasValidDate(lockName) then
		 	return 'Y' ;
		 else
		 	return 'N' ;
		 end if ;
	end hasValidDateYorN ;

	
	FUNCTION getLatestRblRunAmd RETURN DATE IS
				-- for initial run --
		retLatestRblRun DATE := null ;
		returnCode NUMBER ;	 
	BEGIN
		retLatestRblRun := to_date(amd_defaults.GetParamValue(PARAMS_LATEST_RBL_RUN_DATE), 'MM/DD/YYYY') ;
		--IF ( retLatestRblRun IS null ) THEN
		--   retLatestRblRun := REALLY_OLD_DATE ;
		--END IF ;
		RETURN retLatestRblRun ;   
	EXCEPTION WHEN OTHERS THEN
			returnCode := ErrorMsg(
					   pSourceName 	  	  => 'getLatestRblRunAmd',
					   pTableName  	  	  => 'amd_params - problem getting latest Rbl run',
					   pError_location 	  => 10,
					   pReturn_code	  	  => 99,
					   pKey1			  => '',
		   			   pKey2			  => '',
					   pKey3			  => '',		   
					   pData			  => '',
					   pComments		  => PKGNAME) ;		
					   RAISE ;	  	
	END getLatestRblRunAmd ; 
	
	FUNCTION getCurrentPeriod RETURN DATE IS
	   	retCurPeriod DATE := null ;	
		returnCode NUMBER ;		
	BEGIN
		retCurPeriod := to_date(amd_defaults.GetParamValue( PARAMS_CURRENT_PERIOD_DATE ), 'MM/DD/YYYY') ;
		--IF ( retCurPeriod IS null ) THEN
		--   retCurPeriod := REALLY_OLD_DATE ;
		--END IF ;
			/* make sure 1st day of month */
		retCurPeriod := getFirstDateOfMonth(retCurPeriod) ;
		RETURN retCurPeriod ;		
	EXCEPTION WHEN OTHERS THEN
			returnCode := ErrorMsg(
					   pSourceName 	  	  => 'getCurrentPeriod',
					   pTableName  	  	  => 'amd_params - problem getting current period',
					   pError_location 	  => 20,
					   pReturn_code	  	  => 99,
					   pKey1			  => '',
		   			   pKey2			  => '',
					   pKey3			  => '',		   
					   pData			  => '',
					   pComments		  => PKGNAME) ;		
					   RAISE ;	  	
	END getCurrentPeriod ;
	
	
	PROCEDURE setLatestRblRunAmd(pRblRunDate DATE) IS
	BEGIN
		UPDATE amd_param_changes
		SET param_value = to_char(pRblRunDate, 'MM/DD/YYYY'),
			effective_date = sysdate, 
			user_id = PARAM_USER 
		WHERE param_key = PARAMS_LATEST_RBL_RUN_DATE ;
		COMMIT ;
	END setLatestRblRunAmd ;
	
	
	PROCEDURE setCurrentPeriod(pCurrentPeriodDate DATE) IS
	BEGIN
		UPDATE amd_param_changes
		SET param_value = to_char(getFirstDateOfMonth(pCurrentPeriodDate), 'MM/DD/YYYY'),
			effective_date = sysdate, 
			user_id = PARAM_USER 
		WHERE param_key = PARAMS_CURRENT_PERIOD_DATE  ;
		COMMIT ;
	END setCurrentPeriod ;
	
	
	PROCEDURE  InsertTmpA2A_EF (
			pPartNo 			   VARCHAR2,
			pLocation			   VARCHAR2,
			pForecastType		   VARCHAR2,
			pPeriod				   DATE,
			pQty				   NUMBER, 
			pActionCode 	   	   VARCHAR2, 
			pLastUpdateDt 		   DATE,
			pDuplicate			   number  ) IS
			
			procedure insertTmpA2A is
			begin
				INSERT INTO tmp_a2a_ext_forecast (
					  part_no,
					  location,
					  demand_forecast_type,
					  period,
					  quantity,
					  action_code,
					  last_update_dt,
					  duplicate 	
				)
				VALUES
				(
				 	  pPartNo,
					  pLocation,
					  pForecastType,
					  trunc(pPeriod),
					  pQty,
					  pActionCode,
					  pLastUpdateDt,
					  pDuplicate	
				) ;
				
			EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
				UPDATE tmp_a2a_ext_forecast
				SET		
					period 		   = trunc(pPeriod),
					quantity 	   = pQty,
					action_code	   = pActionCode,
					last_update_dt = pLastUpdateDt 			   	   
				WHERE
					part_no 	   = pPartNo 	AND
					location	   = pLocation	AND
					period		   = pPeriod ; 	
			end insertTmpA2A ;
			
	BEGIN
		if pActionCode = amd_defaults.INSERT_ACTION
		or pActionCode = amd_defaults.UPDATE_ACTION then
		   if a2a_pkg.wasPartSent(pPartNo) then -- check if part exists in amd_sent_to_a2a with action_code <> DELETE_ACTION
		   	  insertTmpA2A ;
		   end if ;
		else
			if a2a_pkg.isPartSent(pPartNo) then -- check if the part exists in amd_sent_to_a2a with any action_code
			   insertTmpA2A ;
			end if ;
		end if ;
		 
	END InsertTmpA2A_EF ;
	
	
	PROCEDURE InsertTmpA2A_EF_AllPeriods(pPartNo VARCHAR2, pLocation VARCHAR2, pStartPeriod DATE, pQty NUMBER, pActionCode VARCHAR2, pLastUpdateDt DATE ) IS
			 period DATE ;	  	
	BEGIN
			 period := add_months(pStartPeriod, -1) ;
			 FOR i IN 1 .. ROLLING_PERIOD_MONTHS
			 LOOP
			 	 InsertTmpA2A_EF (pPartNo, pLocation, DEMAND_FORECAST_TYPE, add_months(period, i), pQty, pActionCode, pLastUpdateDt, DUPLICATES ) ;
				 exit when i = 1 ; -- process only one record and 60 will be automaticlly generated for the duplicate column
			 END LOOP ;	 
	END InsertTmpA2A_EF_AllPeriods ;
	
	PROCEDURE TmpA2A_EF_AddMonth(startDate DATE) IS
			 
		 CURSOR cur IS
			 SELECT 
			 		part_no,
					spo_location location, 
					startDate period,
					forecast_qty quantity,
					Amd_Defaults.INSERT_ACTION action_code,
					sysdate last_update_dt
			 FROM 
				 	amd_part_loc_forecasts aplf, 
					amd_spare_networks asn				
			 WHERE
			 	  	aplf.loc_sid = asn.loc_sid AND
					aplf.action_code != Amd_Defaults.DELETE_ACTION AND
					asn.action_code != Amd_Defaults.DELETE_ACTION AND
				 	nvl(aplf.forecast_qty, 0) > 0 ORDER BY part_no ;
			returnCode NUMBER ;		
	BEGIN		 
		FOR rec IN cur 
		LOOP
			BEGIN
			  -- this is called prior to diffing and after part info determines added/deleted parts.
			  -- add check for if part deleted so that an add month is not sent for a deleted part
			  -- which will not know till subsequent diff occurs.
				 IF (NOT amd_location_part_leadtime_pkg.IsPartDeleted(rec.part_no) ) THEN
				 		 
				 	InsertTmpA2A_EF
				 	 (	
					 	rec.part_no,
						rec.location,
						DEMAND_FORECAST_TYPE,
						rec.period,
						rec.quantity,
						rec.action_code,
						rec.last_update_dt,
						DUPLICATES -- duplicate
					 )	;				
			 	 END IF ;
			EXCEPTION WHEN OTHERS THEN
				returnCode := ErrorMsg(
						   pSourceName 	  	  => 'InsertTmpA2A_EF',
						   pTableName  	  	  => 'tmp_a2a_ext_forecast',
						   pError_location 	  => 30,
						   pReturn_code	  	  => 99,
						   pKey1			  => rec.part_no,
			   			   pKey2			  => rec.location,
						   pKey3			  => rec.period,		   
						   pData			  => '',
						   pComments		  => PKGNAME) ;		
						   RAISE ;
						   	   			
			END ;	 	
		END LOOP ;
		COMMIT ;
	END TmpA2A_EF_AddMonth ;	  
	
	PROCEDURE LoadAmdBssmSBasePartPeriods(pLockSid bssm_s_base_part_periods.lock_sid%TYPE, pScenarioSid bssm_s_base_part_periods.scenario_sid%TYPE) IS
		returnCode NUMBER ;
		recordExists VARCHAR2(1) := null;
	BEGIN
		 -- make sure data exists before deleting local amd copy
		BEGIN 
			SELECT 'x' INTO recordExists
			FROM bssm_s_base_part_periods
				  WHERE scenario_sid = pScenarioSid
				  AND lock_sid = pLockSid AND rownum = 1 ;
		EXCEPTION WHEN OTHERS THEN
			returnCode := ErrorMsg(
				   pSourceName 	  	  => 'LoadAmdBssmSBasePartPeriods',
				   pTableName  	  	  => 'amd_bssm_s_base_part_periods',
				   pError_location 	  => 40,
				   pReturn_code	  	  => 99,
				   pKey1			  => 'lock_sid:' || pLockSid,
	   			   pKey2			  => 'scenario_sid:' || pScenarioSid,
				   pKey3			  => '',		   
				   pData			  => '',
				   pComments		  => PKGNAME || 'bssm locks indicates new run but problem retrieving bssm_s_base_part_periods.') ;		
				   RAISE ;
		END ;	
		BEGIN	   
			mta_truncate_table('amd_bssm_s_base_part_periods','reuse storage');
			COMMIT ;
			INSERT INTO amd_bssm_s_base_part_periods
				   SELECT 
				     LOCK_SID,
  					 SCENARIO_SID,
  					 SCENARIO_PERIOD,
  					 NSN,
					 SRAN,
  					 TARGET_STOCK01,
  					 TARGET_STOCK02,
  					 TARGET_STOCK03,
  					 TARGET_STOCK04,
  					 TARGET_STOCK05,
  					 DEMAND_RATE01,
  					 DEMAND_RATE02,
  					 DEMAND_RATE03,
  					 DEMAND_RATE04,
  					 DEMAND_RATE05,
  					 STOCK_LEVEL01,
  					 STOCK_LEVEL02,
  					 STOCK_LEVEL03,
  					 STOCK_LEVEL04,
  					 STOCK_LEVEL05,
					  PERCENT_REPLACE01,
					  PERCENT_REPLACE02,
					  PERCENT_REPLACE03,
					  PERCENT_REPLACE04,
					  PERCENT_REPLACE05,
					  REORDER_QUANT01,
					  REORDER_QUANT02,
					  REORDER_QUANT03,
					  REORDER_QUANT04,
					  REORDER_QUANT05,
					  sysdate
					  FROM bssm_s_base_part_periods
					  WHERE scenario_sid = pScenarioSid
					  AND lock_sid = pLockSid ; 
			COMMIT ;		  
		EXCEPTION WHEN OTHERS THEN
				 returnCode := ErrorMsg(
					   pSourceName 	  	  => 'LoadAmdBssmSBasePartPeriods',
					   pTableName  	  	  => 'amd_bssm_s_base_part_periods',
					   pError_location 	  => 50,
					   pReturn_code	  	  => 99,
					   pKey1			  => '',
		   			   pKey2			  => '',
					   pKey3			  => '',		   
					   pData			  => '',
					   pComments		  => PKGNAME) ;		
					   RAISE ;
		END ;			   	   
	END ; 
	
	--  amd_bssm_s_base_part_periods only can hold one rbl run, do not need to query by lock_sid scenario_sid 
	PROCEDURE LoadTmpAmdPartLocForecasts IS
		 returnCode NUMBER ;	  
	BEGIN
		writeMsg(pTableName => 'tmp_amd_part_loc_forecasts', pError_location => 60,
				pKey1 => 'LoadTmpAmdPartLocForecasts',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
				
		 mta_truncate_table('tmp_amd_part_loc_forecasts', 'reuse storage') ;
		 COMMIT ;
	     INSERT INTO tmp_amd_part_loc_forecasts 
		 		(loc_sid, part_no, forecast_qty, action_code, last_update_dt) 
		 SELECT loc_sid, 
		 		spo_prime_part_no part_no,
				round(sum(nvl(demand_rate01, 0)), DP) forecast_qty, 
				Amd_Defaults.INSERT_ACTION, 
				SYSDATE
	 		   FROM amd_bssm_s_base_part_periods bsbpp, 
			   		amd_nsns an, 
					amd_spare_networks asn, 
					amd_national_stock_items ansi,
					amd_sent_to_a2a asta
	 		   WHERE 
			   spo_prime_part_no is not null 
			   and bsbpp.nsn = an.nsn	 
			   AND an.nsi_sid = ansi.nsi_sid
		       AND ansi.prime_part_no = asta.part_no
			   AND decode(asn.loc_id, Amd_Defaults.AMD_WAREHOUSE_LOCID, Amd_Defaults.BSSM_WAREHOUSE_SRAN, asn.loc_id) = bsbpp.sran		    
		   	   AND ansi.action_code != Amd_Defaults.DELETE_ACTION
	   		   AND asta.action_code != Amd_Defaults.DELETE_ACTION
			   AND asn.action_code != Amd_Defaults.DELETE_ACTION
			   GROUP BY spo_prime_part_no, loc_sid 
			   HAVING round(sum(nvl(demand_rate01, 0)), DP) > 0 ;
			   
		writeMsg(pTableName => 'tmp_amd_part_loc_forecasts', pError_location => 70,
				pKey1 => 'LoadTmpAmdPartLocForecasts',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
				
	EXCEPTION WHEN OTHERS THEN
		returnCode := ErrorMsg(
				   pSourceName 	  	  => 'LoadTmpAmdPartLocForecasts',
				   pTableName  	  	  => 'tmp_amd_part_loc_forecasts',
				   pError_location 	  => 80,
				   pReturn_code	  	  => 99,
				   pKey1			  => '',
	   			   pKey2			  => '',
				   pKey3			  => '',		   
				   pData			  => '',
				   pComments		  => PKGNAME) ;		
				   RAISE ;	   
	END LoadTmpAmdPartLocForecasts ;		  
	
	PROCEDURE LoadLatestRblRun IS
		 CURSOR rbl_cur IS	 		
			 SELECT lock_sid, rbl_scenario_sid, 
			 getLatestRblRunBssm(name) latestRblRunBssm, last_data_date 
			 FROM bssm_locks
		 	 WHERE last_data_date = (SELECT max(last_data_date)  
		  			    FROM bssm_locks 
						WHERE rbl_scenario_sid IS NOT NULL)
		 	 AND rbl_scenario_sid IS NOT NULL
			 and hasValidDateYorN(name) = 'Y'
			 order by  getLatestRblRunBssm(name) ;
			 
		     latestRblRunAmd DATE ;
			 latestRblRunBssm DATE := null ;	
			 lockSid bssm_locks.lock_sid%TYPE ;
			 scenarioSid VARCHAR2(5) ;
			 str VARCHAR2(100) ;
			 rec rbl_cur%ROWTYPE ;	 
		returnCode NUMBER ;	 
		errorComment VARCHAR2(100) := null ;
	BEGIN	  
		latestRblRunAmd := getLatestRblRunAmd ;
	    -- use the last row with the most recent date for latestRblRunBssm
		FOR rec IN rbl_cur
		LOOP
		     latestRblRunBssm := rec.latestRblRunBssm ;	 	 
		   	 scenarioSid := rec.rbl_scenario_sid ;
		   	 lockSid := rec.lock_sid ;
		END LOOP ;	 
		
		IF latestRblRunBssm IS NULL THEN
		    Raise_Application_Error(-20000, 'latestRblRunBssm date is null. Perhaps the pattern to match the date changed or bssm locks has no rbl run.') ;
		ELSIF (trunc(latestRblRunBssm) > trunc(latestRblRunAmd)) THEN
			  -- keep amd copy since runs can be accidently deleted from bssm side
			LoadAmdBssmSBasePartPeriods( lockSid, scenarioSid ) ;
		 	setLatestRblRunAmd(latestRblRunBssm) ;
		END IF ;
	    	
	EXCEPTION WHEN OTHERS THEN
		returnCode := ErrorMsg(
				   pSourceName 	  	  => 'LoadExtForecastAndLatestRblRun',
				   pTableName  	  	  => 'amd_bssm_s_base_part_periods',
				   pError_location 	  => 90,
				   pReturn_code	  	  => 99,
				   pKey1			  => 'latestRblRunAmd:' || latestRblRunAmd,
	   			   pKey2			  => 'latestRblRunBssm:' || latestRblRunBssm,
				   pKey3			  => '',	   
				   pData			  => '',
				   pComments		  => PKGNAME || ': ' || errorComment) ;		
				   RAISE ;
	END LoadLatestRblRun ;
	
	PROCEDURE LoadTmpAmdPartLocForecasts_Add IS
		currentPeriodAmd DATE 	  := 	getCurrentPeriod ;
		currentPeriod 	 DATE 	  := 	getFirstDateOfMonth(sysdate) ;	
		returnCode NUMBER ;  
	BEGIN
		mta_truncate_table('tmp_a2a_ext_forecast', 'reuse storage') ;
		IF ( trunc(currentPeriodAmd) < trunc(currentPeriod) )  THEN
			TmpA2A_EF_AddMonth(currentPeriod) ;		
		END IF ;
		setCurrentPeriod(currentPeriod) ;
		-- though rbl only quarterly run, parts can be added or deleted during each run
	    	-- which may be part of the last rbl run.  Load tmp_amd_part_loc_forecasts 
			-- for subsequent diff whether new rbl run or not.
		LoadTmpAmdPartLocForecasts ;
	EXCEPTION WHEN OTHERS THEN
		returnCode := ErrorMsg(
				   pSourceName 	  	  => 'LoadTmpAmdPartLocForecasts_Add',
				   pTableName  	  	  => 'tmp_amd_part_loc_forecasts',
				   pError_location 	  => 100,
				   pReturn_code	  	  => 99,
				   pKey1			  => 'currentPeriod:' || currentPeriod,
	   			   pKey2			  => 'currentPeriodAmd:' || currentPeriodAmd,
				   pKey3			  => '',		   
				   pData			  => '',
				   pComments		  => PKGNAME ) ;		
				   RAISE ;	
	END LoadTmpAmdPartLocForecasts_Add ;
	
	PROCEDURE UpdateAmdPartLocForecasts (
			pPartNo                     amd_part_loc_forecasts.part_no%TYPE,
			pLocSid                     amd_part_loc_forecasts.loc_sid%TYPE,
			pForecastQty				amd_part_loc_forecasts.forecast_qty%TYPE, 
			pActionCode					amd_part_loc_forecasts.action_code%TYPE,
			pLastUpdateDt				amd_part_loc_forecasts.last_update_dt%TYPE ) IS
	BEGIN
		 UPDATE amd_part_loc_forecasts
		 SET 
		 	 forecast_qty 	= pForecastQty,
		 	 action_code 	= pActionCode,
			 last_update_dt	= pLastUpdateDt
		 WHERE
		 	 part_no = pPartNo AND
			 loc_sid = pLocSid ;
	END	UpdateAmdPartLocForecasts ;	
	
	PROCEDURE InsertAmdPartLocForecasts (
			pPartNo                     amd_part_loc_forecasts.part_no%TYPE,
			pLocSid                     amd_part_loc_forecasts.loc_sid%TYPE,
			pForecastQty				amd_part_loc_forecasts.forecast_qty%TYPE, 
			pActionCode					amd_part_loc_forecasts.action_code%TYPE,
			pLastUpdateDt				amd_part_loc_forecasts.last_update_dt%TYPE ) IS
	BEGIN
	    INSERT INTO amd_part_loc_forecasts
			  (	
			  	part_no,
			  	loc_sid, 
				forecast_qty,
				action_code,
				last_update_dt
			  ) VALUES (
			  	pPartNo,
				pLocSid,
				pForecastQty,
				pActionCode,
				pLastUpdateDt
			  ) ;
	EXCEPTION WHEN DUP_VAL_ON_INDEX THEN	  		
		 	 UpdateAmdPartLocForecasts
			 (
			  	pPartNo,
				pLocSid,
				pForecastQty,
				pActionCode,
				pLastUpdateDt
			 ) ;
	
	END	InsertAmdPartLocForecasts ;	
					  
	
	
	FUNCTION InsertRow(
			pPartNo                     amd_part_loc_forecasts.part_no%TYPE,
			pLocSid                     amd_part_loc_forecasts.loc_sid%TYPE,
			pForecastQty				amd_part_loc_forecasts.forecast_qty%TYPE ) 
			return NUMBER IS
			returnCode NUMBER ;
	BEGIN 
		BEGIN  
		  	InsertAmdPartLocForecasts
			(
			 	pPartNo,
				pLocSid,
				pForecastQty,
				Amd_Defaults.INSERT_ACTION,
				sysdate
			) ;
		EXCEPTION WHEN OTHERS THEN
			returnCode := ErrorMsg(
				   pSourceName 	  	  => 'InsertRow.InsertAmdPartLocForecasts',
				   pTableName  	  	  => 'amd_part_loc_forecasts',
				   pError_location 	  => 110,
				   pReturn_code	  	  => 99,
				   pKey1			  => pPartNo,
	   			   pKey2			  => pLocSid,
				   pKey3			  => '',		   
				   pData			  => '',
				   pComments		  => PKGNAME) ;		
				   RAISE ;	  
		END ;	
		BEGIN			   	  		   
		  	InsertTmpA2A_EF_AllPeriods
			(
				pPartNo, 
				Amd_Utils.GetSpoLocation(pLocSid) , 
				GetCurrentPeriod, 
				pForecastQty , 
				Amd_Defaults.INSERT_ACTION, 
				sysdate 
			)  ;
		EXCEPTION WHEN OTHERS THEN
				returnCode := ErrorMsg(
				   pSourceName 	  	  => 'InsertRow.InsertTmpA2A_EF_AllPeriods',
				   pTableName  	  	  => 'tmp_a2a_ext_forecast',
				   pError_location 	  => 120,
				   pReturn_code	  	  => 99,
				   pKey1			  => pPartNo,
	   			   pKey2			  => pLocSid,
				   pKey3			  => '',		   
				   pData			  => '',
				   pComments		  => PKGNAME) ;		
				   RAISE ;
		END ;		
		RETURN SUCCESS ;
	EXCEPTION WHEN OTHERS THEN
		RETURN FAILURE ;		   
	END InsertRow ;		
			
			
			
	FUNCTION UpdateRow(
			pPartNo                  amd_part_loc_forecasts.part_no%TYPE,
			pLocSid                  amd_part_loc_forecasts.loc_sid%TYPE,
			pForecastQty			 amd_part_loc_forecasts.forecast_qty%TYPE ) 
			RETURN NUMBER IS
			returnCode NUMBER ;
	BEGIN
		 BEGIN
		 	   UpdateAmdPartLocForecasts
				 (
			  		 pPartNo,
					 pLocSid,
					 pForecastQty,
					 Amd_Defaults.UPDATE_ACTION,
					 sysdate
			 	 ) ;
		 EXCEPTION WHEN OTHERS THEN		
		 	returnCode := ErrorMsg(
				   pSourceName 	  	  => 'UpdateRow.UpdateAmdPartLocForecasts',
				   pTableName  	  	  => 'amd_part_loc_forecasts',
				   pError_location 	  => 130,
				   pReturn_code	  	  => 99,
				   pKey1			  => pPartNo,
	   			   pKey2			  => pLocSid,
				   pKey3			  => '',		   
				   pData			  => '',
				   pComments		  => PKGNAME) ;		
				   RAISE ;
		 END ; 
		 BEGIN
				 -- likely 59 months 
			   InsertTmpA2A_EF_AllPeriods
			   	(
					pPartNo, 
					Amd_Utils.GetSpoLocation(pLocSid) , 
					GetCurrentPeriod, 
					pForecastQty , 
					Amd_Defaults.UPDATE_ACTION, 
					sysdate 
				)  ;
		 EXCEPTION WHEN OTHERS THEN		
		 	returnCode := ErrorMsg(
				   pSourceName 	  	  => 'UpdateRow.InsertTmpA2A_EF_AllPeriods',
				   pTableName  	  	  => 'tmp_a2a_ext_forecast',
				   pError_location 	  => 140,
				   pReturn_code	  	  => 99,
				   pKey1			  => pPartNo,
	   			   pKey2			  => pLocSid,
				   pKey3			  => '',		   
				   pData			  => '',
				   pComments		  => PKGNAME) ;		
				   RAISE ;
		 END ; 		
					
		RETURN SUCCESS ;
	EXCEPTION WHEN OTHERS THEN
		RETURN FAILURE ;		
	END UpdateRow ;		
							
	
	FUNCTION DeleteRow(
			pPartNo                     amd_part_loc_forecasts.part_no%TYPE,
			pLocSid                     amd_part_loc_forecasts.loc_sid%TYPE,
			pForecastQty				amd_part_loc_forecasts.forecast_qty%TYPE ) 
			RETURN NUMBER IS
			returnCode NUMBER ;
	BEGIN 
		BEGIN
		  	UpdateAmdPartLocForecasts
			 (
			  	pPartNo,
				pLocSid,
				pForecastQty,
				Amd_Defaults.DELETE_ACTION,
				sysdate
			 ) ;
		EXCEPTION WHEN OTHERS THEN		
		 	returnCode := ErrorMsg(
				   pSourceName 	  	  => 'DeleteRow.UpdateAmdPartLocForecasts',
				   pTableName  	  	  => 'amd_part_loc_forecasts',
				   pError_location 	  => 150,
				   pReturn_code	  	  => 99,
				   pKey1			  => pPartNo,
	   			   pKey2			  => pLocSid,
				   pKey3			  => '',		   
				   pData			  => '',
				   pComments		  => PKGNAME) ;		
				   RAISE ;
		END ; 	 
		BEGIN	 
		  	IF ( NOT amd_location_part_leadtime_pkg.IsPartDeleted(pPartNo) ) THEN	  	  
			  	InsertTmpA2A_EF_AllPeriods
				(
					pPartNo, 
					Amd_Utils.GetSpoLocation(pLocSid) , 
					GetCurrentPeriod, 
					pForecastQty , 
					Amd_Defaults.DELETE_ACTION, 
					sysdate 
				)  ;
			END IF ;	
		EXCEPTION WHEN OTHERS THEN		
		 	returnCode := ErrorMsg(
				   pSourceName 	  	  => 'DeleteRow.InsertTmpA2A_EF_AllPeriods',
				   pTableName  	  	  => 'tmp_a2a_ext_forecast',
				   pError_location 	  => 160,
				   pReturn_code	  	  => 99,
				   pKey1			  => pPartNo,
	   			   pKey2			  => pLocSid,
				   pKey3			  => '',		   
				   pData			  => '',
				   pComments		  => PKGNAME) ;		
				   RAISE ;
		END ; 		
		RETURN SUCCESS ; 
	EXCEPTION WHEN OTHERS THEN	 	
		RETURN FAILURE ;	  
	END DeleteRow ;		
	
	procedure processPartLocForecasts(partLocForecasts in partLocForecastsCur) is
		cnt number := 0 ;
		sdate date :=  GetFirstDateOfMonth(sysdate) ;
		rec partLocForecastsRec ;
	begin
		 writeMsg(pTableName => 'tmp_a2a_ext_forecast', pError_location => 170,
				pKey1 => 'processLocPartForecasts',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS')) ;
		 loop
		 	 fetch partLocForecasts into rec ;
			 exit when partLocForecasts%NOTFOUND ;
			 InsertTmpA2A_EF_AllPeriods(
			 				   rec.part_no, 
							   rec.spo_location, 
							   sdate, 
							   rec.forecast_qty, 
							   rec.action_code,
							   sysdate ) ;
			 cnt := cnt + 1 ;
			 if mod(cnt, 500) = 0 then
			 	commit ;
			 end if ;
		 end loop ;
	
		 writeMsg(pTableName => 'tmp_a2a_ext_forecast', pError_location => 180,
				pKey1 => 'processLocPartForecasts',
				pKey2 => 'cnt=' || to_char(cnt),
				pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS')) ;
		 commit ;
	end processPartLocForecasts ;
	
	procedure loadA2AByDate(from_dt in date := a2a_pkg.start_dt, to_dt in date := sysdate) is
		theCursor partLocForecastsCur ;
		sdate DATE ;	
		returnCode NUMBER ;	   
	begin
		 writeMsg(pTableName => 'tmp_a2a_ext_forecast', pError_location => 190,
		 		pKey1 => 'loadA2AByDate',
				pKey2 => 'from_dt=' || to_char(from_dt,'MM/DD/YYYY'),
				pKey3 => 'to_dt=' || to_char(to_dt,'MM/DD/YYYY'),
				pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS')) ;
	
		mta_truncate_table('tmp_a2a_ext_forecast','reuse storage');
		a2a_pkg.setSendAllData(true) ;
		open theCursor for
		  SELECT  part_no, spo_location, forecast_qty, aplf.action_code
			 FROM amd_part_loc_forecasts aplf, amd_spare_networks asn
			 WHERE 
			 	   asn.action_code != Amd_Defaults.DELETE_ACTION
			 	   AND asn.loc_sid = aplf.loc_sid
				   AND nvl(forecast_qty, 0) > 0 
				   and trunc(aplf.last_update_dt) between trunc(from_dt) and trunc(to_dt) ;
		processPartLocForecasts(theCursor) ;
		close theCursor ;	 
	
		 writeMsg(pTableName => 'tmp_a2a_ext_forecast', pError_location => 200,
		 		pKey1 => 'loadA2AByDate',
				pKey2 => 'from_dt=' || to_char(from_dt,'MM/DD/YYYY'),
				pKey3 => 'to_dt=' || to_char(to_dt,'MM/DD/YYYY'),
				pKey4 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS')) ;
				
	EXCEPTION WHEN OTHERS THEN		
		 	returnCode := ErrorMsg(
				   pSourceName 	  	  => 'amd_part_loc_forecast_pkg.loadA2AByDate',
				   pTableName  	  	  => 'tmp_a2a_part_loc_forecasts',
				   pError_location 	  => 210,
				   pReturn_code	  	  => 99,
				   pKey1			  => '',
	   			   pKey2			  => '',
				   pKey3			  => '',		   
				   pData			  => '',
				   pComments		  => PKGNAME ) ;		
				   RAISE ;
	end loadA2AByDate ;
	
	PROCEDURE LoadAllA2A IS
		theCursor partLocForecastsCur ;
		returnCode number ;
	BEGIN
		writeMsg(pTableName => 'tmp_a2a_ext_forecast', pError_location => 220,
				pKey1 => 'LoadAllA2A',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
				
		mta_truncate_table('tmp_a2a_ext_forecast','reuse storage');
		a2a_pkg.setSendAllData(true) ;
		open theCursor for 
		  SELECT  part_no, spo_location, forecast_qty, aplf.action_code
			 FROM amd_part_loc_forecasts aplf, amd_spare_networks asn
			 WHERE 
			 	   asn.action_code != Amd_Defaults.DELETE_ACTION
			 	   AND asn.loc_sid = aplf.loc_sid
				   AND nvl(forecast_qty, 0) > 0 ;
		processPartLocForecasts(theCursor) ;
		close theCursor ;	 
		
		writeMsg(pTableName => 'tmp_a2a_ext_forecast', pError_location => 230,
				pKey1 => 'LoadAllA2A',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
				
	EXCEPTION WHEN OTHERS THEN		
		 	returnCode := ErrorMsg(
				   pSourceName 	  	  => 'LoadAllA2A',
				   pTableName  	  	  => 'tmp_a2a_part_loc_forecasts',
				   pError_location 	  => 240,
				   pReturn_code	  	  => 99,
				   pKey1			  => '',
	   			   pKey2			  => '',
				   pKey3			  => '',		   
				   pData			  => '',
				   pComments		  => PKGNAME ) ;		
				   RAISE ;
	END LoadAllA2A ;
	
	
	PROCEDURE LoadInitial IS
		 returnCode NUMBER ;	
	BEGIN
		writeMsg(pTableName => 'tmp_amd_part_loc_forecasts', pError_location => 250,
				pKey1 => 'LoadInitial',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
				
		LoadTmpAmdPartLocForecasts ;
		mta_truncate_table('amd_part_loc_forecasts','reuse storage');
		BEGIN 
			 INSERT INTO amd_part_loc_forecasts
			 SELECT * FROM tmp_amd_part_loc_forecasts 
			 	WHERE action_code != Amd_Defaults.DELETE_ACTION ;
			
		EXCEPTION WHEN OTHERS THEN		
		 	returnCode := ErrorMsg(
				   pSourceName 	  	  => 'LoadInitial',
				   pTableName  	  	  => 'amd_part_loc_forecasts',
				   pError_location 	  => 260,
				   pReturn_code	  	  => 99,
				   pKey1			  => '',
	   			   pKey2			  => '',
				   pKey3			  => '',		   
				   pData			  => '',
				   pComments		  => PKGNAME || ': Insert into amd_part_loc_forecasts') ;		
				   RAISE ;
		END ;
		LoadAllA2A ;
		
		writeMsg(pTableName => 'tmp_amd_part_loc_forecasts', pError_location => 270,
				pKey1 => 'LoadInitial',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	END LoadInitial ;	

	procedure doExtForecast is
	begin
		 LoadLatestRblRun ;
		 LoadTmpAmdPartLocForecasts_Add ;
	end doExtForecast ;

	procedure version is
	begin
		 writeMsg(pTableName => 'amd_part_loc_forecasts_pkg', 
		 		pError_location => 280, pKey1 => 'amd_part_loc_forecasts_pkg', pKey2 => '$Revision:   1.26  $') ;
		 dbms_output.put_line('amd_part_loc_forecasts_pkg: $Revision:   1.26  $') ;
	end version ;
	
END AMD_PART_LOC_FORECASTS_PKG ;
/

show errors

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.Amd_Location_Part_Override_Pkg AS

 /*
      $Author:   zf297a  $
	$Revision:   1.52  $
        $Date:   26 Jan 2007 09:53:10  $
    $Workfile:   AMD_LOCATION_PART_OVERRIDE_PKG.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_LOCATION_PART_OVERRIDE_PKG.pkb.-arc  $
/*   
/*      Rev 1.52   26 Jan 2007 09:53:10   zf297a
/*   implemented deleteRspTslA2A
/*   
/*      Rev 1.51   Dec 19 2006 10:52:48   zf297a
/*   Fixed deleteRow to use an Update action_code, when the part is valid to be an A2A part, otherwise it will always send a Delete action_code.
/*   
/*   Fixed the open cursor for getTestData, getDataByLastUpdateDt, and getAllData to use a DELETE action_code when the A2A part has been deleted from the amd_sent_to_a2a, otherwise send an UPDATE action_code when the action_code is DELETE for the amd_location_part_override row or when the amd_location_part_override row has an INSERT or UPDATE send amd_location_part_override.action_code.
/*   
/*   
/*   
/*      Rev 1.50   Dec 13 2006 12:00:38   zf297a
/*   When a part/loc_sid is being deleted by the java diff applicaton, update the spo data with a zero quantity - i.e. insert a record with a quantity of zero and an action_code of UPDATE.
/*   
/*   For all cursor queries make sure the quantity is zero when the action_code is DELETE and make sure that the UPDATE action gets sent for a row that has been deleted in amd_location_part_override.
/*   
/*   Implemented isTmpA2AOkay - this just checks to be sure that every part that has been sent is associated with a location.
/*   
/*      Rev 1.49   Dec 05 2006 15:14:50   zf297a
/*   Implemented new interface for processTsl.  The pDoAllA2A parameter was removed.  It was no longer necessary since the tsl cursor does all the filtering.  Removed unecessary code:
/*   insertTmpA2A - this is redundant code
/*   Removed all the unnecessary condition checks since the tsl cursor does all the fnecessary filtering.
/*   Resequenced values used for pError_location.
/*   in LoadAllA2A removed unused variables - doAllA2A, returnCode and rc.
/*   Fixed the open of the cursors to use the action_code from the amd_location_part_override for deleted rows, otherwise use the amd_sent_to_a2a action_code.
/*   For the unions of amd_rsp_sum make sure the mob is still valid by checking it against amd_spare_networks.  For the amd_rsp_sum data always use the amd_sent_to_a2a action_code and always send a zero for any row that has been deleted.
/*   
/*      Rev 1.48   Dec 04 2006 13:57:22   zf297a
/*   Fixed processTsl - used trunc for date compare + checked each action_code per each record of the tsl cursor (tslCur).
/*   
/*      Rev 1.47   Nov 28 2006 13:44:48   zf297a
/*   fixed getDataByLastUpdateDt - changed code layout for open.
/*   
/*   fixed getDataByTranDtAndBatchTime - changed code layout for open.
/*   
/*      Rev 1.46   Nov 28 2006 12:54:40   zf297a
/*   fixed insertTmpA2ALPO - for INSERT_ACTION or UPDATE_ACTION check to see if the part is in amd_sent_to_a2a with action_code <> DELETE_ACTION then insert it into tmp_a2a_loc_part_override.  For DELETE_ACTION's check to see if the part is in amd_sent_to_a2a with any action_code then insert it into tmp_a2a_loc_part_override.
/*   
/*   fixed insertTmpA2A for INSERT_ACTION or UPDATE_ACTION check to see if the part is in amd_sent_to_a2a with action_code <> DELETE_ACTION then insert it into tmp_a2a_loc_part_override.  For DELETE_ACTION's check to see if the part is in amd_sent_to_a2a with any action_code then insert it into tmp_a2a_loc_part_override.
/*   
/*   fixed getDataByLastUpdtDt to check if there is a part in amd_location_part_overrides that has changed for the given time period.
/*   
/*   fixed getDataByTranDtAndBatchTime check if there is a part in amd_location_part_overrides that has changed for the given time period.
/*   
/*      Rev 1.45   Oct 23 2006 11:05:28   zf297a
/*   Check pError_location in procedured errorMsg to make sure it is numeric.   Changed dup_val_on_index for insertedTmpA2ALPO to update tmp_a2a_loc_part_override and to record what has changed in amd_load_details.  This may provide the necessary information to eliminate this exception condition.
/*   
/*      Rev 1.44   Oct 19 2006 11:08:26   zf297a
/*   Fixed all tslCur's to use the amd_sent_to_a2a.action_code and created a nested procedure for each unique Open of the tslCur and record the procedure's name in amd_load_details.
/*   
/*      Rev 1.42   Oct 16 2006 08:41:44   zf297a
/*   For function getFirstLogonIdForPart only consider the action_code for amd_planners and amd_planner_logons since the part may have been deleted, but still needs to be sent with the proper logon_id when sending delete A2A transactions.
/*   
/*      Rev 1.41   Oct 11 2006 11:03:46   zf297a
/*   When doing a loadAllA2A and getting data from amd_rsp_sum always use the action_code of amd_sent_to_a2a.spo_prime_part_no and send a zero quantity when the amd_rsp_sum.action_code = 'D' otherwise send the rsp_level.
/*   
/*      Rev 1.40   Oct 09 2006 22:28:04   zf297a
/*   Fixed inner getActionCode function of insertTmpA2A of processTsl - used rsp_location / site_location for search of amd_rsp_sum.  Added additional exception handlers for getActionCode too.
/*   
/*      Rev 1.39   Oct 09 2006 10:34:56   zf297a
/*   For A2A transactions give the action_code belonging to amd_location_part_override or amd_rsp_sum priority when it is a delete action, otherwise use the action_code from the associated amd_sent_to_a2a row.
/*   
/*      Rev 1.38   Sep 05 2006 12:47:08   zf297a
/*   Renumbered pError_location's values
/*   
/*      Rev 1.37   Aug 31 2006 16:02:12   zf297a
/*   Added more exception handlers.  Added dbms_output to version procedure.
/*   
/*      Rev 1.36   Aug 31 2006 15:34:22   zf297a
/*   Replaced errorMsg function with errorMsg procedure
/*   
/*      Rev 1.35   Aug 31 2006 14:56:12   zf297a
/*   Added more when others exceptions
/*   fixed loadAllA2A to use the amd_sent_to_a2a action_code 
/*   
/*      Rev 1.34   Aug 31 2006 12:03:18   zf297a
/*   Used not exists instead of function inInTmpA2AYorN
/*   Used action_code from amd_sent_to_a2a in most cases
/*   
/*   
/*      Rev 1.33   Jul 17 2006 11:21:00   zf297a
/*   Added cursor_spoSum for warehouse.  This amount get subtracted from the spo_total_inventory
/*   
/*      Rev 1.32   Jun 16 2006 09:21:54   zf297a
/*   For LoadWhse added a cursor_rspSum which get summed with cursor_basesSum resulting in substracting out the rsp sum for the final tsl_override_qty that gets put into tmp_amd_location_part_override.
/*   
/*      Rev 1.31   Jun 12 2006 13:22:32   zf297a
/*   use symbolic constants UK_LOCATION and BASC_LOCATION.
/*   
/*      Rev 1.30   Jun 09 2006 11:56:00   zf297a
/*   implemented version
/*   
/*      Rev 1.29   Jun 07 2006 11:11:04   zf297a
/*   For the loadAll unioned amd_rsp_sum with amd_location_part_overrides to get the non zero tsl's.
/*   
/*      Rev 1.28   Jun 07 2006 09:45:06   zf297a
/*   for loadRspZeroTsl fixed the sql for the cursors where amd_location_part_override_pkg.isInTmpA2AYorN(spo_prime_part_no, mob || '_RSP') = 'N' is needed (the value was checked for was not all 'N''s and the mob was not concatenated with the literal '_RSP')
/*   
/*      Rev 1.27   Jun 03 2006 20:25:54   zf297a
/*   enhanced the use of writeMsg
/*   
/*      Rev 1.26   Jun 03 2006 19:09:54   zf297a
/*   added:
/*   and parts.action_code != amd_defaults.getDELETE_ACTION
/*   to the last open tsl cursor of procedure LoadZeroTslA2A
/*   
/*      Rev 1.25   Jun 03 2006 18:59:36   zf297a
/*   fixed procedure amd_location_part_override_pkg.LoadZeroTslA2A(pDoAllA2A BOOLEAN, pSpoLocation VARCHAR2,from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE) 
/*    to use select's similar to the following: 
/*    SELECT distinct primes.spo_prime_part_no,
/*      amd_defaults.getINSERT_ACTION,
/*      sysdate,
/*      theLocation spo_location,
/*      ansi.nsn,
/*      ansi.nsi_sid,
/*      0 override_qty
/*      FROM (select distinct spo_prime_part_no from amd_sent_to_a2a where action_code <> 'D') primes, 
/*      AMD_NATIONAL_STOCK_ITEMS ansi
/*      WHERE amd_location_part_override_pkg.isInTmpA2AYorN(primes.spo_prime_part_no, theLocation) = 'N'
/*      AND ansi.prime_part_no = primes.spo_prime_part_no
/*      AND ansi.action_code != Amd_Defaults.getDELETE_ACTION 
/*     
/*   and procedure amd_location_part_override_pkg.LoadZeroTslA2A(doAllA2A IN BOOLEAN := FALSE, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE) 
/*   
/*   was fixed by adding an additional invocation of 
/*   amd_location_part_override_pkg.LoadZeroTslA2A(pDoAllA2A BOOLEAN, pSpoLocation VARCHAR2,from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE) 
/*   
/*   for pSpoLocation equal to amd_location_part_override_pkg.THE_WAREHOUSE (FD2090).
/*   
/*   
/*      Rev 1.24   Jun 01 2006 22:20:24   zf297a
/*   Fiixed query for loadRspZeroTsl - added qualification for amd_spare_parts - part_no = spo_prime_part_no
/*   
/*      Rev 1.23   Jun 01 2006 12:01:14   zf297a
/*   Added writeMsg to the beginning of processTsl
/*   
/*      Rev 1.22   Jun 01 2006 10:57:52   zf297a
/*   Fixed loadRspZeroTsl's.  use amd_utils.writeMsg instead of dbms_output
/*   
/*      Rev 1.21   May 31 2006 08:20:46   zf297a
/*   Used Mta_Truncate_Table for loadAllA2A instead of truncateIfOld
/*   
/*      Rev 1.20   May 12 2006 14:00:36   zf297a
/*   For loadAllA2A include all action_codes and all parts that are in amd_sent_to_a2a  where the spo_prime_part_no is filled in too.
/*   
/*      Rev 1.19   Apr 28 2006 13:16:24   zf297a
/*   Implemented the loadRspZeroTslA2A
/*   
/*      Rev 1.18   Apr 21 2006 14:02:00   zf297a
/*   Made insertTmpA2ALPO public, so prototype could be removed.  Also made sure that insertTmpA2ALPO never updates an existing tmp_a2a record with a zero quantity.
/*   
/*      Rev 1.17   Apr 20 2006 13:23:00   zf297a
/*   Added an insertTmpA2A routine for the processTsl procedure.  This routine is used only to insert zero tsl's.  If a tmp_a2a row exists already, it is not overwritten.
/*   
/*      Rev 1.16   Mar 23 2006 09:08:56   zf297a
/*   Use truncateIfOld for tmp_a2a_loc_part_override - .  The table will get truncated if there is no active batch job or it will get truncated if there is an active batch job and the table has not changed since the batch job started.
/*   
/*      Rev 1.15   Mar 06 2006 08:37:34   zf297a
/*   Removed unused references to amd_batch_jobs
/*   
/*      Rev 1.14   Mar 05 2006 15:26:36   zf297a
/*   Added debug code.
/*   
/*      Rev 1.13   Mar 05 2006 14:16:24   zf297a
/*   Added amd_utils.debugMsg to record counts and procedure completion.
/*   Added enhanced processing to tsl's.
/*   
/*      Rev 1.12   Mar 03 2006 12:06:22   zf297a
/*   Moved boolean2Varchar2 to amd_utils.  Used amd_batch_pkg.getLastStartTime instead of amd_location_part_leadtime_pkg.getBatchRunStart.  This will retrieve the last batch start time even if the job has finished.  This way any data changed since the last batch job has been run, can have a2a transactions created for it.  (The only other choice with the previous method would be the "send all" method versus what has changed since the last batch start time).
/*   Added more qualification for the tsl cursor in procedure loadZeroTslA2APartsWithNoTsls
/*   
/*   
/*      Rev 1.11   Feb 24 2006 15:07:26   zf297a
/*   Streamlined routines handling TSL's.  Added some additional TSL loads.
/*   
/*      Rev 1.10   Feb 17 2006 09:25:10   zf297a
/*   Changed requisition_objective to demand_level
/*   
/*      Rev 1.9   Feb 15 2006 21:22:52   zf297a
/*   Added ref cursor's, type's and common process routines.
/*   
/*      Rev 1.8   Jan 03 2006 12:56:26   zf297a
/*   Added date range to procedures loadZeroTslA2AByDate and loadA2AByDate
/*   
/*      Rev 1.7   Jan 03 2006 09:13:06   zf297a
/*   Changed name from loadByDate to loadA2AByDate
/*   
/*      Rev 1.6   Dec 30 2005 01:20:08   zf297a
/*   add loadByDate
/*   
/*      Rev 1.5   Dec 15 2005 12:16:44   zf297a
/*   Added truncate table tmp_a2a_loc_part_override to LoadTmpAmdLocPartOverride
/*   
/*      Rev 1.4   Dec 06 2005 09:52:36   zf297a
/*   Fixed display of sysdate in errorMsg - changed to MM/DD/YYYY HH:MM:SS
/*   
/*      Rev 1.3   Nov 15 2005 11:57:26   zf297a
/*   Add additional where clauses to load all the data.  Added return statement for insertedTmpA2ALPO.
/*   
/*      Rev 1.2   Nov 10 2005 11:08:24   zf297a
/*   Added global counters for insert, update, and delete and public getter's.
/*   
/*   Added a testData Cursor.
/*   
/*   Added counters and displaying of start/end messages for all the load routines.
/*   
/*      Rev 1.1   Oct 28 2005 12:46:04   zf297a
/*   Added check for wasPartSent before inserting to tmp_a2a_loc_part_override
/*   
/*      Rev 1.0   Oct 19 2005 12:40:56   zf297a
/*   Initial revision.
/*   
/*      Rev 1.0   Oct 18 2005 13:07:22   zf297a
/*   Initial revision.
		 */

	PKGNAME CONSTANT VARCHAR2(30) := 'AMD_LOCATION_PART_OVERRIDE_PKG' ;
	
	COMMIT_THRESHOLD CONSTANT NUMBER := 250 ;
	
	insertCnt NUMBER := 0 ;
	updateCnt NUMBER := 0 ;
	deleteCnt NUMBER := 0 ;
	
	procedure writeMsg(
				pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
				pError_location IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
				pKey1 IN VARCHAR2 := '',
				pKey2 IN VARCHAR2 := '',
				pKey3 IN VARCHAR2 := '',
				pKey4 in varchar2 := '',
				pData IN VARCHAR2 := '',
				pComments IN VARCHAR2 := '')  IS
	BEGIN
		Amd_Utils.writeMsg (
				pSourceName => 'amd_location_part_override_pkg',	
				pTableName  => pTableName,
				pError_location => pError_location,
				pKey1 => pKey1,
				pKey2 => pKey2,
				pKey3 => pKey3,
				pKey4 => pKey4,
				pData    => pData,
				pComments => pComments);
	end writeMsg ;
	
	PROCEDURE ErrorMsg(
	    pSqlfunction IN AMD_LOAD_STATUS.SOURCE%TYPE,
	    pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
	    pError_location AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
	    pKey1 IN AMD_LOAD_DETAILS.KEY_1%TYPE := '',
	    pKey2 IN AMD_LOAD_DETAILS.KEY_2%TYPE := '',
	    pKey3 IN AMD_LOAD_DETAILS.KEY_3%TYPE := '',
	    pKey4 IN AMD_LOAD_DETAILS.KEY_4%TYPE := '',
	    pComments IN VARCHAR2 := '') IS
	 
	    key5 AMD_LOAD_DETAILS.KEY_5%TYPE := pComments ;
		error_location number ;
	 
	BEGIN
	  ROLLBACK;
	  IF key5 = '' THEN
	     key5 := pSqlFunction || '/' || pTableName ;
	  ELSE
	   key5 := key5 || ' ' || pSqlFunction || '/' || pTableName ;
	  END IF ;
	  if amd_utils.isNumber(pError_location) then
	  	 error_location := pError_location ;
	  else
	  	 error_location := -9999 ;
	  end if ;
	  -- use substr's to make sure that the input parameters for InsertErrorMsg and GetLoadNo
	  -- do not exceed the length of the column's that the data gets inserted into
	  -- This is for debugging and logging, so efforts to make it not be the source of more
	  -- errors is VERY important
	  Amd_Utils.InsertErrorMsg (
	    pLoad_no => Amd_Utils.GetLoadNo(
	      pSourceName => SUBSTR(pSqlfunction,1,20),
	      pTableName  => SUBSTR(pTableName,1,20)),
	    pData_line_no => error_location,
	    pData_line    => 'amd_location_part_override_pkg',
	    pKey_1 => SUBSTR(pKey1,1,50),
	    pKey_2 => SUBSTR(pKey2,1,50),
	    pKey_3 => SUBSTR(pKey3,1,50),
	    pKey_4 => SUBSTR(pKey4,1,50),
	    pKey_5 => TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS') ||
	         ' ' || substr(key5,1,50),
	    pComments => SUBSTR('sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')',1,2000));
	    COMMIT;
	  
	EXCEPTION WHEN OTHERS THEN
	  if pSqlFunction is not null then dbms_output.put_line('pSqlFunction=' || pSqlfunction) ; end if ;
	  if pTableName is not null then dbms_output.put_line('pTableName=' || pTableName) ; end if ;
	  if pError_location is not null then dbms_output.put_line('pError_location=' || pError_location) ; end if ;
	  if pKey1 is not null then dbms_output.put_line('key1=' || pKey1) ; end if ;
	  if pkey2 is not null then dbms_output.put_line('key2=' || pKey2) ; end if ;
	  if pKey3 is not null then dbms_output.put_line('key3=' || pKey3) ; end if ;
	  if pKey4 is not null then dbms_output.put_line('key4=' || pKey4) ; end if ;
	  if pComments is not null then dbms_output.put_line('pComments=' || pComments) ; end if ;
	  raise ;
	END ErrorMsg;
	
	
	PROCEDURE UpdateAmdLocPartOverride (
	  		  pPartNo 			   		AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			  pLocSid 					AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			  pTslOverrideQty			AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE,
			  pTslOverrideUser			AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE,
			  pActionCode				AMD_LOCATION_PART_OVERRIDE.action_code%TYPE,
			  pLastUpdateDt				AMD_LOCATION_PART_OVERRIDE.last_update_dt%TYPE) IS
	BEGIN
		 	  UPDATE AMD_LOCATION_PART_OVERRIDE
			  SET
			  	  tsl_override_qty 			= pTslOverrideQty,
				  tsl_override_user  		= pTslOverrideUser,
				  action_code				= pActionCode,
				  last_update_dt			= pLastUpdateDt
			  WHERE
			  	  part_no = pPartNo AND
				  loc_sid = pLocSid ;
	exception when others then			  
		 ErrorMsg(
				   pSqlfunction 	  => 'UpdateAmdLocPartOverride',
				   pTableName  	  	  => 'amd_location_part_override',
				   pError_location => 10) ;
		 raise ;	
	END UpdateAmdLocPartOverride ;
	
	PROCEDURE UpdateTmpAmdLocPartOverride (
	  		  pPartNo 			   		AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			  pLocSid 					AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			  pTslOverrideQty			AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE,
			  pTslOverrideUser			AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE,
			  pActionCode				AMD_LOCATION_PART_OVERRIDE.action_code%TYPE,
			  pLastUpdateDt				AMD_LOCATION_PART_OVERRIDE.last_update_dt%TYPE) IS
	BEGIN
		 	  UPDATE TMP_AMD_LOCATION_PART_OVERRIDE
			  SET
			  	  tsl_override_qty 			= pTslOverrideQty,
				  tsl_override_user  		= pTslOverrideUser,
				  action_code				= pActionCode,
				  last_update_dt			= pLastUpdateDt
			  WHERE
			  	  part_no = pPartNo AND
				  loc_sid = pLocSid ;
		 exception when others then			  
		 ErrorMsg(
				   pSqlfunction 	  => 'UpdateTmpAmdLocPartOverride',
				   pTableName  	  	  => 'tmp_amd_location_part_override',
				   pError_location => 20) ;
		 raise ;	
		 END UpdateTmpAmdLocPartOverride ;
	
	
	PROCEDURE InsertTmpAmdLocPartOverride (
			  pPartNo 			   		AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			  pLocSid 					AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			  pTslOverrideQty			AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE,
			  pTslOverrideUser			AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE,
			  pActionCode				AMD_LOCATION_PART_OVERRIDE.action_code%TYPE,
			  pLastUpdateDt				AMD_LOCATION_PART_OVERRIDE.last_update_dt%TYPE) IS
	BEGIN
		 INSERT INTO TMP_AMD_LOCATION_PART_OVERRIDE
		 (
		  		part_no,
				loc_sid,
				tsl_override_qty,
				tsl_override_user,
				action_code,
				last_update_dt
		 )
		 VALUES
		 (
		  		pPartNo,
				pLocSid,
				pTslOverrideQty,
				pTslOverrideUser,
				pActionCode,
				pLastUpdateDt
		 ) ;
	EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
		 	  UpdateTmpAmdLocPartOverride (
		   		  pPartNo,
		 		  pLocSid,
		 		  pTslOverrideQty,
		 		  pTslOverrideUser,
		 		  pActionCode,
		 		  SYSDATE ) ;
	  when others then			  
		 ErrorMsg(
				   pSqlfunction 	  => 'InsertTmpAmdLocPartOverride',
				   pTableName  	  	  => 'tmp_amd_location_part_override',
				   pError_location => 30) ;
		raise ;
	END InsertTmpAmdLocPartOverride ;
	
	PROCEDURE InsertAmdLocPartOverride (
			  pPartNo 			   		AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			  pLocSid 					AMD_SPARE_NETWORKS.loc_sid%TYPE,
			  pTslOverrideQty			NUMBER,
			  pTslOverrideUser			VARCHAR2,
			  pActionCode				VARCHAR2,
			  pLastUpdateDt				DATE) IS
	BEGIN
		 INSERT INTO AMD_LOCATION_PART_OVERRIDE
		 (
		  		part_no,
				loc_sid,
				tsl_override_qty,
				tsl_override_user,
				action_code,
				last_update_dt
		 )
		 VALUES
		 (
		  		pPartNo,
				pLocSid,
				pTslOverrideQty,
				pTslOverrideUser,
				pActionCode,
				pLastUpdateDt
		 ) ;
	EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
		 	  UpdateAmdLocPartOverride (
		   		  pPartNo,
		 		  pLocSid,
		 		  pTslOverrideQty,
		 		  pTslOverrideUser,
		 		  pActionCode,
		 		  SYSDATE ) ;
	 when others then			  
		 ErrorMsg(
				   pSqlfunction 	  => 'InsertAmdLocPartOverride',
				   pTableName  	  	  => 'amd_location_part_override',
				   pError_location => 40) ;
		 raise ;
	END InsertAmdLocPartOverride ;
	
				  
	FUNCTION insertedTmpA2ALPO(rec IN TMP_A2A_LOC_PART_OVERRIDE%ROWTYPE) RETURN BOOLEAN IS
			 rc number ;
	BEGIN
		 RETURN insertedTmpA2ALPO(
				  rec.part_no,
				  rec.site_location,
				  rec.override_type,
				  rec.override_quantity,
				  rec.override_reason,
				  rec.override_user,
				  rec.begin_date,
				  rec.action_code,
				  rec.last_update_dt) ;
				 
	exception when others then
			  
		 ErrorMsg(
				   pSqlfunction 	  => 'insertedTmpA2ALPO',
				   pTableName  	  	  => 'tmp_a2a_loc_part_override',
				   pError_location => 50,
				   pKey1			  => rec.part_no,
	   			   pKey2			  => rec.site_location,
				   pKey3			  => rec.action_code,
				   pComments		  => PKGNAME) ;
		RAISE ;
	END insertedTmpA2ALPO ;
	
	FUNCTION insertedTmpA2ALPO (
				  pPartNo			TMP_A2A_LOC_PART_OVERRIDE.part_no%TYPE,
				  pBaseName			TMP_A2A_LOC_PART_OVERRIDE.site_location%TYPE,
				  pOverrideType		TMP_A2A_LOC_PART_OVERRIDE.override_type%TYPE,
				  pTslOverrideQty	TMP_A2A_LOC_PART_OVERRIDE.override_quantity%TYPE,
				  pOverrideReason	TMP_A2A_LOC_PART_OVERRIDE.override_reason%TYPE,
				  pTslOverrideUser	TMP_A2A_LOC_PART_OVERRIDE.override_user%TYPE,
				  pBeginDate		TMP_A2A_LOC_PART_OVERRIDE.begin_date%TYPE,
				  pActionCode		TMP_A2A_LOC_PART_OVERRIDE.action_code%TYPE,
				  pLastUpdateDt		TMP_A2A_LOC_PART_OVERRIDE.last_update_dt%TYPE
				  ) RETURN BOOLEAN IS
				  
			rc number ;
			
			procedure doUpdate is
			begin
			   UPDATE TMP_A2A_LOC_PART_OVERRIDE
		 		SET
					  override_type		 = pOverrideType,
					  override_quantity	 = pTslOverrideQty,
					  override_reason	 = pOverrideReason,
					  override_user		 = pTslOverrideUser,
					  begin_date		 = pBeginDate,
					  action_code		 = pActionCode,
					  last_update_dt	 = pLastUpdateDt
				WHERE
					  part_no 			 = pPartNo AND
					  site_location		 = pBaseName ;
			end doUpdate ;
			
			procedure insertRow is

					  procedure recordInfo is
					 		override_type tmp_a2a_loc_part_override.OVERRIDE_TYPE%type ;
							override_quantity tmp_a2a_loc_part_override.OVERRIDE_QUANTITY%type ;
							override_reason tmp_a2a_loc_part_override.OVERRIDE_REASON%type ;
							override_user tmp_a2a_loc_part_override.OVERRIDE_USER%type ;
							begin_date tmp_a2a_loc_part_override.BEGIN_DATE%type ;
							action_code tmp_a2a_loc_part_override.ACTION_CODE%type ;
							last_update_dt tmp_a2a_loc_part_override.LAST_UPDATE_DT%type ;
							
							-- log what's different about this row
							procedure changed (field in varchar2, curfieldValue in varchar2, prevFieldValue in varchar2, 
									  pError_location in number) is
							begin
								writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => pError_Location,
									pKey1 => 'insertedTmpA2ALPO.changed',
									pKey2 => 'part_no=' || pPartNo,
									pKey3 => 'pBaseName=' || pBaseName,
									pKey4 => 'prev ' || field || '=' || nvl(prevfieldValue,'Null'),
									pData => 'cur ' || field || '=' || nvl(curFieldValue,'Null') ) ;
							end changed ;
					
					  begin
			 	
					    select override_type, override_quantity, override_reason, override_user, begin_date, action_code, last_update_dt
						into override_type, override_quantity, override_reason, override_user, begin_date, action_code, last_update_dt
						from tmp_a2a_loc_part_override 
						where part_no = pPartNo
						and site_location = pBaseName ;
						
						if pOverrideType <> override_type or override_quantity <> pTslOverrideQty or override_reason <> pOverrideReason
						or pBeginDate <> begin_date or pActionCode <> action_code or pLastUpdateDt <> last_update_dt then
						   	   -- something changed 
							   -- record only the column that changed
							   if pOverrideType <> override_type then 
							   	  changed('override_type', pOverrideType, override_type, pError_location => 60) ; 
							   end if ;
							   if pTslOverrideQty <> override_quantity then
							   	  changed('override_quantity', to_char(pTslOverrideQty), to_char(override_quantity), pError_location => 70) ;
							   end if ;
							   if pOverrideReason <> override_reason then
							   	  changed('override_reason', pOverrideReason, override_reason,  pError_location => 80) ;
							   end if ; 
							   if pTslOverrideUser <> override_user then
							   	  changed('override_user', pTslOverrideUser, override_user,  pError_location => 90) ;
							   end if ;
							   if pBeginDate <> begin_date then				   
							   	  changed('begin_date', to_char(pBeginDate,'MM/DD/YYYY HH:MI:SS'), to_char(begin_date,'MM/DD/YYYY HH:MI:SS'), pError_location => 100) ;
							   end if ;
							   if pActionCode <> action_code then
							   	  changed('action_code',  pActionCode, action_code, pError_location => 110) ;
							   end if ;
							   if pLastUpdateDt <> last_update_dt then
							   	  changed('last_update_dt', to_char(pLastUpdateDt,'MM/DD/YYYY HH:MI:SS'), to_char(last_update_dt,'MM/DD/YYYY HH:MI:SS'), pError_location => 120) ;
							   end if ;
						 end if ;
					  end recordInfo ;
					  
			begin				 	 
					 INSERT INTO TMP_A2A_LOC_PART_OVERRIDE (
						  part_no,
						  site_location,
						  override_type,
						  override_quantity,
						  override_reason,
						  override_user,
						  begin_date,
						  action_code,
						  last_update_dt
					 )
					 VALUES
					 (
					 	  pPartNo,
						  pBaseName,
						  pOverrideType,
						  pTslOverrideQty,
						  pOverrideReason,
						  pTslOverrideUser,
						  pBeginDate,
						  pActionCode,
						  pLastUpdateDt
					 ) ;
					 
		    EXCEPTION 
			    WHEN DUP_VAL_ON_INDEX THEN
			  	   recordInfo ;
				   doUpdate ;
			end insertRow ;
			
	BEGIN
		 if pActionCode = amd_defaults.INSERT_ACTION
		 or pActionCode = amd_defaults.UPDATE_ACTION then
		 
			 IF A2a_Pkg.wasPartSent(pPartNo) 
			 AND pBaseName IS NOT NULL  THEN -- see if part exsits in amd_sent_to_a2a with action_code <> DELETE_ACTION
			 
				  insertRow ;
				  RETURN TRUE ;
				  
			ELSE
			  RETURN FALSE ;
			END IF ;
		else
			if a2a_pkg.isPartSent(pPartNo) then -- see if part exists in amd_sent_to_a2a with any action_code
			   insertRow ;
			   return true ;
			end if ;
		end if ;
	 exception WHEN others THEN
	 
  	   ErrorMsg(pSqlfunction => 'insertedTmpA2ALPO',
		   pTableName => 'tmp_a2a_loc_part_override',
		   pError_location => 130,
		   pKey1 => pPartNo,
  		   pKey2 => pBaseName,
		   pKey3 => pActionCode,
		   pComments => PKGNAME) ;
		RAISE ;
	
	END insertedTmpA2ALPO ;
	
	
	
	FUNCTION InsertRow(
			pPartNo                      AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			pLocSid                      AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			pTslOverrideQty				 AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE ,
			pTslOverrideUser			 AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE )
			RETURN NUMBER IS
		 returnCode NUMBER ;
	BEGIN
		 BEGIN
		    InsertAmdLocPartOverride (
		 	  pPartNo,
			  pLocSid,
			  pTslOverrideQty,
			  pTslOverrideUser,
			  Amd_Defaults.INSERT_ACTION,
			  SYSDATE ) ;
	
		 EXCEPTION WHEN OTHERS THEN
		 ErrorMsg(
				   pSqlfunction 	  	  => 'InsertRow.InsertAmdLocPartOverride',
				   pTableName  	  	  => 'amd_location_part_override',
				   pError_location => 140,
				   pKey1			  => pPartNo,
	   			   pKey2			  => pLocSid,
				   pComments		  => PKGNAME) ;
		 RAISE ;
	
		 END ;
		 BEGIN
		  	   IF insertedTmpA2ALPO(
				  pPartNo,
				  Amd_Utils.GetSpoLocation(pLocSid),
				  OVERRIDE_TYPE,
				  pTslOverrideQty,
				  OVERRIDE_REASON,
				  pTslOverrideUser,
				  SYSDATE,
				  Amd_Defaults.INSERT_ACTION,
				  SYSDATE
			    ) THEN
				 insertCnt := insertCnt + 1 ;
			END IF ;
	
	
		  END ;
		  RETURN SUCCESS ;
	EXCEPTION WHEN OTHERS THEN
		 ErrorMsg(
				   pSqlfunction => 'InsertRow.InsertTmpA2A_LPO',
				   pTableName  	  	  => 'tmp_a2a_loc_part_override',
				   pError_location => 150,
				   pKey1			  => pPartNo,
	   			   pKey2			  => pLocSid) ;
		RAISE ;
	END InsertRow ;
	
	
	FUNCTION UpdateRow(
			pPartNo                      AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			pLocSid                      AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			pTslOverrideQty				 AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE ,
			pTslOverrideUser			 AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE )
			RETURN NUMBER IS
			returnCode NUMBER ;
	BEGIN
		 BEGIN
		 	UpdateAmdLocPartOverride (
	  		  pPartNo,
			  pLocSid,
			  pTslOverrideQty,
			  pTslOverrideUser,
			  Amd_Defaults.UPDATE_ACTION,
			  SYSDATE ) ;
		 EXCEPTION WHEN OTHERS THEN
		 ErrorMsg(
				   pSqlfunction 	  	  => 'UpdateRow.InsertTmpA2A_LPO',
				   pTableName  	  	  => 'amd_location_part_override',
				   pError_location => 160,
				   pKey1			  => pPartNo,
	   			   pKey2			  => pLocSid) ;
		 RAISE ;
		 END ;
		 BEGIN
			IF insertedTmpA2ALPO (
				  pPartNo,
				  Amd_Utils.GetSpoLocation(pLocSid),
				  OVERRIDE_TYPE,
				  pTslOverrideQty,
				  OVERRIDE_REASON,
				  pTslOverrideUser,
				  SYSDATE,
				  Amd_Defaults.UPDATE_ACTION,
				  SYSDATE
		   ) THEN
		   	 updateCnt := updateCnt + 1 ;
		 END IF ;
		 END ;
		 RETURN SUCCESS ;
	EXCEPTION WHEN OTHERS THEN
		 ErrorMsg(
				   pSqlfunction 	  	  => 'UpdateRow.InsertTmpA2A_LPO',
				   pTableName  	  	  => 'tmp_a2a_loc_part_override',
				   pError_location => 170,
				   pKey1			  => pPartNo,
	   			   pKey2			  => pLocSid) ;
		RAISE ;
	END UpdateRow ;
	
	
	
	FUNCTION DeleteRow(
			pPartNo                      AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			pLocSid                      AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			pTslOverrideQty				 AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE ,
			pTslOverrideUser			 AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE )
			RETURN NUMBER IS
			returnCode NUMBER ;
	BEGIN
		 BEGIN
			 UpdateAmdLocPartOverride (
		  		  pPartNo,
				  pLocSid,
				  pTslOverrideQty,
				  pTslOverrideUser,
				  Amd_Defaults.DELETE_ACTION,
				  SYSDATE ) ;
		 EXCEPTION WHEN OTHERS THEN
		 ErrorMsg(
				   pSqlfunction 	  	  => 'DeleteRow.UpdateAmdLocPartOverride',
				   pTableName  	  	  => 'amd_location_part_override',
				   pError_location => 180,
				   pKey1			  => pPartNo,
	   			   pKey2			  => pLocSid) ;
		 RAISE ;
		 END ;
		 declare
		 		action_code tmp_a2a_loc_part_override.ACTION_CODE%type ;
		 BEGIN
		 	  if a2a_pkg.isPartValid(pPartNo) then
			  	 action_code := amd_defaults.UPDATE_ACTION ;
			  else
			  	 action_code := amd_defaults.DELETE_ACTION ;
			  end if ;
		 	  
		 	  -- deletion of parts handled by part info delete
		 	--IF (NOT amd_location_part_leadtime_pkg.IsPartDeleted(pPartNo)) THEN
		 		IF insertedTmpA2ALPO (
		 			  pPartNo,
		 			  Amd_Utils.GetSpoLocation(pLocSid),
		 			  OVERRIDE_TYPE,
		 			  0, -- quantity needs to be set to zero when deleting
		 			  OVERRIDE_REASON,
		 			  pTslOverrideUser,
		 			  SYSDATE,
		 			  action_code,
		 			  SYSDATE
		 	   ) THEN
			   deleteCnt := deleteCnt + 1 ;
			 END IF ;
			--END IF ;
		 END ;
	  	RETURN SUCCESS ;
	EXCEPTION WHEN OTHERS THEN
		 ErrorMsg(
				   pSqlfunction 	  	  => 'DeleteRow',
				   pTableName  	  	  => 'tmp_a2a_loc_part_override',
				   pError_location => 190,
				   pKey1			  => pPartNo,
	   			   pKey2			  => pLocSid) ;
		RAISE ;
	END DeleteRow ;
	
	FUNCTION IsNumeric(pString VARCHAR2) RETURN VARCHAR2 IS
			 ret VARCHAR2(1) ;
			 I NUMBER ;
	BEGIN
		 BEGIN
		 	  IF pString IS NULL THEN
			  	 ret := 'N' ;
			  ELSE
			     I := TO_NUMBER(pString) ;
			     ret := 'Y' ;
			  END IF ;
		 EXCEPTION WHEN OTHERS THEN
		 	  ret := 'N' ;
		 END ;
		 RETURN ret ;
	END ;
	
	PROCEDURE LoadUK IS
	
		CURSOR cur_cand IS
			SELECT spo_prime_part_no part_no,
				  loc_sid
				  FROM AMD_SENT_TO_A2A asta, AMD_SPARE_NETWORKS asn
				  WHERE asta.part_no = asta.spo_prime_part_no
				  AND asn.loc_id = Amd_Defaults.AMD_UK_LOC_ID
				  AND asta.action_code != Amd_Defaults.DELETE_ACTION ;
	
	 	CURSOR cur_stock IS
			SELECT Amd_Partprime_Pkg.getSuperPrimePart(asp.part_no) part_no,
				   SUM(NVL(stock_level, 0)) tsl_override_qty
				  FROM WHSE w, AMD_SPARE_PARTS asp
				  WHERE w.part = asp.part_no
				  AND w.sc LIKE 'C17%CODUKBG'
		 	      AND asp.action_code != Amd_Defaults.DELETE_ACTION
				  GROUP BY	Amd_Partprime_Pkg.getSuperPrimePart(asp.part_no) ;
	
		returnCode NUMBER ;
		TYPE partNo_stock IS TABLE OF NUMBER INDEX BY AMD_SPARE_PARTS.part_no%TYPE  ;
		partNo_stockLevel partNo_stock ;
		tslOverrideQty AMD_LOCATION_PART_OVERRIDE.TSL_OVERRIDE_QTY%TYPE ;
		I NUMBER := 0 ;
		stock_cnt NUMBER := 0 ;
		cand_cnt NUMBER := 0 ;
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 200,
				pKey1 => 'LoadUK',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		BEGIN
			FOR rec IN cur_stock
			LOOP
				BEGIN
					 IF ( rec.part_no IS NOT NULL ) THEN
					 	partNo_stockLevel(rec.part_no) := rec.tsl_override_qty ;
					 END IF ;
				EXCEPTION WHEN OTHERS THEN
					ErrorMsg(
				   	   pSqlfunction 	  	  => 'LoadUk',
					   pTableName  	  	  => 'tmp_amd_location_part_override',
					   pError_location => 210,
					   pKey1			  => 'partNo: ' || rec.part_no,
		   			   pKey2			  => 'qty: ' || rec.tsl_override_qty) ;
					RAISE ;
			   	END ;
				stock_cnt := stock_cnt + 1 ;
			END LOOP ;
			FOR rec IN cur_cand
			LOOP
				tslOverrideQty := 0 ;
				BEGIN
					tslOverrideQty := partNo_stockLevel(rec.part_no) ;
				EXCEPTION WHEN NO_DATA_FOUND THEN
					tslOverrideQty := 0 ;
				END ;
				BEGIN
					 InsertTmpAmdLocPartOverride(
					 	rec.part_no,
						rec.loc_sid,
						tslOverrideQty,
						NULL,
						Amd_Defaults.INSERT_ACTION,
						SYSDATE
					 ) ;
				EXCEPTION WHEN OTHERS THEN
				  ErrorMsg(
				   pSqlfunction	  	  => 'LoadUk',
					   pTableName  	  	  => 'tmp_amd_location_part_override',
					   pError_location => 220,
					   pKey1			  => 'partNo: ' || rec.part_no,
		   			   pKey2			  => 'locSid: ' || rec.loc_sid) ;
					   RAISE ;
			   	END ;
				IF (I > COMMITAFTER) THEN
				   I := 0 ;
				   COMMIT ;
				END IF ;
				I := I + 1 ;
				cand_cnt := cand_cnt + 1 ;
			END LOOP ;
		END ;
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 230,
				pKey1 => 'LoadUK',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'stock_cnt=' || stock_cnt, 
				pKey4 => 'cand_cnt=' || cand_cnt ) ;
	EXCEPTION WHEN OTHERS THEN
		 ErrorMsg(pSqlfunction => 'LoadUk',pTableName => 'tmp_amd_location_part_override',
					   pError_location => 240 ) ;
		RAISE ;
	END LoadUk ;
	
	
	PROCEDURE LoadBasc IS
		CURSOR cur_cand IS
			SELECT spo_prime_part_no part_no,
				  loc_sid
				  FROM AMD_SENT_TO_A2A asta, AMD_SPARE_NETWORKS asn
				  WHERE asta.part_no = asta.spo_prime_part_no
				  AND asn.loc_id = Amd_Defaults.AMD_BASC_LOC_ID
				  AND asta.action_code != Amd_Defaults.DELETE_ACTION ;
	
	 	CURSOR cur_stock IS
			SELECT Amd_Partprime_Pkg.getSuperPrimePart(asp.part_no) part_no,
				   SUM(NVL(stock_level, 0)) tsl_override_qty
				  FROM WHSE w, AMD_SPARE_PARTS asp
				  WHERE w.part = asp.part_no
				  AND sc = 'C17PCAG'
		 	      AND asp.action_code != Amd_Defaults.DELETE_ACTION
	 			  GROUP BY	Amd_Partprime_Pkg.getSuperPrimePart(asp.part_no) ;
	
		returnCode NUMBER ;
		TYPE partNo_stock IS TABLE OF NUMBER INDEX BY AMD_SPARE_PARTS.part_no%TYPE  ;
		partNo_stockLevel partNo_stock ;
		tslOverrideQty AMD_LOCATION_PART_OVERRIDE.TSL_OVERRIDE_QTY%TYPE ;
		I NUMBER := 0 ;
		stock_cnt NUMBER := 0 ;
		cand_cnt NUMBER := 0 ;
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 250,
				pKey1 => 'LoadBasc',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		BEGIN
			FOR rec IN cur_stock
			LOOP
				BEGIN
					 IF ( rec.part_no IS NOT NULL ) THEN
					 	 partNo_stockLevel(rec.part_no) := rec.tsl_override_qty ;
					 END IF ;
				EXCEPTION WHEN OTHERS THEN
					ErrorMsg(
					   pSqlfunction 	  	  => 'LoadBasc',
					   pTableName  	  	  => 'tmp_amd_location_part_override',
					   pError_location => 260,
					   pKey1			  => 'partNo: ' || rec.part_no,
		   			   pKey2			  => 'qty: ' || rec.tsl_override_qty) ;
					   RAISE ;
			   	END ;
				stock_cnt := stock_cnt + 1 ;
			END LOOP ;
			FOR rec IN cur_cand
			LOOP
				tslOverrideQty := 0 ;
				BEGIN
					tslOverrideQty := partNo_stockLevel(rec.part_no) ;
				EXCEPTION WHEN NO_DATA_FOUND THEN
					tslOverrideQty := 0 ;
				END ;
				BEGIN
					 InsertTmpAmdLocPartOverride(
					 	rec.part_no,
						rec.loc_sid,
						tslOverrideQty,
						NULL,
						Amd_Defaults.INSERT_ACTION,
						SYSDATE
					 ) ;
				EXCEPTION WHEN OTHERS THEN
					ErrorMsg(
					   pSqlfunction 	  	  => 'LoadBasc',
					   pTableName  	  	  => 'tmp_amd_location_part_override',
					   pError_location => 270,
					   pKey1			  => 'partNo: ' || rec.part_no,
		   			   pKey2			  => 'locSid: ' || rec.loc_sid) ;
					RAISE ;
			   	END ;
				IF (I > COMMITAFTER) THEN
				   I := 0 ;
				   COMMIT ;
				END IF ;
				I := I + 1 ;
				cand_cnt := cand_cnt + 1 ;
			END LOOP ;
		END ;
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 280,
				pKey1 => 'LoadBasc',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'stock_cnt=' || stock_cnt,
				pKey4 => 'cand_cnt=' || cand_cnt) ;
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(
		   pSqlfunction 	  	  => 'LoadBasc',
		   pTableName  	  	  => 'tmp_amd_location_part_override',
		   pError_location => 290) ;
		RAISE ;
	END LoadBasc ;
	
	PROCEDURE LoadFslMob IS
		CURSOR cur IS
			SELECT spo_prime_part_no part_no,
				   loc_sid,
				   0,
				   NULL,
				   Amd_Defaults.INSERT_ACTION,
				   SYSDATE
				   FROM AMD_SENT_TO_A2A asta, AMD_SPARE_NETWORKS asn
				   WHERE asta.spo_prime_part_no = asta.part_no
				   AND asn.loc_type IN ('MOB', 'FSL')
				   AND asta.action_code != Amd_Defaults.DELETE_ACTION
				   AND asn.action_code != Amd_Defaults.DELETE_ACTION;
	
		CURSOR cur_req IS
			SELECT Amd_Partprime_Pkg.getSuperPrimePart(ansi.prime_part_no) part_no,
				   loc_sid,
				   SUM(NVL(r.demand_level,0)) demand_level
				   FROM RAMP r, AMD_NATIONAL_STOCK_ITEMS ansi, AMD_SENT_TO_A2A asta, AMD_SPARE_NETWORKS asn
				   WHERE r.sc LIKE 'C170008%'
				   AND SUBSTR(r.sc, 8, 6) = asn.loc_id
				   AND asn.loc_type IN ('MOB', 'FSL')
				   AND REPLACE(r.current_stock_number, '-') = ansi.nsn
				   AND ansi.prime_part_no = asta.part_no
				   AND Amd_Location_Part_Override_Pkg.IsNumeric(ansi.nsn) = 'Y'
				   AND ansi.action_code != Amd_Defaults.DELETE_ACTION
				   AND asta.action_code != Amd_Defaults.DELETE_ACTION
				   AND asn.action_code != Amd_Defaults.DELETE_ACTION
				   GROUP BY  Amd_Partprime_Pkg.getSuperPrimePart(ansi.prime_part_no) , loc_sid
				   HAVING SUM(NVL(r.demand_level,0))  > 0 ;
	
		TYPE ARRAY IS TABLE OF TMP_AMD_LOCATION_PART_OVERRIDE%ROWTYPE;
		l_data ARRAY;
		returnCode NUMBER ;
		I NUMBER := 0 ;
		cur_cnt NUMBER := 0 ;
		req_cnt NUMBER := 0 ;
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 300,
				pKey1 => 'LoadFslMod',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		BEGIN
			OPEN cur ;
	    	LOOP
			    FETCH cur BULK COLLECT INTO l_data LIMIT BULKLIMIT ;
				cur_cnt := cur_cnt + l_data.COUNT ;
		    	FORALL i IN 1..l_data.COUNT
		    	   INSERT INTO TMP_AMD_LOCATION_PART_OVERRIDE VALUES l_data(i);
				   COMMIT ;
		    	EXIT WHEN cur%NOTFOUND;			
		    END LOOP;
	    	CLOSE cur;
			COMMIT ;
	
		EXCEPTION WHEN OTHERS THEN
					ErrorMsg(
					   pSqlfunction 	  	  => 'LoadFslMob',
				   pTableName  	  	  => 'tmp_amd_location_part_override',
				   pError_location => 310) ;
				   RAISE ;
	  	END ;
		I := 0 ;
		FOR rec IN cur_req
		LOOP
	
			BEGIN
				UPDATE TMP_AMD_LOCATION_PART_OVERRIDE
					SET	   tsl_override_qty = rec.demand_level
					WHERE part_no = rec.part_no
							  AND loc_sid = rec.loc_sid ;
			EXCEPTION WHEN OTHERS THEN
					ErrorMsg(
					   pSqlfunction 	  	  => 'LoadFslMob',
				   pTableName  	  	  => 'tmp_amd_location_part_override',
				   pError_location => 320,
				   pKey1			  => rec.part_no,
	   			   pKey2			  => rec.loc_sid) ;
				   RAISE ;
	  		END ;
			IF (I > COMMITAFTER) THEN
			   COMMIT ;
			   I := 0 ;
			END IF ;
			I := I + 1 ;
			req_cnt := req_cnt + 1 ;
		END LOOP ;
		COMMIT ;
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 330,
				pKey1 => 'LoadFslMod',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'cur_cnt=' || cur_cnt,
				pKey4 => 'req_cnt=' || req_cnt) ;
	exception when others then			  
		 ErrorMsg(
				   pSqlfunction 	  => 'LoadFslMob',
				   pTableName  	  	  => 'tmp_amd_location_part_override',
				   pError_location => 340) ;
		 raise ;	
	END LoadFslMob ;
	
	
	PROCEDURE LoadWhse IS
		TYPE ARRAY IS TABLE OF TMP_AMD_LOCATION_PART_OVERRIDE%ROWTYPE;
		l_data ARRAY;
	
		CURSOR cursor_warehouse_parts IS
			   SELECT spo_prime_part_no part_no,
			   		  loc_sid,
					  0 tsl_override_qty,
					  NULL tsl_override_user,
					  'A' action_code,
					  SYSDATE last_update_dt
				   FROM AMD_SENT_TO_A2A asta, AMD_SPARE_NETWORKS asn
				   WHERE asta.spo_prime_part_no = asta.part_no
				   AND asn.loc_id = Amd_Defaults.AMD_WAREHOUSE_LOCID
				   AND asta.action_code != Amd_Defaults.DELETE_ACTION
				   AND asn.action_code != Amd_Defaults.DELETE_ACTION
				   and asn.SPO_LOCATION is not null ;
	
			 -- get all those whse where the rbl run had 0 value for and
			 --	1) sum all the tsls where FSL, MOB, UAB
			 --	2) from Total Spo Inventory, subtract out those from 1)
	
	
			-- tmp_amd_location_part_override is already by spo prime, no need to determine
		CURSOR cursor_peacetimeBasesSum IS
			  SELECT part_no, SUM(NVL(tsl_override_qty,0)) qty
			  	   FROM TMP_AMD_LOCATION_PART_OVERRIDE t, AMD_SPARE_NETWORKS asn
				   WHERE t.loc_sid = asn.loc_sid
				   AND t.action_code != Amd_Defaults.DELETE_ACTION
				   AND asn.action_code != Amd_Defaults.DELETE_ACTION
				   AND ( loc_type IN ('MOB', 'FSL', 'UAB', 'COD')
				   	     OR
						 loc_id IN (Amd_Defaults.AMD_BASC_LOC_ID, Amd_Defaults.AMD_UK_LOC_ID )
					   )
				   and asn.SPO_LOCATION is not null
				   GROUP BY part_no ;
		
		Cursor cursor_wartimeRspSum is
			   select part_no, sum(nvl(rsp_level,0)) qty
			   from amd_rsp_sum
			   group by part_no ;
	
		Cursor cursor_peacetimeBO_Spo_Sum is
			   select spo_prime_part_no,  qty
			   from amd_backorder_spo_sum
			   order by spo_prime_part_no ;
			   
				  -- get the whole list and the sum to spo prime
		CURSOR cursor_peacetimeSpoInv IS
			  SELECT spo_prime_part_no part_no,
			  		 SUM(NVL(spo_total_inventory,0)) qty
					  FROM AMD_SENT_TO_A2A asta, AMD_NATIONAL_STOCK_ITEMS ansi
					  WHERE asta.part_no = ansi.prime_part_no
					  AND asta.action_code != Amd_Defaults.DELETE_ACTION
					  AND ansi.action_code != Amd_Defaults.DELETE_ACTION
					  GROUP BY spo_prime_part_no ;
	
		TYPE partNo_sum IS TABLE OF NUMBER INDEX BY AMD_SPARE_PARTS.part_no%TYPE  ;
		-- arrays where index is nsi_sid, and the values are the sums
		partNoCandidates_sum partNo_sum ;
		partNoBases_sum partNo_sum ;
		partNoSpoInv_sum partNo_sum ;
		wareHouseLocSid AMD_SPARE_NETWORKS.loc_sid%TYPE ;
		basesTsl_Rsp_Backorder_sum NUMBER ;
		sumOfSpoTotalInv NUMBER ;
		AtlantaWarehouseQty NUMBER ;
		returnCode NUMBER ;
		I NUMBER := 0 ;
		cur_cnt NUMBER := 0 ;
		baseSum_cnt NUMBER := 0 ;
		spoInv_cnt NUMBER := 0 ;
		rsp_cnt number := 0 ;
		spoSum_cnt number := 0 ;
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 350,
				pKey1 => 'LoadWhse',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
			-- Calculation WareHouse TSLs
	
		BEGIN
			 -- load partNoBases_sum array where each partNo index has the sum for the bases
			FOR rec IN cursor_peacetimeBasesSum
			LOOP
				partNoBases_sum(rec.part_no) := rec.qty ;
				baseSum_cnt := baseSum_cnt + 1 ;
			END LOOP ;
			
			for rec in cursor_wartimeRspSum
			loop
				begin
					 partNoBases_sum(rec.part_no) := partNoBases_sum(rec.part_no) + rec.qty ;
				exception when standard.no_data_found then
					 partNoBases_sum(rec.part_no) := rec.qty ;
				end ;
				rsp_cnt := rsp_cnt + 1 ;
			end loop ;
	
			for rec in cursor_peacetimeBO_Spo_Sum
			loop
				begin
					 partNoBases_sum(rec.spo_prime_part_no) := partNoBases_sum(rec.spo_prime_part_no) + rec.qty ;
				exception when standard.no_data_found then
					 partNoBases_sum(rec.spo_prime_part_no) := rec.qty ;
				end ;
				spoSum_cnt := spoSum_cnt + 1 ;
			end loop ;
			 -- load partNoSpoInv_sum array where each partNo index has the total_spo_inventory
			FOR rec IN cursor_peacetimeSpoInv
			LOOP
				partNoSpoInv_sum(rec.part_no) := rec.qty ;
				spoInv_cnt := spoInv_cnt + 1 ;
			END LOOP ;
	
	--		wareHouseLocSid := amd_utils.GetLocSid(amd_defaults.AMD_WAREHOUSE_LOCID) ;
	
			-- cycle thru each of the zero candidates
			-- line up the partNo and do the necessary calculation.
			-- per each partNo
			-- 	   total_spo_inventory minus bases sum
			-- 	   if result negative, make result zero
			I := 0 ;
			FOR rec IN cursor_warehouse_parts
			LOOP
				BEGIN
					BEGIN
						 basesTsl_Rsp_Backorder_sum := partNoBases_sum(rec.part_no) ;
					EXCEPTION WHEN NO_DATA_FOUND THEN
						 basesTsl_Rsp_Backorder_sum := 0 ;
					END ;
					BEGIN
						 sumOfSpoTotalInv := partNoSpoInv_sum(rec.part_no) ;
					EXCEPTION WHEN NO_DATA_FOUND THEN
						 sumOfSpoTotalInv := 0 ;
					END ;
					AtlantaWarehouseQty := sumOfSpoTotalInv - basesTsl_Rsp_Backorder_sum ;
					IF (AtlantaWarehouseQty < 0) THEN
					   AtlantaWarehouseQty := 0 ;
					END IF ;
				    INSERT INTO TMP_AMD_LOCATION_PART_OVERRIDE
		 			    (
						  part_no,
						  loc_sid,
						  tsl_override_qty,
						  tsl_override_user,
						  action_code,
						  last_update_dt
		 				)
		 				VALUES
		 				(
		 				  rec.part_no,
						  rec.loc_sid,
						  AtlantaWarehouseQty,
						  NULL,
						  Amd_Defaults.INSERT_ACTION,
						  SYSDATE
		 				) ;
					   /*
						UPDATE tmp_amd_location_part_override
							SET tsl_override_AtlantaWarehouseQty = AtlantaWarehouseQty
							WHERE part_no = rec.part_no
							AND loc_sid = wareHouseLocSid ;
						*/
				EXCEPTION WHEN OTHERS THEN
					ErrorMsg(
					   pSqlfunction 	  	  => 'LoadWhse',
				   pTableName  	  	  => 'tmp_amd_location_part_override',
				   pError_location => 360,
				   pKey1			  => 'partNo: ' || rec.part_no) ;
				   RAISE ;
			    END ;
				IF (I > COMMITAFTER) THEN
			   	   COMMIT ;
			   	   I := 0 ;
				END IF ;
				I := I + 1 ;
				cur_cnt := cur_cnt + 1 ;
			END LOOP ;
	
		EXCEPTION WHEN OTHERS THEN
					ErrorMsg(
					   pSqlfunction 	  	  => 'LoadWhse',
				   pTableName  	  	  => 'tmp_amd_location_part_override',
				   pError_location => 370) ;
				   RAISE ;
		END ;
	
		COMMIT ;
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 380,
				pKey1 => 'LoadWhse',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'cur_cnt=' || to_char(cur_cnt),
				pKey4 => 'baseSum_cnt=' || to_char(baseSum_cnt),
				pData => 'spoInv_cnt=' || to_char(spoInv_cnt) || ' rsp_cnt=' || to_char(rsp_cnt) || ' spoSum_cnt=' || to_char(spoSum_cnt)) ;
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(
		   pSqlfunction 	  	  => 'LoadWhse',
	   pTableName  	  	  => 'tmp_amd_location_part_override',
	   pError_location => 390) ;
	   RAISE ;
	END LoadWhse ;
	
	
	FUNCTION GetFirstLogonIdForPart(pNsiSid AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE) RETURN AMD_PLANNER_LOGONS.logon_id%TYPE IS
		CURSOR cur( pNsiSid AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE ) IS
			SELECT apl.*
				FROM AMD_PLANNER_LOGONS apl, AMD_PLANNERS ap, AMD_NATIONAL_STOCK_ITEMS ansi
				WHERE ansi.nsi_sid = pNsiSid
				AND Amd_Preferred_Pkg.GetPreferredValue(ansi.planner_code_cleaned, ansi.planner_code) = ap.planner_code
				AND ap.planner_code = apl.planner_code
				AND ap.action_code != Amd_Defaults.DELETE_ACTION
				AND apl.action_code != Amd_Defaults.DELETE_ACTION
				-- AND ansi.action_code != Amd_Defaults.DELETE_ACTION the part may be deleted but we still
				-- need to send data when the a2a_pkg.loadAllA2A is performed and whatever logonId is needed for 
				-- the part should be sent too
				ORDER BY apl.planner_code, data_source, logon_id ;
		 retLogonId AMD_PLANNER_LOGONS%ROWTYPE := NULL ;
	BEGIN
		 IF NOT cur%ISOPEN
		 THEN
		 	OPEN cur(pNsiSid) ;
		 END IF ;
		 FETCH cur INTO retLogonId ;
		 IF cur%NOTFOUND THEN
		 	retLogonId.logon_id := NULL ;
		 END IF ;
		 CLOSE cur ;
		 RETURN retLogonId.logon_id ;
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(
		   pSqlfunction 	  	  => 'GetFirstLogonIdForPart',
	   pTableName  	  	  => 'amd_planner_logons',
	   pError_location => 400) ;
	   RAISE ;
	END GetFirstLogonIdForPart ;
	
	PROCEDURE LoadOverrideUsers IS
		CURSOR cur IS
			 SELECT part_no, nsi_sid, nsn
			 FROM TMP_AMD_LOCATION_PART_OVERRIDE talpo, AMD_NATIONAL_STOCK_ITEMS ansi
			 WHERE talpo.part_no = ansi.prime_part_no AND
			 	   talpo.action_code != Amd_Defaults.DELETE_ACTION AND
			 	   ansi.action_code != Amd_Defaults.DELETE_ACTION
			 ORDER BY nsi_sid;
		lastNsiSid AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE := -9993 ;
		-- TYPE partNo_logonId_tab IS TABLE OF amd_planner_logons.logon_id%TYPE INDEX BY amd_spare_parts.part_no%TYPE  ;
		-- partNo_logonId partNo_logonId_tab ;
		-- rowPartNo amd_spare_parts.part_no%TYPE  ;
		-- defaultUser amd_location_part_override.tsl_override_user%TYPE := Amd_Defaults.GetParamValue('override_user_default');
		tslOverrideUser AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE ;
		returnCode NUMBER ;
		cur_cnt NUMBER := 0 ;
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 410,
				pKey1 => 'LoadOverrideUsers',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
				
		 FOR rec IN cur
		 LOOP
		 	 BEGIN
			 	 IF (lastNsiSid != rec.nsi_sid) THEN
				 	-- partNo_logonId(rec.part_no) := nvl(GetFirstLogonIdForPart(rec.nsi_sid), amd_defaults.GetLogonId(rec.nsn) ) ;
					tslOverrideUser := NVL( GetFirstLogonIdForPart(rec.nsi_sid), Amd_Defaults.GetLogonId(rec.nsn) ) ;
					UPDATE TMP_AMD_LOCATION_PART_OVERRIDE
			 	 	   SET 	tsl_override_user = tslOverrideUser
			 	 	   WHERE	part_no = rec.part_no ;
				 END IF ;
				 lastNsiSid := rec.nsi_sid ;
			 EXCEPTION WHEN OTHERS THEN
					ErrorMsg(
					   pSqlfunction 	  	  => 'LoadOverrideUsers',
				   pTableName  	  	  => 'tmp_amd_location_part_override',
				   pError_location => 420,
				   pKey1			  => 'nsiSid: ' || rec.nsi_sid,
	   			   pKey2			  => 'partNo: ' || rec.part_no) ;
				   RAISE ;
			END ;
			cur_cnt := cur_cnt + 1 ;
		 END LOOP ;
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 430,
				pKey1 => 'LoadOverrideUsers',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'cur_cnt=' || cur_cnt) ;
		COMMIT ;
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(
		   pSqlfunction 	  	  => 'LoadOverrideUsers',
	   pTableName  	  	  => 'tmp_amd_location_part_override',
	   pError_location => 440) ;
	   RAISE ;
	END LoadOverrideUsers ;
	
	PROCEDURE processTsl(tsl IN tslCur) IS
		tslOverrideUser TMP_A2A_LOC_PART_OVERRIDE.OVERRIDE_USER%TYPE ;
		delete_cnt NUMBER := 0 ;
		update_cnt NUMBER := 0 ;
		insert_cnt NUMBER := 0 ;
		rec_cnt NUMBER := 0 ;
		rec tslRec ;
				
		procedure countTran is
		begin
			 if rec.action_code = amd_defaults.INSERT_ACTION then
			 	insert_cnt := insert_cnt + 1 ;
			elsif rec.action_code = amd_defaults.UPDATE_ACTION then
				update_cnt := update_cnt + 1 ;
			else
				delete_cnt := delete_cnt + 1 ;
			end if ;
		end countTran ;
		
	BEGIN
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 450,
				pKey1 => 'processTsl',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
		 LOOP
		 	 FETCH tsl INTO rec ;
			 EXIT WHEN tsl%NOTFOUND ;
			 rec_cnt := rec_cnt + 1 ;
			 IF MOD(insert_cnt + delete_cnt + update_cnt,  COMMIT_THRESHOLD) = 0 THEN
			 	COMMIT ;
			 END IF  ;
			 BEGIN
				tslOverrideUser := NVL(GetFirstLogonIdForPart(rec.nsi_sid), Amd_Defaults.GetLogonId(rec.nsn) ) ;
				IF insertedTmpA2ALPO (
						  rec.spo_prime_part_no,
						  rec.spo_location,
						  OVERRIDE_TYPE,
						  rec.override_quantity,
						  OVERRIDE_REASON,
						  tslOverrideUser,
						  SYSDATE,
						  rec.action_code,
						  SYSDATE
						)	THEN
						    countTran ;
				END IF ;
			EXCEPTION WHEN OTHERS THEN
				ErrorMsg(pSqlfunction => 'processTsl',
				   pTableName => 'tmp_amd_location_part_override',
				   pError_location => 460,
				   pKey1 => 'spo_prime_part: ' || rec.spo_prime_part_no,
	   			   pKey2 => 'action_code: ' || rec.action_code,
				   pKey3 => 'spo_location: ' || rec.spo_location,
				   pKey4 => 'insert_cnt:' || to_char(insert_cnt) || ' delete_cnt:' || to_char(delete_cnt), 
				   pComments => 'update_cnt: ' || to_char(update_cnt) || ' rec_cnt=' || to_char(rec_cnt)) ;

				   RAISE ;
			END ;
			 
		 END LOOP ;
		 
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 470,
				pKey1 => 'processTsl',
				pKey2 => 'rec_cnt=' || to_char(rec_cnt),
				pKey3 => 'insert_cnt=' || to_char(insert_cnt),
				pKey4 => 'delete_cnt=' || to_char(delete_cnt), 
				pData => 'update_cnt=' || to_char(update_cnt),
				pComments => 'processTsl ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	    COMMIT ;
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(
		   pSqlfunction => 'processTsl',
	   	   pTableName => 'tmp_a2a_loc_part_override',
	   	   pError_location => 480) ;
	   	   RAISE ;
	END processTsl ;
	
	PROCEDURE loadZeroTslA2AByDate(pDoAllA2A IN BOOLEAN, 
			  from_dt IN DATE, to_dt IN DATE, pSpolocation IN VARCHAR2) IS
			
	BEGIN
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 490,
				pKey1 => 'LoadZeroTslA2AByDate', 
				pKey2 => 'from_dt=' || to_char(from_dt,'MM/DD/YYYY'),
				pKey3 => 'to_dt=' ||  to_char(to_dt,'MM/DD/YYYY'),
				pKey4 => 'pDoAllA2A=' || amd_utils.boolean2Varchar2(pDoAllA2A) || ' pSpoLocation=' || pSpoLocation,
				pData => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
		loadZeroTslA2A(pDoAllA2A, pSpoLocation, from_dt, to_dt) ;
	
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 500,
				pKey1 => 'LoadZeroTslA2AByDate',
				pKey2 => 'from_dt=' || to_char(from_dt,'MM/DD/YYYY'),
				pKey3 => 'to_dt=' || to_char(to_dt,'MM/DD/YYYY'),
				pKey4 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(
		   pSqlfunction 	  	  => 'loadZeroTslA2AByDate',
	   pTableName  	  	  => 'tmp_a2a_loc_part_override',
	   pError_location => 510) ;
	   RAISE ;
	END loadZeroTslA2AByDate ;
	
	PROCEDURE  LoadZeroTslA2A(pDoAllA2A BOOLEAN, pSpoLocation VARCHAR2,from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE)   IS
		
		tsl tslCur ;
		rc number ;
		
		procedure openTestData is
		begin
		  	writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 520,
	 		pKey1 => 'getTestData' ) ;
			commit ;

			   OPEN tsl FOR
			   SELECT distinct sent.spo_prime_part_no,
			   sent.action_code action_code,
			   sysdate,
			   pSpoLocation spo_location,
			   ansi.nsn,
			   ansi.nsi_sid,
			   0 override_AtlantaWarehouseQty
			   FROM  AMD_NATIONAL_STOCK_ITEMS ansi, amd_sent_to_a2a sent, amd_test_parts testParts
			   WHERE ansi.prime_part_no = sent.spo_prime_part_no
			   and sent.part_no = sent.spo_prime_part_no
			   and not exists (
					 SELECT null 
					 FROM TMP_A2A_LOC_PART_OVERRIDE
					 WHERE part_no = sent.spo_prime_part_no
					 AND site_location = pSpoLocation) 
			   AND ansi.action_code != Amd_Defaults.getDELETE_ACTION
			   AND sent.spo_prime_part_no = testParts.PART_NO ; 
		end openTestData ;
		
		procedure getAllData is
		begin
		  	writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 530,
	 		pKey1 => 'getAllData' ) ;
			commit ;

			   OPEN tsl FOR
			   SELECT distinct sent.spo_prime_part_no,
			   sent.action_code action_code,
			   sysdate,
			   pSpoLocation spo_location,
			   ansi.nsn,
			   ansi.nsi_sid,
			   0 override_AtlantaWarehouseQty
			   FROM  AMD_NATIONAL_STOCK_ITEMS ansi, amd_sent_to_a2a sent
			   WHERE ansi.prime_part_no = sent.spo_prime_part_no
			   and sent.part_no = sent.spo_prime_part_no
			   and not exists (
					 SELECT null 
					 FROM TMP_A2A_LOC_PART_OVERRIDE
					 WHERE part_no = sent.spo_prime_part_no
					 AND site_location = pSpoLocation) 
			   AND ansi.action_code != Amd_Defaults.getDELETE_ACTION ;
			   
		end getAllData ;
		
		procedure getDataByLastUpdateDt is
		begin
		  	writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 540,
	 		pKey1 => 'getDataByLastUpdateDt' ) ;
			commit ;
			OPEN tsl FOR
			   SELECT distinct sent.spo_prime_part_no,
			   sent.action_code action_code,
			   sysdate,
			   pSpoLocation spo_location,
			   ansi.nsn,
			   ansi.nsi_sid,
			   0 override_AtlantaWarehouseQty
			   FROM  AMD_NATIONAL_STOCK_ITEMS ansi, amd_sent_to_a2a sent, amd_spare_parts parts
			   WHERE ansi.prime_part_no = sent.spo_prime_part_no
			   and sent.part_no = sent.spo_prime_part_no
			   and ansi.action_code != Amd_Defaults.getDELETE_ACTION			   
			   and parts.part_no = sent.spo_prime_part_no
			   and not exists (
					 SELECT null 
					 FROM TMP_A2A_LOC_PART_OVERRIDE
					 WHERE part_no = sent.spo_prime_part_no
					 AND site_location = pSpoLocation) 
			   and parts.action_code <> amd_defaults.getDELETE_ACTION
			   and  exists (select null
			   			    from amd_location_part_override
							where part_no = sent.spo_prime_part_no
							and (amd_utils.GetSpoLocation(loc_sid) = pSpoLocation 
								 or pSpoLocation in (Amd_Location_Part_Leadtime_Pkg.getVIRTUAL_UAB_SPO_LOCATION, 
								 				 Amd_Location_Part_Leadtime_Pkg.getVIRTUAL_COD_SPO_LOCATION) )
							and trunc(last_update_dt) between trunc(from_dt) and trunc(to_dt) ) ;  
		end getDataByLastUpdateDt ;
		
		procedure getDataByTranDtAndBatchTime is
		begin
				-- and then transaction_date >= amd_batch_jobs.start_time
		  	writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 550,
	 		pKey1 => 'getDataByTranDtAndBatchTime' ) ;
			commit ;
			   OPEN tsl FOR
				   SELECT distinct sent.spo_prime_part_no,
				   sent.action_code action_code,
				   sysdate,
				   pSpoLocation spo_location,
				   ansi.nsn,
				   ansi.nsi_sid,
				   0 override_AtlantaWarehouseQty
				   FROM  AMD_NATIONAL_STOCK_ITEMS ansi, 
				      amd_sent_to_a2a sent, amd_spare_parts parts
				   where ansi.prime_part_no = sent.spo_prime_part_no
				   and sent.part_no = sent.spo_prime_part_no
				   AND ansi.action_code != Amd_Defaults.getDELETE_ACTION
				   and parts.part_no = sent.spo_prime_part_no
				   and not exists (
						 SELECT null 
						 FROM TMP_A2A_LOC_PART_OVERRIDE
						 WHERE part_no = sent.spo_prime_part_no
						 AND site_location = pSpoLocation) 
				   and parts.action_code != amd_defaults.getDELETE_ACTION
				   and  exists (select null
				   			    from amd_location_part_override
								where part_no = sent.spo_prime_part_no
								and (amd_utils.GetSpoLocation(loc_sid) = pSpoLocation 
									 or pSpoLocation in (Amd_Location_Part_Leadtime_Pkg.getVIRTUAL_UAB_SPO_LOCATION, 
									 				 Amd_Location_Part_Leadtime_Pkg.getVIRTUAL_COD_SPO_LOCATION) )
								and trunc(last_update_dt) >= trunc(amd_batch_pkg.getLastStartTime) ) ;  
		end getDataByTranDtAndBatchTime ;		
		
	BEGIN
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 560,
				pKey1 => 'LoadZeroTslA2A',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'pDoAllA2A=' || amd_utils.boolean2Varchar2(pDoAllA2A),
				pKey4 => 'pSpoLocation=' || pSpoLocation,
				pData => 'from_dt=' || to_char(from_dt,'MM/DD/YYYY'),
				pComments => 'to_dt=' || to_char(to_dt,'MM/DD/YYYY') 
					  || ' useTestData=' || amd_utils.boolean2Varchar2(useTestData) ) ;
	    COMMIT ;
		
		-- pDoAllA2A has the highest priority
		IF pDoAllA2A THEN
		   IF useTestData THEN
		   	  openTestData ;
			ELSE
			  getAllData ;
			END IF ;
		ELSE
			-- then by date range
			IF TRUNC(from_dt) <> TRUNC(A2a_Pkg.start_dt) OR TRUNC(to_dt) <> TRUNC(SYSDATE) THEN
						getDataByLastUpdateDt ;
			ELSIF useTestData THEN
				  openTestData ;
			ELSE
				getDataByTranDtAndBatchTime ;
			END IF ;
		END IF ;
		
		processTsl(tsl) ;
		
		CLOSE tsl ;
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 570,
				pKey1 => 'LoadZeroTslA2A',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'pSpoLocation=' || pSpoLocation) ;
	    COMMIT ;
    exception when others then
		ErrorMsg(
		   pSqlfunction	  	  => 'LoadZeroTslA2A',
	   pTableName  	  	  => 'tmp_a2a_loc_part_override',
	   pError_location => 580) ;
		RAISE ;

	END LoadZeroTslA2A ;
	
	PROCEDURE LoadTmpAmdLocPartOverride IS
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 590,
				pKey1 => 'LoadTmpAmdLocPartOverride',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
				
		 Mta_Truncate_Table('tmp_amd_location_part_override','reuse storage');
		 Amd_Batch_Pkg.truncateIfOld('tmp_a2a_loc_part_override') ; 	 
		 COMMIT ;
		 LoadFslMob ;
		 LoadUk ;
		 LoadBasc ;
		 LoadWhse ;
		 LoadOverrideUsers ;
		 
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 600,
				pKey1 => 'LoadTmpAmdLocPartOverride',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
    exception when others then
		ErrorMsg(
		   pSqlfunction	  	  => 'LoadTmpAmdLocPartOverride',
	   pTableName  	  	  => 'tmp_amd_location_part_override',
	   pError_location => 610) ;
		RAISE ;

	END LoadTmpAmdLocPartOverride;
	
	PROCEDURE LoadZeroTslA2A(doAllA2A IN BOOLEAN := FALSE, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE) IS
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 620,
				pKey1 => 'LoadZeroTslA2A',
				pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
				pKey3 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
				pKey4 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
				pData => 'usesTestData=' || Amd_Utils.boolean2Varchar2(useTestData),
				pComments => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
			-- do Inserts/Deletes only, i.e. not initial load
		loadZeroTslA2APartsWithNoTsls(doAllA2A => doAllA2A, useTestData => useTestData) ;
		loadZeroTslA2A4DelSpoPrimParts(doAllA2A => doAllA2A, useTestData => useTestData) ;
		loadRspZeroTslA2A(doAllA2A => doAllA2A, useTestData => useTestData) ;
		LoadZeroTslA2A( doAllA2A, Amd_Location_Part_Leadtime_Pkg.VIRTUAL_COD_SPO_LOCATION, from_dt, to_dt, useTestData ) ;
		LoadZeroTslA2A( doAllA2A, Amd_Location_Part_Leadtime_Pkg.VIRTUAL_UAB_SPO_LOCATION, from_dt, to_dt, useTestData ) ;
		loadZeroTslA2A( doAllA2A, amd_location_part_override_pkg.THE_WAREHOUSE, from_dt, to_dt, useTestData) ;
	
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 630,
				pKey1 => 'LoadZeroTslA2A',
				pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
				pKey3 => 'from_dt=' ||  TO_CHAR(from_dt,'MM/DD/YYYY'),
				pKey4 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
				pData =>  'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
    exception when others then
		ErrorMsg(
		   pSqlfunction	 => 'LoadZeroTslA2A',
	   pTableName  	  	  => 'tmp_amd_location_part_override',
	   pError_location => 640) ;
		RAISE ;

	END LoadZeroTslA2A ;
	
	PROCEDURE loadA2AByDate( from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE) IS
		returnCode NUMBER ;
		doAllA2A BOOLEAN := TRUE ;
		cnt NUMBER := 0 ;
		lpo TMP_A2A_LOC_PART_OVERRIDE%ROWTYPE ;
		rc NUMBER ;
		dataByDate locPartOverrideCur ;
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 650,
				pKey1 => 'loadA2AByDate',
				pKey2 => 'from_dt=' || to_char(from_dt,'MM/DD/YYYY'),
				pKey3 => 'to_dt='  || to_char(to_dt,'MM/DD/YYYY'),
				pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
		 Amd_Batch_Pkg.truncateIfOld('tmp_a2a_loc_part_override') ;
		 OPEN dataByDate FOR
		 	 SELECT alpo.part_no,
			 		spo_location AS site_location,
					OVERRIDE_TYPE AS override_type,
					tsl_override_qty AS override_quantity,
					OVERRIDE_REASON AS override_reason,
					tsl_override_user,
					SYSDATE AS begin_date,
					NULL AS end_date,
					alpo.action_code AS action_code,
					SYSDATE AS last_update_dt
			 FROM AMD_LOCATION_PART_OVERRIDE alpo, AMD_SPARE_NETWORKS asn
			 WHERE alpo.loc_sid = asn.loc_sid
			 	   AND alpo.action_code != Amd_Defaults.DELETE_ACTION
				   AND TRUNC(alpo.last_update_dt) BETWEEN TRUNC(from_dt) AND TRUNC(to_dt)
				   AND alpo.part_no IN 
				   	   (SELECT DISTINCT spo_prime_part_no 
					    FROM AMD_SENT_TO_A2A 
					    WHERE action_code != Amd_Defaults.DELETE_ACTION) ;
		 processLocPartOverride(dataByDate) ;
		 CLOSE dataByDate ;
		 LoadZeroTslA2A( doAllA2A, from_dt, to_dt ) ;
	
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 660,
				pKey1 => 'loadA2AByDate',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
    exception when others then
		ErrorMsg(
		   pSqlfunction	 => 'LoadA2AByDate',
	   pTableName  	  	  => 'tmp_amd_location_part_override',
	   pError_location => 670) ;
		RAISE ;

	END loadA2AByDate ;
	
	PROCEDURE processLocPartOverride(locPartOverride IN locPartOverrideCur) IS
		cnt NUMBER := 0 ;
		lpo TMP_A2A_LOC_PART_OVERRIDE%ROWTYPE ;
		rec locPartOverrideRec ;
		rc number ;
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 680,
				pKey1 => 'processLocPartOverride',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
		 LOOP
		 	 FETCH locPartOverride INTO rec ;
			 EXIT WHEN locPartOverride%NOTFOUND ;
			 	 lpo.part_no := rec.part_no ;
				 lpo.site_location := rec.site_location ;
				 lpo.override_type := rec.override_type ;
				 lpo.override_quantity := rec.override_quantity ;
				 lpo.override_reason := rec.override_reason ;
				 lpo.override_user := rec.tsl_override_user ;
				 lpo.begin_date := rec.begin_date ;
				 lpo.end_date := rec.end_date ;
				 lpo.action_code := rec.action_code ;
				 lpo.last_update_dt := rec.last_update_dt ;
			 	 IF insertedTmpA2ALPO(lpo) THEN
			 	 	cnt := cnt + 1 ;
					IF MOD(cnt,COMMIT_THRESHOLD) = 0 THEN
					   COMMIT ;
					END IF ;
				 ELSE
				   Amd_Utils.debugMsg(pMsg => 'Part/site_location was not loaded to tmp_a2a_loc_part_override',
				   	  pPackage => 'amd_location_part_override_pkg.processLocPartOverride',
					  pLocation => 222,
					  pMsg2 =>rec.part_no, 
					  pMsg4 => rec.site_location) ;
				 END IF ;		 
		 END LOOP ;	 
		 writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 690,
				pKey1 => 'processLocPartOverride',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
		 		pKey3 => 'cnt=' || cnt) ;
		 COMMIT ;
	exception when others then
		ErrorMsg(pSqlfunction => 'processLocPartOverride',pTableName => 'tmp_a2a_loc_part_override',
			   pError_location => 700) ;
		RAISE ;
	END processLocPartOverride ;
	
	PROCEDURE LoadAllA2A( useTestData IN BOOLEAN := FALSE, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE) IS
		
		overrides locPartOverrideCur ;
		
		procedure getTestData is
		begin
		  	writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 710,
	 		pKey1 => 'getTestData' ) ;
			commit ;
		 	OPEN overrides FOR
			 	 SELECT alpo.part_no,
				 		spo_location AS site_location,
						OVERRIDE_TYPE AS override_type,
						case
							when sent.action_code = amd_defaults.getDELETE_ACTION or alpo.action_code = amd_defaults.getDELETE_ACTION then
								 0
							else
								tsl_override_qty
						end AS override_quantity,
						OVERRIDE_REASON AS override_reason,
						tsl_override_user,
						SYSDATE AS begin_date,
						NULL AS end_date,
						case sent.action_code
						 when amd_defaults.getDELETE_ACTION then
						 	  amd_defaults.getDELETE_ACTION -- The part is not longer valid
						 else
						 	 case alpo.action_code
							 	  when amd_defaults.getDELETE_ACTION then
								  	   amd_defaults.getUPDATE_ACTION -- the part is still valid, update the current value to zero
								  else
								  	  alpo.action_code
							 end
					    end AS action_code,
						SYSDATE AS last_update_dt
				 FROM AMD_LOCATION_PART_OVERRIDE alpo, AMD_SPARE_NETWORKS asn, amd_sent_to_a2a sent
				 WHERE alpo.loc_sid = asn.loc_sid
					   AND alpo.part_no = sent.part_no
					   and sent.SPO_PRIME_PART_NO is not null
					   and sent.PART_NO = sent.SPO_PRIME_PART_NO 
					   AND alpo.part_no IN (SELECT part_no FROM AMD_TEST_PARTS)
				union
				select distinct rsp.part_no,
				rsp_location,
				OVERRIDE_TYPE as override_type,
				case 
					 when rsp.action_code = amd_defaults.getDELETE_ACTION or sent.action_code = amd_defaults.getDELETE_ACTION then
					 	  0
					 else
					 	 rsp_level
				end override_quantity,
				OVERRIDE_REASON as override_reason,
				Amd_Location_Part_Override_Pkg.GetFirstLogonIdForPart(Amd_Utils.GetNsiSidFromPartNo(rsp.part_no)),
				sysdate as begin_date,
				null as end_date,
				case sent.action_code
					 when amd_defaults.getDELETE_ACTION then
					 	  amd_defaults.getDELETE_ACTION -- The part is not longer valid
					 else
					 	 case rsp.action_code
							 when amd_defaults.getDELETE_ACTION then
							 	  amd_defaults.getUPDATE_ACTION -- the part is still valid, update the current value to zero
							 else
					 	 	 	 rsp.action_code
						end					
				end AS action_code,
				sysdate as last_update_dt
				from amd_rsp_sum rsp, amd_sent_to_a2a sent, amd_spare_networks nwks
				where rsp.part_no = sent.part_no
				and sent.part_no = sent.spo_prime_part_no
				and sent.SPO_PRIME_PART_NO is not null
				and rsp.part_no in (select part_no from amd_test_parts)
				and substr(rsp_location,1,length(rsp_location) - 4) = nwks.mob
				and nwks.mob is not null ;							
		end getTestData ;
		
		procedure getDataByLastUpdateDt is
		begin
		  	writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 720,
	 		pKey1 => 'getDataByLastUpdateDt' ) ;
			commit ;
			OPEN overrides FOR
		 	 SELECT alpo.part_no,
			 		spo_location AS site_location,
					OVERRIDE_TYPE AS override_type,
					case
						when sent.action_code = amd_defaults.getDELETE_ACTION or alpo.action_code = amd_defaults.getDELETE_ACTION then
							 0
						else
							tsl_override_qty
					end AS override_quantity,
					OVERRIDE_REASON AS override_reason,
					tsl_override_user,
					SYSDATE AS begin_date,
					NULL AS end_date,
					case sent.action_code
						 when amd_defaults.getDELETE_ACTION then
						 	  amd_defaults.getDELETE_ACTION -- The part is not longer valid
						 else
						 	 case alpo.action_code
							 	  when amd_defaults.getDELETE_ACTION then
								  	   amd_defaults.getUPDATE_ACTION -- the part is still valid, update the current value to zero
								  else
								  	  alpo.action_code
							 end
					end AS action_code,
					SYSDATE AS last_update_dt
			 FROM AMD_LOCATION_PART_OVERRIDE alpo, AMD_SPARE_NETWORKS asn, amd_sent_to_a2a sent
			 WHERE alpo.loc_sid = asn.loc_sid
				   AND TRUNC(alpo.last_update_dt) BETWEEN TRUNC(from_dt) AND TRUNC(to_dt)
				   AND alpo.part_no = sent.part_no
				   and sent.SPO_PRIME_PART_NO is not null
				   and sent.part_no = sent.spo_prime_part_no 
			union
			select distinct rsp.part_no,
			rsp_location,
			OVERRIDE_TYPE as override_type,
			case 
				 when rsp.action_code = amd_defaults.getDELETE_ACTION or sent.action_code = amd_defaults.getDELETE_ACTION then
				 	  0
				 else
				 	 rsp_level
			end override_quantity,
			OVERRIDE_REASON as override_reason,
			Amd_Location_Part_Override_Pkg.GetFirstLogonIdForPart(Amd_Utils.GetNsiSidFromPartNo(rsp.part_no)),
			sysdate as begin_date,
			null as end_date,
			case sent.action_code
				 when amd_defaults.getDELETE_ACTION then
				 	  amd_defaults.getDELETE_ACTION -- The part is not longer valid
				 else
				 	 case rsp.action_code
						 when amd_defaults.getDELETE_ACTION then
						 	  amd_defaults.getUPDATE_ACTION -- the part is still valid, update the current value to zero
						 else
				 	 	 	 rsp.action_code
					end					
			end AS action_code,
			sysdate as last_update_dt
			from amd_rsp_sum rsp, amd_sent_to_a2a sent, amd_spare_networks nwks
			where trunc(rsp.last_update_dt) between trunc(from_dt) and trunc(to_dt) 
			and rsp.part_no = sent.part_no
			and sent.part_no = sent.spo_prime_part_no
			and sent.SPO_PRIME_PART_NO is not null						
			and substr(rsp_location,1,length(rsp_location) - 4) = nwks.mob
			and nwks.mob is not null ;
		end getDataByLastUpdateDt ;

		procedure getAllData is
		begin
		  	writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 730,
	 		pKey1 => 'getAllData' ) ;
			commit ;
			OPEN overrides FOR
		 	 SELECT sent.spo_prime_part_no,
			 		spo_location AS site_location,
					OVERRIDE_TYPE AS override_type,
					case
						when sent.action_code = amd_defaults.getDELETE_ACTION or alpo.action_code = amd_defaults.getDELETE_ACTION then
							 0
						else
							tsl_override_qty
					end AS override_quantity,
					OVERRIDE_REASON AS override_reason,
					tsl_override_user,
					SYSDATE AS begin_date,
					NULL AS end_date,
					case sent.action_code
						 when amd_defaults.getDELETE_ACTION then
						 	  amd_defaults.getDELETE_ACTION -- The part is not longer valid
						 else
						 	 case alpo.action_code
							 	  when amd_defaults.getDELETE_ACTION then
								  	   amd_defaults.getUPDATE_ACTION -- the part is still valid, update the current value to zero
								  else
								  	  alpo.action_code
							 end
					end AS action_code,
					SYSDATE AS last_update_dt
			 FROM AMD_LOCATION_PART_OVERRIDE alpo, AMD_SPARE_NETWORKS asn, amd_sent_to_a2a sent
			 WHERE alpo.loc_sid = asn.loc_sid
			 	   AND alpo.part_no = sent.part_no 
			 	   and sent.SPO_PRIME_PART_NO is not null
				   and sent.spo_prime_part_no = sent.part_no 
			union
			select distinct sent.spo_prime_part_no,
			rsp_location,
			OVERRIDE_TYPE as override_type,
			case 
				 when rsp.action_code = amd_defaults.getDELETE_ACTION or sent.action_code = amd_defaults.getDELETE_ACTION then
				 	  0
				 else
				 	 rsp_level
			end override_quantity,
			OVERRIDE_REASON as override_reason,
			Amd_Location_Part_Override_Pkg.GetFirstLogonIdForPart(Amd_Utils.GetNsiSidFromPartNo(rsp.part_no)),
			sysdate as begin_date,
			null as end_date,
			case sent.action_code
				 when amd_defaults.getDELETE_ACTION then
				 	  amd_defaults.getDELETE_ACTION -- The part is not longer valid
				 else
				 	 case rsp.action_code
						 when amd_defaults.getDELETE_ACTION then
						 	  amd_defaults.getUPDATE_ACTION -- the part is still valid, update the current value to zero
						 else
				 	 	 	 rsp.action_code
					end					
			end AS action_code,
			sysdate as last_update_dt
			from amd_rsp_sum rsp, 
			amd_sent_to_a2a sent,
			amd_spare_networks nwks
			where  rsp.part_no = sent.part_no
			and sent.spo_prime_part_no = sent.part_no 
			and sent.SPO_PRIME_PART_NO is not null
			and substr(rsp_location,1,length(rsp_location) - 4) = nwks.mob
			and nwks.mob is not null ;
		end getAllData ;

	BEGIN
		 writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 740,
		 		pKey1 => 'LoadAllA2A',
				pKey2 => 'useTestData=' || Amd_Utils.boolean2Varchar2(useTestData),
				pKey3 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
				pKey4 => 'to_dt='  || TO_CHAR(to_dt,'MM/DD/YYYY'),
				pData => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
		 Mta_Truncate_Table('tmp_a2a_loc_part_override','reuse storage');
		 a2a_pkg.setSendAllData(true) ;
		 IF useTestData THEN
			getTestData ;
		ELSE
			IF TRUNC(from_dt) <> TRUNC(A2a_Pkg.start_dt) OR TRUNC(to_dt) <> TRUNC(SYSDATE) THEN
				getDataByLastUpdateDt ;
			ELSE
			 	getAllData ; 
			END IF ;
		END IF ;

		processLocPartOverride(overrides) ;
		CLOSE overrides ;

		loadZeroTslA2A(doAllA2A => TRUE, from_dt => from_dt, to_dt => to_dt, useTestData => useTestData) ;
		
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 750,
		 		pKey1 => 'LoadAllA2A',
				pKey2 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
				pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
				pData => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
				
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(
		   pSqlfunction 	  	  => 'LoadAllA2A',
		   pTableName  	  	  => 'tmp_a2a_loc_part_override',
		   pError_location => 760,
  		   pKey1			  => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
		   pKey2			  => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
		   pKey3  		      => 'useTestData=' || Amd_Utils.boolean2Varchar2(useTestData)) ;
		RAISE ;
	END LoadAllA2A ;
	
	PROCEDURE LoadInitial IS
		 returnCode NUMBER ;
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 770,
		 		pKey1 => 'LoadInitial',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		 
		 LoadTmpAmdLocPartOverride ;
	 	 Mta_Truncate_Table('amd_location_part_override','reuse storage');
		 COMMIT ;
		 INSERT INTO AMD_LOCATION_PART_OVERRIDE
		 	SELECT * FROM TMP_AMD_LOCATION_PART_OVERRIDE ;
		 COMMIT ;
		 LoadAllA2A ;
		 dbms_output.put_line('LoadInitial ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(pSqlfunction => 'LoadInitial', pTableName => 'tmp_amd_location_part_override',
				   pError_location => 780 ) ;
		RAISE ;
	END LoadInitial ;
	
	PROCEDURE loadZeroTslA2APartsWithNoTsls(doAllA2A IN BOOLEAN := FALSE, useTestData IN BOOLEAN := FALSE) IS
			  tsl tslCur ;
			  
			  procedure getTestData is 
			  begin
		  		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 790,
	 			pKey1 => 'getTestData' ) ;
				commit ;
			   OPEN tsl FOR
				SELECT spo_prime_part_no,
				sent.action_code action_code, 
				transaction_date, 
				loc_id spo_location,
				items.nsn,
				nsi_sid,
				0 override_quantity 
				FROM AMD_SENT_TO_A2A sent, AMD_NATIONAL_STOCK_ITEMS items, 
					   ( 
					   SELECT loc_id FROM AMD_SPARE_NETWORKS n 
					   WHERE (n.LOC_TYPE IN ('FSL','MOB') AND n.SPO_LOCATION IS NOT NULL) 
					   OR loc_id IN (amd_location_part_leadtime_pkg.BASC_LOCATION, 
					   	  		     amd_location_part_leadtime_pkg.UK_LOCATION) 
					   ) spo_locations, amd_test_parts testParts 
				WHERE sent.part_no NOT IN (SELECT DISTINCT part_no FROM AMD_LOCATION_PART_OVERRIDE WHERE action_code <> 'D')
				AND not exists (
					 SELECT null 
					 FROM TMP_A2A_LOC_PART_OVERRIDE
					 WHERE part_no = spo_prime_part_no
					 AND site_location = spo_locations.loc_id) 
				AND sent.part_no = testParts.PART_NO
				and sent.part_no = sent.spo_prime_part_no
				AND spo_prime_part_no = items.prime_part_no 
				and items.LAST_UPDATE_DT >= (select max(last_update_dt)
					               from amd_national_stock_items where prime_part_no = spo_prime_part_no) ;				
			  end getTestData ;
			  
			  procedure getAllData is
			  begin
		  		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 800,
	 			pKey1 => 'getAllData' ) ;
				commit ;
			   	OPEN tsl FOR
				SELECT spo_prime_part_no,
				sent.action_code action_code, 
				transaction_date, 
				loc_id spo_location,
				nsn,
				nsi_sid,
				0 override_quantity 
				FROM AMD_SENT_TO_A2A sent, AMD_NATIONAL_STOCK_ITEMS items,  
					   ( 
					   SELECT loc_id FROM AMD_SPARE_NETWORKS n 
					   WHERE (n.LOC_TYPE IN ('FSL','MOB') AND n.SPO_LOCATION IS NOT NULL) 
					   OR loc_id IN (amd_location_part_leadtime_pkg.BASC_LOCATION, 
					   	  		     amd_location_part_leadtime_pkg.UK_LOCATION) 
					   ) spo_locations 
				WHERE part_no NOT IN (SELECT DISTINCT part_no FROM AMD_LOCATION_PART_OVERRIDE WHERE action_code <> 'D')
				AND not exists (
					 SELECT null 
					 FROM TMP_A2A_LOC_PART_OVERRIDE
					 WHERE part_no = spo_prime_part_no
					 AND site_location = spo_locations.loc_id) 
				and sent.part_no = sent.spo_prime_part_no
				AND spo_prime_part_no = items.prime_part_no 
				and items.LAST_UPDATE_DT >= (select max(last_update_dt)
					 from amd_national_stock_items where prime_part_no = spo_prime_part_no) ;				 
			  end getAllData ;
			  
			  procedure getDataByTranDtAndBatchTime is
			  begin
		  		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 810,
	 			pKey1 => 'getDataByTranDtAndBatchTime' ) ;
				commit ;
				
			 	OPEN tsl FOR
					SELECT spo_prime_part_no,
					sent.action_code action_code, 
					transaction_date, 
					loc_id spo_location,
					nsn,
					nsi_sid,
					0 override_quantity 
					FROM AMD_SENT_TO_A2A sent, AMD_NATIONAL_STOCK_ITEMS items,  
						   ( 
						   SELECT loc_id FROM AMD_SPARE_NETWORKS n 
						   WHERE (n.LOC_TYPE IN ('FSL','MOB') AND n.SPO_LOCATION IS NOT NULL) 
						   OR loc_id IN ('EY1746', 'EY8780') 
						   ) spo_locations 
					WHERE part_no NOT IN (SELECT DISTINCT part_no FROM AMD_LOCATION_PART_OVERRIDE WHERE action_code <> 'D') 
					AND not exists (
						 SELECT null 
						 FROM TMP_A2A_LOC_PART_OVERRIDE
						 WHERE part_no = spo_prime_part_no
						 AND site_location = spo_locations.loc_id) 
					AND spo_prime_part_no = items.prime_part_no
					and items.LAST_UPDATE_DT >= (select max(last_update_dt)
					 	from amd_national_stock_items where prime_part_no = spo_prime_part_no)
				    and sent.part_no = sent.spo_prime_part_no
					and sent.ACTION_CODE <> amd_defaults.getDELETE_ACTION 
					AND TRUNC(transaction_date) >= TRUNC(Amd_Batch_Pkg.getLastStartTime) ;
			  end getDataByTranDtAndBatchTime ;
			  
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 820,
		 		pKey1 => 'loadZeroTslA2APartsWithNoTsls',
				pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
				pKey3 => 'useTestData=' || Amd_Utils.boolean2Varchar2(useTestData),
				pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	    COMMIT ;
		IF doAllA2A THEN
		   IF useTestData THEN
		   	   getTestData ;
		   ELSE
		   	   getAllData ;
		   END IF ;
		ELSE
			IF useTestData THEN
			   getTestData ;
			ELSE
				getDataByTranDtAndBatchTime ;
			END IF ;
		END IF ;
		
			
		processTsl(tsl) ;
		CLOSE tsl ;
	
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 830,
		 		pKey1 => 'loadZeroTslA2APartsWithNoTsls',
				pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
				pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	    COMMIT ;
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(pSqlfunction => 'loadZeroTslA2APartsWithNoTsls',pTableName => 'tmp_amd_location_part_override',
				   pError_location => 840 ) ;
		RAISE ;
	END loadZeroTslA2APartsWithNoTsls ;
	
	PROCEDURE loadRspZeroTslA2A(doAllA2A IN BOOLEAN := FALSE, useTestData in boolean := false ) IS 
			  rspTsl tslCur ;
			  
			  procedure getTestData is
			  begin
		  		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 850,
	 			pKey1 => 'getTestData' ) ;
				commit ;
		       -- send all the test data and do NOT filter on the last_update_dt
		       OPEN rspTsl FOR
				 	SELECT DISTINCT spo_prime_part_no, 
						   Amd_Defaults.INSERT_ACTION action_code , 
						   SYSDATE, 
						   mob,
						   nsn,
						   nsi_sid,
						   0 override_quantity   
					FROM 
						 (
					 	 SELECT  distinct spo_prime_part_no , mob || '_RSP' mob, 0 quantity
						 from (SELECT  DISTINCT spo_prime_part_no
						 	   FROM AMD_SENT_TO_A2A 
							   where part_no = spo_prime_part_no 
							   and action_code <> amd_defaults.getDelete_ACTION) primes,
                         AMD_SPARE_NETWORKS net
						 where mob is not null
						 AND not exists (
								 SELECT null 
								 FROM TMP_A2A_LOC_PART_OVERRIDE
								 WHERE part_no = spo_prime_part_no
								 AND site_location = mob || '_RSP') 
					 )  tsl,
					 AMD_NATIONAL_STOCK_ITEMS items 
					 where spo_prime_part_no = items.prime_part_no
					 and items.LAST_UPDATE_DT >= (select max(last_update_dt)
						 from amd_national_stock_items where prime_part_no = spo_prime_part_no)				 
					 and spo_prime_part_no in (select part_no from amd_test_parts)
					 AND items.action_code <> amd_defaults.getDelete_ACTION
					 and items.LAST_UPDATE_DT >= (select max(last_update_dt)
						 from amd_national_stock_items where prime_part_no = spo_prime_part_no) ;
			  end getTestData ;

			  procedure getAllData is
			  begin
		  		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 860,
	 			pKey1 => 'getAllData' ) ;
				commit ;
		       OPEN rspTsl FOR
				 	SELECT DISTINCT spo_prime_part_no, 
						   tsl.action_code , 
						   SYSDATE, 
						   mob,
						   nsn,
						   nsi_sid,
						   0 override_quantity   
					FROM 
						 (
					 	 SELECT  distinct spo_prime_part_no , mob || '_RSP' mob, 0 quantity, primes.action_code
						 from (SELECT  DISTINCT spo_prime_part_no, action_code
						       FROM AMD_SENT_TO_A2A
							   where part_no = spo_prime_part_no) primes,
						      AMD_SPARE_NETWORKS net
						 where mob is not null
						 AND not exists (
								 SELECT null 
								 FROM TMP_A2A_LOC_PART_OVERRIDE
								 WHERE part_no = spo_prime_part_no
								 AND site_location = mob || '_RSP') 
					 )  tsl,
					 AMD_NATIONAL_STOCK_ITEMS items 
				     where spo_prime_part_no = items.prime_part_no
					 and items.LAST_UPDATE_DT >= (select max(last_update_dt)
					 	 from amd_national_stock_items where prime_part_no = spo_prime_part_no)					 
					 and items.LAST_UPDATE_DT >= (select max(last_update_dt)
					 	 					  from amd_national_stock_items where prime_part_no = spo_prime_part_no) ;					 
			  end getAllData ;

			  procedure getDataByLastUpdateDt is
			  begin
		  		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 870,
	 			pKey1 => 'getDataByLastUpdateDt' ) ;
				commit ;
		   	   -- send all data whose last_update_dt >= amd_batch_pkg.getLastStartTime - ie all the 
			   -- data that has been processed by the diff for the lastest batch job  
		       	OPEN rspTsl FOR
				 	SELECT DISTINCT spo_prime_part_no, 
						   tsl.action_code action_code , 
						   SYSDATE, 
						   mob,
						   items.nsn,
						   nsi_sid,
						   0 override_quantity   
					FROM 
						 (
						 	 SELECT  distinct spo_prime_part_no , mob || '_RSP' mob, 0 quantity, primes.last_update_dt last_update_dt, primes.action_code action_code
							 from (SELECT  DISTINCT spo_prime_part_no, transaction_date last_update_dt, action_code
							       FROM AMD_SENT_TO_A2A 
								   where part_no = spo_prime_part_no 
								   and action_code <> amd_defaults.getDELETE_ACTION) primes,
							 AMD_SPARE_NETWORKS net
							 where mob is not null
							 AND not exists (
									 SELECT null 
									 FROM TMP_A2A_LOC_PART_OVERRIDE
									 WHERE part_no = spo_prime_part_no
									 AND site_location = mob || '_RSP') 
					 	 )  tsl,
					 	 AMD_NATIONAL_STOCK_ITEMS items,
						 amd_spare_parts parts 
						 where spo_prime_part_no = items.prime_part_no
						 and items.LAST_UPDATE_DT >= (select max(last_update_dt)
					 	 	 					  from amd_national_stock_items where prime_part_no = spo_prime_part_no)
					 	 and spo_prime_part_no = parts.part_no
						 and items.action_code <> amd_defaults.getDELETE_ACTION
						 and parts.action_code <> amd_defaults.getDELETE_ACTION					
					 	 and (trunc(tsl.last_update_dt) >= trunc(amd_batch_pkg.getLastStartTime)
						 	 or trunc(items.last_update_dt) >= trunc(amd_batch_pkg.getLastStartTime)
							 or trunc(parts.last_update_dt) >= trunc(amd_batch_pkg.getLastStartTime)) ;
			  end getDataByLastUpdateDt ;
			  			  			  
	BEGIN
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 880,
		 		pKey1 => 'loadRspZeroTslA2A',
				pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
				pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
	   if useTestData then
	   	  getTestData ;
	   else
	   	   if doAllA2A then
		   	  getAllData ;
		   else
		   	   getDataByLastUpdateDt ;
			END IF ;
		end if ;
		
		processTsl(tsl => rspTsl) ;
		CLOSE rspTsl;
		
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(pSqlfunction => 'loadRspZeroTslA2A',pTableName => 'tmp_amd_location_part_override',
				   pError_location => 890 ) ;
		RAISE ;
	END loadRspZeroTslA2A;
	
	PROCEDURE deleteRspTslA2A is 
			  rspTsl tslCur ;
			  
			  procedure getPrimeChangedData is
			  begin
		  		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 892,
	 			pKey1 => 'getTestData' ) ;
				commit ;
		       -- send all the test data and do NOT filter on the last_update_dt
		       OPEN rspTsl FOR
				 	SELECT DISTINCT spo_prime_part_no, 
						   Amd_Defaults.getDELETE_ACTION action_code , 
						   SYSDATE, 
						   mob,
						   nsn,
						   nsi_sid,
						   0 override_quantity   
					FROM 
						 (
					 	 SELECT  distinct spo_prime_part_no , mob || '_RSP' mob, 0 quantity
						 from (SELECT  DISTINCT part_no spo_prime_part_no
						 	   FROM AMD_test_parts ) primes, 
						 AMD_SPARE_NETWORKS net
                         where mob is not null
                     )  tsl,
                     AMD_NATIONAL_STOCK_ITEMS items 
                     where spo_prime_part_no = items.prime_part_no
                     and items.LAST_UPDATE_DT >= (select max(last_update_dt)
                         from amd_national_stock_items where prime_part_no = spo_prime_part_no)                 
                     and spo_prime_part_no in (select part_no from amd_test_parts)
                     AND items.action_code <> amd_defaults.getDelete_ACTION
                     and items.LAST_UPDATE_DT >= (select max(last_update_dt)
                         from amd_national_stock_items where prime_part_no = spo_prime_part_no) ;
			  end getPrimeChangedData ;


			  			  			  
	BEGIN
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 896,
		 		pKey1 => 'deleteRspTslA2A',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
        getPrimeChangedData ;	   	
		processTsl(tsl => rspTsl) ;
		CLOSE rspTsl;
		
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(pSqlfunction => 'deleteRspTslA2A',pTableName => 'tmp_amd_location_part_override',
				   pError_location => 898 ) ;
		RAISE ;
	END deleteRspTslA2A;
				 		
	
	PROCEDURE loadZeroTslA2A4DelSpoPrimParts(doAllA2A IN BOOLEAN := FALSE, useTestData IN BOOLEAN := FALSE) IS
			  tsl tslCur ;
			  
			  procedure getTestData is
			  begin
		  		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 900,
	 			pKey1 => 'getTestData' ) ;
				commit ;
				 OPEN tsl FOR
				 	SELECT DISTINCT sent.spo_prime_part_no,
					 	sent.action_code action_code,
						sent.transaction_date, 
						net.SPO_LOCATION spo_location, 
						i.nsn,
						i.nsi_sid,
						0 override_AtlantaWarehouseQty
					FROM AMD_LOCATION_PART_OVERRIDE o, AMD_SPARE_NETWORKS net, AMD_SENT_TO_A2A sent, AMD_NATIONAL_STOCK_ITEMS i,
					amd_test_parts testParts 
					WHERE o.action_code = Amd_Defaults.DELETE_ACTION
					AND not exists (
							 SELECT null 
							 FROM TMP_A2A_LOC_PART_OVERRIDE
							 WHERE part_no = sent.spo_prime_part_no
							 AND site_location = net.spo_location) 
					AND sent.spo_prime_part_no = testParts.PART_NO
					and sent.spo_prime_part_no = sent.part_no 
					AND o.loc_sid = net.LOC_SID
					AND o.part_no = sent.spo_prime_part_no
					AND o.part_no = i.PRIME_PART_NO ;
			  end getTestData ;
			  
			  procedure getAllData is
			  begin
		  		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 910,
	 			pKey1 => 'getAllData' ) ;
				commit ;
				 OPEN tsl FOR
				 	SELECT DISTINCT sent.spo_prime_part_no,
						sent.action_code action_code,
						sent.transaction_date, 
						net.SPO_LOCATION spo_location, 
						i.nsn,
						i.nsi_sid,
						0 override_AtlantaWarehouseQty
					FROM AMD_LOCATION_PART_OVERRIDE o, AMD_SPARE_NETWORKS net, AMD_SENT_TO_A2A sent, AMD_NATIONAL_STOCK_ITEMS i 
					WHERE o.action_code = Amd_Defaults.DELETE_ACTION
					AND not exists (
							 SELECT null 
							 FROM TMP_A2A_LOC_PART_OVERRIDE
							 WHERE part_no = sent.spo_prime_part_no
							 AND site_location = net.spo_location) 
					AND o.loc_sid = net.LOC_SID
					AND o.part_no = sent.spo_prime_part_no
					AND o.part_no = i.PRIME_PART_NO 
					and sent.spo_prime_part_no = sent.part_no ; 
			  end getAllData ;

			  procedure getDataByTranDtAndBatchTime is
			  begin
		  		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 920,
	 			pKey1 => 'getDataByTranDtAndBatchTime' ) ;
				commit ;
				 OPEN tsl FOR
				 	SELECT DISTINCT sent.spo_prime_part_no, 
						sent.action_code action_code, 
						sent.transaction_date, 
						net.SPO_LOCATION spo_location, 
						i.nsn,
						i.nsi_sid,
						0 override_AtlantaWarehouseQty
					FROM AMD_LOCATION_PART_OVERRIDE o, AMD_SPARE_NETWORKS net, AMD_SENT_TO_A2A sent, AMD_NATIONAL_STOCK_ITEMS i 
					WHERE o.action_code = Amd_Defaults.DELETE_ACTION
					AND not exists (
							 SELECT null 
							 FROM TMP_A2A_LOC_PART_OVERRIDE
							 WHERE part_no = sent.spo_prime_part_no
							 AND site_location = net.spo_location) 
					AND o.loc_sid = net.LOC_SID
					AND o.part_no = sent.spo_prime_part_no
					AND o.part_no = i.PRIME_PART_NO
					and sent.spo_prime_part_no = sent.part_no 
					AND TRUNC(sent.TRANSACTION_DATE) >= TRUNC(Amd_Batch_Pkg.getLastStartTime) ;
			  end getDataByTranDtAndBatchTime ;
			  			  
	BEGIN
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 930,
		 		pKey1 => 'loadZeroTslA2A4DelSpoPrimParts',
				pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
				pKey3 => 'useTestData=' ||  Amd_Utils.boolean2Varchar2(useTestData),
				pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
				
		 
	 	IF useTestData THEN
		 	getTestData ;
		elsif doAllA2A THEN
		 	getAllData ;
		else
		   	getDataByTranDtAndBatchTime ;
		END IF ;
		
		processTsl(tsl) ;
		CLOSE tsl ;
	
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 940,
		 		pKey1 => 'loadZeroTslA2A4DelSpoPrimParts',
				pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
				pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	    COMMIT ;
	
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(pSqlfunction => 'loadZeroTslA2A4DelSpoPrimParts',pTableName => 'tmp_amd_location_part_override',
				   pError_location => 950 ) ;
		RAISE ;
	END loadZeroTslA2A4DelSpoPrimParts ;
	
	PROCEDURE loadTslA2AWarehouseParts(doAllA2A IN BOOLEAN := FALSE, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE) IS
			  tsl tslCur ;
			  
			  procedure getTestData is
			  begin
		  		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 960,
	 			pKey1 => 'getTestData' ) ;
				commit ;
		 	OPEN tsl FOR
				SELECT 
					spo_prime_part_no,
					spoPrimes.action_code,
					spoPrimes.transaction_date,
					spo_location,
					items.nsn,
					items.nsi_sid,
					override_quantity
				FROM (
					SELECT sent.spo_prime_part_no,
						THE_WAREHOUSE spo_location,
						SUM(NVL(i.SPO_TOTAL_INVENTORY,0)) override_quantity,
						sent.action_code action_code,
						SYSDATE transaction_date
					FROM AMD_SENT_TO_A2A sent, AMD_SPARE_PARTS p, AMD_NATIONAL_STOCK_ITEMS i
					WHERE
					sent.ACTION_CODE <> Amd_Defaults.DELETE_ACTION
					AND not exists (
							 SELECT null 
							 FROM TMP_A2A_LOC_PART_OVERRIDE
							 WHERE part_no = sent.spo_prime_part_no
							 AND site_location = THE_WAREHOUSE) 
					AND spo_prime_part_no IN (SELECT part_no FROM AMD_TEST_PARTS)
					AND p.ACTION_CODE <> Amd_Defaults.DELETE_ACTION
					AND sent.part_no = p.part_no
					and sent.spo_prime_part_no = sent.part_no 
					AND p.nsn = i.NSN
					GROUP BY sent.spo_prime_part_no
					) spoPrimes, 
					AMD_NATIONAL_STOCK_ITEMS items
				WHERE spo_prime_part_no = items.PRIME_PART_NO
				and items.LAST_UPDATE_DT >= (select max(last_update_dt)
					 from amd_national_stock_items where prime_part_no = spo_prime_part_no)	;
			  end getTestData ;
			  
			  procedure getAllValidSpoData is
			  begin
		  		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 970,
	 			pKey1 => 'getAllValidSpoData' ) ;
				commit ;
				OPEN tsl FOR
				SELECT 
					spo_prime_part_no,
					spoPrimes.action_code,
					spoPrimes.transaction_date,
					spo_location,
					items.nsn,
					items.nsi_sid,
					override_quantity
				FROM (
					SELECT sent.spo_prime_part_no,
						THE_WAREHOUSE spo_location,
						SUM(NVL(i.SPO_TOTAL_INVENTORY,0)) override_quantity,
						sent.action_code action_code,
						SYSDATE transaction_date
					FROM AMD_SENT_TO_A2A sent, AMD_SPARE_PARTS p, AMD_NATIONAL_STOCK_ITEMS i
					WHERE
					sent.ACTION_CODE <> Amd_Defaults.DELETE_ACTION -- spo data is valid if  sent.action_code <> delete_action
					AND not exists (
							 SELECT null 
							 FROM TMP_A2A_LOC_PART_OVERRIDE
							 WHERE part_no = sent.spo_prime_part_no
							 AND site_location = THE_WAREHOUSE) 
					AND p.ACTION_CODE <> Amd_Defaults.DELETE_ACTION
					AND sent.part_no = p.part_no
					and sent.spo_prime_part_no = sent.part_no 
					AND p.nsn = i.NSN
					GROUP BY sent.spo_prime_part_no
					) spoPrimes, 
					AMD_NATIONAL_STOCK_ITEMS items
				WHERE spo_prime_part_no = items.PRIME_PART_NO 
				and items.LAST_UPDATE_DT >= (select max(last_update_dt)
					 from amd_national_stock_items where prime_part_no = spo_prime_part_no)	;
			  end getAllValidSpoData ;
			  		  
	BEGIN
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 980,
		 		pKey1 => 'loadTslA2AWarehouseParts',
				pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
				pKey3 => 'useTestData=' || Amd_Utils.boolean2Varchar2(useTestData),
				pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
		IF useTestData THEN
		   getTestData ;
		 ELSE
		   getAllValidSpoData ;
		 END IF ;
		  
		 processTsl(tsl) ;
		 CLOSE tsl ;
	
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 990,
		 		pKey1 => 'loadTslA2AWarehouseParts',
				pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
				pKey3 =>  'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(pSqlfunction => 'loadTslA2AWarehouseParts',pTableName => 'tmp_amd_location_part_override',
				   pError_location => 1000 ) ;
		RAISE ;
	END loadTslA2AWarehouseParts ;
	
	FUNCTION isInTmpA2AYorN(part_no IN TMP_A2A_LOC_PART_OVERRIDE.part_no%TYPE, site_location IN TMP_A2A_LOC_PART_OVERRIDE.SITE_LOCATION%TYPE) RETURN VARCHAR2 IS
	BEGIN
		 IF isInTmpA2A(part_no, site_location) THEN
		 	RETURN 'Y' ;
		 ELSE
		 	RETURN 'N' ;
		 END IF ; 
	END isInTmpA2AYorN ;
	
	FUNCTION isInTmpA2A(part_no IN TMP_A2A_LOC_PART_OVERRIDE.part_no%TYPE, site_location IN TMP_A2A_LOC_PART_OVERRIDE.SITE_LOCATION%TYPE) RETURN BOOLEAN IS
			 thePartNo TMP_A2A_LOC_PART_OVERRIDE.part_no%TYPE ;
			 rc NUMBER ;
	BEGIN
		 SELECT part_no INTO thePartNo
		 FROM TMP_A2A_LOC_PART_OVERRIDE
		 WHERE part_no = isInTmpA2A.part_no
		 AND site_location = isInTmpA2A.site_location ;
		 RETURN TRUE ;
	EXCEPTION
			 WHEN standard.NO_DATA_FOUND THEN
			 	  RETURN FALSE ;
			 WHEN OTHERS THEN
					ErrorMsg(
					   pSqlfunction 	  	  => 'isInTmpA2A',
				   pTableName  	  	  => 'tmp_a2a_loc_part_override',
				   pError_location => 1010,
				   pKey1			  => part_no,
	   			   pKey2			  => site_location) ;
				   RAISE ;
	END isInTmpA2A ;
	-- added 11/7/05 dse
	FUNCTION getInsertCnt RETURN NUMBER IS 
	BEGIN
		 RETURN insertCnt ;
	END getInsertCnt ;
	
	FUNCTION getUpdateCnt RETURN NUMBER IS
	BEGIN
		 RETURN updateCnt ;
	END getUpdateCnt ;
	
	FUNCTION getDeleteCnt RETURN NUMBER IS
	BEGIN
		 RETURN deleteCnt ;
	END getDeleteCnt ;
	
	FUNCTION getOVERRIDE_TYPE RETURN VARCHAR2 IS
	BEGIN
		 RETURN OVERRIDE_TYPE ;
	END getOVERRIDE_TYPE ;
	
	FUNCTION getOVERRIDE_REASON RETURN VARCHAR2 IS
	BEGIN
		 RETURN OVERRIDE_REASON ;
	END getOVERRIDE_REASON ;
	
	FUNCTION getBULKLIMIT RETURN NUMBER IS
	BEGIN
		 RETURN BULKLIMIT ;
	END getBULKLIMIT ;
	
	FUNCTION getCOMMITAFTER RETURN NUMBER IS
	BEGIN
		 RETURN COMMITAFTER ;
	END getCOMMITAFTER ;
	
	FUNCTION getSUCCESS RETURN NUMBER IS
	BEGIN
		 RETURN SUCCESS ;
	END getSUCCESS ;
	
	FUNCTION getFAILURE RETURN NUMBER IS
	BEGIN
		 RETURN FAILURE ;
	END getFAILURE ;
	
	FUNCTION getTHE_WAREHOUSE RETURN VARCHAR2 IS
	BEGIN
		 RETURN THE_WAREHOUSE ;
	END getTHE_WAREHOUSE ;

	procedure version is
	begin
		 writeMsg(pTableName => 'amd_location_part_override_pkg', 
		 		pError_location => 1020, pKey1 => 'amd_location_part_override_pkg', pKey2 => '$Revision:   1.52  $') ;
		 dbms_output.put_line('amd_location_part_override_pkg: $Revision:   1.52  $') ;
	end version ;
	
	
	function isTmpA2AOkay return boolean is
			 result varchar2(1) ;
	begin
		select 'Y' into result
		from dual
		where exists (select null 
			  		  from tmp_a2a_loc_part_override
					  where action_code <> amd_defaults.getDELETE_ACTION
					  group by site_location
					  having count(part_no) <> (select count(*) 
					  		 				    from amd_sent_to_a2a 
												where part_no = spo_prime_part_no 
			   				  	 		 		and action_code <> amd_defaults.getDELETE_ACTION)
												) ;
		return false ;
	exception when standard.no_data_found then
		return true ;	
	end isTmpA2AOkay ;
	
	function isTmpA2AOkayYorN return varchar2 is
	begin
		 if isTmpA2AOkay then
		 	return 'Y' ;
		 end if ;
		 
		 return 'N' ;
		 
	end isTmpA2AOkayYorN ;
	
END Amd_Location_Part_Override_Pkg ;
/

show errors

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.AMD_LOAD AS

    /*
	    PVCS Keywords

       $Author:   c402417  $
     $Revision:   1.47  $
         $Date:   Jan 17 2007 16:22:14  $
     $Workfile:   amd_load.pkb  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_load.pkb-arc  $
   
      Rev 1.47   Jan 17 2007 16:22:14   c402417
   Added Procedure LoadRblPairs - This step is to populate the data to table AMD_RBL_PAIRS from the Gold database instead of using data from the FedLog.
   
      Rev 1.46   Nov 21 2006 10:16:08   zf297a
   Fixed insert of tmp_a2a_site_resp_asset_mgr
   
      Rev 1.45   Oct 31 2006 14:45:18   zf297a
   Implemented validatePartStructure
   
      Rev 1.44   Oct 13 2006 10:23:54   zf297a
   For the primeCat cursor changed the RTRIM's to TRIM (a part with a leading space got loaded into amd_spare_parts).  For catCur changed the RTRIM to TRIM.
   
      Rev 1.43   Oct 10 2006 11:11:12   zf297a
   For function getBemsId, errorMsg and writeMsg cannot be used when the function is being used in a query.   Therefore, the error handling routines have been adjusted to check for this error and use the raise_application_error as a last resort for report what may be wrong with the function.  Enhanced the algorithm to try getting the bems_id via the clock number (emp_id) and if that fails try using the employeeNo as the bems_id and verify it against the amd_people_all_v table.
   
      Rev 1.42   Oct 10 2006 09:56:38   zf297a
   Added more error checks for getBemsId.  
   
      Rev 1.41   Oct 03 2006 11:51:54   zf297a
   Make sure planner_code_cleaned and smr_code_cleaned are in upper case
   
      Rev 1.40   Sep 18 2006 10:16:24   zf297a
   Removed infoMsg.  Added writeMsg at the start and the end of loadGold, loadPsms, and loadMain.  Changed all execute immediates to use mta_truncate_table.  Changed errorMsg to have default values for all args and changed error_location to pError_Location.   Added dbms_output.put_line to version.  Fixed 2nd select of bssm data to use only the part and verify that it has an nsn_type of C for current.
   
      Rev 1.39   Sep 15 2006 14:49:44   zf297a
   Added data_source to insertSiteRespAssetMgr
   
      Rev 1.38   Jul 11 2006 11:23:34   zf297a
   Removed quotes from package name
   
      Rev 1.37   Jun 09 2006 11:44:56   zf297a
   implemented version
   
      Rev 1.36   Jun 04 2006 13:27:26   zf297a
   Fixed createSiteRespAssetMgrA2Atran to use a cursor.

      Rev 1.35   Mar 20 2006 08:57:00   zf297a
   Added  "Future use" comments

      Rev 1.34   Mar 19 2006 01:50:50   zf297a
   Used didStepComplete to conditionally execute a batch step only once for a given job.

      Rev 1.33   Mar 17 2006 09:06:00   zf297a
   Eliminated rudundant step ending code.

      Rev 1.32   Mar 16 2006 15:24:18   zf297a
   Add steps to PrepAmdDatabase

      Rev 1.31   Mar 16 2006 15:08:20   zf297a
   Added step info to preProcess and LoadGoldPsmsMain

      Rev 1.30   Mar 16 2006 10:37:40   zf297a
   Fixed retrieval of bssm data: try to retrieve the data using nsn and if the data is not found, use the part_no.  Write separate procedures for the routinese that gather rmads data and bssm data to enable easy unit testing.

      Rev 1.29   Mar 08 2006 12:01:04   zf297a
   Added mtbdr_computed

      Rev 1.28   Mar 05 2006 21:19:50   zf297a
   Implemented  loadGoldPsmsMain, preProcess, postProcess, postDiffProcess, prepAmdDatabase, disableAmdConstraints, truncateAmdTables, and enableAmdConstraints to simplify the amd_loader.ksh script.

      Rev 1.27   Dec 15 2005 12:12:52   zf297a
   Added truncate table for tmp_a2a_bom_detail and tmp_a2a_part_effectivity to loadGold

      Rev 1.26   Dec 07 2005 13:18:18   zf297a
   Fixed insertUsersRow by returning SUCCESS after a doUpdate is invoked without an error.

      Rev 1.25   Dec 07 2005 12:22:48   zf297a
   fixed insertUsersRow by adding a doUpdate routine for a user that has been

      Rev 1.24   Dec 06 2005 09:46:24   zf297a
   Fixed display of sysdate in errorMsg - changed to MM/DD/YYYY HH:MM:SS

      Rev 1.23   Nov 23 2005 07:39:02   zf297a
   Fixed routine getBssmData, the getOriginalData begin block, added an additional qualification for the subselect getting data from amd_nsns so that only one row of data is returned by this query: added "and nsn_type = 'C', which checks for the "current" nsn being used - there can only be one of these per nsi_sid.

      Rev 1.22   Aug 26 2005 14:50:26   zf297a
   updated getOffBaseTurnAroundTime to use an action taken of 'F' (modification/repair) and changed interface for amd_clean_data to use both nsn and part_no

      Rev 1.23   Aug 23 2005 12:16:08   zf297a
   Used new interface, which uses nsn and part_no, for the best spares cleaned data

      Rev 1.22   Aug 19 2005 12:45:24   zf297a
   Converted time_to_repair_off_base_cleand and order_lead_time_cleaned from months to calendar days.  Converted order_lead_time from business days to calendar days.

      Rev 1.21   Aug 16 2005 14:12:30   zf297a
   removed loadCurrentBackorder

      Rev 1.20   Aug 09 2005 09:52:26   zf297a
   Added the ability to dynamically use debugMsg via the amd_param_changes table having a param debugAmdLoad with a value of 1.

      Rev 1.19   Aug 05 2005 12:28:12   zf297a
   Fixed insertRow for amd_planners to handle changing of a logically deleted planner to an added planner.  Added return SUCCESS to insertUsersRow, updateUsersRow, and deleteUsersRow.

      Rev 1.18   Aug 04 2005 14:43:54   zf297a
   Implemented insertUsersRow, updateUsersRow, and deleteUsersRow for the amd_users diff java application.

      Rev 1.17   Jul 28 2005 08:42:08   zf297a
   Qualified cursors currentUsers, newUsers, and deleteUsers with action_codes not equal to amd_defaults.DELETE_ACTION.

      Rev 1.16   Jul 27 2005 14:56:38   zf297a
   Refined newUsers and deleteUsers cursors for loadUsers

      Rev 1.15   Jul 27 2005 11:48:32   zf297a
   Fixed getBemsId by transforming the employeeNo into a work field before it is used in a query.  Fixed loadUsers by refering to the besm_id via the rec variable for the insert statement and the invocation of the spo routines.

      Rev 1.14   Jul 26 2005 12:32:22   zf297a
   Enhanced the loadUsers procedure to use the getBemsId function.

      Rev 1.13   Jul 20 2005 07:47:00   zf297a
   using only bems_id for amd_users

      Rev 1.12   Jul 19 2005 14:22:48   zf297a
   added procedure loadUsers - populates the amd_users table and sends inserts, updates, and deletes via the a2a_pgk.spoUser procedure.

      Rev 1.11   Jun 10 2005 11:23:32   c970183
   using new version of insertSiteRespAssetMgr with the additional param of action_code

      Rev 1.10   Jun 09 2005 14:58:58   c970183
   Added insert, update, and delete routines for the amd_planners diff and the amd_planner_logons diff.

      Rev 1.9   May 17 2005 14:24:12   c970183
   Modified getCleaned block to use the amd_clean_data package functions.

      Rev 1.8   May 17 2005 10:18:24   c970183
   Update InsertErrorMessage to new interface

      Rev 1.7   May 16 2005 12:02:12   c970183
   Moved time_to_repair_off_base and cost_to_repair_off_base from amd_part_locs to be part of tmp_amd_spare_parts.

      Rev 1.5   Apr 27 2005 09:19:28   c970183
   added infoMsg, which is almost the same as ErrorMsg, but it does not do a Rollback or a commit.
		  **/
	--
	-- Local Declarations
	--
	THIS_PACKAGE 		   constant varchar2(8) := 'amd_load' ;
	THE_AMD_INVENTORY_PKG  constant varchar2(13) := 'amd_inventory' ;

	mDebug	 			     BOOLEAN := FALSE ;
	COMMIT_THRESHOLD CONSTANT NUMBER := 1000 ;

	--
	-- procedure/Function bodies
	--
	PROCEDURE performLogicalDelete(
							pPartNo VARCHAR2);

	PROCEDURE debugMsg(pMsg IN AMD_LOAD_DETAILS.DATA_LINE%TYPE) IS
	BEGIN
	  IF mDebug THEN
	        Amd_Utils.debugMsg(pMsg) ;
			commit ;
	  END IF ;
	END debugMsg ;


	PROCEDURE errorMsg(
					sqlFunction IN VARCHAR2 := 'errorMsg',
					tableName IN VARCHAR2 := 'noname',
					pError_location IN NUMBER := -100,
					key1 IN VARCHAR2 := '',
			 		key2 IN VARCHAR2 := '',
					key3 IN VARCHAR2 := '',
					key4 IN VARCHAR2 := '',
					key5 IN VARCHAR2 := '',
					keywordValuePairs IN VARCHAR2 := '')  IS
	BEGIN
		ROLLBACK;
		Amd_Utils.InsertErrorMsg (
				pLoad_no => Amd_Utils.GetLoadNo(
						pSourceName => sqlFunction,
						pTableName  => tableName),
				pData_line_no => pError_location,
				pData_line    => THIS_PACKAGE,
				pKey_1 => key1,
				pKey_2 => key2,
				pKey_3 => key3,
				pKey_4 => key4,
				pKey_5 => key5 || ' ' || TO_CHAR(SYSDATE,'MM/DD/YY HH:MM:SS') ||
						   ' ' || keywordValuePairs,
				pComments => 'sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')');
		COMMIT;
		RETURN ;
	END ErrorMsg;

	
	procedure writeMsg(
				pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
				pError_location IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
				pKey1 IN VARCHAR2 := '',
				pKey2 IN VARCHAR2 := '',
				pKey3 IN VARCHAR2 := '',
				pKey4 in varchar2 := '',
				pData IN VARCHAR2 := '',
				pComments IN VARCHAR2 := '')  IS
	BEGIN
		Amd_Utils.writeMsg (
				pSourceName => 'amd_load',	
				pTableName  => pTableName,
				pError_location => pError_location,
				pKey1 => pKey1,
				pKey2 => pKey2,
				pKey3 => pKey3,
				pKey4 => pKey4,
				pData    => pData,
				pComments => pComments);
	end writeMsg ;


	 FUNCTION getBemsId(employeeNo IN AMD_USE1.EMPLOYEE_NO%TYPE) RETURN AMD_USERS.BEMS_ID%TYPE IS
	 		   bems_id amd_people_all_v.BEMS_ID%TYPE ;

		   wk_employeeNo AMD_USE1.employee_no%TYPE := UPPER(trim(REPLACE(employeeNo,';',''))) ;

		   FUNCTION isNumber(txt IN VARCHAR2) RETURN BOOLEAN IS
		   			theNumber NUMBER ;
		   BEGIN
		        <<testForNumber>>
		   		BEGIN
					 theNumber := TO_NUMBER(txt) ;
				EXCEPTION WHEN VALUE_ERROR THEN
						  theNumber := NULL ;
				END testForNumber ;
				RETURN (theNumber IS NOT NULL) ;
		   END isNumber ;
		   
		   procedure getViaBemsId is		   
	   	   begin
		   	   IF isNumber(wk_employeeNo) AND LENGTH(wk_employeeNo) = 6 THEN
			   	  getBemsId.bems_id := '0' || wk_employeeNo ;
			   ELSE
			   	  getBemsId.bems_id := substr(wk_employeeNo,1,7) ;
			   END IF ;
			   	   begin
				  	   SELECT bems_id INTO getBemsId.bems_id
					   FROM amd_people_all_v
					   WHERE bems_id = getBemsId.bems_id ;
				   exception
				   			when standard.no_data_found then
								 getBemsId.bems_id := null ;
							when others then
								ErrorMsg(sqlFunction => 'select',
									tableName => 'amd_people_all_v',
									pError_location => 40,
									key1 => 'wk_employeeNo=' || wk_employeeNo ) ;
								RAISE ;
				   end ;
		   exception when others then
				ErrorMsg(sqlFunction => 'select',
					tableName => 'amd_people_all_v',
					pError_location => 50,
					key1 => 'wk_employeeNo=' || wk_employeeNo ) ;
				RAISE ;
		   end  getViaBemsId ;
		   
	 BEGIN
	   IF SUBSTR(wk_employeeNo,LENGTH(wk_employeeNo),1) NOT IN ('1','2','3','4','5','6','7','8','9','0') THEN
	   	  wk_employeeNo := SUBSTR(wk_employeeNo,1,LENGTH(wk_employeeNo) - 1) ; -- strip non-numeric suffix
	   END IF ;

	   IF SUBSTR(wk_employeeNo,1,1) = 'C' THEN
	   	  -- try getting bemsid via the emp_id
	      begin
		   	  SELECT bems_id INTO getBemsId.bems_id
			  FROM amd_people_all_v
			  WHERE UPPER(emp_id) = wk_employeeNo ;
		  exception 
		  			when standard.no_data_found then
						 getViaBemsId ;
					when others then
						ErrorMsg(sqlFunction => 'select',
							tableName => 'amd_people_all_v',
							pError_location => 20,
							key1 => 'wk_employeeNo=' || wk_employeeNo ) ;
						RAISE ;
		  end ;
	   ELSE
	       getViaBemsId ;		
	   END IF ;

	  RETURN getBemsId.bems_id ;

	 EXCEPTION
	    when standard.no_data_found then
			 return null ; 
		when others then
			 if sqlcode <> -14551 and sqlcode <>  -14552 then
			 	 -- cannot do a rollback inside a query
				 ErrorMsg(sqlFunction => 'getBemsId',
					tableName => 'amd_people_all_v',
					pError_location => 60,
					key1 => 'wk_employeeNo=' || wk_employeeNo ) ;
				raise ;
			 else
			 	 dbms_output.put_line('getBemsId: sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm) ;
				 raise_application_error(-20001,'getBemsId: sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm || ' wk_employeeNo=' || wk_employeeNo ) ;
			 end if ;
			 return null ;
	 END getBemsId ;

	


	/* function GetOffBaseRepairCost, logic same as previous load version */
	FUNCTION  GetOffBaseRepairCost(pPartNo CHAR) RETURN AMD_PART_LOCS.cost_to_repair%TYPE IS
		offBaseRepairCost   AMD_PART_LOCS.cost_to_repair%TYPE := NULL;
		--
		--    Use only PART   number because POI1 does not have Cage Code.
		--
	BEGIN
		SELECT
			SUM(NVL(ext_price,0))/COUNT(*)
		INTO offBaseRepairCost
		FROM POI1
		WHERE
			part = pPartNo
			AND SUBSTR(ccn,1,5) IN ( SELECT ccn_prefix FROM AMD_CCN_PREFIX )
			AND NVL(ext_price,0) > 0;
		RETURN(offBaseRepairCost);
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			 RETURN NULL;
	END GetOffBaseRepairCost;

	/* function get_off_base_tat, logic same as previous load version
	   removed offbasediag time from previous version */
	FUNCTION GetOffBaseTurnAround (pPartno CHAR) RETURN AMD_PART_LOCS.time_to_repair%TYPE IS
		-- goldpart      char(50);
		offBaseTurnAroundTime AMD_PART_LOCS.time_to_repair%TYPE;

	BEGIN
		SELECT
			AVG( completed_docdate  - created_docdate)
		INTO offBaseTurnAroundTime
		FROM ORD1
		WHERE
			part = pPartNo
			AND NVL(action_taken,'*') IN ('A', 'B', 'E', 'G', 'F', '*' )
			AND order_type = 'J'
			AND completed_docdate IS NOT NULL
		GROUP BY part;
		RETURN offBaseTurnAroundTime;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RETURN NULL;
	END GetOffBaseTurnAround;

	FUNCTION  getUnitCost(
							pPartNo VARCHAR2) RETURN NUMBER IS
		CURSOR costCur IS
			SELECT cap_price
			FROM PRC1
			WHERE
				part = pPartNo
			ORDER BY
				sc DESC;

		unitCost     NUMBER;
	BEGIN
		FOR rec IN costCur LOOP
			unitCost := rec.cap_price;
			EXIT;
		END LOOP;

		RETURN unitCost;
	END;


	FUNCTION getMmac(
			 		 				  pNsn  VARCHAR2) RETURN VARCHAR2 IS
			CURSOR macCur IS
				   SELECT nsn_smic
				   FROM NSN1
				   WHERE
				    	 nsn = pNsn;

		mMac			 VARCHAR2(2);
		BEGIN
			 FOR rec IN macCur LOOP
			 	 mMac :=rec.nsn_smic;
				 EXIT;
			END LOOP;

		RETURN mMac;
	END;


	PROCEDURE performLogicalDelete(
							pPartNo VARCHAR2) IS
		nsiSid    AMD_NSNS.nsi_sid%TYPE;
		nsnCnt    NUMBER;
	BEGIN

		UPDATE AMD_SPARE_PARTS SET
			nsn            = NULL,
			action_code    = Amd_Defaults.DELETE_ACTION,
			last_update_dt = SYSDATE
		WHERE part_no = pPartNo;

		BEGIN
			SELECT nsi_sid
			INTO nsiSid
			FROM AMD_NSI_PARTS
			WHERE part_no = pPartNo
				AND unassignment_date IS NULL;

			UPDATE AMD_NSI_PARTS SET
				unassignment_date = SYSDATE
			WHERE part_no = pPartNo
				AND nsi_sid = nsiSid;

			SELECT COUNT(*)
			INTO nsnCnt
			FROM AMD_NSI_PARTS
			WHERE nsi_sid = nsiSid
				AND unassignment_date IS NULL;

			IF (nsnCnt = 0) THEN
				UPDATE AMD_NATIONAL_STOCK_ITEMS SET
					action_code    = Amd_Defaults.DELETE_ACTION,
					last_update_dt = SYSDATE
				WHERE nsi_sid = nsiSid;
			END IF;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				NULL;
		END;

	END;


	FUNCTION onNsl(
							pPartNo VARCHAR2) RETURN BOOLEAN IS
		recCnt     NUMBER;
	BEGIN

		SELECT COUNT(*)
		INTO recCnt
		FROM AMD_NSNS an
		WHERE nsi_sid IN
				(SELECT nsi_sid
				FROM AMD_NSI_PARTS
				WHERE part_no = pPartNo
					AND unassignment_date IS NULL)
			AND nsn_type = 'C'
			AND nsn LIKE 'NSL%';

		IF (recCnt != 0) THEN
			RETURN TRUE;
		ELSE
			RETURN FALSE;
		END IF;
	END;


	FUNCTION  GetSmr(
							pPsmsInst VARCHAR2,
							pPart VARCHAR2,
							pCage VARCHAR2) RETURN VARCHAR2 IS

		/* -------------------------------------------------- */
		/* 1) if there is only one smr code found in PSMS,    */
		/*    use that smr Code.                              */
		/* 2) if more than one smr code found:                */
		/*    2.1) Use the most occurrences in HG table which */
		/*         have length of six characters.             */
		/*    2.2) if there is equal   number of occurrences of */
		/*         smr with length of six characters, select  */
		/*         one smr(anyone).                           */
		/*    2.3) if no smr code with length of six char.    */
		/*         found, use the most occurrences in hg.     */
		/* -------------------------------------------------- */

		CURSOR sel_psmsprod_smr IS
			SELECT
				hg.smrcodhg,
				COUNT(*),
				MAX(NVL(LENGTH(hg.smrcodhg),0))
			FROM
				amd_psms_ldmhg hg,
				amd_psms_ldmha ha
			WHERE
				hg.ipn          = ha.ipn
				AND ha.refnumha = pPart
				AND ha.cagecdxh = pCage
				AND HG.smrcodhg IS NOT NULL
			GROUP BY
				hg.smrcodhg
			ORDER BY
				MAX(NVL(LENGTH(hg.smrcodhg),0)) DESC,
				COUNT(*) DESC;

		CURSOR sel_psmsvend_smr IS
			SELECT
				hg.smrcodhg,
				COUNT(*),
				MAX(NVL(LENGTH(hg.smrcodhg),0))
			FROM
				amd_psmv_ldmhg hg,
				amd_psmv_ldmha ha
			WHERE
				hg.ipn          = ha.ipn
				AND ha.refnumha = pPart
				AND ha.cagecdxh = pCage
				AND hg.smrcodhg IS NOT NULL
			GROUP BY
				HG.smrcodhg
			ORDER BY
				MAX(NVL(LENGTH(HG.smrcodhg),0)) DESC,
				COUNT(*) DESC;

		smr   VARCHAR2(6);
		cnt   NUMBER;
		len   NUMBER;
	BEGIN

		IF pPsmsInst = 'PSMSPROD' THEN
			OPEN sel_psmsprod_smr;
			FETCH sel_psmsprod_smr INTO smr, cnt, len;
			CLOSE sel_psmsprod_smr;
		ELSE
			OPEN sel_psmsvend_smr;
			FETCH sel_psmsvend_smr INTO smr, cnt, len;
			CLOSE sel_psmsvend_smr;
		END IF;

		RETURN smr;

	END GetSmr;




	/* ------------------------------------------------------------------- */
	/*  This procedure returns PSMS Instance to be used: */
	/*                                                                     */
	/*  - PSMSVend Instance keeps Generic Engine Parts.(Pratt and Whitneys)*/
	/*             Per Dan Manigavlt.  if we find parts in PSMSVend,      */
	/*             data is more up to date than in PSMSPROD instance      */
	/*  - PSMSPROD Instance keeps other Quick Engine Change Kit Parts      */
	/*                                                                     */
	/* ------------------------------------------------------------------- */
	FUNCTION GetPsmsInstance (
							pPart VARCHAR2,
							pCage VARCHAR2) RETURN VARCHAR2 IS

		cnt        NUMBER;
		psmsInst   VARCHAR2(8);
	BEGIN

		SELECT COUNT(*)
		INTO cnt
		FROM
			amd_psmv_ldmha ha,
			TMP_AMD_SPARE_PARTS s
		WHERE
			ha.cagecdxh     = s.mfgr
			AND ha.refnumha = s.part_no
			AND ha.cagecdxh = pCage
			AND ha.refnumha = pPart;

		IF cnt > 0 THEN
			psmsInst := 'PSMSVEND';
		ELSE

			SELECT COUNT(*)
			INTO cnt
			FROM
				amd_psms_ldmha ha,
				TMP_AMD_SPARE_PARTS s
			WHERE
				ha.cagecdxh     = s.mfgr
				AND ha.refnumha = s.part_no
				AND ha.cagecdxh = pCage
				AND ha.refnumha = pPart;

			IF cnt > 0 THEN
				psmsInst := 'PSMSPROD';
			ELSE
				psmsInst := NULL;
			END IF;

		END IF;

		RETURN psmsInst;

	END GetPsmsInstance;


	PROCEDURE GetPsmsData (
							pPartNo VARCHAR2,
							pCage VARCHAR2,
							pPsmsInst VARCHAR2,
							pSlifeDay OUT NUMBER,
							pUnitVol  OUT NUMBER,
							pSmrCode  OUT VARCHAR2) IS

		/* ------------------------------------------------------------------- */
		/*  This procedure returns PSMS data for the Part and Cage Code from   */
		/*  the specified PSMS instance. Any integer indicates Shelf Life in Days          */
		/* ------------------------------------------------------------------- */

		sLife   VARCHAR2(2);
	BEGIN

		IF (pPsmsInst = 'PSMSVEND') THEN

			SELECT
				shlifeha,
				(ulengtha * uwidthha * uheighha) / 1728
			INTO sLife, pUnitVol
			FROM
				amd_psmv_ldmha ha,
				TMP_AMD_SPARE_PARTS s
			WHERE
				ha.cagecdxh     = s.mfgr
				AND ha.refnumha = s.part_no
				AND ha.cagecdxh = pCage
				AND ha.refnumha = pPartNo;

			IF (sLife IS NOT NULL) THEN
				SELECT storage_days
				INTO pSlifeDay
				FROM AMD_SHELF_LIFE_CODES
				WHERE sl_code = sLife;
			END IF;

		ELSIF (pPsmsInst = 'PSMSPROD') THEN

			SELECT
				shlifeha,
				(ulengtha * uwidthha * uheighha) / 1728
			INTO sLife, pUnitVol
			FROM
				amd_psms_ldmha ha,
				TMP_AMD_SPARE_PARTS s
			WHERE
				ha.cagecdxh     = s.mfgr
				AND ha.refnumha = s.part_no
				AND ha.cagecdxh = pCage
				AND ha.refnumha = pPartNo;

			IF (slife IS NOT NULL) THEN
				SELECT storage_days
				INTO pSlifeDay
				FROM AMD_SHELF_LIFE_CODES
				WHERE sl_code = sLife;
			END IF;

		END IF;

		pSmrCode := GetSmr(pPsmsInst, pPartNo, pCage);

	END GetPsmsData;


	FUNCTION  IsValidSmr(
							pSmrCode VARCHAR2) RETURN BOOLEAN IS
	BEGIN

		IF (SUBSTR(pSmrCode,6,1) IN ('T','P','N')) THEN
			RETURN TRUE;
		ELSE
			RETURN FALSE;
		END IF;

	END IsValidSmr;


	FUNCTION GetPrime(
							pNsn CHAR) RETURN VARCHAR2 IS
		--
		-- Cursor selects primes w/matching part on same or other rec UNION with
		-- ONE record to use as default if no records satisfy above portion
		--
		CURSOR primeCur IS
			SELECT DISTINCT
				1 qNo,
				DECODE(part,prime,'1 - Prime','2 - Equivalent') partType,
				TRIM(part) part,
				TRIM(prime) prime,
				TRIM(manuf_cage) manuf_cage
			FROM CAT1 c1
			WHERE c1.nsn = pNsn
				AND EXISTS
				(SELECT 'x'
				FROM CAT1 c2
				WHERE c2.nsn = c1.nsn
					AND c2.part = c1.prime)
			UNION
			SELECT DISTINCT
				2 qNo,
				DECODE(part,prime,'1 - Prime','2 - Equivalent') partType,
				TRIM(part) part,
				TRIM(prime) prime,
				TRIM(manuf_cage) manuf_cage
			FROM CAT1
			WHERE nsn = pNsn
				AND ROWNUM =1
			ORDER BY
				qNo,
				partType,
				prime,
				part;


		goodPrime   VARCHAR2(50);
		firstPass   BOOLEAN:=TRUE;
		primePrefix  VARCHAR2(3);
		char1       VARCHAR2(1);
		char2       VARCHAR2(1);
		char3       VARCHAR2(1);
		priority    NUMBER:=0;
	BEGIN

		FOR rec IN primeCur LOOP
			--
			-- Set part of first rec as good prime in case good prime never shows.
			-- Funky logic used in Best Spares to determine good prime compares
			-- first 3 characters to determine good prime.
			--
			IF (firstPass) THEN
				goodPrime := rec.part;
				firstPass := FALSE;
			END IF;

			primePrefix := SUBSTR(rec.prime,1,3);
			char1       := SUBSTR(rec.prime,1,1);
			char2       := SUBSTR(rec.prime,2,1);
			char3       := SUBSTR(rec.prime,3,1);

			IF (rec.qNo = 1) THEN
				IF (rec.part = rec.prime AND rec.manuf_cage = '88277') THEN
					goodPrime := rec.prime;
					priority := 6;
				END IF;

				IF (priority < 6 AND rec.part = rec.prime) THEN
					goodPrime := rec.prime;
					priority := 5;
				END IF;

				IF (priority < 5 AND primePrefix = '17B') THEN
					goodPrime := rec.prime;
					priority  := 4;
				END IF;

				IF (priority < 4 AND primePrefix = '17P') THEN
					goodPrime := rec.prime;
					priority  := 3;
				END IF;

				IF (priority < 3 AND ((char1 != '1' OR char2 != '7' OR
							(char3 NOT IN ('P','B')))
							AND (char1> '9' OR char1< '1' OR char2 != 'D'))) THEN
					goodPrime := rec.prime;
				END IF;
			END IF;

		END LOOP;

		RETURN goodPrime;

	END GetPrime;


	FUNCTION  GetItemType(
							pSmrCode VARCHAR2) RETURN VARCHAR2 IS
		itemType   VARCHAR2(1);
		char1      VARCHAR2(1);
		char6      VARCHAR2(1);
	BEGIN

		char1 := SUBSTR(pSmrCode,1,1);
		char6 := SUBSTR(pSmrCode,6,1);

		-- Consumable when smr is P____N
		-- Repairable when smr is P____P
		--              or smr is P____T
		--
		IF (char1 = 'P') THEN

			IF (char6 = 'N') THEN
				itemType := 'C';
			ELSIF (char6 IN ('P','T'))  THEN
				itemType := 'R';
			END IF;

		END IF;

		RETURN itemType;

	END GetItemType;


	FUNCTION getMic(
							pNsn VARCHAR2) RETURN VARCHAR2 IS
		l67Mic   VARCHAR2(1);
	BEGIN
		SELECT MIN(mic)
		INTO l67Mic
		FROM AMD_L67_SOURCE
		WHERE
			nsn = pNsn
			AND mic != '*';

		RETURN l67Mic;
	END;


	 procedure getOriginalBssmData(nsn in amd_nsns.nsn%type,
		 part_no in bssm_owner.bssm_parts.PART_NO%type,
		 condemn_avg out amd_national_stock_items.condemn_avg%type,
		 criticality out amd_national_stock_items.criticality%type,
		 mtbdr_computed out amd_national_stock_items.mtbdr_computed%type,
		 nrts_avg out amd_national_stock_items.nrts_avg%type,
		 rts_avg out amd_national_stock_items.rts_avg%type) IS

		 CURRENT_NSN constant varchar2(1) := 'C' ;
		 ORIGINAL_DATA constant varchar2(1) := '0' ;

	begin
	 		SELECT condemn, criticality, mtbdr_computed, nrts, rts
	INTO condemn_avg, criticality, mtbdr_computed, nrts_avg, rts_avg
	FROM bssm_owner.bssm_parts bp, AMD_NSNS nsns
	WHERE
	nsns.nsn = getOriginalBssmData.nsn
	AND bp.nsn IN (SELECT nsn FROM AMD_NSNS WHERE nsi_sid = nsns.nsi_sid AND nsn_type = CURRENT_NSN)
	AND lock_sid = ORIGINAL_DATA ;
	EXCEPTION
		  WHEN standard.NO_DATA_FOUND THEN
		    <<getByPart>>
		    begin
				SELECT condemn, criticality, mtbdr_computed,  nrts, rts
				INTO condemn_avg, criticality, mtbdr_computed,  nrts_avg, rts_avg
				FROM bssm_owner.bssm_parts bp, amd_spare_parts parts, amd_nsns nsns
				WHERE
				bp.PART_NO = getOriginalBssmData.part_no
				and bp.part_no = parts.part_no
				and parts.nsn = nsns.nsn
				and nsn_type = CURRENT_NSN
				AND lock_sid = ORIGINAL_DATA ;
			exception
				  when standard.no_data_found then
				  	   condemn_avg := NULL ;
					   criticality := NULL ;
				       mtbdr_computed := null ;
					   nrts_avg := NULL ;
					   rts_avg := NULL ;
				  WHEN OTHERS THEN
						ErrorMsg(sqlFunction => 'select',
							tableName => 'bssm_parts',
							pError_location => 70,
							key1 => getOriginalBssmData.part_no,
							key2 => 'locksid=' || ORIGINAL_DATA);
						RAISE ;
			end getByPart ;

		  WHEN OTHERS THEN
				ErrorMsg(sqlFunction => 'select',
					tableName => 'bssm_parts and amd_nsns',
					pError_location => 80,
					key1 => getOriginalBssmData.part_no,
					key2 => 'locksid=' || ORIGINAL_DATA);
				RAISE ;
	end getOriginalBssmData ;

	procedure getCleanedBssmData(nsn in amd_nsns.nsn%type,
		part_no 				in bssm_owner.bssm_parts.part_no%type,
		condemn_avg_cleaned 	out amd_national_stock_items.condemn_avg_cleaned%type,
		criticality_cleaned 	out amd_national_stock_items.criticality_cleaned%type,
		mtbdr_cleaned 			out amd_national_stock_items.mtbdr_cleaned%type,
		nrts_avg_cleaned 		out amd_national_stock_items.nrts_avg_cleaned%type,
		rts_avg_cleaned 		out amd_national_stock_items.rts_avg_cleaned%type,
		order_lead_time_cleaned out amd_national_stock_items.order_lead_time_cleaned%type,
		planner_code_cleaned 	out amd_national_stock_items.planner_code_cleaned%type,
		smr_code_cleaned 		out amd_national_stock_items.smr_code_cleaned%type,
		unit_cost_cleaned 		out amd_national_stock_items.unit_cost_cleaned%type,
		cost_to_repair_off_base_cleand out amd_national_stock_items.cost_to_repair_off_base_cleand%type,
		time_to_repair_off_base_cleand out amd_national_stock_items.time_to_repair_off_base_cleand%type) is

	begin
		condemn_avg_cleaned := Amd_Clean_Data.GetCondemnAvg(nsn, part_no) ;
		criticality_cleaned := Amd_Clean_Data.GetCriticality(nsn, part_no ) ;
		mtbdr_cleaned := Amd_Clean_Data.GetMtbdr(nsn, part_no) ;
		nrts_avg_cleaned := Amd_Clean_Data.GetNrtsAvg(nsn, part_no) ;
		rts_avg_cleaned := Amd_Clean_Data.GetRtsAvg(nsn, part_no) ;
		order_lead_time_cleaned := Amd_Utils.months2CalendarDays(Amd_Clean_Data.GetOrderLeadTime(nsn, part_no)) ;
		planner_code_cleaned := upper(Amd_Clean_Data.GetPlannerCode(nsn, part_no)) ;
		smr_code_cleaned := upper(Amd_Clean_Data.GetSmrCode(nsn, part_no)) ;
		unit_cost_cleaned := Amd_Clean_Data.GetUnitCost(nsn, part_no) ;
		cost_to_repair_off_base_cleand := Amd_Clean_Data.GetCostToRepairOffBase(nsn, part_no) ;
		time_to_repair_off_base_cleand := Amd_Utils.months2CalendarDays(Amd_Clean_Data.GetTimeToRepairOffBase(nsn, part_no)) ;
	end getCleanedBssmData ;

	PROCEDURE getBssmData(nsn in amd_nsns.nsn%type,
		part_no 		 in bssm_owner.bssm_parts.part_no%type,

		condemn_avg 	 out amd_national_stock_items.condemn_avg%type,
		criticality 	 out amd_national_stock_items.criticality%type,
		mtbdr_computed  out amd_national_stock_items.mtbdr_computed%type,
		nrts_avg 		 out amd_national_stock_items.nrts_avg%type,
		rts_avg 		 out amd_national_stock_items.rts_avg%type,

		condemn_avg_cleaned   out AMD_NATIONAL_STOCK_ITEMS.condemn_avg_cleaned%TYPE,
		criticality_cleaned   out AMD_NATIONAL_STOCK_ITEMS.criticality_cleaned%TYPE,
		mtbdr_cleaned         out AMD_NATIONAL_STOCK_ITEMS.mtbdr_cleaned%TYPE,
		nrts_avg_cleaned      out AMD_NATIONAL_STOCK_ITEMS.nrts_avg_cleaned%TYPE,
		rts_avg_cleaned       out AMD_NATIONAL_STOCK_ITEMS.rts_avg_cleaned%TYPE,
		order_lead_time_cleaned out AMD_NATIONAL_STOCK_ITEMS.order_lead_time_cleaned%TYPE,
		planner_code_cleaned  	 out AMD_NATIONAL_STOCK_ITEMS.planner_code_cleaned%TYPE,
		smr_code_cleaned      	 out AMD_NATIONAL_STOCK_ITEMS.smr_code_cleaned%TYPE,
		unit_cost_cleaned     	 out AMD_NATIONAL_STOCK_ITEMS.unit_cost_cleaned%TYPE,
		cost_to_repair_off_base_cleand  out AMD_NATIONAL_STOCK_ITEMS.cost_to_repair_off_base_cleand%TYPE,
		time_to_repair_off_base_cleand  out AMD_NATIONAL_STOCK_ITEMS.time_to_repair_off_base_cleand%TYPE) is

	BEGIN
		getOriginalBssmData(nsn => nsn, part_no => part_no, condemn_avg => condemn_avg,
		criticality => criticality, mtbdr_computed => mtbdr_computed, nrts_avg => nrts_avg, rts_avg => rts_avg) ;

		getCleanedBssmData( nsn => nsn, part_no => part_no,
		condemn_avg_cleaned => condemn_avg_cleaned,
		criticality_cleaned => criticality_cleaned, mtbdr_cleaned => mtbdr_cleaned,
		nrts_avg_cleaned => nrts_avg_cleaned, rts_avg_cleaned => rts_avg_cleaned,
		order_lead_time_cleaned => order_lead_time_cleaned,
		planner_code_cleaned => planner_code_cleaned, smr_code_cleaned => smr_code_cleaned,
		unit_cost_cleaned => unit_cost_cleaned,
		cost_to_repair_off_base_cleand => cost_to_repair_off_base_cleand,
		time_to_repair_off_base_cleand => time_to_repair_off_base_cleand) ;

	END getBssmData ;

	PROCEDURE getRmadsData (part_no in amd_rmads_source_tmp.part_no%type, qpei_weighted out amd_rmads_source_tmp.QPEI_WEIGHTED%type,
		mtbdr out amd_rmads_source_tmp.MTBDR%type) is
	BEGIN
		SELECT qpei_weighted, mtbdr INTO qpei_weighted, mtbdr
		FROM AMD_RMADS_SOURCE_TMP
		WHERE part_no = getRmadsData.part_no ;
	EXCEPTION
		WHEN standard.NO_DATA_FOUND THEN
			qpei_weighted := NULL ;
			mtbdr := null ;
		WHEN OTHERS THEN
			ErrorMsg(sqlFunction => 'select',
			tableName => 'amd_rmads_source_tmp',
			pError_location => 90,
			key1 => getRmadsData.part_no) ;
			RAISE ;
	END getRmadsData ;

	PROCEDURE LoadGold IS
		CURSOR catCur IS
			SELECT
				TRIM(nsn) nsn,
				DECODE(prime,part,'PRIME','EQUIVALENT') partType,
				TRIM(part) part,
				TRIM(prime) prime,
				TRIM(manuf_cage) manuf_cage,
				TRIM(source_code) source_code,
				TRIM(noun) noun,
				TRIM(serial_mandatory_b) serial_mandatory_b,
				TRIM(ims_designator_code) ims_designator_code,
				TRIM(smrc) smrc,
				TRIM(um_cap_code) um_cap_code,
				TRIM(user_ref7) user_ref7,
				TRIM(um_show_code) um_show_code
			FROM CAT1
			WHERE
				source_code = 'F77'
				AND nsn NOT LIKE 'N%'
			UNION
			SELECT
				TRIM(nsn) nsn,
				DECODE(prime,part,'PRIME','EQUIVALENT') partType,
				TRIM(part) part,
				TRIM(prime) prime,
				TRIM(manuf_cage) manuf_cage,
				TRIM(source_code) source_code,
				TRIM(noun) noun,
				TRIM(serial_mandatory_b) serial_mandatory_b,
				TRIM(ims_designator_code) ims_designator_code,
				TRIM(smrc) smrc,
				TRIM(um_cap_code) um_cap_code,
				TRIM(user_ref7) user_ref7,
				TRIM(um_show_code) um_show_code
			FROM CAT1
			WHERE
				source_code = 'F77'
				AND nsn LIKE 'NSL%'
				AND part = prime
			ORDER BY
				nsn,
				partType DESC,
				part;

		loadNo        NUMBER;
		nsn           VARCHAR2(50);
		prevNsn       VARCHAR2(50):='prevNsn';
		nsnStripped   VARCHAR2(50);
		goodPrime     VARCHAR2(50);
		primeInd      VARCHAR2(1);
		itemType      VARCHAR2(1);
		smrCode       VARCHAR2(6);
		orderUom	  VARCHAR2(2);
		plannerCode   VARCHAR2(8);
		nsnType       VARCHAR2(1);
		hasPrimeRec   BOOLEAN;
		sequenced     BOOLEAN;
		l67Mic        VARCHAR2(1);
		unitCost      NUMBER;
		unitOfIssue	  VARCHAR2(2);
		mMac		  VARCHAR2(2);
		rowsInserted NUMBER := 0 ;
	BEGIN
	    writeMsg(pTableName => 'tmp_amd_spare_parts', pError_location => 100,
				pKey1 => 'loadGold',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		Mta_Truncate_Table('tmp_amd_spare_parts','reuse storage');
		Mta_Truncate_Table('tmp_a2a_part_info','reuse storage');
		Mta_Truncate_Table('tmp_a2a_part_lead_time','reuse storage');
		Mta_Truncate_Table('tmp_a2a_part_pricing','reuse storage');
		Mta_Truncate_Table('tmp_a2a_bom_detail','reuse storage');
		Mta_Truncate_Table('tmp_a2a_part_effectivity','reuse storage');

		loadNo := Amd_Utils.GetLoadNo('GOLD','TMP_AMD_SPARE_PARTS');

		FOR rec IN catCur LOOP

			IF (rec.nsn LIKE 'NSL%') THEN
				sequenced := TRUE;
				nsn := Amd_Nsl_Sequence_Pkg.SequenceTheNsl(rec.prime);
			ELSE
				sequenced := FALSE;
				nsn := rec.nsn;
			END IF;

			IF (nsn != prevNsn) THEN
				prevNsn     := nsn;
				nsnStripped := Amd_Utils.FormatNsn(nsn);

				-- If sequenceTheNsl() returned an NSL$ then it is assumed to be
				-- the prime, otherwise, run it through the getPrime() logic.
				--
				IF (nsn LIKE 'NSL%') THEN
					IF (NOT onNsl(rec.part)) THEN
						-- An NSL starts the part/nsn process so 'delete' the part
						-- so the diff will think it's a brand new part and
						-- assign it its own nsi_sid.
						--
						performLogicalDelete(rec.part);
					END IF;
					goodPrime := rec.part;
				ELSE
					goodPrime := GetPrime(nsn);
				END IF;

				nsnType     := 'C';
				plannerCode := rec.ims_designator_code;
				itemType    := NULL;
				smrCode     := rec.smrc;
				unitOfIssue := rec.um_show_code;
				orderUom := rec.um_cap_code;

				IF (IsValidSmr(smrCode)) THEN
					itemType := GetItemType(smrCode);
				END IF;

			END IF;

			-- if GetPrime() returned a null that means that the nsn no longer
			-- exists in Gold. This happens when a part goes from an NCZ to an NSL
			--
			IF (goodPrime IS NULL OR rec.part = goodPrime) THEN
				primeInd := 'Y';
			ELSE
				primeInd := 'N';
			END IF;

			l67Mic   := getMic(nsnStripped);
			unitCost := getUnitCost(rec.part);
			mMac := getMmac(rec.nsn);
			-- 4/13/05 DSE created insertTmpAmdSpareParts block of code
			<<insertTmpAmdSpareParts>>
			DECLARE
				   mtbdr                           AMD_NATIONAL_STOCK_ITEMS.mtbdr%TYPE ;
  				   mtbdr_cleaned                   AMD_NATIONAL_STOCK_ITEMS.mtbdr_cleaned%TYPE ;
  				   qpei_weighted                   AMD_NATIONAL_STOCK_ITEMS.qpei_weighted%TYPE ;
  				   condemn_avg					   AMD_NATIONAL_STOCK_ITEMS.condemn_avg%TYPE ;
  				   condemn_avg_cleaned             AMD_NATIONAL_STOCK_ITEMS.condemn_avg_cleaned%TYPE ;
  				   criticality                     AMD_NATIONAL_STOCK_ITEMS.criticality%TYPE ;
  				   criticality_cleaned             AMD_NATIONAL_STOCK_ITEMS.criticality_cleaned%TYPE ;
  				   nrts_avg                        AMD_NATIONAL_STOCK_ITEMS.nrts_avg%TYPE ;
  				   nrts_avg_cleaned                AMD_NATIONAL_STOCK_ITEMS.nrts_avg_cleaned%TYPE ;
  				   cost_to_repair_off_base_cleand  AMD_NATIONAL_STOCK_ITEMS.cost_to_repair_off_base_cleand%TYPE ;
  				   time_to_repair_off_base_cleand  AMD_NATIONAL_STOCK_ITEMS.time_to_repair_off_base_cleand%TYPE ;
  				   order_lead_time_cleaned         AMD_NATIONAL_STOCK_ITEMS.order_lead_time_cleaned%TYPE ;
  				   planner_code_cleaned            AMD_NATIONAL_STOCK_ITEMS.planner_code_cleaned%TYPE ;
  				   rts_avg                         AMD_NATIONAL_STOCK_ITEMS.rts_avg%TYPE ;
  				   rts_avg_cleaned                 AMD_NATIONAL_STOCK_ITEMS.rts_avg_cleaned%TYPE ;
  				   smr_code_cleaned                AMD_NATIONAL_STOCK_ITEMS.smr_code_cleaned%TYPE ;
  				   unit_cost_cleaned               AMD_NATIONAL_STOCK_ITEMS.unit_cost_cleaned%TYPE ;
				   cost_to_repair_off_base 		   AMD_NATIONAL_STOCK_ITEMS.cost_to_repair_off_base%TYPE ;
				   time_to_repair_off_base         AMD_NATIONAL_STOCK_ITEMS.time_to_repair_off_base%TYPE ;
				   mtbdr_computed				   amd_national_stock_items.mtbdr_computed%type ;






			BEGIN

				 getBssmData(nsn => nsnStripped, part_no => rec.part,
				 	condemn_avg => condemn_avg, criticality => criticality,  mtbdr_computed => mtbdr_computed,
					nrts_avg => nrts_avg, rts_avg => rts_avg,

			  		condemn_avg_cleaned => condemn_avg_cleaned, criticality_cleaned => criticality_cleaned,
					mtbdr_cleaned => mtbdr_cleaned, nrts_avg_cleaned => nrts_avg_cleaned,
					rts_avg_cleaned => rts_avg_cleaned, order_lead_time_cleaned => order_lead_time_cleaned,
					planner_code_cleaned => planner_code_cleaned, smr_code_cleaned => smr_code_cleaned,
					unit_cost_cleaned => unit_cost_cleaned,
					cost_to_repair_off_base_cleand => cost_to_repair_off_base_cleand,
					time_to_repair_off_base_cleand => time_to_repair_off_base_cleand) ;

				 getRmadsData(part_no => rec.part, qpei_weighted => qpei_weighted, mtbdr=> mtbdr) ;

				 IF primeInd = 'Y' THEN
				 	cost_to_repair_off_base := GetOffBaseRepairCost(rec.part);
					time_to_repair_off_base := GetOffBaseTurnAround(rec.part);
				 END IF ;

				INSERT INTO TMP_AMD_SPARE_PARTS (	part_no,	mfgr,
					icp_ind,	item_type,
					nomenclature, nsn,
					nsn_type,
					planner_code,
					order_uom,
					prime_ind,
					serial_flag,
					smr_code,
					acquisition_advice_code,
					unit_cost,
					mic,
					mmac,
					unit_of_issue,
				   mtbdr,
				   mtbdr_computed,
  				   mtbdr_cleaned,
  				   qpei_weighted,
  				   condemn_avg,
  				   condemn_avg_cleaned,
  				   criticality,
  				   criticality_cleaned,
  				   nrts_avg_cleaned,
  				   nrts_avg,
  				   cost_to_repair_off_base_cleand,
  				   time_to_repair_off_base_cleand,
  				   order_lead_time_cleaned,
  				   planner_code_cleaned,
  				   rts_avg,
  				   rts_avg_cleaned,
  				   smr_code_cleaned,
  				   unit_cost_cleaned,
				   cost_to_repair_off_base,
				   time_to_repair_off_base
				)
				VALUES
				(	rec.part, rec.manuf_cage,
					rec.source_code,
					itemType,
					rec.noun,			nsnStripped,
					nsnType,			plannerCode,
					rec.um_cap_code,
					primeInd, 	rec.serial_mandatory_b,
					smrCode, 	rec.user_ref7,
					unitCost,
					l67Mic,
					mMac,
					unitOfIssue,
				   mtbdr,
				   mtbdr_computed,
  				   mtbdr_cleaned,
  				   qpei_weighted,
  				   condemn_avg,
  				   condemn_avg_cleaned,
  				   criticality,
  				   criticality_cleaned,
  				   nrts_avg_cleaned,
  				   nrts_avg,
  				   cost_to_repair_off_base_cleand,
  				   time_to_repair_off_base_cleand,
  				   order_lead_time_cleaned,
  				   planner_code_cleaned,
  				   rts_avg,
  				   rts_avg_cleaned,
  				   smr_code_cleaned,
  				   unit_cost_cleaned,
				   cost_to_repair_off_base,
				   time_to_repair_off_base 		) ;

			EXCEPTION
				 WHEN OTHERS THEN
							ErrorMsg(sqlFunction => 'insert',
								tableName => 'tmp_amd_spare_parts',
								pError_location => 110,
								key1 => nsnStripped,
								key2 => rec.part,
								key3 => rec.manuf_cage,
								key4 => nsnType) ;
						RAISE ;

			END insertTmpAmdSpareParts ;

			rowsInserted := rowsInserted + 1 ;
			IF MOD(rowsInserted,COMMIT_THRESHOLD) = 0 THEN
			   COMMIT ;
			   dbms_output.put_line('committed last ' || COMMIT_THRESHOLD || ' inserts.') ;
			END IF ;
		END LOOP;
	    writeMsg(pTableName => 'tmp_amd_spare_parts', pError_location => 120,
				pKey1 => 'loadGold',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'rowsInserted=' || to_char(rowsInserted)) ;

		COMMIT ;

	EXCEPTION
		 WHEN OTHERS THEN
					ErrorMsg(sqlFunction => 'loadGold',
						tableName => 'tmp_amd_spare_parts',
						pError_location => 130) ;
					dbms_output.put_line('loadGold had an error - check amd_load_details. rowsInserted=' || rowsInserted) ;
				RAISE ;
	END LoadGold;
	
	
	PROCEDURE LoadRblPairs IS
	BEGIN
		 EXECUTE IMMEDIATE 'truncate table AMD_RBL_PAIRS' ;
		 
	--Populate data into table AMD_RBL_PAIRS
	<<insertRblPairs>>
	BEGIN
		 INSERT INTO AMD_RBL_PAIRS
		 (
		   		old_nsn,
		   		new_nsn, 
				subgroup_code, 
				part_pref_code, 
				last_update_dt, 
				action_code
		 )
		 SELECT 
		 		replace(stock_number,'-',''), 
				replace(isg_master_stock_number,'-',''), 
	   			substr(isg_oou_code,1,2), 
				substr(isg_oou_code,3,1), 
				sysdate , 
				'A'
		FROM 
			 cgvt, 
			 amd_national_stock_items ansi, 
			 amd_nsns an
		WHERE 
			  (replace(isg_master_stock_number,'-','') = an.nsn )
			  AND an.nsn = ansi.nsn
			  AND ansi.action_code != 'D'
			  AND isg_master_stock_number  IN 
			  	  (SELECT isg_master_stock_number 
				   FROM cgvt  
				   WHERE isg_master_stock_number IN 
				   		 (SELECT isg_master_stock_number 
						  FROM cgvt 
						  WHERE isg_master_stock_number = stock_number) 
					GROUP BY isg_master_stock_number HAVING count(*) > 1)
		ORDER BY 
			  replace(isg_master_stock_number,'-','');
		COMMIT;
		END insertRblPairs ;
	END LoadRblPairs ;



	PROCEDURE LoadPsms IS
		CURSOR F77 IS
			SELECT
				part_no,
				mfgr,
				smr_code,
				item_type
			FROM TMP_AMD_SPARE_PARTS;

		loadNo        NUMBER;
		psmsInstance  VARCHAR2(10);
		SLIFEDAY      NUMBER;
		UNITVOL       NUMBER;
		smrCode       VARCHAR2(6);
		itemType      VARCHAR2(1);
		cnt			  number := 0 ;
	BEGIN

	    writeMsg(pTableName => 'tmp_amd_spare_parts', pError_location => 140,
				pKey1 => 'loadPsms',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		--
		--     Get the load_no for insert into amd_load_status table
		--
		loadNo := Amd_Utils.GetLoadNo('PSMS','TMP_AMD_SPARE_PARTS');

		--
		-- select ICP Part/CAGE and check to see if the part is existing in PSMS.
		--
		FOR rec IN F77 LOOP

			psmsInstance := GetPsmsInstance(rec.part_no,rec.mfgr);

			IF (psmsInstance IS NOT NULL) THEN

				GetPsmsData(rec.part_no,rec.mfgr,psmsInstance,
									sLifeDay,unitVol,smrCode);

				IF (IsValidSmr(smrCode)) THEN
					itemType := GetItemType(smrCode);
				ELSE
					smrCode  := rec.smr_code;
					itemType := rec.item_type;
				END IF;

				UPDATE TMP_AMD_SPARE_PARTS SET
					shelf_life     = sLifeDay,
					unit_volume    = unitVol,
					smr_code	= smrCode,
					item_type      = itemType
				WHERE
					part_no  = rec.part_no
					AND smr_code IS NULL;
					
				 cnt := cnt + 1 ;

			END IF;

		END LOOP;
		
	    writeMsg(pTableName => 'tmp_amd_spare_parts', pError_location => 150,
				pKey1 => 'loadPsms',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'rowsUpdated=' || to_char(cnt) ) ;
				
		commit ;

	END LoadPsms;



	PROCEDURE LoadMain IS
		CURSOR f77Cur IS
			SELECT
				nsn,
				part_no,
				prime_ind,
				SUBSTR(smr_code,6,1) smrCode6
			FROM TMP_AMD_SPARE_PARTS
			ORDER BY
				nsn,
				prime_ind DESC;


		loadNo         NUMBER;
		cnt            NUMBER := 0;
		maxPoDate      DATE;
		maxPo          VARCHAR2(20);
		leadTime       NUMBER;
		orderUom       VARCHAR2(2);
		orderQuantity  NUMBER;
		orderQty       NUMBER;
		poAge          NUMBER;
		prevNsn        VARCHAR2(15):='prevNsn';
		
		
	BEGIN

	    writeMsg(pTableName => 'tmp_amd_spare_parts', pError_location => 160,
				pKey1 => 'loadMain',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		--
		--     Get the load_no for insert into amd_load_status table
		--
		loadNo := Amd_Utils.GetLoadNo('MAIN','TMP_AMD_SPARE_PARTS');

		FOR aspRec IN f77Cur LOOP

			--
			-- Attempt to get some values from tmp_main.(Only look at po's that
			-- have a length of 9.)
			--
			BEGIN
				--
				-- select the latest PO date.
				--
				SELECT
					MAX(TO_DATE(po_date,'RRMMDD')) po_date,
					(TRUNC(SYSDATE) - MAX(TO_DATE(po_date,'RRMMDD'))) po_age
				INTO
					maxPoDate,
					poAge
				FROM TMP_MAIN
				WHERE
					part_no = aspRec.part_no
					AND LENGTH(SUBSTR(po_no,1,INSTR(po_no,' ')-1)) = 9;

				--
				-- get latest PO
				--
				SELECT
					MAX(po_no)
				INTO maxPo
				FROM TMP_MAIN
				WHERE
					part_no     = aspRec.part_no
					AND po_date = TO_CHAR(maxPoDate,'RRMMDD')
					AND LENGTH(SUBSTR(po_no,1,INSTR(po_no,' ')-1)) = 9;

				SELECT
					total_lead_time,
					order_qty
				INTO
					leadTime,
					orderQuantity
				FROM TMP_MAIN
				WHERE
					part_no     = aspRec.part_no
					AND po_date = TO_CHAR(maxPoDate,'RRMMDD')
					AND po_no   = maxPo
					AND LENGTH(SUBSTR(po_no,1,INSTR(po_no,' ')-1)) = 9;



					-- We apply the order_quantity we got from the prime part
				-- to all the equivalent parts so we only set it here when the
				-- prime rec comes in.  The prime rec is the first rec in the
				-- nsn series due to the sort order of the cursor.
				--
				IF (aspRec.nsn != prevNsn) THEN
					prevNsn := aspRec.nsn;
					orderQty := orderQuantity;
				END IF;

			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					orderQuantity := NULL;
					leadTime      := NULL;
	--				orderUom      := NULL;
			END;

			UPDATE TMP_AMD_SPARE_PARTS SET
				order_lead_time = Amd_Utils.bizDays2CalendarDays(leadTime),
	--			order_uom = orderUom,
				order_quantity  = orderQty
			WHERE
				part_no       = aspRec.part_no;
			
			cnt := cnt + 1 ;

		END LOOP;

	    writeMsg(pTableName => 'tmp_amd_spare_parts', pError_location => 170,
		pKey1 => 'loadMain',
		pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
		pKey3 => 'rowsUpdated=' || to_char(cnt) ) ;
		
		commit ;

	END LoadMain;



	PROCEDURE LoadTempNsns IS
		RAW_DATA  NUMBER:=0;

		CURSOR tempNsnCur IS
			-- From MILS table
			SELECT DISTINCT
				asp.part_no part,
				RTRIM(SUBSTR(m.status_line,8,15)) nsnTemp,
				'MILS' dataSource
			FROM
				AMD_SPARE_PARTS asp,
				MILS m
			WHERE
				m.default_name  = 'A0E'
				AND asp.part_no = RTRIM(SUBSTR(m.status_line,81,30))
				AND asp.nsn    != RTRIM(SUBSTR(m.status_line,8,15))
				AND 'NSL'      != RTRIM(SUBSTR(m.status_line,8,15))
			UNION
			-- From CHGH table, "FROM" column
			SELECT DISTINCT
				asp.part_no part,
				RTRIM(REPLACE(m."FROM",'-',NULL)) nsnTemp,
				'CHGH' dataSource
			FROM
				AMD_SPARE_PARTS asp,
				CHGH m
			WHERE
				m.field         = 'NSN'
				AND asp.part_no = m.key_value1
				AND asp.nsn    != RTRIM(REPLACE(m."FROM",'-',NULL))
				AND 'NSL'      != RTRIM(REPLACE(m."FROM",'-',NULL))
			UNION
			-- From CHGH table, "TO" column
			SELECT DISTINCT
				asp.part_no part,
				RTRIM(REPLACE(m."TO",'-',NULL)) nsnTemp,
				'CHGH' dataSource
			FROM
				AMD_SPARE_PARTS asp,
				CHGH m
			WHERE
				m.field         = 'NSN'
				AND asp.part_no = m.key_value1
				AND asp.nsn    != RTRIM(REPLACE(m."TO",'-',NULL))
				AND 'NSL'      != RTRIM(REPLACE(m."TO",'-',NULL))
			UNION
			-- From BSSM_PARTS table
			SELECT DISTINCT
				bp.part_no,
				bp.nsn nsnTemp,
				'BSSM' dataSource
			FROM
				bssm_parts bp,
				(SELECT nsn
				FROM bssm_parts
				WHERE nsn LIKE 'NSL#%'
					AND lock_sid = RAW_DATA
				MINUS
				SELECT nsn
				FROM AMD_NSNS
				WHERE nsn LIKE 'NSL#%') nslQ
			WHERE
				bp.nsn = nslQ.nsn
				AND bp.lock_sid = RAW_DATA
				AND bp.part_no IS NOT NULL
			ORDER BY 1;

		nsn       VARCHAR2(16);
		nsiSid    NUMBER;
		loadNo    NUMBER;
		mmacCode  NUMBER;
	BEGIN
		loadNo := Amd_Utils.GetLoadNo('MILS','AMD_NSNS');

		FOR rec IN tempNsnCur LOOP
			BEGIN

				IF (rec.nsnTemp = 'NSL') THEN
					nsn := Amd_Nsl_Sequence_Pkg.SequenceTheNsl(rec.part);
				ELSIF (rec.nsnTemp LIKE 'NSL#%') THEN
					nsn := rec.nsnTemp;
				ELSE
					-- Need to ignore last 2 char's of nsn from MILS if not numeric.
					-- So if last 2 characters are not numeric an exception will
					-- occur and the nsn will be truncated to 13 characters.
					--
					nsn := rec.nsnTemp;
					IF (rec.dataSource = 'MILS') THEN
						BEGIN
							mmacCode := SUBSTR(nsn,14,2);
						EXCEPTION
							WHEN OTHERS THEN
								nsn := SUBSTR(nsn,1,13);
						END;
					END IF;
				END IF;

				nsiSid := Amd_Utils.GetNsiSid(pPart_no=>rec.part);

				INSERT INTO AMD_NSNS
				(
					nsn,
					nsn_type,
					nsi_sid,
					creation_date
				)
				VALUES
				(
					nsn,
					'T',
					nsiSid,
					SYSDATE
				);

			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;     -- nsiSid not found generates this, just ignore
				WHEN DUP_VAL_ON_INDEX THEN
					NULL;     -- we don't care if nsn is already there
				WHEN OTHERS THEN
					Amd_Utils.InsertErrorMsg(pLoad_no => loadNo,pKey_1 => 'amd_load.LoadTempNsns',
							pKey_2 => 'Exception: OTHERS',pKey_3 => 'insert into amd_nsns');
			END;

		END LOOP;

	END loadTempNsns ;


	FUNCTION insertRow(planner_code IN VARCHAR2) RETURN NUMBER IS
			 PROCEDURE doUpdate IS
			 BEGIN
			 	  UPDATE AMD_PLANNERS
				  SET planner_description = insertRow.planner_code,
				  action_code = Amd_Defaults.INSERT_ACTION,
				  last_update_dt = SYSDATE
				  WHERE planner_code = insertRow.planner_code ;
			 EXCEPTION WHEN OTHERS THEN
			    errorMsg(sqlFunction => 'update', tableName => 'amd_planners', pError_location => 180,
			   		key1 => insertRow.planner_code) ;
			   RAISE ;
			 END doUpdate ;
	BEGIN
		 <<insertAmdPlanners>>
		 BEGIN
			 INSERT INTO AMD_PLANNERS
			 (planner_code, planner_description, action_code, last_update_dt)
			 VALUES (insertRow.planner_code, insertRow.planner_code, Amd_Defaults.INSERT_ACTION, SYSDATE) ;
		 EXCEPTION
		  WHEN standard.DUP_VAL_ON_INDEX THEN
		  	   doUpdate ;
		  WHEN OTHERS THEN
		    errorMsg(sqlFunction => 'insert', tableName => 'amd_planners', pError_location => 190,
		   		key1 => insertRow.planner_code) ;
		   RAISE ;

	 	 END insertAmdPlanners ;

		 RETURN SUCCESS ;

	EXCEPTION WHEN OTHERS THEN
		 RETURN FAILURE ;
	END insertRow ;

	FUNCTION updateRow(planner_code IN VARCHAR2) RETURN NUMBER IS
	BEGIN
		 <<updateAmdPlanners>>
		 BEGIN
			 UPDATE AMD_PLANNERS
			 SET
			 planner_description = updateRow.planner_code,
			 last_update_dt = SYSDATE,
			 action_code = Amd_Defaults.UPDATE_ACTION
			 WHERE planner_code = updateRow.planner_code ;
		 EXCEPTION WHEN OTHERS THEN
		   errorMsg(sqlFunction => 'update', tableName => 'amd_planners', pError_location => 200,
		   		key1 => updateRow.planner_code) ;
		   RAISE ;

	 	 END updateAmdPlanners ;

		 RETURN SUCCESS ;

	EXCEPTION WHEN OTHERS THEN
		RETURN FAILURE ;
	END updateRow ;

	FUNCTION deleteRow(planner_code IN VARCHAR2) RETURN NUMBER IS
	BEGIN
		 <<deleteAmdPlanners>>
		 BEGIN
			 UPDATE AMD_PLANNERS
			 SET last_update_dt = SYSDATE,
			 action_code = Amd_Defaults.DELETE_ACTION
			 WHERE planner_code = deleteRow.planner_code ;
		 EXCEPTION WHEN OTHERS THEN
		   errorMsg(sqlFunction => 'update', tableName => 'amd_planners', pError_location => 210,
		   		key1 => deleteRow.planner_code) ;
		   RAISE ;

	 	 END deleteAmdPlanners ;

		 RETURN SUCCESS ;

	EXCEPTION WHEN OTHERS THEN
		RETURN FAILURE ;
	END deleteRow ;

	FUNCTION getNewUsers RETURN resultSetCursor IS
			 newUsers resultSetCursor ;
	BEGIN
		 OPEN newUsers FOR
		 SELECT
		 Amd_Load.getBemsId(employee_NO) bems_id,
		 stable_email,
		 last_name,
		 first_name
		 FROM AMD_USE1, amd_people_all_v
		 WHERE employee_status = 'A'
		 AND ims_designator_code IS NOT NULL
		 AND LENGTH(ims_designator_code) = 3
		 AND Amd_Load.getBemsId(employee_no) = amd_people_all_v.bems_id
		 ORDER BY bems_id ;
		 RETURN newUsers ;
	END getNewUsers ;

	FUNCTION insertUsersRow(bems_id IN VARCHAR2, stable_email IN VARCHAR2, last_name IN VARCHAR2, first_name IN VARCHAR2) RETURN NUMBER IS

			 procedure doUpdate is
			 begin
			 	  update amd_users
				  set stable_email = insertUsersRow.stable_email,
				  last_name = insertUsersRow.last_name,
				  first_name = insertUsersRow.first_name,
				  action_code = amd_defaults.INSERT_ACTION,
				  last_update_dt = sysdate
				  where bems_id = insertUsersRow.bems_id ;
			 exception when others then
			   errorMsg(sqlFunction => 'update', tableName => 'amd_users', pError_location => 220,
			   		key1 => bems_id) ;
			   RAISE ;
			 end doUpdate ;
	BEGIN
		 INSERT INTO AMD_USERS
		 (bems_id, stable_email, last_name, first_name, action_code, last_update_dt)
		 VALUES (bems_id, stable_email, last_name, first_name,  Amd_Defaults.INSERT_ACTION, SYSDATE) ;
 		 A2a_Pkg.insertTmpA2ASpoUsers(bems_id, stable_email, last_name, first_name, Amd_Defaults.INSERT_ACTION) ;
		 RETURN SUCCESS ;
	EXCEPTION
		when standard.dup_val_on_index then
			 doUpdate ;
			 return success ;
		WHEN OTHERS THEN
		   errorMsg(sqlFunction => 'insert', tableName => 'amd_users', pError_location => 230,
		   		key1 => bems_id) ;
		   RAISE ;
	END insertUsersRow ;

	FUNCTION updateUsersRow(bems_id IN VARCHAR2, stable_email IN VARCHAR2, last_name IN VARCHAR2, first_name IN VARCHAR2) RETURN NUMBER IS
	BEGIN
		 UPDATE AMD_USERS
		 SET stable_email = updateUsersRow.stable_email,
		 last_name = updateUsersRow.last_name,
		 first_name = updateUsersRow.first_name,
		 action_code = Amd_Defaults.UPDATE_ACTION,
		 last_update_dt = SYSDATE
		 WHERE bems_id = updateUsersRow.bems_id ;
 		 A2a_Pkg.insertTmpA2ASpoUsers(bems_id, stable_email, last_name, first_name, Amd_Defaults.UPDATE_ACTION) ;
		 RETURN SUCCESS ;
	EXCEPTION WHEN OTHERS THEN
		   errorMsg(sqlFunction => 'update', tableName => 'amd_users', pError_location => 240,
		   		key1 => bems_id) ;
		   RAISE ;
	END updateUsersRow ;

	FUNCTION deleteUsersRow(bems_id IN VARCHAR2) RETURN NUMBER IS
			 last_name AMD_USERS.last_name%TYPE ;
			 first_name AMD_USERS.first_name%TYPE ;
			 stable_email AMD_USERS.stable_email%TYPE ;
	BEGIN
		 UPDATE AMD_USERS
		 SET action_code = Amd_Defaults.DELETE_ACTION,
		 last_update_dt = SYSDATE
		 WHERE bems_id = deleteUsersRow.bems_id ;

		 <<getData>>
		 BEGIN
			 SELECT stable_email, last_name, first_name INTO stable_email, last_name, first_name
			 FROM AMD_USERS
			 WHERE bems_id = deleteUsersRow.bems_id ;
		 EXCEPTION WHEN OTHERS THEN
		   errorMsg(sqlFunction => 'select', tableName => 'amd_users', pError_location => 250,
		   		key1 => bems_id) ;
		   RAISE ;
		 END getData ;

 		 A2a_Pkg.insertTmpA2ASpoUsers(bems_id, stable_email, last_name, first_name, Amd_Defaults.DELETE_ACTION) ;
		 RETURN SUCCESS ;
	EXCEPTION WHEN OTHERS THEN
		   errorMsg(sqlFunction => 'update', tableName => 'amd_users', pError_location => 260,
		   		key1 => bems_id) ;
		   RAISE ;
	END deleteUsersRow ;

	PROCEDURE loadUsers IS
			  CURSOR currentUsers IS
			  SELECT bems_id FROM AMD_USERS
			  WHERE action_code != Amd_Defaults.DELETE_ACTION ;

			  CURSOR newUsers IS
				SELECT Amd_Load.getBemsId(employee_NO) bems_id
				FROM AMD_USE1
				WHERE employee_status = 'A'
				AND  Amd_Load.getBemsId(employee_no) NOT IN (
					 SELECT bems_id
					 FROM AMD_USERS
					 WHERE action_code != Amd_Defaults.DELETE_ACTION)
				AND ims_designator_code IS NOT NULL
				AND LENGTH(ims_designator_code) = 3 ;

			  CURSOR deletedUsers IS
			  SELECT bems_id
			  FROM AMD_USERS
			  WHERE bems_id NOT IN (
			  		SELECT Amd_Load.getBemsId(employee_no) bems_id
					FROM AMD_USE1
					WHERE employee_status = 'A'
					AND ims_designator_code IS NOT NULL
					AND LENGTH(ims_designator_code) = 3)
			 AND action_code != Amd_Defaults.DELETE_ACTION ;

			  bems_id AMD_USERS.BEMS_ID%TYPE ;

			  inserted NUMBER := 0 ;
			  deleted NUMBER := 0 ;


	BEGIN
	    writeMsg(pTableName => 'amd_users', pError_location => 270,
				pKey1 => 'loadUsers',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
				
		Mta_Truncate_Table('tmp_a2a_spo_users','reuse storage');

		 FOR rec IN newUsers LOOP
		 	 IF rec.bems_id IS NOT NULL THEN
			   <<insertAmdUsers>>
			   BEGIN
			 	 INSERT INTO AMD_USERS
				 (bems_id, action_code, last_update_dt)
				 VALUES (rec.bems_id,  Amd_Defaults.INSERT_ACTION, SYSDATE) ;
				 inserted := inserted + 1 ;
			     A2a_Pkg.spoUser(rec.bems_id,  Amd_Defaults.INSERT_ACTION) ;
			   EXCEPTION WHEN standard.DUP_VAL_ON_INDEX THEN
			     NULL ; -- ignore because some users have multiple planner codes
			   END insertAmdUsers ;
			END IF ;
		 END LOOP ;

		 FOR rec IN deletedUsers LOOP
		 	 UPDATE AMD_USERS
			 SET action_code = Amd_Defaults.DELETE_ACTION,
			 last_update_dt = SYSDATE
			 WHERE bems_id = rec.bems_id ;
			 deleted := deleted + 1 ;
			 A2a_Pkg.spoUser(rec.bems_id,  Amd_Defaults.DELETE_ACTION) ;
		 END LOOP ;

	    writeMsg(pTableName => 'amd_users', pError_location => 280,
				pKey1 => 'loadUsers',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'inserted=' || to_char(inserted),
				pKey4 => 'deleted=' || to_char(deleted) ) ;
				
		commit ;
	END loadUsers ;

	
	FUNCTION insertPlannerLogons(planner_code IN VARCHAR2, logon_id IN VARCHAR2, data_source in varchar2) RETURN NUMBER IS
	
			 
			 PROCEDURE doUpdate IS
			 BEGIN
			 	  UPDATE AMD_PLANNER_LOGONS
				  SET
				  action_code = Amd_Defaults.INSERT_ACTION,
				  last_update_dt = SYSDATE
				  WHERE planner_code = insertPlannerLogons.planner_code
				  AND logon_id = insertPlannerLogons.logon_id
				  and data_source = insertPlannerLogons.data_source ;
			 EXCEPTION WHEN OTHERS THEN
			   errorMsg(sqlFunction => 'update', tableName => 'amd_planner_logons', pError_location => 290,
			   		key1 => insertPlannerLogons.planner_code,
					key2 => insertPlannerLogons.logon_id,
					key3 => insertPlannerLogons.data_source) ;
			   RAISE ;

			 END doUpdate ;
	BEGIN
		 debugMsg('planner_code=' || planner_code || ' logon_id=' || logon_id || ' data_source=' || data_source) ;
		 <<insertAmdPlannerLogons>>
		 BEGIN
			 INSERT INTO AMD_PLANNER_LOGONS
			 (planner_code, logon_id, data_source, action_code, last_update_dt)
			 VALUES (insertPlannerLogons.planner_code, insertPlannerLogons.logon_id, insertPlannerLogons.data_source, Amd_Defaults.INSERT_ACTION, SYSDATE) ;
		 EXCEPTION
		   WHEN standard.DUP_VAL_ON_INDEX THEN
		   		doUpdate ;
		   WHEN OTHERS THEN
			   errorMsg(sqlFunction => 'insert', tableName => 'amd_planner_logons', pError_location => 300,
			   		key1 => insertPlannerLogons.planner_code,
					key2 => insertPlannerLogons.logon_id,
					key3 => insertPlannerLogons.data_source) ;
			   RAISE ;

	 	 END insertAmdPlannerLogons ;

	 	 A2a_Pkg.insertSiteRespAssetMgr(assetMgr => insertPlannerLogons.planner_code, 
	        logonId => insertPlannerLogons.logon_id,
	 		data_source => insertPlannerLogons.data_source,
	 		action_code => Amd_Defaults.INSERT_ACTION) ;
		 
		RETURN SUCCESS ;

	EXCEPTION WHEN OTHERS THEN
	    errorMsg(sqlFunction => 'insertPlannerLogons', tableName => 'amd_planner_logons', pError_location => 310) ;
		RETURN FAILURE ;
	END insertPlannerLogons ;

	FUNCTION updatePlannerLogons(planner_code IN VARCHAR2, logon_id IN VARCHAR2, data_source in varchar2) RETURN NUMBER IS
	BEGIN
		 <<updateAmdPlannerLogons>>
		 BEGIN
		 	UPDATE AMD_PLANNER_LOGONS
			SET
			last_update_dt = SYSDATE,
			action_code = Amd_Defaults.UPDATE_ACTION
			WHERE planner_code = updatePlannerLogons.planner_code
			AND logon_id = updatePlannerLogons.logon_id
			and data_source = updatePlannerLogons.data_source ;
		 EXCEPTION WHEN OTHERS THEN
		   errorMsg(sqlFunction => 'update', tableName => 'amd_planner_logons', pError_location => 320,
		   		key1 => updatePlannerLogons.planner_code,
				key2 => updatePlannerLogons.logon_id,
				key3 => updatePlannerLogons.data_source) ;
		   RAISE ;

	 	 END updateAmdPlannerLogons ;

	 	 A2a_Pkg.insertSiteRespAssetMgr(assetMgr => updatePlannerLogons.planner_code, 
	        logonId => updatePlannerLogons.logon_id,
	 		data_source => updatePlannerLogons.data_source,
	 		action_code => Amd_Defaults.UPDATE_ACTION) ;
		
		RETURN SUCCESS ;
	EXCEPTION WHEN OTHERS THEN
	    errorMsg(sqlFunction => 'updatePlannerLogons', tableName => 'amd_planner_logons', pError_location => 330) ;
		RETURN FAILURE ;
	END updatePlannerLogons ;

	FUNCTION deletePlannerLogons(planner_code IN VARCHAR2, logon_id IN VARCHAR2, data_source in varchar2) RETURN NUMBER IS
	BEGIN
		 <<deleteAmdPlannerLogons>>
		 BEGIN
		 	UPDATE AMD_PLANNER_LOGONS
			SET
			last_update_dt = SYSDATE,
			action_code = Amd_Defaults.DELETE_ACTION
			WHERE planner_code = deletePlannerLogons.planner_code
			AND logon_id = deletePlannerLogons.logon_id
			and data_source = deletePlannerLogons.data_source ;
		 EXCEPTION WHEN OTHERS THEN
		   errorMsg(sqlFunction => 'update', tableName => 'amd_planner_logons', pError_location => 340,
		   		key1 => deletePlannerLogons.planner_code, key2 => deletePlannerLogons.logon_id, key3 => deletePlannerLogons.data_source) ;
		   RAISE ;

	 	 END deleteAmdPlanners ;

		A2a_Pkg.insertSiteRespAssetMgr(deletePlannerLogons.planner_code, deletePlannerLogons.logon_id,		  
		  Amd_Defaults.DELETE_ACTION,
		  deletePlannerLogons.data_source) ;

		RETURN SUCCESS ;

	EXCEPTION WHEN OTHERS THEN
	    errorMsg(sqlFunction => 'deletePlannerLogons', tableName => 'amd_planner_logons', pError_location => 350) ;
		RETURN FAILURE ;
	END deletePlannerLogons ;

	-- For future use
	-- The following procedures: loadGoldPsmsMain, preProcess, postProcess, & postDiffProcess,
	-- may be used to replace the bulky sql scripts currently used by amd_loader.ksh
	procedure loadGoldPsmsMain(startStep in number := 1, endStep in number := 3) is
			  batch_job_number amd_batch_jobs.BATCH_JOB_NUMBER%type := amd_batch_pkg.getActiveJob ;
			  batch_step_number amd_batch_job_steps.BATCH_STEP_NUMBER%type ;
			  LOAD_GOLD constant varchar2(8) := 'loadGold' ;
			  LOAD_PSMS constant varchar2(8) := 'loadPsms' ;
			  LOAD_MAIN constant varchar2(8) := 'loadMain' ;
	begin
		 if batch_job_number is null then
		 	raise no_active_job ;
		 end if ;

		 for step in startStep..endStep loop
		 	 if step = 1 then
			 	if not amd_batch_pkg.isStepComplete(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
				   	   					description => LOAD_GOLD) then
				 	amd_batch_pkg.start_step(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
						description => LOAD_GOLD, package_name => THIS_PACKAGE, procedure_name => LOAD_GOLD) ;

				 	loadGold ;
				end if ;

			 elsif step = 2 then
			 	if not amd_batch_pkg.isStepComplete(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
				   	   					description => LOAD_PSMS) then
				 	amd_batch_pkg.start_step(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
						description => LOAD_PSMS, package_name => THIS_PACKAGE, procedure_name => LOAD_PSMS) ;

				 	loadPsms ;
				end if ;

			 elsif step = 3 then
			 	if not amd_batch_pkg.isStepComplete(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
				   	   					description => LOAD_MAIN) then
				 	amd_batch_pkg.start_step(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
						description => LOAD_MAIN, package_name => THIS_PACKAGE, procedure_name => LOAD_MAIN) ;

				    loadMain ;
				end if ;

			 end if ;
			 debugMsg('loadGoldPsmsMain: completed step ' || step) ;
			 batch_step_number := amd_batch_pkg.getActiveStep(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP) ;
			 if batch_step_number is not null then
			 	 amd_batch_pkg.end_step(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
					batch_step_number => batch_step_number) ;
			 end if ;
			 commit ;
		 end loop ;
	end loadGoldPsmsMain ;

	procedure preProcess(startStep in number := 1, endStep in number := 3) is
	begin
		 loadGoldPsmsMain(startStep, endStep) ;
	end preProcess ;

	procedure postProcess(startStep in number := 1, endStep in number := 18) is
			  batch_job_number amd_batch_jobs.BATCH_JOB_NUMBER%type := amd_batch_pkg.getActiveJob(system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP) ;
			  batch_step_number amd_batch_job_steps.BATCH_STEP_NUMBER%type ;

			  THE_A2A_PKG 					 constant varchar2(7)  := 'a2a_pkg' ;
			  THE_AMD_PARTPRIME_PKG 		 constant varchar2(17) := 'amd_partprime_pkg' ;
			  THE_AMD_PART_LOC_FORECASTS_PKG constant varchar2(26) := 'amd_part_loc_forecasts_pkg' ;
			  THE_AMD_SPARE_PARTS_PKG 	  	 constant varchar2(19) := 'amd_spare_parts_pkg' ;
			  THE_AMD_SPARE_NETWORKS_PKG  	 constant varchar2(22) :=  'amd_spare_networks_pkg' ;
			  THE_AMD_DEMAND_PKG 		  	 constant varchar2(10) := 'amd_demand' ;
			  THE_AMD_PART_LOCS_LOAD_PKG  	 constant varchar2(22) := 'amd_part_locs_load_pkg' ;
			  THE_AMD_FROM_BSSM_PKG			 constant varchar2(17) := 'amd_from_bssm_pkg' ;
			  THE_AMD_CLEANED_FROM_BSSM_PKG  constant varchar2(25) := 'amd_cleaned_from_bssm_pkg' ;

			  DELETE_INVALID_PARTS 	   constant varchar2(18) := 'deleteinvalidParts' ;
			  DIFF_PART_TO_PRIME 	   constant varchar2(15) := 'DiffPartToPrime' ;
			  LOAD_LATEST_RBL_RUN 	   constant varchar2(16) := 'LoadLatestRblRun' ;
			  LOAD_CURRENT_BACKORDER   constant varchar2(20) := 'loadCurrentBackOrder' ;
			  LOAD_TEMP_NSNS 		   constant varchar2(12) := 'loadtempnsns' ;
			  AUTO_LOAD_SPARE_NETWORKS constant varchar2(24) := 'auto_load_spare_networks' ;
			  LOAD_AMD_DEMANDS 		   constant varchar2(14) := 'loadamddemands' ;
			  LOAD_BASC_UK_DEMANDS 	   constant varchar2(17) := 'loadBascUkdemands' ;
			  AMD_DEMAND_A2A 		   constant varchar2(14) := 'amd_demand_a2a' ;
			  LOAD_GOLD_INVENTORY 	   constant varchar2(17) := 'loadGoldInventory' ;
			  LOAD_AMD_PART_LOCATIONS  	  constant varchar2(20) := 'LoadAmdPartLocations' ;
			  LOAD_AMD_BASE_FROM_BSSM_RAW constant varchar2(22) := 'LoadAmdBaseFromBssmRaw' ;

	begin
		if batch_job_number is null then
		 	raise amd_load.no_active_job ;
		end if ;
		for step in startStep..endStep loop
			if step = 1 then
				if amd_batch_pkg.didStepStart(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
						description => DELETE_INVALID_PARTS, package_name => THE_A2A_PKG, procedure_name => DELETE_INVALID_PARTS) then

					  a2a_pkg.deleteinvalidparts;
				end if ;

			elsif step = 2 then
			 	if amd_batch_pkg.didStepStart(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
					description => DIFF_PART_TO_PRIME, package_name => THE_AMD_PARTPRIME_PKG, procedure_name => DIFF_PART_TO_PRIME) then

				  amd_partprime_pkg.DiffPartToPrime;
				end if ;

			elsif step = 3 then
			 	if amd_batch_pkg.didStepStart(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
					description => LOAD_LATEST_RBL_RUN, package_name => THE_AMD_PART_LOC_FORECASTS_PKG, procedure_name => LOAD_LATEST_RBL_RUN) then

				  amd_part_loc_forecasts_pkg.LoadLatestRblRun;
				end if ;

			elsif step = 4 then
			 	if amd_batch_pkg.didStepStart(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
					description => LOAD_CURRENT_BACKORDER, package_name => THE_AMD_SPARE_PARTS_PKG, procedure_name => LOAD_CURRENT_BACKORDER) then

				  amd_spare_parts_pkg.loadCurrentBackOrder;
				end if ;

			elsif step = 5 then
			 	if amd_batch_pkg.didStepStart(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
					description => LOAD_TEMP_NSNS, package_name => THIS_PACKAGE, procedure_name => LOAD_TEMP_NSNS) then

				  amd_load.loadtempnsns;
				end if ;

			elsif step = 6 then
			 	if amd_batch_pkg.didStepStart(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
					description => AUTO_LOAD_SPARE_NETWORKS, package_name => THE_AMD_SPARE_NETWORKS_PKG, procedure_name => AUTO_LOAD_SPARE_NETWORKS) then

				  amd_spare_networks_pkg.auto_load_spare_networks;
				end if ;

			elsif step = 7 then
			 	if amd_batch_pkg.didStepStart(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
					description => LOAD_AMD_DEMANDS, package_name => THE_AMD_DEMAND_PKG, procedure_name => LOAD_AMD_DEMANDS) then

				  amd_demand.loadamddemands;
				end if ;

			elsif step = 8 then
			 	if amd_batch_pkg.didStepStart(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
					description => LOAD_BASC_UK_DEMANDS, package_name => THE_AMD_DEMAND_PKG, procedure_name => LOAD_BASC_UK_DEMANDS) then

				  amd_demand.loadBascUkdemands;
				end if ;

			elsif step = 9 then
			 	if amd_batch_pkg.didStepStart(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
					description => AMD_DEMAND_A2A, package_name => THE_AMD_DEMAND_PKG, procedure_name => AMD_DEMAND_A2A) then

				  amd_demand.amd_demand_a2a;
				end if ;

			elsif step = 10 then
			 	if amd_batch_pkg.didStepStart(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
					description => LOAD_GOLD_INVENTORY, package_name => THE_AMD_INVENTORY_PKG, procedure_name => LOAD_GOLD_INVENTORY) then

				  amd_inventory.loadGoldInventory;
				end if ;

			elsif step = 11 then
				  if amd_batch_pkg.didStepStart(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
					description => LOAD_AMD_PART_LOCATIONS, package_name => THE_AMD_PART_LOCS_LOAD_PKG, procedure_name => LOAD_AMD_PART_LOCATIONS) then

				  	amd_part_locs_load_pkg.LoadAmdPartLocations;
				  end if ;

			elsif step = 12 then
			 	  if amd_batch_pkg.didStepStart(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
					description => LOAD_AMD_BASE_FROM_BSSM_RAW, package_name => THE_AMD_FROM_BSSM_PKG, procedure_name => LOAD_AMD_BASE_FROM_BSSM_RAW) then

				    amd_from_bssm_pkg.LoadAmdBaseFromBssmRaw;
				  end if ;

			elsif step = 13 then
			 	  if amd_batch_pkg.didStepStart(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
					description => 'UpdateAmdAllBaseCleaned', package_name => THE_AMD_CLEANED_FROM_BSSM_PKG, procedure_name => 'UpdateAmdAllBaseCleaned') then

				    amd_cleaned_from_bssm_pkg.UpdateAmdAllBaseCleaned;
				  end if ;

			elsif step = 14 then
			 	  if amd_batch_pkg.didStepStart(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
					description => 'LoadAmdReqs', package_name => THIS_PACKAGE, procedure_name => 'LoadAmdReqs') then

				    amd_reqs_pkg.LoadAmdReqs;
				 end if ;

			elsif step = 15 then
			 	  if amd_batch_pkg.didStepStart(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
					description => 'LoadTmpAmdPartFactors', package_name => THIS_PACKAGE, procedure_name => 'LoadTmpAmdPartFactors') then

				   amd_part_factors_pkg.LoadTmpAmdPartFactors;
				 end if ;

			elsif step = 16 then
			 	  if amd_batch_pkg.didStepStart(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
					description => 'ProcessA2AVirtualLocs', package_name => THIS_PACKAGE, procedure_name => 'ProcessA2AVirtualLocs') then

				    amd_part_factors_pkg.ProcessA2AVirtualLocs;
				 end if ;

			elsif step = 17 then
			 	  if amd_batch_pkg.didStepStart(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
					description => 'LoadTmpAmdPartLocForecasts_Add', package_name => THIS_PACKAGE, procedure_name => 'LoadTmpAmdPartLocForecasts_Add') then

				    amd_part_loc_forecasts_pkg.LoadTmpAmdPartLocForecasts_Add;
				 end if ;

			elsif step = 18 then
			 	  if amd_batch_pkg.didStepStart(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
					description => 'LoadTmpAmdLocPartLeadtime', package_name => THIS_PACKAGE, procedure_name => 'LoadTmpAmdLocPartLeadtime') then

				    amd_location_part_leadtime_pkg.LoadTmpAmdLocPartLeadtime;
				 end if ;

			end if ;
			debugMsg('postProcess: completed step ' || step) ;
		    batch_step_number := amd_batch_pkg.getActiveStep(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP) ;
			if batch_step_number is not null then
		 	    amd_batch_pkg.end_step(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
				  batch_step_number => batch_step_number) ;
		    end if ;
			commit;
		end loop ;
	end postProcess ;

	procedure postDiffProcess(startStep in number := 1, endStep in number := 3) is
			  batch_job_number amd_batch_jobs.BATCH_JOB_NUMBER%type := amd_batch_pkg.getActiveJob(system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP) ;
			  batch_step_number amd_batch_job_steps.BATCH_STEP_NUMBER%type ;
	begin
		 if batch_job_number is null then
		 	raise amd_load.no_active_job ;
		 end if ;
		 for step in startStep..endStep loop
		 	 if step = 1 then
		 	    if amd_batch_pkg.didStepStart(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
				  description => 'UpdateSpoTotalInventory', package_name => THE_AMD_INVENTORY_PKG, procedure_name => 'UpdateSpoTotalInventory') then

			 	  amd_inventory.UpdateSpoTotalInventory;
			   end if ;

			 elsif step = 2 then
		 	    if amd_batch_pkg.didStepStart(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
				  description => 'LoadTmpAmdLocPartOverride', package_name => THIS_PACKAGE, procedure_name => 'LoadTmpAmdLocPartOverride') then

			 	  amd_location_part_override_pkg.LoadTmpAmdLocPartOverride;
			   end if ;

			 elsif step = 3 then
		 	    if amd_batch_pkg.didStepStart(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
				  description => 'LoadZeroTslA2A', package_name => THIS_PACKAGE, procedure_name => 'LoadZeroTslA2A') then

			      amd_location_part_override_pkg.LoadZeroTslA2A;
			    end if ;

			 end if ;
			 debugMsg('postDiffProcess: completed step ' || step) ;
			 batch_step_number := amd_batch_pkg.getActiveStep(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP) ;
			 if batch_step_number is not null then
			 	 amd_batch_pkg.end_step(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
					batch_step_number => batch_step_number) ;
			 end if ;
			 commit ;
		 end loop ;
	end postDiffProcess ;

	procedure disableAmdConstraints is
	begin
		 debugMsg('start disableAmdContraints') ;
		 mta_disable_constraint('amd_part_loc_time_periods','amd_part_loc_time_periods_fk01');
		 mta_disable_constraint('amd_part_locs','amd_part_locs_fk01');
		 mta_disable_constraint('amd_part_locs','amd_part_locs_fk02');
		 mta_disable_constraint('amd_maint_task_distribs','amd_maint_task_distribs_fk01');
		 mta_disable_constraint('amd_bods','amd_bods_fk02');
		 mta_disable_constraint('amd_part_next_assemblies','amd_part_next_assemblies_fk01');
		 mta_disable_constraint('amd_demands','amd_demands_fk01');
		 mta_disable_constraint('amd_demands','amd_demands_fk02');
		 mta_disable_constraint('amd_demands','amd_demands_pk');
		 debugMsg('end disableAmdContraints') ;
		 commit ;
	end disableAmdConstraints ;

	procedure truncateAmdTables is
	begin
		 debugMsg('start truncateAmdTables') ;
		 mta_truncate_table('tmp_a2a_bom_detail','reuse storage');
		 mta_truncate_table('tmp_a2a_demands','reuse storage');
		 mta_truncate_table('tmp_a2a_org_flight_acty','reuse storage');
		 mta_truncate_table('tmp_a2a_org_flight_acty_frecst','reuse storage');
		 mta_truncate_table('tmp_a2a_site_resp_asset_mgr','reuse storage');
		 mta_truncate_table('tmp_a2a_spo_users','reuse storage');
		 mta_truncate_table('tmp_a2a_part_effectivity','reuse storage');
		 mta_truncate_table('tmp_amd_demands','reuse storage');
		 mta_truncate_table('tmp_amd_part_locs','reuse storage');
		 mta_truncate_table('tmp_amd_spare_parts','reuse storage');
		 mta_truncate_table('tmp_lcf_icp','reuse storage');
		 mta_truncate_table('amd_bssm_source','reuse storage');
		 mta_truncate_table('amd_maint_task_distribs','reuse storage');
		 mta_truncate_table('amd_part_loc_time_periods','reuse storage');
		 mta_truncate_table('amd_flight_stats','reuse storage');
		 mta_truncate_table('tmp_a2a_ext_forecast','reuse storage') ;
		 debugMsg('end truncateAmdTables') ;
		 commit ;
	end truncateAmdTables ;

	procedure enableAmdConstraints is
	begin
		 debugMsg('start enableAmdConstraints') ;
		 mta_enable_constraint('amd_part_loc_time_periods','amd_part_loc_time_periods_fk01');
		 mta_enable_constraint('amd_part_locs','amd_part_locs_fk01');
		 mta_enable_constraint('amd_part_locs','amd_part_locs_fk02');
		 mta_enable_constraint('amd_maint_task_distribs','amd_maint_task_distribs_fk01');
		 mta_enable_constraint('amd_bods','amd_bods_fk02');
		 mta_enable_constraint('amd_part_next_assemblies','amd_part_next_assemblies_fk01');
		 mta_enable_constraint('amd_demands','amd_demands_fk01');
		 mta_enable_constraint('amd_demands','amd_demands_fk02');
		 mta_enable_constraint('amd_demands','amd_demands_pk');
		 debugMsg('end enableAmdConstraints') ;
		 commit ;
	end enableAmdConstraints ;

	procedure prepAmdDatabase is
		  batch_job_number amd_batch_jobs.BATCH_JOB_NUMBER%type := amd_batch_pkg.getActiveJob(system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP) ;
		  batch_step_number amd_batch_job_steps.BATCH_STEP_NUMBER%type ;
	begin
		 debugMsg('start prepAmdDatabase') ;
		 if batch_job_number is null then
		 	raise amd_load.no_active_job ;
		 end if ;
 	     amd_batch_pkg.start_step(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
		   description => 'disableAmdConstraints', package_name => THIS_PACKAGE, procedure_name => 'disableAmdConstraints') ;
		 disableAmdConstraints ;
		 batch_step_number := amd_batch_pkg.getActiveStep(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP) ;
	 	 amd_batch_pkg.end_step(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
			batch_step_number => batch_step_number) ;

 	     amd_batch_pkg.start_step(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
		   description => 'truncateAmdTables', package_name => THIS_PACKAGE, procedure_name => 'truncateAmdTables') ;
		 truncateAmdTables ;
		 batch_step_number := amd_batch_pkg.getActiveStep(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP) ;
	 	 amd_batch_pkg.end_step(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
			batch_step_number => batch_step_number) ;

 	     amd_batch_pkg.start_step(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
		   description => 'enableAmdConstraints', package_name => THIS_PACKAGE, procedure_name => 'enableAmdConstraints') ;
		 enableAmdConstraints ;
		 batch_step_number := amd_batch_pkg.getActiveStep(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP) ;
	 	 amd_batch_pkg.end_step(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
			batch_step_number => batch_step_number) ;

		 debugMsg('end prepAmdDatabase') ;
		 commit ;
	end prepAmdDatabase ;

	procedure version is
	begin
		 writeMsg(pTableName => 'amd_load', 
		 		pError_location => 360, pKey1 => 'amd_load', pKey2 => '$Revision:   1.47  $') ;
		 dbms_output.put_line('amd_load: $Revision:   1.47  $') ;
	end version ;
	
	procedure validatePartStructure is
			  cursor NoNsn4SpareParts is
			  		 select * from amd_spare_parts where nsn is null ;
			  cursor NoNsn4Items is
			  		 select * from amd_National_Stock_Items where nsn is null ;
			  cursor NoPrimePart is
			  		 select * from amd_national_stock_items where prime_part_no is null ;
			  cursor NotDeleted is
			  		 select nsi_sid, prime_part_no from amd_national_stock_items items, amd_spare_parts parts where prime_part_no = part_no
					 and items.action_code <> amd_defaults.DELETE_ACTION and parts.action_code = amd_defaults.DELETE_ACTION ;  
			  
			  cntNoNsnParts number := 0 ;
			  cntNoNsnItems number := 0 ;
			  cntNoPrimePart number := 0 ;
			  cntNotDeleted number := 0 ;
	begin
		 for rec in NoNsn4SpareParts loop
		 	 cntNoNsnParts := cntNoNsnParts + 1 ;
			 writeMsg(pTableName => 'amd_spare_parts', pError_location => 370,
			 		pKey1 => 'part_no=' || rec.part_no, pKey2 => 'No Nsn',
					pKey3 => 'action_code=' || rec.action_code) ;
		 end loop ;
		 for rec in NoNsn4Items loop
		 	 cntNoNsnItems := cntNoNsnItems + 1 ;
			 writeMsg(pTableName => 'amd_national_stock_items', pError_location => 380,
			 		pKey1 => 'prime_part_no=' || rec.prime_part_no, pKey2 => 'No Nsn',
					pKey3 => 'action_code=' || rec.action_code) ;
		 end loop ;
		 for rec in NoPrimePart loop
		 	 cntNoPrimePart := cntNoPrimePart + 1 ;
			 writeMsg(pTableName => 'amd_national_stock_items', pError_location => 390,
			 		pKey1 => 'nsi_sid=' || rec.nsi_sid, pKey2 => 'No Prime Part',
					pKey3 => 'action_code=' || rec.action_code,
					pKey4 => 'nsn=' || rec.nsn) ;
		 end loop ;
		 for rec in NotDeleted loop
		 	 cntNotDeleted := cntNotDeleted + 1 ;
			 update amd_national_stock_items
			 set action_code = amd_defaults.DELETE_ACTION,
			 last_update_dt = sysdate 
			 where nsi_sid = rec.nsi_sid;
			 IF MOD(cntNotDeleted,COMMIT_THRESHOLD) = 0 THEN
			   COMMIT ;
			 end if ;
		 end loop ;
		 dbms_output.put_line('cntNoNsnParts=' || cntNoNsnParts) ;
		 dbms_output.put_line('cntNoNsnItems=' || cntNoNsnItems) ;
		 dbms_output.put_line('cntNoPrimePart=' || cntNoPrimePart) ;
		 dbms_output.put_line('cntNotDeleted=' || cntNotDeleted) ;
		 writeMsg(pTableName => 'amd_spare_parts', pError_location => 390,
		 		pKey1 => 'cntNoNsnParts=' || to_char(cntNoNsnParts)) ;
		 writeMsg(pTableName => 'amd_national_stock_items', pError_location => 400,
		 		pKey1 => 'cntNoNsnItems=' || to_char(cntNoNsnItems)) ;
		 writeMsg(pTableName => 'amd_national_stock_items', pError_location => 410,
		 		pKey1 => 'cntNoPrimePart=' || to_char(cntNoPrimePart)) ;
		 writeMsg(pTableName => 'amd_national_stock_items', pError_location => 410,
		 		pKey1 => 'cntNotDeleted=' || to_char(cntNotDeleted)) ;
	end validatePartStructure ;

BEGIN

  <<getDebugParam>>
  DECLARE
  	 param AMD_PARAM_CHANGES.PARAM_VALUE%TYPE ;
  BEGIN
     SELECT param_value INTO param FROM AMD_PARAM_CHANGES WHERE param_key = 'debugAmdLoad' ;
     mDebug := (param = '1');
  EXCEPTION WHEN OTHERS THEN
     mDebug := FALSE ;
  END getDebugParam;

END Amd_Load;
/

show errors

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.Amd_Inventory AS

	/* ------------------------------------------------------------------- */
	/*  this program extracts data from gold and generate records for the  */
	/*  amd_spare_invs table for the boeing icp parts which have been      */
	/*  loaded in the amd_spare_parts.                                     */
	/*                                                                     */
	/*  this program also generates data for amd_repair_levels and         */
	/*  amd_main_task_distribs table.                                      */
	/* ------------------------------------------------------------------- */
	/* 
	    PVCS Keywords
		
       $Author:   c402417  $
     $Revision:   1.76  $
         $Date:   Jan 17 2007 16:13:50  $
     $Workfile:   amd_inventory.pkb  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_inventory.pkb-arc  $
   
      Rev 1.76   Jan 17 2007 16:13:50   c402417
   Removed total_inaccessible from RspQty when populate data into table tmp_amd_rsp.
   Also modified the cursor rampCurFB to get more accurate data into tmp_amd_rsp and it's the only cursor for tmp_amd_rsp.
   
      Rev 1.75   Nov 29 2006 23:30:26   zf297a
   Removed unecessary site_location variables
   
      Rev 1.74   Nov 28 2006 13:29:02   zf297a
   fixed doRspSumDiff - For delete transactons send a zero qty for tmp_a2a_loc_part_override a2a transactions.
   
      Rev 1.73   Nov 07 2006 09:29:02   c402417
   Removed the query to get data from rvs1 to tmp_amd_in_transits per Laurie.
   
      Rev 1.72   Nov 03 2006 12:13:12   c402417
   Added Exception for duplicate on insert into tmp_amd_in_transits
   
      Rev 1.71   Jun 09 2006 11:39:30   zf297a
   implemented interface version
   
      Rev 1.70   Jun 05 2006 08:59:06   zf297a
   Fixed errorMsg - changed literal from amd_load to amd_inventory
   
      Rev 1.69   May 16 2006 12:08:00   zf297a
   Fixed doRspSumDiff to invoke A2a_Pkg.insertInvInfo with the qty_on_hand or zero if it is null
   
      Rev 1.68   Apr 28 2006 12:51:28   c402417
   Added tmp_a2a_loc_part_override to truncate .
   
      Rev 1.67   Apr 28 2006 12:42:32   c402417
   Added AMD Inventory Mofication for SPO - including new process for amd_rsp, removed Order Type of M from amd_on_order, removed HPMSK_BALANCE+ SPRAM_BALANCE+WRM_BALANCE from amd_on_hand_inv.
   
      Rev 1.66   Jan 20 2006 12:01:38   c402417
   Need to exclude part_no w/out spo_location for spo_total_inventory.
   
      Rev 1.65   Dec 15 2005 12:20:44   zf297a
   Added truncate of table tmp_a2a_repair_inv_info to loadInRepair
   
      Rev 1.64   Dec 06 2005 14:25:44   zf297a
   Fixed the doUpdate of the insertOnOrderRow routine when it checks for a Deleted order qualify the select with the order_date and also fixed the update by adding the order_date in its where clause.
   
      Rev 1.63   Dec 06 2005 14:04:36   zf297a
   Fixed deleteRow - passed an qty_ordered of 0 and sysdate for the A2A transaction.
   
      Rev 1.62   Dec 06 2005 12:29:20   zf297a
   Implemented new version of deleteRow for amd_on_order diff.  The code has been streamlined since all the necessary data is being passed in from the java diff application.
   
      Rev 1.61   Dec 06 2005 10:20:20   zf297a
   Fixed update of amd_on_order: qualified the where clause with  gold_order_number and order_date.  Order_date was missing and caused a unique constraint error.
   
      Rev 1.60   Nov 03 2005 09:33:18   c402417
   Changed sequence of procedure so the SpoTotalInventory get update after all inventory tables get loaded.
   
      Rev 1.59   Oct 27 2005 15:47:54   c402417
   Added repair_need_date to A2a_pkg.insertRepairInfo.
   
      Rev 1.58   Oct 20 2005 16:35:58   c402417
   Added Cursor RampCurUAB. This cursor feeds data from table ramp with SC = UAB to amd_on_hand_invs.
   
      Rev 1.57   Oct 19 2005 11:37:42   zf297a
   removed invocation of insertTmpA2AOrderInfoLine and update the arg list for insertTmpA2AOrderInfo, which now inserts both the tmp_a2a_order_info and the tmp_a2a_order_info_line.
   
   Thuy, added code for rampCurUAB.
   
      Rev 1.56   Oct 13 2005 11:12:14   c402417
   Added Repair Inventory Sum diff function . This to sum parts which have doc_no like 'R' and 'II' and send them to table amd_repair_invs_sum and these data consider DEFECTIVE as on_hand_type in SPO - Inventory.
   
      Rev 1.55   Oct 04 2005 13:05:12   c402417
   Add goldsa for amd_on_hand_invs.(This added for SPO 5.0)
   
      Rev 1.54   Oct 04 2005 11:51:26   c402417
   minor fixed in in_repair update statement .
   
      Rev 1.53   Sep 26 2005 09:31:20   zf297a
   Fixed deleteRow for doOnHandInvsSumDiff: it was trying to update amd_on_hand_invs instead of amd_on_hand_invs_sum
   
      Rev 1.52   Sep 13 2005 12:44:24   zf297a
   Implemented the isVoucher boolean function and modified the getOnOrderParams procedure to check if from/to dates not null and have a length > 0 before returning them.
   
      Rev 1.51   Sep 12 2005 11:36:40   zf297a
   implemented interfaces for one get and one set procedure for all the on order date parameters for a given voucher.
   
      Rev 1.50   Sep 09 2005 10:56:34   zf297a
   For amd_on_hand_inv_sums changed the site_location column to be the spo_location column.  The spo_location comes from amd_spare_networks.spo_location.
   
      Rev 1.49   Sep 07 2005 21:01:24   zf297a
   raised sched_receipt_date_exception in setScheduledReceiptDate when the from_date argument is > than the to_date argument.
   
      Rev 1.48   Sep 07 2005 15:17:32   zf297a
   Added orderdates subtype.   Implemented gets and sets for create_order_date, scheduled_receipt_date_from, scheduled_receipt_date_to, and number_of_calander days.
   
      Rev 1.47   Sep 02 2005 15:50:24   zf297a
   Started implementing interfaces for getOrderCreateDate, setOrderCreateDate, getScdeduledReceiptDateFrom, getScdeduledReceiptDateTo, setScheduledReceiptDate, and setScheduledReceiptDateCalDays using empty functions and procedures.
   
      Rev 1.46   Aug 30 2005 10:40:38   zf297a
   Moved cursors outside of loadGoldInventory.  Implemented loadOnHandInvs and loadInRepair as separate procedures.  Updated loadGoldInventory to use these new procedures.
   
      Rev 1.45   12 Aug 2005 09:42:18   c402417
   Added FC to order_no on ORD1 for amd_on_onder
   
      Rev 1.44   Aug 04 2005 08:12:52   zf297a
   Made insertRow and updateRow unique for the jdbc interface by renaming them to insertOnOrderRow and updateOnOrderRow.
   
      Rev 1.43   03 Aug 2005 17:43:14   b1013683
   Added Accountable_YN in  amd_in_repair.
   Added sched_receipt_date & changed in order_date in amd_on_order.
   Made modification in getting spo_total_inventory in table ansi.
   
      Rev 1.41   Jul 15 2005 10:59:08   zf297a
   Fixed updateRow for amd_inv_on_hand and insertRow for amd_in_transits
   
      Rev 1.39   Jul 11 2005 11:49:12   zf297a
   used procedure a2a_pkg.insertTmpA2AInTransits
   
      Rev 1.38   Jul 11 2005 10:39:22   zf297a
   used a2a_pkg to insertTmpA2AOrderInfo and insertTmpA2AOrderInfoLine
   
      Rev 1.37   Jul 11 2005 09:49:02   zf297a
   updated pErrorLocation numbers (10, 20, 30,.........400)
   
      Rev 1.36   Jul 11 2005 09:30:36   zf297a
   made the loading of tmp_amd_in_transits a separate procedure
   
      Rev 1.35   Jul 11 2005 09:17:42   zf297a
   made the loading of tmp_amd_on_order a separate procedure
   
      Rev 1.34   Jul 06 2005 09:28:14   zf297a
   Enhanced amd_in_repair and added spo inventory total
   
      Rev 1.33   Jun 17 2005 06:52:50   c970183
   removed insertInvInfo, updateInvInfo, and deleteInvInfo from routine dealing with amd_in_repair
   
      Rev 1.32   May 17 2005 10:06:08   c970183
   Updated InsertErrorMessage to new interface
   
      Rev 1.31   May 04 2005 10:26:04   c970183
   added logical insert (update) for AMD_IN_TRANSITS which had previously been logically deleted.
   
      Rev 1.30   May 04 2005 10:14:30   c970183
   added logical insert (update) for AMD_ON_HAND_INVS which has been previously logically deleted.
   
      Rev 1.29   May 04 2005 10:05:50   c970183
   added a logical insert (update) for amd_in_repair for a row that has been previously logically deleted.
   
      Rev 1.28   May 04 2005 09:50:14   c970183
   truncated all tmp_a2a tables when loadGoldInventory is executed
   
      Rev 1.27   May 04 2005 09:16:00   c970183
   Added logical insert of amd_on_order when it has been previously marked as deleted.
   
      Rev 1.26   Apr 27 2005 09:21:42   c970183
   aded counters of rows inserted for loadGoldInventory.  Added info messages using dbms_output and amd_load_details.
   
      Rev 1.25   20 Sep 2004 10:17:42   c970183
   Fixed site_location for insertRow of in_transits - it must be varchar(20)
   
      Rev 1.24   20 Aug 2004 16:51:46   c402417
   Added tmp_amd_in_repairs
   
      Rev 1.23   09 Aug 2004 14:48:22   c970183
   fixed deleteRow for tmp_a2a_on_hand_invs: the qty_on_hand is required, so set it to zero.
   
      Rev 1.22   09 Aug 2004 14:40:02   c970183
   fixed deleteRow (insert of tmp_a2a_on_hand_invs) the site_location field was NOT being inserted.
   
      Rev 1.21   09 Aug 2004 14:23:46   c970183
   added insertion of tmp_a2a_order_info for inserts and updates
   
      Rev 1.16   05 Aug 2004 07:47:26   c970183
   changed parameter from using p prefix to the same namje as used by the colum.  Added function or procedure qualification for all parameters used in SQL where clauses and UPDATE set clauses
   
      Rev 1.13   03 Aug 2004 10:15:02   c402417
   Added the amd_in_repair diff function.
   
      Rev 1.12   02 Aug 2004 14:14:34   c970183
   accomodate insert/update of detail rows for amd_on_hand_invs
   
      Rev 1.11   Aug 02 2004 08:47:10   c970183
   changed case of plocSid to pLocSid
   
      Rev 1.9   Jul 30 2004 12:02:18   c970183
   added comments to document changes made 
		  
	 */
   	-- DSE 7/23/04 added InsertRow, DeleteRow, and UpdateRow stubs
	-- TL  7/26/04 added ErrorMsg and code for amd_on_order InsertRow, DeleteRow, and UpdateRow
	-- DSE 7/27/04 added tmp prefix to all amd tables created by LoadGoldInventory
	-- DSE 7/29/04 Added InsertRow, UpdateRow, and DeleteRow for the amd_on_order table
	-- TL  7/30/04 Enhanced the ErrorMsg Function and implemented the InsertRow, UpdateRow,
	-- 	   		   and DeleteRow functions for the amd_on_hand_invs table
	-- TP	 8/2/04  Added InsertRow, UpdateRow, and DeleteRow for the amd_in_repair table.
	-- TP    8/18/04 Added InsertRow, UpdateRow, and DeleteRow for the amd_in_transits table.
	-- 

	ON_ORDER_DATE CONSTANT AMD_PARAMS.PARAM_KEY%TYPE := 'on_order_date_' ;
		
	SUBTYPE orderdates IS NUMBER ;
	ORDER_CREATE_DATE CONSTANT orderdates := 1 ;
	SCHEDULED_RECEIPT_DATE_FROM CONSTANT orderdates := 2 ;
	SCHEDULED_RECEIPT_DATE_TO CONSTANT orderdates := 3 ;
	NUMBER_OF_CALANDER_DAYS CONSTANT orderdates := 4 ;
	
	
	CURSOR partCur IS
		SELECT DISTINCT
			asp.part_no,
			asp.nsn
		FROM
			AMD_SPARE_PARTS asp,
			AMD_NATIONAL_STOCK_ITEMS ansi,
			AMD_NSI_PARTS anp
		WHERE
			icp_ind = 'F77'
			AND asp.part_no   = anp.part_no
			AND anp.prime_ind = 'Y'
			AND anp.unassignment_date IS NULL
			AND asp.nsn = ansi.nsn
			AND asp.action_code != 'D';
				
	-- Type 1,2 Retail
	CURSOR rampCur(pNsn VARCHAR2) IS
		SELECT
			DECODE(n.loc_type,'TMP',asn2.loc_sid,n.loc_sid) loc_sid,
			NVL(r.serviceable_balance,0) serviceable_balance,
			NVL(r.spram_balance,0) spram_balance,
			NVL(r.wrm_balance,0) wrm_balance,
			NVL(r.hpmsk_balance,0) hpmsk_balance,
			NVL(r.total_inaccessible_qty,0) total_inaccessible_qty,
			NVL(r.difm_balance,0) difm_balance,
			NVL(r.unserviceable_balance,0) unserviceable_balance,
			NVL(r.spram_level,0) spram_level,
			NVL(r.wrm_level,0) wrm_level,
			NVL(r.hpmsk_level_qty,0) hpmsk_level_qty,
			NVL(r.suspended_in_stock,0) suspended_in_stock,
			TRUNC(NVL(r.date_processed,SYSDATE)) inv_date,
			TRUNC((r.date_processed) + NVL(avg_repair_cycle_time,0)) repair_need_date
		FROM
			(SELECT * FROM RAMP
			WHERE current_stock_number = pNsn ) r,
			--AMD_SPARE_PARTS asp,
			AMD_SPARE_NETWORKS n,
			AMD_SPARE_NETWORKS asn2
		WHERE
			n.loc_id = SUBSTR(r.sc(+),8,6)
			--AND asp.nsn = pNsn
			AND n.loc_type IN ('MOB', 'FSL')
			AND n.mob = asn2.loc_id(+);
					
			
	CURSOR rampCurUAB(pNsn VARCHAR2) IS
		SELECT
			DECODE(n.loc_type,'TMP',asn2.loc_sid,n.loc_sid) loc_sid,
			NVL(r.serviceable_balance,0) serviceable_balance,
			NVL(r.spram_balance,0) spram_balance,
			NVL(r.hpmsk_balance,0) hpmsk_balance,
			NVL(r.wrm_balance,0) wrm_balance,
			NVL(r.total_inaccessible_qty,0) total_inaccessible_qty,
			NVL(r.difm_balance,0) difm_balance,
			NVL(r.spram_level,0) spram_level,
			NVL(r.wrm_level,0) wrm_level,
			NVL(r.hpmsk_level_qty,0) hpmsk_level_qty,
			TRUNC(NVL(r.date_processed,SYSDATE)) inv_date,
			TRUNC((r.date_processed) + NVL(avg_repair_cycle_time,0)) repair_need_date
		FROM
			(SELECT * FROM RAMP
			WHERE current_stock_number = pNsn ) r,
			--AMD_SPARE_PARTS asp,
			AMD_SPARE_NETWORKS n,
			AMD_SPARE_NETWORKS asn2
		WHERE
			n.loc_id = SUBSTR(r.sc(+),8,6)
			AND SUBSTR(r.sc,8,2) = 'FB'
			--AND asp.nsn = pNsn
			AND n.loc_type = 'UAB'
			AND n.mob = asn2.loc_id(+);
			
			
		CURSOR rampCurFB(pNsn VARCHAR2) IS
		SELECT
			DECODE(n.loc_type,'TMP',asn2.loc_sid,n.loc_sid) loc_sid,
			NVL(r.serviceable_balance,0) serviceable_balance,
			NVL(r.spram_balance,0) spram_balance,
			NVL(r.hpmsk_balance,0) hpmsk_balance,
			NVL(r.wrm_balance,0) wrm_balance,
			NVL(r.total_inaccessible_qty,0) total_inaccessible_qty,
			NVL(r.difm_balance,0) difm_balance,
			NVL(r.spram_level,0) spram_level,
			NVL(r.wrm_level,0) wrm_level,
			NVL(r.hpmsk_level_qty,0) hpmsk_level_qty,
			TRUNC(NVL(r.date_processed,SYSDATE)) inv_date,
			TRUNC((r.date_processed) + NVL(avg_repair_cycle_time,0)) repair_need_date
		FROM
			(SELECT * FROM RAMP
			WHERE current_stock_number = pNsn ) r,
			--AMD_SPARE_PARTS asp,
			AMD_SPARE_NETWORKS n,
			AMD_SPARE_NETWORKS asn2
		WHERE
			n.loc_id = SUBSTR(r.sc(+),8,6)
			AND n.loc_type in ('MOB','FSL','UAB')
			AND substr(r.sc,8,2) like 'FB%'
			--AND asp.nsn = pNsn
			AND n.mob = asn2.loc_id(+);
			
				
	-- Type 1 Wholesale from ITEM and TMP1
	CURSOR itemType1Cur IS
		SELECT
			asp.part_no,
			DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
			invQ.inv_date inv_date,
			'1' inv_type,
			SUM(invQ.inv_qty) inv_qty
		FROM
			(SELECT
				RTRIM(part) part_no,
				SUBSTR(i.sc,8,6) loc_id,
				TRUNC(DECODE(i.created_datetime, NULL, i.last_changed_datetime,i.created_datetime)) inv_date,
				'1' inv_type,
				SUM(NVL(i.qty,0)) inv_qty
			FROM
				ITEM i
			WHERE
				i.status_3 != 'I'
				AND i.status_servicable = 'Y'
				AND i.status_new_order = 'N'
				AND i.status_accountable = 'Y'
				AND i.status_active = 'Y'
				AND i.status_mai = 'N'
				AND i.condition != 'B170-ATL'
				AND NOT EXISTS (SELECT 1 FROM ITEM ii
							    WHERE ii.status_avail = 'N' 
								AND   ii.receipt_order_no IS NULL
								AND   ii.item_id = i.item_id)
				GROUP BY 
					  RTRIM(part),
					  SUBSTR(i.sc,8,6) ,
					  TRUNC(DECODE(i.created_datetime, NULL, i.last_changed_datetime,i.created_datetime))  
				UNION 
			(SELECT
				RTRIM(part) part_no,
				DECODE(i.sc,'C17PCAG','EY1746') loc_id,
				TRUNC(DECODE(i.created_datetime, NULL, i.last_changed_datetime,i.created_datetime)) inv_date,
				'1' inv_type,
				SUM(NVL(i.qty,0)) inv_qty
			FROM
				ITEMSA i
			WHERE
				i.status_3 != 'I'
				AND i.status_servicable = 'Y'
				AND i.status_new_order = 'N'
				AND i.status_accountable = 'Y'
				AND i.status_active = 'Y'
				AND i.status_mai = 'N'
				AND i.condition != 'B170-ATL'
				AND NOT EXISTS (SELECT 1 FROM ITEMSA ii
							    WHERE ii.status_avail = 'N' 
								AND   ii.receipt_order_no IS NULL
								AND   ii.item_id = i.item_id)
				GROUP BY 
				 	  RTRIM(part),
					  DECODE(i.sc,'C17PCAG','EY1746') ,
					  TRUNC(DECODE(i.created_datetime, NULL, i.last_changed_datetime,i.created_datetime)) )) invQ,
			AMD_SPARE_NETWORKS asn,
			AMD_SPARE_PARTS asp,
			AMD_SPARE_NETWORKS asnLink
		WHERE
			asp.part_no = invQ.part_no
			AND asn.loc_id = invQ.loc_id
			AND asp.action_code != 'D'
			AND asn.mob = asnLink.loc_id(+)
	 GROUP BY  asp.part_no,
	 DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) ,
	 invQ.inv_date;

		-- Type 4 Wholesale
	CURSOR itemMCur IS
		SELECT
			asp.part_no,
			DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
			'4' inv_type,
			RTRIM(i.item_id) item_id,
			DECODE(i.created_datetime,NULL,TRUNC(i.last_changed_datetime),
			      TRUNC(i.created_datetime)) inv_date,
			TRUNC(i.created_datetime) repair_date,
			TRUNC(i.created_datetime + ansi.time_to_repair_off_base) repair_need_date,
			SUM(NVL(i.qty,0)) inv_qty
		FROM
			ITEM i,
			AMD_NATIONAL_STOCK_ITEMS ansi,
			AMD_SPARE_NETWORKS asn,
			AMD_SPARE_PARTS asp,
			AMD_SPARE_NETWORKS asnLink
		WHERE
			asp.part_no = RTRIM(i.part)
			AND RTRIM(i.prime) = RTRIM(ansi.prime_part_no)
			AND i.status_3 != 'I'
			AND i.status_servicable = 'N'
			AND i.status_new_order = 'N'
			AND i.status_accountable = 'Y'
			AND i.status_active = 'Y'
			AND i.status_mai = 'N'
			AND asn.loc_id = SUBSTR(i.sc,8,6)
			AND asp.action_code != 'D'
			AND asn.mob = asnLink.loc_id(+)
		GROUP BY
			asp.part_no,
			DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid),
			RTRIM(i.item_id),
			DECODE(i.created_datetime,NULL,TRUNC(i.last_changed_datetime),
			      TRUNC(i.created_datetime)),
			TRUNC(i.created_datetime),
			TRUNC(i.created_datetime + ansi.time_to_repair_off_base);
	 
		CURSOR itemACur IS
		SELECT
			asp.part_no,
			DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
			'4' inv_type,
			RTRIM(i.item_id) item_id,
			DECODE(i.created_datetime, NULL, TRUNC(i.last_changed_datetime), TRUNC(i.created_datetime)) inv_date,
			TRUNC(i.created_datetime) repair_date,
			TRUNC(i.created_datetime + NVL(ansi.time_to_repair_off_base,0)) repair_need_date,
			SUM(NVL(i.qty,0)) inv_qty
		FROM
			ITEMSA i,
			AMD_NATIONAL_STOCK_ITEMS ansi,
			AMD_SPARE_NETWORKS asn,
			AMD_SPARE_PARTS asp,
			AMD_SPARE_NETWORKS asnLink
		WHERE
			RTRIM(asp.part_no) = RTRIM(i.part)
			AND RTRIM(i.prime) = RTRIM(ansi.prime_part_no)
			AND i.status_3 != 'I'
			AND i.status_servicable = 'N'
			AND i.status_new_order = 'N'
			AND i.status_accountable = 'Y'
			AND i.status_active = 'Y'
			AND i.status_mai = 'N'
			AND asn.loc_id = 'EY1746'
			AND asp.action_code != 'D'
			AND asn.mob = asnLink.loc_id(+)
		GROUP BY
			asp.part_no,
			DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid),
			RTRIM(i.item_id),
			DECODE(i.created_datetime, NULL, TRUNC(i.last_changed_datetime), TRUNC(i.created_datetime)),
			TRUNC(i.created_datetime),
			TRUNC(i.created_datetime + NVL(ansi.time_to_repair_off_base,0));
				
	CURSOR itemType5Cur IS	
	SELECT
		asp.part_no,
		DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
		'3' inv_type,
		o.created_datetime inv_date,
		NVL(o.qty_due,0) inv_qty,
		RTRIM(o.order_no) order_no,
		DECODE(ov.vendor_est_ret_date,NULL, o.ecd, ov.vendor_est_ret_date) repair_need_date
	FROM
		ORD1 o,
		ORDV ov,
		AMD_SPARE_NETWORKS asn,
		AMD_SPARE_PARTS asp,
		AMD_SPARE_NETWORKS asnLink
	WHERE
		RTRIM(o.order_no) = RTRIM(ov.order_no)
		AND asp.part_no  = RTRIM(o.part)
		AND o.status IN ('O', 'U')
		AND o.order_type = 'J'
		AND o.accountable_yn = 'Y'
		AND asn.loc_id = SUBSTR(o.sc,8,6)
		AND asp.action_code != 'D'
		AND asn.mob = asnLink.loc_id(+);
				
	PROCEDURE writeMsg(
				pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
				pError_location IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
				pKey1 IN VARCHAR2 := '',
				pKey2 IN VARCHAR2 := '',
				pKey3 IN VARCHAR2 := '',
				pKey4 IN VARCHAR2 := '',
				pData IN VARCHAR2 := '',
				pComments IN VARCHAR2 := '')  IS
	BEGIN
		Amd_Utils.writeMsg (
				pSourceName => 'amd_inventory',	
				pTableName  => pTableName,
				pError_location => pError_location,
				pKey1 => pKey1,
				pKey2 => pKey2,
				pKey3 => pKey3,
				pKey4 => pKey4,
				pData    => pData,
				pComments => pComments);
	END writeMsg ;
	
	PROCEDURE infoMsg(
					sqlFunction IN VARCHAR2,
					tableName IN VARCHAR2,
					pErrorLocation IN NUMBER,
					key1 IN VARCHAR2 := '',
			 		key2 IN VARCHAR2 := '',
					key3 IN VARCHAR2 := '',
					key4 IN VARCHAR2 := '',
					key5 IN VARCHAR2 := '',					
					keywordValuePairs IN VARCHAR2 := '')  IS
	BEGIN
		Amd_Utils.InsertErrorMsg (
				pLoad_no => Amd_Utils.GetLoadNo(
						pSourceName => sqlFunction,
						pTableName  => tableName),
				pData_line_no => pErrorLocation,
				pData_line    => 'amd_inventory',
				pKey_1 => key1,
				pKey_2 => key2,
				pKey_3 => key3,
				pKey_4 => key4,
				pKey_5 => key5 || ' ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ||
						   ' ' || keywordValuePairs,
				pComments => 'sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')');
	END infoMsg ;

	PROCEDURE errorMsg(
					sqlFunction IN VARCHAR2,
					tableName IN VARCHAR2,
					pErrorLocation IN NUMBER,
					key1 IN VARCHAR2 := '',
			 		key2 IN VARCHAR2 := '',
					key3 IN VARCHAR2 := '',
					key4 IN VARCHAR2 := '',
					key5 IN VARCHAR2 := '',					
					keywordValuePairs IN VARCHAR2 := '') IS
	BEGIN
		ROLLBACK;
		Amd_Utils.InsertErrorMsg (
				pLoad_no => Amd_Utils.GetLoadNo(
						pSourceName => sqlFunction,
						pTableName  => tableName),
				pData_line_no => pErrorLocation,
				pData_line    => 'amd_inventory',
				pKey_1 => key1,
				pKey_2 => key2,
				pKey_3 => key3,
				pKey_4 => key4,
				pKey_5 => key5 || ' ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ||
						   ' ' || keywordValuePairs,
				pComments => SqlFunction || '/' || TableName || ' sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')');
		COMMIT;
		RETURN ;
	END ErrorMsg;
	
	FUNCTION ErrorMsg(
					pSqlFunction IN VARCHAR2,
					pTableName IN VARCHAR2,
					pErrorLocation IN NUMBER,
					pReturn_code IN NUMBER,
					pKey_1 IN VARCHAR2,
			 		pKey_2 IN VARCHAR2 := '',
					pKey_3 IN VARCHAR2 := '',
					pKey_4 IN VARCHAR2 := '',					
					pKeywordValuePairs IN VARCHAR2 := '') RETURN NUMBER IS
	BEGIN
		ROLLBACK;
		Amd_Utils.InsertErrorMsg (
				pLoad_no => Amd_Utils.GetLoadNo(
						pSourceName => pSqlFunction,
						pTableName  => pTableName),
				pData_line_no => pErrorLocation,
				pData_line    => 'amd_inventory',
				pKey_1 => pKey_1,
				pKey_2 => pKey_2,
				pKey_3 => pKey_3,
				pKey_4 => pKey_4,
				pKey_5 => 'rc=' || TO_CHAR(pReturn_code) ||
					       ' ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ||
						   ' ' || pKeywordValuePairs,
				pComments => pSqlFunction || '/' || pTableName || ' sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')');
		COMMIT;
		RETURN pReturn_code;
	END ErrorMsg;
	

	PROCEDURE LoadGoldInventory IS

		nsnDashed      VARCHAR2(16);
		orderSid       NUMBER;

		pn          VARCHAR2(50);
		loc_sid     NUMBER;
		inv_date    DATE;
		invQty      NUMBER;

		result NUMBER ;
		cntOnHandInvs NUMBER := 0 ;
		cntInRepair   NUMBER := 0 ;
		cntOnOrder NUMBER := 0 ;
		cntInTransits NUMBER := 0 ;
		cntlnRsp  NUMBER := 0;
		
	
	
	BEGIN

		dbms_output.put_line('loadGoldInventory started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS')) ;

		loadOnHandInvs ;
		SELECT COUNT(*) INTO cntOnHandInvs FROM TMP_AMD_ON_HAND_INVS ;

		loadInRepair ;
		SELECT COUNT(*) INTO cntInRepair FROM TMP_AMD_IN_REPAIR ;

		loadOnOrder ;
		SELECT COUNT(*) INTO cntOnOrder FROM TMP_AMD_ON_ORDER ;
		
		loadInTransits ;
		SELECT COUNT(*) INTO cntInTransits FROM TMP_AMD_IN_TRANSITS ;
		
		loadRsp;
		SELECT COUNT(*) INTO cntlnRsp FROM TMP_AMD_RSP ;			

		dbms_output.put_line('loadGoldInventory ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ) ;
		dbms_output.put_line('cntOnHandInvs=' || cntOnHandInvs) ;
		dbms_output.put_line('cntInRepair=' || cntInRepair) ;
		dbms_output.put_line('cntOnOrder=' || cntOnOrder) ;
		dbms_output.put_line('cntInTransits=' || cntInTransits) ;
		dbms_output.put_line('cntInRsp=' || cntlnRsp) ;
		
		infoMsg(sqlFunction => 'end of proc',
			tableName => 'tmp_amd_spare_parts',
			pErrorLocation => 10, 
			key1 => TO_CHAR(cntOnHandInvs),
			key2 => TO_CHAR(cntInRepair),
			key3 => TO_CHAR(cntOnOrder),
			key4 => TO_CHAR(cntInTransits),
			key5 => TO_CHAR(cntlnRsp)) ;
			
	EXCEPTION
		 WHEN OTHERS THEN 
					ErrorMsg(sqlFunction => 'loadGoldInventory',
						tableName => 'inventory tables',
						pErrorLocation => 20) ; 
					dbms_output.put_line('loadGoldIntentory had an error - check amd_load_details. cntOnHandInvs=' || cntOnHandInvs || ' cntInRepair=' || cntInRepair || ' cntInTransits=' || cntInTransits) ;
				RAISE ;
	END LoadGoldInventory;
	

	PROCEDURE loadOnOrder IS
		-- Type 3 Wholesale
			   		  			
		CURSOR itemType3aCur IS
		SELECT 
	   		   RTRIM(asp.part_no) part_no,
	  		    DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
	   			invQ.inv_date inv_date,
	  			SUM(invQ.inv_qty) inv_qty,
	  			invQ.order_no order_no,
				TRUNC(invQ.receipt_date) receipt_date	  
		FROM (				
			 /*SELECT
				   RTRIM(o.part) part_no,
				   SUBSTR(sc,8,6) loc_id,
				   TRUNC(o.created_datetime) inv_date,
				   NVL(o.qty_due,0) inv_qty,
				   RTRIM(o.order_no) order_no,
				   DECODE(ecd, NULL, need_date, ecd) receipt_date
			FROM
				   ORD1 o
			WHERE
				   o.status = 'O'
				   AND o.order_type = 'M'
			UNION ALL */
			SELECT
				  RTRIM(part) part_no,
				  SUBSTR(sc,8,6) loc_id,
				  TRUNC(o.created_datetime) inv_date,
				  NVL(o.qty_due,0) inv_qty,
				  RTRIM(o.order_no) order_no,
				  DECODE(o.ecd, NULL, o.need_date, o.ecd) receipt_date
			FROM
				  ORD1 o
			WHERE
				   o.status = 'O'
				   AND o.order_type = 'C'
				   AND SUBSTR(o.order_no,1,2) IN ('FC','BA','AM','RS','SE','BR','BN','LB')) invQ,
			    AMD_SPARE_NETWORKS  asn,
				AMD_SPARE_PARTS  asp,
				AMD_SPARE_NETWORKS  asnLink
		WHERE
	 		 RTRIM(asp.part_no) = invQ.part_no
			 AND asn.loc_id = invQ.loc_id
			 AND asp.action_code != 'D'
			 AND asn.mob = asnLink.loc_id(+)
		GROUP BY 
	  	 	RTRIM(asp.part_no),
			DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid),
			invQ.inv_date,
			invQ.order_no,
			TRUNC(invQ.receipt_date);
						   
				   
			CURSOR itemType3bCur IS	   
			SELECT 
				  RTRIM(i.part) part_no,
				  DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
				  TRUNC(i.created_datetime) inv_date,
				  SUM(i.qty) inv_qty,
				  RTRIM(i.receipt_order_no) order_no,
				  DECODE(TRUNC(o.ecd), NULL, SYSDATE, TRUNC(o.ecd))  receipt_date
			FROM
				  ITEM i,
				  ORD1 o,
				  AMD_SPARE_NETWORKS  asn,
				  AMD_SPARE_PARTS  asp,
				  AMD_SPARE_NETWORKS asnLink
			WHERE
				  RTRIM(i.receipt_order_no) = RTRIM(o.order_no)
				  AND i.condition = 'B170-ATL' 
				  AND RTRIM(asp.part_no) = RTRIM(i.part)
			      AND asn.loc_id = SUBSTR(i.sc,8,6) 
			      AND asp.action_code != 'D'
				  AND asn.mob = asnLink.loc_id(+)
		    GROUP BY 
				  RTRIM(i.part),
				  DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid),
				  TRUNC(i.created_datetime),
				  RTRIM(i.receipt_order_no),
				  DECODE(TRUNC(o.ecd), NULL, SYSDATE, TRUNC(o.ecd));
				  
			
			CURSOR itemType3cCur IS
			SELECT
				 RTRIM(from_part) part_no,
				 DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
				 TRUNC(from_datetime) inv_date,
				 SUM(qty_due) inv_qty,
				 RTRIM(temp_out_id) order_no,
				DECODE(est_return_date, NULL, NULL,est_return_date) receipt_date            
			FROM
				 TMP1,
				 AMD_SPARE_NETWORKS  asn,
				 AMD_SPARE_PARTS  asp,
				 AMD_SPARE_NETWORKS asnLink
			WHERE
				  returned_voucher IS NULL
				  AND status = 'O'
				  AND tcn = 'LNI'
	 			  AND  RTRIM(asp.part_no) = RTRIM(from_part)
			 	  AND asn.loc_id = SUBSTR(from_sc,8,6)
			 	  AND asp.action_code != 'D'
				  AND asn.mob = asnLink.loc_id(+)
		GROUP BY 
	  	 	RTRIM(from_part),
			DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid),
			TRUNC(from_datetime),
			RTRIM(temp_out_id),
			est_return_date; 
			
		cntOnOrdera	  NUMBER := 0 ;
		cntOnOrderb	  NUMBER := 0;
		cntOnOrderc   NUMBER := 0;
		
	BEGIN
		dbms_output.put_line('loadOnOrder started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ) ;
		EXECUTE IMMEDIATE 'truncate table TMP_AMD_ON_ORDER' ;
		EXECUTE IMMEDIATE 'truncate table TMP_A2A_ORDER_INFO_LINE' ;
		EXECUTE IMMEDIATE 'truncate table tmp_a2a_order_info' ;
		
		<<type3aWholeSale>>
		FOR iRec3a IN itemType3aCur LOOP

			IF (iRec3a.inv_date IS NULL) THEN
				Amd_Utils.InsertErrorMsg(pLoad_no => Amd_Utils.GetLoadNo('GOLD/RAMP/ITEM','AMD_SPARE_INVS'),pKey_1 => iRec3a.part_no,pKey_2 => iRec3a.loc_sid,
						pKey_3 => 'GOLD/SPAREINV',
						pKey_4 => 'No inventory date found' );
			ELSE

				IF iRec3a.inv_qty > 0 THEN

				<<Type_3a>>
				BEGIN
					INSERT INTO TMP_AMD_ON_ORDER
					(
						part_no,
						loc_sid,
						order_date,
						order_qty,
						gold_order_number,
						action_code,
						last_update_dt,
						sched_receipt_date
					)
					VALUES
					(
						iRec3a.part_no,
						iRec3a.loc_sid,
						iRec3a.inv_date,
						iRec3a.inv_qty,
						iRec3a.order_no,
						Amd_Defaults.INSERT_ACTION,
						SYSDATE,
						iRec3a.receipt_date
					);
					cntOnOrdera := cntOnOrdera + 1 ;
				EXCEPTION
					WHEN DUP_VAL_ON_INDEX THEN
						DECLARE
							   result NUMBER := 0 ;
						BEGIN
							result := ErrorMsg(pSqlFunction => 'insert',
									pTableName => 'tmp_amd_on_order',
									pErrorLocation => 30, 
									pReturn_code => FAILURE,
									pKey_1 => iRec3a.part_no,
									pKey_2 => iRec3a.loc_sid,
									pKey_3 => iRec3a.inv_date,
									pKey_4 => iRec3a.order_no,
									pKeywordValuePairs => 'inv_qty=' || iRec3a.inv_qty) ;
						END ;
						RAISE ;
				END Type_3a;			
			END IF;
			END IF;
		END LOOP type3aWholeSale; 
	
		<<type3bWholesale>>
		FOR iRec3b IN itemType3bCur LOOP

			IF (iRec3b.inv_date IS NULL) THEN
				Amd_Utils.InsertErrorMsg(pLoad_no => Amd_Utils.GetLoadNo('GOLD/RAMP/ITEM','AMD_SPARE_INVS'),pKey_1 => iRec3b.part_no,pKey_2 => iRec3b.loc_sid,
						pKey_3 => 'GOLD/SPAREINV',
						pKey_4 => 'No inventory date found' );
			ELSE
             
				IF iRec3b.inv_qty > 0 THEN
				<<Type_3b>>
				BEGIN
					INSERT INTO TMP_AMD_ON_ORDER
					(
						part_no,
						loc_sid,
						order_date,
						order_qty,
						gold_order_number,
						action_code,
						last_update_dt,
						sched_receipt_date
					)
					VALUES
					(
						iRec3b.part_no,
						iRec3b.loc_sid,
						iRec3b.inv_date,
						iRec3b.inv_qty,
						iRec3b.order_no,
						Amd_Defaults.INSERT_ACTION,
						SYSDATE,
						iRec3b.receipt_date
					);
					cntOnOrderb := cntOnOrderb + 1 ;
				EXCEPTION
					WHEN DUP_VAL_ON_INDEX THEN
						DECLARE
							   result NUMBER := 0 ;
						BEGIN
							result := ErrorMsg(pSqlFunction => 'insert',
									pTableName => 'tmp_amd_on_order',
									pErrorLocation => 40, 
									pReturn_code => FAILURE,
									pKey_1 => iRec3b.part_no,
									pKey_2 => iRec3b.loc_sid,
									pKey_3 => iRec3b.inv_date,
									pKey_4 => iRec3b.order_no,
									pKeywordValuePairs => 'inv_qty=' || iRec3b.inv_qty) ;
						END ;
						RAISE ;
				END Type_3b;			
				END IF;
			END IF;
		END LOOP type3bWholeSale;
		
		<<type3cWholeSale>>
		FOR iRec3c IN itemType3cCur LOOP

			IF (iRec3c.inv_date IS NULL) THEN
				Amd_Utils.InsertErrorMsg(pLoad_no => Amd_Utils.GetLoadNo('GOLD/RAMP/ITEM','AMD_SPARE_INVS'),pKey_1 => iRec3c.part_no,pKey_2 => iRec3c.loc_sid,
						pKey_3 => 'GOLD/SPAREINV',
						pKey_4 => 'No inventory date found' );
			ELSE

				IF iRec3c.inv_qty > 0 THEN
				<<Type_3c>>
				BEGIN
					INSERT INTO TMP_AMD_ON_ORDER
					(
						part_no,
						loc_sid,
						order_date,
						order_qty,
						gold_order_number,
						action_code,
						last_update_dt,
						sched_receipt_date
					)
					VALUES
					(
						iRec3c.part_no,
						iRec3c.loc_sid,
						iRec3c.inv_date,
						iRec3c.inv_qty,
						iRec3c.order_no,
						Amd_Defaults.INSERT_ACTION,
						SYSDATE,
						iRec3c.receipt_date
					);
					cntOnOrderc := cntOnOrderc + 1 ;
				EXCEPTION
					WHEN DUP_VAL_ON_INDEX THEN
						DECLARE
							   result NUMBER := 0 ;
						BEGIN
							result := ErrorMsg(pSqlFunction => 'insert',
									pTableName => 'tmp_amd_on_order',
									pErrorLocation => 50, 
									pReturn_code => FAILURE,
									pKey_1 => iRec3c.part_no,
									pKey_2 => iRec3c.loc_sid,
									pKey_3 => iRec3c.inv_date,
									pKey_4 => iRec3c.order_no,
									pKeywordValuePairs => 'inv_qty=' || iRec3c.inv_qty) ;
						END ;
						RAISE ;
				END Type_3c;			
				END IF;
			END IF;
		END LOOP type3cWholeSale;  

		dbms_output.put_line('loadOnOrder ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ) ;	
		dbms_output.put_line('cntOnOrdera=' || cntOnOrdera) ;
		
	END loadOnOrder ;
	
	
	
	PROCEDURE loadInTransits IS
	BEGIN
		
		dbms_output.put_line('loadInTransits started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ) ;
		EXECUTE IMMEDIATE 'truncate table TMP_AMD_IN_TRANSITS' ; 
		EXECUTE IMMEDIATE 'truncate table TMP_A2A_IN_TRANSITS' ;
		
		-- Populate data into table amd_in_transits
		<<insertInTransits1>>
		BEGIN 
			INSERT INTO TMP_AMD_IN_TRANSITS
			(
				   to_loc_sid,
				   quantity,
				   action_code,
				   last_update_dt,
				   document_id,
				   part_no,
				   from_location,
				   in_transit_date,
				   serviceable_flag
			)
			SELECT 
				   loc_sid,
				   (NVL(m.ship_qty,0) - NVL(m.receipt_qty,0)) quantity,
				   'A',
				   SYSDATE,
				   m.document_id,
				   RTRIM(m.part),
				   m.in_tran_from,
				   TO_DATE(m.create_date),
				   DECODE(m.mils_condition,'A','Y','B','Y','C','Y','D','Y','N') mils_condition
			FROM
				MLIT m,
				AMD_SPARE_NETWORKS a
			WHERE
				 (NVL(m.ship_qty,0) - NVL(m.receipt_qty,0)) > 0 
				 AND m.in_tran_to NOT LIKE 'FE%'
				 AND (DECODE(m.in_tran_to,'FD2090','CTLATL','FB' || SUBSTR(in_tran_to,3)) = a.loc_id
				 OR DECODE(m.in_tran_to,'EY3571','CODALT','FB' || SUBSTR(in_tran_to,3)) = a.loc_id
				 OR DECODE(m.in_tran_to,'EY7739','CODCHS','FB' || SUBSTR(in_tran_to,3)) = a.loc_id
				 OR DECODE(m.in_tran_to,'EY8388','CODMCD','FB' || SUBSTR(in_tran_to,3)) = a.loc_id);
			COMMIT;
		END insertInTransits1 ;
		
		<<insertInTransits2>>
		BEGIN
			 INSERT INTO TMP_AMD_IN_TRANSITS
			 (
			  		to_loc_sid,
					quantity,
					action_code,
					last_update_dt,
					document_id,
					part_no,
					from_location,
					in_transit_date,
					serviceable_flag
			)
			SELECT
				  a.loc_sid,
				  i.qty,
				  'A',
				  SYSDATE,
				  i.item_id,
				  RTRIM(i.part),
				  SUBSTR(i.sc,8,6),
				  r.created_docdate,
				  i.status_servicable
			FROM
				ITEM i, RSV1 r, AMD_SPARE_NETWORKS a
				WHERE i.status_3 = 'I'
				AND i.condition != 'B170-ATL'
				AND i.status_servicable = 'Y'
				AND i.status_new_order = 'N'
				AND i.status_accountable = 'Y'
				AND i.status_active = 'Y'
				AND i.status_mai = 'N'
				AND NOT EXISTS (SELECT 1 FROM ITEM i2 
								    WHERE i2.status_avail = 'N' 
									AND   i2.receipt_order_no IS NULL
									AND   i2.item_id = i.item_id)
				AND r.status = 'O'
				AND i.item_id = r.item_id
				AND SUBSTR(r.to_sc,8,6) = a.loc_id
				AND i.qty IS NOT NULL;			
			COMMIT;
		END insertInTransits2 ;
		
		/*<<insertInTransits3>>
		BEGIN
			 INSERT INTO TMP_AMD_IN_TRANSITS
			 (
			  		to_loc_sid,
					quantity,
					action_code,
					last_update_dt,
					document_id,
					part_no,
					from_location,
					in_transit_date,
					serviceable_flag
			)
			SELECT
				  a.loc_sid,
				  i.qty,
				  'A',
				  SYSDATE,
				  i.item_id,
				  RTRIM(i.part),
				  SUBSTR(i.sc,8,6),
				  r.created_docdate,
				  i.status_servicable
			FROM
				ITEM i, RSV1 r, AMD_SPARE_NETWORKS a
				WHERE i.status_3 = 'I'
				AND i.condition != 'B170-ATL'
				AND i.status_servicable = 'N'
				AND i.status_new_order = 'N'
				AND i.status_accountable = 'Y'
				AND i.status_active = 'Y'
				AND i.status_mai = 'N'
				AND r.status = 'O'
				AND i.item_id = r.item_id
				AND SUBSTR(r.to_sc,8,6) = a.loc_id
				AND i.qty IS NOT NULL;
				EXCEPTION 
						  WHEN standard.DUP_VAL_ON_INDEX THEN 
						   NULL;	 -- Ignore duplicate record.		
			COMMIT;
		END insertInTransits3; */

		dbms_output.put_line('loadInTransits ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ) ;
	END loadInTransits ;
	
	
	PROCEDURE loadRsp IS
			  nsnDashed					VARCHAR2(16) := NULL;
			  RspQty  						 NUMBER := 0;
			  RspLevel					   NUMBER := 0;
			  cntRsp						  NUMBER := 0;
			  cntType1						  NUMBER := 0;
			  cntType2						  NUMBER := 0;
			  result						  NUMBER := 0;
			  
	
	BEGIN
		
		dbms_output.put_line('loadRsp started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ) ;
		EXECUTE IMMEDIATE 'truncate table TMP_AMD_RSP' ; 
		Amd_Batch_Pkg.truncateIfOld('tmp_a2a_loc_part_override') ;
		COMMIT;
		
		
		
		-- Populate data into table tmp_amd_rsp
		  /* FOR rec IN partCur LOOP
		   
		   	   	   nsnDashed := Amd_Utils.FormatNsn(rec.nsn, 'GOLD');
				   
				   --
				   -- For each part, extract inventory data from ramp and item tables.
				   --
				   FOR rRec IN rampCur (nsnDashed) LOOP
				   	   		RspQty := rRec.spram_balance + rRec.hpmsk_balance + rRec.wrm_balance + rRec.total_inaccessible_qty;
				 	   		RspLevel := rRec.spram_level+ rRec.wrm_level + rRec.hpmsk_level_qty ;
				 
				 IF RspQty > 0 THEN
				 <<insertRsp>>
				 			  BEGIN 
							  		INSERT INTO TMP_AMD_RSP
									(
									 	   part_no,
										   loc_sid,
										   rsp_inv,
										   rsp_level,
										   action_code,
										   last_update_dt
									)
									VALUES
									(
									 	  rec.part_no,
										  rRec.loc_sid,
										  RspQty,
										  RspLevel,
										  Amd_Defaults.INSERT_ACTION,
										  SYSDATE
									);
									cntType1 := cntType1 + 1;
									cntRsp := cntRsp + 1;
							EXCEPTION
									 	   WHEN	DUP_VAL_ON_INDEX THEN
										   result := ErrorMsg(pSqlFunction => 'insert',
										   		  	 						pTableName => 'tmp_amd_rsp',
																			pErrorLocation => 60,
																			pReturn_code => FAILURE,
																			pKey_1 => rec.part_no,
																			pKey_2 => rRec.loc_sid,
																			pKey_3 => nsnDashed);
											RAISE;
									END TYPE_1;
						END IF ;
					END LOOP;
			END LOOP f77PartLoop;*/
			
	-- Populate data into table tmp_amd_rsp		
	FOR rec IN partCur LOOP
		
				nsnDashed := Amd_Utils.FormatNsn(rec.nsn, 'GOLD');
				<<rspUABRampLoop>>
				FOR uRec IN rampCurFB(nsnDashed) LOOP
				
							RspQty := uRec.spram_balance + uRec.hpmsk_balance + uRec.wrm_balance ;
				 	   		RspLevel := uRec.spram_level+ uRec.wrm_level + uRec.hpmsk_level_qty ;
							
							IF RspQty > 0 OR RspLevel > 0 THEN
							   BEGIN
							   		  	INSERT INTO TMP_AMD_RSP
											   (
											   		part_no, 
													loc_sid,
										   			rsp_inv,
										  			rsp_level,
										   			action_code,
										   			last_update_dt
												)
												VALUES
												(
									 	 		 	  rec.part_no,
													  uRec.loc_sid,
										  			  RspQty,
										 			  RspLevel,
										  			   Amd_Defaults.INSERT_ACTION,
										 			    SYSDATE
									);
									cntType2 := cntType2 + 1;
									cntRsp := cntRsp + 1;
							EXCEPTION
									 	   WHEN	DUP_VAL_ON_INDEX THEN
										   result := ErrorMsg(pSqlFunction => 'insert',
										   		  	 						pTableName => 'tmp_amd_rsp',
																			pErrorLocation => 70,
																			pReturn_code => FAILURE,
																			pKey_1 => rec.part_no,
																			pKey_2 => uRec.loc_sid,
																			pKey_3 => nsnDashed);
											RAISE;
								END Type_2;
							END IF;
						END LOOP rspUABRampLoop;
				END LOOP f77PartLoop;  
			
	END loadRsp;
										  
	
	FUNCTION getSiteLocation(loc_sid IN AMD_SPARE_NETWORKS.loc_sid%TYPE) RETURN
			 AMD_SPARE_NETWORKS.loc_id%TYPE IS
			 
			 loc_id AMD_SPARE_NETWORKS.loc_id%TYPE ;
			 result NUMBER ;
	BEGIN
		SELECT loc_id INTO loc_id 
		FROM AMD_SPARE_NETWORKS
		WHERE loc_sid = getSiteLocation.loc_sid ;
		
		RETURN loc_id ;
	EXCEPTION WHEN OTHERS THEN
		result := ErrorMsg(pSqlFunction => 'select',
		pTableName => 'amd_spare_networks',
		pErrorLocation => 80 , 
		pReturn_code => FAILURE,
		pKey_1 => 'loc_sid') ;
		RAISE ;
	END getSiteLocation ;
	
	
	FUNCTION doRepairInvsSumDiff(
			 part_no IN VARCHAR2, 
			 site_location IN VARCHAR2,
			 qty_on_hand IN NUMBER, 
			 action_code IN VARCHAR2) RETURN NUMBER IS

		badActionCode EXCEPTION ;
		
		FUNCTION InsertRow RETURN NUMBER IS
	
		BEGIN
		  	<<insertAmdRepairInvsSums>> 
			DECLARE
				   PROCEDURE doUpdate IS
				   BEGIN
				   		<<getActionCode>>
						DECLARE
							   action_code AMD_IN_REPAIR.action_code%TYPE ;
							   badInsert EXCEPTION ;
						BEGIN
							 SELECT action_code 
							 INTO action_code 
							 FROM AMD_REPAIR_INVS_SUM 
							 WHERE part_no = doRepairInvsSumDiff.part_no 
							 AND site_location = doRepairInvsSumDiff.site_location ;
							 
							 IF action_code != Amd_Defaults.DELETE_ACTION THEN
							 	RAISE badInsert ;
							 END IF ;
						EXCEPTION WHEN OTHERS THEN
							errorMsg(SqlFunction => 'select',
										TableName => 'amd_repair_invs_sum',
										pErrorLocation => 90, 
										key1 => doRepairInvsSumDiff.part_no,
										key2 => doRepairInvsSumDiff.site_location);
						
						END getActionCode ;
						UPDATE AMD_REPAIR_INVS_SUM
						SET qty_on_hand = doRepairInvsSumDiff.qty_on_hand,
						action_code = Amd_Defaults.INSERT_ACTION,
						last_update_dt = SYSDATE
						WHERE part_no = doRepairInvsSumDiff.part_no AND site_location = doRepairInvsSumDiff.site_location ;
				   END doUpdate ;
			BEGIN
				 INSERT INTO AMD_REPAIR_INVS_SUM
				(
					part_no,
					site_location,
					qty_on_hand,
					action_code,
					last_update_dt
				)
				VALUES
				(
				    part_no,
					site_location,
					qty_on_hand,
					Amd_Defaults.INSERT_ACTION,
					SYSDATE
				);
				
				EXCEPTION
						WHEN standard.DUP_VAL_ON_INDEX THEN
							 doUpdate ;
						WHEN OTHERS THEN
							RETURN ErrorMsg(pSqlFunction => 'insert',
										pTableName => 'amd_repair_invs_sum',
										pErrorLocation => 100, 
										pReturn_code => FAILURE,
										pKey_1 => part_no,
										pKey_2 => site_location ) ;
		     END insertAmdRepairInvs ;
			 
			A2a_Pkg.insertRepairInvInfo(part_no, site_location, qty_on_hand, Amd_Defaults.INSERT_ACTION);
			 
			 RETURN SUCCESS;
		END InsertRow ;
		
		FUNCTION UpdateRow RETURN NUMBER IS
			-- get the detail for the summarized inv_qty
			result NUMBER ;
			 
		BEGIN
			<<updateAmdRepairInvs>> 
			BEGIN
				UPDATE AMD_REPAIR_INVS_SUM SET
		            qty_on_hand 	   = doRepairInvsSumDiff.qty_on_hand,
					action_code    = Amd_Defaults.UPDATE_ACTION,
					last_update_dt = SYSDATE
				WHERE part_no  = doRepairInvsSumDiff.part_no
				      AND site_location  = doRepairInvsSumDiff.site_location ;
				EXCEPTION
						WHEN OTHERS THEN
							RETURN ErrorMsg(pSqlFunction => 'update',
										pTableName => 'amd_repair_invs_sum',
										pErrorLocation => 110, 
										pReturn_code => FAILURE,
										pKey_1 => part_no,
										pKey_2 => site_location) ;
			END updateAmdRepairInvs ;
			
			
			A2a_Pkg.insertRepairInvInfo(part_no,site_location,qty_on_hand, Amd_Defaults.UPDATE_ACTION) ;
			RETURN SUCCESS;
	
		END UpdateRow ;
	
		FUNCTION DeleteRow RETURN NUMBER IS
		BEGIN
		     
			<<updateAmdRepairInvs>> -- logically delete all records for the part_no and loc_sid
			BEGIN
			 UPDATE AMD_REPAIR_INVS_SUM SET
				action_code    = Amd_Defaults.DELETE_ACTION,
				last_update_dt = SYSDATE
			WHERE    part_no  = doRepairInvsSumDiff.part_no
				 AND site_location  = doRepairInvsSumDiff.site_location ;
			
			
			EXCEPTION
					WHEN OTHERS THEN
						RETURN ErrorMsg(pSqlFunction => 'update',
									pTableName => 'amd_repair_invs_sum',
									pErrorLocation => 120, 
									pReturn_code => FAILURE,
									pKey_1 => part_no,
									pKey_2 => site_location) ;
			 END updateAmdRepairInvs;
			 
			
			A2a_Pkg.insertRepairInvInfo(part_no, site_location,0, Amd_Defaults.DELETE_ACTION) ;
			RETURN SUCCESS;
			
		END DeleteRow ;
	BEGIN
		 IF action_code = Amd_Defaults.INSERT_ACTION THEN
		 	RETURN insertRow ;
		ELSIF action_code = Amd_Defaults.UPDATE_ACTION THEN
			RETURN updateRow ;
		ELSIF action_code = Amd_Defaults.DELETE_ACTION THEN
			RETURN deleteRow ;
		ELSE
			errorMsg(action_code,'amd_repair_invs_sum',68,part_no, site_location) ;
			RAISE badActionCode ;
			RETURN FAILURE ;
		END IF ;
	END doRepairInvsSumDiff ;
		
	
	/* amd_in_repair diff functions */
	FUNCTION InsertRow(
							PART_NO             IN VARCHAR2,
  							LOC_SID             IN NUMBER,
							REPAIR_DATE		  IN DATE,
  							REPAIR_QTY          IN NUMBER,
  							ORDER_NO		  IN VARCHAR2,
							REPAIR_NEED_DATE  IN DATE) RETURN NUMBER IS
			
	BEGIN
		 <<insertAmdInRepair>>
		 DECLARE
		 		PROCEDURE doUpdate IS
				BEGIN
					 <<getActionCode>>
					 DECLARE
					 		action_code AMD_IN_REPAIR.action_code%TYPE ;
							badInsert EXCEPTION ;
					 BEGIN
					 	  SELECT action_code 
						  INTO action_code 
						  FROM AMD_IN_REPAIR 
						  WHERE part_no = insertRow.part_no 
						  AND loc_sid = insertRow.loc_sid 
						  AND order_no = insertRow.order_no ;
						  IF action_code != Amd_Defaults.DELETE_ACTION THEN
						  	 RAISE badInsert ;
						  END IF ;
					 EXCEPTION WHEN OTHERS THEN 
						errorMsg(sqlFunction => 'select',
							     tableName => 'amd_in_repair',
								 pErrorLocation => 130, 
								 key1 => part_no,
								 key2 => loc_sid,
								 key3 => order_no);
					 END getActionCode ;
					 
					 UPDATE AMD_IN_REPAIR
					 SET
					 		     part_no = insertRow.part_no,
					 			 loc_sid = insertRow.loc_sid, 
					  			repair_date = insertRow.repair_date,
					 			repair_qty = insertRow.repair_qty,
					 			order_no= insertRow.order_no,
					 			repair_need_date = insertRow.repair_need_date,
								 action_code = Amd_Defaults.INSERT_ACTION,
								  last_update_dt = SYSDATE
					 WHERE part_no = insertRow.part_no 
					 AND loc_sid = insertRow.loc_sid 
					 AND order_no = insertRow.order_no ;
				END doUpdate ;
		 BEGIN
			 INSERT INTO AMD_IN_REPAIR
			(
				part_no,
				loc_sid,
				repair_date,
				repair_qty,
				order_no,
				repair_need_date,
				action_code,
				last_update_dt
			)
			VALUES
			(
				part_no,
				loc_sid,
				repair_date,
				repair_qty,
				order_no,
				repair_need_date,
				Amd_Defaults.INSERT_ACTION,
				SYSDATE
			);
			
			EXCEPTION
					WHEN standard.DUP_VAL_ON_INDEX THEN
						 doUpdate ;
					WHEN OTHERS THEN
						RETURN ErrorMsg(pSqlFunction => 'insert',
									pTableName => 'amd_in_repair',
									pErrorLocation => 140, 
									pReturn_code => FAILURE,
									pKey_1 => part_no,
									pKey_2 => loc_sid,
									pKey_3 => order_no);
	     END insertAmdInRepair ;
		 
		 A2a_Pkg.insertRepairInfo(part_no,loc_sid,order_no,repair_date,A2a_Pkg.OPEN_STATUS,repair_qty,
              repair_need_date, Amd_Defaults.INSERT_ACTION) ;		 																							
		 
		 RETURN SUCCESS;
	END InsertRow ;

	FUNCTION UpdateRow(
							PART_NO             IN VARCHAR2,
  							LOC_SID             IN NUMBER,
							REPAIR_DATE		  IN DATE,
							REPAIR_QTY		  IN NUMBER,
  							ORDER_NO		  IN VARCHAR2,
							REPAIR_NEED_DATE  IN DATE) RETURN NUMBER IS
	BEGIN
		<<updateAmdInRepair>>  
		BEGIN
			UPDATE AMD_IN_REPAIR SET
					repair_date		=	UpdateRow.repair_date,
					repair_qty 		= 	UpdateRow.repair_qty,
					repair_need_date =  UpdateRow.repair_need_date,
					action_code    = Amd_Defaults.UPDATE_ACTION,
					last_update_dt = SYSDATE
			WHERE part_no = part_no
			AND loc_sid = UpdateRow.loc_sid
			AND order_no = UpdateRow.order_no;

			EXCEPTION
					WHEN OTHERS THEN
						RETURN ErrorMsg(pSqlFunction => 'update',
									pTableName => 'amd_in_repair',
									pErrorLocation => 150, 
									pReturn_code => FAILURE,
									pKey_1 => part_no,
									pKey_2 => loc_sid,
									pKey_3 => order_no);
		END updateAmdInRepair;
		
		 A2a_Pkg.insertRepairInfo(part_no,loc_sid,order_no,repair_date,A2a_Pkg.OPEN_STATUS,repair_qty,
               repair_need_date,Amd_Defaults.UPDATE_ACTION) ;		 																							
		RETURN SUCCESS ;
	END UpdateRow ;

	FUNCTION inRepairDeleteRow(
				 		   			PART_NO	  IN VARCHAR2,
									LOC_SID	  IN NUMBER,
									ORDER_NO  IN VARCHAR2) RETURN NUMBER IS
			repair_qty AMD_IN_REPAIR.repair_qty%TYPE;
			repair_date AMD_IN_REPAIR.repair_date%TYPE;
			repair_need_date AMD_IN_REPAIR. repair_need_date%TYPE ;
	BEGIN
		 <<updateAmdInRepair>>		 
		 BEGIN
			 UPDATE AMD_IN_REPAIR SET
				action_code    = Amd_Defaults.DELETE_ACTION,
				last_update_dt = SYSDATE
			WHERE PART_NO = inRepairDeleteRow.part_no
			AND LOC_SID = inRepairDeleteRow.LOC_SID
			AND ORDER_NO = inRepairDeleteRow.ORDER_NO ;
	
			EXCEPTION
					WHEN OTHERS THEN
						RETURN ErrorMsg(pSqlFunction => 'update',
									pTableName => 'amd_in_repair',
									pErrorLocation => 160, 
									pReturn_code => FAILURE,
									pKey_1 => part_no,
									pKey_2 => loc_sid,
									pKey_3 => order_no);
		 END updateAmdInRepair;
		 <<selectAmdInRepair>>
		 BEGIN
			SELECT repair_qty, repair_date, repair_need_date  INTO repair_qty, repair_date, repair_need_date
			FROM AMD_IN_REPAIR
			WHERE part_no = inRepairDeleteRow.part_no
			AND loc_sid = inRepairDeleteRow.loc_sid
			AND order_no = inRepairDeleteRow.order_no;
	
			EXCEPTION
					WHEN OTHERS THEN
						RETURN ErrorMsg(pSqlFunction => 'select',
									pTableName => 'amd_in_repair',
									pErrorLocation => 170, 
									pReturn_code => FAILURE,
									pKey_1 => part_no,
									pKey_2 => loc_sid,
									pKey_3 => order_no);
		 END selectAmdInRepair; 
		 
		 A2a_Pkg.insertRepairInfo(part_no,loc_sid,order_no,repair_date,A2a_Pkg.OPEN_STATUS,repair_qty,
               repair_need_date,Amd_Defaults.DELETE_ACTION) ;		 																							
		RETURN SUCCESS ;
	END inRepairDeleteRow ;


	/* amd_on_order diff functions */
	FUNCTION insertOnOrderRow(
							PART_NO             IN VARCHAR2,
  							LOC_SID             IN NUMBER,
							ORDER_DATE          IN DATE,
  							ORDER_QTY           IN NUMBER,
  							GOLD_ORDER_NUMBER   IN VARCHAR2,
							SCHED_RECEIPT_DATE IN  DATE) RETURN NUMBER IS
	
 		-- site_location TMP_A2A_ORDER_INFO_LINE.SITE_LOCATION%TYPE := getSiteLocation(loc_sid) ;
		
		PROCEDURE doUpdate IS
		BEGIN
			 <<getActionCode>>
			 DECLARE
				  action_code AMD_ON_ORDER.action_code%TYPE ;
				  badInsert EXCEPTION ;
			 BEGIN
			 	  SELECT action_code INTO action_code FROM AMD_ON_ORDER 
				  WHERE gold_order_number = insertOnOrderRow.gold_order_number
				  AND order_date = insertOnOrderRow.order_date ;
				  
				  IF action_code != Amd_Defaults.DELETE_ACTION THEN
				  	 RAISE badInsert ;
				  END IF ;
			 EXCEPTION
			 		  WHEN OTHERS THEN				
						errorMsg(sqlFunction => 'select',
								 tableName => 'amd_on_order',
								 pErrorLocation => 180,
								 key1 => gold_order_number,
								 key2 => TO_CHAR(order_date,'MM/DD/YYYY')) ;
					  	RAISE ;
			 END getActionCode ;
			 
			 UPDATE AMD_ON_ORDER
				 SET part_no = insertOnOrderRow.part_no,
				 loc_sid = insertOnOrderRow.loc_sid,
				 order_qty = insertOnOrderRow.order_qty,
				 action_code = Amd_Defaults.INSERT_ACTION,
				 last_update_dt = SYSDATE
			 WHERE gold_order_number = insertOnOrderRow.gold_order_number
			 AND order_date = insertOnOrderRow.order_date ;
	    EXCEPTION WHEN OTHERS THEN
				errorMsg(sqlFunction => 'update',
						 tableName => 'amd_on_order',
						 pErrorLocation => 190,
						 key1 => gold_order_number,
						 key2 => TO_CHAR(order_date,'MM/DD/YYYY')) ;
			 
		END doUpdate ;
		
	BEGIN
		 <<insertAmdOnOrder>>
		 BEGIN
			 INSERT INTO AMD_ON_ORDER
			(
				part_no,
				loc_sid,
				order_date,
				order_qty,
				gold_order_number,
				action_code,
				last_update_dt,
				sched_receipt_date
			)
			VALUES
			(
				part_no,
				loc_sid,
				order_date,
				order_qty,
				gold_order_number,
				Amd_Defaults.INSERT_ACTION,
				SYSDATE,
				sched_receipt_date
			);
			
			EXCEPTION
					WHEN standard.DUP_VAL_ON_INDEX THEN
						 doUpdate ;
					WHEN OTHERS THEN
						RETURN ErrorMsg(pSqlFunction => 'insert',
									pTableName => 'amd_on_order',
									pErrorLocation => 200, 
									pReturn_code => FAILURE,
									pKey_1 => gold_order_number,
									pKey_2 => TO_CHAR(order_date,'MM/DD/YYYY HH:MM:SS'));
	     END insertAmdOnOrder ;
		 
		 A2a_Pkg.insertTmpA2AOrderInfo(insertOnOrderRow.gold_order_number,
			  insertOnOrderRow.loc_sid,
			  insertOnOrderRow.order_date,
			  insertOnOrderRow.part_no,
	 		  insertOnOrderRow.order_qty,
			  insertOnOrderRow.sched_receipt_date,
			  Amd_Defaults.INSERT_ACTION) ;
		 
		 RETURN SUCCESS ;
	END insertOnOrderRow ;

	FUNCTION updateOnOrderRow(
							PART_NO             IN VARCHAR2,
  							LOC_SID             IN NUMBER,
							ORDER_DATE          IN DATE,
  							ORDER_QTY           IN NUMBER,
  							GOLD_ORDER_NUMBER   IN VARCHAR2,
							SCHED_RECEIPT_DATE IN  DATE) RETURN NUMBER IS
							
	   -- site_location TMP_A2A_ORDER_INFO_LINE.site_location%TYPE := getSiteLocation(loc_sid) ;
	   
	BEGIN
		<<updateAmdOnOrder>> 
		BEGIN
			UPDATE AMD_ON_ORDER SET
				part_no        		= 	UpdateOnOrderRow.part_no,
				loc_sid    			= 	UpdateOnOrderRow.loc_sid,
	            order_qty 			= 	UpdateOnOrderRow.order_qty,
				action_code         = Amd_Defaults.UPDATE_ACTION,
				last_update_dt      = SYSDATE
			WHERE gold_order_number = UpdateOnOrderRow.gold_order_number
			AND order_date = UpdateOnOrderRow.order_date;
	
			EXCEPTION
					WHEN OTHERS THEN
						RETURN ErrorMsg(pSqlFunction => 'update',
									pTableName => 'amd_on_order',
									pErrorLocation => 210, 
									pReturn_code => FAILURE,
									pKey_1 => UpdateOnOrderRow.gold_order_number,
									pKey_2 => TO_CHAR(UpdateOnOrderRow.order_date,'MM/DD/YYYY HH:MM:SS'));
		END updateAmdOnOrder;
		
		A2a_Pkg.insertTmpA2AOrderInfo(updateOnOrderRow.gold_order_number,
			  updateOnOrderRow.loc_sid,
			  updateOnOrderRow.order_date,
			  updateOnOrderRow.part_no,
	 		  updateOnOrderRow.order_qty,
			  updateOnOrderRow.sched_receipt_date,
			  Amd_Defaults.UPDATE_ACTION) ;

		
		RETURN SUCCESS ;
	END updateOnOrderRow ;

	FUNCTION deleterow(part_no IN VARCHAR2, loc_sid IN NUMBER, gold_order_number IN VARCHAR2, order_date IN DATE) RETURN NUMBER IS
	BEGIN
		 <<updateAmdOnOrder>>
		 BEGIN
			 UPDATE AMD_ON_ORDER SET
				action_code    = Amd_Defaults.DELETE_ACTION,
				last_update_dt = SYSDATE
			WHERE GOLD_ORDER_NUMBER = DeleteRow.gold_order_number
			AND order_date = DeleteRow.order_date ;
	
			EXCEPTION WHEN OTHERS THEN
						RETURN ErrorMsg(pSqlFunction => 'update',
									pTableName => 'amd_on_order',
									pErrorLocation => 220, 
									pReturn_code => FAILURE,
									pKey_1 => gold_order_number,
									pKey_2 => TO_CHAR(order_date,'MM/DD/YYYY HH:MM:SS'));
		 END updateAmdOnOrder;
		
				
		A2a_Pkg.insertTmpA2AOrderInfo(deleteRow.gold_order_number,
			  deleteRow.loc_sid,
			  deleteRow.order_date,
			  deleteRow.part_no,
			  0,
			  SYSDATE,
			  Amd_Defaults.DELETE_ACTION) ;
		
		RETURN SUCCESS ;
	END DeleteRow ;
	
	FUNCTION doOnHandInvsSumDiff(
			 part_no IN VARCHAR2, 
			 spo_location IN VARCHAR2,
			 qty_on_hand IN NUMBER, 
			 action_code IN VARCHAR2) RETURN NUMBER IS

		badActionCode EXCEPTION ;
		
		FUNCTION InsertRow RETURN NUMBER IS
	
		BEGIN
		  	<<insertAmdOnHandInvsSums>> 
			DECLARE
				   PROCEDURE doUpdate IS
				   BEGIN
				   		<<getActionCode>>
						DECLARE
							   action_code AMD_ON_HAND_INVS.action_code%TYPE ;
							   badInsert EXCEPTION ;
						BEGIN
							 SELECT action_code 
							 INTO action_code 
							 FROM AMD_ON_HAND_INVS_SUM 
							 WHERE part_no = doOnHandInvsSumDiff.part_no 
							 AND spo_location = doOnHandInvsSumDiff.spo_location ;
							 
							 IF action_code != Amd_Defaults.DELETE_ACTION THEN
							 	RAISE badInsert ;
							 END IF ;
						EXCEPTION WHEN OTHERS THEN
							errorMsg(SqlFunction => 'select',
										TableName => 'amd_on_hand_invs_sum',
										pErrorLocation => 230, 
										key1 => doOnHandInvsSumDiff.part_no,
										key2 => doOnHandInvsSumDiff.spo_location);
						
						END getActionCode ;
						UPDATE AMD_ON_HAND_INVS_SUM
						SET qty_on_hand = doOnHandInvsSumDiff.qty_on_hand,
						action_code = Amd_Defaults.INSERT_ACTION,
						last_update_dt = SYSDATE
						WHERE part_no = doOnHandInvsSumDiff.part_no 
						AND spo_location = doOnHandInvsSumDiff.spo_location ;
				   END doUpdate ;
			BEGIN
				 INSERT INTO AMD_ON_HAND_INVS_SUM
				(
					part_no,
					spo_location,
					qty_on_hand,
					action_code,
					last_update_dt
				)
				VALUES
				(
				    part_no,
					spo_location,
					qty_on_hand,
					Amd_Defaults.INSERT_ACTION,
					SYSDATE
				);
				
				EXCEPTION
						WHEN standard.DUP_VAL_ON_INDEX THEN
							 doUpdate ;
						WHEN OTHERS THEN
							RETURN ErrorMsg(pSqlFunction => 'insert',
										pTableName => 'amd_on_hand_invs_sum',
										pErrorLocation => 240, 
										pReturn_code => FAILURE,
										pKey_1 => part_no,
										pKey_2 => spo_location ) ;
		     END insertAmdOnHandInvs ;
			 				 
			 A2a_Pkg.insertInvInfo(part_no, spo_location,qty_on_hand, Amd_Defaults.INSERT_ACTION) ;
			 
	         RETURN SUCCESS ;
		END InsertRow ;
	
		FUNCTION UpdateRow RETURN NUMBER IS
			-- get the detail for the summarized inv_qty
			result NUMBER ;
			 
		BEGIN
			<<updateAmdOnHandInvs>> 
			BEGIN
				UPDATE AMD_ON_HAND_INVS_SUM SET
		            qty_on_hand 	   = doOnHandInvsSumDiff.qty_on_hand,
					action_code    = Amd_Defaults.UPDATE_ACTION,
					last_update_dt = SYSDATE
				WHERE part_no  = doOnHandInvsSumDiff.part_no
				      AND spo_location  = doOnHandInvsSumDiff.spo_location ;
				EXCEPTION
						WHEN OTHERS THEN
							RETURN ErrorMsg(pSqlFunction => 'update',
										pTableName => 'amd_on_hand_invs_sum',
										pErrorLocation => 250, 
										pReturn_code => FAILURE,
										pKey_1 => part_no,
										pKey_2 => spo_location) ;
			END updateAmdOnHandInvs ;
			
			
			A2a_Pkg.insertInvInfo(part_no,spo_location,qty_on_hand, Amd_Defaults.UPDATE_ACTION) ;
			RETURN SUCCESS;
	
		END UpdateRow ;
	
		FUNCTION DeleteRow RETURN NUMBER IS
		BEGIN
		     
			<<updateAmdOnHandInvs>> -- logically delete all records for the part_no and loc_sid
			BEGIN
			 UPDATE AMD_ON_HAND_INVS_SUM SET
				action_code    = Amd_Defaults.DELETE_ACTION,
				last_update_dt = SYSDATE
			WHERE    part_no  = doOnHandInvsSumDiff.part_no
				 AND spo_location  = doOnHandInvsSumDiff.spo_location ;
			
			
			EXCEPTION
					WHEN OTHERS THEN
						RETURN ErrorMsg(pSqlFunction => 'update',
									pTableName => 'amd_on_hand_invs_sum',
									pErrorLocation => 260, 
									pReturn_code => FAILURE,
									pKey_1 => part_no,
									pKey_2 => spo_location) ;
			 END updateAmdOnHandInvs;
			 
			
			A2a_Pkg.insertInvInfo(part_no, spo_location,0, Amd_Defaults.DELETE_ACTION) ;
			RETURN SUCCESS;
			
		END DeleteRow ;
	BEGIN
		 IF action_code = Amd_Defaults.INSERT_ACTION THEN
		 	RETURN insertRow ;
		ELSIF action_code = Amd_Defaults.UPDATE_ACTION THEN
			RETURN updateRow ;
		ELSIF action_code = Amd_Defaults.DELETE_ACTION THEN
			RETURN deleteRow ;
		ELSE
			errorMsg(action_code,'amd_on_hand_invs_sum',330,part_no, spo_location) ;
			RAISE badActionCode ;
			RETURN FAILURE ;
		END IF ;
	END doOnHandInvsSumDiff ;
	
		/* amd_on_hand_invs diff functions */
	FUNCTION InsertRow(
			 		   		 part_no        IN VARCHAR2,
  							 loc_sid        IN NUMBER,
  							 inv_qty        IN NUMBER) RETURN NUMBER IS
		

	BEGIN
	  	<<insertAmdOnHandInvs>> 
		DECLARE
			   PROCEDURE doUpdate IS
			   BEGIN
			   		<<getActionCode>>
					DECLARE
						   action_code AMD_ON_HAND_INVS.action_code%TYPE ;
						   badInsert EXCEPTION ;
					BEGIN
						 SELECT action_code INTO action_code FROM AMD_ON_HAND_INVS WHERE part_no = insertRow.part_no AND loc_sid = insertRow.loc_sid ;
						 IF action_code != Amd_Defaults.DELETE_ACTION THEN
						 	RAISE badInsert ;
						 END IF ;
					EXCEPTION WHEN OTHERS THEN
						errorMsg(SqlFunction => 'select',
									TableName => 'amd_on_hand_invs',
									pErrorLocation => 270, 
									key1 => insertRow.part_no,
									key2 => insertRow.loc_sid);
					
					END getActionCode ;
					UPDATE AMD_ON_HAND_INVS
					SET inv_qty = insertRow.inv_qty,
					action_code = Amd_Defaults.INSERT_ACTION,
					last_update_dt = SYSDATE
					WHERE part_no = insertRow.part_no AND loc_sid = insertRow.loc_sid ;
			   END doUpdate ;
		BEGIN
			 INSERT INTO AMD_ON_HAND_INVS
			(
				part_no,
				loc_sid,
				inv_qty,
				action_code,
				last_update_dt
			)
			VALUES
			(
			    part_no,
				InsertRow.loc_sid,
				inv_qty,
				Amd_Defaults.INSERT_ACTION,
				SYSDATE
			);
			
			EXCEPTION
					WHEN standard.DUP_VAL_ON_INDEX THEN
						 doUpdate ;
					WHEN OTHERS THEN
						RETURN ErrorMsg(pSqlFunction => 'insert',
									pTableName => 'amd_on_hand_invs',
									pErrorLocation => 280, 
									pReturn_code => FAILURE,
									pKey_1 => part_no,
									pKey_2 => TO_CHAR(InsertRow.loc_sid) ) ;
	     END insertAmdOnHandInvs ;
		 				 
		 
         RETURN SUCCESS ;
	END InsertRow ;

	FUNCTION UpdateRow(
			 		   		 part_no         IN VARCHAR2,
  							 loc_sid         IN NUMBER,
  							 inv_qty         IN NUMBER) RETURN NUMBER IS                       
		-- get the detail for the summarized inv_qty
		result NUMBER ;
		 
	BEGIN
		<<updateAmdOnHandInvs>> 
		BEGIN
			UPDATE AMD_ON_HAND_INVS SET
	            inv_qty 	   = UpdateRow.inv_qty,
				action_code    = Amd_Defaults.UPDATE_ACTION,
				last_update_dt = SYSDATE
			WHERE part_no  = UpdateRow.part_no
			      AND loc_sid  = UpdateRow.loc_sid ;
			EXCEPTION
					WHEN OTHERS THEN
						RETURN ErrorMsg(pSqlFunction => 'update',
									pTableName => 'amd_on_hand_invs',
									pErrorLocation => 290, 
									pReturn_code => FAILURE,
									pKey_1 => part_no,
									pKey_2 => TO_CHAR(loc_sid)) ;
		END updateAmdOnHandInvs ;
		
		
		RETURN SUCCESS;

	END UpdateRow ;

	FUNCTION DeleteRow(
			 		   		 part_no         IN VARCHAR2,
  							 loc_sid         IN NUMBER) RETURN NUMBER IS
	BEGIN
	     
		<<updateAmdOnHandInvs>> -- logically delete all records for the part_no and loc_sid
		BEGIN
		 UPDATE AMD_ON_HAND_INVS SET
			action_code    = Amd_Defaults.DELETE_ACTION,
			last_update_dt = SYSDATE
		WHERE    part_no  = DeleteRow.part_no
			 AND loc_sid  = DeleteRow.loc_sid ;
		
		
		EXCEPTION
				WHEN OTHERS THEN
					RETURN ErrorMsg(pSqlFunction => 'update',
								pTableName => 'amd_on_hand_invs',
								pErrorLocation => 300, 
								pReturn_code => FAILURE,
								pKey_1 => part_no,
								pKey_2 => TO_CHAR(loc_sid)) ;
		 END updateAmdOnHandInvs;
		 
		
		RETURN SUCCESS;
		
	END DeleteRow ;	
	
	/*amd_rsp diff functions */
	
	FUNCTION RspInsertRow(		 
			 				   	 	part_no		IN VARCHAR2,
									loc_sid		IN NUMBER,
									rsp_inv		IN NUMBER,
									rsp_level	   IN NUMBER) RETURN NUMBER IS
									
						PROCEDURE doUpdate IS	
						BEGIN
							 	  <<getActionCode>>
							  	  DECLARE
						   		  		 		   action_code AMD_RSP.action_code%TYPE;
								  				   badInsert EXCEPTION;
								  BEGIN
								  	   			   SELECT action_code INTO action_code 
												   FROM AMD_RSP 
								 				   WHERE part_no = RspInsertRow.part_no 
								 				   AND loc_sid = RspInsertRow.loc_sid ;
															   
														 IF action_code != Amd_Defaults.DELETE_ACTION THEN
								 						 	RAISE badInsert ;
														 END IF ;
							   					
								  EXCEPTION 
								  						 	 WHEN OTHERS THEN
									  	   		  	  		 	  		 errorMsg(SqlFunction => 'select',
										   					 			 TableName => 'amd_rsp',
																		  pErrorLocation => 310,
																		  key1 => RspInsertRow.part_no,
																		  key2 => RspInsertRow.loc_sid );
															RAISE ;
								  END getActionCode ;
													
								  UPDATE AMD_RSP
								  		 		SET rsp_inv = RspInsertRow.rsp_inv,
									  			rsp_level = RspInsertRow.rsp_level,
									  			action_code = Amd_Defaults.INSERT_ACTION,
									  			last_update_dt = SYSDATE
												WHERE part_no = RspInsertRow.part_no 
												AND loc_sid = RspInsertRow.loc_sid ;
								  EXCEPTION WHEN OTHERS THEN
											  	   		  	  					   errorMsg(sqlFunction => 'update',
																				   tableName => 'amd_rsp',
																				   pErrorLocation => 320,
																				   key1 => RspInsertRow.part_no,
																				   key2 => RspInsertRow.loc_sid );																			   
							
						END doUpdate ;
	
				 		BEGIN
							 		 <<insertAmdRsp>>
									 BEGIN
			 	 	  				 	  			 INSERT INTO AMD_RSP
					  								 (	  
					  	  							 	  part_no,
					  	 								  loc_sid,
					 	  								  rsp_inv,
					  	  								  rsp_level,
					  	  								  action_code,
					  	  								  last_update_dt
													 )
													 VALUES
					 								 (
				 	  	   							  	   part_no,
					  	   								   RspInsertRow.loc_sid,
					  	   								   rsp_inv,
					  	   								   rsp_level,
					  	   								   Amd_Defaults.INSERT_ACTION,
					  	   								   SYSDATE
													  );
				 
		 		 									 EXCEPTION 
				 		   	 					 	 		   WHEN standard.DUP_VAL_ON_INDEX THEN
												 	  						doUpdate ;
																WHEN OTHERS THEN
													 				 			RETURN ErrorMsg(pSqlFunction => 'insert',
																				pTableName => 'amd_rsp',
																				pErrorLocation => 330,
																				pReturn_code => FAILURE,
																				pKey_1 => part_no,
																				pkey_2 => TO_CHAR(RspInsertRow.loc_sid)) ;
															
									 END insertAmdRsp;											
									RETURN SUCCESS;
				        END RspInsertRow;
						
		
						FUNCTION RspUpdateRow(
				 		   	   	 							part_no								   IN VARCHAR2,
						   									loc_sid								   IN NUMBER,
						   									rsp_inv								   IN NUMBER,
						  									rsp_level							 IN NUMBER) RETURN NUMBER IS
															 
								result  NUMBER ;
					
						BEGIN
					 			<<updateAmdRsp>>
								BEGIN
									 			UPDATE AMD_RSP SET
													   		   rsp_inv		= RspUpdateRow.rsp_inv,
															   rsp_level  = RspUpdateRow.rsp_level,
															   action_code = Amd_Defaults.UPDATE_ACTION,
															   last_update_dt = SYSDATE
												WHERE		   
															   part_no = RspUpdateRow.part_no
															   AND loc_sid = RspUpdateRow.loc_sid ;
												EXCEPTION
														 	   WHEN OTHERS THEN
															   			   RETURN ErrorMsg(pSqlFunction => 'update',
																		   		  						pTableName => 'amd_rsp',
																										pErrorLocation => 340,
																										pReturn_code => FAILURE,
																										pKey_1 => RspUpdateRow.part_no,
																										pKey_2 => TO_CHAR(RspUpdateRow.loc_sid));
								END updateAmdRsp ;
								RETURN SUCCESS;
						END RspUpdateRow ;
		
						FUNCTION RspDeleteRow(
				 		   				   	   	  					part_no			IN VARCHAR2,
																	loc_sid			IN NUMBER) RETURN NUMBER IS
						BEGIN
							 		<<updateAmdRsp>> -- logically delete all records for the part_no and loc_sid
									BEGIN
										 UPDATE AMD_RSP SET
										 		action_code = Amd_Defaults.DELETE_ACTION,
												last_update_dt = SYSDATE
										WHERE
											 	part_no = RspDeleteRow.part_no
												AND loc_sid = RspDeleteRow.loc_sid ;
												
								        EXCEPTION 
												  			  			WHEN OTHERS THEN
																			 			RETURN ErrorMsg(pSqlFunction => 'update',
																							   						pTableName => 'amd_rsp',
																													pErrorLocation => 350,
																													pReturn_code => FAILURE,
																													pKey_1 => part_no,
																													pKey_2 => TO_CHAR(loc_sid)) ;
									END updateAmdRsp ;									
									RETURN SUCCESS ;
					    END RspDeleteRow ;
																											
	/* amd_rsp_sum diff functions */
	
	FUNCTION doRspSumDiff (
			 part_no IN VARCHAR2, 
			 rsp_location IN VARCHAR2,
			 qty_on_hand IN NUMBER, 
			 rsp_level	 	IN NUMBER,
			 action_code IN VARCHAR2) RETURN NUMBER IS

		badActionCode EXCEPTION ;
		
		PROCEDURE InsertRow IS
		
				   PROCEDURE doUpdate IS
							   action_code AMD_RSP_SUM.action_code%TYPE ;
							   badInsert EXCEPTION ;
				   BEGIN
				   		<<getActionCode>>
						BEGIN
							 SELECT action_code 
							 INTO action_code 
							 FROM AMD_RSP_SUM 
							 WHERE part_no = doRspSumDiff.part_no 
							 AND rsp_location = doRspSumDiff.rsp_location ;
							 
							 IF action_code != Amd_Defaults.DELETE_ACTION THEN
							 	RAISE badInsert ;
							 END IF ;
						EXCEPTION WHEN OTHERS THEN
							errorMsg(SqlFunction => 'select',
										TableName => 'amd_rsp_sum',
										pErrorLocation => 360, 
										key1 => doRspSumDiff.part_no,
										key2 => doRspSumDiff.rsp_location);
										RAISE ;						
						END getActionCode ;
						
						UPDATE AMD_RSP_SUM
						SET qty_on_hand = doRspSumDiff.qty_on_hand,
							rsp_level = doRspSumDiff.rsp_level,
							action_code = Amd_Defaults.INSERT_ACTION,
							last_update_dt = SYSDATE
						WHERE part_no = doRspSumDiff.part_no AND rsp_location = doRspSumDiff.rsp_location ;
						
				   END doUpdate ;
				   
		BEGIN
		
					  <<insertAmdRspSum>>
					   BEGIN
							 INSERT INTO AMD_RSP_SUM
							(
								part_no,
								rsp_location,
								qty_on_hand,
								rsp_level,
								action_code,
								last_update_dt
							)
							VALUES
							(
							    part_no,
								rsp_location,
								qty_on_hand,
								rsp_level,
								Amd_Defaults.INSERT_ACTION,
								SYSDATE
							);
					
					EXCEPTION
									WHEN standard.DUP_VAL_ON_INDEX THEN
										 doUpdate ;
									WHEN OTHERS THEN
										 ErrorMsg(sqlFunction => 'insert',
													tableName => 'amd_rsp_sum',
													pErrorLocation => 370, 
													key1 => part_no,
													key2 => rsp_location ) ;
										 RAISE; 
													
					END insertAmdRspSum;
		END InsertRow ;
	
		PROCEDURE UpdateRow IS
			-- get the detail for the summarized inv_qty
			result NUMBER ;
			 
		BEGIN
			<<updateAmdRspSum>> 
			BEGIN
				UPDATE AMD_RSP_SUM SET
		            qty_on_hand 	   = doRspSumDiff.qty_on_hand,
					rsp_level  = doRspSumDiff.rsp_level,
					action_code    = Amd_Defaults.UPDATE_ACTION,
					last_update_dt = SYSDATE
				WHERE part_no  = doRspSumDiff.part_no
				      AND rsp_location  = doRspSumDiff.rsp_location ;
				EXCEPTION
						WHEN OTHERS THEN
							 ErrorMsg(SqlFunction => 'update',
										TableName => 'amd_rsp_sum',
										pErrorLocation => 380, 
									     key1 => part_no,
										key2 => rsp_location) ;
							 RAISE ;
			END updateAmdRspSum ;
					

		END UpdateRow ;
	
		PROCEDURE DeleteRow IS
		BEGIN
		     
			<<updateAmdRspSum>> -- logically delete all records for the part_no and loc_sid
			BEGIN
			 UPDATE AMD_RSP_SUM SET
				action_code    = Amd_Defaults.DELETE_ACTION,
				last_update_dt = SYSDATE
			WHERE    part_no  = doRspSumDiff.part_no
				 AND rsp_location  = doRspSumDiff.rsp_location ;
					
			EXCEPTION
					WHEN OTHERS THEN
						   ErrorMsg(SqlFunction => 'update',
									TableName => 'amd_rsp_sum',
									pErrorLocation => 390, 
									key1 => part_no,
									key2 => rsp_location) ;
							RAISE ;
			 END updateAmdRspSum;
			 
			
			
			
		END DeleteRow ;
	BEGIN
		 IF action_code = Amd_Defaults.INSERT_ACTION THEN
		     insertRow ;
		ELSIF action_code = Amd_Defaults.UPDATE_ACTION THEN
		 	  updateRow ;
		ELSIF action_code = Amd_Defaults.DELETE_ACTION THEN
			 deleteRow ;
		ELSE
			 errorMsg(action_code,'rsp_sum',331,part_no, rsp_location) ;
			 RAISE badActionCode ;
		END IF ;
		
		A2a_Pkg.insertInvInfo(part_no, rsp_location,NVL(qty_on_hand,0), action_code) ;
			
		<<insertTmpA2ALocPartOverride>>
		declare 
				qty number ;
				a2a_action_code tmp_a2a_loc_part_override.action_code%type ;
		begin
			 if action_code = amd_defaults.DELETE_ACTION then
			 	qty := 0 ;
				a2a_action_code := amd_defaults.UPDATE_ACTION ;
			 else
			 	qty := rsp_level ;
				a2a_action_code := action_code ;
			 end if ;
			 IF Amd_Location_Part_Override_Pkg.insertedTmpA2ALPO(part_no, rsp_location,
						                                     'TSL Fixed', qty, 
															 'Fixed TSL Load',
															  Amd_Location_Part_Override_Pkg.GetFirstLogonIdForPart(Amd_Utils.GetNsiSidFromPartNo(part_no)),
															   SYSDATE,
															  a2a_action_code,
															   SYSDATE)  THEN							
							NULL ; -- do nothing
			 END IF ;
		end insertTmpA2ALocPartOverride ;

		RETURN SUCCESS;
	 EXCEPTION WHEN OTHERS THEN
			   ErrorMsg(SqlFunction => 'doRspSumDiff(' || action_code || ')',
									TableName => 'amd_rsp_sum / tmp_a2a_loc_part_override',
									pErrorLocation => 400) ; 
	 		   RETURN FAILURE ;
	END doRspSumDiff ;
	
	
	
	
	
	/* amd_in_transits diff functions */
	FUNCTION InsertRow(
			 		   		to_loc_sid	   	  IN NUMBER,
							quantity		  IN NUMBER,
							document_id		  IN VARCHAR2,
							part_no				 	IN VARCHAR2,
							from_location 			IN VARCHAR2,
							in_transit_date			IN DATE,
							serviceable_flag		IN VARCHAR2) RETURN NUMBER IS 
			result NUMBER;
			
			--site_location TMP_IN_TRANSITS_DIFF.site_location%TYPE := getSiteLocation(to_loc_sid) ;
			
	PROCEDURE doUpdate IS
	BEGIN
	     <<GetActionCode>>
		 DECLARE
		   action_code AMD_IN_TRANSITS.action_code%TYPE ;
		   badInsert EXCEPTION ;
		 BEGIN
			SELECT action_code INTO action_code
			FROM AMD_IN_TRANSITS 
			WHERE document_id = insertRow.document_id ;
			IF action_code != Amd_Defaults.DELETE_ACTION THEN
				RAISE badInsert ;
			END IF ;
		 EXCEPTION WHEN OTHERS THEN
							ErrorMsg(sqlFunction => 'select',
									tableName => 'amd_in_transits',
									pErrorLocation => 410, 
									key1 => insertRow.document_id) ;
		END getActionCode ;
					
		UPDATE AMD_IN_TRANSITS
		SET to_loc_sid = insertRow.to_loc_sid,
			quantity = insertRow.quantity,
			action_code = Amd_Defaults.INSERT_ACTION,
			last_update_dt = SYSDATE,
			part_no = insertRow.part_no,
			from_location = insertRow.from_location,
			in_transit_date = insertRow.in_transit_date,
			serviceable_flag = insertRow.serviceable_flag 
		WHERE document_id = insertRow.document_id ;
	END doUpdate ;
			  	
	BEGIN 
	  <<insertAmdInTransits>>
	  BEGIN
			INSERT INTO  AMD_IN_TRANSITS
					(
					to_loc_sid,
					quantity,
					action_code,
					last_update_dt,
					document_id,
					part_no,
					from_location,
					in_transit_date,
					serviceable_flag
					)
				VALUES
					(
					to_loc_sid,
					quantity,
					Amd_Defaults.INSERT_ACTION,
					SYSDATE,
					document_id,
					part_no,
					from_location,
					in_transit_date,
					serviceable_flag
					);
			EXCEPTION
			 	WHEN standard.DUP_VAL_ON_INDEX THEN
					 doUpdate ; 
				WHEN OTHERS THEN
					RETURN ErrorMsg(pSqlFunction => 'insert',
					pTableName => 'amd_in_transits',
					pErrorLocation => 420,
					pReturn_code => FAILURE,
					pKey_1 =>document_id,
					pKey_2 => part_no,
					pKey_3 => to_loc_sid,
					pKey_4 => in_transit_date) ;
		END insertAmdInTransits;
		RETURN SUCCESS;				
	
    END InsertRow ;
			
	FUNCTION UpdateRow(
					   TO_LOC_SID				IN NUMBER,
					   QUANTITY					IN NUMBER,
					   DOCUMENT_ID				IN VARCHAR2,
					   PART_NO					IN VARCHAR2,
					   FROM_LOCATION			IN VARCHAR2,
					   IN_TRANSIT_DATE			IN  DATE,
					   SERVICEABLE_FLAG			IN VARCHAR2) RETURN  NUMBER IS 
	BEGIN
	    <<updateAmdInTransits>>
		BEGIN
		 UPDATE AMD_IN_TRANSITS SET
					quantity		 = UpdateRow.quantity,
					action_code	 = Amd_Defaults.UPDATE_ACTION,
					last_update_dt	 = SYSDATE,
					from_location	 = UpdateRow.from_location,
					in_transit_date = UpdateRow.in_transit_date
		 WHERE document_id = UpdateRow.document_id
		 AND part_no = UpdateRow.part_no
		 AND to_loc_sid = UpdateRow.to_loc_sid;
						
		 EXCEPTION
				WHEN OTHERS THEN
					RETURN ErrorMsg(pSqlFunction =>'update',
							  		 pTableName =>'amd_in_transits',
									 pErrorLocation => 430,
									 pReturn_code => FAILURE,
									 pKey_1 => document_id,
									 pKey_2 => part_no,
									 pKey_3 => TO_CHAR(to_loc_sid));
		END updateAmdInTransit;
				
		
	    RETURN SUCCESS ;
					
		EXCEPTION WHEN OTHERS THEN
			  	   RETURN ErrorMsg(pSqlFunction => 'updateRow',
				   		  pTableName => 'amd_in_transits',
						  pErrorLocation => 440,
						  pReturn_code => FAILURE,
						  pKey_1 => part_no);
	END UpdateRow ;
				
	FUNCTION DeleteRow(
						 DOCUMENT_ID	 IN VARCHAR2,
						 PART_NO		 IN 		 VARCHAR2,
						 TO_LOC_SID	 IN NUMBER) RETURN NUMBER IS 
						 
			quantity AMD_IN_TRANSITS.quantity%TYPE;
			from_location AMD_IN_TRANSITS.from_location%TYPE;
			in_transit_date AMD_IN_TRANSITS.in_transit_date%TYPE;
	BEGIN
	  <<updateAmdInTransit>>
	  BEGIN
		UPDATE AMD_IN_TRANSITS SET
					quantity = DeleteRow.quantity,
					from_location = DeleteRow.from_location,
					in_transit_date = DeleteRow.in_transit_date,
					action_code = Amd_Defaults.DELETE_ACTION,
					last_update_dt = SYSDATE
		WHERE DOCUMENT_ID = DeleteRow.DOCUMENT_ID
		AND PART_NO = Deleterow.PART_NO
		AND TO_LOC_SID = DeleteRow.TO_LOC_SID ;
						 
		EXCEPTION
			WHEN OTHERS THEN
					RETURN ErrorMsg(pSqlFunction => 'update',
									pTableName => 'amd_in_transits',
									pErrorLocation => 450,
									pReturn_code =>FAILURE,
									pKey_1 => document_id,
									pKey_2 => part_no,
									pKey_3 => TO_CHAR(to_loc_sid)) ;														
	  END updateAmdInTransit;
	  <<selectAmdInTransit>>
	  BEGIN
			SELECT quantity, from_location, in_transit_date 
			INTO quantity, from_location, in_transit_date
			FROM AMD_IN_TRANSITS
			WHERE document_id = DeleteRow.document_id
			AND part_no = DeleteRow.part_no
			AND to_loc_sid = DeleteRow.to_loc_sid;
						
	  EXCEPTION
		 WHEN OTHERS THEN 
		      RETURN ErrorMsg(pSqlFunction => 'select',
							pTableName => 'amd_in_transits',
							pErrorLocation => 460,
							pReturn_code => FAILURE,
							pKey_1 => document_id,
							pKey_2 => part_no,
							pKey_3 => TO_CHAR(to_loc_sid) );
	  END selectAmdInTransit;
	  RETURN SUCCESS;
   END DeleteRow;
   
   FUNCTION InsertRow(
   					  part_no	   	  IN VARCHAR2,
					  site_location	  IN VARCHAR2,
					  quantity			  IN NUMBER,
					  serviceable_flag	 IN VARCHAR2) RETURN NUMBER IS
			
			result NUMBER;
		 FUNCTION doUpdate RETURN NUMBER IS
		    action_code AMD_IN_TRANSITS_SUM.action_code%TYPE;
			badInsert EXCEPTION;
		 BEGIN
		 
		    UPDATE AMD_IN_TRANSITS_SUM
			SET quantity = InsertRow.quantity,
			    serviceable_flag = InsertRow.serviceable_flag,
			    action_code = Amd_Defaults.INSERT_ACTION,
				last_update_dt = SYSDATE	
			WHERE  part_no = InsertRow.part_no 
			AND site_location = InsertRow.site_location;
			RETURN SUCCESS;
		 EXCEPTION  WHEN OTHERS THEN
		 			result := ErrorMsg(pSqlFunction => 'update',
					                   pTableName => 'amd_in_transits_sum',
									   pErrorLocation => 470,
									   pReturn_code => FAILURE,
									   pKey_1 => part_no,
									   pKey_2 => site_location) ;
					RAISE;
		 END doUpdate ;
	  BEGIN
	   IF (quantity > 0) THEN
	   BEGIN
	      INSERT INTO AMD_IN_TRANSITS_SUM
		  (
		   part_no,
		   site_location,
		   quantity,
		   serviceable_flag,
		   action_code,
		   last_update_dt
		  )
		  VALUES
		  (
		   InsertRow.part_no,
		   InsertRow.site_location,
		   quantity,
		   serviceable_flag,
		   Amd_Defaults.INSERT_ACTION,
		   SYSDATE
		  ) ;
		  EXCEPTION WHEN standard.DUP_VAL_ON_INDEX THEN
		  				 result := doUpdate ;
					WHEN OTHERS THEN
						 result := ErrorMsg(pSqlFunction => 'insert',
						 		   			  pTableName => 'amd_in_transits_sum',
											  pErrorLocation => 480,
											  pReturn_code => FAILURE,
											  pKey_1 => part_no,
											  pKey_2 => site_location,
											  pKey_3 => quantity) ;
					RAISE;
		  END insertAmdIntransitSum;
		-- END IF ;
		 
		A2a_Pkg.insertTmpA2AInTransits(
			  insertRow.part_no,
			  insertRow.site_location,
			  insertRow.quantity,
			  insertRow.serviceable_flag,
			  Amd_Defaults.INSERT_ACTION) ;
		END IF ;
		RETURN SUCCESS;
	END InsertRow;
	
	FUNCTION UpdateRow(
			 		   part_no	   		 IN VARCHAR2,
					   site_location  	   	 IN VARCHAR2,
					   quantity	   		 IN NUMBER,
					   serviceable_flag	 IN VARCHAR2) RETURN NUMBER IS
			 result NUMBER;
	BEGIN
		<<updateAmdInTransitsSum>>
		BEGIN
		  UPDATE AMD_IN_TRANSITS_SUM SET
		  		 quantity = UpdateRow.quantity,
				 action_code = Amd_Defaults.UPDATE_ACTION,
				 last_update_dt = SYSDATE
		  WHERE part_no = UpdateRow.part_no
		  AND site_location = UpdateRow.site_location;
		END updateAmdInTransitsSum ;
		
		A2a_Pkg.insertTmpA2AInTransits(
			  updateRow.part_no,
			  updateRow.site_location,
			  updateRow.quantity,
			  updateRow.serviceable_flag,
			  Amd_Defaults.UPDATE_ACTION) ;
			  RETURN SUCCESS;
			  
	END UpdateRow;
	
	FUNCTION DeleteRow(
			 		   part_no	   	IN VARCHAR2,
					   site_location	IN VARCHAR2,
					   serviceable_flag		  IN VARCHAR2) RETURN NUMBER IS
	
	BEGIN
		<<updateAmdInTransits>>
		BEGIN
			 UPDATE AMD_IN_TRANSITS_SUM SET
			 	action_code = Amd_Defaults.DELETE_ACTION,
				last_update_dt = SYSDATE
			 WHERE part_no = DeleteRow.part_no
			 AND   site_location = DeleteRow.site_location ;
		END updateAmdInTransits ;
		
		A2a_Pkg.insertTmpA2AInTransits(
			  deleteRow.part_no,
			  deleteRow.site_location,
			  0,
			  deleteRow.serviceable_flag,
			  Amd_Defaults.DELETE_ACTION) ;
			  RETURN SUCCESS;

	END DeleteRow ;	 
	
	PROCEDURE loadOnHandInvs IS
		nsnDashed      		 VARCHAR2(16) := NULL;
		invQty         		 NUMBER := 0 ;
		cntOnHandInvs 	   	 NUMBER := 0 ;
		cntType1 	  		 NUMBER := 0 ;
		cntType2			 NUMBER := 0 ;
		result 				 NUMBER := 0 ;
		cntType1WholeSale 	 NUMBER := 0 ;
	BEGIN
	   dbms_output.put_line('loadOnHandInvs started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS')) ;
	   EXECUTE IMMEDIATE 'truncate table TMP_AMD_ON_HAND_INVS';
	   EXECUTE IMMEDIATE 'truncate table TMP_A2A_INV_INFO' ;
		
		FOR rec IN partCur LOOP

			nsnDashed := Amd_Utils.FormatNsn(rec.nsn,'GOLD');

			--
			-- For each part, extract inventory data from ramp and item tables.
			--
			<<invRampLoop>> 
			FOR rRec IN rampCur(nsnDashed) LOOP

				invQty := rRec.serviceable_balance +  rRec.difm_balance ;

				IF invQty > 0 THEN
				    <<Type_1>>					
					BEGIN
						INSERT INTO TMP_AMD_ON_HAND_INVS
						(
							part_no,
							loc_sid,
							inv_date,
							inv_qty,
							action_code,
							last_update_dt
						)
						VALUES
						(
							rec.part_no,
							rRec.loc_sid,
							rRec.inv_date,
							invQty,
							Amd_Defaults.INSERT_ACTION,
							SYSDATE
						);
						cntType1 := cntType1 + 1 ;
						cntOnhandInvs := cntOnHandInvs + 1 ;
					EXCEPTION
						WHEN DUP_VAL_ON_INDEX THEN
						 result := ErrorMsg(pSqlFunction => 'insert',
									pTableName => 'tmp_amd_on_hand_invs',
									pErrorLocation => 490, 
									pReturn_code => FAILURE,
									pKey_1 => rec.part_no,
									pKey_2 => rRec.loc_sid,
									pKey_3 => rRec.inv_date,
									pKey_4 => nsnDashed);
							RAISE ;
					END Type_1;
				END IF;
			END LOOP invRampLoop ;
		END LOOP f77PartLoop;
		
	
		
		<<type1WholeSale>>
		FOR iRec IN itemType1Cur LOOP

			IF (iRec.inv_date IS NULL) THEN
				Amd_Utils.InsertErrorMsg(pLoad_no => Amd_Utils.GetLoadNo('GOLD/RAMP/ITEM','AMD_SPARE_INVS'),pKey_1 => iRec.part_no,
						pKey_2 => iRec.loc_sid, pKey_3 => 'GOLD/SPAREINV',
						pKey_4 => 'No inventory date found' );
			ELSE

				-- Type 1
				IF iRec.inv_qty > 0 THEN
                    <<insertTmpAmdOnHandInvs>>   
					BEGIN
						INSERT INTO TMP_AMD_ON_HAND_INVS
						(
							part_no,
							loc_sid,
							inv_date,
							inv_qty,
							action_code,
							last_update_dt
						)
						VALUES
						(
							iRec.part_no,
							iRec.loc_sid,
							iRec.inv_date,
							iRec.inv_qty,
							Amd_Defaults.INSERT_ACTION,
							SYSDATE
						);
						cntType1WholeSale := cntType1WholeSale + 1 ;
						cntOnHandInvs := cntOnHandInvs + 1 ;
					EXCEPTION
						WHEN OTHERS THEN
							result := ErrorMsg(pSqlFunction => 'insert',
									pTableName => 'tmp_amd_on_hand_invs',
									pErrorLocation => 500, 
									pReturn_code => FAILURE,
									pKey_1 => iRec.part_no,
									pKey_2 => iRec.loc_sid,
									pKey_3 => iRec.inv_date) ;
							RAISE ;
					END insertTmpAmdOnHandInvs ;

				END IF;
			END IF;

		END LOOP type1WholeSale ;
		
		dbms_output.put_line('loadOnHandInvs ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ) ;
		dbms_output.put_line('cntOnHandInvs=' || cntOnHandInvs) ;
		dbms_output.put_line('cntType1=' || cntType1) ;
		dbms_output.put_line('cntType1WholeSale=' || cntType1WholeSale) ;
		
		infoMsg(sqlFunction => 'loadOnHandInvs',
			tableName => 'tmp_amd_on_hand_invs',
			pErrorLocation => 510, 
			key1 => TO_CHAR(cntOnHandInvs),
			key2 => TO_CHAR(cntType1),
			key3 => TO_CHAR(cntType1WholeSale)) ;
			
	EXCEPTION
		WHEN OTHERS THEN
			 ErrorMsg(sqlFunction => 'select',
				tableName => 'tmp_amd_on_hand_invs',
				pErrorLocation => 520) ; 
		RAISE ;
	END loadOnHandInvs ;
	
	PROCEDURE loadInRepair IS
		nsnDashed      		 VARCHAR2(16) := NULL;
		invQty         		 NUMBER := 0 ;
		cntType2 	  		 NUMBER := 0 ;
		cntInRepair   		 NUMBER := 0 ;
		result				 NUMBER := 0 ;
		cntType4WholeSale	 NUMBER :=  0 ;
		cntTypeBASCWholeSale NUMBER := 0 ;
		cntType5WholeSale	 NUMBER := 0 ;
	BEGIN
		dbms_output.put_line('loadInRepair started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS')) ;
		EXECUTE IMMEDIATE 'truncate table TMP_AMD_IN_REPAIR' ;
		EXECUTE IMMEDIATE 'truncate table TMP_A2A_REPAIR_INFO' ;
		EXECUTE IMMEDIATE 'truncate table tmp_a2a_repair_inv_info' ;
		
		<<f77PartLoop>> 
		FOR rec IN partCur LOOP

			nsnDashed := Amd_Utils.FormatNsn(rec.nsn,'GOLD');

			--
			-- For each part, extract inventory data from ramp and item tables.
			--
			<<invRampLoop>> 
			FOR rRec IN rampCur(nsnDashed) LOOP

				invQty := rRec.unserviceable_balance + rRec.suspended_in_stock;

				IF invQty > 0  THEN
					<<Type_2>>
					BEGIN
						INSERT INTO TMP_AMD_IN_REPAIR
						(
							part_no,
							loc_sid,
							repair_date,
							repair_qty,
							order_no,
							repair_need_date,
							action_code,
							last_update_dt
						)
						VALUES
						(
							rec.part_no,
							rRec.loc_sid,
							rRec.inv_date,
							invQty,
							'Retail',
							rRec.repair_need_date,
							Amd_Defaults.INSERT_ACTION,
							SYSDATE
						);
						cntType2 := cntType2 + 1 ;
						cntInRepair := cntInRepair + 1 ;
					EXCEPTION
						WHEN DUP_VAL_ON_INDEX THEN
							result := ErrorMsg(pSqlFunction => 'insert',
									pTableName => 'tmp_amd_in_repair',
									pErrorLocation => 530, 
									pReturn_code => FAILURE,
									pKey_1 => rec.part_no,
									pKey_2 => rRec.loc_sid,
									pKey_3 => rRec.inv_date,
									pKey_4 => rRec.repair_need_date) ;
							RAISE ;
								
					END Type_2;
				END IF;

			END LOOP invRampLoop ;

		END LOOP f77PartLoop;
		
		<<type4WholeSale>>
		FOR imRec IN itemMCur LOOP

			IF (imRec.inv_date IS NULL) THEN
				Amd_Utils.InsertErrorMsg(pLoad_no => Amd_Utils.GetLoadNo('GOLD/RAMP/ITEM','AMD_SPARE_INVS'),pKey_1 => imRec.part_no, pKey_2 => imRec.loc_sid,
						pKey_3 => 'GOLD/SPAREINV', pKey_4 => 'No inventory date found' );
			ELSE

				IF imRec.inv_qty > 0 THEN
				
				<<insertTmpAmdInRepair>>
				DECLARE
					   result NUMBER ;
				BEGIN
					--SELECT amd_order_sid_seq.NEXTVAL
					--INTO orderSid
					--FROM dual;

					-- Type 4
					INSERT INTO TMP_AMD_IN_REPAIR
					(
						part_no,
						loc_sid,
						repair_date,
						repair_qty,
						order_no,
						repair_need_date,
						action_code,
						last_update_dt
					)
					VALUES
					(
						imRec.part_no,
						imRec.loc_sid,
						imRec.inv_date,
						imRec.inv_qty,
						imRec.item_id,
						imRec.repair_need_date,
						Amd_Defaults.INSERT_ACTION,
						SYSDATE
					);
					cntType4WholeSale := cntType4WholeSale + 1 ;
					cntInRepair := cntInRepair + 1 ;
				EXCEPTION WHEN OTHERS THEN
					 result := ErrorMsg(
						pSqlFunction => 'insert' ,
						pTableName => 'tmp_amd_in_repair',
						pErrorLocation => 540,
						pReturn_code => FAILURE,
						pKey_1 => imRec.part_no,
						pKey_2 => TO_CHAR(imRec.loc_sid),
						pKey_3 => TO_CHAR(imRec.inv_date,'DD/MON/YYYY'),
						pKey_4 => imRec.inv_type) ;					
					
					RAISE ;

				END insertTmpAmdInRepair ;
				
				END IF;
			END IF;

		END LOOP type4WholeSale ;

		<<typeBASCWholeSale>>
		FOR iaRec IN itemACur LOOP

			IF (iaRec.repair_date IS NULL) THEN
				Amd_Utils.InsertErrorMsg(pLoad_no => Amd_Utils.GetLoadNo('GOLD/RAMP/ITEM','AMD_SPARE_INVS'),pKey_1 => iaRec.part_no, pKey_2 => iaRec.loc_sid,
						pKey_3 => 'GOLD/SPAREINV', pKey_4 => 'No inventory date found' );
			ELSE

				IF iaRec.inv_qty > 0 THEN
				
				<<insertTmpAmdInRepair>>
				DECLARE
					   result NUMBER ;
				BEGIN
					
					INSERT INTO TMP_AMD_IN_REPAIR
					(
						part_no,
						loc_sid,
						repair_date,
						repair_qty,
						order_no,
						repair_need_date,
						action_code,
						last_update_dt
					)
					VALUES
					(
						iaRec.part_no,
						iaRec.loc_sid,
						iaRec.repair_date,
						iaRec.inv_qty,
						iaRec.item_id,
						iaRec.repair_need_date,
						Amd_Defaults.INSERT_ACTION,
						SYSDATE
					);
					cntTypeBASCWholeSale := cntTypeBASCWholeSale + 1 ;
					cntInRepair := cntInRepair + 1 ;
				EXCEPTION WHEN OTHERS THEN
					 result := ErrorMsg(
						pSqlFunction => 'insert' ,
						pTableName => 'tmp_amd_in_repair',
						pErrorLocation => 550,
						pReturn_code => FAILURE,
						pKey_1 => iaRec.part_no,
						pKey_2 => TO_CHAR(iaRec.loc_sid),
						pKey_3 => TO_CHAR(iaRec.repair_date,'DD/MON/YYYY'));				
					
					RAISE ;

				END insertTmpAmdInRepair ;
				
				END IF;
			END IF;

		END LOOP typeBASCWholeSale ;
		
		<<itemType5WholeSale>>
		FOR oRec IN itemType5Cur LOOP

			IF (oRec.inv_date IS NULL) THEN
				Amd_Utils.InsertErrorMsg(pLoad_no => Amd_Utils.GetLoadNo('GOLD/RAMP/ITEM','AMD_SPARE_INVS'),pKey_1 => oRec.part_no, pKey_2 => oRec.loc_sid,
						pKey_3 => 'GOLD/SPAREINV', pKey_4 => 'No inventory date found' );
			ELSE

				IF oRec.inv_qty > 0 THEN
				
				<<insertTmpAmdInRepair>>
				DECLARE
					   result NUMBER ;
				BEGIN
					
					INSERT INTO TMP_AMD_IN_REPAIR
					(
						part_no,
						loc_sid,
						repair_date,
						repair_qty,
						order_no,
						repair_need_date,
						action_code,
						last_update_dt
					)
					VALUES
					(
						oRec.part_no,
						oRec.loc_sid,
						oRec.inv_date,
						oRec.inv_qty,
						oRec.order_no,
						oRec.repair_need_date,
						Amd_Defaults.INSERT_ACTION,
						SYSDATE
					);
					cntType5WholeSale := cntType5WholeSale + 1 ;
					cntInRepair := cntInRepair + 1 ;
				EXCEPTION WHEN OTHERS THEN
					 result := ErrorMsg(
						pSqlFunction => 'insert' ,
						pTableName => 'tmp_amd_in_repair',
						pErrorLocation => 560,
						pReturn_code => FAILURE,
						pKey_1 => oRec.part_no,
						pKey_2 => TO_CHAR(oRec.loc_sid),
						pKey_3 => TO_CHAR(oRec.inv_date,'DD/MON/YYYY'));				
					
					RAISE ;

				END insertTmpAmdInRepair ;
				
				END IF;
			END IF;

		END LOOP itemType5WholeSale ;
		
		dbms_output.put_line('loadInRepair ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ) ;
		dbms_output.put_line('cntInRepair=' || cntInRepair) ;
		dbms_output.put_line('cntType2=' || cntType2) ;
		dbms_output.put_line('cntType4WholeSale=' || cntType4WholeSale) ;
		dbms_output.put_line('cntTypeBASCWholeSale=' || cntTypeBASCWholeSale) ;
		dbms_output.put_line('cntType5WholeSale=' || cntType5WholeSale) ;
		
		infoMsg(sqlFunction => 'loadOnHandPlusInRepair',
			tableName => 'tmp_amd_in_repair',
			pErrorLocation => 570, 
			key1 => TO_CHAR(cntInRepair),
			key2 => TO_CHAR(cntType2),
			key3 => TO_CHAR(cntType4WholeSale),
			key4 => TO_CHAR(cntTypeBASCWholeSale),
			key5 => TO_CHAR(cntType5WholeSale)) ;
			
	EXCEPTION
		WHEN OTHERS THEN
			 ErrorMsg(sqlFunction => 'select',
				tableName => 'tmp_amd_in_repair',
				pErrorLocation => 580) ; 
		RAISE ;
	END loadInRepair ;
	
	
	PROCEDURE updateSpoTotalInventory IS
	
			CURSOR partCur IS
				   SELECT DISTINCT
				   		prime_part_no
				   FROM AMD_NATIONAL_STOCK_ITEMS ansi,
				    	AMD_SPARE_PARTS asp
				   WHERE 
				   		 RTRIM(ansi.nsn) = RTRIM(asp.nsn)
						 AND ansi.action_code != 'D' ;
													   
			CURSOR  totalSpoInvCur IS
					SELECT ansi.nsn,  SUM(qty) quantity 
               		 FROM
					 	 (SELECT a.part_no,quantity qty, nsn
						 FROM AMD_IN_TRANSITS a,
						 	  		   AMD_SPARE_NETWORKS asn,
						 	  		   AMD_SPARE_PARTS asp
						 WHERE asn.loc_sid = a.to_loc_sid
						 AND a.part_no = asp.part_no
						 AND asp.action_code IN ('A', 'C')
						 AND a.action_code != 'D'
						 AND asn.action_code != 'D'
						 AND asn.spo_location IS NOT NULL
						 UNION ALL
						 SELECT a.part_no,order_qty qty, asp.nsn
						 FROM AMD_ON_ORDER a, 
						 	  		   AMD_SPARE_NETWORKS asn,
			    					   AMD_SPARE_PARTS asp
				 		WHERE asn.loc_sid = a.loc_sid 
						AND a.part_no = asp.part_no
						AND asp.action_code IN ('A', 'C')
						AND a.action_code != 'D'
						AND asn.action_code != 'D'
						AND asn.spo_location IS NOT NULL				 
						UNION ALL
						SELECT a.part_no,inv_qty qty, asp.nsn
						FROM AMD_ON_HAND_INVS a, 
							 		 AMD_SPARE_NETWORKS asn,
									 AMD_SPARE_PARTS asp
						WHERE asn.loc_sid = a.loc_sid 
						AND RTRIM(a.part_no) = RTRIM(asp.part_no)
						AND asp.action_code IN ('A', 'C')
						AND a.action_code != 'D'
						AND asn.action_code != 'D'
						AND asn.spo_location IS NOT NULL
						UNION ALL 
						SELECT a.part_no, repair_qty qty, asp.nsn
						FROM AMD_IN_REPAIR a, 
							 		  AMD_SPARE_NETWORKS asn,
									  AMD_SPARE_PARTS asp 
						WHERE asn.loc_sid = a.loc_sid 
						AND a.part_no = asp.part_no
						AND asp.action_code IN ('A', 'C')
						AND a.action_code != 'D'
						AND asn.action_code != 'D'
						AND asn.spo_location IS NOT NULL
						UNION ALL 
						SELECT a.part_no, rsp_inv qty, asp.nsn
						FROM AMD_RSP a,
							 		  AMD_SPARE_NETWORKS asn,
									  AMD_SPARE_PARTS asp
						WHERE asn.loc_sid = a.loc_sid
						AND a.part_no = asp.part_no
						AND asp.action_code IN ('A','C')
						AND a.action_code != 'D'
						AND asn.action_code != 'D'
						AND asn.spo_location IS NOT NULL) qtyQ,
						AMD_NATIONAL_STOCK_ITEMS  ansi
						WHERE  ansi.nsn = qtyQ.nsn
						GROUP BY ansi.nsn ;
						
	BEGIN
		 		
		 dbms_output.put_line('updateSpoTotalInventory started at ' || TO_CHAR(SYSDATE,  'MM/DD/YYYY HH:MM:SS') ) ;	
		 
		 BEGIN
		 	  	UPDATE AMD_NATIONAL_STOCK_ITEMS
				SET spo_total_inventory = NULL
				WHERE spo_total_inventory IS NOT NULL ;
		END ;
				
		 <<primePartLoop>>
		-- FOR rec IN partCur LOOP
		 	 
			 FOR rRec IN totalSpoInvCur LOOP
			-- dbms_output.put_line('part_no=' || rRec.prime_part_no ); --' qty = ' || rRec.quantity) ;
			 	 BEGIN
				 	  UPDATE AMD_NATIONAL_STOCK_ITEMS
					  SET spo_total_inventory = rRec.quantity
					  WHERE nsn  = rRec.nsn
					  AND action_code != 'D' ;				  
				 END;
			 END LOOP totalSpoInvLoop ; 
		--END LOOP partCur ;
		 dbms_output.put_line('updateSpoTotalInventory ended at ' || TO_CHAR(SYSDATE,  'MM/DD/YYYY HH:MM:SS') ) ;	
	
	END updateSpoTotalInventory ; 
	
	-- added 9/2/2005
	FUNCTION getParamDate(rawData IN AMD_PARAM_CHANGES.PARAM_VALUE%TYPE, typeOfDate IN orderdates) RETURN DATE IS
			 paramDate DATE ;
			 params Amd_Utils.arrayOfWords := Amd_Utils.arrayOfWords() ;
			 cnt NUMBER ;
	BEGIN
		 params := Amd_Utils.splitString(rawData) ;
		 cnt := params.COUNT() ;
		 IF params.COUNT() > 0 THEN
		 	paramDate := TO_DATE(params(typeOfDate),'MM/DD/YYYY') ;
		 END IF ;		
		 RETURN paramDate ;
	END getParamDate ; 
	
	PROCEDURE setParamDate(voucher IN VARCHAR2, theDate IN DATE, typeOfDate IN orderdates) IS
			  params Amd_Utils.arrayOfwords ; 
	BEGIN
		 params := Amd_Utils.splitString(Amd_Defaults.getParamValue(ON_ORDER_DATE || voucher)) ;
		 IF params.COUNT() > 0 THEN
		 	params(typeOfDate) := theDate ;
		 END IF ;
		 Amd_Defaults.setParamValue(LOWER(ON_ORDER_DATE || voucher), Amd_Utils.joinString(params) ) ;
	EXCEPTION
			 WHEN standard.NO_DATA_FOUND THEN
			 	  Amd_Defaults.setParamValue(LOWER('on_order_date' || voucher), NULL) ;
	END setParamDate ;

	FUNCTION getOrderCreateDate(voucher IN VARCHAR2) RETURN DATE IS
	BEGIN
		 RETURN getParamDate(Amd_Defaults.GetParamValue(LOWER(ON_ORDER_DATE || voucher)), ORDER_CREATE_DATE) ;
	EXCEPTION
		WHEN standard.NO_DATA_FOUND THEN
			 RETURN NULL ;
	END getOrderCreateDate ;
	
	
	PROCEDURE setOrderCreateDate(voucher IN VARCHAR2, orderCreateDate IN DATE) IS
			  theDate VARCHAR2(10) := TO_CHAR(orderCreateDate,'MM/DD/YYYY') ;
			  pos NUMBER ;
			  rawData AMD_PARAM_CHANGES.PARAM_VALUE%TYPE ;
			  params Amd_Utils.arrayOfWords ;
	BEGIN
		 setParamDate(voucher, orderCreateDate, ORDER_CREATE_DATE) ;
	END setOrderCreateDate ;
		 
	FUNCTION getScdeduledReceiptDateFrom(voucher IN VARCHAR2) RETURN DATE IS
	BEGIN
		 RETURN getParamDate(Amd_Defaults.GetParamValue(LOWER(ON_ORDER_DATE || voucher)), SCHEDULED_RECEIPT_DATE_FROM) ;
	EXCEPTION
		WHEN standard.NO_DATA_FOUND THEN
			 RETURN NULL ;
	END getScdeduledReceiptDateFrom ;
	
	FUNCTION getScdeduledReceiptDateTo(voucher IN VARCHAR2) RETURN DATE IS
	BEGIN
		 RETURN getParamDate(Amd_Defaults.GetParamValue(LOWER(ON_ORDER_DATE || voucher)), SCHEDULED_RECEIPT_DATE_TO) ;
	EXCEPTION
		WHEN standard.NO_DATA_FOUND THEN
			 RETURN NULL ;
	END getScdeduledReceiptDateTo ;

	PROCEDURE setScheduledReceiptDate(voucher IN VARCHAR2, fromDate IN DATE, toDate DATE) IS
			  params Amd_Utils.arrayOfwords ; 
	BEGIN
		 IF fromDate IS NOT NULL AND toDate IS NOT NULL THEN
			 IF fromDate > toDate THEN
			 	RAISE sched_receipt_date_exception ;
			 END IF ;
		 END IF ;
		 params := Amd_Utils.splitString(Amd_Defaults.getParamValue(ON_ORDER_DATE || voucher)) ;
		 IF params.COUNT() = 0 THEN
		 	params.extend(SCHEDULED_RECEIPT_DATE_TO) ;
		 ELSIF params.COUNT() = 1 THEN
		 	params.extend(2) ;
		 END IF ;
		 params(SCHEDULED_RECEIPT_DATE_FROM) := fromDate ;
		 params(SCHEDULED_RECEIPT_DATE_TO) := toDate ;
		 Amd_Defaults.setParamValue(LOWER(ON_ORDER_DATE || voucher), Amd_Utils.joinString(params) ) ;
	END setScheduledReceiptDate ;
	
	PROCEDURE setScheduledReceiptDateCalDays(voucher IN VARCHAR2, days IN NUMBER) IS 
			  params Amd_Utils.arrayOfwords ; 
	BEGIN
		 params := Amd_Utils.splitString(Amd_Defaults.getParamValue(ON_ORDER_DATE || voucher)) ;
		 IF params.COUNT() > 0 THEN
		 	params(NUMBER_OF_CALANDER_DAYS) := days ;
		 END IF ;
		 Amd_Defaults.setParamValue(LOWER(ON_ORDER_DATE || voucher), Amd_Utils.joinString(params,',') ) ;
	END setScheduledReceiptDateCalDays ;
	
   	FUNCTION getScheduledReceiptDateCalDays(voucher IN VARCHAR2) RETURN NUMBER IS
			 calDays NUMBER := NULL ;
			 params Amd_Utils.arrayOfWords ;
	BEGIN
		 params := Amd_Utils.splitString(Amd_Defaults.GetParamValue(ON_ORDER_DATE || voucher)) ;
		 IF params.COUNT() > 0 THEN
		 	calDays := TO_NUMBER(params(NUMBER_OF_CALANDER_DAYS)) ;
		 END IF ;		
		 RETURN calDays ;
	EXCEPTION WHEN standard.NO_DATA_FOUND THEN
		RETURN NULL ;
	END getScheduledReceiptDateCalDays ;

	PROCEDURE getOnOrderParams(voucher IN VARCHAR2, 
		  orderCreateDate 		  OUT DATE, 
		  schedReceiptDateFrom 	  OUT DATE, 
		  schedReceiptDateTo 	  OUT DATE, 
		  schedReceiptCalDays 	  OUT NUMBER) IS
		 params Amd_Utils.arrayOfWords ;
	BEGIN
		 params := Amd_Utils.splitString(Amd_Defaults.GetParamValue(LOWER(ON_ORDER_DATE || voucher))) ;
		 IF params.COUNT() >= NUMBER_OF_CALANDER_DAYS THEN
		    IF params(NUMBER_OF_CALANDER_DAYS) IS NOT NULL THEN
		 	   schedReceiptCalDays := TO_NUMBER(params(NUMBER_OF_CALANDER_DAYS)) ;
			ELSE
			   schedReceiptCalDays := NULL ;
			END IF ;
		 ELSE
		 	schedReceiptCalDays := NULL ;
		 END IF ;		
		 IF params.COUNT() >= SCHEDULED_RECEIPT_DATE_TO THEN
		    IF params(SCHEDULED_RECEIPT_DATE_FROM) IS NOT NULL AND LENGTH(params(SCHEDULED_RECEIPT_DATE_FROM)) >= 8 THEN
			   schedReceiptDateFrom := TO_DATE(params(SCHEDULED_RECEIPT_DATE_FROM),'MM/DD/YYYY') ;
			ELSE
				schedReceiptDateFrom := NULL ;
			END IF ;
			IF params(SCHEDULED_RECEIPT_DATE_TO) IS NOT NULL AND LENGTH(params(SCHEDULED_RECEIPT_DATE_TO)) >= 8 THEN
		 	   schedReceiptDateTo   := TO_DATE(params(SCHEDULED_RECEIPT_DATE_TO),'MM/DD/YYYY') ;
			ELSE
				schedReceiptDateTo := NULL ;
			END IF ;
			
		 ELSE
		 	schedReceiptDateFrom := NULL ;
		 	schedReceiptDateTo   := NULL ;
		 END IF ;		
		 IF params.COUNT() >= ORDER_CREATE_DATE THEN
		    IF params(ORDER_CREATE_DATE) IS NOT NULL AND LENGTH(params(ORDER_CREATE_DATE)) >= 8 THEN
		 	   orderCreateDate := TO_DATE(params(ORDER_CREATE_DATE),'MM/DD/YYYY') ;
			ELSE
		 	   orderCreateDate := NULL ;
			END IF ;
		 ELSE
		 	orderCreateDate := NULL ;
		 END IF ;		
	END getOnOrderParams ;
	
	PROCEDURE setOnOrderParams(voucher IN VARCHAR2, 
		  orderCreateDate 		   IN DATE, 
		  schedReceiptDateFrom 	   IN DATE, 
		  schedReceiptDateTo 	   IN DATE, 
		  schedReceiptCalDays 	   IN NUMBER) IS
		params Amd_Utils.arrayOfWords := Amd_Utils.arrayOfWords() ; 
	BEGIN
		 params.extend(4) ;
		 params(ORDER_CREATE_DATE) := TO_CHAR(orderCreateDate,'MM/DD/YYYY') ;
		 IF schedReceiptDateFrom IS NOT NULL AND schedReceiptDateTo IS NOT NULL THEN
		 	IF schedReceiptDateFrom > schedReceiptDateTo THEN
			   RAISE sched_receipt_date_exception ;
			END IF ;
			params(SCHEDULED_RECEIPT_DATE_FROM) := TO_CHAR(schedReceiptDateFrom,'MM/DD/YYYY') ;
			params(SCHEDULED_RECEIPT_DATE_TO) := TO_CHAR(schedReceiptDateTo,'MM/DD/YYYY') ; 
		    params(NUMBER_OF_CALANDER_DAYS) := NULL ;
		ELSE
			IF schedReceiptCalDays IS NOT NULL THEN
			   params(SCHEDULED_RECEIPT_DATE_FROM) := NULL ;
			   params(SCHEDULED_RECEIPT_DATE_TO) := NULL ; 
		 	   params(NUMBER_OF_CALANDER_DAYS) := schedReceiptCalDays ; 			
			ELSE
			   params(SCHEDULED_RECEIPT_DATE_FROM) := NULL ;
			   params(SCHEDULED_RECEIPT_DATE_TO) := NULL ;
			   params(NUMBER_OF_CALANDER_DAYS) := NULL ;
			END IF ;
		END IF ;
		IF NOT Amd_Defaults.isParamKey(LOWER(ON_ORDER_DATE || voucher)) THEN
		   Amd_Defaults.addParamKey(LOWER(ON_ORDER_DATE || voucher),'The order create date and scheduled receipt date for the ' || LOWER(voucher) || ' voucher') ; 
		END IF ;
		Amd_Defaults.setParamValue(LOWER(ON_ORDER_DATE || voucher), Amd_Utils.joinString(params) ) ;	
	END setOnOrderParams ;   
   
	FUNCTION isVoucher(voucher IN VARCHAR2) RETURN BOOLEAN IS
			theVoucher VARCHAR2(2) ; 
	BEGIN
		 SELECT DISTINCT SUBSTR(gold_order_number,1,2) INTO theVoucher FROM AMD_ON_ORDER
		 WHERE LOWER(SUBSTR(gold_order_number,1,2)) = LOWER(isVoucher.voucher) ;
		 RETURN TRUE ;
	EXCEPTION WHEN standard.NO_DATA_FOUND THEN
		 RETURN FALSE ;		 
	END isVoucher ;  

	PROCEDURE clearOnOrderParams IS
		CURSOR onOrderParams IS
			SELECT * FROM AMD_PARAM_CHANGES outer WHERE param_key LIKE ON_ORDER_DATE || '%'  
			AND effective_date = (
					SELECT MAX(effective_date)
					FROM AMD_PARAM_CHANGES
					WHERE param_key = outer.param_key) ;
	BEGIN
		 FOR rec IN onOrderParams LOOP
		 	 INSERT INTO AMD_PARAM_CHANGES
			 (param_key, param_value, effective_date, user_id)
			 VALUES (rec.param_key, ',,,', SYSDATE, USER) ;
		 END LOOP ;
	END clearOnOrderParams ;
	
	FUNCTION numberOfOnOrderParams RETURN NUMBER IS
			 cnt NUMBER ;
	BEGIN
		SELECT COUNT(*) INTO cnt FROM AMD_PARAM_CHANGES outer WHERE param_key LIKE ON_ORDER_DATE || '%'  
		AND effective_date = (
				SELECT MAX(effective_date)
				FROM AMD_PARAM_CHANGES
				WHERE param_key = outer.param_key) ;
		RETURN cnt ;
	EXCEPTION WHEN standard.NO_DATA_FOUND THEN
		RETURN 0 ;
	END numberOfOnOrderParams ;
		
	FUNCTION getVouchers RETURN ref_cursor IS
		 vouchers_cursor ref_cursor ;
	BEGIN
		 OPEN vouchers_cursor FOR 
		 SELECT DISTINCT SUBSTR(gold_order_number,1,2) voucher 
		 FROM AMD_ON_ORDER 
		 ORDER BY voucher ;
		 RETURN vouchers_cursor ;		 	  
	END getVouchers ;

	PROCEDURE version IS
	BEGIN
		 writeMsg(pTableName => 'amd_inventory', 
		 		pError_location => 590, pKey1 => 'amd_inventory', pKey2 => '$Revision:   1.76  $') ;
	END version ;
	
			 										 					    
END Amd_Inventory;
/

show errors

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.Amd_Partprime_Pkg AS
/*
      $Author:   zf297a  $
    $Revision:   1.11  $
     $Date:   30 Jan 2007 14:26:40  $
    $Workfile:   AMD_PARTPRIME_PKG.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_PARTPRIME_PKG.pkb.-arc  $
/*   
/*      Rev 1.11   30 Jan 2007 14:26:40   zf297a
/*   implemented interface updatePlannerCodesForSubParts
/*   
/*      Rev 1.10   26 Jan 2007 09:40:04   zf297a
/*   Build a list of spo_prime_part_no's that are no longer used for spo in amd_test_data, then execute deleteRspTslA2A to generate delete transactions for those spo_prime_parts and the bases they are associated with.
/*   
/*      Rev 1.9   19 Jan 2007 11:18:22   zf297a
/*   Make sure amd_sent_to_a2a's spo_prime_part_no is upated before generating the PartInfo A2A transaction.  This will gaurantee that the spo_prime_part_no is correct, whereas before the PartInfo transaction had the old spo_prime_part_no.
/*   
/*      Rev 1.8   Nov 01 2006 12:35:28   zf297a
/*   Fixed DiffPartToPrime to use a2a_pkg.DiffPartToPrime
/*   
/*      Rev 1.7   Oct 20 2006 12:23:14   zf297a
/*   Added code to make sure that a new spo_prime_part_no has been sent to the SPO.
/*   
/*      Rev 1.6   Jun 09 2006 12:07:14   zf297a
/*   implemented interface version
/*   
/*      Rev 1.5   Jun 07 2006 09:19:48   zf297a
/*   Optimizie DiffToPartPrime to send only parts that need to be sent rather than all the parts.
/*   
/*      Rev 1.4   Jun 05 2006 10:55:12   zf297a
/*   Enhanced error reporting.  For DiffPartToPrime if not all the valid parts have been sent, then execute a2a_pkg.initA2APartInfo
/*   
/*      Rev 1.3   Feb 03 2006 08:04:04   zf297a
/*   Converted to use the new amd_rbl_pairs table
/*   
/*      Rev 1.2   Dec 15 2005 12:14:34   zf297a
/*   Added truncate of table tmp_a2a_part_alt_rel_delete to DiffPartToPrime
/*   
/*      Rev 1.1   Dec 06 2005 10:27:20   zf297a
/*   Fixed display of sysdate in errorMsg - changed to MM/DD/YYYY HH:MM:SS
/*   
/*      Rev 1.0   Dec 01 2005 09:41:48   zf297a
/*   Initial revision.
*/
/* need to resolve - what if new_nsn is not a prime in amd ????? */
/*  need to clean up and streamline logic on this package */

	PKGNAME CONSTANT VARCHAR2(30) := 'AMD_PARTPRIME_PKG' ;
	
	PROCEDURE writeMsg(
				pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
				pError_location IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
				pKey1 IN VARCHAR2 := '',
				pKey2 IN VARCHAR2 := '',
				pKey3 IN VARCHAR2 := '',
				pKey4 IN VARCHAR2 := '',
				pData IN VARCHAR2 := '',
				pComments IN VARCHAR2 := '')  IS
	BEGIN
		Amd_Utils.writeMsg (
				pSourceName => 'amd_partprime_pkg',	
				pTableName  => pTableName,
				pError_location => pError_location,
				pKey1 => pKey1,
				pKey2 => pKey2,
				pKey3 => pKey3,
				pKey4 => pKey4,
				pData    => pData,
				pComments => pComments);
	END writeMsg ;

	PROCEDURE ErrorMsg(
				pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
				pError_location IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
				pKey1 IN VARCHAR2 := '',
				pKey2 IN VARCHAR2 := '',
				pKey3 IN VARCHAR2 := '',
				pKey4 IN VARCHAR2 := '',
				pComments IN VARCHAR2 := '')  IS
	BEGIN
		ROLLBACK; -- rollback may not be complete if running with mDebug set to true
		Amd_Utils.InsertErrorMsg (
				pLoad_no => Amd_Utils.GetLoadNo(pSourceName => 'amd_partprime_pkg',	pTableName  => pTableName),
				pData_line_no => pError_location,
				pData_line    => 'amd_partprime_pkg',
				pKey_1 => SUBSTR(pKey1,1,50),
				pKey_2 => SUBSTR(pKey2,1,50),			
				pKey_3 => SUBSTR(pKey3,1,50),
				pKey_4 => SUBSTR(pKey4,1,50),
				pKey_5 => TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pComments => 'sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||') ' || pComments);
		COMMIT;
	END errorMsg ;
	
	
	FUNCTION getNsiSid(pNsn VARCHAR2)
			 RETURN NUMBER IS
		retNsiSid NUMBER ;
	BEGIN
		SELECT nsi_sid INTO retNsiSid
			   FROM AMD_NSNS an
			   WHERE  an.nsn = pNsn ;
		RETURN retNsiSid ;
	EXCEPTION WHEN NO_DATA_FOUND THEN
		RETURN NULL ;	
	END ;	
	
	
	FUNCTION getSuperPrimePartByNsiSid(pNsiSid NUMBER) 
			 RETURN VARCHAR2 IS
		retPrimePart AMD_NATIONAL_STOCK_ITEMS.prime_part_no%TYPE := NULL;
		partNo AMD_SPARE_PARTS.part_no%TYPE ; 	 		 
	BEGIN
		SELECT prime_part_no INTO partNo
			FROM AMD_NATIONAL_STOCK_ITEMS
			WHERE nsi_sid = pNsiSid
			AND action_code != Amd_Defaults.DELETE_ACTION  ;
	   	RETURN getSuperPrimePart(partNo) ;				 
	EXCEPTION 
			  WHEN NO_DATA_FOUND THEN
			  	   RETURN NULL ;
			  WHEN OTHERS THEN	 
		 		   ErrorMsg(
				   pTableName  	  	  => 'amd_national_stock_items',
				   pError_location 	  => 10,
				   pKey1			  => 'pNsiSid=' || TO_CHAR(pNsiSid) ) ;
				   RAISE ;	  		  			  	
	END getSuperPrimePartByNsiSid;
	
	FUNCTION getSuperPrimePartRBL(pNsn VARCHAR2) 
			 RETURN VARCHAR2 IS
		 retPrimePart AMD_NATIONAL_STOCK_ITEMS.prime_part_no%TYPE := NULL;
		 nsiSid NUMBER ;	 
	BEGIN
		 nsiSid := getNsiSid(pNsn) ;
		 SELECT ansi.prime_part_no INTO retPrimePart
		 		FROM AMD_RBL_PAIRS brp, AMD_NSNS an, AMD_NATIONAL_STOCK_ITEMS ansi
		 		WHERE brp.old_nsn IN (SELECT nsn FROM AMD_NSNS WHERE nsi_sid = nsiSid)  
		 		AND brp.new_nsn = an.nsn
				and ansi.nsn = an.nsn
				AND brp.ACTION_CODE != Amd_Defaults.DELETE_ACTION 
		 		AND an.nsi_sid = ansi.nsi_sid AND ansi.action_code != Amd_Defaults.DELETE_ACTION;			
		 RETURN retPrimePart ;
	EXCEPTION 
			  WHEN NO_DATA_FOUND THEN
		 	  	   RETURN NULL ;
			  WHEN OTHERS THEN	 
		 		   ErrorMsg(
				   pTableName  	  	  => 'amd_rbl_pairs/amd_nsns',
				   pError_location 	  => 20,
				   pKey1			  => 'pNsn=' || pNsn) ;
				   RAISE ;	  		  			  	
	END getSuperPrimePartRBL ;
	
	
	FUNCTION getPrimePartAMD(pNsn VARCHAR2)
			 RETURN VARCHAR2 IS
		 retPrimePart AMD_NATIONAL_STOCK_ITEMS.prime_part_no%TYPE := NULL;
	BEGIN
		 SELECT ansi.prime_part_no INTO retPrimePart
		 		FROM AMD_NATIONAL_STOCK_ITEMS ansi, AMD_NSNS an
		 		WHERE an.nsn = pNsn AND an.nsi_sid = ansi.nsi_sid AND ansi.action_code != Amd_Defaults.DELETE_ACTION;			
		 RETURN retPrimePart ;
	EXCEPTION 
			  WHEN NO_DATA_FOUND THEN
		 	  	   RETURN NULL ;
			  WHEN OTHERS THEN	 
		 		   ErrorMsg(
				   pTableName  	  	  => 'amd_national_stock_items',
				   pError_location 	  => 30,
				   pKey1			  => 'pNsn=' || pNsn) ;
				   RAISE ;	  		  			  	
	END getPrimePartAMD ;	 
	
	
	FUNCTION getNsn(pPart VARCHAR2)
			 RETURN VARCHAR2 IS
		retNsn AMD_NSNS.nsn%TYPE ;
	BEGIN
		 SELECT nsn INTO retNsn
	 		FROM AMD_SPARE_PARTS asp
			WHERE asp.part_no = pPart AND action_code != Amd_Defaults.DELETE_ACTION; 
		 RETURN retNsn ;	
	EXCEPTION 
			  WHEN NO_DATA_FOUND THEN
		 	  	   RETURN NULL ; 		
			  WHEN OTHERS THEN	 
		 		   ErrorMsg(
				   pTableName  	  	  => 'amd_spare_parts',
				   pError_location 	  => 40,
				   pKey1			  => 'pPart=' || pPart) ;
				   RAISE ;	  		  			  	
	END ;		
	
	/* RBL new_nsn sometimes did not meet the minimum requirements to be
	   sent over as A2A (e.g. SMR Code did not end in 'T')
	   Easiest affirmation of minimum reqs is checking if active part in
	   amd_sent_to_a2a table */
	FUNCTION MeetMinA2AReqs(pPart VARCHAR2)
			 RETURN BOOLEAN IS
		tmpPart AMD_SPARE_PARTS.part_no%TYPE ; 	 
	BEGIN
		SELECT part_no INTO tmpPart
			FROM AMD_SENT_TO_A2A
			WHERE part_no = pPart AND action_code != Amd_Defaults.DELETE_ACTION;
		RETURN TRUE ;	
	EXCEPTION 
			  WHEN NO_DATA_FOUND THEN
			  	RETURN FALSE ;	
			  WHEN OTHERS THEN	 
		 		   ErrorMsg(
				   pTableName  	  	  => 'amd_sent_to_a2a',
				   pError_location 	  => 50,
				   pKey1			  => 'pPart=' || pPart) ;
				   RAISE ;	  		  			  	
	END MeetMinA2AReqs ;
	
	/*  main function with the business logic, try to keep most of it here */
	FUNCTION getSuperPrimePart(pPart VARCHAR2) 
			 RETURN VARCHAR2 IS
		retPrimePart AMD_NATIONAL_STOCK_ITEMS.prime_part_no%TYPE := NULL;
		nsn AMD_SPARE_PARTS.nsn%TYPE ;
	BEGIN
		nsn := getNsn(pPart) ;
		IF ( nsn IS NOT NULL ) THEN 
		   retPrimePart := getSuperPrimePartRBL(nsn) ;
		   IF ( (retPrimePart IS NULL) OR (NOT MeetMinA2AReqs(retPrimePart)) ) THEN
		   	  retPrimePart := getPrimePartAMD(nsn) ;
		   END IF ;	  
		END IF ;		   
	    RETURN retPrimePart ;
	EXCEPTION WHEN OTHERS THEN
	  ErrorMsg(
	   pTableName  	  	  => 'getSuperPrimePart',
	   pError_location 	  => 60,
	   pKey1			  => 'pPart=' || pPart) ;
	   RAISE ;	  		  			  	
	
	END ;
	
	
	
	FUNCTION getSuperPrimeNsiSidByNsn(pNsn VARCHAR2) 
			 RETURN NUMBER IS
			 retNsiSid NUMBER := NULL ;
			 prime AMD_SPARE_PARTS.part_no%TYPE ;
	BEGIN	
			 prime := getPrimePartAMD(pNsn) ; 
			 IF (prime IS NULL ) THEN
			 	RETURN NULL ;
			 ELSE	
			 	prime := getSuperPrimePart(prime) ;	
			 END IF ;		 		 		 
			 RETURN Amd_Utils.GetNsiSidFromPartNo(prime) ;	
	EXCEPTION 
			  WHEN NO_DATA_FOUND THEN
			  	   RETURN NULL ;
			 WHEN OTHERS THEN
				  ErrorMsg(
				   pTableName  	  	  => 'getSuperPrimeNsiSidByNsn',
				   pError_location 	  => 70,
				   pKey1			  => 'pNsn=' || pNsn) ;
				   RAISE ;	  		  			  	
	END getSuperPrimeNsiSidByNsn ;		 
			  
	
	FUNCTION getSuperPrimeNsiSid(pPart VARCHAR2)
			 RETURN NUMBER IS
		 retNsiSid NUMBER := NULL ;	 
		 prime AMD_SPARE_PARTS.part_no%TYPE ;
	BEGIN
		 prime := getSuperPrimePart(pPart) ;
		 IF (prime IS NOT NULL ) THEN
		 	 retNsiSid := Amd_Utils.GetNsiSidFromPartNo(prime) ;
		 END IF ;		
		 RETURN retNsiSid ;
	EXCEPTION WHEN OTHERS THEN
				  ErrorMsg(
				   pTableName  	  	  => 'getSuperPrimeNsiSid',
				   pError_location 	  => 80,
				   pKey1			  => 'pPart=' || pPart) ;
				   RAISE ;	  		  			  	
	END getSuperPrimeNsiSid;		 
			
	FUNCTION getSuperPrimeNsiSidByNsiSid(pNsiSid NUMBER) 
			 RETURN NUMBER  IS
		 retNsiSid NUMBER := NULL ;	
		 tmpNsn AMD_NSNS.nsn%TYPE ; 
	BEGIN
		 SELECT nsn INTO tmpNsn
		 		FROM AMD_NATIONAL_STOCK_ITEMS 
				WHERE nsi_sid = pNsiSid AND action_code != Amd_Defaults.DELETE_ACTION ;
		 RETURN getSuperPrimeNsiSidByNsn(tmpNsn) ;
	EXCEPTION 
		 WHEN NO_DATA_FOUND THEN
		 	  RETURN NULL ;	 
		 WHEN OTHERS THEN
			  ErrorMsg(
			   pTableName  	  	  => 'getSuperPrimeNsiSidByNsiSid',
			   pError_location 	  => 90,
			   pKey1			  => 'pNsiSid=' || TO_CHAR(pNsiSid)) ;
			   RAISE ;	  		  			  	
	END getSuperPrimeNsiSidByNsiSid ;		
			 
	PROCEDURE updatePrimeASTA(pPart VARCHAR2, pSpoPrimePart VARCHAR2, pDate DATE) IS
	BEGIN
		 UPDATE AMD_SENT_TO_A2A
		 SET	spo_prime_part_no = pSpoPrimePart,
		 		spo_prime_part_chg_date = pDate
		 WHERE  part_no = pPart ;
	EXCEPTION
		 WHEN OTHERS THEN
			  ErrorMsg(
			   pTableName  	  	  => 'amd_sent_to_a2a',
			   pError_location 	  => 100,
			   pKey1			  => 'pPart=' || pPart,
			   pKey2			  => 'pSpoPrimePart=' || pSpoPrimePart,
			   pkey3			  => 'pDate=' || TO_CHAR(pDate,'MM/DD/YYYY HH:MI:SS AM')) ;
			   RAISE ;	  		  			  	
	END updatePrimeASTA; 		 
	
	PROCEDURE InsertA2A_PartAltRelDel(pPart VARCHAR2, pPrime VARCHAR2) IS
		 partCage AMD_SPARE_PARTS.mfgr%TYPE := NULL ;
		 primeCage AMD_SPARE_PARTS.mfgr%TYPE := NULL ;
	BEGIN
	 	 <<getPartCage>>
	 	 BEGIN
			 SELECT mfgr INTO partCage
			 	 FROM AMD_SPARE_PARTS 
			 	 WHERE part_no = pPart ;
		 EXCEPTION WHEN OTHERS THEN
			  ErrorMsg(pTableName => 'amd_spare_parts', pError_location 	  => 110,
			   pKey1 => 'pPart=' || pPart) ;
		      RAISE ;	  		  			  			 
		 END getPartCage;
		 
		 <<getPrimeCage>> 
	 	 BEGIN
		 	 SELECT mfgr INTO primeCage
			 	 FROM AMD_SPARE_PARTS 
			 	 WHERE part_no = pPrime ;
		 EXCEPTION WHEN OTHERS THEN
			  ErrorMsg(pTableName => 'amd_spare_parts', pError_location 	  => 120,
			   pKey1 => 'pPart=' || pPart) ;
		      RAISE ;	  		  			  			 
		 END getPrimeCage ; 
		 
		 <<insertTmpA2APartAltRelDelete>>
		 BEGIN 	  
			 	 INSERT INTO TMP_A2A_PART_ALT_REL_DELETE
			 	 (
			 	  	part_no, cage_code, prime_part,prime_cage, last_update_dt 
			 	 )
			 	 VALUES 
			 	 (
			 	  	pPart, partCage, pPrime, primeCage, SYSDATE 	
			 	 ) ;
		EXCEPTION 
			  WHEN DUP_VAL_ON_INDEX THEN
			  	 BEGIN
				 	 UPDATE TMP_A2A_PART_ALT_REL_DELETE
					 SET	cage_code = partCage,
					 		prime_cage = primeCage
					 WHERE part_no    = pPart AND
					 	   prime_part = pPrime ;
				 EXCEPTION WHEN OTHERS THEN	   		   	 	
					  ErrorMsg(
					   pTableName  	  	  => 'tmp_a2a_part_alt_rel_delete',
					   pError_location 	  => 130,
					   pKey1			  => 'pPart=' || pPart,
					   pKey2			  => 'pPrime=' || pPrime) ;
					   RAISE ;	  		  			  	
				 END ;
			 WHEN OTHERS THEN	   		   	 	
				  ErrorMsg(
				   pTableName  	  	  => 'tmp_a2a_part_alt_rel_delete',
				   pError_location 	  => 140,
				   pKey1			  => 'pPart=' || pPart,
				   pKey2			  => 'pPrime=' || pPrime) ;
				   RAISE ;	  		  			  	
		 END insertTmpA2APartAltRelDelete ;
		 
	END InsertA2A_PartAltRelDel ; 
	 
	FUNCTION getSuperPrimeNsiSidByNsn_A2A(pNsn VARCHAR2) RETURN NUMBER IS
		retNsiSid NUMBER := NULL ;	 
		prime AMD_SPARE_PARTS.part_no%TYPE ;
	BEGIN
		prime := getPrimePartAMD(pNsn) ; 
		prime := getSuperPrimePart(prime) ;
		IF (prime IS NULL ) THEN
			RETURN NULL ;
		ELSIF (NOT MeetMinA2AReqs(prime)) THEN
			RETURN NULL ;		
		END IF ; 		 
		RETURN Amd_Utils.GetNsiSidFromPartNo(prime) ;	
	EXCEPTION 
			  WHEN NO_DATA_FOUND THEN
			  	RETURN NULL ;
			  WHEN OTHERS THEN	 
				  ErrorMsg(
				   pTableName  	  	  => 'getSuperPrimeNsiSidByNsn_A2A',
				   pError_location 	  => 150,
				   pKey1			  => 'pNsn=' || pNsn) ;
				   RAISE ;	  		  			  	
	END getSuperPrimeNsiSidByNsn_A2A ;
     
    procedure updatePlannerCodesForSubParts is
        cursor subParts is
            select info.part_no, spo_prime_part_no from tmp_a2a_part_info info, amd_sent_to_a2a sent 
            where info.part_no not in (select part_no 
                                 from amd_sent_to_a2a 
                                 where part_no = spo_prime_part_no 
                                 and action_code <> amd_defaults.DELETE_ACTION)
            and info.part_no = sent.part_no ; 
            resp_asset_mgr tmp_a2a_part_info.resp_asset_mgr%type ;
    begin
        for rec in subParts loop
            resp_asset_mgr := amd_preferred_pkg.GETPLANNERCODE(amd_utils.GETNSISID(pPart_no => rec.spo_prime_part_no)) ;
            update tmp_a2a_part_info
            set resp_asset_mgr = updatePlannerCodesForSubParts.resp_asset_mgr 
            where part_no = rec.part_no ;        
        end loop ;        
    end updatePlannerCodesForSubParts ; 

	 
	PROCEDURE DiffPartToPrime IS
		CURSOR getCandidates_cur IS
			   SELECT part_no, spo_prime_part_no
			   FROM AMD_SENT_TO_A2A asta
			   WHERE asta.action_code != Amd_Defaults.DELETE_ACTION;
		latestPrime AMD_SPARE_PARTS.part_no%TYPE ;
	    status NUMBER ;
		FUNCTION areAllPartsSent RETURN BOOLEAN IS
				 PossibleValidPartsCount NUMBER ;
				 currentValidPartsCount NUMBER ;
		BEGIN
			 SELECT COUNT(part_no) INTO possibleValidPartsCount 
			 FROM AMD_SPARE_PARTS 
			 WHERE action_code <> Amd_Defaults.DELETE_ACTION 
			 AND A2a_Pkg.isPartValidYorN(part_no) = 'Y' ;
			 
			 SELECT COUNT(*) INTO currentValidPartsCount 
			 FROM AMD_SENT_TO_A2A 
			 WHERE action_code <> Amd_Defaults.DELETE_ACTION ;
			 
			 RETURN currentValidPartsCount >= possibleValidPartsCount ;
		END areAllPartsSent ;
		
		PROCEDURE sendParts IS
				  partsToSend A2a_Pkg.partCur ;
		BEGIN
				  OPEN partsToSend FOR
					SELECT sp.mfgr,
				      sp.part_no,
				      sp.NOMENCLATURE,
				      sp.nsn,
				      sp.order_lead_time,
				      sp.order_lead_time_defaulted,
				      sp.unit_cost,
				      sp.unit_cost_defaulted,
				      sp.unit_of_issue,
				      nsi.unit_cost_cleaned,
				      nsi.order_lead_time_cleaned,
				      nsi.planner_code,
				      nsi.planner_code_cleaned,
				      nsi.mtbdr,
				      nsi.mtbdr_cleaned,
				      nsi.smr_code,
				      nsi.smr_code_cleaned,
				      nsi.smr_code_defaulted,
				      nsi.nsi_sid,
				      nsi.TIME_TO_REPAIR_OFF_BASE_CLEAND,
				      CASE 
					  WHEN TRUNC(sp.last_update_dt) >= TRUNC(nsi.last_update_dt)
						THEN sp.last_update_dt
					  ELSE
						nsi.LAST_UPDATE_DT
				      END AS last_update_dt,
				    CASE 
					WHEN sp.action_code = nsi.action_code
						THEN sp.action_code
					ELSE
						CASE 
							WHEN sp.action_code = 'D' OR nsi.action_code = 'D'
								THEN 'D'
							WHEN sp.action_code = 'C' OR nsi.action_code = 'C'
								THEN 'C'
							ELSE
								'A'
						END
					END AS action_code
				  FROM AMD_SPARE_PARTS sp,
				    AMD_NATIONAL_STOCK_ITEMS nsi
				  WHERE
				  sp.part_no IN (SELECT part_no FROM AMD_SPARE_PARTS WHERE action_code <> Amd_Defaults.DELETE_ACTION AND A2a_Pkg.isPartValidYorN(sp.part_no) = 'Y'
				                 MINUS
								 SELECT part_no FROM AMD_SENT_TO_A2A WHERE action_code <> Amd_Defaults.DELETE_ACTION)			   
				  AND sp.nsn = nsi.nsn ;
			A2a_Pkg.processParts(partsToSend) ;
			CLOSE partsToSend ;
		END sendParts ;
        

	BEGIN
		IF NOT areAllPartsSent THEN
		   sendParts ; -- make sure all parts get sent
		END IF ;
		Mta_Truncate_Table('tmp_a2a_part_alt_rel_delete','reuse storage');
        mta_truncate_table('amd_test_parts','reuse storage') ; 	 
	    FOR a2aRec IN getCandidates_cur 
		LOOP
			BEGIN	
		        latestPrime := getSuperPrimePart(a2aRec.part_no) ;	
				    -- should never really occur 						
				IF ( latestPrime IS NULL ) THEN
				   RAISE standard.NO_DATA_FOUND ;
				END IF ;   			

				if not a2a_pkg.isPartSent(latestPrime) then
					raise_application_error(-20000,'part_no (' || latestPrime || ') has never been sent to the SPO, so it cannot be a spo_prime_part_no.') ;
				end if ; 

					-- case for just added part
				IF ( a2aRec.spo_prime_part_no IS NULL ) THEN		  
				     updatePrimeASTA(a2aRec.part_no, latestPrime, NULL) ;		  
				ELSE 
					 IF ( a2aRec.spo_prime_part_no != latestPrime ) THEN
					 	begin
                        	 insert into amd_test_parts (part_no) values (a2aRec.spo_prime_part_no) ;
						exception
								 when standard.DUP_VAL_ON_INDEX then
								 	  null ; -- do nothing
								 when others then
						 		   ErrorMsg(
									   pTableName  	  	  => 'amd_test_data',
									   pError_location 	  => 158,
									   pKey1			  => 'spo_prime_part_no: <' || a2aRec.spo_prime_part_no ) ;	   
								   RAISE ;	  		  			  	
						end ;                        
				   	 	InsertA2A_PartAltRelDel(a2aRec.part_no, a2aRec.spo_prime_part_no) ;
						updatePrimeASTA(a2aRec.part_no, latestPrime, SYSDATE ) ;
						status := A2a_Pkg.createPartInfo(a2aRec.part_no, Amd_Defaults.INSERT_ACTION) ;				
						-- if previously spo prime part record, catch event of changed prime	
						-- important for those tables with nsi_sid
						IF ( a2aRec.spo_prime_part_no = a2aRec.part_no ) THEN
						   Amd_Demand.prime_part_change(a2aRec.spo_prime_part_no, latestPrime) ;
						END IF ;
				     END IF ;
				END IF ;  
			EXCEPTION WHEN OTHERS THEN
		 		   ErrorMsg(
					   pTableName  	  	  => 'amd_sent_to_a2a',
					   pError_location 	  => 160,
					   pKey1			  => 'partNo: <' || a2aRec.part_no || '>',
		   			   pKey2			  => 'currentSpoPrime:<' || a2aRec.spo_prime_part_no || '>',
					   pKey3			  => 'latestPrime: <' || latestPrime || '>') ;		   
				   RAISE ;	  		  			  	
			END ;	 	 
		END LOOP ;
        amd_location_part_override_pkg.deleteRspTslA2A ;
        updatePlannerCodesForSubParts ;
		COMMIT ;
		a2a_pkg.deleteSentToA2AChildren	;			
	END DiffPartToPrime;		 
  
	PROCEDURE version IS
	BEGIN
		 writeMsg(pTableName => 'amd_partprime_pkg', 
		 		pError_location => 170, pKey1 => 'amd_partprime_pkg', pKey2 => '$Revision:   1.11  $') ;
	END version ;
  

 
END Amd_Partprime_Pkg ;
/

show errors

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.A2a_Pkg AS
 --
 -- SCCSID:   %M%   %I%   Modified: %G%  %U%
 --
 /*
      $Author:   zf297a  $
	$Revision:   1.158  $
     $Date:   26 Jan 2007 11:33:22  $
    $Workfile:   A2A_PKG.PKB  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\A2A_PKG.PKB-arc  $
/*   
/*      Rev 1.158   26 Jan 2007 11:33:22   zf297a
/*   Fixed nested function getSchedReceiptDate of the includeOrder function to ignore DELETED orders and to get the max(line) number for the give gold_order_number and order_date.
/*   Fixed nested function getNextLineNumber of the insertTmpA2AOrderInfo procedure to get the max line for the give gold_order_number and order_date since the order may have been deleted and then added back or added and then deleted.  This will only send the latest line number for the giver gold_order_number and order_date.  
/*   (The diff could be modified to incorporate the line as the key and then the getNextLineNumber could probably be removed, but for now, this works)
/*   
/*      Rev 1.157   26 Jan 2007 10:03:58   zf297a
/*   In errorMsg made the handling of key5 more robust.  
/*   Changed all selects that create a onOrderCur type to have the Line as the third column.
/*   Modified getNextLine to just retrieve the Line from amd_on_order for the give gold_order_number and order_date.  
/*   Write more ifno to amd_load_details when there is an exception in insertTmpA2AOrderInfoLine.
/*   
/*      Rev 1.156   Dec 12 2006 12:25:04   zf297a
/*   Fixed getPartInfo's query by giving the action_code from the amd_sent_to_a2a priority over the action_code from amd_spare_parts.  Did an outer join against the amd_national_stock_items and the amd_sent_to_a2a since both tables may not have matching entries for the selected part.  Eliminated the action_code filter - not <> 'D'.
/*   Changed the query for getTestData in the same manner as was done for getPartInfo.
/*   Changed processParts to count the number inserts, updated, and delete transactions and to record those counts to amd_load_details.
/*   Changed the query for initA2APartInfo with the from date and to date arguments to be similar to the query of getPartInfo.
/*   
/*   The changes made to the queries should gaurantee that all deleted parts are collected and sent to the SPO.  Because some of these deleted parts may not have matching data in amd_national_stock_items, then the PartInfo_DEL.sql query will need to do a union with a query that is NOT using the amd_part_header_v5 view.
/*   
/*   
/*      Rev 1.155   Nov 29 2006 21:59:02   zf297a
/*   for insertRepairInvInfo, insertRepairInfo, insertTmpA2AOrderInfo, insertTmpA2AOrderInfoLine, and insertTmpA2AInTransits delete transactions make sure the site_location is not null.
/*   
/*   
/*      Rev 1.154   Nov 29 2006 21:20:14   zf297a
/*   for insertTmpA2AOrderInfo with delete_actions, make sure the site_location is not null.
/*   
/*      Rev 1.153   Nov 29 2006 13:24:56   zf297a
/*   For table amd_backorder_sum changed the column part_no to spo_prime_part_no.
/*   
/*      Rev 1.152   Nov 28 2006 14:26:50   zf297a
/*   fixed initA2ASpoUsers - use the action_code from amd_users
/*   
/*   fixed initSiteRespAssetMgr - use the action_code from amd_planner_logons
/*   
/*      Rev 1.151   Nov 28 2006 12:23:46   zf297a
/*   fixed processPartLeadTimes to check for the existance of the part_no in amd_sent_to_a2a with any action_code.
/*   
/*   fixed processPart to check for the existance of the part_no in amd_sent_to_a2a with any action_code.
/*   
/*   fixed deletePartInfo to check for the existance of the part_no in amd_sent_to_a2a with any action_code.
/*   
/*   fixed deletePartLeadTime to check for the existance of the part_no in amd_sent_to_a2a with any action_code.
/*   
/*   fixed deleteLocPartLeadTime to check for the existance of the part_no in amd_sent_to_a2a with any action_code.
/*   
/*   
/*   
/*   
/*   
/*   
/*   
/*   
/*   
/*   
/*      Rev 1.150   Nov 28 2006 11:57:46   zf297a
/*   Fixed insertInvInfo - for INSERT_ACTION or UPDATE_ACTION check to see if the part is in amd_sent_to_a2a with action_code <> DELETE_ACTION then insert it into tmp_a2a_inv_info.  For DELETE_ACTION's check to see if the part is in amd_sent_to_a2a with any action_code then insert it into tmp_a2a_inv_info
/*   
/*      Rev 1.149   Nov 28 2006 11:50:18   zf297a
/*   Fixed insertTmpA2AOrderInfo - for the INSERT_ACTION or UPDATE_ACTION check to see if the part exists in amd_sent_to_a2a with an action_code <> DELETE_ACTION and if it meets the include criteria then insert it into the tmp_a2a tables.  For the DELETE_ACTION check to see if the part exists in amd_sent_to_a2a with any action_code, if it does then insert it into the tmp_a2a table.
/*   
/*      Rev 1.148   Nov 28 2006 11:32:08   zf297a
/*   Fixed insertRepairInvInfo - for INSERT_ACTION or UPDATE_ACTION check to see if the part is in amd_sent_to_a2a with action_code <> DELETE_ACTION then insert it into tmp_a2a_repair_inv_info.  For DELETE_ACTION's check to see if the part is in amd_sent_to_a2a with any action_code then insert it into tmp_a2a_repair_inv_info.
/*   
/*   Fixed insertRepairInfo  - for INSERT_ACTION or UPDATE_ACTION check to see if the part is in amd_sent_to_a2a with action_code <> DELETE_ACTION then insert it into tmp_a2a_repair_info.  For DELETE_ACTION's check to see if the part is in amd_sent_to_a2a with any action_code then insert it into tmp_a2a_repair_info.
/*   
/*      Rev 1.147   Nov 28 2006 10:26:50   zf297a
/*   Fixed insertTmpA2AInTransits for deletes - only check that the part has been sent using isPartSent - which ignores the action_code and just looks for the part_no in amd_sent_to_a2a.
/*   
/*      Rev 1.146   Nov 22 2006 13:28:02   zf297a
/*   For initA2ABackorderInfo use spo_prime_part_no
/*   
/*      Rev 1.145   Nov 10 2006 10:50:22   zf297a
/*   Fixed generation of line for tmp_a2a_order_info_line
/*   
/*      Rev 1.144   Nov 01 2006 12:52:18   zf297a
/*   Resequenced pError_location values
/*   
/*      Rev 1.143   Nov 01 2006 09:30:50   zf297a
/*   Fixed initA2ABomDetails us use spo_prime_part_no's.  Moved the opening of "Test Data" and "All the Data" to separate procedure with writeMsg's to log the event.
/*   
/*      Rev 1.142   Oct 26 2006 12:07:38   zf297a
/*   implemented procedure deleteSentToA2AChildren.
/*   
/*      Rev 1.141   Oct 25 2006 10:38:46   zf297a
/*   start_dt is now a constant - so changed all variable names to upper case.  Implemented the get functions for the constants so these constants can be used in SQL queries in TOAD or sqlPlus.
/*   
/*      Rev 1.140   Oct 20 2006 12:21:34   zf297a
/*   Implemented interface isPartSent and isPartSentYorN
/*   
/*      Rev 1.140   Oct 20 2006 12:18:30   zf297a
/*   Implemented interface isPartSent and isPartSentYorN
/*   
/*      Rev 1.139   Oct 04 2006 15:42:40   zf297a
/*   Fixed isPartRepariable to use the preferred smr_code - ie smr_code_cleaned if it is not null and then smr_code.  Used amd_utils.isPartRepairable in a2a_pkg.isPartValid so they use common code.
/*   
/*      Rev 1.138   Sep 12 2006 14:37:30   zf297a
/*   For all initA2A routines use the action_code of the amd data source whenever it has a value of DELETE_ACTION, otherwise the action_code from the amd_sent_to_a2a is used.  If a part has been deleted from SPO the A2A should always be deleted too - that's why amd_sent_to_a2a.action_code is sent for all other cases.  For INSERT's or UPDATE's the A2A only sends an INSERT - if the data is already there the system will update it.
/*   
/*      Rev 1.137   Sep 12 2006 11:11:06   zf297a
/*   Added defaults for all arguments to the errorMsg procedure.  Enhanced the errorMsg procedure by enabling dbms_output when this procedure has an error.
/*   For the insertTmpA2AOrderInfo made sure the delete_action was used for any deleted order and the delete_action was used for any part that has been deleted from the SPO otherwise use whatever is in amd_on_order for this order number and part_no.
/*   
/*      Rev 1.136   Sep 05 2006 12:40:12   zf297a
/*   Renumbered pError_location's values
/*   
/*      Rev 1.135   Sep 05 2006 10:27:52   zf297a
/*   Make sure part lead time and part pricing get deleted at the right time
/*   
/*      Rev 1.134   Aug 31 2006 11:57:52   zf297a
/*   removed errorMsg function
/*   implemented interface for initA2ADemands
/*   fixed format for minutes: MI
/*   changed initA2A routines to use the action_code from the amd_sent_to_a2a table for the corresponding spo_prime_part_no
/*   
/*      Rev 1.133   Aug 28 2006 21:44:18   zf297a
/*   Fixed getScheduledReceiptDate and patched errorMsg - was producing a numeric error.
/*   
/*      Rev 1.132   Aug 18 2006 15:42:54   zf297a
/*   Implemented interfaces processExtForececast and initA2AExtForecast.  Fixed processOnOrder: literal in writeMsg + added order by clause for both cursors.
/*   Fixed action_code for doInsert - always INSERT for included parts and always DELETE for excluded parts, which will make sure they do not exist in SPO.
/*   Changed loadAll to use initA2AExtForecast.
/*   
/*      Rev 1.131   Aug 11 2006 14:27:42   zf297a
/*   Fixed action_code for doInsert procedure
/*   
/*      Rev 1.130   Aug 10 2006 14:38:22   zf297a
/*   Fixed the errorMsg routines to use dbms_output when an exception occurs and then to raise the exception again.
/*   Implemented showReason for isPartValid and isPartValidYorN.  I elimitedn the check of mDebug, since the debugMsg already checks this boolean variable.  Also, if the part passes a test, there is nothing done, but if it fails the test, debugmsg will log the reason to amd_load_details.  debugMsg limits the number of messages recorded by the public variable mDebugThreshold .
/*   Renumbered the pError_location params for the entire package. 
/*   Record all excluded parts to the amd_load_details table.
/*   
/*      Rev 1.129   Aug 04 2006 12:56:56   zf297a
/*   Moved getDueDate to be a public function and added arguments part_no and order_date to its interface.
/*   
/*      Rev 1.128   Aug 04 2006 11:09:30   zf297a
/*   Fixed function includeOrder - retrieved the scheduled_receipt_date before doing compare.
/*   
/*      Rev 1.127   Jul 13 2006 11:48:10   zf297a
/*   Removed converting of part_no to spo_prime_part_no for tmp_a2a_backorder_info - the query that is used to create the xml will do the summation to spo_prime_part_no
/*   
/*      Rev 1.126   Jul 11 2006 14:29:58   c402417
/*   Added the SpoPrimePart function to load all for AmdBackorderSum. And modify the load all for amd_in_transit to amd_in_transit_sum.
/*   
/*      Rev 1.125   Jun 21 2006 09:55:34   zf297a
/*   When doing initA2AOrderInfo make sure the input is sorted by gold_order_number, part_no, and order_date.  By doing this, the genereated line number will be in sync with the order_date 1,2,......N where 1 is the oldest order_date and N is the most recent.
/*   
/*      Rev 1.124   Jun 21 2006 08:51:34   zf297a
/*   Added unique line number for every gold_order_number / part_no pair
/*   
/*      Rev 1.123   Jun 19 2006 10:44:32   zf297a
/*   fixed processOrder - removed erroneous if test. Added some diagnostic info for filters
/*   
/*      Rev 1.122   Jun 08 2006 13:22:34   zf297a
/*   added package name to key1 of amd_load_details for procedure version and moved revision to key2 of amd_load_details.
/*   
/*      Rev 1.121   Jun 08 2006 12:15:24   zf297a
/*   changed getSiteLocation to getSpoLocation in where clause of loadAll for tmp_a2a_demads
/*   
/*      Rev 1.120   Jun 07 2006 21:00:52   zf297a
/*   used getSpoLocation for tmp_a2a_backorder_info and tmp_a2a_demands.  switched to writeMsg instead of dbms_output.  Use mta_truncate_table instead of execute immediate.
/*   
/*      Rev 1.119   May 17 2006 15:00:08   zf297a
/*   removed start_date from on_order_filter
/*   
/*      Rev 1.118   May 17 2006 14:25:20   zf297a
/*   Using amd_on_order_date_filters_pkg routines for on_order date filtering
/*   
/*      Rev 1.117   May 16 2006 12:11:24   zf297a
/*   for initA2AInvInfo routines added the union of amd_rsp_sum to all the appropriate cursors.
/*   
/*      Rev 1.116   May 12 2006 13:58:36   zf297a
/*   Removed deletesOk from the wasPartSent interface.  Now using a global variable mblnSendAllData, which has its own getter and setter.
/*   Changed all init routines to include DELETED action codes and to use all part_no's contained in amd_sent_to_a2a that also have a spo_prime_part_no.
/*   
/*      Rev 1.115   May 12 2006 10:23:12   zf297a
/*   Allowed for A2A part delete transactions to be sent again
/*   
/*      Rev 1.114   May 12 2006 09:58:24   zf297a
/*   Changed processPart so that it sends "deleted" parts as A2A deletes.
/*   
/*      Rev 1.113   Apr 27 2006 12:27:04   zf297a
/*   processBackorder needed an EXIT when backOrder%NOTFOUND to terminate the LOOP otherwise Oracle would issue a ORA-00600 error with a 4454 parameter - meaning the PL/SQL had an infinite loop
/*   
/*      Rev 1.112   Apr 27 2006 08:15:06   zf297a
/*   added system_id to the procedure loadAll
/*   
/*      Rev 1.111   Apr 26 2006 10:05:24   zf297a
/*   Fixed check for an active job at the begining of procedure loadAll
/*   
/*      Rev 1.110   Apr 26 2006 09:28:42   zf297a
/*   Get theJob when the loadAll procedure is started or restarted.
/*   
/*      Rev 1.109   Apr 26 2006 09:23:14   zf297a
/*   Added batch_job and batch_job_steps tracking for the procedure loadAll
/*   
/*      Rev 1.108   Apr 24 2006 14:57:10   zf297a
/*   Fixed isNsnInRblPairs and isNsnInIsgPairs: used cursors since queries could return more than one row.
/*   
/*   Fixed errorMsg to ignore erros when a commit fails, which means an SQL select or DML statement was being executed and "commits" are not allowed then.  
/*   
/*      Rev 1.107   Apr 24 2006 13:28:50   zf297a
/*   Fixed isPartValid by changing the isNsnValid to allow for the nsn to be in amd_rbl_pairs OR  in bssm_isg_pairs.   Previous this was an AND condition.
/*   
/*   Also, started using amd amd_rlb_pairs instead of bssm_rlb_pairs.
/*   
/*      Rev 1.106   Mar 16 2006 23:15:20   zf297a
/*   Added additional filters to isPartValid
/*   
/*      Rev 1.105   Mar 03 2006 14:43:20   zf297a
/*   Implemented the loadAll procedure - this loads all the a2a data from amd
/*   
/*      Rev 1.104   Feb 15 2006 13:39:06   zf297a
/*   Added cur ref's for all init and byDate routines + a common process routine to make sure everything is done the same no matter what selection criteria is used.
/*   
/*      Rev 1.103   Feb 15 2006 10:12:30   zf297a
/*   Fixed InitPartInfo by date: If the part is NOT valid set the action_code to delete (valid parts were getting the action_code set to delete)
/*   
/*      Rev 1.102   Feb 13 2006 10:56:24   zf297a
/*   Added wasPartSent to InsertLocPartLeadTime and UpdateLocPartLeadTime
/*   
/*      Rev 1.101   Jan 06 2006 07:08:10   zf297a
/*   Fixed initA2APartInfo: added isPartValid test
/*   
/*      Rev 1.100   Jan 04 2006 09:14:32   zf297a
/*   For initA2ABomDetail and initA2ABackorderInfo made sure that the part has been sent - i.e. it exists in the amd_sent_to_a2a table and the action_code is not DELETE.
/*   
/*      Rev 1.99   Jan 04 2006 09:01:44   zf297a
/*   Added two overloaded procedures initA2ABackorderInfo which can accept a list of parts or a range of dates like the othe initA2A procedures.
/*   
/*      Rev 1.98   Jan 03 2006 12:44:14   zf297a
/*   Added date range to procedures 
/*   initA2AInvInfo
/*   initA2ARepairInvInfo
/*   initA2AInTransits
/*   initA2ARepairInfo
/*   initA2AOrderInfo
/*   initA2APartInfo
/*   initA2ABomDetail
/*   
/*   
/*      Rev 1.96   Dec 30 2005 01:32:08   zf297a
/*   added initA2ABomDetail by date
/*   
/*      Rev 1.95   Dec 29 2005 16:37:54   zf297a
/*   added initA2A by date procedures for PartInfo, OrderInfo, InvInfo, RepairInfo, InTransits, and RepairInvInfo
/*   
/*      Rev 1.94   Dec 16 2005 09:09:48   zf297a
/*   Removed erroneous reference to tmp_a2a_parts, which is not being used.
/*   
/*      Rev 1.93   Dec 14 2005 11:41:58   zf297a
/*   Fixed updateA2ApartInfo to use the correct rcm_ind.
/*   
/*      Rev 1.92   Dec 14 2005 10:39:08   zf297a
/*   Fixed isPlannerCodeValid - added check for a null planner code.
/*   
/*      Rev 1.91   Dec 07 2005 12:28:42   zf297a
/*   Now handle buffer overflow for dbms_output by disabling the output when this exception occurs.  Also, log the reason for isPartValid's criteria for returning a FALSE using debugMsg.
/*   
/*      Rev 1.90   Dec 07 2005 09:50:06   zf297a
/*   Fixed wasPartSent - checked to make sure the spo_prime_part_no is not null
/*   
/*      Rev 1.89   Dec 05 2005 13:40:54   zf297a
/*   Make sure the part_no is not null before trying to insert or update the tmp_a2a_bom_detail table.
/*   
/*      Rev 1.88   Dec 05 2005 13:29:26   zf297a
/*   Fixed retrieval of time_to_repair from amd_part_locs to allow for the no_data_found exception.
/*   
/*      Rev 1.87   Dec 01 2005 10:26:18   zf297a
/*   made sure spo_prime_part_no is not null before inserting into tmp_a2a_bom_detail
/*   
/*      Rev 1.86   Nov 30 2005 15:09:20   zf297a
/*   added type to errormsg of exception handler for insertTmpA2AInTransits.doUpdate 
/*   
/*      Rev 1.85   Nov 30 2005 15:03:46   zf297a
/*   added type qualifier for tmp_a2a_in_transits for doUpdate
/*   
/*      Rev 1.84   Nov 30 2005 11:32:16   zf297a
/*   added truncate of the tmp_a2a_bom_detail table to the initA2ABomDetail procedure.
/*   
/*      Rev 1.83   Nov 30 2005 10:54:08   zf297a
/*   added amd_test_parts to deletePartInfo.  implemented populateBomDetail.
/*   
/*      Rev 1.82   Nov 30 2005 09:11:50   zf297a
/*   Added isPartValid test when inserting tmp_a2a_repair_info.  Added exception handlers for duplicate keys for function insertTmpA2AInTransits
/*   
/*      Rev 1.81   Nov 15 2005 11:51:52   zf297a
/*   Use cleaned fields for smr_code and planner_code.  Add check for -14552
/*   
/*      Rev 1.80   Nov 10 2005 10:33:26   zf297a
/*   Implemented deleteInvalidParts.  Changed all literal of 'D' to amd_defaults.DELETE_ACTION.  Added "where action_code != amd_defaults.DELETE_ACTION" to all subqueries retrieving part_no's from amd_sent_to_a2a.
/*   
/*   Enhanced the debugMsg routine to ignore exception -14551, where a commit is not allowed during a query.  This exception could occur if some fo the YorN functions are used in a Select query and debug is turned on.
/*   
/*      Rev 1.79   Nov 09 2005 11:10:18   zf297a
/*   Implemented interfaces:  wasPartSentYorN, isPartValidYorN, isPlannerCodeAssign2UserIdYorN, and isNslYorN.
/*   
/*      Rev 1.78   Nov 09 2005 10:35:04   zf297a
/*   Added amd_test_parts table to make it easier to switch test parts.
/*   
/*      Rev 1.77   Oct 28 2005 08:39:36   zf297a
/*   In validateData routine, remove the to_char function for mtbf
/*   
/*      Rev 1.76   Oct 27 2005 15:45:10   c402417
/*   Changed expected_completion_date in tmp_a2a_repair_info to get date from amd_in_repair.repair_need_date.
/*   
/*      Rev 1.75   Oct 27 2005 10:23:10   zf297a
/*   Implemented deletePartInfo so all parts can be deleted or just a set of test cases can be deleted.
/*   
/*      Rev 1.74   Oct 21 2005 07:26:32   zf297a
/*   Added amd_partprime_pkg.DiffPartToPrime to initA2APartLeadTime
/*   
/*      Rev 1.73   Oct 20 2005 11:36:08   zf297a
/*   Removed converting of order_lead_time_cleaned from months to calendar days, since it is already being done by the amd_load.loadGold procedure.
/*   Removed converting of order_lead_time from business days to calendar days, since it is already being don by the amd_load.loadGold procedure.
/*   Removed converting time_to_repair_off_base_cleand from months to calendar days, since it is already being done by the amd_load.loadGold procedure.
/*   Added check that the part was sent before inserting any tmp_a2a_parts_lead_time rows.
/*   
/*      Rev 1.71   Oct 19 2005 11:46:08   zf297a
/*   Changed the arg list for insertTmpA2AOrderInfo and folded the procedure insertTmpA2AOrderInfoLine into insertTmpA2AOrderInfo.  Checked sched_receipt_date and if it is null compute a new due_date based on the order_lead_time (cleaned take precedence).
/*   
/*      Rev 1.70   Oct 18 2005 14:57:08   zf297a
/*   Enhanced debuging of isPartValid
/*   
/*      Rev 1.69   Oct 13 2005 10:18:36   zf297a
/*   Reinstated the in clause for the testParts.  Added additional counters for initA2AOrderInfo.  (include function still needs to be verified).
/*   
/*      Rev 1.68   Oct 11 2005 09:15:34   c402417
/*   changed the where clause in tmp_a2a_repair_info.
/*   
/*      Rev 1.67   Oct 10 2005 09:34:22   zf297a
/*   added price to tmp_a2a_part_info and all insert / update routines for tmp_a2a_part_info
/*   
/*      Rev 1.66   Oct 07 2005 12:18:22   zf297a
/*   Added cage_code to tmp_a2a_order_info and tmp_a2a_part_lead_time.  Created a separate procedure to init tmp_a2a_part_lead_time.
/*   
/*      Rev 1.65   Oct 06 2005 12:22:42   zf297a
/*   Changed set of part test cases.
/*   
/*      Rev 1.64   Oct 05 2005 16:08:22   c402417
/*   added condition to populate data into tmp_a2a_repair_info when ORDER_NO are not in 'RETAIL' or 'II%'.
/*   
/*      Rev 1.63   Sep 29 2005 12:47:20   zf297a
/*   Added check to exclude planner_code of AFD
/*   
/*      Rev 1.62   Sep 13 2005 12:54:48   zf297a
/*   For the includeOrder function removed the voucher test at the start.  If a param is not present for a given voucher, all param will be null, which will result in the order being "included"
/*   
/*      Rev 1.61   Sep 09 2005 13:33:30   zf297a
/*   Changed OrderInfo routines to use getSpoLocation instead of getSiteLocation per Laurie's directions.
/*   
/*      Rev 1.60   Sep 09 2005 11:11:20   zf297a
/*   Changed insertInvInfo to use spo_location, which comes from amd_spare_networks.spo_location.  However, the a2a transactions still refers to it as site_location so that name is left along for the tmp_a2a_inv_info table.
/*   
/*      Rev 1.59   Sep 08 2005 10:30:42   zf297a
/*   added date filter for tmp_a2a_order_info and tmp_a2a_order_info_line ;
/*   
/*      Rev 1.58   Aug 29 2005 14:43:52   zf297a
/*   modified insertA2AOrderInfo to filter by order_date and use the earliest date.
/*   
/*      Rev 1.57   Aug 26 2005 15:10:08   zf297a
/*   Qualified init routines with   and part_no in (select part_no from amd_sent_to_a2a) to make sure the part was sent.
/*   
/*      Rev 1.56   Aug 26 2005 14:51:34   zf297a
/*   Added function isNsnInIsgPairs
/*   
/*      Rev 1.56   Aug 19 2005 12:36:10   zf297a
/*   removed functions bizDays2CalendarDays, months2CalendarDays, and getSiteLocation and put them in amd_utils
/*   
/*      Rev 1.55   Aug 15 2005 14:45:48   zf297a
/*   added initA2ASpoUsers
/*   
/*      Rev 1.54   Aug 12 2005 13:06:44   zf297a
/*   Used getAssignedPlannerCode to determine the planner_code to be used for a2a_part_info - either the current planner or the default planner code.
/*   
/*      Rev 1.53   Aug 11 2005 12:41:54   zf297a
/*   Changed name of the routines that convert business days to calendar days and months to calendar days.  Used these conversion functions in the initA2APartInfo
/*   
/*      Rev 1.52   Aug 10 2005 13:48:04   zf297a
/*   Added commits for the init routines per every COMMIT_THRESHOLD times.  Added validateData to insertPartInfo.
/*      
/*      Rev 1.51   Aug 10 2005 10:00:18   zf297a
/*   Implemented functions convertCleanedOrderLeadTime and convertOrderLeadTime
/*   
/*      Rev 1.50   Aug 10 2005 09:27:04   zf297a
/*   Checked if a planner_code is assigned to a UserId and converted rcm_ind of T to R.
/*   
/*      Rev 1.49   Aug 09 2005 11:54:02   zf297a
/*   Fixed validateData for insertPartInfo: lineNo needed to be initialized and also coneverted to a character when an error is reported via amd_load_details.
/*   
/*      Rev 1.48   Aug 09 2005 10:05:08   zf297a
/*   Enhanced debugMsg by adding a lineNo argument to the interface  and a commit to the implementation.
/*   
/*      Rev 1.47   Aug 09 2005 09:46:54   zf297a
/*   Added validation of input for insertPartInfo, added doUpdate for insertRespSiteAssetMgr, and added substr for the email and name columns so they will not exceed 32 characters.
/*   
/*      Rev 1.46   Aug 04 2005 14:41:12   zf297a
/*   Implemented insertTmpA2ASpoUsers
/*   
/*      Rev 1.45   Aug 03 2005 14:53:56   zf297a
/*   Added sched_receipt_data for tmp_a2a_order_info_line
/*   
/*      Rev 1.44   Aug 02 2005 13:25:50   zf297a
/*   Added debug and dbms_output to isPartValid
/*   
/*      Rev 1.43   Jul 28 2005 10:52:40   zf297a
/*   Applied work around for the Oracle bug that caused this package not to compile with debug.  A view was created that was identical to the cursor partInfo used in initA2APartInfo.  This view is used as the "type" for the rec parameter used by the procedure processPart (partInfo_v%ROWTYPE).  Now the package will compile in "debug" without an error.
/*
/*      Rev 1.42   Jul 22 2005 14:34:34   zf297a
/*   Still getting the compiler error with Toad.  So, I tried eliminating all anonymous blocks in exception handlers, but the problem still persists: Toad displays this message: "Message Code Lang=Oracle was not found. Please verify and re-enter."
/*
/*      Rev 1.41   Jul 22 2005 14:20:36   zf297a
/*   Removed the anonymous block in processPart that declares the smr_code and moved the smr_code up so it belongs to the procedure.  This change enables Toad to compile the package with debug without an error.  For some reason Toad could not handle this syntax.
/*
/*      Rev 1.40   Jul 22 2005 12:24:52   zf297a
/*   Fixed wasPartSent - need paren's around the SQL OR condition otherwise more than one row would be returned.
/*
/*      Rev 1.39   Jul 20 2005 13:46:06   zf297a
/*   Delete the part from the spo via deletePartInfo when it no longer meets the criteria of a "spo part"
/*
/*   Make sure that the part was sent before trying to delete it from the spo. (deletePartInfo now uses wasPartSent)
/*
/*      Rev 1.38   Jul 20 2005 07:46:16   zf297a
/*   using only bems_id for a2a for spo users
/*
/*      Rev 1.37   Jul 19 2005 14:17:58   zf297a
/*   added spoUser procedure to create the a2a transactions for the spo_user
/*
/*      Rev 1.36   Jul 15 2005 10:53:00   zf297a
/*   do not insert into tmp_a2a tables if site_location is null
/*
/*      Rev 1.35   Jul 11 2005 12:38:44   zf297a
/*   added function initA2AInvInfo
/*
/*      Rev 1.34   Jul 11 2005 12:26:20   zf297a
/*   added function initA2AInTransits
/*
/*      Rev 1.33   Jul 11 2005 12:14:52   zf297a
/*   added function initA2ARepairInfo
/*
/*      Rev 1.32   Jul 11 2005 11:54:00   zf297a
/*   updated pError_location (10, 20, 30,...... 450)
/*
/*      Rev 1.31   Jul 11 2005 11:47:46   zf297a
/*   added procedure insertTmpA2AInTransits
/*
/*      Rev 1.30   Jul 11 2005 11:16:50   zf297a
/*   Made wasPartSent and isPartValid public functions
/*
/*      Rev 1.27   Jul 11 2005 10:37:36   zf297a
/*   added procedure to insertTmpA2AOrderInfo and insertTmpA2AOrderInfoLine
/*
/*      Rev 1.26   Jul 06 2005 12:52:58   zf297a
/*   Checked isPlannerCodeValid for all parts
/*
/*      Rev 1.25   Jun 22 2005 15:02:24   c970183
/*   Added flexibility to the Init routines so that the test case can be inserted, changed, or deleted.
/*
/*      Rev 1.24   Jun 10 2005 11:20:02   c970183
/*   Streamlined insertSiteRespAssetMgr, insertInvInfo, and insertRepairInfo.
/*
/*      Rev 1.23   Jun 09 2005 15:03:26   c970183
/*   implemented insert, update, and logical delete for tmp_a2a_site_resp_asset_mgr
/*
/*      Rev 1.22   Jun 08 2005 08:03:50   c970183
/*   Qualified the use of createPartInfo arguments to stop multiple rows from being selected by the getPartInfo routine.
/*
/*      Rev 1.21   May 18 2005 08:57:08   c970183
/*   Added getIndenture public method.  Modified inita2a to use getIndenture.
/*
/*      Rev 1.20   May 18 2005 08:25:50   c970183
/*   Fixed indenture.  Added function name to mArgs debug variable
/*
/*      Rev 1.19   May 13 2005 14:36:06   c970183
/*   Added procedure createPartInfo.  For a given part_no create an update transaction in tmp_a2a_part_info.  action_code may be overridden too.
/*
/*      Rev 1.18   May 02 2005 12:57:12   c970183
/*   Completed part validation routines.
/*
/*      Rev 1.17   Apr 28 2005 14:05:16   c970183
/*   Added part_no filter: if it is not an NSL send it as an A2A transaction.  If it is an NSL, validate that it meets the addional criteria to be sent.
/*
/*      Rev 1.16   Apr 27 2005 07:35:34   c970183
/*   For deletePartPricing - set price_type to AN_ORDER and price to zero.
/*
/*      Rev 1.15   Apr 22 2005 13:57:08   c970183
/*   added return success to all routines handling dup_val_on_index exceptions.
/*
/*      Rev 1.14   Apr 22 2005 10:49:44   c970183
/*   added update's to gaurantee function works.  However, if the unique keys are removed in the future, the update will never get executed and could be removed.
/*
/*      Rev 1.13   Apr 22 2005 08:06:50   c970183
/*   add mArgs to errorMsg
/*
/*      Rev 1.10   Mar 25 2005 11:46:28   c970183
/*   Fixed the update and delete routines to insert data into the tmp_a2a tables and to have the appropriate action_codes: update or delete.
/*
/*      Rev 1.9   03 Sep 2004 10:19:16   c970183
/*   Added check for SQL%ROWCOUNT = 0 after all updates.  This is an error situation that should not occurs.  Also. resequenced pError_location parameters
/*
/*      Rev 1.8   03 Sep 2004 09:59:56   c970183
/*   removed substr for pError_location - its a number not a string
/*
/*      Rev 1.6   03 Sep 2004 08:59:04   c970183
/*   Added substr's to error logging routine to make sure that it is never trying to insert strings longer that the columns that will contain the data: i.e. it should not cause an error when it is supposed to help find errors.
/*
/*      Rev 1.5   27 Aug 2004 14:33:06   c970183
/*   Added constants 'NEW BUY', 'REPAIR', and 'ORDER'.
/*
/*      Rev 1.4   12 Aug 2004 14:54:02   c970183
/*   implemented updatePartInfo function
/*
/*      Rev 1.3   12 Aug 2004 14:41:04   c970183
/*   removed initial prototypes
/*
/*      Rev 1.2   12 Aug 2004 14:30:46   c970183
/*   added insert, update, and delete functions for a2a tables.  implemented insert functions for part data.
/*
/*      Rev 1.1   Jul 20 2004 07:02:32   c970183
/*   Added functions to generate current year.
/*
/*      Rev 1.0   Jul 19 2004 14:10:48   c970183
/*   Initial revision.
    */

 THIS_PACKAGE CONSTANT CHAR(7) := 'a2a_pkg' ;
 mArgs VARCHAR2(2000) ;
 prime_ind VARCHAR2(1) ;
 prime_part AMD_SPARE_PARTS.part_no%TYPE ;
 mblnSendAllData BOOLEAN := FALSE ;

 
 COMMIT_THRESHOLD     CONSTANT NUMBER := 250 ;
 DEBUG_THRESHOLD	  CONSTANT NUMBER := 5000 ;
  
 includeCnt NUMBER := 0 ;
 excludeCnt NUMBER := 0 ;
 
	  


 CURSOR managers IS
 SELECT * FROM AMD_PLANNER_LOGONS ;

 cursor managersNoUser is
	select distinct planner_code, amd_defaults.GetParamValue('nsn_logon_id') logon_id, '3' data_source from amd_national_stock_items
	where planner_code not in (select distinct planner_code from amd_planner_logons)
	and prime_part_no in (select distinct spo_prime_part_no from amd_sent_to_a2a where action_code <> 'D')
	and substr(nsn,1,3) <> 'NSL'
	and planner_code is not null
	union
    select distinct planner_code_cleaned planner_code, amd_defaults.GetParamValue('nsn_logon_id') logon_id, '3' data_source from amd_national_stock_items
	where planner_code not in (select distinct planner_code from amd_planner_logons)
	and prime_part_no in (select distinct spo_prime_part_no from amd_sent_to_a2a where action_code <> 'D')
	and substr(nsn,1,3) <> 'NSL'
	and planner_code_cleaned is not null	
	union
	select distinct planner_code, amd_defaults.GetParamValue('nsl_logon_id') logon_id, '3' data_source from amd_national_stock_items
	where planner_code not in (select distinct planner_code from amd_planner_logons)
	and prime_part_no in (select distinct spo_prime_part_no from amd_sent_to_a2a where action_code <> 'D')
	and substr(nsn,1,3) = 'NSL'
	and planner_code is not null
	union
	select distinct planner_code_cleaned planner_code, amd_defaults.GetParamValue('nsl_logon_id') logon_id, '3' data_source from amd_national_stock_items
	where planner_code not in (select distinct planner_code from amd_planner_logons)
	and prime_part_no in (select distinct spo_prime_part_no from amd_sent_to_a2a where action_code <> 'D')
	and substr(nsn,1,3) = 'NSL'
	and planner_code_cleaned is not null	
	union
	select amd_defaults.GetParamValue('nsn_planner_code')  planner_code, amd_defaults.GetParamValue('nsn_logon_id') logon_id, '3' data_source from dual
	union
	select amd_defaults.GetParamValue('nsl_planner_code')  planner_code, amd_defaults.GetParamValue('nsl_logon_id') logon_id, '3' data_source  from dual
	order by planner_code, logon_id ;

 CURSOR testParts IS
  SELECT sp.mfgr,
      sp.part_no,
      sp.NOMENCLATURE,
      sp.nsn,
      sp.order_lead_time,
      sp.order_lead_time_defaulted,
      sp.unit_cost,
      sp.unit_cost_defaulted,
      sp.unit_of_issue,
      nsi.unit_cost_cleaned,
      nsi.order_lead_time_cleaned,
      nsi.planner_code,
      nsi.planner_code_cleaned,
      nsi.mtbdr,
      nsi.mtbdr_cleaned,
      nsi.smr_code,
      nsi.smr_code_cleaned,
      nsi.smr_code_defaulted,
      nsi.nsi_sid,
      nsi.TIME_TO_REPAIR_OFF_BASE_CLEAND
  FROM AMD_SPARE_PARTS sp,
    AMD_NATIONAL_STOCK_ITEMS nsi
  WHERE sp.nsn = nsi.nsn
     AND sp.action_code != Amd_Defaults.DELETE_ACTION
     AND sp.part_no IN (SELECT part_no FROM AMD_TEST_PARTS) ;


	PROCEDURE writeMsg(
				pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
				pError_location IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
				pKey1 IN VARCHAR2 := '',
				pKey2 IN VARCHAR2 := '',
				pKey3 IN VARCHAR2 := '',
				pKey4 IN VARCHAR2 := '',
				pData IN VARCHAR2 := '',
				pComments IN VARCHAR2 := '')  IS
	BEGIN
		Amd_Utils.writeMsg (
				pSourceName => 'a2a_pkg',	
				pTableName  => pTableName,
				pError_location => pError_location,
				pKey1 => pKey1,
				pKey2 => pKey2,
				pKey3 => pKey3,
				pKey4 => pKey4,
				pData    => pData,
				pComments => pComments);
	END writeMsg ;

	function isNumeric(p_string in varchar2) return boolean is
			 l_number number ;
	begin
		 l_number := p_string ;
		 return true ;
	exception when others then
			  return false ;
	end isNumeric ;

 -- do a forward declaration of ErrorMsg, since it will be wrapped by a procedure of the
 -- same name

	 PROCEDURE ErrorMsg(
	     pSqlfunction IN AMD_LOAD_STATUS.SOURCE%TYPE := 'errorMsg',
	     pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE := 'noname',
	     pError_location AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE := -100,
	     pKey_1 IN AMD_LOAD_DETAILS.KEY_1%TYPE := '',
	      pKey_2 IN AMD_LOAD_DETAILS.KEY_2%TYPE := '',
	     pKey_3 IN AMD_LOAD_DETAILS.KEY_3%TYPE := '',
	     pKey_4 IN AMD_LOAD_DETAILS.KEY_4%TYPE := '',
	     pKeywordValuePairs IN VARCHAR2 := '') IS
		 
	     key5 AMD_LOAD_DETAILS.KEY_5%TYPE := pKeywordValuePairs ;
		 
	 BEGIN
		  ROLLBACK;
		  IF key5 = '' or key5 is null THEN
		     key5 := pSqlFunction || '/' || pTableName ;
		  ELSE
            if key5 is not null then
                if length(key5) + length('' || pSqlFunction || '/' || pTablename) < 50  then           
		            key5 := key5 || ' ' || pSqlFunction || '/' || pTableName ;
                end if ;
            end if ;
		  END IF ;
		  -- use substr's to make sure that the input parameters for InsertErrorMsg and GetLoadNo
		  -- do not exceed the length of the column's that the data gets inserted into
		  -- This is for debugging and logging, so efforts to make it not be the source of more
		  -- errors is VERY important
		  
		  dbms_output.put_line('insertError@' || pError_location) ;
		  
		  Amd_Utils.InsertErrorMsg (
		    pLoad_no => Amd_Utils.GetLoadNo(
		      pSourceName => SUBSTR(pSqlfunction,1,20),
		      pTableName  => SUBSTR(pTableName,1,20)),
		    pData_line_no => pError_location,
		    pData_line    => 'a2a_pkg.' || mArgs,
		    pKey_1 => SUBSTR(pKey_1,1,50),
		    pKey_2 => SUBSTR(pKey_2,1,50),
		    pKey_3 => SUBSTR(pKey_3,1,50),
		    pKey_4 => SUBSTR(pKey_4,1,50),
		    pKey_5 => TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS') ||
		         ' ' || substr(key5,1,50),
		    pComments => SUBSTR('sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')',1,2000));
		    COMMIT;
	   
	 EXCEPTION WHEN OTHERS THEN
	   dbms_output.enable(10000) ;
       dbms_output.put_line('sql error=' || sqlcode || ' ' || sqlerrm) ;
	   if pSqlFunction is not null then dbms_output.put_line('pSqlFunction=' || pSqlfunction) ; end if ;
	   if pTableName is not null then dbms_output.put_line('pTableName=' || pTableName) ; end if ;
	   if pError_location is not null then dbms_output.put_line('pError_location=' || pError_location) ; end if ;
	   if pKey_1 is not null then dbms_output.put_line('key1=' || pKey_1) ; end if ;
	   if pkey_2 is not null then dbms_output.put_line('key2=' || pKey_2) ; end if ;
	   if pKey_3 is not null then dbms_output.put_line('key3=' || pKey_3) ; end if ;
	   if pKey_4 is not null then dbms_output.put_line('key4=' || pKey_4) ; end if ;
	   if pKeywordValuePairs is not null then dbms_output.put_line('pKeywordValuePairs=' || pKeywordValuePairs) ; end if ;
	   raise ;
	 END ErrorMsg;
	
	 FUNCTION ErrorMsg(
	     pSqlfunction IN AMD_LOAD_STATUS.SOURCE%TYPE,
	     pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
	     pError_location AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
	     pReturn_code IN NUMBER,
	     pKey_1 IN AMD_LOAD_DETAILS.KEY_1%TYPE,
	      pKey_2 IN AMD_LOAD_DETAILS.KEY_2%TYPE := '',
	     pKey_3 IN AMD_LOAD_DETAILS.KEY_3%TYPE := '',
	     pKey_4 IN AMD_LOAD_DETAILS.KEY_4%TYPE := '',
	     pKeywordValuePairs IN VARCHAR2 := '') RETURN NUMBER IS
	     key5 AMD_LOAD_DETAILS.KEY_5%TYPE := pKeywordValuePairs ;
	 BEGIN
	  ROLLBACK;
	  IF key5 = '' THEN
	     key5 := pSqlFunction || '/' || pTableName ;
	  ELSE
	   key5 := key5 || ' ' || pSqlFunction || '/' || pTableName ;
	  END IF ;
	  -- use substr's to make sure that the input parameters for InsertErrorMsg and GetLoadNo
	  -- do not exceed the length of the column's that the data gets inserted into
	  -- This is for debugging and logging, so efforts to make it not be the source of more
	  -- errors is VERY important
	  Amd_Utils.InsertErrorMsg (
	    pLoad_no => Amd_Utils.GetLoadNo(
	      pSourceName => SUBSTR(pSqlfunction,1,20),
	      pTableName  => SUBSTR(pTableName,1,20)),
	    pData_line_no => pError_location,
	    pData_line    => 'a2a_pkg.' || mArgs,
	    pKey_1 => SUBSTR(pKey_1,1,50),
	    pKey_2 => SUBSTR(pKey_2,1,50),
	    pKey_3 => SUBSTR(pKey_3,1,50),
	    pKey_4 => SUBSTR(pKey_4,1,50),
	    pKey_5 => SUBSTR('rc=' || TO_CHAR(nvl(pReturn_code,88888)) ||
	            ' ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS') ||
	         ' ' || key5,1,50),
	    pComments => SUBSTR('sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')',1,2000));
	    COMMIT;
	    RETURN pReturn_code;
	 EXCEPTION WHEN OTHERS THEN
	     if pSqlfunction is not null then dbms_output.put_line('pSqlfunction=' ||	   pSqlfunction) ; end if ;
	     if pTableName is not null then dbms_output.put_line('pTableName=' || pTableName) ; end if ;
	     if pError_location is not null then dbms_output.put_line('pError_location=' || pError_location) ; end if ;
	     if pReturn_code is not null then dbms_output.put_line('pReturn_code=' || pReturn_code) ; end if ;
	     if pKey_1 is not null then dbms_output.put_line('pKey_1=' || pKey_1) ; end if ;
	     if pKey_2 is not null then dbms_output.put_line('pKey_2=' || pKey_2) ; end if ;
	     if pKey_3 is not null then dbms_output.put_line('pKey_3=' || pKey_3) ; end if ;
	     if pKey_4 is not null then dbms_output.put_line('pKey_4=' || pKey_4); end if ;
	     if pKeywordValuePairs is not null then dbms_output.put_line('pKeywordValuePairs=' || pKeywordValuePairs) ; end if ;
		 raise ;
	 END ErrorMsg;
	
	 PROCEDURE debugMsg(msg IN AMD_LOAD_DETAILS.DATA_LINE%TYPE, lineNo IN NUMBER) IS
	 BEGIN
	   IF mDebug THEN
		   Amd_Utils.debugMsg(pMsg => msg,pPackage => 'a2a_pkg', pLocation => lineNo) ;
		   COMMIT ; -- make sure the trace is kept
	   END IF ;
	 EXCEPTION WHEN OTHERS THEN
	 		   IF SQLCODE = -14551 OR SQLCODE = -14552 THEN
			   	  NULL ; -- cannot do a commit inside a query, so ignore the error
			   ELSE
			   	   RAISE ;
			   END IF ;
	 END debugMsg ;
	 
	 FUNCTION getSendAllData RETURN BOOLEAN IS
	 BEGIN
	 	  RETURN mblnSendAllData ;
	 END getSendAllData ;
	 
	 PROCEDURE setSendAllData(theIndicator IN BOOLEAN) IS
	 BEGIN
	 	  mblnSendAllData := theIndicator ;
	 END setSendAllData ; 
	
	
	 PROCEDURE truncateA2Atables IS
	 BEGIN
		 Mta_Truncate_Table('tmp_a2a_part_info','reuse storage');
		 Mta_Truncate_Table('tmp_a2a_part_lead_time','reuse storage');
		 Mta_Truncate_Table('tmp_a2a_part_pricing','reuse storage');
	 END truncateA2Atables ;
	 
	 FUNCTION getIndenture(smr_code_preferred IN AMD_NATIONAL_STOCK_ITEMS.SMR_CODE%TYPE) RETURN TMP_A2A_PART_INFO.indenture%TYPE IS
	 BEGIN
	   IF SUBSTR(smr_code_preferred,1,3) IN ('PBO','PAO') THEN
	    RETURN '1' ;
	   END IF ;
	   RETURN '2' ;
	 END getIndenture ;
	 FUNCTION isPartValid(partNo IN VARCHAR2, smrCode IN VARCHAR2, mtbdr IN NUMBER, plannerCode IN VARCHAR2, showReason in boolean := false) RETURN BOOLEAN IS
	
	    result BOOLEAN := FALSE ;
	    nsn AMD_SPARE_PARTS.NSN%TYPE ;
	
	    FUNCTION demandExists RETURN BOOLEAN IS
	        result NUMBER := 0 ;
	    BEGIN
	       SELECT 1 INTO result
	      FROM dual
	      WHERE EXISTS
	        (SELECT *
	       FROM AMD_DEMANDS demands, AMD_NATIONAL_STOCK_ITEMS items, AMD_SPARE_PARTS parts
	       WHERE isPartValid.partNo = parts.part_no
	       AND parts.action_code != Amd_Defaults.DELETE_ACTION
	       AND parts.nsn = items.nsn
	       AND items.ACTION_CODE != Amd_Defaults.DELETE_ACTION
	       AND items.nsi_sid = demands.nsi_sid
	       AND demands.QUANTITY > 0
	       AND demands.ACTION_CODE != Amd_Defaults.DELETE_ACTION) ;
	   	   IF result > 0 THEN
		   	  null ; -- do  nothing
		   ELSE
		  	 debugMsg('Demand does NOT exist for ' || isPartValid.partNo, 10) ;
		  	 if showReason then dbms_output.put_line('Demand does NOT exist for ' || isPartValid.partNo) ; end if ;
		   END IF ;
	       RETURN (result > 0) ;
	   EXCEPTION
	      WHEN standard.NO_DATA_FOUND THEN
	         RETURN FALSE ;
	      WHEN OTHERS THEN
	          ErrorMsg(pSqlfunction => 'select',
	             pTableName => 'demands / items',
	           pError_location => 10,
	           pKey_1 => isPartValid.partNo,
	           pKey_2 => nsn) ;
	        RAISE ;
	    END demandExists ;
	
	    FUNCTION inventoryExists RETURN BOOLEAN IS
	        result NUMBER := 0 ;
	       primePartNo AMD_NATIONAL_STOCK_ITEMS.prime_part_no%TYPE ;
	    BEGIN
	       <<getPrimePartNo>>
	       BEGIN
	        SELECT items.prime_part_no INTO primePartNo
	       FROM AMD_NATIONAL_STOCK_ITEMS items, AMD_SPARE_PARTS parts
	       WHERE isPartValid.partNo = parts.part_no
	       AND parts.nsn = items.nsn ;
	      EXCEPTION WHEN OTHERS THEN
	          ErrorMsg(pSqlfunction => 'select',
		       pTableName => 'amd_spare_parts',
		       pError_location => 20,
		       pKey_1 => isPartValid.partNo,
		       pKey_2 => nsn) ;
	        RAISE ;
	      END getPrimePartNo ;
	
	      <<doesDataExist>>
	      BEGIN
	        SELECT 1 INTO result
	       FROM dual
	       WHERE EXISTS
	         (SELECT *
	        FROM AMD_ON_HAND_INVS oh
	        WHERE primePartNo = oh.part_no
	        AND oh.ACTION_CODE != Amd_Defaults.DELETE_ACTION
	        AND oh.INV_QTY >0
	        )
	      OR EXISTS
	         (SELECT *
	          FROM AMD_IN_REPAIR ir
	       WHERE primePartNo = ir.PART_NO
	       AND ir.ACTION_CODE != Amd_Defaults.DELETE_ACTION
	       AND ir.REPAIR_QTY > 0
	       )
	      OR EXISTS
	         (SELECT *
	          FROM AMD_ON_ORDER oo
	       WHERE primePartNo = oo.PART_NO
	       AND oo.ACTION_CODE != Amd_Defaults.DELETE_ACTION
	       AND oo.ORDER_QTY > 0
	       )
	      OR EXISTS
	         (SELECT *
	          FROM AMD_IN_TRANSITS it
	       WHERE primePartNo = it.PART_NO
	       AND it.ACTION_CODE != Amd_Defaults.DELETE_ACTION
	       AND it.QUANTITY > 0
	       )  ;
	      EXCEPTION
	            WHEN standard.NO_DATA_FOUND THEN
	         NULL ;
	         WHEN OTHERS THEN
	            ErrorMsg(pSqlfunction => 'select',
		         pTableName => 'exist',
		         pError_location => 30,
		         pKey_1 => isPartValid.partNo,
		         pKey_2 => nsn) ;
	          RAISE ;
	
	      END doesDataExist ;
	      IF result > 0 THEN
		  	 null ; -- do nothing
		  ELSE
		 	debugMsg('Inventory does NOT exist for ' || isPartValid.partNo, 20) ;
	  	 	if showReason then dbms_output.put_line('Inventory does NOT exist for ' || isPartValid.partNo) ; end if ;
		  END IF ; 	 
	      RETURN (result > 0) ;
	    END inventoryExists ;
	
	    FUNCTION isPlannerCodeValid RETURN BOOLEAN IS
	        isValid BOOLEAN  := FALSE ;
	    BEGIN
		   IF plannerCode IS NOT NULL THEN
		       IF LENGTH(plannerCode) >= 2 THEN
		        isValid := UPPER(SUBSTR(plannerCode,1,2)) != 'KE' AND UPPER(SUBSTR(plannerCode,1,2)) != 'SE' ;
				IF isValid THEN
					IF LENGTH(plannerCode) >= 3 THEN
					   isValid := UPPER(SUBSTR(plannerCode,1,3)) != 'AFD' ;
					ELSE
						isValid := TRUE ;
					END IF ;
				END IF ;
		      ELSE
		         isValid := TRUE ;
		      END IF ;
		  END IF ;
	      IF isValid THEN
		  	 null ; -- do nothing
		  else
		 	debugMsg(plannerCode || ' Planner code is NOT valid for ' || isPartValid.partNo, 30) ;
	  	 	if showReason then dbms_output.put_line(plannerCode || ' Planner code is NOT valid for ' || isPartValid.partNo) ; end if ;
		  END IF ;
	      RETURN isValid ;
	    END isPlannerCodeValid ;
	
	    FUNCTION isNsnValid RETURN BOOLEAN IS
	        nsn AMD_NATIONAL_STOCK_ITEMS.nsn%TYPE ;
	       FUNCTION isNsnInRblPairs RETURN BOOLEAN IS
	            result BOOLEAN := FALSE ;
	       BEGIN
	         <<tryOldNsn>>
	         DECLARE
			   CURSOR old_nsns IS
			         SELECT old_nsn
					 FROM AMD_RBL_PAIRS 
					 WHERE old_nsn = isNsnValid.nsn ;
	         BEGIN
			 	  FOR rec IN old_nsns LOOP 
	         	  	  result := TRUE ;
					  EXIT WHEN TRUE ;
				  END LOOP ;
	         	  IF NOT result THEN
			           <<tryNewNsn>>
			           DECLARE
			             	  CURSOR new_nsns IS
			              	  SELECT new_nsn
							  FROM AMD_RBL_PAIRS 
							  WHERE new_nsn = isNsnValid.nsn ;
			           BEGIN
					   		FOR rec IN new_nsns LOOP
			             		result := TRUE ;
								EXIT WHEN TRUE ;
							END LOOP ;
			           EXCEPTION
			              WHEN OTHERS THEN
			                  ErrorMsg(pSqlfunction => 'select',
				               pTableName => 'amd_rbl_pairs',
				               pError_location => 40,
				               pKey_1 => isNsnValid.nsn) ;
			                RAISE ;
			           END tryNewNsn ;
				 END  IF ;
			 EXCEPTION WHEN OTHERS THEN
	              ErrorMsg(pSqlfunction => 'select',
			           pTableName => 'amd_rbl_pairs',
			           pError_location => 50,
			           pKey_1 => isNsnValid.nsn) ;
			     RAISE ;
			 END tryOldNsn ;
			 
		     IF result THEN
			 	null ; -- do nothing
			 ELSE
			   debugMsg(isNsnValid.nsn || ' Nsn is NOT valid for ' || isPartValid.partNo,40) ;
		 	   if showReason then dbms_output.put_line(isNsnValid.nsn || ' Nsn is NOT valid for ' || isPartValid.partNo) ; end if ;
		     END IF ;
					
	         RETURN result ;
	
	       END isNsnInRblPairs ;
		   
	       FUNCTION isNsnInIsgPairs RETURN BOOLEAN IS
	            result BOOLEAN := FALSE ;
	       BEGIN
	           <<tryOldNsn>>
	         DECLARE
	           CURSOR old_nsns IS
				   SELECT old_nsn  
				   FROM bssm_isg_pairs 
				   WHERE old_nsn = isNsnValid.nsn AND lock_sid = 0 ;
	         BEGIN
			 	  FOR rec IN old_nsns LOOP
				      result := TRUE ;
					  EXIT WHEN TRUE ;
				  END LOOP ;
			      IF NOT result THEN
		           <<tryNewNsn>>
		           DECLARE
					 CURSOR new_nsns IS
		              SELECT new_nsn FROM bssm_isg_pairs 
					  WHERE new_nsn = isNsnValid.nsn AND lock_sid = 0 ;
		           BEGIN
				   		FOR rec IN new_nsns LOOP
							result := TRUE ;
							EXIT WHEN TRUE ;
						END LOOP ;
		           EXCEPTION
		              WHEN OTHERS THEN
		                  ErrorMsg(pSqlfunction => 'select',
			               pTableName => 'bssm_isg_pairs',
			               pError_location => 60,
			               pKey_1 => isNsnValid.nsn) ;
			              RAISE ;
		           END tryNewNsn ;
				 END IF ;
			 EXCEPTION
		         WHEN OTHERS THEN
		              ErrorMsg(pSqlfunction => 'select',
		           pTableName => 'bssm_isg_pairs',
		           pError_location => 70,
		           pKey_1 => isNsnValid.nsn) ;
		            RAISE ;
				 
	         END tryOldNsn ;
			 
		     IF result THEN
		 	   null ; -- do nothing
			 ELSE
			   debugMsg('Nsn is NOT in ISG Pairs for ' || isPartValid.partNo,50) ;
		 	   if showReason then dbms_output.put_line('Nsn is NOT in ISG Pairs for ' || isPartValid.partNo) ; end if ;
			 END IF ;
	         RETURN result ;
	
	       END isNsnInIsgPairs ;
	    BEGIN
	       <<getNsn>>
	       BEGIN
	        SELECT parts.nsn INTO isNsnValid.nsn
	       FROM AMD_SPARE_PARTS parts
	       WHERE isPartValid.partNo = parts.part_no ;
	      EXCEPTION WHEN OTHERS THEN
	          ErrorMsg(pSqlfunction => 'select',
		       pTableName => 'amd_spare_parts',
		       pError_location => 80,
		       pKey_1 => isPartValid.partNo,
		       pKey_2 => nsn) ;
	        RAISE ;
	      END getNsn ;
	      RETURN isNsnInRblPairs OR isNsnInIsgPairs ;
	    EXCEPTION
	         WHEN standard.NO_DATA_FOUND THEN
	           RETURN FALSE ;
	    END isNsnValid ;
	
	 BEGIN
	   debugMsg(msg => 'isPartValid(' || partNo || ', ' || smrCode || ', ' || mtbdr || ', ' || plannerCode || ')', lineNo => 60) ;
	   IF UPPER(partNo) = 'F117-PW-100' OR INSTR(UPPER(partNo),'17L8D') > 0 OR INSTR(UPPER(partNo),'17R9Y') > 0 OR INSTR(UPPER(smrCode),'PE') > 0 THEN
	   	  RETURN FALSE ;
	   END IF ;
	   DECLARE
	   		  theCode AMD_SPARE_PARTS.ACQUISITION_ADVICE_CODE%TYPE ;
	   BEGIN
		   SELECT acquisition_advice_code INTO theCode
		   FROM AMD_SPARE_PARTS WHERE part_no = partNo ;
		   IF UPPER(theCode) = 'Y' THEN
		   	  RETURN FALSE ;
		   END IF ;
	   EXCEPTION WHEN OTHERS THEN
	          ErrorMsg(pSqlfunction => 'select',
		       pTableName => 'amd_spare_parts',
		       pError_location => 90,
		       pKey_1 => isPartValid.partNo ) ;
	         RAISE ;
	   END ;
	   result := amd_utils.isPartRepairable(isPartValid.partNo) ;
	   
	   IF result THEN
	   	  null ; -- do nothing
	   ELSE
	   	  debugMsg(smrCode || ' is NOT a valid smr code', 70) ;
	   	  if showReason then dbms_output.put_line(smrCode || ' is NOT a valid smr code') ; end if ;
	   END IF ;
	   result := result AND isPlannerCodeValid ;
	   IF result AND isNsl(partNo) THEN
	   
	     IF showReason AND (mtbdr IS NOT NULL AND mtbdr > 0) THEN
		 	dbms_output.put_line('mtbdr > 0 for part ' || partNo) ; 
		 END IF ;
		 
	     result := result AND (demandExists OR inventoryExists
	                    OR (mtbdr IS NOT NULL AND mtbdr > 0)
	            OR isNsnValid ) ;
	  END IF ;
	  IF result THEN
	  	 null ; -- do nothing
	  ELSE
	  	 debugMsg('part ' || partNo || ' is NOT valid.',80) ;
	  	 if showReason then dbms_output.put_line('part ' || partNo || ' is NOT valid.') ; end if ;
	  END IF ;
	  RETURN result ;
	 EXCEPTION WHEN OTHERS THEN
		IF SQLCODE = -20000 THEN
			dbms_output.DISABLE ; -- buffer overflow, disable
			RETURN isPartValid(partNo) ; -- try validation again
		ELSE
			RAISE ;
		END IF ;
	
	 END isPartValid ;
	
	 PROCEDURE insertPartInfo(
	       part_no IN VARCHAR2,
	       nomenclature IN VARCHAR2,
	       action_code IN VARCHAR2,
	        mfgr IN VARCHAR2 := NULL,
	       unit_issue IN VARCHAR2 := NULL,
	       smr_code IN VARCHAR2 := NULL,
	       nsn IN VARCHAR2 := NULL,
	       planner_code IN VARCHAR2 := NULL,
	       third_party_flag IN VARCHAR2 := NULL,
	       mtbdr      IN NUMBER := NULL,
	       indenture IN VARCHAR2 := NULL,
		   price IN NUMBER := NULL) IS
	
	   result NUMBER := SUCCESS ;
	  partInfoError EXCEPTION ;
	 BEGIN
	   CASE action_code
	      WHEN Amd_Defaults.INSERT_ACTION THEN
	         result := insertPartInfo(
	        mfgr,
	       part_no,
	       unit_issue,
	       nomenclature,
	       smr_code,
	       nsn,
	       planner_code,
	       third_party_flag,
	       mtbdr,
	       indenture,
		   price) ;
	
	      WHEN Amd_Defaults.UPDATE_ACTION THEN
	         result := updatePartInfo(
	        mfgr,
	       part_no,
	       unit_issue,
	       nomenclature,
	       smr_code,
	       nsn,
	       planner_code,
	       third_party_flag,
	       mtbdr,
	       indenture,
		   price) ;
	
	      WHEN Amd_Defaults.DELETE_ACTION THEN
	         result := deletePartInfo(part_no, nomenclature) ;
	  END CASE ;
	  IF result != SUCCESS THEN
	     RAISE partInfoError ;
	  END IF ;
	 END insertPartInfo ;
	
	 procedure initA2ADemands is
	 begin
		amd_owner.Mta_Truncate_Table('tmp_a2a_demands','reuse storage');
	  		INSERT INTO amd_owner.TMP_A2A_DEMANDS
		   (part_no, site, docno, demand_date, qty, demand_level, action_code, last_update_dt)
	        SELECT Amd_Partprime_Pkg.getSuperPrimePartByNsiSid(a.NSI_SID) part_no,
	  		  	Amd_Utils.getSpoLocation(a.LOC_SID) site,
			a.DOC_NO docno,
			a.DOC_DATE demand_date,
			a.QUANTITY qty,
			NULL demand_level,
			sent.action_code,
			SYSDATE last_update_dt
		   FROM amd_owner.AMD_DEMANDS a, amd_sent_to_a2a sent
		   WHERE Amd_Partprime_Pkg.getSuperPrimePartByNsiSid(a.NSI_SID) = sent.spo_prime_part_no
		   and sent.part_no = sent.spo_prime_part_no						   
		   AND Amd_Utils.getSpoLocation(a.LOC_SID) NOT IN ('FB4454', 'FB4455', 'FB4412', 'FB4490', 'FB4491') ;
		 COMMIT ;
	 end initA2ADemands ;
	 
	 PROCEDURE processExtForecast(extForecast IN extForecastCur) IS
	 		   rec AMD_part_loc_forecasts%ROWTYPE ;
			   cnt NUMBER := 0 ;
			   rc number ;
	 BEGIN
	  	  writeMsg(pTableName => 'tmp_a2a_ext_forecast', pError_location => 100,
				pKey1 => 'processExtForecast',
				pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	 	  LOOP
		  	  FETCH extForecast INTO rec ;
		  	  EXIT WHEN extForecast%NOTFOUND ;
			  amd_part_loc_forecasts_pkg.InsertTmpA2A_EF_AllPeriods
				(
					rec.part_no, 
					Amd_Utils.GetSpoLocation(rec.loc_sid) , 
					amd_part_loc_forecasts_pkg.GetCurrentPeriod, 
					rec.forecast_qty , 
					rec.action_code, 
					sysdate 
				)  ;
	     	  cnt := cnt + 1 ;
		 	  IF MOD(cnt,COMMIT_THRESHOLD) = 0 THEN
			  	 COMMIT ;
			  END IF ;
	 	  END LOOP ;
	  	  writeMsg(pTableName => 'tmp_a2a_ext_forecast', pError_location => 110,
				pKey1 => 'processExtForecast',
				pKey2 => 'cnt=' || TO_CHAR(cnt),
				pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		  COMMIT ;
	 END processExtForecast ;
	 
	 PROCEDURE initA2AExtForecast(from_dt IN DATE := START_DT, to_dt IN DATE := SYSDATE) IS
	  extForecast extForecastCur ;
	  
	 BEGIN
		  writeMsg(pTableName => 'tmp_a2a_ext_forecast', pError_location => 120,
					pKey1 => 'initA2AExtForecast',
					pKey2 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
					pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
					pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		  Mta_Truncate_Table('tmp_a2a_ext_forecast','reuse storage');
		  mblnSendAllData := TRUE ;
		  OPEN extForecast FOR
			  SELECT * FROM AMD_part_loc_forecasts 
			  WHERE
	    	  TRUNC(last_update_dt) BETWEEN TRUNC(from_dt) AND TRUNC(to_dt) 
			  and part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A WHERE spo_prime_part_no IS NOT NULL);
		  processExtForecast(extForecast) ;
		  CLOSE extForecast ;  
		  writeMsg(pTableName => 'tmp_a2a_ext_forecast', pError_location => 130,
					pKey1 => 'initA2AExtForecast',
					pKey2 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
					pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
					pKey4 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		  COMMIT ;
	 END initA2AExtForecast ;
	 
	  PROCEDURE initA2AExtForecast(useTestParts IN BOOLEAN := FALSE ) is
	  		extForecast extForecastCur ;
	  		procedure getTestData is
			begin
			  	writeMsg(pTableName => 'amd_part_loc_forcecast', pError_location => 140,
		 		pKey1 => 'getTestData' ) ;
				commit ;
			  	OPEN extForecast FOR
					  SELECT *
					  FROM AMD_part_loc_forecasts WHERE
					  part_no IN (SELECT part_no FROM AMD_TEST_PARTS) 
					  AND part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A WHERE spo_prime_part_no IS NOT NULL) ;
			end getTestData ;
			
			procedure getAllData is
			begin
			  	writeMsg(pTableName => 'amd_part_loc_forcecast', pError_location => 150,
		 		pKey1 => 'getAllData' ) ;
				commit ;
		  	    OPEN extForecast FOR
				  SELECT * FROM AMD_part_loc_forecasts WHERE
				  part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A WHERE spo_prime_part_no IS NOT NULL) ;
			end getAllData ;
			
	  begin
		  writeMsg(pTableName => 'tmp_a2a_ext_forecast', pError_location => 160,
					pKey1 => 'initA2AExtForecast',
					pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
					pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		  mblnSendAllData := TRUE ;
		  Mta_Truncate_Table('TMP_A2A_EXT_FORECAST','reuse storage');
		  IF useTestParts THEN
		  	 getTestData ;
		  ELSE
		  	 getAllData ;
		  END IF ;
		  processExtForecast(extForecast) ;
		  CLOSE extForecast ;	 
		  writeMsg(pTableName => 'tmp_a2a_ext_forecast', pError_location => 170,
					pKey1 => 'initA2AExtForecast',
					pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
					pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		  COMMIT ;
	  end initA2AExtForecast ;
	
	
	 PROCEDURE processOnHandInvSum(onHandInvSum IN onHandInvSumCur) IS
	 		   rec AMD_ON_HAND_INVS_SUM%ROWTYPE ;
			   cnt NUMBER := 0 ;
	 BEGIN
	 	  LOOP
		  	  FETCH onHandInvSum INTO rec ;
		  	  EXIT WHEN onHandInvSum%NOTFOUND ;
	          A2a_Pkg.insertInvInfo(rec.part_no,rec.spo_location,rec.qty_on_hand, rec.action_code) ;
	     	  cnt := cnt + 1 ;
		 	  IF MOD(cnt,COMMIT_THRESHOLD) = 0 THEN
			  	 COMMIT ;
			  END IF ;
	 	  END LOOP ;
		  COMMIT ;
	 END processOnHandInvSum ;
	 
	 PROCEDURE initA2AInvInfo(from_dt IN DATE := START_DT, to_dt IN DATE := SYSDATE) IS
	  invInfoByDate onHandInvSumCur ; 
	   
	 BEGIN
		writeMsg(pTableName => 'tmp_a2a_inv_info', pError_location => 180,
				pKey1 => 'initA2AInvInfo',
				pKey2 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
				pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
				pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	  mblnSendAllData := TRUE ;
	  OPEN invInfoByDate FOR
	    SELECT  
			  	  oh.PART_NO,       
				  SPO_LOCATION,    
				  QTY_ON_HAND,
				  case oh.ACTION_CODE
				  	   when amd_defaults.getDELETE_ACTION then
					   		oh.ACTION_CODE
					   else     
				  	   		sent.ACTION_CODE
				  end action_code,     
				  LAST_UPDATE_DT,  
				  REORDER_POINT,   
				  STOCK_LEVEL     
		FROM AMD_ON_HAND_INVS_SUM oh, amd_sent_to_a2a sent 
	    WHERE TRUNC(last_update_dt) BETWEEN TRUNC(from_dt) AND TRUNC(to_dt) 
	    AND oh.part_no = sent.part_no
		and sent.SPO_PRIME_PART_NO is not null
		UNION ALL
		SELECT rsp.part_no, rsp_location, qty_on_hand, 
		case rsp.action_code
			 when amd_defaults.getDELETE_ACTION then
			 	  rsp.action_code
			 else
			 	 sent.action_code
		end action_code, last_update_dt, NULL reorder_point, NULL stock_level
		FROM AMD_RSP_SUM rsp, amd_sent_to_a2a sent 
		WHERE TRUNC(last_update_dt) BETWEEN TRUNC(from_dt) AND TRUNC(to_dt)
		AND rsp.part_no = sent.part_no
		and sent.spo_prime_part_no is not null ;
	
	  Mta_Truncate_Table('TMP_A2A_INV_INFO','reuse storage');
	  processOnHandInvSum(invInfoByDate) ;
	  CLOSE invInfoByDate ;
	  writeMsg(pTableName => 'tmp_a2a_inv_info', pError_location => 190,
				pKey1 => 'initA2AInvInfo',
				pKey2 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
				pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
				pKey4 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	  COMMIT ;
	 END initA2AInvInfo ;
	
	 
	 FUNCTION initA2AInvInfo(useTestParts IN BOOLEAN := FALSE) RETURN NUMBER IS
		 invInfo onHandInvSumCur ;
		 result NUMBER := SUCCESS ;
		 
		 procedure getTestData is
		 begin
			writeMsg(pTableName => 'amd_on_hand_invs_sum', pError_location => 200,
			pKey1 => 'getTestData' ) ;
			commit ;
			OPEN invInfo FOR
			  SELECT 
			  	  oh.PART_NO,       
				  SPO_LOCATION,    
				  QTY_ON_HAND,
				  case oh.action_code
				  	   when amd_defaults.getDELETE_ACTION then
					   		oh.action_code
					   else
					   	   sent.action_code
				  end action_code,     
				  LAST_UPDATE_DT,  
				  REORDER_POINT,   
				  STOCK_LEVEL     
			  FROM AMD_ON_HAND_INVS_SUM oh, amd_sent_to_a2a sent, amd_test_parts testParts 
			  WHERE oh.part_no = testParts.part_no 
			  AND oh.part_no = sent.part_no
			  and sent.SPO_PRIME_PART_NO is not null
			  UNION ALL
			  SELECT rsp.part_no, rsp_location, qty_on_hand, 
			  case rsp.action_code
			  	   when amd_defaults.getDELETE_ACTION then
				   		rsp.action_code
				   else
				   	   sent.action_code
			  end action_code, last_update_dt, NULL reorder_point, NULL stock_level
			  FROM AMD_RSP_SUM rsp, amd_sent_to_a2a sent, amd_test_parts testParts 
			  WHERE rsp.part_no = testParts.part_no
			  AND rsp.part_no = sent.part_no
			  and sent.SPO_PRIME_PART_NO is not null ;
		 end getTestData ;
		 
		 procedure getAllData is
		 begin
			writeMsg(pTableName => 'amd_on_hand_invs_sum', pError_location => 210,
			pKey1 => 'getAllData' ) ;
			commit ;
		  	 OPEN invInfo FOR
				  SELECT  
				  	  oh.PART_NO,       
					  SPO_LOCATION,    
					  QTY_ON_HAND,
					  case oh.action_code
					  	   when amd_defaults.getDELETE_ACTION then
						   		oh.action_code
						   else					        
					  	   		sent.ACTION_CODE
					  end action_code,     
					  LAST_UPDATE_DT,  
					  REORDER_POINT,   
					  STOCK_LEVEL     
		  		  FROM AMD_ON_HAND_INVS_SUM oh, amd_sent_to_a2a sent 
				  WHERE oh.part_no = sent.part_no
				  and sent.SPO_PRIME_PART_NO is not null
				  UNION ALL
				  SELECT rsp.part_no, rsp_location, qty_on_hand, 
				  case rsp.action_code
				  	   when amd_defaults.getDELETE_ACTION then
					   		rsp.action_code
					   else
					   	   sent.action_code
				  end action_code, last_update_dt, NULL reorder_point, NULL stock_level
				  FROM AMD_RSP_SUM rsp, amd_sent_to_a2a sent
				  WHERE rsp.part_no = sent.part_no
				  and sent.SPO_PRIME_PART_NO is not null ;
		 end getAllData ;
	  
	
	 BEGIN
	  writeMsg(pTableName => 'tmp_a2a_inv_info', pError_location => 220,
				pKey1 => 'initA2AInvInfo',
				pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
				pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	  mblnSendAllData := TRUE ;
	  Mta_Truncate_Table('TMP_A2A_INV_INFO','reuse storage');
	  IF useTestParts THEN
	  	 getTestData ;
	  ELSE
	  	 getAllData ;
	  END IF ;
	  processOnHandInvSum(invInfo) ;
	  CLOSE invInfo ;	 
	  writeMsg(pTableName => 'tmp_a2a_inv_info', pError_location => 230,
				pKey1 => 'initA2AInvInfo',
				pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
				pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	  COMMIT ;
	  RETURN result ;
	 END initA2AInvInfo ;
	
	PROCEDURE processRepairInvInfo(repairInvInfo IN repairInvInfoCur) IS
			  rec AMD_REPAIR_INVS_SUM%ROWTYPE ;
			  cnt NUMBER := 0 ;
	BEGIN
	     writeMsg(pTableName => 'tmp_a2a_repair_inv_info', pError_location => 240,
				pKey1 => 'proecessRepairInvInfo',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		 LOOP
		 	 FETCH repairInvInfo INTO rec ;
			 EXIT WHEN repairInvInfo%NOTFOUND ;
	         A2a_Pkg.insertRepairInvInfo(rec.part_no,rec.site_location,rec.qty_on_hand, rec.action_code) ;
	     	 cnt := cnt + 1 ;
		 	 IF MOD(cnt,COMMIT_THRESHOLD) = 0 THEN
			   COMMIT ;
			 END IF ;
		 END LOOP ;
	     writeMsg(pTableName => 'tmp_a2a_repair_inv_info', pError_location => 250,
				pKey1 => 'proecessRepairInvInfo',
				pKey2 => 'cnt=' || TO_CHAR(cnt),
				pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		 COMMIT ;
	END processRepairInvInfo ;
	 
	PROCEDURE initA2ARepairInvInfo(from_dt IN DATE := START_DT, to_dt IN DATE := SYSDATE) IS
	  repairInvInfoByDate repairInvInfoCur ;
	  
	  cnt NUMBER := 0 ;
	  
	BEGIN
	  writeMsg(pTableName => 'tmp_a2a_repair_inv_info', pError_location => 260,
				pKey1 => 'initA2ARepairInvInfo',
				pKey2 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
				pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
				pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	  Mta_Truncate_Table('TMP_A2A_REPAIR_INV_INFO','reuse storage');
	  mblnSendAllData := TRUE ;
	  OPEN repairInvInfoByDate FOR
		  SELECT * FROM AMD_REPAIR_INVS_SUM 
		  WHERE
		  TRUNC(last_update_dt) BETWEEN TRUNC(from_dt) AND TRUNC(to_dt) 
		  AND part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A WHERE spo_prime_part_no IS NOT NULL);
	  processRepairInvInfo(repairInvInfoByDate) ;
	  CLOSE repairInvInfoByDate ;
	  writeMsg(pTableName => 'tmp_a2a_repair_inv_info', pError_location => 270,
				pKey1 => 'initA2ARepairInvInfo',
				pKey2 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
				pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
				pKey4 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	  COMMIT ;
	END initA2ARepairInvInfo ;
	
	   
	FUNCTION initA2ARepairInvInfo(useTestParts IN BOOLEAN := FALSE) RETURN NUMBER IS
		repairInvInfo repairInvInfoCur ;
		result NUMBER := SUCCESS ;
		  
		procedure getTestData is
		begin
			writeMsg(pTableName => 'amd_repair_invs_sum', pError_location => 280,
			pKey1 => 'getTestData' ) ;
			commit ;
		  	OPEN repairInvInfo FOR
				  SELECT *
				  FROM AMD_REPAIR_INVS_SUM WHERE
				  part_no IN (SELECT part_no FROM AMD_TEST_PARTS)
				  AND part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A WHERE spo_prime_part_no IS NOT NULL);
		end getTestData ;
		
		procedure getAllData is
		begin
			writeMsg(pTableName => 'amd_repair_invs_sum', pError_location => 290,
			pKey1 => 'getAllData' ) ;
			commit ;
	  	 	OPEN repairInvInfo FOR
			  SELECT * FROM AMD_REPAIR_INVS_SUM WHERE
			  part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A WHERE spo_prime_part_no IS NOT NULL);
		end getAllData ;
	
	BEGIN
	  writeMsg(pTableName => 'tmp_a2a_repair_inv_info', pError_location => 300,
				pKey1 => 'initA2ARepairInvInfo',
				pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
				pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	  Mta_Truncate_Table('TMP_A2A_REPAIR_INV_INFO','reuse storage');
	  mblnSendAllData := TRUE ;
	  IF useTestParts THEN
	  	 getTestData ;
	  ELSE
	  	 getAllData ;
	  END IF ;
	  processRepairInvInfo(repairInvInfo) ;
	  CLOSE repairInvInfo ;
	
	  writeMsg(pTableName => 'tmp_a2a_repair_inv_info', pError_location => 310,
				pKey1 => 'initA2ARepairInvInfo',
				pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
				pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	  COMMIT ;
	  RETURN result ;
	 END initA2ARepairInvInfo ;
	 
	 PROCEDURE processInTransits(inTransits IN inTransitsCur) IS
	 		   cnt NUMBER := 0 ;
			   rec AMD_IN_TRANSITS_SUM%ROWTYPE ;
	 BEGIN
	      writeMsg(pTableName => 'tmp_a2a_in_transits', pError_location => 320,
				pKey1 => 'processInTransits',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	 	  LOOP
		  	  FETCH inTransits INTO rec ;
			  EXIT WHEN inTransits%NOTFOUND ;
			  A2a_Pkg.insertTmpA2AInTransits(
			       rec.part_no,
			       rec.site_location,
			       rec.quantity,
			       rec.serviceable_flag,
			       rec.action_code) ;	   
	       	  cnt := cnt + 1 ;
		      IF MOD(cnt,COMMIT_THRESHOLD) = 0 THEN
			    COMMIT ;
		      END IF ;
		  END LOOP ;
		  COMMIT ;
	      writeMsg(pTableName => 'tmp_a2a_in_transits', pError_location => 330,
				pKey1 => 'processInTransits',
				pKey2 => 'cnt=' || TO_CHAR(cnt),
				pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		  COMMIT ;
	 END processInTransits ;
	 
	 PROCEDURE initA2AInTransits(from_dt IN DATE := START_DT, to_dt IN DATE := SYSDATE) IS
	  inTransitsByDate inTransitsCur ;
	  
	 BEGIN
		  writeMsg(pTableName => 'tmp_a2a_in_transits', pError_location => 340,
					pKey1 => 'initA2AInTransits',
					pKey2 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
					pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
					pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		  Mta_Truncate_Table('tmp_a2a_in_transits','reuse storage');
		  mblnSendAllData := TRUE ;
		  OPEN inTransitsByDate FOR
			  SELECT * FROM AMD_IN_TRANSITS_SUM 
			  WHERE
			  TRUNC(last_update_dt) BETWEEN TRUNC(from_dt) AND TRUNC(to_dt) 
			  AND part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A WHERE spo_prime_part_no IS NOT NULL);
		  processInTransits(inTransitsByDate) ;
		  CLOSE inTransitsByDate ;  
		  writeMsg(pTableName => 'tmp_a2a_in_transits', pError_location => 350,
					pKey1 => 'initA2AInTransits',
					pKey2 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
					pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
					pKey4 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		  COMMIT ;
	 END initA2AInTransits ;
	 
	 FUNCTION initA2AInTransits(useTestParts IN BOOLEAN := FALSE) RETURN NUMBER IS
		 inTransits inTransitsCur ;
		
		 result NUMBER := SUCCESS ;
		 
		 procedure getTestData is
		 begin
			 writeMsg(pTableName => 'amd_in_transits_sum', pError_location => 360,
			 pKey1 => 'getTestData' ) ;
			 commit ;
		  	 OPEN inTransits FOR
				  SELECT *
				  FROM AMD_IN_TRANSITS_SUM  WHERE
				  part_no IN (SELECT part_no FROM AMD_TEST_PARTS)
				  AND part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A WHERE spo_prime_part_no IS NOT NULL);
		 end getTestData ;
		 
		 procedure getAllData is
		 begin
			 writeMsg(pTableName => 'amd_in_transits_sum', pError_location => 370,
			 pKey1 => 'getAllData' ) ;
			 commit ;
		  	 OPEN inTransits FOR
				  SELECT * FROM AMD_IN_TRANSITS_SUM  WHERE 
				  part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A WHERE spo_prime_part_no IS NOT NULL);
		 end getAllData ;
	
	 BEGIN
		  writeMsg(pTableName => 'tmp_a2a_in_transits', pError_location => 380,
					pKey1 => 'initA2AInTransits',
					pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
					pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  
		  Mta_Truncate_Table('tmp_a2a_in_transits','reuse storage');
		  mblnSendAllData := TRUE ;
		  IF useTestParts THEN
		  	 getTestData ;
		  ELSE
		  	 getAllData ;
		  END IF ;
		  
		  processInTransits(inTransits) ;
		  CLOSE inTransits ;	  
		  writeMsg(pTableName => 'tmp_a2a_in_transits', pError_location => 390,
					pKey1 => 'initA2AInTransits',
					pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
					pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		  COMMIT ;  
		  RETURN result ;
	 END initA2AInTransits ;
	
	 PROCEDURE processInRepair(inRepair IN inRepairCur) IS
	 		   cnt NUMBER := 0 ;
			   rec AMD_IN_REPAIR%ROWTYPE ;
	 BEGIN
	  	  writeMsg(pTableName => 'tmp_a2a_repair_info', pError_location => 400,
				pKey1 => 'processInRepair',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  
	 	  LOOP
		  	  FETCH inRepair INTO rec ;
			  EXIT WHEN inRepair%NOTFOUND ;
	     	  A2a_Pkg.insertRepairInfo(rec.part_no,rec.loc_sid,rec.order_no,rec.repair_date,A2a_Pkg.OPEN_STATUS,rec.repair_qty,
	                rec. repair_need_date, rec.action_code) ;
	     	  cnt := cnt + 1 ;
		 	  IF MOD(cnt,COMMIT_THRESHOLD) = 0 THEN
			     COMMIT ;
			  END IF ;		  
		  END LOOP ;
	  	  writeMsg(pTableName => 'tmp_a2a_repair_info', pError_location => 410,
				pKey1 => 'processInRepair',
				pKey2 => 'cnt=' || TO_CHAR(cnt),
				pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  
		  COMMIT ;
	 END processInRepair ;
	 
	 PROCEDURE initA2ARepairInfo(from_dt IN DATE := START_DT, to_dt IN DATE := SYSDATE) IS
	  
	  repairsByDate inRepairCur ;
	  
	 BEGIN
	  	  writeMsg(pTableName => 'tmp_a2a_repair_info', pError_location => 420,
				pKey1 => 'initA2ARepairInfo',
				pKey2 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
				pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
				pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  
	  	  Mta_Truncate_Table('tmp_a2a_repair_info','reuse storage');
		  mblnSendAllData := TRUE ;
		  OPEN repairsByDate FOR
			  SELECT * FROM AMD_IN_REPAIR 
			  WHERE
			  TRUNC(last_update_dt) BETWEEN TRUNC(from_dt) AND TRUNC(to_dt) 
			  AND part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A WHERE spo_prime_part_no IS NOT NULL);
		  processInRepair(repairsByDate) ;
		  CLOSE repairsByDate ;	  	  
	  	  writeMsg(pTableName => 'tmp_a2a_repair_info', pError_location => 430,
				pKey1 => 'initA2ARepairInfo',
				pKey2 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
				pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
				pKey4 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		  COMMIT ;  
	 END initA2ARepairInfo ;
	 
	 FUNCTION initA2ARepairInfo(useTestParts IN BOOLEAN := FALSE) RETURN NUMBER IS
		 repairs inRepairCur ;
		 result NUMBER := SUCCESS ;
		 
		 procedure getTestData is
		 begin
			 writeMsg(pTableName => 'amd_in_repair', pError_location => 440,
			 pKey1 => 'getTestData' ) ;
			 commit ;
		  	 OPEN repairs FOR
				  SELECT *
				  FROM AMD_IN_REPAIR WHERE
				  part_no IN (SELECT part_no FROM AMD_TEST_PARTS)
				  AND part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A WHERE spo_prime_part_no IS NOT NULL);
		 end getTestData ;
		 
		 procedure getAllData is
		 begin
			 writeMsg(pTableName => 'amd_in_repair', pError_location => 450,
			 pKey1 => 'getAllData' ) ;
			 commit ;
	  	     OPEN repairs FOR
				 SELECT * FROM AMD_IN_REPAIR WHERE 
				 part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A WHERE spo_prime_part_no IS NOT NULL);
		 end getAllData ;
	
	 BEGIN
	  writeMsg(pTableName => 'tmp_a2a_repair_info', pError_location => 460,
		pKey1 => 'initA2ARepairInfo',
		pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
		pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  
	  Mta_Truncate_Table('tmp_a2a_repair_info','reuse storage');
	  mblnSendAllData := TRUE ;
	  IF useTestParts THEN
	  	 getTestData ;
	  ELSE
	  	 getAllData ;
	  END IF ;
	  processInRepair(repairs) ;
	  CLOSE repairs ;
	  writeMsg(pTableName => 'tmp_a2a_repair_info', pError_location => 470,
		pKey1 => 'initA2ARepairInfo',
		pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
		pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	  COMMIT ;  
	  RETURN result ;
	 END initA2ARepairInfo ;
	
	 PROCEDURE processOnOrder(onOrder IN onOrderCur) IS
	 		   cnt NUMBER := 0 ;
			   rec AMD_ON_ORDER%ROWTYPE ;
	 BEGIN
		  writeMsg(pTableName => 'tmp_a2a_order_info', pError_location => 480,
			pKey1 => 'processOnOrder',
			pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  
	 	  LOOP
		  	  FETCH onOrder INTO rec ;
			  EXIT WHEN onOrder%NOTFOUND ;
	          insertTmpA2AOrderInfo(rec.gold_order_number,rec.loc_sid,rec.order_date,rec.part_no,rec.order_qty, rec.sched_receipt_date, rec.action_code) ;
	      	  cnt := cnt + 1 ;
		 	  IF MOD(cnt,COMMIT_THRESHOLD) = 0 THEN
			    COMMIT ;
			  END IF ;
		  END LOOP ;
		  writeMsg(pTableName => 'tmp_a2a_order_info', pError_location => 490,
			pKey1 => 'processOnOrder',
			pKey2 => 'cnt=' || TO_CHAR(cnt),
			pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  
		  COMMIT ;
	 END processOnOrder ;
	 
	 -- create a2a for a specific set of dates
	 PROCEDURE initA2AOrderInfo(from_dt IN DATE := START_DT, to_dt IN DATE := SYSDATE) IS
	  ordersByDate onOrderCur ;
	 BEGIN
		  writeMsg(pTableName => 'tmp_a2a_order_info', pError_location => 500,
			pKey1 => 'initA2AOrderInfo',
			pKey2 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
			pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
			pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		  includeCnt := 0 ;
		  excludeCnt := 0 ;  
	  	  Mta_Truncate_Table('tmp_a2a_order_info','reuse storage');
	  	  Mta_Truncate_Table('tmp_a2a_order_info_line','reuse storage');
		  mblnSendAllData := TRUE ;
		  OPEN ordersByDate FOR
			  SELECT  
				  oo.PART_NO,  
				  LOC_SID,
                  LINE,		  
				  ORDER_DATE,         
				  ORDER_QTY,          
				  GOLD_ORDER_NUMBER, 
				  case oo.ACTION_CODE
				  	   when amd_defaults.getDELETE_ACTION then
					   		oo.ACTION_CODE
					   else  
				  	   		 sent.ACTION_CODE
				  end action_code,        
				  LAST_UPDATE_DT,     
				  SCHED_RECEIPT_DATE
				  FROM AMD_ON_ORDER OO, amd_sent_to_a2a sent 
			  WHERE TRUNC(last_update_dt) BETWEEN TRUNC(from_dt) AND TRUNC(to_dt) 
			  AND oo.part_no = sent.part_no
			  and sent.SPO_PRIME_PART_NO is not null  
			  ORDER BY gold_order_number, part_no, order_date ;
		  processOnOrder(ordersByDate) ;
		  CLOSE ordersByDate ;	  
	  	  writeMsg(pTableName => 'tmp_a2a_order_info', pError_location => 510,
			pKey1 => 'initA2AOrderInfo',
			pKey2 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
			pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
			pKey4 => 'excludeCnt=' || TO_CHAR(excludeCnt),
			pData => 'includeCnt=' || includeCnt || ' ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  
		  COMMIT ;
	 END initA2AOrderInfo ;
	 
	 FUNCTION initA2AOrderInfo(useTestParts IN BOOLEAN := FALSE) RETURN NUMBER IS
		 onOrders onOrderCur ;
		 result NUMBER := SUCCESS ;
		 orders NUMBER := 0 ;
		 lines NUMBER := 0 ;
		 
		 procedure getTestData is
		 begin
			 writeMsg(pTableName => 'amd_on_order', pError_location => 520,
			 pKey1 => 'getTestData' ) ;
			 commit ;
		  	 OPEN onOrders FOR
			  SELECT 
					  oo.PART_NO,  
					  LOC_SID,
                      LINE,		  
					  ORDER_DATE,         
					  ORDER_QTY,          
					  GOLD_ORDER_NUMBER,
					  case oo.ACTION_CODE
					  	   when amd_defaults.getDELETE_ACTION then
						   		oo.ACTION_CODE
						   else  
					  	   		 sent.ACTION_CODE
					  end action_code,        
					  LAST_UPDATE_DT,     
					  SCHED_RECEIPT_DATE
			  FROM AMD_ON_ORDER OO, amd_sent_to_a2a sent, amd_test_parts testParts 
			  WHERE oo.part_no = testParts.PART_NO 
			  AND oo.part_no = sent.part_no
			  and sent.SPO_PRIME_PART_NO is not null	 
			  ORDER BY gold_order_number, part_no, order_date ;
		 end getTestData ;
		 
		 procedure getAllData is
		 begin
			 writeMsg(pTableName => 'amd_on_order', pError_location => 530,
			 pKey1 => 'getAllData' ) ;
			 commit ;
	  	  	 OPEN onOrders FOR 
				 SELECT 
					  oo.PART_NO,  
					  LOC_SID,
                      LINE,		  
					  ORDER_DATE,         
					  ORDER_QTY,          
					  GOLD_ORDER_NUMBER,  
					  case oo.ACTION_CODE
					  	   when amd_defaults.getDELETE_ACTION then
						   		oo.ACTION_CODE
						   else  
					  	   		 sent.ACTION_CODE
					  end action_code,        
					  LAST_UPDATE_DT,     
					  SCHED_RECEIPT_DATE
				  FROM AMD_ON_ORDER OO, amd_sent_to_a2a sent 
				  WHERE oo.part_no = sent.part_no
				  and sent.SPO_PRIME_PART_NO is not null  
				  ORDER BY gold_order_number, part_no, order_date ;
		 end getAllData ;
	
	 BEGIN
	  writeMsg(pTableName => 'tmp_a2a_order_info', pError_location => 540,
			pKey1 => 'initA2AOrderInfo',
			pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
			pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  
	  Mta_Truncate_Table('tmp_a2a_order_info','reuse storage');
	  Mta_Truncate_Table('tmp_a2a_order_info_line','reuse storage');
	  mblnSendAllData := TRUE ;
	  includeCnt := 0 ;
	  excludeCnt := 0 ;
	  IF useTestParts THEN
	  	 getTestData ;
	  ELSE
	  	 getAllData ;
	  END IF ;
	  processOnOrder(onOrders) ;
	  CLOSE onOrders ;
	
	  SELECT COUNT(*) INTO orders FROM TMP_A2A_ORDER_INFO ;
	  SELECT COUNT(*) INTO lines FROM TMP_A2A_ORDER_INFO_LINE ;
	  writeMsg(pTableName => 'tmp_a2a_order_info', pError_location => 550,
			pKey1 => 'initA2AOrderInfo',
			pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
			pKey3 => 'orders=' || TO_CHAR(orders),
			pKey4 => 'lines=' || TO_CHAR(lines),
			pData => 'includeCnt=' || includeCnt || ' excludeCnt=' || excludeCnt, 
			pComments => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  
	  RETURN result ;
	 END initA2AOrderInfo ;

	 function getActionCode(part_no in amd_sent_to_a2a.part_no%type) return amd_sent_to_a2a.action_code%type is
			   theActionCode amd_sent_to_a2a.action_code%type ;
	 begin
		 select action_code into theActionCode from amd_sent_to_a2a where part_no = getActionCode.part_no ;
		 return theActionCode ;
	 end getActionCode ;
	 
	 PROCEDURE insertPartLeadTime(
	        part_no IN tmp_a2a_part_lead_time.PART_NO%type,
	        lead_time_type tmp_a2a_part_lead_time.LEAD_TIME_TYPE%type,
	        lead_time IN tmp_a2a_part_lead_time.LEAD_TIME%type,
	        action_code IN TMP_A2A_PART_LEAD_TIME.action_code%TYPE) IS
		   
	  partLeadTimeError EXCEPTION ;
	  result NUMBER := SUCCESS ;
	 BEGIN
	   CASE action_code
	      WHEN Amd_Defaults.INSERT_ACTION THEN
	         result := InsertPartLeadTime(part_no, lead_time_type, lead_time) ;
	     WHEN Amd_Defaults.UPDATE_ACTION THEN
	         result := UpdatePartLeadTime(part_no, lead_time_type, lead_time) ;
	     WHEN Amd_Defaults.DELETE_ACTION THEN
	         result := DeletePartLeadTime(part_no) ;
	   END CASE ;
	   IF result != SUCCESS THEN
	    RAISE partLeadTimeError ;
	   END IF ;
	 END insertPartLeadTime ;
	 
	 PROCEDURE insertTmpA2APartLeadTime(part_no IN VARCHAR2, 
	 		   order_lead_time IN TMP_A2A_PART_LEAD_TIME.LEAD_TIME%TYPE,
			   order_lead_time_cleaned IN TMP_A2A_PART_LEAD_TIME.LEAD_TIME%TYPE,
			   order_lead_time_defaulted IN TMP_A2A_PART_LEAD_TIME.lead_time%TYPE) IS
			   
	       lead_time tmp_a2a_part_lead_time.LEAD_TIME%type  ;
		   result NUMBER ;
		   
		   action_code tmp_a2a_part_lead_time.action_code%type := getActionCode(part_no) ; -- use whatever action_code is in amd_sent_to_a2a
		      
		   
	 BEGIN
	
	    IF order_lead_time_cleaned IS NOT NULL THEN
	       lead_time := order_lead_time_cleaned ;
	    ELSIF order_lead_time IS NOT NULL THEN
	       lead_time := order_lead_time ;
	    ELSE
	     lead_time := order_lead_time_defaulted ;
	    END IF ;
	 
	    IF lead_time IS not null or (lead_time is null and action_code = amd_defaults.DELETE_ACTION) THEN
		     insertPartLeadTime(part_no => part_no, lead_time_type => NEW_BUY, lead_time => lead_time,
								action_code => action_code) ;
	    END IF ;
	   
	 END insertTmpA2APartLeadTime ;
	 
	 
	 FUNCTION getPartInfo RETURN partCur IS
			  parts partCur ;
	 BEGIN
		  writeMsg(pTableName => 'amd_spare_parts', pError_location => 560,
		  pKey1 => 'getPartInfo' ) ;
		  commit ;
	 	  OPEN parts FOR
			  SELECT sp.mfgr,
			      sp.part_no,
			      sp.NOMENCLATURE,
			      sp.nsn,
			      sp.order_lead_time,
			      sp.order_lead_time_defaulted,
			      sp.unit_cost,
			      sp.unit_cost_defaulted,
			      sp.unit_of_issue,
			      nsi.unit_cost_cleaned,
			      nsi.order_lead_time_cleaned,
			      nsi.planner_code,
			      nsi.planner_code_cleaned,
			      nsi.mtbdr,
			      nsi.mtbdr_cleaned,
			      nsi.smr_code,
			      nsi.smr_code_cleaned,
			      nsi.smr_code_defaulted,
			      nsi.nsi_sid,
			      nsi.TIME_TO_REPAIR_OFF_BASE_CLEAND,
				  nsi.last_update_dt,
				  case 
				  	   when sent.action_code is not null then
					   		sent.action_code
						else
				  			sp.action_code
				  end action_code
			  FROM AMD_SPARE_PARTS sp,
			    AMD_NATIONAL_STOCK_ITEMS nsi,
				amd_sent_to_a2a sent
			  WHERE sp.nsn = nsi.nsn (+)
			  and sp.part_no = sent.part_no (+) ;
				 
		RETURN parts ;
			  
	 END getPartInfo ;
	 
	 FUNCTION getTestData RETURN partCur IS
	 		  parts partCur ;
	 BEGIN
		  writeMsg(pTableName => 'amd_spare_parts', pError_location => 570,
		  pKey1 => 'getTestData' ) ;
		  commit ;
	 	  OPEN parts FOR 
			  SELECT sp.mfgr,
			      sp.part_no,
			      sp.NOMENCLATURE,
			      sp.nsn,
			      sp.order_lead_time,
			      sp.order_lead_time_defaulted,
			      sp.unit_cost,
			      sp.unit_cost_defaulted,
			      sp.unit_of_issue,
			      nsi.unit_cost_cleaned,
			      nsi.order_lead_time_cleaned,
			      nsi.planner_code,
			      nsi.planner_code_cleaned,
			      nsi.mtbdr,
			      nsi.mtbdr_cleaned,
			      nsi.smr_code,
			      nsi.smr_code_cleaned,
			      nsi.smr_code_defaulted,
			      nsi.nsi_sid,
			      nsi.TIME_TO_REPAIR_OFF_BASE_CLEAND,
				  nsi.last_update_dt,
				  case 
				  	   when sent.action_code is not null then
					   		sent.action_code
						else
							sp.action_code
				 end action_code
			  FROM AMD_SPARE_PARTS sp,
			    AMD_NATIONAL_STOCK_ITEMS nsi,
				amd_sent_to_a2a sent
			  WHERE sp.nsn = nsi.nsn (+)
			     and sp.part_no = sent.part_no (+)
			     AND sp.part_no IN (SELECT part_no FROM AMD_TEST_PARTS) ;
		 
		 RETURN parts ;
		  
	END getTestData ;
	 
	PROCEDURE processPartLeadTimes(parts IN partCur) IS
	  rec partInfoRec ;
	  cnt NUMBER := 0  ;
	  
	BEGIN
	     writeMsg(pTableName => 'tmp_a2a_part_lead_time', pError_location => 580,
			pKey1 => 'processPartLeadTimes',
			pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  
		 LOOP
			FETCH parts INTO rec ;
			EXIT WHEN parts%NOTFOUND ;
			
			IF isPartSent(rec.part_no) THEN -- part exists in amd_sent_to_a2a with any action_code
			       insertTmpA2APartLeadTime(part_no => rec.part_no,
			 						order_lead_time => rec.order_lead_time,
								order_lead_time_cleaned => rec.order_lead_time_cleaned,
								order_lead_time_defaulted => rec.order_lead_time_defaulted) ;
					cnt := cnt + 1 ;
			END IF ;
					 
			IF MOD(cnt,COMMIT_THRESHOLD) = 0 THEN
			  COMMIT ;
			END IF ;
			
		 END LOOP ;
	     writeMsg(pTableName => 'tmp_a2a_part_lead_time', pError_location => 590,
			pKey1 => 'processPartLeadTimes',
			pKey2 => 'cnt=' || TO_CHAR(cnt),
			pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		 COMMIT ;  	 
	END processPartLeadTimes ;
			   
	 PROCEDURE initA2APartLeadTime(useTestParts IN BOOLEAN := FALSE) IS
	 		   cnt NUMBER := 0 ;
			   parts partCur ;
	 BEGIN
	  writeMsg(pTableName => 'tmp_a2a_part_lead_time', pError_location => 600,
			pKey1 => 'initA2APartLeadTime',
			pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
			pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  	 
	  Mta_Truncate_Table('tmp_a2a_part_lead_time','reuse storage');
	  IF useTestParts THEN
	  	 parts := getTestData ;
	  ELSE
	    parts := getPartInfo ;
	  END IF ;
	  processPartLeadTimes(parts) ;
	  CLOSE parts ;
	  Amd_Partprime_Pkg.DiffPartToPrime  ;
	  writeMsg(pTableName => 'tmp_a2a_part_lead_time', pError_location => 610,
			pKey1 => 'initA2APartLeadTime',
			pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
			pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	  COMMIT ;  	 
	 END initA2APartLeadTime ;
	 
	 FUNCTION getValidRcmInd(rcmInd IN VARCHAR2) RETURN VARCHAR2 IS
	 BEGIN
	 	  IF UPPER(rcmInd) = 'T' THEN
		  	 RETURN 'R' ;
		  ELSE
		  	  RETURN UPPER(rcmInd) ;
		  END IF ;
	 END getValidRcmInd ;
	
	 PROCEDURE validateData(
	       mfgr IN VARCHAR2,
	       part_no IN VARCHAR2,
	       unit_issue IN VARCHAR2,
	       nomenclature IN VARCHAR2,
	       smr_code IN VARCHAR2,
	       nsn IN VARCHAR2,
	       planner_code IN VARCHAR2,
	       third_party_flag IN VARCHAR2,
	       mtbdr      IN NUMBER,
	       indenture IN VARCHAR2,
	 	   rcm_ind OUT TMP_A2A_PART_INFO.rcm_ind%TYPE) IS
	 
	 		   lineNo NUMBER := 0 ;
			   rec TMP_A2A_PART_INFO%ROWTYPE ;
	 BEGIN
	      lineNo := lineNo + 1;rec.cage_code := validateData.mfgr ;
	      lineNo := lineNo + 1;rec.part_no := validateData.part_no ;
	      lineNo := lineNo + 1;rec.unit_issue := validateData.unit_issue ;
	      lineNo := lineNo + 1;rec.noun := validateData.nomenclature ;
	      lineNo := lineNo + 1;rec.rcm_ind := SUBSTR(validateData.smr_code,6,1) ;
		  
	   	  rcm_ind := getValidRcmInd(rec.rcm_ind) ;
		  
	      lineNo := lineNo + 1;rec.nsn_fsc := SUBSTR(validateData.nsn, 1, 4) ;
	      lineNo := lineNo + 1;rec.nsn_niin := SUBSTR(validateData.nsn, 5, 9) ;
	      lineNo := lineNo + 1;rec.resp_asset_mgr := validateData.planner_code ;
	      lineNo := lineNo + 1;rec.third_party_flag := validateData.third_party_flag ;
	      lineNo := lineNo + 1;rec.mtbf := validateData.mtbdr ;
	      lineNo := lineNo + 1;rec.preferred_smrcode := validateData.smr_code ;
	      lineNo := lineNo + 1;rec.indenture := validateData.indenture ;
	 EXCEPTION WHEN OTHERS THEN
	        ErrorMsg(pSqlfunction => 'none',
		      pTableName => 'validateData',
		      pError_location => 620,
		      pKey_1 => TO_CHAR(lineNo)) ;
		 RAISE ;
	 END validateData ;
	
	PROCEDURE insertTimeToRepair(part_no IN AMD_SPARE_PARTS.part_no%TYPE,
			  nsi_sid IN AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE,
			  time_to_repair_off_base_cleand IN AMD_NATIONAL_STOCK_ITEMS.time_to_repair_off_base_cleand%TYPE) IS
			  
	    time_to_repair NUMBER ;
	    time_to_repair_defaulted NUMBER ;
		result NUMBER ;
		action_code tmp_a2a_part_lead_time.action_code%type := getActionCode(part_no) ; -- use whatever action_code is in amd_sent_to_a2a for this part
	BEGIN
		BEGIN
		  SELECT time_to_repair,
		      time_to_repair_defaulted
		      INTO time_to_repair, time_to_repair_defaulted
		      FROM AMD_PART_LOCS
		      WHERE nsi_sid = insertTimeToRepair.nsi_sid
		      AND   loc_sid = 23 ;
		EXCEPTION WHEN standard.NO_DATA_FOUND THEN
		  NULL ; -- do nothing
		  WHEN OTHERS THEN
		       ErrorMsg(pSqlfunction => 'select',
			     pTableName => 'amd_part_locs',
			     pError_location => 630,
			     pKey_1 => TO_CHAR(insertTimeToRepair.nsi_sid), pKey_2 => '23') ;
		     RAISE ;
		 END ;
	
		 IF insertTimeToRepair.time_to_repair_off_base_cleand IS NOT NULL THEN
		    time_to_repair := insertTimeToRepair.time_to_repair_off_base_cleand ;
		 ELSIF time_to_repair IS NOT NULL THEN
		    time_to_repair := ROUND(time_to_repair) ; -- time_to_repair is stored as calendar days 
		 				  	 					   	 -- round to nearest integer
		 ELSE
		  time_to_repair := time_to_repair_defaulted ;
		 END IF ;
	
		 IF time_to_repair IS not NULL or (time_to_repair is null and action_code = amd_defaults.DELETE_ACTION) THEN	 	
			  InsertPartLeadTime(
			      part_no,
			      REPAIR,
			      time_to_repair,
				  action_code) ;		
	 	END IF ;
		
	END insertTimeToRepair ;

	procedure insertPartPricing( 
	        part_no IN tmp_a2a_part_pricing.PART_NO%type,
	       price_type IN tmp_a2a_part_pricing.PRICE_TYPE%type,
	       unit_cost IN tmp_a2a_part_pricing.PRICE%type ,
		   action_code in tmp_a2a_part_pricing.action_code%type)  IS
		   
		   result number ;
		   
	begin
	   CASE action_code
	      WHEN Amd_Defaults.INSERT_ACTION THEN
	         result := insertPartPricing(part_no, price_type, unit_cost) ;
	     WHEN Amd_Defaults.UPDATE_ACTION THEN
	         result := updatePartPricing(part_no, price_type, unit_cost) ;
	     WHEN Amd_Defaults.DELETE_ACTION THEN
	         result := deletePartPricing(part_no) ;
	   END CASE ;
	end insertPartPricing ;
		
	PROCEDURE insertUnitCost (
			  part_no IN AMD_SPARE_PARTS.part_no%TYPE,
			  unit_cost_cleaned IN AMD_NATIONAL_STOCK_ITEMS.unit_cost_cleaned%TYPE,
			  unit_cost IN AMD_SPARE_PARTS.unit_cost%TYPE, 
			  unit_cost_defaulted IN AMD_SPARE_PARTS.unit_cost_defaulted%TYPE) IS
			  
	    unitCost NUMBER ;
		result 	 NUMBER ;
		action_code tmp_a2a_part_pricing.action_code%type := getActionCode(part_no) ;
		
	BEGIN
	    IF unit_cost_cleaned IS NOT NULL THEN
	       unitCost := unit_cost_cleaned ;
	    ELSIF insertUnitCost.unit_cost IS NOT NULL THEN
	       unitCost := insertUnitCost.unit_cost ;
	    ELSE
	       unitCost := insertUnitCost.unit_cost_defaulted ;
	    END IF;
	
	    IF unitCost IS NOT NULL or (unitCost is null and action_code = amd_defaults.DELETE_ACTION) THEN
	       InsertPartPricing(
	          part_no,
	         'ORDER',
	         unitCost,
			 action_code) ;
			 	
	    END IF ;
	END insertUnitCost ;
	
	  PROCEDURE processPart(rec IN partInfoRec, action_code IN VARCHAR2 := NULL) IS
	       smr_code_preferred AMD_NATIONAL_STOCK_ITEMS.SMR_CODE%TYPE :=
	              Amd_Preferred_Pkg.GetPreferredValue(rec.smr_code_cleaned, rec.smr_code, rec.smr_code_defaulted) ;
	  BEGIN
	   
	   InsertPartInfo(
	       rec.part_no,
	       rec.nomenclature,
	       NVL(action_code,rec.action_code),
	        rec.mfgr,
	       rec.unit_of_issue, -- unit_issue
	       smr_code_preferred,
	       rec.nsn,
	       Amd_Preferred_Pkg.getPreferredValue(rec.planner_code_cleaned, rec.planner_code),
	       NULL , -- third_party_flag
	       Amd_Preferred_Pkg.getPreferredValue(rec.mtbdr_cleaned, rec.mtbdr),
	       getIndenture(smr_code_preferred),
		   Amd_Preferred_Pkg.getPreferredValue(rec.unit_cost_cleaned, rec.unit_cost)) ;
	
	   IF isPartSent(rec.part_no) THEN  -- part exists in amd_sent_to_a2a with any action_code
		   insertTmpA2APartLeadTime(part_no => rec.part_no, 
		   						order_lead_time => rec.order_lead_time, 
								order_lead_time_cleaned => rec.order_lead_time_cleaned, 
								order_lead_time_defaulted => rec.order_lead_time_defaulted) ;
		
			insertTimeToRepair (part_no => rec.part_no, nsi_sid => rec.nsi_sid,
							   time_to_repair_off_base_cleand => rec.time_to_repair_off_base_cleand ) ;
							
			insertUnitCost (part_no => rec.part_no, unit_cost => rec.unit_cost,
						   unit_cost_cleaned => rec.unit_cost_cleaned,
						   unit_cost_defaulted => rec.unit_cost_defaulted) ;
		END IF ;
	  END processPart ;
	
	 
	 PROCEDURE processParts(parts IN partCur) IS
	 		   rec partInfoRec ;
			   cnt NUMBER := 0 ;
			   ins_cnt number := 0 ;
			   upd_cnt number := 0 ;
			   del_cnt number := 0 ;
	 BEGIN
	      writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 640,
			pKey1 => 'processParts',
			pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  	 
	 	  
		  LOOP
		  	  FETCH parts INTO rec ;
			  EXIT WHEN parts%NOTFOUND ;
			  case rec.action_code
			  	   when amd_defaults.INSERT_ACTION then
				   		ins_cnt := ins_cnt + 1 ;
				   when amd_defaults.UPDATE_ACTION then
				   		upd_cnt := upd_cnt + 1 ;
				   when amd_defaults.DELETE_ACTION then
				   		del_cnt := del_cnt + 1 ;
			  end case ;		
			  processPart(rec) ;
			  cnt := cnt + 1 ;
		      IF MOD(cnt,COMMIT_THRESHOLD) = 0 THEN
		   	   COMMIT ;
		      END IF ;		 
		  END LOOP ;
	      writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 650,
			pKey1 => 'processParts',
			pKey2 => 'cnt=' || TO_CHAR(cnt),
			pKey3 => 'del_cnt=' || to_char(del_cnt),
			pKey4 => 'ins_cnt=' || to_char(ins_cnt),
			pData => 'upd_cnt=' || to_char(upd_cnt),
			pComments => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  	 
		  COMMIT ;
		  
	 END processParts ;
	 
	 -- allow for collecting data by last_update_dt
	 PROCEDURE initA2APartInfo(from_dt IN DATE := START_DT, to_dt IN DATE := SYSDATE) IS
	 
	 		   preferred_smr_code  AMD_NATIONAL_STOCK_ITEMS.smr_code%TYPE ;
			   rcm_ind 			   TMP_A2A_PART_INFO.rcm_ind%TYPE ;
			   indenture 		   TMP_A2A_PART_INFO.indenture%TYPE ;
			   preferred_unit_cost TMP_A2A_PART_INFO.price%TYPE ;
			   nsn_fsc 			   TMP_A2A_PART_INFO.nsn_fsc%TYPE ;
			   nsn_niin 		   TMP_A2A_PART_INFO.nsn_niin%TYPE ;
			   cnt				   NUMBER := 0 ;
			   parts			   partCur ;
			   
	 BEGIN
	      writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 660,
			pKey1 => 'initA2APartInfo',
			pKey2 => 'start_dt=' || TO_CHAR(start_dt,'MM/DD/YYYY'),
			pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
			pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  	 
	 	  mblnSendAllData := TRUE ;
	  	  truncateA2Atables ;
		  OPEN parts FOR
			SELECT sp.mfgr,
			      sp.part_no,
			      sp.NOMENCLATURE,
			      sp.nsn,
			      sp.order_lead_time,
			      sp.order_lead_time_defaulted,
			      sp.unit_cost,
			      sp.unit_cost_defaulted,
			      sp.unit_of_issue,
			      nsi.unit_cost_cleaned,
			      nsi.order_lead_time_cleaned,
			      nsi.planner_code,
			      nsi.planner_code_cleaned,
			      nsi.mtbdr,
			      nsi.mtbdr_cleaned,
			      nsi.smr_code,
			      nsi.smr_code_cleaned,
			      nsi.smr_code_defaulted,
			      nsi.nsi_sid,
			      nsi.TIME_TO_REPAIR_OFF_BASE_CLEAND,
			      CASE 
				  WHEN TRUNC(sp.last_update_dt) >= TRUNC(nsi.last_update_dt) THEN 
				  	   sp.last_update_dt
				  ELSE
					  nsi.LAST_UPDATE_DT
			      END AS last_update_dt,
			      CASE 
					 when sent.action_code is not null then
					   		sent.action_code
					 WHEN sp.action_code = nsi.action_code THEN 
						 sp.action_code
					 ELSE
						CASE 
							WHEN sp.action_code = amd_defaults.getDELETE_ACTION OR nsi.action_code = amd_defaults.getDELETE_ACTION then
								 amd_defaults.getDELETE_ACTION
							WHEN sp.action_code = amd_defaults.getUPDATE_ACTION OR nsi.action_code = amd_defaults.getUPDATE_ACTION then
								 amd_defaults.getUPDATE_ACTION						
							ELSE
								amd_defaults.getINSERT_ACTION
						END
				END AS action_code
			  FROM AMD_SPARE_PARTS sp,
			    AMD_NATIONAL_STOCK_ITEMS nsi,
				amd_sent_to_a2a sent
			  WHERE sp.nsn = nsi.nsn (+)
			  	 and sp.part_no = sent.part_no (+)  
			     AND (TRUNC(sp.last_update_dt) BETWEEN TRUNC(from_dt) AND TRUNC(to_dt) 
				      OR TRUNC(nsi.last_update_dt) BETWEEN TRUNC(from_dt) AND TRUNC(to_dt) ) ;
					   
		  processParts(parts) ;
		  CLOSE parts ;	  
	      writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 670,
			pKey1 => 'initA2APartInfo',
			pKey2 => 'start_dt=' || TO_CHAR(start_dt,'MM/DD/YYYY'),
			pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
			pKey4 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		  COMMIT ;  	 
	 END initA2APartInfo ;
	 
	
	 FUNCTION initA2APartInfo(useTestParts IN BOOLEAN := FALSE) RETURN NUMBER IS
	     result NUMBER := SUCCESS ;
	 	 parts partCur ;
	
	 BEGIN
	  writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 680,
			pKey1 => 'initA2APartInfo',
			pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
			pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  	 
	  mblnSendAllData := TRUE ;
	  truncateA2Atables ;
	  IF useTestParts THEN
	  	 parts := getTestData ;
	  ELSE
	     parts := getPartInfo ;
	  END IF ;
	  processParts(parts) ;
	  CLOSE parts ;
	
	  writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 690,
			pKey1 => 'initA2APartInfo',
			pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
			pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	  COMMIT ;  	 
	  RETURN result ;
	
	 END initA2APartInfo ;
	 
	 PROCEDURE deletePartInfo(partInfo IN part2DeleteCur) IS
	 		   rec part2Delete ;
			   cnt NUMBER := 0 ;		   
	 		   PROCEDURE processPart(rec IN part2Delete) IS
			   			 result NUMBER ;
			   BEGIN
	   		   		result := A2a_Pkg.DeletePartInfo(rec.part_no, rec.nomenclature) ;
			   END processPart ;
	 BEGIN
	  	  writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 700,
			pKey1 => 'deletePartInfo',
			pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	 	  LOOP
		  	  FETCH partInfo INTO rec ;
			  EXIT WHEN partInfo%NOTFOUND ;
			  processPart(rec) ;
			  cnt := cnt + 1 ;
		  END LOOP ;
	  	  writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 710,
			pKey1 => 'deletePartInfo',
			pKey2 => 'cnt=' || TO_CHAR(cnt),
			pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		  COMMIT ;
	 END deletePartInfo ;
	 
	 PROCEDURE deletePartInfo(useTestParts IN BOOLEAN := FALSE) IS
	 	parts part2DeleteCur ;
		
		procedure getTestData is
		begin
		  writeMsg(pTableName => 'amd_spare_parts', pError_location => 720,
		  pKey1 => 'getTestData' ) ;
		  commit ;
	  	  OPEN parts FOR 
			   SELECT part_no, nomenclature FROM AMD_SPARE_PARTS
			   WHERE part_no IN (SELECT part_no FROM AMD_TEST_PARTS) 
			   AND action_code != Amd_Defaults.DELETE_ACTION ;
		end getTestData ;
		
		procedure getAllData is
		begin
		  writeMsg(pTableName => 'amd_spare_parts', pError_location => 730,
		  pKey1 => 'getAllData' ) ;
		  commit ;
	      OPEN parts FOR	 
			   SELECT part_no, nomenclature FROM AMD_SPARE_PARTS WHERE action_code != Amd_Defaults.DELETE_ACTION ;
		end getAllData ;
			
	 BEGIN
	  writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 740,
			pKey1 => 'deletePartInfo',
			pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
			pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  	 
	  truncateA2Atables ;
	  IF useTestParts THEN
	  	 getTestData ;
	  ELSE
	  	 getAllData ;
	  END IF ;
	  deletePartInfo(parts) ;
	  CLOSE parts ;
	  writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 750,
			pKey1 => 'deletePartInfo',
			pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
			pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	  COMMIT ;  	 
	 END deletePartInfo ;
	
	
	 PROCEDURE updateA2ApartInfo(
	        mfgr IN VARCHAR2,
	       part_no IN VARCHAR2,
	       unit_issue IN VARCHAR2,
	       nomenclature IN VARCHAR2,
	       smr_code IN VARCHAR2,
	       nsn IN VARCHAR2,
	       planner_code IN VARCHAR2,
	       third_party_flag IN VARCHAR2,
	       mtbdr      IN NUMBER,
	       indenture IN VARCHAR2,
	       action_code IN VARCHAR2,
		   price IN NUMBER)  IS
	
	         result NUMBER ;
			 plannerCode AMD_PLANNERS.planner_code%TYPE := getAssignedPlannerCode(part_no, planner_code) ;
			 rcm_ind TMP_A2A_PART_INFO.rcm_ind%TYPE := getValidRcmInd(SUBSTR(updateA2ApartInfo.smr_code,6,1)) ;
	 BEGIN
	 	 
	   UPDATE TMP_A2A_PART_INFO
	
	   SET
	     cage_code = updateA2ApartInfo.mfgr,
	     unit_issue = updateA2ApartInfo.unit_issue,
	     noun = updateA2ApartInfo.nomenclature,
	     rcm_ind = updateA2ApartInfo.rcm_ind,
	     nsn_fsc = SUBSTR(updateA2ApartInfo.nsn, 1, 4),
	     nsn_niin = SUBSTR(updateA2ApartInfo.nsn, 5, 9),
	     resp_asset_mgr = updateA2ApartInfo.plannerCode,
	     third_party_flag = updateA2ApartInfo.third_party_flag,
	     mtbf = updateA2ApartInfo.mtbdr,
	     preferred_smrcode = updateA2ApartInfo.smr_code,
	     indenture = updateA2ApartInfo.indenture,
	     action_code = updateA2ApartInfo.action_code,
	     last_update_dt = SYSDATE,
		 price = updateA2APartInfo.price
	
	    WHERE part_no = updateA2ApartInfo.part_no ;
	
	 EXCEPTION WHEN OTHERS THEN
	     ErrorMsg(pSqlfunction => 'update',
		     pTableName => 'tmp_a2a_part_info',
		     pError_location => 760,
		     pKey_1 => part_no,
		     pKey_2 => mfgr,
		     pKey_3 => nomenclature,
		     pKey_4 => nsn) ;
	   	 RAISE ;
	 END updateA2ApartInfo ;
	
	 FUNCTION isNsl(partNo IN AMD_SPARE_PARTS.part_no%TYPE) RETURN BOOLEAN IS
	    nsn AMD_SPARE_PARTS.nsn%TYPE ;
	 BEGIN
	
	   <<getNsn>>
	   BEGIN
	    SELECT nsn INTO isNsl.nsn
	    FROM AMD_SPARE_PARTS
	    WHERE partNo = part_no ;
	   EXCEPTION WHEN OTHERS THEN
	        ErrorMsg(pSqlfunction => 'select',
		     pTableName => 'amd_spare_parts',
		     pError_location => 770,
		     pKey_1 => partNo) ;
	      RAISE ;
	   END getNsn ;
	   IF UPPER(SUBSTR(nsn,1,3)) = 'NSL' AND mDebug THEN
	   	  debugMsg(partNo || ' is an NSL part.', 90) ;
	   END IF;
	   RETURN UPPER(SUBSTR(nsn,1,3)) = 'NSL' ;
	 END isNsl ;
	 
	 FUNCTION isNslYorN(partNo IN AMD_SPARE_PARTS.part_no%TYPE) RETURN VARCHAR2 IS
	 BEGIN
	 	  IF isNsl(partNo) THEN
		    RETURN 'Y' ;
		  ELSE
		    RETURN 'N' ;
		  END IF ;
	  END isNslYorN ;
	
	 function isPartSent(part_no in amd_sent_to_a2a.part_no%type) return boolean is
		thePartNo amd_sent_to_a2a.part_no%type ;
	 begin
		select part_no into thePartNo from amd_sent_to_a2a where part_no = isPartSent.part_no ;
		return true ;
	 exception when standard.no_data_found then
		return false ;
	 end isPartSent ;

	 function isPartSentYorN(part_no in amd_sent_to_a2a.part_no%type) return varchar2 is
	 begin
		if isPartSent(part_no) then
			return 'Y' ;
		else
			return 'N' ;
		end if ;
	 end isPartSentYorN ;

	 FUNCTION wasPartSent(partNo IN AMD_SPARE_PARTS.part_no%TYPE) RETURN BOOLEAN IS
	      part_no AMD_SENT_TO_A2A.PART_NO%TYPE ;
	 BEGIN
	
	   IF mblnSendAllData THEN
		   SELECT part_no INTO part_no FROM AMD_SENT_TO_A2A WHERE part_no = partNo
			   AND spo_prime_part_no IS NOT NULL ;
	   ELSE
		   SELECT part_no INTO part_no FROM AMD_SENT_TO_A2A WHERE part_no = partNo
		       AND (action_code = Amd_Defaults.INSERT_ACTION OR action_code = Amd_Defaults.UPDATE_ACTION)
			   AND spo_prime_part_no IS NOT NULL ;
	   END IF ;
	   
	   RETURN TRUE ;
	
	 EXCEPTION WHEN standard.NO_DATA_FOUND THEN
	     RETURN FALSE ;
	 END wasPartSent ;
	 
	 FUNCTION isPlannerCodeAssigned2UserId(plannerCode IN VARCHAR2) RETURN BOOLEAN IS
	 		  result NUMBER := 0 ;
	 BEGIN
	 	  <<isPlannerAssigned>>
	 	  BEGIN
	 	  	   SELECT 1 INTO result FROM dual WHERE EXISTS  (SELECT planner_code FROM AMD_PLANNER_LOGONS WHERE planner_code = plannerCode) ;
		  EXCEPTION 
		  	WHEN standard.NO_DATA_FOUND THEN
				 NULL ;
		  	WHEN OTHERS THEN
		        ErrorMsg(pSqlfunction => 'select',
			     pTableName => 'amd_planner_logons',
			     pError_location => 780,
			     pKey_1 => plannerCode) ;
			   RAISE ;
	 	 END isPlannerAssigned ;
		  
		 RETURN result = 1;
		 
	 END isPlannerCodeAssigned2UserId ;
	
	 
	
	 FUNCTION isPartValid (partNo IN AMD_SPARE_PARTS.part_no%TYPE, showReason in boolean := false) RETURN BOOLEAN IS
	    result BOOLEAN := FALSE ;
	    smrCode AMD_NATIONAL_STOCK_ITEMS.smr_code%TYPE ;
		smrCodeCleaned AMD_NATIONAL_STOCK_ITEMS.smr_code_cleaned%TYPE ;
	    mtbdr   AMD_NATIONAL_STOCK_ITEMS.mtbdr%TYPE ;
	    mtbdr_cleaned AMD_NATIONAL_STOCK_ITEMS.mtbdr_cleaned%TYPE ;
	    plannerCode AMD_NATIONAL_STOCK_ITEMS.planner_code%TYPE ;
		part_no AMD_SPARE_PARTS.part_no%TYPE ;
		plannerCodeCleaned AMD_NATIONAL_STOCK_ITEMS.planner_code_cleaned%TYPE ;
	 BEGIN
	   debugMsg(msg => 'isPartValid(' || partNo || ')', lineNo => 100) ;
	   <<doesPartExist>>
	   BEGIN
	   		SELECT part_no INTO isPartValid.part_no FROM AMD_SPARE_PARTS 
			WHERE partNo = part_no AND action_code != Amd_Defaults.DELETE_ACTION ;
	   EXCEPTION
	   		WHEN standard.NO_DATA_FOUND THEN
				 IF mDebug THEN
				 	debugMsg(partNo || ' does not exist in amd_spare_parts or has been logically deleted.', lineNo => 110) ; 
				 END IF ;
				 RETURN FALSE ;
	   END doesPartExist ;
	   
	   <<getPrimePartData>>
	   BEGIN
	    SELECT smr_code, smr_code_cleaned, mtbdr, mtbdr_cleaned, planner_code, planner_code_cleaned INTO smrCode, smrCodeCleaned, mtbdr, mtbdr_cleaned, plannerCode, plannerCodeCleaned
	    FROM AMD_NATIONAL_STOCK_ITEMS items, AMD_NSI_PARTS parts
	    WHERE isPartValid.partNo = parts.part_no
	    AND parts.UNASSIGNMENT_DATE IS NULL
	    AND parts.nsi_sid = items.nsi_sid ;
	   EXCEPTION
	     WHEN standard.NO_DATA_FOUND THEN
		   IF mDebug THEN
		   	  debugMsg(partNo || ' is NOT valid amd_nsi_parts.UNASSIGNMENT_DATE is not be NULL', lineNo => 120) ;
		   END IF ;
	       RETURN FALSE ;
	     WHEN OTHERS THEN
	         ErrorMsg(pSqlfunction => 'select',
		      pTableName => 'items / parts',
		      pError_location => 790,
		      pKey_1 => isPartValid.partNo) ;
	         RAISE ;
	   END getPrimePartData ;
	   RETURN isPartValid(partNo => partNo, smrCode => Amd_Preferred_Pkg.getPreferredValue(smrCodeCleaned,smrCode), mtbdr => Amd_Preferred_Pkg.getPreferredValue(mtbdr_cleaned,mtbdr), plannerCode => Amd_Preferred_Pkg.GetPreferredValue(plannerCodeCleaned,plannerCode), showReason => showReason) ;
	 END isPartValid ;
	
	 FUNCTION createPartInfo(part_no IN VARCHAR2,
	        action_code IN VARCHAR2 := Amd_Defaults.UPDATE_ACTION) RETURN NUMBER IS
	  TYPE  partInfo IS RECORD(
	        mfgr AMD_SPARE_PARTS.mfgr%TYPE,
	       part_no AMD_SPARE_PARTS.part_no%TYPE,
	       unit_of_issue AMD_SPARE_PARTS.unit_of_issue%TYPE,
	       nomenclature AMD_SPARE_PARTS.nomenclature%TYPE,
	       smr_code AMD_NATIONAL_STOCK_ITEMS.smr_code%TYPE,
	       smr_code_cleaned AMD_NATIONAL_STOCK_ITEMS.SMR_CODE_CLEANED%TYPE,
	       smr_code_defaulted AMD_NATIONAL_STOCK_ITEMS.SMR_CODE_DEFAULTED%TYPE,
	       nsn AMD_SPARE_PARTS.nsn%TYPE,
	       planner_code AMD_NATIONAL_STOCK_ITEMS.planner_code%TYPE,
	       planner_code_cleaned AMD_NATIONAL_STOCK_ITEMS.PLANNER_CODE_CLEANED%TYPE,
	       third_party_flag TMP_A2A_PART_INFO.third_party_flag%TYPE,
	       mtbdr      AMD_NATIONAL_STOCK_ITEMS.mtbdr%TYPE,
	       mtbdr_cleaned AMD_NATIONAL_STOCK_ITEMS.MTBDR_CLEANED%TYPE,
	       indenture TMP_A2A_PART_INFO.indenture%TYPE,
		   unit_cost_cleaned AMD_NATIONAL_STOCK_ITEMS.unit_cost_cleaned%TYPE,
		   unit_cost AMD_SPARE_PARTS.UNIT_COST%TYPE) ;
	
	
	  rec partInfo ;
	
	  rc NUMBER := A2a_Pkg.SUCCESS ;
	
	  FUNCTION insertPartInfo(rec partInfo) RETURN NUMBER IS
	  BEGIN
	    RETURN A2a_Pkg.insertPartInfo(mfgr => rec.mfgr,
	                part_no => rec.part_no, unit_issue => rec.unit_of_issue,
	             nomenclature => rec.nomenclature, smr_code => rec.smr_code,
	             nsn => rec.nsn, planner_code => rec.planner_code,
	             third_party_flag => rec.third_party_flag, mtbdr => rec.mtbdr,
	             indenture => rec.indenture,
				 price => Amd_Preferred_Pkg.getPreferredValue(rec.unit_cost_cleaned,rec.unit_cost)) ;
	  END insertPartInfo ;
	
	  FUNCTION updatePartInfo(rec partInfo) RETURN NUMBER IS
	  BEGIN
	    RETURN A2a_Pkg.updatePartInfo(mfgr => rec.mfgr,
	                part_no => rec.part_no, unit_issue => rec.unit_of_issue,
	             nomenclature => rec.nomenclature, smr_code => rec.smr_code,
	             nsn => rec.nsn, planner_code => rec.planner_code,
	             third_party_flag => rec.third_party_flag, mtbdr => rec.mtbdr,
	             indenture => rec.indenture,
				 price => Amd_Preferred_Pkg.getPreferredValue(rec.unit_cost_cleaned, rec.unit_cost)) ;
	  END updatePartInfo ;
	
	  PROCEDURE errorMsgCIP(pError_location IN NUMBER) IS
	  BEGIN
	       errorMsg(pSqlfunction => 'insert',
	    pTableName => 'tmp_a2a_part_info',
	    pError_location => pError_location,
	    pKey_1 => part_no) ;
	  END errorMsgCIP ;
	
	  PROCEDURE getPartInfo IS
	  BEGIN
	      SELECT mfgr, part_no, unit_of_issue, nomenclature,
	       smr_code, smr_code_cleaned, smr_code_defaulted,
	       sp.nsn, planner_code, planner_code_cleaned, mtbdr, mtbdr_cleaned,
		   unit_cost, unit_cost_cleaned
	       INTO
	       rec.mfgr, rec.part_no, rec.unit_of_issue, rec.nomenclature,
	       rec.smr_code, rec.smr_code_cleaned, rec.smr_code_defaulted,
	       rec.nsn, rec.planner_code, rec.planner_code_cleaned, rec.mtbdr, rec.mtbdr_cleaned,
		   rec.unit_cost, rec.unit_cost_cleaned 
	   FROM AMD_SPARE_PARTS sp,
	   AMD_NATIONAL_STOCK_ITEMS items
	   WHERE sp.part_no = createPartInfo.part_no
	   AND sp.nsn = items.nsn ;
	   rec.indenture := getIndenture(Amd_Preferred_Pkg.GetPreferredValue(rec.smr_code_cleaned, rec.smr_code, rec.smr_code_defaulted)) ;
	   rec.third_party_flag := A2a_Pkg.THIRD_PARTY_FLAG ;
	  EXCEPTION
	     WHEN OTHERS THEN
	        errorMsgCIP(pError_location => 800) ;
	      	RAISE ;
	  END getPartInfo ;
	 BEGIN
	   IF mDebug THEN
	    debugMsg('part_no=' || createPartInfo.part_no || ' action_code=' || createPartInfo.action_code, lineNo => 130) ;
	   END IF ;
	   getPartInfo ;
	
	   CASE createPartInfo.action_code
	      WHEN Amd_Defaults.UPDATE_ACTION THEN
	         <<updateAction>>
	       BEGIN
	          rc := updatePartInfo(rec) ;
	       EXCEPTION
	          WHEN OTHERS THEN
	            errorMsgCIP(pError_location => 810) ;
	          	RAISE ;
	       END updateAction ;
	
	      WHEN Amd_Defaults.INSERT_ACTION THEN
	         <<insertAction>>
	       BEGIN
	      rc := insertPartInfo(rec => rec) ;
	       EXCEPTION
	          WHEN OTHERS THEN
	            errorMsgCIP(pError_location => 820) ;
	          	RAISE ;
	       END insertAction ;
	
	      WHEN Amd_Defaults.DELETE_ACTION THEN
	         <<deleteAction>>
	       BEGIN
	      rc := deletePartInfo( part_no => rec.part_no,
	             nomenclature => rec.nomenclature) ;
	       EXCEPTION
	          WHEN OTHERS THEN
	            errorMsgCIP(pError_location => 830) ;
	          	RAISE ;
	       END deleteAction ;
	     ELSE
	        debugMsg('Invalid action_code ' || createPartInfo.action_code, lineNo => 140) ;
	        RAISE A2a_Pkg.APPLICATION_ERROR ;
	   END CASE ;
	
	   RETURN rc ;
	 EXCEPTION
	    WHEN OTHERS THEN
	       errorMsgCIP(pError_location => 840) ;
	       RAISE ;
	 END createPartInfo  ;
	
	 
	 
	 FUNCTION InsertPartInfo(
	       mfgr IN VARCHAR2,
	       part_no IN VARCHAR2,
	       unit_issue IN VARCHAR2,
	       nomenclature IN VARCHAR2,
	       smr_code IN VARCHAR2,
	       nsn IN VARCHAR2,
	       planner_code IN VARCHAR2,
	       third_party_flag IN VARCHAR2,
	       mtbdr      IN NUMBER,
	       indenture IN VARCHAR2,
		   price IN NUMBER) RETURN NUMBER IS
	
	     result NUMBER ;
		 rcm_ind TMP_A2A_PART_INFO.RCM_IND%TYPE ;
		 plannerCode AMD_PLANNERS.planner_code%TYPE := getAssignedPlannerCode(part_no, planner_code) ;
		 
	
	 BEGIN
	   mArgs := 'InsertPartInfo(' || mfgr || ', ' || part_no || ', ' || unit_issue || ', ' || nomenclature
	       || ', ' || smr_code || ', ' || nsn || ', ' || planner_code || ', ' || third_party_flag
	      || ', ' || mtbdr || ', ' || indenture || ')' ;
	   validateData (
	       mfgr,
	       part_no,
	       unit_issue,
	       nomenclature,
	       smr_code,
	       nsn,
	       planner_code,
	       third_party_flag,
	       mtbdr,
	       indenture,
		   rcm_ind) ;
	   IF isPartValid(partNo => part_no, smrCode => smr_code, mtbdr => mtbdr, plannerCode => planner_code) THEN
	    INSERT INTO TMP_A2A_PART_INFO
	    (
	       cage_code,
	       part_no,
	       unit_issue,
	       noun,
	       rcm_ind,
	       nsn_fsc,
	       nsn_niin,
	       resp_asset_mgr,
	       third_party_flag,
	       mtbf,
	       preferred_smrcode,
	       indenture,
	       action_code,
	       last_update_dt,
		   price
	   )
	   VALUES
	   (
	        insertPartInfo.mfgr,
	       insertPartInfo.part_no,
	       insertPartInfo.unit_issue,
	       insertPartInfo.nomenclature,
	       insertPartInfo.rcm_ind,
	       SUBSTR(insertPartInfo.nsn, 1, 4),
	       SUBSTR(insertPartInfo.nsn, 5, 9),
	       insertPartInfo.plannerCode,
	       insertPartInfo.third_party_flag,
	       insertPartInfo.mtbdr,
	       insertPartInfo.smr_code,
	       insertPartInfo.indenture,
	       Amd_Defaults.INSERT_ACTION,
	       SYSDATE,
		   insertPartInfo.price
	   ) ;
	  ELSE
	   result := A2a_Pkg.DeletePartInfo(part_no, nomenclature) ;
	
	  END IF ;
	
	  RETURN SUCCESS ;
	 EXCEPTION
	     WHEN standard.DUP_VAL_ON_INDEX THEN
	       updateA2ApartInfo( mfgr, part_no, unit_issue, nomenclature, smr_code, nsn,
	       planner_code, third_party_flag, mtbdr, indenture, Amd_Defaults.INSERT_ACTION, price) ;
	      RETURN SUCCESS ;
	
	     WHEN OTHERS THEN
	         ErrorMsg(pSqlfunction => 'insert',
		      pTableName => 'tmp_a2a_part_info',
		      pError_location => 850,
		      pKey_1 => part_no,
		      pKey_2 => mfgr,
		      pKey_3 => nomenclature,
		      pKey_4 => nsn) ;
	       RAISE ;
	
	 END InsertPartInfo ;
	
	
	 FUNCTION UpdatePartInfo(
	       mfgr IN VARCHAR2,
	       part_no IN VARCHAR2,
	       unit_issue IN VARCHAR2,
	       nomenclature IN VARCHAR2,
	       smr_code IN VARCHAR2,
	       nsn IN VARCHAR2,
	       planner_code IN VARCHAR2,
	       third_party_flag IN VARCHAR2,
	       mtbdr      IN NUMBER,
	       indenture IN VARCHAR2,
		   price IN NUMBER) RETURN NUMBER IS
	  
	  result NUMBER ;
	  rcm_ind TMP_A2A_PART_INFO.rcm_ind%TYPE ;
	  
	 BEGIN
	   mArgs := 'UpdatePartInfo(' || mfgr || ', ' || part_no || ', ' || unit_issue || ', '
	     || nomenclature || ', ' || smr_code || ', ' || nsn || ', ' || planner_code
	    || ', ' || third_party_flag || ', ' || mtbdr || ', ' || indenture ||')' ;
	   debugMsg(msg => mArgs, lineNo => 150 ) ;
	   
	   validateData (
	       mfgr,
	       part_no,
	       unit_issue,
	       nomenclature,
	       smr_code,
	       nsn,
	       planner_code,
	       third_party_flag,
	       mtbdr,
	       indenture,
		   rcm_ind) ;
		   
	   IF isPartValid(partNo => part_no, smrCode => smr_code, mtbdr => mtbdr, plannerCode => planner_code) THEN
	    INSERT INTO TMP_A2A_PART_INFO
	    (
	       cage_code,
	       part_no,
	       unit_issue,
	       noun,
	       rcm_ind,
	       nsn_fsc,
	       nsn_niin,
	       resp_asset_mgr,
	       third_party_flag,
	       mtbf,
	       preferred_smrcode,
	       indenture,
	       action_code,
	       last_update_dt,
		   price
	   )
	   VALUES
	   (
	        UpdatePartInfo.mfgr,
	       UpdatePartInfo.part_no,
	       UpdatePartInfo.unit_issue,
	       UpdatePartInfo.nomenclature,
	       rcm_ind,
	       SUBSTR(UpdatePartInfo.nsn, 1, 4),
	       SUBSTR(UpdatePartInfo.nsn, 5, 9),
	       UpdatePartInfo.planner_code,
	       UpdatePartInfo.third_party_flag,
	       UpdatePartInfo.mtbdr,
	       UpdatePartInfo.smr_code,
	       UpdatePartInfo.indenture,
	       Amd_Defaults.UPDATE_ACTION,
	       SYSDATE,
		   updatePartInfo.price
	   ) ;
	  ELSE
	   result := A2a_Pkg.DeletePartInfo(part_no, nomenclature) ;
	
	  END IF ;
	  RETURN SUCCESS ;
	 EXCEPTION
	     WHEN standard.DUP_VAL_ON_INDEX THEN
	       updateA2ApartInfo( mfgr, part_no, unit_issue, nomenclature, smr_code, nsn,
	       planner_code, third_party_flag, mtbdr, indenture, Amd_Defaults.UPDATE_ACTION, price) ;
	      RETURN SUCCESS ;
	     WHEN OTHERS THEN
		 	  ErrorMsg(pSqlfunction => 'update',
		       pTableName => 'tmp_a2a_part_info',
		       pError_location => 860,
		       pKey_1 => part_no,
		       pKey_2 => mfgr,
		       pKey_3 => nomenclature,
		       pKey_4 => nsn) ;
		    RAISE ;
	
	
	
	 END UpdatePartInfo;
	
	 FUNCTION DeletePartInfo(
	       part_no IN VARCHAR2, nomenclature IN VARCHAR2) RETURN NUMBER IS
	  result NUMBER ;
	  PROCEDURE makeA2AdeletePartInfo IS
	  BEGIN
	    debugMsg(msg => 'makeA2AdeletePartInfo', lineNo => 160) ;
	    UPDATE TMP_A2A_PART_INFO
	    SET noun = DeletePartInfo.nomenclature,
	    action_code = Amd_Defaults.DELETE_ACTION,
	    last_update_dt = SYSDATE
	    WHERE part_no = DeletePartInfo.part_no ;
	
	  EXCEPTION WHEN OTHERS THEN
	  	ErrorMsg(pSqlfunction => 'delete',
	      pTableName => 'tmp_a2a_part_info',
	      pError_location => 870,
	      pKey_1 => part_no) ;
	   RAISE ;
	
	  END makeA2AdeletePartInfo ;
	
	 BEGIN
	   mArgs := 'DeletePartInfo(' || part_no || ', ' || nomenclature || ')' ;
	   debugMsg(msg => mArgs, lineNo => 170 ) ;
	   -- mblnSendAllData allows parts to be deleted even if they have been deleted previously.  This
	   -- allows the system to send all types of A2A transactions when the initPartInfoA2A is executed
	   IF isPartSent(part_no => part_no)  THEN  -- part exists in amd_sent_to_a2a with any action_code
	    INSERT INTO TMP_A2A_PART_INFO
	    (
	       part_no,
	       noun,
	       action_code,
	       last_update_dt
	    )
	    VALUES
	    (
	         DeletePartInfo.part_no,
	       nomenclature,
	       Amd_Defaults.DELETE_ACTION,
	       SYSDATE
	    ) ;
	   END IF ;
	   RETURN SUCCESS ;
	 EXCEPTION
	  WHEN standard.DUP_VAL_ON_INDEX THEN
	    makeA2AdeletePartInfo ;
	    RETURN SUCCESS ;
	
	  WHEN OTHERS THEN
	   ErrorMsg(pSqlfunction => 'delete',
	      pTableName => 'tmp_a2a_part_info',
	      pError_location => 880,
	      pKey_1 => part_no) ;
	   RAISE ;
	
	 END DeletePartInfo ;
	
	 PROCEDURE updateA2ApartLeadTime(
	        part_no IN VARCHAR2,
	       lead_time_type IN VARCHAR2,
	       lead_time IN NUMBER,
	       action_code IN VARCHAR2)  IS
	     result NUMBER ;
		 cage_code TMP_A2A_PART_LEAD_TIME.cage_code%TYPE := Amd_Utils.getCageCode(part_no) ;
	 BEGIN
	
	   UPDATE TMP_A2A_PART_LEAD_TIME
	   SET lead_time = updateA2ApartLeadTime.lead_time,
	   action_code = updateA2ApartLeadTime.action_code,
	   last_update_dt = SYSDATE,
	   cage_code = updateA2aPartLeadTime.cage_code
	   WHERE part_no = updateA2ApartLeadTime.part_no
	   AND lead_time_type = updateA2ApartLeadTime.lead_time_type ;
	
	 EXCEPTION WHEN OTHERS THEN
	    ErrorMsg(pSqlfunction => 'update',
	       pTableName => 'tmp_a2a_part_lead_time',
	       pError_location => 890,
	       pKey_1 => part_no,
	       pKey_2 => lead_time_type,
	       pKey_3 => lead_time,
		   pKey_4 => cage_code) ;
	   RAISE ;
	 END updateA2ApartLeadTime ;
	
	
	 FUNCTION InsertPartLeadTime(
	        part_no IN VARCHAR2,
	       lead_time_type IN VARCHAR2,
	       lead_time IN NUMBER) RETURN NUMBER IS
	  result NUMBER ;
	  cage_code TMP_A2A_PART_LEAD_TIME.cage_code%TYPE := Amd_Utils.getCageCode(part_no) ;
	  PROCEDURE validateData IS
	  			lineNo NUMBER := 0 ;
				rec TMP_A2A_PART_LEAD_TIME%ROWTYPE ;
	  BEGIN
	  	   lineNo := lineNo + 1;rec.part_no := part_no ;
	  	   lineNo := lineNo + 1;rec.lead_time_type := lead_time_type ;
	  	   lineNo := lineNo + 1;rec.lead_time := lead_time ;
	  EXCEPTION WHEN OTHERS THEN
	  	 errorMsg(	   
		     pSqlfunction => ':=',
		     pTableName => 'tmp_a2a_part_lead_time',
		     pError_location => 900,
		     pKey_1 => TO_CHAR(lineNo)) ;
		 RAISE ;
	  END validateData ;
	 BEGIN
	   mArgs := 'updateA2APartLeadTime(' || part_no || ', ' || lead_time_type || ', ' || lead_time || ')' ;
	   validateData ;
	   IF isPartValid(part_no) AND wasPartSent(part_no) THEN
	    INSERT INTO TMP_A2A_PART_LEAD_TIME
	    (
	     part_no,
		 cage_code,
	     lead_time_type,
	     lead_time,
	     action_code,
	     last_update_dt
	    )
	    VALUES
	    (
	    part_no,
		insertPartLeadTime.cage_code,
	    lead_time_type,
	    lead_time,
	    Amd_Defaults.INSERT_ACTION,
	    SYSDATE
	    ) ;
	   END IF ;
	
	   RETURN SUCCESS ;
	
	 EXCEPTION
	  WHEN standard.DUP_VAL_ON_INDEX THEN
	    updateA2ApartLeadTime(part_no, lead_time_type, lead_time, Amd_Defaults.INSERT_ACTION) ;
	    RETURN SUCCESS ;
	
	  WHEN OTHERS THEN
	   ErrorMsg(pSqlfunction => 'insert',
	      pTableName => 'tmp_a2a_part_lead_time',
	      pError_location => 910,
	      pKey_1 => part_no,
	      pKey_2 => lead_time_type,
	      pKey_3 => lead_time) ;
	   RAISE ;
	
	 END InsertPartLeadTime ;
	
	 FUNCTION UpdatePartLeadTime(
	        part_no IN VARCHAR2,
	       lead_time_type IN VARCHAR2,
	       lead_time IN NUMBER) RETURN NUMBER IS
	  result NUMBER ;
	  cage_code TMP_A2A_PART_LEAD_TIME.cage_code%TYPE := Amd_Utils.getCageCode(part_no) ;
	 BEGIN
	   mArgs := 'UpdatePartLeadTime(' || part_no || ', ' || lead_time_type || ', ' || lead_time || ')' ;
	   IF isPartValid(part_no) AND wasPartSent(part_no) THEN
	    INSERT INTO TMP_A2A_PART_LEAD_TIME
	    (
	     part_no,
		 cage_code,
	     lead_time_type,
	     lead_time,
	     action_code,
	     last_update_dt
	    )
	    VALUES
	    (
	    part_no,
		updatePartLeadTime.cage_code,
	    lead_time_type,
	    lead_time,
	    Amd_Defaults.UPDATE_ACTION,
	    SYSDATE
	    ) ;
	   END IF ;
	   RETURN SUCCESS ;
	
	 EXCEPTION
	  WHEN standard.DUP_VAL_ON_INDEX THEN
	    updateA2ApartLeadTime(part_no, lead_time_type, lead_time, Amd_Defaults.UPDATE_ACTION) ;
	    RETURN SUCCESS ;
	
	  WHEN OTHERS THEN
	   ErrorMsg(pSqlfunction => 'update',
	      pTableName => 'tmp_a2a_part_lead_time',
	      pError_location => 920,
	      pKey_1 => part_no,
	      pKey_2 => lead_time_type,
	      pKey_3 => lead_time) ;
	
	    RAISE ;
	 END UpdatePartLeadTime ;
	
	
	 FUNCTION DeletePartLeadTime(
	        part_no IN VARCHAR2) RETURN NUMBER IS
	
	   rc NUMBER ;
	   cage_code TMP_A2A_PART_LEAD_TIME.cage_code%TYPE := Amd_Utils.getCageCode(part_no) ;
	
	   PROCEDURE makeDelete IS
	       rc NUMBER ;
	   BEGIN
	       UPDATE TMP_A2A_PART_LEAD_TIME
	     SET action_code = Amd_Defaults.DELETE_ACTION,
	     last_update_dt = SYSDATE
	     WHERE part_no = DeletePartLeadTime.part_no
	     AND lead_time_type = REPAIR ;
	   EXCEPTION WHEN OTHERS THEN
	     ErrorMsg(pSqlfunction => 'update',
	      pTableName => 'tmp_a2a_part_lead_time',
	      pError_location => 930,
	      pKey_1 => part_no) ;
	    RAISE ;
	
	   END makeDelete ;
	
	 BEGIN
	   mArgs := 'DeletePartLeadTime(' || part_no || ')' ;
	   IF isPartSent(part_no) THEN  -- part exists in amd_sent_to_a2a with any action_code
	    INSERT INTO TMP_A2A_PART_LEAD_TIME
	    (
	     part_no,
		 cage_code,
	     lead_time_type,
	     action_code,
	     last_update_dt
	    )
	    VALUES
	    (
	    part_no,
		deletePartLeadTime.cage_code,
	    REPAIR,
	    Amd_Defaults.DELETE_ACTION,
	    SYSDATE
	    ) ;
	   END IF ;
	   RETURN SUCCESS ;
	
	 EXCEPTION
	     WHEN standard.DUP_VAL_ON_INDEX THEN
	    makeDelete ;
	    RETURN SUCCESS ;
	
	  WHEN OTHERS THEN
	     ErrorMsg(pSqlfunction => 'insert',
	      pTableName => 'tmp_a2a_part_lead_time',
	      pError_location => 940,
	      pKey_1 => part_no) ;
	    RAISE ;
	
	 END DeletePartLeadTime ;
	
	
	 PROCEDURE updateA2ApartPricing(
	        part_no IN VARCHAR2,
	       price_type IN VARCHAR2,
	       price IN NUMBER,
	       action_code IN VARCHAR2)  IS
	      result NUMBER ;
	 BEGIN
	   UPDATE TMP_A2A_PART_PRICING
	   SET
	   price_fiscal_year = TO_CHAR(SYSDATE, 'YYYY'),
	   price_type = updateA2ApartPricing.price_type,
	   price = updateA2ApartPricing.price,
	   action_code = updateA2ApartPricing.action_code,
	   last_update_dt = SYSDATE
	
	   WHERE part_no = updateA2ApartPricing.part_no ;
	
	 EXCEPTION WHEN OTHERS THEN
	   ErrorMsg(pSqlfunction => 'update',
	      pTableName => 'tmp_a2a_part_pricing',
	      pError_location => 950,
	      pKey_1 => part_no,
	      pKey_2 => price_type,
	      pKey_3 => price,
	      pKey_4 => TO_CHAR(SYSDATE, 'YYYY') );
	  RAISE ;
	 END updateA2ApartPricing ;
	
	 FUNCTION InsertPartPricing(
	        part_no IN VARCHAR2,
	       price_type IN VARCHAR2,
	       unit_cost IN NUMBER) RETURN NUMBER IS
	  result NUMBER ;
	  price NUMBER := unit_cost ;
	 BEGIN
	   mArgs := 'InsertPartPricing(' || part_no || ', ' || price_type || ', ' || unit_cost || ')' ;
	   IF isPartValid(part_no) THEN
	    IF price IS NULL THEN
	     price := 4999.99 ;
	    END IF ;
	    INSERT INTO TMP_A2A_PART_PRICING
	    (
	     part_no,
	     price_fiscal_year,
	     price_type,
	     price,
	     price_date, -- do not sendthis field
	     action_code,
	     last_update_dt
	    )
	    VALUES
	    (
	     part_no,
	     TO_CHAR(SYSDATE, 'YYYY'),
	     price_type,
	     price,
	     SYSDATE,
	     Amd_Defaults.INSERT_ACTION,
	     SYSDATE
	    ) ;
	   END IF ;
	
	   RETURN SUCCESS ;
	
	 EXCEPTION
	     WHEN standard.DUP_VAL_ON_INDEX THEN
	    updateA2ApartPricing(part_no,price_type,price,Amd_Defaults.INSERT_ACTION) ;
	    RETURN SUCCESS ;
	
	  WHEN OTHERS THEN
	   ErrorMsg(pSqlfunction => 'insert',
	      pTableName => 'tmp_a2a_part_pricing',
	      pError_location => 960,
	      pKey_1 => part_no,
	      pKey_2 => price_type,
	      pKey_3 => unit_cost,
	      pKey_4 => TO_CHAR(SYSDATE, 'YYYY') );
	   RAISE ;
	
	 END InsertPartPricing ;
	
	
	 FUNCTION UpdatePartPricing(
	        part_no IN VARCHAR2,
	       price_type IN VARCHAR2,
	       unit_cost IN NUMBER) RETURN NUMBER IS
	  result NUMBER ;
	 BEGIN
	   mArgs := 'UpdatePartPricing(' || part_no || ', ' || price_type || ', ' || unit_cost || ')' ;
	   IF isPartValid(part_no) THEN
	    INSERT INTO TMP_A2A_PART_PRICING
	    (
	     part_no,
	     price_fiscal_year,
	     price_type,
	     price,
	     price_date, -- do not sent this field
	     action_code,
	     last_update_dt
	    )
	    VALUES
	    (
	     part_no,
	     TO_CHAR(SYSDATE, 'YYYY'),
	     price_type,
	     unit_cost,
	     SYSDATE,
	     Amd_Defaults.UPDATE_ACTION,
	     SYSDATE
	    ) ;
	   END IF ;
	
	   RETURN SUCCESS ;
	
	
	
	 EXCEPTION
	     WHEN standard.DUP_VAL_ON_INDEX THEN
	    updateA2ApartPricing(part_no,price_type, unit_cost,Amd_Defaults.UPDATE_ACTION) ;
	    RETURN SUCCESS ;
	
	  WHEN OTHERS THEN
	   ErrorMsg(pSqlfunction => 'update',
	      pTableName => 'tmp_a2a_part_pricing',
	      pError_location => 970,
	      pKey_1 => part_no,
	      pKey_2 => price_type,
	      pKey_3 => unit_cost,
	      pKey_4 => TO_CHAR(SYSDATE, 'YYYY') );
	   RAISE ;
	
	 END UpdatePartPricing ;
	
	
	 FUNCTION DeletePartPricing(
	        part_no IN VARCHAR2) RETURN NUMBER IS
	  result NUMBER ;
	
	  PROCEDURE makeDelete IS
	  BEGIN
	    UPDATE TMP_A2A_PART_PRICING
	    SET action_code = Amd_Defaults.DELETE_ACTION,
	    last_update_dt = SYSDATE
	    WHERE part_no = DeletePartPricing.part_no ;
	  EXCEPTION WHEN OTHERS THEN
	   ErrorMsg(pSqlfunction => 'update',
	      pTableName => 'tmp_a2a_part_pricing',
	      pError_location => 980,
	      pKey_1 => part_no) ;
	   RAISE ;
	
	  END makeDelete ;
	
	 BEGIN
	      mArgs := 'DeletePartPricing(' || part_no || ')' ;
	   IF isPartValid(part_no) THEN
	    INSERT INTO TMP_A2A_PART_PRICING
	    (
	     part_no,
	     price_type,
	     price,
	     action_code,
	     last_update_dt
	    )
	    VALUES
	    (
	     part_no,
	     A2a_Pkg.AN_ORDER,
	     0,
	     Amd_Defaults.DELETE_ACTION,
	     SYSDATE
	    ) ;
	   END IF ;
	
	   RETURN SUCCESS ;
	
	 EXCEPTION
	     WHEN standard.DUP_VAL_ON_INDEX THEN
	    makeDelete ;
	    RETURN SUCCESS ;
	
	  WHEN OTHERS THEN
	   ErrorMsg(pSqlfunction => 'update',
	      pTableName => 'tmp_a2a_part_pricing',
	      pError_location => 990,
	      pKey_1 => part_no) ;
	   RAISE ;
	
	 END DeletePartPricing ;
	
	 PROCEDURE updateA2AlocPartLeadTime(
	        part_no IN VARCHAR2,
	       location_name IN VARCHAR2,
	       lead_time_type IN VARCHAR2,
	       time_to_repair IN NUMBER,
	       action_code IN VARCHAR2) IS
	      result NUMBER ;
	 BEGIN
	   UPDATE TMP_A2A_LOC_PART_LEAD_TIME
	   SET
	    site_location = location_name,
	    lead_time_type = updateA2AlocPartLeadTime.lead_time_type,
	    lead_time = time_to_repair,
	    action_code = updateA2AlocPartLeadTime.action_code,
	    last_update_dt = SYSDATE
	   WHERE part_no = updateA2AlocPartLeadTime.part_no ;
	
	 EXCEPTION WHEN OTHERS THEN
	   ErrorMsg(pSqlfunction => 'insert',
	      pTableName => 'tmp_a2a_loc_part_lead_time',
	      pError_location => 1000,
	      pKey_1 => part_no,
	      pKey_2 => lead_time_type,
	      pKey_3 => time_to_repair );
	  RAISE ;
	 END updateA2AlocPartLeadTime ;
	
	 FUNCTION InsertLocPartLeadTime(
	        part_no IN VARCHAR2,
	       loc_sid IN NUMBER,
	       location_name IN VARCHAR2,
	       lead_time_type IN VARCHAR2,
	       time_to_repair IN NUMBER) RETURN NUMBER IS
	  result NUMBER ;
	 BEGIN
	      mArgs := 'InsertLocPartLeadTime(' || part_no || ', ' || loc_sid || ', ' || location_name || ', ' || lead_time_type || ', ' || time_to_repair || ')' ;
	    IF isPartValid(part_no) AND wasPartSent(part_no) THEN
	    INSERT INTO TMP_A2A_LOC_PART_LEAD_TIME
	    (
	     part_no,
	     site_location,
	     lead_time_type,
	     lead_time,
	     action_code,
	     last_update_dt
	    )
	    VALUES
	    (
	      part_no,
	      location_name,
	      lead_time_type,
	      time_to_repair,
	      Amd_Defaults.INSERT_ACTION,
	      SYSDATE
	    ) ;
	   END IF ;
	   RETURN SUCCESS ;
	
	 EXCEPTION
	     WHEN standard.DUP_VAL_ON_INDEX THEN
	    updateA2AlocPartLeadTime(part_no,location_name,lead_time_type,time_to_repair,Amd_Defaults.INSERT_ACTION) ;
	    RETURN SUCCESS ;
	
	  WHEN OTHERS THEN
	   ErrorMsg(pSqlfunction => 'insert',
	      pTableName => 'tmp_a2a_loc_part_lead_time',
	      pError_location => 1010,
	      pKey_1 => part_no,
	      pKey_2 => loc_sid,
	      pKey_3 => lead_time_type,
	      pKey_4 => time_to_repair );
	   RAISE ;
	 END InsertLocPartLeadTime ;
	
	
	 FUNCTION UpdateLocPartLeadTime(
	        part_no IN VARCHAR2,
	       loc_sid IN NUMBER,
	       location_name IN VARCHAR2,
	       lead_time_type IN VARCHAR2,
	       time_to_repair IN NUMBER) RETURN NUMBER IS
	  result NUMBER ;
	 BEGIN
	      mArgs := 'UpdateLocPartLeadTime(' || part_no || ', ' || loc_sid || ', ' || location_name || ', ' || lead_time_type || ', ' || time_to_repair || ')' ;
	   IF isPartValid(part_no) AND wasPartSent(part_no) THEN
	    INSERT INTO TMP_A2A_LOC_PART_LEAD_TIME
	    (
	     part_no,
	     site_location,
	     lead_time_type,
	     lead_time,
	     action_code,
	     last_update_dt
	    )
	    VALUES
	    (
	      part_no,
	      location_name,
	      lead_time_type,
	      time_to_repair,
	      Amd_Defaults.UPDATE_ACTION,
	      SYSDATE
	    ) ;
	   END IF ;
	   RETURN SUCCESS ;
	
	 EXCEPTION
	     WHEN standard.DUP_VAL_ON_INDEX THEN
	    updateA2AlocPartLeadTime(part_no,location_name,lead_time_type,time_to_repair,Amd_Defaults.UPDATE_ACTION) ;
	    RETURN SUCCESS ;
	
	  WHEN OTHERS THEN
	   ErrorMsg(pSqlfunction => 'update',
	      pTableName => 'tmp_a2a_loc_part_lead_time',
	      pError_location => 1020,
	      pKey_1 => part_no,
	      pKey_2 => loc_sid,
	      pKey_3 => lead_time_type,
	      pKey_4 => time_to_repair );
	
	   RAISE ;
	
	 END UpdateLocPartLeadTime ;
	
	
	 FUNCTION DeleteLocPartLeadTime(
	        part_no IN VARCHAR2,
	       loc_sid IN NUMBER,
	       location_name IN NUMBER) RETURN NUMBER IS
	  result NUMBER ;
	  PROCEDURE makeDelete IS
	  BEGIN
	    UPDATE TMP_A2A_LOC_PART_LEAD_TIME
	    SET action_code = Amd_Defaults.DELETE_ACTION,
	    last_update_dt = SYSDATE
	    WHERE part_no = DeleteLocPartLeadTime.part_no
	    AND loc_sid = DeleteLocPartLeadTime.loc_sid ;
	  EXCEPTION WHEN OTHERS THEN
	   ErrorMsg(pSqlfunction => 'delete',
	      pTableName => 'tmp_a2a_loc_part_lead_time',
	      pError_location => 1030,
	      pKey_1 => part_no,
	      pKey_2 => loc_sid,
	      pKey_3 => location_name );
	
	   RAISE ;
	
	  END makeDelete ;
	 BEGIN
	      mArgs := 'DeleteLocPartLeadTime(' || part_no || ', ' || loc_sid || ', ' || location_name || ')' ;
	   IF isPartSent(part_no) THEN  -- part exists in amd_sent_to_a2a with any action_code
	    INSERT INTO TMP_A2A_LOC_PART_LEAD_TIME
	    (
	     part_no,
	     site_location,
	     action_code,
	     last_update_dt
	    )
	    VALUES
	    (
	      part_no,
	      location_name,
	      Amd_Defaults.DELETE_ACTION,
	      SYSDATE
	    ) ;
	   END IF ;
	   RETURN SUCCESS ;
	
	 EXCEPTION WHEN OTHERS THEN
	 	ErrorMsg(pSqlfunction => 'delete',
	     pTableName => 'tmp_a2a_loc_part_lead_time',
	     pError_location => 1040,
	     pKey_1 => part_no,
	     pKey_2 => loc_sid,
	     pKey_3 => location_name );
	
	  RAISE ;
	
	 END DeleteLocPartLeadTime ;
	
	 PROCEDURE initA2ASpoUsers IS
	 		   CURSOR allUsers IS
			   SELECT * FROM AMD_USERS ;
	 BEGIN
	  	  Mta_Truncate_Table('tmp_a2a_spo_users','reuse storage');
	 	  FOR rec IN allUsers LOOP
			  insertTmpA2ASpoUsers(rec.bems_id, rec.stable_email, rec.last_name, rec.first_Name, rec.action_code) ;
		  END LOOP ;
	 END initA2ASpoUsers ;
	 
	 PROCEDURE deleteAllSiteRespAssetMgr IS
	 BEGIN
	   Mta_Truncate_Table('tmp_a2a_site_resp_asset_mgr','reuse storage');
	   FOR rec IN managers LOOP
	     insertSiteRespAssetMgr(assetMgr => rec.planner_code, logonId => rec.logon_id, action_code => Amd_Defaults.DELETE_ACTION,
		 								 data_source => rec.data_source) ;
	   END LOOP ;
	 END deleteAllSiteRespAssetMgr ;
	
	 PROCEDURE initSiteRespAssetMgr IS
	 		   cnt number := 0 ;
			   cntNoUser number := 0 ;
	 BEGIN
	   writeMsg(pTableName => 'tmp_a2a_site_resp_asset_mgr', pError_location => 1050,
		pKey1 => 'initSiteRespAssetMgr',
		pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  	 
	   Mta_Truncate_Table('tmp_a2a_site_resp_asset_mgr','reuse storage');
	   FOR rec IN managers LOOP
	     cnt := cnt + 1 ;
	     insertSiteRespAssetMgr(assetMgr => rec.planner_code, logonId => rec.logon_id, action_code => rec.action_code,
		 								 data_source => rec.data_source) ;
	   END LOOP ;
	   /*
	   for rec in managersNoUser loop
	   	 cntNoUser := cntNoUser + 1 ;
	     insertSiteRespAssetMgr(assetMgr => rec.planner_code, logonId => rec.logon_id, action_code => Amd_Defaults.INSERT_ACTION,
		 								 data_source => rec.data_source) ;
	   end loop ;
	   */
	   writeMsg(pTableName => 'tmp_a2a_site_resp_asset_mgr', pError_location => 1060,
		pKey1 => 'initSiteRespAssetMgr',
		pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
		pKey3 => 'cnt=' || to_char(cnt) ) ;
		-- pKey4 => 'cntNoUser=' || to_char(cntNoUser) ) ; 
	   commit ; 	 
	 END initSiteRespAssetMgr ;
	
	 PROCEDURE insertSiteRespAssetMgr(
	        assetMgr IN TMP_A2A_SITE_RESP_ASSET_MGR.SITE_RESP_ASSET_MGR%TYPE,
	       logonId  IN TMP_A2A_SITE_RESP_ASSET_MGR.TOOL_LOGON_ID%TYPE,
	       action_code IN TMP_A2A_SITE_RESP_ASSET_MGR.action_code%TYPE,
		   data_source in tmp_a2a_site_resp_asset_mgr.data_source%type) IS
		   
		   PROCEDURE doUpdate IS
		   BEGIN
		        UPDATE TMP_A2A_SITE_RESP_ASSET_MGR
		        SET last_update_dt = SYSDATE,
		        action_code = insertSiteRespAssetMgr.action_code,
				data_source = insertSiteRespAssetMgr.data_source
		        WHERE site_resp_asset_mgr = InsertSiteRespAssetMgr.assetMgr
				AND tool_logon_id = insertSiteRespAssetMgr.logonId ;
			EXCEPTION WHEN OTHERS THEN
		       ErrorMsg( pSqlfunction => 'update', pTableName => 'tmp_a2a_site_resp_asset_mgr', pError_location => 1070,
		         pkey_1 => assetMgr, pKey_2 => logonId, pKey_3 => data_source) ;
		       RAISE ;
		   
		   END doUpdate ;
	 BEGIN
	   mArgs := 'insertSiteRespAssetMgr(' || assetMgr || ', ' || logonId || ', ' || data_source || ')' ;
	   <<insertTmpA2ASiteRespAssetMgr>>
	   BEGIN
	    INSERT INTO TMP_A2A_SITE_RESP_ASSET_MGR
	    (site_resp_asset_mgr, tool_logon_id, action_code, data_source, last_update_dt)
	    VALUES (assetmgr, logonid, insertSiteRespAssetMgr.action_code, data_source, SYSDATE) ;
	   EXCEPTION
	       WHEN standard.DUP_VAL_ON_INDEX THEN
		   		doUpdate ;
	     WHEN OTHERS THEN
	       ErrorMsg( pSqlfunction => 'insert', pTableName => 'tmp_a2a_site_resp_asset_mgr', pError_location => 1080,
	         pkey_1 => assetMgr, pKey_2 => logonId, pKey_3 => data_source) ;
	       RAISE ;
	      END insertTmpA2ASiteRespAssetMgr ;
	
	 EXCEPTION WHEN OTHERS THEN
	    ErrorMsg( pSqlfunction => 'insert', pTableName => 'tmp_a2a_site_resp_asset_mgr', pError_location => 1090,
	      pkey_1 => assetMgr, pKey_2 => logonId, pKey_3 => data_source ) ;
		raise ;
	 END insertSiteRespAssetMgr ;
	
	 PROCEDURE doUpdate(part_no IN TMP_A2A_INV_INFO.part_no%TYPE,
	    spo_location IN TMP_A2A_INV_INFO.site_location%TYPE,
	    inv_qty IN TMP_A2A_INV_INFO.QTY_ON_HAND%TYPE,
	    action_code IN TMP_A2A_INV_INFO.action_code%TYPE) IS
	  BEGIN
	     UPDATE TMP_A2A_INV_INFO
	    SET 
	    qty_on_hand = doUpdate.inv_qty,
	    action_code = doUpdate.action_code,
	    last_update_dt = SYSDATE
	    WHERE part_no = doUpdate.part_no
	    AND site_location = doUpdate.spo_location ;
	
	  EXCEPTION WHEN OTHERS THEN
	    ErrorMsg( pSqlfunction => 'select', pTableName => 'tmp_a2a_inv_info', pError_location => 1100,
	      pkey_1 => part_no, pKey_2 => spo_location) ;
	    RAISE ;
	
	 END doUpdate ;
	
	 PROCEDURE insertInvInfo(part_no IN TMP_A2A_INV_INFO.part_no%TYPE,
	    spo_location IN TMP_A2A_INV_INFO.site_location%TYPE ,
	    qty_on_hand IN TMP_A2A_INV_INFO.QTY_ON_HAND%TYPE,
	    action_code IN TMP_A2A_INV_INFO.action_code%TYPE)  IS
		
		procedure insertRow is
		begin
			    INSERT INTO TMP_A2A_INV_INFO
			   (
			    part_no,
			    site_location,
			    qty_on_hand,
			    action_code,
			    last_update_dt
			   )
			   VALUES
			   (
			    insertInvInfo.part_no,
			    insertInvInfo.spo_location,
			    insertInvInfo.qty_on_hand,
			    insertInvInfo.action_code,
			    SYSDATE
			   );
	    EXCEPTION
	       WHEN standard.DUP_VAL_ON_INDEX THEN
	       	 doUpdate( part_no, spo_location, qty_on_hand, action_code) ;
	  	   WHEN OTHERS THEN
		     ErrorMsg( pSqlfunction => 'insert', pTableName => 'tmp_a2a_inv_info', pError_location => 1110,
		       pkey_1 => part_no, pKey_2 => spo_location) ;
		     RAISE ;
		end insertRow ;

	 BEGIN
	  if insertInvInfo.action_code = amd_defaults.INSERT_ACTION
	  or insertInvInfo.action_code = amd_defaults.UPDATE_ACTION then
	  
		  IF wasPartSent(insertInvInfo.part_no) -- does the part exist in amd_sent_to_a2a with an action_code <> DELETE_ACTION
		     AND spo_location IS NOT NULL THEN
			 
			 	 insertRow ;
				 
		  END IF ;
	  else
	  	  if isPartSent(insertInvInfo.part_no) then -- does the part exist in amd_sent_to_a2a with any action_code
		  
		  	 insertRow ;
			 
		  end if ;
	  end if ;
	
	
	 END insertInvInfo ;
	
	
	PROCEDURE insertRepairInvInfo(part_no IN TMP_A2A_REPAIR_INV_INFO.part_no%TYPE,
	    site_location IN TMP_A2A_REPAIR_INV_INFO.site_location%TYPE,
	    inv_qty IN TMP_A2A_REPAIR_INV_INFO.QTY_ON_HAND%TYPE,
	    action_code IN TMP_A2A_REPAIR_INV_INFO.action_code%TYPE)  IS
		
		procedure insertRow is
		begin
			    INSERT INTO TMP_A2A_REPAIR_INV_INFO
			   (
			    part_no,
			    site_location,
			    qty_on_hand,
			    action_code,
			    last_update_dt
			   )
			   VALUES
			   (
			    insertRepairInvInfo.part_no,
			    insertRepairInvInfo.site_location,
			    insertRepairInvInfo.inv_qty,
			    insertRepairInvInfo.action_code,
			    SYSDATE
			   );
		EXCEPTION
		     WHEN standard.DUP_VAL_ON_INDEX THEN
		    doUpdate( part_no, site_location, inv_qty, action_code) ;
		  WHEN OTHERS THEN
		     ErrorMsg( pSqlfunction => 'insert', pTableName => 'tmp_a2a_repair_inv_info', pError_location => 1120,
		       pkey_1 => part_no, pKey_2 => site_location) ;
		     RAISE ;
		end insertRow ;
	
	 BEGIN
		if action_code = amd_defaults.INSERT_ACTION 
		or action_code = amd_defaults.UPDATE_ACTION then
		
			IF wasPartSent(insertRepairInvInfo.part_no) -- must be in amd_sent_to_a2a with action_code <> D
			   AND site_location IS NOT NULL THEN
			   			insertRow ;
			END IF ;
			
		else
		  if isPartSent(insertRepairInvInfo.part_no)
		  	 and site_location is not null then -- must be in amd_sent_to_a2a - ignores action_code
			 insertRow ;
		  end if ;
		end if ;	
	
	 END insertRepairInvInfo ;
	 
	
	 FUNCTION getNsiSid(part_no IN VARCHAR2) RETURN VARCHAR2 IS
	    nsisid NUMBER ;
	    result NUMBER ;
	 BEGIN
	   SELECT nsi.nsi_sid INTO nsisid
	   FROM AMD_NATIONAL_STOCK_ITEMS nsi,
	   AMD_SPARE_PARTS asp
	   WHERE asp.part_no = getnsisid.part_no
	   AND asp.nsn = nsi.nsn ;
	
	   RETURN nsisid ;
	
	 EXCEPTION WHEN OTHERS THEN
	    errormsg( psqlfunction => 'select', ptablename => 'amd_national_stock_items', pError_location => 1130,
	      pkey_1 => part_no) ;
	    RAISE ;
	
	 END getNsiSid ;
	
	    FUNCTION getTimeToRepair(loc_sid  IN AMD_IN_REPAIR.loc_sid%TYPE,
	             part_no IN VARCHAR2)
	
	    RETURN AMD_PART_LOCS.time_to_repair%TYPE IS
	
	    result NUMBER ;
	
	    time_to_repair AMD_PART_LOCS.time_to_repair%TYPE ;
	    time_to_repair_defaulted AMD_PART_LOCS.time_to_repair_defaulted%TYPE ;
	
	    no_time_to_repair    EXCEPTION ;
	
	    nsisid NUMBER := getnsisid(part_no) ;
	
	 BEGIN
	  <<execSelectTimeToRepair>>
	  BEGIN
	   SELECT time_to_repair, time_to_repair_defaulted
	   INTO time_to_repair, time_to_repair_defaulted
	   FROM AMD_PART_LOCS
	   WHERE nsi_sid = nsisid
	   AND loc_sid = gettimetorepair.loc_sid ;
	
	   IF time_to_repair IS NOT NULL THEN
	    NULL ; -- do nothing use time_to_repair
	   ELSIF time_to_repair_defaulted IS NOT NULL THEN
	       time_to_repair := time_to_repair_defaulted ;
	   ELSE
	    time_to_repair := Amd_Defaults.time_to_repair_onbase ;
	   END IF ;
	
	  EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	     time_to_repair := Amd_Defaults.time_to_repair_onbase ;
	   WHEN OTHERS THEN
	      errormsg( psqlfunction => 'select', ptablename => 'amd_part_locs', pError_location => 1140,
	        pkey_1 => part_no, pkey_2 => loc_sid) ;
	    RAISE ;
	
	  END execSelectTimeToRepair ;
	
	  RETURN time_to_repair ;
	
	 END getTimeToRepair ;
	
	 PROCEDURE insertRepairInfo(part_no IN TMP_A2A_REPAIR_INFO.part_no%TYPE,
	    loc_sid IN NUMBER,
	    doc_no IN TMP_A2A_REPAIR_INFO.doc_no%TYPE, 
	    repair_date IN TMP_A2A_REPAIR_INFO.repair_date%TYPE,
	    status IN TMP_A2A_REPAIR_INFO.status%TYPE,
	    quantity IN TMP_A2A_REPAIR_INFO.quantity%TYPE /* repair_qty */,
		expected_completion_date  IN TMP_A2A_REPAIR_INFO.expected_completion_date%TYPE,
	    action_code IN TMP_A2A_REPAIR_INFO.action_code%TYPE)  IS
	
	   site_location TMP_A2A_REPAIR_INFO.site_location%TYPE  := Amd_Utils.getSpoLocation(loc_sid) ;
	
	   /* Not needed in tmp_a2a_repair_info */
	 -- expectedCompletionDate TMP_A2A_REPAIR_INFO.expected_completion_date%TYPE
	       --  := repair_date + gettimetorepair(loc_sid,part_no) ;
	
	  PROCEDURE doUpdate IS
	  BEGIN
	    UPDATE TMP_A2A_REPAIR_INFO
	    SET doc_no = insertRepairInfo.doc_no,
	    status = insertRepairInfo.status,
	    quantity = insertRepairInfo.quantity,
		expected_completion_date = insertRepairInfo.expected_completion_date,
	    action_code = insertRepairInfo.action_code,
	    last_update_dt = SYSDATE
	    WHERE part_no = insertRepairInfo.part_no
		AND doc_no = insertRepairInfo.doc_no 
		AND site_location = insertRepairInfo.site_location
	    AND repair_date = insertRepairInfo.repair_date ;
	
	  EXCEPTION WHEN OTHERS THEN
	     errormsg( psqlfunction => 'update', ptablename => 'tmp_a2a_repair_info', pError_location => 1150,
	       pkey_1 => part_no, pkey_2 => loc_sid, pkey_3 => doc_no, pkey_4 => TO_CHAR(repair_date,'MM/DD/YYYY'),pKeywordValuePairs => 'status=' || status || '  qty=' || quantity || ' action=' || action_code) ;
	     RAISE ;
	  END doUpdate ;
	  
	  procedure insertRow is
	  begin
		    INSERT INTO TMP_A2A_REPAIR_INFO
		   (
		    part_no,
		    site_location,
		    doc_no,
		    repair_date,
		    status,
		    receipt_date,
		    expected_completion_date,
		    quantity,
		    action_code,
		    last_update_dt
		   )
		   VALUES
		   (
		    part_no,
		    site_location,
		    doc_no, 
		    repair_date,
		    insertRepairInfo.status, -- OPEN
		    NULL,
		    expected_completion_date,
		    insertRepairInfo.quantity, -- repair_qty
		    insertRepairInfo.action_code,
		    SYSDATE
		   );
	  EXCEPTION
		   WHEN standard.DUP_VAL_ON_INDEX THEN
		       doUpdate ;
		   WHEN OTHERS THEN
		     errormsg( psqlfunction => 'insert', ptablename => 'tmp_a2a_repair_info', pError_location => 1160,
		 pkey_1 => part_no, pkey_2 => loc_sid, pkey_3 => doc_no, pkey_4 => TO_CHAR(repair_date,'MM/DD/YYYY'),pKeywordValuePairs => 'status=' || status || '  qty=' || quantity || ' action=' || action_code) ;
		     RAISE ;
	  end insertRow ;
	
	  BEGIN
	   if insertRepairInfo.action_code = amd_defaults.INSERT_ACTION 
	   or insertRepairInfo.action_code = amd_defaults.UPDATE_ACTION then
	   
		   -- added isPartValid test DSE 11/30/05
		   IF isPartValid(insertRepairInfo.part_no) 
		      AND wasPartSent(insertRepairInfo.part_no) -- must exist in amd_sent_to_a2a with action_code <> DELETE_ACTION
			  AND doc_no NOT LIKE 'R%'  
			  AND doc_no NOT LIKE 'II%'
			  AND site_location IS NOT NULL 
		   THEN
		   	   insertRow ;
		   END IF ;
	 else
	 	 if isPartSent(insertRepairInfo.part_no) 
		 	and site_location is not null then -- i.e. it exists in amd_sent_to_a2a - ignore action_code
		 	insertRow ;
		 end if ;
	 end if ;
	 END insertRepairInfo ;
	
	 FUNCTION getDueDate(part_no in AMD_ON_ORDER.PART_NO%TYPE, order_date in AMD_ON_ORDER.ORDER_DATE%TYPE)  RETURN DATE IS
	 
	 		  order_lead_time AMD_SPARE_PARTS.ORDER_LEAD_TIME%TYPE ;
			  order_lead_time_defaulted AMD_SPARE_PARTS.ORDER_LEAD_TIME_DEFAULTED%TYPE ;
			  order_lead_time_cleaned AMD_NATIONAL_STOCK_ITEMS.order_lead_time_cleaned%TYPE ;
	 BEGIN
	      <<getOrderLeadTime>>
	 	  BEGIN
	 	  	   SELECT order_lead_time, order_lead_time_defaulted INTO order_lead_time, order_lead_time_defaulted FROM AMD_SPARE_PARTS WHERE part_no = getDueDate.part_no ;
		  EXCEPTION WHEN standard.NO_DATA_FOUND THEN
		  	   order_lead_time := NULL ;
		  END getOrderLeadTime ;
		  
		  <<getOrderLeadTimeCleaned>>
		  BEGIN
		  	   SELECT order_lead_time_cleaned INTO order_lead_time_cleaned FROM AMD_NATIONAL_STOCK_ITEMS items, AMD_SPARE_PARTS parts WHERE parts.part_no = getDueDate.part_no AND parts.nsn = items.nsn ;
		  EXCEPTION WHEN standard.NO_DATA_FOUND THEN
		  	   order_lead_time_cleaned := NULL ;	   
		  END getOrderLeadTimeCleaned ;
		  
		  RETURN getDueDate.order_date + Amd_Preferred_Pkg.GetPreferredValue(order_lead_time_cleaned, order_lead_time, NVL(order_lead_time_defaulted,1)) ;
	  
	 END getDueDate ;
	
	 FUNCTION includeOrder(gold_order_number IN AMD_ON_ORDER.gold_order_number%TYPE, 
	 		  			  order_date IN AMD_ON_ORDER.order_date%TYPE,
						  part_no in amd_on_order.part_no%type) RETURN BOOLEAN IS
	 
	 	  ON_ORDER_DATES_FILTER_NAME CONSTANT VARCHAR2(14) := 'on_order_dates' ;
	 	  created_order_date DATE ;
		  sched_receipt_date_from DATE ;
		  sched_receipt_date_to DATE ;
		  numberOfCalanderDays NUMBER ;
		  sched_receipt_date AMD_ON_ORDER.SCHED_RECEIPT_DATE%TYPE ;
		  lineOfCode number := 0 ;
		  
		  FUNCTION getSchedReceiptDate  RETURN DATE IS
		  		   sched_receipt_date AMD_ON_ORDER.SCHED_RECEIPT_DATE%TYPE ;
		  BEGIN
		  	   SELECT sched_receipt_date INTO sched_receipt_date
			   FROM AMD_ON_ORDER
			   WHERE AMD_ON_ORDER.GOLD_ORDER_NUMBER =  includeOrder.gold_order_number
			   and amd_on_order.ORDER_DATE = includeOrder.order_date
               and action_code <> amd_defaults.DELETE_ACTION
               and line = (select max(line) 
                           from amd_on_order 
                           where gold_order_number = includeOrder.gold_order_number
                           and order_date = includeOrder.order_date
                           and action_code <> amd_defaults.DELETE_ACTION) ;
			   RETURN sched_receipt_date ;
		  EXCEPTION 
		  		WHEN standard.NO_DATA_FOUND THEN
		  			 return null ;
                when others then
            	     errormsg( psqlfunction => 'select', ptablename => 'amd_on_order', pError_location => 1169,
            	 	 		   pkey_1 => gold_order_number, pkey_2 => to_char(order_date,'MM/DD/YYYY') ) ;
                     raise ; 
		  END getSchedReceiptDate ;
		  
		  --function calculate
	
		  PROCEDURE recordReason (theReason IN VARCHAR2) IS
		  BEGIN	  
			   writeMsg(pTableName => 'tmp_a2a_order_info_line',pError_location => 1170,
			   		pKey1 => 'gold_order_number=' || gold_order_number,
					pKey2 => 'order_date=' || TO_CHAR(order_date,'MM/DD/YYYY HH:MI:SS AM'),
					pKey3 => 'reason=' || theReason) ;
		  END recordReason ;
		  
		  function iif(condition in boolean, truePart in varchar2, falsePart in varchar2) return varchar2 is
		  begin
		  	   if condition then
			   	  return truePart ;
			   else
			   	  return falsePart ;
			   end if ;
		  end iif ;
		  
	 BEGIN
	 	  --IF SUBSTR(gold_order_number,1,2) IN ('AM', 'BA', 'BN', 'BR', 'LB', 'RS', 'SE') THEN
		  --	 RETURN TRUE ; -- include
		  --END IF ;
		  lineOfCode := 1 ;
		  created_order_date := Amd_On_Order_Date_Filters_Pkg.getOrderCreateDate(ON_ORDER_DATES_FILTER_NAME,SUBSTR(gold_order_number,1,2)) ;
		  sched_receipt_date_from := Amd_On_Order_Date_Filters_Pkg.getScheduledReceiptDateFrom(ON_ORDER_DATES_FILTER_NAME,SUBSTR(gold_order_number,1,2)) ;
		  sched_receipt_date_to := Amd_On_Order_Date_Filters_Pkg.getScheduledReceiptDateTo(ON_ORDER_DATES_FILTER_NAME,SUBSTR(gold_order_number,1,2)) ;
		  Amd_On_Order_Date_Filters_Pkg.getScheduledReceiptDateCalDays(ON_ORDER_DATES_FILTER_NAME,SUBSTR(gold_order_number,1,2), numberOfCalanderDays) ;
		  lineOfCode := 2 ;
		  IF created_order_date IS NOT NULL THEN
		  	 IF order_date >= created_order_date THEN
			 	recordReason('order_date >= created_order_date') ;
			 	RETURN FALSE ; -- exclude
			 END IF ;
		  END IF ;
		  lineOfCode := 3 ;
		  IF numberOfCalanderDays IS NOT NULL THEN
		  	 sched_receipt_date := getSchedReceiptDate ;
		  	 IF sched_receipt_date IS NULL then
			 	sched_receipt_date := getDueDate(part_no => part_no, order_date => order_date) ;
			 end if ;
		 	 IF sched_receipt_date > SYSDATE + numberOfCalanderDays THEN
		 	   recordReason('sched_receipt_date > ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') || ' + ' || TO_CHAR(numberOfCalanderDays) ) ; 
			   RETURN FALSE ; -- exclude
			 END IF ;
		 END IF ;
		  lineOfCode := 4 ;
		 IF sched_receipt_date_from IS NOT NULL THEN
		 	IF sched_receipt_date_to IS NOT NULL THEN
			   IF sched_receipt_date_from <= sched_receipt_date_to THEN
			   	  sched_receipt_date := getSchedReceiptDate ;
				  if sched_receipt_date is null then
				  	 sched_receipt_date := getDueDate(part_no => part_no, order_date => order_date) ;
				  end if ;
			   	  IF sched_receipt_date >= sched_receipt_date_from AND sched_receipt_date <= sched_receipt_date_to THEN
				  	 RETURN TRUE ; -- include
				  ELSE
			 	     recordReason('sched_receipt_date NOT BETWEEN sched_receipt_date_from AND sched_receipt_date_to') ; 
				  	 RETURN FALSE ; -- exclude
				  END IF ;
			   END IF ;
			END IF ;
	     END IF ;
		 
		 RETURN TRUE ; -- include
	 exception when others then
	 	 dbms_output.put_line('includeOrder: lineOfCode=' || lineOfCode) ;
	     errormsg( psqlfunction => 'select', ptablename => 'amd_on_order', pError_location => 1180,
	 	 		   pkey_1 => gold_order_number, pkey_2 => to_char(order_date,'MM/DD/YYYY'), 
				   pkey_3 => part_no,
				   pKey_4 => iif(sched_receipt_date is null,'NULL',to_char(sched_receipt_date,'MM/DD/YYYY')) || 'lineOfCode=' || lineOfCode, 
				   pKeywordValuePairs => 'numberOfCalanderDays=' || iif(numberOfCalanderDays is NULL,'NULL',to_char(numberOfCalanderDays)) ) ; /* 
				   		|| ' sched_receipt_date_from=' || iif(sched_receipt_date_from is NULL,'NULL',to_char(sched_receipt_date_from,'MM/DD/YYYY')) 
						|| ' sched_receipt_date_to=' || iif(sched_receipt_date_to is NULL,'NULL',to_char(sched_receipt_date_to,'MM/DD/YYYY'))
						|| ' created_order_date=' || iif(created_order_date is NULL,'NULL',to_char(created_order_date,'MM/DD/YYYY')) ) ; */
	     RAISE ;
	 
	 END includeOrder ;
	 
	
	
	
	 PROCEDURE insertTmpA2AOrderInfo(gold_order_number IN AMD_ON_ORDER.GOLD_ORDER_NUMBER%TYPE,
	     loc_sid IN AMD_ON_ORDER.LOC_SID%TYPE,
	     order_date IN AMD_ON_ORDER.ORDER_DATE%TYPE,
	     part_no IN AMD_ON_ORDER.PART_NO%TYPE,
	     order_qty IN AMD_ON_ORDER.ORDER_QTY%TYPE,
		 sched_receipt_date IN AMD_ON_ORDER.SCHED_RECEIPT_DATE%TYPE,
	     action_code IN TMP_A2A_ORDER_INFO.action_code%TYPE) IS
	
	   	 site_location TMP_A2A_ORDER_INFO_LINE.SITE_LOCATION%TYPE := Amd_Utils.getSpoLocation(loc_sid) ;
		 lineNumber NUMBER := 0 ;
		 current_created_date TMP_A2A_ORDER_INFO.CREATED_DATE%TYPE := NULL ;
		 lineOfCode number := 0 ;
		 
		 cage_code TMP_A2A_ORDER_INFO.cage_code%TYPE := Amd_Utils.getCageCode(part_no) ;
	
		PROCEDURE insertTmpA2AOrderInfoLine(action_code in tmp_a2a_order_info_line.ACTION_CODE%type) IS
		
			 due_date TMP_A2A_ORDER_INFO_LINE.DUE_DATE%TYPE ;
			 
			 
			 PROCEDURE doUpdate IS
			 BEGIN
			 		UPDATE TMP_A2A_ORDER_INFO_LINE
					SET 
					    loc_sid = insertTmpA2AOrderInfo.loc_sid,
					    site_location = insertTmpA2AOrderInfo.site_location,
					    qty_ordered = insertTmpA2AOrderInfo.order_qty,
					    action_code = insertTmpA2AOrderInfoLine.action_code,
					    last_update_dt = SYSDATE,
						due_date = insertTmpA2AOrderInfoLine.due_date,
						line = lineNumber
					WHERE order_no = insertTmpA2AOrderInfo.gold_order_number
					AND part_no = insertTmpA2AOrderInfo.part_no
					AND created_date = insertTmpA2AOrderInfo.order_date ;
			  
			 EXCEPTION WHEN OTHERS THEN
			     errormsg( psqlfunction => 'update', ptablename => 'tmp_a2a_order_info_line', pError_location => 1190,
			       pkey_1 => gold_order_number) ;
			     RAISE ;
			 END doUpdate ;
		 
			 FUNCTION getNextLineNumber RETURN NUMBER IS
			 		  result NUMBER := 0 ;
			 BEGIN
            	  select line into result from amd_on_order 
            	  where gold_order_number = insertTmpA2AOrderInfo.gold_order_number
                  and order_date = insertTmpA2AOrderInfo.order_date
                  and line = (select max(line) from amd_on_order 
                              where gold_order_number = insertTmpA2AOrderInfo.gold_order_number
                              and order_date = insertTmpA2AOrderInfo.order_date) ;
				  return result ;
				  
			 EXCEPTION 
					   WHEN OTHERS THEN
					     errormsg( psqlfunction => 'select', ptablename => 'tmp_a2a_order_info_line', pError_location => 1200,
					       pkey_1 => gold_order_number, 
                           pKey_2 => part_no, 
                           pKey_3 => TO_CHAR(order_date,'MM/DD/YYYY HH:MI:SS AM'), pKey_4 => 'result=' || nvl(result,'NULL'),
                           pKeywordValuePairs => 'loc_sid=' || to_char(loc_sid) || ' orderQty=' || order_qty || ' sched' || to_char(sched_receipt_date,'MM/DD/YYYY HH:MI:SS AM') ) ;
					     RAISE ;			   
			 END getNextLineNumber ;
		 
		BEGIN
              writeMsg(pTableName => 'tmp_a2a_order_info_line',pError_location => 1201,
                pKey1 => 'gold_order_number=' || gold_order_number,
                pKey2 => 'part_no= ' ||  part_no,
                pKey3 => 'loc_sid= ' || loc_sid,
                pKey4 => 'order_date=' || TO_CHAR(order_date,'MM/DD/YYYY HH:MI:SS AM'),
                pData => 'ordQty=' || order_qty || ' sched=' || to_char(sched_receipt_date, 'MM/DD/YYYY HH:MI:SS AM') || ' ac=' || action_code) ;
              commit ;
			  IF sched_receipt_date IS NULL THEN
			   	 due_date := getDueDate(part_no => insertTmpA2AOrderInfo.part_no, order_date => insertTmpA2AOrderInfo.order_date) ;
			  ELSE
			  	 due_date := sched_receipt_date ;
			  END IF ;
			  
			  lineNumber := getNextLineNumber ;
			  
			  INSERT INTO TMP_A2A_ORDER_INFO_LINE
			 (
			  order_no,
			  part_no,
			  loc_sid,
			  site_location,
			  created_date,
			  status,
			  line,
			  qty_ordered,
			  qty_received,
			  action_code,
			  last_update_dt,
			  due_date
			 )
			 VALUES
			 (
			  gold_order_number,
			  part_no,
			  loc_sid,
			  site_location,
			  order_date,
			  'O',
			  lineNumber,
			  order_qty,
			  0,
			  insertTmpA2AOrderInfoLine.action_code,
			  SYSDATE,
			  due_date
			 );
			 COMMIT ;
		EXCEPTION
			  WHEN standard.DUP_VAL_ON_INDEX THEN
			 doUpdate ;
			 
			  WHEN OTHERS THEN
			     errormsg( psqlfunction => 'insert', ptablename => 'tmp_a2a_order_info_line', pError_location => 1210,
			       pkey_1 => gold_order_number, pKey_2 => part_no, pKey_3 => TO_CHAR(order_date,'MM/DD/YYYY HH:MI:SS AM'), pKey_4 => 'result=' || nvl(lineNumber,'NULL'),
                          pKeywordValuePairs => 'loc_sid=' || to_char(loc_sid) || ' orderQty=' || order_qty || ' sched' || to_char(sched_receipt_date,'MM/DD/YYYY HH:MI:SS AM') ) ; 
			     RAISE ;
		END insertTmpA2aOrderInfoLine ;
		
		PROCEDURE doUpdate(action_code in tmp_a2a_order_info.action_code%type) IS
		 BEGIN
		   UPDATE TMP_A2A_ORDER_INFO
		   SET
		   cage_code = insertTmpA2AOrderInfo.cage_code, 
		   loc_sid = insertTmpA2AOrderInfo.loc_sid,
		   site_location = insertTmpA2AOrderInfo.site_location,
		   created_date = insertTmpA2AOrderInfo.order_date,
		   status = 'O',
		   action_code = doUpdate.action_code,
		   last_update_dt = SYSDATE
		   WHERE order_no = insertTmpA2AOrderInfo.gold_order_number 
		AND part_no = insertTmpA2AOrderInfo.part_no ;
		 EXCEPTION WHEN OTHERS THEN
		    errormsg( psqlfunction => 'update', ptablename => 'tmp_a2a_order_info', pError_location => 1220,
		      pkey_1 => gold_order_number) ;
		    RAISE ;
		 END doUpdate ;
		 
		 PROCEDURE doInsert(action_code in tmp_a2a_order_info.action_code%type) IS
		 BEGIN
			    INSERT INTO TMP_A2A_ORDER_INFO
			   (
			    order_no,
			    part_no,
				cage_code,
			    loc_sid,
			    site_location,
			    created_date,
			    status,
			    action_code,
			    last_update_dt
			   )
			   VALUES
			   (
			    gold_order_number,
			    part_no,
				insertTmpA2AOrderInfo.cage_code,
			    loc_sid,
			    site_location,
			    order_date,
			    'O',
			    doInsert.action_code,
			    SYSDATE
			   );
			
			EXCEPTION
			  WHEN standard.DUP_VAL_ON_INDEX THEN
			    doUpdate(doInsert.action_code) ; -- update with the most recent order date
			  WHEN OTHERS THEN 
			    errormsg( psqlfunction => 'insert', ptablename => 'tmp_a2a_order_info', pError_location => 1230,
			      pkey_1 => gold_order_number) ;
			    RAISE ;
			  
		 END doInsert ;
		 
	
	 BEGIN
		   if insertTmpA2AOrderInfo.action_code = amd_defaults.INSERT_ACTION 
		   or insertTmpA2AOrderInfo.action_code = amd_defaults.UPDATE_ACTION then
				lineOfCode := 1 ;
		   
			   IF wasPartSent(insertTmpA2AOrderInfo.part_no) 
			   	  AND site_location IS NOT NULL THEN
					lineOfCode := 2 ;
					 
					IF includeOrder(gold_order_number => gold_order_number,order_date => order_date,
									part_no => insertTmpA2AOrderInfo.part_no) THEN
						
						lineOfCode := 3 ;
						includeCnt := includeCnt + 1 ;
						doInsert(insertTmpA2AOrderInfo.action_code) ; 
			 			insertTmpA2AOrderInfoLine(insertTmpA2AOrderInfo.action_code) ;
						
					ELSE
					    lineOfCode := 4 ;
						excludeCnt := excludeCnt + 1 ;
						doInsert(amd_defaults.DELETE_ACTION) ; -- always set the action code to delete for execluded tmp_a2a_Order_Info
						insertTmpA2AOrderInfoLine(amd_defaults.DELETE_ACTION) ;
					    writeMsg(pTableName => 'tmp_a2a_order_info_line',pError_location => 1240,
					   		pKey1 => 'gold_order_number=' || gold_order_number,
							pKey2 => 'part_no= ' || insertTmpA2AOrderInfo.part_no,
							pKey3 => 'site_location= ' || insertTmpA2AOrderInfo.site_location,
							pKey4 => 'order_date=' || TO_CHAR(insertTmpA2AOrderInfo.order_date,'MM/DD/YYYY HH:MI:SS AM'),
							pData => 'excluded') ;
					END IF ;
					
			  END IF ;
		else
			lineOfCode := 4 ;
			if isPartSent(insertTmpA2AOrderInfo.part_no) 
			   and site_location is not null then -- the part must exist in amd_sent_to_a2a with any action_code
				doInsert(insertTmpA2AOrderInfo.action_code) ;
				insertTmpA2AOrderInfoLine(insertTmpA2AOrderInfo.action_code) ;
			end if ;
		end if ;
		 
	 EXCEPTION
		   WHEN OTHERS THEN
			  dbms_output.put_line('insertTmpA2AOrderInfo: lineNumber=' || nvl(lineNumber,9999) || ' lineOfCode=' || nvl(lineOfCode,9999) ) ; 
		      errormsg( psqlfunction => 'insert', ptablename => 'tmp_a2a_order_info', pError_location => 1250,
		        pkey_1 => 'gold_order_number=' || to_char(Nvl(gold_order_number,0)),
				pKey_2 => 'part_no=' || insertTmpA2AOrderInfo.part_no,
				pKey_3 => 'site_location=' || insertTmpA2AOrderInfo.site_location,
				pKey_4 => 'order_date=' || TO_CHAR(insertTmpA2AOrderInfo.order_date,'MM/DD/YYYY HH:MI:SS AM'),
				pKeywordValuePairs => 'lineNumber=' || TO_CHAR(NVL(lineNumber,0)) || ' lineOfCode=' || to_char(lineOfCode) || ' action_code=' || action_code ) ;
		      RAISE ;
	 END insertTmpA2AOrderInfo ;
	
	
	 PROCEDURE insertTmpA2AInTransits(part_no IN AMD_IN_TRANSITS_SUM.part_no%TYPE,
	   site_location     IN AMD_IN_TRANSITS_SUM.site_location%TYPE,
	   quantity      IN AMD_IN_TRANSITS_SUM.quantity%TYPE,
	   serviceable_flag  IN AMD_IN_TRANSITS_SUM.serviceable_flag%TYPE,
	   action_code   IN TMP_A2A_IN_TRANSITS.action_code%TYPE) IS
	
	 -- site_location TMP_A2A_IN_TRANSITS.site_location%TYPE := Amd_Utils.getSpoLocation(to_loc_sid) ;
	    -- added doUpdate DSE 11/30/05
	 	PROCEDURE doUpdate IS
		BEGIN
			 UPDATE TMP_A2A_IN_TRANSITS
			 SET
			     qty = insertTmpA2AInTransits.quantity,
			     action_code = insertTmpA2AInTransits.action_code,
			     last_update_dt = SYSDATE
			WHERE part_no = insertTmpA2AInTransits.part_no
			AND site_location = insertTmpA2AInTransits.site_location 
			AND TYPE = insertTmpA2AInTransits.serviceable_flag ;
			
		EXCEPTION WHEN OTHERS THEN
	      errormsg( psqlfunction => 'update', ptablename => 'tmp_a2a_in_transits', pError_location => 1260,
	        pkey_1 => insertTmpA2AInTransits.part_no, pKey_2 => insertTmpA2AInTransits.site_location,
			pkey_3 => insertTmpA2AInTransits.serviceable_flag) ;
	      RAISE ;	
		END doUpdate ;
		
		procedure insertRow is
		begin
		    INSERT INTO TMP_A2A_IN_TRANSITS
		    (
		     part_no,
		     site_location,
		     qty,
		     TYPE,
		     action_code,
		     last_update_dt
		    )
		    VALUES
		    (
		     insertTmpA2AInTransits.part_no,
		     insertTmpA2AInTransits.site_location,
		     insertTmpA2AInTransits.quantity,
		     insertTmpA2AInTransits.serviceable_flag,
		     insertTmpA2AInTransits.action_code,
		     SYSDATE
		    ) ;
	   -- added exception handlers DSE 11/30/05
	    EXCEPTION
	 		  WHEN standard.DUP_VAL_ON_INDEX THEN
			  	   doUpdate ;
			  WHEN OTHERS THEN 
			      errormsg( psqlfunction => 'insert', ptablename => 'tmp_a2a_in_transits', pError_location => 1270,
			        pkey_1 => insertTmpA2AInTransits.part_no, pKey_2 => insertTmpA2AInTransits.site_location) ;
			      RAISE ;
		end insertRow ;
	
	 BEGIN
	  if action_code = amd_defaults.INSERT_ACTION 
	  or action_code = amd_defaults.UPDATE_ACTION then
	  
		  IF quantity > 0 
		  AND wasPartSent(insertTmpA2AInTransits.part_no)
		  AND isPartValid(insertTmpA2AInTransits.part_no) -- added isPartValid DSE 11/30/05 
		  AND site_location IS NOT NULL  THEN
		  
		  	  insertRow ;
		  
		  END IF ;
	  else
	   	  if isPartSent(part_no) 
		  	 and site_location is not null then
	  	  	 insertRow ;
		  end if ;		  
	  end if ;
			  	   
	 END insertTmpA2AInTransits ;
	
	
	 PROCEDURE spoUser(bems_id IN TMP_A2A_SPO_USERS.BEMS_ID%TYPE,
	  action_code IN TMP_A2A_SPO_USERS.ACTION_CODE%TYPE) IS
	
	  spoUserUpdateError EXCEPTION ;
	
	
	
	 BEGIN
	
	
	  <<insertA2A>>
	  BEGIN
	
	   INSERT INTO TMP_A2A_SPO_USERS
	   (BEMS_ID,  ACTION_CODE, LAST_UPDATE_DT)
	   VALUES (spoUser.bems_id, spoUser.action_code, SYSDATE) ;
	
	  EXCEPTION
	   WHEN standard.DUP_VAL_ON_INDEX THEN
	     NULL ; -- ignore
	   WHEN OTHERS THEN
	    errormsg( psqlfunction => 'insert', ptablename => 'tmp_a2a_spo_users', pError_location => 1280,
	        pkey_1 => bems_id) ;
	    RAISE ;
	  END insertA2A ;
	
	
	 END spoUser ;
	
	 PROCEDURE insertTmpA2ASpoUsers(bems_id IN TMP_A2A_SPO_USERS.bems_id%TYPE,
	       stable_email     IN TMP_A2A_SPO_USERS.EMAIL%TYPE,
	       last_name      IN VARCHAR2,
	       first_name  IN VARCHAR2,
	       action_code   IN TMP_A2A_IN_TRANSITS.action_code%TYPE) IS
		   
		   PROCEDURE doUpdate IS
		   			 theEmail TMP_A2A_SPO_USERS.email%TYPE ;
					 theName TMP_A2A_SPO_USERS.name%TYPE ;
					 debugIt BOOLEAN := A2a_Pkg.mDebug ; -- save current debug settings
		   BEGIN
		   		SELECT email, name INTO theEmail, theName FROM TMP_A2A_SPO_USERS WHERE bems_id = insertTmpA2ASpoUsers.bems_id ;
				A2a_Pkg.mDebug := TRUE ; -- always record the before and after
				debugMsg(msg => 'before update bems_id = ' || bems_id || 'email= ' || theEmail || 'last_name=' || theName, lineNo => 180) ;
				
		   		UPDATE TMP_A2A_SPO_USERS
				SET email = SUBSTR(insertTmpA2ASpoUsers.stable_email,1,32),
				name = SUBSTR(last_name || ', ' || first_name,1,32),
				action_code = insertTmpA2ASpoUsers.action_code,
				last_update_dt = SYSDATE
				WHERE bems_id = insertTmpA2ASpoUsers.bems_id ;
				
				debugMsg(msg => 'after update bems_id = ' || bems_id || 'email= ' || SUBSTR(stable_email,1,32) || 'last_name=' || SUBSTR(last_name || ', ' || first_name,1,32), lineNo => 190) ;
				A2a_Pkg.mDebug := debugIt ; -- restore
				
		   EXCEPTION WHEN OTHERS THEN
			    errormsg( psqlfunction => 'update', ptablename => 'tmp_a2a_spo_users', pError_location => 1290,
			        pkey_1 => bems_id) ;
			    RAISE ;
		   END doUpdate ;
		   
	 BEGIN
	 	  INSERT INTO TMP_A2A_SPO_USERS
		  (bems_id, email, NAME, action_code, last_update_dt)
		  VALUES(bems_id, SUBSTR(stable_email,1,32), SUBSTR(last_name || ', ' || first_name,1,32), action_code, SYSDATE) ;
	 EXCEPTION
	 		  WHEN standard.DUP_VAL_ON_INDEX THEN
			  	   doUpdate ;
			  WHEN OTHERS THEN
				    errormsg( psqlfunction => 'insert', ptablename => 'tmp_a2a_spo_users', pError_location => 1300,
				        pkey_1 => bems_id) ;
				    RAISE ;
			  
	 END insertTmpA2ASpoUsers ;
	
	
	  FUNCTION getAssignedPlannerCode(part_no IN TMP_A2A_PART_INFO.part_no%TYPE,
	 		  planner_code IN AMD_PLANNERS.planner_code%TYPE) RETURN AMD_PLANNERS.planner_code%TYPE  IS
			  
			  plannerCode AMD_PLANNERS.planner_code%TYPE ;
			  
	  BEGIN
		IF isPlannerCodeAssigned2UserId(planner_code) THEN
			  plannerCode := planner_code ;
		ELSE
		   IF isNsl(part_no) THEN
			  	 plannerCode := Amd_Defaults.NSL_PLANNER_CODE ;
		  ELSE
			 plannerCode := Amd_Defaults.NSN_PLANNER_CODE ;
		   END IF ;
		   debugMsg('For part ' || part_no || ' planner_code ' || planner_code || ' is not assigned to a users.  Using default of ' || plannerCode, 200) ; 
		END IF ;
		
		RETURN plannerCode ;
		
	  END getAssignedPlannerCode ;
	
	  FUNCTION wasPartSentYorN(partNo IN AMD_SPARE_PARTS.part_no%TYPE) RETURN VARCHAR2 IS 
	  BEGIN
	  	   IF wasPartSent(partNo) THEN
		   	 RETURN 'Y' ;
		   ELSE
		     RETURN 'N' ;
		   END IF ;
	  END wasPartSentYorN ;
	  
	  FUNCTION isPartValidYorN(partNo IN AMD_SPARE_PARTS.part_no%TYPE, showReason in varchar2 := 'N') RETURN VARCHAR2 IS
	  		   showReasonBool boolean := false ;
	  BEGIN
	  	   if showReason <> 'N' then
		  	   if upper(substr(showReason,1,1)) = 'Y' then
			   	  showReasonBool := true ;
			   end if ;
		   end if ;
	  	   IF isPartValid(partNo, showReason => showReasonBool) THEN
		       RETURN 'Y' ;
		   ELSE
		       RETURN 'N' ;
		   END IF ;
	  END isPartValidYorN ;
	  
	  FUNCTION isPlannerCodeAssign2UserIdYorN(plannerCode IN VARCHAR2) RETURN VARCHAR2 IS
	  BEGIN
	  	   IF isPlannerCodeAssigned2UserId(plannerCode) THEN
		     RETURN 'Y' ;
		   ELSE
		     RETURN 'N' ;
		   END IF ;
	  END isPlannerCodeAssign2UserIdYorN ;
	  
	  PROCEDURE deleteInvalidParts (testOnly IN BOOLEAN := FALSE) IS
		  CURSOR sentParts IS
		  SELECT part_no FROM AMD_SENT_TO_A2A
		  WHERE action_code != Amd_Defaults.DELETE_ACTION
		  AND spo_prime_part_no IS NOT NULL ;
		  
		  nomenclature AMD_SPARE_PARTS.NOMENCLATURE%TYPE ;
		  rc NUMBER ;
		  cnt NUMBER := 0 ;
	  			
	  BEGIN
	  	   writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 1310,
			pKey1 => 'deleteInvalidParts',
			pKey2 => 'testOnly=' || Amd_Utils.boolean2Varchar2(testOnly),
			pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  	 
	  	   FOR rec IN sentParts LOOP
		   	   IF NOT isPartValid(rec.part_no)  THEN
			   	  SELECT nomenclature INTO nomenclature FROM AMD_SPARE_PARTS WHERE part_no = rec.part_no ;
				  IF NOT testOnly THEN
				   	  rc := A2a_Pkg.DeletePartInfo(rec.part_no,nomenclature) ;
					  UPDATE AMD_SENT_TO_A2A
					  SET action_code = Amd_Defaults.DELETE_ACTION,
					  transaction_date = SYSDATE
					  WHERE part_no = rec.part_no ; 
				  END IF ;
				  cnt := cnt + 1 ;
				  debugMsg('part ' || rec.part_no || ' to be deleted from the spo via an a2a transaction.', 210) ;			  
			   END IF ;
		   END LOOP ;
	  	   writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 1320,
			pKey1 => 'deleteInvalidParts',
			pKey2 => 'testOnly=' || Amd_Utils.boolean2Varchar2(testOnly),
			pKey3 => 'cnt=' || TO_CHAR(cnt),
			pKey4 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		   COMMIT ;  	 
	  END deleteInvalidParts ;
	
	PROCEDURE populateBomDetail(part_no IN TMP_A2A_BOM_DETAIL.part_no%TYPE,
			  included_part IN TMP_A2A_BOM_DETAIL.INCLUDED_PART%TYPE,
			  action_code IN TMP_A2A_BOM_DETAIL.action_code%TYPE,
			  quantity IN TMP_A2A_BOM_DETAIL.QUANTITY%TYPE := Amd_Defaults.BOM_QUANTITY,
			  bom IN TMP_A2A_BOM_DETAIL.BOM%TYPE := Amd_Defaults.BOM,
			  begin_date IN TMP_A2A_BOM_DETAIL.BEGIN_DATE%TYPE := NULL,
			  end_date IN TMP_A2A_BOM_DETAIL.end_date%TYPE := NULL) IS
			  
			  PROCEDURE doUpdate IS
			  BEGIN
			 	  UPDATE TMP_A2A_BOM_DETAIL
				  SET action_code = populateBomDetail.action_code,
				  last_update_dt = SYSDATE
				  WHERE part_no = populateBomDetail.part_no ; 
			  EXCEPTION WHEN OTHERS THEN
			    errormsg( psqlfunction => 'update', ptablename => 'tmp_a2a_bom_detail', pError_location => 1330,
			        pkey_1 => populateBomDetail.part_no, pkey_2 => populateBomDetail.included_part) ;
				RAISE ;
			  END doUpdate ;
		BEGIN
			 IF part_no IS NOT NULL THEN
				 INSERT INTO TMP_A2A_BOM_DETAIL
				 (part_no, included_part, quantity, bom, begin_date, end_date, action_code, last_update_dt)
				 VALUES
				 (populateBomDetail.part_no, populateBomDetail.included_part, 
				 	populateBomDetail.quantity, populateBomDetail.bom, 
					populateBomDetail.begin_date, populateBomDetail.end_date,
					populateBomDetail.action_code,SYSDATE) ;
			END IF ;
		EXCEPTION
			 WHEN standard.DUP_VAL_ON_INDEX THEN
			 	  doUpdate ;
		     WHEN OTHERS THEN
			    errormsg( psqlfunction => 'insert', ptablename => 'tmp_a2a_bom_detail', pError_location => 1340,
			        pkey_1 => populateBomDetail.part_no, pkey_2 => populateBomDetail.included_part) ;
			    RAISE ;		 
		END populateBomDetail ; 
	
	  PROCEDURE processPart(rec IN AMD_SENT_TO_A2A%ROWTYPE) IS
	  BEGIN
	  	   populateBomDetail(part_no => rec.spo_prime_part_no,
		   	 included_part => rec.spo_prime_part_no,
			 action_code => rec.action_code) ;
	  END processPart ; 
	
	 PROCEDURE processBomDetail(bomDetail IN bomDetailCur) IS
	 		   cnt NUMBER := 0 ;
			   rec AMD_SENT_TO_A2A%ROWTYPE ;
	 BEGIN
	  	  writeMsg(pTableName => 'tmp_a2a_bom_detail', pError_location => 1350,
			pKey1 => 'processBomDetail',
			pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  	 
	 	  LOOP
		  	  FETCH bomDetail INTO rec ;
			  EXIT WHEN bomDetail%NOTFOUND ;
			  IF rec.spo_prime_part_no IS NOT NULL THEN
				  processPart(rec) ;
				  cnt := cnt + 1 ;
				  IF MOD(cnt,commit_threshold) = 0 THEN
					 COMMIT ;
				  END IF ;
			  END IF ;
		  END LOOP ;
	  	  writeMsg(pTableName => 'tmp_a2a_bom_detail', pError_location => 1360,
			pKey1 => 'processBomDetail',
			pKey2 => 'cnt=' || TO_CHAR(cnt),
			pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  	 
		  COMMIT ;
	 END processBomDetail ;
	 
	 PROCEDURE initA2ABomDetail(from_dt IN DATE := START_DT, to_dt IN DATE := SYSDATE ) IS
		  partsByDate bomDetailCur ;
		  cnt NUMBER := 0 ;
		BEGIN
	  	  writeMsg(pTableName => 'tmp_a2a_bom_detail', pError_location => 1370,
			pKey1 => 'initA2ABomDetail',
			pKey2 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
			pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
			pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  	 
	   	  Mta_Truncate_Table('tmp_a2a_bom_detail','reuse storage');
		  mblnSendAllData := TRUE ;
		  OPEN partsByDate FOR
			  SELECT *
			  FROM AMD_SENT_TO_A2A 
			  WHERE 
			  TRUNC(transaction_date) BETWEEN TRUNC(from_dt) AND TRUNC(to_dt) 
			  AND part_no IN (SELECT spo_prime_part_no FROM AMD_SENT_TO_A2A WHERE part_no = spo_prime_part_no);
		 processBomDetail(partsByDate) ;
		 CLOSE partsByDate ; 
	  	  writeMsg(pTableName => 'tmp_a2a_bom_detail', pError_location => 1380,
			pKey1 => 'initA2ABomDetail',
			pKey2 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
			pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
			pKey4 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		  COMMIT ;  	 
		END initA2ABomDetail ;
		
		PROCEDURE initA2ABomDetail(useTestParts IN BOOLEAN := FALSE) IS
		  parts bomDetailCur ;
		  procedure getTestData is
		  begin
			writeMsg(pTableName => 'amd_sent_to_a2a', pError_location => 1390,
			pKey1 => 'getTestData' ) ;
			commit ;
		    OPEN parts FOR
			  SELECT *
			  FROM AMD_SENT_TO_A2A 
			  WHERE part_no IN (SELECT part_no FROM AMD_TEST_PARTS) 
			  AND part_no IN (SELECT spo_prime_part_no FROM AMD_SENT_TO_A2A WHERE part_no = spo_prime_part_no);
		  end getTestData ;
		  
		  procedure getAllData is
		  begin
			writeMsg(pTableName => 'amd_sent_to_a2a', pError_location => 1400,
			pKey1 => 'getAllData' ) ;
			commit ;
		    OPEN parts FOR
			  SELECT *
			  FROM AMD_SENT_TO_A2A WHERE
			  part_no IN (SELECT spo_prime_part_no FROM AMD_SENT_TO_A2A WHERE part_no = spo_prime_part_no);
		  end getAllData ;
		   
		BEGIN
	  	  writeMsg(pTableName => 'tmp_a2a_bom_detail', pError_location => 1410,
			pKey1 => 'initA2ABomDetail',
			pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
			pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  	 
	   	  Mta_Truncate_Table('tmp_a2a_bom_detail','reuse storage');
		  mblnSendAllData := TRUE ;
		  IF useTestParts THEN
		  	 getTestData ;
		  ELSE
		    getAllData ;
		  END IF ;
		  processBomDetail(parts) ;
		  CLOSE parts ;		
	  	  writeMsg(pTableName => 'tmp_a2a_bom_detail', pError_location => 1420,
			pKey1 => 'initA2ABomDetail',
			pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
			pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		  COMMIT ;  	 
		END initA2ABomDetail ;
	
		PROCEDURE processBackorder(rec IN AMD_BACKORDER_SUM%ROWTYPE, site_location IN TMP_A2A_BACKORDER_INFO.site_location%TYPE) IS
		   PROCEDURE doUpdate IS
		   BEGIN
		  	   UPDATE TMP_A2A_BACKORDER_INFO
			   SET qty = rec.qty,
			   action_code = rec.action_code,
			   last_update_dt = rec.last_update_dt
			   WHERE part_no = rec.spo_prime_part_no
			   AND site_location = processBackorder.site_location
			   AND loc_sid = rec.loc_sid ;
		   EXCEPTION WHEN OTHERS THEN
			    errormsg( psqlfunction => 'update', ptablename => 'tmp_a2a_backorder_info', pError_location => 1430,
			        pkey_1 => rec.spo_prime_part_no, pkey_2 => TO_CHAR(rec.loc_sid), pkey_3 => site_location) ;
		   		RAISE ;
		   END doUpdate ;
		   
		   FUNCTION getSpoPrimePartNo(part_no AMD_SENT_TO_A2A.part_no%TYPE) RETURN AMD_SENT_TO_A2A.SPO_PRIME_PART_NO%TYPE IS
		   			spo_prime_part_no AMD_SENT_TO_A2A.SPO_PRIME_PART_NO%TYPE ;
		   BEGIN
		   		SELECT DISTINCT spo_prime_part_no INTO spo_prime_part_no 
				FROM AMD_SENT_TO_A2A
				WHERE part_no = getSpoPrimePartNo.part_no ;
				RETURN spo_prime_part_no ;
		   END getSpoPrimePartNo ;
		   
		BEGIN
			INSERT INTO TMP_A2A_BACKORDER_INFO
				(part_no, loc_sid, site_location,qty, action_code, last_update_dt)
				VALUES
				(rec.spo_prime_part_no, rec.loc_sid, site_location, rec.qty, rec.action_code, rec.last_update_dt);
		EXCEPTION 
			WHEN standard.DUP_VAL_ON_INDEX THEN
				doUpdate ;
			WHEN OTHERS THEN
			    errormsg( psqlfunction => 'insert', ptablename => 'tmp_a2a_backorder_info', pError_location => 1440,
			        pkey_1 => rec.spo_prime_part_no, pkey_2 => TO_CHAR(rec.loc_sid), pkey_3 => site_location) ;
				RAISE ;
		END processBackorder ;
	    PROCEDURE processBackOrder(backOrder IN backOrderCur) IS
				  cnt NUMBER := 0 ;
				  rec AMD_BACKORDER_SUM%ROWTYPE ;
		 		  site_location TMP_A2A_BACKORDER_INFO.site_location%TYPE ;
		BEGIN
		  	 writeMsg(pTableName => 'tmp_a2a_backorder_info', pError_location => 1450,
				pKey1 => 'processBackOrder',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  	 
			 LOOP
			 	 FETCH backOrder INTO rec ;
				 EXIT WHEN backOrder%NOTFOUND ;
			  	 site_location := Amd_Utils.getSpoLocation(rec.loc_sid) ;
				 IF site_location IS NOT NULL THEN
			  	  	 processBackorder(rec, site_location) ;
					 cnt := cnt + 1 ;
					 IF MOD(cnt,commit_threshold) = 0 THEN
						 COMMIT ;
					 END IF ;
				 END IF ;
			 END LOOP ;
		  	 writeMsg(pTableName => 'tmp_a2a_backorder_info', pError_location => 1460,
				pKey1 => 'processBackOrder',
				pKey2 => 'cnt=' || TO_CHAR(cnt),
				pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  	 
			 COMMIT ;
		END processBackOrder ;
		
	 	PROCEDURE initA2ABackorderInfo(from_dt IN DATE := START_DT, to_dt IN DATE := SYSDATE ) IS
		  
		  backOrdersByDate backOrderCur ;
		  
		BEGIN
		  	 writeMsg(pTableName => 'tmp_a2a_backorder_info', pError_location => 1470,
				pKey1 => 'initA2ABackorderInfo',
				pKey2 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
				pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
				pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  	 
	   	  Mta_Truncate_Table('tmp_a2a_backorder_info','reuse storage');
		  mblnSendAllData := TRUE ;
		  OPEN backOrdersByDate FOR
			  SELECT
				  sent.spo_prime_part_no,         
				  bo.LOC_SID,         
				  QTY,
				  case bo.action_code
				  	   when amd_defaults.getDELETE_ACTION then
					   		bo.action_code             
				  	   else
					   	   sent.ACTION_CODE
				  end action_code,    
				  LAST_UPDATE_DT 		  
			  FROM AMD_BACKORDER_SUM bo, amd_sent_to_a2a sent 
			  WHERE 
			  TRUNC(last_update_dt) BETWEEN TRUNC(from_dt) AND TRUNC(to_dt) 
		  	  AND bo.spo_prime_part_no = sent.part_no
			  and sent.SPO_PRIME_PART_NO is not null ;
			  
		  processBackOrder(backOrdersByDate) ;
		  CLOSE backOrdersByDate ;	  
		  writeMsg(pTableName => 'tmp_a2a_backorder_info', pError_location => 1480,
				pKey1 => 'initA2ABackorderInfo',
				pKey2 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
				pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
				pKey4 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  	 
		  COMMIT ;
		END initA2ABackorderInfo ;
	
	 	PROCEDURE initA2ABackorderInfo(useTestParts IN BOOLEAN := FALSE ) IS
		  parts backOrderCur ;
		  useTestPartsString VARCHAR2(5) := 'False' ;
		  procedure getTestData is
		  begin
			 writeMsg(pTableName => 'amd_backorder_sum', pError_location => 1490,
			 pKey1 => 'getTestData' ) ;
			 commit ;
		  	 OPEN parts FOR
			  SELECT 
				  sent.spo_prime_part_no,         
				  LOC_SID,         
				  QTY,             
				  case bo.action_code
				  	   when amd_defaults.getDELETE_ACTION then
					   		bo.action_code
					   else    
					   		sent.ACTION_CODE
				  end action_code,
				  LAST_UPDATE_DT 		  
			  FROM AMD_BACKORDER_SUM bo, amd_sent_to_a2a sent, amd_test_parts testParts 
			  WHERE 
			  bo.spo_prime_part_no = testParts.part_no 
		  	  AND bo.spo_prime_part_no = sent.part_no
			  and sent.SPO_PRIME_PART_NO is not null ;
			  
		  	  useTestPartsString := 'True' ;
			  
		  end getTestData ;
		  
		  procedure getAllData is
		  begin
			 writeMsg(pTableName => 'amd_backorder_sum', pError_location => 1500,
			 pKey1 => 'getAllData' ) ;
			 commit ;
		  	 OPEN parts FOR
			  SELECT 
				  sent.spo_prime_part_no,         
				  LOC_SID,         
				  QTY,
				  case bo.action_code
				  	   when amd_defaults.getDELETE_ACTION then
					   		bo.action_code
					   else             
				  	   		sent.ACTION_CODE
				  end action_code,    
				  LAST_UPDATE_DT 		  
			  FROM AMD_BACKORDER_SUM bo, amd_sent_to_a2a sent
			  WHERE bo.spo_prime_part_no = sent.part_no
			  and sent.SPO_PRIME_PART_NO is not null ;
		  end getAllData ;
		  
		BEGIN
		  writeMsg(pTableName => 'tmp_a2a_backorder_info', pError_location => 1510,
				pKey1 => 'initA2ABackorderInfo',
				pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
				pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  	 
	   	  Mta_Truncate_Table('tmp_a2a_backorder_info','reuse storage');
		  mblnSendAllData := TRUE ;
		  IF useTestParts THEN
		  	 getTestData ;
		  ELSE
		  	 getAllData ;
		  END IF ;
		  processBackOrder(parts) ;
		  CLOSE parts ;
		  writeMsg(pTableName => 'tmp_a2a_backorder_info', pError_location => 1520,
				pKey1 => 'initA2ABackorderInfo',
				pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
				pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		  COMMIT ;  	 
		END initA2ABackorderInfo ;
	
		PROCEDURE loadAll(startStep IN NUMBER := 1, endStep IN NUMBER := 15, debugIt IN BOOLEAN := FALSE, system_id IN AMD_BATCH_JOBS.SYSTEM_ID%TYPE := 'LOAD_ALL_A2A') IS
				  rc NUMBER := 0 ;
				  SPO_USERS CONSTANT VARCHAR2(9) := 'SPO_USERS' ;
				  RESP_ASSET_MGR CONSTANT VARCHAR2(14) := 'RESP_ASSET_MGR' ;
				  PART_INFO CONSTANT VARCHAR2(9) := 'PART_INFO' ;
				  ORDER_INFO CONSTANT VARCHAR2(10) := 'ORDER_INFO' ;
				  REPAIR_INFO CONSTANT VARCHAR2(11) := 'REPAIR_INFO' ; 
				  IN_TRANSITS CONSTANT VARCHAR2(11) := 'IN_TRANSITS' ; 
				  INV_INFO CONSTANT VARCHAR2(8) := 'INV_INFO' ;
				  REPAIR_INV_INFO CONSTANT VARCHAR2(15) := 'REPAIR_INV_INFO' ;
				  BACKORDER_INFO CONSTANT VARCHAR2(14) := 'BACKORDER_INFO' ;
				  LOC_PART_LEAD_TIME CONSTANT VARCHAR2(18) := 'LOC_PART_LEAD_TIME' ;
				  LOC_PART_OVERRIDE CONSTANT VARCHAR2(17) := 'LOC_PART_OVERRIDE' ;
				  BOM_DETAIL CONSTANT VARCHAR2(10) := 'BOM_DETAIL' ;
				  EXT_FORECAST CONSTANT VARCHAR2(12) := 'EXT_FORECAST' ;
				  PART_FACTORS CONSTANT VARCHAR2(12) := 'PART_FACTORS' ;
				  DEMANDS CONSTANT VARCHAR2(7) := 'DEMANDS' ;
				  
				  theJob AMD_BATCH_JOBS.BATCH_JOB_NUMBER%TYPE ;
				  batch_step_number AMD_BATCH_JOB_STEPS.BATCH_STEP_NUMBER%TYPE ;
		BEGIN
		   writeMsg(pTableName => 'loadAll', pError_location => 1530,
				pKey1 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
			mblnSendAllData := TRUE ;
			IF NOT Amd_Batch_Pkg.isJobActive(system_id => loadAll.system_id) THEN
			   Amd_Batch_Pkg.start_job(system_id => loadAll.system_id,description => 'Load all the A2A transactions') ;
			END IF ;
			
			theJob := Amd_Batch_Pkg.getActiveJob(system_id => loadAll.system_id) ;
			
			A2a_Pkg.mDebug := debugIt ;
			FOR step IN startStep..endStep LOOP
				IF step = 1 THEN
				 	IF NOT Amd_Batch_Pkg.isStepComplete(batch_job_number => theJob, system_id => loadAll.system_id,
		   					description => SPO_USERS) THEN
					 	Amd_Batch_Pkg.start_step(batch_job_number => theJob, system_id => loadAll.system_id,
							description => SPO_USERS, package_name => THIS_PACKAGE, procedure_name => SPO_USERS) ;
						amd_owner.A2a_Pkg.initA2ASpoUsers ;
					END IF ;
				ELSIF step = 2 THEN
				 	IF NOT Amd_Batch_Pkg.isStepComplete(batch_job_number => theJob, system_id => loadAll.system_id,
		   					description => RESP_ASSET_MGR) THEN
					 	Amd_Batch_Pkg.start_step(batch_job_number => theJob, system_id => loadAll.system_id,
							description => RESP_ASSET_MGR, package_name => THIS_PACKAGE, procedure_name => RESP_ASSET_MGR) ;
							amd_owner.A2a_Pkg.initSiteRespAssetMgr ;
					END IF ;
				ELSIF step = 3 THEN
				 	IF NOT Amd_Batch_Pkg.isStepComplete(batch_job_number => theJob, system_id => loadAll.system_id,
		   					description => PART_INFO) THEN
					 	Amd_Batch_Pkg.start_step(batch_job_number => theJob, system_id => loadAll.system_id,
							description => PART_INFO, package_name => THIS_PACKAGE, procedure_name => PARt_INFO) ;
							rc := amd_owner.A2a_Pkg.initA2APartInfo(useTestParts => FALSE) ;
					END IF ;
				ELSIF step = 4 THEN
				 	IF NOT Amd_Batch_Pkg.isStepComplete(batch_job_number => theJob, system_id => loadAll.system_id,
		   					description => ORDER_INFO) THEN
					 	Amd_Batch_Pkg.start_step(batch_job_number => theJob, system_id => loadAll.system_id,
							description => ORDER_INFO, package_name => THIS_PACKAGE, procedure_name => ORDER_INFO) ;
						rc := amd_owner.A2a_Pkg.initA2AOrderInfo(useTestParts => FALSE) ;
						Amd_Partprime_Pkg.DiffPartToPrime ; -- set amd_sent_to_a2a.spo_prime_part_no
					END IF ;
				ELSIF step = 5 THEN
				 	IF NOT Amd_Batch_Pkg.isStepComplete(batch_job_number => theJob, system_id => loadAll.system_id,
		   					description => REPAIR_INFO) THEN
					 	Amd_Batch_Pkg.start_step(batch_job_number => theJob, system_id => loadAll.system_id,
							description => REPAIR_INFO, package_name => THIS_PACKAGE, procedure_name => REPAIR_INFO) ;
						rc := amd_owner.A2a_Pkg.initA2ARepairInfo(useTestParts => FALSE) ;
					END IF ;
				ELSIF step = 6 THEN
				 	IF NOT Amd_Batch_Pkg.isStepComplete(batch_job_number => theJob, system_id => loadAll.system_id,
		   					description => IN_TRANSITS) THEN
					 	Amd_Batch_Pkg.start_step(batch_job_number => theJob, system_id => loadAll.system_id,
							description => IN_TRANSITS, package_name => THIS_PACKAGE, procedure_name => IN_TRANSITS) ;
							rc := amd_owner.A2a_Pkg.initA2AInTransits(useTestParts => FALSE) ;
					END IF ;
				ELSIF step = 7 THEN
				 	IF NOT Amd_Batch_Pkg.isStepComplete(batch_job_number => theJob, system_id => loadAll.system_id,
		   					description => INV_INFO) THEN
					 	Amd_Batch_Pkg.start_step(batch_job_number => theJob, system_id => loadAll.system_id,
							description => INV_INFO, package_name => THIS_PACKAGE, procedure_name => INV_INFO) ;
							rc := amd_owner.A2a_Pkg.initA2AInvInfo(useTestParts => FALSE) ;
					END IF ;
				ELSIF step = 8 THEN
				 	IF NOT Amd_Batch_Pkg.isStepComplete(batch_job_number => theJob, system_id => loadAll.system_id,
		   					description => REPAIR_INV_INFO) THEN
					 	Amd_Batch_Pkg.start_step(batch_job_number => theJob, system_id => loadAll.system_id,
							description => REPAIR_INV_INFO, package_name => THIS_PACKAGE, procedure_name => REPAIR_INV_INFO) ;
							rc := amd_owner.A2a_Pkg.initA2ARepairInvInfo(useTestParts => FALSE) ;
					END IF ;
				ELSIF step = 9 THEN
				 	IF NOT Amd_Batch_Pkg.isStepComplete(batch_job_number => theJob, system_id => loadAll.system_id,
		   					description => BACKORDER_INFO) THEN
					 	Amd_Batch_Pkg.start_step(batch_job_number => theJob, system_id => loadAll.system_id,
							description => BACKORDER_INFO, package_name => THIS_PACKAGE, procedure_name => BACKORDER_INFO) ;
						amd_owner.A2a_Pkg.initA2ABackorderInfo(useTestParts => FALSE) ;
					END IF ;
				ELSIF step = 10 THEN
				 	IF NOT Amd_Batch_Pkg.isStepComplete(batch_job_number => theJob, system_id => loadAll.system_id,
		   					description => LOC_PART_LEAD_TIME) THEN
					 	Amd_Batch_Pkg.start_step(batch_job_number => theJob, system_id => loadAll.system_id,
							description => LOC_PART_LEAD_TIME, package_name => THIS_PACKAGE, procedure_name => LOC_PART_LEAD_TIME) ;
							amd_owner.Amd_Location_Part_Leadtime_Pkg.LoadAllA2A ;
					END IF ;
				ELSIF step = 11 THEN
				 	IF NOT Amd_Batch_Pkg.isStepComplete(batch_job_number => theJob, system_id => loadAll.system_id,
		   					description => LOC_PART_OVERRIDE) THEN
					 	Amd_Batch_Pkg.start_step(batch_job_number => theJob, system_id => loadAll.system_id,
							description => LOC_PART_OVERRIDE, package_name => THIS_PACKAGE, procedure_name => LOC_PART_OVERRIDE) ;
						amd_owner.Amd_Location_Part_Override_Pkg.loadAllA2A ;
					END IF ;
				ELSIF step = 12 THEN
				 	IF NOT Amd_Batch_Pkg.isStepComplete(batch_job_number => theJob, system_id => loadAll.system_id,
		   					description => BOM_DETAIL) THEN
					 	Amd_Batch_Pkg.start_step(batch_job_number => theJob, system_id => loadAll.system_id,
							description => BOM_DETAIL, package_name => THIS_PACKAGE, procedure_name => BOM_DETAIL) ;
							amd_owner.A2a_Pkg.initA2ABomDetail(useTestParts => FALSE) ;
					END IF ;
				ELSIF step = 13 THEN
				 	IF NOT Amd_Batch_Pkg.isStepComplete(batch_job_number => theJob, system_id => loadAll.system_id,
		   					description => EXT_FORECAST) THEN
					 	Amd_Batch_Pkg.start_step(batch_job_number => theJob, system_id => loadAll.system_id,
							description => EXT_FORECAST, package_name => THIS_PACKAGE, procedure_name => EXT_FORECAST) ;
						<<loadExtForecast>>
						DECLARE
							cnt NUMBER ;
						BEGIN
							<<getCnt>>
							BEGIN
								SELECT COUNT(*) INTO cnt FROM AMD_PART_LOC_FORECASTS ;
							EXCEPTION WHEN standard.NO_DATA_FOUND THEN
								cnt := 0 ;
							END getCnt ;
							IF cnt = 0 THEN
								amd_owner.Amd_Part_Loc_Forecasts_Pkg.LoadInitial ;
							ELSE
								initA2AExtForecast(useTestParts => false) ;
							END IF ;
						END loadExtForecast ;
					END IF ;
				ELSIF step = 14 THEN
				 	IF NOT Amd_Batch_Pkg.isStepComplete(batch_job_number => theJob, system_id => loadAll.system_id,
		   					description => PART_FACTORS) THEN
					 	Amd_Batch_Pkg.start_step(batch_job_number => theJob, system_id => loadAll.system_id,
							description => PART_FACTORS, package_name => THIS_PACKAGE, procedure_name => PART_FACTORS) ;
							amd_owner.Amd_Part_Factors_Pkg.loadAllA2A ;
					END IF ;
				ELSIF step = 15 THEN
				 	IF NOT Amd_Batch_Pkg.isStepComplete(batch_job_number => theJob, system_id => loadAll.system_id,
		   					description => DEMANDS) THEN
					 	Amd_Batch_Pkg.start_step(batch_job_number => theJob, system_id => loadAll.system_id,
							description => DEMANDS, package_name => THIS_PACKAGE, procedure_name => DEMANDS) ;
						initA2ADemands ;
					END IF ;
				END IF ;
				COMMIT ;
				 batch_step_number := Amd_Batch_Pkg.getActiveStep(batch_job_number => theJob, system_id => loadAll.system_id) ;
				 IF batch_step_number IS NOT NULL THEN
				 	 Amd_Batch_Pkg.end_step(batch_job_number => theJob, system_id => loadAll.system_id,
						batch_step_number => batch_step_number) ;
				 END IF ;
				 COMMIT ;
		  		 writeMsg(pTableName => 'loadAll', pError_location => 1540,
				 		pKey1 => 'step=' || step,
						pKey2 => 'rc=' || rc) ;
				 COMMIT ;
				 rc := 0 ;
			END LOOP ;
			Amd_Batch_Pkg.end_job(batch_job_number => theJob, system_id => loadAll.system_id) ;
		    writeMsg(pTableName => 'loadAll', pError_location => 1550,
				pKey1 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		END loadAll ;
		
		PROCEDURE version IS
		BEGIN
			 writeMsg(pTableName => 'a2a_pkg', 
			 		pError_location => 1560, pKey1 => 'a2a_pkg', pKey2 => '$Revision:   1.158  $') ;
		 	 dbms_output.put_line('a2a_pkg: $Revision:   1.158  $') ;
		END version ;
		
		function getStart_dt return date is
		begin
			 return START_DT ;
		end getStart_dt ;

		function getNEW_BUY return tmp_a2a_loc_part_lead_time.LEAD_TIME_TYPE%type is
		begin
			 return NEW_BUY ;
		end getNEW_BUY ;
		 
		function getREPAIR  return tmp_a2a_loc_part_lead_time.lead_time_type%type is
		begin
			 return REPAIR ;
		end getREPAIR ;
		
		function getAN_ORDER return tmp_a2a_part_pricing.PRICE_TYPE%type is
		begin
			 return AN_ORDER ;
		end getAN_ORDER ;
		
		function getOPEN_STATUS return tmp_a2a_repair_info.STATUS%type is
		begin
			 return OPEN_STATUS ;
		end getOPEN_STATUS ;
		
		function getTHIRD_PARTY_FLAG return tmp_a2a_part_info.THIRD_PARTY_FLAG%type is
		begin
			 return THIRD_PARTY_FLAG ;
		end getTHIRD_PARTY_FLAG ;
		
		procedure deleteSentToA2AChildren is
				  cursor childrenToDelete is
					select ch.part_no, nomenclature 
					from 
					amd_sent_to_a2a paren,
					amd_sent_to_a2a ch, 
					amd_spare_parts parts
					where ch.part_no <> ch.spo_prime_part_no
					and ch.SPO_PRIME_PART_NO = paren.part_no
					and ch.action_code <> paren.action_code
					and paren.action_code = amd_defaults.getDELETE_ACTION
					and ch.part_no = parts.part_no ;
				cnt number := 0 ;
				result number ; 
		begin
		    writeMsg(pTableName => 'deleteSentToA2AChildren', pError_location => 1570,
				pKey1 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
			 for rec in childrenToDelete loop
			 	 cnt := cnt + 1 ;
				 update amd_sent_to_a2a
				 set action_code = amd_defaults.DELETE_ACTION
				 where part_no = rec.part_no ;
				 
			 	 if mod(cnt,COMMIT_THRESHOLD) = 0 then
				  	 commit ;
				 end if ;
				 
				 result := deletePartInfo(rec.part_no, rec.nomenclature) ;
				 
			 end loop ;
		     writeMsg(pTableName => 'deleteSentToA2AChildren', pError_location => 1580,
				pKey1 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey2 => 'cnt=' || to_char(cnt) ) ;
		
		end deleteSentToA2AChildren ;

			
	BEGIN
	
	  <<getDebugParam>>
	  DECLARE
	  	 param AMD_PARAM_CHANGES.PARAM_VALUE%TYPE ;
	  BEGIN
	     SELECT param_value INTO param FROM AMD_PARAM_CHANGES WHERE param_key = 'debugA2A' ;
	     mDebug := (param = '1');
	  EXCEPTION WHEN OTHERS THEN
	     mDebug := FALSE ;
	  END getDebugParam;
END A2a_Pkg ;
/

show errors

ALTER TABLE tmp_amd_rsp ENABLE PRIMARY KEY;

CREATE PUBLIC SYNONYM AMD_INVENTORY FOR AMD_OWNER.AMD_INVENTORY;


CREATE PUBLIC SYNONYM AMD_LOAD FOR AMD_OWNER.AMD_LOAD;


CREATE PUBLIC SYNONYM AMD_LOCATION_PART_OVERRIDE_PKG FOR AMD_OWNER.AMD_LOCATION_PART_OVERRIDE_PKG;


CREATE PUBLIC SYNONYM AMD_PART_LOC_FORECASTS_PKG FOR AMD_OWNER.AMD_PART_LOC_FORECASTS_PKG;


GRANT EXECUTE ON  AMD_OWNER.AMD_INVENTORY TO AMD_READER_ROLE;

GRANT EXECUTE ON  AMD_OWNER.AMD_LOAD TO AMD_READER_ROLE;

GRANT EXECUTE ON  AMD_OWNER.AMD_LOCATION_PART_OVERRIDE_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON  AMD_OWNER.AMD_PART_LOC_FORECASTS_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON  AMD_OWNER.AMD_INVENTORY TO AMD_WRITER_ROLE;

GRANT EXECUTE ON  AMD_OWNER.AMD_LOAD TO AMD_WRITER_ROLE;

GRANT EXECUTE ON  AMD_OWNER.AMD_LOCATION_PART_OVERRIDE_PKG TO AMD_WRITER_ROLE;

GRANT EXECUTE ON  AMD_OWNER.AMD_PART_LOC_FORECASTS_PKG TO AMD_WRITER_ROLE;

GRANT EXECUTE ON  AMD_OWNER.AMD_INVENTORY TO BSRM_LOADER;




