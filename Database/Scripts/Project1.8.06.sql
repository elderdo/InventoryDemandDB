set define off

CREATE OR REPLACE PACKAGE Amd_Utils AS
/*
       $Author:   zf297a  $
     $Revision:   1.28  $
         $Date:   Oct 13 2006 12:56:26  $
     $Workfile:   amd_utils.pks  $
	 $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_utils.pks-arc  $
   
      Rev 1.28   Oct 13 2006 12:56:26   zf297a
   Added interface for function getNsn
   
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
	
END Amd_Utils;
/

show errors

CREATE OR REPLACE PACKAGE A2a_Pkg AS
 --
 -- SCCSID:   %M%   %I%   Modified: %G%  %U%
 --
 /*
      $Author:   zf297a  $
    $Revision:   1.51  $
     $Date:   Oct 26 2006 12:07:22  $
    $Workfile:   A2A_PKG.PKS  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\A2A_PKG.PKS-arc  $
/*   
/*      Rev 1.51   Oct 26 2006 12:07:22   zf297a
/*   Added interface for procedure deleteSentToA2AChildren.
/*   
/*      Rev 1.50   Oct 25 2006 10:36:20   zf297a
/*   Defined constants using anchored declarations via the %type attribute.
/*   Added interfaces for get functions to return the constants.
/*   
/*      Rev 1.49   Oct 20 2006 12:17:42   zf297a
/*   Add a new interface for boolean function isPartSent and for varchar2 function isPartSentYorN.
/*   
/*      Rev 1.48   Aug 31 2006 11:36:36   zf297a
/*   Added interface for initA2ADemands
/*   
/*      Rev 1.47   Aug 18 2006 15:36:46   zf297a
/*   Added interface for processExtForecast and added 2 interfaces for initA2AExtForecasts.  Defined extForecastCur type.
/*   
/*      Rev 1.46   Aug 10 2006 14:29:32   zf297a
/*   Added an optional param that will display the reason a part is not valid if the param is set to true or Y for the boolean function isPartValid and the varchar2 function, isPartValidYorN, that returns Y or N
/*   
/*      Rev 1.45   Aug 04 2006 12:55:38   zf297a
/*   Added interface getDueDate and changed the interface includeOrder by adding part_no as an argument
/*   
/*      Rev 1.44   Aug 04 2006 11:08:46   zf297a
/*   Made the boolean function includeOrder public
/*   
/*      Rev 1.43   Jul 11 2006 14:33:28   c402417
/*   Modified TYPE inTransitsCur from AMD_IN_TRANSITS to AMD_IN_TRANSITS_SUM.
/*   
/*      Rev 1.42   Jun 07 2006 20:59:10   zf297a
/*   added version procedure
/*   
/*      Rev 1.41   May 12 2006 13:57:14   zf297a
/*   Removed deletesOk from the wasPartSent interface.  Now using a global variable mblnSendAllData, which has its own getter and setter.
/*   Changed all init routines to include DELETED action codes and to use all part_no's contained in amd_sent_to_a2a that also have a spo_prime_part_no.
/*   
/*      Rev 1.40   May 12 2006 10:23:10   zf297a
/*   Allowed for A2A part delete transactions to be sent again
/*   
/*      Rev 1.39   Apr 27 2006 14:51:40   zf297a
/*   Changed interface for loadAll by adding an optional system_id
/*   
/*      Rev 1.38   Mar 03 2006 14:42:46   zf297a
/*   added loadAll procedure - this sends all the a2a data
/*   
/*      Rev 1.37   Feb 15 2006 13:39:06   zf297a
/*   Added cur ref's for all init and byDate routines + a common process routine to make sure everything is done the same no matter what selection criteria is used.
/*   
/*      Rev 1.36   Jan 04 2006 09:01:44   zf297a
/*   Added two overloaded procedures initA2ABackorderInfo which can accept a list of parts or a range of dates like the othe initA2A procedures.
/*   
/*      Rev 1.35   Jan 03 2006 12:44:14   zf297a
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
/*      Rev 1.34   Dec 30 2005 01:32:08   zf297a
/*   added initA2ABomDetail by date
/*   
/*      Rev 1.33   Dec 29 2005 16:37:54   zf297a
/*   added initA2A by date procedures for PartInfo, OrderInfo, InvInfo, RepairInfo, InTransits, and RepairInvInfo
/*   
/*      Rev 1.32   Nov 30 2005 10:52:02   zf297a
/*   Added interface for BomDetail
/*
/*      Rev 1.31   Nov 10 2005 10:12:18   zf297a
/*   Added interface deleteInvalidParts
/*
/*      Rev 1.30   Nov 09 2005 11:09:56   zf297a
/*   Added interfaces:  wasPartSentYorN, isPartValidYorN, isPlannerCodeAssign2UserIdYorN, and isNslYorN.
/*
/*      Rev 1.29   Oct 27 2005 15:46:38   c402417
/*   Added expected_completion_date in fucntion InsertRepairInfo.
/*
/*      Rev 1.28   Oct 27 2005 10:21:38   zf297a
/*   Added interfaces deletePartInfo, which can be used to generate deletes for all parts or a set of test parts.  Added interface getTimeToRepair, so this previously private function is now a public function and so it can be tested using Toad's debugger.
/*
/*      Rev 1.27   Oct 19 2005 10:21:34   zf297a
/*   removed interface for insertTmpA2AOrderInfoLine and changed the interface for insertTmpA2AOrderInfo.   insertTmpA2AOrderInfo will now insert both the tmp_a2a_order_info and tmp_a2a_order_info_line.
/*
/*      Rev 1.26   Oct 10 2005 09:32:16   zf297a
/*   Added price to insertPartInfo and updatePartInfo
/*
/*      Rev 1.25   Oct 07 2005 12:18:22   zf297a
/*   Added cage_code to tmp_a2a_order_info and tmp_a2a_part_lead_time.  Created a separate procedure to init tmp_a2a_part_lead_time.
/*
/*      Rev 1.24   Sep 09 2005 11:11:22   zf297a
/*   Changed insertInvInfo to use spo_location, which comes from amd_spare_networks.spo_location.  However, the a2a transactions still refers to it as site_location so that name is left along for the tmp_a2a_inv_info table.
/*
/*      Rev 1.24   Aug 19 2005 12:36:10   zf297a
/*   removed functions bizDays2CalendarDays, months2CalendarDays, and getSiteLocation and put them in amd_utils
/*
/*      Rev 1.23   Aug 16 2005 14:28:56   zf297a
/*   Made getSiteLocation public
/*
/*      Rev 1.22   Aug 15 2005 14:46:22   zf297a
/*   added initA2ASpoUsers
/*
/*      Rev 1.20   Aug 10 2005 09:59:10   zf297a
/*   Added functions convertCleanedOrderLeadTime and convertOrderLeadTime.
/*
/*      Rev 1.19   Aug 04 2005 14:40:36   zf297a
/*   Added interface for insertTmpA2ASpoUsers.
/*
/*      Rev 1.18   Jul 20 2005 07:46:18   zf297a
/*   using only bems_id for a2a for spo users
/*
/*      Rev 1.17   Jul 19 2005 14:18:02   zf297a
/*   added spoUser procedure to create the a2a transactions for the spo_user
/*
/*      Rev 1.16   Jul 11 2005 12:38:40   zf297a
/*   added function initA2AInvInfo
/*
/*      Rev 1.15   Jul 11 2005 12:29:04   zf297a
/*   fixed name of initA2AInTransits
/*
/*      Rev 1.14   Jul 11 2005 12:26:22   zf297a
/*   added function initA2AInTransits
/*
/*      Rev 1.13   Jul 11 2005 12:14:54   zf297a
/*   added function initA2ARepairInfo
/*
/*      Rev 1.12   Jul 11 2005 11:47:48   zf297a
/*   added procedure insertTmpA2AInTransits
/*
/*      Rev 1.11   Jul 11 2005 11:16:52   zf297a
/*   Made wasPartSent and isPartValid public functions
/*
/*      Rev 1.9   Jul 11 2005 10:37:38   zf297a
/*   added procedure to insertTmpA2AOrderInfo and insertTmpA2AOrderInfoLine
/*
/*      Rev 1.8   Jun 22 2005 15:03:32   c970183
/*   Made the interface for the inita2aPartInfo more flexible.
/*
/*      Rev 1.7   Jun 10 2005 11:20:04   c970183
/*   Streamlined insertSiteRespAssetMgr, insertInvInfo, and insertRepairInfo.
/*
/*      Rev 1.6   May 18 2005 08:57:04   c970183
/*   Added getIndenture public method.  Modified inita2a to use getIndenture.
/*
/*      Rev 1.5   May 13 2005 14:39:32   c970183
/*   For a given part_no create an update transaction in tmp_a2a_part_info.  action_code may be overridden too.
/*
/*      Rev 1.4   Apr 22 2005 08:05:10   c970183
/*   Added debug code.  Added mArgs: a global variable containing the list of arguments to any public function or procedure.
/*
/*      Rev 1.2   27 Aug 2004 14:33:06   c970183
/*   Added s 'NEW BUY', 'REPAIR', and 'ORDER'.
/*
/*      Rev 1.1   12 Aug 2004 14:30:48   c970183
/*   added insert, update, and delete functions for a2a tables.  implemented insert functions for part data.
/*
/*      Rev 1.0   Jul 19 2004 14:10:48   c970183
/*   Initial revision.
    */
	 SUCCESS 		  CONSTANT NUMBER := 0 ;
	 FAILURE 		  CONSTANT NUMBER := 4 ;
	 NEW_BUY 		  CONSTANT tmp_a2a_loc_part_lead_time.LEAD_TIME_TYPE%type := 'NEW-BUY' ;
	 REPAIR  		  CONSTANT tmp_a2a_loc_part_lead_time.LEAD_TIME_TYPE%type := 'REPAIR' ;
	 AN_ORDER 		  CONSTANT tmp_a2a_part_pricing.PRICE_TYPE%type := 'ORDER' ;
	 OPEN_STATUS 	  CONSTANT tmp_a2a_repair_info.STATUS%type   := 'O' ;
	 THIRD_PARTY_FLAG CONSTANT tmp_a2a_part_info.THIRD_PARTY_FLAG%type := '?' ;
	 
	 APPLICATION_ERROR EXCEPTION ;
	
	 mDebug BOOLEAN := FALSE ; -- allow debugging to be turned on or off at the package level
	 
	  TYPE partInfoRec IS RECORD (
	 	  mfgr 		  AMD_SPARE_PARTS.mfgr%TYPE, 
	      part_no	  AMD_SPARE_PARTS.part_no%TYPE,
	      NOMENCLATURE AMD_SPARE_PARTS.nomenclature%TYPE,
	      nsn		   AMD_SPARE_PARTS.nsn%TYPE,
	      order_lead_time AMD_SPARE_PARTS.order_lead_time%TYPE,
	      order_lead_time_defaulted AMD_SPARE_PARTS.order_lead_time_defaulted%TYPE,
	      unit_cost					AMD_SPARE_PARTS.unit_cost%TYPE,
	      unit_cost_defaulted		AMD_SPARE_PARTS.unit_cost_defaulted%TYPE,
	      unit_of_issue				AMD_SPARE_PARTS.unit_of_issue%TYPE,
	      unit_cost_cleaned			AMD_NATIONAL_STOCK_ITEMS.unit_cost_cleaned%TYPE,
	      order_lead_time_cleaned	AMD_NATIONAL_STOCK_ITEMS.order_lead_time_cleaned%TYPE,
	      planner_code				AMD_NATIONAL_STOCK_ITEMS.planner_code%TYPE,
	      planner_code_cleaned		AMD_NATIONAL_STOCK_ITEMS.planner_code_cleaned%TYPE,
	      mtbdr						AMD_NATIONAL_STOCK_ITEMS.mtbdr%TYPE,
	      mtbdr_cleaned				AMD_NATIONAL_STOCK_ITEMS.mtbdr_cleaned%TYPE,
	      smr_code					AMD_NATIONAL_STOCK_ITEMS.smr_code%TYPE,
	      smr_code_cleaned			AMD_NATIONAL_STOCK_ITEMS.smr_code_cleaned%TYPE,
	      smr_code_defaulted		AMD_NATIONAL_STOCK_ITEMS.smr_code_defaulted%TYPE,
	      nsi_sid					AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE,
	      TIME_TO_REPAIR_OFF_BASE_CLEAND AMD_NATIONAL_STOCK_ITEMS.TIME_TO_REPAIR_OFF_BASE_CLEAND%TYPE,
		  last_update_dt			AMD_SPARE_PARTS.last_update_dt%TYPE,
		  action_code				AMD_SPARE_PARTS.action_code%TYPE
	) ;
	
	TYPE part2Delete IS RECORD (
	 	  part_no AMD_SPARE_PARTS.part_no%TYPE,
		  nomenclature AMD_SPARE_PARTS.nomenclature%TYPE
	) ;
	
	
	 TYPE partCur IS REF CURSOR RETURN partInfoRec ;
	 TYPE onHandInvSumCur IS REF CURSOR RETURN AMD_ON_HAND_INVS_SUM%ROWTYPE ;
	 TYPE repairInvInfoCur IS REF CURSOR RETURN AMD_REPAIR_INVS_SUM%ROWTYPE ;
	 TYPE inTransitsCur IS REF CURSOR RETURN AMD_IN_TRANSITS_SUM%ROWTYPE ;
	 TYPE inRepairCur IS REF CURSOR RETURN AMD_IN_REPAIR%ROWTYPE ;
	 TYPE onOrderCur IS REF CURSOR RETURN AMD_ON_ORDER%ROWTYPE ;
	 TYPE part2DeleteCur IS REF CURSOR RETURN part2Delete ;
	 TYPE bomDetailCur IS REF CURSOR RETURN AMD_SENT_TO_A2A%ROWTYPE ;
	 TYPE backOrderCur IS REF CURSOR RETURN AMD_BACKORDER_SUM%ROWTYPE ;
	 type extForecastCur is ref cursor return amd_part_loc_forecasts%rowtype ;
	 
	 PROCEDURE processParts(parts IN partCur) ;
	 PROCEDURE processPartLeadTimes(parts IN partCur) ;
	 PROCEDURE processOnHandInvSum(onHandInvSum IN onHandInvSumCur) ;
	 PROCEDURE processRepairInvInfo(repairInvInfo IN repairInvInfoCur) ;
	 PROCEDURE processInTransits(inTransits IN inTransitsCur) ;
	 PROCEDURE processInRepair(inRepair IN inRepairCur) ;
	 PROCEDURE processOnOrder(onOrder IN onOrderCur) ;
	 PROCEDURE deletePartInfo(partInfo IN part2DeleteCur) ;
	 PROCEDURE processBomDetail(bomDetail IN bomDetailCur) ;
	 PROCEDURE processBackOrder(backOrder IN backOrderCur) ;
	 PROCEDURE processExtForecast(extForecast IN extForecastCur) ;
	
	
	
	
	 FUNCTION getIndenture(smr_code_preferred IN AMD_NATIONAL_STOCK_ITEMS.SMR_CODE%TYPE) RETURN TMP_A2A_PART_INFO.indenture%TYPE ;
	
	 FUNCTION getAssignedPlannerCode(part_no IN TMP_A2A_PART_INFO.part_no%TYPE,
	 		  planner_code IN AMD_PLANNERS.planner_code%TYPE) RETURN AMD_PLANNERS.planner_code%TYPE  ;
	
	 FUNCTION createPartInfo(part_no IN VARCHAR2,
	        action_code IN VARCHAR2 := Amd_Defaults.UPDATE_ACTION) RETURN NUMBER ;
	
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
		   price IN NUMBER) RETURN NUMBER;
	
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
		   price IN NUMBER) RETURN NUMBER;
	
	 FUNCTION DeletePartInfo(
	       part_no IN VARCHAR2, nomenclature IN VARCHAR2) RETURN NUMBER ;
	
	 FUNCTION InsertPartLeadTime(
	        part_no IN VARCHAR2,
	       lead_time_type IN VARCHAR2,
	       lead_time IN NUMBER) RETURN NUMBER;
	
	 FUNCTION UpdatePartLeadTime(
	        part_no IN VARCHAR2,
	       lead_time_type IN VARCHAR2,
	       lead_time IN NUMBER) RETURN NUMBER;
	
	 FUNCTION DeletePartLeadTime(
	        part_no IN VARCHAR2) RETURN NUMBER;
	
	 FUNCTION InsertPartPricing(
	        part_no IN VARCHAR2,
	       price_type IN VARCHAR2,
	       unit_cost IN NUMBER) RETURN NUMBER;
	
	 FUNCTION UpdatePartPricing(
	        part_no IN VARCHAR2,
	       price_type IN VARCHAR2,
	       unit_cost IN NUMBER) RETURN NUMBER;
	
	 FUNCTION DeletePartPricing(
	        part_no IN VARCHAR2) RETURN NUMBER ;
	
	
	 FUNCTION InsertLocPartLeadTime(
	        part_no IN VARCHAR2,
	       loc_sid IN NUMBER,
	       location_name IN VARCHAR2,
	       lead_time_type IN VARCHAR2,
	       time_to_repair IN NUMBER) RETURN NUMBER;
	
	 FUNCTION UpdateLocPartLeadTime(
	        part_no IN VARCHAR2,
	       loc_sid IN NUMBER,
	       location_name IN VARCHAR2,
	       lead_time_type IN VARCHAR2,
	       time_to_repair IN NUMBER) RETURN NUMBER;
	
	 FUNCTION DeleteLocPartLeadTime(
	        part_no IN VARCHAR2,
	       loc_sid IN NUMBER,
	       location_name IN NUMBER) RETURN NUMBER;
	
	 PROCEDURE insertSiteRespAssetMgr(
	        assetMgr IN TMP_A2A_SITE_RESP_ASSET_MGR.SITE_RESP_ASSET_MGR%TYPE,
	       logonId  IN TMP_A2A_SITE_RESP_ASSET_MGR.TOOL_LOGON_ID%TYPE,
	       action_code IN TMP_A2A_SITE_RESP_ASSET_MGR.action_code%TYPE,
		   data_source in tmp_a2a_site_resp_asset_mgr.DATA_SOURCE%type) ;
		   
	    PROCEDURE deleteAllSiteRespAssetMgr  ;
	 PROCEDURE initSiteRespAssetMgr ;
	
	 procedure initA2ADemands ;
	
	 PROCEDURE initA2ASpoUsers ;
	
	
	 FUNCTION initA2APartInfo(useTestParts IN BOOLEAN := FALSE) RETURN NUMBER ;
	
	 FUNCTION initA2AOrderInfo(useTestParts IN BOOLEAN := FALSE) RETURN NUMBER ;
	
	 FUNCTION initA2ARepairInfo(useTestParts IN BOOLEAN := FALSE) RETURN NUMBER ;
	
	 FUNCTION initA2AInTransits(useTestParts IN BOOLEAN := FALSE) RETURN NUMBER ;
	
	 FUNCTION initA2AInvInfo(useTestParts IN BOOLEAN := FALSE) RETURN NUMBER ;
	
	 FUNCTION initA2ARepairInvInfo(useTestParts IN BOOLEAN := FALSE) RETURN NUMBER ;
	 
	
	  PROCEDURE insertRepairInvInfo(part_no IN TMP_A2A_REPAIR_INV_INFO.part_no%TYPE,
	    site_location IN TMP_A2A_REPAIR_INV_INFO.site_location%TYPE,
	    inv_qty IN TMP_A2A_REPAIR_INV_INFO.QTY_ON_HAND%TYPE,
	    action_code IN TMP_A2A_REPAIR_INV_INFO.action_code%TYPE)  ;
	
	 PROCEDURE insertInvInfo(part_no IN TMP_A2A_INV_INFO.part_no%TYPE,
	    spo_location IN TMP_A2A_INV_INFO.site_location%TYPE ,
	    qty_on_hand IN TMP_A2A_INV_INFO.QTY_ON_HAND%TYPE,
	    action_code IN TMP_A2A_INV_INFO.action_code%TYPE)  ;
	
	 PROCEDURE insertRepairInfo(part_no IN TMP_A2A_REPAIR_INFO.part_no%TYPE,
	    loc_sid IN NUMBER,
	    doc_no IN TMP_A2A_REPAIR_INFO.doc_no%TYPE, -- order_sid
	    repair_date IN TMP_A2A_REPAIR_INFO.repair_date%TYPE,
	    status IN TMP_A2A_REPAIR_INFO.status%TYPE,
	    quantity IN TMP_A2A_REPAIR_INFO.quantity%TYPE /* repair_qty */,
		expected_completion_date IN TMP_A2A_REPAIR_INFO.expected_completion_date%TYPE,
	    action_code IN TMP_A2A_REPAIR_INFO.action_code%TYPE) ;
	
	 PROCEDURE insertTmpA2AOrderInfo(gold_order_number IN AMD_ON_ORDER.GOLD_ORDER_NUMBER%TYPE,
	     loc_sid IN AMD_ON_ORDER.LOC_SID%TYPE,
	     order_date IN AMD_ON_ORDER.ORDER_DATE%TYPE,
	     part_no IN AMD_ON_ORDER.PART_NO%TYPE,
	     order_qty IN AMD_ON_ORDER.ORDER_QTY%TYPE,
		 sched_receipt_date IN AMD_ON_ORDER.SCHED_RECEIPT_DATE%TYPE,
	     action_code IN TMP_A2A_ORDER_INFO.action_code%TYPE) ;
	
	
	  PROCEDURE insertTmpA2AInTransits(part_no IN AMD_IN_TRANSITS_SUM.part_no%TYPE,
	       site_location    IN AMD_IN_TRANSITS_SUM.site_location%TYPE,
	       quantity      IN AMD_IN_TRANSITS_SUM.quantity%TYPE,
	       serviceable_flag  IN AMD_IN_TRANSITS_SUM.serviceable_flag%TYPE,
	       action_code   IN TMP_A2A_IN_TRANSITS.action_code%TYPE) ;
	
	  FUNCTION wasPartSent(partNo IN AMD_SPARE_PARTS.part_no%TYPE) RETURN BOOLEAN ;
	  FUNCTION wasPartSentYorN(partNo IN AMD_SPARE_PARTS.part_no%TYPE) RETURN VARCHAR2 ;
	  FUNCTION isPartValid (partNo IN AMD_SPARE_PARTS.part_no%TYPE, showReason in boolean := false) RETURN BOOLEAN ;
	  FUNCTION isPartValidYorN(partNo IN AMD_SPARE_PARTS.part_no%TYPE, showReason in varchar2 := 'N') RETURN VARCHAR2 ;
	  FUNCTION isPlannerCodeAssigned2UserId(plannerCode IN VARCHAR2) RETURN BOOLEAN ;
	  FUNCTION isPlannerCodeAssign2UserIdYorN(plannerCode IN VARCHAR2) RETURN VARCHAR2 ;
	  FUNCTION isNsl(partNo IN AMD_SPARE_PARTS.part_no%TYPE) RETURN BOOLEAN ;
	  FUNCTION isNslYorN(partNo IN AMD_SPARE_PARTS.part_no%TYPE) RETURN VARCHAR2 ;
	
	   PROCEDURE spoUser(bems_id IN TMP_A2A_SPO_USERS.BEMS_ID%TYPE,
	  action_code IN TMP_A2A_SPO_USERS.ACTION_CODE%TYPE) ;
	
	PROCEDURE insertTmpA2ASpoUsers(bems_id IN TMP_A2A_SPO_USERS.bems_id%TYPE,
	       stable_email     IN TMP_A2A_SPO_USERS.EMAIL%TYPE,
	       last_name      IN VARCHAR2,
	       first_name  IN VARCHAR2,
	       action_code   IN TMP_A2A_IN_TRANSITS.action_code%TYPE) ;
	
	 PROCEDURE initA2APartLeadTime(useTestParts IN BOOLEAN := FALSE) ;
	 
	 PROCEDURE initA2ABomDetail(useTestParts IN BOOLEAN := FALSE) ;
	
	 PROCEDURE deletePartInfo(useTestParts IN BOOLEAN := FALSE) ;
	
	 FUNCTION getTimeToRepair(loc_sid  IN AMD_IN_REPAIR.loc_sid%TYPE,
	 		  part_no IN VARCHAR2) RETURN AMD_PART_LOCS.time_to_repair%TYPE ;
	
	 PROCEDURE deleteInvalidParts (testOnly IN BOOLEAN := FALSE) ;
	
	PROCEDURE populateBomDetail(part_no IN TMP_A2A_BOM_DETAIL.part_no%TYPE,
			  included_part IN TMP_A2A_BOM_DETAIL.INCLUDED_PART%TYPE,
			  action_code IN TMP_A2A_BOM_DETAIL.action_code%TYPE,
			  quantity IN TMP_A2A_BOM_DETAIL.QUANTITY%TYPE := Amd_Defaults.BOM_QUANTITY,
			  bom IN TMP_A2A_BOM_DETAIL.BOM%TYPE := Amd_Defaults.BOM,
			  begin_date IN TMP_A2A_BOM_DETAIL.BEGIN_DATE%TYPE := NULL,
			  end_date IN TMP_A2A_BOM_DETAIL.end_date%TYPE := NULL) ;
			  
	 START_DT constant DATE := TO_DATE('01/01/1990','MM/DD/YYYY') ;
	 
	 PROCEDURE initA2AInvInfo(from_dt IN DATE := start_dt, to_dt IN DATE := SYSDATE) ;
	 PROCEDURE initA2ARepairInvInfo(from_dt IN DATE := start_dt, to_dt IN DATE := SYSDATE) ;
	 PROCEDURE initA2AInTransits(from_dt IN DATE := start_dt, to_dt IN DATE := SYSDATE) ;
	 PROCEDURE initA2ARepairInfo(from_dt IN DATE := start_dt, to_dt IN DATE := SYSDATE) ;
	 PROCEDURE initA2AOrderInfo(from_dt IN DATE := start_dt, to_dt IN DATE := SYSDATE) ;
	 PROCEDURE initA2APartInfo(from_dt IN DATE := start_dt, to_dt IN DATE := SYSDATE) ;
	 PROCEDURE initA2ABomDetail(from_dt IN DATE := start_dt, to_dt IN DATE := SYSDATE ) ;
	 
	 PROCEDURE initA2ABackorderInfo(from_dt IN DATE := start_dt, to_dt IN DATE := SYSDATE ) ;
	 PROCEDURE initA2ABackorderInfo(useTestParts IN BOOLEAN := FALSE ) ;
	 
	 PROCEDURE initA2AExtForecast(from_dt IN DATE := start_dt, to_dt IN DATE := SYSDATE) ;
	 PROCEDURE initA2AExtForecast(useTestParts IN BOOLEAN := FALSE ) ;
	
	 PROCEDURE loadAll(startStep IN NUMBER := 1, endStep IN NUMBER := 15, debugIt IN BOOLEAN := FALSE, system_id IN AMD_BATCH_JOBS.SYSTEM_ID%TYPE := 'LOAD_ALL_A2A') ;
	 FUNCTION getSendAllData RETURN BOOLEAN ;
	 PROCEDURE setSendAllData(theIndicator IN BOOLEAN) ;
	 PROCEDURE version ;
	 
	 FUNCTION includeOrder(gold_order_number IN AMD_ON_ORDER.gold_order_number%TYPE, 
	 		  			  order_date IN AMD_ON_ORDER.order_date%TYPE,
						  part_no in amd_on_order.part_no%type) RETURN BOOLEAN ;
						  
	 FUNCTION getDueDate(part_no in AMD_ON_ORDER.PART_NO%TYPE, order_date in AMD_ON_ORDER.ORDER_DATE%TYPE)  RETURN DATE ;
	-- added 10/20/2006 by dse
	 function isPartSent(part_no in amd_sent_to_a2a.part_no%type) return boolean ;
	-- added 10/20/2006 by dse
	 function isPartSentYorN(part_no in amd_sent_to_a2a.part_no%type) return varchar2 ;
	 -- added functions to return constants 10/25/2006 by dse
	 function getStart_dt return date ;
	 function getNEW_BUY return tmp_a2a_loc_part_lead_time.LEAD_TIME_TYPE%type ; 
	 function getREPAIR  return tmp_a2a_loc_part_lead_time.lead_time_type%type ;
	 function getAN_ORDER return tmp_a2a_part_pricing.PRICE_TYPE%type ;
	 function getOPEN_STATUS return tmp_a2a_repair_info.STATUS%type ;
	 function getTHIRD_PARTY_FLAG return tmp_a2a_part_info.THIRD_PARTY_FLAG%type ;
	 -- added 10/26/2006 by dse
	 procedure deleteSentToA2AChildren ;

