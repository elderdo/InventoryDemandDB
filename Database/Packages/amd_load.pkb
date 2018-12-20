DROP PACKAGE BODY AMD_OWNER.AMD_LOAD;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.AMD_LOAD
AS
   /*
           PVCS Keywords

          $Author:   Douglas S. Elder
        $Revision:   1.97
            $Date:   05 Feb 2018
        $Workfile:   amd_load.pkb  $

          Rev 1.97   05 FEb 2018 renamed loadBascUKDemands to loadDepotDemands per TFS 52919


          Rev 1.96   5 Dec 2017 use mtbdr when the associated part has been created within the last 5 years (tfs 47117)

          Rev 1.95  21 Nov 2017 added dbms_output.put_line for every raise command
          Rev 1.94  15 Nov 2017 added qualified where clauses by using lock_sid, part_no, and nsn
                                for bssm_parts since that is the primary key!
                                Added nsn qualifier for queries of bssm_parts when having part_no and nsn
                                removed calculation of elapsed time for loadGold since SQL*Plus will
                                give elapsed time with SET TIMING ON
          Rev 1.93  14 Nov 2013 added dbms_output with counts and reformatted code
                                added exception handler for <<cleaned>> begin end to just
                                report problem and continue
                                added cursor to getCleanedDataByPart because was fetching more than one row

          Rev 1.92  19 Oct 2015 fix loadRblPairs to ignore duplicate rows, but to report them. Also,
          add order by old_nsn, subgroup_code, part_pref_code so that
           old_nsn AA (subgroup_code) A (part_pref_code) gets inserted over the same old_nsn AA B

          Rev 1.91  17 Aug 2015 when performing logical deletes or bulk inserts ignore trigger compilation
                   errors

          Rev 1.90  17 Feb 2015 removed amd_owner and bssm_owner qualifier

          Rev 1.89  added amd_defaults.getSourceCode, getNonStockageList

          Rev 1.88  Use slic_ha_v and slic_hg_v views instead of table and db links

         Rev 1.87 added exception handler to loadMain and added distict to query for order_qty from tmp_main zf297a

         Rev 1.86 renamed amd_demand.amd_demand_a2a to amd_demand.load_amd_demands_table
         and renamed amd_demand.loadAmdDemands to amd_demand.loadAmdBssmSourceTmpAmdDemands

          Rev 1.85 removed truncate of tmp_a2a tables

           Rev 1.84  21 Feb 2012 rewrote loadPsms to use simplified slic views
           that do not trim any columns used by the where clause predicate so that
           the query is fast.  Used the Oracle analytical functions to get the best smr_code
           from slic.  loadPsms has been reduced to a bulk select and a bulk update.  Used
           Toad's reformat tool to make loadGold code neater.

          Rev 1.84  16 Feb 2012 tried to optimize getSmr zf297a

         Rev 1.83  13 Feb 2012 used common routine and new amd_repair_cost_detail to calc avg cost  to repair off base zf297a

         Rev 1.82   09 Feb 2012 changed names of all pslms views to a slic prefix with a _v suffix

         Rev 1.81    07 Dec 2011  made the ccn_prefix query more flexible by using the length of the ccn_prefix in the substr of the existential subquery

         Rev 1.80    03 Aug 2011 Added useBizDays switch, added code to invoke the amd_utils.bizdays2calendardays when useBizDays is true
                         otherwise do not invoke it.  added code to get/set the useBizDays switch via SQL or via the amd_param_changes table using the useBizDays data switch

         Rev 1.79    18 Mar 2010 Made changes to function getOffBaseTurnAround to comply with ClearQuest LBPSS00002451

         Rev 1.78    26 Feb 2010 Eliminated the PsmsInstance Function and updated the Procedure GetPsmsData to comply with the conversion of the SLICWave.

                     Made changes in getting smr_code and shelf_life from PSMS to SLICWave and PSMV is going away.

                     Removed constant the_a2a_pkg which is more a2a code not being used.
                     Thuy is making changes to loadPsms and Douglas removed amd_partPrime_pkg.diffPartToPrime

         Rev 1.77   05 Oct 2009 eliminated more A2A code

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
   TYPE t_part_no_tab IS TABLE OF tmp_amd_spare_parts.part_no%TYPE;

   THIS_PACKAGE            CONSTANT VARCHAR2 (8) := 'amd_load';
   THE_AMD_INVENTORY_PKG   CONSTANT VARCHAR2 (13) := 'amd_inventory';

   mDebug                           BOOLEAN := FALSE;
   useBizDays                       BOOLEAN := FALSE;
   bulkInsertThreshold              NUMBER := 600;
   debugThreshold                   NUMBER := 5000;
   startDebugRec                    NUMBER := 0;
   psms_cnt                         NUMBER := 0;
   psmsThreshold                    NUMBER := 10000;


   --
   -- procedure/Function bodies
   --
   PROCEDURE performLogicalDelete (pPartNo VARCHAR2);

   PROCEDURE debugMsg (msg               IN AMD_LOAD_DETAILS.DATA_LINE%TYPE,
                       pError_Location   IN NUMBER)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      IF mDebug
      THEN
         Amd_Utils.debugMsg (pMsg        => msg,
                             pPackage    => THIS_PACKAGE,
                             pLocation   => pError_location);
         COMMIT;                                -- make sure the trace is kept
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF SQLCODE = -14551 OR SQLCODE = -14552
         THEN
            NULL;    -- cannot do a commit inside a query, so ignore the error
         ELSE
            DBMS_OUTPUT.put_line (
               'debugMsg: sqlcode=' || SQLCODE || ' sqlerrm=' || SQLERRM);
            RAISE;
         END IF;
   END debugMsg;


   PROCEDURE errorMsg (sqlFunction         IN VARCHAR2 := 'errorMsg',
                       tableName           IN VARCHAR2 := 'noname',
                       pError_location     IN NUMBER := -100,
                       key1                IN VARCHAR2 := '',
                       key2                IN VARCHAR2 := '',
                       key3                IN VARCHAR2 := '',
                       key4                IN VARCHAR2 := '',
                       key5                IN VARCHAR2 := '',
                       keywordValuePairs   IN VARCHAR2 := '')
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      Amd_Utils.InsertErrorMsg (
         pLoad_no        => Amd_Utils.GetLoadNo (pSourceName   => sqlFunction,
                                                 pTableName    => tableName),
         pData_line_no   => pError_location,
         pData_line      => THIS_PACKAGE,
         pKey_1          => key1,
         pKey_2          => key2,
         pKey_3          => key3,
         pKey_4          => key4,
         pKey_5          => key5 || ' ' || keywordValuePairs,
         pComments       =>    'sqlcode('
                            || SQLCODE
                            || ') sqlerrm('
                            || SQLERRM
                            || ')');
      COMMIT;
      RETURN;
   END ErrorMsg;


   PROCEDURE writeMsg (
      pTableName        IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
      pError_location   IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
      pKey1             IN VARCHAR2 := '',
      pKey2             IN VARCHAR2 := '',
      pKey3             IN VARCHAR2 := '',
      pKey4             IN VARCHAR2 := '',
      pData             IN VARCHAR2 := '',
      pComments         IN VARCHAR2 := '')
   IS
   BEGIN
      Amd_Utils.writeMsg (pSourceName       => 'amd_load',
                          pTableName        => pTableName,
                          pError_location   => pError_location,
                          pKey1             => pKey1,
                          pKey2             => pKey2,
                          pKey3             => pKey3,
                          pKey4             => pKey4,
                          pData             => pData,
                          pComments         => pComments);
   END writeMsg;


   FUNCTION getBemsId (employeeNo IN AMD_USE1.EMPLOYEE_NO%TYPE)
      RETURN AMD_USERS.BEMS_ID%TYPE
   IS
      bems_id         amd_people_all_v.BEMS_ID%TYPE;

      wk_employeeNo   AMD_USE1.employee_no%TYPE
                         := UPPER (TRIM (REPLACE (employeeNo, ';', '')));

      FUNCTION isNumber (txt IN VARCHAR2)
         RETURN BOOLEAN
      IS
         theNumber   NUMBER;
      BEGIN
        <<testForNumber>>
         BEGIN
            theNumber := TO_NUMBER (txt);
         EXCEPTION
            WHEN VALUE_ERROR
            THEN
               theNumber := NULL;
         END testForNumber;

         RETURN (theNumber IS NOT NULL);
      END isNumber;

      PROCEDURE getViaBemsId
      IS
      BEGIN
         IF isNumber (wk_employeeNo) AND LENGTH (wk_employeeNo) = 6
         THEN
            getBemsId.bems_id := '0' || wk_employeeNo;
         ELSE
            IF SUBSTR (wk_employeeNo, 1, 1) = 'C'
            THEN
               wk_employeeNo := SUBSTR (wk_employeeNo, 2);

               IF isNumber (wk_employeeNo) AND LENGTH (wk_employeeNo) = 6
               THEN
                  wk_employeeNo := '0' || wk_employeeNo;
               END IF;
            END IF;

            getBemsId.bems_id := SUBSTR (wk_employeeNo, 1, 7);
         END IF;

         BEGIN
            SELECT bems_id
              INTO getBemsId.bems_id
              FROM amd_people_all_v
             WHERE bems_id = getBemsId.bems_id;
         EXCEPTION
            WHEN STANDARD.NO_DATA_FOUND
            THEN
               getBemsId.bems_id := NULL;
            WHEN OTHERS
            THEN
               ErrorMsg (
                  sqlFunction       => 'select',
                  tableName         => 'amd_people_all_v',
                  pError_location   => 10,
                  key1              => 'wk_employeeNo=' || wk_employeeNo);
               DBMS_OUTPUT.put_line (
                     'getViaBemsId: wkr_employeeNo='
                  || wk_employeeNo
                  || ' select amd_people_all_v 1 sqlcode='
                  || SQLCODE
                  || ' sqlerrm='
                  || SQLERRM);
               RAISE;
         END;
      EXCEPTION
         WHEN OTHERS
         THEN
            ErrorMsg (sqlFunction       => 'select',
                      tableName         => 'amd_people_all_v',
                      pError_location   => 20,
                      key1              => 'wk_employeeNo=' || wk_employeeNo);
            DBMS_OUTPUT.put_line (
                  'getViaBemsId: wkr_employeeNo='
               || wk_employeeNo
               || ' select amd_people_all_v 2 sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            RAISE;
      END getViaBemsId;
   BEGIN
      IF SUBSTR (wk_employeeNo, LENGTH (wk_employeeNo), 1) NOT IN ('1',
                                                                   '2',
                                                                   '3',
                                                                   '4',
                                                                   '5',
                                                                   '6',
                                                                   '7',
                                                                   '8',
                                                                   '9',
                                                                   '0')
      THEN
         wk_employeeNo :=
            SUBSTR (wk_employeeNo, 1, LENGTH (wk_employeeNo) - 1); -- strip non-numeric suffix
      END IF;

      IF SUBSTR (wk_employeeNo, 1, 1) = 'C'
      THEN
         -- try getting bemsid via the emp_id
         BEGIN
            SELECT bems_id
              INTO getBemsId.bems_id
              FROM amd_people_all_v
             WHERE UPPER (emp_id) = wk_employeeNo;
         EXCEPTION
            WHEN STANDARD.NO_DATA_FOUND
            THEN
               getViaBemsId;
            WHEN OTHERS
            THEN
               ErrorMsg (
                  sqlFunction       => 'select',
                  tableName         => 'amd_people_all_v',
                  pError_location   => 30,
                  key1              => 'wk_employeeNo=' || wk_employeeNo);
               DBMS_OUTPUT.put_line (
                     'getViaBemsId: wkr_employeeNo='
                  || wk_employeeNo
                  || ' select amd_people_all_v 3 sqlcode='
                  || SQLCODE
                  || ' sqlerrm='
                  || SQLERRM);
               RAISE;
         END;
      ELSE
         getViaBemsId;
      END IF;

      RETURN getBemsId.bems_id;
   EXCEPTION
      WHEN STANDARD.NO_DATA_FOUND
      THEN
         RETURN NULL;
      WHEN OTHERS
      THEN
         IF SQLCODE <> -14551 AND SQLCODE <> -14552
         THEN
            -- cannot do a rollback inside a query
            ErrorMsg (sqlFunction       => 'getBemsId',
                      tableName         => 'amd_people_all_v',
                      pError_location   => 40,
                      key1              => 'wk_employeeNo=' || wk_employeeNo);
            DBMS_OUTPUT.put_line (
                  'getViaBemsId: wkr_employeeNo='
               || wk_employeeNo
               || ' select amd_people_all_v 4 sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            RAISE;
         ELSE
            DBMS_OUTPUT.put_line (
               'getBemsId: sqlcode=' || SQLCODE || ' sqlerrm=' || SQLERRM);
            DBMS_OUTPUT.put_line (
                  'getViaBemsId: wkr_employeeNo='
               || wk_employeeNo
               || ' select amd_people_all_v 5 sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            raise_application_error (
               -20001,
                  'getBemsId: sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM
               || ' wk_employeeNo='
               || wk_employeeNo);
         END IF;

         RETURN NULL;
   END getBemsId;



   /* function GetOffBaseRepairCost, logic same as previous load version */
   FUNCTION GetOffBaseRepairCost (pPartNo VARCHAR2)
      RETURN AMD_PART_LOCS.cost_to_repair%TYPE
   IS
      nsiSid   amd_national_stock_items.nsi_sid%TYPE := NULL;
   --
   --    Use only PART   number because POI1 does not have Cage Code.
   --
   BEGIN
      SELECT nsi_sid
        INTO nsiSid
        FROM amd_national_stock_items items, amd_spare_parts parts
       WHERE     parts.part_no = pPartNo
             AND parts.nsn = items.nsn
             AND parts.action_code <> 'D'
             AND items.action_code <> 'D';

      RETURN GETCOSTTOREPAIROFFBASE (nsiSid);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END GetOffBaseRepairCost;

   /* function get_off_base_tat, logic same as previous load version
      removed offbasediag time from previous version */
   FUNCTION GetOffBaseTurnAround (pPartno VARCHAR2)
      RETURN AMD_PART_LOCS.time_to_repair%TYPE
   IS
      -- goldpart      char(50);
      offBaseTurnAroundTime   AMD_PART_LOCS.time_to_repair%TYPE;

      offBaseCnt              NUMBER := 0;
   BEGIN
        SELECT AVG (completed_docdate - created_docdate)
          INTO offBaseTurnAroundTime
          FROM ORD1, amd_spare_parts parts
         WHERE     part = parts.part_no
               AND parts.action_code <> 'D'
               AND parts.nsn IN
                      (SELECT nsn
                         FROM amd_national_stock_items
                        WHERE prime_part_no = pPartNo AND action_code <> 'D')
               AND NVL (action_taken, '*') IN ('A',
                                               'B',
                                               'E',
                                               'G',
                                               'F',
                                               '*')
               AND order_type = 'J'
               AND completed_docdate IS NOT NULL
      GROUP BY nsn;

      offBaseCnt := offBaseCnt + SQL%ROWCOUNT;
      RETURN offBaseTurnAroundTime;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END GetOffBaseTurnAround;

   FUNCTION getUnitCost (pPartNo VARCHAR2)
      RETURN NUMBER
   IS
      CURSOR costCur
      IS
           SELECT cap_price
             FROM PRC1
            WHERE part = pPartNo
         ORDER BY sc DESC;

      unitCost   NUMBER := 0;
   BEGIN
      FOR rec IN costCur
      LOOP
         unitCost := rec.cap_price;
         EXIT;
      END LOOP;

      RETURN unitCost;
   END getUnitCost;


   FUNCTION getMmac (pNsn VARCHAR2)
      RETURN VARCHAR2
   IS
      CURSOR macCur
      IS
         SELECT nsn_smic
           FROM NSN1
          WHERE nsn = pNsn;

      mMac   VARCHAR2 (2) := NULL;
   BEGIN
      FOR rec IN macCur
      LOOP
         mMac := rec.nsn_smic;
         EXIT;
      END LOOP;

      RETURN mMac;
   END;


   PROCEDURE performLogicalDelete (pPartNo VARCHAR2)
   IS
      nsiSid   AMD_NSNS.nsi_sid%TYPE;
      nsnCnt   NUMBER;
   BEGIN
     <<update_amd_spare_parts>>
      BEGIN
         UPDATE AMD_SPARE_PARTS
            SET nsn = NULL,
                action_code = Amd_Defaults.DELETE_ACTION,
                last_update_dt = SYSDATE
          WHERE part_no = pPartNo;
      EXCEPTION
         WHEN OTHERS
         THEN
            -- ignore trigger compile errors
            IF SQLCODE != -4098
            THEN
               DBMS_OUTPUT.put_line (
                     'update_amd_spare_parts: pPartNo='
                  || pPartNo
                  || ' sqlcode='
                  || SQLCODE
                  || ' sqlerrm='
                  || SQLERRM);
               RAISE;
            END IF;
      END update_amd_spare_parts;

      BEGIN
         SELECT nsi_sid
           INTO nsiSid
           FROM AMD_NSI_PARTS
          WHERE part_no = pPartNo AND unassignment_date IS NULL;

         UPDATE AMD_NSI_PARTS
            SET unassignment_date = SYSDATE
          WHERE part_no = pPartNo AND nsi_sid = nsiSid;

         SELECT COUNT (*)
           INTO nsnCnt
           FROM AMD_NSI_PARTS
          WHERE nsi_sid = nsiSid AND unassignment_date IS NULL;

         IF (nsnCnt = 0)
         THEN
            UPDATE AMD_NATIONAL_STOCK_ITEMS
               SET action_code = Amd_Defaults.DELETE_ACTION,
                   last_update_dt = SYSDATE
             WHERE nsi_sid = nsiSid;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;
   END;


   FUNCTION onNsl (pPartNo VARCHAR2)
      RETURN BOOLEAN
   IS
      recCnt   NUMBER;
   BEGIN
      SELECT /*+ INDEX(an amd_nsns_nk01) */
            COUNT (*)
        INTO recCnt
        FROM AMD_NSNS an
       WHERE     nsi_sid IN
                    (SELECT nsi_sid
                       FROM AMD_NSI_PARTS
                      WHERE part_no = pPartNo AND unassignment_date IS NULL)
             AND nsn_type = 'C'
             AND nsn LIKE amd_defaults.getNonStockageList || '%';

      IF (recCnt != 0)
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END;


   /*  Date: 2/17/2012
        Desc: use the regular slic table using the link
        need to convert the param's to char(..) to
        match pslms_hg otherwise the varchar's won't
        match and return no_data_found

   */



   FUNCTION GetSmr (pPart VARCHAR2, pCage VARCHAR2)
      RETURN VARCHAR2
   IS
      smr_code   slic_hg_v.smrcodhg%TYPE;
      part_no    CHAR (50) := pPart;
      cage_cd    CHAR (13) := pCage;
   BEGIN
      IF mDebug AND MOD (psms_cnt, psmsThreshold) = 0
      THEN
         debugMsg (
               'GetSmr: '
            || ' pPart='
            || pPart
            || ' pCage='
            || pCage
            || ' psms_cnt='
            || psms_cnt
            || ' started:'
            || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
            pError_location   => 71);
      END IF;

      SELECT smrcodhg
        INTO smr_code
        FROM (  SELECT cagecdxh,
                       refnumha,
                       smrcodhg,
                       COUNT (smrcodhg) + LENGTH (TRIM (smrcodhg)),
                       LENGTH (smrcodhg),
                       DENSE_RANK ()
                       OVER (
                          PARTITION BY cagecdxh, refnumha
                          ORDER BY
                             COUNT (smrcodhg) + LENGTH (TRIM (smrcodhg)) DESC)
                          rnk
                  FROM slic_hg_v a
                 WHERE     cagecdxh = cage_cd
                       AND refnumha = part_no
                       AND smrcodhg <> '  '
              GROUP BY cagecdxh, refnumha, smrcodhg)
       WHERE rnk = 1 AND ROWNUM = 1;

      IF mDebug AND MOD (psms_cnt, psmsThreshold) = 0
      THEN
         debugMsg (
               'GetSmr: '
            || ' pPart='
            || pPart
            || ' pCage='
            || pCage
            || ' psms_cnt='
            || psms_cnt
            || ' ended:'
            || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
            pError_location   => 72);
      END IF;

      RETURN smr_code;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         IF mDebug AND MOD (psms_cnt, psmsThreshold) = 0
         THEN
            debugMsg (
                  'GetSmr: '
               || ' pPart='
               || pPart
               || ' pCage='
               || pCage
               || ' psms_cnt='
               || psms_cnt
               || ' ended:'
               || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
               pError_location   => 73);
         END IF;

         RETURN NULL;
      WHEN OTHERS
      THEN
         ErrorMsg (sqlFunction       => 'select',
                   tableName         => 'pslms_hg',
                   pError_location   => 50,
                   key1              => 'part=' || pPart,
                   key2              => 'cage=' || pCage,
                   key3              => 'getSmr');
         DBMS_OUTPUT.put_line (
               'getsmr: pPar='
            || pPart
            || ' pCage='
            || pCage
            || ' sqlcode='
            || SQLCODE
            || ' sqlerrm='
            || SQLERRM);
         RAISE;
   --
   END getsmr;


   PROCEDURE GetPsmsData (pPartNo         VARCHAR2,
                          pCage           VARCHAR2,
                          pSlifeDay   OUT NUMBER,
                          pUnitVol    OUT NUMBER,
                          pSmrCode    OUT VARCHAR2)
   IS
      /* ------------------------------------------------------------------- */
      /*  This procedure returns PSMS data for the Part and Cage Code from   */
      /*  the specified PSMS instance. Any integer indicates Shelf Life in Days          */
      /* ------------------------------------------------------------------- */

      sLife     VARCHAR2 (2);
      part_no   CHAR (50) := pPartNo;
      cage_cd   CHAR (13) := pCage;
   BEGIN
      IF mDebug AND MOD (psms_cnt, psmsThreshold) = 0
      THEN
         debugMsg (
               'GetPsmsData: '
            || ' pPartNo='
            || pPartNo
            || ' pCage='
            || pCage
            || ' psms_cnt='
            || psms_cnt
            || ' started:'
            || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
            pError_location   => 77);
      END IF;

     -- IF (pPsmsInst = 'PSMSVEND') THEN
     <<getPslmsHa>>
      BEGIN
         SELECT shlifeha, (ulengtha * uwidthha * uheighha) / 1728
           INTO sLife, pUnitVol
           FROM slic_ha_v ha, TMP_AMD_SPARE_PARTS s
          WHERE     ha.cagecdxh = s.mfgr
                AND ha.refnumha = s.part_no
                AND ha.cagecdxh = cage_cd
                AND ha.refnumha = part_no;
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            sLife := NULL;
            pUnitVol := NULL;
         WHEN OTHERS
         THEN
            ErrorMsg (sqlFunction       => 'select',
                      tableName         => 'slic_ha_v',
                      pError_location   => 60,
                      key1              => 'part=' || pPartNo,
                      key2              => 'cage=' || pCage);
            DBMS_OUTPUT.put_line (
                  'getPsmlsHa: part='
               || pPartNo
               || ' pCage='
               || pCage
               || ' sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            RAISE;
      END getPsmlsHa;

      IF (sLife IS NOT NULL)
      THEN
        <<getStorageDays>>
         BEGIN
            SELECT storage_days
              INTO pSlifeDay
              FROM AMD_SHELF_LIFE_CODES
             WHERE sl_code = sLife;
         EXCEPTION
            WHEN OTHERS
            THEN
               ErrorMsg (sqlFunction       => 'select',
                         tableName         => 'amd_shelf_life_codes',
                         pError_location   => 70,
                         key1              => 'sLife=' || sLife);
               DBMS_OUTPUT.put_line (
                     'getStorageDays: sLife='
                  || sLife
                  || ' sqlcode='
                  || SQLCODE
                  || ' sqlerrm='
                  || SQLERRM);
               RAISE;
         END getStorageDays;
      END IF;


      pSmrCode := GetSmr (pPartNo, pCage);

      IF mDebug AND MOD (psms_cnt, psmsThreshold) = 0
      THEN
         debugMsg (
               'GetPsmsData: '
            || ' pPartNo='
            || pPartNo
            || ' pCage='
            || pCage
            || ' psms_cnt='
            || psms_cnt
            || ' ended:'
            || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
            pError_location   => 94);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         ErrorMsg (sqlFunction       => 'select',
                   tableName         => 'AMD_SHELF_LIFE_CODES',
                   pError_location   => 80,
                   key1              => 'part=' || pPartNo,
                   key2              => 'cage=' || pCage,
                   key3              => 'GetPsmsData');
         DBMS_OUTPUT.put_line (
               'getPsmsData: pPartNo='
            || pPartNo
            || ' pCage='
            || pCage
            || ' sqlcode='
            || SQLCODE
            || ' sqlerrm='
            || SQLERRM);
         RAISE;
   END GetPsmsData;


   FUNCTION IsValidSmr (pSmrCode VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      IF (SUBSTR (pSmrCode, 6, 1) IN ('T', 'P', 'N'))
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END IsValidSmr;


   FUNCTION GetPrime (pNsn CHAR)
      RETURN VARCHAR2
   IS
      --
      -- Cursor selects primes w/matching part on same or other rec UNION with
      -- ONE record to use as default if no records satisfy above portion
      --
      TYPE primeRec IS RECORD
      (
         qNo          NUMBER,
         part_type    VARCHAR2 (15),
         part         cat1.part%TYPE,
         prime        cat1.prime%TYPE,
         manuf_cage   cat1.manuf_cage%TYPE
      );

      TYPE primeTab IS TABLE OF primeRec;

      primeRecs     primeTab;

      CURSOR primeCur
      IS
         SELECT DISTINCT
                1 qNo,
                DECODE (part, prime, '1 - Prime', '2 - Equivalent') partType,
                part part,
                prime prime,
                manuf_cage
           FROM CAT1 c1
          WHERE     c1.nsn = pNsn
                AND EXISTS
                       (SELECT 'x'
                          FROM CAT1 c2
                         WHERE c2.nsn = c1.nsn AND c2.part = c1.prime)
         UNION
         SELECT DISTINCT
                2 qNo,
                DECODE (part, prime, '1 - Prime', '2 - Equivalent') partType,
                TRIM (part) part,
                TRIM (prime) prime,
                TRIM (manuf_cage) manuf_cage
           FROM CAT1
          WHERE nsn = pNsn AND ROWNUM = 1
         ORDER BY qNo,
                  partType,
                  prime,
                  part;


      goodPrime     VARCHAR2 (50);
      firstPass     BOOLEAN := TRUE;
      primePrefix   VARCHAR2 (3);
      char1         VARCHAR2 (1);
      char2         VARCHAR2 (1);
      char3         VARCHAR2 (1);
      priority      NUMBER := 0;
   BEGIN
      OPEN primeCur;

      FETCH primeCur BULK COLLECT INTO primeRecs;

      CLOSE primeCur;

      IF primeRecs.FIRST IS NOT NULL
      THEN
         FOR indx IN primeRecs.FIRST .. primeRecs.LAST
         LOOP
            --
            -- Set part of first rec as good prime in case good prime never shows.
            -- Funky logic used in Best Spares to determine good prime compares
            -- first 3 characters to determine good prime.
            --
            IF (firstPass)
            THEN
               goodPrime := primeRecs (indx).part;
               firstPass := FALSE;
            END IF;

            primePrefix := SUBSTR (primeRecs (indx).prime, 1, 3);
            char1 := SUBSTR (primeRecs (indx).prime, 1, 1);
            char2 := SUBSTR (primeRecs (indx).prime, 2, 1);
            char3 := SUBSTR (primeRecs (indx).prime, 3, 1);

            IF (primeRecs (indx).qNo = 1)
            THEN
               IF (    primeRecs (indx).part = primeRecs (indx).prime
                   AND primeRecs (indx).manuf_cage = '88277')
               THEN
                  goodPrime := primeRecs (indx).prime;
                  priority := 6;
               END IF;

               IF (    priority < 6
                   AND primeRecs (indx).part = primeRecs (indx).prime)
               THEN
                  goodPrime := primeRecs (indx).prime;
                  priority := 5;
               END IF;

               IF (priority < 5 AND primePrefix = '17B')
               THEN
                  goodPrime := primeRecs (indx).prime;
                  priority := 4;
               END IF;

               IF (priority < 4 AND primePrefix = '17P')
               THEN
                  goodPrime := primeRecs (indx).prime;
                  priority := 3;
               END IF;

               IF (    priority < 3
                   AND (    (   char1 != '1'
                             OR char2 != '7'
                             OR (char3 NOT IN ('P', 'B')))
                        AND (char1 > '9' OR char1 < '1' OR char2 != 'D')))
               THEN
                  goodPrime := primeRecs (indx).prime;
               END IF;
            END IF;
         END LOOP;
      END IF;

      RETURN goodPrime;
   END GetPrime;


   FUNCTION GetItemType (pSmrCode VARCHAR2)
      RETURN VARCHAR2
   IS
      itemType   VARCHAR2 (1);
      char1      VARCHAR2 (1);
      char6      VARCHAR2 (1);
   BEGIN
      char1 := SUBSTR (pSmrCode, 1, 1);
      char6 := SUBSTR (pSmrCode, 6, 1);

      -- Consumable when smr is P____N
      -- Repairable when smr is P____P
      --              or smr is P____T
      --
      IF (char1 = 'P')
      THEN
         IF (char6 = 'N')
         THEN
            itemType := 'C';
         ELSIF (char6 IN ('P', 'T'))
         THEN
            itemType := 'R';
         END IF;
      END IF;

      RETURN itemType;
   END GetItemType;


   FUNCTION getMic (pNsn VARCHAR2)
      RETURN VARCHAR2
   IS
      l67Mic   VARCHAR2 (1);
   BEGIN
      SELECT MIN (mic)
        INTO l67Mic
        FROM AMD_L67_SOURCE
       WHERE nsn = pNsn AND mic != '*' AND SUBSTR (doc_no, 1, 4) <> 'S005';

      RETURN l67Mic;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END;


   PROCEDURE getOriginalBssmData (
      nsn           IN     amd_nsns.nsn%TYPE,
      part_no       IN     bssm_parts.PART_NO%TYPE,
      condemn_avg      OUT amd_national_stock_items.condemn_avg%TYPE,
      criticality      OUT amd_national_stock_items.criticality%TYPE,
      nrts_avg         OUT amd_national_stock_items.nrts_avg%TYPE,
      rts_avg          OUT amd_national_stock_items.rts_avg%TYPE,
      amc_demand       OUT amd_national_stock_items.amc_demand%TYPE)
   IS
      PROCEDURE getByPartNo
      IS
      BEGIN
         SELECT condemn,
                criticality,
                nrts,
                rts,
                amc_demand
           INTO condemn_avg,
                criticality,
                nrts_avg,
                rts_avg,
                amc_demand
           FROM bssm_parts bp, AMD_NSNS nsns
          WHERE     lock_sid = ORIGINAL_DATA
                AND bp.part_no = getOriginalBssmData.part_no
                AND bp.nsn = nsns.nsn
                AND bp.nsn IN
                       (SELECT nsn
                          FROM AMD_NSNS
                         WHERE     nsi_sid = nsns.nsi_sid
                               AND nsn_type = CURRENT_NSN);
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            condemn_avg := NULL;
            criticality := NULL;
            nrts_avg := NULL;
            rts_avg := NULL;
            amc_demand := NULL;
         WHEN OTHERS
         THEN
            ErrorMsg (
               sqlFunction       => 'select',
               tableName         => 'bssm_parts',
               pError_location   => 90,
               key1              => 'part=' || getOriginalBssmData.part_no,
               key2              => 'nsn=' || getOriginalBssmData.nsn,
               key3              => 'locksid=' || ORIGINAL_DATA);
            DBMS_OUTPUT.put_line (
                  'getByPartNo: part_no='
               || getOriginalBssmData.part_no
               || ' nsn='
               || getOriginalBssmData.nsn
               || ' sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            RAISE;
      END getByPartNo;
   BEGIN
      SELECT condemn,
             criticality,
             nrts,
             rts,
             amc_demand
        INTO condemn_avg,
             criticality,
             nrts_avg,
             rts_avg,
             amc_demand
        FROM bssm_parts bp, AMD_NSNS nsns
       WHERE     lock_sid = ORIGINAL_DATA
             AND nsns.nsn = getOriginalBssmData.nsn
             AND bp.nsn IN
                    (SELECT nsn
                       FROM AMD_NSNS
                      WHERE nsi_sid = nsns.nsi_sid AND nsn_type = CURRENT_NSN);
   EXCEPTION
      WHEN STANDARD.NO_DATA_FOUND
      THEN
         getByPartNo;
      WHEN OTHERS
      THEN
         ErrorMsg (
            sqlFunction       => 'select',
            tableName         => 'bssm_parts',
            pError_location   => 100,
            key1              => 'part=' || getOriginalBssmData.part_no,
            key2              => 'nsn=' || getOriginalBssmData.nsn,
            key3              => 'locksid=' || ORIGINAL_DATA);
         DBMS_OUTPUT.put_line (
               'getOriginalBssmData: part_no='
            || getOriginalBssmData.part_no
            || ' nsn='
            || getOriginalBssmData.nsn
            || ' sqlcode='
            || SQLCODE
            || ' sqlerrm='
            || SQLERRM);
         RAISE;
   END getOriginalBssmData;

   FUNCTION getCalculatedData (nsn       IN amd_nsns.nsn%TYPE,
                               part_no   IN bssm_parts.PART_NO%TYPE)
      RETURN amd_national_stock_items.mtbdr_computed%TYPE
   IS
      mtbdr_computed   amd_national_stock_items.MTBDR_COMPUTED%TYPE := NULL;


      PROCEDURE getOriginalByPart
      IS
      BEGIN
         SELECT mtbdr_computed
           INTO mtbdr_computed
           FROM bssm_parts bp
          WHERE     bp.lock_sid = ORIGINAL_DATA
                AND (   bp.part_no = getCalculatedData.part_no
                     OR bp.part_no IS NULL)
                AND bp.nsn = getCalculatedData.nsn
                AND (   amd_utils.ISNSNACTIVEYORN (bp.nsn) = 'Y'
                     OR amd_utils.ISPARTACTIVEYORN (bp.part_no) = 'Y');
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            NULL;
         WHEN OTHERS
         THEN
            ErrorMsg (
               sqlFunction       => 'select',
               tableName         => 'bssm_parts and amd_nsns',
               pError_location   => 110,
               key1              => 'part=' || getCalculatedData.part_no,
               key2              => 'nsn=' || getCalculatedData.nsn,
               key3              => 'locksid=' || ORIGINAL_DATA);
            DBMS_OUTPUT.put_line (
                  'getOriginalByPart: part_no='
               || getCalculatedData.part_no
               || ' nsn='
               || getCalculatedData.nsn
               || ' lock_sid='
               || ORIGINAL_DATA
               || ' returning mtbdr_computed = null'
               || ' sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
      END getOriginalByPart;


      PROCEDURE getOriginalDataByNsn
      IS
      BEGIN
         SELECT mtbdr_computed
           INTO mtbdr_computed
           FROM bssm_parts p1
          WHERE     nsn = getCalculatedData.nsn
                AND (part_no = getCalculatedData.part_no OR part_no IS NULL)
                AND lock_sid = ORIGINAL_DATA
                AND mtbdr_computed IS NOT NULL
                AND (   amd_utils.ISNSNACTIVEYORN (nsn) = 'Y'
                     OR amd_utils.ISPARTACTIVEYORN (part_no) = 'Y');
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            getOriginalByPart;
         WHEN OTHERS
         THEN
            ErrorMsg (
               sqlFunction       => 'select',
               tableName         => 'bssm_parts and amd_nsns',
               pError_location   => 120,
               key1              => 'part=' || getCalculatedData.part_no,
               key2              => 'nsn=' || getCalculatedData.nsn,
               key3              => 'locksid=' || ORIGINAL_DATA);
            DBMS_OUTPUT.put_line (
                  'getOriginalDataByNsn: part_no='
               || getCalculatedData.part_no
               || ' nsn='
               || getCalculatedData.nsn
               || ' lock_sid='
               || ORIGINAL_DATA
               || ' returning mtbdr_computed = null'
               || ' sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
      END getOriginalDataByNsn;

      PROCEDURE getCleanedDataByPart
      IS
         cnt   NUMBER := 0;

         CURSOR bssmPartInfo
         IS
            SELECT mtbdr_computed
              INTO mtbdr_computed
              FROM bssm_parts bp
             WHERE     bp.lock_sid = CLEANED_DATA
                   AND mtbdr_computed IS NOT NULL
                   AND (   bp.part_no = getCalculatedData.part_no
                        OR bp.part_no IS NULL)
                   AND bp.nsn =
                          (SELECT nsn
                             FROM bssm_parts
                            WHERE     (   part_no = getCalculatedData.part_no
                                       OR part_no IS NULL)
                                  AND nsn = getCalculatedData.nsn
                                  AND lock_sid = ORIGINAL_DATA)
                   AND (   amd_utils.ISNSNACTIVEYORN (bp.nsn) = 'Y'
                        OR amd_utils.ISPARTACTIVEYORN (
                              getCalculatedData.part_no) = 'Y');
      BEGIN
         FOR rec IN bssmPartInfo
         LOOP
            cnt := cnt + 1;

            IF cnt = 1
            THEN
               mtbdr_computed := rec.mtbdr_computed;
            END IF;
         END LOOP;

         IF cnt > 1
         THEN
            DBMS_OUTPUT.put_line (
                  'getCleanedDataByPart: '
               || cnt
               || ' rows retrieved for part_no='
               || getCalculatedData.part_no
               || ' and lock_sid='
               || ORIGINAL_DATA);
         END IF;
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            getOriginalDataByNsn;
         WHEN OTHERS
         THEN
            ErrorMsg (
               sqlFunction       => 'select',
               tableName         => 'bssm_parts and amd_nsns',
               pError_location   => 130,
               key1              => 'part=' || getCalculatedData.part_no,
               key2              => 'nsn=' || getCalculatedData.nsn,
               key3              => 'locksid=' || ORIGINAL_DATA);
            DBMS_OUTPUT.put_line (
                  'getCleanedDataByPart: part_no='
               || getCalculatedData.part_no
               || ' nsn='
               || getCalculatedData.nsn
               || ' lock_sid='
               || ORIGINAL_DATA
               || ' returning mtbdr_computed = null'
               || ' sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
      END getCleanedDataByPart;
   BEGIN
      SELECT mtbdr_computed
        INTO mtbdr_computed
        FROM bssm_parts p1
       WHERE     nsn = getCalculatedData.nsn
             AND (part_no = getCalculatedData.part_no OR part_no IS NULL)
             AND lock_sid = CLEANED_DATA
             AND mtbdr_computed IS NOT NULL
             AND (   amd_utils.ISNSNACTIVEYORN (nsn) = 'Y'
                  OR EXISTS
                        (SELECT NULL
                           FROM bssm_parts p2
                          WHERE     p1.nsn = p2.nsn
                                AND (   p1.part_no = p2.part_no
                                     OR p2.part_no IS NULL)
                                AND p2.nsn = getCalculatedData.nsn
                                AND lock_sid = ORIGINAL_DATA
                                AND (   amd_utils.isPartActiveYorN (
                                           p2.part_no) = 'Y'
                                     OR amd_utils.IsNsnActiveYorN (p2.nsn) =
                                           'Y')));

      RETURN mtbdr_computed;
   EXCEPTION
      WHEN STANDARD.NO_DATA_FOUND
      THEN
         getCleanedDataByPart;
         RETURN mtbdr_computed;
      WHEN OTHERS
      THEN
         ErrorMsg (sqlFunction       => 'select',
                   tableName         => 'bssm_parts and amd_nsns',
                   pError_location   => 140,
                   key1              => 'part=' || getCalculatedData.part_no,
                   key2              => 'nsn=' || getCalculatedData.nsn,
                   key3              => 'locksid=' || CLEANED_DATA);
         DBMS_OUTPUT.put_line (
               'getCalculatedData: part_no='
            || getCalculatedData.part_no
            || ' nsn='
            || getCalculatedData.nsn
            || ' lock_sid='
            || CLEANED_DATA
            || ' returning mtbdr_computed = null'
            || ' sqlcode='
            || SQLCODE
            || ' sqlerrm='
            || SQLERRM);
         RETURN mtbdr_computed;
   END getCalculatedData;


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
      amc_demand_cleaned                  OUT amd_national_stock_items.amc_demand_cleaned%TYPE)
   IS
      line_no   NUMBER := 0;
   BEGIN
      line_no := line_no + 1;
      condemn_avg_cleaned := Amd_Clean_Data.GetCondemnAvg (nsn, part_no);
      line_no := line_no + 1;
      criticality_cleaned := Amd_Clean_Data.GetCriticality (nsn, part_no);
      line_no := line_no + 1;
      mtbdr_cleaned := Amd_Clean_Data.GetMtbdr (nsn, part_no);
      line_no := line_no + 1;
      nrts_avg_cleaned := Amd_Clean_Data.GetNrtsAvg (nsn, part_no);
      line_no := line_no + 1;
      rts_avg_cleaned := Amd_Clean_Data.GetRtsAvg (nsn, part_no);
      line_no := line_no + 1;
      order_lead_time_cleaned :=
         Amd_Utils.months2CalendarDays (
            Amd_Clean_Data.GetOrderLeadTime (nsn, part_no));
      line_no := line_no + 1;
      planner_code_cleaned :=
         UPPER (Amd_Clean_Data.GetPlannerCode (nsn, part_no));
      line_no := line_no + 1;
      smr_code_cleaned := UPPER (Amd_Clean_Data.GetSmrCode (nsn, part_no));
      line_no := line_no + 1;
      unit_cost_cleaned := Amd_Clean_Data.GetUnitCost (nsn, part_no);
      line_no := line_no + 1;
      cost_to_repair_off_base_cleand :=
         Amd_Clean_Data.GetCostToRepairOffBase (nsn, part_no);
      line_no := line_no + 1;
      time_to_repair_off_base_cleand :=
         Amd_Utils.months2CalendarDays (
            Amd_Clean_Data.GetTimeToRepairOffBase (nsn, part_no));
      line_no := line_no + 1;
      amc_demand_cleaned := Amd_Clean_Data.GETAMCDEMAND (nsn);
   EXCEPTION
      WHEN OTHERS
      THEN
         ErrorMsg (sqlFunction       => 'getCleanedBssmData',
                   tableName         => 'bssm_parts',
                   pError_location   => 150,
                   key1              => TO_CHAR (line_no),
                   key2              => nsn,
                   key3              => part_no);
         DBMS_OUTPUT.put_line (
               'getCleanedBssmData: nsn='
            || nsn
            || ' part_no='
            || part_no
            || ' sqlcode='
            || SQLCODE
            || ' sqlerrm='
            || SQLERRM);
         RAISE;
   END getCleanedBssmData;


   PROCEDURE getBssmData (
      nsn                              IN     amd_nsns.nsn%TYPE,
      part_no                          IN     bssm_parts.part_no%TYPE,
      condemn_avg                         OUT amd_national_stock_items.condemn_avg%TYPE,
      criticality                         OUT amd_national_stock_items.criticality%TYPE,
      mtbdr_computed                      OUT amd_national_stock_items.mtbdr_computed%TYPE,
      nrts_avg                            OUT amd_national_stock_items.nrts_avg%TYPE,
      rts_avg                             OUT amd_national_stock_items.rts_avg%TYPE,
      amc_demand                          OUT amd_national_stock_items.amc_demand%TYPE,
      condemn_avg_cleaned                 OUT AMD_NATIONAL_STOCK_ITEMS.condemn_avg_cleaned%TYPE,
      criticality_cleaned                 OUT AMD_NATIONAL_STOCK_ITEMS.criticality_cleaned%TYPE,
      mtbdr_cleaned                       OUT AMD_NATIONAL_STOCK_ITEMS.mtbdr_cleaned%TYPE,
      nrts_avg_cleaned                    OUT AMD_NATIONAL_STOCK_ITEMS.nrts_avg_cleaned%TYPE,
      rts_avg_cleaned                     OUT AMD_NATIONAL_STOCK_ITEMS.rts_avg_cleaned%TYPE,
      order_lead_time_cleaned             OUT AMD_NATIONAL_STOCK_ITEMS.order_lead_time_cleaned%TYPE,
      planner_code_cleaned                OUT AMD_NATIONAL_STOCK_ITEMS.planner_code_cleaned%TYPE,
      smr_code_cleaned                    OUT AMD_NATIONAL_STOCK_ITEMS.smr_code_cleaned%TYPE,
      unit_cost_cleaned                   OUT AMD_NATIONAL_STOCK_ITEMS.unit_cost_cleaned%TYPE,
      cost_to_repair_off_base_cleand      OUT AMD_NATIONAL_STOCK_ITEMS.cost_to_repair_off_base_cleand%TYPE,
      time_to_repair_off_base_cleand      OUT AMD_NATIONAL_STOCK_ITEMS.time_to_repair_off_base_cleand%TYPE,
      amc_demand_cleaned                  OUT amd_national_stock_items.amc_demand_cleaned%TYPE)
   IS
   BEGIN
      getOriginalBssmData (nsn           => nsn,
                           part_no       => part_no,
                           condemn_avg   => condemn_avg,
                           criticality   => criticality,
                           nrts_avg      => nrts_avg,
                           rts_avg       => rts_avg,
                           amc_demand    => amc_demand);

      getCleanedBssmData (
         nsn                              => nsn,
         part_no                          => part_no,
         condemn_avg_cleaned              => condemn_avg_cleaned,
         criticality_cleaned              => criticality_cleaned,
         mtbdr_cleaned                    => mtbdr_cleaned,
         nrts_avg_cleaned                 => nrts_avg_cleaned,
         rts_avg_cleaned                  => rts_avg_cleaned,
         order_lead_time_cleaned          => order_lead_time_cleaned,
         planner_code_cleaned             => planner_code_cleaned,
         smr_code_cleaned                 => smr_code_cleaned,
         unit_cost_cleaned                => unit_cost_cleaned,
         cost_to_repair_off_base_cleand   => cost_to_repair_off_base_cleand,
         time_to_repair_off_base_cleand   => time_to_repair_off_base_cleand,
         amc_demand_cleaned               => amc_demand_cleaned);

      mtbdr_computed := getCalculatedData (nsn => nsn, part_no => part_no);
      planner_code_cleaned :=
         amd_utils.validatePlannerCode (planner_code_cleaned);
   END getBssmData;

   PROCEDURE getRmadsData (
      part_no         IN     amd_rmads_source_tmp.part_no%TYPE,
      qpei_weighted      OUT amd_rmads_source_tmp.QPEI_WEIGHTED%TYPE,
      mtbdr              OUT amd_rmads_source_tmp.MTBDR%TYPE)
   IS
   BEGIN
      SELECT qpei_weighted,
             CASE
                WHEN FLOOR (
                        MONTHS_BETWEEN (SYSDATE, cat1.created_datetime) / 12) <
                        5
                THEN
                   mtbdr
                ELSE
                   NULL
             END
                mtbdr
        INTO qpei_weighted, mtbdr
        FROM AMD_RMADS_SOURCE_TMP, cat1
       WHERE part_no = getRmadsData.part_no AND part_no = cat1.part;
   EXCEPTION
      WHEN STANDARD.NO_DATA_FOUND
      THEN
         qpei_weighted := NULL;
         mtbdr := NULL;
      WHEN OTHERS
      THEN
         ErrorMsg (sqlFunction       => 'select',
                   tableName         => 'amd_rmads_source_tmp,cat1',
                   pError_location   => 160,
                   key1              => getRmadsData.part_no);
         DBMS_OUTPUT.put_line (
               'getRmadsData: part_no='
            || getRmadsData.part_no
            || ' sqlcode='
            || SQLCODE
            || ' sqlerrm='
            || SQLERRM);
         RAISE;
   END getRmadsData;

   FUNCTION getOrderLeadTime (part IN cat1.part%TYPE)
      RETURN NUMBER
   IS
      ave_cap_lead_time   cat1.AVE_CAP_LEAD_TIME%TYPE;
   BEGIN
      SELECT ave_cap_lead_time
        INTO getOrderLeadTime.ave_cap_lead_time
        FROM CAT1
       WHERE part = (getOrderleadTime.part);

      IF ave_cap_lead_time = 0
      THEN
         ave_cap_lead_time := NULL;
      END IF;

      RETURN ave_cap_lead_time;
   EXCEPTION
      WHEN STANDARD.NO_DATA_FOUND
      THEN
         RETURN NULL;
   END getOrderLeadTime;

   PROCEDURE setDebugThreshold (VALUE IN NUMBER := NULL)
   IS
   BEGIN
      IF VALUE IS NULL
      THEN
         SELECT ROUND (COUNT (*) / 10)
           INTO debugThreshold
           FROM amd_spare_parts
          WHERE action_code <> amd_defaults.getDELETE_ACTION;
      ELSE
         debugThreshold := VALUE;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         debugThreshold := 10000;
   END setDebugThreshold;

   PROCEDURE setPsmsThreshold (VALUE IN NUMBER := NULL)
   IS
   BEGIN
      IF VALUE IS NULL
      THEN
         SELECT ROUND (COUNT (*) / 10)
           INTO psmsThreshold
           FROM amd_spare_parts
          WHERE action_code <> amd_defaults.getDELETE_ACTION;
      ELSE
         psmsThreshold := VALUE;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         psmsThreshold := 500;
   END setPsmsThreshold;

   PROCEDURE setStartDebugRec (VALUE IN NUMBER)
   IS
   BEGIN
      startDebugRec := VALUE;
   END setStartDebugRec;

   FUNCTION getStartDebugRec
      RETURN NUMBER
   IS
   BEGIN
      RETURN startDebugRec;
   END getStartDebugRec;

   FUNCTION getDebugThreshold
      RETURN NUMBER
   IS
   BEGIN
      RETURN debugThreshold;
   END getDebugThreshold;



   PROCEDURE LoadGold
   IS
      bulk_errors       EXCEPTION;
      PRAGMA EXCEPTION_INIT (bulk_errors, -24381);

      TYPE tmpRecs IS TABLE OF tmp_amd_spare_parts%ROWTYPE
         INDEX BY PLS_INTEGER;

      recsOut           tmpRecs;

      TYPE catRec IS RECORD
      (
         nsn                   cat1.nsn%TYPE,
         part_type             VARCHAR2 (10),
         part                  cat1.part%TYPE,
         prime                 cat1.prime%TYPE,
         manuf_cage            cat1.manuf_cage%TYPE,
         source_code           cat1.source_code%TYPE,
         noun                  cat1.noun%TYPE,
         serial_mandatory_b    cat1.serial_mandatory_b%TYPE,
         ims_designator_code   cat1.ims_designator_code%TYPE,
         smrc                  cat1.smrc%TYPE,
         um_cap_code           cat1.um_cap_code%TYPE,
         user_ref7             cat1.user_ref7%TYPE,
         um_show_code          cat1.um_show_code%TYPE
      );

      TYPE catTab IS TABLE OF catRec;

      catRecs           catTab;

      CURSOR catCur
      IS
         SELECT nsn,
                DECODE (prime, part, 'PRIME', 'EQUIVALENT') partType,
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
          WHERE     source_code = amd_defaults.getSourceCode
                AND nsn NOT LIKE 'N%'
         UNION
         SELECT nsn,
                DECODE (prime, part, 'PRIME', 'EQUIVALENT') partType,
                part,
                prime,
                manuf_cage,
                source_code,
                noun,
                serial_mandatory_b,
                ims_designator_code,
                smrc,
                um_cap_code,
                TRIM (user_ref7) user_ref7,
                um_show_code
           FROM CAT1
          WHERE     source_code = amd_defaults.getSourceCode
                AND nsn LIKE amd_defaults.getNonStockageList || '%'
                AND part = prime
         ORDER BY nsn, partType DESC, part;



      loadNo            NUMBER;
      nsn               VARCHAR2 (50);
      prevNsn           VARCHAR2 (50) := 'prevNsn';
      nsnStripped       VARCHAR2 (50);
      goodPrime         VARCHAR2 (50);
      primeInd          VARCHAR2 (1);
      itemType          VARCHAR2 (1);
      smrCode           VARCHAR2 (6);
      orderUom          VARCHAR2 (2);
      orderleadTime     NUMBER;
      plannerCode       VARCHAR2 (8);
      nsnType           VARCHAR2 (1);
      hasPrimeRec       BOOLEAN;
      sequenced         BOOLEAN;
      l67Mic            VARCHAR2 (1);
      unitCost          NUMBER;
      unitOfIssue       VARCHAR2 (2);
      mMac              VARCHAR2 (2);
      rowsInserted      NUMBER := 0;
      loopStartTime     NUMBER := 0;
      cur_line          NUMBER := 0;
      trigger_problem   BOOLEAN := FALSE;
   BEGIN
      writeMsg (
         pTableName        => 'tmp_amd_spare_parts',
         pError_location   => 170,
         pKey1             => 'loadGold',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
      Mta_Truncate_Table ('tmp_amd_spare_parts', 'reuse storage');

      loadNo := Amd_Utils.GetLoadNo ('GOLD', 'TMP_AMD_SPARE_PARTS');

      OPEN catCur;

      FETCH catCur BULK COLLECT INTO catRecs;

      CLOSE catCur;


      IF catRecs.FIRST IS NOT NULL
      THEN
         writeMsg (
            pTableName        => 'tmp_amd_spare_parts',
            pError_location   => 210,
            pKey1             => 'cat1_loop',
            pKey2             =>    'started at '
                                 || TO_CHAR (SYSDATE,
                                             'MM/DD/YYYY HH:MI:SS AM'));


         FOR indx IN catRecs.FIRST .. catRecs.LAST
         LOOP
           <<cat1_proc>>
            BEGIN
               loopStartTime := DBMS_UTILITY.get_time;

               IF (catRecs (indx).nsn LIKE
                      amd_defaults.getNonStockageList || '%')
               THEN
                  sequenced := TRUE;
                  nsn :=
                     Amd_Nsl_Sequence_Pkg.SequenceTheNsl (
                        catRecs (indx).prime);
               ELSE
                  sequenced := FALSE;
                  nsn := catRecs (indx).nsn;
               END IF;

               cur_line := 10;

               IF (nsn != prevNsn)
               THEN
                  prevNsn := nsn;
                  nsnStripped := Amd_Utils.FormatNsn (nsn);

                  -- If sequenceTheNsl() returned an NSL$ then it is assumed to be
                  -- the prime, otherwise, run it through the getPrime() logic.
                  --
                  IF (nsn LIKE amd_defaults.getNonStockageList || '%')
                  THEN
                     IF (NOT onNsl (catRecs (indx).part))
                     THEN
                        -- An NSL starts the part/nsn process so 'delete' the part
                        -- so the diff will think it's a brand new part and
                        -- assign it its own nsi_sid.
                        --
                        performLogicalDelete (catRecs (indx).part);
                     END IF;

                     goodPrime := catRecs (indx).part;
                  ELSE
                     goodPrime := GetPrime (nsn);
                  END IF;

                  cur_line := 20;

                  nsnType := 'C';
                  cur_line := 30;
                  plannerCode :=
                     amd_utils.validatePlannerCode (
                        catRecs (indx).ims_designator_code);
                  cur_line := 40;
                  itemType := NULL;
                  cur_line := 50;
                  smrCode := catRecs (indx).smrc;

                  cur_line := 60;

                  IF LENGTH (catRecs (indx).um_show_code) <= 2
                  THEN
                     unitOfIssue := catRecs (indx).um_show_code;
                  ELSIF LENGTH (catRecs (indx).um_show_code) > 2
                  THEN
                     IF UPPER (catRecs (indx).um_show_code) = 'KIT'
                     THEN
                        unitOfIssue := 'KT';
                     ELSE
                        unitOfIssue :=
                           SUBSTR (catRecs (indx).um_show_code, 1, 2);
                     END IF;
                  END IF;

                  cur_line := 70;

                  IF LENGTH (catRecs (indx).um_cap_code) <= 2
                  THEN
                     orderUom := catRecs (indx).um_cap_code;
                  ELSE
                     IF LENGTH (catRecs (indx).um_cap_code) > 2
                     THEN
                        orderUom := SUBSTR (catRecs (indx).um_cap_code, 1, 2);
                     END IF;
                  END IF;

                  cur_line := 80;

                  IF (IsValidSmr (smrCode))
                  THEN
                     itemType := GetItemType (smrCode);
                  END IF;
               END IF;

               -- if GetPrime() returned a null that means that the nsn no longer
               -- exists in Gold. This happens when a part goes from an NCZ to an NSL
               --
               IF (goodPrime IS NULL OR catRecs (indx).part = goodPrime)
               THEN
                  primeInd := 'Y';
               ELSE
                  primeInd := 'N';
               END IF;

               cur_line := 90;

               l67Mic := getMic (nsnStripped);
               cur_line := 100;

               unitCost := getUnitCost (catRecs (indx).part);
               cur_line := 110;

               mMac := getMmac (catRecs (indx).nsn);
               cur_line := 120;

               IF     mDebug
                  AND (   rowsInserted > startDebugRec
                       OR MOD (indx, debugThreshold) = 0)
               THEN
                  debugMsg (
                        'rowsInserted='
                     || rowsInserted
                     || ' part='
                     || catRecs (indx).part
                     || ' time:'
                     || (DBMS_UTILITY.get_time - loopStartTime),
                     pError_location   => 220);
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  ErrorMsg (sqlFunction       => 'select',
                            tableName         => 'cat1',
                            key1              => catRecs (indx).part,
                            key2              => 'cur_line=' || cur_line,
                            pError_location   => 230);
                  DBMS_OUTPUT.put_line (
                        'cat1_proc: part='
                     || catRecs (indx).part
                     || ' sqlcode='
                     || SQLCODE
                     || ' sqlerrm='
                     || SQLERRM);
                  RAISE;
            END cat1_proc;

           -- 4/13/05 DSE created insertTmpAmdSpareParts block of code

           <<insertTmpAmdSpareParts>>
            DECLARE
               mtbdr                            AMD_NATIONAL_STOCK_ITEMS.mtbdr%TYPE;
               mtbdr_cleaned                    AMD_NATIONAL_STOCK_ITEMS.mtbdr_cleaned%TYPE;
               qpei_weighted                    AMD_NATIONAL_STOCK_ITEMS.qpei_weighted%TYPE;
               condemn_avg                      AMD_NATIONAL_STOCK_ITEMS.condemn_avg%TYPE;
               condemn_avg_cleaned              AMD_NATIONAL_STOCK_ITEMS.condemn_avg_cleaned%TYPE;
               criticality                      AMD_NATIONAL_STOCK_ITEMS.criticality%TYPE;
               criticality_cleaned              AMD_NATIONAL_STOCK_ITEMS.criticality_cleaned%TYPE;
               nrts_avg                         AMD_NATIONAL_STOCK_ITEMS.nrts_avg%TYPE;
               nrts_avg_cleaned                 AMD_NATIONAL_STOCK_ITEMS.nrts_avg_cleaned%TYPE;
               cost_to_repair_off_base_cleand   AMD_NATIONAL_STOCK_ITEMS.cost_to_repair_off_base_cleand%TYPE;
               time_to_repair_off_base_cleand   AMD_NATIONAL_STOCK_ITEMS.time_to_repair_off_base_cleand%TYPE;
               order_lead_time_cleaned          AMD_NATIONAL_STOCK_ITEMS.order_lead_time_cleaned%TYPE;
               planner_code_cleaned             AMD_NATIONAL_STOCK_ITEMS.planner_code_cleaned%TYPE;
               rts_avg                          AMD_NATIONAL_STOCK_ITEMS.rts_avg%TYPE;
               rts_avg_cleaned                  AMD_NATIONAL_STOCK_ITEMS.rts_avg_cleaned%TYPE;
               smr_code_cleaned                 AMD_NATIONAL_STOCK_ITEMS.smr_code_cleaned%TYPE;
               unit_cost_cleaned                AMD_NATIONAL_STOCK_ITEMS.unit_cost_cleaned%TYPE;
               cost_to_repair_off_base          AMD_NATIONAL_STOCK_ITEMS.cost_to_repair_off_base%TYPE;
               time_to_repair_off_base          AMD_NATIONAL_STOCK_ITEMS.time_to_repair_off_base%TYPE;
               mtbdr_computed                   amd_national_stock_items.mtbdr_computed%TYPE;
               amc_demand                       amd_national_stock_items.amc_demand%TYPE;
               amc_demand_cleaned               amd_national_stock_items.amc_demand_cleaned%TYPE;

               PROCEDURE addRec (indx IN NUMBER)
               IS
               BEGIN
                  recsOut (indx).part_no := catRecs (indx).part;
                  cur_line := 130;
                  recsOut (indx).mfgr := catRecs (indx).manuf_cage;
                  cur_line := 140;
                  recsOut (indx).icp_ind := catRecs (indx).source_code;
                  cur_line := 150;
                  recsOut (indx).item_type := itemType;
                  cur_line := 160;
                  recsOut (indx).nomenclature := catRecs (indx).noun;
                  cur_line := 170;
                  recsOut (indx).nsn := nsnStripped;
                  cur_line := 180;
                  recsOut (indx).nsn_type := nsnType;
                  cur_line := 190;
                  recsOut (indx).planner_code := plannerCode;
                  cur_line := 200;

                  IF LENGTH (catRecs (indx).um_cap_code) <= 2
                  THEN
                     recsOut (indx).order_uom := catRecs (indx).um_cap_code;
                     cur_line := 210;
                  ELSE
                     IF LENGTH (catRecs (indx).um_cap_code) > 2
                     THEN
                        recsOut (indx).order_uom :=
                           SUBSTR (catRecs (indx).um_cap_code, 1, 2);
                     END IF;
                  END IF;

                  IF useBizDays
                  THEN
                     recsOut (indx).order_lead_time :=
                        amd_utils.bizDays2CalendarDays (
                           getOrderLeadTime (catRecs (indx).part));
                     cur_line := 220;
                  ELSE
                     recsOut (indx).order_lead_time :=
                        getOrderLeadTime (catRecs (indx).part);
                     cur_line := 220;
                  END IF;

                  recsOut (indx).prime_ind := primeInd;
                  cur_line := 230;
                  recsOut (indx).serial_flag :=
                     catRecs (indx).serial_mandatory_b;
                  cur_line := 240;
                  recsOut (indx).smr_code := smrCode;
                  cur_line := 250;
                  recsOut (indx).acquisition_advice_code :=
                     catRecs (indx).user_ref7;
                  cur_line := 260;
                  recsOut (indx).unit_cost := unitCost;
                  cur_line := 270;
                  recsOut (indx).mic := l67Mic;
                  cur_line := 280;
                  recsOut (indx).mmac := mMac;
                  cur_line := 290;
                  recsOut (indx).unit_of_issue := unitOfIssue;
                  cur_line := 300;
                  recsOut (indx).mtbdr := mtbdr;
                  cur_line := 310;
                  recsOut (indx).mtbdr_computed := mtbdr_computed;
                  cur_line := 320;
                  recsOut (indx).mtbdr_cleaned := mtbdr_cleaned;
                  cur_line := 330;
                  recsOut (indx).qpei_weighted := qpei_weighted;
                  cur_line := 340;
                  recsOut (indx).condemn_avg := condemn_avg;
                  cur_line := 350;
                  recsOut (indx).condemn_avg_cleaned := condemn_avg_cleaned;
                  cur_line := 360;
                  recsOut (indx).criticality := criticality;
                  cur_line := 370;
                  recsOut (indx).criticality_cleaned := criticality_cleaned;
                  cur_line := 380;
                  recsOut (indx).nrts_avg_cleaned := nrts_avg_cleaned;
                  cur_line := 390;
                  recsOut (indx).nrts_avg := nrts_avg;
                  cur_line := 400;
                  recsOut (indx).time_to_repair_off_base_cleand :=
                     time_to_repair_off_base_cleand;
                  cur_line := 410;
                  recsOut (indx).order_lead_time_cleaned :=
                     order_lead_time_cleaned;
                  cur_line := 420;
                  recsOut (indx).planner_code_cleaned := planner_code_cleaned;
                  cur_line := 430;
                  recsOut (indx).rts_avg := rts_avg;
                  cur_line := 440;
                  recsOut (indx).rts_avg_cleaned := rts_avg_cleaned;
                  cur_line := 450;
                  recsOut (indx).smr_code_cleaned := smr_code_cleaned;
                  cur_line := 460;
                  recsOut (indx).unit_cost_cleaned := unit_cost_cleaned;
                  cur_line := 470;
                  recsOut (indx).cost_to_repair_off_base :=
                     cost_to_repair_off_base;
                  cur_line := 480;
                  recsOut (indx).time_to_repair_off_base :=
                     time_to_repair_off_base;
                  cur_line := 490;
                  recsOut (indx).amc_demand := amc_demand;
                  cur_line := 500;
                  recsOut (indx).amc_demand_cleaned := amc_demand_cleaned;
                  cur_line := 510;
                  recsOut (indx).last_update_dt := SYSDATE;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     ErrorMsg (sqlFunction       => 'addRec',
                               tableName         => 'tmp_amd_spare_parts',
                               pError_location   => 180,
                               key1              => catRecs (indx).part,
                               key2              => 'cur_line=' || cur_line);
                     DBMS_OUTPUT.put_line (
                           'addRec: part='
                        || catRecs (indx).part
                        || ' sqlcode='
                        || SQLCODE
                        || ' sqlerrm='
                        || SQLERRM);
                     RAISE;
               END addRec;
            BEGIN
               getBssmData (
                  nsn                              => nsnStripped,
                  part_no                          => catRecs (indx).part,
                  condemn_avg                      => condemn_avg,
                  criticality                      => criticality,
                  mtbdr_computed                   => mtbdr_computed,
                  nrts_avg                         => nrts_avg,
                  rts_avg                          => rts_avg,
                  amc_demand                       => amc_demand,
                  condemn_avg_cleaned              => condemn_avg_cleaned,
                  criticality_cleaned              => criticality_cleaned,
                  mtbdr_cleaned                    => mtbdr_cleaned,
                  nrts_avg_cleaned                 => nrts_avg_cleaned,
                  rts_avg_cleaned                  => rts_avg_cleaned,
                  order_lead_time_cleaned          => order_lead_time_cleaned,
                  planner_code_cleaned             => planner_code_cleaned,
                  smr_code_cleaned                 => smr_code_cleaned,
                  unit_cost_cleaned                => unit_cost_cleaned,
                  cost_to_repair_off_base_cleand   => cost_to_repair_off_base_cleand,
                  time_to_repair_off_base_cleand   => time_to_repair_off_base_cleand,
                  amc_demand_cleaned               => amc_demand_cleaned);

               getRmadsData (part_no         => catRecs (indx).part,
                             qpei_weighted   => qpei_weighted,
                             mtbdr           => mtbdr);

               cur_line := 520;

               IF primeInd = 'Y'
               THEN
                  cur_line := 530;
                  cost_to_repair_off_base :=
                     GetOffBaseRepairCost (catRecs (indx).part);
                  cur_line := 540;
                  time_to_repair_off_base :=
                     GetOffBaseTurnAround (catRecs (indx).part);
               END IF;

               cur_line := 550;
               rowsInserted := rowsInserted + 1;
               cur_line := 560;
               addRec (rowsInserted);
               cur_line := 570;

               IF recsOut.COUNT >= bulkInsertThreshold
               THEN
                  FORALL i IN recsOut.FIRST .. recsOut.LAST SAVE EXCEPTIONS
                     INSERT INTO tmp_amd_spare_parts
                          VALUES recsOut (i);

                  recsOut.delete;
               END IF;

               cur_line := 580;

               IF MOD (indx, debugThreshold) = 0
               THEN
                  debugMsg (
                     'indx=' || indx || ' part=' || catRecs (indx).part,
                     pError_location   => 250);
               END IF;
            EXCEPTION
               WHEN bulk_errors
               THEN
                  FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
                  LOOP
                     ErrorMsg (
                        sqlFunction       => 'insert',
                        tableName         => 'tmp_amd_spare_parts',
                        pError_location   => 190,
                        key1              =>    'index='
                                             || TO_CHAR (
                                                   SQL%BULK_EXCEPTIONS (j).ERROR_INDEX),
                        key2              => SQLERRM (
                                               SQL%BULK_EXCEPTIONS (j).ERROR_CODE));

                     IF SQL%BULK_EXCEPTIONS (j).ERROR_CODE = -4098
                     THEN
                        trigger_problem := TRUE;
                     END IF;
                  END LOOP;

                  IF NOT trigger_problem
                  THEN
                     DBMS_OUTPUT.put_line (
                           'insertTmpAmdSpareParts: 1'
                        || ' sqlcode='
                        || SQLCODE
                        || ' sqlerrm='
                        || SQLERRM);
                     RAISE;
                  END IF;
               WHEN OTHERS
               THEN
                  ErrorMsg (sqlFunction       => 'insert',
                            tableName         => 'tmp_amd_spare_parts',
                            pError_location   => 200,
                            key1              => nsnStripped,
                            key2              => catRecs (indx).part,
                            key3              => catRecs (indx).manuf_cage,
                            key4              => 'cur_line=' || cur_line);

                  IF SQLCODE = -4098
                  THEN
                     trigger_problem := TRUE;
                  END IF;

                  IF NOT trigger_problem
                  THEN
                     DBMS_OUTPUT.put_line (
                           'insertTmpAmdSpareParts: 2'
                        || ' sqlcode='
                        || SQLCODE
                        || ' sqlerrm='
                        || SQLERRM);
                     RAISE;
                  END IF;
            END insertTmpAmdSpareParts;

            cur_line := 590;


            IF MOD (indx, debugThreshold) = 0
            THEN
               debugMsg ('indx=' || indx || ' part=' || catRecs (indx).part,
                         pError_location   => 280);
            END IF;
         --end loop;
         END LOOP;

         writeMsg (
            pTableName        => 'tmp_amd_spare_parts',
            pError_location   => 290,
            pKey1             => 'cat1_loop',
            pKey2             =>    'ended at '
                                 || TO_CHAR (SYSDATE,
                                             'MM/DD/YYYY HH:MI:SS AM'));

         writeMsg (
            pTableName        => 'tmp_amd_spare_parts',
            pError_location   => 212,
            pKey1             => 'bulk_insert',
            pKey2             =>    'started at '
                                 || TO_CHAR (SYSDATE,
                                             'MM/DD/YYYY HH:MI:SS AM'));

        <<bulk_insert>>
         BEGIN
            FORALL i IN recsOut.FIRST .. recsOut.LAST SAVE EXCEPTIONS
               INSERT INTO tmp_amd_spare_parts
                    VALUES recsOut (i);

            writeMsg (
               pTableName        => 'tmp_amd_spare_parts',
               pError_location   => 214,
               pKey1             => 'bulk_insert',
               pKey2             =>    'ended at '
                                    || TO_CHAR (SYSDATE,
                                                'MM/DD/YYYY HH:MI:SS AM'));
         EXCEPTION
            WHEN bulk_errors
            THEN
               FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
               LOOP
                  ErrorMsg (
                     sqlFunction       => 'insert',
                     tableName         => 'tmp_amd_spare_parts',
                     pError_location   => 215,
                     key1              =>    'index='
                                          || TO_CHAR (
                                                SQL%BULK_EXCEPTIONS (j).ERROR_INDEX),
                     key2              => SQLERRM (
                                            SQL%BULK_EXCEPTIONS (j).ERROR_CODE));
               END LOOP;

               DBMS_OUTPUT.put_line (
                     'loadGold: bulk_insert sqlcode='
                  || SQLCODE
                  || ' sqlerrm='
                  || SQLERRM);
               RAISE;
         END bulk_insert;
      END IF;

      writeMsg (
         pTableName        => 'tmp_amd_spare_parts',
         pError_location   => 220,
         pKey1             => 'loadGold',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
         pKey3             => 'rowsInserted=' || TO_CHAR (rowsInserted));

      DBMS_OUTPUT.put_line (
            'loadGold: '
         || rowsInserted
         || ' rows inserted to tmp_amd_spare_parts');


      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ErrorMsg (sqlFunction       => 'loadGold',
                   tableName         => 'tmp_amd_spare_parts',
                   pError_location   => 230,
                   key1              => 'cur_line=' || cur_line);
         DBMS_OUTPUT.put_line (
               'loadGold had an error - check amd_load_details. rowsInserted='
            || rowsInserted
            || ' sqlcode='
            || SQLCODE
            || ' sqlerrm='
            || SQLERRM);
         RAISE;
   END LoadGold;


   PROCEDURE LoadRblPairs
   IS
      CURSOR rblpairs
      IS
           SELECT old_nsn,
                  new_nsn,
                  subgroup_code,
                  part_pref_code,
                  SYSDATE,
                  'A'
             FROM amd_isgp_rbl_pairs_v
         ORDER BY old_nsn, subgroup_code, part_pref_code;

      dup_cnt   NUMBER := 0;
      ins_cnt   NUMBER := 0;
   BEGIN
      mta_truncate_table ('AMD_RBL_PAIRS', 'reuse storage');


      --Populate data into table AMD_RBL_PAIRS
      FOR rec IN rblpairs
      LOOP
        <<insertRblPairs>>
         BEGIN
            INSERT INTO AMD_RBL_PAIRS (old_nsn,
                                       new_nsn,
                                       subgroup_code,
                                       part_pref_code,
                                       last_update_dt,
                                       action_code)
                 VALUES (rec.old_nsn,
                         rec.new_nsn,
                         rec.subgroup_code,
                         rec.part_pref_code,
                         SYSDATE,
                         'A');

            ins_cnt := ins_cnt + 1;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               dup_cnt := dup_cnt + 1;
               DBMS_OUTPUT.put_line (
                     'duplicate: '
                  || rec.old_nsn
                  || ','
                  || rec.new_nsn
                  || ','
                  || rec.subgroup_code
                  || ','
                  || rec.part_pref_code);
         END insertRblPairs;
      END LOOP;

      IF dup_cnt > 0
      THEN
         DBMS_OUTPUT.put_line ('number of duplicates=' || dup_cnt);
      END IF;

      DBMS_OUTPUT.put_line ('LoadRblPairs: rows inserted=' || ins_cnt);
   END LoadRblPairs;



   PROCEDURE LoadPsms
   IS
      TYPE t_shelf_life_tab IS TABLE OF tmp_amd_spare_parts.SHELF_LIFE%TYPE;

      TYPE t_unit_volume_tab IS TABLE OF tmp_amd_spare_parts.UNIT_VOLUME%TYPE;

      TYPE t_smr_code_tab IS TABLE OF tmp_amd_spare_parts.SMR_CODE%TYPE;

      TYPE t_item_type_tab IS TABLE OF tmp_amd_spare_parts.ITEM_TYPE%TYPE;

      shelf_life_tab      t_shelf_life_tab;
      unit_volume_tab     t_unit_volume_tab;
      smr_code_tab        t_smr_code_tab;
      item_type_tab       t_item_type_tab;
      part_no_tab         t_part_no_tab;

      CURSOR F77
      IS
         SELECT TRIM (tp.part_no) part_no,
                CASE
                   WHEN SUBSTR (slic.smr_code, 6, 1) IN ('P', 'T', 'N')
                   THEN
                      TRIM (slic.smr_code)
                   ELSE
                      tp.smr_code
                END
                   smr_code,
                CASE
                   WHEN SUBSTR (slic.smr_code, 1, 1) = 'P'
                   THEN
                      CASE
                         WHEN SUBSTR (slic.smr_code, 6, 1) IN ('P', 'T')
                         THEN
                            'R'                                  -- repairable
                         WHEN SUBSTR (slic.smr_code, 6, 1) = 'N'
                         THEN
                            'C'                                  -- consumable
                         ELSE
                            tp.item_type
                      END
                   ELSE
                      tp.item_type
                END
                   item_type,
                slic.storage_days,
                slic.unit_volume
           FROM TMP_AMD_SPARE_PARTS tp, slic_ha_shelf_life_v slic
          WHERE     slic.part_no = CAST (tp.part_no AS CHAR (50))
                AND slic.mfgr = CAST (tp.mfgr AS CHAR (5));

      cnt                 NUMBER := 0;
      loadPsmsStartTime   NUMBER := DBMS_UTILITY.get_time;
   BEGIN
      writeMsg (
         pTableName        => 'tmp_amd_spare_parts',
         pError_location   => 240,
         pKey1             => 'loadPsms',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      --
      --     Get the load_no for insert into amd_load_status table
      --

      --
      -- select ICP Part/CAGE and check to see if the part is existing in PSMS.
      --
      OPEN f77;

      FETCH f77
         BULK COLLECT INTO part_no_tab,
              smr_code_tab,
              item_type_tab,
              shelf_life_tab,
              unit_volume_tab;

      CLOSE f77;

      IF part_no_tab.FIRST IS NOT NULL
      THEN
        <<bulkUpdt>>
         BEGIN
            FORALL i IN part_no_tab.FIRST .. part_no_tab.LAST
               UPDATE tmp_amd_spare_parts
                  SET shelf_life = shelf_life_tab (i),
                      unit_volume = unit_volume_tab (i),
                      smr_code = smr_code_tab (i),
                      item_type = item_type_tab (i)
                WHERE part_no = part_no_tab (i) AND smr_code IS NULL;

            FOR i IN part_no_tab.FIRST .. part_no_tab.LAST
            LOOP
               cnt := cnt + SQL%BULK_ROWCOUNT (i);
            END LOOP;
         EXCEPTION
            WHEN OTHERS
            THEN
               ErrorMsg (sqlFunction       => 'bulk_update',
                         tableName         => 'tmp_amd_spare_parts',
                         pError_location   => 260,
                         key1              => 'bulkUpdt');
               DBMS_OUTPUT.put_line (
                  'bulkUpdt: sqlcode=' || SQLCODE || ' sqlerrm=' || SQLERRM);
               RAISE;
         END bulkUpdt;
      END IF;

      DBMS_OUTPUT.put_line (
         'loadPsms: ' || cnt || ' rows loaded to tmp_amd_spare_parts');
      writeMsg (
         pTableName        => 'tmp_amd_spare_parts',
         pError_location   => 270,
         pKey1             => 'loadPsms',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
         pKey3             => 'rowsUpdated=' || TO_CHAR (cnt),
         pKey4             =>    'elapsedTime='
                              || (DBMS_UTILITY.get_time - loadPsmsStartTime));

      COMMIT;
      debugMsg (
         'loadPsms secs:' || (DBMS_UTILITY.get_time - loadPsmsStartTime),
         pError_location   => 350);
   EXCEPTION
      WHEN OTHERS
      THEN
         ErrorMsg (sqlFunction       => 'load',
                   tableName         => 'tmp_amd_spare_parts',
                   pError_location   => 280,
                   key1              => 'loadPsms',
                   key2              => 'cnt=' || cnt);
         DBMS_OUTPUT.put_line (
               'loadPsms: cnt='
            || cnt
            || ' sqlcode='
            || SQLCODE
            || ' sqlerrm='
            || SQLERRM);
         RAISE;
   END LoadPsms;



   PROCEDURE LoadMain
   IS
      TYPE mainRec IS RECORD
      (
         part_no     tmp_amd_spare_parts.part_no%TYPE,
         nsn         tmp_amd_spare_parts.nsn%TYPE,
         prime_ind   tmp_amd_spare_parts.prime_ind%TYPE,
         smrCode6    VARCHAR2 (1)
      );

      TYPE mainTab IS TABLE OF mainRec;

      mainRecs             mainTab;

      TYPE t_order_quantity_tab
         IS TABLE OF tmp_amd_spare_parts.ORDER_QUANTITY%TYPE;

      order_quantity_tab   t_order_quantity_tab := t_order_quantity_tab ();
      part_no_tab          t_part_no_tab := t_part_no_tab ();


      CURSOR f77Cur
      IS
           SELECT part_no,
                  nsn,
                  prime_ind,
                  SUBSTR (smr_code, 6, 1) smrCode6
             FROM TMP_AMD_SPARE_PARTS
         ORDER BY nsn, prime_ind DESC;



      loadNo               NUMBER;
      cnt                  NUMBER := 0;
      maxPoDate            DATE;
      maxPo                VARCHAR2 (20);
      leadTime             NUMBER;
      orderUom             VARCHAR2 (2);
      orderQuantity        NUMBER;
      orderQty             NUMBER;
      poAge                NUMBER;
      prevNsn              VARCHAR2 (15) := 'prevNsn';
      loadMainStartTime    NUMBER := DBMS_UTILITY.get_time;
   BEGIN
      writeMsg (
         pTableName        => 'tmp_amd_spare_parts',
         pError_location   => 290,
         pKey1             => 'loadMain',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
      COMMIT;
      --
      --     Get the load_no for insert into amd_load_status table
      --
      loadNo := Amd_Utils.GetLoadNo ('MAIN', 'TMP_AMD_SPARE_PARTS');

      OPEN f77Cur;

      FETCH f77Cur BULK COLLECT INTO mainRecs;

      CLOSE f77Cur;

      IF mainRecs.FIRST IS NOT NULL
      THEN
         FOR indx IN mainRecs.FIRST .. mainRecs.LAST
         LOOP
            --
            -- Attempt to get some values from tmp_main.(Only look at po's that
            -- have a length of 9.)
            --
            BEGIN
               --
               -- select the latest PO date.
               --
               SELECT MAX (TO_DATE (po_date, 'RRMMDD')) po_date,
                      (TRUNC (SYSDATE) - MAX (TO_DATE (po_date, 'RRMMDD')))
                         po_age
                 INTO maxPoDate, poAge
                 FROM TMP_MAIN
                WHERE     part_no = mainRecs (indx).part_no
                      AND LENGTH (SUBSTR (po_no, 1, INSTR (po_no, ' ') - 1)) =
                             9;

               --
               -- get latest PO
               --
               SELECT MAX (po_no)
                 INTO maxPo
                 FROM TMP_MAIN
                WHERE     part_no = mainRecs (indx).part_no
                      AND po_date = TO_CHAR (maxPoDate, 'RRMMDD')
                      AND LENGTH (SUBSTR (po_no, 1, INSTR (po_no, ' ') - 1)) =
                             9;

               SELECT --total_lead_time,  -- getting lead_time from Cat1 table  3/1/07
                      DISTINCT order_qty
                 INTO                                              --leadTime,
                     orderQuantity
                 FROM TMP_MAIN
                WHERE     part_no = mainRecs (indx).part_no
                      AND po_date = TO_CHAR (maxPoDate, 'RRMMDD')
                      AND po_no = maxPo
                      AND LENGTH (SUBSTR (po_no, 1, INSTR (po_no, ' ') - 1)) =
                             9;



               -- We apply the order_quantity we got from the prime part
               -- to all the equivalent parts so we only set it here when the
               -- prime rec comes in.  The prime rec is the first rec in the
               -- nsn series due to the sort order of the cursor.
               --
               IF (mainRecs (indx).nsn != prevNsn)
               THEN
                  prevNsn := mainRecs (indx).nsn;
                  orderQty := orderQuantity;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  orderQuantity := NULL;
               WHEN OTHERS
               THEN
                  ErrorMsg (sqlFunction       => 'loadMain',
                            tableName         => 'tmp_main',
                            pError_location   => 280,
                            key1              => mainRecs (indx).part_no,
                            key2              => maxPoDate,
                            key3              => maxPo);
                  COMMIT;
                  DBMS_OUTPUT.put_line (
                        'loadMain: part_no='
                     || mainRecs (indx).part_no
                     || ' maxPoDate='
                     || maxPoDate
                     || ' maxPo='
                     || maxPo
                     || ' sqlcode='
                     || SQLCODE
                     || ' sqlerrm='
                     || SQLERRM);
                  RAISE;
            END;

            order_quantity_tab.EXTEND;
            part_no_tab.EXTEND;
            order_quantity_tab (order_quantity_tab.LAST) := orderQty;
            part_no_tab (part_no_tab.LAST) := mainRecs (indx).part_no;

            /*
            UPDATE TMP_AMD_SPARE_PARTS SET
    --            order_lead_time = Amd_Utils.bizDays2CalendarDays(leadTime),
    --            order_uom = orderUom,
                order_quantity  = orderQty
            WHERE
                part_no       = mainRecs(indx).part_no;
             */
            cnt := cnt + 1;
         END LOOP;

         FORALL i IN order_quantity_tab.FIRST .. order_quantity_tab.LAST
            UPDATE tmp_amd_spare_parts
               SET order_quantity = order_quantity_tab (i)
             WHERE part_no = part_no_tab (i);
      END IF;

      DBMS_OUTPUT.put_line (
         'loadMain: ' || cnt || ' rows updated in tmp_amd_spare_parts');
      writeMsg (
         pTableName        => 'tmp_amd_spare_parts',
         pError_location   => 300,
         pKey1             => 'loadMain',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
         pKey3             => 'rowsUpdated=' || TO_CHAR (cnt));

      COMMIT;
   END LoadMain;

   PROCEDURE LoadWecm
   IS
   BEGIN
      BEGIN
         UPDATE tmp_amd_spare_parts
            SET wesm_indicator = 'Y'
          WHERE     (SUBSTR (nsn, 5, 9)) IN
                       (SELECT DISTINCT w1.niin
                          FROM L11 w1,
                               active_niins w2,
                               tmp_amd_spare_parts w3
                         WHERE     w1.niin = w2.niin
                               AND w1.niin = SUBSTR (w3.nsn, 5, 9))
                AND prime_ind = 'Y';

         DBMS_OUTPUT.put_line (
               'loadWecm: '
            || SQL%ROWCOUNT
            || ' rows updated in tmp_amd_spare_parts');
      END;
   END LoadWecm;

   PROCEDURE LoadTempNsns
   IS
      RAW_DATA   NUMBER := 0;

      TYPE nsnRec IS RECORD
      (
         part         amd_spare_parts.part_no%TYPE,
         nsnTemp      mils.status_line%TYPE,
         dataSource   VARCHAR2 (4)
      );

      TYPE nsnTab IS TABLE OF nsnRec;

      nsnRecs    nsnTab;

      CURSOR tempNsnCur
      IS
         -- From MILS table
         SELECT DISTINCT
                asp.part_no part,
                RTRIM (SUBSTR (m.status_line, 8, 15)) nsnTemp,
                'MILS' dataSource
           FROM AMD_SPARE_PARTS asp, MILS m
          WHERE     m.default_name = 'A0E'
                AND asp.part_no = RTRIM (SUBSTR (m.status_line, 81, 30))
                AND asp.nsn != RTRIM (SUBSTR (m.status_line, 8, 15))
                AND 'NSL' != RTRIM (SUBSTR (m.status_line, 8, 15))
         UNION
         -- From CHGH table, "FROM" column
         SELECT DISTINCT
                asp.part_no part,
                RTRIM (REPLACE (m."FROM", '-', NULL)) nsnTemp,
                'CHGH' dataSource
           FROM AMD_SPARE_PARTS asp, CHGH m
          WHERE     m.field = 'NSN'
                AND asp.part_no = m.key_value1
                AND asp.nsn != RTRIM (REPLACE (m."FROM", '-', NULL))
                AND 'NSL' != RTRIM (REPLACE (m."FROM", '-', NULL))
         UNION
         -- From CHGH table, "TO" column
         SELECT DISTINCT
                asp.part_no part,
                RTRIM (REPLACE (m."TO", '-', NULL)) nsnTemp,
                'CHGH' dataSource
           FROM AMD_SPARE_PARTS asp, CHGH m
          WHERE     m.field = 'NSN'
                AND asp.part_no = m.key_value1
                AND asp.nsn != RTRIM (REPLACE (m."TO", '-', NULL))
                AND 'NSL' != RTRIM (REPLACE (m."TO", '-', NULL))
         UNION
         -- From BSSM_PARTS table
         SELECT DISTINCT bp.part_no, bp.nsn nsnTemp, 'BSSM' dataSource
           FROM bssm_parts bp,
                (SELECT nsn
                   FROM bssm_parts
                  WHERE nsn LIKE 'NSL#%' AND lock_sid = RAW_DATA
                 MINUS
                 SELECT nsn
                   FROM AMD_NSNS
                  WHERE nsn LIKE 'NSL#%') nslQ
          WHERE     bp.nsn = nslQ.nsn
                AND bp.lock_sid = RAW_DATA
                AND bp.part_no IS NOT NULL
         ORDER BY 1;

      nsn        VARCHAR2 (16);
      nsiSid     NUMBER;
      loadNo     NUMBER;
      mmacCode   NUMBER;
      cnt        NUMBER := 0;
   BEGIN
      writeMsg (
         pTableName        => 'amd_nsns',
         pError_location   => 310,
         pKey1             => 'loadTempNsns',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      loadNo := Amd_Utils.GetLoadNo ('MILS', 'AMD_NSNS');

      OPEN tempNsnCur;

      FETCH tempNsnCur BULK COLLECT INTO nsnRecs;

      CLOSE tempNsnCur;

      IF nsnRecs.FIRST IS NOT NULL
      THEN
         FOR indx IN nsnRecs.FIRST .. nsnRecs.LAST
         LOOP
            BEGIN
               IF (nsnRecs (indx).nsnTemp = 'NSL')
               THEN
                  nsn :=
                     Amd_Nsl_Sequence_Pkg.SequenceTheNsl (
                        nsnRecs (indx).part);
               ELSIF (nsnRecs (indx).nsnTemp LIKE 'NSL#%')
               THEN
                  nsn := nsnRecs (indx).nsnTemp;
               ELSE
                  -- Need to ignore last 2 char's of nsn from MILS if not numeric.
                  -- So if last 2 characters are not numeric an exception will
                  -- occur and the nsn will be truncated to 13 characters.
                  --
                  nsn := nsnRecs (indx).nsnTemp;

                  IF (nsnRecs (indx).dataSource = 'MILS')
                  THEN
                     BEGIN
                        mmacCode := SUBSTR (nsn, 14, 2);
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           nsn := SUBSTR (nsn, 1, 13);
                     END;
                  END IF;
               END IF;

               nsiSid := Amd_Utils.GetNsiSid (pPart_no => nsnRecs (indx).part);

               INSERT INTO AMD_NSNS (nsn,
                                     nsn_type,
                                     nsi_sid,
                                     creation_date)
                    VALUES (nsn,
                            'T',
                            nsiSid,
                            SYSDATE);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;        -- nsiSid not found generates this, just ignore
               WHEN DUP_VAL_ON_INDEX
               THEN
                  NULL;               -- we don't care if nsn is already there
               WHEN OTHERS
               THEN
                  Amd_Utils.InsertErrorMsg (
                     pLoad_no   => loadNo,
                     pKey_1     => 'amd_load.LoadTempNsns',
                     pKey_2     => 'Exception: OTHERS',
                     pKey_3     => 'insert into amd_nsns');
            END;

            cnt := cnt + 1;
         END LOOP;
      END IF;

      DBMS_OUTPUT.put_line (
         'loadTempNsns: ' || cnt || ' rows inserted to amd_nsns');
      writeMsg (
         pTableName        => 'amd_nsns',
         pError_location   => 320,
         pKey1             => 'loadTempNsns',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
         pKey3             => 'cnt=' || TO_CHAR (cnt));
      COMMIT;
   END loadTempNsns;


   FUNCTION insertRow (planner_code IN VARCHAR2)
      RETURN NUMBER
   IS
      PROCEDURE doUpdate
      IS
      BEGIN
         UPDATE AMD_PLANNERS
            SET planner_description = insertRow.planner_code,
                action_code = Amd_Defaults.INSERT_ACTION,
                last_update_dt = SYSDATE
          WHERE planner_code = insertRow.planner_code;
      EXCEPTION
         WHEN OTHERS
         THEN
            errorMsg (sqlFunction       => 'update',
                      tableName         => 'amd_planners',
                      pError_location   => 330,
                      key1              => insertRow.planner_code);
            DBMS_OUTPUT.put_line (
                  'doUpdate: planner_code='
               || insertRow.planner_code
               || ' sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            RAISE;
      END doUpdate;
   BEGIN
     <<insertAmdPlanners>>
      BEGIN
         INSERT INTO AMD_PLANNERS (planner_code,
                                   planner_description,
                                   action_code,
                                   last_update_dt)
              VALUES (insertRow.planner_code,
                      insertRow.planner_code,
                      Amd_Defaults.INSERT_ACTION,
                      SYSDATE);
      EXCEPTION
         WHEN STANDARD.DUP_VAL_ON_INDEX
         THEN
            doUpdate;
         WHEN OTHERS
         THEN
            errorMsg (sqlFunction       => 'insert',
                      tableName         => 'amd_planners',
                      pError_location   => 340,
                      key1              => insertRow.planner_code);
            DBMS_OUTPUT.put_line (
                  'insertAmdPlanners: planner_code='
               || insertRow.planner_code
               || ' sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            RAISE;
      END insertAmdPlanners;

      RETURN SUCCESS;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FAILURE;
   END insertRow;

   FUNCTION updateRow (planner_code IN VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
     <<updateAmdPlanners>>
      BEGIN
         UPDATE AMD_PLANNERS
            SET planner_description = updateRow.planner_code,
                last_update_dt = SYSDATE,
                action_code = Amd_Defaults.UPDATE_ACTION
          WHERE planner_code = updateRow.planner_code;
      EXCEPTION
         WHEN OTHERS
         THEN
            errorMsg (sqlFunction       => 'update',
                      tableName         => 'amd_planners',
                      pError_location   => 350,
                      key1              => updateRow.planner_code);
            DBMS_OUTPUT.put_line (
                  'updateAmdPlanners: planner_code='
               || updateRow.planner_code
               || ' sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            RAISE;
      END updateAmdPlanners;

      RETURN SUCCESS;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FAILURE;
   END updateRow;

   FUNCTION deleteRow (planner_code IN VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
     <<deleteAmdPlanners>>
      BEGIN
         UPDATE AMD_PLANNERS
            SET last_update_dt = SYSDATE,
                action_code = Amd_Defaults.DELETE_ACTION
          WHERE planner_code = deleteRow.planner_code;
      EXCEPTION
         WHEN OTHERS
         THEN
            errorMsg (sqlFunction       => 'update',
                      tableName         => 'amd_planners',
                      pError_location   => 360,
                      key1              => deleteRow.planner_code);
            DBMS_OUTPUT.put_line (
                  'deleteAmdPlanners: planner_code='
               || deleteRow.planner_code
               || ' sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            RAISE;
      END deleteAmdPlanners;

      RETURN SUCCESS;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FAILURE;
   END deleteRow;

   FUNCTION getNewUsers
      RETURN resultSetCursor
   IS
      newUsers   resultSetCursor;
   BEGIN
      OPEN newUsers FOR
           SELECT Amd_Load.getBemsId (employee_NO) bems_id,
                  stable_email,
                  last_name,
                  first_name
             FROM AMD_USE1, amd_people_all_v
            WHERE     employee_status = 'A'
                  AND ims_designator_code IS NOT NULL
                  AND LENGTH (ims_designator_code) = 3
                  AND Amd_Load.getBemsId (employee_no) =
                         amd_people_all_v.bems_id
         ORDER BY bems_id;

      RETURN newUsers;
   END getNewUsers;

   FUNCTION insertUsersRow (bems_id        IN VARCHAR2,
                            stable_email   IN VARCHAR2,
                            last_name      IN VARCHAR2,
                            first_name     IN VARCHAR2)
      RETURN NUMBER
   IS
      PROCEDURE doUpdate
      IS
      BEGIN
         UPDATE amd_users
            SET stable_email = TRIM (insertUsersRow.stable_email),
                last_name = TRIM (insertUsersRow.last_name),
                first_name = TRIM (insertUsersRow.first_name),
                action_code = amd_defaults.INSERT_ACTION,
                last_update_dt = SYSDATE
          WHERE bems_id = insertUsersRow.bems_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            errorMsg (sqlFunction       => 'update',
                      tableName         => 'amd_users',
                      pError_location   => 370,
                      key1              => bems_id);
            DBMS_OUTPUT.put_line (
                  'doUpdate: bems_id='
               || bems_id
               || ' sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            RAISE;
      END doUpdate;
   BEGIN
      INSERT INTO AMD_USERS (bems_id,
                             stable_email,
                             last_name,
                             first_name,
                             action_code,
                             last_update_dt)
           VALUES (TRIM (bems_id),
                   TRIM (stable_email),
                   TRIM (last_name),
                   TRIM (first_name),
                   Amd_Defaults.INSERT_ACTION,
                   SYSDATE);

      RETURN SUCCESS;
   EXCEPTION
      WHEN STANDARD.DUP_VAL_ON_INDEX
      THEN
         doUpdate;
         RETURN success;
      WHEN OTHERS
      THEN
         errorMsg (sqlFunction       => 'insert',
                   tableName         => 'amd_users',
                   pError_location   => 380,
                   key1              => bems_id);
         DBMS_OUTPUT.put_line (
               'insertUsersRow: bems_id='
            || bems_id
            || ' sqlcode='
            || SQLCODE
            || ' sqlerrm='
            || SQLERRM);
         RAISE;
   END insertUsersRow;

   FUNCTION updateUsersRow (bems_id        IN VARCHAR2,
                            stable_email   IN VARCHAR2,
                            last_name      IN VARCHAR2,
                            first_name     IN VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
      UPDATE AMD_USERS
         SET stable_email = TRIM (updateUsersRow.stable_email),
             last_name = TRIM (updateUsersRow.last_name),
             first_name = TRIM (updateUsersRow.first_name),
             action_code = Amd_Defaults.UPDATE_ACTION,
             last_update_dt = SYSDATE
       WHERE bems_id = updateUsersRow.bems_id;

      RETURN SUCCESS;
   EXCEPTION
      WHEN OTHERS
      THEN
         errorMsg (sqlFunction       => 'update',
                   tableName         => 'amd_users',
                   pError_location   => 390,
                   key1              => bems_id);
         DBMS_OUTPUT.put_line (
               'updateUsersRows: bems_id='
            || bems_id
            || ' sqlcode='
            || SQLCODE
            || ' sqlerrm='
            || SQLERRM);
         RAISE;
   END updateUsersRow;

   FUNCTION deleteUsersRow (bems_id IN VARCHAR2)
      RETURN NUMBER
   IS
      last_name      AMD_USERS.last_name%TYPE;
      first_name     AMD_USERS.first_name%TYPE;
      stable_email   AMD_USERS.stable_email%TYPE;
   BEGIN
      UPDATE AMD_USERS
         SET action_code = Amd_Defaults.DELETE_ACTION,
             last_update_dt = SYSDATE
       WHERE bems_id = deleteUsersRow.bems_id;

     <<getData>>
      BEGIN
         SELECT stable_email, last_name, first_name
           INTO stable_email, last_name, first_name
           FROM AMD_USERS
          WHERE bems_id = deleteUsersRow.bems_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            errorMsg (sqlFunction       => 'select',
                      tableName         => 'amd_users',
                      pError_location   => 400,
                      key1              => bems_id);
            DBMS_OUTPUT.put_line (
                  'getData: besm_id='
               || bems_id
               || ' sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            RAISE;
      END getData;

      RETURN SUCCESS;
   EXCEPTION
      WHEN OTHERS
      THEN
         errorMsg (sqlFunction       => 'update',
                   tableName         => 'amd_users',
                   pError_location   => 410,
                   key1              => bems_id);
         DBMS_OUTPUT.put_line (
               'deleteUsersRow: bems_id='
            || bems_id
            || ' sqlcode='
            || SQLCODE
            || ' sqlerrm='
            || SQLERRM);
         RAISE;
   END deleteUsersRow;

   PROCEDURE loadUsers
   IS
      TYPE bemsIdTab IS TABLE OF amd_users.bems_id%TYPE;

      bemsIdRecs   bemsIdTab;

      CURSOR currentUsers
      IS
         SELECT bems_id
           FROM AMD_USERS
          WHERE action_code != Amd_Defaults.DELETE_ACTION;

      CURSOR newUsers
      IS
         SELECT Amd_Load.getBemsId (employee_NO) bems_id
           FROM AMD_USE1
          WHERE     employee_status = 'A'
                AND Amd_Load.getBemsId (employee_no) NOT IN
                       (SELECT bems_id
                          FROM AMD_USERS
                         WHERE action_code != Amd_Defaults.DELETE_ACTION)
                AND ims_designator_code IS NOT NULL
                AND LENGTH (ims_designator_code) = 3;

      CURSOR deletedUsers
      IS
         SELECT bems_id
           FROM AMD_USERS
          WHERE     bems_id NOT IN
                       (SELECT Amd_Load.getBemsId (employee_no) bems_id
                          FROM AMD_USE1
                         WHERE     employee_status = 'A'
                               AND ims_designator_code IS NOT NULL
                               AND LENGTH (ims_designator_code) = 3)
                AND action_code != Amd_Defaults.DELETE_ACTION;

      bems_id      AMD_USERS.BEMS_ID%TYPE;

      inserted     NUMBER := 0;
      deleted      NUMBER := 0;
   BEGIN
      writeMsg (
         pTableName        => 'amd_users',
         pError_location   => 420,
         pKey1             => 'loadUsers',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));


      OPEN newUsers;

      FETCH newUsers BULK COLLECT INTO bemsIdRecs;

      CLOSE newUsers;

      IF bemsIdRecs.FIRST IS NOT NULL
      THEN
         FOR indx IN bemsIdRecs.FIRST .. bemsIdRecs.LAST
         LOOP
            IF bemsIdRecs (indx) IS NOT NULL
            THEN
              <<insertAmdUsers>>
               BEGIN
                  INSERT
                    INTO AMD_USERS (bems_id, action_code, last_update_dt)
                     VALUES (
                               bemsIdRecs (indx),
                               Amd_Defaults.INSERT_ACTION,
                               SYSDATE);

                  inserted := inserted + 1;
               EXCEPTION
                  WHEN STANDARD.DUP_VAL_ON_INDEX
                  THEN
                     NULL; -- ignore because some users have multiple planner codes
               END insertAmdUsers;
            END IF;
         END LOOP;
      END IF;

      OPEN deletedUsers;

      FETCH deletedUsers BULK COLLECT INTO bemsIdRecs;

      CLOSE deletedUsers;

      IF bemsIdRecs.FIRST IS NOT NULL
      THEN
         FOR indx IN bemsIdRecs.FIRST .. bemsIdRecs.LAST
         LOOP
            UPDATE AMD_USERS
               SET action_code = Amd_Defaults.DELETE_ACTION,
                   last_update_dt = SYSDATE
             WHERE bems_id = bemsIdRecs (indx);

            deleted := deleted + 1;
         END LOOP;
      END IF;

      writeMsg (
         pTableName        => 'amd_users',
         pError_location   => 430,
         pKey1             => 'loadUsers',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
         pKey3             => 'inserted=' || TO_CHAR (inserted),
         pKey4             => 'deleted=' || TO_CHAR (deleted));

      COMMIT;
   END loadUsers;


   FUNCTION insertPlannerLogons (planner_code   IN VARCHAR2,
                                 logon_id       IN VARCHAR2,
                                 data_source    IN VARCHAR2)
      RETURN NUMBER
   IS
      PROCEDURE doUpdate
      IS
      BEGIN
         UPDATE AMD_PLANNER_LOGONS
            SET action_code = Amd_Defaults.INSERT_ACTION,
                last_update_dt = SYSDATE
          WHERE     planner_code = insertPlannerLogons.planner_code
                AND logon_id = insertPlannerLogons.logon_id
                AND data_source = insertPlannerLogons.data_source;
      EXCEPTION
         WHEN OTHERS
         THEN
            errorMsg (sqlFunction       => 'update',
                      tableName         => 'amd_planner_logons',
                      pError_location   => 440,
                      key1              => insertPlannerLogons.planner_code,
                      key2              => insertPlannerLogons.logon_id,
                      key3              => insertPlannerLogons.data_source);
            DBMS_OUTPUT.put_line (
                  'doUpdate: planner_code='
               || insertPlannerLogons.planner_code
               || ' logon_id='
               || insertPlannerLogons.logon_id
               || ' data_source='
               || insertPlannerLogons.data_source
               || ' sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            RAISE;
      END doUpdate;
   BEGIN
      debugMsg (
            'planner_code='
         || planner_code
         || ' logon_id='
         || logon_id
         || ' data_source='
         || data_source,
         pError_location   => 520);

     <<insertAmdPlannerLogons>>
      BEGIN
         INSERT INTO AMD_PLANNER_LOGONS (planner_code,
                                         logon_id,
                                         data_source,
                                         action_code,
                                         last_update_dt)
              VALUES (insertPlannerLogons.planner_code,
                      insertPlannerLogons.logon_id,
                      insertPlannerLogons.data_source,
                      Amd_Defaults.INSERT_ACTION,
                      SYSDATE);
      EXCEPTION
         WHEN STANDARD.DUP_VAL_ON_INDEX
         THEN
            doUpdate;
         WHEN OTHERS
         THEN
            errorMsg (sqlFunction       => 'insert',
                      tableName         => 'amd_planner_logons',
                      pError_location   => 450,
                      key1              => insertPlannerLogons.planner_code,
                      key2              => insertPlannerLogons.logon_id,
                      key3              => insertPlannerLogons.data_source);
            DBMS_OUTPUT.put_line (
                  'insertAmdPlannerLogons: planner_code='
               || insertPlannerLogons.planner_code
               || ' logon_id='
               || insertPlannerLogons.logon_id
               || ' data_source='
               || insertPlannerLogons.data_source
               || ' sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            RAISE;
      END insertAmdPlannerLogons;


      RETURN SUCCESS;
   EXCEPTION
      WHEN OTHERS
      THEN
         errorMsg (sqlFunction       => 'insertPlannerLogons',
                   tableName         => 'amd_planner_logons',
                   pError_location   => 540);
         RETURN FAILURE;
   END insertPlannerLogons;

   FUNCTION updatePlannerLogons (planner_code   IN VARCHAR2,
                                 logon_id       IN VARCHAR2,
                                 data_source    IN VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
     <<updateAmdPlannerLogons>>
      BEGIN
         UPDATE AMD_PLANNER_LOGONS
            SET last_update_dt = SYSDATE,
                action_code = Amd_Defaults.UPDATE_ACTION
          WHERE     planner_code = updatePlannerLogons.planner_code
                AND logon_id = updatePlannerLogons.logon_id
                AND data_source = updatePlannerLogons.data_source;
      EXCEPTION
         WHEN OTHERS
         THEN
            errorMsg (sqlFunction       => 'update',
                      tableName         => 'amd_planner_logons',
                      pError_location   => 460,
                      key1              => updatePlannerLogons.planner_code,
                      key2              => updatePlannerLogons.logon_id,
                      key3              => updatePlannerLogons.data_source);
            DBMS_OUTPUT.put_line (
                  'updateAmdPlannerLogons: planner_code='
               || updatePlannerLogons.planner_code
               || ' logon_id='
               || updatePlannerLogons.logon_id
               || ' data_source='
               || updatePlannerLogons.data_source
               || ' sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            RAISE;
      END updateAmdPlannerLogons;


      RETURN SUCCESS;
   EXCEPTION
      WHEN OTHERS
      THEN
         errorMsg (sqlFunction       => 'updatePlannerLogons',
                   tableName         => 'amd_planner_logons',
                   pError_location   => 560);
         RETURN FAILURE;
   END updatePlannerLogons;

   FUNCTION deletePlannerLogons (planner_code   IN VARCHAR2,
                                 logon_id       IN VARCHAR2,
                                 data_source    IN VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
     <<deleteAmdPlannerLogons>>
      BEGIN
         UPDATE AMD_PLANNER_LOGONS
            SET last_update_dt = SYSDATE,
                action_code = Amd_Defaults.DELETE_ACTION
          WHERE     planner_code = deletePlannerLogons.planner_code
                AND logon_id = deletePlannerLogons.logon_id
                AND data_source = deletePlannerLogons.data_source;
      EXCEPTION
         WHEN OTHERS
         THEN
            errorMsg (sqlFunction       => 'update',
                      tableName         => 'amd_planner_logons',
                      pError_location   => 470,
                      key1              => deletePlannerLogons.planner_code,
                      key2              => deletePlannerLogons.logon_id,
                      key3              => deletePlannerLogons.data_source);
            DBMS_OUTPUT.put_line (
                  'deleteAmdPlanners: planner_code='
               || deletePlannerLogons.planner_code
               || ' logon_id='
               || deletePlannerLogons.logon_id
               || ' data_source='
               || deletePlannerLogons.data_source
               || ' sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            RAISE;
      END deleteAmdPlanners;


      RETURN SUCCESS;
   EXCEPTION
      WHEN OTHERS
      THEN
         errorMsg (sqlFunction       => 'deletePlannerLogons',
                   tableName         => 'amd_planner_logons',
                   pError_location   => 580);
         RETURN FAILURE;
   END deletePlannerLogons;

   -- For future use
   -- The following procedures: loadGoldPsmsMain, preProcess, postProcess, and postDiffProcess,
   -- may be used to replace the bulky sql scripts currently used by amd_loader.ksh
   PROCEDURE loadGoldPsmsMain (startStep   IN NUMBER := 1,
                               endStep     IN NUMBER := 3)
   IS
      batch_job_number     amd_batch_jobs.BATCH_JOB_NUMBER%TYPE
                              := amd_batch_pkg.getActiveJob;
      batch_step_number    amd_batch_job_steps.BATCH_STEP_NUMBER%TYPE;
      LOAD_GOLD   CONSTANT VARCHAR2 (8) := 'loadGold';
      LOAD_PSMS   CONSTANT VARCHAR2 (8) := 'loadPsms';
      LOAD_MAIN   CONSTANT VARCHAR2 (8) := 'loadMain';
   BEGIN
      IF batch_job_number IS NULL
      THEN
         DBMS_OUTPUT.put_line (
               'loadGoldPsmsMain: start_step='
            || startStep
            || ' endStep='
            || endStep
            || ' sqlcode='
            || SQLCODE
            || ' sqlerrm='
            || SQLERRM);
         RAISE no_active_job;
      END IF;

      FOR step IN startStep .. endStep
      LOOP
         IF step = 1
         THEN
            IF NOT amd_batch_pkg.isStepComplete (
                      batch_job_number   => batch_job_number,
                      system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                      description        => LOAD_GOLD)
            THEN
               amd_batch_pkg.start_step (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => LOAD_GOLD,
                  package_name       => THIS_PACKAGE,
                  procedure_name     => LOAD_GOLD);

               loadGold;
            END IF;
         ELSIF step = 2
         THEN
            IF NOT amd_batch_pkg.isStepComplete (
                      batch_job_number   => batch_job_number,
                      system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                      description        => LOAD_PSMS)
            THEN
               amd_batch_pkg.start_step (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => LOAD_PSMS,
                  package_name       => THIS_PACKAGE,
                  procedure_name     => LOAD_PSMS);

               loadPsms;
            END IF;
         ELSIF step = 3
         THEN
            IF NOT amd_batch_pkg.isStepComplete (
                      batch_job_number   => batch_job_number,
                      system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                      description        => LOAD_MAIN)
            THEN
               amd_batch_pkg.start_step (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => LOAD_MAIN,
                  package_name       => THIS_PACKAGE,
                  procedure_name     => LOAD_MAIN);

               loadMain;
            END IF;
         END IF;

         debugMsg ('loadGoldPsmsMain: completed step ' || step,
                   pError_location   => 590);
         batch_step_number :=
            amd_batch_pkg.getActiveStep (
               batch_job_number   => batch_job_number,
               system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP);

         IF batch_step_number IS NOT NULL
         THEN
            amd_batch_pkg.end_step (
               batch_job_number    => batch_job_number,
               system_id           => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
               batch_step_number   => batch_step_number);
         END IF;

         COMMIT;
      END LOOP;
   END loadGoldPsmsMain;

   PROCEDURE preProcess (startStep IN NUMBER := 1, endStep IN NUMBER := 3)
   IS
   BEGIN
      loadGoldPsmsMain (startStep, endStep);
   END preProcess;

   PROCEDURE postProcess (startStep IN NUMBER := 1, endStep IN NUMBER := 18)
   IS
      batch_job_number                          amd_batch_jobs.BATCH_JOB_NUMBER%TYPE
         := amd_batch_pkg.getActiveJob (
               system_id   => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP);
      batch_step_number                         amd_batch_job_steps.BATCH_STEP_NUMBER%TYPE;

      THE_AMD_PARTPRIME_PKG            CONSTANT VARCHAR2 (17) := 'amd_partprime_pkg';
      THE_AMD_PART_LOC_FORECASTS_PKG   CONSTANT VARCHAR2 (26)
         := 'amd_part_loc_forecasts_pkg' ;
      THE_AMD_SPARE_PARTS_PKG          CONSTANT VARCHAR2 (19)
                                                   := 'amd_spare_parts_pkg' ;
      THE_AMD_SPARE_NETWORKS_PKG       CONSTANT VARCHAR2 (22)
         := 'amd_spare_networks_pkg' ;
      THE_AMD_DEMAND_PKG               CONSTANT VARCHAR2 (10) := 'amd_demand';
      THE_AMD_PART_LOCS_LOAD_PKG       CONSTANT VARCHAR2 (22)
         := 'amd_part_locs_load_pkg' ;
      THE_AMD_FROM_BSSM_PKG            CONSTANT VARCHAR2 (17)
                                                   := 'amd_from_bssm_pkg' ;
      THE_AMD_CLEANED_FROM_BSSM_PKG    CONSTANT VARCHAR2 (25)
         := 'amd_cleaned_from_bssm_pkg' ;

      DELETE_INVALID_PARTS             CONSTANT VARCHAR2 (18)
                                                   := 'deleteinvalidParts' ;
      DIFF_PART_TO_PRIME               CONSTANT VARCHAR2 (15)
                                                   := 'DiffPartToPrime' ;
      LOAD_LATEST_RBL_RUN              CONSTANT VARCHAR2 (16)
                                                   := 'LoadLatestRblRun' ;
      LOAD_CURRENT_BACKORDER           CONSTANT VARCHAR2 (20)
                                                   := 'loadCurrentBackOrder' ;
      LOAD_TEMP_NSNS                   CONSTANT VARCHAR2 (12)
                                                   := 'loadtempnsns' ;
      AUTO_LOAD_SPARE_NETWORKS         CONSTANT VARCHAR2 (24)
         := 'auto_load_spare_networks' ;
      LOAD_AMD_DEMANDS                 CONSTANT VARCHAR2 (14)
                                                   := 'loadamddemands' ;
      LOAD_BASC_UK_DEMANDS             CONSTANT VARCHAR2 (17)
                                                   := 'loadBascUkdemands' ;
      AMD_DEMAND_A2A                   CONSTANT VARCHAR2 (14)
                                                   := 'amd_demand_a2a' ;
      LOAD_GOLD_INVENTORY              CONSTANT VARCHAR2 (17)
                                                   := 'loadGoldInventory' ;
      LOAD_AMD_PART_LOCATIONS          CONSTANT VARCHAR2 (20)
                                                   := 'LoadAmdPartLocations' ;
      LOAD_AMD_BASE_FROM_BSSM_RAW      CONSTANT VARCHAR2 (22)
         := 'LoadAmdBaseFromBssmRaw' ;
   BEGIN
      IF batch_job_number IS NULL
      THEN
         RAISE amd_load.no_active_job;
      END IF;

      FOR step IN startStep .. endStep
      LOOP
         IF step = 1
         THEN
            NULL;
         ELSIF step = 2
         THEN
            IF amd_batch_pkg.didStepStart (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => DIFF_PART_TO_PRIME,
                  package_name       => THE_AMD_PARTPRIME_PKG,
                  procedure_name     => DIFF_PART_TO_PRIME)
            THEN
               NULL;
            END IF;
         ELSIF step = 3
         THEN
            IF amd_batch_pkg.didStepStart (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => LOAD_LATEST_RBL_RUN,
                  package_name       => THE_AMD_PART_LOC_FORECASTS_PKG,
                  procedure_name     => LOAD_LATEST_RBL_RUN)
            THEN
               amd_part_loc_forecasts_pkg.LoadLatestRblRun;
            END IF;
         ELSIF step = 4
         THEN
            IF amd_batch_pkg.didStepStart (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => LOAD_CURRENT_BACKORDER,
                  package_name       => THE_AMD_SPARE_PARTS_PKG,
                  procedure_name     => LOAD_CURRENT_BACKORDER)
            THEN
               amd_spare_parts_pkg.loadCurrentBackOrder;
            END IF;
         ELSIF step = 5
         THEN
            IF amd_batch_pkg.didStepStart (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => LOAD_TEMP_NSNS,
                  package_name       => THIS_PACKAGE,
                  procedure_name     => LOAD_TEMP_NSNS)
            THEN
               amd_load.loadtempnsns;
            END IF;
         ELSIF step = 6
         THEN
            IF amd_batch_pkg.didStepStart (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => AUTO_LOAD_SPARE_NETWORKS,
                  package_name       => THE_AMD_SPARE_NETWORKS_PKG,
                  procedure_name     => AUTO_LOAD_SPARE_NETWORKS)
            THEN
               amd_spare_networks_pkg.auto_load_spare_networks;
            END IF;
         ELSIF step = 7
         THEN
            IF amd_batch_pkg.didStepStart (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => LOAD_AMD_DEMANDS,
                  package_name       => THE_AMD_DEMAND_PKG,
                  procedure_name     => LOAD_AMD_DEMANDS)
            THEN
               amd_demand.loadAmdBssmSourceTmpAmdDemands;
            END IF;
         ELSIF step = 8
         THEN
            IF amd_batch_pkg.didStepStart (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => LOAD_BASC_UK_DEMANDS,
                  package_name       => THE_AMD_DEMAND_PKG,
                  procedure_name     => LOAD_BASC_UK_DEMANDS)
            THEN
               amd_demand.loadDepotDemands;
            END IF;
         ELSIF step = 9
         THEN
            IF amd_batch_pkg.didStepStart (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => AMD_DEMAND_A2A,
                  package_name       => THE_AMD_DEMAND_PKG,
                  procedure_name     => AMD_DEMAND_A2A)
            THEN
               amd_demand.load_amd_demands_table;
            END IF;
         ELSIF step = 10
         THEN
            IF amd_batch_pkg.didStepStart (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => LOAD_GOLD_INVENTORY,
                  package_name       => THE_AMD_INVENTORY_PKG,
                  procedure_name     => LOAD_GOLD_INVENTORY)
            THEN
               amd_inventory.loadGoldInventory;
            END IF;
         ELSIF step = 11
         THEN
            IF amd_batch_pkg.didStepStart (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => LOAD_AMD_PART_LOCATIONS,
                  package_name       => THE_AMD_PART_LOCS_LOAD_PKG,
                  procedure_name     => LOAD_AMD_PART_LOCATIONS)
            THEN
               amd_part_locs_load_pkg.LoadAmdPartLocations;
            END IF;
         ELSIF step = 12
         THEN
            IF amd_batch_pkg.didStepStart (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => LOAD_AMD_BASE_FROM_BSSM_RAW,
                  package_name       => THE_AMD_FROM_BSSM_PKG,
                  procedure_name     => LOAD_AMD_BASE_FROM_BSSM_RAW)
            THEN
               amd_from_bssm_pkg.LoadAmdBaseFromBssmRaw;
            END IF;
         ELSIF step = 13
         THEN
            IF amd_batch_pkg.didStepStart (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => 'UpdateAmdAllBaseCleaned',
                  package_name       => THE_AMD_CLEANED_FROM_BSSM_PKG,
                  procedure_name     => 'UpdateAmdAllBaseCleaned')
            THEN
              <<cleaned>>
               BEGIN
                  amd_cleaned_from_bssm_pkg.UpdateAmdAllBaseCleaned;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     ErrorMsg (sqlFunction       => 'call',
                               key1              => 'updateAmdAllBaseCleaned',
                               pError_location   => 5);
                     DBMS_OUTPUT.put_line (
                           'loadGold: exception calling amd_cleaned_from_bssm_pkg.UpdateAmdAllBaseCleaned'
                        || 'sqlcode('
                        || SQLCODE
                        || ') sqlerrm('
                        || SQLERRM
                        || ')');
               END cleaned;
            END IF;
         ELSIF step = 14
         THEN
            IF amd_batch_pkg.didStepStart (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => 'LoadAmdReqs',
                  package_name       => THIS_PACKAGE,
                  procedure_name     => 'LoadAmdReqs')
            THEN
               amd_reqs_pkg.LoadAmdReqs;
            END IF;
         ELSIF step = 15
         THEN
            IF amd_batch_pkg.didStepStart (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => 'LoadTmpAmdPartFactors',
                  package_name       => THIS_PACKAGE,
                  procedure_name     => 'LoadTmpAmdPartFactors')
            THEN
               amd_part_factors_pkg.LoadTmpAmdPartFactors;
            END IF;
         ELSIF step = 16
         THEN
            IF amd_batch_pkg.didStepStart (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => 'ProcessA2AVirtualLocs',
                  package_name       => THIS_PACKAGE,
                  procedure_name     => 'ProcessA2AVirtualLocs')
            THEN
               NULL;             --amd_part_factors_pkg.ProcessA2AVirtualLocs;
            END IF;
         ELSIF step = 17
         THEN
            IF amd_batch_pkg.didStepStart (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => 'LoadTmpAmdPartLocForecasts_Add',
                  package_name       => THIS_PACKAGE,
                  procedure_name     => 'LoadTmpAmdPartLocForecasts_Add')
            THEN
               amd_part_loc_forecasts_pkg.LoadTmpAmdPartLocForecasts_Add;
            END IF;
         ELSIF step = 18
         THEN
            IF amd_batch_pkg.didStepStart (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => 'LoadTmpAmdLocPartLeadtime',
                  package_name       => THIS_PACKAGE,
                  procedure_name     => 'LoadTmpAmdLocPartLeadtime')
            THEN
               amd_location_part_leadtime_pkg.LoadTmpAmdLocPartLeadtime;
            END IF;
         END IF;

         debugMsg ('postProcess: completed step ' || step,
                   pError_location   => 600);
         batch_step_number :=
            amd_batch_pkg.getActiveStep (
               batch_job_number   => batch_job_number,
               system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP);

         IF batch_step_number IS NOT NULL
         THEN
            amd_batch_pkg.end_step (
               batch_job_number    => batch_job_number,
               system_id           => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
               batch_step_number   => batch_step_number);
         END IF;

         COMMIT;
      END LOOP;
   END postProcess;

   PROCEDURE postDiffProcess (startStep   IN NUMBER := 1,
                              endStep     IN NUMBER := 3)
   IS
      batch_job_number    amd_batch_jobs.BATCH_JOB_NUMBER%TYPE
         := amd_batch_pkg.getActiveJob (
               system_id   => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP);
      batch_step_number   amd_batch_job_steps.BATCH_STEP_NUMBER%TYPE;
   BEGIN
      IF batch_job_number IS NULL
      THEN
         DBMS_OUTPUT.put_line (
               'postDiffProcess: startStep='
            || startStep
            || ' endStep='
            || endStep
            || ' sqlcode='
            || SQLCODE
            || ' sqlerrm='
            || SQLERRM);
         RAISE amd_load.no_active_job;
      END IF;

      FOR step IN startStep .. endStep
      LOOP
         IF step = 1
         THEN
            IF amd_batch_pkg.didStepStart (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => 'UpdateSpoTotalInventory',
                  package_name       => THE_AMD_INVENTORY_PKG,
                  procedure_name     => 'UpdateSpoTotalInventory')
            THEN
               amd_inventory.UpdateSpoTotalInventory;
            END IF;
         ELSIF step = 2
         THEN
            IF amd_batch_pkg.didStepStart (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => 'LoadTmpAmdLocPartOverride',
                  package_name       => THIS_PACKAGE,
                  procedure_name     => 'LoadTmpAmdLocPartOverride')
            THEN
               amd_location_part_override_pkg.LoadTmpAmdLocPartOverride;
            END IF;
         ELSIF step = 3
         THEN
            IF amd_batch_pkg.didStepStart (
                  batch_job_number   => batch_job_number,
                  system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
                  description        => 'LoadZeroTslA2A',
                  package_name       => THIS_PACKAGE,
                  procedure_name     => 'LoadZeroTslA2A')
            THEN
               NULL; -- procdure amd_location_part_override_pkg.LoadZeroTslA2A has been removed
            END IF;
         END IF;

         debugMsg ('postDiffProcess: completed step ' || step,
                   pError_location   => 610);
         batch_step_number :=
            amd_batch_pkg.getActiveStep (
               batch_job_number   => batch_job_number,
               system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP);

         IF batch_step_number IS NOT NULL
         THEN
            amd_batch_pkg.end_step (
               batch_job_number    => batch_job_number,
               system_id           => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
               batch_step_number   => batch_step_number);
         END IF;

         COMMIT;
      END LOOP;
   END postDiffProcess;

   PROCEDURE disableAmdConstraints
   IS
   BEGIN
      debugMsg ('start disableAmdContraints', pError_location => 620);
      mta_disable_constraint ('amd_part_loc_time_periods',
                              'amd_part_loc_time_periods_fk01');
      mta_disable_constraint ('amd_part_locs', 'amd_part_locs_fk01');
      mta_disable_constraint ('amd_part_locs', 'amd_part_locs_fk02');
      mta_disable_constraint ('amd_maint_task_distribs',
                              'amd_maint_task_distribs_fk01');
      mta_disable_constraint ('amd_bods', 'amd_bods_fk02');
      mta_disable_constraint ('amd_part_next_assemblies',
                              'amd_part_next_assemblies_fk01');
      mta_disable_constraint ('amd_demands', 'amd_demands_fk01');
      mta_disable_constraint ('amd_demands', 'amd_demands_fk02');
      mta_disable_constraint ('amd_demands', 'amd_demands_pk');
      debugMsg ('end disableAmdContraints', pError_location => 630);
      COMMIT;
   END disableAmdConstraints;

   PROCEDURE truncateAmdTables
   IS
   BEGIN
      debugMsg ('start truncateAmdTables', pError_location => 640);
      mta_truncate_table ('tmp_amd_demands', 'reuse storage');
      mta_truncate_table ('tmp_amd_part_locs', 'reuse storage');
      mta_truncate_table ('tmp_amd_spare_parts', 'reuse storage');
      mta_truncate_table ('tmp_lcf_icp', 'reuse storage');
      mta_truncate_table ('amd_bssm_source', 'reuse storage');
      mta_truncate_table ('amd_maint_task_distribs', 'reuse storage');
      mta_truncate_table ('amd_part_loc_time_periods', 'reuse storage');
      mta_truncate_table ('amd_flight_stats', 'reuse storage');
      debugMsg ('end truncateAmdTables', pError_location => 650);
      COMMIT;
   END truncateAmdTables;

   PROCEDURE enableAmdConstraints
   IS
   BEGIN
      debugMsg ('start enableAmdConstraints', pError_location => 660);
      mta_enable_constraint ('amd_part_loc_time_periods',
                             'amd_part_loc_time_periods_fk01');
      mta_enable_constraint ('amd_part_locs', 'amd_part_locs_fk01');
      mta_enable_constraint ('amd_part_locs', 'amd_part_locs_fk02');
      mta_enable_constraint ('amd_maint_task_distribs',
                             'amd_maint_task_distribs_fk01');
      mta_enable_constraint ('amd_bods', 'amd_bods_fk02');
      mta_enable_constraint ('amd_part_next_assemblies',
                             'amd_part_next_assemblies_fk01');
      mta_enable_constraint ('amd_demands', 'amd_demands_fk01');
      mta_enable_constraint ('amd_demands', 'amd_demands_fk02');
      mta_enable_constraint ('amd_demands', 'amd_demands_pk');
      debugMsg ('end enableAmdConstraints', pError_location => 670);
      COMMIT;
   END enableAmdConstraints;

   PROCEDURE prepAmdDatabase
   IS
      batch_job_number    amd_batch_jobs.BATCH_JOB_NUMBER%TYPE
         := amd_batch_pkg.getActiveJob (
               system_id   => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP);
      batch_step_number   amd_batch_job_steps.BATCH_STEP_NUMBER%TYPE;
   BEGIN
      debugMsg ('start prepAmdDatabase', pError_location => 680);

      IF batch_job_number IS NULL
      THEN
         DBMS_OUTPUT.put_line (
            'prepAmdDatabase: sqlcode=' || SQLCODE || ' sqlerrm=' || SQLERRM);
         RAISE amd_load.no_active_job;
      END IF;

      amd_batch_pkg.start_step (
         batch_job_number   => batch_job_number,
         system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
         description        => 'disableAmdConstraints',
         package_name       => THIS_PACKAGE,
         procedure_name     => 'disableAmdConstraints');
      disableAmdConstraints;
      batch_step_number :=
         amd_batch_pkg.getActiveStep (
            batch_job_number   => batch_job_number,
            system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP);
      amd_batch_pkg.end_step (
         batch_job_number    => batch_job_number,
         system_id           => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
         batch_step_number   => batch_step_number);

      amd_batch_pkg.start_step (
         batch_job_number   => batch_job_number,
         system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
         description        => 'truncateAmdTables',
         package_name       => THIS_PACKAGE,
         procedure_name     => 'truncateAmdTables');
      truncateAmdTables;
      batch_step_number :=
         amd_batch_pkg.getActiveStep (
            batch_job_number   => batch_job_number,
            system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP);
      amd_batch_pkg.end_step (
         batch_job_number    => batch_job_number,
         system_id           => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
         batch_step_number   => batch_step_number);

      amd_batch_pkg.start_step (
         batch_job_number   => batch_job_number,
         system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
         description        => 'enableAmdConstraints',
         package_name       => THIS_PACKAGE,
         procedure_name     => 'enableAmdConstraints');
      enableAmdConstraints;
      batch_step_number :=
         amd_batch_pkg.getActiveStep (
            batch_job_number   => batch_job_number,
            system_id          => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP);
      amd_batch_pkg.end_step (
         batch_job_number    => batch_job_number,
         system_id           => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP,
         batch_step_number   => batch_step_number);

      debugMsg ('end prepAmdDatabase', pError_location => 690);
      COMMIT;
   END prepAmdDatabase;

   PROCEDURE version
   IS
   BEGIN
      writeMsg (pTableName        => 'amd_load',
                pError_location   => 480,
                pKey1             => 'amd_load',
                pKey2             => '$Revision:   1.97  $');
      DBMS_OUTPUT.put_line ('amd_load: $Revision:   1.97  $');
   END version;

   FUNCTION getVersion
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN '$Revision:   1.97  $';
   END getVersion;

   PROCEDURE validatePartStructure
   IS
      CURSOR NoNsn4SpareParts
      IS
         SELECT *
           FROM amd_spare_parts
          WHERE nsn IS NULL;

      CURSOR NoNsn4Items
      IS
         SELECT *
           FROM amd_National_Stock_Items
          WHERE nsn IS NULL;

      CURSOR NoPrimePart
      IS
         SELECT *
           FROM amd_national_stock_items
          WHERE prime_part_no IS NULL;

      CURSOR NotDeleted
      IS
         SELECT nsi_sid, prime_part_no
           FROM amd_national_stock_items items, amd_spare_parts parts
          WHERE     prime_part_no = part_no
                AND items.action_code <> amd_defaults.DELETE_ACTION
                AND parts.action_code = amd_defaults.DELETE_ACTION;

      cntNoNsnParts    NUMBER := 0;
      cntNoNsnItems    NUMBER := 0;
      cntNoPrimePart   NUMBER := 0;
      cntNotDeleted    NUMBER := 0;
   BEGIN
      FOR rec IN NoNsn4SpareParts
      LOOP
         cntNoNsnParts := cntNoNsnParts + 1;
         writeMsg (pTableName        => 'amd_spare_parts',
                   pError_location   => 490,
                   pKey1             => 'part_no=' || rec.part_no,
                   pKey2             => 'No Nsn',
                   pKey3             => 'action_code=' || rec.action_code);
      END LOOP;

      FOR rec IN NoNsn4Items
      LOOP
         cntNoNsnItems := cntNoNsnItems + 1;
         writeMsg (pTableName        => 'amd_national_stock_items',
                   pError_location   => 500,
                   pKey1             => 'prime_part_no=' || rec.prime_part_no,
                   pKey2             => 'No Nsn',
                   pKey3             => 'action_code=' || rec.action_code);
      END LOOP;

      FOR rec IN NoPrimePart
      LOOP
         cntNoPrimePart := cntNoPrimePart + 1;
         writeMsg (pTableName        => 'amd_national_stock_items',
                   pError_location   => 510,
                   pKey1             => 'nsi_sid=' || rec.nsi_sid,
                   pKey2             => 'No Prime Part',
                   pKey3             => 'action_code=' || rec.action_code,
                   pKey4             => 'nsn=' || rec.nsn);
      END LOOP;

      FOR rec IN NotDeleted
      LOOP
         cntNotDeleted := cntNotDeleted + 1;

         UPDATE amd_national_stock_items
            SET action_code = amd_defaults.DELETE_ACTION,
                last_update_dt = SYSDATE
          WHERE nsi_sid = rec.nsi_sid;
      END LOOP;

      DBMS_OUTPUT.put_line ('cntNoNsnParts=' || cntNoNsnParts);
      DBMS_OUTPUT.put_line ('cntNoNsnItems=' || cntNoNsnItems);
      DBMS_OUTPUT.put_line ('cntNoPrimePart=' || cntNoPrimePart);
      DBMS_OUTPUT.put_line ('cntNotDeleted=' || cntNotDeleted);
      writeMsg (
         pTableName        => 'amd_spare_parts',
         pError_location   => 520,
         pKey1             => 'cntNoNsnParts=' || TO_CHAR (cntNoNsnParts));
      writeMsg (
         pTableName        => 'amd_national_stock_items',
         pError_location   => 530,
         pKey1             => 'cntNoNsnItems=' || TO_CHAR (cntNoNsnItems));
      writeMsg (
         pTableName        => 'amd_national_stock_items',
         pError_location   => 540,
         pKey1             => 'cntNoPrimePart=' || TO_CHAR (cntNoPrimePart));
      writeMsg (
         pTableName        => 'amd_national_stock_items',
         pError_location   => 550,
         pKey1             => 'cntNotDeleted=' || TO_CHAR (cntNotDeleted));
      COMMIT;
   END validatePartStructure;

   -- added 4/2/2007 by DSE
   FUNCTION getORIGINAL_DATA
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN ORIGINAL_DATA;
   END getORIGINAL_DATA;

   FUNCTION getCLEANED_DATA
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN CLEANED_DATA;
   END getCLEANED_DATA;

   FUNCTION getCURRENT_NSN
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN CURRENT_NSN;
   END getCURRENT_NSN;

   -- added 6/25/2008 by dse
   PROCEDURE setBulkInsertThreshold (VALUE IN NUMBER)
   IS
   BEGIN
      bulkInsertThreshold := VALUE;
   END setBulkInsertThreshold;

   FUNCTION setBulkInsertThreshold (VALUE IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      setBulkInsertThreshold (VALUE);
      RETURN getBulkInsertThreshold;
   END setBulkInsertThreshold;

   FUNCTION getBulkInsertThreshold
      RETURN NUMBER
   IS
   BEGIN
      RETURN bulkInsertThreshold;
   END getBulkInsertThreshold;

   FUNCTION setDebug (VALUE IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      setDebug (VALUE);
      RETURN getDebug;
   END setDebug;

   PROCEDURE setDebug (VALUE IN VARCHAR2)
   IS                                                       -- added 6/30/2008
   BEGIN
      mDebug :=
         (LOWER (VALUE) IN ('1',
                            'y',
                            't',
                            'yes',
                            'true'));

      IF mDebug
      THEN
         DBMS_OUTPUT.ENABLE (100000);
      ELSE
         DBMS_OUTPUT.DISABLE;
      END IF;
   END setDebug;

   FUNCTION getDebug
      RETURN VARCHAR2
   IS
   BEGIN
      IF mDebug
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END getDebug;

   FUNCTION getUseBizDays
      RETURN VARCHAR2
   IS
   BEGIN
      IF useBizDays
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END getUseBizDays;

   PROCEDURE setUseBizDays (VALUE IN VARCHAR2)
   IS
   BEGIN
      useBizDays :=
         (LOWER (VALUE) IN ('1',
                            'y',
                            't',
                            'yes',
                            'true'));
   END setUseBizDays;

   FUNCTION setUseBizDays (VALUE IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      setUseBizDays (VALUE);
      RETURN getUseBizDays;
   END setUseBizDays;
BEGIN
  <<getDebugParam>>
   DECLARE
      param   AMD_PARAM_CHANGES.PARAM_VALUE%TYPE;
   BEGIN
      param := amd_defaults.GetParamValue ('debugAmdLoad');

      IF param IS NOT NULL
      THEN
         mDebug :=
            (LOWER (param) IN ('1',
                               'y',
                               't',
                               'yes',
                               'true'));
      ELSE
         mDebug := FALSE;
      END IF;

      param := amd_defaults.GetParamValue ('useBizDays');

      IF param IS NOT NULL
      THEN
         useBizDays :=
            (LOWER (param) IN ('1',
                               'y',
                               't',
                               'yes',
                               'true'));
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         mDebug := FALSE;
   END getDebugParam;

   bulkInsertThreshold :=
      NVL (TO_NUMBER (amd_defaults.GETPARAMVALUE ('bulkInsertThreshold')),
           bulkInsertThreshold);
END Amd_Load;
/


DROP PUBLIC SYNONYM AMD_LOAD;

CREATE PUBLIC SYNONYM AMD_LOAD FOR AMD_OWNER.AMD_LOAD;


GRANT EXECUTE ON AMD_OWNER.AMD_LOAD TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_LOAD TO AMD_WRITER_ROLE;
