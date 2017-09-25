CREATE OR REPLACE PACKAGE AMD_OWNER.Amd_Utils AS
/*
       $Author:   zf297a  $
     $Revision:   1.43  $
         $Date:   24 Jun 2009 09:30:50  $
     $Workfile:   amd_utils.pks  $
	 $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_utils.pks-arc  $
   
      Rev 1.43   24 Jun 2009 09:30:50   zf297a
   Added interface for convertToBase and groupPriority.
   
      Rev 1.42   24 Mar 2009 15:37:06   zf297a
   Changed the interface for getSpoPrimePartNo and added interface for isSpoPartYorN.
   
      Rev 1.41   24 Mar 2009 15:20:56   zf297a
   Added interfaces for getDebug, setDebug, getDebugCnt, setDebugCnt, getDebugThreshold, setDebugThreshold, getLastLoadDetail, and emptyTraceTables.
   
      Rev 1.40   09 Sep 2008 15:21:28   zf297a
   added interfaces:    
   function isDiffYorN(oldText in varchar2, newText in varchar2) return varchar2 ; 
   function isDiffYorN(oldNum in number, newNum in number) return varchar2 ;
   function isDiffYorN(oldDate in date, newDate in Date) return varchar2 ;
   
   
      Rev 1.39   23 May 2008 13:12:34   zf297a
   Added interface for function validatePlannerCode.
   
      Rev 1.38   22 May 2008 16:44:26   zf297a
   Added interface for getVersion.
   
      Rev 1.37   22 May 2008 09:03:36   zf297a
   Defined interfaces for isForeignMilitarySale and isForeignMilitarySaleYorN
   
      Rev 1.36   19 Sep 2007 16:57:26   zf297a
   Added new interfaces for isPartConsumable and isPartConsumablesYorN.  Added new interfaces IsRepairableSmrCode and isRepairSmrCodeYorN.
   
      Rev 1.35   19 Jul 2007 13:28:02   zf297a
   Added the following interfaces:
   isWesmPart(part_no)
   isWesmPartYorN(part_no)
   getPrimePartNo(nsn) returns the prime_part_no from amd_national_stock_items
   
      Rev 1.34   25 May 2007 14:21:56   zf297a
   Added transformNsn 
   
      Rev 1.33   24 May 2007 14:44:56   zf297a
   Added interfaces isPartConsumable and isPartConsumableYorN
   
      Rev 1.32   03 Apr 2007 14:36:48   zf297a
   Define interface cleanTraceTables
   
      Rev 1.31   22 Mar 2007 10:14:48   zf297a
   Added interface for isSpoPrimePart
   
      Rev 1.30   21 Mar 2007 11:39:24   zf297a
   Defined interfaces for functions:
   isPartActiveYorN
   isPartActive
   isNsnActiveYorN
   isNsnActive
   
   
      Rev 1.29   Nov 09 2006 08:45:52   zf297a
   Added interface rank
   
      Rev 1.27   Sep 25 2006 15:16:06   zf297a
   added interface for isDiff with date parameters
   
      Rev 1.26   Sep 18 2006 13:14:18   zf297a
   added overloaded boolean functions isDiff
   
      Rev 1.25   Sep 12 2006 10:56:32   zf297a
   added interface for isNumber and isNumberYorN
   
      Rev 1.24   Aug 23 2006 09:43:48   zf297a
   Defined interface for boolean function isPartRepairable and
   the interface for varchar2 function isPartRepairableYorN.
   
      Rev 1.23   Jul 13 2006 12:12:42   zf297a
   Added interface for getSpoPrimePartNo.

      Rev 1.22   Jun 09 2006 11:27:30   zf297a
   added version interface

      Rev 1.21   Jun 01 2006 10:55:58   zf297a
   Added writeMsg

      Rev 1.19   Nov 09 2005 11:25:46   zf297a
   Added interface for isPrimePartYorN.

      Rev 1.18   Sep 09 2005 00:20:36   zf297a
   Changed splitString and joinString to use a single character delimiter.

      Rev 1.17   Sep 07 2005 09:44:42   zf297a
   Added the arrayOfWords 'type' and interfaces splitString and joinString.

      Rev 1.16   Sep 02 2005 15:05:32   zf297a
   Added interfaces for getLocType,  isPrimePart, getPrimePart, getEquivalentParts, equivalentParts

      Rev 1.17   Aug 19 2005 12:41:06   zf297a
   Added functions bizDays2CalendarDays, months2CalendarDays, and getSiteLocation.

      Rev 1.16   Aug 19 2005 11:35:16   c378632
   add GetNsiSidFromPartNo

      Rev 1.15   07 Jun 2005 22:13:08   c378632
   add GetLocationInfo, GetSpoLocation, GetPartNo

      Rev 1.14   May 17 2005 10:03:58   c970183
   Removed redundant version of InsertErrorMessage

      Rev 1.13   May 13 2005 14:19:00   c970183
   For the insertErrorMsg procedure all parameters are now optional.  The load_no will still get set, the key5 variable will get set if it is null to the sysdate, and the comments column will get set to sqlcode and sqlerrm.

      Rev 1.12   May 02 2005 13:35:34   c970183
   Removed the global mDebug - each package should have their own mDebug flag which determines if the debug code is executed.

      Rev 1.11   Apr 21 2005 08:17:08   c970183
   Created debugMsg which can be controlled via mDebug and mDebugThreshold.  Both params can be controlled by the package user or the amd_param_changes table.  The data from amd_param_changes is loaded at package initialization, therefore the settings given by the package user have a higher priority since they can be overriden at any time during the session.

      Rev 1.9   05 Sep 2002 10:16:34   c970183
   Added $Log$ keyword and changed variable name from sendorAddress to senderAddress

	--
	-- SCCSID: %M%  %I%  Modified: %G% %U%
	--
	-- Date     By     History
	-- -------- -----  ---------------------------------------------------
	-- 10/14/01 FF     Initial implementation
	-- 10/17/01 DSE		Added GetNsiSid functions
	-- 10/24/01 ks		added GetLocSid
	-- 10/28/01 ks		added GetLocType, GetLocId
	-- 10/30/01 dse		added a variation of InsertErrorMsg with all
						the fields for amd_load_details
	-- 09/05/02 dse		added sendMail procedure
	-- 9/3/04 dse		added stronger data typing for GetLoadNo and InsertErrorMsg
	-- 06/07/05 ks		add GetLocationInfo, GetSpoLocation, GetPartNo
	-- 06/09/05 ks		add GetNsiSidFromPartNo
	   					(signatures often equivalent for other GetNsiSid -
						received too many functions match this call)
*/

