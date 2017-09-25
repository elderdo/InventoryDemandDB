SET DEFINE OFF;
DROP PACKAGE AMD_OWNER.AMD_LOAD;

CREATE OR REPLACE PACKAGE AMD_OWNER.amd_load as
    /*
        PVCS Keywords

       $Author:   zf297a  $
     $Revision:   1.25  $
         $Date:   25 Nov 2008 22:29:18  $
     $Workfile:   amd_load.pks  $
          $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_load.pks-arc  $
   
      Rev 1.25   25 Nov 2008 22:29:18   zf297a
   Add interfaces setStartDebugRec and getStartDebugRec.  startDebugRec starts the loadGold procedure to dump the current index and part to the amd_load_details table.  This is to be used for debugging purposes only.
   
      Rev 1.24   07 Jul 2008 09:15:38   zf297a
   Added interface for setDebugThreshold and getDebugThreshold
   
      Rev 1.23   30 Jun 2008 15:23:08   zf297a
   Added interfaces for setDebug and getDebug
   
      Rev 1.22   23 May 2008 13:10:02   zf297a
   Added interface for function getVersion.
   
      Rev 1.21   Aug 09 2007 10:47:44   c402417
   Added procedure LoadWecm.
   
      Rev 1.20   10 Apr 2007 09:04:12   zf297a
   Made partNo varchar2 for getOffBaseTurnaround and getOffBaseRepairCost
   
      Rev 1.19   02 Apr 2007 10:53:36   zf297a
   Removed mtbdr_computed from the getOriginalBssmData interface.  Added constants: CLEANED_DATA, ORIGINAL_DATA, and CURRENT_NSN and get functions for each of the constants.
   
   Changed procedure getCalculatedData to a function taking nsn and part_no as arguments and returning mtbdr_computed.
   
   Added function getOrderLeadTime which takes a trimmed cat1 part number as an arguments and returns the order lead time from cat1.
   
      Rev 1.18   14 Feb 2007 13:47:18   zf297a
   Added amc_demand to the interface for getOriginalBssmData, added amc_demand_cleaned to the interface for getCleanedBssmData, and added new interface for getCalculatedData which will handle mtbdr_computed which is not a cleaned field, but it does appear on lock_sid 2.
   
      Rev 1.17   Jan 17 2007 16:23:08   c402417
   Added Procedure LoadRblPairs right after  Procedure LoadGold .
   
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
   Made functions     GetOffBaseRepairCost and GetOffBaseTurnAround public.

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
    -- 09/22/04 TP       Changed how we pull SMR Code from PSMS to GOLD .
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
         nrts_avg out amd_national_stock_items.nrts_avg%type,
         rts_avg out amd_national_stock_items.rts_avg%type,
         amc_demand out amd_national_stock_items.amc_demand%type) ;

    procedure getCleanedBssmData(nsn in amd_nsns.nsn%type,
        part_no                 in bssm_owner.bssm_parts.part_no%type,
        condemn_avg_cleaned     out amd_national_stock_items.condemn_avg_cleaned%type,
        criticality_cleaned     out amd_national_stock_items.criticality_cleaned%type,
        mtbdr_cleaned             out amd_national_stock_items.mtbdr_cleaned%type,
        nrts_avg_cleaned         out amd_national_stock_items.nrts_avg_cleaned%type,
        rts_avg_cleaned         out amd_national_stock_items.rts_avg_cleaned%type,
        order_lead_time_cleaned out amd_national_stock_items.order_lead_time_cleaned%type,
        planner_code_cleaned     out amd_national_stock_items.planner_code_cleaned%type,
        smr_code_cleaned         out amd_national_stock_items.smr_code_cleaned%type,
        unit_cost_cleaned         out amd_national_stock_items.unit_cost_cleaned%type,
        cost_to_repair_off_base_cleand out amd_national_stock_items.cost_to_repair_off_base_cleand%type,
        time_to_repair_off_base_cleand out amd_national_stock_items.time_to_repair_off_base_cleand%type,
        amc_demand_cleaned out amd_national_stock_items.amc_demand_cleaned%type) ;

    PROCEDURE getRmadsData (part_no in amd_rmads_source_tmp.part_no%type, qpei_weighted out amd_rmads_source_tmp.QPEI_WEIGHTED%type,
        mtbdr out amd_rmads_source_tmp.MTBDR%type) ;

    PROCEDURE GetPsmsData(pPartNo VARCHAR2, pCage VARCHAR2, pPsmsInst VARCHAR2,
              pSlifeDay OUT NUMBER, pUnitVol  OUT NUMBER, pSmrCode  OUT VARCHAR2);


    procedure LoadGold;
    procedure LoadRblPairs;
    procedure LoadPsms;
    procedure LoadMain;
    procedure LoadWecm;
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

    CLEANED_DATA           constant varchar2(1) := '2' ;
    function getCLEANED_DATA return varchar2 ;        
    ORIGINAL_DATA          constant varchar2(1) := '0' ;
    function getORIGINAL_DATA return varchar2 ;
    CURRENT_NSN            constant varchar2(1) := 'C' ;
    function getCURRENT_NSN return varchar2 ;

    -- for amd_planners diff
    function insertRow(planner_code in varchar2) return number ;
    function updateRow(planner_code in varchar2) return number ;
    function deleteRow(planner_code in varchar2) return number ;

    -- for amd_planner_logons diff
    function insertplannerlogons(planner_code in varchar2, logon_id in varchar2, data_source in varchar2) return number ;
    function updatePlannerLogons(planner_code in varchar2, logon_id in varchar2, data_source in varchar2) return number ;
    function deletePlannerLogons(planner_code in varchar2, logon_id in varchar2, data_source in varchar2) return number ;

    function getBemsId(employeeNo in amd_use1.EMPLOYEE_NO%type) return amd_users.BEMS_ID%type ;

    function GetOffBaseRepairCost(pPartno varchar2) return amd_part_locs.cost_to_repair%type ;
    function GetOffBaseTurnAround (pPartno varchar2) return amd_part_locs.time_to_repair%type ;

    type resultSetCursor is REF cursor ;
    function getNewUsers return resultSetCursor ;
    function insertUsersRow(bems_id in varchar2, stable_email in varchar2, last_name in varchar2, first_name in varchar2) return number ;
    function updateUsersRow(bems_id in varchar2, stable_email in varchar2, last_name in varchar2, first_name in varchar2) return number ;
    function deleteUsersRow(bems_id in varchar2) return number ;
    
    -- added 6/9/2006 by DSE
    procedure version ;
    
    -- added 10/30/2006 by DSE
    procedure validatePartStructure ;

    -- added 2/12/2007 by DSE
    -- send in nsn and part to get lock_sid 2
    -- send in mtbdr_computed for lock_sid = 0 
    -- send out mtbdr_computed for lock_sid = 2  (see Note below)
    --      Note: This field is calculated by BestSpares from demand and flight hours and is preferred by the user over 
    --      the RMADS MTBDR value.  It is not cleanable by the user, but can be recalculated by the user if they clean 
    --      flight hours.  BestSpares stores MTBDR_COMPUTED on Lock_SID = 2 when there is any cleaning info for the part
    --      and removes the values on Lock_SID = 0.  If there is no cleaning info for the part then MTBDR_COMPUTED is stored
    --      on Lock_SID = 0.   
    function getCalculatedData(nsn in amd_nsns.nsn%type,
         part_no in bssm_owner.bssm_parts.PART_NO%type) return amd_national_stock_items.mtbdr_computed%type ;
          
    -- add 3/28/2007 by dse
    function getOrderLeadTime(part in cat1.part%type) return number ;
    
    function getVersion return varchar2 ;
    
    procedure setBulkInsertThreshold(value in number) ; -- added 6/25/2008 by dse
    function getBulkInsertThreshold return number ; -- added 6/25/2008 by dse
    
    procedure setDebug(value in varchar2) ; -- added 6/30/2008 by dse
    function getDebug return varchar2 ; -- added 6/30/2008 by dse
    
    procedure setDebugThreshold(value in number := null) ;
    
    function getDebugThreshold return number ;
    
    procedure setStartDebugRec(value in number) ; -- added 11/25/2008
    function getStartDebugRec return number ; -- added 11/25/2008

end amd_load;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_LOAD;

CREATE PUBLIC SYNONYM AMD_LOAD FOR AMD_OWNER.AMD_LOAD;


GRANT EXECUTE ON AMD_OWNER.AMD_LOAD TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_LOAD TO AMD_WRITER_ROLE;


SET DEFINE OFF;
DROP PACKAGE BODY AMD_OWNER.AMD_LOAD;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.AMD_LOAD AS

/*
	    PVCS Keywords

       $Author:   zf297a  $
     $Revision:   1.77  $
         $Date:   15 Jul 2009 10:28:18  $
     $Workfile:   amd_load.pkb  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_load.pkb-arc  $
   
      Rev 1.76   15 Jul 2009 10:28:18   zf297a
   Removed a2a code
   
      Rev 1.75   06 Jul 2009 11:19:32   zf297a
   Used amd_isgp_rbl_pairs as the source for amd_rbl_pairs
   
      Rev 1.74   24 Feb 2009 15:08:58   zf297a
   eliminated part factors load of virtual loc's.
   
      Rev 1.73   14 Feb 2009 16:18:26   zf297a
   Removed invocation of any A2A procedure for package amd_location_part_override_pkg since all A2A code has been removed from that package.
   
      Rev 1.72   26 Nov 2008 07:50:08   zf297a
   Use new debugMsg procedure with a pError_location parameter to help locate the debugMsg in the code.  Also, added the autonomous transaction pragma.
   Inserted lots of debug code for loadGold.
   
   
      Rev 1.71   30 Sep 2008 10:59:52   zf297a
   Fixed getBemsId ... was not returning a bemsid when it should have for a C + bems_id.
   
      Rev 1.70   07 Jul 2008 10:01:28   zf297a
   Make the debugThreshold 1/10 of the size of amd_spare_partss when a null value is passed to the setDebugThreshold procedure.
   
      Rev 1.69   07 Jul 2008 09:17:18   zf297a
   Implemented interfaces getDebugThreshold and setDebugThreshold.  Added debug code to time routines.
   
      Rev 1.68   03 Jul 2008 23:40:30   zf297a
   Added bulk insert to loadGold and bulk update to loadMain and loadPsms.  Added timing dbms_output to loadGold.
   
      Rev 1.67   30 Jun 2008 15:25:44   zf297a
   Implemented setDebug, and getDebug.  Changed default for bulkInsertThreshold to 600.
   
      Rev 1.66   23 May 2008 13:10:44   zf297a
   Implemented  function getVersion.
   
      Rev 1.65   23 May 2008 13:06:34   zf297a
   Make sure that all planner_code exist in amd_planners where amd_planners.action_code <> 'D'
   
      Rev 1.64   07 Nov 2007 12:42:24   zf297a
   Added bulk collect to most cursors.
   
      Rev 1.63   12 Sep 2007 15:53:10   zf297a
   Removed commits from for loops.
   
      Rev 1.62   25 Aug 2007 21:49:32   zf297a
   Added hint to sql statement in boolean function onNsl to make sure Oracle uses the correct index in its execution plan.
   
      Rev 1.61   Aug 09 2007 10:49:52   c402417
   Added procedure LoadWecm to support Version 6.p with Consumables.
   
      Rev 1.60   Jul 04 2007 10:14:18   c402417
   Fixed the main where clause in LoadRblPairs select statement.
   
      Rev 1.59   24 Apr 2007 10:21:10   zf297a
   Modified algorithm of getCalculatedData:
   1. try getting cleaned data by nsn
   2. try getting cleaned data by part_no/nsn
   3. try getting original data by nsn
   4. try getting original data by part_no
   
      Rev 1.58   23 Apr 2007 16:42:04   zf297a
   Fixed getCalculatedData: 1st tried getting the cleaned data via nsn and verifying that either the nsn is currently active or that the part_no for the lock_sid 0 is currently active.
   If no data is not found try getting the lock sid 0 data and verifying that either the nsn is active or the part_no is active.
   If no data is found, try getting the  original data via part_no and verifying that either the nsn is active or the part is active.
   
      Rev 1.57   12 Apr 2007 09:29:24   zf297a
   Added commit threshold checks for all load routines.  Converted execute immediate to mta_truncate_table per DBA's recommendation.
   
      Rev 1.56   10 Apr 2007 16:20:02   zf297a
   Added Trim's to updateUsersRow for the Users diff
   
      Rev 1.55   10 Apr 2007 09:04:52   zf297a
   Made partNo varchar2 for getOffBaseTurnAround and getOffBaseRepairCost
   
      Rev 1.53   05 Apr 2007 00:37:20   zf297a
   Get rid of recursion error - getByPatNo
   
      Rev 1.52   04 Apr 2007 15:35:06   zf297a
   Fixed getCalculatedData to try getting mtbdr_computed in the following order:
   by nsn for cleaned data
   by nsn for original data
   by part for cleaned data
   by part for original data.
   
      Rev 1.51   03 Apr 2007 17:18:24   zf297a
   Fix getOriginalBssmData to try first by using the nsn and then using the part_no.
   
      Rev 1.50   02 Apr 2007 12:57:10   zf297a
   Replaced getOriginalBssmData with the new inferface that does not use the mtbdr_computed argument.
   
   Simplified the procedure getOriginalBssmData by only using one "select" and its exception handlers.
   
   Replaced procedure getCalulatedData with function getCalculatedData which takes two arguments: nsn and part_no and returns mtbdr_computed.
   
   Use the new getOriginalBssmData and getCalculatedData in procedure getBssmData.
   
   Implemented function getOrderLeadTime - it takes a trimmed part_no and retrives the order lead time from cat1 if it can find it otherwise it returns a null.
   
   Eliminated ave_cap_lead_time from the catCur cursor since that data is being retrieved by the function getOrderLeadTime
   
   Implemented functions getORIGINAL_DATA, getCLEANED_DATA, and getCURRENT_NSN to return their assocaited constants.
   
      Rev 1.49   Mar 05 2007 11:45:16   c402417
   Amd_spare_parts.order_lead-time is now getting data from Cat1 instead of tmp_main per Laurie.
   
      Rev 1.48   14 Feb 2007 13:52:26   zf297a
   Added amc_demand to getOrigianlBssmData and added amc_demand_cleaned to getCleanedBssmData. Implemented getCalculatedData to get mtbdr_computed.
   Added amc_demand and amc_demand_cleaned to getBssmData.  Added invocation of getCalculatedData to getBssmData.  Added amc_demand and amc_demand_cleaned to insert of tmp_amd_spare_parts.
   
      Rev 1.47   Jan 17 2007 16:22:14   c402417
   Added Procedure LoadRblPairs - This step is to populate the data to table AMD_RBL_PAIRS from the Gold database instead of using data from the FedLog.
   
      Rev 1.46   Nov 21 2006 10:16:08   zf297a
   Fixed insert of tmp_a2a_site_resp_asset_mgr
   
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
    type t_part_no_tab is table of tmp_amd_spare_parts.part_no%type ;
    
	THIS_PACKAGE 		   constant varchar2(8) := 'amd_load' ;
	THE_AMD_INVENTORY_PKG  constant varchar2(13) := 'amd_inventory' ;

	mDebug	 			     BOOLEAN := FALSE ;
    bulkInsertThreshold     number := 600 ;
    debugThreshold          number := 5000 ;
	startDebugRec	    number := 0 ;

	--
	-- procedure/Function bodies
	--
	PROCEDURE performLogicalDelete(
							pPartNo VARCHAR2);

     PROCEDURE debugMsg(msg IN AMD_LOAD_DETAILS.DATA_LINE%TYPE, pError_Location IN NUMBER) IS
        pragma autonomous_transaction ;
     BEGIN
       IF mDebug THEN
           Amd_Utils.debugMsg(pMsg => msg,pPackage => THIS_PACKAGE, pLocation => pError_location) ;
           COMMIT ; -- make sure the trace is kept
       END IF ;
     EXCEPTION WHEN OTHERS THEN
                IF SQLCODE = -14551 OR SQLCODE = -14552 THEN
                     NULL ; -- cannot do a commit inside a query, so ignore the error
               ELSE
                      RAISE ;
               END IF ;
     END debugMsg ;


	PROCEDURE errorMsg( sqlFunction IN VARCHAR2 := 'errorMsg',
		tableName IN VARCHAR2 := 'noname',
		pError_location IN NUMBER := -100,
		key1 IN VARCHAR2 := '',
 		key2 IN VARCHAR2 := '',
		key3 IN VARCHAR2 := '',
		key4 IN VARCHAR2 := '',
		key5 IN VARCHAR2 := '',
		keywordValuePairs IN VARCHAR2 := '')  IS

         	pragma autonomous_transaction ;

	BEGIN
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
			pKey_5 => key5 || ' ' || keywordValuePairs,
			pComments => 'sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')');
		commit;
		return ;
	END ErrorMsg;

	
	procedure writeMsg( pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
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
				if substr(wk_employeeNo,1,1) = 'C' then
					wk_employeeNo := substr(wk_employeeNo,2) ;
					if isNumber(wk_employeeNo) and length(wk_employeeNo) = 6 then
						wk_employeeNo := '0' || wk_employeeNo ;
					end if ;                            
				end if ;                    
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
						pError_location => 10,
						key1 => 'wk_employeeNo=' || wk_employeeNo ) ;
				RAISE ;
			end ;
		exception when others then
			ErrorMsg(sqlFunction => 'select',
				tableName => 'amd_people_all_v',
				pError_location => 20,
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
							pError_location => 30,
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
					pError_location => 40,
					key1 => 'wk_employeeNo=' || wk_employeeNo ) ;
				raise ;
			 else
			 	 dbms_output.put_line('getBemsId: sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm) ;
				 raise_application_error(-20001,'getBemsId: sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm || ' wk_employeeNo=' || wk_employeeNo ) ;
			 end if ;
			 return null ;
	 END getBemsId ;

	


	/* function GetOffBaseRepairCost, logic same as previous load version */
	FUNCTION  GetOffBaseRepairCost(pPartNo varchar2) RETURN AMD_PART_LOCS.cost_to_repair%TYPE IS
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
	FUNCTION GetOffBaseTurnAround (pPartno varchar2) RETURN AMD_PART_LOCS.time_to_repair%TYPE IS
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

		unitCost     NUMBER := 0 ;
	BEGIN
		for rec IN costCur loop
			unitCost := rec.cap_price;
			exit;
		end loop;

		return unitCost;
	END getUnitCost;


	FUNCTION getMmac(
			 		 				  pNsn  VARCHAR2) RETURN VARCHAR2 IS
			CURSOR macCur IS
				   SELECT nsn_smic
				   FROM NSN1
				   WHERE
				    	 nsn = pNsn;

		mMac	 VARCHAR2(2) := null ;
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

		SELECT /*+ INDEX(an amd_nsns_nk01) */
        COUNT(*)
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
		cnt   NUMBER :=  0;
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
        type primeRec is record (
            qNo number,
            part_type varchar2(15),
            part cat1.part%type,
            prime cat1.prime%type,
            manuf_cage cat1.manuf_cage%type
        ) ;
        type primeTab is table of primeRec ;
        primeRecs primeTab ;
        
		CURSOR primeCur IS
			SELECT DISTINCT
				1 qNo,
				DECODE(part,prime,'1 - Prime','2 - Equivalent') partType,
				part part,
				prime prime,
				manuf_cage
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

        open primeCur ;
        fetch primeCur bulk collect into primeRecs ;
        close primeCur ;
        
        if primeRecs.first is not null then
            FOR indx in primeRecs.first .. primeRecs.last LOOP
                --
                -- Set part of first rec as good prime in case good prime never shows.
                -- Funky logic used in Best Spares to determine good prime compares
                -- first 3 characters to determine good prime.
                --
                IF (firstPass) THEN
                    goodPrime := primeRecs(indx).part;
                    firstPass := FALSE;
                END IF;

                primePrefix := SUBSTR(primeRecs(indx).prime,1,3);
                char1       := SUBSTR(primeRecs(indx).prime,1,1);
                char2       := SUBSTR(primeRecs(indx).prime,2,1);
                char3       := SUBSTR(primeRecs(indx).prime,3,1);

                IF (primeRecs(indx).qNo = 1) THEN
                    IF (primeRecs(indx).part = primeRecs(indx).prime AND primeRecs(indx).manuf_cage = '88277') THEN
                        goodPrime := primeRecs(indx).prime;
                        priority := 6;
                    END IF;

                    IF (priority < 6 AND primeRecs(indx).part = primeRecs(indx).prime) THEN
                        goodPrime := primeRecs(indx).prime;
                        priority := 5;
                    END IF;

                    IF (priority < 5 AND primePrefix = '17B') THEN
                        goodPrime := primeRecs(indx).prime;
                        priority  := 4;
                    END IF;

                    IF (priority < 4 AND primePrefix = '17P') THEN
                        goodPrime := primeRecs(indx).prime;
                        priority  := 3;
                    END IF;

                    IF (priority < 3 AND ((char1 != '1' OR char2 != '7' OR
                                (char3 NOT IN ('P','B')))
                                AND (char1> '9' OR char1< '1' OR char2 != 'D'))) THEN
                        goodPrime := primeRecs(indx).prime;
                    END IF;
                END IF;

            END LOOP;
        end if ;            

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
		 nrts_avg out amd_national_stock_items.nrts_avg%type,
		 rts_avg out amd_national_stock_items.rts_avg%type,
         amc_demand out amd_national_stock_items.amc_demand%type) IS
         
         procedure getByPartNo is
         begin
	 		SELECT condemn, criticality, nrts, rts, amc_demand
        	INTO condemn_avg, criticality,  nrts_avg, rts_avg, amc_demand
        	FROM bssm_owner.bssm_parts bp, AMD_NSNS nsns
        	WHERE lock_sid = ORIGINAL_DATA
            and bp.part_no = getOriginalBssmData.part_no
            and bp.nsn = nsns.nsn
            and bp.nsn IN (SELECT nsn 
                               FROM AMD_NSNS 
                               WHERE nsi_sid = nsns.nsi_sid 
                               AND nsn_type = CURRENT_NSN) ;
        exception
            WHEN standard.NO_DATA_FOUND THEN
                condemn_avg := NULL ;
                criticality := NULL ;
                nrts_avg := NULL ;
                rts_avg := NULL ;
                amc_demand := null ;
        WHEN OTHERS THEN
            ErrorMsg(sqlFunction => 'select',
            	tableName => 'bssm_parts',
            	pError_location => 50,
            	key1 => 'part=' || getOriginalBssmData.part_no,
                key2 => 'nsn=' || getOriginalBssmData.nsn,
            	key3 => 'locksid=' || ORIGINAL_DATA);
            RAISE ;
         end getByPartNo ;


	begin
	 		SELECT condemn, criticality, nrts, rts, amc_demand
        	INTO condemn_avg, criticality,  nrts_avg, rts_avg, amc_demand
        	FROM bssm_owner.bssm_parts bp, AMD_NSNS nsns
        	WHERE lock_sid = ORIGINAL_DATA
            and nsns.nsn = getOriginalBssmData.nsn
            and bp.nsn IN (SELECT nsn 
                               FROM AMD_NSNS 
                               WHERE nsi_sid = nsns.nsi_sid 
                               AND nsn_type = CURRENT_NSN) ;
                
	EXCEPTION
        WHEN standard.NO_DATA_FOUND THEN
            getByPartNo ;
        WHEN OTHERS THEN
            ErrorMsg(sqlFunction => 'select',
            	tableName => 'bssm_parts',
            	pError_location => 60,
            	key1 => 'part=' || getOriginalBssmData.part_no,
                                  key2 => 'nsn=' || getOriginalBssmData.nsn,
            	key3 => 'locksid=' || ORIGINAL_DATA);
            RAISE ;
	end getOriginalBssmData ;

	function getCalculatedData(nsn in amd_nsns.nsn%type,
		 part_no in bssm_owner.bssm_parts.PART_NO%type) return amd_national_stock_items.mtbdr_computed%type is
         
         mtbdr_computed amd_national_stock_items.MTBDR_COMPUTED%type := null ;
         
         
         procedure getOriginalByPart is
         begin
	 		SELECT mtbdr_computed INTO mtbdr_computed
        	FROM bssm_owner.bssm_parts bp
        	WHERE bp.lock_sid = ORIGINAL_DATA
            and bp.part_no = getCalculatedData.part_no
            and (amd_utils.ISNSNACTIVEYORN(bp.nsn) = 'Y' or amd_utils.ISPARTACTIVEYORN(bp.part_no) = 'Y') ;
         exception
            when standard.no_data_found then
                null ;
            when others then
				ErrorMsg(sqlFunction => 'select',
					tableName => 'bssm_parts and amd_nsns',
					pError_location => 70,
					key1 => 'part=' || getCalculatedData.part_no,
                    key2 => 'nsn=' || getCalculatedData.nsn,
					key3 => 'locksid=' || ORIGINAL_DATA);
				RAISE ;
         end getOriginalByPart ;

         
         procedure getOriginalDataByNsn is
         begin
            select mtbdr_computed into mtbdr_computed 
            from bssm_parts p1 
            where nsn = getCalculatedData.nsn
            and lock_sid = ORIGINAL_DATA
            and mtbdr_computed is not null
            and (amd_utils.ISNSNACTIVEYORN(nsn) = 'Y' or amd_utils.ISPARTACTIVEYORN(part_no) = 'Y') ;
         exception 
            when standard.no_data_found then
                getOriginalByPart ;
            when others then
				ErrorMsg(sqlFunction => 'select',
					tableName => 'bssm_parts and amd_nsns',
					pError_location => 80,
					key1 => 'part=' || getCalculatedData.part_no,
                    key2 => 'nsn=' || getCalculatedData.nsn,
					key3 => 'locksid=' || ORIGINAL_DATA);
				RAISE ;
         end getOriginalDataByNsn ;
         
         procedure getCleanedDataByPart is
         begin
	 		SELECT mtbdr_computed INTO mtbdr_computed
        	FROM bssm_owner.bssm_parts bp
        	WHERE bp.lock_sid = CLEANED_DATA
            and mtbdr_computed is not null
            and bp.nsn = (select nsn 
                          from bssm_parts 
                          where part_no = getCalculatedData.part_no
                          and lock_sid = ORIGINAL_DATA)
            and (amd_utils.ISNSNACTIVEYORN(bp.nsn) = 'Y' or amd_utils.ISPARTACTIVEYORN(getCalculatedData.part_no) = 'Y') ;
         exception
            when standard.no_data_found then
                getOriginalDataByNsn ;
            when others then
				ErrorMsg(sqlFunction => 'select',
					tableName => 'bssm_parts and amd_nsns',
					pError_location => 90,
					key1 => 'part=' || getCalculatedData.part_no,
                    key2 => 'nsn=' || getCalculatedData.nsn,
					key3 => 'locksid=' || ORIGINAL_DATA);
				RAISE ;
         end getCleanedDataByPart ;
         
    begin
        select mtbdr_computed into mtbdr_computed 
        from bssm_parts p1 
        where nsn = getCalculatedData.nsn
        and lock_sid = CLEANED_DATA
        and mtbdr_computed is not null
        and (amd_utils.ISNSNACTIVEYORN(nsn) = 'Y' or
                exists (select null 
                        from bssm_parts p2
                        where p1.nsn = p2.nsn
                        and lock_sid = ORIGINAL_DATA
                        and amd_utils.isPartActiveYorN(p2.part_no) = 'Y') ) ;
                        
        return mtbdr_computed ;
    exception 
        when standard.no_data_found then
            getCleanedDataByPart ;
            return  mtbdr_computed ;                
            
		WHEN OTHERS THEN
				ErrorMsg(sqlFunction => 'select',
					tableName => 'bssm_parts and amd_nsns',
					pError_location => 100,
					key1 => 'part=' || getCalculatedData.part_no,
                    key2 => 'nsn=' || getCalculatedData.nsn,
					key3 => 'locksid=' || CLEANED_DATA);
				RAISE ;
    end getCalculatedData ;


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
		time_to_repair_off_base_cleand out amd_national_stock_items.time_to_repair_off_base_cleand%type,
        amc_demand_cleaned out amd_national_stock_items.amc_demand_cleaned%type) is
        
        line_no number := 0 ;

	begin
		line_no := line_no + 1 ; condemn_avg_cleaned := Amd_Clean_Data.GetCondemnAvg(nsn, part_no) ;
		line_no := line_no + 1 ;criticality_cleaned := Amd_Clean_Data.GetCriticality(nsn, part_no ) ;
		line_no := line_no + 1 ;mtbdr_cleaned := Amd_Clean_Data.GetMtbdr(nsn, part_no) ;
		line_no := line_no + 1 ;nrts_avg_cleaned := Amd_Clean_Data.GetNrtsAvg(nsn, part_no) ;
		line_no := line_no + 1 ;rts_avg_cleaned := Amd_Clean_Data.GetRtsAvg(nsn, part_no) ;
		line_no := line_no + 1 ;order_lead_time_cleaned := Amd_Utils.months2CalendarDays(Amd_Clean_Data.GetOrderLeadTime(nsn, part_no)) ;
		line_no := line_no + 1 ;planner_code_cleaned := upper(Amd_Clean_Data.GetPlannerCode(nsn, part_no)) ;
		line_no := line_no + 1 ;smr_code_cleaned := upper(Amd_Clean_Data.GetSmrCode(nsn, part_no)) ;
		line_no := line_no + 1 ;unit_cost_cleaned := Amd_Clean_Data.GetUnitCost(nsn, part_no) ;
		line_no := line_no + 1 ;cost_to_repair_off_base_cleand := Amd_Clean_Data.GetCostToRepairOffBase(nsn, part_no) ;
		line_no := line_no + 1 ;time_to_repair_off_base_cleand := Amd_Utils.months2CalendarDays(Amd_Clean_Data.GetTimeToRepairOffBase(nsn, part_no)) ;
        line_no := line_no + 1 ;amc_demand_cleaned := Amd_Clean_Data.GETAMCDEMAND(nsn) ;
    exception when others then
        ErrorMsg(sqlFunction => 'getCleanedBssmData',tableName => 'bssm_parts', pError_location => 110,
        	key1 => to_char(line_no), key2 => nsn, key3 => part_no);
        RAISE ;        
	end getCleanedBssmData ;
    

	PROCEDURE getBssmData(nsn in amd_nsns.nsn%type,
		part_no 		 in bssm_owner.bssm_parts.part_no%type,

		condemn_avg 	 out amd_national_stock_items.condemn_avg%type,
		criticality 	 out amd_national_stock_items.criticality%type,
		mtbdr_computed  out amd_national_stock_items.mtbdr_computed%type,
		nrts_avg 		 out amd_national_stock_items.nrts_avg%type,
		rts_avg 		 out amd_national_stock_items.rts_avg%type,
        amc_demand       out amd_national_stock_items.amc_demand%type,

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
		time_to_repair_off_base_cleand  out AMD_NATIONAL_STOCK_ITEMS.time_to_repair_off_base_cleand%TYPE,
        amc_demand_cleaned out amd_national_stock_items.amc_demand_cleaned%type) is

	BEGIN
		getOriginalBssmData(nsn => nsn, part_no => part_no, condemn_avg => condemn_avg,
		    criticality => criticality, nrts_avg => nrts_avg, rts_avg => rts_avg,
            amc_demand => amc_demand) ;

		getCleanedBssmData( nsn => nsn, part_no => part_no,
    		condemn_avg_cleaned => condemn_avg_cleaned,
    		criticality_cleaned => criticality_cleaned, mtbdr_cleaned => mtbdr_cleaned,
    		nrts_avg_cleaned => nrts_avg_cleaned, rts_avg_cleaned => rts_avg_cleaned,
    		order_lead_time_cleaned => order_lead_time_cleaned,
    		planner_code_cleaned => planner_code_cleaned, smr_code_cleaned => smr_code_cleaned,
    		unit_cost_cleaned => unit_cost_cleaned,
    		cost_to_repair_off_base_cleand => cost_to_repair_off_base_cleand,
    		time_to_repair_off_base_cleand => time_to_repair_off_base_cleand,
            amc_demand_cleaned => amc_demand_cleaned) ;
            
       mtbdr_computed := getCalculatedData(nsn => nsn, part_no => part_no) ; 
       planner_code_cleaned := amd_utils.validatePlannerCode(planner_code_cleaned) ;

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
			pError_location => 120,
			key1 => getRmadsData.part_no) ;
			RAISE ;
	END getRmadsData ;
    
    function getOrderLeadTime(part in cat1.part%type) return number is
        ave_cap_lead_time cat1.AVE_CAP_LEAD_TIME%type ;
    begin
			   SELECT ave_cap_lead_time into getOrderLeadTime.ave_cap_lead_time
			   FROM CAT1
			   WHERE part = (getOrderleadTime.part) ;
               
               if ave_cap_lead_time = 0 then
                    ave_cap_lead_time := null ;
               end if ;
               
               return ave_cap_lead_time ;
               
    exception when standard.no_data_found then
            return null ;
    end getOrderLeadTime ;
    
    procedure setDebugThreshold(value in number := null) is
    begin
        if value is null then
            select round(count(*) / 10) into debugThreshold from amd_spare_parts
            where action_code <> amd_defaults.getDELETE_ACTION ;            
        else
            debugThreshold := value ;
        end if ;                        
    exception when no_data_found then
        debugThreshold := 10000 ;        
    end setDebugThreshold ;

    procedure setStartDebugRec(value in number) is
    begin
	startDebugRec := value ;
    end setStartDebugRec ;

    function getStartDebugRec return number is
    begin
	return startDebugRec ;
    end getStartDebugRec ;
    
    function getDebugThreshold return number is
    begin
        return debugThreshold ;
    end getDebugThreshold ;        
    

	PROCEDURE LoadGold IS
    
        bulk_errors   EXCEPTION;
        PRAGMA EXCEPTION_INIT (bulk_errors, -24381);
        
        type tmpRecs is table of tmp_amd_spare_parts%rowtype index by pls_integer ;
        recsOut tmpRecs ;
        
        type catRec is record (
            nsn cat1.nsn%type,
            part_type varchar2(10),
            part cat1.part%type,
            prime cat1.prime%type,
            manuf_cage cat1.manuf_cage%type,
            source_code cat1.source_code%type,
            noun cat1.noun%type,
            serial_mandatory_b cat1.serial_mandatory_b%type,
            ims_designator_code cat1.ims_designator_code%type,
            smrc cat1.smrc%type,
            um_cap_code cat1.um_cap_code%type,
            user_ref7 cat1.user_ref7%type,
            um_show_code cat1.um_show_code%type            
        ) ;
        type catTab is table of catRec ;
        catRecs catTab ;
        
		CURSOR catCur IS
			SELECT
				nsn,
				DECODE(prime,part,'PRIME','EQUIVALENT') partType,
				part,
				prime,
				manuf_cage,
				source_code,
				noun,
				serial_mandatory_b,
				ims_designator_code,
				smrc,
				um_cap_code,
				user_ref7,
				um_show_code
			FROM CAT1
			WHERE
				source_code = 'F77'
				AND nsn NOT LIKE 'N%'
			UNION
			SELECT
			nsn,
				DECODE(prime,part,'PRIME','EQUIVALENT') partType,
				part,
				prime,
				manuf_cage,
				source_code,
				noun,
				serial_mandatory_b,
				ims_designator_code,
				smrc,
				um_cap_code,
				TRIM(user_ref7) user_ref7,
				um_show_code
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
		orderleadTime NUMBER;
		plannerCode   VARCHAR2(8);
		nsnType       VARCHAR2(1);
		hasPrimeRec   BOOLEAN;
		sequenced     BOOLEAN;
		l67Mic        VARCHAR2(1);
		unitCost      NUMBER;
		unitOfIssue	  VARCHAR2(2);
		mMac		  VARCHAR2(2);
		rowsInserted NUMBER := 0 ;
        loadGoldStartTime number := dbms_utility.get_time ;
        loopStartTime number := 0 ;
	    cur_line    number := 0 ;
	BEGIN
	    writeMsg(pTableName => 'tmp_amd_spare_parts', pError_location => 130,
				pKey1 => 'loadGold',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		Mta_Truncate_Table('tmp_amd_spare_parts','reuse storage');
		Mta_Truncate_Table('tmp_a2a_part_info','reuse storage');
		Mta_Truncate_Table('tmp_a2a_part_lead_time','reuse storage');
		Mta_Truncate_Table('tmp_a2a_part_pricing','reuse storage');
		Mta_Truncate_Table('tmp_a2a_bom_detail','reuse storage');
		Mta_Truncate_Table('tmp_a2a_part_effectivity','reuse storage');

		loadNo := Amd_Utils.GetLoadNo('GOLD','TMP_AMD_SPARE_PARTS');

        open catCur ;
        fetch catCur bulk collect into catRecs ;
        close catCur ;
        
        if catRecs.first is not null then
	    debugMsg('process cat1 recs', pError_location => 140) ;
            FOR indx in catRecs.first .. catRecs.last LOOP
        <<cat1_proc>>
		begin
			loopStartTime := dbms_utility.get_time ;
			IF (catRecs(indx).nsn LIKE 'NSL%') THEN
			    sequenced := TRUE;
			    nsn := Amd_Nsl_Sequence_Pkg.SequenceTheNsl(catRecs(indx).prime);
			ELSE
			    sequenced := FALSE;
			    nsn := catRecs(indx).nsn;
			END IF;
			cur_line := 10 ;

			IF (nsn != prevNsn) THEN
			    prevNsn     := nsn;
			    nsnStripped := Amd_Utils.FormatNsn(nsn);

			    -- If sequenceTheNsl() returned an NSL$ then it is assumed to be
			    -- the prime, otherwise, run it through the getPrime() logic.
			    --
			    IF (nsn LIKE 'NSL%') THEN
                    		IF (NOT onNsl(catRecs(indx).part)) THEN
		                        -- An NSL starts the part/nsn process so 'delete' the part
               		         	-- so the diff will think it's a brand new part and
	                       		 -- assign it its own nsi_sid.
		                        --
       	        		         performLogicalDelete(catRecs(indx).part);
		                    END IF;
				    goodPrime := catRecs(indx).part;
			    ELSE
				    goodPrime := GetPrime(nsn);
			    END IF;
			    cur_line := 20 ;

			    nsnType     := 'C';
			    cur_line := 30 ;
			    plannerCode := amd_utils.validatePlannerCode(catRecs(indx).ims_designator_code) ;
			    cur_line := 40 ;
			    itemType    := NULL;
			    cur_line := 50 ;
			    smrCode     := catRecs(indx).smrc;

			    cur_line := 60 ;
			    if length(catRecs(indx).um_show_code) <= 2 then
			    	unitOfIssue := catRecs(indx).um_show_code;
			   elsif length(catRecs(indx).um_show_code) > 2 then
				if upper(catRecs(indx).um_show_code) = 'KIT' then				
					unitOfIssue := 'KT' ;
				else
					unitOfIssue := substr(catRecs(indx).um_show_code,1,2) ;
				end if ;
			    end if ;
										
			    cur_line := 70 ;
			    if length(catRecs(indx).um_cap_code) <= 2 then
			    	orderUom := catRecs(indx).um_cap_code;
			    else
				if length(catRecs(indx).um_cap_code) > 2 then
					orderUom := substr(catRecs(indx).um_cap_code,1,2) ;
				end if ;
			    end if ;

			    cur_line := 80 ;

			    IF (IsValidSmr(smrCode)) THEN
				    itemType := GetItemType(smrCode);
			    END IF;

			END IF;

			-- if GetPrime() returned a null that means that the nsn no longer
			-- exists in Gold. This happens when a part goes from an NCZ to an NSL
			--
			IF (goodPrime IS NULL OR catRecs(indx).part = goodPrime) THEN
			    primeInd := 'Y';
			ELSE
			    primeInd := 'N';
			END IF;

			cur_line := 90 ;

			l67Mic   := getMic(nsnStripped);
			cur_line := 100 ;

			unitCost := getUnitCost(catRecs(indx).part);
			cur_line := 110 ;

			mMac := getMmac(catRecs(indx).nsn);
			cur_line := 120 ;

			if mDebug 
			and (rowsInserted > startDebugRec or mod(indx,debugThreshold) = 0) then
			    debugMsg('rowsInserted=' || rowsInserted 
				|| ' part=' || catRecs(indx).part
				|| ' time:' || (dbms_utility.get_time - loopStartTime), pError_location => 150) ;
			end if ;                    

	exception when others then
            ErrorMsg(sqlFunction => 'select', tableName => 'cat1', key1 => catRecs(indx).part,
			key2 => 'cur_line=' || cur_line,
                       pError_location => 160) ;
            raise ;
        end cat1_proc ;

                -- 4/13/05 DSE created insertTmpAmdSpareParts block of code
                <<insertTmpAmdSpareParts>>
                DECLARE
                       mtbdr                           AMD_NATIONAL_STOCK_ITEMS.mtbdr%TYPE ;
                       mtbdr_cleaned                   AMD_NATIONAL_STOCK_ITEMS.mtbdr_cleaned%TYPE ;
                       qpei_weighted                   AMD_NATIONAL_STOCK_ITEMS.qpei_weighted%TYPE ;
                       condemn_avg                       AMD_NATIONAL_STOCK_ITEMS.condemn_avg%TYPE ;
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
                       cost_to_repair_off_base            AMD_NATIONAL_STOCK_ITEMS.cost_to_repair_off_base%TYPE ;
                       time_to_repair_off_base         AMD_NATIONAL_STOCK_ITEMS.time_to_repair_off_base%TYPE ;
                       mtbdr_computed                   amd_national_stock_items.mtbdr_computed%type ;
                       amc_demand                      amd_national_stock_items.amc_demand%type ;
                       amc_demand_cleaned              amd_national_stock_items.amc_demand_cleaned%type ;
                       
                       procedure addRec(indx in number) is
                       begin
                           recsOut(indx).part_no := catRecs(indx).part ; cur_line := 130 ;
                           recsOut(indx).mfgr := catRecs(indx).manuf_cage ; cur_line := 140 ;
                           recsOut(indx).icp_ind := catRecs(indx).source_code ; cur_line := 150 ;
                           recsOut(indx).item_type := itemType ; cur_line := 160 ;
                           recsOut(indx).nomenclature :=  catRecs(indx).noun ; cur_line := 170 ;
                           recsOut(indx).nsn :=  nsnStripped ; cur_line := 180 ;
                           recsOut(indx).nsn_type :=  nsnType ; cur_line := 190 ;
                           recsOut(indx).planner_code :=  plannerCode ; cur_line := 200 ;

			   if length(catRecs(indx).um_cap_code) <= 2 then
                           	recsOut(indx).order_uom :=  catRecs(indx).um_cap_code ; cur_line := 210 ;
			   else
				if length(catRecs(indx).um_cap_code) > 2 then
					recsOut(indx).order_uom := substr(catRecs(indx).um_cap_code,1,2) ;
				end if ;
			   end if ;
                           recsOut(indx).order_lead_time :=  amd_utils.bizDays2CalendarDays(getOrderLeadTime(catRecs(indx).part)) ; cur_line := 220 ;
                           recsOut(indx).prime_ind :=  primeInd ; cur_line := 230 ;
                           recsOut(indx).serial_flag :=  catRecs(indx).serial_mandatory_b ; cur_line := 240 ;
                           recsOut(indx).smr_code :=  smrCode ; cur_line := 250 ;
                           recsOut(indx).acquisition_advice_code :=  catRecs(indx).user_ref7 ; cur_line := 260 ;
                           recsOut(indx).unit_cost :=  unitCost ; cur_line := 270 ;
                           recsOut(indx).mic :=  l67Mic ; cur_line := 280 ;
                           recsOut(indx).mmac :=  mMac ; cur_line := 290 ;
                           recsOut(indx).unit_of_issue :=  unitOfIssue ; cur_line := 300 ;
                           recsOut(indx).mtbdr :=  mtbdr ; cur_line := 310 ;
                           recsOut(indx).mtbdr_computed :=  mtbdr_computed ; cur_line := 320 ;
                           recsOut(indx).mtbdr_cleaned :=  mtbdr_cleaned ; cur_line := 330 ;
                           recsOut(indx).qpei_weighted :=  qpei_weighted ; cur_line := 340 ;
                           recsOut(indx).condemn_avg :=  condemn_avg ; cur_line := 350 ;
                           recsOut(indx).condemn_avg_cleaned :=  condemn_avg_cleaned ; cur_line := 360 ;
                           recsOut(indx).criticality :=  criticality ; cur_line := 370 ;
                           recsOut(indx).criticality_cleaned :=  criticality_cleaned ; cur_line := 380 ;
                           recsOut(indx).nrts_avg_cleaned :=  nrts_avg_cleaned ; cur_line := 390 ;
                           recsOut(indx).nrts_avg :=  nrts_avg ; cur_line := 400 ;
                           recsOut(indx).time_to_repair_off_base_cleand :=  time_to_repair_off_base_cleand ; cur_line := 410 ;
                           recsOut(indx).order_lead_time_cleaned :=  order_lead_time_cleaned ; cur_line := 420 ;
                           recsOut(indx).planner_code_cleaned :=  planner_code_cleaned ; cur_line := 430 ;
                           recsOut(indx).rts_avg :=  rts_avg ; cur_line := 440 ;
                           recsOut(indx).rts_avg_cleaned :=  rts_avg_cleaned ; cur_line := 450 ;
                           recsOut(indx).smr_code_cleaned :=  smr_code_cleaned ; cur_line := 460 ;
                           recsOut(indx).unit_cost_cleaned :=  unit_cost_cleaned ; cur_line := 470 ;
                           recsOut(indx).cost_to_repair_off_base :=  cost_to_repair_off_base ;  cur_line := 480 ;
                           recsOut(indx).time_to_repair_off_base :=  time_to_repair_off_base ;  cur_line := 490 ;
                           recsOut(indx).amc_demand :=  amc_demand ;  cur_line := 500 ;
                           recsOut(indx).amc_demand_cleaned :=  amc_demand_cleaned ; cur_line := 510 ;
                           recsOut(indx).last_update_dt := sysdate ;                        
			exception
				WHEN OTHERS THEN
					ErrorMsg(sqlFunction => 'addRec',
						tableName => 'tmp_amd_spare_parts',
						pError_location => 170,
						key1 => catRecs(indx).part,
						key2 => 'cur_line=' || cur_line) ;
					raise ;
                       end addRec ;


                BEGIN
                     getBssmData(nsn => nsnStripped, part_no => catRecs(indx).part,
                        condemn_avg => condemn_avg, criticality => criticality,  mtbdr_computed => mtbdr_computed,
                        nrts_avg => nrts_avg, rts_avg => rts_avg, amc_demand => amc_demand,
                        condemn_avg_cleaned => condemn_avg_cleaned, criticality_cleaned => criticality_cleaned,
                        mtbdr_cleaned => mtbdr_cleaned, nrts_avg_cleaned => nrts_avg_cleaned,
                        rts_avg_cleaned => rts_avg_cleaned, order_lead_time_cleaned => order_lead_time_cleaned,
                        planner_code_cleaned => planner_code_cleaned, smr_code_cleaned => smr_code_cleaned,
                        unit_cost_cleaned => unit_cost_cleaned,
                        cost_to_repair_off_base_cleand => cost_to_repair_off_base_cleand,
                        time_to_repair_off_base_cleand => time_to_repair_off_base_cleand,
                        amc_demand_cleaned => amc_demand_cleaned) ;
                     
                     getRmadsData(part_no => catRecs(indx).part, qpei_weighted => qpei_weighted, mtbdr=> mtbdr) ;

		     cur_line := 520 ;
                     IF primeInd = 'Y' THEN
		     	cur_line := 530 ;
                        cost_to_repair_off_base := GetOffBaseRepairCost(catRecs(indx).part);
		     	cur_line := 540 ;
                        time_to_repair_off_base := GetOffBaseTurnAround(catRecs(indx).part);
                     END IF ;
                     
		    cur_line := 550 ;
                    rowsInserted := rowsInserted + 1 ;
		    cur_line := 560 ;
                    addRec(rowsInserted) ;                    
		    cur_line := 570 ;
                    if recsOut.count >= bulkInsertThreshold then
                        forall i in recsOut.first .. recsOut.last
                            save exceptions
                            insert into tmp_amd_spare_parts values recsOut(i) ;
                        recsOut.delete ;                                                                                
                    end if ;
		    cur_line := 580 ;
                    if mod(indx,debugThreshold) = 0 then
                        debugMsg('indx=' || indx 
				|| ' part=' || catRecs(indx).part,
				pError_location => 180) ;
                    end if ;                    
                EXCEPTION
                     when bulk_errors then
                        for j in 1 .. sql%bulk_exceptions.count loop
                            ErrorMsg(sqlFunction => 'insert',
                                tableName => 'tmp_amd_spare_parts',
                                pError_location => 190,
                                key1 => 'index=' || to_char(sql%bulk_exceptions(j).error_index),
                                key2 => sqlerrm(sql%bulk_exceptions(j).error_code) )  ;
                        end loop ;
                        raise ;
                     WHEN OTHERS THEN
                                ErrorMsg(sqlFunction => 'insert',
                                    tableName => 'tmp_amd_spare_parts',
                                    pError_location => 200,
                                    key1 => nsnStripped,
                                    key2 => catRecs(indx).part,
                                    key3 => catRecs(indx).manuf_cage,
                                    key4 => 'cur_line=' || cur_line) ;
                            RAISE ;

                END insertTmpAmdSpareParts ;

		cur_line := 590 ;

                if mod(indx,debugThreshold) = 0 then
                    debugMsg('indx=' || indx 
			|| ' part=' || catRecs(indx).part,
			pError_location => 210) ;
                end if ;                    

                --end loop;
            END LOOP;

            debugmsg('end cat1 loop', pError_location => 220) ;

            <<bulk_insert>>
            begin
                forall i in recsOut.first .. recsOut.last
                    save exceptions
                    insert into tmp_amd_spare_parts values recsOut(i) ;
            exception                
             when bulk_errors then
                for j in 1 .. sql%bulk_exceptions.count loop
                    ErrorMsg(sqlFunction => 'insert',
                        tableName => 'tmp_amd_spare_parts',
                        pError_location => 230,
                        key1 => 'index=' || to_char(sql%bulk_exceptions(j).error_index),
                        key2 => sqlerrm(sql%bulk_exceptions(j).error_code) )  ;
                end loop ;
                raise ;
            end bulk_insert ;                
                
        end if ;
                    
        writeMsg(pTableName => 'tmp_amd_spare_parts', pError_location => 240,
            pKey1 => 'loadGold',
            pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
            pKey3 => 'rowsInserted=' || to_char(rowsInserted),
            pKey4 => 'elapsedTime=' || (dbms_utility.get_time - loadGoldStartTime)) ;

            dbms_output.put_line('loadGold min:' || ((dbms_utility.get_time - loadGoldStartTime) / 60));

        COMMIT ;

    EXCEPTION
         WHEN OTHERS THEN
            ErrorMsg(sqlFunction => 'loadGold',
                tableName => 'tmp_amd_spare_parts',
                pError_location => 250,
		key1 => 'cur_line=' || cur_line) ;
            dbms_output.put_line('loadGold had an error - check amd_load_details. rowsInserted=' || rowsInserted) ;
            RAISE ;    
                
    
    END LoadGold;
    
    
    
    PROCEDURE LoadRblPairs IS
    BEGIN
         mta_truncate_table('AMD_RBL_PAIRS','reuse storage') ;
         
         
    --Populate data into table AMD_RBL_PAIRS
    <<insertRblPairs>>
    BEGIN
         INSERT INTO AMD_RBL_PAIRS
         (
                   old_nsn,
                   new_nsn, 
                subgroup_code, 
                part_pref_code, 
                last_update_dt, 
                action_code
         )
         SELECT 
                old_nsn, 
                new_nsn, 
                subgroup_code, 
                part_pref_code, 
                sysdate , 
                'A'
        FROM amd_isgp_rbl_pairs_v 
        COMMIT;
        END insertRblPairs ;
    END LoadRblPairs ;



    PROCEDURE LoadPsms IS
        type psmsRec is record (
            part_no tmp_amd_spare_parts.part_no%type,
            mfgr tmp_amd_spare_parts.mfgr%type,
            smr_code tmp_amd_spare_parts.smr_code%type,
            item_type tmp_amd_spare_parts.item_type%type
        ) ;
        type psmsTab is table of psmsRec ;
        psmsRecs psmsTab ;
        
        type t_shelf_life_tab is table of tmp_amd_spare_parts.SHELF_LIFE%type ;
        type t_unit_volume_tab is table of tmp_amd_spare_parts.UNIT_VOLUME%type ;
        type t_smr_code_tab is table of tmp_amd_spare_parts.SMR_CODE%type ;
        type t_item_type_tab is table of tmp_amd_spare_parts.ITEM_TYPE%type ;
        
        shelf_life_tab t_shelf_life_tab := t_shelf_life_tab() ;
        unit_volume_tab t_unit_volume_tab := t_unit_volume_tab() ;
        smr_code_tab t_smr_code_tab := t_smr_code_tab() ;
        item_type_tab t_item_type_tab := t_item_type_tab() ;
        part_no_tab t_part_no_tab := t_part_no_tab() ;
        
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
        cnt              number := 0 ;
        loadPsmsStartTime number := dbms_utility.get_time ;        
    BEGIN

        writeMsg(pTableName => 'tmp_amd_spare_parts', pError_location => 260,
                pKey1 => 'loadPsms',
                pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
        --
        --     Get the load_no for insert into amd_load_status table
        --
        loadNo := Amd_Utils.GetLoadNo('PSMS','TMP_AMD_SPARE_PARTS');

        --
        -- select ICP Part/CAGE and check to see if the part is existing in PSMS.
        --
        open f77 ;
        fetch f77 bulk collect into psmsRecs ;
        close f77 ;
        if psmsRecs.first is not null then
            FOR indx in psmsRecs.first .. psmsRecs.last LOOP

                psmsInstance := GetPsmsInstance(psmsRecs(indx).part_no,psmsRecs(indx).mfgr);

                IF (psmsInstance IS NOT NULL) THEN

                    GetPsmsData(psmsRecs(indx).part_no,psmsRecs(indx).mfgr,psmsInstance,
                                        sLifeDay,unitVol,smrCode);

                    IF (IsValidSmr(smrCode)) THEN
                        itemType := GetItemType(smrCode);
                    ELSE
                        smrCode  := psmsRecs(indx).smr_code;
                        itemType := psmsRecs(indx).item_type;
                    END IF;
    
                    shelf_life_tab.extend ;
                    unit_volume_tab.extend ;
                    smr_code_tab.extend ;
                    item_type_tab.extend ;
                    part_no_tab.extend ;
                    
                    shelf_life_tab(shelf_life_tab.last) := sLifeDay ;
                    unit_volume_tab(unit_volume_tab.last) := unitVol ;
                    smr_code_tab(smr_code_tab.last) := smrCode ;                    
                    item_type_tab(item_type_tab.last) := itemType ;
                    part_no_tab(part_no_tab.last) := psmsRecs(indx).part_no ;
                    /*
                    UPDATE TMP_AMD_SPARE_PARTS SET
                        shelf_life     = sLifeDay,
                        unit_volume    = unitVol,
                        smr_code    = smrCode,
                        item_type      = itemType
                    WHERE
                        part_no  = psmsRecs(indx).part_no
                        AND smr_code IS NULL;
                    */    
                     cnt := cnt + 1 ;

                END IF;

            END LOOP;
            forall i in shelf_life_tab.first .. shelf_life_tab.last 
                update tmp_amd_spare_parts
                    set shelf_life = shelf_life_tab(i),
                    unit_volume = unit_volume_tab(i),
                    smr_code = smr_code_tab(i),
                    item_type = item_type_tab(i)
                where part_no = part_no_tab(i)
                and smr_code is null ;                
        end if ;            
        
        writeMsg(pTableName => 'tmp_amd_spare_parts', pError_location => 270,
                pKey1 => 'loadPsms',
                pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => 'rowsUpdated=' || to_char(cnt),
                pKey4 => 'elapsedTime=' || (dbms_utility.get_time - loadPsmsStartTime)) ;
                
        commit ;
        debugMsg('loadPsms secs:' 
		|| (dbms_utility.get_time - loadPsmsStartTime), pError_location => 280);

    END LoadPsms;
    
    
    
    

    PROCEDURE LoadMain IS
        type mainRec is record (
            part_no tmp_amd_spare_parts.part_no%type,
            nsn tmp_amd_spare_parts.nsn%type,
            prime_ind tmp_amd_spare_parts.prime_ind%type,
            smrCode6 varchar2(1)
        ) ;
        type mainTab is table of mainRec ;
        mainRecs mainTab ;
        
        type t_order_quantity_tab is table of tmp_amd_spare_parts.ORDER_QUANTITY%type ;
        order_quantity_tab t_order_quantity_tab := t_order_quantity_tab() ;
        part_no_tab t_part_no_tab := t_part_no_tab() ;
        
        
        CURSOR f77Cur IS
            SELECT
                part_no,
                nsn,
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
        loadMainStartTime number := dbms_utility.get_time ;
        
        
    BEGIN

        writeMsg(pTableName => 'tmp_amd_spare_parts', pError_location => 290,
                pKey1 => 'loadMain',
                pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
        --
        --     Get the load_no for insert into amd_load_status table
        --
        loadNo := Amd_Utils.GetLoadNo('MAIN','TMP_AMD_SPARE_PARTS');

        open f77Cur ;
        fetch f77Cur bulk collect into mainRecs ;
        close f77Cur ;
        
        if mainRecs.first is not null then
            FOR indx in mainRecs.first .. mainRecs.last LOOP

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
                        part_no = mainRecs(indx).part_no
                        AND LENGTH(SUBSTR(po_no,1,INSTR(po_no,' ')-1)) = 9;

                    --
                    -- get latest PO
                    --
                    SELECT
                        MAX(po_no)
                    INTO maxPo
                    FROM TMP_MAIN
                    WHERE
                        part_no     = mainRecs(indx).part_no
                        AND po_date = TO_CHAR(maxPoDate,'RRMMDD')
                        AND LENGTH(SUBSTR(po_no,1,INSTR(po_no,' ')-1)) = 9;

                    SELECT
                        --total_lead_time,  -- getting lead_time from Cat1 table  3/1/07
                        order_qty
                    INTO
                        --leadTime,
                        orderQuantity
                    FROM TMP_MAIN
                    WHERE
                        part_no     = mainRecs(indx).part_no
                        AND po_date = TO_CHAR(maxPoDate,'RRMMDD')
                        AND po_no   = maxPo
                        AND LENGTH(SUBSTR(po_no,1,INSTR(po_no,' ')-1)) = 9;
                                    
        

                        -- We apply the order_quantity we got from the prime part
                    -- to all the equivalent parts so we only set it here when the
                    -- prime rec comes in.  The prime rec is the first rec in the
                    -- nsn series due to the sort order of the cursor.
                    --
                    IF (mainRecs(indx).nsn != prevNsn) THEN
                        prevNsn := mainRecs(indx).nsn;
                        orderQty := orderQuantity;
                    END IF;

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        orderQuantity := NULL;
        --                leadTime      := NULL;
        --                orderUom      := NULL;
                END;

                order_quantity_tab.extend ;
                part_no_tab.extend ;
                order_quantity_tab(order_quantity_tab.last) := orderQty ;
                part_no_tab(part_no_tab.last) := mainRecs(indx).part_no ;
                
                /*
                UPDATE TMP_AMD_SPARE_PARTS SET
        --            order_lead_time = Amd_Utils.bizDays2CalendarDays(leadTime),
        --            order_uom = orderUom,
                    order_quantity  = orderQty
                WHERE
                    part_no       = mainRecs(indx).part_no;
                 */   
                 cnt := cnt + 1 ;

            END LOOP;
            
            forall i in order_quantity_tab.first .. order_quantity_tab.last 
                update tmp_amd_spare_parts
                    set order_quantity = order_quantity_tab(i)
                where part_no = part_no_tab(i) ;
                
        end if ;

        writeMsg(pTableName => 'tmp_amd_spare_parts', pError_location => 300,
        pKey1 => 'loadMain',
        pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
        pKey3 => 'rowsUpdated=' || to_char(cnt) ) ;
        
        commit ;

    END LoadMain;
    
    PROCEDURE LoadWecm IS 
    BEGIN
       
            BEGIN
                UPDATE tmp_amd_spare_parts
                set wesm_indicator = 'Y'
                where (substr(nsn,5,9)) in (SELECT distinct w1.niin
                                          FROM L11 w1, active_niins w2, tmp_amd_spare_parts w3
                                          WHERE w1.niin = w2.niin
                                          and w1.niin = substr(w3.nsn,5,9))
                and prime_ind = 'Y';
            END;
    END LoadWecm;

    PROCEDURE LoadTempNsns IS
        RAW_DATA  NUMBER:=0;

        type nsnRec is record (
            part amd_spare_parts.part_no%type,
            nsnTemp mils.status_line%type,
            dataSource varchar2(4)
        ) ;
        type nsnTab is table of nsnRec ;
        nsnRecs nsnTab ;
        
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
        cnt       NUMBER := 0;
    BEGIN
        writeMsg(pTableName => 'amd_nsns', pError_location => 310,
        pKey1 => 'loadTempNsns',
        pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
        
        loadNo := Amd_Utils.GetLoadNo('MILS','AMD_NSNS');

        open tempNsnCur ;
        fetch tempNsnCur bulk collect into nsnRecs ;
        close tempNsnCur ;
        
        if nsnRecs.first is not null then
            FOR indx in nsnRecs.first .. nsnRecs.last LOOP
                BEGIN

                    IF (nsnRecs(indx).nsnTemp = 'NSL') THEN
                        nsn := Amd_Nsl_Sequence_Pkg.SequenceTheNsl(nsnRecs(indx).part);
                    ELSIF (nsnRecs(indx).nsnTemp LIKE 'NSL#%') THEN
                        nsn := nsnRecs(indx).nsnTemp;
                    ELSE
                        -- Need to ignore last 2 char's of nsn from MILS if not numeric.
                        -- So if last 2 characters are not numeric an exception will
                        -- occur and the nsn will be truncated to 13 characters.
                        --
                        nsn := nsnRecs(indx).nsnTemp;
                        IF (nsnRecs(indx).dataSource = 'MILS') THEN
                            BEGIN
                                mmacCode := SUBSTR(nsn,14,2);
                            EXCEPTION
                                WHEN OTHERS THEN
                                    nsn := SUBSTR(nsn,1,13);
                            END;
                        END IF;
                    END IF;

                    nsiSid := Amd_Utils.GetNsiSid(pPart_no=>nsnRecs(indx).part);

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
        
                cnt := cnt + 1 ;

            END LOOP;
        end if ;            
        
        writeMsg(pTableName => 'amd_nsns', pError_location => 320,
        pKey1 => 'loadTempNsns',
        pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
        pKey3 => 'cnt=' || to_char(cnt) ) ;
        commit ;

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
                errorMsg(sqlFunction => 'update', tableName => 'amd_planners', pError_location => 330,
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
            errorMsg(sqlFunction => 'insert', tableName => 'amd_planners', pError_location => 340,
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
           errorMsg(sqlFunction => 'update', tableName => 'amd_planners', pError_location => 350,
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
           errorMsg(sqlFunction => 'update', tableName => 'amd_planners', pError_location => 360,
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
                  set stable_email = trim(insertUsersRow.stable_email),
                  last_name = trim(insertUsersRow.last_name),
                  first_name = trim(insertUsersRow.first_name),
                  action_code = amd_defaults.INSERT_ACTION,
                  last_update_dt = sysdate
                  where bems_id = insertUsersRow.bems_id ;
             exception when others then
               errorMsg(sqlFunction => 'update', tableName => 'amd_users', pError_location => 370,
                       key1 => bems_id) ;
               RAISE ;
             end doUpdate ;
    BEGIN
         INSERT INTO AMD_USERS
         (bems_id, stable_email, last_name, first_name, action_code, last_update_dt)
         VALUES (trim(bems_id), trim(stable_email), trim(last_name), trim(first_name),  Amd_Defaults.INSERT_ACTION, SYSDATE) ;
         RETURN SUCCESS ;
    EXCEPTION
        when standard.dup_val_on_index then
             doUpdate ;
             return success ;
        WHEN OTHERS THEN
           errorMsg(sqlFunction => 'insert', tableName => 'amd_users', pError_location => 380,
                   key1 => bems_id) ;
           RAISE ;
    END insertUsersRow ;

    FUNCTION updateUsersRow(bems_id IN VARCHAR2, stable_email IN VARCHAR2, last_name IN VARCHAR2, first_name IN VARCHAR2) RETURN NUMBER IS
    BEGIN
         UPDATE AMD_USERS
         SET stable_email = trim(updateUsersRow.stable_email),
         last_name = trim(updateUsersRow.last_name),
         first_name = trim(updateUsersRow.first_name),
         action_code = Amd_Defaults.UPDATE_ACTION,
         last_update_dt = SYSDATE
         WHERE bems_id = updateUsersRow.bems_id ;
         RETURN SUCCESS ;
    EXCEPTION WHEN OTHERS THEN
           errorMsg(sqlFunction => 'update', tableName => 'amd_users', pError_location => 390,
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
           errorMsg(sqlFunction => 'select', tableName => 'amd_users', pError_location => 400,
                   key1 => bems_id) ;
           RAISE ;
         END getData ;

         RETURN SUCCESS ;
    EXCEPTION WHEN OTHERS THEN
           errorMsg(sqlFunction => 'update', tableName => 'amd_users', pError_location => 410,
                   key1 => bems_id) ;
           RAISE ;
    END deleteUsersRow ;

    PROCEDURE loadUsers IS
    
              type bemsIdTab is table of amd_users.bems_id%type ;
              bemsIdRecs bemsIdTab ;
        
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
        writeMsg(pTableName => 'amd_users', pError_location => 420,
                pKey1 => 'loadUsers',
                pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
                
        Mta_Truncate_Table('tmp_a2a_spo_users','reuse storage');

         open newUsers ;
         fetch newUsers bulk collect into bemsIdRecs ;
         close newUsers ;
         
         if bemsIdRecs.first is not null then 
             FOR indx in bemsIdRecs.first .. bemsIdRecs.last LOOP
                 IF bemsIdRecs(indx) IS NOT NULL THEN
                   <<insertAmdUsers>>
                   BEGIN
                     INSERT INTO AMD_USERS
                     (bems_id, action_code, last_update_dt)
                     VALUES (bemsIdRecs(indx),  Amd_Defaults.INSERT_ACTION, SYSDATE) ;
                     inserted := inserted + 1 ;
                   EXCEPTION WHEN standard.DUP_VAL_ON_INDEX THEN
                     NULL ; -- ignore because some users have multiple planner codes
                   END insertAmdUsers ;
                END IF ;
             END LOOP ;
        end if ;             

         open deletedUsers ;
         fetch deletedUsers bulk collect into bemsIdRecs ;
         close deletedUsers ;
         
         if bemsIdRecs.first is not null then
             FOR indx in bemsIdRecs.first .. bemsIdRecs.last LOOP
                 UPDATE AMD_USERS
                 SET action_code = Amd_Defaults.DELETE_ACTION,
                 last_update_dt = SYSDATE
                 WHERE bems_id = bemsIdRecs(indx) ;
                 deleted := deleted + 1 ;
             END LOOP ;
        end if ;             

        writeMsg(pTableName => 'amd_users', pError_location => 430,
                pKey1 => 'loadUsers',
                pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => 'inserted=' || to_char(inserted),
                pKey4 => 'deleted=' || to_char(deleted) ) ;
                
        commit ;
    END loadUsers ;

    
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
               errorMsg(sqlFunction => 'update', tableName => 'amd_planner_logons', pError_location => 440,
                       key1 => insertPlannerLogons.planner_code,
                    key2 => insertPlannerLogons.logon_id,
                    key3 => insertPlannerLogons.data_source) ;
               RAISE ;

             END doUpdate ;
    BEGIN
         debugMsg('planner_code=' || planner_code || ' logon_id=' || logon_id || ' data_source=' || data_source,
            pError_location => 450) ;
         <<insertAmdPlannerLogons>>
         BEGIN
             INSERT INTO AMD_PLANNER_LOGONS
             (planner_code, logon_id, data_source, action_code, last_update_dt)
             VALUES (insertPlannerLogons.planner_code, insertPlannerLogons.logon_id, insertPlannerLogons.data_source, Amd_Defaults.INSERT_ACTION, SYSDATE) ;
         EXCEPTION
           WHEN standard.DUP_VAL_ON_INDEX THEN
                   doUpdate ;
           WHEN OTHERS THEN
               errorMsg(sqlFunction => 'insert', tableName => 'amd_planner_logons', pError_location => 460,
                       key1 => insertPlannerLogons.planner_code,
                    key2 => insertPlannerLogons.logon_id,
                    key3 => insertPlannerLogons.data_source) ;
               RAISE ;

          END insertAmdPlannerLogons ;

         
        RETURN SUCCESS ;

    EXCEPTION WHEN OTHERS THEN
        errorMsg(sqlFunction => 'insertPlannerLogons', tableName => 'amd_planner_logons', pError_location => 470) ;
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
           errorMsg(sqlFunction => 'update', tableName => 'amd_planner_logons', pError_location => 480,
                   key1 => updatePlannerLogons.planner_code,
                key2 => updatePlannerLogons.logon_id,
                key3 => updatePlannerLogons.data_source) ;
           RAISE ;

          END updateAmdPlannerLogons ;

        
        RETURN SUCCESS ;
    EXCEPTION WHEN OTHERS THEN
        errorMsg(sqlFunction => 'updatePlannerLogons', tableName => 'amd_planner_logons', pError_location => 490) ;
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
           errorMsg(sqlFunction => 'update', tableName => 'amd_planner_logons', pError_location => 500,
                   key1 => deletePlannerLogons.planner_code, key2 => deletePlannerLogons.logon_id, key3 => deletePlannerLogons.data_source) ;
           RAISE ;

          END deleteAmdPlanners ;


        RETURN SUCCESS ;

    EXCEPTION WHEN OTHERS THEN
        errorMsg(sqlFunction => 'deletePlannerLogons', tableName => 'amd_planner_logons', pError_location => 510) ;
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
             debugMsg('loadGoldPsmsMain: completed step ' || step, pError_location => 520) ;
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

              THE_A2A_PKG                      constant varchar2(7)  := 'a2a_pkg' ;
              THE_AMD_PARTPRIME_PKG          constant varchar2(17) := 'amd_partprime_pkg' ;
              THE_AMD_PART_LOC_FORECASTS_PKG constant varchar2(26) := 'amd_part_loc_forecasts_pkg' ;
              THE_AMD_SPARE_PARTS_PKG            constant varchar2(19) := 'amd_spare_parts_pkg' ;
              THE_AMD_SPARE_NETWORKS_PKG       constant varchar2(22) :=  'amd_spare_networks_pkg' ;
              THE_AMD_DEMAND_PKG                constant varchar2(10) := 'amd_demand' ;
              THE_AMD_PART_LOCS_LOAD_PKG       constant varchar2(22) := 'amd_part_locs_load_pkg' ;
              THE_AMD_FROM_BSSM_PKG             constant varchar2(17) := 'amd_from_bssm_pkg' ;
              THE_AMD_CLEANED_FROM_BSSM_PKG  constant varchar2(25) := 'amd_cleaned_from_bssm_pkg' ;

              DELETE_INVALID_PARTS        constant varchar2(18) := 'deleteinvalidParts' ;
              DIFF_PART_TO_PRIME        constant varchar2(15) := 'DiffPartToPrime' ;
              LOAD_LATEST_RBL_RUN        constant varchar2(16) := 'LoadLatestRblRun' ;
              LOAD_CURRENT_BACKORDER   constant varchar2(20) := 'loadCurrentBackOrder' ;
              LOAD_TEMP_NSNS            constant varchar2(12) := 'loadtempnsns' ;
              AUTO_LOAD_SPARE_NETWORKS constant varchar2(24) := 'auto_load_spare_networks' ;
              LOAD_AMD_DEMANDS            constant varchar2(14) := 'loadamddemands' ;
              LOAD_BASC_UK_DEMANDS        constant varchar2(17) := 'loadBascUkdemands' ;
              AMD_DEMAND_A2A            constant varchar2(14) := 'amd_demand_a2a' ;
              LOAD_GOLD_INVENTORY        constant varchar2(17) := 'loadGoldInventory' ;
              LOAD_AMD_PART_LOCATIONS        constant varchar2(20) := 'LoadAmdPartLocations' ;
              LOAD_AMD_BASE_FROM_BSSM_RAW constant varchar2(22) := 'LoadAmdBaseFromBssmRaw' ;

    begin
        if batch_job_number is null then
             raise amd_load.no_active_job ;
        end if ;
        for step in startStep..endStep loop
            if step = 1 then
                if amd_batch_pkg.didStepStart(batch_job_number => batch_job_number, system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                        description => DELETE_INVALID_PARTS, package_name => THE_A2A_PKG, procedure_name => DELETE_INVALID_PARTS) then

                      null ;
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

                    null ; --amd_part_factors_pkg.ProcessA2AVirtualLocs;
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
            debugMsg('postProcess: completed step ' || step, pError_location => 530) ;
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

                  null ; -- procdure amd_location_part_override_pkg.LoadZeroTslA2A has been removed 
                end if ;

             end if ;
             debugMsg('postDiffProcess: completed step ' || step, pError_location => 540) ;
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
         debugMsg('start disableAmdContraints', pError_location => 550) ;
         mta_disable_constraint('amd_part_loc_time_periods','amd_part_loc_time_periods_fk01');
         mta_disable_constraint('amd_part_locs','amd_part_locs_fk01');
         mta_disable_constraint('amd_part_locs','amd_part_locs_fk02');
         mta_disable_constraint('amd_maint_task_distribs','amd_maint_task_distribs_fk01');
         mta_disable_constraint('amd_bods','amd_bods_fk02');
         mta_disable_constraint('amd_part_next_assemblies','amd_part_next_assemblies_fk01');
         mta_disable_constraint('amd_demands','amd_demands_fk01');
         mta_disable_constraint('amd_demands','amd_demands_fk02');
         mta_disable_constraint('amd_demands','amd_demands_pk');
         debugMsg('end disableAmdContraints', pError_location => 560) ;
         commit ;
    end disableAmdConstraints ;

    procedure truncateAmdTables is
    begin
         debugMsg('start truncateAmdTables', pError_location => 570) ;
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
         debugMsg('end truncateAmdTables', pError_location => 580) ;
         commit ;
    end truncateAmdTables ;

    procedure enableAmdConstraints is
    begin
         debugMsg('start enableAmdConstraints', pError_location => 590) ;
         mta_enable_constraint('amd_part_loc_time_periods','amd_part_loc_time_periods_fk01');
         mta_enable_constraint('amd_part_locs','amd_part_locs_fk01');
         mta_enable_constraint('amd_part_locs','amd_part_locs_fk02');
         mta_enable_constraint('amd_maint_task_distribs','amd_maint_task_distribs_fk01');
         mta_enable_constraint('amd_bods','amd_bods_fk02');
         mta_enable_constraint('amd_part_next_assemblies','amd_part_next_assemblies_fk01');
         mta_enable_constraint('amd_demands','amd_demands_fk01');
         mta_enable_constraint('amd_demands','amd_demands_fk02');
         mta_enable_constraint('amd_demands','amd_demands_pk');
         debugMsg('end enableAmdConstraints', pError_location => 600) ;
         commit ;
    end enableAmdConstraints ;

    procedure prepAmdDatabase is
          batch_job_number amd_batch_jobs.BATCH_JOB_NUMBER%type := amd_batch_pkg.getActiveJob(system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP) ;
          batch_step_number amd_batch_job_steps.BATCH_STEP_NUMBER%type ;
    begin
         debugMsg('start prepAmdDatabase', pError_location => 610) ;
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

         debugMsg('end prepAmdDatabase', pError_location => 620) ;
         commit ;
    end prepAmdDatabase ;

    procedure version is
    begin
         writeMsg(pTableName => 'amd_load', 
                 pError_location => 630, pKey1 => 'amd_load', pKey2 => '$Revision:   1.77  $') ;
         dbms_output.put_line('amd_load: $Revision:   1.77  $') ;
    end version ;
    
    function getVersion return varchar2 is
    begin
        return '$Revision:   1.77  $' ;
    end getVersion ;
    
    procedure validatePartStructure is
              cursor NoNsn4SpareParts is
                       select * from amd_spare_parts where nsn is null ;
              cursor NoNsn4Items is
                       select * from amd_National_Stock_Items where nsn is null ;
              cursor NoPrimePart is
                       select * from amd_national_stock_items where prime_part_no is null ;
              cursor NotDeleted is
                       select nsi_sid, prime_part_no from amd_national_stock_items items, amd_spare_parts parts where prime_part_no = part_no
                     and items.action_code <> amd_defaults.DELETE_ACTION and parts.action_code = amd_defaults.DELETE_ACTION ;  
              
              cntNoNsnParts number := 0 ;
              cntNoNsnItems number := 0 ;
              cntNoPrimePart number := 0 ;
              cntNotDeleted number := 0 ;
    begin
         for rec in NoNsn4SpareParts loop
              cntNoNsnParts := cntNoNsnParts + 1 ;
             writeMsg(pTableName => 'amd_spare_parts', pError_location => 640,
                     pKey1 => 'part_no=' || rec.part_no, pKey2 => 'No Nsn',
                    pKey3 => 'action_code=' || rec.action_code) ;
         end loop ;
         for rec in NoNsn4Items loop
              cntNoNsnItems := cntNoNsnItems + 1 ;
             writeMsg(pTableName => 'amd_national_stock_items', pError_location => 650,
                     pKey1 => 'prime_part_no=' || rec.prime_part_no, pKey2 => 'No Nsn',
                    pKey3 => 'action_code=' || rec.action_code) ;
         end loop ;
         for rec in NoPrimePart loop
              cntNoPrimePart := cntNoPrimePart + 1 ;
             writeMsg(pTableName => 'amd_national_stock_items', pError_location => 660,
                     pKey1 => 'nsi_sid=' || rec.nsi_sid, pKey2 => 'No Prime Part',
                    pKey3 => 'action_code=' || rec.action_code,
                    pKey4 => 'nsn=' || rec.nsn) ;
         end loop ;
         for rec in NotDeleted loop
              cntNotDeleted := cntNotDeleted + 1 ;
             update amd_national_stock_items
             set action_code = amd_defaults.DELETE_ACTION,
             last_update_dt = sysdate 
             where nsi_sid = rec.nsi_sid;
         end loop ;
         dbms_output.put_line('cntNoNsnParts=' || cntNoNsnParts) ;
         dbms_output.put_line('cntNoNsnItems=' || cntNoNsnItems) ;
         dbms_output.put_line('cntNoPrimePart=' || cntNoPrimePart) ;
         dbms_output.put_line('cntNotDeleted=' || cntNotDeleted) ;
         writeMsg(pTableName => 'amd_spare_parts', pError_location => 670,
                 pKey1 => 'cntNoNsnParts=' || to_char(cntNoNsnParts)) ;
         writeMsg(pTableName => 'amd_national_stock_items', pError_location => 680,
                 pKey1 => 'cntNoNsnItems=' || to_char(cntNoNsnItems)) ;
         writeMsg(pTableName => 'amd_national_stock_items', pError_location => 690,
                 pKey1 => 'cntNoPrimePart=' || to_char(cntNoPrimePart)) ;
         writeMsg(pTableName => 'amd_national_stock_items', pError_location => 700,
                 pKey1 => 'cntNotDeleted=' || to_char(cntNotDeleted)) ;
         commit ;                
    end validatePartStructure ;
    
    -- added 4/2/2007 by DSE
    function getORIGINAL_DATA return varchar2 is
    begin
        return ORIGINAL_DATA ;
    end getORIGINAL_DATA ;

    function getCLEANED_DATA return varchar2 is
    begin
        return CLEANED_DATA ;
    end getCLEANED_DATA ;
    
    function getCURRENT_NSN return varchar2 is
    begin   
        return CURRENT_NSN ;
    end getCURRENT_NSN ;
    
    -- added 6/25/2008 by dse
    procedure setBulkInsertThreshold(value in number) is
    begin
        bulkInsertThreshold := value ;
    end setBulkInsertThreshold ;
    
    function getBulkInsertThreshold return number is
    begin
        return bulkInsertThreshold ;
    end getBulkInsertThreshold ;
    
    procedure setDebug(value in varchar2) is -- added 6/30/2008
    begin
        mDebug := (value in ('Y','y','T','t','YES','yes','TRUE','true')) ;
        if mDebug then
            dbms_output.ENABLE(100000) ;
        else
            dbms_output.DISABLE ;
        end if ;                          
    end setDebug ;
    
    function getDebug return varchar2 is
    begin
        if mDebug then
            return 'Y' ;
        else
            return 'N' ;
        end if ;                        
    end getDebug ;

BEGIN

  <<getDebugParam>>
  DECLARE
       param AMD_PARAM_CHANGES.PARAM_VALUE%TYPE ;
  BEGIN
     param := amd_defaults.GetParamValue('debugAmdLoad') ;
     if param is not null then
     	mDebug := (param = '1');	
     else
	mDebug := false ;
     end if ;
  EXCEPTION WHEN OTHERS THEN
     mDebug := FALSE ;
  END getDebugParam;
  
  bulkInsertThreshold := nvl(to_number(amd_defaults.GETPARAMVALUE('bulkInsertThreshold')),bulkInsertThreshold) ;

END Amd_Load;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_LOAD;

CREATE PUBLIC SYNONYM AMD_LOAD FOR AMD_OWNER.AMD_LOAD;


GRANT EXECUTE ON AMD_OWNER.AMD_LOAD TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_LOAD TO AMD_WRITER_ROLE;

