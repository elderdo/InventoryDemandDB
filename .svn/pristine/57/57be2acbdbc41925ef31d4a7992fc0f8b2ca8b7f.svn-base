CREATE OR REPLACE PACKAGE BODY AMD_OWNER.Amd_Partprime_Pkg AS
/*
      $Author:   zf297a  $
    $Revision:   1.32  $
     $Date:   15 Jul 2009 15:08:50  $
    $Workfile:   AMD_PARTPRIME_PKG.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_PARTPRIME_PKG.pkb.-arc  $
/*   
/*      Rev 1.31   15 Jul 2009 15:08:50   zf297a
/*   Removed more a2a code
/*   
/*      Rev 1.30   15 Jul 2009 13:50:40   zf297a
/*   Removed more a2a code.
/*   
/*      Rev 1.29   15 Jul 2009 10:08:44   zf297a
/*   Removed A2A code.
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
                   pTableName              => 'amd_spare_parts',
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
                 pError_location => 390, pKey1 => 'amd_partprime_pkg', pKey2 => '$Revision:   1.32  $') ;
    END version ;
  
    function getVersion return varchar2 is -- added 5/23/2008 by dse
    begin
        return '$Revision:   1.32  $' ;    
    end getVersion ;
 
END Amd_Partprime_Pkg ;
/