END A2a_Pkg ;
/

show errors

CREATE OR REPLACE PACKAGE AMD_LOCATION_PART_LEADTIME_PKG AS
/*
      $Author:   zf297a  $
    $Revision:   1.9  $
	    $Date:   Oct 25 2006 09:56:32  $
    $Workfile:   AMD_LOCATION_PART_LEADTIME_PKG.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_LOCATION_PART_LEADTIME_PKG.pks.-arc  $
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
	
	-- added get functions to return constants 10/25/2006 by dse
	function getVIRTUAL_COD_SPO_LOCATION return amd_spare_networks.spo_location%type ;
	function getVIRTUAL_UAB_SPO_LOCATION return amd_spare_networks.spo_location%type ;
	function getUK_LOCATION 			 return amd_spare_networks.LOC_ID%type ;
	function getBASC_LOCATION			 return amd_spare_networks.LOC_ID%type ;	
	function getLEADTIMETYPE 			 return tmp_a2a_loc_part_lead_time.LEAD_TIME_TYPE%type ;
	function getBULKLIMIT 	 		  	 return number ;

END AMD_LOCATION_PART_LEADTIME_PKG ;
/

show errors

ALTER TABLE AMD_OWNER.AMD_SENT_TO_A2A ADD (
  CONSTRAINT AMD_SENT_TO_A2A_FK03 
 FOREIGN KEY (SPO_PRIME_PART_NO) 
 REFERENCES AMD_OWNER.AMD_SENT_TO_A2A (PART_NO));
/

show errors

CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_SENT_TO_A2A_AFTER_TRIG
AFTER UPDATE
ON AMD_OWNER.AMD_SENT_TO_A2A 
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
/***
      $Author:   zf297a  $
    $Revision:   1.4  $
	    $Date:   Oct 20 2006 12:24:40  $
    $Workfile:   AMD_SENT_TO_A2A_AFTER_TRIG.trg  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Triggers\AMD_SENT_TO_A2A_AFTER_TRIG.trg-arc  $
/*   
/*      Rev 1.4   Oct 20 2006 12:24:40   zf297a
/*   Fixed time format - MI for minutes not MM which is the format for months.
/*   
/*      Rev 1.3   Nov 30 2005 11:04:04   zf297a
/*   use a2a_pkg.populateBomDetail procedure
/*   
/*      Rev 1.2   Sep 21 2005 11:24:48   zf297a
/*   Added populateBomDetail
/*   
/*      Rev 1.1   Jul 15 2005 11:51:06   zf297a
/*   changed range_from and range_to to all upper case.
/*   
/*      Rev 1.0   Jul 11 2005 15:10:24   zf297a
/*   Initial revision.
*/		 
	PROCEDURE errorMsg(sqlFunction IN VARCHAR2, 
			  tableName IN VARCHAR2, 
			  location IN NUMBER) IS
	BEGIN
		dbms_output.put_line('sqlcode('||SQLCODE||') sqlerrm('|| SQLERRM||')') ;
		dbms_output.put_line('part_no=' || :NEW.part_no || ' action_code=' || :NEW.action_code) ;
		Amd_Utils.InsertErrorMsg (
				pLoad_no => Amd_Utils.GetLoadNo(pSourceName => SUBSTR(sqlFunction,1,20),
						                        pTableName  => SUBSTR(tableName,1,20)),
				pData_line_no => location,
				pData_line    => 'amd_sent_to_a2a_after_trig', 
				pKey_1 => SUBSTR(:NEW.part_no,1,50),
				pKey_2 => SUBSTR(:NEW.action_code,1,50),
				pKey_5 => TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS'),
				pComments => SUBSTR('sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')',1,2000));
	END ErrorMsg;
	
	
	PROCEDURE populatePartEffectivity IS
	BEGIN
		 INSERT INTO TMP_A2A_PART_EFFECTIVITY
		 (part_no, mdl, series, effectivity_type, range_from, range_to, range_flag, qpei, customer, action_code, last_update_dt)
		 VALUES
		 (:NEW.spo_prime_part_no, 'C17', 'A', 'P', 'C17FULL','C17FULL','B','1','AF', :NEW.action_code, SYSDATE) ;
	EXCEPTION
		 WHEN standard.DUP_VAL_ON_INDEX THEN
		 	  BEGIN
			 	  UPDATE TMP_A2A_PART_EFFECTIVITY
				  SET action_code = :NEW.action_code,
				  last_update_dt = SYSDATE
				  WHERE part_no = :NEW.spo_prime_part_no ;
			  EXCEPTION WHEN OTHERS THEN
			  	  errormsg(sqlFunction => 'update',
				    tableName => 'tmp_a2a_part_effectivity',
					location => 10) ;
			  END ;
	     WHEN OTHERS THEN
		   errormsg(sqlFunction => 'insert',
		     tableName => 'tmp_a2a_part_effectivity',
			 location => 20) ;
	       RAISE;
		 
	END populatePartEffectivity ;

PROCEDURE populateBomDetail IS
	BEGIN
		 a2a_pkg.populateBomDetail(part_no => :NEW.spo_prime_part_no,
		 	included_part => :NEW.spo_prime_part_no,
			action_code => :NEW.action_code) ;
	END populateBomDetail ; 
BEGIN
	IF :NEW.spo_prime_part_no IS NOT NULL THEN
		populatePartEffectivity ;
		populateBomDetail ;
	END IF ;
EXCEPTION WHEN OTHERS THEN	 
	errorMsg(sqlFunction => 'populate', 
		tableName => 'bom & effectivity', 
		location => 30) ;
	RAISE;
END ;
/

show errors
CREATE OR REPLACE PACKAGE AMD_PART_LOC_FORECASTS_PKG AS
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

CREATE OR REPLACE PACKAGE amd_load as
    /*
	    PVCS Keywords

       $Author:   zf297a  $
     $Revision:   1.16  $
         $Date:   Oct 31 2006 14:45:08  $
     $Workfile:   amd_load.pks  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_load.pks-arc  $
   
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

CREATE OR REPLACE PACKAGE BODY AMD_LOAD AS

    /*
	    PVCS Keywords

       $Author:   zf297a  $
     $Revision:   1.45  $
         $Date:   Oct 31 2006 14:45:18  $
     $Workfile:   amd_load.pkb  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_load.pkb-arc  $
   
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

	mDebug	 			   BOOLEAN := FALSE ;

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
		commitThreshold CONSTANT NUMBER := 1000 ;
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
			IF MOD(rowsInserted,commitThreshold) = 0 THEN
			   COMMIT ;
			   dbms_output.put_line('committed last ' || commitThreshold || ' inserts.') ;
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

	procedure createSiteRespAssetMgrA2ATran(planner_code in varchar2, logon_id in varchar2, data_source in varchar2) is
			 cursor planners is
			 		select data_source, logon_id  
			  		from amd_planner_logons 
			  		where planner_code = createSiteRespAssetMgrA2ATran.planner_code 
			  		order by data_source ;
	begin
		 begin
		 	  for rec in planners loop
				 A2a_Pkg.insertSiteRespAssetMgr(assetMgr => createSiteRespAssetMgrA2ATran.planner_code, 
				        logonId => rec.logon_id,
				 		data_source => rec.data_source,
				 		action_code => Amd_Defaults.INSERT_ACTION) ;
				 exit when 1 = 1 ;			  	  
			  end loop ;
		 end ;
		
	end createSiteRespAssetMgrA2Atran ;
	
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

 		createSiteRespAssetMgrA2Atran(insertPlannerLogons.planner_code, insertPlannerLogons.logon_id, insertPlannerLogons.data_source) ;
		 
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

		createSiteRespAssetMgrA2Atran(updatePlannerLogons.planner_code, updatePlannerLogons.logon_id, updatePlannerLogons.data_source) ;
		
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
		 		pError_location => 360, pKey1 => 'amd_load', pKey2 => '$Revision:   1.45  $') ;
		 dbms_output.put_line('amd_load: $Revision:   1.45  $') ;
	end version ;
	
	procedure validatePartStructure is
			  cursor NoNsn4SpareParts is
			  		 select * from amd_spare_parts where nsn is null ;
			  cursor NoNsn4Items is
			  		 select * from amd_National_Stock_Items where nsn is null ;
			  cursor NoPrimePart is
			  		 select * from amd_national_stock_items where prime_part_no is null ; 
			  
			  cntNoNsnParts number := 0 ;
			  cntNoNsnItems number := 0 ;
			  cntNoPrimePart number := 0 ;
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
		 dbms_output.put_line('cntNoNsnParts=' || cntNoNsnParts) ;
		 dbms_output.put_line('cntNoNsnItems=' || cntNoNsnItems) ;
		 dbms_output.put_line('cntNoPrimePart=' || cntNoPrimePart) ;
		 writeMsg(pTableName => 'amd_spare_parts', pError_location => 390,
		 		pKey1 => 'cntNoNsnParts=' || to_char(cntNoNsnParts)) ;
		 writeMsg(pTableName => 'amd_national_stock_items', pError_location => 400,
		 		pKey1 => 'cntNoNsnItems=' || to_char(cntNoNsnItems)) ;
		 writeMsg(pTableName => 'amd_national_stock_items', pError_location => 410,
		 		pKey1 => 'cntNoPrimePart=' || to_char(cntNoPrimePart)) ;
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

CREATE OR REPLACE PACKAGE BODY AMD_PART_LOC_FORECASTS_PKG AS
 /*
      $Author:   zf297a  $
	$Revision:   1.22  $
        $Date:   Nov 01 2006 11:39:12  $
    $Workfile:   AMD_PART_LOC_FORECASTS_PKG.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_PART_LOC_FORECASTS_PKG.pkb.-arc  $
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
	begin
	 		 /* spec denotes specific format of month Mon DD, YYYY  that will be in best spares
			 	text field */
			 result := false ;
			 str := lockName ;
			 
		   	 IF owa_pattern.match(str, '(\w \d{2}, \d{4})(.*)') THEN
		   	  	  owa_pattern.CHANGE(str, '(\w \d{2}, \d{4})(.*)', '\1') ;
				  begin
		   		  	   theDate := to_date(str, 'Mon DD, YYYY') ;
					   result := true ;
				  exception when others then
				  	   result := false ;				  		
				  end ;
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
	
		if pActionCode = amd_defaults.DELETE_ACTION and a2a_pkg.wasPartSent(pPartNo) then
		   insertTmpA2A ;
		else
		    if (a2a_pkg.isPartValid(pPartNo) or a2a_pkg.getSendAllData) and a2a_pkg.wasPartSent(pPartNo) then
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
			 	 InsertTmpA2A_EF (pPartNo, pLocation, DEMAND_FORECAST_TYPE, add_months(period, i), pQty, pActionCode, pLastUpdateDt, 60 ) ;
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
						60 -- duplicate
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
		 		pError_location => 280, pKey1 => 'amd_part_loc_forecasts_pkg', pKey2 => '$Revision:   1.22  $') ;
		 dbms_output.put_line('amd_part_loc_forecasts_pkg: $Revision:   1.22  $') ;
	end version ;
	
END AMD_PART_LOC_FORECASTS_PKG ;
/

show errors

CREATE OR REPLACE PACKAGE BODY A2a_Pkg AS
 --
 -- SCCSID:   %M%   %I%   Modified: %G%  %U%
 --
 /*
      $Author:   zf297a  $
	$Revision:   1.144  $
     $Date:   Nov 01 2006 12:52:18  $
    $Workfile:   A2A_PKG.PKB  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\A2A_PKG.PKB-arc  $
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
		  IF key5 = '' THEN
		     key5 := pSqlFunction || '/' || pTableName ;
		  ELSE
		   key5 := key5 || ' ' || pSqlFunction || '/' || pTableName ;
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
		   
		   action_code tmp_a2a_part_lead_time.action_code%type := getActionCode(part_no) ;
		      
		   
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
				  nsi.action_code
			  FROM AMD_SPARE_PARTS sp,
			    AMD_NATIONAL_STOCK_ITEMS nsi
			  WHERE sp.nsn = nsi.nsn
			     AND sp.action_code != Amd_Defaults.DELETE_ACTION ;
				 
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
				  nsi.action_code
			  FROM AMD_SPARE_PARTS sp,
			    AMD_NATIONAL_STOCK_ITEMS nsi
			  WHERE sp.nsn = nsi.nsn
			     AND sp.action_code != Amd_Defaults.DELETE_ACTION
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
			
			IF wasPartSent(rec.part_no) THEN
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
		action_code tmp_a2a_part_lead_time.action_code%type := getActionCode(part_no) ;
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
	
	   IF wasPartSent(rec.part_no) THEN
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
	 BEGIN
	      writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 640,
			pKey1 => 'processParts',
			pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  	 
	 	  
		  LOOP
		  	  FETCH parts INTO rec ;
			  EXIT WHEN parts%NOTFOUND ;		
			  processPart(rec) ;
			  cnt := cnt + 1 ;
		      IF MOD(cnt,COMMIT_THRESHOLD) = 0 THEN
		   	   COMMIT ;
		      END IF ;		 
		  END LOOP ;
	      writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 650,
			pKey1 => 'processParts',
			pKey2 => 'cnt=' || TO_CHAR(cnt),
			pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  	 
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
			  WHERE sp.nsn = nsi.nsn  
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
	   IF wasPartSent(partNo => part_no)  THEN
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
	   IF isPartValid(part_no) AND wasPartSent(part_no) THEN
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
	   IF wasPartSent(part_no) THEN
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
			  insertTmpA2ASpoUsers(rec.bems_id, rec.stable_email, rec.last_name, rec.first_Name, Amd_Defaults.INSERT_ACTION) ;
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
	     insertSiteRespAssetMgr(assetMgr => rec.planner_code, logonId => rec.logon_id, action_code => Amd_Defaults.INSERT_ACTION,
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
	
	
	 BEGIN
	  IF wasPartSent(insertInvInfo.part_no)
	     AND spo_location IS NOT NULL THEN
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
	  END IF ;
	
	 EXCEPTION
	     WHEN standard.DUP_VAL_ON_INDEX THEN
	       doUpdate( part_no, spo_location, qty_on_hand, action_code) ;
	  WHEN OTHERS THEN
	     ErrorMsg( pSqlfunction => 'insert', pTableName => 'tmp_a2a_inv_info', pError_location => 1110,
	       pkey_1 => part_no, pKey_2 => spo_location) ;
	     RAISE ;
	
	 END insertInvInfo ;
	
	
	PROCEDURE insertRepairInvInfo(part_no IN TMP_A2A_REPAIR_INV_INFO.part_no%TYPE,
	    site_location IN TMP_A2A_REPAIR_INV_INFO.site_location%TYPE,
	    inv_qty IN TMP_A2A_REPAIR_INV_INFO.QTY_ON_HAND%TYPE,
	    action_code IN TMP_A2A_REPAIR_INV_INFO.action_code%TYPE)  IS
	
	 BEGIN
	  IF wasPartSent(insertRepairInvInfo.part_no)
	     AND site_location IS NOT NULL THEN
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
	  END IF ;
	
	 EXCEPTION
	     WHEN standard.DUP_VAL_ON_INDEX THEN
	    doUpdate( part_no, site_location, inv_qty, action_code) ;
	  WHEN OTHERS THEN
	     ErrorMsg( pSqlfunction => 'insert', pTableName => 'tmp_a2a_repair_inv_info', pError_location => 1120,
	       pkey_1 => part_no, pKey_2 => site_location) ;
	     RAISE ;
	
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
	
	  BEGIN
	   -- added isPartValid test DSE 11/30/05
	   IF isPartValid(insertRepairInfo.part_no) AND wasPartSent(insertRepairInfo.part_no)
		  AND doc_no NOT LIKE 'R%'  
		  AND doc_no NOT LIKE 'II%'
		  AND site_location IS NOT NULL 
	   THEN
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
	  END IF ;
	 EXCEPTION
	   WHEN standard.DUP_VAL_ON_INDEX THEN
	       doUpdate ;
	   WHEN OTHERS THEN
	     errormsg( psqlfunction => 'insert', ptablename => 'tmp_a2a_repair_info', pError_location => 1160,
	 pkey_1 => part_no, pkey_2 => loc_sid, pkey_3 => doc_no, pkey_4 => TO_CHAR(repair_date,'MM/DD/YYYY'),pKeywordValuePairs => 'status=' || status || '  qty=' || quantity || ' action=' || action_code) ;
	     RAISE ;
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
			   and amd_on_order.ORDER_DATE = includeOrder.order_date ;
			   RETURN sched_receipt_date ;
		  EXCEPTION 
		  		WHEN standard.NO_DATA_FOUND THEN
		  			 return null ;
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
				   pKey_4 => iif(sched_receipt_date is null,'NULL',to_char(sched_receipt_date,'MM/DD/YYYY')), 
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
			 		  result NUMBER := 1 ;
			 BEGIN
			 	  SELECT MAX(line) INTO result
				  FROM TMP_A2A_ORDER_INFO_LINE
				  WHERE order_no = insertTmpA2AOrderInfo.gold_order_number
				  AND part_no = insertTmpA2AOrderInfo.part_no ;
				  IF result IS NULL THEN
				  	 RETURN 1 ;
				  ELSE		
				  			RETURN result + 1 ;
				  END IF ;
			 EXCEPTION 
			 		   WHEN standard.NO_DATA_FOUND THEN
			 	  	   		RETURN 1 ;
					   WHEN OTHERS THEN
					     errormsg( psqlfunction => 'select', ptablename => 'tmp_a2a_order_info_line', pError_location => 1200,
					       pkey_1 => gold_order_number, pKey_2 => part_no, pKey_3 => TO_CHAR(order_date,'MM/DD/YYYY HH:MI:SS AM'), pKey_4 => TO_CHAR(lineNumber)) ;
					     RAISE ;			   
			 END getNextLineNumber ;
		 
		BEGIN
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
			       pkey_1 => gold_order_number) ;
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
		   lineOfCode := 1 ;
		   IF wasPartSent(insertTmpA2AOrderInfo.part_no) AND site_location IS NOT NULL THEN
			lineOfCode := 2 ; 
			IF includeOrder(gold_order_number => gold_order_number,order_date => order_date,
							part_no => insertTmpA2AOrderInfo.part_no) THEN
				lineOfCode := 3 ;
				includeCnt := includeCnt + 1 ;
				declare
					   sent_action_code amd_sent_to_a2a.action_code%type  ;
					   theAction tmp_a2a_order_info_line.action_code%type ;
				begin
					 select action_code into sent_action_code from amd_sent_to_a2a where part_no = insertTmpA2AOrderInfo.part_no ;
					 -- a deleted order should be deleted from the SPO
					 -- a part that has been deleted from SPO should have its order deleted too
					 if insertTmpA2AOrderInfo.action_code = amd_defaults.DELETE_ACTION or sent_action_code = amd_defaults.DELETE_ACTION then
					 	theAction := amd_defaults.DELETE_ACTION ; 
					 else
					 	 theAction := insertTmpA2AOrderInfo.action_code ; 
					 end if ;						
					 doInsert(theAction) ; 
		 			 insertTmpA2AOrderInfoLine(theAction) ;
				end ;
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
	
	 BEGIN
	  IF quantity > 0 
	  AND wasPartSent(insertTmpA2AInTransits.part_no)
	  AND isPartValid(insertTmpA2AInTransits.part_no) -- added isPartValid DSE 11/30/05 
	  AND site_location IS NOT NULL  THEN
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
	  END IF ;
	  -- added exception handlers DSE 11/30/05
	 EXCEPTION
	 		  WHEN standard.DUP_VAL_ON_INDEX THEN
			  	   doUpdate ;
			  WHEN OTHERS THEN 
			      errormsg( psqlfunction => 'insert', ptablename => 'tmp_a2a_in_transits', pError_location => 1270,
			        pkey_1 => insertTmpA2AInTransits.part_no, pKey_2 => insertTmpA2AInTransits.site_location) ;
			      RAISE ;
			  	   
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
			   WHERE part_no = rec.part_no
			   AND site_location = processBackorder.site_location
			   AND loc_sid = rec.loc_sid ;
		   EXCEPTION WHEN OTHERS THEN
			    errormsg( psqlfunction => 'update', ptablename => 'tmp_a2a_backorder_info', pError_location => 1430,
			        pkey_1 => rec.part_no, pkey_2 => TO_CHAR(rec.loc_sid), pkey_3 => site_location) ;
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
				(rec.part_no, rec.loc_sid, site_location, rec.qty, rec.action_code, rec.last_update_dt);
		EXCEPTION 
			WHEN standard.DUP_VAL_ON_INDEX THEN
				doUpdate ;
			WHEN OTHERS THEN
			    errormsg( psqlfunction => 'insert', ptablename => 'tmp_a2a_backorder_info', pError_location => 1440,
			        pkey_1 => rec.part_no, pkey_2 => TO_CHAR(rec.loc_sid), pkey_3 => site_location) ;
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
				  bo.PART_NO,         
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
		  	  AND bo.part_no = sent.part_no
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
				  bo.PART_NO,         
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
			  bo.part_no = testParts.part_no 
		  	  AND bo.part_no = sent.part_no
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
				  bo.PART_NO,         
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
			  WHERE bo.part_no = sent.part_no
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
			 		pError_location => 1560, pKey1 => 'a2a_pkg', pKey2 => '$Revision:   1.144  $') ;
		 	 dbms_output.put_line('a2a_pkg: $Revision:   1.144  $') ;
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

CREATE OR REPLACE PACKAGE BODY Amd_Utils AS
/*
       $Author:   zf297a  $
     $Revision:   1.39  $
         $Date:   Oct 13 2006 12:57:28  $
     $Workfile:   amd_utils.pkb  $
	 $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_utils.pkb-arc  $
   
      Rev 1.39   Oct 13 2006 12:57:28   zf297a
   Implemented interface getNsn
   
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
		  raise ;
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
	 	  RETURN ROUND((ROUND(months * 22) / 5) * 7) ;
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
		  AND np.UNASSIGNMENT_DATE IS NOT NULL
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
		 		pError_location => 999, pKey1 => 'amd_utils', pKey2 => '$Revision:   1.39  $') ;
		 dbms_output.put_line('a2a_utils: $Revision:   1.39  $') ;
	end version ;


   FUNCTION getSpoPrimePartNo(part_no AMD_SENT_TO_A2A.part_no%TYPE) RETURN AMD_SENT_TO_A2A.SPO_PRIME_PART_NO%TYPE IS
   			spo_prime_part_no AMD_SENT_TO_A2A.SPO_PRIME_PART_NO%TYPE ;
   BEGIN
   		SELECT DISTINCT spo_prime_part_no INTO spo_prime_part_no 
		FROM AMD_SENT_TO_A2A
		WHERE part_no = getSpoPrimePartNo.part_no ;
		RETURN spo_prime_part_no ;
   END getSpoPrimePartNo ;
   
   	function isPartRepairable(part_no amd_spare_parts.part_no%type) return boolean is
			 smr_code amd_national_stock_items.smr_code%type ;
			 smr_code_cleaned amd_national_stock_items.SMR_CODE_CLEANED%type ;
			 result boolean := false ;
	begin
		 select smr_code, smr_code_cleaned into smr_code, smr_code_cleaned 
		 from amd_spare_parts parts, 
		 amd_national_stock_items items
		 where parts.part_no = isPartRepairable.part_no
		 and parts.nsn = items.nsn ;
		 smr_code := amd_preferred_pkg.getPreferredValue(smr_code_cleaned, smr_code) ; 
		 if length(smr_code) >= 6 then
		 	result := upper(substr(smr_code,6,1)) = 'T' ;
		 end if ;
		 
		 return result ;
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

show errors

CREATE OR REPLACE PACKAGE BODY AMD_LOCATION_PART_LEADTIME_PKG AS
/*
      $Author:   zf297a  $
    $Revision:   1.14  $
	    $Date:   Oct 25 2006 09:19:46  $
    $Workfile:   AMD_LOCATION_PART_LEADTIME_PKG.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_LOCATION_PART_LEADTIME_PKG.pkb.-arc  $
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
	COMMIT_THRESHOLD     CONSTANT NUMBER := 250 ;
		 /* cursor used for data load */	
		 /* previous spec, 0 and null same for avgRepairCycleTime from ramp */
		 /* appears for BULK COLLECT to work, cursor needs to be 
		 in column id order (i.e. cannot just qualify by field name) 
		 and all columns have to be accounted for */			
		 -- decode(nvl(GetAvgRepairCycleTime(ansi.nsn, loc_id), 0), 0, decode(IsPartRepairable(nsi_sid), 'Y', Amd_Defaults.TIME_TO_REPAIR_ONBASE, someOtherDefault ), GetAvgRepairCycleTime(ansi.nsn, loc_id)) time_to_repair,
	CURSOR locPartLeadtime_cur IS
		  	SELECT spo_prime_part_no part_no, 
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
	BEGIN
		BEGIN
			 if a2a_pkg.isPartValid(pPartNo) and a2a_pkg.wasPartSent(pPartNo) then
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
		begin
			 writeMsg(pTableName => 'tmp_a2a_loc_part_lead_time', pError_location => 100,
					pKey1 => 'processLocPartLeadTime started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS')) ;
			 loop
			 	 fetch locPartLeadTime into rec ;
				 exit when locPartLeadTime%NOTFOUND ;
			 	 processData(rec);
				 if mod(cnt,COMMIT_THRESHOLD) = 0 then
				 	commit ;
				 end if ; 
				 cnt := cnt + 1 ;			 
			 end loop ;
	
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
			 close dataByDate ;
	
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
		  			  AND part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A where spo_prime_part_no is not null) ;
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
			  			  part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A where spo_prime_part_no is not null);
				 
			 end if ;
			 processLocPartLeadTime(locPartLeadTime) ;
			 close locPartLeadTime ;
	
			 writeMsg(pTableName => 'tmp_a2a_loc_part_lead_time', pError_location => 150,
					pKey1 => 'loadAllA2A(' || useTestPartsString || ') ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS')) ;
		     commit ;
		end loadAllA2a ;		  	
					
	PROCEDURE LoadTmpAmdLocPartLeadtime IS
		 TYPE ARRAY IS TABLE OF tmp_amd_location_part_leadtime%ROWTYPE;
		 l_data ARRAY;
		  returnCode NUMBER ;
	BEGIN
		mta_truncate_table('tmp_amd_location_part_leadtime','reuse storage');
		mta_truncate_table('tmp_a2a_loc_part_lead_time','reuse storage');
		COMMIT ;
		OPEN locPartLeadtime_cur ;
	    LOOP
		    FETCH locPartLeadtime_cur BULK COLLECT INTO l_data LIMIT BULKLIMIT ;
	
	    	FORALL i IN 1..l_data.COUNT -- SAVE EXCEPTIONS
		    	   INSERT INTO tmp_amd_location_part_leadtime
				   VALUES l_data(i) ;
		   COMMIT ;
		   EXIT WHEN locPartLeadtime_cur%NOTFOUND;
	    END LOOP;
	    CLOSE locPartLeadtime_cur;	
		COMMIT ;
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
		 TYPE ARRAY IS TABLE OF amd_location_part_leadtime%ROWTYPE;
		 l_data ARRAY;
		 returnCode NUMBER ;
	BEGIN
		mta_truncate_table('amd_location_part_leadtime','reuse storage');
		COMMIT ;
		
		OPEN locPartLeadtime_cur;
	    LOOP
		    FETCH locPartLeadtime_cur BULK COLLECT INTO l_data LIMIT BULKLIMIT ;
	
	    	FORALL i IN 1..l_data.COUNT -- SAVE EXCEPTIONS
	    	   INSERT INTO amd_location_part_leadtime
			   VALUES l_data(i) ;
			   COMMIT;
			   EXIT WHEN locPartLeadtime_cur%NOTFOUND;		   
	    END LOOP;
	    CLOSE locPartLeadtime_cur;	
		COMMIT ;
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
		 		pError_location => 180, pKey1 => 'amd_location_part_leadtime_pkg', pKey2 => '$Revision:   1.14  $') ;
		 	 dbms_output.put_line('amd_location_part_leadtime_pkg: $Revision:   1.14  $') ;		 
	end version ;

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