type equivalent_parts is ref cursor return amd_spare_parts%rowtype ;
type parts is table of amd_spare_parts%Rowtype ;
type arrayOfWords is varray(50) of varchar2(512) ;

subtype orderOfUsage is varchar2(3) ;
type orderOfUsages is table of orderOfUsage index by orderOfUsage ;

mDebugThreshold NUMBER := 1000 ; -- this can be controlled by the user of the package
				                 -- or by amd_param_changes / debugUtilsThreshold

-- when this routine has been executed pDebugThreshold times, it will not create any more
-- output
PROCEDURE debugMsg(pMsg IN AMD_LOAD_DETAILS.DATA_LINE%TYPE,
			  pPackage IN AMD_LOAD_DETAILS.KEY_1%TYPE := 'amd_utils',
			  pLocation IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE := 999,
			  pMsg2 IN AMD_LOAD_DETAILS.KEY_2%TYPE := '',
			  pMsg3 IN AMD_LOAD_DETAILS.key_3%TYPE := '',
			  pMsg4 IN AMD_LOAD_DETAILS.key_4%TYPE := '') ;


FUNCTION GetLoadNo(
							pSourceName AMD_LOAD_STATUS.SOURCE%TYPE,
							pTableName AMD_LOAD_STATUS.TABLE_NAME%TYPE) RETURN NUMBER ;

FUNCTION FormatNsn(
							pNsn VARCHAR2,
							pType VARCHAR2 DEFAULT 'AMD') RETURN VARCHAR2;

