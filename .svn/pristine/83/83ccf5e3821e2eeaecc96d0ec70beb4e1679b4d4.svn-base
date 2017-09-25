SET DEFINE OFF;
DROP PACKAGE AMD_OWNER.AMD_LOCATION_PART_LEADTIME_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.AMD_LOCATION_PART_LEADTIME_PKG AS
/*
      $Author:   zf297a  $
    $Revision:   1.11  $
	    $Date:   18 Feb 2008 14:50:04  $
    $Workfile:   AMD_LOCATION_PART_LEADTIME_PKG.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_LOCATION_PART_LEADTIME_PKG.pks.-arc  $
/*   
/*      Rev 1.11   18 Feb 2008 14:50:04   zf297a
/*   Added interface for function getVersion
/*   
/*      Rev 1.10   07 Nov 2007 17:25:30   zf297a
/*   Added type locationPartLeadTimeTab.
/*   
/*      Rev 1.9   Oct 25 2006 09:56:32   zf297a
/*   Made the constanst anchored declarations - ie used %type attribute.
/*   
/*      Rev 1.8   Oct 25 2006 09:19:06   zf297a
/*   Added interfaces for functions to return constants:
/*   getVIRTUAL_COD_SPO_LOCATION
/*   getVIRTUAL_UAB_SPO_LOCATION
/*   getUK_LOCATION 		
/*   getBASC_LOCATION
/*   getLEADTIMETYPE
/*   getBULKLIMIT 
/*   
/*   
/*      Rev 1.7   Jun 12 2006 13:22:08   zf297a
/*   added symbolic constants for UK_LOCATION and BASC_LOCATION.
/*   
/*      Rev 1.6   Jun 09 2006 11:50:52   zf297a
/*   added interface version
/*   
/*      Rev 1.5   Mar 03 2006 12:18:56   zf297a
/*   Removed IsLatestRun and GetBatchRunStart.  GetBatchRunStart is being replaced by amd_batch_pkg.getLastStartTime since it will always return the last start time of the last job that has been run even if it has already completed.  That way if data has changed since the start of the last batch job, then it should be sent in an a2a transaction.  This may cause the same data to be sent again but that is not a problem.
/*   
/*      Rev 1.4   Feb 15 2006 14:00:46   zf297a
/*   Added cur ref, record type and a common process routine so that the data gets loaded the same no matter what selection criteria is used.
/*   
/*      Rev 1.3   Jan 04 2006 10:07:38   zf297a
/*   Made loadAllA2A and loadA2AByDate conform to the a2a_pkg.initA2A procedures.
/*   
/*      Rev 1.2   Jan 03 2006 12:45:50   zf297a
/*   Added date range to procedure loadA2AByDate
/*   
/*      Rev 1.1   Dec 29 2005 16:29:58   zf297a
/*   Added loadA2AByDate procedure
/*   
/*      Rev 1.0   Nov 30 2005 12:40:00   zf297a
/*   Initial revision.
/*   
/*      Rev 1.0   Nov 30 2005 12:31:04   zf297a
/*   Initial revision.
*/	

	VIRTUAL_COD_SPO_LOCATION CONSTANT amd_spare_networks.spo_location%type := 'VIRTUAL COD' ;
	VIRTUAL_UAB_SPO_LOCATION CONSTANT amd_spare_networks.spo_location%type := 'VIRTUAL UAB' ;
	UK_LOCATION 			 CONSTANT amd_spare_networks.LOC_ID%type  := 'EY8780' ;
	BASC_LOCATION			 CONSTANT amd_spare_networks.loc_id%type  := 'EY1746' ;
	
	LEADTIMETYPE 			 CONSTANT tmp_a2a_part_lead_time.LEAD_TIME_TYPE%type := 'REPAIR' ;
	
	BULKLIMIT 	 		  			CONSTANT NUMBER := 100000 ;
	SUCCESS							CONSTANT NUMBER := 0 ;
	FAILURE							CONSTANT NUMBER := 4 ;
	
	type locationPartLeadTimeRec is record  (
		part_no amd_location_part_leadtime.part_no%type,
		lead_time_type varchar2(6),
		time_to_repair amd_location_part_leadtime.TIME_TO_REPAIR%type,
		action_code amd_location_part_leadtime.action_code%type,
		last_update_dt date,
		site_location tmp_a2a_loc_part_lead_time.site_location%type
	) ;
	type locationPartLeadTimeTab is table of locationPartLeadTimeRec ;
    
	type locPartLeadTimeCur is ref cursor return locationPartLeadTimeRec ;
	procedure processLocPartLeadtime(locPartLeadTime in locPartLeadTimeCur) ;
	
	FUNCTION IsPartRepairable(pNsiSid amd_national_stock_items.nsi_sid%TYPE ) RETURN VARCHAR2 ;
	FUNCTION IsPartRepairable(pPartNo amd_spare_parts.part_no%TYPE ) RETURN VARCHAR2 ;
	-- pragma restrict_references (IsPartRepairable, WNDS) ;
	FUNCTION IsPartDeleted(pPartNo amd_sent_to_a2a.part_no%TYPE) RETURN BOOLEAN ;
	FUNCTION GetAvgRepairCycleTime(pNsn amd_nsns.nsn%TYPE, pLocId amd_spare_networks.loc_id%TYPE) RETURN ramp.avg_repair_cycle_time%TYPE ;
	FUNCTION GetRampData(pNsn amd_nsns.nsn%TYPE, pLocId amd_spare_networks.loc_id%TYPE) RETURN ramp%ROWTYPE ;
	pragma restrict_references (GetRampData, WNDS) ;
	pragma restrict_references (GetAvgRepairCycleTime, WNDS) ;
	
	
	-- load procedure will truncate tmp_amd_location_part_leadtime prior to loading
	
	FUNCTION InsertRow(
			pPartNo                      amd_location_part_leadtime.part_no%TYPE,
			pLocSid                      amd_location_part_leadtime.loc_sid%TYPE,
			pTimeToRepair				 amd_location_part_leadtime.time_to_repair%TYPE)
			return NUMBER ;
	
	FUNCTION Updaterow(
			pPartNo                      amd_location_part_leadtime.part_no%TYPE,
			pLocSid                      amd_location_part_leadtime.loc_sid%TYPE,
			pTimeToRepair				 amd_location_part_leadtime.time_to_repair%TYPE)
			RETURN NUMBER ;
	
	
	FUNCTION DeleteRow(
			pPartNo                      amd_location_part_leadtime.part_no%TYPE,
			pLocSid                      amd_location_part_leadtime.loc_sid%TYPE,
			pTimeToRepair				 amd_location_part_leadtime.time_to_repair%TYPE)
			RETURN NUMBER ;
	
	
	
	PROCEDURE LoadTmpAmdLocPartLeadtime ;
	PROCEDURE LoadAmdLocPartLeadtime ;
	PROCEDURE LoadAllA2A(useTestParts in boolean := false) ;
	procedure loadA2AByDate (from_dt in date := a2a_pkg.start_dt, to_dt in date := sysdate) ;
	PROCEDURE LoadInitial ;

	-- added 6/9/2006 by dse
	procedure version ;

    function getVersion return varchar2 ; -- added 2/18/2008 by dse
	
	-- added get functions to return constants 10/25/2006 by dse
	function getVIRTUAL_COD_SPO_LOCATION return amd_spare_networks.spo_location%type ;
	function getVIRTUAL_UAB_SPO_LOCATION return amd_spare_networks.spo_location%type ;
	function getUK_LOCATION 			 return amd_spare_networks.LOC_ID%type ;
	function getBASC_LOCATION			 return amd_spare_networks.LOC_ID%type ;	
	function getLEADTIMETYPE 			 return tmp_a2a_loc_part_lead_time.LEAD_TIME_TYPE%type ;
	function getBULKLIMIT 	 		  	 return number ;

