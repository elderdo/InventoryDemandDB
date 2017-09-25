SET DEFINE OFF;
DROP PACKAGE AMD_OWNER.AMD_PARTPRIME_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.AMD_PARTPRIME_PKG AS
/*
      $Author:   zf297a  $
    $Revision:   1.7  $
     $Date:   15 Oct 2008 09:03:02  $
    $Workfile:   AMD_PARTPRIME_PKG.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_PARTPRIME_PKG.pks.-arc  $
/*   
/*      Rev 1.7   15 Oct 2008 09:03:02   zf297a
/*   Added procedure setDebug
/*   
/*      Rev 1.6   26 Sep 2008 17:48:52   zf297a
/*   Changed name of function getPrimePartAmd to getAmdPrimePart.  Added interface for isSpoPrimePart, isSpoPrimePartYorN, and  getTwoWayRblPrimePart.
/*   
/*      Rev 1.5   22 Sep 2008 19:38:40   zf297a
/*   added interfaces setSpoPrimePart , updateAllSpoPrimeParts, and updateSpoPrimePart
/*   
/*      Rev 1.4   23 May 2008 13:20:56   zf297a
/*   Added interface for function getVersion.
/*   
/*      Rev 1.3   15 May 2008 21:43:04   zf297a
/*   Added set/get for the threshold variable.
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
       
	   FUNCTION getAmdPrimePart(pNsn VARCHAR2) RETURN VARCHAR2 ; -- changed 9/26/2008 by dse

	   FUNCTION getNsn(pPart VARCHAR2)
		 RETURN VARCHAR2 ;

		 -- added 6/9/2006 by dse
		 procedure version ;

        -- added 1/30/2007 by dse
        procedure updatePlannerCodesForSubParts ;
        
     -- added 5/15/2008 by dse   
     procedure setThreshold(value in number) ;
     function getThreshold return number ;
     
     function getVersion return varchar2 ; -- added 5/23/2008 by dse
       
     procedure setSpoPrimePart(part_no in amd_spare_parts.part_no%type, 
        spo_prime_part_no in amd_spare_parts.spo_prime_part_no%type) ; -- added 9/22/2008 by dse
   
    procedure updateAllSpoPrimeParts ; -- added 9/22/2008 by dse
    
    procedure updateSpoPrimePart(last_update_dt in amd_spare_parts.last_update_dt%type
        := amd_batch_pkg.getLastStartTime) ;
        
    function getTwoWayRblPrimePart(pNsn VARCHAR2) return varchar2 ; -- added 9/26/2008 by dse
    
	function isSpoPrimePart(pPart VARCHAR2) return boolean ; -- added 9/26/2008 by dse    
    function isSpoPrimePartYorN(pPart VARCHAR2) return varchar2 ; -- added 9/26/2008 by dse
    
    procedure setDebug(switch in varchar2) ; -- added 10/11/2008 by dse
END ;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_PARTPRIME_PKG;

CREATE PUBLIC SYNONYM AMD_PARTPRIME_PKG FOR AMD_OWNER.AMD_PARTPRIME_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_PARTPRIME_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_PARTPRIME_PKG TO AMD_WRITER_ROLE;


SET DEFINE OFF;
DROP PACKAGE BODY AMD_OWNER.AMD_PARTPRIME_PKG;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.Amd_Partprime_Pkg AS
/*
      $Author:   zf297a  $
    $Revision:   1.28  $
     $Date:   15 Oct 2008 09:41:44  $
    $Workfile:   AMD_PARTPRIME_PKG.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_PARTPRIME_PKG.pkb.-arc  $
/*   
/*      Rev 1.28   15 Oct 2008 09:41:44   zf297a
/*   Added lots of debugMsg's.  For diffPartToPrime moved the code that does insert to tmp_a2a_part_info into a separate for loop.  Also, updated the amd_sent_to_a2a with null spo_prime_part_no's with one update statment.
/*   
/*      Rev 1.27   26 Sep 2008 18:35:02   zf297a
/*   Made errorMsg act as autonomous transaction so that this routine may issue commits independent of the main transaction.
/*   Fixed getAmdPrimePart.
/*   
/*      Rev 1.26   26 Sep 2008 17:50:46   zf297a
/*   Implemented interfaces for isSpoPrimePart, isSpoPrimePartYorN, and  getTwoWayRblPrimePart.  For getTwoWayRblPrimePart used the new view amd_twoway_rbl_pairs_v.
/*   
/*      Rev 1.25   22 Sep 2008 19:38:58   zf297a
/*   implemented interfaces setSpoPrimePart , updateAllSpoPrimeParts, and updateSpoPrimePart
/*   
/*      Rev 1.24   27 Jun 2008 11:59:56   zf297a
/*   Added some debug for diffPartToPrime plus extra commit's
/*   
/*      Rev 1.23   29 May 2008 15:30:56   zf297a
/*   Added more debug code to diffPartToPrime.
/*   
/*      Rev 1.22   23 May 2008 13:21:24   zf297a
/*   Implemented function getVersion.
/*   
/*      Rev 1.21   15 May 2008 22:16:50   zf297a
/*   Added lots of debug code.
/*   
/*      Rev 1.20   11 Feb 2008 08:46:36   zf297a
/*   Eliminated close of cursor partsToSend in procedure sendParts, since the procedure a2a_pkg.processParts uses a bulk collect and then closes the cursor.
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
    debug boolean := false ;
    threshold number := 1000 ;
    
    PROCEDURE writeMsg(
                pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
                pError_location IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
                pKey1 IN VARCHAR2 := '',
                pKey2 IN VARCHAR2 := '',
                pKey3 IN VARCHAR2 := '',
                pKey4 IN VARCHAR2 := '',
                pData IN VARCHAR2 := '',
                pComments IN VARCHAR2 := '')  IS
                 pragma autonomous_transaction ;
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
        commit ;
    END writeMsg ;

    PROCEDURE ErrorMsg(
                pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
                pError_location IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
                pKey1 IN VARCHAR2 := '',
                pKey2 IN VARCHAR2 := '',
                pKey3 IN VARCHAR2 := '',
                pKey4 IN VARCHAR2 := '',
                pComments IN VARCHAR2 := '')  IS
                
                 pragma autonomous_transaction ;
                
    BEGIN
        Amd_Utils.InsertErrorMsg (
                pLoad_no => Amd_Utils.GetLoadNo(pSourceName => 'amd_partprime_pkg',    pTableName  => pTableName),
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
    
    procedure setDebug(switch in varchar2) is
    begin
        debug := upper(switch) in ('Y','T','YES','TRUE') ;
        if debug then
            dbms_output.ENABLE(100000) ;
        else
            dbms_output.DISABLE ;
        end if ;                    
    end setDebug ;

    PROCEDURE debugMsg(msg IN AMD_LOAD_DETAILS.DATA_LINE%TYPE, pError_Location IN NUMBER) IS
        pragma autonomous_transaction ;
    BEGIN
       IF debug THEN
           Amd_Utils.debugMsg(pMsg => msg,pPackage => 'amd_partPrime_pkg', pLocation => pError_location) ;
           COMMIT ; -- make sure the trace is kept
       END IF ;
    EXCEPTION WHEN OTHERS THEN
       IF SQLCODE = -14551 OR SQLCODE = -14552 THEN
       		NULL ; -- cannot do a commit inside a query, so ignore the error
       ELSE
       		RAISE ;
       END IF ;
    END debugMsg ;
 
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
                   pTableName              => 'amd_national_stock_items',
                   pError_location => 10,
                   pKey1              => 'pNsiSid=' || TO_CHAR(pNsiSid) ) ;
                   RAISE ;                                  
    END getSuperPrimePartByNsiSid;
    
    FUNCTION getTwoWayRblPrimePart(pNsn VARCHAR2) 
             RETURN VARCHAR2 IS
         retPrimePart AMD_NATIONAL_STOCK_ITEMS.prime_part_no%TYPE := NULL;
         nsiSid NUMBER ;     
    BEGIN
         select new_prime_part_no into retprimePart
         from amd_twoway_rbl_pairs_v
         where pNsn = old_nsn ;
         RETURN retPrimePart ;
    EXCEPTION 
              WHEN NO_DATA_FOUND THEN
                      RETURN NULL ;
              WHEN OTHERS THEN     
                    ErrorMsg(
                       pTableName              => 'amd_rbl_pairs/amd_nsns',
                       pError_location => 20,
                       pKey1              => 'pNsn=' || pNsn) ;
                   RAISE ;                                  
    END getTwoWayRblPrimePart ;
    
    
    FUNCTION getAmdPrimePart(pNsn VARCHAR2)
             RETURN VARCHAR2 IS
         retPrimePart AMD_NATIONAL_STOCK_ITEMS.prime_part_no%TYPE := NULL;
    BEGIN
         SELECT items.prime_part_no INTO retPrimePart
                 FROM AMD_NATIONAL_STOCK_ITEMS items
                 WHERE items.nsn = pNsn
                and items.action_code <> 'D' ; 
         RETURN retPrimePart ;
    EXCEPTION 
              WHEN NO_DATA_FOUND THEN
                      RETURN NULL ;
              WHEN OTHERS THEN     
                    ErrorMsg(
                   pTableName              => 'amd_national_stock_items',
                   pError_location => 30,
                   pKey1              => 'pNsn=' || pNsn) ;
                   RAISE ;                                  
    END getAmdPrimePart ;     
    
    
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
                   pTableName              => 'amd_spare_parts',
                   pError_location => 40,
                   pKey1              => 'pPart=' || pPart) ;
                   RAISE ;                                  
    END ;        
    
    FUNCTION isSpoPrimePart(pPart VARCHAR2)
             RETURN BOOLEAN IS
        tmpPart AMD_SPARE_PARTS.part_no%TYPE ;      
    BEGIN
        SELECT part_no INTO tmpPart
            FROM AMD_spare_parts
            WHERE part_no = pPart AND is_spo_part = 'Y' ;
        RETURN TRUE ;    
    EXCEPTION 
              WHEN NO_DATA_FOUND THEN
                  RETURN FALSE ;    
              WHEN OTHERS THEN     
                    ErrorMsg(
                   pTableName              => 'amd_sent_to_a2a',
                   pError_location => 50,
                   pKey1              => 'pPart=' || pPart) ;
                   RAISE ;                                  
    END isSpoPrimePart ;
    
    function isSpoPrimePartYorN(pPart VARCHAR2) return varchar2 is
    begin
        if isSpoPrimePart(pPart) then
            return 'Y' ;
        else
            return 'N' ;
        end if ;                        
    end isSpoPrimePartYorN ;
    
    /*  main function with the business logic, try to keep most of it here */
    FUNCTION getSuperPrimePart(pPart VARCHAR2) 
             RETURN VARCHAR2 IS
        retPrimePart AMD_NATIONAL_STOCK_ITEMS.prime_part_no%TYPE := NULL;
        nsn AMD_SPARE_PARTS.nsn%TYPE ;
    BEGIN
        nsn := getNsn(pPart) ;
        IF ( nsn IS NOT NULL ) THEN 
           retPrimePart := getTwoWayRblPrimePart(nsn) ;
           IF ( (retPrimePart IS NULL) OR (NOT isSpoPrimePart(retPrimePart)) ) THEN
                 retPrimePart := getAmdPrimePart(nsn) ;
              if not isSpoPrimePart(retPrimePart) then
                retPrimePart := null ;
              end if ;                
           END IF ;      
        END IF ;           
        RETURN retPrimePart ;
    EXCEPTION WHEN OTHERS THEN
      ErrorMsg(
       pTableName              => 'getSuperPrimePart',
       pError_location => 60,
       pKey1              => 'pPart=' || pPart) ;
       RAISE ;                                  
    
    END ;
        
    
    FUNCTION getSuperPrimeNsiSidByNsn(pNsn VARCHAR2) 
             RETURN NUMBER IS
             retNsiSid NUMBER := NULL ;
             prime AMD_SPARE_PARTS.part_no%TYPE ;
    BEGIN    
             prime := getAmdPrimePart(pNsn) ; 
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
                   pTableName              => 'getSuperPrimeNsiSidByNsn',
                   pError_location => 70,
                   pKey1              => 'pNsn=' || pNsn) ;
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
                   pTableName              => 'getSuperPrimeNsiSid',
                   pError_location => 80,
                   pKey1              => 'pPart=' || pPart) ;
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
               pTableName              => 'getSuperPrimeNsiSidByNsiSid',
               pError_location => 90,
               pKey1              => 'pNsiSid=' || TO_CHAR(pNsiSid)) ;
               RAISE ;                                  
    END getSuperPrimeNsiSidByNsiSid ;        
             
    PROCEDURE updatePrimeASTA(pPart VARCHAR2, pSpoPrimePart VARCHAR2, pDate DATE) IS
    BEGIN
         UPDATE AMD_SENT_TO_A2A
         SET    spo_prime_part_no = pSpoPrimePart,
                 spo_prime_part_chg_date = pDate
         WHERE  part_no = pPart ;
    EXCEPTION
         WHEN OTHERS THEN
              ErrorMsg(
               pTableName              => 'amd_sent_to_a2a',
               pError_location => 100,
               pKey1              => 'pPart=' || pPart,
               pKey2              => 'pSpoPrimePart=' || pSpoPrimePart,
               pkey3              => 'pDate=' || TO_CHAR(pDate,'MM/DD/YYYY HH:MI:SS AM')) ;
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
              ErrorMsg(pTableName => 'amd_spare_parts', pError_location => 110,
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
              ErrorMsg(pTableName => 'amd_spare_parts', pError_location => 120,
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
                     SET    cage_code = partCage,
                             prime_cage = primeCage
                     WHERE part_no    = pPart AND
                            prime_part = pPrime ;
                 EXCEPTION 
                 WHEN STANDARD.NO_DATA_FOUND THEN NULL;
                 WHEN OTHERS THEN                           
                      ErrorMsg(
                       pTableName              => 'tmp_a2a_part_altrel_delete',
                       pError_location => 130,
                       pKey1              => 'pPart=' || pPart,
                       pKey2              => 'pPrime=' || pPrime) ;
                       RAISE ;                                  
                 END ;
             WHEN OTHERS THEN                           
                  ErrorMsg(
                   pTableName              => 'tmp_a2a_part_alt_rel_delete',
                   pError_location => 140,
                   pKey1              => 'pPart=' || pPart,
                   pKey2              => 'pPrime=' || pPrime) ;
                   RAISE ;                                  
         END insertTmpA2APartAltRelDelete ;
         
    END InsertA2A_PartAltRelDelete ;
     
    FUNCTION getSuperPrimeNsiSidByNsn_A2A(pNsn VARCHAR2) RETURN NUMBER IS
        retNsiSid NUMBER := NULL ;     
        prime AMD_SPARE_PARTS.part_no%TYPE ;
    BEGIN
        prime := getAmdPrimePart(pNsn) ; 
        prime := getSuperPrimePart(prime) ;
        IF (prime IS NULL ) THEN
            RETURN NULL ;
        ELSIF (NOT isSpoPrimePart(prime)) THEN
            RETURN NULL ;        
        END IF ;          
        RETURN Amd_Utils.GetNsiSidFromPartNo(prime) ;    
    EXCEPTION 
              WHEN NO_DATA_FOUND THEN
                  RETURN NULL ;
              WHEN OTHERS THEN     
                  ErrorMsg(
                   pTableName              => 'getSuperPrimeNsiSidByNsn_A2A',
                   pError_location => 150,
                   pKey1              => 'pNsn=' || pNsn) ;
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
        writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 160,
            pKey1 => 'updatePlannerCodesForSubParts',
            pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM')) ;
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
                            pError_location => 170, pKey1 => 'part_no=' || subPartRecs(indx).spo_prime_part_no, pKey2 => 'planner code not found') ;
                    when others then
                          ErrorMsg(
                           pTableName              => 'updatePlannerCodesForSubParts',
                           pError_location => 180,
                           pKey1              => 'part_no=' || subPartRecs(indx).spo_prime_part_no) ;
                           RAISE ;                                                      
                end ;        
            end loop ;        
        end if ;            
        writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 190,
            pKey1 => 'updatePlannerCodesForSubParts',
            pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM')) ;
    end updatePlannerCodesForSubParts ; 

    procedure setSpoPrimePart(part_no in amd_spare_parts.part_no%type, 
        spo_prime_part_no in amd_spare_parts.spo_prime_part_no%type) is
    begin
        update amd_spare_parts
        set spo_prime_part_no = setSpoPrimePart.spo_prime_part_no,
        last_update_dt = sysdate
        where part_no = setSpoPrimePart.part_no ;
    exception
        when others then                         
            errorMsg(
                pTableName              => 'setSpoPrimePart',
                pError_location => 200,
                pKey1              => part_no,
                pKey2 => spo_prime_part_no ) ;
            raise ;                                                      
    end setSpoPrimePart ;
    
    procedure updateSpoPrimePart(last_update_dt in amd_spare_parts.last_update_dt%type
        := amd_batch_pkg.getLastStartTime) is
        
        cursor recentlyUpdatedParts is
        select part_no, spo_prime_part_no 
        from amd_spare_parts 
        where last_update_dt >= updateSpoPrimePart.last_update_dt
        and action_code <> amd_defaults.DELETE_ACTION
        and is_spo_part = 'Y' ;
        
        spo_prime_part_no amd_spare_parts.spo_prime_part_no%type ;
	cnt number := 0 ;
    begin
        writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 202,
            pKey1 => 'updateSpoPrimePart',
            pKey2 => to_char(last_update_dt,'MM/DD/YYYY HH:MI:SS AM'),
            pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM')) ;
        for rec in recentlyUpdatedParts loop
            spo_prime_part_no := getSuperPrimePart(rec.part_no) ;
            if rec.spo_prime_part_no is null or rec.spo_prime_part_no <> spo_prime_part_no then    
                setSpoPrimePart(rec.part_no,spo_prime_part_no) ;
	    	cnt := cnt + 1 ;
            end if ;                
        end loop ;
        writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 204,
            pKey1 => 'updateSpoPrimePart',
            pKey2 => cnt || ' recs updated.',
	    pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM')) ;
        commit ;
    end updateSpoPrimePart ;

    procedure updateAllSpoPrimeParts is
        cursor allActiveParts is
        select part_no, spo_prime_part_no 
        from amd_spare_parts 
        where action_code <> amd_defaults.DELETE_ACTION
        and is_spo_part = 'Y' ;
        
        spo_prime_part_no amd_spare_parts.spo_prime_part_no%type ;
    begin
        for rec in allActiveParts loop
            spo_prime_part_no := getSuperPrimePart(rec.part_no) ;
            if rec.spo_prime_part_no is null or rec.spo_prime_part_no <> spo_prime_part_no then    
                setSpoPrimePart(rec.part_no,spo_prime_part_no) ;
            end if ;                
        end loop ;
        commit ;
    end updateAllSpoPrimeParts ;
     
    FUNCTION areAllPartsSent RETURN BOOLEAN IS
             partsNotSent NUMBER ;
    BEGIN
	select count(*) into partsNotSent
	from amd_spare_parts parts
	where is_spo_part = 'Y'
	and part_no not in (select part_no from amd_spare_parts where part_no = parts.part_no) ;
         
         RETURN (partsNotSent > 0) ;
    END areAllPartsSent ;

    PROCEDURE DiffPartToPrime IS
        CURSOR getCandidates_cur IS
           SELECT parts.part_no, sent.spo_prime_part_no, parts.spo_prime_part_no, is_consumable, is_repairable
           FROM amd_spare_parts parts, amd_sent_to_a2a sent
           WHERE is_spo_part = 'Y' 
           and parts.part_no = sent.part_no
	   and sent.spo_prime_part_no is not null
	   and parts.spo_prime_part_no is not null
	   and sent.spo_prime_part_no <> parts.spo_prime_part_no ;
        
        type partTab is table of amd_sent_to_a2a.part_no%type ;
        type spoPrimeTab is table of amd_sent_to_a2a.spo_prime_part_no%type ;
        type consumableTab is table of amd_spare_parts.is_consumable%type ;
        type repairableTab is table of amd_spare_parts.is_repairable%type ;

        parts partTab ;
        spoPrimes spoPrimeTab ;               
    	latestPrime spoPrimeTab ;
    	consumables consumableTab ;
    	repairables repairableTab ;

    	status NUMBER ;
        cnt number := 0 ;
        insertCnt number := 0 ;
        updateCnt number := 0 ;
        
        
        PROCEDURE sendParts IS
                  partsToSend A2a_Pkg.partCur ;
        BEGIN
            writeMsg(pTableName => 'amd_sent_to_a2a', pError_location => 210,
                pKey1 => 'DiffPartToPrime.sendParts',
                pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM')) ;
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
                  WHERE sp.is_spo_part = 'Y'
                  and sp.part_no not IN (SELECT part_no FROM amd_sent_to_a2a WHERE sp.Part_no = part_no)
                  AND sp.nsn = nsi.nsn ;

            A2a_Pkg.processParts(partsToSend) ;
            writeMsg(pTableName => 'amd_sent_to_a2a', pError_location => 220,
                pKey1 => 'DiffPartToPrime.sendParts',
                pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM')) ;
        END sendParts ;
             
        

    BEGIN
         writeMsg(pTableName => 'tmp_a2a_part_rel_delete', pError_location => 230,
            pKey1 => 'DiffPartToPrime',
            pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM')) ;
        IF NOT areAllPartsSent THEN
           sendParts ; -- make sure all parts get sent
        END IF ;
        amd_owner.mta_truncate_Table('tmp_a2a_part_alt_rel_delete','reuse storage');
        
        updateSpoPrimePart ;
   
	update amd_sent_to_a2a a2a
	set spo_prime_part_no = (select spo_prime_part_no from amd_spare_parts where part_no = a2a.part_no)
	where spo_prime_part_no is null
	and action_code <> amd_defaults.DELETE_ACTION ;
       		
        open getCandidates_cur ;
        fetch getCandidates_cur bulk collect into parts, spoPrimes, latestPrime, consumables, repairables ;
        close getCandidates_cur ;
        
        if spoPrimes.first is not null then
            writeMsg(pTableName => 'tmp_a2a_part_rel_delete', pError_location => 240,
                pKey1 => 'DiffPartToPrime',
                pKey2 => 'spoPrimes.count=' || spoPrimes.Count ) ;

	    for indx in parts.first .. parts.last
            loop
	   	debugMsg('DiffPartToPrime: ' || parts(indx) || ','
		|| amd_defaults.INSERT_ACTION, pError_location => 242) ;
	    	status := A2a_Pkg.createPartInfo(parts(indx), Amd_Defaults.INSERT_ACTION) ;                
	    	debugMsg('DiffPartToPrime: end createPartInfo', pError_location => 244) ;
	    end loop ;

            FOR indx in parts.first .. parts.last  
            LOOP
                cnt := cnt + 1 ;
                if mod(cnt,threshold) = 0 then
                    debugMsg('DiffPartToPrime: cnt=' || cnt, pError_location => 250) ;
                end if ;                        

                BEGIN    
                        -- should never really occur                         
                    IF ( latestPrime(indx) IS NULL ) THEN
                       RAISE standard.NO_DATA_FOUND ;
                    END IF ;               


		 IF ( spoPrimes(indx) != latestPrime(indx)) THEN
		    debugMsg('DiffPartToPrime: spo prime part changed ' || spoPrimes(indx) || ' to ' || latestPrime(indx), pError_location => 280) ;

		    InsertA2A_PartAltRelDelete(parts(indx), spoPrimes(indx)) ;
		    debugMsg('DiffPartToPrime: end InsertA2A_PartAltRelDelete ' 
			|| parts(indx), pError_location => 290) ;
		    updatePrimeASTA(parts(indx), latestPrime(indx), SYSDATE ) ;
		    debugMsg('DiffPartToPrime: end updatePrimeASTA', pError_location => 300) ;
		    updateCnt := updateCnt + 1 ;

		    -- if previously spo prime part record, catch event of changed prime    
		    -- important for those tables with nsi_sid
		    IF (spoPrimes(indx) = parts(indx) ) THEN
		       	debugMsg('DiffPartToPrime: start amd_demand.prime_part_change', pError_location => 320) ;
		       	Amd_Demand.prime_part_change(spoPrimes(indx), latestPrime(indx)) ;
			debugMsg('DiffPartToPrime: end amd_demand.prime_part_change', pError_location => 325) ;
		    END IF ;

		    debugMsg('DiffPartToPrime: end spo prime part changed', pError_location => 330) ;

		 END IF ;
                EXCEPTION WHEN OTHERS THEN
                       ErrorMsg(
                           pTableName              => 'amd_sent_to_a2a',
                           pError_location => 340,
                           pKey1              => 'partNo: <' || parts(indx) || '>',
                           pKey2              => 'currentSpoPrime:<' || spoPrimes(indx) || '>',
                           pKey3              => 'latestPrime: <' || latestPrime(indx) || '>') ;           
                       RAISE ;                                  
                END ;          
                if mod(cnt,threshold + 285) = 0 then
                    writeMsg(pTableName => 'tmp_a2a_part_rel_delete', pError_location => 350,
                        pKey1 => 'DiffPartToPrime',
                        pKey2 => 'cnt=' || cnt ) ;
                end if ;                        
            END LOOP ;
            writeMsg(pTableName => 'diffPartToPrime', pError_location => 360,
                pKey1 => 'DiffPartToPrime',
                pKey2 => 'end loop cnt=' || cnt ) ;
        else        
            writeMsg(pTableName => 'diffPartToPrime', pError_location => 370,
                pKey1 => 'DiffPartToPrime',
                pKey2 => 'cursor getCandidates_cur is empty' ) ;
                        
        end if ;
        commit ;            
        updatePlannerCodesForSubParts ;
    COMMIT ;
        writeMsg(pTableName => 'tmp_a2a_part_rel_delete', pError_location => 380,
            pKey1 => 'DiffPartToPrime',
            pKey2 => 'cnt=' || cnt || ' ins=' || insertCnt || ' upd=' || updateCnt,
            pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM')) ;
    END DiffPartToPrime;         

    procedure setThreshold(value in number) is
    begin
        threshold := value ;
    end setThreshold ;
    
    function getThreshold return number is
    begin
        return threshold ;
    end getThreshold ;         
    
    PROCEDURE version IS
    BEGIN
         writeMsg(pTableName => 'amd_partprime_pkg', 
                 pError_location => 390, pKey1 => 'amd_partprime_pkg', pKey2 => '$Revision:   1.28  $') ;
    END version ;
  
    function getVersion return varchar2 is -- added 5/23/2008 by dse
    begin
        return '$Revision:   1.28  $' ;    
    end getVersion ;
 
END Amd_Partprime_Pkg ;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_PARTPRIME_PKG;

CREATE PUBLIC SYNONYM AMD_PARTPRIME_PKG FOR AMD_OWNER.AMD_PARTPRIME_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_PARTPRIME_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_PARTPRIME_PKG TO AMD_WRITER_ROLE;