show errors

CREATE OR REPLACE PACKAGE BODY Amd_Partprime_Pkg AS
/*
      $Author:   zf297a  $
    $Revision:   1.8  $
     $Date:   Nov 01 2006 12:35:28  $
    $Workfile:   AMD_PARTPRIME_PKG.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_PARTPRIME_PKG.pkb.-arc  $
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
				   	 	InsertA2A_PartAltRelDel(a2aRec.part_no, a2aRec.spo_prime_part_no) ;
						status := A2a_Pkg.createPartInfo(a2aRec.part_no, Amd_Defaults.INSERT_ACTION) ;				
						updatePrimeASTA(a2aRec.part_no, latestPrime, SYSDATE ) ;
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
		COMMIT ;
		a2a_pkg.deleteSentToA2AChildren	;			
	END DiffPartToPrime;		 
  
	PROCEDURE version IS
	BEGIN
		 writeMsg(pTableName => 'amd_partprime_pkg', 
		 		pError_location => 170, pKey1 => 'amd_partprime_pkg', pKey2 => '$Revision:   1.8  $') ;
	END version ;
  

 
END Amd_Partprime_Pkg ;
/

show errors


CREATE OR REPLACE PACKAGE BODY amd_spare_parts_pkg as
	--
	-- SCCSID:   %M%   %I%   Modified: %G%  %U%
	--
	/*
       $Author:   zf297a  $
     $Revision:   1.82  $
         $Date:   Oct 06 2006 08:48:42  $
     $Workfile:   AMD_SPARE_PARTS_PKG.pkb  $
	     $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_spare_parts_pkg.pkb-arc  $	
   
      Rev 1.82   Oct 06 2006 08:48:42   zf297a
   When insert of amd_spare_parts gets a dup_val_on_index change it to an update.
   
      Rev 1.81   Oct 05 2006 13:38:26   zf297a
   return SUCCESS when there is the part_already_exists exception for the insertRow function.
   
      Rev 1.80   Oct 05 2006 13:33:28   zf297a
   ignore duplicates for insertRow
   
      Rev 1.79   Oct 03 2006 11:54:48   zf297a
   Fixed query for getQtyDue of loadCurrentBackOrder.  Added dbms_output to version.
   
      Rev 1.78   Sep 14 2006 00:42:34   zf297a
   Added procedure deleteAnyRblPairs which is used when the nsn gets updated in amd_national_stock_items - this will delete any dependent child from amd_rbl_pairs if necessary.
   
      Rev 1.77   Jun 21 2006 11:36:44   zf297a
   Fixed loadCurrentBackOrder - needed to trim the part_no in the where clause of the update statements, otherwise the update did not find any matches per the criteria and it does not generate an exception.
   
      Rev 1.76   Jun 09 2006 12:29:48   zf297a
   implemented version
   
      Rev 1.75   Mar 23 2006 14:15:38   zf297a
   Changed code to use amd_defaults.nsn_planner_code or nsl_planner_code where either the cleaned planner code or the original planner_code do not exist in amd_planners.
   
      Rev 1.74   Mar 08 2006 09:25:46   zf297a
   Added mtbdr_computed
   
      Rev 1.73   Oct 10 2005 09:36:26   zf297a
   added price to insertPartInfo and updatePartInfo parameter list
   
      Rev 1.72   Sep 27 2005 08:53:46   zf297a
   Fixed updatePartLeadtime and updatePartPricing by adding a parts.part_no to both where clauses.  Aslo, added comprehensive checks of the data changing from null to not null or not null to null.
   
      Rev 1.72   Aug 19 2005 12:48:26   zf297a
   Since the amd_load package is converting ime_to_repair_off_base_cleand and order_lead_time_cleaned from months to calendar days and Converting order_lead_time from business days to calendar days remove all conversions from this package.
   
      Rev 1.71   Aug 17 2005 15:01:24   zf297a
   Enhanced loadCurrentBackOrder with periodic commits and display of update counters.
   
      Rev 1.70   Aug 16 2005 12:51:22   zf297a
   made same change as made to version 1.39.1.7
   
      Rev 1.69   Aug 10 2005 10:02:06   zf297a
   converted cleaned order_lead_time and order_lead_time to calandar days for a2a transactions.
   
      Rev 1.68   Aug 09 2005 07:23:32   zf297a
   Applied the same update for getQtyDue and cursor curDue - same patch will be applied to current prod (1.7.1)
   
      Rev 1.67   Jul 29 2005 14:59:40   zf297a
   Allow Nsn to change on the Prime or the Equivalent part.
   
      Rev 1.66   Jul 28 2005 10:36:20   zf297a
   Make sure that when a prime_part_no becomes unassigned that its associated national_stock_item gets logically deleted (set the last_update_dt too).  Whenever a new prime_part_no gets assigned to an exisiting national_stock_item update the action_code (U) and the last_update_dt.
   
      Rev 1.65   Jun 27 2005 13:55:24   c970183
   Moved a2a code for part_lead_time and part_pricing to be after partInfo
   
      Rev 1.64   Jun 27 2005 11:37:26   c970183
   Added the display of pPart_no and pNsn for the errorMsg when doing updatePartLeadTime
   
      Rev 1.63   Jun 17 2005 09:03:08   c970183
   Removed exception handler for insertLoadDetail, added raise_application for dup keys, and updated deleteRow's exception handler.
   
      Rev 1.62   Jun 16 2005 15:53:14   c970183
   Changed errorMsg to be the same as the errorMsg in the a2a_pkg: this uses a unique pError_location number to pinpoint the block of code that has the exception.  Also, added some user defined exception instead of return codes.
   
      Rev 1.61   Jun 03 2005 12:50:08   c970183
   Added the procedure loadCurrentBackOrder for amd_national_stock_items.current_backorder
   
      Rev 1.60   May 18 2005 08:59:04   c970183
   Started using a2a_pkg.getIndenture.
   
      Rev 1.59   May 18 2005 07:29:44   c970183
   Modified how mArgs is used.  Added function name for args list and prefixed package name.
   
      Rev 1.58   May 16 2005 11:59:50   c970183
   Moved time_to_repair_off_base and cost_to_repair_off_base from amd_part_locs to amd_national_stock_items.  Created "changed indicators" for both of these fields.
   
      Rev 1.57   May 13 2005 14:44:06   c970183
   Started using a2a_pkg.THIRD_PARTY_FLAG and a2a_pkg.INDENTURE constants
   
      Rev 1.56   May 06 2005 08:23:46   c970183
   changed dla_warehouse_stock, dla_warehouse_stock_cleaned, and getDlaWarehouseStock to current_backorder, current_backorder_cleaned, and getCurrentBackorder.
   
      Rev 1.55   May 02 2005 12:54:42   c970183
   Added some error handling for deleteRow.
   
      Rev 1.53   Apr 26 2005 14:04:02   c970183
   Fixed return value of getCriticalityChangedInd, getNrtsAvgChangedInd, getRtsAvgChangedInd, and getCondemiAvgChanged.
   
      Rev 1.52   Apr 26 2005 11:36:48   c970183
   Added criticality_changed, nrts_avg_changed, rts_avg_changed, and condemn_avg_changed indicators to amd_national_stock_items.
   
      Rev 1.51   Apr 25 2005 12:46:34   c970183
   Fixed the update of amd_spare_parts by adding in mfgr.  Enhanced debugging by adding a global mArgs string that contains all the data that was used to invoke insertRow, updateRow, or deleteRow.
   
      Rev 1.50   Apr 22 2005 08:33:34   c970183
   Fixed InsertRow so that it only invokes a2a_pkg.insertPartInfo when it does a physical insert to amd_national_stock_items, otherwise it will do an update function.
   
      Rev 1.49   Apr 22 2005 08:08:46   c970183
   added additional debug code
   
      Rev 1.48   Apr 18 2005 10:54:42   c970183
   Added new parameters to insertRow and updateRow.  Leveraged the old routines by just defining the new parameters as global member variables and invoking the old insertRow and updateRow methods.   Change the insert and update of amd_national_stock_items to use the new global member variables.
   
      Rev 1.47   Mar 24 2005 14:37:06   c970183
   added ver 1.40 - 1.45 changes.  Plus fixed a2a trans
   
      Rev 1.46  Mar 24 2005 09:36:22   c970183
   Added qpei_weighted, order_lead_time_cleaned, unit_cost_cleaned, planner_code_cleaned, smr_code_cleaned, cost_to_repair_off_base_cleand to InsertRow and UpdateRow

      Rev 1.39.1.0   06 Jan 2005 10:26:24   c970183
   Added mmac and unit_of_issue
   
   Copied the following changes from the SCCS version:
         Rev 1.6   13 Jun 2003 09:52:24   c970408
      Modified updateAmdSparePartRow() to use it's own nsn and removed call to updateNsnFromPrimeRec(). Modifed nsnChanged() to look at an.nsn instead of asp.nsn. Added call to makeNsnSameForAllParts() to checkNsnAndPrimeInd().
   
         Rev 1.5   18 Mar 2003 11:07:44   c970408
      Modified the code to correctly move a part from one nsn to another if both nsns exist concurrently in CAT1.
   
         Rev 1.4   05 Mar 2003 13:23:42   c970408
      fixed the movement of temp nsns to cat1 and the unassociation that results.
   
         Rev 1.3   26 Nov 2002 17:04:22   c970408
      Added getFedcCost().
   
         Rev 1.2   04 Nov 2002 16:20:06   c970408
      Mod'ed updating of the ansi.action_code = 'D' query in UpdateRow method to be more efficient.
   
         Rev 1.1   14 Oct 2002 16:03:44   c970408
      Added query at end of UpdateRow to update ansi.action_code = 'D' if no active amd_nsi_parts recs are linked to and ansi.nsi_sid.
   
         Rev 1.0   07 Oct 2002 06:26:18   c372701
      Initial revision.
   
   

      Rev 1.39   02 Oct 2002 12:30:06   c970408
   Added updateNsnFromPrimeRec() to resolve issue with amd_spare_parts.nsn not updating correctly on non-primes. Removed the nsi_sid qualification in UnassignPrimePart() to resolve issue when a part moves from one nsi_sid to another AND changes from a prime to a non-prime.

      Rev 1.38   30 Aug 2002 11:46:26   c970183
   Fixed updating of the prime_part_no.   When a prime_part_no and its equivalent parts got deleted and reinserted,  the logic caused the amd_national_stock_items.prime_part_no column to get set to a null value.  To accomodate this condition code has been added to the equivalent part section that checks for an existing amd_nsi_parts.part_no with its prime_ind set to 'Y'.  If found it makes sure that the same part_no appears in amd_national_stock_items.prime_part_no.

      Rev 1.37   28 Aug 2002 09:56:04   c970183
   Added the latest_config column for amd_national_stock_items with a value of 'Y'

      Rev 1.35   23 Aug 2002 12:10:54   c970183
   Stripped out ErrorMsg as a nested procedure and made it global to eliminate some redundant code.  Stripped out the updating of amd_national_stock_items to eliminate some redundant code.  Stripped out the routine for making all the equivalent parts have the same nsn as the prime part to eliminate some redundant code.
   Added the invocation of the routine to make nsn's same for equivalent parts for a part that was equivalent, but is now prime.

      Rev 1.34   08 Aug 2002 13:58:58   c970183
   Fixed InsertNewNsn's no_data_found exception: made sure it returned a value.

      Rev 1.33   08 Aug 2002 13:49:14   c970183
   Made the InsertNatStkItem function global to the package.  Wrap all the code needed to create the amd_national_stock_items and amd_nsns rows in a global procedure called CreateNationalStockItem.
   Changed the UpdateRow.InsertNewNsn to accomodate not finding a nsi_sid via the part_no (after having attempted to get it by the Nsn) to create a new Amd_National_Stock_Item/Amd_Nsns pair.

      Rev 1.32   07 Aug 2002 08:58:22   c970183
   Set unassignment_date to sysdate for deleted parts.

				 29 July 2002 fixed code so that a part that will be used a prime
				  	is unassigned no matter what nsn it is currently assigned and
					regardless of its current prime_ind


      	 		 22 July 2002 fixed code so that only one current 'C', nsn_type will
				 exist in amd_nsns for a given nsi_sid

      Rev 1.30   22 May 2002 06:41:16   c970183
   Added routines to create an NsiGroup for new Nsn's and to create NsiEffects for new Nsn's using the amd_default_effectivity_pkg

      Rev 1.29   16 May 2002 09:59:28   c970183
   Qualifed two updates of amd_nsns with the nsn so that only one will be CURRENT.

      Rev 1.28   11 Apr 2002 10:02:08   c970183
   Added 2nd SUCCESS return code for the exception handler of insertNsiPart when it recovers without a problem.

      Rev 1.27   11 Apr 2002 09:51:08   c970183
   Added SUCCESS return code to insertNsiParts

      Rev 1.26   11 Apr 2002 08:32:22   c970183
   Added ONE routine that inserts the amd_nsi_parts row and handles the dup key problem by sleeping one second and then doing the insert again.

      Rev 1.25   11 Apr 2002 08:09:20   c970183
   Added $Log$ keyword

      10/02/01 Douglas Elder   Initial implementation
	  03/28/02 Douglas Elder   Made application sleep when a duplicate insert
	  		   		   		   occurs and then retry the insert.
	  04/04/02 Douglas Elder	Added Mic Code to insert and update
	  04/05/02 Douglas Elder	Added code to update the nsn_type for
	  		   		   			a given nsi_sid to
	  		   		   			the amd_spare_parts_pkg.TEMPORARY_NSN
								whenever the nsn_type is
								amd_spare_parts_pkg.CURRENT_NSN
	   04/11/02 Douglas Elder   Added ONE routine that inserts the
	   							amd_nsi_parts row and handles the dup key
								problem by sleeping one second and then doing
								the insert again.
	   04/11/12 Douglas Elder   Added SUCCESS return code to insertNsiParts
     */


	UNIT_COST_CLEANED_VIA_NSN   exception;
	CANNOT_FIND_PART            exception;
	
	-- package member variables
	mRc		   		  		   	  number := FAILURE ;
	mArgs	   		  		      varchar2(2000) ;
	mMtbdr	   		              amd_national_stock_items.mtbdr%type ;
	mMtbdr_computed				  amd_national_stock_items.mtbdr_computed%type ;
	mQpeiWeighted	  			  amd_national_stock_items.qpei_weighted%type ;
	mCondemnAvgCleaned			  amd_national_stock_items.condemn_avg_cleaned%type ;
  	mCriticalityCleaned			  amd_national_stock_items.criticality%type ;
    mMtbdrCleaned       		  amd_national_stock_items.mtbdr_cleaned%type ;
  	mNrtsAvgCleaned     		  amd_national_stock_items.nrts_avg_cleaned%type ;
  	mCostToRepairOffBaseCleand    amd_national_stock_items.cost_to_repair_off_base_cleand%type ;
  	mTimeToRepairOffBaseCleand    amd_national_stock_items.time_to_repair_off_base_cleand%type ;
  	mOrderLeadTimeCleaned         amd_national_stock_items.order_lead_time_cleaned%type ;
  	mPlannerCodeCleaned           amd_national_stock_items.planner_code_cleaned%type ;
  	mRtsAvgCleaned                amd_national_stock_items.rts_avg_cleaned%type ;
  	mSmrCodeCleaned               amd_national_stock_items.smr_code_cleaned%type ;
  	mUnitCostCleaned              amd_national_stock_items.unit_cost_cleaned%type ;
  	mCondemnAvg                   amd_national_stock_items.condemn_avg%type ;
  	mCriticality                  amd_national_stock_items.criticality%type ;
  	mNrtsAvg                      amd_national_stock_items.nrts_avg%type ;
  	mRtsAvg                       amd_national_stock_items.rts_avg%type ;
	mCostToRepairOffBase		  amd_national_stock_items.cost_to_repair_off_base%type ;
	mTimeToRepairOffBase		  amd_national_stock_items.time_to_repair_off_base%type ;
	

	---------------------------------------------------------------
	-- Private declarations
	--

	function  getFedcCost(
							pPartNo varchar2) return number;
	function hasPartMoved(
							pPartNo varchar2,
							pNsn varchar2) return boolean;
	procedure unassignPart(
							pPartNo varchar2);

	function ErrorMsg(
							pSourceName in amd_load_status.SOURCE%type,
							pTableName in amd_load_status.TABLE_NAME%type,
							pError_location in amd_load_details.DATA_LINE_NO%type,
							pReturn_code in number,
							pPart_no in varchar2 := '',
							pNsi_sid in varchar2 := '',
							pKeywordValuePairs in varchar2 := '',
							pComments in varchar2 := '') return number ;
	--
	-- End Private declarations
	---------------------------------------------------------------

	debugThreshold number := 1000 ;
	debugCnt	   number := 0 ;
	
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
				pSourceName => 'amd_spare_parts_pkg',	
				pTableName  => pTableName,
				pError_location => pError_location,
				pKey1 => pKey1,
				pKey2 => pKey2,
				pKey3 => pKey3,
				pKey4 => pKey4,
				pData    => pData,
				pComments => pComments);
	end writeMsg ;
	
	function ErrorMsg(
				pSqlfunction in amd_load_status.SOURCE%type,
				pTableName in amd_load_status.TABLE_NAME%type,
				pError_location amd_load_details.DATA_LINE_NO%type,
				pReturn_code in number,
				pKey_1 in amd_load_details.KEY_1%type,
		 		pKey_2 in amd_load_details.KEY_2%type := '',
				pKey_3 in amd_load_details.KEY_3%type := '',
				pKey_4 in amd_load_details.KEY_4%type := '',					
				pKeywordValuePairs in varchar2 := '') return number is
	key5 amd_load_details.KEY_5%type := pKeywordValuePairs ;
	begin
		rollback;
		if key5 = '' then
		   key5 := pSqlFunction || '/' || pTableName ;
		else
			key5 := key5 || ' ' || pSqlFunction || '/' || pTableName ;
		end if ;
		-- use substr's to make sure that the input parameters for InsertErrorMsg and GetLoadNo
		-- do not exceed the length of the column's that the data gets inserted into
		-- This is for debugging and logging, so efforts to make it not be the source of more
		-- errors is VERY important
		Amd_Utils.InsertErrorMsg (
				pLoad_no => Amd_Utils.GetLoadNo(
						pSourceName => substr(pSqlfunction,1,20),
						pTableName  => substr(pTableName,1,20)),
				pData_line_no => pError_location,
				pData_line    => 'amd_spare_parts_pkg.' || mArgs,
				pKey_1 => substr(pKey_1,1,50),
				pKey_2 => substr(pKey_2,1,50),
				pKey_3 => substr(pKey_3,1,50),
				pKey_4 => substr(pKey_4,1,50),
				pKey_5 => substr('rc=' || to_char(pReturn_code) ||
					       ' ' || to_char(sysdate,'MM/DD/YYYY HH:MM:SS') ||
						   ' ' || key5,1,50),
				pComments => substr('sqlcode('||sqlcode||') sqlerrm('||sqlerrm||')',1,2000));
		commit;
		return pReturn_code;
	exception when others then
			  commit ;
	end ErrorMsg;

	procedure ErrorMsg(
					pSqlfunction in amd_load_status.SOURCE%type,
					pTableName in amd_load_status.TABLE_NAME%type := '',
					pError_location amd_load_details.DATA_LINE_NO%type,
					pKey_1 in amd_load_details.KEY_1%type := '',
			 		pKey_2 in amd_load_details.KEY_2%type := '',
					pKey_3 in amd_load_details.KEY_3%type := '',
					pKey_4 in amd_load_details.KEY_4%type := '',					
					pKeywordValuePairs in varchar2 := '') is
		result number ;
	begin
		 result := ErrorMsg(pSqlfunction => pSqlfunction,
							pTableName => pTableName,
							pError_location => pError_location,
							pReturn_code => a2a_pkg.FAILURE,
						    pKey_1 => pKey_1,
							pKey_2 => pKey_2,
							pKey_3 => pKey_3,
							pKey_4 => pKey_4,
							pKeywordValuePairs => pKeywordValuePairs) ;
							
	exception when others then
			  commit ;
	end ErrorMsg;

	-- add wrapper for amd_utils.debugMsg
	procedure debugMsg(pMsg in varchar2,pLineNo in number) is
		result number ;
	begin
		-- is debugging turned on for this package?
		if mDebug then
		   amd_utils.debugMsg(pMsg => pMsg,pPackage => 'amd_spare_parts', pLocation => pLineNo) ;
		   commit ; -- make sure the trace is kept
		end if ;
	end;

	function getCriticalityChangedInd(nsi_sid in amd_national_stock_items.nsi_sid%type) 
			 return amd_national_stock_items.criticality_changed%type  is
			 oldCriticality amd_national_stock_items.CRITICALITY%type ;
			 oldCriticalityCleaned amd_national_stock_items.CRITICALITY_CLEANED%type ;
	begin
		 <<getOldValues>>
		 begin
			 select criticality, criticality_cleaned into oldCriticality, oldCriticalityCleaned
			 from amd_national_stock_items
			 where nsi_sid = getCriticalityChangedInd.nsi_sid ;
		 exception
		 		  when standard.NO_DATA_FOUND then
				  	   oldCriticality := null ;
					   oldCriticalityCleaned := null ;
				  when others then
				  	   ErrorMsg(pSqlfunction => 'select',
							pTableName => 'amd_national_stock_items',
							pError_location => 10, 
							pKey_1 => to_char(getCriticalityChangedInd.nsi_sid)) ;
				  		raise ;
		 end getOldValues ;
		 if amd_preferred_pkg.GetPreferredValue(mCriticalityCleaned, mCriticality) !=
		 	amd_preferred_pkg.GetPreferredValue(oldCriticalityCleaned, oldCriticality) then
			return 'Y' ;
		 else
		 	 return 'N' ;
		 end if ;
	end getCriticalityChangedInd ; 

	function getNrtsAvgChangedInd(nsi_sid in amd_national_stock_items.nsi_sid%type) return 
			 							  amd_national_stock_items.nrts_avg_changed%type is
			 oldNrtsAvg amd_national_stock_items.Nrts_Avg%type ;
			 oldNrtsAvgCleaned amd_national_stock_items.Nrts_Avg_CLEANED%type ;
	begin
		 <<getOldValues>>
		 begin
			 select Nrts_Avg, Nrts_Avg_cleaned into oldNrtsAvg, oldNrtsAvgCleaned
			 from amd_national_stock_items
			 where nsi_sid = getNrtsAvgChangedInd.nsi_sid ;
		 exception
		 		  when standard.NO_DATA_FOUND then
				  	   oldNrtsAvg := null ;
					   oldNrtsAvgCleaned := null ;
				  when others then
				  	   ErrorMsg(pSqlfunction => 'select',
							pTableName => 'amd_national_stock_items',
							pError_location => 20, 
							pKey_1 => to_char(getNrtsAvgChangedInd.nsi_sid)) ;
				  		raise ;
		 end getOldValues ;
		 if amd_preferred_pkg.GetPreferredValue(mNrtsAvgCleaned, mNrtsAvg) !=
		 	amd_preferred_pkg.GetPreferredValue(oldNrtsAvgCleaned, oldNrtsAvg) then
			return 'Y' ;
		 else
		 	 return 'N' ;
		 end if ;
	end getNrtsAvgChangedInd ; 

	function getRtsAvgChangedInd(nsi_sid in amd_national_stock_items.nsi_sid%type) return 
			  amd_national_stock_items.rts_avg_changed%type  is
			 oldRtsAvg amd_national_stock_items.Rts_Avg%type ;
			 oldRtsAvgCleaned amd_national_stock_items.Rts_Avg_CLEANED%type ;
	begin
		 <<getOldValues>>
		 begin
			 select Rts_Avg, Rts_Avg_cleaned into oldRtsAvg, oldRtsAvgCleaned
			 from amd_national_stock_items
			 where nsi_sid = getRtsAvgChangedInd.nsi_sid ;
		 exception
		 		  when standard.NO_DATA_FOUND then
				  	   oldRtsAvg := null ;
					   oldRtsAvgCleaned := null ;
				  when others then
				  	   ErrorMsg(pSqlfunction => 'select',
							pTableName => 'amd_national_stock_items',
							pError_location => 30, 
							pKey_1 => to_char(getRtsAvgChangedInd.nsi_sid)) ;
				  		raise ;
		 end getOldValues ;
		 if amd_preferred_pkg.GetPreferredValue(mRtsAvgCleaned, mRtsAvg) !=
		 	amd_preferred_pkg.GetPreferredValue(oldRtsAvgCleaned, oldRtsAvg) then
			return 'Y' ;
		 else
		 	 return 'N' ;
		 end if ;
	end getRtsAvgChangedInd ; 

	function getCondemnAvgChangedInd(nsi_sid in amd_national_stock_items.nsi_sid%type) return 
			 	amd_national_stock_items.condemn_avg_changed%type is
			 oldCondemnAvg amd_national_stock_items.Condemn_Avg%type ;
			 oldCondemnAvgCleaned amd_national_stock_items.Condemn_Avg_CLEANED%type ;
	begin
		 <<getOldValues>>
		 begin
			 select Condemn_Avg, Condemn_Avg_cleaned into oldCondemnAvg, oldCondemnAvgCleaned
			 from amd_national_stock_items
			 where nsi_sid = getCondemnAvgChangedInd.nsi_sid ;
		 exception
		 		  when standard.NO_DATA_FOUND then
				  	   oldCondemnAvg := null ;
					   oldCondemnAvgCleaned := null ;
				  when others then
				  	   ErrorMsg(pSqlfunction => 'select',
							pTableName => 'amd_national_stock_items',
							pError_location => 40, 
							pKey_1 => to_char(getCondemnAvgChangedInd.nsi_sid)) ;
				  		raise ;
		 end getOldValues ;
		 if amd_preferred_pkg.GetPreferredValue(mCondemnAvgCleaned, mCondemnAvg) !=
		 	amd_preferred_pkg.GetPreferredValue(oldCondemnAvgCleaned, oldCondemnAvg) then
			return 'Y' ;
		 else
		 	 return 'N' ;
		 end if ;
	end getCondemnAvgChangedInd ; 

	function getCostToRepairOffBaseChgedInd(nsi_sid in amd_national_stock_items.nsi_sid%type) return 
			 	amd_national_stock_items.cost_to_repair_off_base_chged%type is
			 oldCostToRepairOffBase amd_national_stock_items.cost_to_repair_off_base%type ;
			 oldCostToRepairOffBaseCleand amd_national_stock_items.cost_to_repair_off_base_cleand%type ;
	begin
		 <<getOldValues>>
		 begin
			 select cost_to_repair_off_base, cost_to_repair_off_base_cleand into oldCostToRepairOffBase, oldCostToRepairOffBaseCleand
			 from amd_national_stock_items
			 where nsi_sid = getCostToRepairOffBaseChgedInd.nsi_sid ;
		 exception
		 		  when standard.NO_DATA_FOUND then
				  	   oldCostToRepairOffBase := null ;
					   oldCostToRepairOffBaseCleand := null ;
				  when others then
				  	   ErrorMsg(pSqlfunction => 'select',
							pTableName => 'amd_national_stock_items',
							pError_location => 50, 
							pKey_1 => to_char(getCostToRepairOffBaseChgedInd.nsi_sid)) ;
				  		raise ;
		 end getOldValues ;
		 if amd_preferred_pkg.GetPreferredValue(mCostToRepairOffBaseCleand, mCostToRepairOffBase) !=
		 	amd_preferred_pkg.GetPreferredValue(oldCostToRepairOffBaseCleand, oldCostToRepairOffBase) then
			return 'Y' ;
		 else
		 	 return 'N' ;
		 end if ;
	end getCostToRepairOffBaseChgedInd ; 

	function getTimeToRepairOffBaseChgedInd(nsi_sid in amd_national_stock_items.nsi_sid%type) return 
			 	amd_national_stock_items.time_to_repair_off_base_chged%type is
			 oldTimeToRepairOffBase amd_national_stock_items.time_to_repair_off_base%type ;
			 oldTimeToRepairOffBaseCleand amd_national_stock_items.time_to_repair_off_base_cleand%type ;
	begin
		 <<getOldValues>>
		 begin
			 select time_to_repair_off_base, time_to_repair_off_base_cleand into oldTimeToRepairOffBase, oldTimeToRepairOffBaseCleand
			 from amd_national_stock_items
			 where nsi_sid = getTimeToRepairOffBaseChgedInd.nsi_sid ;
		 exception
		 		  when standard.NO_DATA_FOUND then
				  	   oldTimeToRepairOffBase := null ;
					   oldTimeToRepairOffBaseCleand := null ;
				  when others then
				  	   ErrorMsg(pSqlfunction => 'select',
							pTableName => 'amd_national_stock_items',
							pError_location => 60, 
							pKey_1 => to_char(getTimeToRepairOffBaseChgedInd.nsi_sid)) ;
				  		raise ;
		 end getOldValues ;
		 if amd_preferred_pkg.GetPreferredValue(mTimeToRepairOffBaseCleand, mTimeToRepairOffBase) !=
		 	amd_preferred_pkg.GetPreferredValue(oldTimeToRepairOffBaseCleand, oldTimeToRepairOffBase) then
			return 'Y' ;
		 else
		 	 return 'N' ;
		 end if ;
	end getTimeToRepairOffBaseChgedInd ; 

	procedure insertLoadDetail(
							pPartNo varchar2,
							pNsn varchar2,
							pPrimeInd varchar2,
							pAction varchar2) is
		aspNsn     amd_spare_parts.nsn%type;
		aspAction  amd_spare_parts.action_code%type;
		anpNsiSid  amd_nsi_parts.nsi_sid%type;
		anNsiSid   amd_nsns.nsi_sid%type;
		anNsn      amd_nsns.nsn%type;
		anNsn2     amd_nsns.nsn%type;
		anNsnType  amd_nsns.nsn_type%type;
		anNsnType2 amd_nsns.nsn_type%type;
		anpPrime   amd_nsi_parts.prime_ind%type;
	begin
		begin
			select anp.prime_ind,an.nsn,an.nsn_type,anp.nsi_sid,
				asp.action_code,asp.nsn
			into anpPrime,anNsn,anNsnType,anpNsiSid,aspAction,aspNsn
			from amd_spare_parts asp,
				amd_nsi_parts anp,
				amd_nsns an
			where asp.part_no = pPartNo
				and asp.part_no = anp.part_no
				and anp.nsi_sid = an.nsi_sid
				and anp.unassignment_date is null
				and an.nsn_type = 'C';
		exception when others then 
				  NULL; 
		end;

		begin
			select nsi_sid,nsn,nsn_type
			into anNsiSid,anNsn2,anNsnType2
			from amd_nsns
			where nsn = pNsn;
		exception when others then
				  null ; 
		end;

		amd_utils.InsertErrorMsg (
				pLoad_no => amd_utils.GetLoadNo(
					pSourceName => 'amd_spare_parts_pkg',
					pTableName  => 'amd_spare_parts'),
				pData_line_no => 1,
				pData_line    => substr('D: '||pAction||'- Curr View - pPartNo('||pPartNo||') pNsn('||pNsn||') pPrimeInd('||pPrimeInd||') - anNsn('||anNsn||') anNsnType('||anNsnType||') aspAction('||aspAction||') anpPrime('||anpPrime||') anpNsiSid('||anpNsiSid||')',1,2000),
				pKey_1 => 'anNsn2('||anNsiSid||')',
				pKey_2 => 'anNsnType2('||anNsnType2||')',
				pKey_3 => 'aspNsn('||aspNsn||')',
				pKey_4 => 'anNsiSid('||anNsiSid||')',
				pKey_5 => '',
				pComments => to_char(sysdate,'yyyymmdd hh:mi:ss am'));

		commit;
	end insertLoadDetail ;


	procedure unassociateTmpNsn(
							pNsn varchar2) is
	begin
		debugMsg('unassociateTmpNsn('||pNsn||')', pLineNo => 10);
		-- We do this when a temp nsn now appears in CAT1. This will remove
		-- the association to the current nsn and will set up the process
		-- to create a new nsi_sid for this formerly temp nsn.
		--
		delete from amd_nsns
		where nsn = pNsn
			and nsn_type = 'T';
	end;


	function hasPartMoved(
							pPartNo varchar2,
							pNsn varchar2) return boolean is
		nsn    amd_nsns.nsn%type;
	begin
		debugMsg('hasPartMoved('||pPartNo||')', pLineNo => 20);

		-- A part has moved from one nsn to another if the new and old nsns
		-- appear in tmp_amd_spare_parts at the same time.
		--
		select distinct 'Part has moved.'
		into nsn
		from tmp_amd_spare_parts
		where
			nsn =
				(select an.nsn
				from
					amd_nsi_parts anp,
					amd_nsns an
				where anp.part_no = pPartNo
					and anp.nsi_sid = an.nsi_sid
					and anp.unassignment_date is null
					and an.nsn_type = 'C'
					and an.nsn != pNsn)
		union
		select 'Part has moved.'
		from amd_nsns an,
			amd_nsi_parts anp
		where anp.part_no = pPartNo
			and an.nsi_sid != anp.nsi_sid
			and anp.unassignment_date is null
			and an.nsn_type = 'C'
			and an.nsn = pNsn;

		return TRUE;
	exception
		when NO_DATA_FOUND then
			return FALSE;
	end;


	function  getFedcCost(
							pPartNo varchar2) return number is
		cursor costCur is
			select gfp_price
			from prc1
			where
				part = pPartNo
				and gfp_price is not null
			order by sc desc;

		fedcCost    number;
	begin
		debugMsg('getFedcCost(' || pPartNo || ')', pLineNo => 30) ;
		for rec in costCur loop
			fedcCost := rec.gfp_price;
			exit;
		end loop;

		return fedcCost;
	exception when others then
  	   ErrorMsg(pSqlfunction => 'select',
			pTableName => 'prcl',
			pError_location => 80, 
			pKey_1 => pPartNo) ;
  		raise ;
	end getFedcCost ;



	procedure unassignPart(
							pPartNo varchar2) is
	begin
		debugMsg('unassignPart('||pPartNo||')', pLineNo => 40);
		update amd_nsi_parts set
			unassignment_date = sysdate
		where
			part_no = pPartNo
			and unassignment_date is null;
	end unassignPart ;


	function IsPrimePart(
						pPrime_ind in amd_nsi_parts.prime_ind%type) return boolean is
	begin
		debugMsg('isPrimePart(' || pPrime_ind || ')', pLineNo => 50);
		return (Upper(pPrime_ind) = amd_defaults.PRIME_PART);
	exception when others then
  	   ErrorMsg(pSqlfunction => 'isPrimeInd',
			pTableName => '',
			pError_location => 90, 
			pKey_1 => pPrime_ind) ;
  		raise ;
	end IsPrimePart;


	procedure sleep(
							secs in number) is
		ss varchar2(2);
	begin
		ss := to_char(sysdate,'ss');
		while to_number(ss) + secs > to_number(to_char(sysdate,'ss'))
		loop
			null;
		end loop;
	end;


	/* 8/23/02 DSE added ErrorMsg to eliminate some redundant code
	 * and to give the error messages a std structure.
	 */
	 -- 9/3/04 DSE add stronger typing for Source and Table_name + add substr's to make
	 -- certain that the key_1 to key_5 never exceed 50 characters
	function ErrorMsg(
							pSourceName in amd_load_status.SOURCE%type,
							pTableName in amd_load_status.TABLE_NAME%type,
							pError_location in amd_load_details.DATA_LINE_NO%type,
							pReturn_code in number,
							pPart_no in varchar2 := '',
							pNsi_sid in varchar2 := '',
							pKeywordValuePairs in varchar2 := '',
							pComments in varchar2 := '') return number is
	begin
		rollback; -- rollback may not be complete if running with mDebug set to true
		amd_utils.InsertErrorMsg (
				pLoad_no => amd_utils.GetLoadNo(
						pSourceName => pSourceName,
						pTableName  => pTableName),
				pData_line_no => pError_location,
				pData_line    => 'amd_spare_parts_pkg.' || mArgs,
				pKey_1 => substr(pPart_no,1,50),
				pKey_2 => substr(pNsi_sid,1,50),
				pKey_3 => pKeywordValuePairs,
				pKey_4 => to_char(pReturn_code),
				pKey_5 => sysdate,
				pComments => 'sqlcode('||sqlcode||') sqlerrm('||sqlerrm||') ' || pComments);

		commit;
		return pReturn_code;
	end;


	function insertNsiParts(
							pNsi_sid in amd_nsi_parts.nsi_sid%type,
							pPart_no in amd_nsi_parts.part_no%type,
							pPrime_ind in amd_nsi_parts.prime_ind%type,
							pPrime_ind_cleaned in amd_nsi_parts.prime_ind_cleaned%type,
							pBadRc in number) return number is
		currDate   date:=sysdate;
	begin
		debugMsg('insertNsiParts('||pNsi_sid||','||pPart_no||','||pPrime_ind||','||pPrime_ind_cleaned||','||pBadRc||')', pLineNo => 60);

		insert into amd_nsi_parts
		(
			nsi_sid,
			assignment_date,
			part_no,
			prime_ind
		)
		values
		(
			pNsi_sid,
			currDate,
			pPart_no,
			pPrime_ind
		);

		-- This is a safeguard to ensure all other records are unassigned
		update amd_nsi_parts set
			unassignment_date = sysdate
		where
			part_no = pPart_no
			and unassignment_date is null
			and assignment_date < currDate;

		return SUCCESS;
	exception
		when dup_val_on_index then
		    <<InsertAgainAfterOneSecond>>
			begin
				sleep(1);
				insert into amd_nsi_parts
				(
					nsi_sid,
					assignment_date,
					part_no,
					prime_ind
				)
				values
				(
					pNsi_sid,
					sysdate,
					pPart_no,
					pPrime_ind
				);
				return SUCCESS;
			exception
				when others then
				   mRc := amd_spare_parts_pkg.INSERTAGAIN_ERR + pBadRC ;
			  	   ErrorMsg(pSqlfunction => 'insert',
						pTableName => 'amd_nsi_parts',
						pError_location => 100, 
						pKey_1 => pPart_no,
						pKey_2 => to_char(pNsi_sid),
						pKey_3 => 'prime_ind=' || pPrime_ind) ;
			  		raise ;
			end InsertAgainAfterOneSecond;
		when others then
			   mRC := pBadRc ;
		  	   ErrorMsg(pSqlfunction => 'update',
					pTableName => 'amd_nsi_parts',
					pError_location => 110, 
					pKey_1 => pPart_no) ;
		  		raise ;
	end insertNsiParts;


	/* 8/22/02 DSE added MakeNsnSameForAllParts to eliminate some
	 * redundant code.\
	 */
	function MakeNsnSameForAllParts(
							pNsi_sid in amd_nsi_parts.nsi_sid%type,
							pNsn in amd_national_stock_items.nsn%type) return number is
		cursor partList is
			select
				part_no
			from amd_nsi_parts
			where nsi_sid = pNsi_sid
			and unassignment_date is null;
	begin
		for partList_rec in partList loop
			update amd_spare_parts parts set
				nsn = pNsn
			where part_no = partList_rec.part_no;
		end loop;
		return SUCCESS;
	exception
		when others then
		   mRC := amd_spare_parts_pkg.UPD_NSN_SPARE_PARTS_ERR ;
	  	   ErrorMsg(pSqlfunction => 'select',
				pTableName => 'amd_nsi_parts',
				pError_location => 120, 
				pKey_1 => to_char(pNsi_sid)) ;
	  		raise ;
	end MakeNsnSameForAllParts;


	/*
		For a given nsn if all related parts are marked
		as deleted, then its associated nsn in the
		amd_national_stock_items should be marked as DELETED.
		For a given nsn if any related part is not marked
		DELETED and its associated nsn is marked DELETED,
		then mark the nsn as either INSERTED or UPDATED depending
		on the current action
	  */
	function UpdateNatStkItem(
							pNsn in amd_spare_parts.nsn%type,
							pAction in varchar2,
							pPartNo varchar2 default null) return number is

		nsi_sid     amd_nsi_parts.nsi_sid%type := null;

		function NumberOfActiveParts return number is
			cnt number := 0;
			result number := SUCCESS;
		begin

			select count(*)
			into cnt
			from  amd_nsi_parts nsi, amd_spare_parts parts
			where nsi.nsi_sid = UpdateNatStkItem.nsi_sid
			and nsi.part_no = parts.part_no
			and nsi.unassignment_date is null
			and parts.action_code != amd_defaults.DELETE_ACTION;

			return cnt;
		exception
			when NO_DATA_FOUND then
				return 0;
			when others then
		  	   ErrorMsg(pSqlfunction => 'select',
					pTableName => 'amd_nsi_parts',
					pError_location => 130, 
					pKey_1 => to_char(UpdateNatStkItem.nsi_sid)) ;
		  		raise ;
		end NumberOfActiveParts;


		function IsNsnMarkedDeleted return boolean is
			action_code amd_national_stock_items.action_code%type := null;
			result number;
		begin
			select action_code
			into action_code
			from amd_national_stock_items items
			where items.nsi_sid = UpdateNatStkItem.nsi_sid;
			return (action_code = amd_defaults.DELETE_ACTION);
		exception
			when others then
		  	   ErrorMsg(pSqlfunction => 'select',
					pTableName => 'amd_national_stock_items',
					pError_location => 140, 
					pKey_1 => to_char(UpdateNatStkItem.nsi_sid)) ;
		  		raise ;
		end IsNsnMarkedDeleted;

	begin -- UpdateNatStkItem
	    debugMsg('UpdateNatStkItem(' || pNsn || ', ' || pAction || ', ' || pPartNo || ')', pLineNo => 70) ;
		
		<<GetNsiSid>>
		begin
			/*
				use the nsi_sid to get a row from the
				amd_national_stock_items since it is always
				better than the Nsn - even though this Nsn
				should be the current Nsn for the prime part
				and its equivalent parts.
			*/
			nsi_sid := amd_utils.GetNsiSid(pNsn => pNsn);
		exception
			when NO_DATA_FOUND then
				return amd_spare_parts_pkg.UNABLE_TO_GET_NSI_SID;
		end GetNsiSid;

		if pAction = amd_defaults.DELETE_ACTION then
		
		    <<numberOfActivePartsGt0>>
			begin
				if NumberOfActiveParts() = 0 then
						update amd_national_stock_items set
							action_code    = amd_defaults.DELETE_ACTION,
							last_update_dt = sysdate
						where nsi_sid = UpdateNatStkItem.nsi_sid;
				end if;
			exception
				when others then
					return amd_spare_parts_pkg.UNABLE_TO_GET_NUM_ACTIVE_PARTS;
			end numberOfActivePartsGt0;
			
		else
			/* must be an INSERT_ACTION or an UPDATE_ACTION */
			<<processInsertOrDelete>>
			begin
				if (NumberOfActiveParts() > 0 and IsNsnMarkedDeleted() ) then
					update amd_national_stock_items set
						action_code    = pAction,
						last_update_dt = sysdate
					where nsi_sid = UpdateNatStkItem.nsi_sid;
				end if;
			exception
				when others then
					return amd_spare_parts_pkg.UNABLE_TO_PROC_INS_OR_DLET;
			end processInsertOrDelete;
		end if;

		return SUCCESS;
	exception
		when others then
			mRC := amd_spare_parts_pkg.UPDT_NATSTKITEM_ERR ;
			ErrorMsg(pSqlfunction => 'updateNatStkItem',
				pTableName => 'amd_national_stock_items',
				pError_location => 150) ;
			raise ;
	end UpdateNatStkItem;


	/* 8/22/02 DSE added UpdtNsiPrimePartData to eliminate some
	 * redundant code.
	 */
	function UpdtNsiPrimePartData(
							pPrime_ind in amd_nsi_parts.prime_ind%type,
							pNsi_sid in amd_national_stock_items.nsi_sid%type,
							pPartNo in amd_national_stock_items.prime_part_no%type,
							pNsn in amd_national_stock_items.nsn%type,
							pItem_type in amd_national_stock_items.item_type%type,
							pOrder_quantity in amd_national_stock_items.order_quantity%type,
							pPlannerCode in amd_national_stock_items.planner_code%type,
							pSmr_code in amd_national_stock_items.smr_code%type,
							pMic_code_lowest in amd_national_stock_items.mic_code_lowest%type,
							pAction_code in amd_national_stock_items.action_code%type,
							pReturn_code in number,
							pMmac in amd_national_stock_items.mmac%type) RETURN NUMBER is
		fedcCost   number;
		procedure verifyData is
				  rec amd_national_stock_items%rowtype ;
				  x number := 0 ;
		begin
		    debugMsg('verifyData', pLineNo => 80) ;
		 	x:=x+1;rec.prime_part_no := pPartNo ;
		 	x:=x+1;rec.fedc_cost := fedcCost ;
		 	x:=x+1;rec.nsn := pNsn ;
		 	x:=x+1;rec.item_type := pItem_type ;
		 	x:=x+1;rec.order_quantity := pOrder_quantity ;
		 	x:=x+1;rec.planner_code := pPlannerCode ;
		 	x:=x+1;rec.smr_code := pSmr_Code ;
		 	x:=x+1;rec.mic_code_lowest := pMic_code_lowest ;
			x:=x+1;rec.last_update_dt := sysdate ;
		 	x:=x+1;rec.mmac := pMmac ;
		 	x:=x+1;rec.mtbdr := mMtbdr ;
			x:=x+1;rec.mtbdr_computed := mMtbdr_computed ;
		 	x:=x+1;rec.qpei_weighted := mQpeiWeighted ;
			 
			x:=x+1;rec.condemn_avg_cleaned 		 := mCondemnAvgCleaned ;
			x:=x+1;rec.criticality_cleaned   		   := mCriticalityCleaned ;
			x:=x+1;rec.mtbdr_cleaned 		  		   := mMtbdrCleaned ;
			x:=x+1;rec.nrts_avg_cleaned 	  		   := mNrtsAvgCleaned ;
			x:=x+1;rec.cost_to_repair_off_base_cleand := mCostToRepairOffBaseCleand ;
			x:=x+1;rec.time_to_repair_off_base_cleand := mTimeToRepairOffBaseCleand ;
			x:=x+1;rec.order_lead_time_cleaned 	   := mOrderLeadTimeCleaned ;
			x:=x+1;rec.planner_code_cleaned 		   := mPlannerCodeCleaned ;
			x:=x+1;rec.rts_avg_cleaned 			   := mRtsAvgCleaned ;
			x:=x+1;rec.smr_code_cleaned 			   := mSmrCodeCleaned ;
			x:=x+1;rec.unit_cost_cleaned 			   := mUnitCostCleaned ;
			x:=x+1;rec.condemn_avg 				   := mCondemnAvg ;
			x:=x+1;rec.criticality 				   := mCriticality ;
			x:=x+1;rec.nrts_avg 					   := mNrtsAvg ;
			x:=x+1;rec.rts_avg 					   := mRtsAvg ;
			x:=x+1;rec.cost_to_repair_off_base	   := mCostToRepairOffBase ;
			x:=x+1;rec.time_to_repair_off_base	   := mTimeToRepairOffBase ;
			x:=x+1;rec.action_code := pAction_code ;
		exception when others then
			ErrorMsg(pSqlfunction => 'verifyData',
				pTableName => 'amd_national_stock_items',
				pError_location => 160) ;
			raise ;
		end verifyData ;
		
		procedure doUpdate(planner_code_cleaned in varchar2, planner_code in varchar2) is
				  criticality_changed amd_national_stock_items.CRITICALITY_CHANGED%type 
				   :=  getCriticalityChangedInd(pNsi_sid) ;
				  nrts_avg_changed amd_national_stock_items.NRTS_AVG_CHANGED%type 
				    := getNrtsAvgChangedInd(pNsi_sid) ;
				  rts_avg_changed amd_national_stock_items.RTS_AVG_CHANGED%type 
				    := getRtsAvgChangedInd(pNsi_sid) ;
				  condemn_avg_changed amd_national_stock_items.CONDEMN_AVG_CHANGED%type
				    := getCondemnAvgChangedInd(pNsi_sid) ;
				  cost_to_repair_off_base_chged amd_national_stock_items.COST_TO_REPAIR_OFF_BASE_CHGED%type 
				    := getCostToRepairOffBaseChgedInd(pNsi_sid) ;
				  time_to_repair_off_base_chged amd_national_stock_items.time_to_repair_off_base_chged%type
				    := getTimeToRepairOffBaseChgedInd(PNsi_sid) ;
					
				procedure deleteAnyRblPairs is
				begin
					 
					 delete from amd_rbl_pairs where 
					 		(old_nsn in (select nsn from amd_national_stock_items where nsi_sid = pNsi_sid)
							 and old_nsn <> pNsn)
					 or (new_nsn in (select nsn from amd_national_stock_items where nsi_sid = pNsi_sid) 
					 	 and new_nsn <> pNsn) ;
					 
				end deleteAnyRblPairs ;
				
				   	    
		begin
			debugMsg('doUpdate', pLineNo => 90) ;
			
			deleteAnyRblPairs ;
			
			update amd_national_stock_items set
			    criticality_changed = doUpdate.criticality_changed,
				nrts_avg_changed = doUpdate.nrts_avg_changed,
				rts_avg_changed = doUpdate.rts_avg_changed,
				condemn_avg_changed = doUpdate.condemn_avg_changed,
				cost_to_repair_off_base_chged = doUpdate.cost_to_repair_off_base_chged,
				time_to_repair_off_base_chged = doUpdate.time_to_repair_off_base_chged,
				prime_part_no   = pPartNo,
				fedc_cost       = fedcCost,
				nsn             = pNsn,
				item_type       = pItem_type,
				order_quantity  = pOrder_quantity,
				planner_code    = doUpdate.planner_code,
				smr_code        = pSmr_code,
				mic_code_lowest = pMic_code_lowest,
				last_update_dt  = sysdate,
				mmac			= pMmac,
				mtbdr			= mMtbdr,
				mtbdr_computed  = mMtbdr_computed,
				qpei_weighted	= mQpeiWeighted,
				condemn_avg_cleaned 		   = mCondemnAvgCleaned,
				criticality_cleaned   		   = mCriticalityCleaned,
				mtbdr_cleaned 		  		   = mMtbdrCleaned,
				nrts_avg_cleaned 	  		   = mNrtsAvgCleaned,
				cost_to_repair_off_base_cleand = mCostToRepairOffBaseCleand,
				time_to_repair_off_base_cleand = mTimeToRepairOffBaseCleand,
				order_lead_time_cleaned 	   = mOrderLeadTimeCleaned,
				planner_code_cleaned 		   = doUpdate.planner_code_cleaned,
				rts_avg_cleaned 			   = mRtsAvgCleaned,
				smr_code_cleaned 			   = mSmrCodeCleaned,
				unit_cost_cleaned 			   = mUnitCostCleaned,
				condemn_avg 				   = mCondemnAvg,
				criticality 				   = mCriticality,
				nrts_avg 					   = mNrtsAvg,
				rts_avg 					   = mRtsAvg,
				cost_to_repair_off_base		   = mCostToRepairOffBase,
				time_to_repair_off_base		   = mTimeToRepairOffBase,
				action_code     			   = pAction_code
			where nsi_sid = pNsi_sid;
		end doUpdate ;
		
	begin
		debugMsg('UpdtNsiPrimePartData',pLineNo => 100) ;
		if (IsPrimePart(pPrime_ind)) then
			fedcCost := getFedcCost(pPartNo);
			
			verifyData ;
			

			begin
				 doUpdate (planner_code_cleaned => mPlannerCodeCleaned, planner_code => pPlannerCode);
			exception when others then
				if sqlcode = -2291 then
				   <<constraintError>>
				   declare
				   		  msg varchar2(50) ;
						  planner_code amd_planners.planner_code%type ;
				   begin
				       -- figurr out which foreign key does not have a parent
					   if instr(sqlerrm,'FK04') > 0  then
						  if substr(pNsn,1,3) = 'NSL' then
						  	 mPlannerCodeCleaned := amd_defaults.NSL_PLANNER_CODE ;
						  else
						     mPlannerCodeCleaned := amd_defaults.NSN_PLANNER_CODE ;
						  end if ;
						  doUpdate (planner_code_cleaned => mPlannerCodeCleaned, planner_code => pPlannerCode) ;
						  return SUCCESS ;
					   elsif instr(sqlerrm,'FK03') > 0 then
						  if substr(pNsn,1,3) = 'NSL' then
						  	 planner_code := amd_defaults.NSL_PLANNER_CODE ;
						  else
						     planner_code := amd_defaults.NSN_PLANNER_CODE ;
						  end if ;
						  doUpdate(planner_code_cleaned => mPlannerCodeCleaned, planner_code => planner_code) ;
					   	  return SUCCESS ;
					   elsif instr(sqlerrm,'FK02') > 0 then
					   	  msg := 'no parent for partNo=' || pPartNo ;
					   elsif instr(sqlerrm,'FK01') > 0 then
					   	  msg := 'no parent for nsn=' || pNsn ;
					   else
					   	   msg := 'Unknown' ;
					   end if ;
					   mRC := pReturn_code ;
					   ErrorMsg(pSqlfunction => 'UpdtNsiPrimePartData',
							pTableName => 'amd_national_stock_items',
							pError_location => 170,
							pKey_1 => pPartNo,
							pKey_2 => to_char(pNsi_sid),
							pKey_3 => msg) ;
						raise ;
					end constraintError ;
				else
				   mRC := pReturn_code ;
				   ErrorMsg(pSqlfunction => 'UpdtNsiPrimePartData',
						pTableName => 'amd_national_stock_items',
						pError_location => 180,
						pKey_1 => pPartNo,
						pKey_2 => to_char(pNsi_sid),
						pKey_3 => 'plannerCodeCleaned=' || mPlannerCodeCleaned) ;
					raise ;
				end if ;
			end ;
		end if;

		return SUCCESS;

	exception
		when others then
		   mRC := pReturn_code ;
		   ErrorMsg(pSqlfunction => 'UpdtNsiPrimePartData',
				pTableName => 'amd_national_stock_items',
				pError_location => 190,
				pKey_1 => pPartNo,
				pKey_2 => to_char(pNsi_sid),
				pKey_3 => 'nsn=' || pNsn) ;
			raise ;
	end UpdtNsiPrimePartData;


	function InsertNatStkItem(
							pNsi_sid out amd_national_stock_items.nsi_sid%type,
							pNsn in amd_spare_parts.nsn%type,
							pItem_type in amd_national_stock_items.item_type%type,
							pOrder_quantity in amd_national_stock_items.order_quantity%type,
							pPlanner_code in amd_national_stock_items.planner_code%type,
							pSmr_code in amd_national_stock_items.smr_code%type,
							pTactical in amd_national_stock_items.tactical%type,
							pMic_code_lowest in amd_national_stock_items.mic_code_lowest%type,
							pMmac in amd_national_stock_items.mmac%type) RETURN NUMBER is

		result number := SUCCESS;
		nsiGroupSid number;

		function GetNsiSid return amd_national_stock_items.nsi_sid%type is
			nsi_sid amd_national_stock_items.nsi_sid%type := null;
		begin
			select amd_nsi_sid_seq.CURRVAL
			into nsi_sid
			from dual;
			return nsi_sid;
		end GetNsiSid;

	begin -- InsertNatStkItem
	    debugMsg('InsertNatStkItem', pLineNo => 110) ;
		nsiGroupSid := amd_default_effectivity_pkg.NewGroup;

		begin
			INSERT INTO AMD_NATIONAL_STOCK_ITEMS
			(
				nsn,
				add_increment_cleaned,
				amc_base_stock_cleaned,
				amc_days_experience_cleaned,
				amc_demand_cleaned,
				capability_requirement_cleaned,
				criticality_cleaned,
				distrib_uom_defaulted,
				dla_demand_cleaned,
				current_backorder_cleaned,
				fedc_cost_cleaned,
				item_type,
				item_type_cleaned,
				mic_code_lowest_cleaned,
				mtbdr_cleaned,
				nomenclature_cleaned,
				order_lead_time_cleaned,
				order_quantity,
				order_quantity_defaulted,
				order_uom_cleaned,
				planner_code,
				planner_code_cleaned,
				prime_part_no,
				qpei_weighted_defaulted,
				ru_ind_cleaned,
				smr_code,
				smr_code_cleaned,
				unit_cost_cleaned,
				condemn_avg_defaulted,
				condemn_avg_cleaned,
				nrts_avg_defaulted,
				nrts_avg_cleaned,
				rts_avg_defaulted,
				rts_avg_cleaned,
				cost_to_repair_off_base_cleand,
				time_to_repair_off_base_cleand,
				time_to_repair_on_base_avg_df,
				time_to_repair_on_base_avg_cl,
				tactical,
				action_code,
				last_update_dt,
				mic_code_lowest,
				nsi_group_sid,
				latest_config,
				effect_by,
				mmac,
				mtbdr,
				mtbdr_computed,
				qpei_weighted,
				criticality,
				nrts_avg,
				rts_avg,
				cost_to_repair_off_base,
				time_to_repair_off_base
			)
			VALUES
			(
				NULL, -- nsn
				Amd_Clean_Data.GetAddIncrement(pNsn),
				Amd_Clean_Data.GetAmcBaseStock(pNsn),
				Amd_Clean_Data.GetAmcDaysExperience(pNsn),
				Amd_Clean_Data.GetAmcDemand(pNsn),
				Amd_Clean_Data.GetCapabilityRequirement(pNsn),
				mCriticalityCleaned,
				Amd_Defaults.DISTRIB_UOM,
				Amd_Clean_Data.GetDlaDemand(pNsn),
				Amd_Clean_Data.GetCurrentBackorder(pNsn),
				Amd_Clean_Data.GetFedcCost(pNsn),
				pItem_type,
				Amd_Clean_Data.GetItemType(pNsn),
				Amd_Clean_Data.GetMicCodeLowest(pNsn),
				mMtbdrCleaned,
				Amd_Clean_Data.GetNomenclature(pNsn),
				mOrderLeadTimeCleaned,
				pOrder_Quantity,
				Amd_Defaults.ORDER_QUANTITY,
				Amd_Clean_Data.GetOrderUom(pNsn),
				pPlanner_code,
				mPlannerCodeCleaned,
				NULL, -- prime_part_no
				Amd_Defaults.QPEI_WEIGHTED,
				Amd_Clean_Data.GetRuInd(pNsn),
				pSmr_code,
				mSmrCodeCleaned,
				mUnitCostCleaned,
				mCondemnAvg,
				mCondemnAvgCleaned,
				Amd_Defaults.NRTS_AVG,
				mNrtsAvgCleaned,
				Amd_Defaults.RTS_AVG,
				mRtsAvgCleaned,
				mCostToRepairOffBaseCleand,
				mTimeToRepairOffBaseCleand,
				Amd_Defaults.TIME_TO_REPAIR_ONBASE,
				Amd_Clean_Data.GetTimeToRepairOnBaseAvg(pNsn),
				pTactical,
				Amd_Defaults.INSERT_ACTION,
				SYSDATE,
				pMic_code_lowest,
				nsiGroupSid,
				'Y',
				'S',
				pMmac,
				mMtbdr,
				mMtbdr_computed,
				mQpeiWeighted,
				mCriticality,
				mNrtsAvg,
				mRtsAvg,
				mCostToRepairOffBase,
				mTimeToRepairOffBase
			);
		exception
			when others then
			   mRC := amd_spare_parts_pkg.CREATE_NATSTKITEM_ERR ;
			   ErrorMsg(pSqlfunction => 'insert',
					pTableName => 'amd_national_stock_items',
					pError_location => 200) ;
			   raise ;
		end InsertNsi;

		pNsi_sid := GetNsiSid();

		return SUCCESS;
	end InsertNatStkItem;


	function ChgCurNsn2TempNsn(
							pNsiSid in amd_nsns.nsi_sid%type) return number is
	begin
	    debugMsg('ChgCurNsn2TempNsn(' || pNsiSid || ')', pLineNo => 120) ;
		update amd_nsns set
			nsn_type = amd_spare_parts_pkg.TEMPORARY_NSN
		where nsi_sid = pNsiSid and nsn_type = amd_spare_parts_pkg.CURRENT_NSN;
		return SUCCESS;
	exception
		when others then
		   mRC := amd_spare_parts_pkg.UNABLE_TO_CHG_NSN_TYPE ;
		   ErrorMsg(pSqlfunction => 'update',
				pTableName => 'amd_nsns',
				pError_location => 210,
				pKey_1 => to_char(pNsiSid)) ;
		   raise ;
	end ChgCurNsn2TempNsn;


	function InsertAmdNsn(
							pNsi_sid in amd_nsns.nsi_sid%type,
							pNsn in amd_nsns.nsn%type,
							pNsn_type in amd_nsns.nsn_type%type ) return number is

		result number ;

	begin
	    debugMsg('InsertAmdNsn(' || pNsi_sid || ', ' || pNsn || ', ' || pNsn_type, pLineNo => 130) ;
	    if pNsn_type = amd_spare_parts_pkg.CURRENT_NSN then
		   result:= ChgCurNsn2TempNsn(pNsiSid => pNsi_sid);
		end if;
		if result = SUCCESS then
			insert into amd_nsns
			(
				nsn,
				nsn_type,
				nsi_sid,
				creation_date
			)
			values
			(
				pNsn,
				pNsn_type,
				pNsi_sid,
				sysdate
			);
			return SUCCESS;
		end if;
		return result;
	exception
		when others then
		   mRC := amd_spare_parts_pkg.UNABLE_TO_INSERT_AMD_NSNS ;
		   ErrorMsg(pSqlfunction => 'insert',
				pTableName => 'amd_nsns',
				pError_location => 220,
				pKey_1 => to_char(pNsi_Sid),
				pKey_2 => pNsn,
				pKey_3 => pNsn_type) ;
		   raise ;
	end InsertAmdNsn;


	function UpdateAmdNsn(
							pNsi_sid in amd_nsns.nsi_sid%type,
							pNsn in amd_nsns.nsn%type,
							pNsn_type in amd_nsns.nsn_type%type ) return number is
		result number;
	begin
		debugMsg('UpdateAmdNsn(' || pNsi_sid || ', ' || pNsn || ', ' || pNsn_type || ')', pLineNo => 140) ;
		if pNsn_type = amd_spare_parts_pkg.CURRENT_NSN then
		   result:= ChgCurNsn2TempNsn(pNsiSid => pNsi_sid);
		end if ;
		if result = SUCCESS then
			update amd_nsns set
				nsn_type = pNsn_type
			where nsi_sid = pNsi_sid and nsn = pNsn;
			return SUCCESS;
		end if;
		return result;

	exception
		when others then
		   mRC := amd_spare_parts_pkg.UNABLE_TO_INSERT_AMD_NSNS ;
		   ErrorMsg(pSqlfunction => 'update',
				pTableName => 'amd_nsns',
				pError_location => 230,
				pKey_1 => to_char(pNsi_Sid),
				pKey_2 => pNsn) ;
		   raise ;
	end UpdateAmdNsn;


	function CreateNationalStockItem(
							pNsi_sid out amd_national_stock_items.nsi_sid%type,
							pNsn in amd_spare_parts.nsn%type,
							pItem_type in amd_national_stock_items.item_type%type,
							pOrder_quantity in amd_national_stock_items.order_quantity%type,
							pPlanner_code in amd_national_stock_items.planner_code%type,
							pSmr_code in amd_national_stock_items.smr_code%type,
							pTactical in amd_national_stock_items.tactical%type,
							pMic_code_lowest in amd_national_stock_items.mic_code_lowest%type,
							pNsn_type in amd_nsns.nsn_type%type,
							pMmac in amd_national_stock_items.mmac%type) RETURN NUMBER is
		result number := SUCCESS;

	begin
		result := InsertNatStkItem(pNsi_sid => pNsi_sid,
					 pNsn => pNsn,
					 pItem_type => pItem_type,
					 pOrder_quantity => pOrder_quantity,
					 pPlanner_code => pPlanner_code,
					 pSmr_code => pSmr_code,
					 pTactical => pTactical,
					 pMic_code_lowest => pMic_code_lowest,
					 pMmac => pMmac) ;					 

		if result = SUCCESS then
		   amd_default_effectivity_pkg.SetNsiEffects(pNsi_sid);
		   if pNsn_type = amd_spare_parts_pkg.CURRENT_NSN then
		   	  result := amd_spare_parts_pkg.ChgCurNsn2TempNsn(
							pNsiSid => pNsi_sid);
		   end if;
		   if result = SUCCESS then
		   	  result := InsertAmdNsn(pNsi_sid => pNsi_sid, pNsn => pNsn, pNsn_type => pNsn_type);
		   end if;
		end if;

		return result;

	end CreateNationalStockItem;

	-- forward declare the old insertRow method, which is now private, so it can be used in
	-- the new public insertRow method
	FUNCTION InsertRow
                (pPart_no IN VARCHAR2,
                pMfgr IN VARCHAR2,
                pDate_icp IN DATE,
                pDisposal_cost IN NUMBER,
                pErc IN VARCHAR2,
                pIcp_ind IN VARCHAR2,
                pNomenclature IN VARCHAR2,
                pOrder_lead_time IN NUMBER,
				pOrder_quantity IN NUMBER,
                pOrder_uom IN VARCHAR2,
				pPrime_ind IN VARCHAR2,
                pScrap_value IN NUMBER,
                pSerial_flag IN VARCHAR2,
                pShelf_life IN NUMBER,
                pUnit_cost IN NUMBER,
                pUnit_volume IN NUMBER,
                pNsn IN VARCHAR2,
				pNsn_type IN VARCHAR2,
                pItem_type IN VARCHAR2,
                pSmr_code IN VARCHAR2,
                pPlanner_code IN VARCHAR2,
				pMic_code_lowest IN VARCHAR2,
				pAcquisition_advice_code IN VARCHAR2,
				pMmac IN VARCHAR2,
				pUnitOfIssue IN VARCHAR2) return number ;
				
	FUNCTION InsertRow
                (pPart_no IN VARCHAR2,
                pMfgr IN VARCHAR2,
                pDate_icp IN DATE,
                pDisposal_cost IN NUMBER,
                pErc IN VARCHAR2,
                pIcp_ind IN VARCHAR2,
                pNomenclature IN VARCHAR2,
                pOrder_lead_time IN NUMBER,
				pOrder_quantity IN NUMBER,
                pOrder_uom IN VARCHAR2,
				pPrime_ind IN VARCHAR2,
                pScrap_value IN NUMBER,
                pSerial_flag IN VARCHAR2,
                pShelf_life IN NUMBER,
                pUnit_cost IN NUMBER,
                pUnit_volume IN NUMBER,
                pNsn IN VARCHAR2,
				pNsn_type IN VARCHAR2,
                pItem_type IN VARCHAR2,
                pSmr_code IN VARCHAR2,
                pPlanner_code IN VARCHAR2,
				pMic_code_lowest IN VARCHAR2,
				pAcquisition_advice_code IN VARCHAR2,
				pMmac IN VARCHAR2,
				pUnitOfIssue IN VARCHAR2,
				pMtbdr in number,
				pMtbdr_computed in number,
  				pQpeiWeighted in number,
  				pCondemnAvgCleaned in number,
  				pCriticalityCleaned in number,
  				pMtbdrCleaned in number,
  				pNrtsAvgCleaned in number,
  				pCosToRepairOffBaseCleand in number,
  				pTimeToRepairOffBaseCleand in  number,
  				pOrderLeadTimeCleaned in number,
  				pPlannerCodeCleaned in amd_national_stock_items.planner_code_cleaned%type,
  				pRtsAvgCleaned in number,
  				pSmrCodeCleaned in amd_national_stock_items.smr_code_cleaned%type,
  				pUnitCostCleaned in number,
  				pCondemnAvg in number,
  				pCriticality in number,
  				pNrtsAvg in number,
  				pRtsAvg in number,
				pCostToRepairOffBase in number,
				pTimeToRepairOffBase in number) return number is
	begin
		 -- By overriding the insertRow and updateRow routines all that needs to be done
		 -- is to set the member variables to the values passed in and then invoke
		 -- the old insertRow method, which is now private, That way I don't have to pass parameters just get the data
		 -- from these global member variables.
		 mArgs := 'insertRow(' || pPart_no || ', ' ||
                pMfgr || ', ' ||
                pDate_icp || ', ' ||
                pDisposal_cost || ', ' ||
                pErc || ', ' ||
                pIcp_ind || ', ' ||
                pNomenclature || ', ' ||
                pOrder_lead_time || ', ' ||
				pOrder_quantity || ', ' ||
                pOrder_uom || ', ' ||
				pPrime_ind || ', ' ||
                pScrap_value || ', ' ||
                pSerial_flag || ', ' ||
                pShelf_life || ', ' ||
                pUnit_cost || ', ' ||
                pUnit_volume || ', ' ||
                pNsn || ', ' ||
				pNsn_type || ', ' ||
                pItem_type || ', ' ||
                pSmr_code || ', ' ||
                pPlanner_code || ', ' ||
				pMic_code_lowest || ', ' ||
				pAcquisition_advice_code || ', ' ||
				pMmac || ', ' ||
				pUnitOfIssue || ', ' ||
				pMtbdr || ', ' ||
				pMtbdr_computed || ', ' ||
  				pQpeiWeighted || ', ' ||
  				pCondemnAvgCleaned || ', ' ||
  				pCriticalityCleaned || ', ' ||
  				pMtbdrCleaned || ', ' ||
  				pNrtsAvgCleaned || ', ' ||
  				pCosToRepairOffBaseCleand || ', ' ||
  				pTimeToRepairOffBaseCleand || ', ' ||
  				pOrderLeadTimeCleaned || ', ' ||
  				pPlannerCodeCleaned || ', ' ||
  				pRtsAvgCleaned || ', ' ||
  				pSmrCodeCleaned || ', ' ||
  				pUnitCostCleaned || ', ' ||
  				pCondemnAvg || ', ' ||
  				pCriticality || ', ' ||
  				pNrtsAvg || ', ' ||
  				pRtsAvg || ')' ;
		 mMtbdr 		   		   	:= pMtbdr ;
		 mMtbdr_computed			:= pMtbdr_computed ;
  		 mQpeiWeighted 	   		   	:= pQpeiWeighted ;
  		 mCondemnAvgCleaned 		:= pCondemnAvgCleaned ;
  		 mCriticalityCleaned   		:= pCriticalityCleaned ;
  		 mMtbdrCleaned 		 		:= pMtbdrCleaned ;
		 mNrtsAvgCleaned  			:= pNrtsAvgCleaned ;
		 mCostToRepairOffBaseCleand := pCosToRepairOffBaseCleand ;
  		 mTimeToRepairOffBaseCleand := pTimeToRepairOffBaseCleand ;
  		 mOrderLeadTimeCleaned 		:= pOrderLeadTimeCleaned ;
  		 mPlannerCodeCleaned   		:= pPlannerCodeCleaned ;
		 mRtsAvgCleaned 	 		:= pRtsAvgCleaned ;
  		 mSmrCodeCleaned 			:= pSmrCodeCleaned ;
  		 mUnitCostCleaned			:= pUnitCostCleaned ;
  		 mCondemnAvg				:= pCondemnAvg ;
  		 mCriticality				:= pCriticality ;
  		 mNrtsAvg					:= pNrtsAvg ;
  		 mRtsAvg					:= pRtsAvg ;
		 mCostToRepairOffBase		:= pCostToRepairOffBase ;
		 mTimeToRepairOffBase		:= pTimeToRepairOffBase ;
		 
		 return InsertRow
                (pPart_no,
                pMfgr,
                pDate_icp,
                pDisposal_cost,
                pErc,
                pIcp_ind,
                pNomenclature,
                pOrder_lead_time,
				pOrder_quantity,
                pOrder_uom,
				pPrime_ind,
                pScrap_value,
                pSerial_flag,
                pShelf_life,
                pUnit_cost,
                pUnit_volume,
                pNsn,
				pNsn_type,
                pItem_type,
                pSmr_code,
                pPlanner_code,
				pMic_code_lowest,
				pAcquisition_advice_code,
				pMmac,
				pUnitOfIssue) ;
				
	end InsertRow ;

	-- forward declare the old updateRow method, which is now private, so it can be used in
	-- the new public updateRow method
	FUNCTION UpdateRow
                (pPart_no IN VARCHAR2,
                pMfgr IN VARCHAR2,
                pDate_icp IN DATE,
                pDisposal_cost in number,
                pErc IN VARCHAR2,
                pIcp_ind IN VARCHAR2,
                pNomenclature IN VARCHAR2,
                pOrder_lead_time IN NUMBER,
				pOrder_quantity IN NUMBER,
                pOrder_uom IN VARCHAR2,
				pPrime_ind IN VARCHAR2,
                pScrap_value IN NUMBER,
                pSerial_flag IN VARCHAR2,
                pShelf_life IN NUMBER,
                pUnit_cost IN NUMBER,
                pUnit_volume IN NUMBER,
                pNsn IN VARCHAR2,
				pNsn_type IN VARCHAR2,
                pItem_type IN VARCHAR2,
                pSmr_code IN VARCHAR2,
                pPlanner_code IN VARCHAR2,
				pMic_code_lowest IN VARCHAR2,
				pAcquisition_advice_code IN VARCHAR2,
				pMmac IN VARCHAR2,
				pUnitOfIssue IN VARCHAR2) return number ;

	FUNCTION UpdateRow
                (pPart_no IN VARCHAR2,
                pMfgr IN VARCHAR2,
                pDate_icp IN DATE,
                pDisposal_cost IN NUMBER,
                pErc IN VARCHAR2,
                pIcp_ind IN VARCHAR2,
                pNomenclature IN VARCHAR2,
                pOrder_lead_time IN NUMBER,
				pOrder_quantity IN NUMBER,
                pOrder_uom IN VARCHAR2,
				pPrime_ind IN VARCHAR2,
                pScrap_value IN NUMBER,
                pSerial_flag IN VARCHAR2,
                pShelf_life IN NUMBER,
                pUnit_cost IN NUMBER,
                pUnit_volume IN NUMBER,
                pNsn IN VARCHAR2,
				pNsn_type IN VARCHAR2,
                pItem_type IN VARCHAR2,
                pSmr_code IN VARCHAR2,
                pPlanner_code IN VARCHAR2,
				pMic_code_lowest IN VARCHAR2,
				pAcquisition_advice_code IN VARCHAR2,
				pMmac IN VARCHAR2,
				pUnitOfIssue IN VARCHAR2,
				pMtbdr in number,
				pMtbdr_computed in number,
  				pQpeiWeighted in number,
  				pCondemnAvgCleaned in number,
  				pCriticalityCleaned in number,
  				pMtbdrCleaned in number,
  				pNrtsAvgCleaned in number,
  				pCosToRepairOffBaseCleand in number,
  				pTimeToRepairOffBaseCleand in  number,
  				pOrderLeadTimeCleaned in number,
  				pPlannerCodeCleaned in amd_national_stock_items.planner_code_cleaned%type,
  				pRtsAvgCleaned in number,
  				pSmrCodeCleaned in amd_national_stock_items.smr_code_cleaned%type,
  				pUnitCostCleaned in number,
  				pCondemnAvg in number,
  				pCriticality in number,
  				pNrtsAvg in number,
  				pRtsAvg in number,
				pCostToRepairOffBase in number,
				pTimeToRepairOffBase in number) return number is
				
				lineNo number := 0 ;
				result number ;
	begin
		 -- By overriding the updateRow andinsertRow routines all that needs to be done
		 -- is to set the member variables to the values passed in and then invoke
		 -- the old updateRow method, which is now private, That way I don't have to pass parameters just get the data
		 -- from these global member variables.
		 mArgs := 'UpdateRow(' || pPart_no || ', ' ||
                pMfgr || ', ' ||
                pDate_icp || ', ' ||
                pDisposal_cost || ', ' ||
                pErc || ', ' ||
                pIcp_ind || ', ' ||
                pNomenclature || ', ' ||
                pOrder_lead_time || ', ' ||
				pOrder_quantity || ', ' ||
                pOrder_uom || ', ' ||
				pPrime_ind || ', ' ||
                pScrap_value || ', ' ||
                pSerial_flag || ', ' ||
                pShelf_life || ', ' ||
                pUnit_cost || ', ' ||
                pUnit_volume || ', ' ||
                pNsn || ', ' ||
				pNsn_type || ', ' ||
                pItem_type || ', ' ||
                pSmr_code || ', ' ||
                pPlanner_code || ', ' ||
				pMic_code_lowest || ', ' ||
				pAcquisition_advice_code || ', ' ||
				pMmac || ', ' ||
				pUnitOfIssue || ', ' ||
				pMtbdr || ', ' ||
				pMtbdr_computed || ', ' ||
  				pQpeiWeighted || ', ' ||
  				pCondemnAvgCleaned || ', ' ||
  				pCriticalityCleaned || ', ' ||
  				pMtbdrCleaned || ', ' ||
  				pNrtsAvgCleaned || ', ' ||
  				pCosToRepairOffBaseCleand || ', ' ||
  				pTimeToRepairOffBaseCleand || ', ' ||
  				pOrderLeadTimeCleaned || ', ' ||
  				pPlannerCodeCleaned || ', ' ||
  				pRtsAvgCleaned || ', ' ||
  				pSmrCodeCleaned || ', ' ||
  				pUnitCostCleaned || ', ' ||
  				pCondemnAvg || ', ' ||
  				pCriticality || ', ' ||
  				pNrtsAvg || ', ' ||
  				pRtsAvg || ', ' ||
				pCostToRepairOffBase || ', ' ||
				pTimeToRepairOffBase || ')' ;
		 lineNo := lineNo + 1 ;mMtbdr 		   		   	:= pMtbdr ;
		 lineNo := lineNo + 1 ;mMtbdr_computed			:= pMtbdr_computed ;
  		 lineNo := lineNo + 1 ;mQpeiWeighted 	   		   	:= pQpeiWeighted ;
  		 lineNo := lineNo + 1 ;mCondemnAvgCleaned 		:= pCondemnAvgCleaned ;
  		 lineNo := lineNo + 1 ;mCriticalityCleaned   		:= pCriticalityCleaned ;
  		 lineNo := lineNo + 1 ;mMtbdrCleaned 		 		:= pMtbdrCleaned ;
		 lineNo := lineNo + 1 ;mNrtsAvgCleaned  			:= pNrtsAvgCleaned ;
		 lineNo := lineNo + 1 ;mCostToRepairOffBaseCleand := pCosToRepairOffBaseCleand ;
  		 lineNo := lineNo + 1 ;mTimeToRepairOffBaseCleand := pTimeToRepairOffBaseCleand ;
  		 lineNo := lineNo + 1 ;mOrderLeadTimeCleaned 		:= pOrderLeadTimeCleaned ;
  		 lineNo := lineNo + 1 ;mPlannerCodeCleaned   		:= pPlannerCodeCleaned ;
		 lineNo := lineNo + 1 ;mRtsAvgCleaned 	 		:= pRtsAvgCleaned ;
  		 lineNo := lineNo + 1 ;mSmrCodeCleaned 			:= pSmrCodeCleaned ;
  		 lineNo := lineNo + 1 ;mUnitCostCleaned			:= pUnitCostCleaned ;
  		 lineNo := lineNo + 1 ;mCondemnAvg				:= pCondemnAvg ;
  		 lineNo := lineNo + 1 ;mCriticality				:= pCriticality ;
  		 lineNo := lineNo + 1 ;mNrtsAvg					:= pNrtsAvg ;
  		 lineNo := lineNo + 1 ;mRtsAvg					:= pRtsAvg ;
		 lineNo := lineNo + 1 ;mCostToRepairOffBase		:= pCostToRepairOffBase ;
		 lineNo := lineNo + 1 ;mTimeToRepairOffBase		:= pTimeToRepairOffBase ;
		 
		 return UpdateRow
                (pPart_no,
                pMfgr,
                pDate_icp,
                pDisposal_cost,
                pErc,
                pIcp_ind,
                pNomenclature,
                pOrder_lead_time,
				pOrder_quantity,
                pOrder_uom,
				pPrime_ind,
                pScrap_value,
                pSerial_flag,
                pShelf_life,
                pUnit_cost,
                pUnit_volume,
                pNsn,
				pNsn_type,
                pItem_type,
                pSmr_code,
                pPlanner_code,
				pMic_code_lowest,
				pAcquisition_advice_code,
				pMmac,
				pUnitOfIssue) ;
	exception when others then
		   ErrorMsg(pSqlfunction => 'updateRow',
				pTableName => '',
				pError_location => 240) ;
		   return UPDT_ERRX ;
	end UpdateRow ;

	function InsertRow(
							pPart_no in varchar2,
							pMfgr in varchar2,
							pDate_icp in date,
							pDisposal_cost in number,
							pErc in varchar2,
							pIcp_ind in varchar2,
							pNomenclature in varchar2,
							pOrder_lead_time in number,
							pOrder_quantity in number,
							pOrder_uom in varchar2,
							pPrime_ind in varchar2,
							pScrap_value in number,
							pSerial_flag in varchar2,
							pShelf_life in number,
							pUnit_cost in number,
							pUnit_volume in number,
							pNsn in varchar2,
							pNsn_type in varchar2,
							pItem_type in varchar2,
							pSmr_code in varchar2,
							pPlanner_code in varchar2,
							pMic_code_lowest in varchar2,
							pAcquisition_advice_code in varchar2,
							pMmac in varchar2,
							pUnitOfIssue in varchar2) RETURN NUMBER is

		/* Although the following variables are local to the InsertRow
		  procedure, you will see them referenced as InsertRow.variable_name.
		  This was done to improve readability.  A similar approach is used
		  for package constants: package_name.constant_name.
		 */
		prime_ind_cleaned    amd_nsi_parts.prime_ind_cleaned%type := null;
		result               number := SUCCESS;
		tactical             amd_spare_parts.tactical%type := 'N';
		unit_cost_defaulted  amd_spare_parts.unit_cost_defaulted%type := null;
		part_already_exists	 exception ;


		/* Put a wrapper on the amd_utils.InsertErrorMsg procedure, so it is
			more specific to the InsertRow function.  Output gets stored
			into amd_load_details and amd_load_status.
		*/

		function InsertAmdNsiParts(
							pNsi_sid in amd_nsi_parts.nsi_sid%type) return number is

			result number := SUCCESS;
		begin
			return insertNsiParts(pNsi_sid => pNsi_sid,
				   	   pPart_no => pPart_no,
				   	   pPrime_ind => pPrime_ind,
					   pPrime_ind_cleaned => prime_ind_cleaned,
				   	   pBadRc => amd_spare_parts_pkg.UNABLE_TO_INSERT_AMD_NSI_PARTS);
		end InsertAmdNsiParts;


		function InsertEquivalentPartData(
							pNsi_sid in amd_nsi_parts.nsi_sid%type) return number is
		begin
			return InsertAmdNsiParts(pNsi_sid);
		end InsertEquivalentPartData;


		function DoPhysicalInsert return number is

			nsi_sid amd_national_stock_items.nsi_sid%type := null;

			function IsPrimeReplacingExistingOne(
							pNsi_sid in amd_nsi_parts.nsi_sid%type,
							pCurrent_prime_part_no out amd_nsi_parts.part_no%type) return boolean is

				prime_ind amd_nsi_parts.prime_ind%type := null;
			begin
				begin
					select
						part_no,
						prime_ind
					into pCurrent_prime_part_no, prime_ind
					from amd_nsi_parts
					where nsi_sid = pNsi_sid
					and prime_ind = amd_defaults.PRIME_PART
					and unassignment_date is null;
					return true;
				exception
					when no_data_found then
						return false;
				end;
			end IsPrimeReplacingExistingOne;


			function PrepareDataForInsert return number is
			begin

				-- todo prime_ind_cleaned will be set in a separate routine since it is
				-- so complicated
				-- InsertRow.prime_ind_cleaned := amd_clean_data.prime_ind(nsn);

				<<getTacticalInd>>
				begin
					InsertRow.tactical :=
							amd_validation_pkg.GetTacticalInd(
								amd_preferred_pkg.GetPreferredValue(mUnitCostCleaned,
										  pUnit_cost,
										  InsertRow.unit_cost_defaulted),
								amd_preferred_pkg.GetPreferredValue(mSmrCodeCleaned,
										 pSmr_code)
								 );
				exception
					when others then
					   ErrorMsg(pSqlfunction => 'getTacticalInd',
							pError_location => 270) ;
					   raise ;
				end getTacticalInd;

				if pPlanner_code is not null then
					if not amd_validation_pkg.IsValidPlannerCode(pPlanner_code) then
						if amd_validation_pkg.AddPlannerCode(pPlanner_code) != amd_validation_pkg.SUCCESS then
							return amd_spare_parts_pkg.ADD_PLANNER_CODE_ERR;
						end if;
					end if;
				end if;

				if pOrder_uom is not null then
					if not amd_validation_pkg.IsValidUomCode(pOrder_uom) then
						if amd_validation_pkg.AddUomCode(pOrder_uom) != amd_validation_pkg.SUCCESS then
							return amd_spare_parts_pkg.ADD_UOM_CODE_ERR;
						end if;
					end if;
				end if;
				return SUCCESS;
			exception
				when others then
				       mRC := amd_spare_parts_pkg.UNABLE_TO_PREP_DATA ;
					   ErrorMsg(pSqlfunction => 'prepareDataForInsert',
							pError_location => 280) ;
					   raise ;
			end prepareDataForInsert;


			function NatStkItemExists(
							pNsn in amd_spare_parts.nsn%type,
							pNsi_sid out amd_nsns.nsi_sid%type) return boolean is
			begin
				select nsi_sid
				into pNsi_sid
				from amd_nsns
				where nsn = pNsn
				and nsi_sid is not null;
				return true;
			exception
				when no_data_found then
					return false;
			end NatStkItemExists;


			function InsertSparePart return number is
			begin
				insert into amd_spare_parts
				(
					part_no,
					mfgr,
					date_icp,
					disposal_cost,
					disposal_cost_defaulted,
					erc,
					icp_ind,
					nomenclature ,
					order_lead_time,
					order_lead_time_defaulted,
					order_uom,
					order_uom_defaulted,
					scrap_value,
					scrap_value_defaulted,
					serial_flag,
					shelf_life,
					shelf_life_defaulted,
					unit_cost,
					unit_cost_defaulted,
					unit_volume,
					unit_volume_defaulted,
					nsn,
					tactical,
					action_code,
					last_update_dt,
					acquisition_advice_code,
					unit_of_issue
				)
				values
				(
					pPart_no,
					pMfgr,
					pDate_icp,
					pDisposal_cost,
					amd_defaults.DISPOSAL_COST,
					pErc,
					pIcp_ind,
					pNomenclature ,
					pOrder_lead_time,
					amd_defaults.GetOrderLeadTime(pItem_type),
					pOrder_uom,
					amd_defaults.ORDER_UOM,
					pScrap_value,
					amd_defaults.SCRAP_VALUE,
					pSerial_flag,
					pShelf_life,
					amd_defaults.SHELF_LIFE,
					pUnit_cost,
					InsertRow.unit_cost_defaulted,
					pUnit_volume,
					amd_defaults.UNIT_VOLUME,
					pNsn,
					InsertRow.tactical,
					amd_defaults.INSERT_ACTION,
					sysdate,
					pAcquisition_advice_code,
					pUnitOfIssue
				);
				return SUCCESS;
			exception
				when DUP_VAL_ON_INDEX then	   
					   writeMsg(pTableName => 'amd_spare_parts', pError_location => 290,
								pKey1 => 'pPart_no=' || pPart_no,
								pKey2 => 'tried to insert a part that was already there' ) ;
					   return UpdateRow
									(pPart_no,
									pMfgr,
									pDate_icp,
									pDisposal_cost,
									pErc,
									pIcp_ind,
									pNomenclature,
									pOrder_lead_time,
									pOrder_quantity,
									pOrder_uom,
									pPrime_ind,
									pScrap_value,
									pSerial_flag,
									pShelf_life,
									pUnit_cost,
									pUnit_volume,
									pNsn,
									pNsn_type,
									pItem_type,
									pSmr_code,
									pPlanner_code,
									pMic_code_lowest,
									pAcquisition_advice_code,
									pMmac,
									pUnitOfIssue) ;
				when others then
					   ErrorMsg(pSqlfunction => 'insert',
							pTableName => 'amd_spare_parts',
							pError_location => 300,
							pKey_1 => pPart_no) ;
					   raise ;
			end InsertSparePart;


			function UpdatePrimePartData(
							pNsi_sid in amd_national_stock_items.nsi_sid%type) return number is

				result number := SUCCESS;


			begin -- UpdatePrimePartData
			    <<insertNsiParts>>
				begin
					result := InsertAmdNsiParts(pNsi_sid);
				exception
					when others then
					   mRC := INS_AMD_NSI_PARTS_ERR ;
					   ErrorMsg(pSqlfunction => 'insert',
							pTableName => 'amd_nsi_parts',
							pError_location => 310,
							pKey_1 => to_char(pNsi_sid)) ;
					   raise ;
				end insertNsiParts;
				
				if result = SUCCESS then
					result := UpdtNsiPrimePartData (pPrime_ind => pPrime_ind,
		 					  pNsi_sid => pNsi_sid,
		 					  pPartNo => pPart_no,
		 					  pNsn => pNsn,
							  pItem_type => pItem_type,
							  pOrder_quantity => pOrder_quantity,
							  pPlannerCode => pPlanner_code,
							  pSmr_code => pSmr_code,
							  pMic_code_lowest => pMic_code_lowest,
							  pAction_code => amd_defaults.INSERT_ACTION,
							  pReturn_code => amd_spare_parts_pkg.UNABLE_TO_PRIME_INFO,
							  pMmac => pMmac) ;					 
				end if;
				return result;
			exception
				when others then
					   mRC := INSERT_PRIMEPART_ERR ;
					   ErrorMsg(pSqlfunction => 'updatePrimePartData',
							pError_location => 320) ;
					   raise ;
			end UpdatePrimePartData;


			function UpdatePrimePartData(
							pNsn in amd_national_stock_items.nsn%type,
							pNsi_sid in amd_nsns.nsi_sid%type,
							pCurrent_prime_part_no in amd_nsi_parts.part_no%type) return number is

				result number := SUCCESS;

				function MakePrimeAnEquivalentPart return number is
						 curPrime amd_nsi_parts.PART_NO%type ;
						 
				begin
					-- first make sure the prime_part is flagged as logically deleted 
					update amd_national_stock_items
					set action_code = amd_defaults.DELETE_ACTION,
					last_update_dt = sysdate
					where nsi_sid = pNsi_sid
					and prime_part_no =
						  (select part_no from amd_nsi_parts
						   where nsi_sid = pNsi_sid
						   and (prime_ind = amd_defaults.PRIME_PART or prime_ind_cleaned = amd_defaults.PRIME_PART)
						   and unassignment_date is null ) ;
						  
						    
					update amd_nsi_parts set
						unassignment_date = sysdate
					where
						nsi_sid = pNsi_sid
						and (prime_ind             = amd_defaults.PRIME_PART
								or prime_ind_cleaned = amd_defaults.PRIME_PART)
						and unassignment_date is null;

					return insertNsiParts(pNsi_sid => pNsi_sid,
						    pPart_no => pCurrent_prime_part_no,
							pPrime_ind => amd_defaults.NOT_PRIME_PART,
							pPrime_ind_cleaned => null,
							pBadRc => amd_spare_parts_pkg.UNASSIGN_OLD_PRIME_PART_ERR);

				end MakePrimeAnEquivalentPart;


			begin -- UpdatePrimePartData
				result := UpdtNsiPrimePartData (pPrime_ind => pPrime_ind,
	 					  pNsi_sid => pNsi_sid,
	 					  pPartNo => pPart_no,
	 					  pNsn => pNsn,
						  pItem_type => pItem_type,
						  pOrder_quantity => pOrder_quantity,
						  pPlannerCode => pPlanner_code,
						  pSmr_code => pSmr_code,
						  pMic_code_lowest => pMic_code_lowest,
						  pAction_code => amd_defaults.UPDATE_ACTION,
						  pReturn_code => amd_spare_parts_pkg.CANNOT_UPADATE_NAT_STCK_ITEMS,
						  pMmac => pMmac) ;					 

				if result != SUCCESS then
				   return result;
				end if;

				if pNsn_type = amd_spare_parts_pkg.CURRENT_NSN then
					result := amd_spare_parts_pkg.ChgCurNsn2TempNsn(pNsiSid => pNsi_sid);
					if result != SUCCESS then
						return result;
					end if;
				end if;

				begin
					result := amd_spare_parts_pkg.UpdateAmdNsn(pNsn_Type => pNsn_Type,
													 pNsi_Sid => pNsi_sid,
													 pNsn => pNsn ) ;
				exception
					when others then
					   mRC := CANNOT_UPDATE_AMD_NSNS ;
					   ErrorMsg(pSqlfunction => 'updateAmdNsn',
							pError_location => 330,
							pKey_1 => pNsn_Type,
							pKey_2 => to_char(pNsi_sid),
							pKey_3 => pNsn) ;
					   raise ;
				end update_amd_nsns;

				result := MakePrimeAnEquivalentPart();
				if result = SUCCESS then
					result := insertNsiParts(pNsi_sid => pNsi_sid,
				   	  			pPart_no => pPart_no,
								pPrime_ind => pPrime_ind,
								pPrime_ind_cleaned => null,
								pBadRc => amd_spare_parts_pkg.MAKE_NEW_PRIME_PART_ERR);
				end if;
				if result = SUCCESS then
					result := MakeNsnSameForAllParts(pNsi_sid => pNsi_sid, pNsn => pNsn );
				end if;
				return result;
			end UpdatePrimePartData;

		begin -- DoPhysicalInsert
			debugMsg('DoPhysicalInsert', pLineNo => 150) ;
			result := PrepareDataForInsert;

			if result = SUCCESS then
				if NatStkItemExists(pNsn => pNsn, pNsi_sid => DoPhysicalInsert.nsi_sid) then
					null ; -- OK do nothing
				else -- create one
				    result := CreateNationalStockItem(pNsi_sid => DoPhysicalInsert.nsi_sid,
			 			   	  pNsn => pNsn,
			 				  pItem_type => pItem_type,
			 				  pOrder_quantity => pOrder_quantity,
			 				  pPlanner_code => pPlanner_code,
			 				  pSmr_code => pSmr_code,
			 				  pTactical => InsertRow.tactical,
			 				  pMic_code_lowest => InsertRow.pMic_code_lowest,
							  pNsn_type => pNsn_type,
							  pMmac => pMmac) ;					 
				end if;
			end if;

			if result = SUCCESS then
				result := InsertSparePart();
			end if;

			if result = SUCCESS then
				if IsPrimePart(pPrime_ind) then
					declare
						current_prime_part_no amd_nsi_parts.part_no%type := null;
					begin
						if IsPrimeReplacingExistingOne(pNsi_sid => DoPhysicalInsert.nsi_sid,
								pCurrent_prime_part_no 	=> current_prime_part_no) then
							begin
								result := UpdatePrimePartData(pNsn => pNsn,
											pNsi_sid => DoPhysicalInsert.nsi_sid,
											pCurrent_prime_part_no => current_prime_part_no);
							exception when others then
							   mRC := UPD_PRIME_PART_ERR ;
							   ErrorMsg(pSqlfunction => 'updatePrimePartData',
									pError_location => 340,
									pKey_1 => pNsn,
									pKey_2 => to_char(DoPhysicalInsert.nsi_sid),
									pKey_3 => current_prime_part_no) ;
							   raise ;
							end UpdatePrimePartData;
						else
							begin
								result := UpdatePrimePartData(pNsi_sid => DoPhysicalInsert.nsi_sid);
							exception when others then
							   ErrorMsg(pSqlfunction => 'updatePrimePartData',
									pError_location => 350,
									pKey_1 => to_char(DoPhysicalInsert.nsi_sid)) ;
							   raise ;
							end UpdatePrimePartData;
						end if;
					end CheckForExistingPrime;
				else
					begin
						result := InsertEquivalentPartData(pNsi_sid => DoPhysicalInsert.nsi_sid);
					exception when others then
					   mRC := UPD_PRIME_PART_ERR ;
					   ErrorMsg(pSqlfunction => 'insertEquiivalentPartData',
							pError_location => 360,
							pKey_1 => to_char(DoPhysicalInsert.nsi_sid)) ;
					   raise ;
					end;
				end if;
			end if ;
			if result = SUCCESS then
				if pNsn is not null then
					begin
						result := UpdateNatStkItem(pNsn, amd_defaults.INSERT_ACTION,pPart_no);
					exception when others then
					   mRC := UPDATE_NATSTK_ERR ;
					   ErrorMsg(pSqlfunction => 'updateNatStkItem',
							pError_location => 370,
							pKey_1 => pNsn,
							pKey_2 => pPart_no) ;
					   raise ;
					end;
				end if;
			end if;

			return result;
		end DoPhysicalInsert;


		function DoLogicalInsert return number is
		begin

			result := UpdateRow
						(pPart_no,
						pMfgr,
						pDate_icp,
						pDisposal_cost,
						pErc,
						pIcp_ind,
						pNomenclature,
						pOrder_lead_time,
						pOrder_quantity,
						pOrder_uom,
						pPrime_ind,
						pScrap_value,
						pSerial_flag,
						pShelf_life,
						pUnit_cost,
						pUnit_volume,
						pNsn,
						pNsn_type,
						pItem_type,
						pSmr_code,
						pPlanner_code,
						pMic_code_lowest,
						pAcquisition_advice_code,
						pMmac,
						pUnitOfIssue) ;
						
			if result = SUCCESS then
				begin
					-- Make it look like an insert was just
					-- done.
					update amd_spare_parts set
						action_code = amd_defaults.INSERT_ACTION
					where part_no = pPart_no;
				exception
					when others then
					   mRC := LOGICAL_INSERT_FAILED ;
					   ErrorMsg(pSqlfunction => 'update',
					   		pTablename => 'amd_spare_parts',
							pError_location => 380,
							pKey_1 => pPart_no) ;
					   raise ;
				end LogicalInsert;
			end if;
			return result;
		end DoLogicalInsert;


		function IsPartMarkedAsDeleted return boolean is

			function GetActionCode return varchar2 is
				action_code varchar2(1);
			begin
				select action_code
				into action_code
				from amd_spare_parts
				where		part_no = pPart_no;
				return action_code;
			exception
				when NO_DATA_FOUND then
					return null;
			end GetActionCode;

		begin
			return (GetActionCode() = amd_defaults.DELETE_ACTION);
		end IsPartMarkedAsDeleted;

    begin -- <<<---- InsertRow
		amd_spare_parts_pkg.mDebug := true ;
		amd_utils.mDebugThreshold := 100000 ;
		debugMsg(mArgs, pLineNo => 5) ;

