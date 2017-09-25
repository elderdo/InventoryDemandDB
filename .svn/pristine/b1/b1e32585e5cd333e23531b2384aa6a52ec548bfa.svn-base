set define off

DROP PACKAGE AMD_OWNER.AMD_PART_FACTORS_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.AMD_PART_FACTORS_PKG AS

 /*
      $Author:   zf297a  $
	$Revision:   1.1  $
        $Date:   16 Oct 2007 17:21:40  $
    $Workfile:   amd_part_factors_pkg.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Scripts\AMD 2.0 Implementation\amd_part_factors_pkg.sql.-arc  $
/*   
/*      Rev 1.1   16 Oct 2007 17:21:40   zf297a
/*   Fixed literal being written out by the version procedure
/*   
/*      Rev 1.3   Jun 09 2006 12:02:52   zf297a
/*   added interface version
/*   
/*      Rev 1.2   Jan 03 2006 13:03:18   zf297a
/*   Added date range to procedure loadA2AByDate
/*   
/*      Rev 1.1   Jan 03 2006 08:07:42   zf297a
/*   Added procedure loadA2AByDate
/*
/*      Rev 1.0   Oct 31 2005 08:04:54   zf297a
/*   Initial revision.
*/

	DEFAULT_WHSE_COND CONSTANT NUMBER := .005 ;
	CRITICALITY_REPAIRABLE_DEFAULT	CONSTANT amd_national_stock_items.criticality%TYPE := .5 ;
		--  consumable not defined yet, placeholder for when defined
	CRITICALITY_CONSUMABLE_DEFAULT	CONSTANT amd_national_stock_items.criticality%TYPE :=  0 ;
	
		-- calcs done to 4 decimal places
	DP CONSTANT NUMBER := 4 ;
	COMMITAFTER CONSTANT NUMBER := 100000 ;
	SUCCESS		CONSTANT NUMBER := 0 ;
	FAILURE		CONSTANT NUMBER := 4 ;
	
	
	
	
	PROCEDURE LoadTmpAmdPartFactors ;
	PROCEDURE ProcessA2AVirtualLocs ;
	PROCEDURE ProcessA2AVirtualLocs( pDoAllA2A boolean, pVirtSpoLocation amd_spare_networks.LOC_ID%TYPE ) ;
	PROCEDURE LoadInitial ;
	PROCEDURE LoadAllA2A ;
	procedure loadA2AByDate(from_dt in date := a2a_pkg.start_dt, to_dt in date := sysdate) ;
	
	
	
	
	/* current spec says to send a auto default nrts, rts, cond to vub, vcd, basc,
	   others - mob, fsl, ctlatl, uk will use #'s from best spares.
	   Below function will have to be maintained at this point for which
	   locations are autodefaulted and which are not */
	FUNCTION IsAutoDefaulted(pLocRow amd_spare_networks%ROWTYPE ) RETURN boolean ;
	
	FUNCTION InsertRow(
			pPartNo                      amd_part_factors.part_no%TYPE,
			pLocSid                      amd_part_factors.loc_sid%TYPE,
			pPassUpRate					 amd_part_factors.pass_up_rate%TYPE ,
			pRts						 amd_part_factors.rts%TYPE ,
			pCmdmdRate					 amd_part_factors.cmdmd_rate%TYPE ,
			pCriticality				 amd_national_stock_items.criticality%TYPE,
			pCriticalityChanged			 amd_national_stock_items.criticality_changed%TYPE,
			pCriticalityCleaned			 amd_national_stock_items.criticality_cleaned%TYPE )
			return NUMBER ;
	
	FUNCTION UpdateRow(
			pPartNo                      amd_part_factors.part_no%TYPE,
			pLocSid                      amd_part_factors.loc_sid%TYPE,
			pPassUpRate					 amd_part_factors.pass_up_rate%TYPE ,
			pRts						 amd_part_factors.rts%TYPE ,
			pCmdmdRate					 amd_part_factors.cmdmd_rate%TYPE ,
			pCriticality				 amd_national_stock_items.criticality%TYPE,
			pCriticalityChanged			 amd_national_stock_items.criticality_changed%TYPE,
			pCriticalityCleaned			 amd_national_stock_items.criticality_cleaned%TYPE )							RETURN NUMBER ;
	
	
	FUNCTION DeleteRow(
			pPartNo                      amd_part_factors.part_no%TYPE,
			pLocSid                      amd_part_factors.loc_sid%TYPE,
			pPassUpRate					 amd_part_factors.pass_up_rate%TYPE ,
			pRts						 amd_part_factors.rts%TYPE ,
			pCmdmdRate					 amd_part_factors.cmdmd_rate%TYPE ,
			pCriticality				 amd_national_stock_items.criticality%TYPE,
			pCriticalityChanged			 amd_national_stock_items.criticality_changed%TYPE,
			pCriticalityCleaned			 amd_national_stock_items.criticality_cleaned%TYPE )		RETURN NUMBER ;
	
	FUNCTION GetRepairIndicator(pNsn bssm_base_parts.nsn%TYPE, pSran bssm_base_parts.sran%TYPE, pLockSid bssm_locks.LOCK_SID%TYPE) RETURN VARCHAR2 ;
	pragma restrict_references(GetRepairIndicator, WNDS) ;
	
	-- added 6/9/2006 by dse
	procedure version ;



END AMD_PART_FACTORS_PKG ;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_PART_FACTORS_PKG;

CREATE PUBLIC SYNONYM AMD_PART_FACTORS_PKG FOR AMD_OWNER.AMD_PART_FACTORS_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_PART_FACTORS_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_PART_FACTORS_PKG TO AMD_WRITER_ROLE;


