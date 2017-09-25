CREATE OR REPLACE PACKAGE AMD_OWNER.amd_load
AS
    /*
     PVCS Keywords

       $Author:   zf297a  $
     $Revision:   1.29
         $Date:   20 Jun 2016
     $Workfile:   amd_load.pks  $

      Rev 1.29  20 Jun 2016 reformatted code with Toad

      Rev 1.28  17 Feb 2015 DSE removed bssm_owner qualifier

      Rev 1.27  19 Feb 2012 Added setPsmsThreshold zf297a

      Rev 1.26   03 Aug 2011 11:45:18   zf297a
   Add interfaces setUseBizDays, getUseBizDays.  and added additional set functions that could be used in SQL queries to set the various values

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
   Made functions  GetOffBaseRepairCost and GetOffBaseTurnAround public.

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
   -- 09/22/04 TP    Changed how we pull SMR Code from PSMS to GOLD .
   --

   -- expose the following functions and procedures to allow for easy routine validation and unit testing
   no_active_job            EXCEPTION;


   FUNCTION IsValidSmr (pSmrCode VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION GetSmr (pPart VARCHAR2, pCage VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION GetPrime (pNsn CHAR)
      RETURN VARCHAR2;

   FUNCTION getMic (pNsn VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION getUnitCost (pPartNo VARCHAR2)
      RETURN NUMBER;

   FUNCTION GetItemType (pSmrCode VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION getMmac (pNsn VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION onNsl (pPartNo VARCHAR2)
      RETURN BOOLEAN;

   PROCEDURE getOriginalBssmData (
      nsn           IN     amd_nsns.nsn%TYPE,
      part_no       IN     bssm_parts.PART_NO%TYPE,
      condemn_avg      OUT amd_national_stock_items.condemn_avg%TYPE,
      criticality      OUT amd_national_stock_items.criticality%TYPE,
      nrts_avg         OUT amd_national_stock_items.nrts_avg%TYPE,
      rts_avg          OUT amd_national_stock_items.rts_avg%TYPE,
      amc_demand       OUT amd_national_stock_items.amc_demand%TYPE);

   PROCEDURE getCleanedBssmData (
      nsn                              IN     amd_nsns.nsn%TYPE,
      part_no                          IN     bssm_parts.part_no%TYPE,
      condemn_avg_cleaned                 OUT amd_national_stock_items.condemn_avg_cleaned%TYPE,
      criticality_cleaned                 OUT amd_national_stock_items.criticality_cleaned%TYPE,
      mtbdr_cleaned                       OUT amd_national_stock_items.mtbdr_cleaned%TYPE,
      nrts_avg_cleaned                    OUT amd_national_stock_items.nrts_avg_cleaned%TYPE,
      rts_avg_cleaned                     OUT amd_national_stock_items.rts_avg_cleaned%TYPE,
      order_lead_time_cleaned             OUT amd_national_stock_items.order_lead_time_cleaned%TYPE,
      planner_code_cleaned                OUT amd_national_stock_items.planner_code_cleaned%TYPE,
      smr_code_cleaned                    OUT amd_national_stock_items.smr_code_cleaned%TYPE,
      unit_cost_cleaned                   OUT amd_national_stock_items.unit_cost_cleaned%TYPE,
      cost_to_repair_off_base_cleand      OUT amd_national_stock_items.cost_to_repair_off_base_cleand%TYPE,
      time_to_repair_off_base_cleand      OUT amd_national_stock_items.time_to_repair_off_base_cleand%TYPE,
      amc_demand_cleaned                  OUT amd_national_stock_items.amc_demand_cleaned%TYPE);

   PROCEDURE getRmadsData (
      part_no         IN     amd_rmads_source_tmp.part_no%TYPE,
      qpei_weighted      OUT amd_rmads_source_tmp.QPEI_WEIGHTED%TYPE,
      mtbdr              OUT amd_rmads_source_tmp.MTBDR%TYPE);

   PROCEDURE GetPsmsData (pPartNo         VARCHAR2,
                          pCage           VARCHAR2,
                          pSlifeDay   OUT NUMBER,
                          pUnitVol    OUT NUMBER,
                          pSmrCode    OUT VARCHAR2);


   PROCEDURE LoadGold;

   PROCEDURE LoadRblPairs;

   PROCEDURE LoadPsms;

   PROCEDURE LoadMain;

   PROCEDURE LoadWecm;

   PROCEDURE LoadTempNsns;

   PROCEDURE loadUsers;

   -- For future use
   -- The following procedures: loadGoldPsmsMain, preProcess, postProcess, and postDiffProcess,
   -- may be used to replace the bulky sql scripts currently used by amd_loader.ksh
   PROCEDURE loadGoldPsmsMain (startStep   IN NUMBER := 1,
                               endStep     IN NUMBER := 3);

   PROCEDURE preProcess (startStep IN NUMBER := 1, endStep IN NUMBER := 3);

   PROCEDURE postProcess (startStep IN NUMBER := 1, endStep IN NUMBER := 18);

   PROCEDURE postDiffProcess (startStep   IN NUMBER := 1,
                              endStep     IN NUMBER := 3);

   -- For future use
   -- The following procedures: prepAmdDatabase, disableAmdConstraints, truncateAmdTables, and
   -- enableAmdConstraints can be be used in conjunction with the above procedures
   PROCEDURE prepAmdDatabase;

   PROCEDURE disableAmdConstraints;

   PROCEDURE truncateAmdTables;

   PROCEDURE enableAmdConstraints;


   SUCCESS         CONSTANT NUMBER := 0;
   FAILURE         CONSTANT NUMBER := 4;

   CLEANED_DATA    CONSTANT VARCHAR2 (1) := '2';

   FUNCTION getCLEANED_DATA
      RETURN VARCHAR2;

   ORIGINAL_DATA   CONSTANT VARCHAR2 (1) := '0';

   FUNCTION getORIGINAL_DATA
      RETURN VARCHAR2;

   CURRENT_NSN     CONSTANT VARCHAR2 (1) := 'C';

   FUNCTION getCURRENT_NSN
      RETURN VARCHAR2;

   -- for amd_planners diff
   FUNCTION insertRow (planner_code IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION updateRow (planner_code IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION deleteRow (planner_code IN VARCHAR2)
      RETURN NUMBER;

   -- for amd_planner_logons diff
   FUNCTION insertplannerlogons (planner_code   IN VARCHAR2,
                                 logon_id       IN VARCHAR2,
                                 data_source    IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION updatePlannerLogons (planner_code   IN VARCHAR2,
                                 logon_id       IN VARCHAR2,
                                 data_source    IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION deletePlannerLogons (planner_code   IN VARCHAR2,
                                 logon_id       IN VARCHAR2,
                                 data_source    IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION getBemsId (employeeNo IN amd_use1.EMPLOYEE_NO%TYPE)
      RETURN amd_users.BEMS_ID%TYPE;

   FUNCTION GetOffBaseRepairCost (pPartNo VARCHAR2)
      RETURN amd_part_locs.cost_to_repair%TYPE;

   FUNCTION GetOffBaseTurnAround (pPartno VARCHAR2)
      RETURN amd_part_locs.time_to_repair%TYPE;

   TYPE resultSetCursor IS REF CURSOR;

   FUNCTION getNewUsers
      RETURN resultSetCursor;

   FUNCTION insertUsersRow (bems_id        IN VARCHAR2,
                            stable_email   IN VARCHAR2,
                            last_name      IN VARCHAR2,
                            first_name     IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION updateUsersRow (bems_id        IN VARCHAR2,
                            stable_email   IN VARCHAR2,
                            last_name      IN VARCHAR2,
                            first_name     IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION deleteUsersRow (bems_id IN VARCHAR2)
      RETURN NUMBER;

   -- added 6/9/2006 by DSE
   PROCEDURE version;

   -- added 10/30/2006 by DSE
   PROCEDURE validatePartStructure;

   -- added 2/12/2007 by DSE
   -- send in nsn and part to get lock_sid 2
   -- send in mtbdr_computed for lock_sid = 0
   -- send out mtbdr_computed for lock_sid = 2  (see Note below)
   --      Note: This field is calculated by BestSpares from demand and flight hours and is preferred by the user over
   --      the RMADS MTBDR value.  It is not cleanable by the user, but can be recalculated by the user if they clean
   --      flight hours.  BestSpares stores MTBDR_COMPUTED on Lock_SID = 2 when there is any cleaning info for the part
   --      and removes the values on Lock_SID = 0.  If there is no cleaning info for the part then MTBDR_COMPUTED is stored
   --      on Lock_SID = 0.
   FUNCTION getCalculatedData (nsn       IN amd_nsns.nsn%TYPE,
                               part_no   IN bssm_parts.PART_NO%TYPE)
      RETURN amd_national_stock_items.mtbdr_computed%TYPE;

   -- add 3/28/2007 by dse
   FUNCTION getOrderLeadTime (part IN cat1.part%TYPE)
      RETURN NUMBER;

   FUNCTION getVersion
      RETURN VARCHAR2;

   PROCEDURE setPsmsThreshold (VALUE IN NUMBER := NULL); -- added 2/19/2012 by dse

   PROCEDURE setBulkInsertThreshold (VALUE IN NUMBER); -- added 6/25/2008 by dse

   FUNCTION setBulkInsertThreshold (VALUE IN VARCHAR2)
      RETURN VARCHAR2;                                -- added 8/3/2011 by dse

   FUNCTION getBulkInsertThreshold
      RETURN NUMBER;                                 -- added 6/25/2008 by dse

   PROCEDURE setDebug (VALUE IN VARCHAR2);           -- added 6/30/2008 by dse

   FUNCTION setDebug (VALUE IN VARCHAR2)
      RETURN VARCHAR2;                                -- added 8/3/2011 by dse

   FUNCTION getDebug
      RETURN VARCHAR2;                               -- added 6/30/2008 by dse

   PROCEDURE setUseBizDays (VALUE IN VARCHAR2);       -- added 8/3/2011 by dse

   FUNCTION setUseBizDays (VALUE IN VARCHAR2)
      RETURN VARCHAR2;                                -- added 8/3/2011 by dse

   FUNCTION getUseBizDays
      RETURN VARCHAR2;                                -- added 8/3/2011 by dse

   PROCEDURE setDebugThreshold (VALUE IN NUMBER := NULL);

   FUNCTION getDebugThreshold
      RETURN NUMBER;

   PROCEDURE setStartDebugRec (VALUE IN NUMBER);           -- added 11/25/2008

   FUNCTION getStartDebugRec
      RETURN NUMBER;                                       -- added 11/25/2008
END amd_load;
/