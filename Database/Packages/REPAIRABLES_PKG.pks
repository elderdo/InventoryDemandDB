DROP PACKAGE AMD_OWNER.REPAIRABLES_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.repairables_Pkg AS
 --
 -- SCCSID:   %M%   %I%   Modified: %G%  %U%
 --
 /*
      $Author:   zf297a  $
    $Revision:   1.74  $
     $Date:   26 Jul 2013

         rev 1.74 removed all a2a dependencies
         
         Rev 1.73 renamed the package repairables_pkg
         
/*      Rev 1.72   12 Aug 2008 08:15:44   zf297a
/*   Added interface isPartValidYorN with additional arguments: part_no, preferred smr_code, preferred mtbdr, and preferred planner_code.
/*   
/*      Rev 1.71   31 Jul 2008 11:16:42   zf297a
/*   Changed interface for getAssignedPlannerCode ... just use part_no as an argument.
/*   
/*      Rev 1.70   27 Jun 2008 12:09:00   zf297a
/*   Added get/set's for deleteChildrenThreshold
/*   
/*      Rev 1.69   15 May 2008 19:43:52   zf297a
/*   removed mDebug from the package spec.  debug now only gets set with the setDebug procedure and retrived with the getDebugYorN function.
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
     SUCCESS           CONSTANT NUMBER := 0 ;
     FAILURE           CONSTANT NUMBER := 4 ;
     NEW_BUY           CONSTANT varchar2(20) := 'NEW-BUY' ;
     REPAIR            CONSTANT varchar2(20) := 'REPAIR' ;
     AN_ORDER           CONSTANT varchar2(5) := 'ORDER' ;
     OPEN_STATUS       CONSTANT varchar2(1)   := 'O' ;
     THIRD_PARTY_FLAG CONSTANT varchar2(1) := '?' ;
     RCM_REPAIRABLE   CONSTANT varchar2(1) := 'T' ; -- used for rcm_ind
     RCM_CONSUMABLE   CONSTANT varchar2(1) := 'F' ; -- used for rcm_ind
     
     APPLICATION_ERROR EXCEPTION ;
    
     
      TYPE partInfoRec IS RECORD (
           mfgr           AMD_SPARE_PARTS.mfgr%TYPE, 
          part_no      AMD_SPARE_PARTS.part_no%TYPE,
          NOMENCLATURE AMD_SPARE_PARTS.nomenclature%TYPE,
          nsn           AMD_SPARE_PARTS.nsn%TYPE,
          order_lead_time AMD_SPARE_PARTS.order_lead_time%TYPE,
          order_lead_time_defaulted AMD_SPARE_PARTS.order_lead_time_defaulted%TYPE,
          unit_cost                    AMD_SPARE_PARTS.unit_cost%TYPE,
          unit_cost_defaulted        AMD_SPARE_PARTS.unit_cost_defaulted%TYPE,
          unit_of_issue                AMD_SPARE_PARTS.unit_of_issue%TYPE,
          unit_cost_cleaned            AMD_NATIONAL_STOCK_ITEMS.unit_cost_cleaned%TYPE,
          order_lead_time_cleaned    AMD_NATIONAL_STOCK_ITEMS.order_lead_time_cleaned%TYPE,
          planner_code                AMD_NATIONAL_STOCK_ITEMS.planner_code%TYPE,
          planner_code_cleaned        AMD_NATIONAL_STOCK_ITEMS.planner_code_cleaned%TYPE,
          mtbdr                        AMD_NATIONAL_STOCK_ITEMS.mtbdr%TYPE,
          mtbdr_cleaned                AMD_NATIONAL_STOCK_ITEMS.mtbdr_cleaned%TYPE,
          mtbdr_computed            AMD_NATIONAL_STOCK_ITEMS.mtbdr_computed%type,
          smr_code                    AMD_NATIONAL_STOCK_ITEMS.smr_code%TYPE,
          smr_code_cleaned            AMD_NATIONAL_STOCK_ITEMS.smr_code_cleaned%TYPE,
          smr_code_defaulted        AMD_NATIONAL_STOCK_ITEMS.smr_code_defaulted%TYPE,
          nsi_sid                    AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE,
          TIME_TO_REPAIR_OFF_BASE_CLEAND AMD_NATIONAL_STOCK_ITEMS.TIME_TO_REPAIR_OFF_BASE_CLEAND%TYPE,
          last_update_dt            AMD_SPARE_PARTS.last_update_dt%TYPE,
          action_code                AMD_SPARE_PARTS.action_code%TYPE
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
    
    
    
    
     FUNCTION getIndenture(smr_code_preferred IN AMD_NATIONAL_STOCK_ITEMS.SMR_CODE%TYPE) RETURN varchar2 ;
    
     FUNCTION getAssignedPlannerCode(part_no IN amd_spare_parts.part_no%TYPE) RETURN AMD_PLANNERS.planner_code%TYPE  ;
    
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
            part_no IN amd_spare_parts.PART_NO%type,
            lead_time_type varchar2,
            lead_time IN number,
            action_code IN amd_spare_parts.action_code%TYPE) ;
            
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
    
           
    
     procedure initA2ADemands ;
    
    
    
     FUNCTION initA2APartInfo(useTestParts IN BOOLEAN := FALSE) RETURN NUMBER ;
    
     FUNCTION initA2AOrderInfo(useTestParts IN BOOLEAN := FALSE) RETURN NUMBER ;
    
     FUNCTION initA2ARepairInfo(useTestParts IN BOOLEAN := FALSE) RETURN NUMBER ;
    
    
     FUNCTION initA2AInvInfo(useTestParts IN BOOLEAN := FALSE) RETURN NUMBER ;
    
     FUNCTION initA2ARepairInvInfo(useTestParts IN BOOLEAN := FALSE) RETURN NUMBER ;
     
    
      PROCEDURE insertRepairInvInfo(part_no IN amd_spare_parts.part_no%TYPE,
        site_location IN varchar2,
        inv_qty IN number,
        action_code IN amd_spare_parts.action_code%TYPE)  ;
    
     PROCEDURE insertInvInfo(part_no IN amd_spare_parts.part_no%TYPE,
        spo_location IN varchar2 ,
        qty_on_hand IN number,
        action_code IN amd_spare_parts.action_code%TYPE)  ;
    
     PROCEDURE insertRepairInfo(part_no IN amd_spare_parts.part_no%TYPE,
        loc_sid IN NUMBER,
        doc_no IN varchar2, -- order_sid
        repair_date IN date,
        status IN varchar2,
        quantity IN number /* repair_qty */,
        expected_completion_date IN date,
        action_code IN amd_spare_parts.action_code%TYPE) ;
    
    
    
    
      FUNCTION wasPartSent(partNo IN AMD_SPARE_PARTS.part_no%TYPE) RETURN BOOLEAN ;
      FUNCTION wasPartSentYorN(partNo IN AMD_SPARE_PARTS.part_no%TYPE) RETURN VARCHAR2 ;
      
      FUNCTION isPartValid (partNo IN AMD_SPARE_PARTS.part_no%TYPE, showReason in boolean := false) RETURN BOOLEAN ;
      FUNCTION isPartValidYorN(partNo IN AMD_SPARE_PARTS.part_no%TYPE, showReason in varchar2 := 'N') RETURN VARCHAR2 ;
      
      function isPartValid(partNo IN VARCHAR2, 
        preferredSmrCode IN VARCHAR2, preferredMtbdr IN NUMBER, preferredPlannerCode IN VARCHAR2, 
        showReason in boolean := false) RETURN BOOLEAN ;
      function isPartValidYorN(partNo IN VARCHAR2, preferredSmrCode IN VARCHAR2, 
        preferredMtbdr IN NUMBER, preferredPlannerCode IN VARCHAR2, showReason in varchar2 := 'F') RETURN varchar2 ;

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
    
       PROCEDURE spoUser(bems_id IN varchar2,
      action_code IN amd_spare_parts.ACTION_CODE%TYPE) ;
    
    
     PROCEDURE initA2APartLeadTime(useTestParts IN BOOLEAN := FALSE) ;
     
     PROCEDURE initA2ABomDetail(useTestParts IN BOOLEAN := FALSE) ;
    
     PROCEDURE deletePartInfo(useTestParts IN BOOLEAN := FALSE) ;
    
     FUNCTION getTimeToRepair(loc_sid  IN AMD_IN_REPAIR.loc_sid%TYPE,
               part_no IN VARCHAR2) RETURN AMD_PART_LOCS.time_to_repair%TYPE ;
     PROCEDURE insertTimeToRepair(part_no IN AMD_SPARE_PARTS.part_no%TYPE,
              nsi_sid IN AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE,
              time_to_repair_off_base_cleand IN AMD_NATIONAL_STOCK_ITEMS.time_to_repair_off_base_cleand%TYPE); 
    
     PROCEDURE deleteInvalidParts (testOnly IN BOOLEAN := FALSE) ;
    
              
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
     function getNEW_BUY return varchar2 ; 
     function getREPAIR  return varchar2 ;
     function getAN_ORDER return varchar2 ;
     function getOPEN_STATUS return varchar2 ;
     function getTHIRD_PARTY_FLAG return varchar2;
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
      
      procedure setDeleteChildrenThreshold(value in number) ; -- added 6/27/2008 by dse
        
      function getDeleteChildrenThreshold return number ; -- added 6/27/2008 by dse

      

      
END repairables_Pkg ;
 
/


DROP PUBLIC SYNONYM REPAIRABLES_PKG;

CREATE PUBLIC SYNONYM REPAIRABLES_PKG FOR AMD_OWNER.REPAIRABLES_PKG;


GRANT EXECUTE ON AMD_OWNER.REPAIRABLES_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.REPAIRABLES_PKG TO AMD_WRITER_ROLE;