DROP PACKAGE BODY AMD_OWNER.AMD_PART_FACTORS_PKG;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.AMD_PART_FACTORS_PKG AS

 /*
      $Author:   zf297a  $
	$Revision:   1.1  $
        $Date:   16 Oct 2007 17:21:40  $
    $Workfile:   amd_part_factors_pkg.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_PART_FACTORS_PKG.pkb.-arc  $
/*   
/*      Rev 1.9   16 Oct 2007 17:16:00   zf297a
/*   Fixed literal being written out by the version procedure
/*   
/*      Rev 1.8   12 Sep 2007 15:37:10   zf297a
/*   Removed commits from for loops.
/*   
/*      Rev 1.7   Nov 28 2006 14:54:58   zf297a
/*   fixed insertTmpA2A_PF - for INSERT_ACTION or UPDATE_ACTION check to see if the part is in amd_sent_to_a2a with action_code <> DELETE_ACTION then insert it into tmp_a2a_part_factors.  For DELETE_ACTION's check to see if the part is in amd_sent_to_a2a with any action_code then insert it into tmp_a2a_part_factors.
/*   
/*      Rev 1.6   Jun 09 2006 12:03:06   zf297a
/*   implemented interface version
/*   
/*      Rev 1.5   Mar 03 2006 12:38:32   zf297a
/*   removed amd_location_part_leadtime_pkg.getBatchRunStart and replaced it with amd_batch_pkg.getLastStartTime, which will always return the start time of the last job regardless of whether it has completed or not.  This allows the procedures that select a2a data to be run even if the batch job has completed.  Only the data that has changed since the batch job started will be sent.  This should only be a small amount of data.
/*   
/*      Rev 1.4   Jan 03 2006 13:03:18   zf297a
/*   Added date range to procedure loadA2AByDate
/*   
/*      Rev 1.3   Jan 03 2006 08:07:42   zf297a
/*   Added procedure loadA2AByDate
/*   
/*      Rev 1.2   Dec 16 2005 08:49:30   zf297a
/*   Added truncate of tmp_a2a_part_factors table when tmp_amd_part_factors is loaded.
/*   
/*      Rev 1.1   Dec 06 2005 10:30:26   zf297a
/*   Fixed display of sysdate in errorMsg - changed to MM/DD/YYYY HH:MM:SS
/*   
/*      Rev 1.0   Oct 31 2005 08:04:54   zf297a
/*   Initial revision.
*/


	PKGNAME CONSTANT VARCHAR2(30) := 'AMD_PART_FACTORS_PKG' ;
	
	TYPE mtd_rec IS RECORD (
		 rts NUMBER,
		 nrts NUMBER,
		 condemn NUMBER
	) ;
	
	
	
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
				pSourceName => 'amd_part_factors_pkg',	
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
				pSourceName in amd_load_status.SOURCE%TYPE,
				pTableName in amd_load_status.TABLE_NAME%TYPE,
				pError_location in amd_load_details.DATA_LINE_NO%TYPE,
				pReturn_code in number,			
				pKey1 in varchar2 := '',
				pKey2 in varchar2 := '',
				pKey3 in varchar2 := '',
				pData in varchar2 := '',
				pComments in varchar2 := '') RETURN number IS
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
				pKey_5 => to_char(sysdate,'MM/DD/YYYY HH:MM:SS'),
				pComments => 'sqlcode('||sqlcode||') sqlerrm('||sqlerrm||') ' || pComments);
		COMMIT;
		RETURN pReturn_code;
	END ;
	
	
	
	
	
	
	FUNCTION DefaultMtdToDataSys(pLocId amd_spare_networks.LOC_ID%TYPE )
			 RETURN mtd_rec IS
			 retRec mtd_rec ;
	BEGIN
			 retRec.rts := 0 ;
	 		 retRec.nrts := 0 ;
	 		 retRec.condemn := 0 ;
			 IF (pLocId = amd_defaults.AMD_WAREHOUSE_LOCID) THEN
			 	retRec.condemn := DEFAULT_WHSE_COND ;
			 ELSE
			 	retRec.nrts := 1 ; 
			 END IF ;		 	 
			 RETURN retRec ;
	END ;
	
	FUNCTION GetCriticalityFromSubs(pSpoPrimePartNo amd_sent_to_a2a.spo_prime_part_no%TYPE)
		RETURN	amd_national_stock_items.CRITICALITY%TYPE IS
		CURSOR cur IS
	 		   SELECT criticality_cleaned, criticality
				FROM amd_sent_to_a2a asta, amd_national_stock_items ansi
				WHERE
				spo_prime_part_no = pSpoPrimePartNo
				AND part_no != spo_prime_part_no
				AND ansi.prime_part_no = part_no 
				AND asta.action_code != Amd_Defaults.DELETE_ACTION
				AND ansi.action_code != Amd_Defaults.DELETE_ACTION ;
		retCrit amd_national_stock_items.CRITICALITY%TYPE := null ;		
		SubHasCritOfOne boolean := false ;		
	BEGIN
		FOR rec IN cur
		LOOP
			IF ( amd_preferred_pkg.GetPreferredValue(rec.criticality_cleaned, rec.criticality) = 1 ) THEN
			   SubHasCritOfOne := true ;
			END IF ;
		END LOOP ; 
		IF ( SubHasCritOfOne ) THEN
		   RETURN 1 ;
		ELSE 
		   RETURN null ;
		END IF ;
	END ;
	
	FUNCTION CorrectCriticality(pCrit amd_national_stock_items.CRITICALITY%TYPE) 
		RETURN amd_national_stock_items.CRITICALITY%TYPE IS	
	BEGIN
		IF (pCrit IS NULL ) THEN
		   RETURN null ;
		ELSIF ( pCrit <= 0 ) THEN
		   RETURN 0 ;
		ELSIF ( pCrit > 0 AND pCrit <= .1) THEN
		   RETURN .1 ;
		ELSIF ( pCrit > .1 AND pCrit <= .5) THEN  
		   RETURN .5 ;
		ELSIF ( pCrit > .5 ) THEN
		   RETURN 1 ;
		END IF ;
	END ;	
	
	FUNCTION DetermineCriticality(pCrit amd_national_stock_items.CRITICALITY%TYPE, 
			 					  pPartNo amd_spare_parts.part_no%TYPE ) 
		RETURN amd_national_stock_items.CRITICALITY%TYPE IS
		retCrit amd_national_stock_items.CRITICALITY%TYPE := null ;
	BEGIN
		 IF ( pCrit IS NULL ) THEN
		 	 retCrit := GetCriticalityFromSubs(pPartNo) ;
		 	 IF ( retCrit IS NOT NULL ) THEN
			 	RETURN correctCriticality(retCrit) ;
			 ELSIF (amd_location_part_leadtime_pkg.IsPartRepairable(pPartNo) = 'Y') THEN
			 	RETURN CRITICALITY_REPAIRABLE_DEFAULT ;
			 ELSE
			 	RETURN CRITICALITY_CONSUMABLE_DEFAULT ;
			 END IF ;		 	
		 ELSE
		 	 RETURN correctCriticality(pCrit) ;
		 END IF ;
	END ;	
	
	
	
	FUNCTION DetermineCriticality(pCrit amd_national_stock_items.CRITICALITY%TYPE, 
			 					  pNsiSid amd_national_stock_items.nsi_sid%TYPE ) 
		RETURN amd_national_stock_items.CRITICALITY%TYPE IS
		primePartNo amd_national_stock_items.prime_part_no%TYPE := null ;
	BEGIN
		IF ( pCrit IS NULL ) THEN 
			SELECT prime_part_no INTO primePartNo
				FROM amd_national_stock_items
				WHERE action_code != Amd_Defaults.DELETE_ACTION
				AND nsi_sid = pNsiSid ;
				RETURN DetermineCriticality(pCrit, primePartNo) ;
		ELSE 
			RETURN pCrit ;
		END IF ;			
	EXCEPTION WHEN OTHERS THEN
		RETURN null ; 
	END ;	
	
	/* current spec says to send a default nrts, rts, cond to vub, vcd, basc,
	   others - mob, fsl, ctlatl, uk will use #'s from best spares.
	   Below will have to be maintained */
	FUNCTION IsAutoDefaulted(pLocRow amd_spare_networks%ROWTYPE ) 
			 RETURN boolean IS		 
	 BEGIN	
		 IF ( pLocRow.loc_id NOT IN (Amd_Defaults.AMD_WAREHOUSE_LOCID, Amd_Defaults.AMD_UK_LOC_ID) 
		 	AND pLocRow.loc_type NOT IN ('FSL', 'MOB' ) ) THEN 	 
			 RETURN true ;
		 ELSE
		 	 RETURN false ;
		 END IF ;
	EXCEPTION WHEN NO_DATA_FOUND THEN
		 RETURN true ;
	END ;
	
	FUNCTION AutoDefaultMtd
			 RETURN mtd_rec IS
			 retMtdRec mtd_rec ;
	BEGIN
		 	 retMtdRec.nrts := 1 ;
			 retMtdRec.rts := 0 ;
			 retMtdRec.condemn := 0 ;	 
			 RETURN retMtdRec ;
	END ;
		
	FUNCTION ConvertMtdToDataSys (pLocId amd_spare_networks.LOC_ID%TYPE, pCapabilityLevel VARCHAR2, pRepairInd VARCHAR2, pNrts NUMBER, pRts NUMBER, pCondemn NUMBER) 
			 RETURN mtd_rec IS
			 retRec mtd_rec ;
			 tot NUMBER ;
	BEGIN
		 	
			 retRec.rts := ROUND(nvl(pRts, 0), DP) ;
	 		 retRec.nrts := ROUND(nvl(pNrts, 0), DP) ;
	 		 retRec.condemn := ROUND(nvl(pCondemn, 0), DP) ;
	
		  	 tot := retRec.rts + retRec.nrts + retRec.condemn ;
			  	
				
		 	 IF (tot = 0 OR retRec.rts < 0 OR retRec.nrts < 0 OR retRec.condemn < 0 ) THEN
			 	 RETURN DefaultMtdToDataSys(pLocId) ;
			 END IF ;	
			 	 /* normalize */		 	 
			 IF (tot != 1) THEN
				 retRec.rts := ROUND(retRec.rts/tot, DP) ;
				 retRec.nrts := ROUND(retRec.nrts/tot, DP) ;
		 		 retRec.condemn := ROUND(retRec.condemn/tot, DP) ;
			 END IF ;
			 IF ( pLocId = amd_defaults.AMD_WAREHOUSE_LOCID ) THEN
			 	-- double check w/Dave if rts = 1 
			 	IF (retRec.rts = 1) THEN
				   retRec.condemn := 0 ;
				ELSE
			 		retRec.condemn := ROUND(retRec.condemn/(1 - retRec.rts), DP) ;
				END IF ;	
			  	retRec.rts := 0 ;
				retRec.nrts := 0 ;			
				/* not warehouse */
			 ELSIF ( nvl(pCapabilityLevel, 'notO') = '0' AND nvl(pRepairInd, 'Y') = 'Y' )THEN
			 	retRec.nrts := 1 - retRec.rts ;
				retRec.condemn := 0 ;
			 ELSE	 
			 	retRec.nrts := 1 ;
				retRec.condemn := 0 ;
				retRec.rts := 0 ;
			 END IF ;
			 RETURN retRec ;
	END ConvertMtdToDataSys ;		 
	
	
	PROCEDURE  InsertTmpA2A_PF (
	   			      pPartNo   		   VARCHAR2,
					  pBaseName 		   VARCHAR2, 
					  pMtbdr			   NUMBER, 
					  pMttr				   NUMBER,
					  pPassUpRate		   NUMBER, 
					  pRts				   NUMBER,
					  pCmdmdRate 		   NUMBER,								 
					  pCriticalityCode	   NUMBER,
					  pActionCode 		   VARCHAR2, 
					  pLastUpdateDt 	   DATE ) IS
					  
				procedure insertRow is
				begin
					INSERT INTO tmp_a2a_part_factors (
							   part_no,
							   base_name,
							   mtbdr,
							   mttr,
							   nrts,
							   rts,				   
							   cmdmd_rate,
							   criticality_code,
							   action_code,
							   last_update_dt		
					)
					VALUES
				    (
					 	  	  pPartNo,
							  pBaseName,  
							  pMtbdr, 
							  pMttr,
							  pPassUpRate, 
							  pRts, 
							  pCmdmdRate,								 
							  pCriticalityCode,
							  pActionCode, 
							  pLastUpdateDt 
						 	  
					);
				end insertRow ;
	BEGIN
		BEGIN
			if pActionCode = amd_defaults.INSERT_ACTION
			or pActionCode = amd_defaults.UPDATE_ACTION then 
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
			UPDATE tmp_a2a_part_factors
			SET	   
				   mtbdr 	= pMtbdr,
				   mttr		= pMttr,
				   rts		= pRts,
				   nrts		= pPassUpRate,
				   cmdmd_rate = pCmdmdRate,
				   criticality_code = pCriticalityCode,
				   action_code		= pActionCode,
				   last_update_dt	= pLastUpdateDt
			WHERE
				   part_no 			= pPartNo 	   AND
				   base_name		= pBaseName	  ;
		END ;	
	END InsertTmpA2A_PF;		
		
	
	PROCEDURE UpdateAmdPartFactors (
	  			pPartNo                      amd_part_factors.part_no%TYPE,
				pLocSid                      amd_part_factors.loc_sid%TYPE,
				pPassUpRate					 amd_part_factors.pass_up_rate%TYPE ,
				pRts						 amd_part_factors.rts%TYPE ,										
				pCmdmdRate					 amd_part_factors.cmdmd_rate%TYPE ,
		  	    pActionCode					 amd_part_factors.action_code%TYPE ,
		  	    pLastUpdateDt				 amd_part_factors.last_update_dt%TYPE ) IS
	
	BEGIN
		 	  UPDATE amd_part_factors
			  SET 
			  	  pass_up_rate		 		= pPassUpRate,
				  rts						= pRts,
				  cmdmd_rate				= pCmdmdRate,
			  	  action_code				= pActionCode,
				  last_update_dt			= pLastUpdateDt
			  WHERE
			  	  part_no = pPartNo AND
				  loc_sid = pLocSid ;
	END UpdateAmdPartFactors ;		  					   
	
	PROCEDURE UpdateTmpAmdPartFactors (
			    pPartNo                      amd_part_factors.part_no%TYPE,
				pLocSid                      amd_part_factors.loc_sid%TYPE,
				pPassUpRate					 amd_part_factors.pass_up_rate%TYPE ,
				pRts						 amd_part_factors.rts%TYPE ,										
				pCmdmdRate					 amd_part_factors.cmdmd_rate%TYPE ,
		  	    pActionCode					 amd_part_factors.action_code%TYPE ,
		  	    pLastUpdateDt				 amd_part_factors.last_update_dt%TYPE ) IS
	
	BEGIN
		 	  UPDATE tmp_amd_part_factors
			  SET 
			  	  pass_up_rate		 		= pPassUpRate,
				  rts						= pRts,
				  cmdmd_rate				= pCmdmdRate,
			  	  action_code				= pActionCode,
				  last_update_dt			= pLastUpdateDt
			  WHERE
			  	  part_no = pPartNo AND
				  loc_sid = pLocSid ;
	END UpdateTmpAmdPartFactors ;		
	
	PROCEDURE InsertAmdPartFactors (
			  pPartNo                   amd_part_factors.part_no%TYPE,
			  pLocSid 					amd_spare_networks.loc_sid%TYPE, 
			  pPassUpRate				amd_part_factors.pass_up_rate%TYPE ,
			  pRts						amd_part_factors.rts%TYPE ,										
			  pCmdmdRate				amd_part_factors.cmdmd_rate%TYPE ,
			  pActionCode				amd_part_factors.action_code%TYPE ,
			  pLastUpdateDt				amd_part_factors.last_update_dt%TYPE ) IS
	BEGIN
		 INSERT INTO amd_part_factors 
		 (
		  		part_no,
				loc_sid,
				pass_up_rate,
				rts,
				cmdmd_rate,
				action_code,
				last_update_dt
		 )
		 VALUES 
		 (
		  	  pPartNo,
			  pLocSid,
			  pPassUpRate,
			  pRts,
			  pCmdmdRate,
			  pActionCode,
			  pLastUpdateDt	 
		 ) ;	 
	EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
			  UpdateAmdPartFactors (
		   			pPartNo,
		  			pLocSid,
		  			pPassUpRate,
		  			pRts,										
		  			pCmdmdRate,
		  	  	    pActionCode,
		  	  	    pLastUpdateDt ) ;
			  	 
	END InsertAmdPartFactors ;
	
	PROCEDURE InsertTmpAmdPartFactors (
			  pPartNo 			   		amd_part_factors.part_no%TYPE,
			  pLocSid 					amd_part_factors.loc_sid%TYPE, 
			  pPassUpRate				amd_part_factors.pass_up_rate%TYPE ,
			  pRts						amd_part_factors.rts%TYPE ,										
			  pCmdmdRate				amd_part_factors.cmdmd_rate%TYPE ,
			  pActionCode				amd_part_factors.action_code%TYPE ,
			  pLastUpdateDt				amd_part_factors.last_update_dt%TYPE ) IS
	BEGIN
		 INSERT INTO tmp_amd_part_factors 
		 (
		  		part_no,
				loc_sid,
				pass_up_rate,
				rts,
				cmdmd_rate,
				action_code,
				last_update_dt
		 )
		 VALUES 
		 (
		  	  pPartNo,
			  pLocSid,
			  pPassUpRate,
			  pRts,
			  pCmdmdRate,
			  pActionCode,
			  pLastUpdateDt	 
		 ) ;	 
	EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
			  UpdateTmpAmdPartFactors (
		   			pPartNo,
		  			pLocSid,
		  			pPassUpRate,
		  			pRts,										
		  			pCmdmdRate,
		  	  	    pActionCode,
		  	  	    pLastUpdateDt ) ;
			  	 
	END InsertTmpAmdPartFactors ;
	
	FUNCTION InsertRow(		
			pPartNo                      amd_part_factors.part_no%TYPE,
			pLocSid                      amd_part_factors.loc_sid%TYPE,
			pPassUpRate					 amd_part_factors.pass_up_rate%TYPE ,
			pRts						 amd_part_factors.rts%TYPE ,										
			pCmdmdRate					 amd_part_factors.cmdmd_rate%TYPE ,
			pCriticality				 amd_national_stock_items.criticality%TYPE,
			pCriticalityChanged			 amd_national_stock_items.criticality_changed%TYPE,
			pCriticalityCleaned			 amd_national_stock_items.criticality_cleaned%TYPE )
			return NUMBER  IS
			locationInfo amd_spare_networks%ROWTYPE ;	
			mtdRec mtd_rec := null ; 	
			crit amd_national_stock_items.criticality%TYPE := null ;
			returnCode NUMBER ;
	BEGIN		
		BEGIN
			 InsertAmdPartFactors
			 (
			   	  pPartNo,
			 	  pLocSid,
			  	  pPassUpRate,
				  pRts, 										
				  pCmdmdRate,
			  	  Amd_Defaults.INSERT_ACTION,
			  	  sysdate
			 ) ;	  
		EXCEPTION WHEN OTHERS THEN
		 		   returnCode := ErrorMsg(
				   pSourceName 	  	  => 'InsertRow.InsertAmdPartFactors',
				   pTableName  	  	  => 'amd_part_factors',
				   pError_location 	  => 20,
				   pReturn_code	  	  => 99,
				   pKey1			  => pPartNo,
	   			   pKey2			  => pLocSid,
				   pKey3			  => '',		   
				   pData			  => '',
				   pComments		  => PKGNAME) ;		
				   RAISE ;	  		  			  	
		END ;	 
		
		BEGIN
			locationInfo := amd_utils.GetLocationInfo(pLocSid) ; 
			crit := DetermineCriticality(amd_preferred_pkg.GetPreferredValue(pCriticalityCleaned, pCriticality), pPartNo) ;
		    InsertTmpA2A_PF(
				pPartNo,
				locationInfo.spo_location,
				null,  /* mtbdr */
				null,  /* mttr */
				pPassUpRate,
				pRts,			
				pCmdmdRate,
				crit,
				AMD_DEFAULTS.INSERT_ACTION,
				SYSDATE )	;
		EXCEPTION WHEN OTHERS THEN
		 		   returnCode := ErrorMsg(
				   pSourceName 	  	  => 'InsertRow.insertTmpA2A_PF',
				   pTableName  	  	  => 'tmp_a2a_part_factors',
				   pError_location 	  => 20,
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
			pPartNo                      amd_part_factors.part_no%TYPE,
			pLocSid                      amd_part_factors.loc_sid%TYPE,
			pPassUpRate					 amd_part_factors.pass_up_rate%TYPE ,
			pRts						 amd_part_factors.rts%TYPE ,										
			pCmdmdRate					 amd_part_factors.cmdmd_rate%TYPE ,
			pCriticality				 amd_national_stock_items.criticality%TYPE,
			pCriticalityChanged			 amd_national_stock_items.criticality_changed%TYPE,
			pCriticalityCleaned			 amd_national_stock_items.criticality_cleaned%TYPE )
			return NUMBER  IS
			locationInfo amd_spare_networks%ROWTYPE ;	
			mtdRec mtd_rec := null ; 	
			returnCode NUMBER ;
			crit amd_national_stock_items.criticality%TYPE ;
	BEGIN
		BEGIN
		    UpdateAmdPartFactors
			(
					pPartNo,
					pLocSid,
					pPassUpRate,
					pRts,										
					pCmdmdRate,
			  	    Amd_Defaults.UPDATE_ACTION,
			  	    sysdate
			 ) ;	
		EXCEPTION WHEN OTHERS THEN
		 		   returnCode := ErrorMsg(
				   pSourceName 	  	  => 'UpdateRow.UpdateAmdPartFactors',
				   pTableName  	  	  => 'tmp_amd_part_factors',
				   pError_location 	  => 30,
				   pReturn_code	  	  => 99,
				   pKey1			  => pPartNo,
	   			   pKey2			  => pLocSid,
				   pKey3			  => '',		   
				   pData			  => '',
				   pComments		  => PKGNAME) ;		
				   RAISE ;
		END ;	
		
		BEGIN
			locationInfo := amd_utils.GetLocationInfo(pLocSid) ;
			crit := DetermineCriticality(amd_preferred_pkg.GetPreferredValue(pCriticalityCleaned, pCriticality), pPartNo) ;
		    InsertTmpA2A_PF(
				pPartNo,
				locationInfo.spo_location,
				null,  /* mtbdr */
				null,  /* mttr */
				pPassUpRate,
				pRts,			
				pCmdmdRate,
				crit,
	 			AMD_DEFAULTS.UPDATE_ACTION,
	 			SYSDATE 
			  )	;
		EXCEPTION WHEN OTHERS THEN
		 		   returnCode := ErrorMsg(
				   pSourceName 	  	  => 'UpdateRow.insertTmpA2A_PF',
				   pTableName  	  	  => 'tmp_a2a_part_factors',
				   pError_location 	  => 40,
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
			pPartNo                      amd_part_factors.part_no%TYPE,
			pLocSid                      amd_part_factors.loc_sid%TYPE,
			pPassUpRate					 amd_part_factors.pass_up_rate%TYPE ,
			pRts						 amd_part_factors.rts%TYPE ,										
			pCmdmdRate					 amd_part_factors.cmdmd_rate%TYPE ,
			pCriticality				 amd_national_stock_items.criticality%TYPE,
			pCriticalityChanged			 amd_national_stock_items.criticality_changed%TYPE,
			pCriticalityCleaned			 amd_national_stock_items.criticality_cleaned%TYPE )
			return NUMBER  IS
		    locationInfo amd_spare_networks%ROWTYPE ;	
			mtdRec mtd_rec := null ; 	
			crit amd_national_stock_items.criticality%TYPE := null ;	
			returnCode NUMBER ;	
	BEGIN	
	   	BEGIN
			UpdateAmdPartFactors
			(
	 			pPartNo,
				pLocSid,
				pPassUpRate,
				pRts,										
				pCmdmdRate,
		  	    Amd_Defaults.DELETE_ACTION,
		  	    sysdate
	
			 ) ;
		EXCEPTION WHEN OTHERS THEN
		 		   returnCode := ErrorMsg(
				   pSourceName 	  	  => 'DeleteRow.UpdateAmdPartFactors',
				   pTableName  	  	  => 'amd_part_factors',
				   pError_location 	  => 50,
				   pReturn_code	  	  => 99,
				   pKey1			  => pPartNo,
	   			   pKey2			  => pLocSid,
				   pKey3			  => '',		   
				   pData			  => '',
				   pComments		  => PKGNAME) ;		
				   RAISE ;	  		  			  	
		END ;	
		
		BEGIN
		--	IF (NOT amd_location_part_leadtime_pkg.IsPartDeleted(pPartNo) ) THEN 
				locationInfo := amd_utils.GetLocationInfo(pLocSid) ; 
				crit := DetermineCriticality(amd_preferred_pkg.GetPreferredValue(pCriticalityCleaned, pCriticality), pPartNo) ;		
			    InsertTmpA2A_PF(
					pPartNo,
					locationInfo.spo_location,
					null,  /* mtbdr */
					null,  /* mttr */
					pPassUpRate,
					pRts,			
					pCmdmdRate,
					crit,
					AMD_DEFAULTS.DELETE_ACTION,
					SYSDATE )	;
	--		END IF ;		
		EXCEPTION WHEN OTHERS THEN
		 		   returnCode := ErrorMsg(
				   pSourceName 	  	  => 'DeleteRow.InsertTmpA2A_PF',
				   pTableName  	  	  => 'tmp_a2a_part_factors',
				   pError_location 	  => 20,
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
	
	/*   
		 ----------------------------------------------
		 Load related procedures 
		 ----------------------------------------------
	*/
	
	
	FUNCTION GetRepairIndicator(pNsn bssm_base_parts.nsn%TYPE, pSran bssm_base_parts.sran%TYPE, pLockSid bssm_locks.LOCK_SID%TYPE) 
		 RETURN VARCHAR2 IS 
		 retRI bssm_base_parts.repair_indicator%TYPE ;	 	  
	BEGIN 
		 IF ((pNsn IS NULL) OR (pSran IS NULL) ) THEN
		 	RETURN null ;
		 END IF ;
	 
		 SELECT repair_indicator INTO retRI
		 	FROM bssm_base_parts bbp, amd_nsns an 
		 	WHERE bbp.lock_sid = pLockSid
			AND   an.nsn = bbp.nsn 
			AND	  an.nsi_sid = (SELECT nsi_sid FROM amd_nsns WHERE nsn = pNsn)
			AND   bbp.sran =  pSran ;
		 RETURN retRI ;	 	
	EXCEPTION WHEN NO_DATA_FOUND THEN
		 RETURN null ;	 
	END ;
	
	FUNCTION GetCapabilityLevel(pLocId amd_spare_networks.loc_id%TYPE) 
		 RETURN bssm_bases.capabilty_level%TYPE IS
		 retCap bssm_bases.capabilty_level%TYPE := null ;
	BEGIN
		 SELECT capabilty_level INTO retCap 
	  	    FROM bssm_bases 
	  	 	WHERE sran = decode(pLocId, Amd_Defaults.AMD_WAREHOUSE_LOCID, Amd_Defaults.BSSM_WAREHOUSE_SRAN, pLocId)
	  		AND lock_sid = '0' ;
		 RETURN retCap ;	
	EXCEPTION WHEN NO_DATA_FOUND THEN
		 RETURN null ;	
	END ;
	
	
	PROCEDURE LoadTmpAmdPartFactorsByLocType ( pLocType IN amd_spare_networks.loc_type%TYPE ) IS 
			  -- no mapping of amd loc_id to bssm sran for this one, use ByLocId if needed
		 CURSOR partFactors_cur IS
		  	SELECT spo_prime_part_no part_no,
				   ansi.nsn, 
				   loc_sid, 
				   loc_type,
				   loc_id,			   			  
	   	  		   amd_preferred_pkg.GetPreferredValue(rts_avg_cleaned, rts_avg, rts_avg_defaulted) rts,
			  	   amd_preferred_pkg.GetPreferredValue(nrts_avg_cleaned, nrts_avg, nrts_avg_defaulted) nrts,
			  	   amd_preferred_pkg.GetPreferredValue(condemn_avg_cleaned, condemn_avg, condemn_avg_defaulted) condemn
				FROM amd_national_stock_items ansi, amd_sent_to_a2a asta,
					 amd_spare_networks asn
		 		WHERE asta.part_no = asta.spo_prime_part_no 
				AND asta.spo_prime_part_no = ansi.prime_part_no 
				AND asta.action_code != Amd_Defaults.DELETE_ACTION
				AND ansi.action_code != Amd_Defaults.DELETE_ACTION
				AND asn.action_code != Amd_Defaults.DELETE_ACTION
				AND asn.loc_type = pLocType ;		
		I NUMBER := 0 ;		
		mtdRec mtd_rec ;
		locationInfo amd_spare_networks%ROWTYPE ;
		returnCode NUMBER ;	
	BEGIN
	    FOR rec IN partFactors_cur
	    LOOP
			BEGIN
				locationInfo.loc_type := rec.loc_type ;
				locationInfo.loc_id := rec.loc_id ;
				mtdRec := null ;
			    IF IsAutoDefaulted( locationInfo ) THEN
				 	mtdRec := AutoDefaultMtd ;
				ELSE			
					mtdRec := convertMtdToDataSys(
				 		 locationInfo.loc_id,		
						 GetCapabilityLevel(rec.loc_id) ,
						 amd_preferred_pkg.GetPreferredValue(				 					 
					   	 					GetRepairIndicator(rec.nsn, rec.loc_id, '2'),
					   						GetRepairIndicator(rec.nsn, rec.loc_id, '0') 
										  ),
						 rec.nrts,
						 rec.rts,
						 rec.condemn
					);
				END IF ;	
				InsertTmpAmdPartFactors
				 (
				   	  rec.part_no,
				 	  rec.loc_sid,
				  	  mtdRec.nrts,
					  mtdRec.rts, 										
					  mtdRec.condemn,
				  	  Amd_Defaults.INSERT_ACTION,
				  	  sysdate
				 ) ;	  
				I := I + 1 ;
		  	EXCEPTION WHEN OTHERS THEN
		 		   returnCode := ErrorMsg(
				   pSourceName 	  	  => 'LoadTmpAmdPartFactorsByLocType',
				   pTableName  	  	  => 'tmp_amd_part_factors',
				   pError_location 	  => 20,
				   pReturn_code	  	  => 99,
				   pKey1			  => 'locType:' || rec.loc_type,
			   	   pKey2			  => 'partNo:' || rec.part_no,
				   pKey3			  => 'locSid:' || rec.loc_sid,		     
				   pData			  => '',
				   pComments		  => PKGNAME ) ;		
				   RAISE ;
			END ;
	    END LOOP;
	   	COMMIT ;  
	END ;
	 
	
	PROCEDURE LoadTmpAmdPartFactors(pAmdLocId  IN  amd_spare_networks.loc_id%TYPE, 
			  						pBssmSran  IN  bssm_base_parts.sran%TYPE ) IS
		 CURSOR partFactors_cur IS
		  	SELECT spo_prime_part_no part_no,
				   ansi.nsn, 
				   loc_sid, 
				   loc_type,
				   loc_id,
				   amd_preferred_pkg.GetPreferredValue(rts_avg_cleaned, rts_avg, rts_avg_defaulted) rts,
			  	   amd_preferred_pkg.GetPreferredValue(nrts_avg_cleaned, nrts_avg, nrts_avg_defaulted) nrts,
			  	   amd_preferred_pkg.GetPreferredValue(condemn_avg_cleaned, condemn_avg, condemn_avg_defaulted) condemn
				FROM amd_national_stock_items ansi, amd_sent_to_a2a asta,
					 amd_spare_networks asn
		 		WHERE asta.part_no = asta.spo_prime_part_no 
				AND asta.spo_prime_part_no = ansi.prime_part_no 
				AND asta.action_code != Amd_Defaults.DELETE_ACTION
				AND ansi.action_code != Amd_Defaults.DELETE_ACTION
				AND asn.action_code != Amd_Defaults.DELETE_ACTION
				AND asn.loc_id = pAmdLocId ;		
		I NUMBER := 0 ;		
		mtdRec mtd_rec ;
		locationInfo amd_spare_networks%ROWTYPE ;
		returnCode NUMBER ;	
	BEGIN
	    FOR rec IN partFactors_cur
	    LOOP
			BEGIN
				locationInfo.loc_type := rec.loc_type ;
				locationInfo.loc_id := rec.loc_id ;
				mtdRec := null ;
			    IF IsAutoDefaulted( locationInfo ) THEN
				 	mtdRec := AutoDefaultMtd ;
				ELSE			
					mtdRec := convertMtdToDataSys(
				 		 locationInfo.loc_id,		
						 GetCapabilityLevel(rec.loc_id) ,
						 amd_preferred_pkg.GetPreferredValue(				 					 
					   	 					GetRepairIndicator(rec.nsn, rec.loc_id, '2'),
					   						GetRepairIndicator(rec.nsn, rec.loc_id, '0') 
										  ),
						 rec.nrts,
						 rec.rts,
						 rec.condemn
					);
				END IF ;	
				InsertTmpAmdPartFactors
				 (
				   	  rec.part_no,
				 	  rec.loc_sid,
				  	  mtdRec.nrts,
					  mtdRec.rts, 										
					  mtdRec.condemn,
				  	  Amd_Defaults.INSERT_ACTION,
				  	  sysdate
				 ) ;	  
				I := I + 1 ;			
			EXCEPTION WHEN OTHERS THEN
				 		   returnCode := ErrorMsg(
						   pSourceName 	  	  => 'LoadTmpAmdPartFactorsByLocType',
						   pTableName  	  	  => 'tmp_amd_part_factors',
						   pError_location 	  => 20,
						   pReturn_code	  	  => 99,
						   pKey1			  => 'locType:' || rec.loc_type,
			   			   pKey2			  => 'partNo:' || rec.part_no,
						   pKey3			  => 'locSid:' || rec.loc_sid,		   
						   pData			  => '',
						   pComments		  => PKGNAME ) ;		
						   RAISE ;
			END ;
	    END LOOP;
	   	COMMIT ;
		   
	END ;
	
	procedure loadA2AByDate(from_dt in date := a2a_pkg.start_dt, to_dt in date := sysdate) is
		CURSOR cur(fromDate in date, toDate in date) IS
			   SELECT ansi.nsi_sid,
			   		  pass_up_rate,
					  rts,
					  cmdmd_rate,
			   		  criticality_cleaned,
					  criticality,
					  prime_part_no,
					  loc_id,
					  loc_type, 
					  spo_location
			   FROM amd_part_factors apf, amd_national_stock_items ansi, amd_spare_networks asn
			   WHERE apf.part_no = ansi.prime_part_no 
			   		 AND apf.loc_sid = asn.loc_sid 
					 AND apf.action_code != Amd_Defaults.DELETE_ACTION 
					 AND ansi.action_code != Amd_Defaults.DELETE_ACTION
					 AND asn.action_code !=  Amd_Defaults.DELETE_ACTION   
					 and trunc(apf.last_update_dt) between trunc(fromDate) and trunc(toDate) ;
		I NUMBER := 0 ;
		returnCode NUMBER ;
		crit amd_national_stock_items.criticality%TYPE ;
	BEGIN
	  	dbms_output.put_line('amd_part_factors.loadA2AByDate(' || from_dt || ',' || to_dt || ') started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS')) ;
		mta_truncate_table('tmp_a2a_part_factors','reuse storage');
		COMMIT ;
		FOR rec IN cur(from_dt, to_dt) 
		LOOP
			crit := DetermineCriticality(amd_preferred_pkg.GetPreferredValue(rec.criticality_cleaned, rec.criticality), rec.nsi_sid ) ;     	
			InsertTmpA2A_PF(
	 			rec.prime_part_no,
	 			rec.spo_location,
	 			null,  -- mtbdr 
	 			null,  -- mttr 
	 			rec.pass_up_rate,
	 			rec.rts,
	 			rec.cmdmd_rate,
				crit,
	 			AMD_DEFAULTS.INSERT_ACTION,
	 			SYSDATE 
			 )	;
			I := I + 1 ;
		END LOOP ;
	  	dbms_output.put_line('amd_part_factors.loadA2AByDate(' || from_dt || ',' || to_dt || ') ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS')) ;
        commit ;
	EXCEPTION WHEN OTHERS THEN
	  returnCode := ErrorMsg(
				   pSourceName 	  	  => 'loadA2AByDate',
				   pTableName  	  	  => 'tmp_a2a_part_factors',
				   pError_location 	  => 60,
				   pReturn_code	  	  => 99,
				   pKey1			  => '',
	   			   pKey2			  => '',
				   pKey3			  => '',		   
				   pData			  => '',
				   pComments		  => PKGNAME || ': loadA2AByDate(' || from_dt || ',' || to_dt || ')') ;		
				   RAISE ;
	END loadA2AByDate ;
		
						
	PROCEDURE LoadAllA2A IS
		CURSOR cur IS
			   SELECT ansi.nsi_sid,
			   		  pass_up_rate,
					  rts,
					  cmdmd_rate,
			   		  criticality_cleaned,
					  criticality,
					  prime_part_no,
					  loc_id,
					  loc_type, 
					  spo_location
			   FROM amd_part_factors apf, amd_national_stock_items ansi, amd_spare_networks asn
			   WHERE apf.part_no = ansi.prime_part_no 
			   		 AND apf.loc_sid = asn.loc_sid 
					 AND apf.action_code != Amd_Defaults.DELETE_ACTION 
					 AND ansi.action_code != Amd_Defaults.DELETE_ACTION
					 AND asn.action_code !=  Amd_Defaults.DELETE_ACTION   ;
		I NUMBER := 0 ;
		returnCode NUMBER ;
		crit amd_national_stock_items.criticality%TYPE ;
	BEGIN
		mta_truncate_table('tmp_a2a_part_factors','reuse storage');
		COMMIT ;
		FOR rec IN cur
		LOOP
			crit := DetermineCriticality(amd_preferred_pkg.GetPreferredValue(rec.criticality_cleaned, rec.criticality), rec.nsi_sid ) ;     	
			InsertTmpA2A_PF(
	 			rec.prime_part_no,
	 			rec.spo_location,
	 			null,  -- mtbdr 
	 			null,  -- mttr 
	 			rec.pass_up_rate,
	 			rec.rts,
	 			rec.cmdmd_rate,
				crit,
	 			AMD_DEFAULTS.INSERT_ACTION,
	 			SYSDATE 
			 )	;
			I := I + 1 ;
		END LOOP ;
        commit ;
	EXCEPTION WHEN OTHERS THEN
	  returnCode := ErrorMsg(
				   pSourceName 	  	  => 'LoadAllA2A',
				   pTableName  	  	  => 'tmp_a2a_part_factors',
				   pError_location 	  => 60,
				   pReturn_code	  	  => 99,
				   pKey1			  => '',
	   			   pKey2			  => '',
				   pKey3			  => '',		   
				   pData			  => '',
				   pComments		  => PKGNAME || ': LoadAllA2A') ;		
				   RAISE ;
	END ;
	
	
	/* assumption is virtuals will always get default values which likely be the case.
	   therefore don't waste storage in amd_part_factors and process separately.
	   Just check status of amd_sent_to_a2a to determine if part deleted or added.
	   If changed, do nothing as always same defaults.
	   If defaults do change can process all with doAllA2A passed as true */
	 
	PROCEDURE ProcessA2AVirtualLocs( pDoAllA2A boolean, pVirtSpoLocation amd_spare_networks.LOC_ID%TYPE ) IS
		CURSOR cur(pVirtSpoLocation VARCHAR2) IS
			SELECT asta.spo_prime_part_no, 
				   asta.action_code, 
				   asta.transaction_date, 
				   criticality_cleaned, 
				   criticality, 
				   criticality_changed,
				   ansi.last_update_dt,
				   nsi_sid, 
				   pVirtSpoLocation spo_location 
			FROM amd_sent_to_a2a asta, amd_national_stock_items ansi
			WHERE asta.part_no = asta.spo_prime_part_no 
			AND ansi.prime_part_no = asta.spo_prime_part_no 
			AND ansi.action_code != Amd_Defaults.DELETE_ACTION
			ORDER BY nsi_sid ;  
			  	 
			
		mtdRec mtd_rec ;	 	  
		crit amd_national_stock_items.criticality%TYPE ;
		lastNsiSid amd_national_stock_items.nsi_sid%TYPE := -333 ;
		batchStart DATE := nvl(amd_batch_pkg.getLastStartTime, to_date('01/01/2100', 'MM/DD/YYYY') );
		critHasChanged boolean := false ;
	BEGIN
		mtdRec := AutoDefaultMtd ; 
		FOR rec IN cur(pVirtSpoLocation) 
		LOOP
			critHasChanged := false ;
			IF ( rec.criticality_changed = 'Y' AND rec.last_update_dt >= batchStart ) THEN
			   critHasChanged := true ;
			END IF ;
			IF (lastNsiSid != rec.nsi_sid) THEN		   		    
			   	crit := DetermineCriticality(amd_preferred_pkg.GetPreferredValue(rec.criticality_cleaned, rec.criticality), rec.nsi_sid  );
			END IF ;	
			IF ( pDoAllA2A ) THEN
		   		InsertTmpA2A_PF(
		 			rec.spo_prime_part_no,
		 			rec.spo_location,
		 			null,  -- mtbdr 
		 			null,  -- mttr
					mtdRec.nrts,
					mtdRec.rts,
		 			mtdRec.condemn,
					crit,
		 			AMD_DEFAULTS.INSERT_ACTION,
	 			SYSDATE 
				)	;
			ELSIF ( rec.action_code = Amd_Defaults.INSERT_ACTION AND rec.transaction_date >= batchStart )THEN
			   InsertTmpA2A_PF(
		 			rec.spo_prime_part_no,
		 			rec.spo_location,
		 			null,  -- mtbdr 
		 			null,  -- mttr 
					mtdRec.nrts,
					mtdRec.rts,
		 			mtdRec.condemn,				
					crit,
		 			AMD_DEFAULTS.INSERT_ACTION,
	 			   SYSDATE 
				  ) ;
			ELSIF ( rec.action_code = Amd_Defaults.DELETE_ACTION AND rec.transaction_date >= batchStart  ) THEN
				-- if action_code deleted, do nothing since part info deletes part  
			   InsertTmpA2A_PF(
		 			rec.spo_prime_part_no,
		 			rec.spo_location,
		 			null,  -- mtbdr 
		 			null,  -- mttr 
					mtdRec.nrts,
					mtdRec.rts,
		 			mtdRec.condemn,				
					crit,
		 			AMD_DEFAULTS.DELETE_ACTION,
	 			   SYSDATE 
				  ) ;	   
			ELSIF (rec.action_code != Amd_Defaults.DELETE_ACTION AND critHasChanged) THEN
			   InsertTmpA2A_PF(
		 			rec.spo_prime_part_no,
		 			rec.spo_location,
		 			null,  -- mtbdr 
		 			null,  -- mttr 
					mtdRec.nrts,
					mtdRec.rts,
		 			mtdRec.condemn,				
					crit,
		 			AMD_DEFAULTS.UPDATE_ACTION,
	 			   SYSDATE 
				  ) ;	   
			END IF ;				   
			lastNsiSid := rec.nsi_sid ;
		END LOOP ;
		COMMIT ;
	END ;
	
	PROCEDURE ProcessA2AVirtualLocs IS
		 doAllA2A boolean := false ;	  
	BEGIN
		  ProcessA2AVirtualLocs(doAllA2A, amd_location_part_leadtime_pkg.VIRTUAL_UAB_SPO_LOCATION) ;
	  	  ProcessA2AVirtualLocs(doAllA2A, amd_location_part_leadtime_pkg.VIRTUAL_COD_SPO_LOCATION) ;
	END ;
	
	
	PROCEDURE LoadTmpAmdPartFactors(pAmdLocId  IN  amd_spare_networks.loc_id%TYPE ) IS
	BEGIN
		 LoadTmpAmdPartFactors(pAmdLocId, pAmdLocId ) ;
	END ;
	
	
	PROCEDURE LoadTmpAmdPartFactors IS
		 NO_BSSM_SRAN varchar2(6) := null ;
	BEGIN
		 mta_truncate_table('tmp_amd_part_factors','reuse storage');
		 mta_truncate_table('tmp_a2a_part_factors','reuse storage') ;
		 	  -- mob and fsls 
		 LoadTmpAmdPartFactorsByLocType('MOB') ;
	 	 LoadTmpAmdPartFactorsByLocType('FSL') ;
		 	  -- whse - bssm 'W'', amd 'CTLATL' 
		 LoadTmpAmdPartFactors(amd_defaults.AMD_WAREHOUSE_LOCID, amd_defaults.BSSM_WAREHOUSE_SRAN ) ;
		 LoadTmpAmdPartFactors(amd_defaults.AMD_UK_LOC_ID ) ;
		 LoadTmpAmdPartFactors(amd_defaults.AMD_BASC_LOC_ID ) ;
			 
	END ;
	
	
	PROCEDURE LoadInitial IS
		 returnCode NUMBER ;	  
		 doAllA2A boolean := true ;	 
	BEGIN
		 mta_truncate_table('amd_part_factors','reuse storage');
		 COMMIT ;
		 LoadTmpAmdPartFactors ;
		 INSERT INTO amd_part_factors
		 	SELECT * FROM tmp_amd_part_factors ;
		 COMMIT ;
		 LoadAllA2A ;
		 ProcessA2AVirtualLocs(doAllA2A, amd_location_part_leadtime_pkg.VIRTUAL_UAB_SPO_LOCATION ) ;
		 ProcessA2AVirtualLocs(doAllA2A, amd_location_part_leadtime_pkg.VIRTUAL_COD_SPO_LOCATION ) ;
	EXCEPTION WHEN OTHERS THEN
	  returnCode := ErrorMsg(
				   pSourceName 	  	  => 'LoadInitial',
				   pTableName  	  	  => 'tmp_amd_part_factors',
				   pError_location 	  => 70,
				   pReturn_code	  	  => 99,
				   pKey1			  => '',
	   			   pKey2			  => '',
				   pKey3			  => '',		   
				   pData			  => '',
				   pComments		  => PKGNAME || ': LoadInitial') ;		
				   RAISE ;
	END ;

	procedure version is
	begin
		 writeMsg(pTableName => 'amd_part_factors_pkg', 
		 		pError_location => 80, pKey1 => 'amd_part_factors_pkg', pKey2 => '$Revision:   1.1  $') ;
	end version ;

END AMD_PART_FACTORS_PKG ;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_PART_FACTORS_PKG;

CREATE PUBLIC SYNONYM AMD_PART_FACTORS_PKG FOR AMD_OWNER.AMD_PART_FACTORS_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_PART_FACTORS_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_PART_FACTORS_PKG TO AMD_WRITER_ROLE;