END AMD_LOCATION_PART_LEADTIME_PKG ;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_LOCATION_PART_LEADTIME_PKG;

CREATE PUBLIC SYNONYM AMD_LOCATION_PART_LEADTIME_PKG FOR AMD_OWNER.AMD_LOCATION_PART_LEADTIME_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_LOCATION_PART_LEADTIME_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_LOCATION_PART_LEADTIME_PKG TO AMD_WRITER_ROLE;


SET DEFINE OFF;
DROP PACKAGE BODY AMD_OWNER.AMD_LOCATION_PART_LEADTIME_PKG;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.AMD_LOCATION_PART_LEADTIME_PKG AS
/*
      $Author:   zf297a  $
    $Revision:   1.21  $
	    $Date:   24 Sep 2008 11:20:24  $
    $Workfile:   AMD_LOCATION_PART_LEADTIME_PKG.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_LOCATION_PART_LEADTIME_PKG.pkb.-arc  $
/*   
/*      Rev 1.21   24 Sep 2008 11:20:24   zf297a
/*   Fixed locPartLeadtime_cur by qualifying spo_prime_part_no with table amd_sent_to_a2a
/*   
/*      Rev 1.20   18 Feb 2008 14:50:22   zf297a
/*   implemented function getVersion
/*   
/*      Rev 1.19   18 Feb 2008 14:44:14   zf297a
/*   For the loadAllA2A make sure the part is prime and that it is active.
/*   
/*      Rev 1.18   03 Dec 2007 13:18:42   zf297a
/*   Removed close of locPartLeadTime cursor since it is already closed by the processLocPartLeadTime procedure.
/*   
/*      Rev 1.17   07 Nov 2007 17:25:48   zf297a
/*   Use bulk collect for all the cursors.
/*   
/*      Rev 1.16   12 Sep 2007 14:01:22   zf297a
/*   Removed commit from for loop.
/*   
/*      Rev 1.15   Nov 28 2006 14:35:20   zf297a
/*   fixed insertTmpA2A_LPLT - for INSERT_ACTION or UPDATE_ACTION check to see if the part is in amd_sent_to_a2a with action_code <> DELETE_ACTION then insert it into tmp_a2a_loc_part_lead_time.  For DELETE_ACTION's check to see if the part is in amd_sent_to_a2a with any action_code then insert it into tmp_a2a_loc_part_lead_time.
/*   
/*      Rev 1.14   Oct 25 2006 09:19:46   zf297a
/*   Implemented functions:
/*   getVIRTUAL_COD_SPO_LOCATION
/*   getVIRTUAL_UAB_SPO_LOCATION
/*   getUK_LOCATION 		
/*   getBASC_LOCATION
/*   getLEADTIMETYPE
/*   getBULKLIMIT.
/*   Added dbms_output.put_line to the version procedure.
/*   
/*   
/*      Rev 1.13   Jun 09 2006 11:51:06   zf297a
/*   implemented version
/*   
/*      Rev 1.12   Jun 01 2006 12:13:10   zf297a
/*   switched from dbms_output to amd_utils.writeMsg and from executed immediate to Mta_Truncate_Table
/*   
/*      Rev 1.11   May 12 2006 14:47:24   zf297a
/*   For the loadAll routines use all the action_codes and use the SendAllData property of the a2a_pkg in conjunction with the isPartValid and wasPartSent functions to determine if a part is sent as an A2A transaction.
/*   
/*      Rev 1.10   Mar 05 2006 14:14:38   zf297a
/*   Added amd_utils.debugMsg to record counts and procedure completion.
/*   
/*      Rev 1.9   Mar 03 2006 12:27:48   zf297a
/*   Removed function getBatchRunStart which has been replaced by amd_batch_pkg.getLastStartTime.  This will always return the last start time of the last job that has been run or is currently running.  This was data that has changed since the job started can always be sent as an A2A transaction even though it may have already been sent.  The small amount of repeat data should not be great.
/*   
/*      Rev 1.8   Feb 15 2006 14:00:46   zf297a
/*   Added cur ref, record type and a common process routine so that the data gets loaded the same no matter what selection criteria is used.
/*   
/*   
/*      Rev 1.7   Jan 04 2006 10:07:38   zf297a
/*   Made loadAllA2A and loadA2AByDate conform to the a2a_pkg.initA2A procedures.
/*   
/*      Rev 1.6   Jan 03 2006 12:45:50   zf297a
/*   Added date range to procedure loadA2AByDate
/*   
/*      Rev 1.5   Dec 29 2005 16:29:56   zf297a
/*   Added loadA2AByDate procedure
/*   
/*      Rev 1.4   Dec 15 2005 12:18:32   zf297a
/*   Added truncate of table tmp_a2a_loc_part_lead_time to LoadTmpAmdLocPartLeadtime
/*   
/*      Rev 1.3   Dec 07 2005 09:17:44   zf297a
/*   Added checks for isPartValid and wasPartSent.
/*   
/*      Rev 1.2   Dec 07 2005 08:37:56   zf297a
/*   Simplified errorMsg by making it a procedure with default values for most parameters.  Fixed loadAllA2A to ignore dup_value_on_index.
/*   
/*      Rev 1.1   Dec 06 2005 09:49:40   zf297a
/*   Fixed display of sysdate in errorMsg - changed to MM/DD/YYYY HH:MM:SS
/*   
/*      Rev 1.0   Nov 30 2005 12:40:00   zf297a
/*   Initial revision.
/*   
/*      Rev 1.0   Nov 30 2005 12:31:04   zf297a
/*   Initial revision.
*/	

	   
	PKGNAME CONSTANT VARCHAR2(50) := 'AMD_LOCATION_PART_LEADTIME_PKG' ;
		 /* cursor used for data load */	
		 /* previous spec, 0 and null same for avgRepairCycleTime from ramp */
		 /* appears for BULK COLLECT to work, cursor needs to be 
		 in column id order (i.e. cannot just qualify by field name) 
		 and all columns have to be accounted for */			
		 -- decode(nvl(GetAvgRepairCycleTime(ansi.nsn, loc_id), 0), 0, decode(IsPartRepairable(nsi_sid), 'Y', Amd_Defaults.TIME_TO_REPAIR_ONBASE, someOtherDefault ), GetAvgRepairCycleTime(ansi.nsn, loc_id)) time_to_repair,
         type locPartLeadtimeRec is record (
            part_no amd_sent_to_a2a.spo_prime_part_no%type,
            loc_sid amd_spare_networks.loc_sid%type,
            time_to_repair ramp.AVG_REPAIR_CYCLE_TIME%TYPE,
            action_code amd_spare_parts.action_code%type,
            last_update_dt amd_spare_parts.last_update_dt%type
         ) ;
         type locPartLeadtimeTab is table of locPartLeadTimeRec ;
         locPartLeadtimeRecs locPartLeadtimeTab ;
         
	    CURSOR locPartLeadtime_cur IS
		  	SELECT asta.spo_prime_part_no part_no, 
				   loc_sid, 
				   decode(nvl(GetAvgRepairCycleTime(asp.nsn, loc_id), 0), 0, Amd_Defaults.TIME_TO_REPAIR_ONBASE, GetAvgRepairCycleTime(asp.nsn, loc_id)) time_to_repair,
				   amd_defaults.INSERT_ACTION action_code,
				   sysdate last_update_dt  
		 		FROM amd_spare_parts asp, amd_sent_to_a2a asta,
					 amd_spare_networks asn
		 		WHERE asta.part_no = asta.spo_prime_part_no 
				AND asta.spo_prime_part_no = asp.part_no
				AND asta.action_code != Amd_Defaults.DELETE_ACTION
				AND asp.action_code != Amd_Defaults.DELETE_ACTION
				AND asn.action_code != Amd_Defaults.DELETE_ACTION
				AND asn.loc_type in ('MOB', 'FSL') ;
	
	
	FUNCTION IsPartRepairable(pPartNo amd_spare_parts.part_no%TYPE ) RETURN VARCHAR2 IS
	BEGIN
		RETURN IsPartRepairable(amd_utils.GetNsiSidFromPartNo(pPartNo)) ;
	EXCEPTION WHEN OTHERS THEN
		 RETURN null ;	
	END ;
	
	FUNCTION IsPartRepairable(pNsiSid amd_national_stock_items.nsi_sid%TYPE ) RETURN VARCHAR2 IS
		 ansiRow amd_national_stock_items%ROWTYPE ;
		 smr amd_national_stock_items.SMR_CODE%TYPE ; 
	BEGIN
		 SELECT * INTO ansiRow
			FROM amd_national_stock_items
		 	WHERE nsi_sid = pNsiSid ;
		 IF (ansiRow.smr_code_cleaned IS NOT NULL) THEN
		 	smr := ansiRow.smr_code_cleaned ;
		 ELSIF (ansiRow.smr_code IS NOT NULL ) THEN
		 	smr := ansiRow.smr_code ;
		 ELSE	  
		 	smr := ansiRow.smr_code_defaulted ;
		 END IF ;	
		 IF (substr(smr, 6, 1) = 'T') THEN
		 	RETURN 'Y';
		 ELSE
		 	RETURN 'N' ;
		 END IF ; 	
	EXCEPTION WHEN NO_DATA_FOUND THEN
		 RETURN null ;
	END ;			
	
	FUNCTION IsPartDeleted(pPartNo amd_sent_to_a2a.part_no%TYPE) RETURN BOOLEAN IS
		 actionCode amd_sent_to_a2a.action_code%TYPE ;
	BEGIN
		 SELECT action_code INTO actionCode
		 	 FROM amd_sent_to_a2a
		 	 WHERE  part_no = pPartNo ;
		 IF actionCode = Amd_Defaults.DELETE_ACTION THEN
		 	 RETURN true ;
		 END IF ;
		 RETURN false ;	 
	EXCEPTION WHEN NO_DATA_FOUND THEN
		 RETURN NULL ;
	END ; 			
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
					pSourceName => 'amd_location_part_leadtime_pkg',	
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
	     pKey_1 IN AMD_LOAD_DETAILS.KEY_1%TYPE,
	     pKey_2 IN AMD_LOAD_DETAILS.KEY_2%TYPE := '',
	     pKey_3 IN AMD_LOAD_DETAILS.KEY_3%TYPE := '',
	     pKey_4 IN AMD_LOAD_DETAILS.KEY_4%TYPE := '',
	     pKeywordValuePairs IN VARCHAR2 := '') IS
	  result NUMBER ;
	  key5 amd_load_details.KEY_5%type := pKeywordValuePairs ;
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
	    pData_line    => 'amd_location_part_leadtime_pkg',
	    pKey_1 => SUBSTR(pKey_1,1,50),
	    pKey_2 => SUBSTR(pKey_2,1,50),
	    pKey_3 => SUBSTR(pKey_3,1,50),
	    pKey_4 => SUBSTR(pKey_4,1,50),
	    pKey_5 =>  TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ||
	         ' ' || substr(key5,1,50),
	    pComments => SUBSTR('sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')',1,2000));
	  COMMIT;
	 END ErrorMsg;
				
	FUNCTION GetRampData(pNsn amd_nsns.nsn%TYPE, pLocSid amd_spare_networks.loc_sid%TYPE) RETURN ramp%ROWTYPE IS
		rampData ramp%ROWTYPE := null;
		locId amd_spare_networks.loc_id%TYPE;
	BEGIN
		locId := amd_utils.GetLocId(pLocSid);
		IF (locId IS null) THEN
		    RETURN rampData;
		ELSE
			RETURN GetRampData(pNsn, locId);
		END IF;
	EXCEPTION WHEN OTHERS THEN
		RETURN null ;	
	END GetRampData;
	
	
	FUNCTION GetRampData(pNsn amd_nsns.nsn%TYPE, pLocId amd_spare_networks.loc_id%TYPE) RETURN ramp%ROWTYPE IS
	    CURSOR rampData_cur (pNsn ramp.nsn%TYPE, pLocId amd_spare_networks.loc_id%TYPE) IS
			SELECT * 
			FROM
			   ramp
			WHERE
			   replace(current_stock_number, '-') = pNsn AND
			   substr(sc, 8, 6) = pLocId;
		
		rampData rampData_cur%ROWTYPE := null;
		-- though currently ramp does not RETURN more than one record, design
		-- of ramp table allows. current_stock_number IS not part of key.
		-- use explicit CURSOR just in case.
	
		BEGIN
			 IF (NOT rampData_cur%isopen) THEN
		   	 	OPEN rampData_cur(pNsn, pLocId);
			 END IF;
			 FETCH rampData_cur INTO
			    rampData;
		     CLOSE rampData_cur;
		RETURN rampData;
	END GetRampData;
	
	FUNCTION GetAvgRepairCycleTime(pNsn amd_nsns.nsn%TYPE, pLocId amd_spare_networks.loc_id%TYPE) RETURN ramp.AVG_REPAIR_CYCLE_TIME%TYPE IS
		rampData ramp%ROWTYPE ;
	BEGIN
		rampData := GetRampData(pNsn, pLocId);
		RETURN rampData.avg_repair_cycle_time ;
	END GetAvgRepairCycleTime ; 
	
	
	
	PROCEDURE UpdateAmdLocPartLeadtime (
	  		  pPartNo 			   		amd_location_part_leadtime.part_no%TYPE,
			  pLocSid 					amd_spare_networks.loc_sid%TYPE, 
			  pTimeToRepair				amd_location_part_leadtime.time_to_repair%TYPE,
			  pActionCode				amd_location_part_leadtime.action_code%TYPE,
			  pLastUpdateDt				amd_location_part_leadtime.last_update_dt%TYPE ) IS
			  returnCode NUMBER ;
	BEGIN
		 	  UPDATE amd_location_part_leadtime
			  SET 
			  	  time_to_repair 			= pTimeToRepair,
				  action_code				= pActionCode,
				  last_update_dt			= pLastUpdateDt
			  WHERE
			  	  part_no = pPartNo AND
				  loc_sid = pLocSid ;
	exception when others then
			  errorMsg(pSqlFunction => 'update',
			  		pTablename => 'amd_location_part_leadtime',
					pError_location => 10,
					pKey_1 => pPartNo, pKey_2 => to_char(pLocSid) ) ;			  
	END UpdateAmdLocPartLeadtime ;		  					   
	
	
	
	PROCEDURE InsertAmdLocPartLeadtime (
			  pPartNo 			   		amd_location_part_leadtime.part_no%TYPE,
			  pLocSid 					amd_spare_networks.loc_sid%TYPE, 
			  pTimeToRepair				amd_location_part_leadtime.time_to_repair%TYPE,
			  pActionCode				amd_location_part_leadtime.action_code%TYPE,
			  pLastUpdateDt				amd_location_part_leadtime.last_update_dt%TYPE ) IS
	BEGIN
		 INSERT INTO amd_location_part_leadtime 
		 (
		  		part_no,
				loc_sid,
				time_to_repair,
				action_code,
				last_update_dt
		 )
		 VALUES 
		 (
		  		pPartNo,
				pLocSid,
				pTimeToRepair,
				pActionCode,
				pLastUpdateDt	 
		 ) ;	
	EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
		 	  UpdateAmdLocPartLeadtime
		 	  (
	  		    pPartNo,
				pLocSid,
				pTimeToRepair,
				pActionCode,
				sysdate
		 	  ) ;	 
		  
	END InsertAmdLocPartLeadtime ;
	
	PROCEDURE InsertTmpA2A_LPLT (
				  pPartNo			VARCHAR2,
				  pBaseName			VARCHAR2,
				  pLeadtimetype		VARCHAR2, 
				  pLeadTime			NUMBER,
				  pActionCode		VARCHAR2,
				  pLastUpdateDt		DATE
				  ) IS
		returnCode NUMBER ;
		
				   procedure insertRow is
				   begin
						 INSERT INTO tmp_a2a_loc_part_lead_time (
							  part_no,
							  site_location,
							  lead_time_type,
							  lead_time,
							  action_code,
							  last_update_dt
						 )	  
						 VALUES
						 (	
						 	  pPartNo,
							  pBaseName,
							  pLeadtimetype,
							  pLeadTime,
							  pActionCode,
							  pLastUpdateDt		 	
						 ) ;
				   end insertRow ;		  
	BEGIN
		BEGIN
			 if pActionCode = amd_defaults.INSERT_ACTION
			 or pActionCode = amd_defaults.DELETE_ACTION then
				 if a2a_pkg.isPartValid(pPartNo) 
				 and a2a_pkg.wasPartSent(pPartNo) then -- part must exist in amd_sent_to_a2a with action_code <> DELETE_ACTION
				 	 insertRow ;
				end if ;
			else
				if a2a_pkg.isPartSent(pPartNo) then -- part must exist in amd_sent_to_a2a with any action_code
				   insertRow ;
				end if ;
			end if ;
			
		EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
				begin
					UPDATE tmp_a2a_loc_part_lead_time
					SET	   lead_time_type = pLeadtimetype,
						   lead_time	  = pLeadTime,
						   action_code	  = pActionCode,
					   	   last_update_dt = pLastUpdateDt 
					WHERE
						   part_no 		  = pPartNo AND
						   site_location  = pBaseName ;
				exception when others then
						  errorMsg(pSqlFunction => 'update', pTablename => 'tmp_a2a_loc_part_lead_time', 
						  		pError_location => 20, pKey_1 => pPartNo, pKey_2 => pBaseName) ;
				end ;
		END ;	 
	 
	END InsertTmpA2A_LPLT ;
	
	/*  
		-------------------------------------------------------------
		InsertRow, UpdateRow, DeleteRow called From Java diff program
		-------------------------------------------------------------	 
	*/
	
	FUNCTION InsertRow(
			pPartNo                      amd_location_part_leadtime.part_no%TYPE,
			pLocSid                      amd_location_part_leadtime.loc_sid%TYPE,
			pTimeToRepair				 amd_location_part_leadtime.time_to_repair%TYPE)
			RETURN NUMBER IS
			returnCode NUMBER ;		
	BEGIN
		 BEGIN
		 	  InsertAmdLocPartLeadtime
			  (
		  	   	pPartNo,
				pLocSid,
				pTimeToRepair,
				Amd_Defaults.INSERT_ACTION,
				sysdate
		 	  ) ;	
		 EXCEPTION WHEN OTHERS THEN
		 		   ErrorMsg( pSqlfunction => 'insert',
					   pTableName  	  	  => 'amd_location_part_leadtime',
					   pError_location 	  => 20,
					   pKey_1			  => pPartNo,
		   			   pKey_2			  => pLocSid) ;
				   RAISE ;	  
		 END ;	  	
		 
		 BEGIN
		 	  --
		 	  -- decode(IsPartRepairable(pPartNo),'Y', LEADTIMETYPE, LEADTIMETYPE_CONSUM) 
			  --  	
		 	  InsertTmpA2A_LPLT 
			  (
			      pPartNo,
				  amd_utils.GetSpoLocation(pLocSid),
				  LEADTIMETYPE, 
				  pTimeToRepair,
				  Amd_Defaults.INSERT_ACTION,
				  sysdate
			  ) ;
		 EXCEPTION WHEN OTHERS THEN
		 		ErrorMsg(pSqlfunction 	  => 'insert',
					   pTableName  	  	  =>'tmp_a2a_loc_part_lead_time',
					   pError_location 	  => 30,
					   pKey_1			  => pPartNo,
		   			   pKey_2			  => pLocSid) ;
			  	RAISE ;		   					  			  
		 END ;
	 	 RETURN SUCCESS ;
	EXCEPTION WHEN OTHERS THEN
		 RETURN FAILURE ;
	END InsertRow ;		
			
	
			
	FUNCTION UpdateRow(
			pPartNo                      amd_location_part_leadtime.part_no%TYPE,
			pLocSid                      amd_location_part_leadtime.loc_sid%TYPE,
			pTimeToRepair				 amd_location_part_leadtime.time_to_repair%TYPE)		RETURN NUMBER IS
			returnCode NUMBER ;
	BEGIN
		 BEGIN
		 	  UpdateAmdLocPartLeadtime
		 	  (
	  		    pPartNo,
				pLocSid,
				pTimeToRepair,
				Amd_Defaults.UPDATE_ACTION,
				sysdate 
		 	  ) ;
			 
		EXCEPTION WHEN OTHERS THEN
				  ErrorMsg(
				   pSqlfunction 	  	  => 'update',
				   pTableName  	  	  =>'amd_location_part_leadtime',
				   pError_location 	  => 40,
				   pKey_1			  => pPartNo,
	   			   pKey_2			  => pLocSid) ;
				   RAISE ;		
		 END ;
		 BEGIN
	 	  InsertTmpA2A_LPLT 
			  (
			      pPartNo,
				  amd_utils.GetSpoLocation(pLocSid),
				  LEADTIMETYPE, 
				  pTimeToRepair,
				  Amd_Defaults.UPDATE_ACTION,
				  sysdate
			  ) ;
		 EXCEPTION WHEN OTHERS THEN
		 		 ErrorMsg(
				   pSqlfunction 	  	  => 'insert',
				   pTableName  	  	  =>'tmp_a2a_loc_part_lead_time',
				   pError_location 	  => 50,
				   pKey_1			  => pPartNo,
	   			   pKey_2			  => pLocSid) ;
			  	RAISE ;	
		 END ;	  
		 RETURN SUCCESS ; 	  
	EXCEPTION WHEN OTHERS THEN
		 RETURN FAILURE ;		   
	END UpdateRow ;		
	
	
	
	FUNCTION DeleteRow(
			pPartNo                      amd_location_part_leadtime.part_no%TYPE,
			pLocSid                      amd_location_part_leadtime.loc_sid%TYPE,
			pTimeToRepair				 amd_location_part_leadtime.time_to_repair%TYPE)		RETURN NUMBER IS
			returnCode NUMBER ;
	BEGIN
		 BEGIN
		 	  UpdateAmdLocPartLeadtime
			  (
		  	   	pPartNo,
				pLocSid,
				pTimeToRepair,
				Amd_Defaults.DELETE_ACTION,
				sysdate
		 	  ) ;
		 EXCEPTION WHEN OTHERS THEN
		 		 ErrorMsg(pSqlFunction => 'update',
				   pTableName  	  	  =>'amd_location_part_leadtime',
				   pError_location 	  => 60,
				   pKey_1			  => pPartNo,
	   			   pKey_2			  => pLocSid) ;
				   RAISE ;		
		 END ;	  	
		 
		 BEGIN
		 /*
		 	  "Deletion of Parts,  No parts are physically deleted from the data system or SPO, it is all logically deleted.  
			  In that case the only thing you have to do is send a delete  transaction in for the part 
			  and we will set the end_date and set the planned_flag to 'F'
	
			  All child records for the deleted part will not be used because the parent is "logically deleted".
	
			  -- multi deletes can cause error and a delete action when the part is already deleted.
			  -- only send when location has been deleted.
		 */	  
		-- 	  IF (NOT IsPartDeleted(pPartNo) ) THEN
		 	 	  InsertTmpA2A_LPLT 
		 		  (
		 		      pPartNo,
		 			  amd_utils.GetSpoLocation(pLocSid),
		 			  LEADTIMETYPE, 
		 			  pTimeToRepair,
		 			  Amd_Defaults.DELETE_ACTION,
		 			  sysdate
		 		  ) ;
		--	  END IF ;		  
		 EXCEPTION WHEN OTHERS THEN
		 		 ErrorMsg(
				   pSqlFunction 	  => 'InsertTmpA2A_LPLT',
				   pTableName  	  	  =>'tmp_a2a_loc_part_lead_time',
				   pError_location 	  => 70,
				   pKey_1			  => pPartNo,
	   			   pKey_2			  => pLocSid) ;
			  	RAISE ;	
		 END ;
		 RETURN SUCCESS ;
	EXCEPTION WHEN OTHERS THEN	 
	   	 RETURN FAILURE ;
	END DeleteRow ;		
	
		procedure processData(rec in locationPartLeadTimeRec) is
				  procedure doUpdate is
				  begin
				  	   update tmp_a2a_loc_part_lead_time
					   set lead_time_type = rec.lead_time_type,
					   lead_time = rec.time_to_repair,
					   action_code = rec.action_code,
					   last_update_dt = sysdate
					   where part_no = rec.part_no
					   and site_location = rec.site_location ;
				  exception when others then
				       ErrorMsg(pSqlfunction => 'update',
					     pTableName => 'tmp_a2a_loc_part_lead_time', pError_location => 80,
					     pKey_1 => rec.part_no, pKey_2 => rec.site_location) ;
				       RAISE ;
				  end doUpdate ;
		begin
		 	insert into tmp_a2a_loc_part_lead_time
			 	 		(part_no,lead_time_type, lead_time, action_code, 
						 last_update_dt,site_location )
			values (rec.part_no, rec.lead_time_type, rec.time_to_repair, rec.action_code, 
				   sysdate, rec.site_location) ;
			
		   exception 
			  when standard.DUP_VAL_ON_INDEX then
			   doUpdate ;
			  when others then
		       ErrorMsg(pSqlfunction => 'insert',
		     pTableName => 'tmp_a2a_loc_part_lead_time',
		     pError_location => 90,
		     pKey_1 => rec.part_no, pKey_2 => rec.site_location) ;
		       RAISE ;
		end processData ;
		
		procedure processLocPartLeadtime(locPartLeadTime in locPartLeadTimeCur) is
				  cnt number := 0 ;
				  rec locationPartLeadTimeRec ;
                  locationPartLeadTimeRecs locationPartLeadTimeTab ;
		begin
			 writeMsg(pTableName => 'tmp_a2a_loc_part_lead_time', pError_location => 100,
					pKey1 => 'processLocPartLeadTime started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS')) ;
             fetch locPartLeadTime bulk collect into locationPartLeadTimeRecs ;
             close locPartLeadTime ;
             
             if locationPartLeadTimeRecs.first is not null then
                for indx in locationPartLeadTimeRecs.first .. locationPartLeadTimeRecs.last                    
                 loop
                     processData(locationPartLeadTimeRecs(indx));
                     cnt := cnt + 1 ;			 
                 end loop ;
            end if ;           
	
			 writeMsg(pTableName => 'tmp_a2a_loc_part_lead_time', pError_location => 110,
					pKey1 => 'Rows processed = ' || cnt,
					pKey2 => 'processLocPartLeadTime ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS')) ;
			 commit ;
		end ;
		
		procedure loadA2AByDate (from_dt in date := a2a_pkg.start_dt, to_dt in date := sysdate) is
			dataByDate locPartLeadTimeCur ;
		begin
			 writeMsg(pTableName => 'tmp_a2a_loc_part_lead_time', pError_location => 120,
					pKey1 => 'loadA2AByDate(' || from_dt || ',' || to_dt || ') started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS')) ;
					
			 Mta_Truncate_Table('tmp_a2a_loc_part_lead_time','reuse storage');
			 a2a_pkg.setSendAllData(true) ;
			 open dataByDate for
			 	 SELECT
				 	  distinct	 
			 	      part_no,			  
					  LEADTIMETYPE lead_time_type, 
					  time_to_repair,
					  action_code,
					  sysdate,
					  amd_utils.GetSpoLocation(loc_sid) site_location
				 FROM
				 	  amd_location_part_leadtime 
				 WHERE 
					  trunc(last_update_dt) between trunc(from_dt) and trunc(to_dt) 
		  			  AND part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A where spo_prime_part_no is not null);
			 processLocPartLeadTime(dataByDate) ;
	
			 writeMsg(pTableName => 'tmp_a2a_loc_part_lead_time', pError_location => 130,
					pKey1 => 'loadA2AByDate(' || from_dt || ',' || to_dt || ') ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS')) ;
		end loadA2AByDate ;
		
		PROCEDURE LoadAllA2A(useTestParts in boolean := false) IS
			locPartLeadTime locPartLeadTimeCur ;		  		   		
			
			useTestPartsString varchar2(5) := 'False' ;
			
			
		begin
			 writeMsg(pTableName => 'tmp_a2a_loc_part_lead_time', pError_location => 140,
					pKey1 => 'loadAllA2A(' || useTestPartsString || ') started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS')) ;
	
			 Mta_Truncate_Table('tmp_a2a_loc_part_lead_time','reuse storage');
			 a2a_pkg.setSendAllData(true) ;
			 if useTestParts then
			 	useTestPartsString := 'True' ;
			    open locPartLeadTime for
			 	 SELECT
				 	  distinct	 
			 	      part_no,			  
					  LEADTIMETYPE lead_time_type, 
					  time_to_repair,
					  action_code,
					  sysdate,
					  amd_utils.GetSpoLocation(loc_sid) site_location
				 FROM
				 	  amd_location_part_leadtime 
				 WHERE 
					  part_no in (select part_no from amd_test_parts)
		  			  AND part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A where spo_prime_part_no is not null 
                            and action_code <> amd_defaults.getDELETE_ACTION) ;
			 else
			 	 open locPartLeadTime for
				 	 SELECT
					 	  distinct	 
				 	      part_no,			  
						  LEADTIMETYPE lead_time_type, 
						  time_to_repair,
						  action_code,
						  sysdate,
						  amd_utils.GetSpoLocation(loc_sid) site_location
					 FROM
					 	  amd_location_part_leadtime 
					 WHERE 
			  			  part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A where spo_prime_part_no is not null
                                        and action_code <> amd_defaults.getDELETE_ACTION);
				 
			 end if ;
			 processLocPartLeadTime(locPartLeadTime) ;
	
			 writeMsg(pTableName => 'tmp_a2a_loc_part_lead_time', pError_location => 150,
					pKey1 => 'loadAllA2A(' || useTestPartsString || ') ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS')) ;
		     commit ;
		end loadAllA2a ;		  	
					
	PROCEDURE LoadTmpAmdLocPartLeadtime IS
		  returnCode NUMBER ;
	BEGIN
		mta_truncate_table('tmp_amd_location_part_leadtime','reuse storage');
		mta_truncate_table('tmp_a2a_loc_part_lead_time','reuse storage');
        
		OPEN locPartLeadtime_cur ;
        fetch locPartLeadTime_cur bulk collect into locPartLeadTimeRecs ;
        close locPartLeadTime_cur ;
        
        if locPartLeadTimeRecs.first is not null then    	
            FORALL indx IN locPartLeadTimeRecs.first ..locPartLeadTimeRecs.last -- SAVE EXCEPTIONS
                   INSERT INTO tmp_amd_location_part_leadtime
                   VALUES locPartLeadTimeRecs(indx) ;
            COMMIT ;
        end if ;            
	EXCEPTION WHEN OTHERS THEN
			  ErrorMsg(
				   pSqlFunction 	  	  => 'forall insert',
				   pTableName  	  	  =>'tmp_amd_location_part_leadtime',
				   pError_location 	  => 160,
				   pKey_1 => 'failed') ;
			 raise ;
	END ;	
	
	PROCEDURE LoadAmdLocPartLeadtime IS
		-- defaultTimeToRepair tmp_amd_location_part_leadtime.time_to_repair_defaulted%TYPE := amd_defaults.TIME_TO_REPAIR_ONBASE ;
		 returnCode NUMBER ;
	BEGIN
		mta_truncate_table('amd_location_part_leadtime','reuse storage');
		
		OPEN locPartLeadtime_cur;
        fetch locPartLeadTime_cur bulk collect into locPartLeadTimeRecs ;
        close locPartLeadTime_cur ;
        
        if locPartLeadTimeRecs.first is not null then	
	    	FORALL indx IN locPartLeadTimeRecs.first .. locPartLeadTimeRecs.last -- SAVE EXCEPTIONS
	    	   INSERT INTO amd_location_part_leadtime
			   VALUES locPartLeadTimeRecs(indx) ;
    		COMMIT ;
        end if ;            
	EXCEPTION WHEN OTHERS THEN
			  ErrorMsg(
				   pSqlFunction 	=> 'forall insert',
				   pTableName  	  	  =>'amd_location_part_leadtime',
				   pError_location 	  => 170,
				   pKey_1		  => 'load bulk insert') ;
			 raise ;
	END ;	  		
	  		
	
	PROCEDURE LoadInitial IS
	BEGIN
		 LoadTmpAmdLocPartLeadtime ;
		 LoadAmdLocPartLeadtime ;
		 LoadAllA2A(false) ;
	END ;

	procedure version is
	begin
		 writeMsg(pTableName => 'amd_location_part_leadtime_pkg', 
		 		pError_location => 180, pKey1 => 'amd_location_part_leadtime_pkg', pKey2 => '$Revision:   1.21  $') ;
		 	 dbms_output.put_line('amd_location_part_leadtime_pkg: $Revision:   1.21  $') ;		 
	end version ;

    function getVersion return varchar2 is
    begin
        return '$Revision:   1.21  $' ;
    end getVersion ;
    
	-- added get functions to return constants 10/25/2006 by dse
	function getVIRTUAL_COD_SPO_LOCATION return amd_spare_networks.spo_location%type is
	begin
		 return VIRTUAL_COD_SPO_LOCATION ;
	end getVIRTUAL_COD_SPO_LOCATION ;
	
	function getVIRTUAL_UAB_SPO_LOCATION return amd_spare_networks.spo_location%type is
	begin
		 return VIRTUAL_UAB_SPO_LOCATION ;
	end getVIRTUAL_UAB_SPO_LOCATION ;
	
	function getUK_LOCATION 			 return amd_spare_networks.LOC_ID%type is
	begin
		 return UK_LOCATION ;
	end getUK_LOCATION ;
	
	function getBASC_LOCATION			 return amd_spare_networks.LOC_ID%type is
	begin
		 return BASC_LOCATION ;
	end getBASC_LOCATION ;
	 	
	function getLEADTIMETYPE 			 return tmp_a2a_loc_part_lead_time.LEAD_TIME_TYPE%type is
	begin
		 return LEADTIMETYPE ;
	end getLEADTIMETYPE ;
	
	function getBULKLIMIT 	 		  	 return number is
	begin
		 return BULKLIMIT ;
	end getBULKLIMIT ;
	
END AMD_LOCATION_PART_LEADTIME_PKG ;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_LOCATION_PART_LEADTIME_PKG;

CREATE PUBLIC SYNONYM AMD_LOCATION_PART_LEADTIME_PKG FOR AMD_OWNER.AMD_LOCATION_PART_LEADTIME_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_LOCATION_PART_LEADTIME_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_LOCATION_PART_LEADTIME_PKG TO AMD_WRITER_ROLE;


