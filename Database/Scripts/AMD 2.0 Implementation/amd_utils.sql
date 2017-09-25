set define off

DROP PACKAGE AMD_OWNER.AMD_UTILS;

CREATE OR REPLACE PACKAGE AMD_OWNER.Amd_Utils AS
/*
       $Author:   zf297a  $
     $Revision:   1.1  $
         $Date:   16 Oct 2007 00:01:38  $
     $Workfile:   amd_utils.sql  $
	 $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Scripts\AMD 2.0 Implementation\amd_utils.sql.-arc  $
/*   
/*      Rev 1.1   16 Oct 2007 00:01:38   zf297a
/*   Added isPartConsumable interface and implementation
   
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
	FUNCTION getSpoPrimePartNo(part_no AMD_SENT_TO_A2A.part_no%TYPE) RETURN AMD_SENT_TO_A2A.SPO_PRIME_PART_NO%TYPE ;
	
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
        nsn amd_national_stock_items.nsn%type) return varchar2 ;
        
    -- this was written to be used by a trigger to avoid ora-04091 - table name is mutating
   	function isRepairableSmrCode(preferred_smr_code amd_national_stock_items.smr_code%type) return boolean ;
   	function isRepairableSmrCodeYorN(preferred_smr_code amd_national_stock_items.smr_code%type) return varchar2 ;
        
    -- added 5/24/2007 by dse
        
    function isPartConsumable(part_no amd_spare_parts.part_no%type) return boolean ;
    function isPartConsumableYorN(part_no amd_spare_parts.part_no%type) return varchar2 ;
    
    -- added 7/13/2007 by tp
    function isWesmPart(part_no in amd_national_stock_items.prime_part_no%type) return boolean;
    function isWesmPartYorN(part_no in amd_national_stock_items.prime_part_no%type) return varchar2;
    
    
    function transformNsn(nsn in varchar2) return varchar2  ;
    
    function getPrimePartNo(nsn in varchar2) return varchar2 ;
  
END Amd_Utils;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_UTILS;

CREATE PUBLIC SYNONYM AMD_UTILS FOR AMD_OWNER.AMD_UTILS;


GRANT EXECUTE ON AMD_OWNER.AMD_UTILS TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_UTILS TO BSSM_OWNER WITH GRANT OPTION;


DROP PACKAGE BODY AMD_OWNER.AMD_UTILS;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.Amd_Utils AS
/*
       $Author:   zf297a  $
     $Revision:   1.1  $
         $Date:   16 Oct 2007 00:01:38  $
     $Workfile:   amd_utils.sql  $
	 $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_utils.pkb-arc  $
   
      Rev 1.53   19 Sep 2007 16:59:36   zf297a
   Implementednew interfaces for isPartConsumable and isPartConsumablesYorN so that the determination can be made without retrieving any additional data.. Implemented new interfaces IsRepairableSmrCode and isRepairSmrCodeYorNm, so that a part's smr_code can be used to determine if it is repairable or not.
   
      Rev 1.52   21 Aug 2007 12:03:40   zf297a
   Fixed isNsnActive and isPartActive to return false for all NO_DATA_FOUND exceptions.
   
      Rev 1.51   19 Jul 2007 13:30:40   zf297a
   Implemented isWesmPart, isWesmPartYorN, getPrimePartNo and modified isPartConsumable - checked planner_code_cleaned and exclude nsn's beginning with NSL
   
      Rev 1.50   25 May 2007 14:22:16   zf297a
   Implemented transformNsn
   
      Rev 1.49   24 May 2007 14:45:36   zf297a
   Implemented isPartConsumable and isPartConsumableYorN.
   
      Rev 1.48   14 Apr 2007 00:36:52   zf297a
   fixed cleanTraceTables - added trim to dayOfWeek
   
      Rev 1.47   03 Apr 2007 14:37:28   zf297a
   Implement interface cleanTraceTables.
   
      Rev 1.46   22 Mar 2007 10:15:26   zf297a
   Implemented functions isSpoPrimePart and isSpoPrimePartYorN
   
      Rev 1.45   21 Mar 2007 11:40:36   zf297a
   Implemented functions:
   isPartActiveYorN
   isPartActive
   isNsnActiveYorN
   isNsnActive
   
   
      Rev 1.44   14 Mar 2007 13:52:38   zf297a
   Fixed errorMsg to use raise_application_error when it encounters an exception.
   
      Rev 1.43   14 Mar 2007 13:44:00   zf297a
   Mix multiplier for months2Calendar days - was supposed to be 30
   
      Rev 1.42   10 Mar 2007 18:25:24   zf297a
   Fixed isPrimePart - check for null for amd_nsi_parts.unassigned_date
   
      Rev 1.41   20 Feb 2007 11:36:54   zf297a
   Changed function months2CalendarDays to a simple multiplication by 30
   
      Rev 1.40   Nov 09 2006 08:46:08   zf297a
   Implemented interface rank
   
      Rev 1.38   Oct 04 2006 15:42:40   zf297a
   Fixed isPartRepariable to use the preferred smr_code - ie smr_code_cleaned if it is not null and then smr_code.  Used amd_utils.isPartRepairable in a2a_pkg.isPartValid so they use common code.
   
      Rev 1.37   Sep 25 2006 15:16:30   zf297a
   implemented interface isDiff with date parameters
   
      Rev 1.36   Sep 18 2006 13:14:40   zf297a
   implemented overloaded boolean functions isDiff
   
      Rev 1.35   Sep 12 2006 10:57:00   zf297a
   implemented interface isNumber and isNumberYorN
   
      Rev 1.34   Sep 05 2006 10:32:58   zf297a
   Added dbms_output to version
   
      Rev 1.33   Aug 29 2006 08:43:30   zf297a
   For boolean function isPartRepairable, relaxed the select criteria so that it determines if the part is repairable even if it is deleted.  Also, added an exception handler for the NO_DATA_FOUND exception and had it return false: i.e. the function was not able to clearly determine if the part was repairable based on the smr_code alone.
   
      Rev 1.32   Aug 23 2006 09:45:12   zf297a
   implemented interface isPartRepairable and isPartRepairYorN
   
      Rev 1.31   Jul 13 2006 12:13:08   zf297a
   added implementation for  getSpoPrimePartNo.

      Rev 1.30   Jun 09 2006 11:27:40   zf297a
   implemented version

      Rev 1.29   Jun 01 2006 10:55:56   zf297a
   Added writeMsg

      Rev 1.28   Mar 05 2006 19:14:12   zf297a
   Fixed debugMsg bug: substr's were wrong for pMsg3, and pMsg4

      Rev 1.26   Dec 06 2005 09:21:56   zf297a
   Fixed date so it display MM/DD/YYYY HH:MM:SS for the debugMsg

      Rev 1.24   Nov 09 2005 11:26:02   zf297a
   Implemented interface for isPrimePartYorN.

      Rev 1.23   Oct 21 2005 10:54:26   zf297a
   Removed dbms_output.put_line from debugMsg because it was filling up the output buffer.

      Rev 1.22   Sep 09 2005 14:04:22   zf297a
   Make sure there are words to join for the joinString function

      Rev 1.21   Sep 09 2005 00:20:38   zf297a
   Changed splitString and joinString to use a single character delimiter.

      Rev 1.20   Sep 07 2005 10:13:52   zf297a
   Implemented interfaces splitString and joinString (lesson learned - varray type variables must always be initialized and extended before adding an element using the extend method)

      Rev 1.19   Sep 02 2005 15:06:28   zf297a
   Missing versions after 1.18 because of PVCS server change. Implemented interfaces for getLocType,  isPrimePart, getPrimePart, getEquivalentParts, equivalentParts

      Rev 1.20   Aug 19 2005 12:41:06   zf297a
   Added functions bizDays2CalendarDays, months2CalendarDays, and getSiteLocation.

      Rev 1.19   Aug 19 2005 11:35:16   c378632
   add GetNsiSidFromPartNo

      Rev 1.18   07 Jun 2005 22:13:02   c378632
   add GetLocationInfo, GetSpoLocation, GetPartNo

      Rev 1.17   May 17 2005 10:03:56   c970183
   Removed redundant version of InsertErrorMessage

      Rev 1.16   May 13 2005 14:18:58   c970183
   For the insertErrorMsg procedure all parameters are now optional.  The load_no will still get set, the key5 variable will get set if it is null to the sysdate, and the comments column will get set to sqlcode and sqlerrm.

      Rev 1.15   May 02 2005 13:40:22   c970183
   Removed global debugging.  Used exact types related to amd_load_details for paramater args to debugMsg

      Rev 1.14   Apr 21 2005 08:17:06   c970183
   Created debugMsg which can be controlled via mDebug and mDebugThreshold.  Both params can be controlled by the package user or the amd_param_changes table.  The data from amd_param_changes is loaded at package initialization, therefore the settings given by the package user have a higher priority since they can be overriden at any time during the session.

      Rev 1.13   03 Dec 2004 07:29:14   c970183
   Made sure sourceName and tableName do not exceed the column size for the getLoadNo function

      Rev 1.12   02 Dec 2004 14:32:44   c970183
   Made sure the error logging routines never try to insert a column that is longer than the maximum field.

      Rev 1.10   05 Sep 2002 10:16:34   c970183
   Added $Log$ keyword and changed variable name from sendorAddress to senderAddress
	-- 09/05/02 dse		added sendMail procedure

	--06/07/05 KS		added GetSpoLocation, GetLocationInfo, GetPartNo
*/

	debugCnt NUMBER := 0 ;


    -- use this function  to make sure a field never exceeds its max length
	FUNCTION trimToMax(str IN VARCHAR2, maxLen IN NUMBER) RETURN VARCHAR2 IS
	BEGIN
		 IF LENGTH(str) >maxLen THEN
		 	RETURN SUBSTR(str,1,maxLen) ;
		 ELSE
		 	 RETURN str ;
		 END IF ;
	END trimToMax ;

	FUNCTION GetLoadNo(
							pSourceName AMD_LOAD_STATUS.SOURCE%TYPE,
							pTableName AMD_LOAD_STATUS.TABLE_NAME%TYPE) RETURN NUMBER IS
		loadNo   NUMBER;
		sourceName AMD_LOAD_STATUS.SOURCE%TYPE := trimToMax(pSourceName,20) ;
		tableName AMD_LOAD_STATUS.TABLE_NAME%TYPE := trimToMax(pTableName,30) ;
	BEGIN
		SELECT
			amd_load_status_seq.NEXTVAL
		INTO loadNo
		FROM dual;
		INSERT INTO AMD_LOAD_STATUS
		(
			load_no,
			source,
			load_date,
			table_name
		)
		VALUES
		(
			loadNo,
			sourceName,
			SYSDATE,
			tableName
		);
		RETURN loadNo;
	END GetLoadNo;
	FUNCTION FormatNsn(
							pNsn VARCHAR2,
							pType VARCHAR2 DEFAULT 'AMD') RETURN VARCHAR2 IS
		RetVal	VARCHAR2(50);
	BEGIN
		--
		-- AMD uses NSN w/o dashes. GOLD uses NSN w/dashes.
		--
		IF (pType = 'AMD') THEN
			RetVal := REPLACE(pNsn,'-');
		ELSE
			RetVal := SUBSTR(pNsn,1,4)||'-'||SUBSTR(pNsn,5,2)||'-'||
							SUBSTR(pNsn,7,3)||'-'||SUBSTR(pNsn,10,4);
		END IF;
		RETURN RetVal;
	END;


	PROCEDURE InsertErrorMsg (
							pLoad_no IN AMD_LOAD_DETAILS.load_no%TYPE := NULL,
							pData_line_no IN AMD_LOAD_DETAILS.data_line_no%TYPE := NULL,
							pData_line IN AMD_LOAD_DETAILS.data_line%TYPE := NULL,
							pKey_1 IN AMD_LOAD_DETAILS.key_1%TYPE := NULL,
							pKey_2 IN AMD_LOAD_DETAILS.key_2%TYPE := NULL,
							pKey_3 IN AMD_LOAD_DETAILS.key_3%TYPE := NULL,
							pKey_4 IN AMD_LOAD_DETAILS.key_4%TYPE := NULL,
							pKey_5 IN AMD_LOAD_DETAILS.key_5%TYPE := NULL,
							pComments IN AMD_LOAD_DETAILS.comments%TYPE := NULL ) IS

		loadNo NUMBER := pLoad_no ;
		dataLine AMD_LOAD_DETAILS.data_line%TYPE := trimToMax(pData_line,2000) ;
		k1 AMD_LOAD_DETAILS.KEY_1%TYPE := trimToMax(pKey_1,50) ;
		k2 AMD_LOAD_DETAILS.KEY_2%TYPE := trimToMax(pKey_2, 50) ;
		k3 AMD_LOAD_DETAILS.KEY_3%TYPE := trimToMax(pKey_3, 50) ;
		k4 AMD_LOAD_DETAILS.KEY_4%TYPE := trimToMax(pKey_4, 40) ;
		k5 AMD_LOAD_DETAILS.KEY_5%TYPE := trimToMax(pKey_5, 50) ;
		msg AMD_LOAD_DETAILS.COMMENTS%TYPE := trimToMax(pComments, 2000) ;

	BEGIN
		 IF loadNo IS NULL THEN
		 	loadNo := getLoadNo('amd_utils','amd_load_details') ;
		 END IF ;
		 IF k5 IS NULL THEN
		 	k5 := TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ;
		 END IF ;
		 IF msg IS NULL THEN
		 	msg := SUBSTR('sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')',1,2000) ;
		 END IF ;
		INSERT INTO AMD_LOAD_DETAILS
		(
			load_no,
			data_line_no,
			data_line,
			key_1,
			key_2,
			key_3,
			key_4,
			key_5,
			comments
		)
		VALUES
		(
			pLoad_no,
			pData_line_no,
			dataLine,
			k1,
			k2,
			k3,
			k4,
			k5,
			msg
		);
	exception when others then
		  dbms_output.enable(100000) ;
		  if not isNumber(to_char(pLoad_no)) then
		  	 dbms_output.put_line('pLoad_no is not a number') ;
		  end if ;
		  if not isNumber(to_char(dataLine)) then
		  	 dbms_output.put_line('dataLine is not a number') ;
		  end if ;
		  dbms_output.put_line('k1=' || k1) ;			  
		  dbms_output.put_line('k2=' || k2) ;
		  dbms_output.put_line('k3=' || k3) ;
		  dbms_output.put_line('k4=' || k4) ;
		  dbms_output.put_line('k5=' || k5) ;
		  dbms_output.put_line('msg=' || msg) ;
          
          raise_application_error(-20010,
                substr('amd_utils ' 
                    || sqlcode || ' '
                    || pLoad_no || ' ' 
                    || dataLine || ' ' 
                    || k1 || ' ' 
                    || k2 || ' ' 
                    || k3 || ' ' 
                    || k4 || ' '
                    || k5 || ' '
                    || msg, 1,2000)) ;
                    
	END InsertErrorMsg;

	FUNCTION GetNsiSid(pNsn IN AMD_NSNS.nsn%TYPE) RETURN AMD_NSNS.nsi_sid%TYPE IS
		nsi_sid AMD_NSNS.nsi_sid%TYPE := NULL ;
	BEGIN
		SELECT nsi_sid INTO nsi_sid
		FROM AMD_NSNS
		WHERE nsn = pNsn ;
		RETURN nsi_sid ;
	END GetNsiSid ;

	FUNCTION GetNsiSid(pPart_no IN AMD_NSI_PARTS.part_no%TYPE) RETURN AMD_NSI_PARTS.nsi_sid%TYPE IS
		nsi_sid AMD_NSI_PARTS.nsi_sid%TYPE := NULL ;
	BEGIN
		SELECT nsi_sid INTO nsi_sid
		FROM AMD_NSI_PARTS
		WHERE part_no = pPart_no
		AND unassignment_date IS NULL ;
		RETURN nsi_sid ;
	END GetNsiSid ;

	FUNCTION GetLocSid(pLocId AMD_SPARE_NETWORKS.loc_id%TYPE) RETURN AMD_SPARE_NETWORKS.loc_sid%TYPE IS
		locSid AMD_SPARE_NETWORKS.loc_sid%TYPE := NULL;
		-- locId amd_spare_networks.loc_id%type := null;
	BEGIN
		 /* may not always be applicable, moved to amd_from_bssm_pkg
		 if (pLocId = amd_from_bssm_pkg.BSSM_WAREHOUSE_SRAN) then
	    	   locId := amd_from_bssm_pkg.AMD_WAREHOUSE_LOCID;
		 else
		 	   locId := pLocId;
		 end if;
		 */
		 SELECT loc_sid
		 INTO locSid
		 FROM AMD_SPARE_NETWORKS
		 WHERE loc_id = pLocId;
		 RETURN locSid;
	EXCEPTION
		 WHEN NO_DATA_FOUND THEN
		 	  RETURN NULL;
	END GetLocSid;

	FUNCTION GetLocType(pLocSid AMD_SPARE_NETWORKS.loc_sid%TYPE) RETURN AMD_SPARE_NETWORKS.loc_type%TYPE IS
		locType AMD_SPARE_NETWORKS.loc_type%TYPE := NULL;
	BEGIN
		 SELECT loc_type
		 INTO locType
		 FROM AMD_SPARE_NETWORKS
		 WHERE loc_sid = pLocSid;
		 RETURN locType;
	EXCEPTION
		 WHEN NO_DATA_FOUND THEN
		 	  RETURN NULL;
	END GetLocType;

	FUNCTION GetLocId(pLocSid AMD_SPARE_NETWORKS.loc_sid%TYPE) RETURN AMD_SPARE_NETWORKS.loc_id%TYPE IS
		locId AMD_SPARE_NETWORKS.loc_id%TYPE := NULL;
	BEGIN
		 SELECT loc_id
		 INTO locId
		 FROM AMD_SPARE_NETWORKS
		 WHERE loc_sid = pLocSid;
		 RETURN locid;
	EXCEPTION
		 WHEN NO_DATA_FOUND THEN
		 	  RETURN NULL;
	END GetLocId;

	procedure writeMsg(
			pSourceName in varchar2,
			pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
			pError_location IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
			pKey1 IN VARCHAR2 := '',
			pKey2 IN VARCHAR2 := '',
			pKey3 IN VARCHAR2 := '',
			pKey4 in varchar2 := '',
			pData IN VARCHAR2 := '',
			pComments IN VARCHAR2 := '')  IS
	BEGIN
		Amd_Utils.InsertErrorMsg (
				pLoad_no => Amd_Utils.GetLoadNo(pSourceName => pSourceName,	pTableName  => pTableName),
				pData_line_no => pError_location,
				pData_line    => pData,
				pKey_1 => SUBSTR(pKey1,1,50),
				pKey_2 => SUBSTR(pKey2,1,50),
				pKey_3 => substr(pKey3,1,50),
				pKey_4 => substr(pKey4,1,50),
				pKey_5 => TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS'),
				pComments => 'sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||') ' || pComments);
	end writeMsg ;


	-- NOTE: this routine does not do any commit's that is left up to the user of the routine
	PROCEDURE debugMsg(pMsg IN AMD_LOAD_DETAILS.DATA_LINE%TYPE,
			  pPackage IN AMD_LOAD_DETAILS.KEY_1%TYPE := 'amd_utils',
			  pLocation IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE := 999,
			  pMsg2 IN AMD_LOAD_DETAILS.KEY_2%TYPE := '',
			  pMsg3 IN AMD_LOAD_DETAILS.key_3%TYPE := '',
			  pMsg4 IN AMD_LOAD_DETAILS.key_4%TYPE := '') IS
	BEGIN
		IF debugCnt  <= mDebugThreshold THEN

		   -- dbms_output.put_line(pMsg);

		   InsertErrorMsg (
					pLoad_no => Amd_Utils.GetLoadNo(
							pSourceName => 'debugMsg',
							pTableName  => 'amd_load_details'),
					pData_line_no => pLocation,
					pData_line    => SUBSTR(pMsg,1,2000),
					pKey_1 => SUBSTR(pPackage,1,50),
					pKey_2 => SUBSTR(pMsg2,1,50),
					pKey_3 =>  SUBSTR(pMsg3,1,50),
					pKey_4 => SUBSTR(pMsg4,1,50),
					pKey_5 => SUBSTR(to_char(SYSDATE,'MM/DD/YYYY HH:MM:SS') || ' debugThreshold=' || TO_CHAR(mDebugThreshold),1,50),
					pComments => SUBSTR('sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||') ' || SUBSTR(pMsg,201),1,2000));

		   debugCnt := debugCnt + 1 ;
		END IF ;
	EXCEPTION WHEN OTHERS THEN
			  dbms_output.put_line('sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||') ') ;
	END;

	PROCEDURE sendMail(senderAddress   VARCHAR2, receiverAddress VARCHAR2, subject VARCHAR2, mesg VARCHAR2) IS
		 EmailServer     VARCHAR2(30) := 'mail.boeing.com';
		 Port NUMBER  := 25;
		 conn UTL_SMTP.CONNECTION;
		 mesg_body VARCHAR2(32767) ;
		 crlf VARCHAR2( 2 ):= CHR( 13 ) || CHR( 10 );
	BEGIN
		conn:= utl_smtp.open_connection( EmailServer, Port );
		utl_smtp.helo( conn, EmailServer );
		utl_smtp.mail( conn, senderAddress);
		utl_smtp.rcpt( conn, receiverAddress );
		mesg_body := 'Date: ' || TO_CHAR( SYSDATE, 'dd Mon yy hh24:mi:ss' )|| crlf ||
		       'From:'  || senderAddress || crlf ||
			   'Subject: ' || subject  || crlf ||
			   'To: '|| receiverAddress || crlf ||
			   '' || crlf || mesg ;

		utl_smtp.data( conn, mesg_body );
		utl_smtp.quit( conn );

	END sendMail ;

	 --- ks added 06/07/05 --

	FUNCTION GetSpoLocation(pLocSid AMD_SPARE_NETWORKS.loc_sid%TYPE)
		RETURN AMD_SPARE_NETWORKS.spo_location%TYPE IS
		retLocation AMD_SPARE_NETWORKS.spo_location%TYPE := NULL ;
	BEGIN
		 SELECT spo_location INTO retLocation
	   	 	FROM AMD_SPARE_NETWORKS
	   		WHERE loc_sid = pLocSid ;
			RETURN retLocation ;
	EXCEPTION WHEN OTHERS THEN
		 RETURN NULL ;
	END GetSpoLocation ;

	FUNCTION GetPartNo(pNsiSid AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE)
		RETURN AMD_NATIONAL_STOCK_ITEMS.prime_part_no%TYPE IS
		retPart AMD_NATIONAL_STOCK_ITEMS.prime_part_no%TYPE := NULL ;
	BEGIN
		 SELECT prime_part_no INTO retPart
	   	 	FROM AMD_NATIONAL_STOCK_ITEMS
	   		WHERE nsi_sid = pNsiSid AND action_code != 'D';
		 RETURN retPart ;
	EXCEPTION WHEN OTHERS THEN
		RETURN NULL ;
	END GetPartNo ;

	FUNCTION GetLocationInfo(pLocSid IN AMD_SPARE_NETWORKS.loc_sid%TYPE) RETURN
		AMD_SPARE_NETWORKS%ROWTYPE IS
		retRow AMD_SPARE_NETWORKS%ROWTYPE := NULL ;
	BEGIN
		SELECT * INTO retRow
			FROM AMD_SPARE_NETWORKS
			WHERE loc_sid = pLocSid ;
		RETURN retRow ;
	EXCEPTION WHEN OTHERS THEN
		RETURN retRow ;
	END GetLocationInfo ;

	-- ks added 06/09/05 ---
	FUNCTION GetNsiSidFromPartNo(pPart AMD_NSI_PARTS.part_no%TYPE)
		 RETURN AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE IS
		 retNsiSid AMD_NSI_PARTS.nsi_sid%TYPE  ;
	BEGIN
		SELECT nsi_sid INTO retNsiSid
			FROM AMD_NSI_PARTS
			WHERE part_no = pPart
			AND unassignment_date IS NULL ;
		RETURN retNsiSid ;
	EXCEPTION WHEN NO_DATA_FOUND THEN
		RETURN NULL ;
	END GetNsiSidFromPartNo ;

	 --  added 08/19/05
	 FUNCTION bizDays2CalendarDays(bizDays IN INTEGER) RETURN INTEGER IS
	 BEGIN
	 	  RETURN ROUND((bizDays / 5) * 7) ;
	 END bizDays2CalendarDays ;


	 --  added 08/19/05
	 FUNCTION months2CalendarDays(months IN DECIMAL) RETURN NUMBER IS
	 BEGIN
	 	  RETURN ROUND(months * 30) ;
	 END months2CalendarDays ;

	 --  added 08/19/05
	 FUNCTION getSiteLocation(loc_sid IN AMD_SPARE_NETWORKS.loc_sid%TYPE) RETURN
	    AMD_SPARE_NETWORKS.loc_id%TYPE IS

	    loc_id AMD_SPARE_NETWORKS.loc_id%TYPE ;
	 BEGIN
	  SELECT loc_id INTO loc_id
	  FROM AMD_SPARE_NETWORKS
	  WHERE loc_sid = getsitelocation.loc_sid ;

	  RETURN loc_id ;
	 END getSiteLocation ;

	 FUNCTION getLocType(loc_sid IN AMD_SPARE_NETWORKS.loc_sid%TYPE) RETURN AMD_SPARE_NETWORKS.loc_type%TYPE IS
	 		  loc_type AMD_SPARE_NETWORKS.loc_type%TYPE ;
	 BEGIN
	 	  SELECT loc_type INTO loc_type FROM AMD_SPARE_NETWORKS WHERE loc_sid = getLocType.loc_sid ;
		  RETURN loc_type ;

	 EXCEPTION
	 	  WHEN standard.NO_DATA_FOUND THEN
		  	   RETURN NULL ;
	 END getLocType ;

	 FUNCTION isPrimePart(part_no IN AMD_SPARE_PARTS.part_no%TYPE) RETURN BOOLEAN IS
	 		  prime_part_no AMD_NATIONAL_STOCK_ITEMS.prime_part_no%TYPE ;
	 BEGIN
	 	  SELECT sp.part_no INTO prime_part_no
		  FROM AMD_SPARE_PARTS sp,
		  AMD_NSI_PARTS np
		  WHERE action_code != 'D'
		  AND sp.part_no = isPrimePart.part_no
		  AND sp.part_no = np.part_no
		  AND np.UNASSIGNMENT_DATE IS  NULL
		  AND np.PRIME_IND = 'Y' ;
		  RETURN TRUE ;
	 EXCEPTION
	 	WHEN standard.NO_DATA_FOUND THEN
			 RETURN FALSE ;
	 END isPrimePart ;

	 FUNCTION isPrimePartYorN(part_no AMD_SPARE_PARTS.part_no%TYPE) RETURN VARCHAR2 IS
	 BEGIN
	 	  IF isPrimePart(part_no) THEN
		  	 RETURN 'Y' ;
		  ELSE
		     RETURN 'N' ;
		  END IF ;
	 END isPrimePartYorN ;

	 FUNCTION getPrimePart(part_no AMD_NSI_PARTS.part_no%TYPE) RETURN AMD_NATIONAL_STOCK_ITEMS.prime_part_no%TYPE IS
	 		  prime_part_no AMD_NATIONAL_STOCK_ITEMS.prime_part_no%TYPE ;
	 BEGIN
	 	  SELECT items.prime_part_no INTO prime_part_no
		  FROM AMD_NATIONAL_STOCK_ITEMS items,
		  AMD_NSI_PARTS parts
		  WHERE items.nsi_sid = (SELECT nsi_sid FROM AMD_NSI_PARTS parts WHERE getPrimePart.part_no = parts.part_no AND parts.unassignment_date IS NULL)
		  AND items.action_code != 'D'
		  AND items.nsi_sid = parts.nsi_sid
		  AND parts.prime_ind = 'Y'
		  AND parts.UNASSIGNMENT_DATE IS NULL ;

		  RETURN prime_part_no ;

	 EXCEPTION
	 	  WHEN standard.NO_DATA_FOUND THEN
		  	   RETURN NULL ;
	 END getPrimePart ;
     
    function isSpoPrimePart(part_no in amd_spare_parts.part_no%type) return boolean is
        result number := 0 ;
    begin
        select 1 into result 
        from dual 
        where exists (select null 
                      from amd_sent_to_a2a
                      where spo_prime_part_no = isSpoPrimePart.part_no
                      and action_code <> amd_defaults.DELETE_ACTION
                      ) ;
        return true ;
    exception when standard.no_data_found then
        return false ;        
    end isSpoPrimePart ;
	
function isSpoPrimePartYorN(part_no in amd_spare_parts.part_no%type) return varchar2 is
begin
    if isSpoPrimePart(part_no) then
        return 'Y' ;
    end if ;
    return 'N' ;
end isSpoPrimePartYorN ;

	FUNCTION getEquivalentParts(part_no AMD_SPARE_PARTS.part_no%TYPE) RETURN equivalent_parts IS
			 equivParts equivalent_parts ;
			 rec AMD_SPARE_PARTS%ROWTYPE ;
	 BEGIN
	 	  OPEN equivParts FOR
		  SELECT * FROM AMD_SPARE_PARTS parts
		  WHERE parts.part_no IN
		    (SELECT part_no FROM AMD_NSI_PARTS nsi
			 WHERE nsi.nsi_sid = (
			 	   			   SELECT nsi_sid
							   FROM AMD_NATIONAL_STOCK_ITEMS
							   WHERE prime_part_no = Amd_Utils.getPrimePart(getEquivalentParts.part_no)
							   AND action_code != 'D'
							    )
			AND nsi.unassignment_date IS NULL
			AND nsi.prime_ind != 'Y' );

	 	  RETURN equivParts ;

	 END getEquivalentParts ;

	FUNCTION equivalentParts(part_no AMD_SPARE_PARTS.part_no%TYPE) RETURN parts PIPELINED IS
			 equivParts equivalent_parts ;
			 rec AMD_SPARE_PARTS%ROWTYPE ;
	 BEGIN
	 	  OPEN equivParts FOR
		  SELECT * FROM AMD_SPARE_PARTS parts
		  WHERE parts.part_no IN
		    (SELECT part_no FROM AMD_NSI_PARTS nsi
			 WHERE nsi.nsi_sid = (
			 	   			   SELECT nsi_sid
							   FROM AMD_NATIONAL_STOCK_ITEMS
							   WHERE prime_part_no = Amd_Utils.getPrimePart(equivalentParts.part_no)
							   AND action_code != 'D'
							    )
			AND nsi.unassignment_date IS NULL
			AND nsi.prime_ind != 'Y' );
		  LOOP
		  	  FETCH equivParts INTO rec ;
			  EXIT WHEN equivParts%NOTFOUND ;
	 	  	  pipe ROW(rec) ;
		  END LOOP ;
		  RETURN ;
	 END equivalentParts ;

	-- added 9/7/2005 dse
	FUNCTION splitString(text IN VARCHAR2, delim IN VARCHAR2 := ',') RETURN arrayOfWords IS
			 word VARCHAR2(512) ;
			 words arrayOfWords := arrayOfWords() ;
			 x NUMBER := 0 ;


			 PROCEDURE addWord IS
			 BEGIN
			 	 x := x + 1 ;
				 words.extend ;
				 words(x) := word ;
				 word := NULL ;
			 END addWord ;


	BEGIN
		 IF LENGTH(text) > 0 THEN
			 FOR i IN 1..LENGTH(text) LOOP
			 	 IF SUBSTR(text,i,1) != delim THEN
				 	word := word || SUBSTR(text,i,1) ;
				 ELSE
				 	 addWord ;
				 END IF ;
				 IF LENGTH(text) > 0 AND i = LENGTH(text) THEN
				 	addWord ;
				 END IF ;
			 END LOOP ;
		 END IF ;
		 RETURN words ;
	END splitString ;

	FUNCTION joinString(words IN arrayOfWords, delim IN VARCHAR2 := ',') RETURN VARCHAR2 IS
			 buf VARCHAR2(512) := '' ;
	BEGIN

		 IF words.COUNT() > 0 THEN
			 FOR i IN words.first..words.last LOOP
			 	 IF i != words.last THEN
					buf := buf || words(i) || delim ;
				 ELSE
				 	buf := buf || words(i) ;
				 END IF ;
			 END LOOP ;
		 END IF ;
		 RETURN buf ;
	END joinString ;

	FUNCTION getCageCode(part_no IN VARCHAR2) RETURN VARCHAR2 IS
			  cageCode AMD_SPARE_PARTS.mfgr%TYPE ;
	BEGIN
		  SELECT mfgr INTO cageCode FROM AMD_SPARE_PARTS WHERE part_no = getCageCode.part_no ;
	  RETURN cageCode ;
	EXCEPTION WHEN standard.NO_DATA_FOUND THEN
		  RETURN NULL ;
	END getCageCode ;

	FUNCTION getUnitCostDefaulted(part_no IN VARCHAR2) RETURN AMD_SPARE_PARTS.unit_cost_defaulted%TYPE IS
			 nsn AMD_SPARE_PARTS.nsn%TYPE ;
			 mfgr AMD_SPARE_PARTS.mfgr%TYPE ;
			 smr_code AMD_NATIONAL_STOCK_ITEMS.smr_code%TYPE ;
			 planner_code AMD_NATIONAL_STOCK_ITEMS.planner_code%TYPE ;
	BEGIN
		 SELECT nsn, mfgr INTO nsn, mfgr
		 FROM AMD_SPARE_PARTS
		 WHERE part_no = getUnitCostDefaulted.part_no
		 AND action_code != Amd_Defaults.DELETE_ACTION ;

		 SELECT smr_code, planner_code INTO smr_code, planner_code
		 FROM AMD_NATIONAL_STOCK_ITEMS items,
		 AMD_SPARE_PARTS parts
		 WHERE parts.part_no = getUnitCostDefaulted.part_no
		 AND parts.nsn = items.nsn
		 AND items.action_code != Amd_Defaults.DELETE_ACTION ;
		 RETURN Amd_Defaults.GetUnitCost(pNsn => nsn, pPart_no => part_no,pMfgr => mfgr, pSmr_code => smr_code, pPlanner_code => planner_code)  ;
	EXCEPTION WHEN standard.NO_DATA_FOUND THEN
			  RETURN NULL ;
	END getUnitCostDefaulted ;

	function boolean2Varchar2(theValue in boolean, YorN in boolean := false) return varchar2 is
	begin
		 if theValue then
		 	if YorN then
			   return 'Y' ;
			else
		 		return 'true' ;
			end if ;
		 else
		    if YorN then
			   return 'N' ;
			else
		 		 return 'false' ;
			end if ;
		 end if ;
	end boolean2Varchar2 ;

	procedure version is
	begin
		 amd_utils.writeMsg(pSourceName => 'amd_utils', pTableName => 'amd_utils',
		 		pError_location => 999, pKey1 => 'amd_utils', pKey2 => '$Revision:   1.1  $') ;
		 dbms_output.put_line('a2a_utils: $Revision:   1.1  $') ;
	end version ;


   FUNCTION getSpoPrimePartNo(part_no AMD_SENT_TO_A2A.part_no%TYPE) RETURN AMD_SENT_TO_A2A.SPO_PRIME_PART_NO%TYPE IS
   			spo_prime_part_no AMD_SENT_TO_A2A.SPO_PRIME_PART_NO%TYPE ;
   BEGIN
   		SELECT DISTINCT spo_prime_part_no INTO spo_prime_part_no 
		FROM AMD_SENT_TO_A2A
		WHERE part_no = getSpoPrimePartNo.part_no ;
		RETURN spo_prime_part_no ;
   END getSpoPrimePartNo ;
   
   -- this was written to be used by a trigger to avoid ora-04091 - table name is mutating
   function isPartConsumable(preferred_smr_code amd_national_stock_items.smr_code%type,
        preferred_planner_code amd_national_stock_items.planner_code%type,
        nsn amd_national_stock_items.nsn%type) return boolean is
             result boolean := false ;
   begin
        if substr(nsn,1,3) <> 'NSL' then
            if preferred_planner_code  in ('NSF','NSA','NSG','PSD') then
                 if length(preferred_smr_code) >= 6 then
                    result := upper(substr(preferred_smr_code,6,1)) in ( 'P','N') 
                              and upper(substr(preferred_smr_code,1,1)) = 'P' ;
        		 end if ;
            end if ;
        end if ;
        return result ;                             
   end isPartConsumable ;
   
   function isPartConsumableYorN(preferred_smr_code amd_national_stock_items.smr_code%type,
        preferred_planner_code amd_national_stock_items.planner_code%type,
        nsn amd_national_stock_items.nsn%type) return varchar2 is
   begin
        if isPartConsumable(preferred_smr_code => preferred_smr_code, preferred_planner_code => preferred_planner_code,
            nsn => nsn) then
            return 'Y' ;
        else
            return 'N' ;
        end if ;                         
   end isPartConsumableYorN ;        
                
   function isPartConsumable(part_no amd_spare_parts.part_no%type) return boolean is
    
			 preferred_smr_code amd_national_stock_items.smr_code%type ;
             preferred_planner_code amd_national_stock_items.planner_code%type;
             nsn amd_national_stock_items.nsn%type ;
	begin
		 select amd_preferred_pkg.getPreferredValue(smr_code_cleaned, smr_code), 
         amd_preferred_pkg.getPreferredValue(planner_code_cleaned,planner_code),
         items.nsn into preferred_smr_code, preferred_planner_code, nsn 
		 from amd_spare_parts parts, 
		 amd_national_stock_items items
		 where parts.part_no = isPartConsumable.part_no
		 and parts.nsn = items.nsn ;

         return isPartConsumable(preferred_smr_code => preferred_smr_code,
            preferred_planner_code => preferred_planner_code,
            nsn => nsn) ;         
         
	exception when standard.no_data_found then
			  return false ;		 
	end isPartConsumable ;

   	function isPartConsumableYorN(part_no amd_spare_parts.part_no%type) return varchar2 is
    begin
        if isPartConsumable(part_no) then
            return 'Y' ;
        else
            return 'N' ;
        end if ;
    end isPartConsumableYorN ;
    
    
    function isWesmPart(part_no in amd_national_stock_items.prime_part_no%type) return boolean is
        result number := 0;
    begin
        select 1 into result
        from dual
        where exists (select null
                      from l11 , amd_national_stock_items items, active_niins
                      where items.prime_part_no = isWesmPart.part_no
                      and l11.nsn = items.nsn and items.action_code <> amd_defaults.getDELETE_ACTION
                      and l11.niin = active_niins.niin) ;
    
        return true;

    exception when standard.no_data_found then
        return false;
    
    end isWesmPart;
    
    
    function isWesmPartYorN(part_no in amd_national_stock_items.prime_part_no%type) return varchar2 is
    begin
        if isWesmPart(part_no) then
	        return 'Y';
        end if; 
            return 'N';
    end isWesmPartYorN ;

    
    -- this was written to be used by a trigger to avoid ora-04091 - table name is mutating
   	function isRepairableSmrCode(preferred_smr_code amd_national_stock_items.smr_code%type) return boolean is
    begin
        return length(preferred_smr_code) >= 6 and upper(substr(preferred_smr_code,6,1)) = 'T' ;
    end isRepairableSmrCode ;             

   	function isRepairableSmrCodeYorN(preferred_smr_code amd_national_stock_items.smr_code%type) return varchar2 is
    begin
        if isRepairableSmrCode(preferred_smr_code => preferred_smr_code) then
            return 'Y' ;
        else
            return 'N' ;
        end if ;                        
    end isRepairableSmrCodeYorN ;

    
   	function isPartRepairable(part_no amd_spare_parts.part_no%type) return boolean is
			 preferred_smr_code amd_national_stock_items.smr_code%type ;
	begin
		 select amd_preferred_pkg.getPreferredValue(smr_code_cleaned, smr_code) into preferred_smr_code 
		 from amd_spare_parts parts, 
		 amd_national_stock_items items
		 where parts.part_no = isPartRepairable.part_no
		 and parts.nsn = items.nsn ;
         
         return isRepairableSmrCode(preferred_smr_code => preferred_smr_code) ;
         
	exception when standard.no_data_found then
			  return false ;		 
	end isPartRepairable ;
	
	function isPartRepairableYorN(part_no amd_spare_parts.part_no%type) return varchar2 is
	begin
		 if isPartRepairable(part_no) then
		 	return 'Y' ;
		 else
		 	return 'N' ;
		 end if ;
	end isPartRepairableYorN ;

	function isNumber( p_string in varchar2 ) return boolean
	is
	   l_number number;
	begin
	   l_number := P_string;
	   return true;
	exception 
	   when others then return false;
	end;
	
	function isNumberYorN( p_string in varchar2 ) return varchar2 is
	begin
		 if isNumber(p_string) then
		 	return 'Y' ;
		else
			return 'N' ;
		end if ;
	end isNumberYorN ;
		   
	function isDiff(oldText in varchar2, newText in varchar2) return boolean is
	begin
		 return oldText <> newText 
		 		or (oldText is null and newText is not null) 
				or (oldText is not null and newText is null) ;
	end isDiff ;
    
	
	function isDiff(oldNum in number, newNum in number) return boolean is
	begin
		 return (oldNum <> newNum)
		 		or (oldNum is null and newNum is not null) 
				or (oldNum is not null and newNum is null) ;
	end isDiff ;

	function isDiff(oldDate in date, newDate in Date) return boolean is
	begin
		 return (oldDate <> newDate)
		 		or (oldDate is null and newDate is not null) 
				or (oldDate is not null and newDate is null) ;
	end isDiff ;
	
	function getNsn(part_no in amd_spare_parts.part_no%type) return amd_spare_parts.nsn%type is
			 theNsn amd_spare_parts.nsn%type ;
	begin
		 select nsn into theNsn from amd_spare_parts where part_no = getNsn.part_no ;
		 return theNsn ;
	exception when standard.no_data_found then
		 return null ;
	end getNsn ;
	
	function rank(orderOfUsage in varchar2) return number is
			 i number ;
			 j number ;
			 exp number := 0 ;
			 cnt number := 0 ;
	begin
		 
		 for i in reverse  1..3 loop
		 	 dbms_output.put_line('i=' || i) ;
			 for j in 1..26 loop
			 	 if chr(64 + j) = substr(orderOfUsage,i,1) then
				 	cnt := cnt + (j * 26 ** exp) ;
					exit ;
				 end if ;
			 end loop ;	  
			 exp := exp + 1 ; 
		 end loop ;
		 return cnt ;
	end rank ;
	
	function isOneWay(orderOfUse in orderOfUsages) return boolean is
			 secondLetter varchar2(1) ;
	begin
		 secondLetter := substr(orderOfUse.FIRST,2,1) ;
		 for oou in orderOfUse.NEXT(orderOfUse.FIRST)..orderOfUse.LAST loop
		 	 if secondLetter  <> substr(oou,2,1) then
			 	return true ;
			 end if ;
		 end loop ;
		 return false ;
	end isOneWay ;
	
	function isOneWayYorN(orderOfUse in orderOfUsages) return varchar2 is
	begin
		 if isOneWay(orderOfUse) then
		 	return 'Y' ;
		 else
		 	return 'N' ;
		 end if ;
	end isOneWayYorN ;
    
    -- raises standard.NO_DATA_FOUND
    function isPartActiveYorN(part_no in amd_spare_parts.PART_NO%type) return varchar2 is
    begin
        -- don't check for no data found condition let the caller hand that exception
        if isPartActive(part_no) then
            return 'Y' ;
        end if ;
        return 'N' ;
    end isPartActiveYorN ;
    
    -- raises standard.NO_DATA_FOUND for amd_spare_parts query
    function isPartActive(part_no in amd_spare_parts.part_no%type) return boolean is
        action_code amd_spare_parts.action_code%type ;
    begin
        select action_code into isPartActive.action_code 
        from amd_spare_parts 
        where part_no = isPartActive.part_no ;
        return action_code <> amd_defaults.DELETE_ACTION ;
    exception when standard.no_data_found then
        return false ;        
    end isPartActive ;
    
    function isNsnActiveYorN(nsn in amd_nsns.NSN%type) return varchar2 is
    begin
        -- don't check for no data found condition let the caller hand that exception
        if isNsnActive(nsn) then
            return 'Y' ;
        end if ;
        return 'N' ;
    end isNsnActiveYorN ;
    
    -- raises standard.NO_DATA_FOUND for amd_nsns query
    function isNsnActive(nsn in amd_nsns.NSN%type) return boolean is
        nsn_type amd_nsns.NSN_TYPE%type ;
        nsi_sid amd_nsns.NSI_SID%type ;
        action_code amd_national_stock_items.action_code%type ;
    begin
        select nsn_type, nsi_sid into isNsnActive.nsn_type, isNsnActive.nsi_sid from amd_nsns where nsn = isNsnActive.nsn ;
        if nsn_type = 'C' then -- current
            begin
                select action_code into isNsnActive.action_code 
                from amd_national_stock_items 
                where nsi_sid = isNsnActive.nsi_sid
                and action_code <> amd_defaults.DELETE_ACTION
                and exists (select null 
                            from amd_nsi_parts 
                            where nsi_sid = isNsnActive.nsi_sid 
                           and unassignment_date is null) ;
                return true ;   
            exception when standard.no_data_found then
                return false ;
            end ;
        end if ;
        
        return false ;

    exception when standard.no_data_found then
        return false ;            
    end isNsnActive ;

    procedure cleanTraceTables is
        dayOfWeek varchar2(10) ;
    begin
        select to_char(sysdate,'DAY') into dayOfWeek from dual ;
        if trim(dayOfWeek) = amd_defaults.CLEAN_DATA_DAY then
            mta_truncate_table('amd_load_details','reuse storage') ;
            mta_truncate_table('amd_load_status','reuse storage') ;
        end if ; 
    end cleanTraceTables ;
    
    function transformNsn(nsn in varchar2) return varchar2  is
        newNsn varchar2(65) := upper(nsn) ;
        part_no amd_spare_parts.part_no%type ;
    begin
        if substr(newNsn,1,3) = 'NSL' and substr(newNsn,4,1) in ('~','$','#') then
            part_no := substr(nsn,5) ;
            if isPartActive(part_no) then
                newNsn := getNsn(part_no) ;
            else
                newNsn := null ;
            end if ;
        end if ;
        
        return newNsn ;
        
    end transformNsn ;
    
    function getPrimePartNo(nsn in varchar2) return varchar2 is
        prime_part_no amd_national_stock_items.prime_PART_NO%type ;
    begin
        select prime_part_no into prime_part_no from amd_national_stock_items where nsn = getPrimePartNo.nsn ;
        return prime_part_no ;
    exception when standard.no_data_found then
        return null ;
    end getPrimePartNo ;

	
BEGIN
	 <<getDebugThreshold>>
	 DECLARE
	 		param AMD_PARAM_CHANGES.PARAM_VALUE%TYPE ;
	 BEGIN
	 		SELECT param_value INTO param FROM AMD_PARAM_CHANGES WHERE param_key = 'debugUtilsThreshold' ;
			--mDebugThreshold := to_number(param) ;
	 EXCEPTION WHEN OTHERS THEN
	 		   mDebugThreshold := 1000 ;
	 END getDebugThreshold ;


END Amd_Utils;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_UTILS;

CREATE PUBLIC SYNONYM AMD_UTILS FOR AMD_OWNER.AMD_UTILS;


GRANT EXECUTE ON AMD_OWNER.AMD_UTILS TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_UTILS TO BSSM_OWNER WITH GRANT OPTION;