--		insertLoadDetail(pPart_No,pNsn,pPrime_Ind,'Insert');

		if IsPartMarkedAsDeleted() then
			result := DoLogicalInsert();
		else
			unassociateTmpNsn(pNsn);

			result := DoPhysicalInsert();
		end if;
		if result = SUCCESS then
		   declare
		   		  rc number ;
				  smrCodePreferred amd_national_stock_items.SMR_CODE%type :=
				  		   amd_preferred_pkg.GetPreferredValue(mSmrCodeCleaned, pSmr_code) ;
				  mtbdrPreferred amd_national_stock_items.MTBDR%type := amd_preferred_pkg.GetPreferredValue(mMtbdrCleaned,mMtbdr_computed, mMtbdr) ;
				  plannerCodePreferred amd_national_stock_items.PLANNER_CODE%type := amd_preferred_pkg.GetPreferredValue(mPlannerCodeCleaned,pPlanner_code) ;
				  indenture tmp_a2a_part_info.indenture%type := a2a_pkg.getIndenture(smrCodePreferred) ;
				  
		   begin
		   		debugMsg('a2a.insertPartInfo(' || pMfgr || ', ' || pPart_no || ', ' ||  pUnitOfIssue || ', '
											   || pNomenclature || ', ' || smrCodePreferred || ', ' || pNsn || ', '
											   || plannerCodePreferred || ', ' || a2a_pkg.THIRD_PARTY_FLAG || ', ' || mtbdrPreferred
											   || ', ' || indenture || ')',555) ;
		   		rc := a2a_pkg.InsertPartInfo(mfgr => pMfgr, part_no => pPart_no, unit_issue => pUnitOfIssue, 
				   	  				nomenclature => PNomenclature, smr_code => smrCodePreferred, nsn => pNsn, 
									planner_code => plannerCodePreferred, third_party_flag => a2a_pkg.THIRD_PARTY_FLAG, 
									mtbdr => mtbdrPreferred, indenture => indenture,
									price => amd_preferred_pkg.GetPreferredValue(mUnitCostCleaned,pUnit_cost) ) ;
				if rc = SUCCESS then
					rc := a2a_pkg.InsertPartLeadTime(pPart_no,a2a_pkg.NEW_BUY,amd_preferred_pkg.GetPreferredValue( mOrderLeadTimeCleaned, pOrder_lead_time, amd_defaults.GetOrderLeadTime(pItem_type)) );
				end if ;
				if rc = SUCCESS then
				   result := a2a_pkg.InsertPartPricing(pPart_no,a2a_pkg.AN_ORDER,amd_preferred_pkg.GetPreferredValue(mUnitCostCleaned,pUnit_cost)) ; -- used for SCM 4.2
				end if ;
		   end ;
 	    end if ;

		mDebug := false ;
		return result;

	exception
		when part_already_exists then
			 return SUCCESS ; -- ignore this error
		when others then
		   ErrorMsg(pSqlfunction => 'insertRow',
				pError_location => 390 ) ;
		   return mRC ;
	end InsertRow;


	function UpdateRow(
							pPart_no in varchar2,
							pMfgr in varchar2,
							pDate_icp in date,
							pDisposal_cost in number,
							pErc in varchar2,
							pIcp_ind in varchar2,
							pNomenclature in varchar2,
							pOrder_lead_time in number,
							pOrder_quantity in number,
							pOrder_uom in varchar2,
							pPrime_ind in varchar2,
							pScrap_value in number,
							pSerial_flag in varchar2,
							pShelf_life in number,
							pUnit_cost in number,
							pUnit_volume in number,
							pNsn in varchar2,
							pNsn_type in varchar2,
							pItem_type in varchar2,
							pSmr_code in varchar2,
							pPlanner_code in varchar2,
							pMic_code_lowest in varchar2,
							pAcquisition_advice_code in varchar2,
							pMmac in varchar2,
							pUnitOfIssue in varchar2) RETURN NUMBER is

		/* Although the following variables are local to the UpdateRow
		  procedure, you will see them referenced as UpdateRow.variable_name.
		  This was done to improve readability.  A similar approach is used
		  for package constants: package_name.constant_name.
		 */
		nsiSid      amd_national_stock_items.nsi_sid%type := null;
		result      number := SUCCESS;
		tactical    amd_spare_parts.tactical%type := 'N';


		/* Put a wrapper on the amd_utils.InsertErrorMsg procedure, so it is
			more specific to the UpdateRow function.  Output gets stored
			into amd_load_details and amd_load_status.
		*/


		function PrepareDataForUpdate return number is
			function GetSmrCode
				return amd_national_stock_items.smr_code%type is
				smr_code_cleaned	amd_national_stock_items.smr_code_cleaned%type;
			begin
				select smr_code_cleaned
				into smr_code_cleaned
				from amd_national_stock_items items
				where nsi_sid = nsiSid;
				return amd_preferred_pkg.GetPreferredValue(smr_code_cleaned,
					pSmr_code);
			exception
				when NO_DATA_FOUND then
					return null;
			end GetSmrCode;


			function GetUnitCost return amd_spare_parts.unit_cost%type is
				unit_cost_cleaned amd_national_stock_items.unit_cost_cleaned%type;
				unit_cost_defaulted amd_spare_parts.unit_cost_defaulted%type;
			begin
				begin
					select unit_cost_cleaned, unit_cost_defaulted
					into unit_cost_cleaned, unit_cost_defaulted
					from amd_national_stock_items
					where nsn = pNsn;
				exception
					when NO_DATA_FOUND then
						unit_cost_cleaned := null;
					when others then
						raise amd_spare_parts_pkg.UNIT_COST_CLEANED_VIA_NSN;
				end get_unit_cost_cleaned;
				return amd_preferred_pkg.GetPreferredValue(unit_cost_cleaned,
					pUnit_cost, unit_cost_defaulted);
			end GetUnitCost;

		begin -- PrepareDataForUpdate
			begin
				UpdateRow.tactical :=
					amd_validation_pkg.GetTacticalInd(GetUnitCost(),GetSmrCode() );
			exception
				when amd_spare_parts_pkg.UNIT_COST_CLEANED_VIA_NSN then
				   mRC := amd_spare_parts_pkg.CANNOT_GET_UNIT_COST_CLEANED ;
				   ErrorMsg(pSqlfunction => 'getTacticalInd',
						pError_location => 400 ) ;
				   raise ;
			end setTactical;

			if pPlanner_code is not null then
				if not amd_validation_pkg.IsValidPlannerCode(pPlanner_code) then
					if amd_validation_pkg.AddPlannerCode(pPlanner_code) != amd_validation_pkg.SUCCESS then
						return amd_spare_parts_pkg.ADD_PLANNER_CODE_ERR;
					end if;
				end if;
			end if;

			if pOrder_uom is not null then
				if not amd_validation_pkg.IsValidUomCode(pOrder_uom) then
					if amd_validation_pkg.AddUomCode(pOrder_uom) != amd_validation_pkg.SUCCESS then
						return amd_spare_parts_pkg.ADD_UOM_CODE_ERR;
					end if;
				end if;
			end if;

			return SUCCESS;
		exception when others then
		   mRC := amd_spare_parts_pkg.PREP_DATA_FOR_UPDT_ERR ;
		   ErrorMsg(pSqlfunction => 'prepareDataForUpdate',
				pError_location => 410 ) ;
		   raise ;
		end PrepareDataForUpdate;


		function UpdateAmdSparePartRow(
							pPartNo amd_spare_parts.part_no%type,
							pNsn amd_spare_parts.nsn%type) return number is
		begin
			debugMsg('updateAmdSparePartRow('||pPartNo||','||pNsn||')', pLineNo => 160);
			update amd_spare_parts set
				mfgr            = pMfgr,
				date_icp        = pDate_icp,
				disposal_cost   = pDisposal_cost,
           	erc             = pErc,
           	icp_ind         = pIcp_ind,
           	nomenclature    = pNomenclature ,
           	order_lead_time = pOrder_lead_time,
           	order_uom       = pOrder_uom,
           	scrap_value     = pScrap_value,
           	serial_flag     = pSerial_flag,
           	shelf_life      = pShelf_life,
           	unit_cost       = pUnit_cost,
           	unit_volume     = pUnit_volume,
				tactical        = UpdateRow.tactical,
				action_code     = amd_defaults.UPDATE_ACTION,
				last_update_dt  = sysdate,
				nsn             = pNsn,
				acquisition_advice_code = pAcquisition_advice_code,
				unit_of_issue = pUnitOfIssue
			where part_no = pPartNo;

			return SUCCESS;
		exception when others then
		   mRC := amd_spare_parts_pkg.UPDT_SPAREPART_ERR ;
		   ErrorMsg(pSqlfunction => 'updateAmdSparePartRow',
				pError_location => 420 ) ;
		   raise ;
		end UpdateAmdSparePartRow;


		function UpdatePrimePartData return number is
		begin
		
			<<update_amd_nsns>>
			begin
				result := amd_spare_parts_pkg.UpdateAmdNsn(
					   pNsn_type => pNsn_type,
					   pNsi_sid => nsiSid,
					   pNsn => pNsn);
			exception when others then
			   mRC := amd_spare_parts_pkg.CANNOT_UPDATE_AMD_NSNS ;
			   ErrorMsg(pSqlfunction => 'updateAmdNsn',
					pError_location => 430 ) ;
		   	   raise ;
			end update_amd_nsns;

			return SUCCESS;
		exception when others then
		   mRC := amd_spare_parts_pkg.UPDT_PRIMEPART_ERR ;
		   ErrorMsg(pSqlfunction => 'updatePrimePartData',
				pError_location => 440 ) ;
	   	   raise ;
		end UpdatePrimePartData;


		function NsnChanged(
							pPartNo varchar2,
							pNsn varchar2) return boolean is
			nsn amd_nsns.nsn%type;
		begin
			debugMsg('nsnChanged('||pPartNo||','||pNsn||')', pLineNo => 170);
			select an.nsn
			into nsn
			from
				amd_nsi_parts anp,
				amd_nsns an
			where
				anp.nsi_sid = an.nsi_sid
				and anp.part_no = pPartNo
				and anp.unassignment_date is null
				and an.nsn_type = 'C';

			if nsn != pNsn then
				return true;
			else
				return false;
			end if;

		exception
			when NO_DATA_FOUND then
				return TRUE;
		end NsnChanged;


		function PrimeIndChanged return boolean is
			prime_ind amd_nsi_parts.prime_ind%type := null;
		begin
			debugMsg('primeIndChanged(' || prime_ind || ')', pLineNo => 180);

			select prime_ind
			into prime_ind
			from amd_nsi_parts
			where nsi_sid = nsiSid
			and part_no = pPart_no
			and unassignment_date is null;

			return (prime_ind != pPrime_ind);
		exception
			when no_data_found then
				return true;
		end;


		function UpdateNsnForPrimePart return number is
		/*
		IMPORTANT:  The prime part controls the value of
		the nsn column in amd_spare_parts. Whenever the value
		of the amd_spare_parts nsn column changes for a prime part, the
		following will happen:
				1.	Update the nsn column of amd_national_stock_items.
				2.	Using the amd_nsi_parts linked via nsi_sid update the
					nsn column of amd_spare_parts with the new value -
					i.e. update the prime part and its equivalent parts.
		*/
			result number := SUCCESS;

			function UpdtNsnOfNationalStockItems(
							pNsiSid number) return number is
			begin
				debugMsg('updtNsnOfNationalStockItems('||pNsn||','||pNsiSid||')', pLineNo => 190);
				update amd_national_stock_items set
					nsn = pNsn
				where nsi_sid = pNsiSid;
				return SUCCESS;
			exception when others then
			   mRC := amd_spare_parts_pkg.CANNOT_UPDT_NSN_NAT_STCK_ITEMS ;
			   ErrorMsg(pSqlfunction => 'update', pTableName => 'amd_national_stock_items',
					pError_location => 450 ) ;
		   	   raise ;
			end UpdtNsnOfNationalStockItems;

		begin -- UpdateNsnForPrimePart

			if result = SUCCESS then
				result := UpdtNsnOfNationalStockItems(nsiSid);
			end if;

			if result = SUCCESS then
				result := MakeNsnSameForAllParts(pNsi_sid => nsiSid,
					   	  						   pNsn => pNsn);
			end if;
			return result;
		exception when others then
		   mRC := amd_spare_parts_pkg.UPDT_NSN_PRIME_ERR ;
		   ErrorMsg(pSqlfunction => 'updateNsnForPrimePart',
				pError_location => 460 ) ;
	   	   raise ;
		end UpdateNsnForPrimePart;


		function UpdatePrimeInd return number is
			result number := SUCCESS;

			function UnassignPrimePart(
							pPart_no in amd_nsi_parts.part_no%type) return number is
			begin
				debugMsg('unassignPrimePart(' || pPart_no || ')', pLineNo => 200);

				update amd_nsi_parts set
					unassignment_date = sysdate
				where
					part_no = pPart_no
					and (prime_ind             = amd_defaults.PRIME_PART
							or prime_ind_cleaned = amd_defaults.PRIME_PART)
					and unassignment_date is null;
					
				-- Since this prime_part is unassigned logically delete the 
				-- national_stock_item
				update amd_national_stock_items
				set action_code = amd_defaults.DELETE_ACTION,
				last_update_dt = sysdate				
				where prime_part_no = pPart_no ;

				return SUCCESS;
			end UnassignPrimePart;

			function MakeCurrentPrimeIntoEquiv return number is
				result   number := SUCCESS;
				part_no  amd_nsi_parts.part_no%type := null;
			begin
				begin
					-- get the current Prime Part
					select part_no
					into part_no
					from amd_nsi_parts
					where nsi_sid = nsiSid
					and (prime_ind = amd_defaults.PRIME_PART
						or prime_ind_cleaned = amd_defaults.PRIME_PART)
					and unassignment_date is null;
				exception
					when no_data_found then
						/* This can occur when a prime has alreay become an
							equivalent part, before the NEW prime is processed.
							*/
						return SUCCESS;
					when others then
					   mRC := amd_spare_parts_pkg.UNABLE_TO_GET_PRIME_PART ;
					   ErrorMsg(pSqlfunction => 'select', pTableName => 'amd_nsi_parts',
							pError_location => 470,
							pKey_1 => to_char(nsiSid)) ;
		   	   		   raise ;
				end GetCurrentPrimePart;

				result := UnassignPrimePart(pPart_no => part_no);

				if result = SUCCESS then
					 result := insertNsiParts(pNsi_sid => nsiSid,
								pPart_no => part_no,
							   pPrime_ind => amd_defaults.NOT_PRIME_PART,
							   pPrime_ind_cleaned => null,
							   pBadRc =>amd_spare_parts_pkg.ASSIGN_PRIME_TO_EQUIV_ERR);
				end if;

				return result;

			end MakeCurrentPrimeIntoEquiv;


			function UpdatePrimePartNo return number is
				temp_prime_part_no amd_national_stock_items.prime_part_no%type := null;
			begin
				<<getPrimePart>>
				begin
				    -- check if the prime part has been set yet
					select part_no
					into temp_prime_part_no
					from amd_nsi_parts
					where nsi_sid = nsiSid
					and unassignment_date is null
					and (prime_ind = amd_defaults.PRIME_PART or prime_ind_cleaned = amd_defaults.PRIME_PART);
				exception
					when no_data_found then
				  	   null ; -- OK the prime_part_no has not been set yet
					when others then
					   mRC := amd_spare_parts_pkg.UNABLE_TO_GET_PRIME_PART ;
					   ErrorMsg(pSqlfunction => 'select', pTableName => 'amd_nsi_parts',
							pError_location => 480,
							pKey_1 => to_char(nsiSid)) ;
		   	   		   raise ;
				end getPrimePart ;
				
				if temp_prime_part_no != null then
				   begin
					   select prime_part_no
						into temp_prime_part_no
					   from amd_national_stock_items
					   where nsi_sid = nsiSid
					   and prime_part_no = temp_prime_part_no;
				   exception
					   when no_data_found then
							begin
							    /* This should not happen, but just in
								 * case this will gaurantee that the
								 * prime_part_no = part_no in
								 * amd_nsi_parts with prime_ind = 'Y'
								 */
								update amd_national_stock_items set
									prime_part_no  = temp_prime_part_no,
									last_update_dt = sysdate,
									action_code    = amd_defaults.UPDATE_ACTION
								where nsi_sid = nsiSid;
							exception when others then
							   mRC := amd_spare_parts_pkg.UPDT_NULL_PRIME_COLS_ERR ;
							   ErrorMsg(pSqlfunction => 'update', 
							   		pTableName => 'amd_national_stock_items',
									pError_location => 490,
									pKey_1 => to_char(nsiSid)) ;
				   	   		   raise ;
							end UpdateNationalStockItems;
					   when others then
						   mRC := amd_spare_parts_pkg.UNABLE_TO_GET_PRIME_PART ;
						   ErrorMsg(pSqlfunction => 'updatePrimePartNo', 
								pError_location => 500)  ;
			   	   		   raise ;
				   end;
				else
					-- the prime part is null, but it should get
					-- set with subsequent data
					begin
						update amd_national_stock_items set
							prime_part_no  = temp_prime_part_no,
							last_update_dt = sysdate,
							action_code    = amd_defaults.UPDATE_ACTION
						where nsi_sid = nsiSid;
					exception when others then
					   mRC := amd_spare_parts_pkg.UPDT_NULL_PRIME_COLS_ERR2 ;
					   ErrorMsg(pSqlfunction => 'update',
					   		pTableName => 'amd_national_stock_items', 
							pError_location => 510,
							pKey_1 => to_char(nsiSid))  ;
		   	   		   raise ;
					end UpdateNationalStockItems;
				end if ;
				return SUCCESS;
			end UpdatePrimePartNo;

		begin --  UpdatePrimeInd
			debugMsg('updatePrimeInd()', pLineNo => 210);
			if IsPrimePart(pPrime_ind) then
				result := MakeCurrentPrimeIntoEquiv();
				if result = SUCCESS then

					unassignPart(pPart_no);

					begin
						result := insertNsiParts(pNsi_sid => nsiSid,
							   	      pPart_no => pPart_no,
									  pPrime_ind => pPrime_ind,
									  pPrime_ind_cleaned => null,
									  pBadRc => amd_spare_parts_pkg.ASSIGN_NEW_PRIME_PART_ERR);
					end AssignNewPrimePart;

					begin
					    -- make sure action_code and last_update_dt get set too
						update amd_national_stock_items set
							prime_part_no = pPart_no,
							nsn           = pNsn,
							last_update_dt = sysdate,
							action_code = amd_defaults.UPDATE_ACTION
						where nsi_sid = nsiSid;
					exception when others then
					   mRC := amd_spare_parts_pkg.UPDT_ERR_NATIONAL_STK_ITEMS ;
					   ErrorMsg(pSqlfunction => 'update',
					   		pTableName => 'amd_national_stock_items', 
							pError_location => 520,
							pKey_1 => to_char(nsiSid))  ;
		   	   		   raise ;
					end UpdateNationalStockItems;

					if result = SUCCESS then
					    /* added invocation of MakeNsnSameForAllParts to
						 * to fix bug where equiv parts did not have the same
						 * nsn as the prime part.
						 */
						result := MakeNsnSameForAllParts(pNsi_sid => nsiSid,
							   	  									pNsn => pNsn);
					end if;

				end if;

			else
				result := UnassignPrimePart(pPart_no => pPart_no);
				if result = SUCCESS then
					begin
					   result := insertNsiParts(pNsi_sid => nsiSid,
					   		  	    pPart_no => pPart_no,
									pPrime_ind => pPrime_ind,
									pPrime_ind_cleaned => null,
									pBadRc => amd_spare_parts_pkg.ASSIGN_NEW_EQUIV_PART_ERR);
					end AssignNewEquivPart;

					result := UpdatePrimePartNo;

				end if;
			end if;

		return result;

		exception when others then
		   mRC := amd_spare_parts_pkg.UPD_NSI_PARTS_ERR ;
		   ErrorMsg(pSqlfunction => 'updatePrimeInd',
				pError_location => 530) ;
  	   	   raise ;
		end UpdatePrimeInd;


		function InsertNewNsn(
							pNsi_sid out amd_nsns.nsi_sid%type) return number is
			result number := SUCCESS;

			/* Get the nsi_sid using the part_no */
			function GetNsiSid return number is
			begin
				pNsi_sid := amd_utils.GetNsiSid(pPart_no => pPart_no);
				return SUCCESS;
			exception
				when no_data_found then
					 raise;
			    when others then
				   pNsi_sid := null;
				   mRC := amd_spare_parts_pkg.GET_NSISID_BY_PART_ERR ;
				   ErrorMsg(pSqlfunction => 'getNsiSid',
						pError_location => 540) ;
		  	   	   raise ;
			end GetNsiSid;

		begin -- InsertNewNsn
			result := GetNsiSid();

			if result = SUCCESS then
				result := InsertAmdNsn(pNsi_sid => pNsi_sid,
					   pNsn => pNsn,
					   pNsn_type => pNsn_type);
			end if;
			return result;
		exception
		    when no_data_found then
			    return CreateNationalStockItem(pNsi_sid => pNsi_sid,
	 			   	  pNsn => pNsn,
		 				  pItem_type => pItem_type,
		 				  pOrder_quantity => pOrder_quantity,
		 				  pPlanner_code => pPlanner_code,
		 				  pSmr_code => pSmr_code,
		 				  pTactical => UpdateRow.tactical,
		 				  pMic_code_lowest => pMic_code_lowest,
						  pNsn_type => pNsn_type,
						  pMmac => pMmac) ;					 

		    when others then
			   pNsi_sid := null;
			   mRC := amd_spare_parts_pkg.NEW_NSN_ERROR ;
			   ErrorMsg(pSqlfunction => 'insertNewNsn',
					pError_location => 550) ;
	  	   	   raise ;
		end InsertNewNsn;


		function GetNsiSid(
							pNsi_sid out amd_nsns.nsi_sid%type) return number is

		begin
			debugMsg('getNsiSid()', pLineNo => 220);
			pNsi_sid := amd_utils.GetNsiSid(pNsn => pNsn);
			debugMsg('pNsi_sid=' || pNsi_sid, pLineNo => 230) ;
			return SUCCESS;
		exception
			when no_data_found then
				raise ; -- must be a new nsn

			when others then
			   pNsi_sid := null;
			   ErrorMsg(pSqlfunction => 'getNsiSid',
					pError_location => 560) ;
	  	   	   raise ;
		end GetNsiSid;


		function CheckNsnAndPrimeInd return number is
			result number := SUCCESS;
		begin
			debugMsg('checkNsnAndPrimeInd()',pLineNo => 240);

			if NsnChanged(pPart_no,pNsn) then
			   if IsPrimePart(pPrime_ind) then
					if PrimeIndChanged() then
						result := UpdatePrimeInd();
						if result = SUCCESS then
							result := UpdateNsnForPrimePart();
						end if;
					else
						result := UpdateNsnForPrimePart();
					end if;
	
					result := MakeNsnSameForAllParts(nsiSid,pNsn);
				else
					unassignPart(pPart_no);
					
					result := insertNsiParts(pNsi_sid => nsiSid,
						   	      pPart_no => pPart_no,
								  pPrime_ind => pPrime_ind,
								  pPrime_ind_cleaned => null,
								  pBadRc => amd_spare_parts_pkg.ASSIGN_NEW_PRIME_PART_ERR);
				
					if PrimeIndChanged() then
						result := UpdatePrimeInd();
					end if;
				end if ;
			else
				if PrimeIndChanged() then
					result := UpdatePrimeInd();
				end if;
			end if;
			return result;
		exception
			when amd_spare_parts_pkg.CANNOT_FIND_PART then
			   ErrorMsg(pSqlfunction => 'CheckNsnAndPrimeInd',
					pError_location => 570) ;
	  	   	   raise ;
			when others then
			   mRC := amd_spare_parts_pkg.CHK_NSN_AND_PRIME_ERR2 ;
			   ErrorMsg(pSqlfunction => 'CheckNsnAndPrimeInd',
					pError_location => 580) ;
	  	   	   raise ;
		end CheckNsnAndPrimeInd;

		function updatePartLeadTime return number is
				 result number := SUCCESS ;
				 order_lead_time amd_spare_parts.order_lead_time%type ;
				 order_lead_time_cleaned amd_national_stock_items.order_lead_time_cleaned%type ;
		begin
			 select parts.order_lead_time, items.order_lead_time_cleaned 
			 into order_lead_time, order_lead_time_cleaned
			 from amd_spare_parts parts, amd_national_stock_items items
			 where parts.part_no = pPart_no
			 and parts.nsn = items.nsn ;
			 
			 if order_lead_time != pOrder_lead_time
			 or (order_lead_time is null and pOrder_lead_time is not null)
			 or (order_lead_time is not null and pOrder_lead_time is null) 
			 or order_lead_time_cleaned != mOrderLeadTimeCleaned
			 or (order_lead_time_cleaned is null and mOrderLeadTimeCleaned is not null)
			 or (order_lead_time_cleaned is not null and mOrderLeadTimeCleaned is null) 
			 then
			 	result := a2a_pkg.UpdatePartLeadTime(pPart_no,a2a_pkg.NEW_BUY,amd_preferred_pkg.GetPreferredValue(mOrderLeadTimeCleaned, pOrder_lead_time, amd_defaults.GetOrderLeadTime(pItem_type))) ;
			 end if ;
			 
			 return result ;
		exception
			when standard.NO_DATA_FOUND then
				 return result ;
			when others then
			   ErrorMsg(pSqlfunction => 'updatePartLeadTime',
					pError_location => 590,
					pKey_1 => pPart_no,
					pKey_2 => pNsn) ;
				raise ;
		end updatePartLeadTime ;
		
		function updatePartPricing return number is
				 unit_cost amd_spare_parts.unit_cost%type ;
				 unit_cost_cleaned amd_national_stock_items.unit_cost_cleaned%type ;
		begin
			 select unit_cost, unit_cost_cleaned into unit_cost, unit_cost_cleaned
			 from amd_spare_parts parts, amd_national_stock_items items
			 where parts.part_no = pPart_no
			 and parts.nsn = items.nsn ;
			 
			 if unit_cost != pUnit_Cost
			 or (unit_cost is null and pUnit_cost is not null)
			 or (unit_cost is not null and pUnit_cost is null)			   
			 or unit_cost_cleaned != mUnitCostCleaned
			 or (unit_cost_cleaned is null and mUnitCostCleaned is not null)
			 or (unit_cost_cleaned is not null and mUnitCostCleaned is null) then
			 	result := a2a_pkg.UpdatePartPricing(pPart_no,a2a_pkg.AN_ORDER,amd_preferred_pkg.GetPreferredValue(mUnitCostCleaned, pUnit_Cost)) ;
			 end if ;
			 return result ;
		exception
			when standard.no_data_found then
				 return result ; 
			when others then
			   mRC := amd_spare_parts_pkg.CANNOT_UPDATE_PART_PRICING ; 
			   ErrorMsg(pSqlfunction => 'updatePartPricing',
					pError_location => 600) ;
			   raise ;
		end updatePartPricing ;
		
		procedure validateInput is
	                part_no amd_spare_parts.part_no%type ;
                mfgr amd_spare_parts.mfgr%type ;
                date_icp  amd_spare_parts.DATE_ICP%type ;
                disposal_cost amd_spare_parts.DISPOSAL_COST%type ;
                erc amd_spare_parts.ERC%type ; 
                icp_ind amd_spare_parts.ICP_IND%type ; 
                nomenclature amd_spare_parts.NOMENCLATURE%type ;
                order_lead_time amd_spare_parts.ORDER_LEAD_TIME%type ;
				order_quantity amd_national_stock_items.ORDER_QUANTITY%type ;
                order_uom amd_spare_parts.ORDER_UOM%type ;
				prime_ind amd_nsi_parts.PRIME_IND%type ;
                scrap_value amd_spare_parts.SCRAP_VALUE%type ;
                serial_flag amd_spare_parts.SERIAL_FLAG%type ;
                shelf_life amd_spare_parts.SHELF_LIFE%type ;
                unit_cost amd_spare_parts.UNIT_COST%type ;
                unit_volume amd_spare_parts.UNIT_VOLUME%type ;
                nsn amd_spare_parts.NSN%type ;
				nsn_type amd_nsns.NSN_TYPE%type ;
                item_type amd_national_stock_items.ITEM_TYPE%type ;
                smr_code amd_national_stock_items.SMR_CODE%type ;
                planner_code amd_national_stock_items.PLANNER_CODE%type ;
				mic_code_lowest amd_national_stock_items.MIC_CODE_LOWEST%type ;
				acquisition_advice_code amd_spare_parts.ACQUISITION_ADVICE_CODE%type ;
				mmac amd_national_stock_items.MMAC%type ;
				unit_Of_Issue amd_spare_parts.UNIT_OF_ISSUE%type ;
				mtbdr amd_national_stock_items.MTBDR%type ;
				mtbdr_computed amd_national_stock_items.mtbdr_computed%type ;
  				qpei_weighted amd_national_stock_items.QPEI_WEIGHTED%type ;
  				condemn_avg_cleaned amd_national_stock_items.CONDEMN_AVG_CLEANED%type ;
  				criticality_cleaned amd_national_stock_items.CRITICALITY_CLEANED%type ;
  				mtbdr_cleaned amd_national_stock_items.MTBDR_CLEANED%type ;
  				nrts_avg_cleaned amd_national_stock_items.NRTS_AVG_CLEANED%type ;
  				cost_to_repair_off_base_cleand amd_national_stock_items.COST_TO_REPAIR_OFF_BASE_CLEAND%type ;
  				time_to_repair_off_base_cleand amd_national_stock_items.TIME_TO_REPAIR_OFF_BASE_CLEAND%type ;
  				order_Lead_Time_cleaned amd_national_stock_items.ORDER_LEAD_TIME_CLEANED%type ;
  				planner_code_cleaned amd_national_stock_items.planner_code_cleaned%type ;
  				rts_avg_cleaned amd_national_stock_items.RTS_AVG_CLEANED%type ;
  				smr_code_cleaned amd_national_stock_items.smr_code_cleaned%type ;
  				unit_cost_cleaned amd_national_stock_items.UNIT_COST_CLEANED%type ;
  				condemn_avg amd_national_stock_items.CONDEMN_AVG%type ;
  				criticality amd_national_stock_items.CRITICALITY%type ;
  				nrts_avg amd_national_stock_items.NRTS_AVG%type ;
  				rts_avg amd_national_stock_items.RTS_AVG%type ;
				lineNo number := 0 ;
				result number ;
		begin
			lineNo := lineNo + 1;part_no := pPart_no ;
			lineNo := lineNo + 1;mfgr :=   pMfgr ;
			lineNo := lineNo + 1;date_icp := pDate_icp ;
			lineNo := lineNo + 1;disposal_cost := pDisposal_cost ;
			lineNo := lineNo + 1;erc := pErc ;
			lineNo := lineNo + 1;icp_ind :=  pIcp_ind ;
			lineNo := lineNo + 1;nomenclature :=  pNomenclature ;
			lineNo := lineNo + 1;order_lead_time := pOrder_lead_time ;
			lineNo := lineNo + 1;order_quantity :=	pOrder_quantity ;
            lineNo := lineNo + 1;order_uom :=    pOrder_uom ;
			lineNo := lineNo + 1;prime_ind :=	pPrime_ind ;
            lineNo := lineNo + 1;scrap_value :=    pScrap_value ;
            lineNo := lineNo + 1;serial_flag :=    pSerial_flag ;
            lineNo := lineNo + 1;shelf_life := pShelf_life ;
            lineNo := lineNo + 1;unit_cost :=    pUnit_cost ;
            lineNo := lineNo + 1;unit_volume :=    pUnit_volume ;
            lineNo := lineNo + 1;nsn :=    pNsn ;
			lineNo := lineNo + 1;nsn_type :=	pNsn_type ;
            lineNo := lineNo + 1;item_type :=    pItem_type ;
            lineNo := lineNo + 1;smr_code :=    pSmr_code ;
            lineNo := lineNo + 1;planner_code :=    pPlanner_code ;
			lineNo := lineNo + 1;mic_code_lowest :=	pMic_code_lowest ;
			lineNo := lineNo + 1;acquisition_advice_code :=	pAcquisition_advice_code ;
			lineNo := lineNo + 1;mmac :=	pMmac ;
			lineNo := lineNo + 1;unit_of_issue :=	pUnitOfIssue ;
			/*
			lineNo := lineNo + 1;mtbdr := pMtbdr ;
  			lineNo := lineNo + 1;qpei_weighted := pQpeiWeighted ;
  			lineNo := lineNo + 1;condemn_avg_cleaned := pCondemnAvgCleaned ;
  			lineNo := lineNo + 1;criticality_cleaned := pCriticalityCleaned ;
  			lineNo := lineNo + 1;mtbdr_cleaned := pMtbdrCleaned ;
  			lineNo := lineNo + 1;nrts_avg_cleaned := pNrtsAvgCleaned ;
  			lineNo := lineNo + 1;cost_to_repair_off_base_cleand := pCostOfRepairOffBaseCleand ;
  			lineNo := lineNo + 1;time_to_repair_off_base_cleand := pTimeToRepairOffBaseCleand ;
  			lineNo := lineNo + 1;order_Lead_Time_cleaned := pOrderLeadTimeCleaned ;
  			lineNo := lineNo + 1;planner_code_cleaned := pPlannerCodeCleaned ;
  			lineNo := lineNo + 1;rts_avg_cleaned := pRtsAvgCleaned ;
  			lineNo := lineNo + 1;smr_code_cleaned := pSmrCodeCleaned ;
  			lineNo := lineNo + 1;unit_cost_cleaned := pUnitCostCleaned ;
  			lineNo := lineNo + 1;condemn_avg := pCondemnAvg ;
  			lineNo := lineNo + 1;criticality := pCriticality ;
  			lineNo := lineNo + 1;nrts_avg := pNrtsAvg ;
  			lineNo := lineNo + 1;rts_avg := pRtsAvg ;
			*/
		exception when others then
		   ErrorMsg(pSqlfunction => 'validateInput',
				pError_location => 610) ;
		   raise ;
		end validateInput ;
		
	begin -- <<<---- UpdateRow
		validateInput ;
		debugMsg(mArgs  || ')',pLineNo => 250);
