/* Formatted on 5/17/2017 3:58:02 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY AMD_OWNER.amd_spare_parts_pkg
AS
   /*
      $Author:   Douglas S. Elder
    $Revision:   1.125
        $Date:   14 Jul 2016
    $Workfile:   amd_spare_parts_pkg.pkb  $
    
     Rev 1.125 17 May 2017 added dbms_output to loadCurrentBackOrder and reformatted code
     Rev 1.124 14 Jul 2016 add writeMsg to insertRow when there is a non-zero return code
     Rev 1.123 11 Jul 2016 removed setting mDebug to true for insertRow
     Rev 1.122 17 Jun 2016 reformatted code

     Rev 1.121 21 Sep 2015 added getProgramId

     Rev 1.120.4 18 Jun 2015 use tmp1.to_loc_id and req1.select_from_loc_id

     Rev 1.120.3 23 Feb 2015 added amd_defaults.getStartLocId

     Rev 1.120.2 20 Feb 2015 added new value for last_update_dt and updated_by when amd_bssm_rvt needs
                   to be updated to be in sync on nsn's with amd_national_stock_items

     Rev 1.120.1 2/19/2015 added exception handlers to doUpdate and deleteAnyRblPairs

     Rev 1.120 2/19/2015 merged in patch 1.118.1  of UpdateRow's doupdate procedure and address the amd_bssm_rvt.amd_bssm_rvt_fk01 2292 constraint error that was
     occuring when the nsn was being changed for amd_national_stock_items.  The data that was causing the error was captured, deleted, and then
     restored with the new nsn to amd_bssm_rvt using a local declare .. begin / end block of code.

     Rev 1.119 2/4/2015 added amd_defaults.getSourceCode, getNonStockageList

     Rev 1.118 for hasPartMoved make sure subquery return one row by using "distinct' keyword

     Rev 1.117 - use consumables_pkg instead of a2a_consumables_pkg

     Rev 1.115   07 Aug 2009 11:11:30   zf297a
  Use the common sleep procedure

     Rev 1.114   15 Jul 2009 10:52:16   zf297a
  Removed a2a code

     Rev 1.111   24 Oct 2008 14:08:22   zf297a
  Made updateNsiPrimePartData, insertAmdNsn, updateAmdNsn,  prepareDataForUpdate, updateAmdSparePartRow, updatePrimeInd, insertNewNsn,  and checkNsnAndPrimeInd into procedures that throw exceptions when there are errors to simplify coding.

     Rev 1.110   24 Oct 2008 13:29:12   zf297a
  Made updatePrimePartNo into a procedure that throws exceptions for errors to simplify coding.

     Rev 1.109   24 Oct 2008 13:22:18   zf297a
  Made unassignPrimePart into a procedure that throws exceptions for errors to simplify coding.

     Rev 1.108   24 Oct 2008 13:09:20   zf297a
  Made makeNsnSameFoeAllParts into a procedure that throw exceptions for errors to simplify coding.

     Rev 1.107   24 Oct 2008 13:01:36   zf297a
  made doPhysicalInsert into a procedure that throws exceptions when there are errors to simplify coding.

     Rev 1.106   24 Oct 2008 12:45:38   zf297a
  Made doLogincalInsert into a procedure that throws exceptions for errors.

     Rev 1.105   24 Oct 2008 12:40:00   zf297a
  made updateNatStkItem a procedure which throws exception when there is an error to simplify coding.

     Rev 1.104   24 Oct 2008 12:17:28   zf297a
  Make insertSparePart and updatePrimePartData into procedures that through exceptions when there is an error.  This simplifies the code.

     Rev 1.103   24 Oct 2008 11:56:06   zf297a
  Made createNationalStockItem, makePrimeAnEquivalentPart, and prepareDataForInsert into  procedures to simplity code.  Rely on exception to exit routines when there are errors.

     Rev 1.102   24 Oct 2008 11:36:16   zf297a
  Made insertNsiParts into a procedure.  The exception will stop any routine that invokes it.

     Rev 1.101   24 Oct 2008 10:46:02   zf297a
  Implemented interfaces setDebug and getDebugYorN.  Replaced  writeMsg's that depend on mDebug with debugMsg.
  Changed debugMsg's 2nd param to pError_location so it can be resquenced with the awk resequence utility.

     Rev 1.100   23 Oct 2008 21:30:10   zf297a
  Added variable is_spo_part to deleteRow.

     Rev 1.99   23 Oct 2008 21:21:34   zf297a
  Added autonomous transaction pragma to ErrorMsg and debugMsg.

  Added an out parameter to updateFlags so that invoking routines can determine if the part is a spo part.

  After updating the flags and the part is no longer a spo part, but it had been one then execute a2a_pkg.deletePartInfo.

  Don't execute A2A code if the part is not a spo part.


     Rev 1.98   23 Oct 2008 15:17:56   zf297a
  For updateRow check is_spo_part before invoking a2a routines.

     Rev 1.97   13 Oct 2008 09:10:44   zf297a
  do updateFlags before any A2A processing is done since the package now uses the flags.

     Rev 1.96   22 Sep 2008 13:30:18   zf297a
  update flags is_repairable, is_consumable, and is_spo_part.

     Rev 1.95   09 Jul 2008 14:50:26   zf297a
  started using amd_defaults.CONSUMABLE_PLANNER_CODE and amd_defaults.REPAIRABLE_PLANNER_CODE.

     Rev 1.94   27 Jun 2008 11:59:22   zf297a
  Added some debug code.

     Rev 1.93   06 Jun 2008 22:08:10   zf297a
  Make sure that the part was sent to the spo via the amd_sent_to_a2a table before invoking the a2a_pkg.deletePartPricing function.

     Rev 1.92   16 May 2008 12:10:52   zf297a
  Fixed setting of debug flag for the a2a_pkg and added getVersion function

     Rev 1.91   27 Mar 2008 12:08:40   zf297a
  Made constant unable_to_get_prime_part unique for Oracle 10g

     Rev 1.90   20 Nov 2007 10:39:24   zf297a
  Fixed typo - partNoTab

     Rev 1.89   20 Nov 2007 10:20:12   zf297a
  Use bulk update for function makeNsnSameForAllParts and use bulk collect and bulk update for loadCurrentBackOrder.

     Rev 1.88   Nov 14 2007 18:55:44   c402417
  Added procedures insert, update, and delete for repair to table tmp_a2a_part_lead_time.

     Rev 1.87   11 Sep 2007 16:47:10   zf297a
  Added wesm_indicator and removed commits from for/loop's.

     Rev 1.86   24 May 2007 14:15:38   zf297a
  Used the simplified a2a_pkg.insertPartInfo procedure to create the A2A PartInfo data.

     Rev 1.85   05 Apr 2007 09:28:56   zf297a
  Added isDiff routines to replace complex conditions.  Added lineNumber to updateRow to help in debugging.

     Rev 1.84   05 Mar 2007 11:27:48   zf297a
  For updateRow update amd_spare_parts.order_lead_time_defaulted.

     Rev 1.83   14 Feb 2007 13:58:18   zf297a
  Implemented new version of insertRow and updateRow using amcDemand and amcDemandCleaned.

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
     04/04/02 Douglas Elder    Added Mic Code to insert and update
     04/05/02 Douglas Elder    Added code to update the nsn_type for
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



   PROGRAM_ID          CONSTANT VARCHAR2 (30) := amd_defaults.getProgramId;
   PROGRAM_ID_LL       CONSTANT NUMBER := LENGTH (PROGRAM_ID);

   UNIT_COST_CLEANED_VIA_NSN    EXCEPTION;
   CANNOT_FIND_PART             EXCEPTION;
   ADD_UOM_CODE_EXCEPTION       EXCEPTION;
   ADD_PLANNER_CODE_EXCEPTION   EXCEPTION;
   UNABLE_TO_GET_NSI_SID_EXP    EXCEPTION;

   -- package member variables
   mDebug                       BOOLEAN := FALSE;
   mRc                          NUMBER := FAILURE;
   mArgs                        VARCHAR2 (2000);
   mMtbdr                       amd_national_stock_items.mtbdr%TYPE;
   mMtbdr_computed              amd_national_stock_items.mtbdr_computed%TYPE;
   mQpeiWeighted                amd_national_stock_items.qpei_weighted%TYPE;
   mCondemnAvgCleaned           amd_national_stock_items.condemn_avg_cleaned%TYPE;
   mCriticalityCleaned          amd_national_stock_items.criticality%TYPE;
   mMtbdrCleaned                amd_national_stock_items.mtbdr_cleaned%TYPE;
   mNrtsAvgCleaned              amd_national_stock_items.nrts_avg_cleaned%TYPE;
   mCostToRepairOffBaseCleand   amd_national_stock_items.cost_to_repair_off_base_cleand%TYPE;
   mTimeToRepairOffBaseCleand   amd_national_stock_items.time_to_repair_off_base_cleand%TYPE;
   mOrderLeadTimeCleaned        amd_national_stock_items.order_lead_time_cleaned%TYPE;
   mPlannerCodeCleaned          amd_national_stock_items.planner_code_cleaned%TYPE;
   mRtsAvgCleaned               amd_national_stock_items.rts_avg_cleaned%TYPE;
   mSmrCodeCleaned              amd_national_stock_items.smr_code_cleaned%TYPE;
   mUnitCostCleaned             amd_national_stock_items.unit_cost_cleaned%TYPE;
   mCondemnAvg                  amd_national_stock_items.condemn_avg%TYPE;
   mCriticality                 amd_national_stock_items.criticality%TYPE;
   mNrtsAvg                     amd_national_stock_items.nrts_avg%TYPE;
   mRtsAvg                      amd_national_stock_items.rts_avg%TYPE;
   mCostToRepairOffBase         amd_national_stock_items.cost_to_repair_off_base%TYPE;
   mTimeToRepairOffBase         amd_national_stock_items.time_to_repair_off_base%TYPE;
   mAmcDemand                   amd_national_stock_items.amc_demand%TYPE;
   mAmcDemandCleaned            amd_national_stock_items.amc_demand_cleaned%TYPE;
   mWesmIndicator               amd_national_stock_items.WESM_INDICATOR%TYPE;


   ---------------------------------------------------------------
   -- Private declarations
   --

   FUNCTION getFedcCost (pPartNo VARCHAR2)
      RETURN NUMBER;

   FUNCTION hasPartMoved (pPartNo VARCHAR2, pNsn VARCHAR2)
      RETURN BOOLEAN;

   PROCEDURE unassignPart (pPartNo VARCHAR2);

   FUNCTION ErrorMsg (
      pSourceName          IN amd_load_status.SOURCE%TYPE,
      pTableName           IN amd_load_status.TABLE_NAME%TYPE,
      pError_location      IN amd_load_details.DATA_LINE_NO%TYPE,
      pReturn_code         IN NUMBER,
      pPart_no             IN VARCHAR2 := '',
      pNsi_sid             IN VARCHAR2 := '',
      pKeywordValuePairs   IN VARCHAR2 := '',
      pComments            IN VARCHAR2 := '')
      RETURN NUMBER;

   --
   -- End Private declarations
   ---------------------------------------------------------------

   debugThreshold               NUMBER := 1000;
   debugCnt                     NUMBER := 0;

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
      Amd_Utils.writeMsg (pSourceName       => 'amd_spare_parts_pkg',
                          pTableName        => pTableName,
                          pError_location   => pError_location,
                          pKey1             => pKey1,
                          pKey2             => pKey2,
                          pKey3             => pKey3,
                          pKey4             => pKey4,
                          pData             => pData,
                          pComments         => pComments);
   END writeMsg;

   FUNCTION ErrorMsg (
      pSqlfunction         IN amd_load_status.SOURCE%TYPE,
      pTableName           IN amd_load_status.TABLE_NAME%TYPE,
      pError_location         amd_load_details.DATA_LINE_NO%TYPE,
      pReturn_code         IN NUMBER,
      pKey_1               IN amd_load_details.KEY_1%TYPE,
      pKey_2               IN amd_load_details.KEY_2%TYPE := '',
      pKey_3               IN amd_load_details.KEY_3%TYPE := '',
      pKey_4               IN amd_load_details.KEY_4%TYPE := '',
      pKeywordValuePairs   IN VARCHAR2 := '')
      RETURN NUMBER
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      key5   amd_load_details.KEY_5%TYPE := pKeywordValuePairs;
   BEGIN
      IF key5 = ''
      THEN
         key5 := pSqlFunction || '/' || pTableName;
      ELSE
         key5 := key5 || ' ' || pSqlFunction || '/' || pTableName;
      END IF;

      -- use substr's to make sure that the input parameters for InsertErrorMsg and GetLoadNo
      -- do not exceed the length of the column's that the data gets inserted into
      -- This is for debugging and logging, so efforts to make it not be the source of more
      -- errors is VERY important
      Amd_Utils.InsertErrorMsg (
         pLoad_no        => Amd_Utils.GetLoadNo (
                              pSourceName   => SUBSTR (pSqlfunction, 1, 20),
                              pTableName    => SUBSTR (pTableName, 1, 20)),
         pData_line_no   => pError_location,
         pData_line      => 'amd_spare_parts_pkg.' || mArgs,
         pKey_1          => SUBSTR (pKey_1, 1, 50),
         pKey_2          => SUBSTR (pKey_2, 1, 50),
         pKey_3          => SUBSTR (pKey_3, 1, 50),
         pKey_4          => SUBSTR (pKey_4, 1, 50),
         pKey_5          => SUBSTR (
                                 'rc='
                              || TO_CHAR (pReturn_code)
                              || ' '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM')
                              || ' '
                              || key5,
                              1,
                              50),
         pComments       => SUBSTR (
                                 'sqlcode('
                              || SQLCODE
                              || ') sqlerrm('
                              || SQLERRM
                              || ')',
                              1,
                              2000));
      COMMIT;
      RETURN pReturn_code;
   EXCEPTION
      WHEN OTHERS
      THEN
         COMMIT;
   END ErrorMsg;

   PROCEDURE ErrorMsg (
      pSqlfunction         IN amd_load_status.SOURCE%TYPE,
      pTableName           IN amd_load_status.TABLE_NAME%TYPE := '',
      pError_location         amd_load_details.DATA_LINE_NO%TYPE,
      pKey_1               IN amd_load_details.KEY_1%TYPE := '',
      pKey_2               IN amd_load_details.KEY_2%TYPE := '',
      pKey_3               IN amd_load_details.KEY_3%TYPE := '',
      pKey_4               IN amd_load_details.KEY_4%TYPE := '',
      pKeywordValuePairs   IN VARCHAR2 := '')
   IS
      result   NUMBER;
   BEGIN
      result :=
         ErrorMsg (pSqlfunction         => pSqlfunction,
                   pTableName           => pTableName,
                   pError_location      => pError_location,
                   pReturn_code         => FAILURE,
                   pKey_1               => pKey_1,
                   pKey_2               => pKey_2,
                   pKey_3               => pKey_3,
                   pKey_4               => pKey_4,
                   pKeywordValuePairs   => pKeywordValuePairs);
   EXCEPTION
      WHEN OTHERS
      THEN
         COMMIT;
   END ErrorMsg;


   -- add wrapper for amd_utils.debugMsg
   PROCEDURE debugMsg (pMsg IN VARCHAR2, pError_Location IN NUMBER)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      -- is debugging turned on for this package?
      IF mDebug
      THEN
         amd_utils.debugMsg (pMsg        => pMsg,
                             pPackage    => 'amd_spare_parts',
                             pLocation   => pError_Location);
         COMMIT;                                -- make sure the trace is kept
      END IF;
   END;

   PROCEDURE updateFlags (
      pPart_no      IN     amd_spare_parts.part_no%TYPE,
      is_spo_part      OUT amd_spare_parts.is_spo_part%TYPE)
   IS
      isSpoPart      amd_spare_parts.is_spo_part%TYPE;
      isRepairable   amd_spare_parts.is_repairable%TYPE;
      isConsumable   amd_spare_parts.is_consumable%TYPE;
   BEGIN
      isSpoPart := 'N';
      isConsumable := 'N';
      isRepairable := 'N';

      IF amd_utils.isPartRepairable (pPart_no)
      THEN
         isRepairable := 'Y';

         IF isValidRepairablePart (pPart_no)
         THEN
            isSpoPart := 'Y';
         END IF;
      END IF;

      IF amd_utils.isPartConsumable (pPart_no)
      THEN
         isConsumable := 'Y';

         IF isValidConsumablePart (pPart_no)
         THEN
            isSpoPart := 'Y';
         END IF;
      END IF;

      UPDATE amd_spare_parts
         SET is_repairable = isRepairable,
             is_consumable = isConsumable,
             is_spo_part = isSpoPart
       WHERE part_no = pPart_no;

      is_spo_part := isSpoPart;
   EXCEPTION
      WHEN OTHERS
      THEN
         ErrorMsg (pSqlfunction => 'updateFlags', pError_location => 10);
   END updateFlags;

   FUNCTION getCriticalityChangedInd (
      nsi_sid   IN amd_national_stock_items.nsi_sid%TYPE)
      RETURN amd_national_stock_items.criticality_changed%TYPE
   IS
      oldCriticality          amd_national_stock_items.CRITICALITY%TYPE;
      oldCriticalityCleaned   amd_national_stock_items.CRITICALITY_CLEANED%TYPE;
   BEGIN
     <<getOldValues>>
      BEGIN
         SELECT criticality, criticality_cleaned
           INTO oldCriticality, oldCriticalityCleaned
           FROM amd_national_stock_items
          WHERE nsi_sid = getCriticalityChangedInd.nsi_sid;
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            oldCriticality := NULL;
            oldCriticalityCleaned := NULL;
         WHEN OTHERS
         THEN
            ErrorMsg (
               pSqlfunction      => 'select',
               pTableName        => 'amd_national_stock_items',
               pError_location   => 20,
               pKey_1            => TO_CHAR (getCriticalityChangedInd.nsi_sid));
            RAISE;
      END getOldValues;

      IF amd_preferred_pkg.GetPreferredValue (mCriticalityCleaned,
                                              mCriticality) !=
            amd_preferred_pkg.GetPreferredValue (oldCriticalityCleaned,
                                                 oldCriticality)
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END getCriticalityChangedInd;

   FUNCTION getNrtsAvgChangedInd (
      nsi_sid   IN amd_national_stock_items.nsi_sid%TYPE)
      RETURN amd_national_stock_items.nrts_avg_changed%TYPE
   IS
      oldNrtsAvg          amd_national_stock_items.Nrts_Avg%TYPE;
      oldNrtsAvgCleaned   amd_national_stock_items.Nrts_Avg_CLEANED%TYPE;
   BEGIN
     <<getOldValues>>
      BEGIN
         SELECT Nrts_Avg, Nrts_Avg_cleaned
           INTO oldNrtsAvg, oldNrtsAvgCleaned
           FROM amd_national_stock_items
          WHERE nsi_sid = getNrtsAvgChangedInd.nsi_sid;
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            oldNrtsAvg := NULL;
            oldNrtsAvgCleaned := NULL;
         WHEN OTHERS
         THEN
            ErrorMsg (
               pSqlfunction      => 'select',
               pTableName        => 'amd_national_stock_items',
               pError_location   => 30,
               pKey_1            => TO_CHAR (getNrtsAvgChangedInd.nsi_sid));
            RAISE;
      END getOldValues;

      IF amd_preferred_pkg.GetPreferredValue (mNrtsAvgCleaned, mNrtsAvg) !=
            amd_preferred_pkg.GetPreferredValue (oldNrtsAvgCleaned,
                                                 oldNrtsAvg)
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END getNrtsAvgChangedInd;

   FUNCTION getRtsAvgChangedInd (
      nsi_sid   IN amd_national_stock_items.nsi_sid%TYPE)
      RETURN amd_national_stock_items.rts_avg_changed%TYPE
   IS
      oldRtsAvg          amd_national_stock_items.Rts_Avg%TYPE;
      oldRtsAvgCleaned   amd_national_stock_items.Rts_Avg_CLEANED%TYPE;
   BEGIN
     <<getOldValues>>
      BEGIN
         SELECT Rts_Avg, Rts_Avg_cleaned
           INTO oldRtsAvg, oldRtsAvgCleaned
           FROM amd_national_stock_items
          WHERE nsi_sid = getRtsAvgChangedInd.nsi_sid;
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            oldRtsAvg := NULL;
            oldRtsAvgCleaned := NULL;
         WHEN OTHERS
         THEN
            ErrorMsg (
               pSqlfunction      => 'select',
               pTableName        => 'amd_national_stock_items',
               pError_location   => 40,
               pKey_1            => TO_CHAR (getRtsAvgChangedInd.nsi_sid));
            RAISE;
      END getOldValues;

      IF amd_preferred_pkg.GetPreferredValue (mRtsAvgCleaned, mRtsAvg) !=
            amd_preferred_pkg.GetPreferredValue (oldRtsAvgCleaned, oldRtsAvg)
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END getRtsAvgChangedInd;

   FUNCTION getCondemnAvgChangedInd (
      nsi_sid   IN amd_national_stock_items.nsi_sid%TYPE)
      RETURN amd_national_stock_items.condemn_avg_changed%TYPE
   IS
      oldCondemnAvg          amd_national_stock_items.Condemn_Avg%TYPE;
      oldCondemnAvgCleaned   amd_national_stock_items.Condemn_Avg_CLEANED%TYPE;
   BEGIN
     <<getOldValues>>
      BEGIN
         SELECT Condemn_Avg, Condemn_Avg_cleaned
           INTO oldCondemnAvg, oldCondemnAvgCleaned
           FROM amd_national_stock_items
          WHERE nsi_sid = getCondemnAvgChangedInd.nsi_sid;
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            oldCondemnAvg := NULL;
            oldCondemnAvgCleaned := NULL;
         WHEN OTHERS
         THEN
            ErrorMsg (
               pSqlfunction      => 'select',
               pTableName        => 'amd_national_stock_items',
               pError_location   => 50,
               pKey_1            => TO_CHAR (getCondemnAvgChangedInd.nsi_sid));
            RAISE;
      END getOldValues;

      IF amd_preferred_pkg.GetPreferredValue (mCondemnAvgCleaned,
                                              mCondemnAvg) !=
            amd_preferred_pkg.GetPreferredValue (oldCondemnAvgCleaned,
                                                 oldCondemnAvg)
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END getCondemnAvgChangedInd;

   FUNCTION getCostToRepairOffBaseChgedInd (
      nsi_sid   IN amd_national_stock_items.nsi_sid%TYPE)
      RETURN amd_national_stock_items.cost_to_repair_off_base_chged%TYPE
   IS
      oldCostToRepairOffBase         amd_national_stock_items.cost_to_repair_off_base%TYPE;
      oldCostToRepairOffBaseCleand   amd_national_stock_items.cost_to_repair_off_base_cleand%TYPE;
   BEGIN
     <<getOldValues>>
      BEGIN
         SELECT cost_to_repair_off_base, cost_to_repair_off_base_cleand
           INTO oldCostToRepairOffBase, oldCostToRepairOffBaseCleand
           FROM amd_national_stock_items
          WHERE nsi_sid = getCostToRepairOffBaseChgedInd.nsi_sid;
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            oldCostToRepairOffBase := NULL;
            oldCostToRepairOffBaseCleand := NULL;
         WHEN OTHERS
         THEN
            ErrorMsg (
               pSqlfunction      => 'select',
               pTableName        => 'amd_national_stock_items',
               pError_location   => 60,
               pKey_1            => TO_CHAR (
                                      getCostToRepairOffBaseChgedInd.nsi_sid));
            RAISE;
      END getOldValues;

      IF amd_preferred_pkg.GetPreferredValue (mCostToRepairOffBaseCleand,
                                              mCostToRepairOffBase) !=
            amd_preferred_pkg.GetPreferredValue (
               oldCostToRepairOffBaseCleand,
               oldCostToRepairOffBase)
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END getCostToRepairOffBaseChgedInd;

   FUNCTION getTimeToRepairOffBaseChgedInd (
      nsi_sid   IN amd_national_stock_items.nsi_sid%TYPE)
      RETURN amd_national_stock_items.time_to_repair_off_base_chged%TYPE
   IS
      oldTimeToRepairOffBase         amd_national_stock_items.time_to_repair_off_base%TYPE;
      oldTimeToRepairOffBaseCleand   amd_national_stock_items.time_to_repair_off_base_cleand%TYPE;
   BEGIN
     <<getOldValues>>
      BEGIN
         SELECT time_to_repair_off_base, time_to_repair_off_base_cleand
           INTO oldTimeToRepairOffBase, oldTimeToRepairOffBaseCleand
           FROM amd_national_stock_items
          WHERE nsi_sid = getTimeToRepairOffBaseChgedInd.nsi_sid;
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            oldTimeToRepairOffBase := NULL;
            oldTimeToRepairOffBaseCleand := NULL;
         WHEN OTHERS
         THEN
            ErrorMsg (
               pSqlfunction      => 'select',
               pTableName        => 'amd_national_stock_items',
               pError_location   => 70,
               pKey_1            => TO_CHAR (
                                      getTimeToRepairOffBaseChgedInd.nsi_sid));
            RAISE;
      END getOldValues;

      IF amd_preferred_pkg.GetPreferredValue (mTimeToRepairOffBaseCleand,
                                              mTimeToRepairOffBase) !=
            amd_preferred_pkg.GetPreferredValue (
               oldTimeToRepairOffBaseCleand,
               oldTimeToRepairOffBase)
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END getTimeToRepairOffBaseChgedInd;

   PROCEDURE insertLoadDetail (pPartNo      VARCHAR2,
                               pNsn         VARCHAR2,
                               pPrimeInd    VARCHAR2,
                               pAction      VARCHAR2)
   IS
      aspNsn       amd_spare_parts.nsn%TYPE;
      aspAction    amd_spare_parts.action_code%TYPE;
      anpNsiSid    amd_nsi_parts.nsi_sid%TYPE;
      anNsiSid     amd_nsns.nsi_sid%TYPE;
      anNsn        amd_nsns.nsn%TYPE;
      anNsn2       amd_nsns.nsn%TYPE;
      anNsnType    amd_nsns.nsn_type%TYPE;
      anNsnType2   amd_nsns.nsn_type%TYPE;
      anpPrime     amd_nsi_parts.prime_ind%TYPE;
   BEGIN
      BEGIN
         SELECT anp.prime_ind,
                an.nsn,
                an.nsn_type,
                anp.nsi_sid,
                asp.action_code,
                asp.nsn
           INTO anpPrime,
                anNsn,
                anNsnType,
                anpNsiSid,
                aspAction,
                aspNsn
           FROM amd_spare_parts asp, amd_nsi_parts anp, amd_nsns an
          WHERE     asp.part_no = pPartNo
                AND asp.part_no = anp.part_no
                AND anp.nsi_sid = an.nsi_sid
                AND anp.unassignment_date IS NULL
                AND an.nsn_type = 'C';
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      BEGIN
         SELECT nsi_sid, nsn, nsn_type
           INTO anNsiSid, anNsn2, anNsnType2
           FROM amd_nsns
          WHERE nsn = pNsn;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      amd_utils.InsertErrorMsg (
         pLoad_no        => amd_utils.GetLoadNo (
                              pSourceName   => 'amd_spare_parts_pkg',
                              pTableName    => 'amd_spare_parts'),
         pData_line_no   => 1,
         pData_line      => SUBSTR (
                                 'D: '
                              || pAction
                              || '- Curr View - pPartNo('
                              || pPartNo
                              || ') pNsn('
                              || pNsn
                              || ') pPrimeInd('
                              || pPrimeInd
                              || ') - anNsn('
                              || anNsn
                              || ') anNsnType('
                              || anNsnType
                              || ') aspAction('
                              || aspAction
                              || ') anpPrime('
                              || anpPrime
                              || ') anpNsiSid('
                              || anpNsiSid
                              || ')',
                              1,
                              2000),
         pKey_1          => 'anNsn2(' || anNsiSid || ')',
         pKey_2          => 'anNsnType2(' || anNsnType2 || ')',
         pKey_3          => 'aspNsn(' || aspNsn || ')',
         pKey_4          => 'anNsiSid(' || anNsiSid || ')',
         pKey_5          => '',
         pComments       => TO_CHAR (SYSDATE, 'yyyymmdd hh:mi:ss am'));

      COMMIT;
   END insertLoadDetail;


   PROCEDURE unassociateTmpNsn (pNsn VARCHAR2)
   IS
   BEGIN
      debugMsg ('unassociateTmpNsn(' || pNsn || ')', pError_location => 80);

      -- We do this when a temp nsn now appears in CAT1. This will remove
      -- the association to the current nsn and will set up the process
      -- to create a new nsi_sid for this formerly temp nsn.
      --
      DELETE FROM amd_nsns
            WHERE nsn = pNsn AND nsn_type = 'T';
   END;


   FUNCTION hasPartMoved (pPartNo VARCHAR2, pNsn VARCHAR2)
      RETURN BOOLEAN
   IS
      nsn   amd_nsns.nsn%TYPE;
   BEGIN
      debugMsg ('hasPartMoved(' || pPartNo || ')', pError_location => 90);

      -- A part has moved from one nsn to another if the new and old nsns
      -- appear in tmp_amd_spare_parts at the same time.
      --
      SELECT DISTINCT 'Part has moved.'
        INTO nsn
        FROM tmp_amd_spare_parts
       WHERE nsn =
                (SELECT DISTINCT an.nsn
                   FROM amd_nsi_parts anp, amd_nsns an
                  WHERE     anp.part_no = pPartNo
                        AND anp.nsi_sid = an.nsi_sid
                        AND anp.unassignment_date IS NULL
                        AND an.nsn_type = 'C'
                        AND an.nsn != pNsn)
      UNION
      SELECT 'Part has moved.'
        FROM amd_nsns an, amd_nsi_parts anp
       WHERE     anp.part_no = pPartNo
             AND an.nsi_sid != anp.nsi_sid
             AND anp.unassignment_date IS NULL
             AND an.nsn_type = 'C'
             AND an.nsn = pNsn;

      RETURN TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN FALSE;
   END;


   FUNCTION getFedcCost (pPartNo VARCHAR2)
      RETURN NUMBER
   IS
      CURSOR costCur
      IS
           SELECT gfp_price
             FROM prc1
            WHERE part = pPartNo AND gfp_price IS NOT NULL
         ORDER BY sc DESC;

      fedcCost   NUMBER;
   BEGIN
      debugMsg ('getFedcCost(' || pPartNo || ')', pError_location => 100);

      FOR rec IN costCur
      LOOP
         fedcCost := rec.gfp_price;
         EXIT;
      END LOOP;

      RETURN fedcCost;
   EXCEPTION
      WHEN OTHERS
      THEN
         ErrorMsg (pSqlfunction      => 'select',
                   pTableName        => 'prcl',
                   pError_location   => 110,
                   pKey_1            => pPartNo);
         RAISE;
   END getFedcCost;



   PROCEDURE unassignPart (pPartNo VARCHAR2)
   IS
   BEGIN
      debugMsg ('unassignPart(' || pPartNo || ')', pError_location => 120);

      UPDATE amd_nsi_parts
         SET unassignment_date = SYSDATE
       WHERE part_no = pPartNo AND unassignment_date IS NULL;
   END unassignPart;


   FUNCTION IsPrimePart (pPrime_ind IN amd_nsi_parts.prime_ind%TYPE)
      RETURN BOOLEAN
   IS
   BEGIN
      debugMsg ('isPrimePart(' || pPrime_ind || ')', pError_location => 130);
      RETURN (UPPER (pPrime_ind) = amd_defaults.PRIME_PART);
   EXCEPTION
      WHEN OTHERS
      THEN
         ErrorMsg (pSqlfunction      => 'isPrimeInd',
                   pTableName        => '',
                   pError_location   => 140,
                   pKey_1            => pPrime_ind);
         RAISE;
   END IsPrimePart;



   /* 8/23/02 DSE added ErrorMsg to eliminate some redundant code
    * and to give the error messages a std structure.
    */
   -- 9/3/04 DSE add stronger typing for Source and Table_name + add substr's to make
   -- certain that the key_1 to key_5 never exceed 50 characters
   FUNCTION ErrorMsg (
      pSourceName          IN amd_load_status.SOURCE%TYPE,
      pTableName           IN amd_load_status.TABLE_NAME%TYPE,
      pError_location      IN amd_load_details.DATA_LINE_NO%TYPE,
      pReturn_code         IN NUMBER,
      pPart_no             IN VARCHAR2 := '',
      pNsi_sid             IN VARCHAR2 := '',
      pKeywordValuePairs   IN VARCHAR2 := '',
      pComments            IN VARCHAR2 := '')
      RETURN NUMBER
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      amd_utils.InsertErrorMsg (
         pLoad_no        => amd_utils.GetLoadNo (pSourceName   => pSourceName,
                                                 pTableName    => pTableName),
         pData_line_no   => pError_location,
         pData_line      => 'amd_spare_parts_pkg.' || mArgs,
         pKey_1          => SUBSTR (pPart_no, 1, 50),
         pKey_2          => SUBSTR (pNsi_sid, 1, 50),
         pKey_3          => pKeywordValuePairs,
         pKey_4          => TO_CHAR (pReturn_code),
         pKey_5          => SYSDATE,
         pComments       =>    'sqlcode('
                            || SQLCODE
                            || ') sqlerrm('
                            || SQLERRM
                            || ') '
                            || pComments);

      COMMIT;
      RETURN pReturn_code;
   END;


   PROCEDURE insertNsiParts (
      pNsi_sid             IN amd_nsi_parts.nsi_sid%TYPE,
      pPart_no             IN amd_nsi_parts.part_no%TYPE,
      pPrime_ind           IN amd_nsi_parts.prime_ind%TYPE,
      pPrime_ind_cleaned   IN amd_nsi_parts.prime_ind_cleaned%TYPE,
      pBadRc               IN NUMBER)
   IS
      currDate   DATE := SYSDATE;
   BEGIN
      debugMsg (
            'insertNsiParts('
         || pNsi_sid
         || ','
         || pPart_no
         || ','
         || pPrime_ind
         || ','
         || pPrime_ind_cleaned
         || ','
         || pBadRc
         || ')',
         pError_location   => 150);

      INSERT INTO amd_nsi_parts (nsi_sid,
                                 assignment_date,
                                 part_no,
                                 prime_ind)
           VALUES (pNsi_sid,
                   currDate,
                   pPart_no,
                   pPrime_ind);

      -- This is a safeguard to ensure all other records are unassigned
      UPDATE amd_nsi_parts
         SET unassignment_date = SYSDATE
       WHERE     part_no = pPart_no
             AND unassignment_date IS NULL
             AND assignment_date < currDate;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
        <<InsertAgainAfterOneSecond>>
         BEGIN
            sleep (1);

            INSERT INTO amd_nsi_parts (nsi_sid,
                                       assignment_date,
                                       part_no,
                                       prime_ind)
                 VALUES (pNsi_sid,
                         SYSDATE,
                         pPart_no,
                         pPrime_ind);
         EXCEPTION
            WHEN OTHERS
            THEN
               mRc := amd_spare_parts_pkg.INSERTAGAIN_ERR + pBadRC;
               ErrorMsg (pSqlfunction      => 'insert',
                         pTableName        => 'amd_nsi_parts',
                         pError_location   => 160,
                         pKey_1            => pPart_no,
                         pKey_2            => TO_CHAR (pNsi_sid),
                         pKey_3            => 'prime_ind=' || pPrime_ind);
               RAISE;
         END InsertAgainAfterOneSecond;
      WHEN OTHERS
      THEN
         mRC := pBadRc;
         ErrorMsg (pSqlfunction      => 'update',
                   pTableName        => 'amd_nsi_parts',
                   pError_location   => 170,
                   pKey_1            => pPart_no);
         RAISE;
   END insertNsiParts;


   /* 8/22/02 DSE added MakeNsnSameForAllParts to eliminate some
    * redundant code.\
    */
   PROCEDURE MakeNsnSameForAllParts (
      pNsi_sid   IN amd_nsi_parts.nsi_sid%TYPE,
      pNsn       IN amd_national_stock_items.nsn%TYPE)
   IS
      TYPE partNoTab IS TABLE OF amd_nsi_parts.PART_NO%TYPE;

      partNos   PartNoTab;

      TYPE nsnTab IS TABLE OF amd_national_stock_items.nsn%TYPE;

      nsns      NsnTab;

      CURSOR partList
      IS
         SELECT part_no, pNsn
           FROM amd_nsi_parts
          WHERE nsi_sid = pNsi_sid AND unassignment_date IS NULL;
   BEGIN
      OPEN partList;

      FETCH partList BULK COLLECT INTO partNos, nsns;

      CLOSE partList;

      IF partNos.FIRST IS NOT NULL
      THEN
         FORALL indx IN partNos.FIRST .. partNos.LAST
            UPDATE amd_spare_parts parts
               SET nsn = nsns (indx)
             WHERE part_no = partNos (indx);
      END IF;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         mRC := amd_spare_parts_pkg.UPD_NSN_SPARE_PARTS_ERR;
         ErrorMsg (pSqlfunction      => 'select',
                   pTableName        => 'amd_nsi_parts',
                   pError_location   => 180,
                   pKey_1            => TO_CHAR (pNsi_sid));
         RAISE;
   END MakeNsnSameForAllParts;


   /*
       For a given nsn if all related parts are marked
       as deleted, then its associated nsn in the
       amd_national_stock_items should be marked as DELETED.
       For a given nsn if any related part is not marked
       DELETED and its associated nsn is marked DELETED,
       then mark the nsn as either INSERTED or UPDATED depending
       on the current action
     */
   PROCEDURE UpdateNatStkItem (pNsn      IN amd_spare_parts.nsn%TYPE,
                               pAction   IN VARCHAR2,
                               pPartNo      VARCHAR2 DEFAULT NULL)
   IS
      nsi_sid   amd_nsi_parts.nsi_sid%TYPE := NULL;

      FUNCTION NumberOfActiveParts
         RETURN NUMBER
      IS
         cnt   NUMBER := 0;
      BEGIN
         SELECT COUNT (*)
           INTO cnt
           FROM amd_nsi_parts nsi, amd_spare_parts parts
          WHERE     nsi.nsi_sid = UpdateNatStkItem.nsi_sid
                AND nsi.part_no = parts.part_no
                AND nsi.unassignment_date IS NULL
                AND parts.action_code != amd_defaults.DELETE_ACTION;

         RETURN cnt;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;                                                -- do nothing
         WHEN OTHERS
         THEN
            ErrorMsg (pSqlfunction      => 'select',
                      pTableName        => 'amd_nsi_parts',
                      pError_location   => 190,
                      pKey_1            => TO_CHAR (UpdateNatStkItem.nsi_sid));
            RAISE;
      END NumberOfActiveParts;


      FUNCTION IsNsnMarkedDeleted
         RETURN BOOLEAN
      IS
         action_code   amd_national_stock_items.action_code%TYPE := NULL;
         result        NUMBER;
      BEGIN
         SELECT action_code
           INTO action_code
           FROM amd_national_stock_items items
          WHERE items.nsi_sid = UpdateNatStkItem.nsi_sid;

         RETURN (action_code = amd_defaults.DELETE_ACTION);
      EXCEPTION
         WHEN OTHERS
         THEN
            ErrorMsg (pSqlfunction      => 'select',
                      pTableName        => 'amd_national_stock_items',
                      pError_location   => 200,
                      pKey_1            => TO_CHAR (UpdateNatStkItem.nsi_sid));
            RAISE;
      END IsNsnMarkedDeleted;
   BEGIN                                                   -- UpdateNatStkItem
      debugMsg (
            'UpdateNatStkItem('
         || pNsn
         || ', '
         || pAction
         || ', '
         || pPartNo
         || ')',
         pError_location   => 210);

     <<GetNsiSid>>
      BEGIN
         /*
             use the nsi_sid to get a row from the
             amd_national_stock_items since it is always
             better than the Nsn - even though this Nsn
             should be the current Nsn for the prime part
             and its equivalent parts.
         */
         nsi_sid := amd_utils.GetNsiSid (pNsn => pNsn);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RAISE UNABLE_TO_GET_NSI_SID_EXP;
      END GetNsiSid;

      IF pAction = amd_defaults.DELETE_ACTION
      THEN
        <<numberOfActivePartsGt0>>
         BEGIN
            IF NumberOfActiveParts () = 0
            THEN
               UPDATE amd_national_stock_items
                  SET action_code = amd_defaults.DELETE_ACTION,
                      last_update_dt = SYSDATE
                WHERE nsi_sid = UpdateNatStkItem.nsi_sid;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               ErrorMsg (
                  pSqlfunction      => 'update',
                  pTableName        => 'amd_national_stock_items',
                  pError_location   => 220,
                  pKey_1            => TO_CHAR (UpdateNatStkItem.nsi_sid));
               RAISE;
         END numberOfActivePartsGt0;
      ELSE
        /* must be an INSERT_ACTION or an UPDATE_ACTION */
        <<processInsertOrDelete>>
         BEGIN
            IF (NumberOfActiveParts () > 0 AND IsNsnMarkedDeleted ())
            THEN
               UPDATE amd_national_stock_items
                  SET action_code = pAction, last_update_dt = SYSDATE
                WHERE nsi_sid = UpdateNatStkItem.nsi_sid;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               ErrorMsg (
                  pSqlfunction      => 'update',
                  pTableName        => 'amd_national_stock_items',
                  pError_location   => 230,
                  pKey_1            => TO_CHAR (UpdateNatStkItem.nsi_sid));
               RAISE;
         END processInsertOrDelete;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         mRC := amd_spare_parts_pkg.UPDT_NATSTKITEM_ERR;
         ErrorMsg (pSqlfunction      => 'updateNatStkItem',
                   pTableName        => 'amd_national_stock_items',
                   pError_location   => 240);
         RAISE;
   END UpdateNatStkItem;


   /* 8/22/02 DSE added UpdtNsiPrimePartData to eliminate some
    * redundant code.
    */
   PROCEDURE UpdtNsiPrimePartData (
      pPrime_ind         IN amd_nsi_parts.prime_ind%TYPE,
      pNsi_sid           IN amd_national_stock_items.nsi_sid%TYPE,
      pPartNo            IN amd_national_stock_items.prime_part_no%TYPE,
      pNsn               IN amd_national_stock_items.nsn%TYPE,
      pItem_type         IN amd_national_stock_items.item_type%TYPE,
      pOrder_quantity    IN amd_national_stock_items.order_quantity%TYPE,
      pPlannerCode       IN amd_national_stock_items.planner_code%TYPE,
      pSmr_code          IN amd_national_stock_items.smr_code%TYPE,
      pMic_code_lowest   IN amd_national_stock_items.mic_code_lowest%TYPE,
      pAction_code       IN amd_national_stock_items.action_code%TYPE,
      pReturn_code       IN NUMBER,
      pMmac              IN amd_national_stock_items.mmac%TYPE)
   IS
      fedcCost   NUMBER;

      PROCEDURE verifyData
      IS
         rec   amd_national_stock_items%ROWTYPE;
         x     NUMBER := 0;
      BEGIN
         debugMsg ('verifyData', pError_location => 250);
         x := x + 1;
         rec.prime_part_no := pPartNo;
         x := x + 1;
         rec.fedc_cost := fedcCost;
         x := x + 1;
         rec.nsn := pNsn;
         x := x + 1;
         rec.item_type := pItem_type;
         x := x + 1;
         rec.order_quantity := pOrder_quantity;
         x := x + 1;
         rec.planner_code := pPlannerCode;
         x := x + 1;
         rec.smr_code := pSmr_Code;
         x := x + 1;
         rec.mic_code_lowest := pMic_code_lowest;
         x := x + 1;
         rec.last_update_dt := SYSDATE;
         x := x + 1;
         rec.mmac := pMmac;
         x := x + 1;
         rec.mtbdr := mMtbdr;
         x := x + 1;
         rec.mtbdr_computed := mMtbdr_computed;
         x := x + 1;
         rec.qpei_weighted := mQpeiWeighted;

         x := x + 1;
         rec.condemn_avg_cleaned := mCondemnAvgCleaned;
         x := x + 1;
         rec.criticality_cleaned := mCriticalityCleaned;
         x := x + 1;
         rec.mtbdr_cleaned := mMtbdrCleaned;
         x := x + 1;
         rec.nrts_avg_cleaned := mNrtsAvgCleaned;
         x := x + 1;
         rec.cost_to_repair_off_base_cleand := mCostToRepairOffBaseCleand;
         x := x + 1;
         rec.time_to_repair_off_base_cleand := mTimeToRepairOffBaseCleand;
         x := x + 1;
         rec.amc_demand := mAmcDemand;
         x := x + 1;
         rec.amc_demand_cleaned := mAmcDemandCleaned;
         x := x + 1;
         rec.wesm_indicator := mWesmIndicator;
         x := x + 1;
         rec.order_lead_time_cleaned := mOrderLeadTimeCleaned;
         x := x + 1;
         rec.planner_code_cleaned := mPlannerCodeCleaned;
         x := x + 1;
         rec.rts_avg_cleaned := mRtsAvgCleaned;
         x := x + 1;
         rec.smr_code_cleaned := mSmrCodeCleaned;
         x := x + 1;
         rec.unit_cost_cleaned := mUnitCostCleaned;
         x := x + 1;
         rec.condemn_avg := mCondemnAvg;
         x := x + 1;
         rec.criticality := mCriticality;
         x := x + 1;
         rec.nrts_avg := mNrtsAvg;
         x := x + 1;
         rec.rts_avg := mRtsAvg;
         x := x + 1;
         rec.cost_to_repair_off_base := mCostToRepairOffBase;
         x := x + 1;
         rec.time_to_repair_off_base := mTimeToRepairOffBase;
         x := x + 1;
         rec.action_code := pAction_code;
      EXCEPTION
         WHEN OTHERS
         THEN
            ErrorMsg (pSqlfunction      => 'verifyData',
                      pTableName        => 'amd_national_stock_items',
                      pError_location   => 260);
            RAISE;
      END verifyData;

      PROCEDURE doUpdate (planner_code_cleaned   IN VARCHAR2,
                          planner_code           IN VARCHAR2)
      IS
         criticality_changed             amd_national_stock_items.CRITICALITY_CHANGED%TYPE
            := getCriticalityChangedInd (pNsi_sid);
         nrts_avg_changed                amd_national_stock_items.NRTS_AVG_CHANGED%TYPE
                                            := getNrtsAvgChangedInd (pNsi_sid);
         rts_avg_changed                 amd_national_stock_items.RTS_AVG_CHANGED%TYPE
                                            := getRtsAvgChangedInd (pNsi_sid);
         condemn_avg_changed             amd_national_stock_items.CONDEMN_AVG_CHANGED%TYPE
            := getCondemnAvgChangedInd (pNsi_sid);
         cost_to_repair_off_base_chged   amd_national_stock_items.COST_TO_REPAIR_OFF_BASE_CHGED%TYPE
            := getCostToRepairOffBaseChgedInd (pNsi_sid);
         time_to_repair_off_base_chged   amd_national_stock_items.time_to_repair_off_base_chged%TYPE
            := getTimeToRepairOffBaseChgedInd (PNsi_sid);

         PROCEDURE deleteAnyRblPairs
         IS
         BEGIN
            DELETE FROM amd_rbl_pairs
                  WHERE    (    old_nsn IN (SELECT nsn
                                              FROM amd_national_stock_items
                                             WHERE nsi_sid = pNsi_sid)
                            AND old_nsn <> pNsn)
                        OR (    new_nsn IN (SELECT nsn
                                              FROM amd_national_stock_items
                                             WHERE nsi_sid = pNsi_sid)
                            AND new_nsn <> pNsn);
         EXCEPTION
            WHEN OTHERS
            THEN
               ErrorMsg (pSqlfunction      => 'deleteAnyRblPairs',
                         pTableName        => 'amd_rbl_pairs',
                         pError_location   => 267,
                         pKey_1            => planner_code_cleaned,
                         pKey_2            => planner_code,
                         pKey_3            => TO_CHAR (pNsi_sid));
               RAISE;
         END deleteAnyRblPairs;
      BEGIN
         debugMsg ('doUpdate', pError_location => 270);

         deleteAnyRblPairs;

         UPDATE amd_national_stock_items
            SET criticality_changed = doUpdate.criticality_changed,
                nrts_avg_changed = doUpdate.nrts_avg_changed,
                rts_avg_changed = doUpdate.rts_avg_changed,
                condemn_avg_changed = doUpdate.condemn_avg_changed,
                cost_to_repair_off_base_chged =
                   doUpdate.cost_to_repair_off_base_chged,
                time_to_repair_off_base_chged =
                   doUpdate.time_to_repair_off_base_chged,
                prime_part_no = pPartNo,
                fedc_cost = fedcCost,
                nsn = pNsn,
                item_type = pItem_type,
                order_quantity = pOrder_quantity,
                planner_code = doUpdate.planner_code,
                smr_code = pSmr_code,
                mic_code_lowest = pMic_code_lowest,
                last_update_dt = SYSDATE,
                mmac = pMmac,
                mtbdr = mMtbdr,
                mtbdr_computed = mMtbdr_computed,
                qpei_weighted = mQpeiWeighted,
                condemn_avg_cleaned = mCondemnAvgCleaned,
                criticality_cleaned = mCriticalityCleaned,
                mtbdr_cleaned = mMtbdrCleaned,
                nrts_avg_cleaned = mNrtsAvgCleaned,
                cost_to_repair_off_base_cleand = mCostToRepairOffBaseCleand,
                time_to_repair_off_base_cleand = mTimeToRepairOffBaseCleand,
                amc_demand = mAmcDemand,
                amc_demand_cleaned = mAmcDemandCleaned,
                wesm_indicator = mWesmIndicator,
                order_lead_time_cleaned = mOrderLeadTimeCleaned,
                planner_code_cleaned = doUpdate.planner_code_cleaned,
                rts_avg_cleaned = mRtsAvgCleaned,
                smr_code_cleaned = mSmrCodeCleaned,
                unit_cost_cleaned = mUnitCostCleaned,
                condemn_avg = mCondemnAvg,
                criticality = mCriticality,
                nrts_avg = mNrtsAvg,
                rts_avg = mRtsAvg,
                cost_to_repair_off_base = mCostToRepairOffBase,
                time_to_repair_off_base = mTimeToRepairOffBase,
                action_code = pAction_code
          WHERE nsi_sid = pNsi_sid;
      EXCEPTION
         WHEN OTHERS
         THEN
            ErrorMsg (pSqlfunction      => 'doUpdate',
                      pTableName        => 'amd_national_stock_items',
                      pError_location   => 275,
                      pKey_1            => planner_code_cleaned,
                      pKey_2            => planner_code,
                      pKey_3            => TO_CHAR (pNsi_sid));
            RAISE;
      END doUpdate;
   BEGIN
      debugMsg ('UpdtNsiPrimePartData', pError_location => 280);

      IF (IsPrimePart (pPrime_ind))
      THEN
         fedcCost := getFedcCost (pPartNo);

         verifyData;


         BEGIN
            doUpdate (planner_code_cleaned   => mPlannerCodeCleaned,
                      planner_code           => pPlannerCode);
         EXCEPTION
            WHEN OTHERS
            THEN
               IF SQLCODE = -2291
               THEN
                 <<constraintError>>
                  DECLARE
                     msg            VARCHAR2 (50);
                     planner_code   amd_planners.planner_code%TYPE;
                  BEGIN
                     -- figurr out which foreign key does not have a parent
                     IF INSTR (SQLERRM, 'FK04') > 0
                     THEN
                        IF amd_utils.isPartConsumable (pPartNo)
                        THEN
                           mPlannerCodeCleaned :=
                              amd_defaults.CONSUMABLE_PLANNER_CODE;
                        ELSIF amd_utils.isPartRepairable (pPartNo)
                        THEN
                           mPlannerCodeCleaned :=
                              amd_defaults.REPAIRABLE_PLANNER_CODE;
                        ELSE
                           mPlannerCodeCleaned := NULL;
                        END IF;

                        doUpdate (
                           planner_code_cleaned   => mPlannerCodeCleaned,
                           planner_code           => pPlannerCode);
                        RETURN;
                     ELSIF INSTR (SQLERRM, 'FK03') > 0
                     THEN
                        IF amd_utils.isPartConsumable (pPartNo)
                        THEN
                           planner_code :=
                              amd_defaults.CONSUMABLE_PLANNER_CODE;
                        ELSIF amd_utils.isPartRepairable (pPartNo)
                        THEN
                           planner_code :=
                              amd_defaults.REPAIRABLE_PLANNER_CODE;
                        ELSE
                           planner_code := NULL;
                        END IF;

                        doUpdate (
                           planner_code_cleaned   => mPlannerCodeCleaned,
                           planner_code           => planner_code);
                        RETURN;
                     ELSIF INSTR (SQLERRM, 'FK02') > 0
                     THEN
                        msg := 'no parent for partNo=' || pPartNo;
                     ELSIF INSTR (SQLERRM, 'FK01') > 0
                     THEN
                        msg := 'no parent for nsn=' || pNsn;
                     ELSE
                        msg := 'Unknown';
                     END IF;

                     mRC := pReturn_code;
                     ErrorMsg (pSqlfunction      => 'UpdtNsiPrimePartData',
                               pTableName        => 'amd_national_stock_items',
                               pError_location   => 290,
                               pKey_1            => pPartNo,
                               pKey_2            => TO_CHAR (pNsi_sid),
                               pKey_3            => msg);
                     RAISE;
                  END constraintError;
               ELSIF SQLCODE = -2292
               THEN
                  DECLARE
                     TYPE bssmrvt_recs_type IS TABLE OF amd_bssm_rvt%ROWTYPE;

                     bssmrvt_recs   bssmrvt_recs_type;
                     cur_nsn        amd_bssm_rvt.nsn%TYPE;

                     CURSOR bssmRvts
                     IS
                        SELECT *
                          FROM amd_bssm_rvt
                         WHERE nsn = cur_nsn;
                  BEGIN
                     SELECT nsn
                       INTO cur_nsn
                       FROM amd_national_stock_items
                      WHERE nsi_sid = pNsi_Sid;

                     OPEN bssmRvts;

                     FETCH bssmRvts BULK COLLECT INTO bssmrvt_recs;

                     CLOSE bssmRvts;

                     IF bssmrvt_recs.COUNT > 0
                     THEN
                        BEGIN
                           FOR indx IN bssmrvt_recs.FIRST ..
                                       bssmrvt_recs.LAST
                           LOOP
                              DELETE amd_bssm_rvt
                               WHERE nsn = bssmrvt_recs (indx).nsn;

                              bssmrvt_recs (indx).nsn := pNsn;
                              bssmrvt_recs (indx).last_update_dt := SYSDATE;
                              bssmrvt_recs (indx).updated_by := USER;
                           END LOOP;
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              ErrorMsg (
                                 pSqlfunction      => 'fix_amd_bssm_rvt',
                                 pTableName        => 'amd_bssm_rvt',
                                 pError_location   => 292,
                                 pKey_1            => pPartNo,
                                 pKey_2            => TO_CHAR (pNsi_sid),
                                 pKey_3            => 'nsn ' || pNsn);
                              RAISE;
                        END;
                     END IF;

                     BEGIN
                        doUpdate (
                           planner_code_cleaned   => mPlannerCodeCleaned,
                           planner_code           => pPlannerCode);
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           ErrorMsg (
                              pSqlfunction      => 'fix_amd_bssm_rvt',
                              pTableName        => 'amd_bssm_rvt',
                              pError_location   => 294,
                              pKey_1            => pPartNo,
                              pKey_2            => 'nsn ' || pNsn,
                              pKey_3            =>    'plannerCodeCleaned='
                                                   || mPlannerCodeCleaned);
                           RAISE;
                     END;

                     IF bssmrvt_recs.COUNT > 0
                     THEN
                        BEGIN
                           FORALL indx
                               IN bssmrvt_recs.FIRST .. bssmrvt_recs.LAST
                              INSERT INTO amd_bssm_rvt
                                   VALUES bssmrvt_recs (indx);
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              ErrorMsg (
                                 pSqlfunction      => 'fix_amd_bssm_rvt',
                                 pTableName        => 'amd_bssm_rvt',
                                 pError_location   => 296,
                                 pKey_1            => pPartNo,
                                 pKey_2            => 'nsn ' || pNsn,
                                 pKey_3            =>    'plannerCodeCleaned='
                                                      || mPlannerCodeCleaned);
                              RAISE;
                        END;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        ErrorMsg (
                           pSqlfunction      => 'fix_amd_bssm_rvt',
                           pTableName        => 'amd_bssm_rvt',
                           pError_location   => 298,
                           pKey_1            => pPartNo,
                           pKey_2            => TO_CHAR (pNsi_sid),
                           pKey_3            =>    'plannerCodeCleaned='
                                                || mPlannerCodeCleaned);
                        RAISE;
                  END fix_amd_bssm_rvt;
               ELSE
                  mRC := pReturn_code;
                  ErrorMsg (
                     pSqlfunction      => 'UpdtNsiPrimePartData',
                     pTableName        => 'amd_national_stock_items',
                     pError_location   => 300,
                     pKey_1            => pPartNo,
                     pKey_2            => TO_CHAR (pNsi_sid),
                     pKey_3            =>    'plannerCodeCleaned='
                                          || mPlannerCodeCleaned);
                  RAISE;
               END IF;
         END;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         mRC := pReturn_code;
         ErrorMsg (pSqlfunction      => 'UpdtNsiPrimePartData',
                   pTableName        => 'amd_national_stock_items',
                   pError_location   => 310,
                   pKey_1            => pPartNo,
                   pKey_2            => TO_CHAR (pNsi_sid),
                   pKey_3            => 'nsn=' || pNsn);
         RAISE;
   END UpdtNsiPrimePartData;


   PROCEDURE InsertNatStkItem (
      pNsi_sid              OUT amd_national_stock_items.nsi_sid%TYPE,
      pNsn               IN     amd_spare_parts.nsn%TYPE,
      pItem_type         IN     amd_national_stock_items.item_type%TYPE,
      pOrder_quantity    IN     amd_national_stock_items.order_quantity%TYPE,
      pPlanner_code      IN     amd_national_stock_items.planner_code%TYPE,
      pSmr_code          IN     amd_national_stock_items.smr_code%TYPE,
      pTactical          IN     amd_national_stock_items.tactical%TYPE,
      pMic_code_lowest   IN     amd_national_stock_items.mic_code_lowest%TYPE,
      pMmac              IN     amd_national_stock_items.mmac%TYPE)
   IS
      nsiGroupSid   NUMBER;

      FUNCTION GetNsiSid
         RETURN amd_national_stock_items.nsi_sid%TYPE
      IS
         nsi_sid   amd_national_stock_items.nsi_sid%TYPE := NULL;
      BEGIN
         SELECT amd_nsi_sid_seq.CURRVAL INTO nsi_sid FROM DUAL;

         RETURN nsi_sid;
      END GetNsiSid;
   BEGIN                                                   -- InsertNatStkItem
      debugMsg ('InsertNatStkItem', pError_location => 320);
      nsiGroupSid := amd_default_effectivity_pkg.NewGroup;

      BEGIN
         INSERT
           INTO AMD_NATIONAL_STOCK_ITEMS (nsn,
                                          add_increment_cleaned,
                                          amc_base_stock_cleaned,
                                          amc_days_experience_cleaned,
                                          amc_demand,
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
                                          time_to_repair_off_base,
                                          wesm_indicator)
         VALUES (NULL,                                                  -- nsn
                 Amd_Clean_Data.GetAddIncrement (pNsn),
                 Amd_Clean_Data.GetAmcBaseStock (pNsn),
                 Amd_Clean_Data.GetAmcDaysExperience (pNsn),
                 mAmcDemand,
                 mAmcDemandCleaned,
                 Amd_Clean_Data.GetCapabilityRequirement (pNsn),
                 mCriticalityCleaned,
                 Amd_Defaults.DISTRIB_UOM,
                 Amd_Clean_Data.GetDlaDemand (pNsn),
                 Amd_Clean_Data.GetCurrentBackorder (pNsn),
                 Amd_Clean_Data.GetFedcCost (pNsn),
                 pItem_type,
                 Amd_Clean_Data.GetItemType (pNsn),
                 Amd_Clean_Data.GetMicCodeLowest (pNsn),
                 mMtbdrCleaned,
                 Amd_Clean_Data.GetNomenclature (pNsn),
                 mOrderLeadTimeCleaned,
                 pOrder_Quantity,
                 Amd_Defaults.ORDER_QUANTITY,
                 Amd_Clean_Data.GetOrderUom (pNsn),
                 pPlanner_code,
                 mPlannerCodeCleaned,
                 NULL,                                        -- prime_part_no
                 Amd_Defaults.QPEI_WEIGHTED,
                 Amd_Clean_Data.GetRuInd (pNsn),
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
                 Amd_Clean_Data.GetTimeToRepairOnBaseAvg (pNsn),
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
                 mTimeToRepairOffBase,
                 mWesmIndicator);
      EXCEPTION
         WHEN OTHERS
         THEN
            mRC := amd_spare_parts_pkg.CREATE_NATSTKITEM_ERR;
            ErrorMsg (pSqlfunction      => 'insert',
                      pTableName        => 'amd_national_stock_items',
                      pError_location   => 330);
            RAISE;
      END InsertNsi;

      pNsi_sid := GetNsiSid ();
   EXCEPTION
      WHEN OTHERS
      THEN
         mRC := amd_spare_parts_pkg.CREATE_NATSTKITEM_ERR;
         ErrorMsg (pSqlfunction      => 'insert',
                   pTableName        => 'amd_nsi_groups',
                   pError_location   => 340);
         RAISE;
   END InsertNatStkItem;


   PROCEDURE ChgCurNsn2TempNsn (pNsiSid IN amd_nsns.nsi_sid%TYPE)
   IS
   BEGIN
      debugMsg ('ChgCurNsn2TempNsn(' || pNsiSid || ')',
                pError_location   => 350);

      UPDATE amd_nsns
         SET nsn_type = amd_spare_parts_pkg.TEMPORARY_NSN
       WHERE nsi_sid = pNsiSid AND nsn_type = amd_spare_parts_pkg.CURRENT_NSN;
   EXCEPTION
      WHEN OTHERS
      THEN
         mRC := amd_spare_parts_pkg.UNABLE_TO_CHG_NSN_TYPE;
         ErrorMsg (pSqlfunction      => 'update',
                   pTableName        => 'amd_nsns',
                   pError_location   => 360,
                   pKey_1            => TO_CHAR (pNsiSid));
         RAISE;
   END ChgCurNsn2TempNsn;


   PROCEDURE InsertAmdNsn (pNsi_sid    IN amd_nsns.nsi_sid%TYPE,
                           pNsn        IN amd_nsns.nsn%TYPE,
                           pNsn_type   IN amd_nsns.nsn_type%TYPE)
   IS
   BEGIN
      debugMsg (
         'InsertAmdNsn(' || pNsi_sid || ', ' || pNsn || ', ' || pNsn_type,
         pError_location   => 370);

      IF pNsn_type = amd_spare_parts_pkg.CURRENT_NSN
      THEN
         ChgCurNsn2TempNsn (pNsiSid => pNsi_sid);
      END IF;

      INSERT INTO amd_nsns (nsn,
                            nsn_type,
                            nsi_sid,
                            creation_date)
           VALUES (pNsn,
                   pNsn_type,
                   pNsi_sid,
                   SYSDATE);
   EXCEPTION
      WHEN OTHERS
      THEN
         mRC := amd_spare_parts_pkg.UNABLE_TO_INSERT_AMD_NSNS;
         ErrorMsg (pSqlfunction      => 'insert',
                   pTableName        => 'amd_nsns',
                   pError_location   => 380,
                   pKey_1            => TO_CHAR (pNsi_Sid),
                   pKey_2            => pNsn,
                   pKey_3            => pNsn_type);
         RAISE;
   END InsertAmdNsn;


   PROCEDURE UpdateAmdNsn (pNsi_sid    IN amd_nsns.nsi_sid%TYPE,
                           pNsn        IN amd_nsns.nsn%TYPE,
                           pNsn_type   IN amd_nsns.nsn_type%TYPE)
   IS
   BEGIN
      debugMsg (
            'UpdateAmdNsn('
         || pNsi_sid
         || ', '
         || pNsn
         || ', '
         || pNsn_type
         || ')',
         pError_location   => 390);

      IF pNsn_type = amd_spare_parts_pkg.CURRENT_NSN
      THEN
         ChgCurNsn2TempNsn (pNsiSid => pNsi_sid);
      END IF;

      UPDATE amd_nsns
         SET nsn_type = pNsn_type
       WHERE nsi_sid = pNsi_sid AND nsn = pNsn;
   EXCEPTION
      WHEN OTHERS
      THEN
         mRC := amd_spare_parts_pkg.UNABLE_TO_INSERT_AMD_NSNS;
         ErrorMsg (pSqlfunction      => 'update',
                   pTableName        => 'amd_nsns',
                   pError_location   => 400,
                   pKey_1            => TO_CHAR (pNsi_Sid),
                   pKey_2            => pNsn);
         RAISE;
   END UpdateAmdNsn;


   PROCEDURE CreateNationalStockItem (
      pNsi_sid              OUT amd_national_stock_items.nsi_sid%TYPE,
      pNsn               IN     amd_spare_parts.nsn%TYPE,
      pItem_type         IN     amd_national_stock_items.item_type%TYPE,
      pOrder_quantity    IN     amd_national_stock_items.order_quantity%TYPE,
      pPlanner_code      IN     amd_national_stock_items.planner_code%TYPE,
      pSmr_code          IN     amd_national_stock_items.smr_code%TYPE,
      pTactical          IN     amd_national_stock_items.tactical%TYPE,
      pMic_code_lowest   IN     amd_national_stock_items.mic_code_lowest%TYPE,
      pNsn_type          IN     amd_nsns.nsn_type%TYPE,
      pMmac              IN     amd_national_stock_items.mmac%TYPE)
   IS
      result   NUMBER := SUCCESS;
   BEGIN
      InsertNatStkItem (pNsi_sid           => pNsi_sid,
                        pNsn               => pNsn,
                        pItem_type         => pItem_type,
                        pOrder_quantity    => pOrder_quantity,
                        pPlanner_code      => pPlanner_code,
                        pSmr_code          => pSmr_code,
                        pTactical          => pTactical,
                        pMic_code_lowest   => pMic_code_lowest,
                        pMmac              => pMmac);

      amd_default_effectivity_pkg.SetNsiEffects (pNsi_sid);

      IF pNsn_type = amd_spare_parts_pkg.CURRENT_NSN
      THEN
         amd_spare_parts_pkg.ChgCurNsn2TempNsn (pNsiSid => pNsi_sid);
      END IF;

      InsertAmdNsn (pNsi_sid => pNsi_sid, pNsn => pNsn, pNsn_type => pNsn_type);
   END CreateNationalStockItem;

   -- forward declare the old insertRow method, which is now private, so it can be used in
   -- the new public insertRow method
   FUNCTION InsertRow (pPart_no                   IN VARCHAR2,
                       pMfgr                      IN VARCHAR2,
                       pDate_icp                  IN DATE,
                       pDisposal_cost             IN NUMBER,
                       pErc                       IN VARCHAR2,
                       pIcp_ind                   IN VARCHAR2,
                       pNomenclature              IN VARCHAR2,
                       pOrder_lead_time           IN NUMBER,
                       pOrder_quantity            IN NUMBER,
                       pOrder_uom                 IN VARCHAR2,
                       pPrime_ind                 IN VARCHAR2,
                       pScrap_value               IN NUMBER,
                       pSerial_flag               IN VARCHAR2,
                       pShelf_life                IN NUMBER,
                       pUnit_cost                 IN NUMBER,
                       pUnit_volume               IN NUMBER,
                       pNsn                       IN VARCHAR2,
                       pNsn_type                  IN VARCHAR2,
                       pItem_type                 IN VARCHAR2,
                       pSmr_code                  IN VARCHAR2,
                       pPlanner_code              IN VARCHAR2,
                       pMic_code_lowest           IN VARCHAR2,
                       pAcquisition_advice_code   IN VARCHAR2,
                       pMmac                      IN VARCHAR2,
                       pUnitOfIssue               IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION InsertRow (
      pPart_no                     IN VARCHAR2,
      pMfgr                        IN VARCHAR2,
      pDate_icp                    IN DATE,
      pDisposal_cost               IN NUMBER,
      pErc                         IN VARCHAR2,
      pIcp_ind                     IN VARCHAR2,
      pNomenclature                IN VARCHAR2,
      pOrder_lead_time             IN NUMBER,
      pOrder_quantity              IN NUMBER,
      pOrder_uom                   IN VARCHAR2,
      pPrime_ind                   IN VARCHAR2,
      pScrap_value                 IN NUMBER,
      pSerial_flag                 IN VARCHAR2,
      pShelf_life                  IN NUMBER,
      pUnit_cost                   IN NUMBER,
      pUnit_volume                 IN NUMBER,
      pNsn                         IN VARCHAR2,
      pNsn_type                    IN VARCHAR2,
      pItem_type                   IN VARCHAR2,
      pSmr_code                    IN VARCHAR2,
      pPlanner_code                IN VARCHAR2,
      pMic_code_lowest             IN VARCHAR2,
      pAcquisition_advice_code     IN VARCHAR2,
      pMmac                        IN VARCHAR2,
      pUnitOfIssue                 IN VARCHAR2,
      pMtbdr                       IN NUMBER,
      pMtbdr_computed              IN NUMBER,
      pQpeiWeighted                IN NUMBER,
      pCondemnAvgCleaned           IN NUMBER,
      pCriticalityCleaned          IN NUMBER,
      pMtbdrCleaned                IN NUMBER,
      pNrtsAvgCleaned              IN NUMBER,
      pCosToRepairOffBaseCleand    IN NUMBER,
      pTimeToRepairOffBaseCleand   IN NUMBER,
      pOrderLeadTimeCleaned        IN NUMBER,
      pPlannerCodeCleaned          IN amd_national_stock_items.planner_code_cleaned%TYPE,
      pRtsAvgCleaned               IN NUMBER,
      pSmrCodeCleaned              IN amd_national_stock_items.smr_code_cleaned%TYPE,
      pUnitCostCleaned             IN NUMBER,
      pCondemnAvg                  IN NUMBER,
      pCriticality                 IN NUMBER,
      pNrtsAvg                     IN NUMBER,
      pRtsAvg                      IN NUMBER,
      pCostToRepairOffBase         IN NUMBER,
      pTimeToRepairOffBase         IN NUMBER,
      pAmcDemand                   IN NUMBER,
      pAmcDemandCleaned            IN NUMBER,
      pWesmIndicator               IN VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
      -- By overriding the insertRow and updateRow routines all that needs to be done
      -- is to set the member variables to the values passed in and then invoke
      -- the old insertRow method, which is now private, That way I don't have to pass parameters just get the data
      -- from these global member variables.
      mArgs :=
            'insertRow('
         || pPart_no
         || ', '
         || pMfgr
         || ', '
         || pDate_icp
         || ', '
         || pDisposal_cost
         || ', '
         || pErc
         || ', '
         || pIcp_ind
         || ', '
         || pNomenclature
         || ', '
         || pOrder_lead_time
         || ', '
         || pOrder_quantity
         || ', '
         || pOrder_uom
         || ', '
         || pPrime_ind
         || ', '
         || pScrap_value
         || ', '
         || pSerial_flag
         || ', '
         || pShelf_life
         || ', '
         || pUnit_cost
         || ', '
         || pUnit_volume
         || ', '
         || pNsn
         || ', '
         || pNsn_type
         || ', '
         || pItem_type
         || ', '
         || pSmr_code
         || ', '
         || pPlanner_code
         || ', '
         || pMic_code_lowest
         || ', '
         || pAcquisition_advice_code
         || ', '
         || pMmac
         || ', '
         || pUnitOfIssue
         || ', '
         || pMtbdr
         || ', '
         || pMtbdr_computed
         || ', '
         || pQpeiWeighted
         || ', '
         || pCondemnAvgCleaned
         || ', '
         || pCriticalityCleaned
         || ', '
         || pMtbdrCleaned
         || ', '
         || pNrtsAvgCleaned
         || ', '
         || pCosToRepairOffBaseCleand
         || ', '
         || pTimeToRepairOffBaseCleand
         || ', '
         || pOrderLeadTimeCleaned
         || ', '
         || pPlannerCodeCleaned
         || ', '
         || pRtsAvgCleaned
         || ', '
         || pSmrCodeCleaned
         || ', '
         || pUnitCostCleaned
         || ', '
         || pCondemnAvg
         || ', '
         || pCriticality
         || ', '
         || pNrtsAvg
         || ', '
         || pRtsAvg
         || ', '
         || pAmcDemand
         || ', '
         || pAmcDemandCleaned
         || ','
         || pWesmIndicator
         || ')';
      mMtbdr := pMtbdr;
      mMtbdr_computed := pMtbdr_computed;
      mQpeiWeighted := pQpeiWeighted;
      mCondemnAvgCleaned := pCondemnAvgCleaned;
      mCriticalityCleaned := pCriticalityCleaned;
      mMtbdrCleaned := pMtbdrCleaned;
      mNrtsAvgCleaned := pNrtsAvgCleaned;
      mCostToRepairOffBaseCleand := pCosToRepairOffBaseCleand;
      mTimeToRepairOffBaseCleand := pTimeToRepairOffBaseCleand;
      mAmcDemand := pAmcDemand;
      mAmcDemandCleaned := pAmcDemandCleaned;
      mWesmIndicator := pWesmIndicator;
      mOrderLeadTimeCleaned := pOrderLeadTimeCleaned;
      mPlannerCodeCleaned := pPlannerCodeCleaned;
      mRtsAvgCleaned := pRtsAvgCleaned;
      mSmrCodeCleaned := pSmrCodeCleaned;
      mUnitCostCleaned := pUnitCostCleaned;
      mCondemnAvg := pCondemnAvg;
      mCriticality := pCriticality;
      mNrtsAvg := pNrtsAvg;
      mRtsAvg := pRtsAvg;
      mCostToRepairOffBase := pCostToRepairOffBase;
      mTimeToRepairOffBase := pTimeToRepairOffBase;

      RETURN InsertRow (pPart_no,
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
                        pUnitOfIssue);
   END InsertRow;

   -- forward declare the old updateRow method, which is now private, so it can be used in
   -- the new public updateRow method
   FUNCTION UpdateRow (pPart_no                   IN VARCHAR2,
                       pMfgr                      IN VARCHAR2,
                       pDate_icp                  IN DATE,
                       pDisposal_cost             IN NUMBER,
                       pErc                       IN VARCHAR2,
                       pIcp_ind                   IN VARCHAR2,
                       pNomenclature              IN VARCHAR2,
                       pOrder_lead_time           IN NUMBER,
                       pOrder_quantity            IN NUMBER,
                       pOrder_uom                 IN VARCHAR2,
                       pPrime_ind                 IN VARCHAR2,
                       pScrap_value               IN NUMBER,
                       pSerial_flag               IN VARCHAR2,
                       pShelf_life                IN NUMBER,
                       pUnit_cost                 IN NUMBER,
                       pUnit_volume               IN NUMBER,
                       pNsn                       IN VARCHAR2,
                       pNsn_type                  IN VARCHAR2,
                       pItem_type                 IN VARCHAR2,
                       pSmr_code                  IN VARCHAR2,
                       pPlanner_code              IN VARCHAR2,
                       pMic_code_lowest           IN VARCHAR2,
                       pAcquisition_advice_code   IN VARCHAR2,
                       pMmac                      IN VARCHAR2,
                       pUnitOfIssue               IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION UpdateRow (
      pPart_no                     IN VARCHAR2,
      pMfgr                        IN VARCHAR2,
      pDate_icp                    IN DATE,
      pDisposal_cost               IN NUMBER,
      pErc                         IN VARCHAR2,
      pIcp_ind                     IN VARCHAR2,
      pNomenclature                IN VARCHAR2,
      pOrder_lead_time             IN NUMBER,
      pOrder_quantity              IN NUMBER,
      pOrder_uom                   IN VARCHAR2,
      pPrime_ind                   IN VARCHAR2,
      pScrap_value                 IN NUMBER,
      pSerial_flag                 IN VARCHAR2,
      pShelf_life                  IN NUMBER,
      pUnit_cost                   IN NUMBER,
      pUnit_volume                 IN NUMBER,
      pNsn                         IN VARCHAR2,
      pNsn_type                    IN VARCHAR2,
      pItem_type                   IN VARCHAR2,
      pSmr_code                    IN VARCHAR2,
      pPlanner_code                IN VARCHAR2,
      pMic_code_lowest             IN VARCHAR2,
      pAcquisition_advice_code     IN VARCHAR2,
      pMmac                        IN VARCHAR2,
      pUnitOfIssue                 IN VARCHAR2,
      pMtbdr                       IN NUMBER,
      pMtbdr_computed              IN NUMBER,
      pQpeiWeighted                IN NUMBER,
      pCondemnAvgCleaned           IN NUMBER,
      pCriticalityCleaned          IN NUMBER,
      pMtbdrCleaned                IN NUMBER,
      pNrtsAvgCleaned              IN NUMBER,
      pCosToRepairOffBaseCleand    IN NUMBER,
      pTimeToRepairOffBaseCleand   IN NUMBER,
      pOrderLeadTimeCleaned        IN NUMBER,
      pPlannerCodeCleaned          IN amd_national_stock_items.planner_code_cleaned%TYPE,
      pRtsAvgCleaned               IN NUMBER,
      pSmrCodeCleaned              IN amd_national_stock_items.smr_code_cleaned%TYPE,
      pUnitCostCleaned             IN NUMBER,
      pCondemnAvg                  IN NUMBER,
      pCriticality                 IN NUMBER,
      pNrtsAvg                     IN NUMBER,
      pRtsAvg                      IN NUMBER,
      pCostToRepairOffBase         IN NUMBER,
      pTimeToRepairOffBase         IN NUMBER,
      pAmcDemand                   IN NUMBER,
      pAmcDemandCleaned            IN NUMBER,
      pWesmIndicator               IN VARCHAR2)
      RETURN NUMBER
   IS
      lineNo   NUMBER := 0;
      result   NUMBER;
   BEGIN
      -- By overriding the updateRow andinsertRow routines all that needs to be done
      -- is to set the member variables to the values passed in and then invoke
      -- the old updateRow method, which is now private, That way I don't have to pass parameters just get the data
      -- from these global member variables.
      mArgs :=
            'UpdateRow('
         || pPart_no
         || ', '
         || pMfgr
         || ', '
         || pDate_icp
         || ', '
         || pDisposal_cost
         || ', '
         || pErc
         || ', '
         || pIcp_ind
         || ', '
         || pNomenclature
         || ', '
         || pOrder_lead_time
         || ', '
         || pOrder_quantity
         || ', '
         || pOrder_uom
         || ', '
         || pPrime_ind
         || ', '
         || pScrap_value
         || ', '
         || pSerial_flag
         || ', '
         || pShelf_life
         || ', '
         || pUnit_cost
         || ', '
         || pUnit_volume
         || ', '
         || pNsn
         || ', '
         || pNsn_type
         || ', '
         || pItem_type
         || ', '
         || pSmr_code
         || ', '
         || pPlanner_code
         || ', '
         || pMic_code_lowest
         || ', '
         || pAcquisition_advice_code
         || ', '
         || pMmac
         || ', '
         || pUnitOfIssue
         || ', '
         || pMtbdr
         || ', '
         || pMtbdr_computed
         || ', '
         || pQpeiWeighted
         || ', '
         || pCondemnAvgCleaned
         || ', '
         || pCriticalityCleaned
         || ', '
         || pMtbdrCleaned
         || ', '
         || pNrtsAvgCleaned
         || ', '
         || pCosToRepairOffBaseCleand
         || ', '
         || pTimeToRepairOffBaseCleand
         || ', '
         || pOrderLeadTimeCleaned
         || ', '
         || pPlannerCodeCleaned
         || ', '
         || pRtsAvgCleaned
         || ', '
         || pSmrCodeCleaned
         || ', '
         || pUnitCostCleaned
         || ', '
         || pCondemnAvg
         || ', '
         || pCriticality
         || ', '
         || pNrtsAvg
         || ', '
         || pRtsAvg
         || ', '
         || pCostToRepairOffBase
         || ', '
         || pTimeToRepairOffBase
         || ', '
         || pAmcDemand
         || ', '
         || pAmcDemandCleaned
         || ')';
      lineNo := lineNo + 1;
      mMtbdr := pMtbdr;
      lineNo := lineNo + 1;
      mMtbdr_computed := pMtbdr_computed;
      lineNo := lineNo + 1;
      mQpeiWeighted := pQpeiWeighted;
      lineNo := lineNo + 1;
      mCondemnAvgCleaned := pCondemnAvgCleaned;
      lineNo := lineNo + 1;
      mCriticalityCleaned := pCriticalityCleaned;
      lineNo := lineNo + 1;
      mMtbdrCleaned := pMtbdrCleaned;
      lineNo := lineNo + 1;
      mNrtsAvgCleaned := pNrtsAvgCleaned;
      lineNo := lineNo + 1;
      mCostToRepairOffBaseCleand := pCosToRepairOffBaseCleand;
      lineNo := lineNo + 1;
      mTimeToRepairOffBaseCleand := pTimeToRepairOffBaseCleand;
      lineNo := lineNo + 1;
      mAmcDemand := pAmcDemand;
      lineNo := lineNo + 1;
      mAmcDemandCleaned := pAmcDemandCleaned;
      lineNo := lineNo + 1;
      mWesmIndicator := pWesmIndicator;
      lineNo := lineNo + 1;
      mOrderLeadTimeCleaned := pOrderLeadTimeCleaned;
      lineNo := lineNo + 1;
      mPlannerCodeCleaned := pPlannerCodeCleaned;
      lineNo := lineNo + 1;
      mRtsAvgCleaned := pRtsAvgCleaned;
      lineNo := lineNo + 1;
      mSmrCodeCleaned := pSmrCodeCleaned;
      lineNo := lineNo + 1;
      mUnitCostCleaned := pUnitCostCleaned;
      lineNo := lineNo + 1;
      mCondemnAvg := pCondemnAvg;
      lineNo := lineNo + 1;
      mCriticality := pCriticality;
      lineNo := lineNo + 1;
      mNrtsAvg := pNrtsAvg;
      lineNo := lineNo + 1;
      mRtsAvg := pRtsAvg;
      lineNo := lineNo + 1;
      mCostToRepairOffBase := pCostToRepairOffBase;
      lineNo := lineNo + 1;
      mTimeToRepairOffBase := pTimeToRepairOffBase;

      RETURN UpdateRow (pPart_no,
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
                        pUnitOfIssue);
   EXCEPTION
      WHEN OTHERS
      THEN
         ErrorMsg (pSqlfunction      => 'updateRow',
                   pTableName        => '',
                   pError_location   => 410);
         RETURN UPDT_ERRX;
   END UpdateRow;

   FUNCTION InsertRow (pPart_no                   IN VARCHAR2,
                       pMfgr                      IN VARCHAR2,
                       pDate_icp                  IN DATE,
                       pDisposal_cost             IN NUMBER,
                       pErc                       IN VARCHAR2,
                       pIcp_ind                   IN VARCHAR2,
                       pNomenclature              IN VARCHAR2,
                       pOrder_lead_time           IN NUMBER,
                       pOrder_quantity            IN NUMBER,
                       pOrder_uom                 IN VARCHAR2,
                       pPrime_ind                 IN VARCHAR2,
                       pScrap_value               IN NUMBER,
                       pSerial_flag               IN VARCHAR2,
                       pShelf_life                IN NUMBER,
                       pUnit_cost                 IN NUMBER,
                       pUnit_volume               IN NUMBER,
                       pNsn                       IN VARCHAR2,
                       pNsn_type                  IN VARCHAR2,
                       pItem_type                 IN VARCHAR2,
                       pSmr_code                  IN VARCHAR2,
                       pPlanner_code              IN VARCHAR2,
                       pMic_code_lowest           IN VARCHAR2,
                       pAcquisition_advice_code   IN VARCHAR2,
                       pMmac                      IN VARCHAR2,
                       pUnitOfIssue               IN VARCHAR2)
      RETURN NUMBER
   IS
      /* Although the following variables are local to the InsertRow
        procedure, you will see them referenced as InsertRow.variable_name.
        This was done to improve readability.  A similar approach is used
        for package constants: package_name.constant_name.
       */
      prime_ind_cleaned     amd_nsi_parts.prime_ind_cleaned%TYPE := NULL;
      result                NUMBER := SUCCESS;
      tactical              amd_spare_parts.tactical%TYPE := 'N';
      unit_cost_defaulted   amd_spare_parts.unit_cost_defaulted%TYPE := NULL;
      part_already_exists   EXCEPTION;
      is_spo_part           amd_spare_parts.is_spo_part%TYPE;


      /* Put a wrapper on the amd_utils.InsertErrorMsg procedure, so it is
          more specific to the InsertRow function.  Output gets stored
          into amd_load_details and amd_load_status.
      */

      PROCEDURE InsertAmdNsiParts (pNsi_sid IN amd_nsi_parts.nsi_sid%TYPE)
      IS
      BEGIN
         insertNsiParts (
            pNsi_sid             => pNsi_sid,
            pPart_no             => pPart_no,
            pPrime_ind           => pPrime_ind,
            pPrime_ind_cleaned   => prime_ind_cleaned,
            pBadRc               => amd_spare_parts_pkg.UNABLE_TO_INSERT_AMD_NSI_PARTS);
      EXCEPTION
         WHEN OTHERS
         THEN
            mRC := INS_AMD_NSI_PARTS_ERR;
            ErrorMsg (pSqlfunction      => 'insert',
                      pTableName        => 'amd_nsi_parts',
                      pError_location   => 420,
                      pKey_1            => TO_CHAR (pNsi_sid));
            RAISE;
      END InsertAmdNsiParts;


      PROCEDURE InsertEquivalentPartData (
         pNsi_sid   IN amd_nsi_parts.nsi_sid%TYPE)
      IS
      BEGIN
         InsertAmdNsiParts (pNsi_sid);
      EXCEPTION
         WHEN OTHERS
         THEN
            mRC := INS_AMD_NSI_PARTS_ERR;
            ErrorMsg (pSqlfunction      => 'insert',
                      pTableName        => 'amd_nsi_parts',
                      pError_location   => 430,
                      pKey_1            => TO_CHAR (pNsi_sid));
            RAISE;
      END InsertEquivalentPartData;


      PROCEDURE DoPhysicalInsert
      IS
         nsi_sid   amd_national_stock_items.nsi_sid%TYPE := NULL;

         FUNCTION IsPrimeReplacingExistingOne (
            pNsi_sid                 IN     amd_nsi_parts.nsi_sid%TYPE,
            pCurrent_prime_part_no      OUT amd_nsi_parts.part_no%TYPE)
            RETURN BOOLEAN
         IS
            prime_ind   amd_nsi_parts.prime_ind%TYPE := NULL;
         BEGIN
            BEGIN
               SELECT part_no, prime_ind
                 INTO pCurrent_prime_part_no, prime_ind
                 FROM amd_nsi_parts
                WHERE     nsi_sid = pNsi_sid
                      AND prime_ind = amd_defaults.PRIME_PART
                      AND unassignment_date IS NULL;

               RETURN TRUE;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  RETURN FALSE;
            END;
         END IsPrimeReplacingExistingOne;


         PROCEDURE PrepareDataForInsert
         IS
         BEGIN
           -- todo prime_ind_cleaned will be set in a separate routine since it is
           -- so complicated
           -- InsertRow.prime_ind_cleaned := amd_clean_data.prime_ind(nsn);

           <<getTacticalInd>>
            BEGIN
               InsertRow.tactical :=
                  amd_validation_pkg.GetTacticalInd (
                     amd_preferred_pkg.GetPreferredValue (
                        mUnitCostCleaned,
                        pUnit_cost,
                        InsertRow.unit_cost_defaulted),
                     amd_preferred_pkg.GetPreferredValue (mSmrCodeCleaned,
                                                          pSmr_code));
            EXCEPTION
               WHEN OTHERS
               THEN
                  ErrorMsg (pSqlfunction      => 'getTacticalInd',
                            pError_location   => 440);
                  RAISE;
            END getTacticalInd;

            IF pPlanner_code IS NOT NULL
            THEN
               IF NOT amd_validation_pkg.IsValidPlannerCode (pPlanner_code)
               THEN
                  IF amd_validation_pkg.AddPlannerCode (pPlanner_code) !=
                        amd_validation_pkg.SUCCESS
                  THEN
                     RAISE ADD_PLANNER_CODE_EXCEPTION;
                  END IF;
               END IF;
            END IF;

            IF pOrder_uom IS NOT NULL
            THEN
               IF NOT amd_validation_pkg.IsValidUomCode (pOrder_uom)
               THEN
                  IF amd_validation_pkg.AddUomCode (pOrder_uom) !=
                        amd_validation_pkg.SUCCESS
                  THEN
                     RAISE ADD_UOM_CODE_EXCEPTION;
                  END IF;
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               mRC := amd_spare_parts_pkg.UNABLE_TO_PREP_DATA;
               ErrorMsg (pSqlfunction      => 'prepareDataForInsert',
                         pError_location   => 450);
               RAISE;
         END prepareDataForInsert;


         FUNCTION NatStkItemExists (pNsn       IN     amd_spare_parts.nsn%TYPE,
                                    pNsi_sid      OUT amd_nsns.nsi_sid%TYPE)
            RETURN BOOLEAN
         IS
         BEGIN
            SELECT nsi_sid
              INTO pNsi_sid
              FROM amd_nsns
             WHERE nsn = pNsn AND nsi_sid IS NOT NULL;

            RETURN TRUE;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               RETURN FALSE;
         END NatStkItemExists;


         PROCEDURE InsertSparePart
         IS
         BEGIN
            INSERT INTO amd_spare_parts (part_no,
                                         mfgr,
                                         date_icp,
                                         disposal_cost,
                                         disposal_cost_defaulted,
                                         erc,
                                         icp_ind,
                                         nomenclature,
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
                                         unit_of_issue)
                 VALUES (pPart_no,
                         pMfgr,
                         pDate_icp,
                         pDisposal_cost,
                         amd_defaults.DISPOSAL_COST,
                         pErc,
                         pIcp_ind,
                         pNomenclature,
                         pOrder_lead_time,
                         amd_defaults.GetOrderLeadTime (pItem_type),
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
                         SYSDATE,
                         pAcquisition_advice_code,
                         pUnitOfIssue);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               writeMsg (
                  pTableName        => 'amd_spare_parts',
                  pError_location   => 460,
                  pKey1             => 'pPart_no=' || pPart_no,
                  pKey2             => 'tried to insert a part that was already there');
               result :=
                  UpdateRow (pPart_no,
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
                             pUnitOfIssue);
            WHEN OTHERS
            THEN
               ErrorMsg (pSqlfunction      => 'insert',
                         pTableName        => 'amd_spare_parts',
                         pError_location   => 470,
                         pKey_1            => pPart_no);
               RAISE;
         END InsertSparePart;


         PROCEDURE UpdatePrimePartData (
            pNsi_sid   IN amd_national_stock_items.nsi_sid%TYPE)
         IS
            result   NUMBER := SUCCESS;
         BEGIN                                          -- UpdatePrimePartData
            InsertAmdNsiParts (pNsi_sid);

            UpdtNsiPrimePartData (
               pPrime_ind         => pPrime_ind,
               pNsi_sid           => pNsi_sid,
               pPartNo            => pPart_no,
               pNsn               => pNsn,
               pItem_type         => pItem_type,
               pOrder_quantity    => pOrder_quantity,
               pPlannerCode       => pPlanner_code,
               pSmr_code          => pSmr_code,
               pMic_code_lowest   => pMic_code_lowest,
               pAction_code       => amd_defaults.INSERT_ACTION,
               pReturn_code       => amd_spare_parts_pkg.UNABLE_TO_PRIME_INFO,
               pMmac              => pMmac);
         EXCEPTION
            WHEN OTHERS
            THEN
               mRC := INSERT_PRIMEPART_ERR;
               ErrorMsg (pSqlfunction      => 'updatePrimePartData',
                         pError_location   => 480);
               RAISE;
         END UpdatePrimePartData;


         PROCEDURE UpdatePrimePartData (
            pNsn                     IN amd_national_stock_items.nsn%TYPE,
            pNsi_sid                 IN amd_nsns.nsi_sid%TYPE,
            pCurrent_prime_part_no   IN amd_nsi_parts.part_no%TYPE)
         IS
            result   NUMBER := SUCCESS;

            PROCEDURE MakePrimeAnEquivalentPart
            IS
               curPrime   amd_nsi_parts.PART_NO%TYPE;
            BEGIN
               -- first make sure the prime_part is flagged as logically deleted
               UPDATE amd_national_stock_items
                  SET action_code = amd_defaults.DELETE_ACTION,
                      last_update_dt = SYSDATE
                WHERE     nsi_sid = pNsi_sid
                      AND prime_part_no =
                             (SELECT part_no
                                FROM amd_nsi_parts
                               WHERE     nsi_sid = pNsi_sid
                                     AND (   prime_ind =
                                                amd_defaults.PRIME_PART
                                          OR prime_ind_cleaned =
                                                amd_defaults.PRIME_PART)
                                     AND unassignment_date IS NULL);


               UPDATE amd_nsi_parts
                  SET unassignment_date = SYSDATE
                WHERE     nsi_sid = pNsi_sid
                      AND (   prime_ind = amd_defaults.PRIME_PART
                           OR prime_ind_cleaned = amd_defaults.PRIME_PART)
                      AND unassignment_date IS NULL;

               insertNsiParts (
                  pNsi_sid             => pNsi_sid,
                  pPart_no             => pCurrent_prime_part_no,
                  pPrime_ind           => amd_defaults.NOT_PRIME_PART,
                  pPrime_ind_cleaned   => NULL,
                  pBadRc               => amd_spare_parts_pkg.UNASSIGN_OLD_PRIME_PART_ERR);
            EXCEPTION
               WHEN OTHERS
               THEN
                  ErrorMsg (pSqlfunction      => 'makePrimeAnEquivalentPart',
                            pError_location   => 490);
                  RAISE;
            END MakePrimeAnEquivalentPart;
         BEGIN                                          -- UpdatePrimePartData
            UpdtNsiPrimePartData (
               pPrime_ind         => pPrime_ind,
               pNsi_sid           => pNsi_sid,
               pPartNo            => pPart_no,
               pNsn               => pNsn,
               pItem_type         => pItem_type,
               pOrder_quantity    => pOrder_quantity,
               pPlannerCode       => pPlanner_code,
               pSmr_code          => pSmr_code,
               pMic_code_lowest   => pMic_code_lowest,
               pAction_code       => amd_defaults.UPDATE_ACTION,
               pReturn_code       => amd_spare_parts_pkg.CANNOT_UPADATE_NAT_STCK_ITEMS,
               pMmac              => pMmac);


            IF pNsn_type = amd_spare_parts_pkg.CURRENT_NSN
            THEN
               amd_spare_parts_pkg.ChgCurNsn2TempNsn (pNsiSid => pNsi_sid);
            END IF;

            BEGIN
               amd_spare_parts_pkg.UpdateAmdNsn (pNsn_Type   => pNsn_Type,
                                                 pNsi_Sid    => pNsi_sid,
                                                 pNsn        => pNsn);
            EXCEPTION
               WHEN OTHERS
               THEN
                  mRC := CANNOT_UPDATE_AMD_NSNS;
                  ErrorMsg (pSqlfunction      => 'updateAmdNsn',
                            pError_location   => 500,
                            pKey_1            => pNsn_Type,
                            pKey_2            => TO_CHAR (pNsi_sid),
                            pKey_3            => pNsn);
                  RAISE;
            END update_amd_nsns;

            MakePrimeAnEquivalentPart ();
            insertNsiParts (
               pNsi_sid             => pNsi_sid,
               pPart_no             => pPart_no,
               pPrime_ind           => pPrime_ind,
               pPrime_ind_cleaned   => NULL,
               pBadRc               => amd_spare_parts_pkg.MAKE_NEW_PRIME_PART_ERR);
            MakeNsnSameForAllParts (pNsi_sid => pNsi_sid, pNsn => pNsn);
         EXCEPTION
            WHEN OTHERS
            THEN
               mRC := CANNOT_UPDATE_AMD_NSNS;
               ErrorMsg (pSqlfunction      => 'updatePrimePartData',
                         pError_location   => 510,
                         pKey_1            => pNsn_Type,
                         pKey_2            => TO_CHAR (pNsi_sid),
                         pKey_3            => pNsn);
               RAISE;
         END UpdatePrimePartData;
      BEGIN                                                -- DoPhysicalInsert
         debugMsg ('DoPhysicalInsert', pError_location => 520);

         PrepareDataForInsert;

         IF NatStkItemExists (pNsn       => pNsn,
                              pNsi_sid   => DoPhysicalInsert.nsi_sid)
         THEN
            NULL;                                             -- OK do nothing
         ELSE                                                    -- create one
            CreateNationalStockItem (
               pNsi_sid           => DoPhysicalInsert.nsi_sid,
               pNsn               => pNsn,
               pItem_type         => pItem_type,
               pOrder_quantity    => pOrder_quantity,
               pPlanner_code      => pPlanner_code,
               pSmr_code          => pSmr_code,
               pTactical          => InsertRow.tactical,
               pMic_code_lowest   => InsertRow.pMic_code_lowest,
               pNsn_type          => pNsn_type,
               pMmac              => pMmac);
         END IF;

         InsertSparePart ();

         IF IsPrimePart (pPrime_ind)
         THEN
            DECLARE
               current_prime_part_no   amd_nsi_parts.part_no%TYPE := NULL;
            BEGIN
               IF IsPrimeReplacingExistingOne (
                     pNsi_sid                 => DoPhysicalInsert.nsi_sid,
                     pCurrent_prime_part_no   => current_prime_part_no)
               THEN
                  UpdatePrimePartData (
                     pNsn                     => pNsn,
                     pNsi_sid                 => DoPhysicalInsert.nsi_sid,
                     pCurrent_prime_part_no   => current_prime_part_no);
               ELSE
                  UpdatePrimePartData (pNsi_sid => DoPhysicalInsert.nsi_sid);
               END IF;
            END CheckForExistingPrime;
         ELSE
            InsertEquivalentPartData (pNsi_sid => DoPhysicalInsert.nsi_sid);
         END IF;

         IF pNsn IS NOT NULL
         THEN
            UpdateNatStkItem (pNsn, amd_defaults.INSERT_ACTION, pPart_no);
         END IF;
      END DoPhysicalInsert;


      PROCEDURE DoLogicalInsert
      IS
      BEGIN
         result :=
            UpdateRow (pPart_no,
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
                       pUnitOfIssue);

         IF result = SUCCESS
         THEN
            BEGIN
               -- Make it look like an insert was just
               -- done.
               UPDATE amd_spare_parts
                  SET action_code = amd_defaults.INSERT_ACTION
                WHERE part_no = pPart_no;
            EXCEPTION
               WHEN OTHERS
               THEN
                  mRC := LOGICAL_INSERT_FAILED;
                  ErrorMsg (pSqlfunction      => 'update',
                            pTablename        => 'amd_spare_parts',
                            pError_location   => 530,
                            pKey_1            => pPart_no);
                  RAISE;
            END LogicalInsert;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            ErrorMsg (pSqlfunction      => 'update',
                      pTablename        => 'amd_spare_parts',
                      pError_location   => 540,
                      pKey_1            => pPart_no);
            RAISE;
      END DoLogicalInsert;


      FUNCTION IsPartMarkedAsDeleted
         RETURN BOOLEAN
      IS
         FUNCTION GetActionCode
            RETURN VARCHAR2
         IS
            action_code   VARCHAR2 (1);
         BEGIN
            SELECT action_code
              INTO action_code
              FROM amd_spare_parts
             WHERE part_no = pPart_no;

            RETURN action_code;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               RETURN NULL;
         END GetActionCode;
      BEGIN
         RETURN (GetActionCode () = amd_defaults.DELETE_ACTION);
      END IsPartMarkedAsDeleted;
   BEGIN                                                  -- <<<---- InsertRow
      amd_utils.mDebugThreshold := 100000;
      debugMsg (mArgs, pError_location => 550);

      --        insertLoadDetail(pPart_No,pNsn,pPrime_Ind,'Insert');

      IF IsPartMarkedAsDeleted ()
      THEN
         DoLogicalInsert ();
      ELSE
         unassociateTmpNsn (pNsn);

         DoPhysicalInsert ();
      END IF;

      updateFlags (pPart_no, is_spo_part);

      IF result <> 0
      THEN
         mDebug := TRUE;
         debugMsg (mArgs, pError_location => 553);
         writeMsg (pTableName        => 'tmp_amd_spare_parts',
                   pError_location   => 555,
                   pKey1             => 'insertRow',
                   pKey2             => 'result ' || result,
                   pKey3             => 'part ' || pPart_No);
      END IF;

      mDebug := FALSE;
      RETURN result;
   EXCEPTION
      WHEN part_already_exists
      THEN
         RETURN SUCCESS;                                  -- ignore this error
      WHEN OTHERS
      THEN
         ErrorMsg (pSqlfunction => 'insertRow', pError_location => 560);
         RETURN mRC;
   END InsertRow;


   FUNCTION UpdateRow (pPart_no                   IN VARCHAR2,
                       pMfgr                      IN VARCHAR2,
                       pDate_icp                  IN DATE,
                       pDisposal_cost             IN NUMBER,
                       pErc                       IN VARCHAR2,
                       pIcp_ind                   IN VARCHAR2,
                       pNomenclature              IN VARCHAR2,
                       pOrder_lead_time           IN NUMBER,
                       pOrder_quantity            IN NUMBER,
                       pOrder_uom                 IN VARCHAR2,
                       pPrime_ind                 IN VARCHAR2,
                       pScrap_value               IN NUMBER,
                       pSerial_flag               IN VARCHAR2,
                       pShelf_life                IN NUMBER,
                       pUnit_cost                 IN NUMBER,
                       pUnit_volume               IN NUMBER,
                       pNsn                       IN VARCHAR2,
                       pNsn_type                  IN VARCHAR2,
                       pItem_type                 IN VARCHAR2,
                       pSmr_code                  IN VARCHAR2,
                       pPlanner_code              IN VARCHAR2,
                       pMic_code_lowest           IN VARCHAR2,
                       pAcquisition_advice_code   IN VARCHAR2,
                       pMmac                      IN VARCHAR2,
                       pUnitOfIssue               IN VARCHAR2)
      RETURN NUMBER
   IS
      /* Although the following variables are local to the UpdateRow
        procedure, you will see them referenced as UpdateRow.variable_name.
        This was done to improve readability.  A similar approach is used
        for package constants: package_name.constant_name.
       */
      nsiSid        amd_national_stock_items.nsi_sid%TYPE := NULL;
      result        NUMBER := SUCCESS;
      tactical      amd_spare_parts.tactical%TYPE := 'N';
      lineNumber    NUMBER := 0;
      is_spo_part   amd_spare_parts.is_spo_part%TYPE;


      /* Put a wrapper on the amd_utils.InsertErrorMsg procedure, so it is
          more specific to the UpdateRow function.  Output gets stored
          into amd_load_details and amd_load_status.
      */


      PROCEDURE PrepareDataForUpdate
      IS
         FUNCTION GetSmrCode
            RETURN amd_national_stock_items.smr_code%TYPE
         IS
            smr_code_cleaned   amd_national_stock_items.smr_code_cleaned%TYPE;
         BEGIN
            SELECT smr_code_cleaned
              INTO smr_code_cleaned
              FROM amd_national_stock_items items
             WHERE nsi_sid = nsiSid;

            RETURN amd_preferred_pkg.GetPreferredValue (smr_code_cleaned,
                                                        pSmr_code);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               RETURN NULL;
         END GetSmrCode;


         FUNCTION GetUnitCost
            RETURN amd_spare_parts.unit_cost%TYPE
         IS
            unit_cost_cleaned     amd_national_stock_items.unit_cost_cleaned%TYPE;
            unit_cost_defaulted   amd_spare_parts.unit_cost_defaulted%TYPE;
         BEGIN
            BEGIN
               SELECT unit_cost_cleaned, unit_cost_defaulted
                 INTO unit_cost_cleaned, unit_cost_defaulted
                 FROM amd_national_stock_items
                WHERE nsn = pNsn;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  unit_cost_cleaned := NULL;
               WHEN OTHERS
               THEN
                  RAISE amd_spare_parts_pkg.UNIT_COST_CLEANED_VIA_NSN;
            END get_unit_cost_cleaned;

            RETURN amd_preferred_pkg.GetPreferredValue (unit_cost_cleaned,
                                                        pUnit_cost,
                                                        unit_cost_defaulted);
         END GetUnitCost;
      BEGIN                                            -- PrepareDataForUpdate
         BEGIN
            UpdateRow.tactical :=
               amd_validation_pkg.GetTacticalInd (GetUnitCost (),
                                                  GetSmrCode ());
         EXCEPTION
            WHEN amd_spare_parts_pkg.UNIT_COST_CLEANED_VIA_NSN
            THEN
               mRC := amd_spare_parts_pkg.CANNOT_GET_UNIT_COST_CLEANED;
               ErrorMsg (pSqlfunction      => 'getTacticalInd',
                         pError_location   => 570);
               RAISE;
         END setTactical;

         IF pPlanner_code IS NOT NULL
         THEN
            IF NOT amd_validation_pkg.IsValidPlannerCode (pPlanner_code)
            THEN
               IF amd_validation_pkg.AddPlannerCode (pPlanner_code) !=
                     amd_validation_pkg.SUCCESS
               THEN
                  RAISE ADD_PLANNER_CODE_EXCEPTION;
               END IF;
            END IF;
         END IF;

         IF pOrder_uom IS NOT NULL
         THEN
            IF NOT amd_validation_pkg.IsValidUomCode (pOrder_uom)
            THEN
               IF amd_validation_pkg.AddUomCode (pOrder_uom) !=
                     amd_validation_pkg.SUCCESS
               THEN
                  RAISE ADD_UOM_CODE_EXCEPTION;
               END IF;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            mRC := amd_spare_parts_pkg.PREP_DATA_FOR_UPDT_ERR;
            ErrorMsg (pSqlfunction      => 'prepareDataForUpdate',
                      pError_location   => 580);
            RAISE;
      END PrepareDataForUpdate;


      PROCEDURE UpdateAmdSparePartRow (
         pPartNo    amd_spare_parts.part_no%TYPE,
         pNsn       amd_spare_parts.nsn%TYPE)
      IS
      BEGIN
         debugMsg ('updateAmdSparePartRow(' || pPartNo || ',' || pNsn || ')',
                   pError_location   => 590);

         UPDATE amd_spare_parts
            SET mfgr = pMfgr,
                date_icp = pDate_icp,
                disposal_cost = pDisposal_cost,
                erc = pErc,
                icp_ind = pIcp_ind,
                nomenclature = pNomenclature,
                order_lead_time = pOrder_lead_time,
                order_lead_time_defaulted =
                   amd_defaults.GETORDERLEADTIME (pItem_type),
                order_uom = pOrder_uom,
                scrap_value = pScrap_value,
                serial_flag = pSerial_flag,
                shelf_life = pShelf_life,
                unit_cost = pUnit_cost,
                unit_volume = pUnit_volume,
                tactical = UpdateRow.tactical,
                action_code = amd_defaults.UPDATE_ACTION,
                last_update_dt = SYSDATE,
                nsn = pNsn,
                acquisition_advice_code = pAcquisition_advice_code,
                unit_of_issue = pUnitOfIssue
          WHERE part_no = pPartNo;
      EXCEPTION
         WHEN OTHERS
         THEN
            mRC := amd_spare_parts_pkg.UPDT_SPAREPART_ERR;
            ErrorMsg (pSqlfunction      => 'updateAmdSparePartRow',
                      pError_location   => 600);
            RAISE;
      END UpdateAmdSparePartRow;


      PROCEDURE UpdatePrimePartData
      IS
      BEGIN
        <<update_amd_nsns>>
         BEGIN
            amd_spare_parts_pkg.UpdateAmdNsn (pNsn_type   => pNsn_type,
                                              pNsi_sid    => nsiSid,
                                              pNsn        => pNsn);
         EXCEPTION
            WHEN OTHERS
            THEN
               mRC := amd_spare_parts_pkg.CANNOT_UPDATE_AMD_NSNS;
               ErrorMsg (pSqlfunction      => 'updateAmdNsn',
                         pError_location   => 610);
               RAISE;
         END update_amd_nsns;
      EXCEPTION
         WHEN OTHERS
         THEN
            mRC := amd_spare_parts_pkg.UPDT_PRIMEPART_ERR;
            ErrorMsg (pSqlfunction      => 'updatePrimePartData',
                      pError_location   => 620);
            RAISE;
      END UpdatePrimePartData;


      FUNCTION NsnChanged (pPartNo VARCHAR2, pNsn VARCHAR2)
         RETURN BOOLEAN
      IS
         nsn   amd_nsns.nsn%TYPE;
      BEGIN
         debugMsg ('nsnChanged(' || pPartNo || ',' || pNsn || ')',
                   pError_location   => 630);

         SELECT an.nsn
           INTO nsn
           FROM amd_nsi_parts anp, amd_nsns an
          WHERE     anp.nsi_sid = an.nsi_sid
                AND anp.part_no = pPartNo
                AND anp.unassignment_date IS NULL
                AND an.nsn_type = 'C';

         IF nsn != pNsn
         THEN
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN TRUE;
      END NsnChanged;


      FUNCTION PrimeIndChanged
         RETURN BOOLEAN
      IS
         prime_ind   amd_nsi_parts.prime_ind%TYPE := NULL;
      BEGIN
         debugMsg ('primeIndChanged(' || prime_ind || ')',
                   pError_location   => 640);

         SELECT prime_ind
           INTO prime_ind
           FROM amd_nsi_parts
          WHERE     nsi_sid = nsiSid
                AND part_no = pPart_no
                AND unassignment_date IS NULL;

         RETURN (prime_ind != pPrime_ind);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN TRUE;
      END;


      FUNCTION UpdateNsnForPrimePart
         RETURN NUMBER
      IS
         /*
         IMPORTANT:  The prime part controls the value of
         the nsn column in amd_spare_parts. Whenever the value
         of the amd_spare_parts nsn column changes for a prime part, the
         following will happen:
                 1.    Update the nsn column of amd_national_stock_items.
                 2.    Using the amd_nsi_parts linked via nsi_sid update the
                     nsn column of amd_spare_parts with the new value -
                     i.e. update the prime part and its equivalent parts.
         */
         result   NUMBER := SUCCESS;

         PROCEDURE UpdtNsnOfNationalStockItems (pNsiSid NUMBER)
         IS
         BEGIN
            debugMsg (
                  'updtNsnOfNationalStockItems('
               || pNsn
               || ','
               || pNsiSid
               || ')',
               pError_location   => 650);

            UPDATE amd_national_stock_items
               SET nsn = pNsn
             WHERE nsi_sid = pNsiSid;
         EXCEPTION
            WHEN OTHERS
            THEN
               mRC := amd_spare_parts_pkg.CANNOT_UPDT_NSN_NAT_STCK_ITEMS;
               ErrorMsg (pSqlfunction      => 'update',
                         pTableName        => 'amd_national_stock_items',
                         pError_location   => 660);
               RAISE;
         END UpdtNsnOfNationalStockItems;
      BEGIN                                           -- UpdateNsnForPrimePart
         UpdtNsnOfNationalStockItems (nsiSid);

         MakeNsnSameForAllParts (pNsi_sid => nsiSid, pNsn => pNsn);
         RETURN result;
      EXCEPTION
         WHEN OTHERS
         THEN
            mRC := amd_spare_parts_pkg.UPDT_NSN_PRIME_ERR;
            ErrorMsg (pSqlfunction      => 'updateNsnForPrimePart',
                      pError_location   => 670);
            RAISE;
      END UpdateNsnForPrimePart;


      PROCEDURE UpdatePrimeInd
      IS
         PROCEDURE UnassignPrimePart (pPart_no IN amd_nsi_parts.part_no%TYPE)
         IS
         BEGIN
            debugMsg ('unassignPrimePart(' || pPart_no || ')',
                      pError_location   => 680);

            UPDATE amd_nsi_parts
               SET unassignment_date = SYSDATE
             WHERE     part_no = pPart_no
                   AND (   prime_ind = amd_defaults.PRIME_PART
                        OR prime_ind_cleaned = amd_defaults.PRIME_PART)
                   AND unassignment_date IS NULL;

            -- Since this prime_part is unassigned logically delete the
            -- national_stock_item
            UPDATE amd_national_stock_items
               SET action_code = amd_defaults.DELETE_ACTION,
                   last_update_dt = SYSDATE
             WHERE prime_part_no = pPart_no;
         EXCEPTION
            WHEN OTHERS
            THEN
               ErrorMsg (pSqlfunction      => 'unassignPrimePart',
                         pError_location   => 690,
                         pKey_1            => pPart_no);
               RAISE;
         END UnassignPrimePart;

         PROCEDURE MakeCurrentPrimeIntoEquiv
         IS
            part_no   amd_nsi_parts.part_no%TYPE := NULL;
         BEGIN
            BEGIN
               -- get the current Prime Part
               SELECT part_no
                 INTO part_no
                 FROM amd_nsi_parts
                WHERE     nsi_sid = nsiSid
                      AND (   prime_ind = amd_defaults.PRIME_PART
                           OR prime_ind_cleaned = amd_defaults.PRIME_PART)
                      AND unassignment_date IS NULL;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  /* This can occur when a prime has alreay become an
                      equivalent part, before the NEW prime is processed.
                      */
                  RETURN;                                        -- do nothing
               WHEN OTHERS
               THEN
                  mRC := amd_spare_parts_pkg.UNABLE_TO_GET_PRIME_PART_X;
                  ErrorMsg (pSqlfunction      => 'select',
                            pTableName        => 'amd_nsi_parts',
                            pError_location   => 700,
                            pKey_1            => TO_CHAR (nsiSid));
                  RAISE;
            END GetCurrentPrimePart;

            UnassignPrimePart (pPart_no => part_no);

            insertNsiParts (
               pNsi_sid             => nsiSid,
               pPart_no             => part_no,
               pPrime_ind           => amd_defaults.NOT_PRIME_PART,
               pPrime_ind_cleaned   => NULL,
               pBadRc               => amd_spare_parts_pkg.ASSIGN_PRIME_TO_EQUIV_ERR);
         EXCEPTION
            WHEN OTHERS
            THEN
               ErrorMsg (pSqlfunction      => 'MakeCurrentPrimeIntoEquiv',
                         pError_location   => 710,
                         pKey_1            => pPart_no);
               RAISE;
         END MakeCurrentPrimeIntoEquiv;


         PROCEDURE UpdatePrimePartNo
         IS
            temp_prime_part_no   amd_national_stock_items.prime_part_no%TYPE
                                    := NULL;
         BEGIN
           <<getPrimePart>>
            BEGIN
               -- check if the prime part has been set yet
               SELECT part_no
                 INTO temp_prime_part_no
                 FROM amd_nsi_parts
                WHERE     nsi_sid = nsiSid
                      AND unassignment_date IS NULL
                      AND (   prime_ind = amd_defaults.PRIME_PART
                           OR prime_ind_cleaned = amd_defaults.PRIME_PART);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;           -- OK the prime_part_no has not been set yet
               WHEN OTHERS
               THEN
                  mRC := amd_spare_parts_pkg.UNABLE_TO_GET_PRIME_PART;
                  ErrorMsg (pSqlfunction      => 'select',
                            pTableName        => 'amd_nsi_parts',
                            pError_location   => 720,
                            pKey_1            => TO_CHAR (nsiSid));
                  RAISE;
            END getPrimePart;

            IF temp_prime_part_no != NULL
            THEN
               BEGIN
                  SELECT prime_part_no
                    INTO temp_prime_part_no
                    FROM amd_national_stock_items
                   WHERE     nsi_sid = nsiSid
                         AND prime_part_no = temp_prime_part_no;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     BEGIN
                        /* This should not happen, but just in
                         * case this will gaurantee that the
                         * prime_part_no = part_no in
                         * amd_nsi_parts with prime_ind = 'Y'
                         */
                        UPDATE amd_national_stock_items
                           SET prime_part_no = temp_prime_part_no,
                               last_update_dt = SYSDATE,
                               action_code = amd_defaults.UPDATE_ACTION
                         WHERE nsi_sid = nsiSid;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           mRC := amd_spare_parts_pkg.UPDT_NULL_PRIME_COLS_ERR;
                           ErrorMsg (
                              pSqlfunction      => 'update',
                              pTableName        => 'amd_national_stock_items',
                              pError_location   => 730,
                              pKey_1            => TO_CHAR (nsiSid));
                           RAISE;
                     END UpdateNationalStockItems;
                  WHEN OTHERS
                  THEN
                     mRC := amd_spare_parts_pkg.UNABLE_TO_GET_PRIME_PART;
                     ErrorMsg (pSqlfunction      => 'updatePrimePartNo',
                               pError_location   => 740);
                     RAISE;
               END;
            ELSE
               -- the prime part is null, but it should get
               -- set with subsequent data
               BEGIN
                  UPDATE amd_national_stock_items
                     SET prime_part_no = temp_prime_part_no,
                         last_update_dt = SYSDATE,
                         action_code = amd_defaults.UPDATE_ACTION
                   WHERE nsi_sid = nsiSid;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     mRC := amd_spare_parts_pkg.UPDT_NULL_PRIME_COLS_ERR2;
                     ErrorMsg (pSqlfunction      => 'update',
                               pTableName        => 'amd_national_stock_items',
                               pError_location   => 750,
                               pKey_1            => TO_CHAR (nsiSid));
                     RAISE;
               END UpdateNationalStockItems;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               mRC := amd_spare_parts_pkg.UPDT_NULL_PRIME_COLS_ERR2;
               ErrorMsg (pSqlfunction      => 'update',
                         pTableName        => 'amd_national_stock_items',
                         pError_location   => 760,
                         pKey_1            => TO_CHAR (nsiSid));
               RAISE;
         END UpdatePrimePartNo;
      BEGIN                                                 --  UpdatePrimeInd
         debugMsg ('updatePrimeInd()', pError_location => 770);

         IF IsPrimePart (pPrime_ind)
         THEN
            MakeCurrentPrimeIntoEquiv ();

            unassignPart (pPart_no);

            BEGIN
               insertNsiParts (
                  pNsi_sid             => nsiSid,
                  pPart_no             => pPart_no,
                  pPrime_ind           => pPrime_ind,
                  pPrime_ind_cleaned   => NULL,
                  pBadRc               => amd_spare_parts_pkg.ASSIGN_NEW_PRIME_PART_ERR);
            END AssignNewPrimePart;

            BEGIN
               -- make sure action_code and last_update_dt get set too
               UPDATE amd_national_stock_items
                  SET prime_part_no = pPart_no,
                      nsn = pNsn,
                      last_update_dt = SYSDATE,
                      action_code = amd_defaults.UPDATE_ACTION
                WHERE nsi_sid = nsiSid;
            EXCEPTION
               WHEN OTHERS
               THEN
                  mRC := amd_spare_parts_pkg.UPDT_ERR_NATIONAL_STK_ITEMS;
                  ErrorMsg (pSqlfunction      => 'update',
                            pTableName        => 'amd_national_stock_items',
                            pError_location   => 780,
                            pKey_1            => TO_CHAR (nsiSid));
                  RAISE;
            END UpdateNationalStockItems;

            /* added invocation of MakeNsnSameForAllParts to
             * to fix bug where equiv parts did not have the same
             * nsn as the prime part.
             */
            MakeNsnSameForAllParts (pNsi_sid => nsiSid, pNsn => pNsn);
         ELSE
            UnassignPrimePart (pPart_no => pPart_no);
            insertNsiParts (
               pNsi_sid             => nsiSid,
               pPart_no             => pPart_no,
               pPrime_ind           => pPrime_ind,
               pPrime_ind_cleaned   => NULL,
               pBadRc               => amd_spare_parts_pkg.ASSIGN_NEW_EQUIV_PART_ERR);

            UpdatePrimePartNo;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            mRC := amd_spare_parts_pkg.UPD_NSI_PARTS_ERR;
            ErrorMsg (pSqlfunction => 'updatePrimeInd', pError_location => 790);
            RAISE;
      END UpdatePrimeInd;


      PROCEDURE InsertNewNsn (pNsi_sid OUT amd_nsns.nsi_sid%TYPE)
      IS
         /* Get the nsi_sid using the part_no */
         PROCEDURE GetNsiSid
         IS
         BEGIN
            pNsi_sid := amd_utils.GetNsiSid (pPart_no => pPart_no);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               RAISE;
            WHEN OTHERS
            THEN
               pNsi_sid := NULL;
               mRC := amd_spare_parts_pkg.GET_NSISID_BY_PART_ERR;
               ErrorMsg (pSqlfunction => 'getNsiSid', pError_location => 800);
               RAISE;
         END GetNsiSid;
      BEGIN                                                    -- InsertNewNsn
         GetNsiSid ();

         InsertAmdNsn (pNsi_sid    => pNsi_sid,
                       pNsn        => pNsn,
                       pNsn_type   => pNsn_type);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            CreateNationalStockItem (pNsi_sid           => pNsi_sid,
                                     pNsn               => pNsn,
                                     pItem_type         => pItem_type,
                                     pOrder_quantity    => pOrder_quantity,
                                     pPlanner_code      => pPlanner_code,
                                     pSmr_code          => pSmr_code,
                                     pTactical          => UpdateRow.tactical,
                                     pMic_code_lowest   => pMic_code_lowest,
                                     pNsn_type          => pNsn_type,
                                     pMmac              => pMmac);
         WHEN OTHERS
         THEN
            pNsi_sid := NULL;
            mRC := amd_spare_parts_pkg.NEW_NSN_ERROR;
            ErrorMsg (pSqlfunction => 'insertNewNsn', pError_location => 810);
            RAISE;
      END InsertNewNsn;


      FUNCTION GetNsiSid
         RETURN amd_nsns.nsi_sid%TYPE
      IS
         nsi_sid   amd_nsns.nsi_sid%TYPE;
      BEGIN
         debugMsg ('getNsiSid()', pError_location => 820);
         nsi_sid := amd_utils.GetNsiSid (pNsn => pNsn);
         debugMsg ('Nsi_sid=' || Nsi_sid, pError_location => 830);
         RETURN nsi_sid;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RAISE;                                        -- must be a new nsn
         WHEN OTHERS
         THEN
            ErrorMsg (pSqlfunction => 'getNsiSid', pError_location => 840);
            RAISE;
      END GetNsiSid;


      PROCEDURE CheckNsnAndPrimeInd
      IS
         result   NUMBER := SUCCESS;
      BEGIN
         debugMsg ('checkNsnAndPrimeInd()', pError_location => 850);

         IF NsnChanged (pPart_no, pNsn)
         THEN
            IF IsPrimePart (pPrime_ind)
            THEN
               IF PrimeIndChanged ()
               THEN
                  UpdatePrimeInd ();
                  result := UpdateNsnForPrimePart ();
               ELSE
                  result := UpdateNsnForPrimePart ();
               END IF;

               MakeNsnSameForAllParts (nsiSid, pNsn);
            ELSE
               unassignPart (pPart_no);

               insertNsiParts (
                  pNsi_sid             => nsiSid,
                  pPart_no             => pPart_no,
                  pPrime_ind           => pPrime_ind,
                  pPrime_ind_cleaned   => NULL,
                  pBadRc               => amd_spare_parts_pkg.ASSIGN_NEW_PRIME_PART_ERR);

               IF PrimeIndChanged ()
               THEN
                  UpdatePrimeInd ();
               END IF;
            END IF;
         ELSE
            IF PrimeIndChanged ()
            THEN
               UpdatePrimeInd ();
            END IF;
         END IF;
      EXCEPTION
         WHEN amd_spare_parts_pkg.CANNOT_FIND_PART
         THEN
            ErrorMsg (pSqlfunction      => 'CheckNsnAndPrimeInd',
                      pError_location   => 860);
            RAISE;
         WHEN OTHERS
         THEN
            mRC := amd_spare_parts_pkg.CHK_NSN_AND_PRIME_ERR2;
            ErrorMsg (pSqlfunction      => 'CheckNsnAndPrimeInd',
                      pError_location   => 870);
            RAISE;
      END CheckNsnAndPrimeInd;

      FUNCTION updatePartLeadTime
         RETURN NUMBER
      IS
         result                           NUMBER := SUCCESS;
         order_lead_time                  amd_spare_parts.order_lead_time%TYPE;
         order_lead_time_cleaned          amd_national_stock_items.order_lead_time_cleaned%TYPE;
         time_to_repair_off_base          amd_national_stock_items.TIME_TO_REPAIR_OFF_BASE%TYPE;
         time_to_repair_off_base_cleand   amd_national_stock_items.TIME_TO_REPAIR_OFF_BASE_CLEAND%TYPE;
      BEGIN
         SELECT parts.order_lead_time,
                items.order_lead_time_cleaned,
                items.TIME_TO_REPAIR_OFF_BASE,
                items.TIME_TO_REPAIR_OFF_BASE_CLEAND
           INTO order_lead_time,
                order_lead_time_cleaned,
                time_to_repair_off_base,
                time_to_repair_off_base_cleand
           FROM amd_spare_parts parts, amd_national_stock_items items
          WHERE parts.part_no = pPart_no AND parts.nsn = items.nsn;



         RETURN result;
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            RETURN result;
         WHEN OTHERS
         THEN
            ErrorMsg (pSqlfunction      => 'updatePartLeadTime',
                      pError_location   => 880,
                      pKey_1            => pPart_no,
                      pKey_2            => pNsn);
            RAISE;
      END updatePartLeadTime;

      FUNCTION updatePartPricing
         RETURN NUMBER
      IS
         unit_cost           amd_spare_parts.unit_cost%TYPE;
         unit_cost_cleaned   amd_national_stock_items.unit_cost_cleaned%TYPE;
      BEGIN
         SELECT unit_cost, unit_cost_cleaned
           INTO unit_cost, unit_cost_cleaned
           FROM amd_spare_parts parts, amd_national_stock_items items
          WHERE parts.part_no = pPart_no AND parts.nsn = items.nsn;

         RETURN result;
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            RETURN result;
         WHEN OTHERS
         THEN
            mRC := amd_spare_parts_pkg.CANNOT_UPDATE_PART_PRICING;
            ErrorMsg (pSqlfunction      => 'updatePartPricing',
                      pError_location   => 890);
            RAISE;
      END updatePartPricing;

      PROCEDURE validateInput
      IS
         part_no                          amd_spare_parts.part_no%TYPE;
         mfgr                             amd_spare_parts.mfgr%TYPE;
         date_icp                         amd_spare_parts.DATE_ICP%TYPE;
         disposal_cost                    amd_spare_parts.DISPOSAL_COST%TYPE;
         erc                              amd_spare_parts.ERC%TYPE;
         icp_ind                          amd_spare_parts.ICP_IND%TYPE;
         nomenclature                     amd_spare_parts.NOMENCLATURE%TYPE;
         order_lead_time                  amd_spare_parts.ORDER_LEAD_TIME%TYPE;
         order_quantity                   amd_national_stock_items.ORDER_QUANTITY%TYPE;
         order_uom                        amd_spare_parts.ORDER_UOM%TYPE;
         prime_ind                        amd_nsi_parts.PRIME_IND%TYPE;
         scrap_value                      amd_spare_parts.SCRAP_VALUE%TYPE;
         serial_flag                      amd_spare_parts.SERIAL_FLAG%TYPE;
         shelf_life                       amd_spare_parts.SHELF_LIFE%TYPE;
         unit_cost                        amd_spare_parts.UNIT_COST%TYPE;
         unit_volume                      amd_spare_parts.UNIT_VOLUME%TYPE;
         nsn                              amd_spare_parts.NSN%TYPE;
         nsn_type                         amd_nsns.NSN_TYPE%TYPE;
         item_type                        amd_national_stock_items.ITEM_TYPE%TYPE;
         smr_code                         amd_national_stock_items.SMR_CODE%TYPE;
         planner_code                     amd_national_stock_items.PLANNER_CODE%TYPE;
         mic_code_lowest                  amd_national_stock_items.MIC_CODE_LOWEST%TYPE;
         acquisition_advice_code          amd_spare_parts.ACQUISITION_ADVICE_CODE%TYPE;
         mmac                             amd_national_stock_items.MMAC%TYPE;
         unit_Of_Issue                    amd_spare_parts.UNIT_OF_ISSUE%TYPE;
         mtbdr                            amd_national_stock_items.MTBDR%TYPE;
         mtbdr_computed                   amd_national_stock_items.mtbdr_computed%TYPE;
         qpei_weighted                    amd_national_stock_items.QPEI_WEIGHTED%TYPE;
         condemn_avg_cleaned              amd_national_stock_items.CONDEMN_AVG_CLEANED%TYPE;
         criticality_cleaned              amd_national_stock_items.CRITICALITY_CLEANED%TYPE;
         mtbdr_cleaned                    amd_national_stock_items.MTBDR_CLEANED%TYPE;
         nrts_avg_cleaned                 amd_national_stock_items.NRTS_AVG_CLEANED%TYPE;
         cost_to_repair_off_base_cleand   amd_national_stock_items.COST_TO_REPAIR_OFF_BASE_CLEAND%TYPE;
         time_to_repair_off_base_cleand   amd_national_stock_items.TIME_TO_REPAIR_OFF_BASE_CLEAND%TYPE;
         order_Lead_Time_cleaned          amd_national_stock_items.ORDER_LEAD_TIME_CLEANED%TYPE;
         planner_code_cleaned             amd_national_stock_items.planner_code_cleaned%TYPE;
         rts_avg_cleaned                  amd_national_stock_items.RTS_AVG_CLEANED%TYPE;
         smr_code_cleaned                 amd_national_stock_items.smr_code_cleaned%TYPE;
         unit_cost_cleaned                amd_national_stock_items.UNIT_COST_CLEANED%TYPE;
         condemn_avg                      amd_national_stock_items.CONDEMN_AVG%TYPE;
         criticality                      amd_national_stock_items.CRITICALITY%TYPE;
         nrts_avg                         amd_national_stock_items.NRTS_AVG%TYPE;
         rts_avg                          amd_national_stock_items.RTS_AVG%TYPE;
         lineNo                           NUMBER := 0;
         result                           NUMBER;
      BEGIN
         lineNo := lineNo + 1;
         part_no := pPart_no;
         lineNo := lineNo + 1;
         mfgr := pMfgr;
         lineNo := lineNo + 1;
         date_icp := pDate_icp;
         lineNo := lineNo + 1;
         disposal_cost := pDisposal_cost;
         lineNo := lineNo + 1;
         erc := pErc;
         lineNo := lineNo + 1;
         icp_ind := pIcp_ind;
         lineNo := lineNo + 1;
         nomenclature := pNomenclature;
         lineNo := lineNo + 1;
         order_lead_time := pOrder_lead_time;
         lineNo := lineNo + 1;
         order_quantity := pOrder_quantity;
         lineNo := lineNo + 1;
         order_uom := pOrder_uom;
         lineNo := lineNo + 1;
         prime_ind := pPrime_ind;
         lineNo := lineNo + 1;
         scrap_value := pScrap_value;
         lineNo := lineNo + 1;
         serial_flag := pSerial_flag;
         lineNo := lineNo + 1;
         shelf_life := pShelf_life;
         lineNo := lineNo + 1;
         unit_volume := pUnit_volume;
         lineNo := lineNo + 1;
         nsn := pNsn;
         lineNo := lineNo + 1;
         nsn_type := pNsn_type;
         lineNo := lineNo + 1;
         item_type := pItem_type;
         lineNo := lineNo + 1;
         smr_code := pSmr_code;
         lineNo := lineNo + 1;
         planner_code := pPlanner_code;
         lineNo := lineNo + 1;
         mic_code_lowest := pMic_code_lowest;
         lineNo := lineNo + 1;
         acquisition_advice_code := pAcquisition_advice_code;
         lineNo := lineNo + 1;
         mmac := pMmac;
         lineNo := lineNo + 1;
         unit_of_issue := pUnitOfIssue;
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
      EXCEPTION
         WHEN OTHERS
         THEN
            ErrorMsg (pSqlfunction => 'validateInput', pError_location => 900);
            RAISE;
      END validateInput;
   BEGIN                                                  -- <<<---- UpdateRow
      validateInput;
      debugMsg (mArgs || ')', pError_location => 910);
      --        insertLoadDetail(pPart_No,pNsn,pPrime_Ind,'Update');

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
      lineNumber := 10;

      IF (hasPartMoved (pPart_no, pNsn))
      THEN
         unassociateTmpNsn (pNsn);
         unassignPart (pPart_no);
      END IF;

      -- retrieve the nsi_sid right away, since it will be make
      -- retrieving data from the amd_national_stock_items,
      -- amd_nsns, and amd_nsi_parts easier
      lineNumber := 20;

      BEGIN
         nsiSid := GetNsiSid ();
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            /* This must be a new nsn - add it to amd_nsns
                using part_no to get the current nsi_sid
            */
            InsertNewNsn (pNsi_sid => nsiSid);
      END;

      /* The nsi_sid should not be null, but just leave this code in
          as a backup parachute!
          */
      lineNumber := 30;

      IF nsiSid IS NULL
      THEN
         ErrorMsg (pSqlfunction => 'getNsiSid', pError_location => 920);
         RAISE cannotGetNsiSid;
      END IF;

      lineNumber := 40;
      CheckNsnAndPrimeInd ();

      lineNumber := 50;
      PrepareDataForUpdate ();

      lineNumber := 60;
      UpdateAmdSparePartRow (pPart_no, pNsn);

      lineNumber := 70;
      UpdtNsiPrimePartData (
         pPrime_ind         => pPrime_ind,
         pNsi_sid           => nsiSid,
         pPartNo            => pPart_no,
         pNsn               => pNsn,
         pItem_type         => pItem_type,
         pOrder_quantity    => pOrder_quantity,
         pPlannerCode       => pPlanner_code,
         pSmr_code          => pSmr_code,
         pMic_code_lowest   => pMic_code_lowest,
         pAction_code       => amd_defaults.UPDATE_ACTION,
         pReturn_code       => amd_spare_parts_pkg.UPDATE_NATSTK_ERR,
         pMmac              => pMmac);

      lineNumber := 80;
      amd_spare_parts_pkg.UpdateAmdNsn (pNsn_type   => pNsn_type,
                                        pNsi_sid    => nsiSid,
                                        pNsn        => pNsn);

      lineNumber := 90;

      IF pNsn IS NOT NULL
      THEN
         UpdateNatStkItem (pNsn, amd_defaults.UPDATE_ACTION, pPart_no);
      END IF;

      -- Update amd_national_stock_items.action_code = 'D' for any other
      -- nsi_sid this part came off of that has no parts assigned to it.
      -- An nsi_sid w/o assigned parts is a "deleted" nsi_sid.
      --
      lineNumber := 100;
      debugMsg ('updating action code to D', pError_location => 930);

      UPDATE amd_national_stock_items
         SET action_code = 'D', last_update_dt = SYSDATE
       WHERE     action_code != 'D'
             AND nsi_sid IN
                    (SELECT nsi_sid
                       FROM amd_nsi_parts
                      WHERE part_no = pPart_no AND nsi_sid != nsiSid
                     MINUS
                     SELECT nsi_sid
                       FROM amd_nsi_parts
                      WHERE     nsi_sid IN (SELECT nsi_sid
                                              FROM amd_nsi_parts
                                             WHERE part_no = pPart_no)
                            AND unassignment_date IS NULL);

      updateFlags (pPart_no, is_spo_part);


      lineNumber := 110;
      RETURN result;
   EXCEPTION
      WHEN OTHERS
      THEN
         ErrorMsg (pSqlfunction      => 'updateRow',
                   pError_location   => 940,
                   pKey_1            => lineNumber);
         RETURN mRC;
   END UpdateRow;


   FUNCTION DeleteRow (pPart_no        IN VARCHAR2,
                       pNomenclature   IN VARCHAR2,
                       pMfgr           IN VARCHAR2)
      RETURN NUMBER
   IS
      result        NUMBER := SUCCESS;
      nsn           amd_spare_parts.nsn%TYPE := NULL;
      is_spo_part   amd_spare_parts.is_spo_part%TYPE;

      /* Put a wrapper on the amd_utils.InsertErrorMsg procedure, so it is
          more specific to the DeleteRow function.  Output gets stored
          into amd_load_details and amd_load_status.
      */

      FUNCTION GetNsn
         RETURN amd_spare_parts.nsn%TYPE
      IS
         nsn   amd_spare_parts.nsn%TYPE := NULL;
      BEGIN
         SELECT nsn
           INTO nsn
           FROM amd_spare_parts
          WHERE part_no = pPart_no;

         RETURN nsn;
      END GetNsn;
   BEGIN
      debugMsg ('amd_spare_parts.deleteRow: ' || pPart_no,
                pError_location   => 950);

      mArgs :=
            'DeleteRow('
         || pPart_no
         || ', '
         || pMfgr
         || ', '
         || pNomenclature
         || ')';


      insertLoadDetail (pPart_No,
                        'nsn',
                        'pPrimeInd',
                        'Delete');
      nsn := GetNsn ();

     -- nsn is NULLed to facilitate temp nsns turning into current nsns. When a
     -- temp nsn becomes current the nsn/nsi_sid association needs to be broken
     -- and this helps facilitate that when it may happen at a later time.
     --
     <<updateAmdSpareParts>>
      BEGIN
         UPDATE amd_spare_parts
            SET action_code = amd_defaults.DELETE_ACTION,
                nsn = NULL,
                last_update_dt = SYSDATE
          WHERE part_no = pPart_no;
      EXCEPTION
         WHEN OTHERS
         THEN
            ErrorMsg (pSqlfunction      => 'update',
                      pTableName        => 'amd_spare_parts',
                      pError_location   => 960,
                      pKey_1            => pPart_no);
            RAISE;
      END updateAmdSpareParts;

      unassignPart (pPart_no);

      IF nsn IS NOT NULL
      THEN
         UpdateNatStkItem (nsn, amd_defaults.DELETE_ACTION);
      ELSE
         result := SUCCESS;
      END IF;

      updateFlags (pPart_no, is_spo_part);

      debugMsg ('amd_spare_parts.deleteRow: ' || pPart_no,
                pError_location   => 970);
      RETURN result;
   EXCEPTION
      WHEN OTHERS
      THEN
         ErrorMsg (pSqlfunction => 'deleteRow', pError_location => 980);
         RETURN mRC;
   END DeleteRow;

   FUNCTION getQtyDue (primePartNo IN VARCHAR2)
      RETURN NUMBER
   IS
      qtyDue     NUMBER;
      thePrime   cat1.PRIME%TYPE;
   BEGIN
        SELECT SUM (qty_due) qty_due, prime_part_no
          INTO qtyDue, thePrime
          FROM tmp1, amd_national_stock_items, amd_spare_parts
         WHERE     returned_voucher IS NULL
               AND status = 'O'
               AND tcn = 'LBR'
               AND UPPER (SUBSTR (to_sc, 1, PROGRAM_ID_LL)) = PROGRAM_ID
               AND UPPER (SUBSTR (to_loc_id, 1, 3)) NOT IN
                      ('MRC', 'SUP', 'TST')
               AND to_loc_id NOT IN ('CODLGB', 'ROTLGB')
               AND tmp1.from_part = amd_spare_parts.part_no
               AND amd_spare_parts.action_code IN ('A', 'C')
               AND amd_spare_parts.nsn = amd_national_stock_items.nsn
               AND amd_national_stock_items.action_code IN ('A', 'C')
      GROUP BY prime_part_no
        HAVING prime_part_no = primePartNo;

      RETURN qtyDue;
   EXCEPTION
      WHEN STANDARD.NO_DATA_FOUND
      THEN
         RETURN 0;
   END getQtyDue;


   PROCEDURE loadCurrentBackOrder (debug IN BOOLEAN := FALSE)
   IS
      TYPE qtyDueRec IS RECORD
      (
         primePartNo   cat1.prime%TYPE,
         qtyDue        NUMBER
      );

      TYPE primePartNoTab IS TABLE OF cat1.prime%TYPE;

      primePartNos    primePartNoTab;

      TYPE qtyDueTab IS TABLE OF NUMBER;

      quantitiesDue   qtyDueTab;

      TB     CONSTANT VARCHAR2 (1) := CHR (9);                -- tab character

      curDueCnt       NUMBER := 0;
      curTmpCnt       NUMBER := 0;


      CURSOR curDue
      IS
           SELECT cat1.prime primePartNo,
                    SUM (NVL (req1.qty_due, 0) + NVL (req1.qty_reserved, 0))
                  + getQtyDue (cat1.prime)
                     DUE
             FROM req1, cat1
            WHERE     req1.select_from_part = cat1.part
                  AND req1.request_id NOT LIKE 'KIT%'
                  AND req1.mils_source_dic IS NOT NULL
                  AND req1.select_from_sc LIKE PROGRAM_ID || '%'
                  AND req1.status IN ('U',
                                      'H',
                                      'O',
                                      'R')
                  AND req1.request_priority <= 5
                  AND req1.select_from_loc_id NOT IN ('CODLGB', 'ROTLGB')
                  AND SUBSTR (req1.select_from_loc_id, 1, 3) NOT IN
                         ('MRC', 'SUP', 'TST')
                  AND cat1.SOURCE_CODE = amd_defaults.getSourceCode
         GROUP BY cat1.prime;

      CURSOR curTmp1QtyDue
      IS
         SELECT prime_part_no primePartNo, qty_due qtyDue
           FROM (  SELECT SUM (qty_due) qty_due, prime prime_part_no
                     FROM tmp1,
                          cat1,
                          amd_national_stock_items,
                          amd_spare_parts
                    WHERE     from_part = cat1.PART
                          AND returned_voucher IS NULL
                          AND status = 'O'
                          AND tcn = 'LBR'
                          AND SUBSTR (to_sc, 1, PROGRAM_ID_LL) = PROGRAM_ID
                          AND SUBSTR (to_loc_id, 1, 3) NOT IN
                                 ('MRC', 'SUP', 'TST')
                          AND to_loc_id NOT IN ('CODLGB', 'ROTLGB')
                          AND from_part = amd_spare_parts.part_no
                          AND amd_spare_parts.action_code IN ('A', 'C')
                          AND amd_spare_parts.nsn =
                                 amd_national_stock_items.nsn
                 GROUP BY prime)
          WHERE prime_part_no NOT IN
                   (SELECT DISTINCT cat1.prime primePartNo
                      FROM req1, cat1
                     WHERE     req1.select_from_part = cat1.part
                           AND req1.request_id NOT LIKE 'KIT%'
                           AND req1.mils_source_dic IS NOT NULL
                           AND req1.select_from_sc LIKE PROGRAM_ID || '%'
                           AND req1.status IN ('U',
                                               'H',
                                               'O',
                                               'R')
                           AND req1.request_priority <= 5
                           AND cat1.SOURCE_CODE = amd_defaults.getSourceCode);
   BEGIN
      writeMsg (
         pTableName        => 'amd_spare_parts',
         pError_location   => 990,
         pKey1             => 'loadCurrentBackorder',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      UPDATE amd_national_stock_items
         SET current_backorder = NULL;

      writeMsg (
         pTableName        => 'amd_spare_parts',
         pError_location   => 1000,
         pKey1             => 'curDue',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      COMMIT;

      OPEN curDue;

      FETCH curDue BULK COLLECT INTO primePartNos, quantitiesDue;

      CLOSE curDue;

      IF primePartNos.FIRST IS NOT NULL
      THEN
         FORALL indx IN primePartNos.FIRST .. primePartNos.LAST
            UPDATE amd_national_stock_items
               SET current_backorder = quantitiesDue (indx)
             WHERE prime_part_no = primePartNos (indx);
      END IF;

      curDueCnt := SQL%ROWCOUNT;
      DBMS_OUTPUT.put_line (
            'loadCurrentBackOrder: '
         || curDueCnt
         || ' rows updated for amd_national_stock_items');
      writeMsg (
         pTableName        => 'amd_spare_parts',
         pError_location   => 1010,
         pKey1             => 'curDue',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
         pKey3             => 'curDueCnt=' || TO_CHAR (curDueCnt));
      COMMIT;

      writeMsg (
         pTableName        => 'amd_spare_parts',
         pError_location   => 1020,
         pKey1             => 'curTmp1QtyDue',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      OPEN curTmp1QtyDue;

      FETCH curTmp1QtyDue BULK COLLECT INTO primePartNos, quantitiesDue;

      CLOSE curTmp1QtyDue;

      IF primePartNos.FIRST IS NOT NULL
      THEN
         FORALL indx IN primePartNos.FIRST .. primePartNos.LAST
            UPDATE amd_national_stock_items
               SET current_backorder = quantitiesDue (indx)
             WHERE prime_part_no = primePartNos (indx);
      END IF;

      curTmpCnt := SQL%ROWCOUNT;

      writeMsg (
         pTableName        => 'amd_spare_parts',
         pError_location   => 1030,
         pKey1             => 'curTmp1QtyDue',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
         pKey3             => 'curTmpCnt=' || TO_CHAR (curTmpCnt));

      writeMsg (
         pTableName        => 'amd_spare_parts',
         pError_location   => 1040,
         pKey1             => 'loadCurrentBackorder',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
         pKey3             => 'curDueCnt=' || TO_CHAR (curDueCnt),
         pKey4             => 'curTmpCnt=' || TO_CHAR (curTmpCnt));

      COMMIT;
   END loadCurrentBackOrder;



   PROCEDURE version
   IS
   BEGIN
      writeMsg (pTableName        => 'amd_spare_parts_pkg',
                pError_location   => 1050,
                pKey1             => 'amd_spare_parts_pkg',
                pKey2             => '$Revision:   1.125  $');
      DBMS_OUTPUT.put_line ('amd_spare_parts_pkg: $Revision:   1.125  $');
   END version;

   FUNCTION getVersion
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN '$Revision:   1.125  $';
   END getVersion;

   PROCEDURE setDebug (switch IN VARCHAR2)
   IS
   BEGIN
      mDebug :=
         UPPER (switch) IN ('Y',
                            'T',
                            'YES',
                            'TRUE');

      IF mDebug
      THEN
         DBMS_OUTPUT.ENABLE (100000);
      ELSE
         DBMS_OUTPUT.DISABLE;
      END IF;
   END setDebug;

   FUNCTION getDebugYorN
      RETURN VARCHAR2
   IS
   BEGIN
      IF mDebug
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END getDebugYorN;

   -- used to be a2a code

   FUNCTION isNsnInIsgPairs (nsn          IN amd_spare_parts.nsn%TYPE,
                             showReason   IN BOOLEAN := FALSE)
      RETURN BOOLEAN
   IS
      result   BOOLEAN := FALSE;
   BEGIN
     <<tryOldNsn>>
      DECLARE
         CURSOR old_nsns
         IS
            SELECT old_nsn
              FROM bssm_isg_pairs
             WHERE old_nsn = isNsnInIsgPairs.nsn AND lock_sid = 0;
      BEGIN
         FOR rec IN old_nsns
         LOOP
            result := TRUE;
            EXIT WHEN TRUE;
         END LOOP;

         IF NOT result
         THEN
           <<tryNewNsn>>
            DECLARE
               CURSOR new_nsns
               IS
                  SELECT new_nsn
                    FROM bssm_isg_pairs
                   WHERE new_nsn = isnsninisgpairs.nsn AND lock_sid = 0;
            BEGIN
               FOR rec IN new_nsns
               LOOP
                  result := TRUE;
                  EXIT WHEN TRUE;
               END LOOP;
            EXCEPTION
               WHEN OTHERS
               THEN
                  ErrorMsg (pSqlfunction      => 'select',
                            pTableName        => 'bssm_isg_pairs',
                            pError_location   => 1060,
                            pKey_1            => isNsnInIsgPairs.nsn);
                  RAISE;
            END tryNewNsn;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            ErrorMsg (pSqlfunction      => 'select',
                      pTableName        => 'bssm_isg_pairs',
                      pError_location   => 1070,
                      pKey_1            => isNsnInIsgPairs.nsn);
            RAISE;
      END tryOldNsn;

      IF result
      THEN
         NULL;                                                   -- do nothing
      ELSE
         debugMsg ('Nsn is NOT in ISG Pairs', 50);

         IF showReason
         THEN
            DBMS_OUTPUT.put_line ('Nsn is NOT in ISG Pairs');
         END IF;
      END IF;

      RETURN result;
   END isNsnInIsgPairs;

   FUNCTION isNsnInIsgPairsYorN (nsn          IN amd_spare_parts.nsn%TYPE,
                                 showReason   IN BOOLEAN := FALSE)
      RETURN VARCHAR2
   IS
   BEGIN
      IF isNsnInIsgPairs (nsn, showReason)
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END isNsnInIsgPairsYorN;


   FUNCTION isNsnInRblPairs (nsn          IN amd_spare_parts.nsn%TYPE,
                             showReason   IN BOOLEAN := FALSE)
      RETURN BOOLEAN
   IS
      result   BOOLEAN := FALSE;
   BEGIN
     <<tryOldNsn>>
      DECLARE
         CURSOR old_nsns
         IS
            SELECT old_nsn
              FROM amd_rbl_pairs
             WHERE old_nsn = isNsnInRblPairs.nsn;
      BEGIN
         FOR rec IN old_nsns
         LOOP
            result := TRUE;
            EXIT WHEN TRUE;
         END LOOP;

         IF NOT result
         THEN
           <<tryNewNsn>>
            DECLARE
               CURSOR new_nsns
               IS
                  SELECT new_nsn
                    FROM amd_rbl_pairs
                   WHERE new_nsn = isNsnInRblPairs.nsn;
            BEGIN
               FOR rec IN new_nsns
               LOOP
                  result := TRUE;
                  EXIT WHEN TRUE;
               END LOOP;
            EXCEPTION
               WHEN OTHERS
               THEN
                  ErrorMsg (pSqlfunction      => 'select',
                            pTableName        => 'amd_rbl_pairs',
                            pError_location   => 1080,
                            pKey_1            => isNsnInRblPairs.nsn);
                  RAISE;
            END tryNewNsn;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            ErrorMsg (pSqlfunction      => 'select',
                      pTableName        => 'amd_rbl_pairs',
                      pError_location   => 1090,
                      pKey_1            => isNsnInRblPairs.nsn);
            RAISE;
      END tryOldNsn;

      IF result
      THEN
         NULL;                                                   -- do nothing
      ELSE
         debugMsg (isNsnInRblPairs.nsn || ' Nsn is NOT valid', 40);

         IF showReason
         THEN
            DBMS_OUTPUT.put_line (
               isNsnInRblPairs.nsn || ' Nsn is NOT in Rbl Pairs');
         END IF;
      END IF;

      RETURN result;
   EXCEPTION
      WHEN OTHERS
      THEN
         ErrorMsg (pSqlfunction      => 'isNsnInRblPairs',
                   pTableName        => 'amd_rbl_pairs',
                   pError_location   => 1100,
                   pKey_1            => isNsnInRblPairs.nsn);

         RAISE;
   END isNsnInRblPairs;

   FUNCTION isNsnInRblPairsYorN (nsn          IN amd_spare_parts.nsn%TYPE,
                                 showReason   IN BOOLEAN := FALSE)
      RETURN VARCHAR2
   IS
   BEGIN
      IF isNsnInRblPairs (nsn, showReason)
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END isNsnInRblPairsYorN;

   FUNCTION inventoryExists (part_no      IN amd_spare_parts.part_no%TYPE,
                             showReason   IN BOOLEAN := FALSE)
      RETURN BOOLEAN
   IS
      result        NUMBER := 0;
      primePartNo   AMD_NATIONAL_STOCK_ITEMS.prime_part_no%TYPE;
   BEGIN
     <<getPrimePartNo>>
      BEGIN
         SELECT items.prime_part_no
           INTO primePartNo
           FROM amd_national_stock_items items, amd_spare_parts parts
          WHERE     inventoryExists.part_no = parts.part_no
                AND parts.nsn = items.nsn;
      EXCEPTION
         WHEN OTHERS
         THEN
            ErrorMsg (pSqlfunction      => 'select',
                      pTableName        => 'amd_spare_parts',
                      pError_location   => 1110,
                      pKey_1            => inventoryExists.part_no);
            RAISE;
      END getPrimePartNo;

     <<doesDataExist>>
      BEGIN
         SELECT 1
           INTO result
           FROM DUAL
          WHERE    EXISTS
                      (SELECT *
                         FROM amd_on_hand_invs oh
                        WHERE     primepartno = oh.part_no
                              AND oh.action_code !=
                                     amd_defaults.delete_action
                              AND oh.inv_qty > 0)
                OR EXISTS
                      (SELECT *
                         FROM amd_in_repair ir
                        WHERE     primepartno = ir.part_no
                              AND ir.action_code !=
                                     amd_defaults.delete_action
                              AND ir.repair_qty > 0)
                OR EXISTS
                      (SELECT *
                         FROM amd_on_order oo
                        WHERE     primepartno = oo.part_no
                              AND oo.action_code !=
                                     amd_defaults.delete_action
                              AND oo.order_qty > 0)
                OR EXISTS
                      (SELECT *
                         FROM amd_in_transits it
                        WHERE     primepartno = it.part_no
                              AND it.action_code !=
                                     amd_defaults.delete_action
                              AND it.quantity > 0);
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            NULL;
         WHEN OTHERS
         THEN
            IF SQLCODE = -4091
            THEN
               raise_application_error (
                  -20050,
                  SUBSTR (1, 2000, '29 ' || inventoryExists.part_No));
            ELSE
               ErrorMsg (pSqlfunction      => 'select',
                         pTableName        => 'exist',
                         pError_location   => 1120,
                         pKey_1            => inventoryExists.part_No);
            END IF;

            RAISE;
      END doesDataExist;

      IF result > 0
      THEN
         NULL;                                                   -- do nothing
      ELSE
         debugMsg (
            'Inventory does NOT exist for ' || inventoryExists.part_No,
            20);

         IF showReason
         THEN
            DBMS_OUTPUT.put_line (
               'Inventory does NOT exist for ' || inventoryExists.part_No);
         END IF;
      END IF;

      RETURN (result > 0);
   EXCEPTION
      WHEN OTHERS
      THEN
         ErrorMsg (pSqlfunction      => 'selects',
                   pTableName        => 'inventoryExists',
                   pError_location   => 1130,
                   pKey_1            => part_no);

         RAISE;
   END inventoryExists;

   FUNCTION inventoryExistsYorN (part_no      IN amd_spare_parts.part_no%TYPE,
                                 showReason   IN BOOLEAN := FALSE)
      RETURN VARCHAR2
   IS
   BEGIN
      IF inventoryExists (part_no, showReason)
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         ErrorMsg (pSqlfunction      => 'selects',
                   pTableName        => 'inventoryExistsYorN',
                   pError_location   => 1140,
                   pKey_1            => part_no);

         RAISE;
   END inventoryExistsYorN;

   FUNCTION isNsnValid (part_no      IN amd_spare_parts.part_no%TYPE,
                        showReason   IN BOOLEAN := FALSE)
      RETURN BOOLEAN
   IS
      nsn   amd_spare_parts.nsn%TYPE;
   BEGIN
     <<getNsn>>
      BEGIN
         SELECT parts.nsn
           INTO isNsnValid.nsn
           FROM amd_spare_parts parts
          WHERE isNsnValid.part_no = parts.part_no;
      EXCEPTION
         WHEN OTHERS
         THEN
            ErrorMsg (pSqlfunction      => 'select',
                      pTableName        => 'amd_spare_parts',
                      pError_location   => 1150,
                      pKey_1            => isNsnValid.part_no,
                      pKey_2            => nsn);
            RAISE;
      END getNsn;

      RETURN    isNsnInRblPairs (nsn, showReason)
             OR isNsnInIsgPairs (nsn, showReason);
   EXCEPTION
      WHEN STANDARD.NO_DATA_FOUND
      THEN
         RETURN FALSE;
   END isNsnValid;

   FUNCTION isNsnValidYorN (part_no      IN amd_spare_parts.part_no%TYPE,
                            showReason   IN BOOLEAN := FALSE)
      RETURN VARCHAR2
   IS
   BEGIN
      IF isNsnValid (part_no, showReason)
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END isNsnValidYorN;


   FUNCTION demandExists (part_no      IN amd_spare_parts.part_no%TYPE,
                          showReason   IN BOOLEAN := FALSE)
      RETURN BOOLEAN
   IS
      result   NUMBER := 0;
   BEGIN
      SELECT 1
        INTO result
        FROM DUAL
       WHERE EXISTS
                (SELECT *
                   FROM amd_demands demands,
                        amd_national_stock_items items,
                        amd_spare_parts parts
                  WHERE     demandexists.part_no = parts.part_no
                        AND parts.action_code != amd_defaults.delete_action
                        AND parts.nsn = items.nsn
                        AND items.action_code != amd_defaults.delete_action
                        AND items.nsi_sid = demands.nsi_sid
                        AND demands.quantity > 0
                        AND demands.action_code != amd_defaults.delete_action);

      IF result > 0
      THEN
         NULL;                                                  -- do  nothing
      ELSE
         debugMsg ('Demand does NOT exist for ' || demandExists.part_no, 10);

         IF showReason
         THEN
            DBMS_OUTPUT.put_line (
               'Demand does NOT exist for ' || demandExists.part_no);
         END IF;
      END IF;

      RETURN (result > 0);
   EXCEPTION
      WHEN STANDARD.NO_DATA_FOUND
      THEN
         RETURN FALSE;
      WHEN OTHERS
      THEN
         ErrorMsg (pSqlfunction      => 'select',
                   pTableName        => 'demands / items',
                   pError_location   => 1160,
                   pKey_1            => demandExists.part_no);
         RAISE;
   END demandExists;

   FUNCTION demandExistsYorN (part_no      IN amd_spare_parts.part_no%TYPE,
                              showReason   IN BOOLEAN := FALSE)
      RETURN VARCHAR2
   IS
   BEGIN
      IF demandExists (part_no, showReason)
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END demandExistsYorN;

   FUNCTION isNsl (partNo IN AMD_SPARE_PARTS.part_no%TYPE)
      RETURN BOOLEAN
   IS
      nsn   AMD_SPARE_PARTS.nsn%TYPE;
   BEGIN
     <<getNsn>>
      BEGIN
         SELECT nsn
           INTO isNsl.nsn
           FROM AMD_SPARE_PARTS
          WHERE partNo = part_no;
      EXCEPTION
         WHEN OTHERS
         THEN
            ErrorMsg (pSqlfunction      => 'select',
                      pTableName        => 'amd_spare_parts',
                      pError_location   => 1170,
                      pKey_1            => partNo);
            RAISE;
      END getNsn;

      RETURN UPPER (SUBSTR (nsn, 1, 3)) = amd_defaults.getNonStockageList;
   END isNsl;

   FUNCTION isNslYorN (partNo IN AMD_SPARE_PARTS.part_no%TYPE)
      RETURN VARCHAR2
   IS
   BEGIN
      IF isNsl (partNo)
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END isNslYorN;

   FUNCTION isPlannerCodeValid (
      plannerCode   IN amd_national_stock_items.planner_code%TYPE,
      showReason    IN BOOLEAN := FALSE)
      RETURN BOOLEAN
   IS
      isValid   BOOLEAN := FALSE;
   BEGIN
      IF plannerCode IS NOT NULL
      THEN
         IF LENGTH (plannerCode) >= 2
         THEN
            isValid :=
                   UPPER (SUBSTR (plannerCode, 1, 2)) != 'KE'
               AND UPPER (SUBSTR (plannerCode, 1, 2)) != 'SE';

            IF isValid
            THEN
               IF LENGTH (plannerCode) >= 3
               THEN
                  isValid := UPPER (SUBSTR (plannerCode, 1, 3)) != 'AFD';
               ELSE
                  isValid := TRUE;
               END IF;
            END IF;
         ELSE
            isValid := TRUE;
         END IF;
      END IF;

      IF isValid
      THEN
         NULL;                                                   -- do nothing
      ELSE
         debugMsg (plannerCode || ' Planner code is NOT valid', 10);

         IF showReason
         THEN
            DBMS_OUTPUT.put_line (
               plannerCode || ' Planner code is NOT valid');
         END IF;
      END IF;

      RETURN isValid;
   END isPlannerCodeValid;

   FUNCTION isPlannerCodeValidYorN (
      plannerCode   IN amd_national_stock_items.planner_code%TYPE,
      showReason    IN BOOLEAN := FALSE)
      RETURN VARCHAR2
   IS
   BEGIN
      IF isPlannerCodeValid (plannerCode, showReason)
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END isPlannerCodeValidYorN;

   FUNCTION getAcquisitionAdviceCode (
      part_no   IN amd_spare_parts.part_no%TYPE)
      RETURN VARCHAR2
   IS
      theCode   AMD_SPARE_PARTS.ACQUISITION_ADVICE_CODE%TYPE;
   BEGIN
      mArgs := 'getAcquisitionAdviceCode(' || part_no || ')';

      SELECT acquisition_advice_code
        INTO theCode
        FROM AMD_SPARE_PARTS
       WHERE part_no = getAcquisitionAdviceCode.part_No;

      mArgs := 'theCode=' || theCode;
      RETURN UPPER (theCode);
   EXCEPTION
      WHEN STANDARD.NO_DATA_FOUND
      THEN
         mArgs := 'getAcquisitionAdviceCode: no data found for ' || part_no;
         RETURN NULL;
      WHEN OTHERS
      THEN
         ErrorMsg (pSqlfunction      => 'select',
                   pTableName        => 'amd_spare_parts',
                   pError_location   => 1180,
                   pKey_1            => part_no);
         RAISE;
   END getAcquisitionAdviceCode;


   FUNCTION isValidRepairablePart (partNo       IN AMD_SPARE_PARTS.part_no%TYPE,
                                   showReason   IN BOOLEAN := FALSE)
      RETURN BOOLEAN
   IS
      result               BOOLEAN := FALSE;
      nsn                  amd_national_stock_items.nsn%TYPE;
      smrCode              AMD_NATIONAL_STOCK_ITEMS.smr_code%TYPE;
      smrCodeCleaned       AMD_NATIONAL_STOCK_ITEMS.smr_code_cleaned%TYPE;
      mtbdr                AMD_NATIONAL_STOCK_ITEMS.mtbdr%TYPE;
      mtbdr_cleaned        AMD_NATIONAL_STOCK_ITEMS.mtbdr_cleaned%TYPE;
      mtbdr_computed       AMD_NATIONAL_STOCK_ITEMS.mtbdr_computed%TYPE;
      plannerCode          AMD_NATIONAL_STOCK_ITEMS.planner_code%TYPE;
      part_no              AMD_SPARE_PARTS.part_no%TYPE;
      plannerCodeCleaned   AMD_NATIONAL_STOCK_ITEMS.planner_code_cleaned%TYPE;
   BEGIN
     <<doesPartExist>>
      BEGIN
         SELECT part_no
           INTO isValidRepairablePart.part_no
           FROM AMD_SPARE_PARTS
          WHERE     partNo = part_no
                AND action_code != Amd_Defaults.DELETE_ACTION;
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            RETURN FALSE;
      END doesPartExist;

      IF amd_utils.isPartConsumable (partNo)
      THEN
         RETURN CONSUMABLES_PKG.ISPARTVALID (partNo);
      END IF;

     <<getPrimePartData>>
      BEGIN
         SELECT nsn,
                smr_code,
                smr_code_cleaned,
                mtbdr,
                mtbdr_cleaned,
                mtbdr_computed,
                planner_code,
                planner_code_cleaned
           INTO nsn,
                smrCode,
                smrCodeCleaned,
                mtbdr,
                mtbdr_cleaned,
                mtbdr_computed,
                plannerCode,
                plannerCodeCleaned
           FROM AMD_NATIONAL_STOCK_ITEMS items, AMD_NSI_PARTS parts
          WHERE     isValidRepairablePart.partNo = parts.part_no
                AND parts.UNASSIGNMENT_DATE IS NULL
                AND parts.nsi_sid = items.nsi_sid;
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            RETURN FALSE;
         WHEN OTHERS
         THEN
            ErrorMsg (pSqlfunction      => 'select',
                      pTableName        => 'items / parts',
                      pError_location   => 1190,
                      pKey_1            => isValidRepairablePart.partNo);
            RAISE;
      END getPrimePartData;

      RETURN isValidRepairablePart (
                partNo                 => partNo,
                preferredSmrCode       => Amd_Preferred_Pkg.getPreferredValue (
                                            smrCodeCleaned,
                                            smrCode),
                preferredMtbdr         => Amd_Preferred_Pkg.getPreferredValue (
                                            mtbdr_cleaned,
                                            mtbdr_computed,
                                            mtbdr),
                preferredPlannerCode   => Amd_Preferred_Pkg.GetPreferredValue (
                                            plannerCodeCleaned,
                                            plannerCode,
                                            amd_defaults.getPlannerCode (nsn)),
                showReason             => showReason);
   END isValidRepairablePart;

   FUNCTION isValidRepairablePartYorN (
      partNo                 IN VARCHAR2,
      preferredSmrCode       IN VARCHAR2,
      preferredMtbdr         IN NUMBER,
      preferredPlannerCode   IN VARCHAR2,
      showReason             IN VARCHAR2 := 'F')
      RETURN VARCHAR2
   IS
   BEGIN
      IF isValidRepairablePart (partNo,
                                preferredSmrCode,
                                preferredMtbdr,
                                preferredPlannerCode,
                                UPPER (showReason) IN ('T',
                                                       'Y',
                                                       'YES',
                                                       'TRUE'))
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END isValidRepairablePartYorN;

   FUNCTION isValidRepairablePart (
      partNo                 IN VARCHAR2,
      preferredSmrCode       IN VARCHAR2,
      preferredMtbdr         IN NUMBER,
      preferredPlannerCode   IN VARCHAR2,
      showReason             IN BOOLEAN := FALSE)
      RETURN BOOLEAN
   IS
      result   BOOLEAN := FALSE;
      nsn      amd_spare_parts.nsn%TYPE;
      lineNo   NUMBER := 0;
   BEGIN
      lineNo := 10;

      IF NOT amd_utils.isPartActive (partno)
      THEN
         IF showReason
         THEN
            DBMS_OUTPUT.put_line (partNo || ' is not active');
         END IF;

         RETURN FALSE;
      END IF;

      lineNo := 20;

      IF    UPPER (partNo) = 'F117-PW-100'
         OR INSTR (UPPER (partNo), '17L8D') > 0
         OR INSTR (UPPER (partNo), '17R9Y') > 0
         OR INSTR (UPPER (preferredSmrCode), 'PE') > 0
      THEN
         IF showReason
         THEN
            DBMS_OUTPUT.put_line (
                  partNo
               || ' fails test: UPPER(partNo) = F117-PW-100 OR INSTR(UPPER(partNo),17L8D) > 0 OR INSTR(UPPER(partNo),17R9Y) > 0 OR INSTR(UPPER(preferredSmrCode),PE) > 0');
         END IF;

         RETURN FALSE;
      END IF;

      lineNo := 30;

      IF getAcquisitionAdviceCode (partNo) = 'Y'
      THEN
         IF showReason
         THEN
            DBMS_OUTPUT.put_line (
               partNo || ' has an acquisition advice code of Y');
         END IF;

         RETURN FALSE;
      END IF;

      lineNo := 40;
      result := amd_utils.isRepairableSmrCode (preferredSmrCode);

      IF NOT result
      THEN
         debugmsg (preferredSmrCode || ' is NOT a repairable smr code', 70);

         IF showreason
         THEN
            DBMS_OUTPUT.put_line (
               preferredSmrCode || ' is NOT a repairable smr code');
         END IF;
      END IF;

      lineNo := 50;
      result := result AND isPlannerCodeValid (preferredPlannerCode);

      IF NOT result AND showReason
      THEN
         DBMS_OUTPUT.put_line (
               partNo
            || ' does not have a valid planner code: '
            || preferredPlannerCode);
      END IF;

      IF result AND isNsl (partNo)
      THEN
         IF     showReason
            AND (preferredMtbdr IS NOT NULL AND preferredMtbdr > 0)
         THEN
            DBMS_OUTPUT.put_line ('mtbdr > 0 for part ' || partNo);
         END IF;

         lineNo := 60;
         result :=
                result
            AND (   demandExists (partNo, showReason)
                 OR inventoryExists (partNo, showReason)
                 OR (preferredMtbdr IS NOT NULL AND preferredMtbdr > 0)
                 OR isNsnValid (partNo, showReason));
      END IF;

      IF result
      THEN
         NULL;                                                   -- do nothing
      ELSE
         debugMsg ('part ' || partNo || ' is NOT valid.', 80);

         IF showReason
         THEN
            DBMS_OUTPUT.put_line ('part ' || partNo || ' is NOT valid.');
         END IF;
      END IF;

      lineNo := 70;
      RETURN result;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF SQLCODE = -20000
         THEN
            DBMS_OUTPUT.disable;                   -- buffer overflow, disable
            RETURN isValidRepairablePart (partno);     -- try validation again
         END IF;

         ErrorMsg (pSqlfunction      => 'selects',
                   pTableName        => 'isValidRepairablePart',
                   pError_location   => 1200,
                   pKey_1            => lineNo);

         RAISE;
   END isValidRepairablePart;


   FUNCTION isValidConsumablePart (
      part_no        IN VARCHAR2,
      smr_code       IN amd_national_stock_items.smr_code%TYPE,
      nsn            IN amd_spare_parts.nsn%TYPE,
      planner_code   IN amd_national_stock_items.planner_code%TYPE,
      mtbdr          IN amd_national_stock_items.MTBDR%TYPE)
      RETURN BOOLEAN
   IS
      result   BOOLEAN := FALSE;

      lineNo   NUMBER := 0;
   BEGIN
      -- ToDo: change all literals and tests to be specifically for consumables

      lineNo := 20;

      IF NOT amd_utils.isPartActive (part_no)
      THEN
         RETURN FALSE;
      END IF;

      IF    UPPER (part_No) = 'F117-PW-100'
         OR INSTR (UPPER (part_no), '17L8D') > 0
         OR INSTR (UPPER (part_no), '17R9Y') > 0
         OR INSTR (UPPER (smr_code), 'PE') > 0
      THEN
         RETURN FALSE;
      END IF;


      lineNo := 30;

      IF getAcquisitionAdviceCode (part_no) = 'Y'
      THEN
         RETURN FALSE;
      END IF;

      lineNo := 40;
      result :=
         amd_utils.isPartConsumable (preferred_smr_code       => smr_code,
                                     preferred_planner_code   => planner_code,
                                     nsn                      => nsn);

      IF NOT result
      THEN
         IF mDebug
         THEN
            DBMS_OUTPUT.put_line (smr_code || ' is NOT a valid smr code');
         END IF;
      END IF;

      lineNo := 50;
      result := result AND isPlannerCodeValid (planner_Code);

      IF result AND isNsl (part_no)
      THEN
         IF mdebug AND (mtbdr IS NOT NULL AND mtbdr > 0)
         THEN
            DBMS_OUTPUT.put_line ('mtbdr > 0 for part ' || part_no);
         END IF;

         lineNo := 60;
         result :=
                result
            AND (   demandExists (part_no, mdebug)
                 OR inventoryExists (part_no, mdebug)
                 OR (mtbdr IS NOT NULL AND mtbdr > 0)
                 OR isNsnValid (part_no, mdebug));
      END IF;

      IF NOT result
      THEN
         IF mdebug
         THEN
            DBMS_OUTPUT.put_line ('part ' || part_no || ' is NOT valid.');
         END IF;
      END IF;

      RETURN result;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF SQLCODE = -20000
         THEN
            DBMS_OUTPUT.disable;                   -- buffer overflow, disable
            RETURN isValidConsumablePart (part_no);    -- try validation again
         ELSE
            errorMsg (pSqlfunction      => 'select',
                      pTableName        => 'isValidConsumablePart',
                      pError_location   => 1210,
                      pKey_1            => part_no,
                      pKey_2            => lineNo);
            RAISE;
         END IF;
   END isValidConsumablePart;

   FUNCTION isValidConsumablePartYorN (
      part_no        IN VARCHAR2,
      smr_code       IN amd_national_stock_items.smr_code%TYPE,
      nsn            IN amd_spare_parts.nsn%TYPE,
      planner_code   IN amd_national_stock_items.planner_code%TYPE,
      mtbdr          IN amd_national_stock_items.MTBDR%TYPE)
      RETURN VARCHAR2
   IS
   BEGIN
      IF isValidConsumablePart (part_no,
                                smr_code,
                                nsn,
                                planner_code,
                                mtbdr)
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END isValidConsumablePartYorN;

   PROCEDURE getPartInfoData (
      part_no        IN     amd_spare_parts.part_no%TYPE,
      smr_code          OUT amd_national_stock_items.smr_code%TYPE,
      nsn               OUT amd_spare_parts.nsn%TYPE,
      planner_code      OUT amd_national_stock_items.planner_code%TYPE,
      mtbdr             OUT amd_national_stock_items.MTBDR%TYPE)
   IS
      nsi_sid   amd_national_stock_items.nsi_sid%TYPE;
   BEGIN
      debugMsg ('getPartInfoData: ' || part_no, pError_location => 1220);

      SELECT items.smr_code,
             items.nsn,
             items.mtbdr,
             items.nsi_sid
        INTO smr_code,
             nsn,
             mtbdr,
             nsi_sid
        FROM amd_spare_parts parts, amd_national_stock_items items
       WHERE     getPartInfoData.part_no = parts.part_no
             AND parts.nsn = items.nsn;

      planner_code := amd_preferred_pkg.getPlannerCode (nsi_sid);
   EXCEPTION
      WHEN STANDARD.NO_DATA_FOUND
      THEN
         RETURN;
      WHEN OTHERS
      THEN
         errorMsg (
            pSqlfunction      => 'select',
            pTableName        => 'amd_spare_parts/amd_national_stock_items',
            pError_location   => 1230,
            pKey_1            => part_no);
         RAISE;
   END getPartInfoData;

   FUNCTION isValidConsumablePart (part_no IN VARCHAR2)
      RETURN BOOLEAN
   IS
      smr_code       amd_national_stock_items.smr_code%TYPE;
      nsn            amd_spare_parts.nsn%TYPE;
      planner_code   amd_national_stock_items.planner_code%TYPE;
      mtbdr          amd_national_stock_items.MTBDR%TYPE;
   BEGIN
      getPartInfoData (part_no,
                       smr_code,
                       nsn,
                       planner_code,
                       mtbdr);

      debugMsg (
            'isPartVaid: '
         || part_no
         || ' '
         || smr_code
         || ' '
         || nsn
         || ' '
         || planner_code
         || ' '
         || mtbdr,
         pError_location   => 1240);

      RETURN isValidConsumablePart (part_no,
                                    smr_code,
                                    nsn,
                                    planner_code,
                                    mtbdr);
   END isValidConsumablePart;

   FUNCTION isValidConsumablePartYorN (part_no IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      IF isValidConsumablePart (part_no)
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END isValidConsumablePartYorN;
END amd_spare_parts_pkg;
/