set define off

DROP PACKAGE AMD_OWNER.AMD_PART_LOC_FORECASTS_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.AMD_PART_LOC_FORECASTS_PKG AS
 /*
      $Author:   zf297a  $
	$Revision:   1.1  $
        $Date:   15 Oct 2007 23:50:12  $
    $Workfile:   amd_part_loc_forecasts_pkg.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Scripts\AMD 2.0 Implementation\amd_part_loc_forecasts_pkg.sql.-arc  $
/*   
/*      Rev 1.1   15 Oct 2007 23:50:12   zf297a
/*   Updated to ver 1.30 for the package body
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

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_PART_LOC_FORECASTS_PKG;

CREATE PUBLIC SYNONYM AMD_PART_LOC_FORECASTS_PKG FOR AMD_OWNER.AMD_PART_LOC_FORECASTS_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_PART_LOC_FORECASTS_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_PART_LOC_FORECASTS_PKG TO AMD_WRITER_ROLE;


DROP PACKAGE BODY AMD_OWNER.AMD_PART_LOC_FORECASTS_PKG;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.AMD_PART_LOC_FORECASTS_PKG AS
 /*
      $Author:   zf297a  $
	$Revision:   1.1  $
        $Date:   15 Oct 2007 23:50:12  $
    $Workfile:   amd_part_loc_forecasts_pkg.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_PART_LOC_FORECASTS_PKG.pkb.-arc  $
/*   
/*      Rev 1.30   Oct 03 2007 11:54:46   c402417
/*   Added a check for either part is consumable or repairable before insert into tmp_a2a_ext_forecast.
/*   
/*      Rev 1.29   Oct 02 2007 16:23:54   c402417
/*   Removed the filter FD2090 when insert into tmp_a2a_ext_forecast
/*   
/*      Rev 1.28   12 Sep 2007 13:53:36   zf297a
/*   Removed commits from for loops.
/*   
/*      Rev 1.27   07 Feb 2007 09:36:00   zf297a
/*   Filter out locations FD2090
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
                if Amd_Utils.isPartRepairableYorN(pPartNo) = 'Y' and pLocation = 'FD2090'then
                    null ; -- do nothing
                else  --This condition is for Repairable only.
                
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
                end if ;
				
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
		 		pError_location => 280, pKey1 => 'amd_part_loc_forecasts_pkg', pKey2 => '$Revision:   1.1  $') ;
		 dbms_output.put_line('amd_part_loc_forecasts_pkg: $Revision:   1.1  $') ;
	end version ;
	
END AMD_PART_LOC_FORECASTS_PKG ;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_PART_LOC_FORECASTS_PKG;

CREATE PUBLIC SYNONYM AMD_PART_LOC_FORECASTS_PKG FOR AMD_OWNER.AMD_PART_LOC_FORECASTS_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_PART_LOC_FORECASTS_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_PART_LOC_FORECASTS_PKG TO AMD_WRITER_ROLE;