--		insertLoadDetail(pPart_No,pNsn,pPrime_Ind,'Update');

		-- if part has moved to a different nsn then unassign existing part to
		-- break it's relation to old nsn so it can get associated with a
		-- different sid(new nsn). Also break any current/temp nsn relation of
		-- old nsn(current) with incoming(new) nsn(temp).
		--
		-- "moved" means old nsn and new nsn appear in CAT1 at the same time or
		-- both nsns are already in AMD on different sids,
		-- therefore, they are no longer related regardless of what amd_nsns says.
		-- that's why the part needs to be unassigned from the old nsn.
		--
		if (hasPartMoved(pPart_no,pNsn)) then
			unassociateTmpNsn(pNsn);
			unassignPart(pPart_no);
		end if;

		-- retrieve the nsi_sid right away, since it will be make
		-- retrieving data from the amd_national_stock_items,
		-- amd_nsns, and amd_nsi_parts easier
		begin
			result := GetNsiSid(pNsi_sid => nsiSid);
			if result != SUCCESS then
				return result;
			end if;
		exception
			when no_data_found then
				/* This must be a new nsn - add it to amd_nsns
					using part_no to get the current nsi_sid
				*/
				result := InsertNewNsn(pNsi_sid => nsiSid);
				if result != SUCCESS then
					return result;
				end if;
		end;

		/* The nsi_sid should not be null, but just leave this code in
			as a backup parachute!
			*/
		if nsiSid is null then
		   ErrorMsg(pSqlfunction => 'getNsiSid',
				pError_location => 620) ;
		   raise cannotGetNsiSid ;
		end if;

		if result = SUCCESS then
			result := CheckNsnAndPrimeInd();
		end if;

		if result = SUCCESS then
			result := PrepareDataForUpdate();
		end if;

		if result = SUCCESS then
			result := UpdateAmdSparePartRow(pPart_no,pNsn);
		end if;

		if result = SUCCESS then
			result := UpdtNsiPrimePartData (pPrime_ind => pPrime_ind,
 					  pNsi_sid => nsiSid,
 					  pPartNo => pPart_no,
 					  pNsn => pNsn,
					  pItem_type => pItem_type,
					  pOrder_quantity => pOrder_quantity,
					  pPlannerCode => pPlanner_code,
					  pSmr_code => pSmr_code,
					  pMic_code_lowest => pMic_code_lowest,
					  pAction_code => amd_defaults.UPDATE_ACTION,
					  pReturn_code => amd_spare_parts_pkg.UPDATE_NATSTK_ERR,
					  pMmac => pMmac) ;					 
		end if ;
		if result = SUCCESS then
			result := amd_spare_parts_pkg.UpdateAmdNsn(
				   pNsn_type => pNsn_type,
				   pNsi_sid => nsiSid,
				   pNsn => pNsn);
		end if;

		if result = SUCCESS then
			if pNsn is not null then
				result:= UpdateNatStkItem(pNsn,amd_defaults.UPDATE_ACTION,pPart_no);
			end if;
		end if;

		-- Update amd_national_stock_items.action_code = 'D' for any other
		-- nsi_sid this part came off of that has no parts assigned to it.
		-- An nsi_sid w/o assigned parts is a "deleted" nsi_sid.
		--
		debugMsg('updating action code to D',pLineNo => 260) ;
		update amd_national_stock_items set
			action_code    = 'D',
			last_update_dt = sysdate
		where
			action_code != 'D'
			and nsi_sid in
				(select nsi_sid
				from amd_nsi_parts
				where part_no = pPart_no
					and nsi_sid != nsiSid
				minus
				select nsi_sid
				from amd_nsi_parts
				where
					nsi_sid in
						(select nsi_sid from amd_nsi_parts
						where part_no = pPart_no)
					and unassignment_date is null);

		if result = SUCCESS then
		   declare
		   		  rc number ;
				  smrCodePreferred amd_national_stock_items.SMR_CODE%type := amd_preferred_pkg.GetPreferredValue(mSmrCodeCleaned,pSmr_code) ;
				  plannerCodePreferred amd_national_stock_items.PLANNER_CODE%type := amd_preferred_pkg.GetPreferredValue(mPlannerCodeCleaned,pPlanner_code) ;
				  mtbdrPreferred amd_national_stock_items.MTBDR%type := amd_preferred_pkg.GetPreferredValue(mMtbdrCleaned,mMtbdr_computed,mMtbdr) ;
				  indenture tmp_a2a_part_info.indenture%type := a2a_pkg.getIndenture(smrCodePreferred) ;
		   begin
		   	   a2a_pkg.mDebug := mDebug ; -- turn on debugging for a2a
			   rc := a2a_pkg.UpdatePartInfo(mfgr => pMfgr, part_no => pPart_no, 
							unit_issue => pUnitOfIssue, nomenclature => pNomenclature, 
							smr_code => smrCodePreferred, nsn => pNsn, planner_code => plannerCodePreferred, 
							third_party_flag => a2a_pkg.THIRD_PARTY_FLAG, mtbdr => mtbdrPreferred, indenture => indenture,
							price => amd_preferred_pkg.GetPreferredValue(mUnitCostCleaned, pUnit_Cost)) ;
			   if rc = SUCCESS then	
			      commit ;
			   	  rc := updatePartLeadTime ;
			   end if ;
			   if rc = SUCCESS then
				   result:= updatePartPricing ; -- used for SCM 4.2
			   end if ;
		   end ;
		
		end if ;
		return result;
	exception
		when others then
		   ErrorMsg(pSqlfunction => 'updateRow',
				pError_location => 630) ;
			return mRC ;
	end UpdateRow;


	function DeleteRow(
							pPart_no in varchar2,
							pNomenclature in varchar2,
							pMfgr in varchar2 ) return number is

		result number := SUCCESS ;
		nsn amd_spare_parts.nsn%type := null;

		/* Put a wrapper on the amd_utils.InsertErrorMsg procedure, so it is
			more specific to the DeleteRow function.  Output gets stored
			into amd_load_details and amd_load_status.
		*/

		function GetNsn return amd_spare_parts.nsn%type is
			nsn amd_spare_parts.nsn%type := null;
		begin
			select nsn
			into nsn
			from amd_spare_parts
			where part_no = pPart_no;
			return nsn;
		end GetNsn;

	begin
		mArgs := 'DeleteRow(' || pPart_no || ', ' || pMfgr || ', ' || pNomenclature || ')' ;
		result := a2a_pkg.DeletePartLeadTime(pPart_no) ;
		if result = SUCCESS then
		   result := a2a_pkg.DeletePartPricing(pPart_no) ; -- used for SCM 4.2
		end if ;
		insertLoadDetail(pPart_No,'nsn','pPrimeInd','Delete');
		nsn := GetNsn();

		-- nsn is NULLed to facilitate temp nsns turning into current nsns. When a
		-- temp nsn becomes current the nsn/nsi_sid association needs to be broken
		-- and this helps facilitate that when it may happen at a later time.
		--
		<<updateAmdSpareParts>>
		begin
			update amd_spare_parts set
				action_code    = amd_defaults.DELETE_ACTION,
				nsn            = NULL,
				last_update_dt = sysdate
			where part_no = pPart_no;
		exception when others then
		   ErrorMsg(pSqlfunction => 'update', pTableName => 'amd_spare_parts',
				pError_location => 640, pKey_1 => pPart_no) ;
		   raise ;
		end updateAmdSpareParts ;

		unassignPart(pPart_no);

		if nsn is not null then
		   result := UpdateNatStkItem(nsn, amd_defaults.DELETE_ACTION);
		else
			result := SUCCESS;
		end if;
		if result = SUCCESS then
		   declare
		   		  rc number ;
		   begin
		   		rc := a2a_pkg.DeletePartInfo(pPart_no, pNomenclature) ;
		   end ;
		end if ;
		return result ;
	exception when others then
		   ErrorMsg(pSqlfunction => 'deleteRow',
				pError_location => 650) ;
			return mRC ;
	end DeleteRow ;

	procedure loadCurrentBackOrder(debug in boolean := False) is
			  TB constant varchar2(1) := chr(9);   -- tab character
			  
			COMMIT_THRESHOLD constant number := 250 ;
			curDueCnt number := 0 ;
			curTmpCnt number := 0 ;
			
			  cursor curDue is
			  select cat1.prime primePartNo, 
				sum(nvl(req1.qty_due,0) + nvl(req1.qty_reserved,0)) DUE 
				from req1, cat1 
				where
				req1.select_from_part = cat1.part and 
				req1.request_id not like 'KIT%' and 
				req1.mils_source_dic is not null and 
				req1.select_from_sc like 'C17%' and 
				req1.status in ('U','H','O','R') and 
				req1.request_priority <= 5 and
				upper(substr(req1.select_from_sc,8,6)) not in ('CODLGB','ROTLGB') and
				upper(substr(req1.select_from_sc,8,3)) not in ('MRC','SUP','TST') and
				cat1.SOURCE_CODE = 'F77'
				group by cat1.prime ;

			  cursor curTmp1QtyDue is
				select qty_due qtyDue, prime_part_no primePartNo  from 
				(
				select sum(qty_due) qty_due, prime prime_part_no 
				from tmp1, cat1, amd_national_stock_items, amd_spare_parts
				where from_part = cat1.PART
				and returned_voucher is null
				and status = 'O' 
				and tcn = 'LBR'
			    and upper(substr(to_sc,1,3)) = 'C17'
				and upper(substr(to_sc,8,3)) not in ('MRC','SUP','TST') 
				and upper(substr(to_sc,8,6)) not in ('CODLGB','ROTLGB') 
				and trim(from_part) = trim(amd_spare_parts.part_no) 
				and amd_spare_parts.action_code in ('A','C') 
				and amd_spare_parts.nsn = amd_national_stock_items.nsn
				group by prime)
				where prime_part_no not in ( 
				  select distinct cat1.prime primePartNo 
					from req1, cat1 
					where
					req1.select_from_part = cat1.part and 
					req1.request_id not like 'KIT%' and 
					req1.mils_source_dic is not null and 
					req1.select_from_sc like 'C17%' and 
					req1.status in ('U','H','O','R') and 
					req1.request_priority <= 5 and
					cat1.SOURCE_CODE = 'F77') ;

		function getQtyDue(primePartNo in varchar2) return number is
				 qtyDue number ;
				 thePrime cat1.PRIME%type ;
		begin
			select sum(qty_due) qty_due, prime_part_no into qtyDue, thePrime
			from tmp1,  amd_national_stock_items, amd_spare_parts
			where 
			returned_voucher is null
			and status = 'O' 
			and tcn = 'LBR'
			and upper(substr(to_sc,1,3)) = 'C17'
			and upper(substr(to_sc,8,3)) not in ('MRC','SUP','TST') 
			and upper(substr(to_sc,8,6)) not in ('CODLGB','ROTLGB') 
			and trim(tmp1.from_part) = trim(amd_spare_parts.part_no) 
			and amd_spare_parts.action_code in ('A','C') 
			and amd_spare_parts.nsn = amd_national_stock_items.nsn
			and amd_national_stock_items.action_code in ('A','C')
			group by prime_part_no
			having prime_part_no = primePartNo ;
			
			return qtyDue ;
		exception
			when standard.NO_DATA_FOUND then
				 return 0 ;
		end getQtyDue ;
		
			  
	begin
		writeMsg(pTableName => 'amd_spare_parts', pError_location => 660,
				pKey1 => 'loadCurrentBackorder',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
				
	    update amd_national_stock_items
	    set current_backorder = null ;
	    commit ;
		
		writeMsg(pTableName => 'amd_spare_parts', pError_location => 670,
			pKey1 => 'curDue',
			pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		FOR rec IN curDue  LOOP
			if debug then
			   exit when curDueCnt = 10 ;
			end  if ;
			<<updateItems>>
			declare
				   qtyDue number := getQtyDue(trim(rec.primePartNo)) ;
			begin
			    if debug then
					writeMsg(pTableName => 'amd_spare_parts', pError_location => 680,
						pKey1 => 'primePartNo=' || trim(rec.primePartNo),
						pKey2 => 'current_backorder='  || to_char(rec.due + qtyDue)) ;
				end if ;
				update amd_national_stock_items
				set current_backorder =	rec.due + qtyDue
				where prime_part_no = trim(rec.primePartNo) ;
				curDueCnt := curDueCnt + 1 ;
				if mod(curDueCnt,COMMIT_THRESHOLD) = 0 then
				   commit ;
				end if ;
			exception
					 when standard.NO_DATA_FOUND then
					 	  null ;
					 when others then
					 	  raise ; 
			end updateItems ;
		END LOOP;
		writeMsg(pTableName => 'amd_spare_parts', pError_location => 690,
			pKey1 => 'curDue',
			pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		
		writeMsg(pTableName => 'amd_spare_parts', pError_location => 700,
			pKey1 => 'curTmp1QtyDue',
			pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		for rec in curTmp1QtyDue loop
		    if debug then
			   exit when curTmpCnt = 10 ;
			end if ;
			<<updateItems2>>
			begin
				if debug then
					writeMsg(pTableName => 'amd_spare_parts', pError_location => 710,
						pKey1 => 'primePartNo=' || trim(rec.primePartNo),
						pKey2 => 'current_backorder='  || to_char(rec.qtyDue) ) ;
				end if ;
				update amd_national_stock_items
				set current_backorder =	rec.qtyDue
				where prime_part_no = trim(rec.primePartNo) ;
				curTmpCnt := curTmpCnt + 1 ;
				if mod(curDueCnt + curTmpCnt, COMMIT_THRESHOLD) = 0 then
				   commit ;
				end if ;
			exception
					 when standard.NO_DATA_FOUND then
					 	  null ;
					 when others then
					 	  raise ; 
			end updateItems2 ;
		end loop ;
		writeMsg(pTableName => 'amd_spare_parts', pError_location => 720,
			pKey1 => 'curTmp1QtyDue',
			pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
			
		writeMsg(pTableName => 'amd_spare_parts', pError_location => 730,
				pKey1 => 'loadCurrentBackorder',
				pKey2 => 'curDueCnt=' || to_char(curDueCnt),
				pKey3 => 'curTmpCnt=' || to_char(curTmpCnt),
				pKey4 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
				
		commit ;
	end loadCurrentBackOrder ;

	procedure version is
	begin
		 writeMsg(pTableName => 'amd_spare_parts_pkg', 
		 		pError_location => 740, pKey1 => 'amd_spare_parts_pkg', pKey2 => '$Revision:   1.82  $') ;
		 dbms_output.put_line('amd_spare_parts_pkg: $Revision:   1.82  $') ;
	end version ;

begin
	 <<getDebug>>
	 declare
	 		param amd_param_changes.PARAM_VALUE%type ;
	 begin
	 		select param_value into param from amd_param_changes where param_key = 'debugSpareParts' ;
			mDebug := (param = '1') ;  
	 exception when others then
	 		   mDebug := false ;
	 end getDebug ;
	 
end amd_spare_parts_pkg;
/


show errors
