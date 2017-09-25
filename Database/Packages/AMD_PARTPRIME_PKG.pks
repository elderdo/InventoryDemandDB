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



       
	   FUNCTION getAmdPrimePart(pNsn VARCHAR2) RETURN VARCHAR2 ; -- changed 9/26/2008 by dse

	   FUNCTION getNsn(pPart VARCHAR2)
		 RETURN VARCHAR2 ;

		 -- added 6/9/2006 by dse
		 procedure version ;

        
     -- added 5/15/2008 by dse   
     procedure setThreshold(value in number) ;
     function getThreshold return number ;
     
     function getVersion return varchar2 ; -- added 5/23/2008 by dse
       
     procedure setSpoPrimePart(part_no in amd_spare_parts.part_no%type, 
        spo_prime_part_no in amd_spare_parts.spo_prime_part_no%type) ; -- added 9/22/2008 by dse
   
	procedure updateSpoPrimePart(last_update_dt 
		in amd_spare_parts.last_update_dt%type
		:= amd_batch_pkg.getLastStartTime) ;

     procedure updateAllSpoPrimeParts ; -- added 9/22/2008 by dse
    
        
    function getTwoWayRblPrimePart(pNsn VARCHAR2) return varchar2 ; -- added 9/26/2008 by dse
    
	function isSpoPrimePart(pPart VARCHAR2) return boolean ; -- added 9/26/2008 by dse    
    function isSpoPrimePartYorN(pPart VARCHAR2) return varchar2 ; -- added 9/26/2008 by dse
    
    procedure setDebug(switch in varchar2) ; -- added 10/11/2008 by dse
END ;
/
