SET DEFINE OFF;
DROP PACKAGE AMD_OWNER.A2A_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.A2a_Pkg AS
 --
 -- SCCSID:   %M%   %I%   Modified: %G%  %U%
 --
 /*
      $Author:   zf297a  $
    $Revision:   1.68  $
     $Date:   30 Jan 2008 10:50:12  $
    $Workfile:   A2A_PKG.PKS  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\A2A_PKG.PKS-arc  $
/*   
/*      Rev 1.68   30 Jan 2008 10:50:12   zf297a
/*   Added set/get for the debug and debug thresholds.  Added function to retrieve the version.
/*   
/*      Rev 1.67   Nov 14 2007 16:36:28   c402417
/*   Add procedures InsertTimeToRepair and InsertPartLeadTime.
/*   
/*      Rev 1.66   06 Nov 2007 15:06:20   zf297a
/*   Added table types to be used by bulk collects.
/*   
/*      Rev 1.65   27 Sep 2007 18:54:10   zf297a
/*   Changed interface for loadAllA2A added interface for initA2APartAlt.
/*   
/*      Rev 1.64   19 Sep 2007 17:14:40   zf297a
/*   Added new interface for insertPartInfo.  This interface allows for all the data to be passed to the procedure versus it needing to retrieve it.
/*   Added new interface isPartValid.  This interface allows for all the data to be passed to the function versus it needing to retrieve it.
/*   Added new procedure insertTmpA2APartInfo.  This procedure allows for a row to be inserted into the tmp_a2a_part_info table after having been verified to be repairable or consumable and a valid part for the SPO.
/*   
/*      Rev 1.63   25 Jun 2007 08:16:04   zf297a
/*   Changed the value for the rcm_ind's constants and prefixed its name with RCM.
/*   
/*      Rev 1.62   04 Jun 2007 13:01:36   zf297a
/*   Added interfaces lpOverrideExists and lpOverrideExistsYorN
/*   
/*      Rev 1.61   25 May 2007 13:32:26   zf297a
/*   Added constants CONSUMABLE and REPAIRABLE to the spec.  Added the following functions:
/*   getValidRcmInd
/*   isPlannerCodeValidlannerCode
/*   isPlannerCodeValidYorNlannerCode
/*   getAcquisitionAdviceCodeart_no
/*   isNsnInRblPairssn
/*   isNsnInRblPairsYorNsn
/*   isNsnInIsgPairssn
/*   isNsnInIsgPairsYorNsn
/*   isNsnValidart_no
/*   isNsnValidYorNart_no
/*   demandExistsart_no
/*   demandExistsYorNart_no
/*   inventoryExistsart_no
/*   inventoryExistsYorNart_no
/*   
/*   
/*      Rev 1.60   12 Apr 2007 11:54:22   zf297a
/*   Added interfaces for isSpoPrimePartActive, which returns true if the given spo_prime_part_no is in amd_sent_to_a2a as a part_no that has an action_code not equal to D.
/*   Added interface isSpoPrimePartYorN.
/*   
/*      Rev 1.59   12 Apr 2007 10:23:48   zf297a
/*   Added interfaces isPartActive, which returns true if the part does not have an action_code of D in amd_sent_to_a2a.  Added interface isPartActiveYorN and getSentToA2AActionCode.
/*   
/*      Rev 1.58   29 Mar 2007 12:42:54   zf297a
/*   Added interfaces for tmpA2ALocPartOverrideAddOk, tmpA2AInvInfoAddOk, tmpA2ARepairInvInfoAddOk, and tmpA2AInTransitsAddOk
/*   
/*      Rev 1.57   29 Mar 2007 09:12:22   zf297a
/*   Added interface tmpA2AOrderInfoLineAddOk
/*   
/*      Rev 1.56   29 Mar 2007 00:06:36   zf297a
/*   Added interfaces tmpA2APartInfoAddOk and tmpA2APartInfoAddYorN.
/*   
/*      Rev 1.55   21 Mar 2007 11:35:50   zf297a
/*   Added interfaces for functions:
/*   partExistsInDataSystems
/*   partExistsInDataSystemsYorN
/*   isDataSysPartMarkedDeleted
/*   isDataSysPartMarkedDeletedYorN
/*   
/*   
/*      Rev 1.54   06 Mar 2007 09:55:36   zf297a
/*   Removed insertTmpA2AOrderInfo
/*   added insertTmpA2AOrderInfoLine
/*   
/*      Rev 1.53   27 Feb 2007 16:41:40   zf297a
/*   Added interface includeOrderYorN
/*   
/*      Rev 1.52   21 Feb 2007 20:22:52   zf297a
/*   Added mtbdr_computed to the  PartInfoRec
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
     RCM_REPAIRABLE   CONSTANT varchar2(1) := 'T' ; -- used for rcm_ind
     RCM_CONSUMABLE   CONSTANT varchar2(1) := 'F' ; -- used for rcm_ind
	 
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
          mtbdr_computed            AMD_NATIONAL_STOCK_ITEMS.mtbdr_computed%type,
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
     type partTab is table of partInfoRec ;
	 
     TYPE onHandInvSumCur IS REF CURSOR RETURN AMD_ON_HAND_INVS_SUM%ROWTYPE ;
     type onHandInvSumTab is table of amd_on_hand_invs_sum%rowtype ;
	 
     TYPE repairInvInfoCur IS REF CURSOR RETURN AMD_REPAIR_INVS_SUM%ROWTYPE ;
     type repairInvInfoTab is table of amd_repair_invs_sum%rowtype ;
	 
     TYPE inTransitsCur IS REF CURSOR RETURN AMD_IN_TRANSITS_SUM%ROWTYPE ;
     type inTransitsTab is table of amd_in_transits_sum%rowtype ;
     
	 TYPE inRepairCur IS REF CURSOR RETURN AMD_IN_REPAIR%ROWTYPE ;
     type inRepairTab is table of amd_in_repair%rowtype ;
     
	 TYPE onOrderCur IS REF CURSOR RETURN AMD_ON_ORDER%ROWTYPE ;
     type onOrderTab is table of amd_on_order%rowtype ;
     
	 TYPE part2DeleteCur IS REF CURSOR RETURN part2Delete ;
     type part2DeleteTab is table of part2Delete ;
     
	 TYPE bomDetailCur IS REF CURSOR RETURN AMD_SENT_TO_A2A%ROWTYPE ;
     type bomDetailTab is table of amd_sent_to_a2a%rowtype ;
     
	 TYPE backOrderCur IS REF CURSOR RETURN AMD_BACKORDER_SUM%ROWTYPE ;
     type backOrderTab is table of amd_backorder_sum%rowtype ;
     
	 type extForecastCur is ref cursor return amd_part_loc_forecasts%rowtype ;
     type extForecastTab is table of amd_part_loc_forecasts%rowtype ;
	 
	 PROCEDURE processParts(parts IN partCur) ;
	 PROCEDURE processPartLeadTimes(parts IN partCur) ;
	 PROCEDURE processOnHandInvSum(onHandInvSum IN onHandInvSumCur) ;
	 PROCEDURE processRepairInvInfo(repairInvInfo IN repairInvInfoCur) ;
	 PROCEDURE processInTransits(inTransit IN inTransitsCur) ;
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
	
	 procedure InsertPartInfo(part_no in varchar2, action_code in varchar2) ;
     
           
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
           price IN NUMBER := NULL) ; 
	
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
	
     PROCEDURE insertPartLeadTime(
            part_no IN tmp_a2a_part_lead_time.PART_NO%type,
            lead_time_type tmp_a2a_part_lead_time.LEAD_TIME_TYPE%type,
            lead_time IN tmp_a2a_part_lead_time.LEAD_TIME%type,
            action_code IN TMP_A2A_PART_LEAD_TIME.action_code%TYPE) ;
            
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
	
	 PROCEDURE insertTmpA2AOrderInfoLine(gold_order_number IN AMD_ON_ORDER.GOLD_ORDER_NUMBER%TYPE,
	     loc_sid IN AMD_ON_ORDER.LOC_SID%TYPE,
	     order_date IN AMD_ON_ORDER.ORDER_DATE%TYPE,
	     part_no IN AMD_ON_ORDER.PART_NO%TYPE,
	     order_qty IN AMD_ON_ORDER.ORDER_QTY%TYPE,
		 sched_receipt_date IN AMD_ON_ORDER.SCHED_RECEIPT_DATE%TYPE,
	     action_code IN TMP_A2A_ORDER_INFO_LINE.action_code%TYPE,
         line in amd_on_order.line%type) ;
	
	
	  PROCEDURE insertTmpA2AInTransits(part_no IN AMD_IN_TRANSITS_SUM.part_no%TYPE,
	       site_location    IN AMD_IN_TRANSITS_SUM.site_location%TYPE,
	       quantity      IN AMD_IN_TRANSITS_SUM.quantity%TYPE,
	       serviceable_flag  IN AMD_IN_TRANSITS_SUM.serviceable_flag%TYPE,
	       action_code   IN TMP_A2A_IN_TRANSITS.action_code%TYPE) ;
	
	  FUNCTION wasPartSent(partNo IN AMD_SPARE_PARTS.part_no%TYPE) RETURN BOOLEAN ;
	  FUNCTION wasPartSentYorN(partNo IN AMD_SPARE_PARTS.part_no%TYPE) RETURN VARCHAR2 ;
      
	  FUNCTION isPartValid (partNo IN AMD_SPARE_PARTS.part_no%TYPE, showReason in boolean := false) RETURN BOOLEAN ;
	  FUNCTION isPartValidYorN(partNo IN AMD_SPARE_PARTS.part_no%TYPE, showReason in varchar2 := 'N') RETURN VARCHAR2 ;
      
      function isPartValid(partNo IN VARCHAR2, 
        preferredSmrCode IN VARCHAR2, preferredMtbdr IN NUMBER, preferredPlannerCode IN VARCHAR2, 
        showReason in boolean := false) RETURN BOOLEAN ;

	  FUNCTION isPlannerCodeAssigned2UserId(plannerCode IN VARCHAR2) RETURN BOOLEAN ;
	  FUNCTION isPlannerCodeAssign2UserIdYorN(plannerCode IN VARCHAR2) RETURN VARCHAR2 ;
	  FUNCTION isNsl(partNo IN AMD_SPARE_PARTS.part_no%TYPE) RETURN BOOLEAN ;
	  FUNCTION isNslYorN(partNo IN AMD_SPARE_PARTS.part_no%TYPE) RETURN VARCHAR2 ;
      -- added 4/12/2007 by dse
      function isPartActive(part_no in amd_sent_to_a2a.part_no%type) return boolean ;
      -- added 4/12/2007 by dse
      function isPartActiveYorN(part_no in amd_sent_to_a2a.part_no%type) return varchar2 ;
      -- added 4/12/2007 by dse
      function getSentToA2AActionCode(part_no in amd_sent_to_a2a.part_no%type) return varchar2 ;
      -- added 4/12/2007 by dse
      function isSpoPrimePartActive(spo_prime_part_no in amd_sent_to_a2a.spo_prime_part_no%type) return boolean ;
      -- added 4/12/2007 by dse
      function isSpoPrimePartActiveYorN(spo_prime_part_no in amd_sent_to_a2a.spo_prime_part_no%type) return varchar2 ;
	
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
     PROCEDURE insertTimeToRepair(part_no IN AMD_SPARE_PARTS.part_no%TYPE,
              nsi_sid IN AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE,
              time_to_repair_off_base_cleand IN AMD_NATIONAL_STOCK_ITEMS.time_to_repair_off_base_cleand%TYPE); 
	
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
	
	 PROCEDURE loadAll(startStep IN NUMBER := 1, endStep IN NUMBER := 16, debugIt IN BOOLEAN := FALSE, system_id IN AMD_BATCH_JOBS.SYSTEM_ID%TYPE := 'LOAD_ALL_A2A') ;
	 FUNCTION getSendAllData RETURN BOOLEAN ;
	 PROCEDURE setSendAllData(theIndicator IN BOOLEAN) ;
	 PROCEDURE version ;

	 FUNCTION includeOrderYorN(gold_order_number IN AMD_ON_ORDER.gold_order_number%TYPE, 
	 		  			  order_date IN AMD_ON_ORDER.order_date%TYPE,
						  part_no in amd_on_order.part_no%type) RETURN Varchar2 ;
	 
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
     
     -- added 3/21/2007 by dse
    function partExistsInDataSystems(pPartNo in datasys_part_v.part%type) return boolean ;
    function partExistsInDataSystemsYorN(pPartNo in datasys_part_v.part%type) return varchar2 ;
    function isDataSysPartMarkedDeleted(pPartNo in datasys_part_v.part%type) return boolean ;
    function isDataSysPartMarkedDeletedYorN(pPartNo in datasys_part_v.part%type) return varchar2 ;
    
    -- added 3/28/2007 by DSE
    function tmpA2APartInfoAddOk(part_no in amd_spare_parts.part_no%type) return boolean ; 
    function tmpA2APartInfoAddYorN(part_no in amd_spare_parts.part_no%type) return varchar2 ; 

    -- added 3/29/2007 by DSE
    function tmpA2AOrderInfoLineAddOk(gold_order_number in amd_on_order.gold_order_number%type, 
        from_dt in amd_on_order.order_date%type := START_DT,
        to_dt in amd_on_order.order_date%type := sysdate) return boolean ;
        
    function tmpA2ALocPartOverrideAddOk(part_no in amd_location_part_override.part_no%type) return boolean ;
    
    function tmpA2AInvInfoAddOk(part_no in AMD_ON_HAND_INVS_SUM.PART_NO%type, spo_location in amd_on_hand_invs_sum.SPO_LOCATION%type := null ) return boolean ;
    
    function tmpA2ARepairInvInfoAddOk(part_no in amd_repair_invs_sum.part_no%type,
        site_location in amd_repair_invs_sum.site_location%type := null) return boolean ;
     
	 function tmpA2AInTransitsAddOk(part_no in amd_in_transits.part_no%type) return boolean ;
     
	 FUNCTION getValidRcmInd(rcmInd IN VARCHAR2) RETURN VARCHAR2 ;
     
    function isPlannerCodeValid(plannerCode in amd_national_stock_items.planner_code%type,
        showReason in boolean := false) return boolean ;
    function isPlannerCodeValidYorN(plannerCode in amd_national_stock_items.planner_code%type,
        showReason in boolean := false) return varchar2 ;
    function getAcquisitionAdviceCode(part_no in amd_spare_parts.part_no%type) return varchar2 ;
    function isNsnInRblPairs(nsn in amd_spare_parts.nsn%type, showReason in boolean := false) return boolean ;
    function isNsnInRblPairsYorN(nsn in amd_spare_parts.nsn%type, showReason in boolean := false) return varchar2 ;
    function isNsnInIsgPairs(nsn in amd_spare_parts.nsn%type, showReason in boolean := false) return boolean ;
    function isNsnInIsgPairsYorN(nsn in amd_spare_parts.nsn%type, showReason in boolean := false) return varchar2 ;
    function isNsnValid(part_no in amd_spare_parts.part_no%type, showReason in boolean := false) return boolean ;
    function isNsnValidYorN(part_no in amd_spare_parts.part_no%type, showReason in boolean := false) return varchar2 ;
    function demandExists(part_no in amd_spare_parts.part_no%type, showReason in boolean := false) return boolean ;
    function demandExistsYorN(part_no in amd_spare_parts.part_no%type, showReason in boolean := false) return varchar2 ;
    function inventoryExists(part_no in amd_spare_parts.part_no%type, showReason in boolean := false) return boolean ;
    function inventoryExistsYorN(part_no in amd_spare_parts.part_no%type, showReason in boolean := false) return varchar2 ;

    -- add 6/4/2007 by dse        
    function lpOverrideExists(part_no in datasys_lp_override_v.PART%type, site_location in datasys_lp_override_v.SITE_LOCATION%type) return boolean ;
    function lpOverrideExistsYorN(part_no in datasys_lp_override_v.PART%type, site_location in datasys_lp_override_v.SITE_LOCATION%type) return varchar2 ;
    
    -- added 9/19/2007 by dse
     procedure insertTmpA2APartInfo(mfgr in tmp_a2a_part_info.cage_code%type,
        part_no in tmp_a2a_part_info.part_no%type, unit_issue in tmp_a2a_part_info.unit_issue%type,
        nomenclature in amd_spare_parts.nomenclature%type, rcm_ind in tmp_a2a_part_info.rcm_ind%type, 
        nsn in amd_national_stock_items.nsn%type, planner_code in amd_national_stock_items.planner_code%type,
        mtbdr in tmp_a2a_part_info.mtbf%type, preferred_smrcode in tmp_a2a_part_info.preferred_smrcode%type, 
        indenture in tmp_a2a_part_info.indenture%type,
        action_code in tmp_a2a_part_info.action_code%type, price in tmp_a2a_part_info.price%type) ;

      -- added 9/27/07
      procedure initA2APartAlt ;
      -- added 1/30/08
      function getVersion return varchar2 ;
      function getDebugYorN return varchar2 ;
      procedure setDebug(switch in varchar2) ;
      function getDebugThreshold return number ;
      procedure setDebugThreshold(value in number) ;
      function getInsertAddUpdRepairInfoCnt return number ;
      procedure setInsertAddUpdRepairInfoCnt (value in number) ;
      procedure resetDebugCnts ;
      procedure setDebugDeleteThreshold(value in number) ;
      procedure setDebugRepairInfoThreshold(value in number) ;
      procedure setAllThresholds(value in number) ;
      

      

      
END A2a_Pkg ;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM A2A_PKG;

CREATE PUBLIC SYNONYM A2A_PKG FOR AMD_OWNER.A2A_PKG;


GRANT EXECUTE ON AMD_OWNER.A2A_PKG TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.A2A_PKG TO BSRM_LOADER;


SET DEFINE OFF;
DROP PACKAGE BODY AMD_OWNER.A2A_PKG;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.A2a_Pkg AS
 --
 -- SCCSID:   %M%   %I%   Modified: %G%  %U%
 --
 /*
      $Author:   zf297a  $
    $Revision:   1.216  $
     $Date:   13 Mar 2008 11:48:02  $
    $Workfile:   A2A_PKG.PKB  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\A2A_PKG.PKB-arc  $
/*   
/*      Rev 1.216   13 Mar 2008 11:48:02   zf297a
/*   Changed OVERRIDE_TYPE to TSL_OVERRIDE_TYPE
/*   
/*      Rev 1.215   22 Feb 2008 12:27:32   zf297a
/*   For all initA2A routines make sure the data is in order by key and last_update_dt so the most recent Add, Change, or Delete is sent.
/*   
/*      Rev 1.214   22 Feb 2008 11:58:24   zf297a
/*   for initA2ARepairInvInfo make sure the data is ordered by key and last_update_dt so that the last Add, Change, or Delete for a particular key is the most recent.
/*   
/*      Rev 1.213   22 Feb 2008 11:22:30   zf297a
/*   Made sure updateCnt gets saved correctly to amd_load_details
/*   
/*      Rev 1.212   22 Feb 2008 11:10:28   zf297a
/*   Added package counters for debugging: insertCnt, deleteCnt, updateCnt & rejectCnt.
/*   Added debugging to processOnHandInvSum
/*   Added debugging to initA2AInvInfo
/*   Fixed processRepairInvInfo: removed rec variables, fixed invocation of insertRepairInvInfo - site_location was not being passed from the repairInvInfos array.
/*   Added debugging to initA2ARepairInvInfo
/*   Added execption handlers to all doUpdate routines
/*   Added nested procedure doUpdate to insertInvInfo
/*   Added debugging to insertInvInfo
/*   Added nested procedure doUpdate to insertRepairInvInfo
/*   Added debugging to insertRepairInvInfo
/*   
/*   
/*   
/*   
/*      Rev 1.211   04 Feb 2008 10:37:18   zf297a
/*   Modifed isPartValid to check whether the part is consumable.  If it is consumable it uses the a2a_consumables_pkg.isPartValid funtion to determine if the part is valid for SPO.
/*   
/*      Rev 1.210   30 Jan 2008 10:51:02   zf297a
/*   Added debug and debug threshold variables and their corresponding get/set methods.
/*   
/*      Rev 1.209   03 Dec 2007 13:20:48   zf297a
/*   Removed the rec variable from processOnHandInvSum and made sure to use the array onHandInvSums to get all data for the insertInvInfo procedure.
/*   
/*      Rev 1.208   30 Nov 2007 09:19:28   zf297a
/*   Fixed insertTimeToRepair to use data from amd_national_stock_items vs amd_part_locs.
/*   For the loadAll procedure using a more complete load of amd_location_part_override and amd_locpart_overid_consumables by using amd_location_part_override_pkg.loadInitial and amd_lp_override_consumabl_pkg.initialize ;
/*   
/*      Rev 1.207   16 Nov 2007 13:15:24   zf297a
/*   changed insertTimeToRepair to get the time_to_repair_off_base from amd_national_stock_items instead of amd_part_locs, since amd_part_locs does not get updated.
/*   
/*      Rev 1.206   08 Nov 2007 11:35:46   zf297a
/*   Removed erroneous close's of cursor that are being bulk collected, since the process routine closes the cursor.  Added check to see if .first is not null before trying to process any data in the bulk table.
/*   
/*      Rev 1.204   06 Nov 2007 15:07:00   zf297a
/*   Changed most of the cursors to use bulk collect.
/*   
/*      Rev 1.203   06 Nov 2007 12:14:08   zf297a
/*   Added BULK COLLECt to processParts
/*   
/*      Rev 1.202   01 Nov 2007 11:55:22   zf297a
/*   Fixed initA2APartAlt to load only alternate parts.    Allow all parts to be inserted into tmp_a2a_part_lead_time with their lead time
/*   
/*      Rev 1.201   27 Sep 2007 18:55:02   zf297a
/*   Implemented initA2APartAlt.  Changed loadAllA2A to have 16 steps, where the 16th step executes initA2APartAlt.
/*   
/*      Rev 1.200   19 Sep 2007 17:18:36   zf297a
/*   Implemented the interface for insertPartInfo.  This interface allows for all the data to be passed to the procedure versus it needing to retrieve it.
/*   Implemented the interface for isPartValid.  This interface allows for all the data to be passed to the function versus it needing to retrieve it.
/*   Implemented procedure insertTmpA2APartInfo.  This procedure allows for a row to be inserted into the tmp_a2a_part_info table after having been verified to be repairable or consumable and a valid part for the SPO.
/*   Used the new isPartValid and isRepairableSmr to determine these conditions without retrieving any data, but just using the passed in data.
/*   Replaced the SQL insert's of rows to tmp_a2a_part_info with the new procedure insertTmpA2APartInfo.
/*   
/*      Rev 1.199   17 Sep 2007 21:47:10   zf297a
/*   Fixed lpOverrideExists to use an existenial qualifier 'Exists' to determine if a row exists for the given part and site_location in view datasys_lp_override_v.  The other query return more than one row and caused ORA-01422 fetch errors.
/*   
/*      Rev 1.198   14 Sep 2007 13:23:12   zf297a
/*   For PartLeadTime A2A's only create them for spo_prime_part's.
/*   
/*      Rev 1.197   14 Sep 2007 13:06:06   zf297a
/*   Streamlined functions insertPartLeadTime, updatePartLeadTime, and deletePartLeadTime to use one common routine to create the A2A transaction.
/*   
/*      Rev 1.196   14 Sep 2007 11:52:48   zf297a
/*   Only send delete A2A PartLeadTime delete transactions for repairable or consumable parts.
/*   
/*      Rev 1.194   14 Sep 2007 11:01:30   zf297a
/*   Make sure a2a part lead time transactions are being created for both repairable and consumable parts.
/*   
/*      Rev 1.193   11 Sep 2007 16:03:26   zf297a
/*   Removed commits from all for/loops.
/*   
/*      Rev 1.192   07 Sep 2007 16:04:26   zf297a
/*   For procedure deleteInvalidParts fixed the cursor to retrieve consumables that are no longer valid as well as parts that are neither consumable nor repairable - all these parts need to be "excluded" from SPO.
/*   
/*      Rev 1.191   23 Aug 2007 09:22:32   zf297a
/*   initA2ADemands was running too long with the multiple invocations of functions, so I created a simple cursor and for loop to load the data.
/*   
/*      Rev 1.190   20 Aug 2007 09:36:08   zf297a
/*   Added invocation of amd_demand.loadAllA2A to load the ExtForecast consumables
/*   
/*      Rev 1.189   16 Aug 2007 12:34:34   zf297a
/*   added invocation of amd_lp_override_consumabl_pkg.loadAllA2A in the loadAllA2A procedure.
/*   
/*      Rev 1.188   27 Jul 2007 13:03:14   zf297a
/*   Added the check for isPartConsumable to the overloaded insertPartInfo routine that takes a complete list of arguments to make it like the insertPartInfo with one part_no argument.  The overloaded routine that takes the record does not need this test  since it is just a wrapper for the insertPartInfo with the list of part info arguments.
/*   
/*      Rev 1.187   25 Jun 2007 09:50:00   zf297a
/*   Fixed cursor invalidParts for procedure deleteInvalidParts
/*   
/*      Rev 1.186   25 Jun 2007 08:17:04   zf297a
/*   Use the new rcm constants.  Changed the deleteInvalidParts' cursor to be more specific: for repairable parts that are not valid.
/*   
/*      Rev 1.185   Jun 18 2007 15:05:30   c402417
/*   Modified the Consumable to function getValidRcmInd and isPartValid.
/*   
/*      Rev 1.183   25 May 2007 13:32:54   zf297a
/*   Implemented the following functions:
/*   getValidRcmInd
/*   isPlannerCodeValidlannerCode
/*   isPlannerCodeValidYorNlannerCode
/*   getAcquisitionAdviceCodeart_no
/*   isNsnInRblPairssn
/*   isNsnInRblPairsYorNsn
/*   isNsnInIsgPairssn
/*   isNsnInIsgPairsYorNsn
/*   isNsnValidart_no
/*   isNsnValidYorNart_no
/*   demandExistsart_no
/*   demandExistsYorNart_no
/*   inventoryExistsart_no
/*   inventoryExistsYorNart_no
/*   
/*   
/*      Rev 1.182   15 May 2007 09:43:00   zf297a
/*   Fixed names of variables used by the raise_application_error for the errorMsg procedure.
/*   
/*      Rev 1.181   15 May 2007 09:28:48   zf297a
/*   Added raise_application_error to errorMsg's exception routine.
/*   
/*      Rev 1.180   12 Apr 2007 14:52:38   zf297a
/*   Fixed isSpoPrimePartActive
/*   
/*      Rev 1.179   12 Apr 2007 11:54:46   zf297a
/*   Implemented interfaces for isSpoPrimePartActive, which returns true if the given spo_prime_part_no is in amd_sent_to_a2a as a part_no that has an action_code not equal to D.
/*   Implemented interface isSpoPrimePartYorN.
/*   
/*      Rev 1.178   12 Apr 2007 10:24:24   zf297a
/*   Implemented interface isPartActive, which returns true if the part does not have an action_code of D in amd_sent_to_a2a.  Implemented interfaces isPartActiveYorN and getSentToA2AActionCode.
/*   
/*      Rev 1.176   05 Apr 2007 11:16:56   zf297a
/*   Filter out commit / rollback errors when a routine is invoked via a trigger - however there was a mutating table, so creating the tmp_a2a_order_info_line via a trigger was abandoned.
/*   
/*      Rev 1.175   29 Mar 2007 12:43:02   zf297a
/*   Added interfaces for tmpA2ALocPartOverrideAddOk, tmpA2AInvInfoAddOk, tmpA2ARepairInvInfoAddOk, and tmpA2AInTransitsAddOk
/*   
/*      Rev 1.174   29 Mar 2007 09:12:40   zf297a
/*   Implemented tmpA2AOrderInfoLineAddOk
/*   
/*      Rev 1.173   29 Mar 2007 00:08:28   zf297a
/*   Implemented tmpA2APartInfoAddOk and tmpA2APartInfoAddYorN.
/*   
/*   Changed createPartInfo to use tmpA2APartInfoAddOk
/*   
/*      Rev 1.172   21 Mar 2007 18:40:52   zf297a
/*   Fixed deletePartInfo to check isPartSent instead of going against datasys_part_v since testing all parts going against datasys_part_v would take LOTS of time.
/*   
/*      Rev 1.171   21 Mar 2007 11:36:24   zf297a
/*   Implemented functions:
/*   partExistsInDataSystems
/*   partExistsInDataSystemsYorN
/*   isDataSysPartMarkedDelete
/*   isDataSysPartMarkedDeletedYorN
/*   
/*   
/*      Rev 1.170   13 Mar 2007 21:30:40   zf297a
/*   Fixed the opening of cursor repairInvInfoByDate for procedure initA2ARepairInvInfo to get the proper action_code and fixed the opening of cursors repairInvIno for the nested procedures getAllData and getTestData in the overloaded procedure initA2ARepairInvInfo to have the proper action_code.
/*   
/*      Rev 1.169   13 Mar 2007 12:57:22   zf297a
/*   Removed truncate of tmp_a2a_order_info
/*   
/*      Rev 1.168   13 Mar 2007 00:13:22   zf297a
/*   Add additional debug code for insertA2AOrderInfoLine and remove all commits for this procedure to allow it to be executed via a trigger.
/*   
/*      Rev 1.167   12 Mar 2007 16:06:04   zf297a
/*   fixed numbers for raise_application_error
/*   
/*      Rev 1.166   12 Mar 2007 15:38:06   zf297a
/*   use raise_applicaton_error to try to determine problem when the error does not get logged to amd_load_details.
/*   
/*      Rev 1.165   12 Mar 2007 13:52:56   zf297a
/*   For the following routines ignore commit or rollback exceptions when executed by a trigger:
/*   writemsg and insertTmpA2AOrderInfoLine. 
/*   By ignoring these errors, it will allow the routine to be executed from a trigger.
/*   
/*      Rev 1.164   07 Mar 2007 09:05:04   zf297a
/*   Removed all references to tmp_a2a_order_info table
/*   
/*      Rev 1.163   06 Mar 2007 09:44:34   zf297a
/*   Fixed initA2AOrderInfoLine and removed initA2AOrderInfo
/*   
/*      Rev 1.162   06 Mar 2007 08:19:10   zf297a
/*   removed tmp_a2a_order_info
/*   
/*      Rev 1.160   22 Feb 2007 15:28:12   zf297a
/*   For the loadAll and the PartInfo step 3, after loading all parts to tmp_a2a_part_info do the following:
/*   flag amd_sent_to_a2a parts that should b deleted
/*   create the a2a  part_info delete transaction
/*   load the rbl pairs
/*   update the spo_prime_part_no's
/*   create LocPartOverride delete's for all primes that have changed for all rsp bases
/*   for all non-prime parts in tmp_a2a_part_info update the resp_asset_mgr with the resp_asset_mgr for the prime_part.
/*   
/*      Rev 1.159   21 Feb 2007 20:23:58   zf297a
/*   Updated all PartInfo routines to use the mtbdr_computed field of the PartInfoRec
/*   
/*      Rev 1.158   26 Jan 2007 11:33:22   zf297a
/*   Fixed nested function getSchedReceiptDate of the includeOrder function to ignore DELETED orders and to get the max(line) number for the give gold_order_number and order_date.
/*   Fixed nested function getLIneNumber of the insertTmpA2AOrderInfo procedure to get the max line for the give gold_order_number and order_date since the order may have been deleted and then added back or added and then deleted.  This will only send the latest line number for the giver gold_order_number and order_date.  
/*   (The diff could be modified to incorporate the line as the key and then the getLIneNumber could probably be removed, but for now, this works)
/*   
/*      Rev 1.157   26 Jan 2007 10:03:58   zf297a
/*   In errorMsg made the handling of key5 more robust.  
/*   Changed all selects that create a onOrderCur type to have the Line as the third column.
/*   Modified getNextLine to just retrieve the Line from amd_on_order for the give gold_order_number and order_date.  
/*   Write more ifno to amd_load_details when there is an exception in insertTmpA2AOrderInfoLine.
/*   
/*      Rev 1.156   Dec 12 2006 12:25:04   zf297a
/*   Fixed getPartInfo's query by giving the action_code from the amd_sent_to_a2a priority over the action_code from amd_spare_parts.  Did an outer join against the amd_national_stock_items and the amd_sent_to_a2a since both tables may not have matching entries for the selected part.  Eliminated the action_code filter - not <> 'D'.
/*   Changed the query for getTestData in the same manner as was done for getPartInfo.
/*   Changed processParts to count the number inserts, updated, and delete transactions and to record those counts to amd_load_details.
/*   Changed the query for initA2APartInfo with the from date and to date arguments to be similar to the query of getPartInfo.
/*   
/*   The changes made to the queries should gaurantee that all deleted parts are collected and sent to the SPO.  Because some of these deleted parts may not have matching data in amd_national_stock_items, then the PartInfo_DEL.sql query will need to do a union with a query that is NOT using the amd_part_header_v5 view.
/*   
/*   
/*      Rev 1.155   Nov 29 2006 21:59:02   zf297a
/*   for insertRepairInvInfo, insertRepairInfo, insertTmpA2AOrderInfo, insertTmpA2AOrderInfoLine, and insertTmpA2AInTransits delete transactions make sure the site_location is not null.
/*   
/*   
/*      Rev 1.154   Nov 29 2006 21:20:14   zf297a
/*   for insertTmpA2AOrderInfo with delete_actions, make sure the site_location is not null.
/*   
/*      Rev 1.153   Nov 29 2006 13:24:56   zf297a
/*   For table amd_backorder_sum changed the column part_no to spo_prime_part_no.
/*   
/*      Rev 1.152   Nov 28 2006 14:26:50   zf297a
/*   fixed initA2ASpoUsers - use the action_code from amd_users
/*   
/*   fixed initSiteRespAssetMgr - use the action_code from amd_planner_logons
/*   
/*      Rev 1.151   Nov 28 2006 12:23:46   zf297a
/*   fixed processPartLeadTimes to check for the existance of the part_no in amd_sent_to_a2a with any action_code.
/*   
/*   fixed processPart to check for the existance of the part_no in amd_sent_to_a2a with any action_code.
/*   
/*   fixed deletePartInfo to check for the existance of the part_no in amd_sent_to_a2a with any action_code.
/*   
/*   fixed deletePartLeadTime to check for the existance of the part_no in amd_sent_to_a2a with any action_code.
/*   
/*   fixed deleteLocPartLeadTime to check for the existance of the part_no in amd_sent_to_a2a with any action_code.
/*   
/*   
/*   
/*   
/*   
/*   
/*   
/*   
/*   
/*   
/*      Rev 1.150   Nov 28 2006 11:57:46   zf297a
/*   Fixed insertInvInfo - for INSERT_ACTION or UPDATE_ACTION check to see if the part is in amd_sent_to_a2a with action_code <> DELETE_ACTION then insert it into tmp_a2a_inv_info.  For DELETE_ACTION's check to see if the part is in amd_sent_to_a2a with any action_code then insert it into tmp_a2a_inv_info
/*   
/*      Rev 1.149   Nov 28 2006 11:50:18   zf297a
/*   Fixed insertTmpA2AOrderInfo - for the INSERT_ACTION or UPDATE_ACTION check to see if the part exists in amd_sent_to_a2a with an action_code <> DELETE_ACTION and if it meets the include criteria then insert it into the tmp_a2a tables.  For the DELETE_ACTION check to see if the part exists in amd_sent_to_a2a with any action_code, if it does then insert it into the tmp_a2a table.
/*   
/*      Rev 1.148   Nov 28 2006 11:32:08   zf297a
/*   Fixed insertRepairInvInfo - for INSERT_ACTION or UPDATE_ACTION check to see if the part is in amd_sent_to_a2a with action_code <> DELETE_ACTION then insert it into tmp_a2a_repair_inv_info.  For DELETE_ACTION's check to see if the part is in amd_sent_to_a2a with any action_code then insert it into tmp_a2a_repair_inv_info.
/*   
/*   Fixed insertRepairInfo  - for INSERT_ACTION or UPDATE_ACTION check to see if the part is in amd_sent_to_a2a with action_code <> DELETE_ACTION then insert it into tmp_a2a_repair_info.  For DELETE_ACTION's check to see if the part is in amd_sent_to_a2a with any action_code then insert it into tmp_a2a_repair_info.
/*   
/*      Rev 1.147   Nov 28 2006 10:26:50   zf297a
/*   Fixed insertTmpA2AInTransits for deletes - only check that the part has been sent using isPartSent - which ignores the action_code and just looks for the part_no in amd_sent_to_a2a.
/*   
/*      Rev 1.146   Nov 22 2006 13:28:02   zf297a
/*   For initA2ABackorderInfo use spo_prime_part_no
/*   
/*      Rev 1.145   Nov 10 2006 10:50:22   zf297a
/*   Fixed generation of line for tmp_a2a_order_info_line
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
/*   Changed the arg list for insertTmpA2AOrderInfo and folded the procedure insertTmpA2AOrderInfoLine into insert                 OPEN onOrders FOR 
                 SELECT 
                      oo.PART_NO,  
                      LOC_SID,
                      LINE,          
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
Info.  Checked sched_receipt_date and if it is null compute a new due_date based on the order_lead_time (cleaned take precedence).
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
 debugThreshold number := 500 ;
 debugRepairInfoThreshold number := 500 ;
 debugDeleteThreshold number := 500 ;
 insertRowCnt number := 0 ;
 insertAddUpdRepairInfoCnt number := 0 ;
 deleteCnt number := 0 ;
 insertCnt number := 0 ;
 updateCnt number := 0 ;
 rejectCnt number := 0 ;
 debug boolean := false ;

 
 DEBUG_THRESHOLD      CONSTANT NUMBER := 5000 ;
  
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
    exception when others then
        --  ignoretrying to rollback or commit from trigger
        if sqlcode <> -4092 then
            raise_application_error(-20010,
                substr('a2a_pkg ' 
                    || sqlcode || ' '
                    || pError_Location || ' ' 
                    || pTableName || ' ' 
                    || pKey1 || ' ' 
                    || pKey2 || ' ' 
                    || pKey3 || ' ' 
                    || pKey4 || ' '
                    || pData, 1,2000)) ;
        end if ;
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
         saveSqlCode number := sqlcode ;
         
     BEGIN
          begin
            ROLLBACK;
          exception when others then
            --  ignore trying to do rollback from within a trigger 
            if sqlcode <> -4092 then
                raise_application_error(-20020,
                    substr('a2a_pkg ' 
                        || sqlcode || ' '
                        || pError_location || ' '
                        || pSqlFunction || ' ' 
                        || pTableName || ' ' 
                        || pKey_1 || ' ' 
                        || pKey_2 || ' ' 
                        || pKey_3 || ' ' 
                        || pKey_4 || ' '
                        || pKeywordValuePairs,1, 2000)) ;            
            end if ;
          end ;
          IF key5 = '' or key5 is null THEN
             key5 := pSqlFunction || '/' || pTableName ;
          ELSE
            if key5 is not null then
                if length(key5) + length('' || pSqlFunction || '/' || pTablename) < 50  then           
                    key5 := key5 || ' ' || pSqlFunction || '/' || pTableName ;
                end if ;
            end if ;
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
            pComments => SUBSTR('sqlcode('||saveSQLCODE||') sqlerrm('||SQLERRM||')',1,2000));
            
            if sqlcode <> -4092 then            
                COMMIT;
            end if ;
       
     EXCEPTION WHEN OTHERS THEN
       dbms_output.enable(10000) ;
       dbms_output.put_line('sql error=' || sqlcode || ' ' || sqlerrm) ;
       if pSqlFunction is not null then dbms_output.put_line('pSqlFunction=' || pSqlfunction) ; end if ;
       if pTableName is not null then dbms_output.put_line('pTableName=' || pTableName) ; end if ;
       if pError_location is not null then dbms_output.put_line('pError_location=' || pError_location) ; end if ;
       if pKey_1 is not null then dbms_output.put_line('key1=' || pKey_1) ; end if ;
       if pkey_2 is not null then dbms_output.put_line('key2=' || pKey_2) ; end if ;
       if pKey_3 is not null then dbms_output.put_line('key3=' || pKey_3) ; end if ;
       if pKey_4 is not null then dbms_output.put_line('key4=' || pKey_4) ; end if ;
       if pKeywordValuePairs is not null then dbms_output.put_line('pKeywordValuePairs=' || pKeywordValuePairs) ; end if ;
       if sqlcode <> -4092 then
           raise_application_error(-20030,
                substr('a2a_pkg ' 
                    || sqlcode || ' '
                    || pError_location || ' '
                    || pSqlFunction || ' ' 
                    || pTableName || ' ' 
                    || pKey_1 || ' ' 
                    || pKey_2 || ' ' 
                    || pKey_3 || ' ' 
                    || pKey_4 || ' '
                    || pKeywordValuePairs,1, 2000)) ;
        end if ;
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
         if pSqlfunction is not null then dbms_output.put_line('pSqlfunction=' ||       pSqlfunction) ; end if ;
         if pTableName is not null then dbms_output.put_line('pTableName=' || pTableName) ; end if ;
         if pError_location is not null then dbms_output.put_line('pError_location=' || pError_location) ; end if ;
         if pReturn_code is not null then dbms_output.put_line('pReturn_code=' || pReturn_code) ; end if ;
         if pKey_1 is not null then dbms_output.put_line('pKey_1=' || pKey_1) ; end if ;
         if pKey_2 is not null then dbms_output.put_line('pKey_2=' || pKey_2) ; end if ;
         if pKey_3 is not null then dbms_output.put_line('pKey_3=' || pKey_3) ; end if ;
         if pKey_4 is not null then dbms_output.put_line('pKey_4=' || pKey_4); end if ;
         if pKeywordValuePairs is not null then dbms_output.put_line('pKeywordValuePairs=' || pKeywordValuePairs) ; end if ;
         raise_application_error(-20040,
                substr('a2a_pkg ' 
                    || sqlcode || ' '
                    || pError_Location || ' ' 
                    || pTableName || ' ' 
                    || pKey_1 || ' ' 
                    || pKey_2 || ' ' 
                    || pKey_3 || ' ' 
                    || pKey_4 || ' '
                    || pKeywordValuePairs, 1,2000)) ;
    END ErrorMsg;
    
     PROCEDURE debugMsg(msg IN AMD_LOAD_DETAILS.DATA_LINE%TYPE, pError_Location IN NUMBER) IS
     BEGIN
       IF mDebug THEN
           Amd_Utils.debugMsg(pMsg => msg,pPackage => 'a2a_pkg', pLocation => pError_location) ;
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
     
     FUNCTION getIndenture(smr_code_preferred IN AMD_NATIONAL_STOCK_ITEMS.SMR_CODE%TYPE) return TMP_A2A_PART_INFO.indenture%TYPE IS
     begin
       
       if substr(smr_code_preferred,1,3) in ('PBO','PAO') then
            return '1' ;
       end if ;
       
       return '2' ;
     end getIndenture ;
     
     FUNCTION isPlannerCodeValid(plannerCode in amd_national_stock_items.planner_code%type,
        showReason in boolean := false) RETURN BOOLEAN IS
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
            debugMsg(plannerCode || ' Planner code is NOT valid', 10) ;
             if showReason then 
                dbms_output.put_line(plannerCode || ' Planner code is NOT valid') ;
            end if ;              
        END IF ;
        
        RETURN isValid ;
        
    END isPlannerCodeValid ;
    
    function isPlannerCodeValidYorN(plannerCode in amd_national_stock_items.planner_code%type,
        showReason in boolean := false) return varchar2 is
    begin
        if isPlannerCodeValid(plannerCode, showReason) then
            return 'Y' ;
        else
            return 'N' ;
        end if ;
    end isPlannerCodeValidYorN ;
    
    function getAcquisitionAdviceCode(part_no in amd_spare_parts.part_no%type) return varchar2 is
        theCode AMD_SPARE_PARTS.ACQUISITION_ADVICE_CODE%TYPE ;
    begin
           mArgs := 'getAcquisitionAdviceCode(' || part_no || ')' ;
              SELECT acquisition_advice_code INTO theCode
           FROM AMD_SPARE_PARTS WHERE part_no = getAcquisitionAdviceCode.part_No ;
           mArgs := 'theCode=' || theCode ;
           return UPPER(theCode) ;
           
    EXCEPTION
        when standard.no_data_found then
            mArgs := 'getAcquisitionAdviceCode: no data found for ' || part_no ;
            return null ; 
        WHEN OTHERS THEN
           ErrorMsg(pSqlfunction => 'select',
             pTableName => 'amd_spare_parts',
             pError_location => 10,
             pKey_1 => part_no ) ;
              RAISE ;
    end getAcquisitionAdviceCode ;

    function isNsnInRblPairs(nsn in amd_spare_parts.nsn%type, showReason in boolean := false) return boolean is
        result boolean := false ;
    begin
        <<tryOldNsn>>
        declare
            cursor old_nsns is
                select old_nsn
                from amd_rbl_pairs 
                where old_nsn = isNsnInRblPairs.nsn ;
        begin
            for rec in old_nsns loop 
                   result := true ;
                exit when true ;
            end loop ;
        
            if not result then
                <<tryNewNsn>>
                declare
                    cursor new_nsns is
                        select new_nsn
                        from amd_rbl_pairs 
                        where new_nsn = isNsnInRblPairs.nsn ;
                begin
                    for rec in new_nsns loop
                        result := true ;
                        exit when true ;
                    end loop ;
                exception
                    when others then
                        ErrorMsg(pSqlfunction => 'select',
                            pTableName => 'amd_rbl_pairs',
                            pError_location => 20,
                            pKey_1 => isNsnInRblPairs.nsn) ;
                        raise ;
                End tryNewNsn ;
        end  if ;
        exception when others then
                   ErrorMsg(pSqlfunction => 'select',
                  pTableName => 'amd_rbl_pairs',
                  pError_location => 30,
                  pKey_1 => isNsnInRblPairs.nsn) ;
            raise ;
        end tryOldNsn ;
             
        if result then
            null ; -- do nothing
        else
            debugMsg(isNsnInRblPairs.nsn || ' Nsn is NOT valid',40) ;
            if showReason then dbms_output.put_line(isNsnInRblPairs.nsn || ' Nsn is NOT valid') ; end if ;
        end if ;
                    
        return result ;
    
    exception when others then
        ErrorMsg(pSqlfunction => 'isNsnInRblPairs',
            pTableName => 'amd_rbl_pairs',
            pError_location => 35,
            pKey_1 => isNsnInRblPairs.nsn) ;
        
        raise ;
    End isNsnInRblPairs ;
    
    function isNsnInRblPairsYorN(nsn in amd_spare_parts.nsn%type, showReason in boolean := false) return varchar2 is
    begin
        if isNsnInRblPairs(nsn, showReason) then
            return 'Y' ;
        else
            return 'N' ;
        end if ;
    end isNsnInRblPairsYorN ;

    function isNsnInIsgPairs(nsn in amd_spare_parts.nsn%type, showReason in boolean := false) return boolean is
        result boolean := false ;
    begin
        <<tryOldNsn>>
        DECLARE
            CURSOR old_nsns IS
                select old_nsn  
                from bssm_isg_pairs 
                where old_nsn = isNsnInIsgPairs.nsn AND lock_sid = 0 ;
        begin
            for rec in old_nsns loop
                result := true ;
                exit when true ;
            end loop ;
            if not result then
                <<tryNewNsn>>
                declare
                    cursor new_nsns is
                        select new_nsn from bssm_isg_pairs 
                        where new_nsn = isnsninisgpairs.nsn and lock_sid = 0 ;
                begin
                for rec in new_nsns loop
                    result := true ;
                    exit when true ;
                    end loop ;
                exception
                    when others then
                        ErrorMsg(pSqlfunction => 'select',
                            pTableName => 'bssm_isg_pairs',
                            pError_location => 40,
                            pKey_1 => isNsnInIsgPairs.nsn) ;
                        raise ;
                end tryNewNsn ;
            end if ;
        exception
            when others then
                ErrorMsg(pSqlfunction => 'select',
                    pTableName => 'bssm_isg_pairs',
                    pError_location => 50,
                    pKey_1 => isNsnInIsgPairs.nsn) ;
                raise ;
                 
        end tryOldNsn ;
             
        if result then
            null ; -- do nothing
        else
            debugMsg('Nsn is NOT in ISG Pairs',50) ;
            if showReason then dbms_output.put_line('Nsn is NOT in ISG Pairs') ; end if ;
        end if ;
        return result ;
    
    end isNsnInIsgPairs ;

    function isNsnInIsgPairsYorN(nsn in amd_spare_parts.nsn%type, showReason in boolean := false) return varchar2 is
    begin
        if isNsnInIsgPairs(nsn, showReason) then
            return 'Y' ;
        else
            return 'N' ;
        end if ;
    end isNsnInIsgPairsYorN ;

    function isNsnValid(part_no in amd_spare_parts.part_no%type, showReason in boolean := false) return boolean is
            
        nsn  amd_spare_parts.nsn%type ;
                       
    begin
        <<getNsn>>
        begin
            select parts.nsn into isNsnValid.nsn
            from amd_spare_parts parts
            where isNsnValid.part_no = parts.part_no ;
        exception when others then
            ErrorMsg(pSqlfunction => 'select',
                pTableName => 'amd_spare_parts',
                pError_location => 60,
                pKey_1 => isNsnValid.part_no,
                pKey_2 => nsn) ;
            raise ;
        end getNsn ;
        return isNsnInRblPairs(nsn) or isNsnInIsgPairs(nsn) ;
    exception
        when standard.no_data_found then
            return false ;
    end isNsnValid ;

    function isNsnValidYorN(part_no in amd_spare_parts.part_no%type, showReason in boolean := false) return varchar2 is
    begin
        if isNsnValid(part_no, showReason) then
            return 'Y' ;
        else
            return 'N' ;
        end if ;
    end isNsnValidYorN ;
        
    function demandExists(part_no in amd_spare_parts.part_no%type, showReason in boolean := false) return boolean is
        result NUMBER := 0 ;
    begin
        select 1 into result
        from dual
        where exists
            (select *
            from amd_demands demands, amd_national_stock_items items, amd_spare_parts parts
            where demandexists.part_no = parts.part_no
            and parts.action_code != amd_defaults.delete_action
            and parts.nsn = items.nsn
            and items.action_code != amd_defaults.delete_action
            and items.nsi_sid = demands.nsi_sid
            and demands.quantity > 0
            and demands.action_code != amd_defaults.delete_action) ;
            
        if result > 0 then
            null ; -- do  nothing
        else
            debugMsg('Demand does NOT exist for ' || demandExists.part_no, 10) ;
            if showReason then dbms_output.put_line('Demand does NOT exist for ' || demandExists.part_no) ; end if ;
        end if ;
        
        return (result > 0) ;
        
    exception
        when standard.no_data_found then
            return false ;
        when others then
            ErrorMsg(pSqlfunction => 'select',
                pTableName => 'demands / items',
                pError_location => 70,
                pKey_1 => demandExists.part_no) ;
            raise ;
    end demandExists ;
    
    function demandExistsYorN(part_no in amd_spare_parts.part_no%type, showReason in boolean := false) return varchar2 is
    begin
        if demandExists(part_no, showReason) then
            return 'Y' ;
        else
            return 'N' ;
        end if ;
    end demandExistsYorN ;
        
    function inventoryExists(part_no in amd_spare_parts.part_no%type, showReason in boolean := false) return boolean is
        result NUMBER := 0 ;
        primePartNo AMD_NATIONAL_STOCK_ITEMS.prime_part_no%TYPE ;
    BEGIN
        <<getPrimePartNo>>
        BEGIN
            select items.prime_part_no into primePartNo
            from amd_national_stock_items items, amd_spare_parts parts
            where inventoryExists.part_no = parts.part_no
            and parts.nsn = items.nsn ;
        exception when others then
            ErrorMsg(pSqlfunction => 'select',
                pTableName => 'amd_spare_parts',
                pError_location => 80,
                pKey_1 => inventoryExists.part_no) ;
            raise ;
        end getPrimePartNo ;
    
        <<doesDataExist>>
        begin
            select 1 into result
            from dual
            where exists
                (select *
                from amd_on_hand_invs oh
                where primepartno = oh.part_no
                and oh.action_code != amd_defaults.delete_action
                and oh.inv_qty >0
                )
                or exists
                    (select *
                    from amd_in_repair ir
                    where primepartno = ir.part_no
                    and ir.action_code != amd_defaults.delete_action
                    and ir.repair_qty > 0
                    )
                or exists
                    (select *
                    from amd_on_order oo
                    where primepartno = oo.part_no
                    and oo.action_code != amd_defaults.delete_action
                    and oo.order_qty > 0
                    )
                or exists
                    (select *
                     from amd_in_transits it
                    where primepartno = it.part_no
                    and it.action_code != amd_defaults.delete_action
                    and it.quantity > 0
                    )  ;
        exception
            when standard.no_data_found then
                null ;
            when others then
                if sqlcode = -4091 then
                    raise_application_error(-20050,substr(1,2000,
                        '29 ' || inventoryExists.part_No )) ;
                else
                    ErrorMsg(pSqlfunction => 'select',
                        pTableName => 'exist',
                        pError_location => 90,
                        pKey_1 => inventoryExists.part_No) ;
                end if ;
                raise ;
    
        end doesDataExist ;
        if result > 0 then
            null ; -- do nothing
        else
            debugMsg('Inventory does NOT exist for ' || inventoryExists.part_No, 20) ;
            if showReason then dbms_output.put_line('Inventory does NOT exist for ' || inventoryExists.part_No) ; end if ;
        end if ;      
        return (result > 0) ;
    exception when others then
        ErrorMsg(pSqlfunction => 'selects',
            pTableName => 'inventoryExists',
            pError_location => 100,
            pKey_1 => part_no ) ;
        
        raise ;
    end inventoryExists ;

    function inventoryExistsYorN(part_no in amd_spare_parts.part_no%type, showReason in boolean := false) return varchar2 is
    begin
        if inventoryExists(part_no, showReason) then
            return 'Y' ;
        else
            return 'N' ;
        end if ;
    exception when others then
        ErrorMsg(pSqlfunction => 'selects',
            pTableName => 'inventoryExistsYorN',
            pError_location => 110,
            pKey_1 => part_no) ;
        
        raise ;
    end inventoryExistsYorN ;
        
    function isPartValid(partNo IN VARCHAR2, preferredSmrCode IN VARCHAR2, 
        preferredMtbdr IN NUMBER, preferredPlannerCode IN VARCHAR2, showReason in boolean := false) RETURN BOOLEAN IS
    
        result boolean := false ;
        nsn amd_spare_parts.nsn%type ;
        lineNo number := 0 ;
    
    
     BEGIN
        lineNo := 10 ;
        if not amd_utils.isPartActive(partno) then
             return false ;
        end if ;
       
        lineNo := 20 ;
        IF UPPER(partNo) = 'F117-PW-100' OR INSTR(UPPER(partNo),'17L8D') > 0 OR INSTR(UPPER(partNo),'17R9Y') > 0 OR INSTR(UPPER(preferredSmrCode),'PE') > 0 THEN
              RETURN FALSE ;
        END IF ;
       
        lineNo := 30 ;
       if getAcquisitionAdviceCode(partNo) = 'Y' then
            return false ;
       end if ;
       
        lineNo := 40 ;
       result := amd_utils.isRepairableSmrCode(preferredSmrCode) ;
       
       if not result then
             debugmsg(preferredSmrCode || ' is NOT a valid smr code', 70) ;
             if showreason then 
            dbms_output.put_line(preferredSmrCode || ' is NOT a valid smr code') ; 
          end if ;
       end if ;
       
       lineNo := 50 ;
       result := result AND isPlannerCodeValid(preferredPlannerCode) ;
       IF result AND isNsl(partNo) THEN
       
         IF showReason AND (preferredMtbdr IS NOT NULL AND preferredMtbdr > 0) THEN
             dbms_output.put_line('mtbdr > 0 for part ' || partNo) ; 
         END IF ;
         
         lineNo := 60 ;
         result := result AND (demandExists(partNo, showReason) OR inventoryExists(partNo, showReason)
                    OR (preferredMtbdr IS NOT NULL AND preferredMtbdr > 0)
                    OR isNsnValid(partNo,showReason) ) ;
      END IF ;
      IF result THEN
           null ; -- do nothing
      ELSE
           debugMsg('part ' || partNo || ' is NOT valid.',80) ;
           if showReason then dbms_output.put_line('part ' || partNo || ' is NOT valid.') ; end if ;
      END IF ;
      lineNo := 70 ;
      return result ;
     exception when others then
        
        if sqlcode = -20000 then
            dbms_output.disable ; -- buffer overflow, disable
            return ispartvalid(partno) ; -- try validation again
        end if ;
        
        ErrorMsg(pSqlfunction => 'selects',
            pTableName => 'isPartValid',
            pError_location => 120,
            pKey_1 => lineNo) ;
        
        raise ;
           
     end isPartValid ;
    


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
       if amd_utils.ispartConsumable(part_no) then
            a2a_consumables_pkg.insertPartInfo(part_no, action_code) ;
            result := SUCCESS ;
       else
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
                 if isPartSent(part_no) then
                    result := deletePartInfo(part_no, nomenclature) ;
                 end if ;
          END CASE ;
      end if ;           
      IF result != SUCCESS THEN
         RAISE partInfoError ;
      END IF ;
     END insertPartInfo ;
    
     procedure InsertPartInfo(part_no in varchar2, action_code in varchar2) is
     
           nomenclature     amd_spare_parts.NOMENCLATURE%type ;
           mfgr             amd_spare_parts.MFGR%type ;
           unit_issue       amd_spare_parts.UNIT_OF_ISSUE%type ;
           smr_code         amd_national_stock_items.smr_code%type ;
           nsn              amd_spare_parts.nsn%type ;
           planner_code     amd_national_stock_items.planner_code%type ;
           mtbdr            amd_national_stock_items.MTBDR%type ;
           indenture        tmp_a2a_part_info.INDENTURE%type ;  
           price            amd_spare_parts.UNIT_COST%type ;       
           lineNo           number := 0 ;
           result           number ;    

     begin

        if amd_utils.ispartConsumable(part_no) then
            lineNo := 1 ;
            a2a_consumables_pkg.insertPartInfo(part_no, action_code) ;
        else        
            lineNo := 2 ;
            if action_code = amd_defaults.DELETE_ACTION then
                select nomenclature into nomenclature from amd_spare_parts where part_no = insertPartInfo.part_no ;
                result := deletePartInfo(part_no, nomenclature) ;
            else                
                lineNo := 3 ;
                select nomenclature, mfgr, unit_of_issue, parts.nsn, 
                    amd_preferred_pkg.GetPreferredValue(smr_code_cleaned, smr_code) smr_code,
                    amd_preferred_pkg.getPreferredValue(mtbdr_cleaned, mtbdr_computed, mtbdr) mtbdr,            
                    amd_preferred_pkg.getPreferredValue(planner_code_cleaned, planner_code) planner_code,
                    amd_preferred_pkg.getPreferredValue(unit_cost_cleaned, unit_cost) price
                into nomenclature, mfgr, unit_issue, nsn, smr_code, mtbdr, planner_code, price             
                from amd_spare_parts parts, amd_national_stock_items items
                where part_no = InsertPartInfo.part_no
                and parts.nsn = items.nsn ;
                
                lineNo := 4 ;
                insertPartInfo( part_no => part_no, nomenclature => nomenclature, action_code => action_code,
                    mfgr => mfgr, unit_issue => unit_issue, smr_code => smr_code, nsn => nsn, 
                    planner_code => planner_code, third_party_flag => a2a_pkg.THIRD_PARTY_FLAG, 
                    mtbdr => mtbdr, indenture => getIndenture(smr_code), price => price) ;
            end if ;

        
        end if ;
        
     exception when others then
            
        ErrorMsg(pSqlfunction => 'select/insert',
              pTableName => 'insertPartInfo',
              pError_location => 130,
              pKey_1 => part_no,
              pKey_2 => lineNo ) ;
         RAISE ;
 end insertPartInfo ;
     
     procedure initA2ADemands is
        cnt number := 0 ;
        action_code tmp_a2a_demands.ACTION_CODE%type ;
        site tmp_a2a_demands.site%type ;
        thePartNo tmp_a2a_demands.part_no%type ;
        cursor theDemands is
            SELECT a.NSI_SID,
                a.LOC_SID,
                a.DOC_NO docno,
                a.DOC_DATE demand_date,
                a.QUANTITY qty
            FROM amd_owner.AMD_DEMANDS a ;
     begin
        amd_owner.Mta_Truncate_Table('tmp_a2a_demands','reuse storage');
        for rec in theDemands loop
            thePartNo := Amd_Partprime_Pkg.getSuperPrimePartByNsiSid(rec.nsi_sid) ;
            site := Amd_Utils.getSpoLocation(rec.loc_sid) ;
            if site not in  ('FB4454', 'FB4455', 'FB4412', 'FB4490', 'FB4491') then
                begin
                    select action_code into action_code from amd_sent_to_a2a where part_no = thePartNo
                    and part_no = spo_prime_part_no ;
                    INSERT INTO amd_owner.TMP_A2A_DEMANDS
                       (part_no, site, docno, demand_date, qty, demand_level, action_code, last_update_dt)
                       values (thePartNo, site, rec.docno, rec.demand_date, rec.qty, null, action_code, sysdate) ;
                    cnt := cnt + 1 ;
                exception when standard.no_data_found then
                    null ; -- do nothing
                end ;	
            end if ;
        end loop ;
        dbms_output.put_line('cnt=' || cnt) ;
        commit ;
     end initA2ADemands ;
     
     PROCEDURE processExtForecast(extForecast IN extForecastCur) IS
                rec AMD_part_loc_forecasts%ROWTYPE ;
               cnt NUMBER := 0 ;
               rc number ;
               extForecasts extForecastTab ;
     BEGIN
            writeMsg(pTableName => 'tmp_a2a_ext_forecast', pError_location => 140,
                pKey1 => 'processExtForecast',
                pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
           
           fetch extForecast bulk collect into extForecasts ;
           close extForecast ;
           
           if extForecasts.first is not null then
               for indx in extForecasts.first .. extForecasts.last                
               LOOP
                  amd_part_loc_forecasts_pkg.InsertTmpA2A_EF_AllPeriods
                    (
                        extForecasts(indx).part_no, 
                        Amd_Utils.GetSpoLocation(extForecasts(indx).loc_sid) , 
                        amd_part_loc_forecasts_pkg.GetCurrentPeriod, 
                        extForecasts(indx).forecast_qty , 
                        extForecasts(indx).action_code, 
                        sysdate 
                    )  ;
                   cnt := cnt + 1 ;
               END LOOP ;
            end if ;               
            writeMsg(pTableName => 'tmp_a2a_ext_forecast', pError_location => 150,
                pKey1 => 'processExtForecast',
                pKey2 => 'cnt=' || TO_CHAR(cnt),
                pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
          COMMIT ;
     END processExtForecast ;
     
     PROCEDURE initA2AExtForecast(from_dt IN DATE := START_DT, to_dt IN DATE := SYSDATE) IS
      extForecast extForecastCur ;
      
     BEGIN
          writeMsg(pTableName => 'tmp_a2a_ext_forecast', pError_location => 160,
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
              and part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A WHERE spo_prime_part_no IS NOT NULL)
              order by part_no, loc_sid, last_update_dt ;
          processExtForecast(extForecast) ;
          writeMsg(pTableName => 'tmp_a2a_ext_forecast', pError_location => 170,
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
                writeMsg(pTableName => 'amd_part_loc_forcecast', pError_location => 180,
                    pKey1 => 'getTestData' ) ;
                commit ;
                OPEN extForecast FOR
                    SELECT *
                    FROM AMD_part_loc_forecasts WHERE
                    part_no IN (SELECT part_no FROM AMD_TEST_PARTS) 
                    AND part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A WHERE spo_prime_part_no IS NOT NULL) 
                    order by part_no, loc_sid, last_update_dt ;
                        
            end getTestData ;
            
            procedure getAllData is
            begin
                 writeMsg(pTableName => 'amd_part_loc_forcecast', pError_location => 190,
                     pKey1 => 'getAllData' ) ;
                commit ;
                OPEN extForecast FOR
                    SELECT * FROM AMD_part_loc_forecasts WHERE
                    part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A WHERE spo_prime_part_no IS NOT NULL)
                    order by part_no, loc_sid, last_update_dt ;
                  
            end getAllData ;
            
      begin
          writeMsg(pTableName => 'tmp_a2a_ext_forecast', pError_location => 200,
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
          writeMsg(pTableName => 'tmp_a2a_ext_forecast', pError_location => 210,
                    pKey1 => 'initA2AExtForecast',
                    pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
                    pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
          COMMIT ;
      end initA2AExtForecast ;
    
    
     PROCEDURE processOnHandInvSum(onHandInvSum IN onHandInvSumCur) IS
               cnt NUMBER := 0 ;
               onHandInvSums onHandInvSumTab ;
     BEGIN
        writeMsg(pTableName => 'tmp_a2a_inv_info', pError_location => 212,
            pKey1 => 'processOnHandInvSum',
            pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
        fetch onHandInvSum bulk collect into onHandInvSums ;
        close onHandInvSum ;

        if onHandInvSums.first is not null then
            for indx in onHandInvSums.first .. onHandInvSums.last           
            LOOP
                A2a_Pkg.insertInvInfo(onHandInvSums(indx).part_no,onHandInvSums(indx).spo_location,onHandInvSums(indx).qty_on_hand, onHandInvSums(indx).action_code) ;
                cnt := cnt + 1 ;
            END LOOP ;
            COMMIT ;
        end if ;              
        writeMsg(pTableName => 'tmp_a2a_inv_info', pError_location => 214,
            pKey1 => 'processOnHandInvSum',
            pKey2 => 'cnt=' || TO_CHAR(cnt),
            pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
     END processOnHandInvSum ;
     
     PROCEDURE initA2AInvInfo(from_dt IN DATE := START_DT, to_dt IN DATE := SYSDATE) IS
      invInfoByDate onHandInvSumCur ; 
       
     BEGIN
        writeMsg(pTableName => 'tmp_a2a_inv_info', pError_location => 220,
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
        and sent.spo_prime_part_no is not null
        order by part_no, spo_location, last_update_dt ;
    
      Mta_Truncate_Table('TMP_A2A_INV_INFO','reuse storage');
      processOnHandInvSum(invInfoByDate) ;
      writeMsg(pTableName => 'tmp_a2a_inv_info', pError_location => 230,
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
            writeMsg(pTableName => 'amd_on_hand_invs_sum', pError_location => 240,
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
              and sent.SPO_PRIME_PART_NO is not null
              order by part_no, spo_location, last_update_dt ;
         end getTestData ;
         
         procedure getAllData is
         begin
            writeMsg(pTableName => 'amd_on_hand_invs_sum', pError_location => 250,
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
                  and sent.SPO_PRIME_PART_NO is not null
                  order by part_no, spo_location, last_update_dt ;

         end getAllData ;
      
    
     BEGIN
      writeMsg(pTableName => 'tmp_a2a_inv_info', pError_location => 260,
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
      resetDebugCnts ;
      processOnHandInvSum(invInfo) ;
      writeMsg(pTableName => 'tmp_a2a_inv_info', pError_location => 270,
                pKey1 => 'initA2AInvInfo',
                pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
                pKey3 => 'insertCnt=' || insertCnt || ' deleteCnt=' || deleteCnt || ' rejectCnt=' || rejectCnt,
                pData => 'updateCnt=' || updateCnt,
                pKey4 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
                
      COMMIT ;
      RETURN result ;
     END initA2AInvInfo ;
    
    function tmpA2AInvInfoAddOk(part_no in AMD_ON_HAND_INVS_SUM.PART_NO%type) return boolean is
         invInfo onHandInvSumCur ;
         result number := null ;
    begin
        processOnHandInvSum(invInfo) ;
        select 1 into result from dual
            where exists (select null
                          from tmp_a2a_inv_info
                          where part_no = tmpA2AInvInfoAddOk.part_no ) ; 
        return result is not null ;
    exception when standard.no_data_found then
        return false ;
    end tmpA2AInvInfoAddOk ;
    
    function tmpA2AInvInfoAddOk(part_no in AMD_ON_HAND_INVS_SUM.PART_NO%type, spo_location in amd_on_hand_invs_sum.SPO_LOCATION%type ) return boolean is
         invInfo onHandInvSumCur ;
         result number := null ;
    begin
        if spo_location is null then
                    open invInfo for
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
                  and oh.part_no = tmpA2AInvInfoAddOk.part_no 
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
                  and sent.SPO_PRIME_PART_NO is not null 
                  and rsp.part_no = tmpA2AInvInfoAddOk.part_no ;
        else
            open invInfo for
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
                      and oh.part_no = tmpA2AInvInfoAddOk.part_no
                      and oh.spo_location =  tmpA2AInvInfoAddOk.spo_location
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
                      and sent.SPO_PRIME_PART_NO is not null 
                      and rsp.part_no = tmpA2AInvInfoAddOk.part_no 
                      and rsp.rsp_location =  tmpA2AInvInfoAddOk.spo_location ;
        end if ;
        processOnHandInvSum(invInfo) ;
        if spo_location is null then
            select 1 into result from dual
                where exists (select null
                              from tmp_a2a_inv_info
                              where part_no = tmpA2AInvInfoAddOk.part_no) ;
        else
            select 1 into result from dual
                where exists (select null
                              from tmp_a2a_inv_info
                              where part_no = tmpA2AInvInfoAddOk.part_no
                              and spo_location =  tmpA2AInvInfoAddOk.spo_location) ;
        end if ;
        
        return result is not null ;
        
    exception when standard.no_data_found then
        return false ;
    end tmpA2AInvInfoAddOk ;
    
 
    PROCEDURE processRepairInvInfo(repairInvInfo IN repairInvInfoCur) IS
              cnt NUMBER := 0 ;
              repairInvInfos repairInvInfoTab ;
    BEGIN
         writeMsg(pTableName => 'tmp_a2a_repair_inv_info', pError_location => 280,
                pKey1 => 'proecessRepairInvInfo',
                pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
         fetch repairInvInfo bulk collect into repairInvInfos ;
         close repairInvInfo ;

        if repairInvInfos.first is not null then         
             for indx in repairInvInfos.first .. repairInvInfos.last
             LOOP
                 A2a_Pkg.insertRepairInvInfo(repairInvInfos(indx).part_no,repairInvInfos(indx).site_location,repairInvInfos(indx).qty_on_hand, repairInvInfos(indx).action_code) ;
                  cnt := cnt + 1 ;
             END LOOP ;
             COMMIT ;
        end if ;             
     writeMsg(pTableName => 'tmp_a2a_repair_inv_info', pError_location => 290,
            pKey1 => 'proecessRepairInvInfo',
            pKey2 => 'cnt=' || TO_CHAR(cnt),
            pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
    END processRepairInvInfo ;
     
    PROCEDURE initA2ARepairInvInfo(from_dt IN DATE := START_DT, to_dt IN DATE := SYSDATE) IS
      repairInvInfoByDate repairInvInfoCur ;
      
      cnt NUMBER := 0 ;
      
    BEGIN
      writeMsg(pTableName => 'tmp_a2a_repair_inv_info', pError_location => 300,
                pKey1 => 'initA2ARepairInvInfo',
                pKey2 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
                pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
                pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
      Mta_Truncate_Table('TMP_A2A_REPAIR_INV_INFO','reuse storage');
      mblnSendAllData := TRUE ;
      OPEN repairInvInfoByDate FOR
              SELECT  rep.PART_NO,       
                      rep.SITE_LOCATION,    
                      QTY_ON_HAND,
                      case rep.action_code
                             when amd_defaults.getDELETE_ACTION then
                                   rep.action_code
                           else                            
                                     sent.ACTION_CODE
                      end action_code,     
                      LAST_UPDATE_DT  
              FROM AMD_REPAIR_INVS_SUM rep, amd_sent_to_a2a sent
              where rep.part_no = sent.part_no
              and sent.spo_prime_part_no is not null 
              and TRUNC(last_update_dt) BETWEEN TRUNC(from_dt) AND TRUNC(to_dt) 
              order by rep.part_no, rep.site_location, last_update_dt ;
      resetDebugCnts ;               
      processRepairInvInfo(repairInvInfoByDate) ;
      writeMsg(pTableName => 'tmp_a2a_repair_inv_info', pError_location => 310,
                pKey1 => 'initA2ARepairInvInfo',
                pKey2 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
                pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
                pKey4 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pData => 'insertCnt=' || insertCnt || ' deleteCnt=' || deleteCnt || ' rejectCnt=' || rejectCnt || ' updateCnt=' || updateCnt) ;
      COMMIT ;
    END initA2ARepairInvInfo ;
    
    function tmpA2ARepairInvInfoAddOk(part_no in amd_repair_invs_sum.part_no%type,
        site_location in amd_repair_invs_sum.site_location%type := null) return boolean is
      repairInvInfoByDate repairInvInfoCur ;
      result number := null ;
    begin
      if site_location is null then
          OPEN repairInvInfoByDate FOR
                  SELECT  rep.PART_NO,       
                          rep.SITE_LOCATION,    
                          QTY_ON_HAND,
                          case rep.action_code
                                 when amd_defaults.getDELETE_ACTION then
                                       rep.action_code
                               else                            
                                         sent.ACTION_CODE
                          end action_code,     
                          LAST_UPDATE_DT  
                  FROM AMD_REPAIR_INVS_SUM rep, amd_sent_to_a2a sent
                  where rep.part_no = sent.part_no
                  and sent.spo_prime_part_no is not null
                  and rep.part_no = tmpA2ARepairInvInfoAddOk.part_no ;
      else 
          OPEN repairInvInfoByDate FOR
                  SELECT  rep.PART_NO,       
                          rep.SITE_LOCATION,    
                          QTY_ON_HAND,
                          case rep.action_code
                                 when amd_defaults.getDELETE_ACTION then
                                       rep.action_code
                               else                            
                                         sent.ACTION_CODE
                          end action_code,     
                          LAST_UPDATE_DT  
                  FROM AMD_REPAIR_INVS_SUM rep, amd_sent_to_a2a sent
                  where rep.part_no = sent.part_no
                  and sent.spo_prime_part_no is not null
                  and rep.part_no = tmpA2ARepairInvInfoAddOk.part_no
                  and rep.site_location = tmpA2ARepairInvInfoAddOk.site_location ;
      end if ;
                  
      processRepairInvInfo(repairInvInfoByDate) ;
      
      if site_location is null then
        select 1 into result from dual
        where exists (select null
                      from tmp_a2a_repair_inv_info
                      where part_no = tmpA2ARepairInvInfoAddOk.part_no) ;
      else
        select 1 into result from dual
        where exists (select null
                      from tmp_a2a_repair_inv_info
                      where part_no = tmpA2ARepairInvInfoAddOk.part_no
                      and site_location = tmpA2ARepairInvInfoAddOk.site_location );
      end if ; 
      return result is not null ;
    exception when standard.no_data_found then
        return false ;
    end tmpA2ARepairInvInfoAddOk ;
    
       
    FUNCTION initA2ARepairInvInfo(useTestParts IN BOOLEAN := FALSE) RETURN NUMBER IS
        repairInvInfo repairInvInfoCur ;
        result NUMBER := SUCCESS ;
          
        procedure getTestData is
        begin
            writeMsg(pTableName => 'amd_repair_invs_sum', pError_location => 320,
            pKey1 => 'getTestData' ) ;
            commit ;
              OPEN repairInvInfo FOR
              SELECT  rep.PART_NO,       
                      rep.SITE_LOCATION,    
                      QTY_ON_HAND,
                      case rep.action_code
                             when amd_defaults.getDELETE_ACTION then
                                   rep.action_code             
                           else                            
                                     sent.ACTION_CODE
                      end action_code,     
                      LAST_UPDATE_DT  
              FROM AMD_REPAIR_INVS_SUM rep, amd_sent_to_a2a sent
              where rep.part_no = sent.part_no
              and sent.spo_prime_part_no is not null 
              and rep.part_no IN (SELECT part_no FROM AMD_TEST_PARTS) 
              order by rep.part_no, rep.site_location, last_update_dt ; 
        end getTestData ;
        
        procedure getAllData is
        begin
            writeMsg(pTableName => 'amd_repair_invs_sum', pError_location => 330,
            pKey1 => 'getAllData' ) ;
            commit ;
               OPEN repairInvInfo FOR
              SELECT  rep.PART_NO,       
                      rep.SITE_LOCATION,    
                      QTY_ON_HAND,
                      case rep.action_code
                             when amd_defaults.getDELETE_ACTION then
                                   rep.action_code
                           else                            
                                     sent.ACTION_CODE
                      end action_code,     
                      LAST_UPDATE_DT  
              FROM AMD_REPAIR_INVS_SUM rep, amd_sent_to_a2a sent
              where rep.part_no = sent.part_no
              and sent.spo_prime_part_no is not null
              order by rep.part_no, rep.site_location, last_update_dt ;
        end getAllData ;
    
    BEGIN
      writeMsg(pTableName => 'tmp_a2a_repair_inv_info', pError_location => 340,
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
      resetDebugCnts ;
      processRepairInvInfo(repairInvInfo) ;
    
      writeMsg(pTableName => 'tmp_a2a_repair_inv_info', pError_location => 350,
                pKey1 => 'initA2ARepairInvInfo',
                pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
                pKey3 => 'insertCnt=' || insertCnt || ' deleteCnt=' || deleteCnt || ' rejectCnt=' || rejectCnt,
                pData => 'updateCnt=' || updateCnt,
                pKey4 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
      COMMIT ;
      RETURN result ;
     END initA2ARepairInvInfo ;
     
     PROCEDURE processInTransits(inTransit IN inTransitsCur) IS
                cnt NUMBER := 0 ;
               rec AMD_IN_TRANSITS_SUM%ROWTYPE ;
               inTransits inTransitsTab ;
     BEGIN
          writeMsg(pTableName => 'tmp_a2a_in_transits', pError_location => 360,
                pKey1 => 'processInTransits',
                pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
           fetch inTransit bulk collect into inTransits ;
           close inTransit ;
           
           if inTransits.first is not null then
               for indx in inTransits.first .. inTransits.last                
               LOOP
                  A2a_Pkg.insertTmpA2AInTransits(
                       inTransits(indx).part_no,
                       inTransits(indx).site_location,
                       inTransits(indx).quantity,
                       inTransits(indx).serviceable_flag,
                       inTransits(indx).action_code) ;       
                     cnt := cnt + 1 ;
              END LOOP ;
          end if ;              
          writeMsg(pTableName => 'tmp_a2a_in_transits', pError_location => 370,
                pKey1 => 'processInTransits',
                pKey2 => 'cnt=' || TO_CHAR(cnt),
                pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
          COMMIT ;
     END processInTransits ;
     
     PROCEDURE initA2AInTransits(from_dt IN DATE := START_DT, to_dt IN DATE := SYSDATE) IS
      inTransitsByDate inTransitsCur ;
      
     BEGIN
          writeMsg(pTableName => 'tmp_a2a_in_transits', pError_location => 380,
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
              AND part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A WHERE spo_prime_part_no IS NOT NULL)
              order by part_no, site_location, serviceable_flag, last_update_dt ;
          processInTransits(inTransit => inTransitsByDate) ;
          writeMsg(pTableName => 'tmp_a2a_in_transits', pError_location => 390,
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
             writeMsg(pTableName => 'amd_in_transits_sum', pError_location => 400,
             pKey1 => 'getTestData' ) ;
             commit ;
               OPEN inTransits FOR
                  SELECT *
                  FROM AMD_IN_TRANSITS_SUM  WHERE
                  part_no IN (SELECT part_no FROM AMD_TEST_PARTS)
                  AND part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A WHERE spo_prime_part_no IS NOT NULL)
                  order by part_no, site_location, serviceable_flag, last_update_dt ;
         end getTestData ;
         
         procedure getAllData is
         begin
             writeMsg(pTableName => 'amd_in_transits_sum', pError_location => 410,
             pKey1 => 'getAllData' ) ;
             commit ;
               OPEN inTransits FOR
                  SELECT * FROM AMD_IN_TRANSITS_SUM  WHERE 
                  part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A WHERE spo_prime_part_no IS NOT NULL)
                  order by part_no, site_location, serviceable_flag, last_update_dt ;
         end getAllData ;
    
     BEGIN
          writeMsg(pTableName => 'tmp_a2a_in_transits', pError_location => 420,
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
          writeMsg(pTableName => 'tmp_a2a_in_transits', pError_location => 430,
                    pKey1 => 'initA2AInTransits',
                    pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
                    pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
          COMMIT ;  
          RETURN result ;
     END initA2AInTransits ;
    
     function tmpA2AInTransitsAddOk(part_no in amd_in_transits.part_no%type) return boolean is
         inTransits inTransitsCur ;
        
         result NUMBER := null ;
         
     begin
          
        open inTransits for
            select * from amd_in_transits_sum  where 
            part_no in (select part_no from amd_sent_to_a2a where spo_prime_part_no is not null)
            and part_no = tmpA2AInTransitsAddOk.part_no ;
             
          processintransits(intransits) ;
          
          select 1 into result from dual
          where exists (select null
                        from tmp_a2a_in_transits
                        where part_no = tmpA2AInTransitsAddOk.part_no ) ;
                              
          return result is not null ;
          
     exception when standard.no_data_found then
        return false ;
     end tmpA2AInTransitsAddOk ;
     
     PROCEDURE processInRepair(inRepair IN inRepairCur) IS
                cnt NUMBER := 0 ;
               inRepairs inRepairTab ;
     BEGIN
            writeMsg(pTableName => 'tmp_a2a_repair_info', pError_location => 440,
                pKey1 => 'processInRepair',
                pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
           fetch inRepair bulk collect into inRepairs ;
           close inRepair ;
           
           if inRepairs.first is not null then
               for indx in inRepairs.first .. inRepairs.last  
               LOOP
                   A2a_Pkg.insertRepairInfo(inRepairs(indx).part_no,inRepairs(indx).loc_sid,inRepairs(indx).order_no,inRepairs(indx).repair_date,A2a_Pkg.OPEN_STATUS,inRepairs(indx).repair_qty,
                        inRepairs(indx). repair_need_date, inRepairs(indx).action_code) ;
                   cnt := cnt + 1 ;
              END LOOP ;
           end if ;              
            writeMsg(pTableName => 'tmp_a2a_repair_info', pError_location => 450,
                pKey1 => 'processInRepair',
                pKey2 => 'cnt=' || TO_CHAR(cnt),
                pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  
          COMMIT ;
     END processInRepair ;
     
     PROCEDURE initA2ARepairInfo(from_dt IN DATE := START_DT, to_dt IN DATE := SYSDATE) IS
      
      repairsByDate inRepairCur ;
      
     BEGIN
            writeMsg(pTableName => 'tmp_a2a_repair_info', pError_location => 460,
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
              AND part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A WHERE spo_prime_part_no IS NOT NULL)
              order by order_no, part_no, loc_sid, last_update_dt ;
          resetDebugCnts ;              
          processInRepair(repairsByDate) ;
            writeMsg(pTableName => 'tmp_a2a_repair_info', pError_location => 470,
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
             writeMsg(pTableName => 'amd_in_repair', pError_location => 480,
             pKey1 => 'getTestData' ) ;
             commit ;
               OPEN repairs FOR
                  SELECT *
                  FROM AMD_IN_REPAIR WHERE
                  part_no IN (SELECT part_no FROM AMD_TEST_PARTS)
                  AND part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A WHERE spo_prime_part_no IS NOT NULL)
                  order by order_no, part_no, loc_sid, last_update_dt ;
         end getTestData ;
         
         procedure getAllData is
         begin
             writeMsg(pTableName => 'amd_in_repair', pError_location => 490,
             pKey1 => 'getAllData' ) ;
             commit ;
               OPEN repairs FOR
                 SELECT * FROM AMD_IN_REPAIR WHERE 
                 part_no IN (SELECT part_no FROM AMD_SENT_TO_A2A WHERE spo_prime_part_no IS NOT NULL)
                 order by order_no, part_no, loc_sid, last_update_dt ;
         end getAllData ;
    
     BEGIN
      writeMsg(pTableName => 'tmp_a2a_repair_info', pError_location => 500,
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
      resetDebugCnts ;
      processInRepair(repairs) ;
      writeMsg(pTableName => 'tmp_a2a_repair_info', pError_location => 510,
        pKey1 => 'initA2ARepairInfo',
        pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
        pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
      COMMIT ;  
      RETURN result ;
     END initA2ARepairInfo ;
    
     PROCEDURE processOnOrder(onOrder IN onOrderCur) IS
                cnt NUMBER := 0 ;
               rec AMD_ON_ORDER%ROWTYPE ;
               onOrders onOrderTab ;
     BEGIN
          writeMsg(pTableName => 'tmp_a2a_order_info_line', pError_location => 520,
            pKey1 => 'processOnOrder',
            pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
            
           fetch onOrder bulk collect into onOrders ;
           close onOrder ;
           
           if onOrders.first is not null then
               for indx in onOrders.first .. onOrders.last  
               LOOP
                  insertTmpA2AOrderInfoLine(onOrders(indx).gold_order_number,onOrders(indx).loc_sid,onOrders(indx).order_date,
                    onOrders(indx).part_no,onOrders(indx).order_qty, 
                    onOrders(indx).sched_receipt_date, onOrders(indx).action_code,
                    onOrders(indx).line) ;
                    cnt := cnt + 1 ;
              END LOOP ;
          end if ;              
          writeMsg(pTableName => 'tmp_a2a_order_info_line', pError_location => 530,
            pKey1 => 'processOnOrder',
            pKey2 => 'cnt=' || TO_CHAR(cnt),
            pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  
          COMMIT ;
     END processOnOrder ;
     
     -- create a2a for a specific set of dates
     PROCEDURE initA2AOrderInfo(from_dt IN DATE := START_DT, to_dt IN DATE := SYSDATE) IS
      ordersByDate onOrderCur ;
     BEGIN
          writeMsg(pTableName => 'tmp_a2a_order_info_line', pError_location => 540,
            pKey1 => 'initA2AOrderInfo',
            pKey2 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
            pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
            pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
          includeCnt := 0 ;
          excludeCnt := 0 ;  
            Mta_Truncate_Table('tmp_a2a_order_info_line','reuse storage');
          mblnSendAllData := TRUE ;
          OPEN ordersByDate FOR
              SELECT  
                  oo.PART_NO,  
                  LOC_SID,
                  LINE,          
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
              ORDER BY gold_order_number, order_date, loc_sid, last_update_dt ;
          processOnOrder(ordersByDate) ;
            writeMsg(pTableName => 'tmp_a2a_order_info_line', pError_location => 550,
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
             writeMsg(pTableName => 'amd_on_order', pError_location => 560,
             pKey1 => 'getTestData' ) ;
             commit ;
               OPEN onOrders FOR
              SELECT 
                      oo.PART_NO,  
                      LOC_SID,
                      LINE,          
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
              ORDER BY gold_order_number, order_date, loc_sid, last_update_dt ;
         end getTestData ;
         
         procedure getAllData is
         begin
             writeMsg(pTableName => 'amd_on_order', pError_location => 570,
             pKey1 => 'getAllData' ) ;
             commit ;
                 OPEN onOrders FOR 
                 SELECT 
                      oo.PART_NO,  
                      LOC_SID,
                      LINE,          
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
                  ORDER BY gold_order_number, order_date, loc_sid, last_update_dt ;
         end getAllData ;
    
     BEGIN
      writeMsg(pTableName => 'tmp_a2a_order_info_line', pError_location => 580,
            pKey1 => 'initA2AOrderInfo',
            pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
            pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  
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
    
      SELECT COUNT(*) INTO lines FROM TMP_A2A_ORDER_INFO_LINE ;
      writeMsg(pTableName => 'tmp_a2a_order_info_line', pError_location => 590,
            pKey1 => 'initA2AOrderInfo',
            pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
            pKey3 => 'lines=' || TO_CHAR(lines),
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
             result := insertPartLeadTime(part_no, lead_time_type, lead_time) ;
         WHEN Amd_Defaults.UPDATE_ACTION THEN
             result := updatePartLeadTime(part_no, lead_time_type, lead_time) ;
         WHEN Amd_Defaults.DELETE_ACTION THEN
             result := deletePartLeadTime(part_no) ;
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
           
           action_code tmp_a2a_part_lead_time.action_code%type := getActionCode(part_no) ; -- use whatever action_code is in amd_sent_to_a2a
              
           
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
          writeMsg(pTableName => 'amd_spare_parts', pError_location => 600,
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
                  nsi.mtbdr_computed,
                  nsi.smr_code,
                  nsi.smr_code_cleaned,
                  nsi.smr_code_defaulted,
                  nsi.nsi_sid,
                  nsi.TIME_TO_REPAIR_OFF_BASE_CLEAND,
                  nsi.last_update_dt,
                  sp.action_code
              FROM AMD_SPARE_PARTS sp,
                AMD_NATIONAL_STOCK_ITEMS nsi,
                amd_sent_to_a2a sent
              WHERE sp.nsn = nsi.nsn (+)
              and sp.part_no = sent.part_no (+) ; 
                 
        RETURN parts ;
              
     END getPartInfo ;
     
     FUNCTION getTestData RETURN partCur IS
               parts partCur ;
     BEGIN
          writeMsg(pTableName => 'amd_spare_parts', pError_location => 610,
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
                  nsi.mtbdr_computed,
                  nsi.smr_code,
                  nsi.smr_code_cleaned,
                  nsi.smr_code_defaulted,
                  nsi.nsi_sid,
                  nsi.TIME_TO_REPAIR_OFF_BASE_CLEAND,
                  nsi.last_update_dt,
                sp.action_code
              FROM AMD_SPARE_PARTS sp,
                AMD_NATIONAL_STOCK_ITEMS nsi,
                amd_sent_to_a2a sent
              WHERE sp.nsn = nsi.nsn (+)
                 and sp.part_no = sent.part_no (+)
                 AND sp.part_no IN (SELECT part_no FROM AMD_TEST_PARTS) ;
         
         RETURN parts ;
          
    END getTestData ;
     
    PROCEDURE processPartLeadTimes(parts IN partCur) IS
      rec partInfoRec ;
      cnt NUMBER := 0  ;
      theParts partTab ;
      
    BEGIN
         writeMsg(pTableName => 'tmp_a2a_part_lead_time', pError_location => 620,
            pKey1 => 'processPartLeadTimes',
            pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;  
          fetch parts bulk collect into theParts ;
          close parts ;
          
         if theParts.first is not null then
             for indx in theParts.first .. theParts.last 
             LOOP
                
                IF isPartSent(theParts(indx).part_no) THEN -- part exists in amd_sent_to_a2a with any action_code
                       insertTmpA2APartLeadTime(part_no => theParts(indx).part_no,
                                         order_lead_time => theParts(indx).order_lead_time,
                                    order_lead_time_cleaned => theParts(indx).order_lead_time_cleaned,
                                    order_lead_time_defaulted => theParts(indx).order_lead_time_defaulted) ;
                        cnt := cnt + 1 ;
                        insertTimeToRepair (part_no => theParts(indx).part_no, nsi_sid => theParts(indx).nsi_sid,
                               time_to_repair_off_base_cleand => theParts(indx).time_to_repair_off_base_cleand ) ;
                        cnt := cnt + 1 ;                               
                END IF ;
                         
                
             END LOOP ;
         end if ;             
         writeMsg(pTableName => 'tmp_a2a_part_lead_time', pError_location => 630,
            pKey1 => 'processPartLeadTimes',
            pKey2 => 'cnt=' || TO_CHAR(cnt),
            pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
         COMMIT ;       
    END processPartLeadTimes ;
               
     PROCEDURE initA2APartLeadTime(useTestParts IN BOOLEAN := FALSE) IS
                cnt NUMBER := 0 ;
               parts partCur ;
     BEGIN
      writeMsg(pTableName => 'tmp_a2a_part_lead_time', pError_location => 640,
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
      Amd_Partprime_Pkg.DiffPartToPrime  ;
      writeMsg(pTableName => 'tmp_a2a_part_lead_time', pError_location => 650,
            pKey1 => 'initA2APartLeadTime',
            pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
            pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
      COMMIT ;       
     END initA2APartLeadTime ;
     
     FUNCTION getValidRcmInd(rcmInd IN VARCHAR2) RETURN VARCHAR2 IS
     BEGIN
           IF UPPER(rcmInd) = 'T' THEN
               RETURN RCM_REPAIRABLE ; -- repairable
          elsif upper(rcmInd) in ('N','P') then
            return RCM_CONSUMABLE ; -- consumable
          else
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
              pError_location => 660,
              pKey_1 => TO_CHAR(lineNo)) ;
         RAISE ;
     END validateData ;
    
    PROCEDURE insertTimeToRepair(part_no IN AMD_SPARE_PARTS.part_no%TYPE,
              nsi_sid IN AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE,
              time_to_repair_off_base_cleand IN AMD_NATIONAL_STOCK_ITEMS.time_to_repair_off_base_cleand%TYPE) IS
              
        time_to_repair NUMBER ;
        result NUMBER ;
        action_code tmp_a2a_part_lead_time.action_code%type := getActionCode(part_no) ; -- use whatever action_code is in amd_sent_to_a2a for this part
    BEGIN
        BEGIN
          SELECT ansi.time_to_repair_off_base
              INTO time_to_repair
              FROM amd_national_stock_items ansi 
              WHERE prime_part_no = insertTimeToRepair.part_no 
              and action_code <> amd_defaults.GETDELETE_ACTION ;
        EXCEPTION WHEN standard.NO_DATA_FOUND THEN
          NULL ; -- do nothing
          WHEN OTHERS THEN
               ErrorMsg(pSqlfunction => 'select',
                 pTableName => 'amd_part_locs',
                 pError_location => 670,
                 pKey_1 => TO_CHAR(insertTimeToRepair.part_no), pKey_2 => '23') ;
             RAISE ;
         END ;
         
        
    
         IF insertTimeToRepair.time_to_repair_off_base_cleand IS NOT NULL THEN
            time_to_repair := insertTimeToRepair.time_to_repair_off_base_cleand ;
         ELSIF time_to_repair IS NOT NULL THEN
            time_to_repair := time_to_repair ; 
                                                            
         END IF ;
    
         IF (time_to_repair IS not NULL or (time_to_repair is null and action_code = amd_defaults.DELETE_ACTION)) THEN
           -- and amd_utils.IsSpoPrimePart(part_no) THEN         
              insertPartLeadTime(part_no, REPAIR, time_to_repair, action_code) ;
            else
            null;        
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
        result      NUMBER ;
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
           Amd_Preferred_Pkg.getPreferredValue(rec.mtbdr_cleaned, rec.mtbdr_computed, rec.mtbdr),
           getIndenture(smr_code_preferred),
           Amd_Preferred_Pkg.getPreferredValue(rec.unit_cost_cleaned, rec.unit_cost)) ;
    
       IF isPartSent(rec.part_no) THEN  -- part exists in amd_sent_to_a2a with any action_code
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
      
    function tmpA2APartInfoAddOk(part_no in amd_spare_parts.part_no%type) return boolean is
        action_code tmp_a2a_part_info.action_code%type ;  
        cursor thePart is
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
                  nsi.last_update_dt,
                  sp.action_code
              FROM AMD_SPARE_PARTS sp,
                AMD_NATIONAL_STOCK_ITEMS nsi,
                amd_sent_to_a2a sent
              WHERE sp.nsn = nsi.nsn (+)
              and sp.part_no = sent.part_no (+)
              and sp.part_no = tmpA2APartInfoAddOk.part_no ;    
    begin
        for rec in thePart loop
            processPart(rec) ;
        end loop ;
        
        select action_code into tmpA2APartInfoAddOk.action_code  
        from tmp_a2a_part_info 
        where part_no = tmpA2APartInfoAddOk.part_no ;
        
        return true ;
        
    exception when standard.no_data_found then
        return false ;
                 
    end tmpA2APartInfoAddOk ;
    
    function tmpA2AOrderInfoLineAddOk(gold_order_number in amd_on_order.gold_order_number%type, 
        from_dt in amd_on_order.order_date%type := START_DT,
        to_dt in amd_on_order.order_date%type := sysdate) return boolean is
         result number := null ;
         onOrders onOrderCur ;
    begin
        OPEN onOrders FOR 
        SELECT 
          oo.PART_NO,  
          LOC_SID,
                         LINE,          
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
                     and oo.GOLD_ORDER_NUMBER = tmpA2AOrderInfoLineAddOk.gold_order_number
                     and trunc(oo.ORDER_DATE) between trunc(from_dt) and trunc(to_dt)  
         ORDER BY gold_order_number, part_no, order_date ;
         
        processOnOrder(onOrders) ;
        select 1 into result from dual
            where exists (select null 
                          from tmp_a2a_order_info_line infoLine 
                          where infoLine.ORDER_NO = gold_order_number
                          and trunc(infoLine.CREATED_DATE) between trunc(start_dt) and trunc(to_dt) ) ;
        return (result is not null) ;
    exception when standard.no_data_found then
        return false ;
    end tmpA2AOrderInfoLineAddOk ;  

    
    function tmpA2APartInfoAddYorN(part_no in amd_spare_parts.part_no%type) return varchar2 is
    begin
        if tmpA2APartInfoAddOk(part_no) then
            return 'Y' ;
        else
            return 'N' ;
        end if ;
    end tmpA2APartInfoAddYorN ;
    
    function tmpA2ALocPartOverrideAddOk(part_no in amd_location_part_override.part_no%type) return boolean is
        result number null ;
        overrides amd_location_part_override_pkg.locPartOverrideCur ;
    begin
             OPEN overrides FOR
                  SELECT alpo.part_no,
                         spo_location AS site_location,
                        amd_location_part_override_pkg.TSL_OVERRIDE_TYPE AS override_type,
                        case
                            when sent.action_code = amd_defaults.getDELETE_ACTION or alpo.action_code = amd_defaults.getDELETE_ACTION then
                                 0
                            else
                                tsl_override_qty
                        end AS override_quantity,
                        amd_location_part_override_pkg.OVERRIDE_REASON AS override_reason,
                        tsl_override_user,
                        SYSDATE AS begin_date,
                        NULL AS end_date,
                        case sent.action_code
                         when amd_defaults.getDELETE_ACTION then
                               amd_defaults.getDELETE_ACTION -- The part is not longer valid
                         else
                              case alpo.action_code
                                   when amd_defaults.getDELETE_ACTION then
                                         amd_defaults.getUPDATE_ACTION -- the part is still valid, update the current value to zero
                                  else
                                        alpo.action_code
                             end
                        end AS action_code,
                        SYSDATE AS last_update_dt
                 FROM AMD_LOCATION_PART_OVERRIDE alpo, AMD_SPARE_NETWORKS asn, amd_sent_to_a2a sent
                 WHERE alpo.loc_sid = asn.loc_sid
                       AND alpo.part_no = sent.part_no
                       and sent.SPO_PRIME_PART_NO is not null
                       and sent.PART_NO = sent.SPO_PRIME_PART_NO 
                       AND alpo.part_no = tmpA2ALocPartOverrideAddOk.part_no
                union
                select distinct rsp.part_no,
                rsp_location,
                amd_location_part_override_pkg.TSL_OVERRIDE_TYPE as override_type,
                case 
                     when rsp.action_code = amd_defaults.getDELETE_ACTION or sent.action_code = amd_defaults.getDELETE_ACTION then
                           0
                     else
                          rsp_level
                end override_quantity,
                amd_location_part_override_pkg.OVERRIDE_REASON as override_reason,
                Amd_Location_Part_Override_Pkg.GetFirstLogonIdForPart(Amd_Utils.GetNsiSidFromPartNo(rsp.part_no)),
                sysdate as begin_date,
                null as end_date,
                case sent.action_code
                     when amd_defaults.getDELETE_ACTION then
                           amd_defaults.getDELETE_ACTION -- The part is not longer valid
                     else
                          case rsp.action_code
                             when amd_defaults.getDELETE_ACTION then
                                   amd_defaults.getUPDATE_ACTION -- the part is still valid, update the current value to zero
                             else
                                    rsp.action_code
                        end                    
                end AS action_code,
                sysdate as last_update_dt
                from amd_rsp_sum rsp, amd_sent_to_a2a sent, amd_spare_networks nwks
                where rsp.part_no = sent.part_no
                and sent.part_no = sent.spo_prime_part_no
                and sent.SPO_PRIME_PART_NO is not null
                and rsp.part_no in (select part_no from amd_test_parts)
                and substr(rsp_location,1,length(rsp_location) - 4) = nwks.mob
                and nwks.mob is not null 
                and rsp.part_no = tmpA2ALocPartOverrideAddOk.part_no ;
                
        amd_location_part_override_pkg.processLocPartOverride(overrides) ;
        
                                                    
        select 1 into result from dual
        where exists (select null 
                      from tmp_a2a_loc_part_override 
                      where part_no = tmpA2ALocPartOverrideAddOk.part_no) ;
        
        return result is not null ;
    exception when standard.no_data_found then
        return false ; 
    end tmpA2ALocPartOverrideAddOk ;
 
     
     PROCEDURE processParts(parts IN partCur) IS
                rec partInfoRec ;
               cnt NUMBER := 0 ;
               ins_cnt number := 0 ;
               upd_cnt number := 0 ;
               del_cnt number := 0 ;
               theParts partTab ;
     BEGIN
          writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 680,
            pKey1 => 'processParts',
            pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;       
          
          fetch parts bulk collect into theParts ;
          close parts ;

          if theParts.first is not null then          
              for indx in theParts.first .. theParts.last 
              LOOP
                  case theParts(indx).action_code
                         when amd_defaults.INSERT_ACTION then
                               ins_cnt := ins_cnt + 1 ;
                       when amd_defaults.UPDATE_ACTION then
                               upd_cnt := upd_cnt + 1 ;
                       when amd_defaults.DELETE_ACTION then
                               del_cnt := del_cnt + 1 ;
                  end case ;        
                  processPart(theParts(indx)) ;
                  cnt := cnt + 1 ;
              END LOOP ;
          end if ;              
          writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 690,
            pKey1 => 'processParts',
            pKey2 => 'cnt=' || TO_CHAR(cnt),
            pKey3 => 'del_cnt=' || to_char(del_cnt),
            pKey4 => 'ins_cnt=' || to_char(ins_cnt),
            pData => 'upd_cnt=' || to_char(upd_cnt),
            pComments => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;       
          COMMIT ;
          
     END processParts ;
     
     -- allow for collecting data by last_update_dt
     PROCEDURE initA2APartInfo(from_dt IN DATE := START_DT, to_dt IN DATE := SYSDATE) IS
     
                preferred_smr_code  AMD_NATIONAL_STOCK_ITEMS.smr_code%TYPE ;
               rcm_ind                TMP_A2A_PART_INFO.rcm_ind%TYPE ;
               indenture            TMP_A2A_PART_INFO.indenture%TYPE ;
               preferred_unit_cost TMP_A2A_PART_INFO.price%TYPE ;
               nsn_fsc                TMP_A2A_PART_INFO.nsn_fsc%TYPE ;
               nsn_niin            TMP_A2A_PART_INFO.nsn_niin%TYPE ;
               cnt                   NUMBER := 0 ;
               parts               partCur ;
               
     BEGIN
          writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 700,
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
                  nsi.mtbdr_computed,
                  nsi.smr_code,
                  nsi.smr_code_cleaned,
                  nsi.smr_code_defaulted,
                  nsi.nsi_sid,
                  nsi.TIME_TO_REPAIR_OFF_BASE_CLEAND,
                  CASE 
                  WHEN TRUNC(sp.last_update_dt) >= TRUNC(nsi.last_update_dt) THEN 
                         sp.last_update_dt
                  ELSE
                      nsi.LAST_UPDATE_DT
                  END AS last_update_dt,
                  CASE 
                     when sent.action_code is not null then
                               sent.action_code
                     WHEN sp.action_code = nsi.action_code THEN 
                         sp.action_code
                     ELSE
                        CASE 
                            WHEN sp.action_code = amd_defaults.getDELETE_ACTION OR nsi.action_code = amd_defaults.getDELETE_ACTION then
                                 amd_defaults.getDELETE_ACTION
                            WHEN sp.action_code = amd_defaults.getUPDATE_ACTION OR nsi.action_code = amd_defaults.getUPDATE_ACTION then
                                 amd_defaults.getUPDATE_ACTION                        
                            ELSE
                                amd_defaults.getINSERT_ACTION
                        END
                END AS action_code
              FROM AMD_SPARE_PARTS sp,
                AMD_NATIONAL_STOCK_ITEMS nsi,
                amd_sent_to_a2a sent
              WHERE sp.nsn = nsi.nsn (+)
                   and sp.part_no = sent.part_no (+)  
                 AND (TRUNC(sp.last_update_dt) BETWEEN TRUNC(from_dt) AND TRUNC(to_dt) 
                      OR TRUNC(nsi.last_update_dt) BETWEEN TRUNC(from_dt) AND TRUNC(to_dt) ) ;
                       
          processParts(parts) ;
          
          writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 710,
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
      writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 720,
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
    
      writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 730,
            pKey1 => 'initA2APartInfo',
            pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
            pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
      COMMIT ;       
      RETURN result ;
    
     END initA2APartInfo ;
     
     PROCEDURE deletePartInfo(partInfo IN part2DeleteCur) IS
                rec part2Delete ;
               cnt NUMBER := 0 ;           
               parts2Delete part2DeleteTab ; 
               
                PROCEDURE processPart(rec IN part2Delete) IS
                            result NUMBER ;
               BEGIN
                          result := A2a_Pkg.DeletePartInfo(rec.part_no, rec.nomenclature) ;
               END processPart ;
     BEGIN
            writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 740,
            pKey1 => 'deletePartInfo',
            pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
           fetch partInfo bulk collect into parts2Delete ;
           close partInfo ;
           
           if parts2Delete is null then
               for indx in parts2Delete.first .. parts2Delete.last
               LOOP
                  processPart(parts2Delete(indx)) ;
                  cnt := cnt + 1 ;
              END LOOP ;
            end if ;              
            writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 750,
            pKey1 => 'deletePartInfo',
            pKey2 => 'cnt=' || TO_CHAR(cnt),
            pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
          COMMIT ;
     END deletePartInfo ;
     
     PROCEDURE deletePartInfo(useTestParts IN BOOLEAN := FALSE) IS
         parts part2DeleteCur ;
        
        procedure getTestData is
        begin
          writeMsg(pTableName => 'amd_spare_parts', pError_location => 760,
          pKey1 => 'getTestData' ) ;
          commit ;
            OPEN parts FOR 
               SELECT part_no, nomenclature FROM AMD_SPARE_PARTS
               WHERE part_no IN (SELECT part_no FROM AMD_TEST_PARTS) 
               AND action_code != Amd_Defaults.DELETE_ACTION ;
        end getTestData ;
        
        procedure getAllData is
        begin
          writeMsg(pTableName => 'amd_spare_parts', pError_location => 770,
          pKey1 => 'getAllData' ) ;
          commit ;
          OPEN parts FOR     
               SELECT part_no, nomenclature FROM AMD_SPARE_PARTS WHERE action_code != Amd_Defaults.DELETE_ACTION ;
        end getAllData ;
            
     BEGIN
      writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 780,
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
      writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 790,
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
             pError_location => 800,
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
             pError_location => 810,
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
     
      -- added 4/12/2007 by dse
      function isPartActive(part_no in amd_sent_to_a2a.part_no%type) return boolean is
        action_code amd_sent_to_a2a.action_code%type ;
      begin
        select action_code into isPartActive.action_code 
        from amd_sent_to_a2a
        where part_no = isPartActive.part_no ;
        return (action_code <> amd_defaults.DELETE_ACTION) ;
      exception when standard.no_data_found then
        return false ; 
      end isPartActive ;
      -- added 4/12/2007 by dse
      function isPartActiveYorN(part_no in amd_sent_to_a2a.part_no%type) return varchar2 is
      begin
        if isPartActive(part_no) then
            return 'Y' ;
        else
            return 'N' ;
        end if ;
      end isPartActiveYorN ;
      
      -- added 4/12/2007 by dse
      function isSpoPrimePartActive(spo_prime_part_no in amd_sent_to_a2a.spo_prime_part_no%type) return boolean is
        action_code amd_sent_to_a2a.action_code%type ;
      begin
        select action_code into isSpoPrimePartActive.action_code
        from amd_sent_to_a2a
        where spo_prime_part_no = isSpoPrimePartActive.spo_prime_part_no
        and part_no = spo_prime_part_no
        and action_code <> amd_defaults.DELETE_ACTION ;
        
        return true ;
        
      exception when standard.no_data_found then
        return false ;
      end isSpoPrimePartActive ;
      -- added 4/12/2007 by dse
      function isSpoPrimePartActiveYorN(spo_prime_part_no in amd_sent_to_a2a.spo_prime_part_no%type) return varchar2 is
      begin
        if isSpoPrimePartActive(spo_prime_part_no) then
            return 'Y' ;
        else
            return 'N' ;
        end if ;
      end isSpoPrimePartActiveYorN ;
    
      -- added 4/12/2007 by dse
      function getSentToA2AActionCode(part_no in amd_sent_to_a2a.part_no%type) return varchar2 is
        action_code amd_sent_to_a2a.action_code%type ;
      begin
        select action_code into getSentToA2AActionCode.action_code
        from amd_sent_to_a2a
        where part_no = getSentToA2AActionCode.part_no ;
        return action_code ;
      exception when standard.no_data_found then
        return amd_defaults.DELETE_ACTION ; -- part & associated data should be deleted from SPO  
      end getSentToA2AActionCode ;

      
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
                 pError_location => 820,
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
        mtbdr_computed AMD_NATIONAL_STOCK_ITEMS.mtbdr_computed%TYPE ;        
        plannerCode AMD_NATIONAL_STOCK_ITEMS.planner_code%TYPE ;
        part_no AMD_SPARE_PARTS.part_no%TYPE ;
        plannerCodeCleaned AMD_NATIONAL_STOCK_ITEMS.planner_code_cleaned%TYPE ;
     BEGIN
       debugMsg(msg => 'isPartValid(' || partNo || ')', pError_location => 830) ;
       <<doesPartExist>>
       BEGIN
            SELECT part_no INTO isPartValid.part_no FROM AMD_SPARE_PARTS 
            WHERE partNo = part_no AND action_code != Amd_Defaults.DELETE_ACTION ;
       EXCEPTION
               WHEN standard.NO_DATA_FOUND THEN
                 IF mDebug THEN
                     debugMsg(partNo || ' does not exist in amd_spare_parts or has been logically deleted.', pError_location => 840) ; 
                 END IF ;
                 RETURN FALSE ;
       END doesPartExist ;
       
       if amd_utils.isPartConsumable(partNo) then
            return a2a_consumables_pkg.isPartValid(partNo) ;
       end if ;
                   
       <<getPrimePartData>>
       BEGIN
        SELECT smr_code, smr_code_cleaned, mtbdr, mtbdr_cleaned, mtbdr_computed, planner_code, planner_code_cleaned 
        INTO smrCode, smrCodeCleaned, mtbdr, mtbdr_cleaned, mtbdr_computed, plannerCode, plannerCodeCleaned
        FROM AMD_NATIONAL_STOCK_ITEMS items, AMD_NSI_PARTS parts
        WHERE isPartValid.partNo = parts.part_no
        AND parts.UNASSIGNMENT_DATE IS NULL
        AND parts.nsi_sid = items.nsi_sid ;
       EXCEPTION
         WHEN standard.NO_DATA_FOUND THEN
           IF mDebug THEN
                 debugMsg(partNo || ' is NOT valid amd_nsi_parts.UNASSIGNMENT_DATE is not be NULL', pError_location => 850) ;
           END IF ;
           RETURN FALSE ;
         WHEN OTHERS THEN
             ErrorMsg(pSqlfunction => 'select',
              pTableName => 'items / parts',
              pError_location => 860,
              pKey_1 => isPartValid.partNo) ;
             RAISE ;
       END getPrimePartData ;
       RETURN isPartValid(partNo => partNo, preferredSmrCode => Amd_Preferred_Pkg.getPreferredValue(smrCodeCleaned,smrCode), 
        preferredMtbdr => Amd_Preferred_Pkg.getPreferredValue(mtbdr_cleaned,mtbdr_computed, mtbdr), 
        preferredPlannerCode => Amd_Preferred_Pkg.GetPreferredValue(plannerCodeCleaned,plannerCode), showReason => showReason) ;
        
     END isPartValid ;
    
     FUNCTION createPartInfo(part_no IN VARCHAR2,
            action_code IN VARCHAR2 := Amd_Defaults.UPDATE_ACTION) RETURN NUMBER IS
     BEGIN
        if tmpA2APartInfoAddOK(part_no) then
            return SUCCESS ;
        end if ;
        return FAILURE ; 
     END createPartInfo  ;
    
     procedure insertTmpA2APartInfo(mfgr in tmp_a2a_part_info.cage_code%type,
        part_no in tmp_a2a_part_info.part_no%type, unit_issue in tmp_a2a_part_info.unit_issue%type,
        nomenclature in amd_spare_parts.nomenclature%type, rcm_ind in tmp_a2a_part_info.rcm_ind%type, 
        nsn in amd_national_stock_items.nsn%type, planner_code in amd_national_stock_items.planner_code%type,
        mtbdr in tmp_a2a_part_info.mtbf%type, preferred_smrcode in tmp_a2a_part_info.preferred_smrcode%type, 
        indenture in tmp_a2a_part_info.indenture%type,
        action_code in tmp_a2a_part_info.action_code%type, price in tmp_a2a_part_info.price%type) is
        
        procedure doUpdate is
        begin
        
            update tmp_a2a_part_info
            set cage_code = mfgr, unit_issue = insertTmpA2APartInfo.unit_issue,
            noun = nomenclature, rcm_ind = insertTmpA2APartInfo.rcm_ind,
            nsn_fsc = SUBSTR(nsn, 1, 4), nsn_niin = SUBSTR(nsn, 5, 9), resp_asset_mgr = planner_code,
            third_party_flag = a2a_pkg.THIRD_PARTY_FLAG,
            mtbf = mtbdr, preferred_smrcode = insertTmpA2APartInfo.preferred_smrcode,
            indenture = insertTmpA2APartInfo.indenture, action_code = insertTmpA2APartInfo.action_code,
            last_update_dt = sysdate, price = insertTmpA2APartInfo.price 
            where part_no = insertTmpA2APartInfo.part_no ;
            
        exception when others then            
            ErrorMsg(pSqlfunction => 'update',
               pTableName => 'tmp_a2a_part_info',
               pError_location => 862,
               pKey_1 => insertTmpA2APartInfo.part_no) ;
            raise ;            
        end doUpdate ;
        
     begin
       INSERT INTO TMP_A2A_PART_INFO (cage_code, part_no, unit_issue, noun, rcm_ind, nsn_fsc, nsn_niin, 
         resp_asset_mgr, third_party_flag, mtbf, preferred_smrcode, indenture, action_code, 
         last_update_dt, price)
       VALUES (mfgr, part_no, unit_issue, nomenclature, rcm_ind, SUBSTR(nsn, 1, 4), SUBSTR(nsn, 5, 9),
         planner_code, THIRD_PARTY_FLAG, mtbdr, preferred_smrcode, indenture, action_code, 
         SYSDATE, price) ;
                 
     exception 
        when standard.dup_val_on_index then
            doUpdate ;          
     end insertTmpA2APartInfo ;
     
     
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
       if amd_utils.isPartConsumable(part_no) then
	         a2a_consumables_pkg.insertPartInfo(amd_defaults.INSERT_ACTION, part_no, nomenclature,
                mfgr,  unit_issue, smr_code, nsn, planner_code, THIRD_PARTY_FLAG, mtbdr, price) ;
            return SUCCESS ;
       end if ;
       
       validateData ( mfgr, part_no, unit_issue, nomenclature, smr_code, nsn, planner_code, 
            third_party_flag, mtbdr, indenture, rcm_ind) ;
           
       IF isPartValid(partNo => part_no, preferredSmrCode => smr_code, 
            preferredMtbdr => mtbdr, preferredPlannerCode => planner_code) THEN

            insertTmpA2APartInfo(mfgr => mfgr, part_no => part_no, 
                unit_issue => unit_issue, nomenclature => nomenclature, rcm_ind => rcm_ind, 
                nsn => nsn, planner_code => plannerCode, mtbdr => mtbdr, preferred_smrcode => smr_code,
                indenture => indenture, action_code => amd_defaults.INSERT_ACTION, price => price) ;
                
      ELSE
            result := A2a_Pkg.DeletePartInfo(part_no, nomenclature) ;
    
      end if ;
    
      return SUCCESS ;
      
     exception
         when others then
           errorMsg(pSqlfunction => 'insert', pTableName => 'tmp_a2a_part_info', pError_location => 870,
              pKey_1 => part_no, pKey_2 => mfgr, pKey_3 => nomenclature, pKey_4 => nsn) ;
              
           raise ;
    
     end insertPartInfo ;
    
    
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
      lineNo number := 0 ;
      
     begin
        mArgs := 'UpdatePartInfo(' || mfgr || ', ' || part_no || ', ' || unit_issue || ', '
        || nomenclature || ', ' || smr_code || ', ' || nsn || ', ' || planner_code
        || ', ' || third_party_flag || ', ' || mtbdr || ', ' || indenture ||')' ;
        
        if amd_utils.ispartConsumable(part_no) then
            lineNo := 1 ;
	        a2a_consumables_pkg.insertPartInfo(amd_defaults.UPDATE_ACTION, part_no, nomenclature,
                mfgr, unit_issue, smr_code, nsn, planner_code, THIRD_PARTY_FLAG, mtbdr, price) ;
                
            return SUCCESS ;
            
        end if ;
     
   
       validateData (mfgr,part_no,unit_issue,nomenclature,smr_code,nsn,planner_code, third_party_flag,
           mtbdr, indenture, rcm_ind) ;
           
        if isPartValid(partNo => part_no, preferredSmrCode => smr_code, 
            preferredMtbdr => mtbdr, preferredPlannerCode => planner_code) THEN
            
            insertTmpA2APartInfo(mfgr => mfgr, part_no => part_no, 
                unit_issue => unit_issue, nomenclature => nomenclature, rcm_ind => rcm_ind, 
                nsn => nsn, planner_code => planner_code, mtbdr => mtbdr, preferred_smrcode => smr_code,
                indenture => indenture, action_code => amd_defaults.UPDATE_ACTION, price => price) ;

        else
        
            result := A2a_Pkg.DeletePartInfo(part_no, nomenclature) ;
                
        end if ;
      
      return SUCCESS ;
      
     exception
         when others then
            errorMsg(pSqlfunction => 'update', pTableName => 'tmp_a2a_part_info', pError_location => 890, 
                pKey_1 => part_no, pKey_2 => mfgr,  pKey_3 => nomenclature, pKey_4 => nsn) ;
                
            raise ;
                
     end updatePartInfo;
    
     function deletePartInfo(
           part_no IN VARCHAR2, nomenclature IN VARCHAR2) RETURN NUMBER IS
      result NUMBER ;
      PROCEDURE makeA2AdeletePartInfo IS
      BEGIN
        debugMsg(msg => 'makeA2AdeletePartInfo', pError_location => 900) ;
        UPDATE TMP_A2A_PART_INFO
        SET noun = DeletePartInfo.nomenclature,
        action_code = Amd_Defaults.DELETE_ACTION,
        last_update_dt = SYSDATE
        WHERE part_no = DeletePartInfo.part_no ;
    
      EXCEPTION WHEN OTHERS THEN
          ErrorMsg(pSqlfunction => 'delete',
          pTableName => 'tmp_a2a_part_info',
          pError_location => 910,
          pKey_1 => part_no) ;
       RAISE ;
    
      END makeA2AdeletePartInfo ;
    
     BEGIN
       if amd_utils.isPartConsumable(part_no) then
	        a2a_consumables_pkg.insertPartInfo(amd_defaults.INSERT_ACTION, part_no, nomenclature,
                mfgr => null,  unit_issue => null, smr_code => null, nsn => null, planner_code => null, 
                THIRD_PARTY_FLAG => null, mtbdr => null, price => null) ;
            return SUCCESS ;
       end if ;
       mArgs := 'DeletePartInfo(' || part_no || ', ' || nomenclature || ')' ;
       writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 920,
        pKey1 => part_no,
        pKey2 => nomenclature,
        pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;       
       -- mblnSendAllData allows parts to be deleted even if they have been deleted previously.  This
       -- allows the system to send all types of A2A transactions when the initPartInfoA2A is executed
       if isPartSent(part_no) and not isDataSysPartMarkedDeleted(part_no)  then 
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
           writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 930,
            pKey1 => part_no,
            pKey2 => nomenclature,
            pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;       
       END IF ;
       RETURN SUCCESS ;
     EXCEPTION
      WHEN standard.DUP_VAL_ON_INDEX THEN
        makeA2AdeletePartInfo ;
        RETURN SUCCESS ;
    
      WHEN OTHERS THEN
       ErrorMsg(pSqlfunction => 'delete',
          pTableName => 'tmp_a2a_part_info',
          pError_location => 940,
          pKey_1 => part_no) ;
       RAISE ;
    
     END DeletePartInfo ;
    
    
     procedure doTmpA2APartLeadTimeInsert(part_no in varchar2, lead_time_type in varchar2, lead_time in number,
        action_code in varchar2) IS
        
        cage_code TMP_A2A_PART_LEAD_TIME.cage_code%TYPE := Amd_Utils.getCageCode(part_no) ;
        
        procedure doUpdate is
        begin
           UPDATE TMP_A2A_PART_LEAD_TIME
           SET lead_time = doTmpA2APartLeadTimeInsert.lead_time,
           action_code = doTmpA2APartLeadTimeInsert.action_code,
           last_update_dt = SYSDATE,
           cage_code = doTmpA2APartLeadTimeInsert.cage_code
           WHERE part_no = doTmpA2APartLeadTimeInsert.part_no
           AND lead_time_type = doTmpA2APartLeadTimeInsert.lead_time_type ;
        
         EXCEPTION WHEN OTHERS THEN
            ErrorMsg(pSqlfunction => 'update',
               pTableName => 'tmp_a2a_part_lead_time',
               pError_location => 950,
               pKey_1 => part_no,
               pKey_2 => lead_time_type,
               pKey_3 => lead_time,
               pKey_4 => cage_code) ;
           RAISE ;
        end ;
                   
     begin
       IF 
            (
                  ( 
                   action_code = amd_defaults.DELETE_ACTION
                    and ( 
                          ( amd_utils.isPartRepairable(part_no) or amd_utils.isPartConsumable(part_no) ) 
                            and isPartSent(part_no)
                        )
                  )
                               
               or
               
                 (  
                   (    ( amd_utils.isPartRepairable(part_no) and isPartValid(part_no) ) 
                     or ( amd_utils.isPartConsumable(part_no) and a2a_consumables_pkg.isPartValid(part_no) ) 
                   ) 
                   AND wasPartSent(part_no)
                   
                 )
             )  
        THEN
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
                doTmpA2APartLeadTimeInsert.part_no,
                doTmpA2APartLeadTimeInsert.cage_code,
                doTmpA2APartLeadTimeInsert.lead_time_type,
                doTmpA2APartLeadTimeInsert.lead_time,
                doTmpA2APartLeadTimeInsert.action_code,
                SYSDATE
            ) ;
       END IF ;
       
     EXCEPTION
      WHEN standard.DUP_VAL_ON_INDEX THEN
            doUpdate ;
    
      WHEN OTHERS THEN
           ErrorMsg(pSqlfunction => 'insert',
              pTableName => 'tmp_a2a_part_lead_time',
              pError_location => 970,
              pKey_1 => part_no,
              pKey_2 => lead_time_type,
              pKey_3 => lead_time,
              pKey_4 => cage_code) ;
           RAISE ;
     end doTmpA2APartLeadTimeInsert ;
         
     function insertPartLeadTime(
           part_no in varchar2,
           lead_time_type in varchar2,
           lead_time in number) return number is
           
          result number ;
          
          procedure validateData IS
          
            lineNo number := 0 ;
            rec tmp_a2a_part_lead_time%rowtype ;
          begin
                 lineNo := lineNo + 1;rec.part_no := part_no ;
                 lineNo := lineNo + 1;rec.lead_time_type := lead_time_type ;
                 lineNo := lineNo + 1;rec.lead_time := lead_time ;
          exception when others then
               errorMsg(       
                 pSqlfunction => ':=',
                 pTableName => 'tmp_a2a_part_lead_time',
                 pError_location => 960,
                 pKey_1 => to_char(lineNo)) ;
             raise ;
          end validateData ;
          
     BEGIN
       mArgs := 'insertPartLeadTime(' || part_no || ', ' || lead_time_type || ', ' || lead_time || ')' ;
       
       validateData ;
       if lead_time > 0 then
           doTmpA2APartLeadTimeInsert(part_no => part_no, lead_time_type => lead_time_type, lead_time => lead_time,
                action_code => amd_defaults.INSERT_ACTION ) ;
       end if ;                
             
       return SUCCESS ;    
    
     End insertPartLeadTime ;
    
     function updatePartLeadTime(
            part_no in varchar2,
           lead_time_type in varchar2,
           lead_time in number) return number is
           
     begin
       mArgs := 'UpdatePartLeadTime(' || part_no || ', ' || lead_time_type || ', ' || lead_time || ')' ;
       
       if lead_time > 0 then
           doTmpA2APartLeadTimeInsert(part_no => part_no, lead_time_type => lead_time_type, lead_time => lead_time,
                action_code => amd_defaults.UPDATE_ACTION) ;
        end if ;                
            
       return SUCCESS ;
    
     end updatePartLeadTime ;
    
    
     FUNCTION deletePartLeadTime(
            part_no IN VARCHAR2) RETURN NUMBER IS
    
       rc NUMBER ;
       cage_code TMP_A2A_PART_LEAD_TIME.cage_code%TYPE := Amd_Utils.getCageCode(part_no) ;
    
    
     BEGIN
       mArgs := 'DeletePartLeadTime(' || part_no || ')' ;
       doTmpA2APartLeadTimeInsert(part_no => part_no, lead_time_type => REPAIR, lead_time => 0, 
         action_code => amd_defaults.DELETE_ACTION) ;
        
       return SUCCESS ;
    
    
     end deletePartLeadTime ;
    
    
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
          pError_location => 1010,
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
          pError_location => 1020,
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
          pError_location => 1030,
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
          pError_location => 1040,
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
          pError_location => 1050,
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
          pError_location => 1060,
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
          pError_location => 1070,
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
          pError_location => 1080,
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
          pError_location => 1090,
          pKey_1 => part_no,
          pKey_2 => loc_sid,
          pKey_3 => location_name );
    
       RAISE ;
    
      END makeDelete ;
     BEGIN
          mArgs := 'DeleteLocPartLeadTime(' || part_no || ', ' || loc_sid || ', ' || location_name || ')' ;
       IF isPartSent(part_no) THEN  -- part exists in amd_sent_to_a2a with any action_code
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
         pError_location => 1100,
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
              insertTmpA2ASpoUsers(rec.bems_id, rec.stable_email, rec.last_name, rec.first_Name, rec.action_code) ;
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
       writeMsg(pTableName => 'tmp_a2a_site_resp_asset_mgr', pError_location => 1110,
        pKey1 => 'initSiteRespAssetMgr',
        pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;       
       Mta_Truncate_Table('tmp_a2a_site_resp_asset_mgr','reuse storage');
       FOR rec IN managers LOOP
         cnt := cnt + 1 ;
         insertSiteRespAssetMgr(assetMgr => rec.planner_code, logonId => rec.logon_id, action_code => rec.action_code,
                                          data_source => rec.data_source) ;
       END LOOP ;
       /*
       for rec in managersNoUser loop
            cntNoUser := cntNoUser + 1 ;
         insertSiteRespAssetMgr(assetMgr => rec.planner_code, logonId => rec.logon_id, action_code => Amd_Defaults.INSERT_ACTION,
                                          data_source => rec.data_source) ;
       end loop ;
       */
       writeMsg(pTableName => 'tmp_a2a_site_resp_asset_mgr', pError_location => 1120,
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
               ErrorMsg( pSqlfunction => 'update', pTableName => 'tmp_a2a_site_resp_asset_mgr', pError_location => 1130,
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
           ErrorMsg( pSqlfunction => 'insert', pTableName => 'tmp_a2a_site_resp_asset_mgr', pError_location => 1140,
             pkey_1 => assetMgr, pKey_2 => logonId, pKey_3 => data_source) ;
           RAISE ;
          END insertTmpA2ASiteRespAssetMgr ;
    
     EXCEPTION WHEN OTHERS THEN
        ErrorMsg( pSqlfunction => 'insert', pTableName => 'tmp_a2a_site_resp_asset_mgr', pError_location => 1150,
          pkey_1 => assetMgr, pKey_2 => logonId, pKey_3 => data_source ) ;
        raise ;
     END insertSiteRespAssetMgr ;
    
    
     PROCEDURE insertInvInfo(part_no IN TMP_A2A_INV_INFO.part_no%TYPE,
        spo_location IN TMP_A2A_INV_INFO.site_location%TYPE ,
        qty_on_hand IN TMP_A2A_INV_INFO.QTY_ON_HAND%TYPE,
        action_code IN TMP_A2A_INV_INFO.action_code%TYPE)  IS
        
         PROCEDURE doUpdate is
          BEGIN
            UPDATE TMP_A2A_INV_INFO
            SET qty_on_hand = insertInvInfo.qty_on_hand,
            action_code = insertInvInfo.action_code,
            last_update_dt = SYSDATE
            WHERE part_no = insertInvInfo.part_no
            AND site_location = insertInvInfo.spo_location ;
            updateCnt := updateCnt + 1 ;
          EXCEPTION WHEN OTHERS THEN
            ErrorMsg( pSqlfunction => 'select', pTableName => 'tmp_a2a_inv_info', pError_location => 1160,
              pkey_1 => part_no, pKey_2 => spo_location) ;
            RAISE ;
        
         END doUpdate ;

        procedure insertRow is
        begin
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
        EXCEPTION
           WHEN standard.DUP_VAL_ON_INDEX THEN
                doUpdate ;
           WHEN OTHERS THEN
             ErrorMsg( pSqlfunction => 'insert', pTableName => 'tmp_a2a_inv_info', pError_location => 1170,
               pkey_1 => part_no, pKey_2 => spo_location) ;
             RAISE ;
        end insertRow ;

     BEGIN
        if insertInvInfo.action_code = amd_defaults.INSERT_ACTION
        or insertInvInfo.action_code = amd_defaults.UPDATE_ACTION then
              
            IF wasPartSent(insertInvInfo.part_no) -- does the part exist in amd_sent_to_a2a with an action_code <> DELETE_ACTION
            AND spo_location IS NOT NULL THEN                         
                insertRow ;
                insertCnt := insertCnt + 1 ;
            else
                rejectCnt := rejectCnt + 1 ;                                                                       
            END IF ;
        else
            if isPartSent(insertInvInfo.part_no) then -- does the part exist in amd_sent_to_a2a with any action_code
                      
                insertRow ;
                deleteCnt := deleteCnt + 1 ;
            else
                rejectCnt := rejectCnt + 1 ;                
                         
            end if ;
        end if ;
        
     END insertInvInfo ;
    
    
    PROCEDURE insertRepairInvInfo(part_no IN TMP_A2A_REPAIR_INV_INFO.part_no%TYPE,
        site_location IN TMP_A2A_REPAIR_INV_INFO.site_location%TYPE,
        inv_qty IN TMP_A2A_REPAIR_INV_INFO.QTY_ON_HAND%TYPE,
        action_code IN TMP_A2A_REPAIR_INV_INFO.action_code%TYPE)  IS
        
        procedure doUpdate is
        begin
            update TMP_A2A_REPAIR_INV_INFO
            set qty_on_hand = insertRepairInvInfo.inv_qty,
            action_code = insertRepairInvInfo.action_code,
            last_update_dt = sysdate
            where part_no = insertRepairInvInfo.part_no
            and site_location = insertRepairInvInfo.site_location ;
            updateCnt := updateCnt + 1 ;
        exception when others then            
            ErrorMsg(pSqlfunction => 'update',
               pTableName => 'tmp_a2a_repair_inv_info',
               pError_location => 1174,
               pKey_1 => insertRepairInvInfo.part_no,
               pKey_2 => insertRepairInvInfo.site_location ) ;
            raise ;            
        end doUpdate ;
        
        procedure insertRow is
        begin
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
        EXCEPTION
          WHEN standard.DUP_VAL_ON_INDEX THEN
                doUpdate ;
          WHEN OTHERS THEN
             ErrorMsg( pSqlfunction => 'insert', pTableName => 'tmp_a2a_repair_inv_info', pError_location => 1180,
               pkey_1 => part_no, pKey_2 => site_location) ;
             RAISE ;
        end insertRow ;
    
     BEGIN
        if action_code = amd_defaults.INSERT_ACTION 
        or action_code = amd_defaults.UPDATE_ACTION then
        
            IF wasPartSent(insertRepairInvInfo.part_no) -- must be in amd_sent_to_a2a with action_code <> D
            AND site_location IS NOT NULL THEN
                insertRow ;
                insertCnt := insertCnt + 1 ;                
            else
                rejectCnt := rejectCnt + 1 ;
                if debug then
                    begin
                        dbms_output.put_line('part ' || part_no 
                            || ' not inserted - wasPartSent=' 
                            || wasPartSentYorN(part_no) 
                            || ' site_location=' || nvl(site_location,'null')
                            || ' action_code=' || action_code) ;
                    exception when others then
                        debug := false ;                        
                    end ;                        
                end if ;                           
            END IF ;
            
        else
            if isPartSent(insertRepairInvInfo.part_no)
            and site_location is not null then -- must be in amd_sent_to_a2a - ignores action_code
                insertRow ;
                deleteCnt := deleteCnt + 1 ;
            else
                rejectCnt := rejectCnt + 1 ;
                if debug then
                    begin
                        dbms_output.put_line('part ' || part_no 
                            || ' not inserted - isPartSent=' 
                            || isPartSentYorN(part_no) 
                            || ' site_location=' || nvl(site_location,'null')
                            || ' action_code=' || action_code) ;
                    exception when others then
                        debug := false ;                        
                    end ;                        
                end if ;                                                  
            end if ;
        end if ;    
    
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
        errormsg( psqlfunction => 'select', ptablename => 'amd_national_stock_items', pError_location => 1190,
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
          errormsg( psqlfunction => 'select', ptablename => 'amd_part_locs', pError_location => 1200,
            pkey_1 => part_no, pkey_2 => loc_sid) ;
        RAISE ;
    
      END execSelectTimeToRepair ;
    
      RETURN time_to_repair ;
    
     END getTimeToRepair ;
     
     procedure setDebugRepairInfoThreshold(value in number) is
     begin
        debugRepairInfoThreshold := value ;
     end setDebugRepairInfoThreshold ;
    
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
         errormsg( psqlfunction => 'update', ptablename => 'tmp_a2a_repair_info', pError_location => 1210,
           pkey_1 => part_no, pkey_2 => loc_sid, pkey_3 => doc_no, pkey_4 => TO_CHAR(repair_date,'MM/DD/YYYY'),pKeywordValuePairs => 'status=' || status || '  qty=' || quantity || ' action=' || action_code) ;
         RAISE ;
      END doUpdate ;
      
      procedure insertRow is
      begin
            insertRowCnt := insertRowCnt + 1 ;
            if debug and mod(insertRowCnt,debugThreshold) = 0 then
                dbms_output.put_line('1. part_no=' || part_no || ' loc_sid=' || loc_sid || ' action_code = ' || action_code) ;
            end if ;                
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
      EXCEPTION
           WHEN standard.DUP_VAL_ON_INDEX THEN
               doUpdate ;
           WHEN OTHERS THEN
             errormsg( psqlfunction => 'insert', ptablename => 'tmp_a2a_repair_info', pError_location => 1220,
         pkey_1 => part_no, pkey_2 => loc_sid, pkey_3 => doc_no, pkey_4 => TO_CHAR(repair_date,'MM/DD/YYYY'),pKeywordValuePairs => 'status=' || status || '  qty=' || quantity || ' action=' || action_code) ;
             RAISE ;
      end insertRow ;
    
      BEGIN
       insertCnt := insertCnt + 1 ;
       
       if debug and mod(insertCnt,debugRepairInfoThreshold) = 0 then
            dbms_output.put_line('2. insertRepairInfo ' || part_no || ' ' || action_code) ;
       end if ;
                   
       if insertRepairInfo.action_code = amd_defaults.INSERT_ACTION 
       or insertRepairInfo.action_code = amd_defaults.UPDATE_ACTION then       
           insertAddUpdRepairInfoCnt := insertAddUpdRepairInfoCnt + 1 ;
            if debug  then
                dbms_output.put_line('1.5. part_no=' || part_no || ' loc_sid=' || loc_sid || ' action_code = ' || action_code) ;
            end if ;                
           -- added isPartValid test DSE 11/30/05
           IF isPartValid(insertRepairInfo.part_no) 
              AND wasPartSent(insertRepairInfo.part_no) -- must exist in amd_sent_to_a2a with action_code <> DELETE_ACTION
              AND doc_no NOT LIKE 'R%'  
              AND doc_no NOT LIKE 'II%'
              AND site_location IS NOT NULL 
           THEN
                  insertRow ;
           END IF ;
     else
          deleteCnt := deleteCnt + 1 ;
          if debug and mod(deleteCnt,debugDeleteThreshold) = 0 then
            dbms_output.put_line('3. site_location = ' || site_location || ' loc_sid = ' || loc_sid) ;          
          end if ;
          if isPartSent(insertRepairInfo.part_no) 
             and site_location is not null then -- i.e. it exists in amd_sent_to_a2a - ignore action_code
             insertRow ;
         end if ;
     end if ;
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
    
     FUNCTION includeOrderYorN(gold_order_number IN AMD_ON_ORDER.gold_order_number%TYPE, 
                             order_date IN AMD_ON_ORDER.order_date%TYPE,
                          part_no in amd_on_order.part_no%type) RETURN Varchar2 is
     begin
        if includeOrder(gold_order_number, order_date, part_no) then
            return 'Y' ;
        else
            return 'N' ;
        end if ;
     end includeOrderYorN ;
     
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
               and amd_on_order.ORDER_DATE = includeOrder.order_date
               and action_code <> amd_defaults.DELETE_ACTION
               and line = (select max(line) 
                           from amd_on_order 
                           where gold_order_number = includeOrder.gold_order_number
                           and order_date = includeOrder.order_date
                           and action_code <> amd_defaults.DELETE_ACTION) ;
               RETURN sched_receipt_date ;
          EXCEPTION 
                  WHEN standard.NO_DATA_FOUND THEN
                       return null ;
                when others then
                     if sqlcode = -4091 then
                        raise_application_error(-20060,
                            '1269 gold_order_number=' || gold_order_number || ' order_date=' || to_char(order_date,'MM/DD/YYYY')) ;
                     else
                         errormsg( psqlfunction => 'select', ptablename => 'amd_on_order', pError_location => 1230,
                                     pkey_1 => gold_order_number, pkey_2 => to_char(order_date,'MM/DD/YYYY') ) ;
                     end if ;
                     raise ; 
          END getSchedReceiptDate ;
          
          --function calculate
    
          PROCEDURE recordReason (theReason IN VARCHAR2) IS
          BEGIN     
               writeMsg(pTableName => 'tmp_a2a_order_info_line',pError_location => 1240,
                       pKey1 => 'gold_order_number=' || gold_order_number,
                    pKey2 => 'order_date=' || TO_CHAR(order_date,'MM/DD/YYYY HH:MI:SS AM'),
                    pKey3 => 'reason=' || theReason) ;
          exception when others then
            if sqlcode <> -4092 then
                errormsg( psqlfunction => 'recordReason', ptablename => 'amd_on_order', pError_location => 1250,
                             pkey_1 => gold_order_number, pkey_2 => to_char(order_date,'MM/DD/YYYY') ) ;
                raise ;
            else
                null ; -- do nothing
            end if ;
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
          --     RETURN TRUE ; -- include
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
         errormsg( psqlfunction => 'select', ptablename => 'amd_on_order', pError_location => 1260,
                     pkey_1 => gold_order_number, pkey_2 => to_char(order_date,'MM/DD/YYYY'), 
                   pkey_3 => part_no,
                   pKey_4 => iif(sched_receipt_date is null,'NULL',to_char(sched_receipt_date,'MM/DD/YYYY')) || 'lineOfCode=' || lineOfCode, 
                   pKeywordValuePairs => 'numberOfCalanderDays=' || iif(numberOfCalanderDays is NULL,'NULL',to_char(numberOfCalanderDays)) ) ; /* 
                           || ' sched_receipt_date_from=' || iif(sched_receipt_date_from is NULL,'NULL',to_char(sched_receipt_date_from,'MM/DD/YYYY')) 
                        || ' sched_receipt_date_to=' || iif(sched_receipt_date_to is NULL,'NULL',to_char(sched_receipt_date_to,'MM/DD/YYYY'))
                        || ' created_order_date=' || iif(created_order_date is NULL,'NULL',to_char(created_order_date,'MM/DD/YYYY')) ) ; */
         RAISE ;
     
     END includeOrder ;
     
    
    
    
     PROCEDURE insertTmpA2AOrderInfoLIne(gold_order_number IN AMD_ON_ORDER.GOLD_ORDER_NUMBER%TYPE,
         loc_sid IN AMD_ON_ORDER.LOC_SID%TYPE,
         order_date IN AMD_ON_ORDER.ORDER_DATE%TYPE,
         part_no IN AMD_ON_ORDER.PART_NO%TYPE,
         order_qty IN AMD_ON_ORDER.ORDER_QTY%TYPE,
         sched_receipt_date IN AMD_ON_ORDER.SCHED_RECEIPT_DATE%TYPE,
         action_code IN TMP_A2A_ORDER_INFO_LINE.action_code%TYPE,
         line in amd_on_order.line%type) is
    
            site_location TMP_A2A_ORDER_INFO_LINE.SITE_LOCATION%TYPE := Amd_Utils.getSpoLocation(loc_sid) ;
         lineNumber NUMBER := 0 ;
         current_created_date TMP_A2A_ORDER_INFO_LINE.CREATED_DATE%TYPE := NULL ;
         
         cage_code TMP_A2A_ORDER_INFO_LINE.cage_code%TYPE := Amd_Utils.getCageCode(part_no) ;
         lineOfCode number ;
    
        PROCEDURE doInsert(action_code in tmp_a2a_order_info_line.ACTION_CODE%type) IS
        
             due_date TMP_A2A_ORDER_INFO_LINE.DUE_DATE%TYPE ;
             
             
             PROCEDURE doUpdate IS
             BEGIN
                     UPDATE TMP_A2A_ORDER_INFO_LINE
                    SET 
                        loc_sid = insertTmpA2AOrderInfoLine.loc_sid,
                        site_location = insertTmpA2AOrderInfoLine.site_location,
                        qty_ordered = insertTmpA2AOrderInfoLine.order_qty,
                        action_code = insertTmpA2AOrderInfoLine.action_code,
                        last_update_dt = SYSDATE,
                        due_date = doInsert.due_date,
                        line = insertTmpA2AOrderInfoLine.line,
                        cage_code = cage_code
                    WHERE order_no = insertTmpA2AOrderInfoLine.gold_order_number
                    AND part_no = insertTmpA2AOrderInfoLine.part_no
                    AND created_date = insertTmpA2AOrderInfoLine.order_date ;
              
             EXCEPTION WHEN OTHERS THEN
                 errormsg( psqlfunction => 'update', ptablename => 'tmp_a2a_order_info_line', pError_location => 1270,
                   pkey_1 => gold_order_number) ;
                 RAISE ;
             END doUpdate ;
         
         
        BEGIN
             begin
                  lineOfCode := 6 ;
                  writeMsg(pTableName => 'tmp_a2a_order_info_line',pError_location => 1280,
                    pKey1 => 'gold_order_number=' || gold_order_number,
                    pKey2 => 'part_no= ' ||  part_no,
                    pKey3 => 'loc_sid= ' || loc_sid,
                    pKey4 => 'order_date=' || TO_CHAR(order_date,'MM/DD/YYYY HH:MI:SS AM'),
                    pData => 'ordQty=' || order_qty || ' sched=' || to_char(sched_receipt_date, 'MM/DD/YYYY HH:MI:SS AM') || ' ac=' || action_code) ;
              exception when others then
                    lineOfCode := 7 ;
                    -- ignore commit or rollback exceptions when executed by a trigger
                    if sqlcode <> -4092 then
                        raise ;
                    end if ;
              end ;
              IF sched_receipt_date IS NULL THEN
                    due_date := getDueDate(part_no => insertTmpA2AOrderInfoLine.part_no, order_date => insertTmpA2AOrderInfoLine.order_date) ;
              ELSE
                   due_date := sched_receipt_date ;
              END IF ;
              
              lineOfCode := 8 ;
                    
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
              due_date,
              cage_code
             )
             VALUES
             (
              gold_order_number,
              part_no,
              loc_sid,
              site_location,
              order_date,
              'O',
              insertTmpA2AOrderInfoLine.line,
              order_qty,
              0,
              insertTmpA2AOrderInfoLine.action_code,
              SYSDATE,
              due_date,
              cage_code
             );
             COMMIT ;
        EXCEPTION
              WHEN standard.DUP_VAL_ON_INDEX THEN
                lineOfCode := 9 ;
                doUpdate ;
             
              WHEN OTHERS THEN
                 lineOfCode := 10 ;
                 -- ignore commit or rollback errors from within a trigger
                 if sqlcode <> -4092 then
                     errormsg( psqlfunction => 'insert', ptablename => 'tmp_a2a_order_info_line', pError_location => 1290,
                       pkey_1 => gold_order_number, pKey_2 => part_no, pKey_3 => TO_CHAR(order_date,'MM/DD/YYYY HH:MI:SS AM'), pKey_4 => 'line=' || to_char(line),
                              pKeywordValuePairs => 'loc_sid=' || to_char(loc_sid) || ' orderQty=' || order_qty || ' sched' || to_char(sched_receipt_date,'MM/DD/YYYY HH:MI:SS AM') ) ; 
                     RAISE ;
                 end if ;
        END doInsert ;
        
         
    
     BEGIN
           if insertTmpA2AOrderInfoLine.action_code = amd_defaults.INSERT_ACTION 
           or insertTmpA2AOrderInfoLine.action_code = amd_defaults.UPDATE_ACTION then
                lineOfCode := 1 ;
           
               IF wasPartSent(insertTmpA2AOrderInfoLine.part_no) 
                     AND site_location IS NOT NULL THEN
                    lineOfCode := 2 ;
                     
                    IF includeOrder(gold_order_number => gold_order_number,order_date => order_date,
                                    part_no => insertTmpA2AOrderInfoLine.part_no) THEN
                        
                        lineOfCode := 3 ;
                        includeCnt := includeCnt + 1 ;
                         doInsert(insertTmpA2AOrderInfoLine.action_code) ;
                        
                    ELSE
                        lineOfCode := 4 ;
                        excludeCnt := excludeCnt + 1 ;
                        doInsert(amd_defaults.DELETE_ACTION) ;
                        writeMsg(pTableName => 'tmp_a2a_order_info_line',pError_location => 1300,
                               pKey1 => 'gold_order_number=' || gold_order_number,
                            pKey2 => 'part_no= ' || insertTmpA2AOrderInfoLine.part_no,
                            pKey3 => 'site_location= ' || insertTmpA2AOrderInfoLine.site_location,
                            pKey4 => 'order_date=' || TO_CHAR(insertTmpA2AOrderInfoLine.order_date,'MM/DD/YYYY HH:MI:SS AM'),
                            pData => 'excluded') ;
                    END IF ;
                    
              END IF ;
        else
            lineOfCode := 5 ;
            if isPartSent(insertTmpA2AOrderInfoLine.part_no) 
               and site_location is not null then -- the part must exist in amd_sent_to_a2a with any action_code
                doInsert(insertTmpA2AOrderInfoLine.action_code) ;
            end if ;
        end if ;
         
     EXCEPTION
           WHEN OTHERS THEN
              if sqlcode <> -4092 then
                  errormsg( psqlfunction => 'insert', ptablename => 'tmp_a2a_order_info_line', pError_location => 1310,
                    pkey_1 => 'gold_order_number=' || to_char(Nvl(gold_order_number,0))
                        || ' sqlcode=' || sqlcode,
                    pKey_2 => 'part_no=' || insertTmpA2AOrderInfoLine.part_no 
                        || ' excludeCnt='|| excludeCnt,
                    pKey_3 => 'site_location=' || insertTmpA2AOrderInfoLine.site_location 
                        || ' includeCnt=' || includeCnt,
                    pKey_4 => 'order_date=' || TO_CHAR(insertTmpA2AOrderInfoLine.order_date,'MM/DD/YYYY HH:MI:SS AM'),
                    pKeywordValuePairs => 'lineNumber=' || TO_CHAR(NVL(lineNumber,0)) 
                        || ' lineOfCode=' || to_char(lineOfCode) || ' action_code=' || action_code  ) ;
                  RAISE ;
               end if ;
     END insertTmpA2AOrderInfoLine ;
    
    
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
          errormsg( psqlfunction => 'update', ptablename => 'tmp_a2a_in_transits', pError_location => 1320,
            pkey_1 => insertTmpA2AInTransits.part_no, pKey_2 => insertTmpA2AInTransits.site_location,
            pkey_3 => insertTmpA2AInTransits.serviceable_flag) ;
          RAISE ;    
        END doUpdate ;
        
        procedure insertRow is
        begin
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
       -- added exception handlers DSE 11/30/05
        EXCEPTION
               WHEN standard.DUP_VAL_ON_INDEX THEN
                     doUpdate ;
              WHEN OTHERS THEN 
                  errormsg( psqlfunction => 'insert', ptablename => 'tmp_a2a_in_transits', pError_location => 1330,
                    pkey_1 => insertTmpA2AInTransits.part_no, pKey_2 => insertTmpA2AInTransits.site_location) ;
                  RAISE ;
        end insertRow ;
    
     BEGIN
      if action_code = amd_defaults.INSERT_ACTION 
      or action_code = amd_defaults.UPDATE_ACTION then
      
          IF quantity > 0 
          AND wasPartSent(insertTmpA2AInTransits.part_no)
          AND isPartValid(insertTmpA2AInTransits.part_no) -- added isPartValid DSE 11/30/05 
          AND site_location IS NOT NULL  THEN
          
                insertRow ;
          
          END IF ;
      else
             if isPartSent(part_no) 
               and site_location is not null then
                 insertRow ;
          end if ;          
      end if ;
                     
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
        errormsg( psqlfunction => 'insert', ptablename => 'tmp_a2a_spo_users', pError_location => 1340,
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
                debugMsg(msg => 'before update bems_id = ' || bems_id || 'email= ' || theEmail || 'last_name=' || theName, pError_location => 1350) ;
                
                   UPDATE TMP_A2A_SPO_USERS
                SET email = SUBSTR(trim(insertTmpA2ASpoUsers.stable_email),1,32),
                name = SUBSTR(trim(last_name) || ', ' || trim(first_name),1,32),
                action_code = insertTmpA2ASpoUsers.action_code,
                last_update_dt = SYSDATE
                WHERE bems_id = insertTmpA2ASpoUsers.bems_id ;
                
                debugMsg(msg => 'after update bems_id = ' || bems_id || 'email= ' || SUBSTR(stable_email,1,32) || 'last_name=' || SUBSTR(last_name || ', ' || first_name,1,32), pError_location => 1360) ;
                A2a_Pkg.mDebug := debugIt ; -- restore
                
           EXCEPTION WHEN OTHERS THEN
                errormsg( psqlfunction => 'update', ptablename => 'tmp_a2a_spo_users', pError_location => 1370,
                    pkey_1 => bems_id) ;
                RAISE ;
           END doUpdate ;
           
     BEGIN
           INSERT INTO TMP_A2A_SPO_USERS
          (bems_id, email, NAME, action_code, last_update_dt)
          VALUES(bems_id, SUBSTR(trim(stable_email),1,32), SUBSTR(trim(last_name) || ', ' || trim(first_name),1,32), action_code, SYSDATE) ;
     EXCEPTION
               WHEN standard.DUP_VAL_ON_INDEX THEN
                     doUpdate ;
              WHEN OTHERS THEN
                    errormsg( psqlfunction => 'insert', ptablename => 'tmp_a2a_spo_users', pError_location => 1380,
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
          CURSOR invalidParts IS
          SELECT sent.part_no, nomenclature 
          FROM AMD_SENT_TO_A2A sent, amd_spare_parts parts
          WHERE sent.action_code != Amd_Defaults.DELETE_ACTION
          AND sent.spo_prime_part_no IS NOT NULL
          and (
                (amd_utils.isPartRepairableYorN(sent.part_no) = 'Y' and isPartValidYorN(sent.part_no) = 'N')
               or (amd_utils.isPartConsumableYorN(sent.part_no) = 'Y' and a2a_consumables_pkg.isPartValidYorN(sent.part_no) = 'N')
               or (amd_utils.isPartRepairableYorN(sent.part_no) = 'N' and amd_utils.isPartConsumableYorN(sent.part_no) = 'N')
              )                
          and sent.part_no = parts.part_no ;
          
          rc NUMBER ;
          cnt NUMBER := 0 ;
                  
      BEGIN
            writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 1390,
                pKey1 => 'deleteInvalidParts',
                pKey2 => 'testOnly=' || Amd_Utils.boolean2Varchar2(testOnly),
                pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;       
             FOR rec IN invalidParts LOOP
                  IF NOT testOnly THEN
                      rc := A2a_Pkg.DeletePartInfo(rec.part_no,rec.nomenclature) ;
                      UPDATE AMD_SENT_TO_A2A
                      SET action_code = Amd_Defaults.DELETE_ACTION,
                      transaction_date = SYSDATE
                      WHERE part_no = rec.part_no ; 
                  END IF ;
                  cnt := cnt + 1 ;
           END LOOP ;
           writeMsg(pTableName => 'tmp_a2a_part_info', pError_location => 1400,
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
                errormsg( psqlfunction => 'update', ptablename => 'tmp_a2a_bom_detail', pError_location => 1410,
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
                errormsg( psqlfunction => 'insert', ptablename => 'tmp_a2a_bom_detail', pError_location => 1420,
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
               bomDetails bomDetailTab ;
     BEGIN
            writeMsg(pTableName => 'tmp_a2a_bom_detail', pError_location => 1430,
            pKey1 => 'processBomDetail',
            pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
            fetch bomDetail bulk collect into bomDetails ;
            close bomDetail ;
            
           if bomDetails.first is not null then
               for indx in bomDetails.first .. bomDetails.last        
               LOOP
                  IF bomDetails(indx).spo_prime_part_no IS NOT NULL THEN
                      processPart(bomDetails(indx)) ;
                      cnt := cnt + 1 ;
                  END IF ;
              END LOOP ;
            end if ;              
            writeMsg(pTableName => 'tmp_a2a_bom_detail', pError_location => 1440,
            pKey1 => 'processBomDetail',
            pKey2 => 'cnt=' || TO_CHAR(cnt),
            pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;       
          COMMIT ;
     END processBomDetail ;
     
     PROCEDURE initA2ABomDetail(from_dt IN DATE := START_DT, to_dt IN DATE := SYSDATE ) IS
          partsByDate bomDetailCur ;
          cnt NUMBER := 0 ;
        BEGIN
            writeMsg(pTableName => 'tmp_a2a_bom_detail', pError_location => 1450,
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
            writeMsg(pTableName => 'tmp_a2a_bom_detail', pError_location => 1460,
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
            writeMsg(pTableName => 'amd_sent_to_a2a', pError_location => 1470,
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
            writeMsg(pTableName => 'amd_sent_to_a2a', pError_location => 1480,
            pKey1 => 'getAllData' ) ;
            commit ;
            OPEN parts FOR
              SELECT *
              FROM AMD_SENT_TO_A2A WHERE
              part_no IN (SELECT spo_prime_part_no FROM AMD_SENT_TO_A2A WHERE part_no = spo_prime_part_no);
          end getAllData ;
           
        BEGIN
            writeMsg(pTableName => 'tmp_a2a_bom_detail', pError_location => 1490,
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
            writeMsg(pTableName => 'tmp_a2a_bom_detail', pError_location => 1500,
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
               WHERE part_no = rec.spo_prime_part_no
               AND site_location = processBackorder.site_location
               AND loc_sid = rec.loc_sid ;
           EXCEPTION WHEN OTHERS THEN
                errormsg( psqlfunction => 'update', ptablename => 'tmp_a2a_backorder_info', pError_location => 1510,
                    pkey_1 => rec.spo_prime_part_no, pkey_2 => TO_CHAR(rec.loc_sid), pkey_3 => site_location) ;
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
                (rec.spo_prime_part_no, rec.loc_sid, site_location, rec.qty, rec.action_code, rec.last_update_dt);
        EXCEPTION 
            WHEN standard.DUP_VAL_ON_INDEX THEN
                doUpdate ;
            WHEN OTHERS THEN
                errormsg( psqlfunction => 'insert', ptablename => 'tmp_a2a_backorder_info', pError_location => 1520,
                    pkey_1 => rec.spo_prime_part_no, pkey_2 => TO_CHAR(rec.loc_sid), pkey_3 => site_location) ;
                RAISE ;
        END processBackorder ;
        PROCEDURE processBackOrder(backOrder IN backOrderCur) IS
                  cnt NUMBER := 0 ;
                  rec AMD_BACKORDER_SUM%ROWTYPE ;
                   site_location TMP_A2A_BACKORDER_INFO.site_location%TYPE ;
                  backOrders backOrderTab ;
        BEGIN
               writeMsg(pTableName => 'tmp_a2a_backorder_info', pError_location => 1530,
                pKey1 => 'processBackOrder',
                pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
             fetch backOrder bulk collect into backOrders ;
             close backOrder ;
             
             if backOrders.first is not null then
                 for indx in backOrders.first .. backOrders.last       
                 LOOP
                     site_location := Amd_Utils.getSpoLocation(backOrders(indx).loc_sid) ;
                     IF site_location IS NOT NULL THEN
                             processBackorder(backOrders(indx), site_location) ;
                         cnt := cnt + 1 ;
                     END IF ;
                 END LOOP ;
              end if ;                 
               writeMsg(pTableName => 'tmp_a2a_backorder_info', pError_location => 1540,
                pKey1 => 'processBackOrder',
                pKey2 => 'cnt=' || TO_CHAR(cnt),
                pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;       
             COMMIT ;
        END processBackOrder ;
        
         PROCEDURE initA2ABackorderInfo(from_dt IN DATE := START_DT, to_dt IN DATE := SYSDATE ) IS
          
          backOrdersByDate backOrderCur ;
          
        BEGIN
               writeMsg(pTableName => 'tmp_a2a_backorder_info', pError_location => 1550,
                pKey1 => 'initA2ABackorderInfo',
                pKey2 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
                pKey3 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
                pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;       
             Mta_Truncate_Table('tmp_a2a_backorder_info','reuse storage');
          mblnSendAllData := TRUE ;
          OPEN backOrdersByDate FOR
              SELECT
                  sent.spo_prime_part_no,         
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
                AND bo.spo_prime_part_no = sent.part_no
              and sent.SPO_PRIME_PART_NO is not null 
              order by sent.spo_prime_part_no, last_update_dt ;
              
          processBackOrder(backOrdersByDate) ;
          writeMsg(pTableName => 'tmp_a2a_backorder_info', pError_location => 1560,
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
             writeMsg(pTableName => 'amd_backorder_sum', pError_location => 1570,
             pKey1 => 'getTestData' ) ;
             commit ;
               OPEN parts FOR
              SELECT 
                  sent.spo_prime_part_no,         
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
              bo.spo_prime_part_no = testParts.part_no 
                AND bo.spo_prime_part_no = sent.part_no
              and sent.SPO_PRIME_PART_NO is not null 
              order by sent.spo_prime_part_no, last_update_dt ;
                useTestPartsString := 'True' ;
              
          end getTestData ;
          
          procedure getAllData is
          begin
             writeMsg(pTableName => 'amd_backorder_sum', pError_location => 1580,
             pKey1 => 'getAllData' ) ;
             commit ;
               OPEN parts FOR
              SELECT 
                  sent.spo_prime_part_no,         
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
              WHERE bo.spo_prime_part_no = sent.part_no
              and sent.SPO_PRIME_PART_NO is not null 
              order by sent.spo_prime_part_no, last_update_dt ;
          end getAllData ;
          
        BEGIN
          writeMsg(pTableName => 'tmp_a2a_backorder_info', pError_location => 1590,
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
          writeMsg(pTableName => 'tmp_a2a_backorder_info', pError_location => 1600,
                pKey1 => 'initA2ABackorderInfo',
                pKey2 => 'useTestParts=' || Amd_Utils.boolean2Varchar2(useTestParts),
                pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
          COMMIT ;       
        END initA2ABackorderInfo ;
    
        PROCEDURE loadAll(startStep IN NUMBER := 1, endStep IN NUMBER := 16, debugIt IN BOOLEAN := FALSE, system_id IN AMD_BATCH_JOBS.SYSTEM_ID%TYPE := 'LOAD_ALL_A2A') IS
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
                  PART_ALT CONSTANT VARCHAR2(8) := 'PART_ALT' ;
                  
                  theJob AMD_BATCH_JOBS.BATCH_JOB_NUMBER%TYPE ;
                  batch_step_number AMD_BATCH_JOB_STEPS.BATCH_STEP_NUMBER%TYPE ;
        BEGIN
           writeMsg(pTableName => 'loadAll', pError_location => 1610,
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
                            commit ;
                            a2a_pkg.DELETEINVALIDPARTS ;
                            commit ;
                            amd_load.LOADRBLPAIRS ;
                            commit ;
                            Amd_Partprime_Pkg.DiffPartToPrime ; -- set amd_sent_to_a2a.spo_prime_part_no
                            commit ;
                    END IF ;
                ELSIF step = 4 THEN
                     IF NOT Amd_Batch_Pkg.isStepComplete(batch_job_number => theJob, system_id => loadAll.system_id,
                               description => ORDER_INFO) THEN
                         Amd_Batch_Pkg.start_step(batch_job_number => theJob, system_id => loadAll.system_id,
                            description => ORDER_INFO, package_name => THIS_PACKAGE, procedure_name => ORDER_INFO) ;
                        rc := amd_owner.A2a_Pkg.initA2AOrderInfo(useTestParts => FALSE) ;
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
                        amd_owner.Amd_Location_Part_Override_Pkg.LOADINITIAL ;
                        amd_lp_override_consumabl_pkg.INITIALIZE ;
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
                            amd_demand.LOADALLA2A ; -- load consumables
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
                ELSIF step = 16 THEN
                     IF NOT Amd_Batch_Pkg.isStepComplete(batch_job_number => theJob, system_id => loadAll.system_id,
                               description => PART_ALT) THEN
                         Amd_Batch_Pkg.start_step(batch_job_number => theJob, system_id => loadAll.system_id,
                            description => PART_ALT, package_name => THIS_PACKAGE, procedure_name => PART_ALT) ;
                        initA2APartAlt ;
                    END IF ;
                END IF ;
                COMMIT ;
                 batch_step_number := Amd_Batch_Pkg.getActiveStep(batch_job_number => theJob, system_id => loadAll.system_id) ;
                 IF batch_step_number IS NOT NULL THEN
                      Amd_Batch_Pkg.end_step(batch_job_number => theJob, system_id => loadAll.system_id,
                        batch_step_number => batch_step_number) ;
                 END IF ;
                 COMMIT ;
                   writeMsg(pTableName => 'loadAll', pError_location => 1620,
                         pKey1 => 'step=' || step,
                        pKey2 => 'rc=' || rc) ;
                 COMMIT ;
                 rc := 0 ;
            END LOOP ;
            Amd_Batch_Pkg.end_job(batch_job_number => theJob, system_id => loadAll.system_id) ;
            writeMsg(pTableName => 'loadAll', pError_location => 1630,
                pKey1 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
        END loadAll ;
        
        PROCEDURE version IS
        BEGIN
             writeMsg(pTableName => 'a2a_pkg', 
                     pError_location => 1640, pKey1 => 'a2a_pkg', pKey2 => '$Revision:   1.216  $') ;
              dbms_output.put_line('a2a_pkg: $Revision:   1.216  $') ;
        END version ;

        function getVersion return varchar2 is
        begin
            return '$Revision:   1.216  $' ;
        end getVersion ;
        
        procedure setInsertAddUpdRepairInfoCnt (value in number) is
        begin
            insertAddUpdRepairInfoCnt := value ;
        end setInsertAddUpdRepairInfoCnt ;
        
        procedure resetDebugCnts is
        begin
             insertRowCnt  := 0 ;
             insertAddUpdRepairInfoCnt  := 0 ;
             deleteCnt  := 0 ;
             insertCnt  := 0 ;
             rejectCnt := 0 ;
        end resetDebugCnts ;
        
        function getInsertAddUpdRepairInfoCnt return number is
        begin
            return insertAddUpdRepairInfoCnt ;
        end getInsertAddUpdRepairInfoCnt ;
                            
        function getDebugYorN return varchar2 is
        begin
            if debug then
                return 'Y' ;
            else
                return 'N' ;
            end if ;            
        end getDebugYorN ;   
        
        procedure setDebug(switch in varchar2) is
        begin
            debug := upper(switch) in ('Y','T','YES','TRUE') ;
            if debug then
                dbms_output.ENABLE(100000) ;
            else
                dbms_output.DISABLE ;
            end if ;                    
        end setDebug ;
        
        function getDebugThreshold return number is
        begin
            return debugThreshold ;
        end getDebugThreshold ;
        
        procedure setDebugThreshold(value in number) is
        begin
            debugThreshold := value ;
        end setDebugThreshold ;
        
        procedure setAllThresholds(value in number) is
        begin
            debugThreshold := value ;
            debugRepairInfoThreshold := value ;
            debugDeleteThreshold := value ;
        end setAllThresholds ;
                                
                         
        procedure setDebugDeleteThreshold(value in number) is
        begin
            debugDeleteThreshold := value ;
        end setDebugDeleteThreshold ;            
                    
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
            writeMsg(pTableName => 'deleteSentToA2AChildren', pError_location => 1650,
                pKey1 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
             for rec in childrenToDelete loop
                  cnt := cnt + 1 ;
                 update amd_sent_to_a2a
                 set action_code = amd_defaults.DELETE_ACTION
                 where part_no = rec.part_no ;
                 
                 result := deletePartInfo(rec.part_no, rec.nomenclature) ;
                 
             end loop ;
             writeMsg(pTableName => 'deleteSentToA2AChildren', pError_location => 1660,
                pKey1 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey2 => 'cnt=' || to_char(cnt) ) ;
             commit ;
        
        end deleteSentToA2AChildren ;

        function lpOverrideExists(part_no in datasys_lp_override_v.PART%type, site_location in datasys_lp_override_v.SITE_LOCATION%type) return boolean is
            result number ;
        begin
            select 1 into result
            from dual
            where exists 
                    (select null
                    from datasys_lp_override_v
                    where part = lpOverrideExists.part_no
                    and site_location = lpOverrideExists.site_location ) ;
            
            return true ;
            
        exception when standard.no_data_found then
            return false ;
        end lpOverrideExists ;

        function lpOverrideExistsYorN(part_no in datasys_lp_override_v.PART%type, site_location in datasys_lp_override_v.SITE_LOCATION%type) return varchar2 is
        begin
            if lpOverrideExists(part_no, site_location) then
                return 'Y' ;
            else
                return 'N' ;
            end if ;            
        end lpOverrideExistsYorN ;
        
        function partExistsInDataSystems(pPartNo in datasys_part_v.part%type) return boolean is
            result varchar2(1) := 'N' ;
        begin
            select 'Y' into result from datasys_part_v where part = pPartNo ;
            return true  ;
        exception when standard.no_data_found then
            return false ;
        end partExistsInDataSystems ;

        function partExistsInDataSystemsYorN(pPartNo in datasys_part_v.part%type) return varchar2 is
        begin
            if partExistsInDataSystems(pPartNo) then
                return 'Y' ;
            end if ;
            return 'N' ;
        end partExistsInDataSystemsYorN ;
        

        function isDataSysPartMarkedDeleted(pPartNo in datasys_part_v.part%type) return boolean is
            result varchar2(1) := 'N' ;
        begin
            select 'Y' into result from datasys_part_v where part = pPartNo and end_date is not null ;
            return true ;
        exception when standard.no_data_found then 
            return false ;
        end isDataSysPartMarkedDeleted ;

        function isDataSysPartMarkedDeletedYorN(pPartNo in datasys_part_v.part%type) return varchar2 is
        begin
            if isDataSysPartMarkedDeleted(pPartNo) then
                return 'Y' ;
            end if ;
            return 'N' ;
        end isDataSysPartMarkedDeletedYorN ;
        
        -- added 9/27/07
        procedure initA2APartAlt is
            cursor sentParts is
            select * from amd_sent_to_a2a
            where part_no <> spo_prime_part_no ;
            cnt number := 0 ;
        begin
            writeMsg(pTableName => 'tmp_a2a_part_alt', pError_location => 1665,
                pKey1 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM')) ;
            mta_truncate_table('tmp_a2a_part_alt','reuse storage') ;
            for rec in sentParts loop
                insert into tmp_a2a_part_alt
                (part_no, prime_part, tran_action, last_update_dt)
                values (rec.part_no, rec.spo_prime_part_no,rec.action_code, sysdate) ;
                cnt := cnt + 1 ; 
            end loop ;
            writeMsg(pTableName => 'tmp_a2a_part_alt', pError_location => 1670,
                pKey1 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey2 => 'cnt=' || to_char(cnt) ) ;
            commit ;
        end initA2APartAlt ;
        
            
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

SHOW ERRORS;


DROP PUBLIC SYNONYM A2A_PKG;

CREATE PUBLIC SYNONYM A2A_PKG FOR AMD_OWNER.A2A_PKG;


GRANT EXECUTE ON AMD_OWNER.A2A_PKG TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.A2A_PKG TO BSRM_LOADER;