PROCEDURE InsertErrorMsg (
							pLoad_no IN AMD_LOAD_DETAILS.load_no%TYPE := NULL,
							pData_line_no IN AMD_LOAD_DETAILS.data_line_no%TYPE := NULL,
							pData_line IN AMD_LOAD_DETAILS.data_line%TYPE := NULL,
							pKey_1 IN AMD_LOAD_DETAILS.key_1%TYPE := NULL,
							pKey_2 IN AMD_LOAD_DETAILS.key_2%TYPE := NULL,
							pKey_3 IN AMD_LOAD_DETAILS.key_3%TYPE := NULL,
							pKey_4 IN AMD_LOAD_DETAILS.key_4%TYPE := NULL,
							pKey_5 IN AMD_LOAD_DETAILS.key_5%TYPE := NULL,
							pComments IN AMD_LOAD_DETAILS.comments%TYPE := NULL ) ;

	-- source is amd_nsns
	FUNCTION GetNsiSid(pNsn IN AMD_NSNS.nsn%TYPE) RETURN AMD_NSNS.nsi_sid%TYPE ;
	PRAGMA RESTRICT_REFERENCES(GetNsiSid,WNDS) ;


	-- source is amd_nsi_parts
	FUNCTION GetNsiSid(pPart_no IN AMD_NSI_PARTS.part_no%TYPE) RETURN AMD_NSI_PARTS.nsi_sid%TYPE ;
	PRAGMA RESTRICT_REFERENCES(GetNsiSid,WNDS) ;

	FUNCTION GetLocSid(pLocId AMD_SPARE_NETWORKS.loc_id%TYPE) RETURN AMD_SPARE_NETWORKS.loc_sid%TYPE;
	FUNCTION GetLocType(pLocSid AMD_SPARE_NETWORKS.loc_sid%TYPE) RETURN AMD_SPARE_NETWORKS.loc_type%TYPE;
	FUNCTION GetLocId(pLocSid AMD_SPARE_NETWORKS.loc_sid%TYPE) RETURN AMD_SPARE_NETWORKS.loc_id%TYPE;
	PROCEDURE sendMail(senderAddress   VARCHAR2, receiverAddress VARCHAR2, subject VARCHAR2, mesg VARCHAR2) ;

	-- added 06/07/05
	-- GetPartNo only return active parts
	FUNCTION GetPartNo(pNsiSid AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE)	RETURN AMD_NATIONAL_STOCK_ITEMS.prime_part_no%TYPE ;
	FUNCTION GetSpoLocation(pLocSid AMD_SPARE_NETWORKS.loc_sid%TYPE) 	RETURN AMD_SPARE_NETWORKS.spo_location%TYPE ;
	PRAGMA RESTRICT_REFERENCES (GetPartNo, WNDS) ;
	PRAGMA RESTRICT_REFERENCES (GetSpoLocation, WNDS) ;
	FUNCTION GetLocationInfo(pLocSid IN AMD_SPARE_NETWORKS.loc_sid%TYPE) RETURN	AMD_SPARE_NETWORKS%ROWTYPE ;

	-- added 06/09/05
	FUNCTION GetNsiSidFromPartNo(pPart AMD_NSI_PARTS.part_no%TYPE) RETURN AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE ;

	-- added 08/19/05
	FUNCTION bizDays2CalendarDays(bizDays IN INTEGER) RETURN INTEGER ;
	FUNCTION months2CalendarDays(months IN DECIMAL) RETURN NUMBER ;
	FUNCTION getSiteLocation(loc_sid IN AMD_SPARE_NETWORKS.loc_sid%TYPE) RETURN AMD_SPARE_NETWORKS.loc_id%TYPE ;

	-- added 9/1/2005
	FUNCTION getLocType(loc_sid IN AMD_SPARE_NETWORKS.loc_sid%TYPE) RETURN AMD_SPARE_NETWORKS.loc_type%TYPE ;

	FUNCTION isPrimePart(part_no AMD_SPARE_PARTS.part_no%TYPE) RETURN BOOLEAN ;
	-- added 11/9/2005
	function isPrimePartYorN(part_no amd_spare_parts.part_no%type) return varchar2 ;
	-- for any part number return the prime part - if the input is the prime it will return itself
	function getPrimePart(part_no amd_nsi_parts.part_no%type) return amd_national_stock_items.prime_part_no%type ;

	-- for any part number, return a cursor with all the equivalent parts (could return 0 rows)
	function getEquivalentParts(part_no amd_spare_parts.part_no%type) return equivalent_parts ;

	function equivalentParts(part_no amd_spare_parts.part_no%type) return parts PIPELINED ;

	-- added 9/7/2005
	function splitString(text in varchar2, delim in varchar2 := ',') return arrayOfWords ;
	function joinString(words in arrayOfWords, delim in varchar2 := ',') return varchar2 ;

	-- added 10/7/2005 by DSE
	function getCageCode(part_no in varchar2) return varchar2 ;

	-- added 10/12/2005 by DSE
	function getUnitCostDefaulted(part_no in varchar2) return amd_spare_parts.unit_cost_defaulted%type ;

	-- added 03/03/2006 by DSE
	function boolean2Varchar2(theValue in boolean, YorN in boolean := false) return varchar2 ;

	-- added 6/1/2006 by DSE
	-- record a note in amd_load_details
	procedure writeMsg(
		pSourceName in varchar2,
		pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
		pError_location IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
		pKey1 IN VARCHAR2 := '',
		pKey2 IN VARCHAR2 := '',
		pKey3 IN VARCHAR2 := '',
		pKey4 in varchar2 := '',
		pData IN VARCHAR2 := '',
		pComments IN VARCHAR2 := '')  ;

	-- added 6/9/2006 by DSE
	procedure version ;

	-- added 7/13/2006 by DSE
	FUNCTION getSpoPrimePartNo(part_no AMD_spare_parts.part_no%TYPE) RETURN AMD_spare_parts.SPO_PRIME_PART_NO%TYPE ;
	
	-- add 8/22/2006 by DSE
	function isPartRepairable(part_no amd_spare_parts.part_no%type) return boolean ;
	function isPartRepairableYorN(part_no amd_spare_parts.part_no%type) return varchar2 ;

	-- added 9/12/2006 by DSE
	function isNumber( p_string in varchar2 ) return boolean ;
	-- added 9/12/2006 by DSE
	function isNumberYorN( p_string in varchar2) return varchar2 ;

	
	-- added 9/18/2006 by DSE
	function isDiff(oldText in varchar2, newText in varchar2) return boolean ;
	-- added 9/18/2006 by DSE
	function isDiff(oldNum in number, newNum in number) return boolean ;
	-- added 9/25/2006 by DSE
	function isDiff(oldDate in date, newDate in Date) return boolean ;
	
	-- added 10/13/2006 by DSE
	function getNsn(part_no in amd_spare_parts.part_no%type) return amd_spare_parts.nsn%type ;
	
	-- added 11/09/2006
	function rank(orderOfUsage in varchar2) return number ;
	
	-- added 11/22/2006
	function isOneWay(orderOfUse in orderOfUsages) return boolean ;
	function isOneWayYorN(orderOfUse in orderOfUsages) return varchar2 ;
    
    -- added 3/21/2007
    function isPartActiveYorN(part_no in amd_spare_parts.PART_NO%type) return varchar2 ;
    function isPartActive(part_no in amd_spare_parts.part_no%type) return boolean ;
    function isNsnActiveYorN(nsn in amd_nsns.NSN%type) return varchar2 ;
    function isNsnActive(nsn in amd_nsns.NSN%type) return boolean ;
    
    -- added 3/22/2007
    function isSpoPrimePart(part_no in amd_spare_parts.part_no%type) return boolean ;
	function isSpoPrimePartYorN(part_no in amd_spare_parts.part_no%type) return varchar2 ;
    
    -- added 4/3/2007 by dse
    procedure cleanTraceTables ;
    
    -- added 9/19/2007 by dse
   function isPartConsumable(preferred_smr_code amd_national_stock_items.smr_code%type,
        preferred_planner_code amd_national_stock_items.planner_code%type,
        nsn amd_national_stock_items.nsn%type) return boolean ;
   function isPartConsumableYorN(preferred_smr_code amd_national_stock_items.smr_code%type,
        preferred_planner_code amd_national_stock_items.planner_code%type,
        nsn amd_national_stock_items.nsn%type) return varchar2 deterministic ;
        
    -- this was written to be used by a trigger to avoid ora-04091 - table name is mutating
   	function isRepairableSmrCode(preferred_smr_code amd_national_stock_items.smr_code%type) return boolean ;
   	function isRepairableSmrCodeYorN(preferred_smr_code amd_national_stock_items.smr_code%type) 
                return varchar2 deterministic ;
        
    -- added 5/24/2007 by dse
        
    function isPartConsumable(part_no amd_spare_parts.part_no%type) return boolean ;
    function isPartConsumableYorN(part_no amd_spare_parts.part_no%type) return varchar2 ;
    
    -- added 7/13/2007 by tp
    function isWesmPart(part_no in amd_national_stock_items.prime_part_no%type) return boolean;
    function isWesmPartYorN(part_no in amd_national_stock_items.prime_part_no%type) return varchar2;
    
    
    function transformNsn(nsn in varchar2) return varchar2  ;
    
    function getPrimePartNo(nsn in varchar2) return varchar2 ;
 
    -- added 5/22/2008 by dse
    function isForeignMilitarySale(segment_code in varchar2) return boolean ;
    function isForeignMilitarySaleYorN(segment_code in varchar2) return varchar2 ;

    function getVersion return varchar2 ;
    
    function validatePlannerCode(planner_code in amd_planners.planner_code%type) 
        return amd_planners.PLANNER_CODE%type ; -- added 5/23/2008 by dse
    
    function isDiffYorN(oldText in varchar2, newText in varchar2) return varchar2 ; 
    function isDiffYorN(oldNum in number, newNum in number) return varchar2 ;
    function isDiffYorN(oldDate in date, newDate in Date) return varchar2 ;

    function getDebugYorN return varchar2 ;
    procedure setDebug(value in varchar2) ;
    
    function getDebugCnt return number ;
    procedure setDebugCnt(value in number) ;
    
    function getDebugThreshold return number ;
    procedure setDebugThreshold(value in number) ;
    
    function getLastLoadDetail return number ;
    
    procedure emptyTraceTables ;
    
    function isSpoPartYorN(part_no in amd_spare_parts.part_no%type) return amd_spare_parts.is_spo_part%type ;
    
    function convertToBase(value in number, base in number) return varchar2 ;
 	function groupPriority(rank in number) return varchar2 ;



END Amd_Utils;
/
