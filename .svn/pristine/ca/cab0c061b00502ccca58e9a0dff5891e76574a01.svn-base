set define off

DROP PACKAGE AMD_OWNER.AMD_PARTPRIME_PKG;

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

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_PARTPRIME_PKG;

CREATE PUBLIC SYNONYM AMD_PARTPRIME_PKG FOR AMD_OWNER.AMD_PARTPRIME_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_PARTPRIME_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_PARTPRIME_PKG TO AMD_WRITER_ROLE;


DROP PACKAGE BODY AMD_OWNER.AMD_PARTPRIME_PKG;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.Amd_Partprime_Pkg AS
/*
      $Author:   zf297a  $
    $Revision:   1.19  $
     $Date:   06 Nov 2007 23:43:12  $
    $Workfile:   AMD_PARTPRIME_PKG.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_PARTPRIME_PKG.pkb.-arc  $
/*   
/*      Rev 1.19   06 Nov 2007 23:43:12   zf297a
/*   Added bulk collect for all cursors.
/*   
/*      Rev 1.18   14 Aug 2007 15:54:20   zf297a
/*   Fixed diffPartToPrime to fill in spo_prime_part_no for consumable parts.
/*   
/*      Rev 1.17   12 Jun 2007 21:51:00   zf297a
/*   Make sure any new spo prime part no has it data sent via an A2A PartInfo transaction
/*   
/*      Rev 1.16   01 Mar 2007 13:51:36   zf297a
/*   removed truncation of amd_test_parts by the diffPartToPrime procedure
/*   
/*      Rev 1.15   01 Mar 2007 12:44:48   zf297a
/*   Removed recording of changed spo prime part in amd_test_parts.  invoked sendZeroTslsForSpoPrimePart for the old prime part whenever the prime part changes.
/*   
/*      Rev 1.14   28 Feb 2007 13:58:34   zf297a
/*   Replaced amd_location_part_override_pkg.deleteRspTslA2A with amd_location_part_override_pkg.loadRspZeroTslA2A
/*   
/*      Rev 1.13   22 Feb 2007 00:04:30   zf297a
/*   Added mtbdr_computed to partInfoRec
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
	
	PROCEDURE InsertA2A_PartAltRelDelete(pPart VARCHAR2, pPrime VARCHAR2) IS
		 partCage AMD_SPARE_PARTS.mfgr%TYPE := NULL ;
		 primeCage AMD_SPARE_PARTS.mfgr%TYPE := NULL ;
	BEGIN
	 	 <<getPartCage>>
	 	 BEGIN
			 SELECT mfgr INTO partCage
			 	 FROM AMD_SPARE_PARTS 
			 	 WHERE part_no = pPart ;
		 EXCEPTION 
            WHEN STANDARD.NO_DATA_FOUND THEN 
                NULL ;
            WHEN OTHERS THEN
			  ErrorMsg(pTableName => 'amd_spare_parts', pError_location 	  => 110,
			   pKey1 => 'pPart=' || pPart) ;
		      RAISE ;	  		  			  			 
		 END getPartCage;
		 
		 <<getPrimeCage>> 
	 	 BEGIN
		 	 SELECT mfgr INTO primeCage
			 	 FROM AMD_SPARE_PARTS 
			 	 WHERE part_no = pPrime ;
		 EXCEPTION
            WHEN STANDARD.NO_DATA_FOUND THEN 
              NULL ; 
            WHEN OTHERS THEN
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
              WHEN STANDARD.NO_DATA_FOUND THEN NULL; 
			  WHEN DUP_VAL_ON_INDEX THEN
			  	 BEGIN
				 	 UPDATE TMP_A2A_PART_ALT_REL_DELETE
					 SET	cage_code = partCage,
					 		prime_cage = primeCage
					 WHERE part_no    = pPart AND
					 	   prime_part = pPrime ;
				 EXCEPTION 
                 WHEN STANDARD.NO_DATA_FOUND THEN NULL;
                 WHEN OTHERS THEN	   		   	 	
					  ErrorMsg(
					   pTableName  	  	  => 'tmp_a2a_part_altrel_delete',
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
		 
	END InsertA2A_PartAltRelDelete ;
	 
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
        type subPartRec is record (
            part_no amd_sent_to_a2a.part_no%type,
            spo_prime_part_no amd_sent_to_a2a.spo_prime_part_no%type
        ) ;
        type subPartTab is table of subPartRec ;
        subPartRecs subPartTab ;
                    
        cursor subPartsCur is
            select info.part_no, spo_prime_part_no from tmp_a2a_part_info info, amd_sent_to_a2a sent 
            where info.part_no not in (select part_no 
                                 from amd_sent_to_a2a 
                                 where part_no = spo_prime_part_no 
                                 and action_code <> amd_defaults.DELETE_ACTION)
            and info.part_no = sent.part_no ; 
            resp_asset_mgr tmp_a2a_part_info.resp_asset_mgr%type ;
    begin
        open subPartsCur ;
        fetch subPartsCur bulk collect into subPartRecs ;
        close subPartsCur ;
        if subPartRecs.first is not null then
            for indx in subPartRecs.first .. subPartRecs.last loop
                begin
                    resp_asset_mgr := amd_preferred_pkg.GETPLANNERCODE(amd_utils.GETNSISID(pPart_no => subPartRecs(indx).spo_prime_part_no)) ;
                    update tmp_a2a_part_info
                    set resp_asset_mgr = updatePlannerCodesForSubParts.resp_asset_mgr 
                    where part_no = subPartRecs(indx).part_no ;
                exception 
                    when standard.no_data_found then
                        writeMsg(pTableName => 'updatePlannerCodesForSubParts', 
                            pError_location => 155, pKey1 => 'part_no=' || subPartRecs(indx).spo_prime_part_no, pKey2 => 'planner code not found') ;
                    when others then
                          ErrorMsg(
                           pTableName  	  	  => 'updatePlannerCodesForSubParts',
                           pError_location 	  => 157,
                           pKey1			  => 'part_no=' || subPartRecs(indx).spo_prime_part_no) ;
                           RAISE ;	  		  			  		                
                end ;        
            end loop ;        
        end if ;            
    end updatePlannerCodesForSubParts ; 

	 
	PROCEDURE DiffPartToPrime IS
		CURSOR getCandidates_cur IS
			   SELECT part_no, spo_prime_part_no
			   FROM AMD_SENT_TO_A2A asta
			   WHERE asta.action_code != Amd_Defaults.DELETE_ACTION;
        
        type partTab is table of amd_sent_to_a2a.part_no%type ;
        type spoPrimeTab is table of amd_sent_to_a2a.spo_prime_part_no%type ;
        parts partTab ;
        spoPrimes spoPrimeTab ;               
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
                      nsi.mtbdr_computed,
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
        
        open getCandidates_cur ;
        fetch getCandidates_cur bulk collect into parts, spoPrimes ;
        close getCandidates_cur ;
        
        if spoPrimes.first is not null then
            FOR indx in parts.first .. parts.last  
            LOOP
                BEGIN	
                    latestPrime := getSuperPrimePart(parts(indx)) ;	
                        -- should never really occur 						
                    IF ( latestPrime IS NULL ) THEN
                       RAISE standard.NO_DATA_FOUND ;
                    END IF ;   			

                    if not a2a_pkg.isPartSent(latestPrime) then
                        if amd_utils.isPartRepairable(latestPrime) then
                            if a2a_pkg.isPartValid(latestPrime) then
                                if a2a_pkg.CREATEPARTINFO(part_no => latestPrime, action_code => amd_defaults.INSERT_ACTION) =
                                    a2a_pkg.SUCCESS and a2a_pkg.isPartSent(latestPrime) then
                                    null ; -- do nothing everything is now ok since the new spo prime part no will be sent
                                else
                                    raise_application_error(-20000,'Was not able to send part_no (' || latestPrime || ') which is to be a spo prime part') ;
                                end if ;
                            else
                                raise_application_error(-20001,'The new spo prime part no (' || latestPrime || ') is not valid.this should not occur.') ;
                            end if ;
                        else
                            if amd_utils.isPartConsumable(latestPrime) then
                                a2a_consumables_pkg.insertPartInfo(part_no => latestPrime, action_code => amd_defaults.INSERT_ACTION) ;
                                if a2a_pkg.isPartSent(part_no => latestPrime) then
                                    null ;
                                else
                                    raise_application_error(-20002,'The new spo prime part no (' || latestPrime || ') did not get sent: this should not occur.') ;                        
                                end if ;
                            else
                                raise_application_error(-20003,'The new spo prime part no (' || latestPrime || ') is not repairable or consumable: this should not occur.') ;                        
                            end if ;    
                        end if ;
                    end if ; 

                        -- case for just added part
                    IF ( spoPrimes(indx) IS NULL ) THEN		  
                         updatePrimeASTA(parts(indx), latestPrime, NULL) ;		  
                    ELSE 
                         IF ( spoPrimes(indx) != latestPrime) THEN
                            InsertA2A_PartAltRelDelete(parts(indx), spoPrimes(indx)) ;
                            updatePrimeASTA(parts(indx), latestPrime, SYSDATE ) ;
                            status := A2a_Pkg.createPartInfo(parts(indx), Amd_Defaults.INSERT_ACTION) ;				
                            -- if previously spo prime part record, catch event of changed prime	
                            -- important for those tables with nsi_sid
                            IF (spoPrimes(indx) = parts(indx) ) THEN
                               Amd_Demand.prime_part_change(spoPrimes(indx), latestPrime) ;
                            END IF ;
                            amd_location_part_override_pkg.sendZeroTslsForSpoPrimePart(spoPrimes(indx)) ;
                         END IF ;
                    END IF ;  
                EXCEPTION WHEN OTHERS THEN
                       ErrorMsg(
                           pTableName  	  	  => 'amd_sent_to_a2a',
                           pError_location 	  => 160,
                           pKey1			  => 'partNo: <' || parts(indx) || '>',
                           pKey2			  => 'currentSpoPrime:<' || spoPrimes(indx) || '>',
                           pKey3			  => 'latestPrime: <' || latestPrime || '>') ;		   
                       RAISE ;	  		  			  	
                END ;	 	 
            END LOOP ;
        end if ;            
        updatePlannerCodesForSubParts ;
		COMMIT ;
		a2a_pkg.deleteSentToA2AChildren	;			
	END DiffPartToPrime;		 
  
	PROCEDURE version IS
	BEGIN
		 writeMsg(pTableName => 'amd_partprime_pkg', 
		 		pError_location => 170, pKey1 => 'amd_partprime_pkg', pKey2 => '$Revision:   1.19  $') ;
	END version ;
  

 
END Amd_Partprime_Pkg ;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_PARTPRIME_PKG;

CREATE PUBLIC SYNONYM AMD_PARTPRIME_PKG FOR AMD_OWNER.AMD_PARTPRIME_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_PARTPRIME_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_PARTPRIME_PKG TO AMD_WRITER_ROLE;


