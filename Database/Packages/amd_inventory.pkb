/* Formatted on 11/21/2017 11:56:12 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY AMD_OWNER.Amd_Inventory
AS
   /* ------------------------------------------------------------------- */
   /*  this program extracts data from gold and generate records for the  */
   /*  amd_spare_invs table for the boeing icp parts which have been      */
   /*  loaded in the amd_spare_parts.                                     */
   /*                                                                     */
   /*  this program also generates data for amd_repair_levels and         */
   /*  amd_main_task_distribs table.                                      */
   /* ------------------------------------------------------------------- */
   /*
       PVCS Keywords

      $Author:   Douglas S Elder
    $Revision:   1.121
        $Date:   21 Nov 2017
    $Workfile:   amd_inventory.pkb  $

         Rev 1.121 21 Nov 2017 added dbms_output for all raise commands

         Rev 1.120 24 Aug 2017 per Laurie Compton's email for 8/23/2017 regarding
                              TFS 38300 removed rsp_level > 0 for loadRsp's cursor
                              rspInv

         Rev 1.119 24 Jan 2017 added dbms_output for inserts

         Rev 1.118 17 Jun 2016 reformatted code

         Rev 1.117 Per CQ LBPSS00003520 removed amd_order_prefixes

         Rev 1.116.1  29 Sep 2015 DSE removed redundant check for tmp1.from_loc_id

         Rev 1.116  28 Sep 2015 DSE for loadInRepair, loadInTransits, and loadOnHand make
         aure loc_type is NOT KIT

         Rev 1.115.1  23 Sep 2015 DSE added START_LOC_ID

         Rev 1.115  21 Sep 2015 DSE added amd_defaults.getProgramId, PROGRAM_ID and PROGRAM_ID_LL

         Rev 1.114  03 Sep 2015 DSE for loadRsp - make sure the rspInv cursor only
         gets rows with rsp_level > 0 and rsp_inv > 0

         Rev 1.113.1 18 Jun 2015 DSE use from_loc_id

         Rev 1.113 10 Jun 2015 DSE use new ramp.sran and ord1.loc_id

         Rev 1.112 17 Feb 2015 DSE use new rsp_inv_v and eliminated erroneous update /
         exception hander.  NOTE: the NO_DATA_FOUND exception will not occur
         for the UPDATE when the where clause criteria is not met, instead
         it will just not do the update.

         Rev 1.111 DSE fixed rspCnt by using sql%rowcount immediately after
         the bulk insert

         Rev 1.110 DSE added amd_defaults.getIcpInd

         Rev 1.109 DSE added whse rsp_level's to the loading to tmp_amd_rsp

         Rev 1.108 removed C from segmentt code queries used to load tmp_amd_on_hand_invs and tmp_amd_in_repair per Laurie's IM instructions

         Rev 1.107 add segregation code SATCAA0001C17G  per ClearQuest request LBPSS00003377 and make it EY1746 when loading itemsa data

        Rev 1.106 fixed itemType3aCur for loadOnOrder to check for sc ending in G or the existance of sc = amd_sc_inclusions.include_sc
        and  existance of substtr sc = sbustr amd_sc_inclusions ... exists is used so that it may be entirely empty and moved to prod

       Rev 1.105 make sure records are distinct when loading tmp_amd_in_repair from cursor itemType5Cur
       and renumbered perror's.  Removed all the truncates of a2a tables.

       Rev 1.104   9 Aug 2010    12:00    c402417
   Implemented  per Change Request # LBPSS00002722  and LBPSS00002723  requested by Laurie Compton.

      Rev 1.103    Apr 2010    09:09    c402417
   Added  'UAB' for loc_type to on_hand_invs and in_repair per Laurie's request.

     Rev 1.101   13 Jul 2009 19:06:28   zf297a
  Removed invocations of a2a procedures

     Rev 1.100   05 Jun 2009 09:50:54   zf297a
  Added WF to list of values for substr(order_no,1,2) for table ord1

     Rev 1.99   16 Feb 2009 17:39:56   zf297a
  Implement function interface isInvalidDateYorN

     Rev 1.98   14 Feb 2009 16:13:42   zf297a
  Removed code invoking  A2A's routines for package amd_location_part_override_pkg since they have been removed.

     Rev 1.97   16 Jan 2009 23:17:50   zf297a
  Added warnings for when the repair_need_date is bad and set it to null.  Added warning for when the repair_date is bad and rejected the record.

     Rev 1.96   08 Feb 2008 09:39:10   zf297a
  Thuy Pham changed cursor itemType3bCur to retrieve Open Orders from ord1 ... ie status = 'O'

     Rev 1.95   06 Feb 2008 21:25:32   zf297a
  Added implementation for interfaces for function getVersion and procedure setDebug.  Added an exception handler to getCurrentLine to help in debugging it.

     Rev 1.94   06 Feb 2008 20:28:54   zf297a
  Implemented the new getCurrentLine using the loc_sid as part of the primary key and fixed everyplace it is invoked.

     Rev 1.93   Dec 19 2007 13:14:02   c402417
  Added loc_sid part of the key for OnOrderRow, OnOrderDelete and OnOrderUpdate.

     Rev 1.92   20 Nov 2007 17:22:24   zf297a
  Use bulk insert for most inserts.

     Rev 1.91   07 Nov 2007 21:32:22   zf297a
  Use bulk collect for most cursors.

     Rev 1.90   06 Nov 2007 10:30:22   zf297a
  Make sure that the ROQ data gets sent for corresponding ROQ amd_rsp_sum quantities, since the ROQ value is not stored in amd_rsp_sum.  Send the default ROQ value.

     Rev 1.89   29 Oct 2007 12:04:02   zf297a
  Implemented doRspSumDiff interface - moved override_type from the last argument to become the 3rd argument.

     Rev 1.88   19 Oct 2007 12:13:16   zf297a
  Added argument override_type to function doRspSumDiff.  Added override_type to all where clauses for the UPDATE's.  Whenever an ROP override_type is sent to SPO update the qty by substracting one or making it the default ROP value whenever it is null or zero.

     Rev 1.87   02 May 2007 15:37:36   zf297a
  Added serviceable_flag as part of the key for amd_in_transits_sum

     Rev 1.86   06 Apr 2007 20:48:26   zf297a
  Fixed getCurrentLine interface and implemented new select

     Rev 1.85   06 Apr 2007 16:58:28   zf297a
  Added sched_receipt_date to updates of amd_on_order

     Rev 1.84   06 Apr 2007 09:58:10   zf297a
  Fixed getNextLIne.  When using the MAX aggregate function there will not be a no_data_found exception, instead a null value will be returned by MAX.  Check the "maxLine" for a null.  If maxLIne is null, set it to zero so it will get set to maxLine + 1 for the first line number.

     Rev 1.83   06 Apr 2007 09:25:52   zf297a
  Removed line from interface insertOnOrderRow, updateOnOrderRow, and deleteRow.
  Added functions getNextLine, which will return the next line number for a given gold_order_number, and getCurrentLIne, which will return the current line for the given gold_order_number.

  Changed the insertOnOrderRow to use the new getNextLine function and for updateOnOnOrderRow and deleteRow to use the new getCurrentLine function.

     Rev 1.82   05 Apr 2007 11:10:48   zf297a
  Removed all Rtrim's and added writeMsg for all procedures invoked by loadGoldInventory.

     Rev 1.81   30 Mar 2007 13:14:40   zf297a
  For procedure updateRow qualifed the part_no on the right hand side of the equal operator to be updateRow.part_no, otherwise Oracle will compare the column part_no to itself!

     Rev 1.80   08 Mar 2007 23:35:12   zf297a
  replaced all execute immediate truncate table... with the procedure mta_truncate_table.  Eliminated the truncation of tmp_a2a_order_info - since it no longer exists and causes a ORA-00980 synonym translation is no longer valid

     Rev 1.79   06 Mar 2007 09:19:26   zf297a
  removed a2a_pkg.insertTmpA2AOrderInfoLine

     Rev 1.77   Feb 14 2007 12:45:34   c402417
  Modified cursors itemMCur and itemACur to eliminate duplicate goes into table tmp_amd_in_repair.

     Rev 1.76   Jan 17 2007 16:13:50   c402417
  Removed total_inaccessible from RspQty when populate data into table tmp_amd_rsp.
  Also modified the cursor rampCurFB to get more accurate data into tmp_amd_rsp and it's the only cursor for tmp_amd_rsp.

     Rev 1.75   Nov 29 2006 23:30:26   zf297a
  Removed unecessary site_location variables

     Rev 1.74   Nov 28 2006 13:29:02   zf297a
  fixed doRspSumDiff - For delete transactons send a zero qty for tmp_a2a_loc_part_override a2a transactions.

     Rev 1.73   Nov 07 2006 09:29:02   c402417
  Removed the query to get data from rvs1 to tmp_amd_in_transits per Laurie.

     Rev 1.72   Nov 03 2006 12:13:12   c402417
  Added Exception for duplicate on insert into tmp_amd_in_transits

     Rev 1.71   Jun 09 2006 11:39:30   zf297a
  implemented interface version

     Rev 1.70   Jun 05 2006 08:59:06   zf297a
  Fixed errorMsg - changed literal from amd_load to amd_inventory

     Rev 1.69   May 16 2006 12:08:00   zf297a
  Fixed doRspSumDiff to invoke A2a_Pkg.insertInvInfo with the qty_on_hand or zero if it is null

     Rev 1.68   Apr 28 2006 12:51:28   c402417
  Added tmp_a2a_loc_part_override to truncate .

     Rev 1.67   Apr 28 2006 12:42:32   c402417
  Added AMD Inventory Mofication for SPO - including new process for amd_rsp, removed Order Type of M from amd_on_order, removed HPMSK_BALANCE+ SPRAM_BALANCE+WRM_BALANCE from amd_on_hand_inv.

     Rev 1.66   Jan 20 2006 12:01:38   c402417
  Need to exclude part_no w/out spo_location for spo_total_inventory.

     Rev 1.65   Dec 15 2005 12:20:44   zf297a
  Added truncate of table tmp_a2a_repair_inv_info to loadInRepair

     Rev 1.64   Dec 06 2005 14:25:44   zf297a
  Fixed the doUpdate of the insertOnOrderRow routine when it checks for a Deleted order qualify the select with the order_date and also fixed the update by adding the order_date in its where clause.

     Rev 1.63   Dec 06 2005 14:04:36   zf297a
  Fixed deleteRow - passed an qty_ordered of 0 and sysdate for the A2A transaction.

     Rev 1.62   Dec 06 2005 12:29:20   zf297a
  Implemented new version of deleteRow for amd_on_order diff.  The code has been streamlined since all the necessary data is being passed in from the java diff application.

     Rev 1.61   Dec 06 2005 10:20:20   zf297a
  Fixed update of amd_on_order: qualified the where clause with  gold_order_number and order_date.  Order_date was missing and caused a unique constraint error.

     Rev 1.60   Nov 03 2005 09:33:18   c402417
  Changed sequence of procedure so the SpoTotalInventory get update after all inventory tables get loaded.

     Rev 1.59   Oct 27 2005 15:47:54   c402417
  Added repair_need_date to A2a_pkg.insertRepairInfo.

     Rev 1.58   Oct 20 2005 16:35:58   c402417
  Added Cursor RampCurUAB. This cursor feeds data from table ramp with SC = UAB to amd_on_hand_invs.

     Rev 1.57   Oct 19 2005 11:37:42   zf297a
  removed invocation of insertTmpA2AOrderInfoLine and update the arg list for insertTmpA2AOrderInfo, which now inserts both the tmp_a2a_order_info and the tmp_a2a_order_info_line.

  Thuy, added code for rampCurUAB.

     Rev 1.56   Oct 13 2005 11:12:14   c402417
  Added Repair Inventory Sum diff function . This to sum parts which have doc_no like 'R' and 'II' and send them to table amd_repair_invs_sum and these data consider DEFECTIVE as on_hand_type in SPO - Inventory.

     Rev 1.55   Oct 04 2005 13:05:12   c402417
  Add goldsa for amd_on_hand_invs.(This added for SPO 5.0)

     Rev 1.54   Oct 04 2005 11:51:26   c402417
  minor fixed in in_repair update statement .

     Rev 1.53   Sep 26 2005 09:31:20   zf297a
  Fixed deleteRow for doOnHandInvsSumDiff: it was trying to update amd_on_hand_invs instead of amd_on_hand_invs_sum

     Rev 1.52   Sep 13 2005 12:44:24   zf297a
  Implemented the isVoucher boolean function and modified the getOnOrderParams procedure to check if from/to dates not null and have a length > 0 before returning them.

     Rev 1.51   Sep 12 2005 11:36:40   zf297a
  implemented interfaces for one get and one set procedure for all the on order date parameters for a given voucher.

     Rev 1.50   Sep 09 2005 10:56:34   zf297a
  For amd_on_hand_inv_sums changed the site_location column to be the spo_location column.  The spo_location comes from amd_spare_networks.spo_location.

     Rev 1.49   Sep 07 2005 21:01:24   zf297a
  raised sched_receipt_date_exception in setScheduledReceiptDate when the from_date argument is > than the to_date argument.

     Rev 1.48   Sep 07 2005 15:17:32   zf297a
  Added orderdates subtype.   Implemented gets and sets for create_order_date, scheduled_receipt_date_from, scheduled_receipt_date_to, and number_of_calander days.

     Rev 1.47   Sep 02 2005 15:50:24   zf297a
  Started implementing interfaces for getOrderCreateDate, setOrderCreateDate, getScdeduledReceiptDateFrom, getScdeduledReceiptDateTo, setScheduledReceiptDate, and setScheduledReceiptDateCalDays using empty functions and procedures.

     Rev 1.46   Aug 30 2005 10:40:38   zf297a
  Moved cursors outside of loadGoldInventory.  Implemented loadOnHandInvs and loadInRepair as separate procedures.  Updated loadGoldInventory to use these new procedures.

     Rev 1.45   12 Aug 2005 09:42:18   c402417
  Added FC to order_no on ORD1 for amd_on_onder

     Rev 1.44   Aug 04 2005 08:12:52   zf297a
  Made insertRow and updateRow unique for the jdbc interface by renaming them to insertOnOrderRow and updateOnOrderRow.

     Rev 1.43   03 Aug 2005 17:43:14   b1013683
  Added Accountable_YN in  amd_in_repair.
  Added sched_receipt_date and changed in order_date in amd_on_order.
  Made modification in getting spo_total_inventory in table ansi.

     Rev 1.41   Jul 15 2005 10:59:08   zf297a
  Fixed updateRow for amd_inv_on_hand and insertRow for amd_in_transits

     Rev 1.39   Jul 11 2005 11:49:12   zf297a
  used procedure a2a_pkg.insertTmpA2AInTransits

     Rev 1.38   Jul 11 2005 10:39:22   zf297a
  used a2a_pkg to insertTmpA2AOrderInfo and insertTmpA2AOrderInfoLine

     Rev 1.37   Jul 11 2005 09:49:02   zf297a
  updated pError_Location numbers (10, 20, 30,.........400)

     Rev 1.36   Jul 11 2005 09:30:36   zf297a
  made the loading of tmp_amd_in_transits a separate procedure

     Rev 1.35   Jul 11 2005 09:17:42   zf297a
  made the loading of tmp_amd_on_order a separate procedure

     Rev 1.34   Jul 06 2005 09:28:14   zf297a
  Enhanced amd_in_repair and added spo inventory total

     Rev 1.33   Jun 17 2005 06:52:50   c970183
  removed insertInvInfo, updateInvInfo, and deleteInvInfo from routine dealing with amd_in_repair

     Rev 1.32   May 17 2005 10:06:08   c970183
  Updated InsertErrorMessage to new interface

     Rev 1.31   May 04 2005 10:26:04   c970183
  added logical insert (update) for AMD_IN_TRANSITS which had previously been logically deleted.

     Rev 1.30   May 04 2005 10:14:30   c970183
  added logical insert (update) for AMD_ON_HAND_INVS which has been previously logically deleted.

     Rev 1.29   May 04 2005 10:05:50   c970183
  added a logical insert (update) for amd_in_repair for a row that has been previously logically deleted.

     Rev 1.28   May 04 2005 09:50:14   c970183
  truncated all tmp_a2a tables when loadGoldInventory is executed

     Rev 1.27   May 04 2005 09:16:00   c970183
  Added logical insert of amd_on_order when it has been previously marked as deleted.

     Rev 1.26   Apr 27 2005 09:21:42   c970183
  aded counters of rows inserted for loadGoldInventory.  Added info messages using dbms_output and amd_load_details.

     Rev 1.25   20 Sep 2004 10:17:42   c970183
  Fixed site_location for insertRow of in_transits - it must be varchar(20)

     Rev 1.24   20 Aug 2004 16:51:46   c402417
  Added tmp_amd_in_repairs

     Rev 1.23   09 Aug 2004 14:48:22   c970183
  fixed deleteRow for tmp_a2a_on_hand_invs: the qty_on_hand is required, so set it to zero.

     Rev 1.22   09 Aug 2004 14:40:02   c970183
  fixed deleteRow (insert of tmp_a2a_on_hand_invs) the site_location field was NOT being inserted.

     Rev 1.21   09 Aug 2004 14:23:46   c970183
  added insertion of tmp_a2a_order_info for inserts and updates

     Rev 1.16   05 Aug 2004 07:47:26   c970183
  changed parameter from using p prefix to the same namje as used by the colum.  Added function or procedure qualification for all parameters used in SQL where clauses and UPDATE set clauses

     Rev 1.13   03 Aug 2004 10:15:02   c402417
  Added the amd_in_repair diff function.

     Rev 1.12   02 Aug 2004 14:14:34   c970183
  accomodate insert/update of detail rows for amd_on_hand_invs

     Rev 1.11   Aug 02 2004 08:47:10   c970183
  changed case of plocSid to pLocSid

     Rev 1.9   Jul 30 2004 12:02:18   c970183
  added comments to document changes made

    */



   -- DSE 7/23/04 added InsertRow, DeleteRow, and UpdateRow stubs
   -- TL  7/26/04 added ErrorMsg and code for amd_on_order InsertRow, DeleteRow, and UpdateRow
   -- DSE 7/27/04 added tmp prefix to all amd tables created by LoadGoldInventory
   -- DSE 7/29/04 Added InsertRow, UpdateRow, and DeleteRow for the amd_on_order table
   -- TL  7/30/04 Enhanced the ErrorMsg Function and implemented the InsertRow, UpdateRow,
   --                   and DeleteRow functions for the amd_on_hand_invs table
   -- TP     8/2/04  Added InsertRow, UpdateRow, and DeleteRow for the amd_in_repair table.
   -- TP    8/18/04 Added InsertRow, UpdateRow, and DeleteRow for the amd_in_transits table.
   --

   debug                                  BOOLEAN := FALSE;
   dateThreshold                          DATE := TO_DATE ('01/01/1980', 'MM/DD/YYYY'); -- there should not be any repair dates earlier than this

   ON_ORDER_DATE                 CONSTANT AMD_PARAMS.PARAM_KEY%TYPE := 'on_order_date_';
   PROGRAM_ID                    CONSTANT VARCHAR2 (30) := amd_defaults.getProgramId;
   PROGRAM_ID_LL                 CONSTANT NUMBER := LENGTH (PROGRAM_ID);
   START_LOC_ID                  CONSTANT NUMBER := amd_defaults.getStartLocId;

   SUBTYPE orderdates IS NUMBER;

   ORDER_CREATE_DATE             CONSTANT orderdates := 1;
   SCHEDULED_RECEIPT_DATE_FROM   CONSTANT orderdates := 2;
   SCHEDULED_RECEIPT_DATE_TO     CONSTANT orderdates := 3;
   NUMBER_OF_CALANDER_DAYS       CONSTANT orderdates := 4;

   TYPE partRec IS RECORD
   (
      part_no   amd_spare_parts.part_no%TYPE,
      nsn       amd_national_stock_items.nsn%TYPE
   );

   TYPE partTab IS TABLE OF partRec;

   partRecs                               partTab;



   CURSOR partCur
   IS
      SELECT DISTINCT asp.part_no, asp.nsn
        FROM AMD_SPARE_PARTS asp,
             AMD_NATIONAL_STOCK_ITEMS ansi,
             AMD_NSI_PARTS anp
       WHERE     icp_ind = amd_defaults.getIcpInd
             AND asp.part_no = anp.part_no
             AND anp.prime_ind = 'Y'
             AND NVL (
                    "UNASSIGNMENT_DATE",
                    TO_DATE (' 0001-01-01 00:00:00',
                             'syyyy-mm-dd hh24:mi:ss')) =
                    TO_DATE (' 0001-01-01 00:00:00',
                             'syyyy-mm-dd hh24:mi:ss')
             AND asp.nsn = ansi.nsn
             AND asp.action_code != 'D';

   -- Type 1,2 Retail

   TYPE rampRec IS RECORD
   (
      loc_sid                  amd_spare_networks.loc_sid%TYPE,
      serviceable_balance      ramp.SERVICEABLE_BALANCE%TYPE,
      spram_balance            ramp.SPRAM_BALANCE%TYPE,
      wrm_balance              ramp.WRM_BALANCE%TYPE,
      hpmsk_balance            ramp.HPMSK_BALANCE%TYPE,
      total_inaccessible_qty   ramp.TOTAL_INACCESSIBLE_QTY%TYPE,
      difm_balance             ramp.DIFM_BALANCE%TYPE,
      unserviceable_balance    ramp.UNSERVICEABLE_BALANCE%TYPE,
      spram_level              ramp.SPRAM_LEVEL%TYPE,
      wrm_level                ramp.WRM_LEVEL%TYPE,
      hpmsk_level_qty          ramp.HPMSK_LEVEL_QTY%TYPE,
      suspended_in_stock       ramp.SUSPENDED_IN_STOCK%TYPE,
      inv_date                 ramp.DATE_PROCESSED%TYPE,
      repair_need_date         ramp.DATE_PROCESSED%TYPE
   );


   TYPE rampTab IS TABLE OF rampRec;

   rampRecs                               rampTab;

   TYPE rampInvQtyRec IS RECORD
   (
      loc_sid                  amd_spare_networks.loc_sid%TYPE,
      serviceable_balance      ramp.SERVICEABLE_BALANCE%TYPE,
      spram_balance            ramp.SPRAM_BALANCE%TYPE,
      wrm_balance              ramp.WRM_BALANCE%TYPE,
      hpmsk_balance            ramp.HPMSK_BALANCE%TYPE,
      total_inaccessible_qty   ramp.TOTAL_INACCESSIBLE_QTY%TYPE,
      difm_balance             ramp.DIFM_BALANCE%TYPE,
      unserviceable_balance    ramp.UNSERVICEABLE_BALANCE%TYPE,
      spram_level              ramp.SPRAM_LEVEL%TYPE,
      wrm_level                ramp.WRM_LEVEL%TYPE,
      hpmsk_level_qty          ramp.HPMSK_LEVEL_QTY%TYPE,
      suspended_in_stock       ramp.SUSPENDED_IN_STOCK%TYPE,
      inv_date                 ramp.DATE_PROCESSED%TYPE,
      repair_need_date         ramp.DATE_PROCESSED%TYPE,
      inventory_quantity       NUMBER,
      action_code              TMP_AMD_ON_HAND_INVS.ACTION_CODE%TYPE,
      last_update_dt           DATE
   );

   TYPE rampInvQtyTab IS TABLE OF rampInvQtyRec;

   rampInvQtyRecs                         rampInvQtyTab;



   CURSOR rampCurUAB (
      pNsn    VARCHAR2)
   IS
      SELECT DECODE (n.loc_type, 'TMP', asn2.loc_sid, n.loc_sid) loc_sid,
             NVL (r.serviceable_balance, 0) serviceable_balance,
             NVL (r.spram_balance, 0) spram_balance,
             NVL (r.hpmsk_balance, 0) hpmsk_balance,
             NVL (r.wrm_balance, 0) wrm_balance,
             NVL (r.total_inaccessible_qty, 0) total_inaccessible_qty,
             NVL (r.difm_balance, 0) difm_balance,
             NVL (r.spram_level, 0) spram_level,
             NVL (r.wrm_level, 0) wrm_level,
             NVL (r.hpmsk_level_qty, 0) hpmsk_level_qty,
             TRUNC (NVL (r.date_processed, SYSDATE)) inv_date,
             TRUNC ( (r.date_processed) + NVL (avg_repair_cycle_time, 0))
                repair_need_date
        FROM (SELECT *
                FROM RAMP
               WHERE current_stock_number = pNsn) r,
             AMD_SPARE_NETWORKS n,
             AMD_SPARE_NETWORKS asn2
       WHERE     n.loc_id = r.sran(+)
             AND SUBSTR (r.sran, 1, 2) = 'FB'             --AND asp.nsn = pNsn
             AND n.loc_type = 'UAB'
             AND n.mob = asn2.loc_id(+);

   TYPE rampFBrec IS RECORD
   (
      loc_sid                  amd_spare_networks.loc_sid%TYPE,
      serviceable_balance      ramp.SERVICEABLE_BALANCE%TYPE,
      spram_balance            ramp.SPRAM_BALANCE%TYPE,
      wrm_balance              ramp.WRM_BALANCE%TYPE,
      hpmsk_balance            ramp.HPMSK_BALANCE%TYPE,
      total_inaccessible_qty   ramp.TOTAL_INACCESSIBLE_QTY%TYPE,
      difm_balance             ramp.DIFM_BALANCE%TYPE,
      spram_level              ramp.SPRAM_LEVEL%TYPE,
      wrm_level                ramp.WRM_LEVEL%TYPE,
      hpmsk_level_qty          ramp.HPMSK_LEVEL_QTY%TYPE,
      inv_date                 ramp.DATE_PROCESSED%TYPE,
      repair_need_date         ramp.DATE_PROCESSED%TYPE
   );

   TYPE rampFBtab IS TABLE OF rampFBrec;

   rampFBrecs                             rampFBtab;



   TYPE tmpAmdOnHandInvsTab IS TABLE OF tmp_amd_on_hand_invs%ROWTYPE;

   tmpAmdOnHandInvsRecs                   tmpAmdOnHandInvsTab;



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
      Amd_Utils.writeMsg (pSourceName       => 'amd_inventory',
                          pTableName        => pTableName,
                          pError_location   => pError_location,
                          pKey1             => pKey1,
                          pKey2             => pKey2,
                          pKey3             => pKey3,
                          pKey4             => pKey4,
                          pData             => pData,
                          pComments         => pComments);
   END writeMsg;


   PROCEDURE warningMsg (pWarning_Location   IN NUMBER,
                         key1                IN VARCHAR2 := '',
                         key2                IN VARCHAR2 := '',
                         key3                IN VARCHAR2 := '',
                         key4                IN VARCHAR2 := '',
                         key5                IN VARCHAR2 := '',
                         msg                 IN VARCHAR2 := '')
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      Amd_warnings_pkg.insertWarningMsg (pData_line_no   => pWarning_Location,
                                         pData_line      => 'amd_inventory',
                                         pKey_1          => key1,
                                         pKey_2          => key2,
                                         pKey_3          => key3,
                                         pKey_4          => key4,
                                         pKey_5          => key5,
                                         pWarning        => msg);
      COMMIT;
      RETURN;
   END warningMsg;

   PROCEDURE errorMsg (sqlFunction         IN VARCHAR2,
                       tableName           IN VARCHAR2,
                       pError_Location     IN NUMBER,
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
         pData_line_no   => pError_Location,
         pData_line      => 'amd_inventory',
         pKey_1          => key1,
         pKey_2          => key2,
         pKey_3          => key3,
         pKey_4          => key4,
         pKey_5          => key5 || ' ' || keywordValuePairs,
         pComments       =>    SqlFunction
                            || '/'
                            || TableName
                            || ' sqlcode('
                            || SQLCODE
                            || ') sqlerrm('
                            || SQLERRM
                            || ')');
      COMMIT;
      RETURN;
   END ErrorMsg;

   FUNCTION ErrorMsg (pSqlFunction         IN VARCHAR2,
                      pTableName           IN VARCHAR2,
                      pError_Location      IN NUMBER,
                      pReturn_code         IN NUMBER,
                      pKey_1               IN VARCHAR2,
                      pKey_2               IN VARCHAR2 := '',
                      pKey_3               IN VARCHAR2 := '',
                      pKey_4               IN VARCHAR2 := '',
                      pKeywordValuePairs   IN VARCHAR2 := '')
      RETURN NUMBER
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      Amd_Utils.InsertErrorMsg (
         pLoad_no        => Amd_Utils.GetLoadNo (pSourceName   => pSqlFunction,
                                                 pTableName    => pTableName),
         pData_line_no   => pError_Location,
         pData_line      => 'amd_inventory',
         pKey_1          => pKey_1,
         pKey_2          => pKey_2,
         pKey_3          => pKey_3,
         pKey_4          => pKey_4,
         pKey_5          =>    'rc='
                            || TO_CHAR (pReturn_code)
                            || ' '
                            || pKeywordValuePairs,
         pComments       =>    pSqlFunction
                            || '/'
                            || pTableName
                            || ' sqlcode('
                            || SQLCODE
                            || ') sqlerrm('
                            || SQLERRM
                            || ')');
      COMMIT;
      RETURN pReturn_code;
   END ErrorMsg;


   PROCEDURE LoadGoldInventory
   IS
      nsnDashed   VARCHAR2 (16);
      orderSid    NUMBER;

      pn          VARCHAR2 (50);
      loc_sid     NUMBER;
      inv_date    DATE;
      invQty      NUMBER;

      result      NUMBER;
   BEGIN
      writeMsg (
         pTableName        => 'tmp_amd_...',
         pError_location   => 10,
         pKey1             => 'loadGoldInventory',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      loadOnHandInvs;

      loadInRepair;

      loadOnOrder;

      loadInTransits;

      loadRsp;


      writeMsg (
         pTableName        => 'tmp_amd_...',
         pError_location   => 20,
         pKey1             => 'loadGoldInventory',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
   EXCEPTION
      WHEN OTHERS
      THEN
         ErrorMsg (sqlFunction       => 'loadGoldInventory',
                   tableName         => 'inventory tables',
                   pError_Location   => 20);
         DBMS_OUTPUT.put_line (
               'loadGoldInventory: sqlcode='
            || SQLCODE
            || ' sqlerrm='
            || SQLERRM);
         RAISE;
   END LoadGoldInventory;


   PROCEDURE loadOnOrder
   IS
      TYPE tmpAmdOnOrderTab IS TABLE OF tmp_amd_on_order%ROWTYPE;

      tmpAmdOnOrderRecs   tmpAmdOnOrderTab;



      CURSOR itemType3aCur
      IS
           SELECT asp.part_no part_no,
                  DECODE (asn.loc_type, 'TMP', asnLink.loc_sid, asn.loc_sid)
                     loc_sid,
                  invQ.inv_date inv_date,
                  SUM (invQ.inv_qty) inv_qty,
                  invQ.order_no order_no,
                  TRUNC (invQ.receipt_date) receipt_date,
                  amd_defaults.getINSERT_ACTION action_code,
                  SYSDATE last_update_dt
             FROM (SELECT DISTINCT
                          o.part part_no,
                          o.loc_id,
                          TRUNC (o.created_datetime) inv_date,
                          NVL (o.qty_due, 0) inv_qty,
                          o.order_no order_no,
                          DECODE (ecd, NULL, need_date, ecd) receipt_date
                     FROM ORD1 o, amd_spare_networks asn
                    WHERE     o.status = 'O'
                          AND SUBSTR (o.sc, 1, PROGRAM_ID_LL) = PROGRAM_ID
                          AND (   o.sc LIKE '%G'
                               OR (EXISTS
                                      (SELECT NULL
                                         FROM amd_sc_inclusions
                                        WHERE o.sc = include_sc)))
                          AND o.order_type = 'M'
                          AND o.created_datetime IS NOT NULL
                          AND (   asn.loc_id = o.loc_id
                               OR (EXISTS
                                      (SELECT NULL
                                         FROM amd_sc_inclusions
                                        WHERE SUBSTR (o.sc, START_LOC_ID, 7) =
                                                 SUBSTR (include_sc,
                                                         START_LOC_ID,
                                                         7))))
                   UNION ALL
                   SELECT DISTINCT
                          part part_no,
                          o.loc_id,
                          TRUNC (o.created_datetime) inv_date,
                          NVL (o.qty_due, 0) inv_qty,
                          o.order_no order_no,
                          DECODE (o.ecd, NULL, o.need_date, o.ecd) receipt_date
                     FROM ORD1 o, amd_spare_networks asn
                    WHERE     o.status = 'O'
                          AND SUBSTR (o.sc, 1, PROGRAM_ID_LL) = PROGRAM_ID
                          AND (   o.sc LIKE '%G'
                               OR (EXISTS
                                      (SELECT NULL
                                         FROM amd_sc_inclusions
                                        WHERE o.sc = include_sc)))
                          AND o.order_type = 'C'
                          --AND SUBSTR(o.order_no,1,2) IN (select prefix from amd_order_prefixes)
                          AND o.created_datetime IS NOT NULL
                          AND (   asn.loc_id = o.loc_id
                               OR (EXISTS
                                      (SELECT NULL
                                         FROM amd_sc_inclusions
                                        WHERE SUBSTR (o.sc, START_LOC_ID, 7) =
                                                 SUBSTR (include_sc,
                                                         START_LOC_ID,
                                                         7))))
                   UNION ALL
                   SELECT DISTINCT
                          part part_no,
                          o.loc_id,
                          TRUNC (o.created_datetime) inv_date,
                          NVL (o.qty_due, 0) inv_qty,
                          o.order_no order_no,
                          DECODE (o.ecd, NULL, o.need_date, o.ecd) receipt_date
                     FROM ORD1 o, amd_spare_networks asn
                    WHERE     o.status = 'O'
                          AND SUBSTR (o.sc, 1, PROGRAM_ID_LL) = PROGRAM_ID
                          AND (   o.sc LIKE '%G'
                               OR (EXISTS
                                      (SELECT NULL
                                         FROM amd_sc_inclusions
                                        WHERE o.sc = include_sc)))
                          AND o.order_type = 'C'
                          AND SUBSTR (order_no, 1, 3) =
                                 SUBSTR (asn.loc_id, 4, 3)
                          AND SUBSTR (asn.loc_id, 1, 2) IN ('FB', 'EY')
                          AND o.created_datetime IS NOT NULL
                          AND (   asn.loc_id = o.loc_id
                               OR (EXISTS
                                      (SELECT NULL
                                         FROM amd_sc_inclusions
                                        WHERE SUBSTR (o.sc, START_LOC_ID, 7) =
                                                 SUBSTR (include_sc,
                                                         START_LOC_ID,
                                                         7))))) invQ,
                  AMD_SPARE_NETWORKS asn,
                  AMD_SPARE_PARTS asp,
                  AMD_SPARE_NETWORKS asnLink
            WHERE     asp.part_no = invQ.part_no
                  AND asn.loc_id = invQ.loc_id
                  AND asn.loc_type <> 'KIT'
                  AND asp.action_code != 'D'
                  AND asn.mob = asnLink.loc_id(+)
                  AND invQ.inv_date IS NOT NULL
         GROUP BY asp.part_no,
                  DECODE (asn.loc_type, 'TMP', asnLink.loc_sid, asn.loc_sid),
                  invQ.inv_date,
                  invQ.order_no,
                  TRUNC (invQ.receipt_date)
           HAVING SUM (invQ.inv_qty) > 0;



      CURSOR itemType3bCur
      IS
           SELECT i.part part_no,
                  DECODE (asn.loc_type, 'TMP', asnLink.loc_sid, asn.loc_sid)
                     loc_sid,
                  TRUNC (i.created_datetime) inv_date,
                  SUM (i.qty) inv_qty,
                  i.item_id order_no,
                  DECODE (TRUNC (o.ecd), NULL, SYSDATE, TRUNC (o.ecd))
                     receipt_date,
                  amd_defaults.INSERT_ACTION action_code,
                  SYSDATE last_update_dt
             FROM ITEM i,
                  ORD1 o,
                  AMD_SPARE_NETWORKS asn,
                  AMD_SPARE_PARTS asp,
                  AMD_SPARE_NETWORKS asnLink
            WHERE     i.receipt_order_no = o.order_no
                  AND o.status = 'O'
                  AND SUBSTR (o.sc, 1, PROGRAM_ID_LL) = PROGRAM_ID
                  AND SUBSTR (o.sc, LENGTH (o.sc), 1) = 'G'
                  AND i.condition = 'B170-ATL'
                  AND asp.part_no = i.part
                  AND asn.loc_id = i.loc_id
                  AND ASN.LOC_TYPE <> 'KIT'
                  AND asp.action_code != 'D'
                  AND asn.mob = asnLink.loc_id(+)
                  AND i.created_datetime IS NOT NULL
         GROUP BY i.part,
                  DECODE (asn.loc_type, 'TMP', asnLink.loc_sid, asn.loc_sid),
                  TRUNC (i.created_datetime),
                  i.item_id,
                  DECODE (TRUNC (o.ecd), NULL, SYSDATE, TRUNC (o.ecd))
           HAVING SUM (i.qty) > 0;

      TYPE itemType3cRec IS RECORD
      (
         part_no        tmp1.FROM_PART%TYPE,
         loc_sid        amd_spare_networks.loc_sid%TYPE,
         inv_date       DATE,
         inv_qty        NUMBER,
         order_no       tmp1.TEMP_OUT_ID%TYPE,
         receipt_date   DATE
      );

      TYPE itemType3cTab IS TABLE OF itemType3cRec;

      itemType3cRecs      itemType3cTab;

      CURSOR itemType3cCur
      IS
           SELECT from_part part_no,
                  DECODE (asn.loc_type, 'TMP', asnLink.loc_sid, asn.loc_sid)
                     loc_sid,
                  TRUNC (from_datetime) inv_date,
                  SUM (qty_due) inv_qty,
                  temp_out_id order_no,
                  DECODE (est_return_date, NULL, NULL, est_return_date)
                     receipt_date,
                  amd_defaults.INSERT_ACTION action_code,
                  SYSDATE last_update_dt
             FROM TMP1,
                  AMD_SPARE_NETWORKS asn,
                  AMD_SPARE_PARTS asp,
                  AMD_SPARE_NETWORKS asnLink
            WHERE     NVL (returned_voucher, '-1') = '-1'
                  AND status = 'O'
                  AND tcn = 'LNI'
                  AND SUBSTR (from_sc, 1, PROGRAM_ID_LL) = PROGRAM_ID
                  AND asn.loc_id = from_loc_id
                  AND asp.part_no = from_part
                  AND asn.loc_type <> 'KIT'
                  AND asp.action_code != 'D'
                  AND asn.mob = asnLink.loc_id(+)
                  AND from_datetime IS NOT NULL
         GROUP BY from_part,
                  DECODE (asn.loc_type, 'TMP', asnLink.loc_sid, asn.loc_sid),
                  TRUNC (from_datetime),
                  temp_out_id,
                  est_return_date
           HAVING SUM (qty_due) > 0;
   BEGIN
      writeMsg (
         pTableName        => 'tmp_amd_on_order',
         pError_location   => 30,
         pKey1             => 'loadOnOrder',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
      Mta_Truncate_Table ('TMP_AMD_ON_ORDER', 'reuse storage');

      OPEN itemType3aCur;

      FETCH itemType3aCur BULK COLLECT INTO tmpAmdOnOrderRecs;

      CLOSE itemType3aCur;

      IF tmpAmdOnOrderRecs.FIRST IS NOT NULL
      THEN
         -- type3aWholeSale
         FORALL indx IN tmpAmdOnOrderRecs.FIRST .. tmpAmdOnOrderRecs.LAST
            -- Type_3a
            INSERT INTO TMP_AMD_ON_ORDER
                 VALUES tmpAmdOnOrderRecs (indx);

         DBMS_OUTPUT.put_line (
               'loadOnOrder: rows inserted to tmp_amd_on_order from itemType3aCur '
            || SQL%ROWCOUNT);
         writeMsg (
            pTableName        => 'tmp_amd_on_order',
            pError_location   => 40,
            pKey1             => 'itemType3a',
            pKey2             =>    'loaded at '
                                 || TO_CHAR (SYSDATE,
                                             'MM/DD/YYYY HH:MI:SS AM'),
            pKey3             => '# of recs = ' || TO_CHAR (SQL%ROWCOUNT));
         COMMIT;
      END IF;

      OPEN itemType3bCur;

      FETCH itemType3bCur BULK COLLECT INTO tmpAmdOnOrderRecs;

      CLOSE itemtype3bCur;

      IF tmpAmdOnOrderRecs.FIRST IS NOT NULL
      THEN
         --type3bWholesale
         FORALL indx IN tmpAmdOnOrderRecs.FIRST .. tmpAmdOnOrderRecs.LAST
            -- Type_3b
            INSERT INTO TMP_AMD_ON_ORDER
                 VALUES tmpAmdOnOrderRecs (indx);

         DBMS_OUTPUT.put_line (
               'loadOnOrder: rows inserted to tmp_amd_on_order from itemType3bCur '
            || SQL%ROWCOUNT);
         writeMsg (
            pTableName        => 'tmp_amd_on_order',
            pError_location   => 50,
            pKey1             => 'itemType3b',
            pKey2             =>    'loaded at '
                                 || TO_CHAR (SYSDATE,
                                             'MM/DD/YYYY HH:MI:SS AM'),
            pKey3             => '# recs = ' || TO_CHAR (SQL%ROWCOUNT));
         COMMIT;
      END IF;

      OPEN itemType3cCur;

      FETCH itemType3cCur BULK COLLECT INTO tmpAmdOnOrderRecs;

      CLOSE itemType3cCur;

      IF tmpAmdOnOrderRecs.FIRST IS NOT NULL
      THEN
         -- type3cWholeSale
         FORALL indx IN tmpAmdOnOrderRecs.FIRST .. tmpAmdOnOrderRecs.LAST
            --Type_3c
            INSERT INTO TMP_AMD_ON_ORDER
                 VALUES tmpAmdOnOrderRecs (indx);

         DBMS_OUTPUT.put_line (
               'loadOnOrder: rows inserted to tmp_amd_on_order from itemType3cCur '
            || SQL%ROWCOUNT);

         writeMsg (
            pTableName        => 'tmp_amd_on_order',
            pError_location   => 60,
            pKey1             => 'itemType3c',
            pKey2             =>    'loaded at '
                                 || TO_CHAR (SYSDATE,
                                             'MM/DD/YYYY HH:MI:SS AM'),
            pKey3             => '# recs = ' || TO_CHAR (SQL%ROWCOUNT));
         COMMIT;
      END IF;

      writeMsg (
         pTableName        => 'tmp_amd_on_order',
         pError_location   => 70,
         pKey1             => 'loadOnOrder',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
   END loadOnOrder;



   PROCEDURE loadInTransits
   IS
   BEGIN
      writeMsg (
         pTableName        => 'tmp_amd_in_transits',
         pError_location   => 80,
         pKey1             => 'loadInTransits',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
      Mta_Truncate_Table ('TMP_AMD_IN_TRANSITS', 'reuse storage');

     -- Populate data into table amd_in_transits
     <<insertInTransits1>>
      BEGIN
         INSERT INTO TMP_AMD_IN_TRANSITS (to_loc_sid,
                                          quantity,
                                          action_code,
                                          last_update_dt,
                                          document_id,
                                          part_no,
                                          from_location,
                                          in_transit_date,
                                          serviceable_flag)
            SELECT loc_sid,
                   (NVL (m.ship_qty, 0) - NVL (m.receipt_qty, 0)) quantity,
                   'A',
                   SYSDATE,
                   m.document_id,
                   m.part,
                   m.in_tran_from,
                   TO_DATE (m.create_date),
                   DECODE (m.mils_condition,
                           'A', 'Y',
                           'B', 'Y',
                           'C', 'Y',
                           'D', 'Y',
                           'N')
                      mils_condition
              FROM MLIT m, AMD_SPARE_NETWORKS a
             WHERE     (NVL (m.ship_qty, 0) - NVL (m.receipt_qty, 0)) > 0
                   AND SUBSTR (m.in_tran_to, 1, 2) <> 'FE'
                   AND a.loc_type <> 'KIT'
                   AND (   DECODE (m.in_tran_to,
                                   'FD2090', 'CTLATL',
                                   'FB' || SUBSTR (in_tran_to, 3)) = a.loc_id
                        OR DECODE (m.in_tran_to,
                                   'EY3571', 'CODALT',
                                   'FB' || SUBSTR (in_tran_to, 3)) = a.loc_id
                        OR DECODE (m.in_tran_to,
                                   'EY7739', 'CODCHS',
                                   'FB' || SUBSTR (in_tran_to, 3)) = a.loc_id
                        OR DECODE (m.in_tran_to,
                                   'EY8388', 'CODMCD',
                                   'FB' || SUBSTR (in_tran_to, 3)) = a.loc_id);

         DBMS_OUTPUT.put_line (
               'loadInTransits: rows inserted to tmp_amd_on_order from MLIT '
            || SQL%ROWCOUNT);

         COMMIT;
      END insertInTransits1;

     <<insertInTransits2>>
      BEGIN
         INSERT INTO TMP_AMD_IN_TRANSITS (to_loc_sid,
                                          quantity,
                                          action_code,
                                          last_update_dt,
                                          document_id,
                                          part_no,
                                          from_location,
                                          in_transit_date,
                                          serviceable_flag)
            SELECT a.loc_sid,
                   i.qty,
                   'A',
                   SYSDATE,
                   i.item_id,
                   i.part,
                   i.loc_id,
                   i.created_datetime,
                   i.status_servicable
              FROM ITEM i, AMD_SPARE_NETWORKS a
             WHERE     i.status_3 = 'I'
                   AND i.condition != 'B170-ATL'
                   AND i.status_servicable = 'Y'
                   AND i.status_new_order = 'N'
                   AND i.status_accountable = 'Y'
                   AND i.status_active = 'Y'
                   AND i.status_mai = 'N'
                   AND SUBSTR (i.sc, 1, PROGRAM_ID_LL) = PROGRAM_ID
                   AND NOT EXISTS
                          (SELECT 1
                             FROM ITEM i2
                            WHERE     i2.status_avail = 'N'
                                  AND NVL (i2.receipt_order_no, '-1') = '-1'
                                  AND i2.item_id = i.item_id)
                   AND i.loc_id = a.loc_id
                   AND a.loc_type <> 'KIT'
                   AND i.qty IS NOT NULL;

         DBMS_OUTPUT.put_line (
               'loadInTransits: rows inserted to tmp_amd_on_order from ITEM '
            || SQL%ROWCOUNT);

         COMMIT;
      END insertInTransits2;


      writeMsg (
         pTableName        => 'tmp_amd_in_transits',
         pError_location   => 90,
         pKey1             => 'loadInTransits',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
   END loadInTransits;


   PROCEDURE loadRsp
   IS
      nsnDashed       VARCHAR2 (16) := NULL;
      RspQty          NUMBER := 0;
      RspLevel        NUMBER := 0;
      cntRsp          NUMBER := 0;
      cntType1        NUMBER := 0;
      cntType2        NUMBER := 0;
      result          NUMBER := 0;

      TYPE tmpAmdRspTab IS TABLE OF tmp_amd_rsp%ROWTYPE;

      tmpAmdRspRecs   tmpAmdRspTab;

      CURSOR rspInv
      IS
         SELECT part_no,
                loc_sid,
                rsp_inv,
                rsp_level,
                amd_defaults.getINSERT_ACTION action_code,
                SYSDATE last_update_dt
           FROM rsp_inv_v
          WHERE rsp_inv > 0;


      rspCnt          NUMBER := 0;
      ins_cnt         NUMBER := 0;
      upd_cnt         NUMBER := 0;
   BEGIN
      writeMsg (
         pTableName        => 'tmp_amd_rsp',
         pError_location   => 100,
         pKey1             => 'loadRsp',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
      Mta_Truncate_Table ('TMP_AMD_RSP', 'reuse storage');
      COMMIT;


      -- Populate data into table tmp_amd_rsp

      OPEN rspInv;

      FETCH rspInv BULK COLLECT INTO tmpAmdRspRecs;

      CLOSE rspInv;

      IF tmpAmdRspRecs.FIRST IS NOT NULL
      THEN
         --rspUABRampLoop
         FORALL yDex IN tmpAmdRspRecs.FIRST .. tmpAmdRspRecs.LAST
            INSERT INTO TMP_AMD_RSP
                 VALUES tmpAmdRspRecs (yDex);

         rspCnt := rspCnt + SQL%ROWCOUNT;
         COMMIT;
      END IF;

      DBMS_OUTPUT.put_line ('loadRsp: rows inserted ' || rspCnt);


      DBMS_OUTPUT.put_line (
            'loadRsp ended at '
         || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM')
         || ' # recs = '
         || TO_CHAR (rspCnt));

      writeMsg (
         pTableName        => 'tmp_amd_rsp',
         pError_location   => 110,
         pKey1             => 'loadRsp',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
         pKey3             => '# recs = ' || TO_CHAR (rspCnt));
   END loadRsp;


   FUNCTION getSiteLocation (loc_sid IN AMD_SPARE_NETWORKS.loc_sid%TYPE)
      RETURN AMD_SPARE_NETWORKS.loc_id%TYPE
   IS
      loc_id   AMD_SPARE_NETWORKS.loc_id%TYPE;
      result   NUMBER;
   BEGIN
      SELECT loc_id
        INTO loc_id
        FROM AMD_SPARE_NETWORKS
       WHERE loc_sid = getSiteLocation.loc_sid;

      RETURN loc_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         result :=
            ErrorMsg (pSqlFunction      => 'select',
                      pTableName        => 'amd_spare_networks',
                      pError_Location   => 80,
                      pReturn_code      => FAILURE,
                      pKey_1            => 'loc_sid');
         DBMS_OUTPUT.put_line (
               'getSiteLocation: loc_sid='
            || loc_sid
            || ' sqlcode='
            || ' sqlerrm='
            || SQLERRM);
         RAISE;
   END getSiteLocation;


   FUNCTION doRepairInvsSumDiff (part_no         IN VARCHAR2,
                                 site_location   IN VARCHAR2,
                                 qty_on_hand     IN NUMBER,
                                 action_code     IN VARCHAR2)
      RETURN NUMBER
   IS
      badActionCode   EXCEPTION;

      FUNCTION InsertRow
         RETURN NUMBER
      IS
      BEGIN
        <<insertAmdRepairInvsSums>>
         DECLARE
            PROCEDURE doUpdate
            IS
            BEGIN
              <<getActionCode>>
               DECLARE
                  action_code   AMD_IN_REPAIR.action_code%TYPE;
                  badInsert     EXCEPTION;
               BEGIN
                  SELECT action_code
                    INTO action_code
                    FROM AMD_REPAIR_INVS_SUM
                   WHERE     part_no = doRepairInvsSumDiff.part_no
                         AND site_location =
                                doRepairInvsSumDiff.site_location;

                  IF action_code != Amd_Defaults.DELETE_ACTION
                  THEN
                     DBMS_OUTPUT.put_line (
                           'doRepairInvsSumDiff: insertAmdRepairInvsSums getActionCode: action_code='
                        || action_code
                        || ' part_no='
                        || doRepairInvsSumDiff.part_no
                        || ' site_location='
                        || doRepairInvsSumDiff.site_location
                        || ' qty_on_hand='
                        || qty_on_hand
                        || ' action_code='
                        || action_code);
                     RAISE badInsert;
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     errorMsg (
                        SqlFunction       => 'select',
                        TableName         => 'amd_repair_invs_sum',
                        pError_location   => 120,
                        key1              => doRepairInvsSumDiff.part_no,
                        key2              => doRepairInvsSumDiff.site_location);
               END getActionCode;

               UPDATE AMD_REPAIR_INVS_SUM
                  SET qty_on_hand = doRepairInvsSumDiff.qty_on_hand,
                      action_code = Amd_Defaults.INSERT_ACTION,
                      last_update_dt = SYSDATE
                WHERE     part_no = doRepairInvsSumDiff.part_no
                      AND site_location = doRepairInvsSumDiff.site_location;
            END doUpdate;
         BEGIN
            INSERT INTO AMD_REPAIR_INVS_SUM (part_no,
                                             site_location,
                                             qty_on_hand,
                                             action_code,
                                             last_update_dt)
                 VALUES (part_no,
                         site_location,
                         qty_on_hand,
                         Amd_Defaults.INSERT_ACTION,
                         SYSDATE);
         EXCEPTION
            WHEN STANDARD.DUP_VAL_ON_INDEX
            THEN
               doUpdate;
            WHEN OTHERS
            THEN
               ErrorMsg (sqlFunction       => 'insert',
                         tableName         => 'amd_on_order',
                         pError_location   => 130,
                         key1              => part_no,
                         key2              => site_location);
               DBMS_OUTPUT.put_line (
                     'doRepairInvsSumDiff: insertAmdRepairInvs: part_no='
                  || part_no
                  || ' site_location='
                  || site_location
                  || ' qty_on_hand='
                  || qty_on_hand
                  || ' action_code='
                  || action_code
                  || ' sqlcode='
                  || SQLCODE
                  || ' sqlerrm='
                  || SQLERRM);
               RAISE;
         END insertAmdRepairInvs;


         RETURN SUCCESS;
      END InsertRow;

      FUNCTION UpdateRow
         RETURN NUMBER
      IS
         -- get the detail for the summarized inv_qty
         result   NUMBER;
      BEGIN
        <<updateAmdRepairInvs>>
         BEGIN
            UPDATE AMD_REPAIR_INVS_SUM
               SET qty_on_hand = doRepairInvsSumDiff.qty_on_hand,
                   action_code = Amd_Defaults.UPDATE_ACTION,
                   last_update_dt = SYSDATE
             WHERE     part_no = doRepairInvsSumDiff.part_no
                   AND site_location = doRepairInvsSumDiff.site_location;
         EXCEPTION
            WHEN OTHERS
            THEN
               ErrorMsg (SqlFunction       => 'update',
                         TableName         => 'amd_repair_invs_sum',
                         pError_location   => 140,
                         key1              => part_no,
                         key2              => site_location);
               DBMS_OUTPUT.put_line (
                     'doRepairInvsSumDiff: updateAmdRepairInvs: 1 part_no='
                  || part_no
                  || ' site_location='
                  || site_location
                  || ' qty_on_hand='
                  || qty_on_hand
                  || ' action_code='
                  || action_code
                  || ' sqlcode='
                  || SQLCODE
                  || ' sqlerrm='
                  || SQLERRM);
               RAISE;
         END updateAmdRepairInvs;


         RETURN SUCCESS;
      END UpdateRow;

      FUNCTION DeleteRow
         RETURN NUMBER
      IS
      BEGIN
        <<updateAmdRepairInvs>> -- logically delete all records for the part_no and loc_sid
         BEGIN
            UPDATE AMD_REPAIR_INVS_SUM
               SET action_code = Amd_Defaults.DELETE_ACTION,
                   last_update_dt = SYSDATE
             WHERE     part_no = doRepairInvsSumDiff.part_no
                   AND site_location = doRepairInvsSumDiff.site_location;
         EXCEPTION
            WHEN OTHERS
            THEN
               ErrorMsg (SqlFunction       => 'update',
                         TableName         => 'amd_repair_invs_sum',
                         pError_location   => 150,
                         key1              => part_no,
                         key2              => site_location);
               DBMS_OUTPUT.put_line (
                     'updateAmdRepairInvs: 2 part_no='
                  || part_no
                  || ' site_location='
                  || site_location
                  || ' qty_on_hand='
                  || qty_on_hand
                  || ' action_code='
                  || action_code
                  || ' sqlcode='
                  || SQLCODE
                  || ' sqlerrm='
                  || SQLERRM);
               RAISE;
         END updateAmdRepairInvs;


         RETURN SUCCESS;
      END DeleteRow;
   BEGIN
      IF action_code = Amd_Defaults.INSERT_ACTION
      THEN
         RETURN insertRow;
      ELSIF action_code = Amd_Defaults.UPDATE_ACTION
      THEN
         RETURN updateRow;
      ELSIF action_code = Amd_Defaults.DELETE_ACTION
      THEN
         RETURN deleteRow;
      ELSE
         errorMsg (action_code,
                   'amd_repair_invs_sum',
                   68,
                   part_no,
                   site_location);
         DBMS_OUTPUT.put_line (
               'doRepairInvsSumDiff: action_code='
            || action_code
            || ' part_no='
            || part_no
            || ' site_location='
            || site_location
            || ' qty_on_hand='
            || qty_on_hand
            || ' action_code='
            || action_code
            || ' sqlcode='
            || SQLCODE
            || ' sqlerrm='
            || SQLERRM);

         RAISE badActionCode;
         RETURN FAILURE;
      END IF;
   END doRepairInvsSumDiff;


   FUNCTION getDateThreshold
      RETURN DATE
   IS
   BEGIN
      RETURN dateThreshold;
   END getDateThreshold;

   PROCEDURE setDateThreshold (date_in       IN VARCHAR2,
                               date_format   IN VARCHAR2 := 'MM/DD/YYYY')
   IS
   BEGIN
      dateThreshold := TO_DATE (date_in, date_format);
   END setDateThreshold;


   FUNCTION isInvalidDate (date_in IN DATE)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN TRUNC (date_in) < TRUNC (dateThreshold);
   END isInvalidDate;

   FUNCTION isInvalidDateYorN (date_in IN DATE)
      RETURN VARCHAR2
   IS
   BEGIN
      IF isInvalidDate (date_in)
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END isInvalidDateYorN;

   PROCEDURE dateWarningMsg (date_in            IN DATE,
                             part_no            IN VARCHAR2,
                             loc_sid            IN NUMBER,
                             order_no           IN VARCHAR2,
                             date_name          IN VARCHAR2,
                             warning_location   IN NUMBER,
                             rec_status         IN VARCHAR2 := '')
   IS
   BEGIN
      warningMsg (
         pWarning_Location   => warning_location,
         key1                => part_no,
         key2                => loc_sid,
         key3                => order_no,
         msg                 =>    TO_CHAR (date_in, 'MM/DD/YYYY')
                                || ' occurs before '
                                || TO_CHAR (dateThreshold, 'MM/DD/YYYY')
                                || ' for '
                                || date_name
                                || ' '
                                || rec_status);
   END dateWarningMsg;


   /* amd_in_repair diff functions */
   FUNCTION InsertRow (PART_NO            IN VARCHAR2,
                       LOC_SID            IN NUMBER,
                       REPAIR_DATE        IN DATE,
                       REPAIR_QTY         IN NUMBER,
                       ORDER_NO           IN VARCHAR2,
                       REPAIR_NEED_DATE   IN DATE)
      RETURN NUMBER
   IS
      wk_repair_need_date   DATE := repair_need_date;
   BEGIN
      IF isInvalidDate (repair_need_date)
      THEN
         dateWarningMsg (repair_need_date,
                         part_no,
                         loc_sid,
                         order_no,
                         'amd_in_repair.repair_need_date',
                         10,
                         rec_status   => 'Date set to null');
         wk_repair_need_date := NULL;
      END IF;

      IF isInvalidDate (repair_date)
      THEN
         dateWarningMsg (repair_date,
                         part_no,
                         loc_sid,
                         order_no,
                         'amd_in_repair.repair_date',
                         20,
                         rec_status   => 'Record rejected');
         RETURN SUCCESS; -- warning allows the app to continue and will be reported later
      END IF;

     <<insertAmdInRepair>>
      DECLARE
         PROCEDURE doUpdate
         IS
         BEGIN
           <<getActionCode>>
            DECLARE
               action_code   AMD_IN_REPAIR.action_code%TYPE;
               badInsert     EXCEPTION;
            BEGIN
               SELECT action_code
                 INTO action_code
                 FROM AMD_IN_REPAIR
                WHERE     part_no = insertRow.part_no
                      AND loc_sid = insertRow.loc_sid
                      AND order_no = insertRow.order_no;

               IF action_code != Amd_Defaults.DELETE_ACTION
               THEN
                  DBMS_OUTPUT.put_line (
                        'insertRow: insertAmdInRepair: getActionCode part_no='
                     || part_no
                     || ' loc_sid='
                     || loc_sid
                     || ' repair_date='
                     || TO_CHAR (repair_date, 'MM/DD/YYYY')
                     || ' order_no='
                     || order_no
                     || ' order_need_date='
                     || TO_CHAR (repair_need_date, 'MM/DD/YYYY')
                     || ' action_code='
                     || action_code);
                  RAISE badInsert;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  errorMsg (sqlFunction       => 'select',
                            tableName         => 'amd_in_repair',
                            pError_location   => 160,
                            key1              => part_no,
                            key2              => loc_sid,
                            key3              => order_no);
            END getActionCode;

            UPDATE AMD_IN_REPAIR
               SET part_no = insertRow.part_no,
                   loc_sid = insertRow.loc_sid,
                   repair_date = insertRow.repair_date,
                   repair_qty = insertRow.repair_qty,
                   order_no = insertRow.order_no,
                   repair_need_date = insertRow.wk_repair_need_date,
                   action_code = Amd_Defaults.INSERT_ACTION,
                   last_update_dt = SYSDATE
             WHERE     part_no = insertRow.part_no
                   AND loc_sid = insertRow.loc_sid
                   AND order_no = insertRow.order_no;
         END doUpdate;
      BEGIN
         INSERT INTO AMD_IN_REPAIR (part_no,
                                    loc_sid,
                                    repair_date,
                                    repair_qty,
                                    order_no,
                                    repair_need_date,
                                    action_code,
                                    last_update_dt)
              VALUES (part_no,
                      loc_sid,
                      repair_date,
                      repair_qty,
                      order_no,
                      wk_repair_need_date,
                      Amd_Defaults.INSERT_ACTION,
                      SYSDATE);
      EXCEPTION
         WHEN STANDARD.DUP_VAL_ON_INDEX
         THEN
            doUpdate;
         WHEN OTHERS
         THEN
            ErrorMsg (SqlFunction       => 'insert',
                      TableName         => 'amd_in_repair',
                      pError_location   => 170,
                      key1              => part_no,
                      key2              => loc_sid,
                      key3              => order_no);
            DBMS_OUTPUT.put_line (
                  'insertAmdInRepair: part_no='
               || part_no
               || ' loc_sid='
               || loc_sid
               || ' order_no='
               || order_no
               || ' sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            RAISE;
      END insertAmdInRepair;


      RETURN SUCCESS;
   END InsertRow;

   FUNCTION UpdateRow (PART_NO            IN VARCHAR2,
                       LOC_SID            IN NUMBER,
                       REPAIR_DATE        IN DATE,
                       REPAIR_QTY         IN NUMBER,
                       ORDER_NO           IN VARCHAR2,
                       REPAIR_NEED_DATE   IN DATE)
      RETURN NUMBER
   IS
      wk_repair_need_date   DATE := repair_need_date;
   BEGIN
      IF isInvalidDate (repair_need_date)
      THEN
         dateWarningMsg (repair_need_date,
                         part_no,
                         loc_sid,
                         order_no,
                         'amd_in_repair.repair_need_date',
                         10,
                         rec_status   => 'Date set to null');
         wk_repair_need_date := NULL;
      END IF;

      IF isInvalidDate (repair_date)
      THEN
         dateWarningMsg (repair_date,
                         part_no,
                         loc_sid,
                         order_no,
                         'amd_in_repair.repair_date',
                         20,
                         rec_status   => 'Record rejected');
         RETURN SUCCESS; -- warning allows the app to continue and will be reported later
      END IF;

     <<updateAmdInRepair>>
      BEGIN
         UPDATE AMD_IN_REPAIR
            SET repair_date = UpdateRow.repair_date,
                repair_qty = UpdateRow.repair_qty,
                repair_need_date = UpdateRow.wk_repair_need_date,
                action_code = Amd_Defaults.UPDATE_ACTION,
                last_update_dt = SYSDATE
          WHERE     part_no = UpdateRow.part_no
                AND loc_sid = UpdateRow.loc_sid
                AND order_no = UpdateRow.order_no;
      EXCEPTION
         WHEN OTHERS
         THEN
            ErrorMsg (SqlFunction       => 'update',
                      TableName         => 'amd_in_repair',
                      pError_location   => 180,
                      key1              => part_no,
                      key2              => loc_sid,
                      key3              => order_no);
            DBMS_OUTPUT.put_line (
                  'updateRow: part_no='
               || part_no
               || ' loc_sid='
               || loc_sid
               || ' repair_date='
               || TO_CHAR (repair_date, 'MM/DD/YYYY')
               || ' repair_qty='
               || repair_qty
               || ' order_no='
               || ' repair_need_date='
               || TO_CHAR (repair_need_date, 'MM/DD/YYYY')
               || order_no
               || ' sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            RAISE;
      END updateAmdInRepair;

      RETURN SUCCESS;
   END UpdateRow;

   FUNCTION inRepairDeleteRow (PART_NO    IN VARCHAR2,
                               LOC_SID    IN NUMBER,
                               ORDER_NO   IN VARCHAR2)
      RETURN NUMBER
   IS
      repair_qty         AMD_IN_REPAIR.repair_qty%TYPE;
      repair_date        AMD_IN_REPAIR.repair_date%TYPE;
      repair_need_date   AMD_IN_REPAIR.repair_need_date%TYPE;
   BEGIN
     <<updateAmdInRepair>>
      BEGIN
         UPDATE AMD_IN_REPAIR
            SET action_code = Amd_Defaults.DELETE_ACTION,
                last_update_dt = SYSDATE
          WHERE     PART_NO = inRepairDeleteRow.part_no
                AND LOC_SID = inRepairDeleteRow.LOC_SID
                AND ORDER_NO = inRepairDeleteRow.ORDER_NO;
      EXCEPTION
         WHEN OTHERS
         THEN
            ErrorMsg (SqlFunction       => 'update',
                      TableName         => 'amd_in_repair',
                      pError_location   => 190,
                      key1              => part_no,
                      key2              => loc_sid,
                      key3              => order_no);
            DBMS_OUTPUT.put_line (
                  'updateAmdInRepair: part_no='
               || part_no
               || ' loc_sid='
               || loc_sid
               || ' order_no='
               || order_no
               || ' sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            RAISE;
      END updateAmdInRepair;

     <<selectAmdInRepair>>
      BEGIN
         SELECT repair_qty, repair_date, repair_need_date
           INTO repair_qty, repair_date, repair_need_date
           FROM AMD_IN_REPAIR
          WHERE     part_no = inRepairDeleteRow.part_no
                AND loc_sid = inRepairDeleteRow.loc_sid
                AND order_no = inRepairDeleteRow.order_no;
      EXCEPTION
         WHEN OTHERS
         THEN
            ErrorMsg (SqlFunction       => 'select',
                      TableName         => 'amd_in_repair',
                      pError_location   => 200,
                      key1              => part_no,
                      key2              => loc_sid,
                      key3              => order_no);
            DBMS_OUTPUT.put_line (
                  'selectAmdInRepair: part_no='
               || part_no
               || ' loc_sid='
               || loc_sid
               || ' order_no='
               || order_no
               || ' sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            RAISE;
      END selectAmdInRepair;

      RETURN SUCCESS;
   END inRepairDeleteRow;


   /* amd_on_order diff functions */

   FUNCTION getNextLine (
      gold_order_number   IN amd_on_order.gold_order_number%TYPE)
      RETURN NUMBER
   IS
      maxLine   NUMBER;
   BEGIN
      SELECT MAX (line)
        INTO maxLine
        FROM amd_on_order
       WHERE gold_order_number = getNextLine.gold_order_number;

      IF maxLine IS NULL
      THEN
         maxLine := 0;
      END IF;

      RETURN maxLine + 1;
   END getNextLine;

   FUNCTION getCurrentLine (
      gold_order_number   IN amd_on_order.gold_order_number%TYPE,
      order_date          IN amd_on_order.order_date%TYPE,
      loc_sid             IN amd_on_order.loc_sid%TYPE)
      RETURN NUMBER
   IS
      curLine   NUMBER := NULL;
   BEGIN
      SELECT line
        INTO curLine
        FROM amd_on_order
       WHERE     gold_order_number = getCurrentLine.gold_order_number
             AND order_date = getCurrentLine.order_date
             AND loc_sid = getCurrentLine.loc_sid;

      RETURN curLine;
   EXCEPTION
      WHEN OTHERS
      THEN
         errorMsg (sqlFunction       => 'select',
                   tableName         => 'amd_on_order',
                   pError_location   => 210,
                   key1              => gold_order_number,
                   key2              => TO_CHAR (order_date, 'MM/DD/YYYY'),
                   key3              => loc_sid);
         DBMS_OUTPUT.put_line (
               'getCurrentLine: gold_order_number='
            || gold_order_number
            || ' order_date='
            || TO_CHAR (order_date, 'MM/DD/YYYY')
            || ' loc_sid='
            || loc_sid
            || ' sqlcode='
            || SQLCODE
            || ' sqlerrm='
            || SQLERRM);
         RAISE;
   END getCurrentLine;

   FUNCTION insertOnOrderRow (PART_NO              IN VARCHAR2,
                              LOC_SID              IN NUMBER,
                              ORDER_DATE           IN DATE,
                              ORDER_QTY            IN NUMBER,
                              GOLD_ORDER_NUMBER    IN VARCHAR2,
                              SCHED_RECEIPT_DATE   IN DATE)
      RETURN NUMBER
   IS
      -- site_location TMP_A2A_ORDER_INFO_LINE.SITE_LOCATION%TYPE := getSiteLocation(loc_sid) ;
      nextLine   amd_on_order.line%TYPE := getNextLine (gold_order_number);


      PROCEDURE doUpdate
      IS
      BEGIN
        <<getActionCode>>
         DECLARE
            action_code   AMD_ON_ORDER.action_code%TYPE;
            badInsert     EXCEPTION;
         BEGIN
            SELECT action_code
              INTO action_code
              FROM AMD_ON_ORDER
             WHERE     gold_order_number = insertOnOrderRow.gold_order_number
                   AND order_date = insertOnOrderRow.order_date
                   AND loc_sid = insertOnOrderRow.loc_sid;

            IF action_code != Amd_Defaults.DELETE_ACTION
            THEN
               DBMS_OUTPUT.put_line (
                     'insertOnOrderRow: 1 part_no='
                  || part_no
                  || ' loc_sid='
                  || loc_sid
                  || ' order_date='
                  || TO_CHAR (order_date, 'MM/DD/YYYY')
                  || ' order_qty='
                  || order_qty
                  || ' GOLD_ORDER_NUMBER='
                  || GOLD_ORDER_NUMBER
                  || ' SCHED_RECEIPT_DATE='
                  || TO_CHAR (SCHED_RECEIPT_DATE, 'MM/DD/YYYY'));
               RAISE badInsert;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               errorMsg (
                  sqlFunction       => 'select',
                  tableName         => 'amd_on_order',
                  pError_location   => 220,
                  key1              => gold_order_number,
                  key2              => TO_CHAR (order_date, 'MM/DD/YYYY'));
               DBMS_OUTPUT.put_line (
                     'insertOnOrderRow: 1 part_no='
                  || part_no
                  || ' loc_sid='
                  || loc_sid
                  || ' order_date='
                  || TO_CHAR (order_date, 'MM/DD/YYYY')
                  || ' order_qty='
                  || order_qty
                  || ' GOLD_ORDER_NUMBER='
                  || GOLD_ORDER_NUMBER
                  || ' SCHED_RECEIPT_DATE='
                  || TO_CHAR (SCHED_RECEIPT_DATE, 'MM/DD/YYYY')
                  || ' sqlcode='
                  || SQLCODE
                  || ' sqlerrm='
                  || SQLERRM);
               RAISE;
         END getActionCode;



         UPDATE AMD_ON_ORDER
            SET part_no = insertOnOrderRow.part_no,
                order_qty = insertOnOrderRow.order_qty,
                sched_receipt_date = insertOnOrderRow.sched_receipt_date,
                action_code = Amd_Defaults.INSERT_ACTION,
                last_update_dt = SYSDATE
          WHERE     gold_order_number = insertOnOrderRow.gold_order_number
                AND order_date = insertOnOrderRow.order_date
                AND loc_sid = insertOnOrderRow.loc_sid;
      EXCEPTION
         WHEN OTHERS
         THEN
            errorMsg (sqlFunction       => 'update',
                      tableName         => 'amd_on_order',
                      pError_location   => 230,
                      key1              => gold_order_number,
                      key2              => TO_CHAR (order_date, 'MM/DD/YYYY'));
      END doUpdate;
   BEGIN
     <<insertAmdOnOrder>>
      BEGIN
         INSERT INTO AMD_ON_ORDER (part_no,
                                   loc_sid,
                                   order_date,
                                   order_qty,
                                   gold_order_number,
                                   action_code,
                                   last_update_dt,
                                   sched_receipt_date,
                                   line)
              VALUES (part_no,
                      loc_sid,
                      order_date,
                      order_qty,
                      gold_order_number,
                      Amd_Defaults.INSERT_ACTION,
                      SYSDATE,
                      sched_receipt_date,
                      nextline);
      EXCEPTION
         WHEN STANDARD.DUP_VAL_ON_INDEX
         THEN
            doUpdate;
         WHEN OTHERS
         THEN
            ErrorMsg (
               SqlFunction       => 'insert',
               TableName         => 'amd_on_order',
               pError_location   => 240,
               key1              => gold_order_number,
               key2              => TO_CHAR (order_date,
                                             'MM/DD/YYYY HH:MM:SS'));
            DBMS_OUTPUT.put_line (
                  'insertAmdOnOrder: gold_order_number='
               || gold_order_number
               || ' order_date='
               || TO_CHAR (order_date, 'MM/DD/YYYY')
               || ' sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            RAISE;
      END insertAmdOnOrder;



      RETURN SUCCESS;
   END insertOnOrderRow;

   FUNCTION updateOnOrderRow (PART_NO              IN VARCHAR2,
                              LOC_SID              IN NUMBER,
                              ORDER_DATE           IN DATE,
                              ORDER_QTY            IN NUMBER,
                              GOLD_ORDER_NUMBER    IN VARCHAR2,
                              SCHED_RECEIPT_DATE   IN DATE)
      RETURN NUMBER
   IS
   -- site_location TMP_A2A_ORDER_INFO_LINE.site_location%TYPE := getSiteLocation(loc_sid) ;

   BEGIN
     <<updateAmdOnOrder>>
      BEGIN
         UPDATE AMD_ON_ORDER
            SET part_no = UpdateOnOrderRow.part_no,
                order_qty = UpdateOnOrderRow.order_qty,
                action_code = Amd_Defaults.UPDATE_ACTION,
                sched_receipt_date = updateOnOrderRow.sched_receipt_date,
                last_update_dt = SYSDATE
          WHERE     gold_order_number = UpdateOnOrderRow.gold_order_number
                AND order_date = UpdateOnOrderRow.order_date
                AND loc_sid = UpdateOnOrderRow.loc_sid;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN ErrorMsg (
                      pSqlFunction      => 'update',
                      pTableName        => 'amd_on_order',
                      pError_location   => 250,
                      pReturn_code      => FAILURE,
                      pKey_1            => UpdateOnOrderRow.gold_order_number,
                      pKey_2            => TO_CHAR (
                                             UpdateOnOrderRow.order_date,
                                             'MM/DD/YYYY HH:MM:SS'));
      END updateAmdOnOrder;


      RETURN SUCCESS;
   END updateOnOrderRow;

   FUNCTION deleterow (part_no             IN VARCHAR2,
                       loc_sid             IN NUMBER,
                       gold_order_number   IN VARCHAR2,
                       order_date          IN DATE)
      RETURN NUMBER
   IS
   BEGIN
     <<updateAmdOnOrder>>
      BEGIN
         UPDATE AMD_ON_ORDER
            SET action_code = Amd_Defaults.DELETE_ACTION,
                last_update_dt = SYSDATE
          WHERE     GOLD_ORDER_NUMBER = DeleteRow.gold_order_number
                AND order_date = DeleteRow.order_date
                AND loc_sid = DeleteRow.loc_sid;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN ErrorMsg (
                      pSqlFunction      => 'update',
                      pTableName        => 'amd_on_order',
                      pError_location   => 260,
                      pReturn_code      => FAILURE,
                      pKey_1            => gold_order_number,
                      pKey_2            => TO_CHAR (order_date,
                                                    'MM/DD/YYYY HH:MM:SS'));
      END updateAmdOnOrder;



      RETURN SUCCESS;
   END DeleteRow;

   FUNCTION doOnHandInvsSumDiff (part_no        IN VARCHAR2,
                                 spo_location   IN VARCHAR2,
                                 qty_on_hand    IN NUMBER,
                                 action_code    IN VARCHAR2)
      RETURN NUMBER
   IS
      badActionCode   EXCEPTION;

      FUNCTION InsertRow
         RETURN NUMBER
      IS
      BEGIN
        <<insertAmdOnHandInvsSums>>
         DECLARE
            PROCEDURE doUpdate
            IS
            BEGIN
              <<getActionCode>>
               DECLARE
                  action_code   AMD_ON_HAND_INVS.action_code%TYPE;
                  badInsert     EXCEPTION;
               BEGIN
                  SELECT action_code
                    INTO action_code
                    FROM AMD_ON_HAND_INVS_SUM
                   WHERE     part_no = doOnHandInvsSumDiff.part_no
                         AND spo_location = doOnHandInvsSumDiff.spo_location;

                  IF action_code != Amd_Defaults.DELETE_ACTION
                  THEN
                     DBMS_OUTPUT.put_line (
                           'doOnHandInvsSumDiff: 1 part_no='
                        || part_no
                        || ' spo_location='
                        || spo_location
                        || ' qty_on_hand='
                        || qty_on_hand
                        || ' action_code='
                        || action_code);
                     RAISE badInsert;
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     errorMsg (
                        SqlFunction       => 'select',
                        TableName         => 'amd_on_hand_invs_sum',
                        pError_location   => 270,
                        key1              => doOnHandInvsSumDiff.part_no,
                        key2              => doOnHandInvsSumDiff.spo_location);
               END getActionCode;

               UPDATE AMD_ON_HAND_INVS_SUM
                  SET qty_on_hand = doOnHandInvsSumDiff.qty_on_hand,
                      action_code = Amd_Defaults.INSERT_ACTION,
                      last_update_dt = SYSDATE
                WHERE     part_no = doOnHandInvsSumDiff.part_no
                      AND spo_location = doOnHandInvsSumDiff.spo_location;
            END doUpdate;
         BEGIN
            INSERT INTO AMD_ON_HAND_INVS_SUM (part_no,
                                              spo_location,
                                              qty_on_hand,
                                              action_code,
                                              last_update_dt)
                 VALUES (part_no,
                         spo_location,
                         qty_on_hand,
                         Amd_Defaults.INSERT_ACTION,
                         SYSDATE);
         EXCEPTION
            WHEN STANDARD.DUP_VAL_ON_INDEX
            THEN
               doUpdate;
            WHEN OTHERS
            THEN
               RETURN ErrorMsg (pSqlFunction      => 'insert',
                                pTableName        => 'amd_on_hand_invs_sum',
                                pError_location   => 280,
                                pReturn_code      => FAILURE,
                                pKey_1            => part_no,
                                pKey_2            => spo_location);
         END insertAmdOnHandInvs;


         RETURN SUCCESS;
      END InsertRow;

      FUNCTION UpdateRow
         RETURN NUMBER
      IS
         -- get the detail for the summarized inv_qty
         result   NUMBER;
      BEGIN
        <<updateAmdOnHandInvs>>
         BEGIN
            UPDATE AMD_ON_HAND_INVS_SUM
               SET qty_on_hand = doOnHandInvsSumDiff.qty_on_hand,
                   action_code = Amd_Defaults.UPDATE_ACTION,
                   last_update_dt = SYSDATE
             WHERE     part_no = doOnHandInvsSumDiff.part_no
                   AND spo_location = doOnHandInvsSumDiff.spo_location;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN ErrorMsg (pSqlFunction      => 'update',
                                pTableName        => 'amd_on_hand_invs_sum',
                                pError_location   => 290,
                                pReturn_code      => FAILURE,
                                pKey_1            => part_no,
                                pKey_2            => spo_location);
         END updateAmdOnHandInvs;


         RETURN SUCCESS;
      END UpdateRow;

      FUNCTION DeleteRow
         RETURN NUMBER
      IS
      BEGIN
        <<updateAmdOnHandInvs>> -- logically delete all records for the part_no and loc_sid
         BEGIN
            UPDATE AMD_ON_HAND_INVS_SUM
               SET action_code = Amd_Defaults.DELETE_ACTION,
                   last_update_dt = SYSDATE
             WHERE     part_no = doOnHandInvsSumDiff.part_no
                   AND spo_location = doOnHandInvsSumDiff.spo_location;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN ErrorMsg (pSqlFunction      => 'update',
                                pTableName        => 'amd_on_hand_invs_sum',
                                pError_location   => 300,
                                pReturn_code      => FAILURE,
                                pKey_1            => part_no,
                                pKey_2            => spo_location);
         END updateAmdOnHandInvs;


         RETURN SUCCESS;
      END DeleteRow;
   BEGIN
      IF action_code = Amd_Defaults.INSERT_ACTION
      THEN
         RETURN insertRow;
      ELSIF action_code = Amd_Defaults.UPDATE_ACTION
      THEN
         RETURN updateRow;
      ELSIF action_code = Amd_Defaults.DELETE_ACTION
      THEN
         RETURN deleteRow;
      ELSE
         errorMsg (action_code,
                   'amd_on_hand_invs_sum',
                   330,
                   part_no,
                   spo_location);
         DBMS_OUTPUT.put_line (
               'doOnHandInvsSumDiff: 2 part_no='
            || part_no
            || ' spo_location='
            || spo_location
            || ' qty_on_hand='
            || qty_on_hand
            || ' action_code='
            || action_code);
         RAISE badActionCode;
         RETURN FAILURE;
      END IF;
   END doOnHandInvsSumDiff;

   /* amd_on_hand_invs diff functions */
   FUNCTION InsertRow (part_no   IN VARCHAR2,
                       loc_sid   IN NUMBER,
                       inv_qty   IN NUMBER)
      RETURN NUMBER
   IS
   BEGIN
     <<insertAmdOnHandInvs>>
      DECLARE
         PROCEDURE doUpdate
         IS
         BEGIN
           <<getActionCode>>
            DECLARE
               action_code   AMD_ON_HAND_INVS.action_code%TYPE;
               badInsert     EXCEPTION;
            BEGIN
               SELECT action_code
                 INTO action_code
                 FROM AMD_ON_HAND_INVS
                WHERE     part_no = insertRow.part_no
                      AND loc_sid = insertRow.loc_sid;

               IF action_code != Amd_Defaults.DELETE_ACTION
               THEN
                  DBMS_OUTPUT.put_line (
                        'InsertRow: part_no='
                     || insertRow.part_no
                     || ' loc_sid='
                     || insertRow.loc_sid
                     || ' inv_qty='
                     || inv_qty
                     || ' action_code='
                     || action_code);
                  RAISE badInsert;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  errorMsg (SqlFunction       => 'select',
                            TableName         => 'amd_on_hand_invs',
                            pError_location   => 310,
                            key1              => insertRow.part_no,
                            key2              => insertRow.loc_sid);
            END getActionCode;

            UPDATE AMD_ON_HAND_INVS
               SET inv_qty = insertRow.inv_qty,
                   action_code = Amd_Defaults.INSERT_ACTION,
                   last_update_dt = SYSDATE
             WHERE     part_no = insertRow.part_no
                   AND loc_sid = insertRow.loc_sid;
         END doUpdate;
      BEGIN
         INSERT INTO AMD_ON_HAND_INVS (part_no,
                                       loc_sid,
                                       inv_qty,
                                       action_code,
                                       last_update_dt)
              VALUES (part_no,
                      InsertRow.loc_sid,
                      inv_qty,
                      Amd_Defaults.INSERT_ACTION,
                      SYSDATE);
      EXCEPTION
         WHEN STANDARD.DUP_VAL_ON_INDEX
         THEN
            doUpdate;
         WHEN OTHERS
         THEN
            RETURN ErrorMsg (pSqlFunction      => 'insert',
                             pTableName        => 'amd_on_hand_invs',
                             pError_location   => 320,
                             pReturn_code      => FAILURE,
                             pKey_1            => part_no,
                             pKey_2            => TO_CHAR (InsertRow.loc_sid));
      END insertAmdOnHandInvs;


      RETURN SUCCESS;
   END InsertRow;

   FUNCTION UpdateRow (part_no   IN VARCHAR2,
                       loc_sid   IN NUMBER,
                       inv_qty   IN NUMBER)
      RETURN NUMBER
   IS
      -- get the detail for the summarized inv_qty
      result   NUMBER;
   BEGIN
     <<updateAmdOnHandInvs>>
      BEGIN
         UPDATE AMD_ON_HAND_INVS
            SET inv_qty = UpdateRow.inv_qty,
                action_code = Amd_Defaults.UPDATE_ACTION,
                last_update_dt = SYSDATE
          WHERE part_no = UpdateRow.part_no AND loc_sid = UpdateRow.loc_sid;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN ErrorMsg (pSqlFunction      => 'update',
                             pTableName        => 'amd_on_hand_invs',
                             pError_location   => 330,
                             pReturn_code      => FAILURE,
                             pKey_1            => part_no,
                             pKey_2            => TO_CHAR (loc_sid));
      END updateAmdOnHandInvs;


      RETURN SUCCESS;
   END UpdateRow;

   FUNCTION DeleteRow (part_no IN VARCHAR2, loc_sid IN NUMBER)
      RETURN NUMBER
   IS
   BEGIN
     <<updateAmdOnHandInvs>> -- logically delete all records for the part_no and loc_sid
      BEGIN
         UPDATE AMD_ON_HAND_INVS
            SET action_code = Amd_Defaults.DELETE_ACTION,
                last_update_dt = SYSDATE
          WHERE part_no = DeleteRow.part_no AND loc_sid = DeleteRow.loc_sid;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN ErrorMsg (pSqlFunction      => 'update',
                             pTableName        => 'amd_on_hand_invs',
                             pError_location   => 340,
                             pReturn_code      => FAILURE,
                             pKey_1            => part_no,
                             pKey_2            => TO_CHAR (loc_sid));
      END updateAmdOnHandInvs;


      RETURN SUCCESS;
   END DeleteRow;

   /*amd_rsp diff functions */

   FUNCTION RspInsertRow (part_no     IN VARCHAR2,
                          loc_sid     IN NUMBER,
                          rsp_inv     IN NUMBER,
                          rsp_level   IN NUMBER)
      RETURN NUMBER
   IS
      PROCEDURE doUpdate
      IS
      BEGIN
        <<getActionCode>>
         DECLARE
            action_code   AMD_RSP.action_code%TYPE;
            badInsert     EXCEPTION;
         BEGIN
            SELECT action_code
              INTO action_code
              FROM AMD_RSP
             WHERE     part_no = RspInsertRow.part_no
                   AND loc_sid = RspInsertRow.loc_sid;

            IF action_code != Amd_Defaults.DELETE_ACTION
            THEN
               DBMS_OUTPUT.put_line (
                     'RspInsertRow: part_no='
                  || part_no
                  || ' loc_sid='
                  || loc_sid
                  || ' rsp_inv='
                  || rsp_inv
                  || 'rsp_level='
                  || rsp_level);
               RAISE badInsert;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               errorMsg (SqlFunction       => 'select',
                         TableName         => 'amd_rsp',
                         pError_location   => 350,
                         key1              => RspInsertRow.part_no,
                         key2              => RspInsertRow.loc_sid);
               DBMS_OUTPUT.put_line (
                     'RspInsertRow: 1  part_no='
                  || part_no
                  || ' loc_sid='
                  || ' rsp_inv='
                  || rsp_inv
                  || ' rsp_level='
                  || rsp_level
                  || ' sqlcode='
                  || SQLCODE
                  || ' sqlerrm='
                  || SQLERRM);

               RAISE;
         END getActionCode;

         UPDATE AMD_RSP
            SET rsp_inv = RspInsertRow.rsp_inv,
                rsp_level = RspInsertRow.rsp_level,
                action_code = Amd_Defaults.INSERT_ACTION,
                last_update_dt = SYSDATE
          WHERE     part_no = RspInsertRow.part_no
                AND loc_sid = RspInsertRow.loc_sid;
      EXCEPTION
         WHEN OTHERS
         THEN
            errorMsg (sqlFunction       => 'update',
                      tableName         => 'amd_rsp',
                      pError_location   => 360,
                      key1              => RspInsertRow.part_no,
                      key2              => RspInsertRow.loc_sid);
      END doUpdate;
   BEGIN
     <<insertAmdRsp>>
      BEGIN
         INSERT INTO AMD_RSP (part_no,
                              loc_sid,
                              rsp_inv,
                              rsp_level,
                              action_code,
                              last_update_dt)
              VALUES (part_no,
                      RspInsertRow.loc_sid,
                      rsp_inv,
                      rsp_level,
                      Amd_Defaults.INSERT_ACTION,
                      SYSDATE);
      EXCEPTION
         WHEN STANDARD.DUP_VAL_ON_INDEX
         THEN
            doUpdate;
         WHEN OTHERS
         THEN
            RETURN ErrorMsg (
                      pSqlFunction      => 'insert',
                      pTableName        => 'amd_rsp',
                      pError_location   => 370,
                      pReturn_code      => FAILURE,
                      pKey_1            => part_no,
                      pkey_2            => TO_CHAR (RspInsertRow.loc_sid));
      END insertAmdRsp;

      RETURN SUCCESS;
   END RspInsertRow;


   FUNCTION RspUpdateRow (part_no     IN VARCHAR2,
                          loc_sid     IN NUMBER,
                          rsp_inv     IN NUMBER,
                          rsp_level   IN NUMBER)
      RETURN NUMBER
   IS
      result   NUMBER;
   BEGIN
     <<updateAmdRsp>>
      BEGIN
         UPDATE AMD_RSP
            SET rsp_inv = RspUpdateRow.rsp_inv,
                rsp_level = RspUpdateRow.rsp_level,
                action_code = Amd_Defaults.UPDATE_ACTION,
                last_update_dt = SYSDATE
          WHERE     part_no = RspUpdateRow.part_no
                AND loc_sid = RspUpdateRow.loc_sid;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN ErrorMsg (
                      pSqlFunction      => 'update',
                      pTableName        => 'amd_rsp',
                      pError_location   => 380,
                      pReturn_code      => FAILURE,
                      pKey_1            => RspUpdateRow.part_no,
                      pKey_2            => TO_CHAR (RspUpdateRow.loc_sid));
      END updateAmdRsp;

      RETURN SUCCESS;
   END RspUpdateRow;

   FUNCTION RspDeleteRow (part_no IN VARCHAR2, loc_sid IN NUMBER)
      RETURN NUMBER
   IS
   BEGIN
     <<updateAmdRsp>> -- logically delete all records for the part_no and loc_sid
      BEGIN
         UPDATE AMD_RSP
            SET action_code = Amd_Defaults.DELETE_ACTION,
                last_update_dt = SYSDATE
          WHERE     part_no = RspDeleteRow.part_no
                AND loc_sid = RspDeleteRow.loc_sid;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN ErrorMsg (pSqlFunction      => 'update',
                             pTableName        => 'amd_rsp',
                             pError_location   => 390,
                             pReturn_code      => FAILURE,
                             pKey_1            => part_no,
                             pKey_2            => TO_CHAR (loc_sid));
      END updateAmdRsp;

      RETURN SUCCESS;
   END RspDeleteRow;



   /* amd_rsp_sum diff functions */

   FUNCTION doRspSumDiff (part_no         IN VARCHAR2,
                          rsp_location    IN VARCHAR2,
                          override_type   IN VARCHAR2, /* added 10/29/2007 by dse */
                          qty_on_hand     IN NUMBER,
                          rsp_level       IN NUMBER,
                          action_code     IN VARCHAR2)
      RETURN NUMBER
   IS
      badActionCode   EXCEPTION;


      PROCEDURE InsertRow
      IS
         PROCEDURE doUpdate
         IS
            action_code   AMD_RSP_SUM.action_code%TYPE;
            badInsert     EXCEPTION;
         BEGIN
           <<getActionCode>>
            BEGIN
               SELECT action_code
                 INTO action_code
                 FROM AMD_RSP_SUM
                WHERE     part_no = doRspSumDiff.part_no
                      AND rsp_location = doRspSumDiff.rsp_location
                      AND override_type = doRspSumDiff.override_type;

               IF action_code != Amd_Defaults.DELETE_ACTION
               THEN
                  DBMS_OUTPUT.put_line (
                        'doRspSumDiff: 1 part_no='
                     || part_no
                     || ' rsp_location='
                     || rsp_location
                     || ' override_type='
                     || override_type
                     || ' qty_on_hand='
                     || qty_on_hand
                     || ' rsp_level='
                     || rsp_level
                     || ' action_code='
                     || action_code);
                  RAISE badInsert;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  errorMsg (SqlFunction       => 'select',
                            TableName         => 'amd_rsp_sum',
                            pError_location   => 400,
                            key1              => doRspSumDiff.part_no,
                            key2              => doRspSumDiff.rsp_location,
                            key3              => doRspSumDiff.override_type);
                  DBMS_OUTPUT.put_line (
                        'doRspSumDiff: 2 part_no='
                     || part_no
                     || ' rsp_location='
                     || rsp_location
                     || ' override_type='
                     || override_type
                     || ' qty_on_hand='
                     || qty_on_hand
                     || ' rsp_level='
                     || rsp_level
                     || ' action_code='
                     || action_code
                     || ' sqlcode='
                     || SQLCODE
                     || ' sqlerrm='
                     || SQLERRM);
                  RAISE;
            END getActionCode;

            UPDATE AMD_RSP_SUM
               SET qty_on_hand = doRspSumDiff.qty_on_hand,
                   rsp_level = doRspSumDiff.rsp_level,
                   action_code = Amd_Defaults.INSERT_ACTION,
                   last_update_dt = SYSDATE
             WHERE     part_no = doRspSumDiff.part_no
                   AND rsp_location = doRspSumDiff.rsp_location
                   AND override_type = doRspSumDiff.override_type;
         END doUpdate;
      BEGIN
        <<insertAmdRspSum>>
         BEGIN
            INSERT INTO AMD_RSP_SUM (part_no,
                                     rsp_location,
                                     override_type,
                                     qty_on_hand,
                                     rsp_level,
                                     action_code,
                                     last_update_dt)
                 VALUES (part_no,
                         rsp_location,
                         override_type,
                         qty_on_hand,
                         rsp_level,
                         Amd_Defaults.INSERT_ACTION,
                         SYSDATE);
         EXCEPTION
            WHEN STANDARD.DUP_VAL_ON_INDEX
            THEN
               doUpdate;
            WHEN OTHERS
            THEN
               ErrorMsg (sqlFunction       => 'insert',
                         tableName         => 'amd_rsp_sum',
                         pError_location   => 410,
                         key1              => part_no,
                         key2              => rsp_location,
                         key3              => override_type);
               DBMS_OUTPUT.put_line (
                     'doRspSumDiff: 2 part_no='
                  || part_no
                  || ' rsp_location='
                  || rsp_location
                  || ' override_type='
                  || override_type
                  || ' qty_on_hand='
                  || qty_on_hand
                  || ' rsp_level='
                  || rsp_level
                  || ' action_code='
                  || action_code
                  || ' sqlcode='
                  || SQLCODE
                  || ' sqlerrm='
                  || SQLERRM);
               RAISE;
         END insertAmdRspSum;
      END InsertRow;

      PROCEDURE UpdateRow
      IS
         -- get the detail for the summarized inv_qty
         result   NUMBER;
      BEGIN
        <<updateAmdRspSum>>
         BEGIN
            UPDATE AMD_RSP_SUM
               SET qty_on_hand = doRspSumDiff.qty_on_hand,
                   rsp_level = doRspSumDiff.rsp_level,
                   action_code = Amd_Defaults.UPDATE_ACTION,
                   last_update_dt = SYSDATE
             WHERE     part_no = doRspSumDiff.part_no
                   AND rsp_location = doRspSumDiff.rsp_location
                   AND override_type = doRspSumDiff.override_type;
         EXCEPTION
            WHEN OTHERS
            THEN
               ErrorMsg (SqlFunction       => 'update',
                         TableName         => 'amd_rsp_sum',
                         pError_location   => 420,
                         key1              => part_no,
                         key2              => rsp_location,
                         key3              => override_type);
               DBMS_OUTPUT.put_line (
                     'doRspSumDiff: 3 part_no='
                  || part_no
                  || ' rsp_location='
                  || rsp_location
                  || ' override_type='
                  || override_type
                  || ' qty_on_hand='
                  || qty_on_hand
                  || ' rsp_level='
                  || rsp_level
                  || ' action_code='
                  || action_code
                  || ' sqlcode='
                  || SQLCODE
                  || ' sqlerrm='
                  || SQLERRM);
               RAISE;
         END updateAmdRspSum;
      END UpdateRow;

      PROCEDURE DeleteRow
      IS
      BEGIN
        <<updateAmdRspSum>> -- logically delete all records for the part_no and loc_sid
         BEGIN
            UPDATE AMD_RSP_SUM
               SET action_code = Amd_Defaults.DELETE_ACTION,
                   last_update_dt = SYSDATE
             WHERE     part_no = doRspSumDiff.part_no
                   AND rsp_location = doRspSumDiff.rsp_location
                   AND override_type = doRspSumDiff.override_type;
         EXCEPTION
            WHEN OTHERS
            THEN
               ErrorMsg (SqlFunction       => 'update',
                         TableName         => 'amd_rsp_sum',
                         pError_location   => 430,
                         key1              => part_no,
                         key2              => rsp_location,
                         key3              => override_type);
               DBMS_OUTPUT.put_line (
                     'doRspSumDiff: 4 part_no='
                  || part_no
                  || ' rsp_location='
                  || rsp_location
                  || ' override_type='
                  || override_type
                  || ' qty_on_hand='
                  || qty_on_hand
                  || ' rsp_level='
                  || rsp_level
                  || ' action_code='
                  || action_code
                  || ' sqlcode='
                  || SQLCODE
                  || ' sqlerrm='
                  || SQLERRM);
               RAISE;
         END updateAmdRspSum;
      END DeleteRow;
   BEGIN
      IF action_code = Amd_Defaults.INSERT_ACTION
      THEN
         insertRow;
      ELSIF action_code = Amd_Defaults.UPDATE_ACTION
      THEN
         updateRow;
      ELSIF action_code = Amd_Defaults.DELETE_ACTION
      THEN
         deleteRow;
      ELSE
         errorMsg (action_code,
                   'rsp_sum',
                   331,
                   part_no,
                   rsp_location);
         DBMS_OUTPUT.put_line (
               'doRspSumDiff: 5 part_no='
            || part_no
            || ' rsp_location='
            || rsp_location
            || ' override_type='
            || override_type
            || ' qty_on_hand='
            || qty_on_hand
            || ' rsp_level='
            || rsp_level
            || ' action_code='
            || action_code
            || ' sqlcode='
            || SQLCODE
            || ' sqlerrm='
            || SQLERRM);
         RAISE badActionCode;
      END IF;



      RETURN SUCCESS;
   EXCEPTION
      WHEN OTHERS
      THEN
         ErrorMsg (SqlFunction       => 'doRspSumDiff(' || action_code || ')',
                   TableName         => 'amd_rsp_sum / tmp_a2a_loc_part_override',
                   pError_Location   => 400);
         RETURN FAILURE;
   END doRspSumDiff;



   /* amd_in_transits diff functions */
   FUNCTION InsertRow (to_loc_sid         IN NUMBER,
                       quantity           IN NUMBER,
                       document_id        IN VARCHAR2,
                       part_no            IN VARCHAR2,
                       from_location      IN VARCHAR2,
                       in_transit_date    IN DATE,
                       serviceable_flag   IN VARCHAR2)
      RETURN NUMBER
   IS
      result   NUMBER;

      --site_location TMP_IN_TRANSITS_DIFF.site_location%TYPE := getSiteLocation(to_loc_sid) ;

      PROCEDURE doUpdate
      IS
      BEGIN
        <<GetActionCode>>
         DECLARE
            action_code   AMD_IN_TRANSITS.action_code%TYPE;
            badInsert     EXCEPTION;
         BEGIN
            SELECT action_code
              INTO action_code
              FROM AMD_IN_TRANSITS
             WHERE document_id = insertRow.document_id;

            IF action_code != Amd_Defaults.DELETE_ACTION
            THEN
               DBMS_OUTPUT.put_line (
                     'insertRow: to_loc_sid='
                  || to_loc_sid
                  || ' quantity='
                  || quantity
                  || ' document_id='
                  || document_id
                  || ' part_no='
                  || part_no
                  || ' from_location='
                  || from_location
                  || ' in_transit_date='
                  || TO_CHAR (in_transit_date, 'MM/DD/YYYY')
                  || ' serviceable_flag='
                  || serviceable_flag);
               RAISE badInsert;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               ErrorMsg (sqlFunction       => 'select',
                         tableName         => 'amd_in_transits',
                         pError_location   => 440,
                         key1              => insertRow.document_id);
         END getActionCode;

         UPDATE AMD_IN_TRANSITS
            SET to_loc_sid = insertRow.to_loc_sid,
                quantity = insertRow.quantity,
                action_code = Amd_Defaults.INSERT_ACTION,
                last_update_dt = SYSDATE,
                part_no = insertRow.part_no,
                from_location = insertRow.from_location,
                in_transit_date = insertRow.in_transit_date,
                serviceable_flag = insertRow.serviceable_flag
          WHERE document_id = insertRow.document_id;
      END doUpdate;
   BEGIN
     <<insertAmdInTransits>>
      BEGIN
         INSERT INTO AMD_IN_TRANSITS (to_loc_sid,
                                      quantity,
                                      action_code,
                                      last_update_dt,
                                      document_id,
                                      part_no,
                                      from_location,
                                      in_transit_date,
                                      serviceable_flag)
              VALUES (to_loc_sid,
                      quantity,
                      Amd_Defaults.INSERT_ACTION,
                      SYSDATE,
                      document_id,
                      part_no,
                      from_location,
                      in_transit_date,
                      serviceable_flag);
      EXCEPTION
         WHEN STANDARD.DUP_VAL_ON_INDEX
         THEN
            doUpdate;
         WHEN OTHERS
         THEN
            RETURN ErrorMsg (pSqlFunction      => 'insert',
                             pTableName        => 'amd_in_transits',
                             pError_location   => 450,
                             pReturn_code      => FAILURE,
                             pKey_1            => document_id,
                             pKey_2            => part_no,
                             pKey_3            => to_loc_sid,
                             pKey_4            => in_transit_date);
      END insertAmdInTransits;

      RETURN SUCCESS;
   END InsertRow;

   FUNCTION UpdateRow (TO_LOC_SID         IN NUMBER,
                       QUANTITY           IN NUMBER,
                       DOCUMENT_ID        IN VARCHAR2,
                       PART_NO            IN VARCHAR2,
                       FROM_LOCATION      IN VARCHAR2,
                       IN_TRANSIT_DATE    IN DATE,
                       SERVICEABLE_FLAG   IN VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
     <<updateAmdInTransits>>
      BEGIN
         UPDATE AMD_IN_TRANSITS
            SET quantity = UpdateRow.quantity,
                action_code = Amd_Defaults.UPDATE_ACTION,
                last_update_dt = SYSDATE,
                from_location = UpdateRow.from_location,
                in_transit_date = UpdateRow.in_transit_date
          WHERE     document_id = UpdateRow.document_id
                AND part_no = UpdateRow.part_no
                AND to_loc_sid = UpdateRow.to_loc_sid;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN ErrorMsg (pSqlFunction      => 'update',
                             pTableName        => 'amd_in_transits',
                             pError_location   => 460,
                             pReturn_code      => FAILURE,
                             pKey_1            => document_id,
                             pKey_2            => part_no,
                             pKey_3            => TO_CHAR (to_loc_sid));
      END updateAmdInTransit;


      RETURN SUCCESS;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN ErrorMsg (pSqlFunction      => 'updateRow',
                          pTableName        => 'amd_in_transits',
                          pError_location   => 470,
                          pReturn_code      => FAILURE,
                          pKey_1            => part_no);
   END UpdateRow;

   FUNCTION DeleteRow (DOCUMENT_ID   IN VARCHAR2,
                       PART_NO       IN VARCHAR2,
                       TO_LOC_SID    IN NUMBER)
      RETURN NUMBER
   IS
      quantity          AMD_IN_TRANSITS.quantity%TYPE;
      from_location     AMD_IN_TRANSITS.from_location%TYPE;
      in_transit_date   AMD_IN_TRANSITS.in_transit_date%TYPE;
   BEGIN
     <<updateAmdInTransit>>
      BEGIN
         UPDATE AMD_IN_TRANSITS
            SET quantity = DeleteRow.quantity,
                from_location = DeleteRow.from_location,
                in_transit_date = DeleteRow.in_transit_date,
                action_code = Amd_Defaults.DELETE_ACTION,
                last_update_dt = SYSDATE
          WHERE     DOCUMENT_ID = DeleteRow.DOCUMENT_ID
                AND PART_NO = Deleterow.PART_NO
                AND TO_LOC_SID = DeleteRow.TO_LOC_SID;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN ErrorMsg (pSqlFunction      => 'update',
                             pTableName        => 'amd_in_transits',
                             pError_location   => 480,
                             pReturn_code      => FAILURE,
                             pKey_1            => document_id,
                             pKey_2            => part_no,
                             pKey_3            => TO_CHAR (to_loc_sid));
      END updateAmdInTransit;

     <<selectAmdInTransit>>
      BEGIN
         SELECT quantity, from_location, in_transit_date
           INTO quantity, from_location, in_transit_date
           FROM AMD_IN_TRANSITS
          WHERE     document_id = DeleteRow.document_id
                AND part_no = DeleteRow.part_no
                AND to_loc_sid = DeleteRow.to_loc_sid;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN ErrorMsg (pSqlFunction      => 'select',
                             pTableName        => 'amd_in_transits',
                             pError_location   => 490,
                             pReturn_code      => FAILURE,
                             pKey_1            => document_id,
                             pKey_2            => part_no,
                             pKey_3            => TO_CHAR (to_loc_sid));
      END selectAmdInTransit;

      RETURN SUCCESS;
   END DeleteRow;

   FUNCTION InsertRow (part_no            IN VARCHAR2,
                       site_location      IN VARCHAR2,
                       quantity           IN NUMBER,
                       serviceable_flag   IN VARCHAR2)
      RETURN NUMBER
   IS
      result   NUMBER;

      FUNCTION doUpdate
         RETURN NUMBER
      IS
         action_code   AMD_IN_TRANSITS_SUM.action_code%TYPE;
         badInsert     EXCEPTION;
      BEGIN
         UPDATE AMD_IN_TRANSITS_SUM
            SET quantity = InsertRow.quantity,
                action_code = Amd_Defaults.INSERT_ACTION,
                last_update_dt = SYSDATE
          WHERE     part_no = InsertRow.part_no
                AND site_location = InsertRow.site_location
                AND serviceable_flag = InsertRow.serviceable_flag;

         RETURN SUCCESS;
      EXCEPTION
         WHEN OTHERS
         THEN
            result :=
               ErrorMsg (pSqlFunction      => 'update',
                         pTableName        => 'amd_in_transits_sum',
                         pError_location   => 500,
                         pReturn_code      => FAILURE,
                         pKey_1            => part_no,
                         pKey_2            => site_location,
                         pKey_3            => serviceable_flag);
            DBMS_OUTPUT.put_line (
                  'insertRow: 1 part_no='
               || part_no
               || ' site_location='
               || site_location
               || ' quantity='
               || quantity
               || ' serviceable_flag='
               || serviceable_flag
               || ' sqlcode='
               || SQLCODE
               || ' sqlerrm='
               || SQLERRM);
            RAISE;
      END doUpdate;
   BEGIN
      IF (quantity > 0)
      THEN
         BEGIN
            INSERT INTO AMD_IN_TRANSITS_SUM (part_no,
                                             site_location,
                                             quantity,
                                             serviceable_flag,
                                             action_code,
                                             last_update_dt)
                 VALUES (InsertRow.part_no,
                         InsertRow.site_location,
                         InsertRow.quantity,
                         InsertRow.serviceable_flag,
                         Amd_Defaults.INSERT_ACTION,
                         SYSDATE);
         EXCEPTION
            WHEN STANDARD.DUP_VAL_ON_INDEX
            THEN
               result := doUpdate;
            WHEN OTHERS
            THEN
               result :=
                  ErrorMsg (pSqlFunction      => 'insert',
                            pTableName        => 'amd_in_transits_sum',
                            pError_location   => 510,
                            pReturn_code      => FAILURE,
                            pKey_1            => part_no,
                            pKey_2            => site_location,
                            pKey_3            => serviceable_flag,
                            pKey_4            => quantity);
               DBMS_OUTPUT.put_line (
                     'insertRow: 1 part_no='
                  || part_no
                  || ' site_location='
                  || site_location
                  || ' quantity='
                  || quantity
                  || ' serviceable_flag='
                  || serviceable_flag
                  || ' sqlcode='
                  || SQLCODE
                  || ' sqlerrm='
                  || SQLERRM);
               RAISE;
         END insertAmdIntransitSum;
      -- END IF ;

      END IF;

      RETURN SUCCESS;
   END InsertRow;

   FUNCTION UpdateRow (part_no            IN VARCHAR2,
                       site_location      IN VARCHAR2,
                       quantity           IN NUMBER,
                       serviceable_flag   IN VARCHAR2)
      RETURN NUMBER
   IS
      result   NUMBER;
   BEGIN
     <<updateAmdInTransitsSum>>
      BEGIN
         UPDATE AMD_IN_TRANSITS_SUM
            SET quantity = UpdateRow.quantity,
                action_code = Amd_Defaults.UPDATE_ACTION,
                last_update_dt = SYSDATE
          WHERE     part_no = UpdateRow.part_no
                AND site_location = UpdateRow.site_location
                AND serviceable_flag = updateRow.serviceable_flag;
      END updateAmdInTransitsSum;

      RETURN SUCCESS;
   END UpdateRow;

   FUNCTION DeleteRow (part_no            IN VARCHAR2,
                       site_location      IN VARCHAR2,
                       serviceable_flag   IN VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
     <<updateAmdInTransits>>
      BEGIN
         UPDATE AMD_IN_TRANSITS_SUM
            SET action_code = Amd_Defaults.DELETE_ACTION,
                last_update_dt = SYSDATE
          WHERE     part_no = DeleteRow.part_no
                AND site_location = DeleteRow.site_location
                AND serviceable_flag = DeleteRow.serviceable_flag;
      END updateAmdInTransits;

      RETURN SUCCESS;
   END DeleteRow;

   PROCEDURE loadOnHandInvs
   IS
      nsnDashed           VARCHAR2 (16) := NULL;
      invQty              NUMBER := 0;
      cntOnHandInvs       NUMBER := 0;
      cntType1            NUMBER := 0;
      cntType2            NUMBER := 0;
      result              NUMBER := 0;
      cntType1WholeSale   NUMBER := 0;


      CURSOR onHandCur (
         pNsn       VARCHAR2,
         pPartNo    VARCHAR2)
      IS
         SELECT pPartNo part_no,
                DECODE (n.loc_type, 'TMP', asn2.loc_sid, n.loc_sid) loc_sid,
                TRUNC (NVL (r.date_processed, SYSDATE)) inv_date,
                NVL (r.serviceable_balance, 0) + NVL (r.difm_balance, 0)
                   inv_qty,
                amd_defaults.getINSERT_ACTION action_code,
                SYSDATE last_update_dt
           FROM (SELECT *
                   FROM RAMP
                  WHERE current_stock_number = pNsn) r,
                --AMD_SPARE_PARTS asp,
                AMD_SPARE_NETWORKS n,
                AMD_SPARE_NETWORKS asn2
          WHERE     n.loc_id = r.sran(+)
                --AND asp.nsn = pNsn
                AND n.loc_type IN ('MOB', 'FSL', 'UAB')
                AND n.loc_type NOT IN ('KIT')
                AND n.mob = asn2.loc_id(+)
                AND (NVL (r.serviceable_balance, 0) + NVL (r.difm_balance, 0)) >
                       0;

      -- Type 1 Wholesale from ITEM and TMP1
      CURSOR itemType1Cur
      IS
           SELECT asp.part_no,
                  DECODE (asn.loc_type, 'TMP', asnLink.loc_sid, asn.loc_sid)
                     loc_sid,
                  invQ.inv_date inv_date,
                  SUM (invQ.inv_qty) inv_qty,
                  amd_defaults.getINSERT_ACTION action_code,
                  SYSDATE last_update_dt
             FROM (  SELECT part part_no,
                            SUBSTR (i.sc, 8, 6) loc_id,
                            TRUNC (
                               DECODE (i.created_datetime,
                                       NULL, i.last_changed_datetime,
                                       i.created_datetime))
                               inv_date,
                            '1' inv_type,
                            SUM (NVL (i.qty, 0)) inv_qty
                       FROM ITEM i
                      WHERE     i.status_3 != 'I'
                            AND SUBSTR (i.sc, 1, PROGRAM_ID_LL) = PROGRAM_ID
                            AND SUBSTR (i.sc, LENGTH (i.sc), 1) IN ('G')
                            AND i.status_servicable = 'Y'
                            AND i.status_new_order = 'N'
                            AND i.status_accountable = 'Y'
                            AND i.status_active = 'Y'
                            AND i.status_mai = 'N'
                            AND i.condition != 'B170-ATL'
                            AND NOT EXISTS
                                   (SELECT 1
                                      FROM ITEM ii
                                     WHERE     ii.status_avail = 'N'
                                           AND NVL (ii.receipt_order_no, '-1') =
                                                  '-1'
                                           AND ii.item_id = i.item_id)
                   GROUP BY part,
                            SUBSTR (i.sc, 8, 6),
                            TRUNC (
                               DECODE (i.created_datetime,
                                       NULL, i.last_changed_datetime,
                                       i.created_datetime))
                   UNION
                   (  SELECT part part_no,
                             DECODE (i.sc,
                                     PROGRAM_ID || 'PCAG', 'EY1746',
                                     'SATCAA0001' || PROGRAM_ID || 'G', 'EY1746')
                                loc_id,
                             TRUNC (
                                DECODE (i.created_datetime,
                                        NULL, i.last_changed_datetime,
                                        i.created_datetime))
                                inv_date,
                             '1' inv_type,
                             SUM (NVL (i.qty, 0)) inv_qty
                        FROM ITEMSA i
                       WHERE     i.status_3 != 'I'
                             AND i.status_servicable = 'Y'
                             AND i.status_new_order = 'N'
                             AND i.status_accountable = 'Y'
                             AND i.status_active = 'Y'
                             AND i.status_mai = 'N'
                             AND i.condition != 'B170-ATL'
                             AND NOT EXISTS
                                    (SELECT 1
                                       FROM ITEMSA ii
                                      WHERE     ii.status_avail = 'N'
                                            AND NVL (ii.receipt_order_no, '-1') =
                                                   '-1'
                                            AND ii.item_id = i.item_id)
                    GROUP BY part,
                             DECODE (
                                i.sc,
                                PROGRAM_ID || 'PCAG', 'EY1746',
                                'SATCAA0001' || PROGRAM_ID || 'G', 'EY1746'),
                             TRUNC (
                                DECODE (i.created_datetime,
                                        NULL, i.last_changed_datetime,
                                        i.created_datetime)))) invQ,
                  AMD_SPARE_NETWORKS asn,
                  AMD_SPARE_PARTS asp,
                  AMD_SPARE_NETWORKS asnLink
            WHERE     asp.part_no = invQ.part_no
                  AND asn.loc_id = invQ.loc_id
                  AND asn.loc_type != 'KIT'
                  AND asp.action_code != 'D'
                  AND asn.mob = asnLink.loc_id(+)
         GROUP BY asp.part_no,
                  DECODE (asn.loc_type, 'TMP', asnLink.loc_sid, asn.loc_sid),
                  invQ.inv_date
           HAVING SUM (invQ.inv_qty) > 0;

      onHandCnt           NUMBER := 0;
   BEGIN
      writeMsg (
         pTableName        => 'tmp_amd_on_hand_invs',
         pError_location   => 520,
         pKey1             => 'loadOnHandInvs',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
      DBMS_OUTPUT.put_line (
            'loadOnHandInvs started at '
         || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MM:SS'));
      Mta_Truncate_Table ('TMP_AMD_ON_HAND_INVS', 'reuse storage');

      OPEN partCur;

      FETCH partCur BULK COLLECT INTO partRecs;

      CLOSE partCur;

      IF partRecs.FIRST IS NOT NULL
      THEN
         FOR indx IN partRecs.FIRST .. partRecs.LAST
         LOOP
            nsnDashed := Amd_Utils.FormatNsn (partRecs (indx).nsn, 'GOLD');

            --
            -- For each part, extract inventory data from ramp and item tables.
            --
            OPEN onHandCur (nsnDashed, partRecs (indx).part_no);

            FETCH onHandCur BULK COLLECT INTO tmpAmdOnHandInvsRecs;

            CLOSE onHandCur;

            IF tmpAmdOnHandInvsRecs.FIRST IS NOT NULL
            THEN
               FORALL yDex
                   IN tmpAmdOnHandInvsRecs.FIRST .. tmpAmdOnHandInvsRecs.LAST
                  INSERT INTO tmp_amd_on_hand_invs
                       VALUES tmpAmdOnHandInvsRecs (yDex);
            END IF;

            onHandCnt := onHandCnt + SQL%ROWCOUNT;
         END LOOP f77PartLoop;

         writeMsg (
            pTableName        => 'tmp_amd_on_hand_invs',
            pError_location   => 530,
            pKey1             => 'loadOnHandInvs.f77PartLoop',
            pKey2             =>    'loaded at '
                                 || TO_CHAR (SYSDATE,
                                             'MM/DD/YYYY HH:MI:SS AM'),
            pKey3             => '# of rows=' || TO_CHAR (onHandCnt));
         COMMIT;
         DBMS_OUTPUT.put_line (
            'loadOnHandInvs: rows inserted to tmp_on_hand_invs ' || onHandCnt);
      END IF;


      OPEN itemType1Cur;

      FETCH itemType1Cur BULK COLLECT INTO tmpAmdOnHandInvsRecs;

      CLOSE itemType1Cur;


      IF tmpAmdOnHandInvsRecs.FIRST IS NOT NULL
      THEN
         FORALL indx
             IN tmpAmdOnHandInvsRecs.FIRST .. tmpAmdOnHandInvsRecs.LAST
            -- Type 1
            INSERT INTO tmp_amd_on_hand_invs
                 VALUES tmpAmdOnHandInvsRecs (indx);

         writeMsg (
            pTableName        => 'tmp_amd_on_hand_invs',
            pError_location   => 540,
            pKey1             => 'type1WholeSale',
            pKey2             =>    'loaded at '
                                 || TO_CHAR (SYSDATE,
                                             'MM/DD/YYYY HH:MI:SS AM'),
            pKey3             => '# of rows=' || TO_CHAR (SQL%ROWCOUNT));
         COMMIT;
      END IF;


      writeMsg (
         pTableName        => 'tmp_amd_on_hand_invs',
         pError_location   => 550,
         pKey1             => 'loadOnHandInvs',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'),
         pkey3             => TO_CHAR (cntOnHandInvs),
         pkey4             => TO_CHAR (cntType1),
         pData             => TO_CHAR (cntType1WholeSale));
   EXCEPTION
      WHEN OTHERS
      THEN
         ErrorMsg (sqlFunction       => 'select',
                   tableName         => 'tmp_amd_on_hand_invs',
                   pError_Location   => 520);
         DBMS_OUTPUT.put_line (
               'loadOnHandInvs: cntOnHandInvs='
            || cntOnHandInvs
            || ' cntType1='
            || cntType1
            || ' cntType1WholeSale='
            || cntType1WholeSale);
         RAISE;
   END loadOnHandInvs;

   PROCEDURE loadInRepair
   IS
      nsnDashed              VARCHAR2 (16) := NULL;
      invQty                 NUMBER := 0;
      cntType2               NUMBER := 0;
      cntInRepair            NUMBER := 0;
      result                 NUMBER := 0;
      cntType4WholeSale      NUMBER := 0;
      cntTypeBASCWholeSale   NUMBER := 0;
      cntType5WholeSale      NUMBER := 0;

      TYPE tmpAmdInRepairTab IS TABLE OF tmp_amd_in_repair%ROWTYPE;

      tmpAmdInRepairRecs     tmpAmdInRepairTab;


      CURSOR inRepairCur (
         pNsn       VARCHAR2,
         pPartNo    VARCHAR2)
      IS
         SELECT pPartNo,
                DECODE (n.loc_type, 'TMP', asn2.loc_sid, n.loc_sid) loc_sid,
                TRUNC (NVL (r.date_processed, SYSDATE)) inv_date,
                  NVL (r.unserviceable_balance, 0)
                + NVL (r.suspended_in_stock, 0)
                   inv_qty,
                'Retail' order_no,
                TRUNC ( (r.date_processed) + NVL (avg_repair_cycle_time, 0))
                   repair_need_date,
                amd_defaults.INSERT_ACTION action_code,
                SYSDATE last_update_dt
           FROM (SELECT *
                   FROM RAMP
                  WHERE current_stock_number = pNsn) r,
                --AMD_SPARE_PARTS asp,
                AMD_SPARE_NETWORKS n,
                AMD_SPARE_NETWORKS asn2
          WHERE     n.loc_id = r.sran(+)
                --AND asp.nsn = pNsn
                AND n.loc_type IN ('MOB', 'FSL', 'UAB')
                AND n.mob = asn2.loc_id(+)
                AND (  NVL (r.unserviceable_balance, 0)
                     + NVL (r.suspended_in_stock, 0)) > 0;

      -- Type 4 Wholesale
      CURSOR itemMCur
      IS
           SELECT asp.part_no,
                  DECODE (asn.loc_type, 'TMP', asnLink.loc_sid, asn.loc_sid)
                     loc_sid,
                  TRUNC (i.created_datetime) inv_date,
                  SUM (NVL (i.qty, 0)) inv_qty,
                  i.item_id item_id,
                  TRUNC (i.created_datetime + ansi.time_to_repair_off_base)
                     repair_need_date,
                  amd_defaults.getINSERT_ACTION action_code,
                  SYSDATE last_update_dt
             FROM ITEM i,
                  AMD_NATIONAL_STOCK_ITEMS ansi,
                  AMD_SPARE_NETWORKS asn,
                  AMD_SPARE_PARTS asp,
                  AMD_SPARE_NETWORKS asnLink
            WHERE     asp.part_no = i.part
                  AND i.prime = ansi.prime_part_no
                  AND ansi.nsn = asp.nsn
                  AND i.status_3 != 'I'
                  AND SUBSTR (i.sc, 1, PROGRAM_ID_LL) = PROGRAM_ID
                  AND SUBSTR (i.sc, LENGTH (i.sc), 1) IN ('G')
                  AND i.status_servicable = 'N'
                  AND i.status_new_order = 'N'
                  AND i.status_accountable = 'Y'
                  AND i.status_active = 'Y'
                  AND i.status_mai = 'N'
                  AND asn.loc_id = i.loc_id
                  AND asp.action_code != 'D'
                  AND asn.mob = asnLink.loc_id(+)
                  AND asn.loc_type <> 'KIT'
                  AND i.created_datetime IS NOT NULL
         GROUP BY asp.part_no,
                  DECODE (asn.loc_type, 'TMP', asnLink.loc_sid, asn.loc_sid),
                  i.item_id,
                  DECODE (i.created_datetime,
                          NULL, TRUNC (i.last_changed_datetime),
                          TRUNC (i.created_datetime)),
                  TRUNC (i.created_datetime),
                  TRUNC (i.created_datetime + ansi.time_to_repair_off_base)
           HAVING SUM (NVL (i.qty, 0)) > 0;

      inRepairCnt            NUMBER := 0;

      CURSOR itemACur
      IS
           SELECT asp.part_no,
                  DECODE (asn.loc_type, 'TMP', asnLink.loc_sid, asn.loc_sid)
                     loc_sid,
                  TRUNC (i.created_datetime) repair_date,
                  SUM (NVL (i.qty, 0)) inv_qty,
                  i.item_id item_id,
                  TRUNC (
                     i.created_datetime + NVL (ansi.time_to_repair_off_base, 0))
                     repair_need_date,
                  amd_defaults.getINSERT_ACTION action_code,
                  SYSDATE last_update_dt
             FROM ITEMSA i,
                  AMD_NATIONAL_STOCK_ITEMS ansi,
                  AMD_SPARE_NETWORKS asn,
                  AMD_SPARE_PARTS asp,
                  AMD_SPARE_NETWORKS asnLink
            WHERE     asp.part_no = i.part
                  AND i.prime = ansi.prime_part_no
                  AND ansi.nsn = asp.nsn
                  AND i.status_3 != 'I'
                  AND i.status_servicable = 'N'
                  AND i.status_new_order = 'N'
                  AND i.status_accountable = 'Y'
                  AND i.status_active = 'Y'
                  AND i.status_mai = 'N'
                  AND i.created_datetime IS NOT NULL
                  AND asn.loc_id = 'EY1746'
                  AND asn.loc_type <> 'KIT'
                  AND asp.action_code != 'D'
                  AND asn.mob = asnLink.loc_id(+)
         GROUP BY asp.part_no,
                  DECODE (asn.loc_type, 'TMP', asnLink.loc_sid, asn.loc_sid),
                  i.item_id,
                  DECODE (i.created_datetime,
                          NULL, TRUNC (i.last_changed_datetime),
                          TRUNC (i.created_datetime)),
                  TRUNC (i.created_datetime),
                  TRUNC (
                       i.created_datetime
                     + NVL (ansi.time_to_repair_off_base, 0))
           HAVING SUM (NVL (i.qty, 0)) > 0;

      CURSOR itemType5Cur
      IS
         SELECT DISTINCT
                asp.part_no,
                DECODE (asn.loc_type, 'TMP', asnLink.loc_sid, asn.loc_sid)
                   loc_sid,
                o.created_datetime inv_date,
                NVL (o.qty_due, 0) inv_qty,
                o.order_no order_no,
                DECODE (ov.vendor_est_ret_date,
                        NULL, o.ecd,
                        ov.vendor_est_ret_date)
                   repair_need_date,
                amd_defaults.getINSERT_ACTION action_code,
                SYSDATE last_update_dt
           FROM ORD1 o,
                ORDV ov,
                amd_sc_inclusions,
                AMD_SPARE_NETWORKS asn,
                AMD_SPARE_PARTS asp,
                AMD_SPARE_NETWORKS asnLink
          WHERE     o.order_no = ov.order_no
                AND asp.part_no = o.part
                AND o.status IN ('O', 'U')
                AND o.order_type = 'J'
                AND o.accountable_yn = 'Y'
                AND SUBSTR (o.sc, 1, PROGRAM_ID_LL) = PROGRAM_ID
                AND (   SUBSTR (o.sc, LENGTH (o.sc), 1) = 'G'
                     OR o.loc_id = SUBSTR (include_sc, START_LOC_ID, 6))
                AND asn.loc_id = o.loc_id
                AND asn.loc_type <> 'KIT'
                AND asp.action_code != 'D'
                AND asn.mob = asnLink.loc_id(+)
                AND o.created_datetime IS NOT NULL
                AND NVL (o.qty_due, 0) > 0;
   BEGIN
      writeMsg (
         pTableName        => 'tmp_amd_in_repair',
         pError_location   => 560,
         pKey1             => 'loadInRepair',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
      Mta_Truncate_Table ('TMP_AMD_IN_REPAIR', 'reuse storage');

      OPEN partCur;

      FETCH partCur BULK COLLECT INTO partRecs;

      CLOSE partCur;

      IF partRecs.FIRST IS NOT NULL
      THEN
        <<f77PartLoop>>
         FOR indx IN partRecs.FIRST .. partRecs.LAST
         LOOP
            nsnDashed := Amd_Utils.FormatNsn (partRecs (indx).nsn, 'GOLD');

            --
            -- For each part, extract inventory data from ramp and item tables.
            --
            OPEN inRepairCur (nsnDashed, partRecs (indx).part_no);

            FETCH inRepairCur BULK COLLECT INTO tmpAmdInRepairRecs;

            CLOSE inRepairCur;

            IF tmpAmdInRepairRecs.FIRST IS NOT NULL
            THEN
               FORALL yDex
                   IN tmpAmdInRepairRecs.FIRST .. tmpAmdInRepairRecs.LAST
                  -- type 2
                  INSERT INTO TMP_AMD_IN_REPAIR
                       VALUES tmpAmdInRepairRecs (yDex);
            END IF;

            inRepairCnt := inRepairCnt + SQL%ROWCOUNT;
         END LOOP f77PartLoop;

         writeMsg (
            pTableName        => 'tmp_amd_on_hand_invs',
            pError_location   => 570,
            pKey1             => 'loadInRepair.f77PartLoop',
            pKey2             =>    'loaded at '
                                 || TO_CHAR (SYSDATE,
                                             'MM/DD/YYYY HH:MI:SS AM'),
            pKey3             => '# recs = ' || TO_CHAR (inRepairCnt));
         DBMS_OUTPUT.PUT_LINE (
               'loadInRepair: inserted rows to tmp_amd_in_repair from inRepairCur '
            || inRepairCnt);
         COMMIT;
      END IF;

      OPEN itemMCur;

      FETCH itemMcur BULK COLLECT INTO tmpAmdInRepairRecs;

      CLOSE itemMcur;

      IF tmpAmdInRepairRecs.FIRST IS NOT NULL
      THEN
         FORALL indx IN tmpAmdInRepairRecs.FIRST .. tmpAmdInRepairRecs.LAST
            -- Type 4
            INSERT INTO TMP_AMD_IN_REPAIR
                 VALUES tmpAmdInRepairRecs (indx);

         DBMS_OUTPUT.PUT_LINE (
               'loadInRepair: insert rows int tmp_amd_in_repair from itemMcur '
            || SQL%ROWCOUNT);
         writeMsg (
            pTableName        => 'tmp_amd_on_hand_invs',
            pError_location   => 580,
            pKey1             => 'loadInRepair.type4WholeSale',
            pKey2             =>    'loaded at '
                                 || TO_CHAR (SYSDATE,
                                             'MM/DD/YYYY HH:MI:SS AM'),
            pKey3             => '# of recs = ' || TO_CHAR (SQL%ROWCOUNT));
         COMMIT;
      END IF;

      OPEN itemAcur;

      FETCH itemAcur BULK COLLECT INTO tmpAmdInRepairRecs;

      CLOSE itemAcur;

      IF tmpAmdInRepairRecs.FIRST IS NOT NULL
      THEN
         --typeBASCWholeSale
         FORALL indx IN tmpAmdInRepairRecs.FIRST .. tmpAmdInRepairRecs.LAST
            INSERT INTO TMP_AMD_IN_REPAIR
                 VALUES tmpAmdInRepairRecs (indx);

         DBMS_OUTPUT.PUT_LINE (
               'loadInRepair: insert rows int tmp_amd_in_repair from itemAcur '
            || SQL%ROWCOUNT);
         writeMsg (
            pTableName        => 'tmp_amd_on_hand_invs',
            pError_location   => 590,
            pKey1             => 'loadInRepair.typeBASCWholeSale',
            pKey2             =>    'loaded at '
                                 || TO_CHAR (SYSDATE,
                                             'MM/DD/YYYY HH:MI:SS AM'),
            pKey3             => '# of recs = ' || TO_CHAR (SQL%ROWCOUNT));
         COMMIT;
      END IF;

      OPEN itemType5Cur;

      FETCH itemType5Cur BULK COLLECT INTO tmpAmdInRepairRecs;

      CLOSE itemType5Cur;

      IF tmpAmdInRepairRecs.FIRST IS NOT NULL
      THEN
         -- itemType5WholeSale
         FORALL indx IN tmpAmdInRepairRecs.FIRST .. tmpAmdInRepairRecs.LAST
            INSERT INTO TMP_AMD_IN_REPAIR
                 VALUES tmpAmdInRepairRecs (indx);

         DBMS_OUTPUT.PUT_LINE (
               'loadInRepair: insert rows int tmp_amd_in_repair from itemType5Cur '
            || SQL%ROWCOUNT);

         writeMsg (
            pTableName        => 'tmp_amd_on_hand_invs',
            pError_location   => 600,
            pKey1             => 'loadInRepair.itemType5WholeSale',
            pKey2             =>    'loaded at '
                                 || TO_CHAR (SYSDATE,
                                             'MM/DD/YYYY HH:MI:SS AM'),
            pKey3             => '# of recs = ' || TO_CHAR (SQL%ROWCOUNT));
         COMMIT;
      END IF;

      writeMsg (
         pTableName        => 'tmp_amd_in_repair',
         pError_location   => 610,
         pKey1             => 'loadInRepair',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
   EXCEPTION
      WHEN OTHERS
      THEN
         ErrorMsg (sqlFunction       => 'select',
                   tableName         => 'tmp_amd_in_repair',
                   pError_Location   => 580);
         DBMS_OUTPUT.put_line (
            'loadInRepair: sqlcode=' || SQLCODE || ' sqlerrm=' || SQLERRM);
         RAISE;
   END loadInRepair;


   PROCEDURE updateSpoTotalInventory
   IS
      CURSOR partCur
      IS
         SELECT DISTINCT prime_part_no
           FROM AMD_NATIONAL_STOCK_ITEMS ansi, AMD_SPARE_PARTS asp
          WHERE ansi.nsn = asp.nsn AND ansi.action_code != 'D';

      TYPE spoInvRec IS RECORD
      (
         nsn        amd_national_stock_items.nsn%TYPE,
         quantity   NUMBER
      );

      TYPE spoInvTab IS TABLE OF spoInvRec;

      spoInvRecs   spoInvTab;

      CURSOR totalSpoInvCur
      IS
           SELECT ansi.nsn, SUM (qty) quantity
             FROM (SELECT a.part_no, quantity qty, nsn
                     FROM AMD_IN_TRANSITS a,
                          AMD_SPARE_NETWORKS asn,
                          AMD_SPARE_PARTS asp
                    WHERE     asn.loc_sid = a.to_loc_sid
                          AND a.part_no = asp.part_no
                          AND asp.action_code IN ('A', 'C')
                          AND a.action_code != 'D'
                          AND asn.action_code != 'D'
                          AND asn.spo_location IS NOT NULL
                   UNION ALL
                   SELECT a.part_no, order_qty qty, asp.nsn
                     FROM AMD_ON_ORDER a,
                          AMD_SPARE_NETWORKS asn,
                          AMD_SPARE_PARTS asp
                    WHERE     asn.loc_sid = a.loc_sid
                          AND a.part_no = asp.part_no
                          AND asp.action_code IN ('A', 'C')
                          AND a.action_code != 'D'
                          AND asn.action_code != 'D'
                          AND asn.spo_location IS NOT NULL
                   UNION ALL
                   SELECT a.part_no, inv_qty qty, asp.nsn
                     FROM AMD_ON_HAND_INVS a,
                          AMD_SPARE_NETWORKS asn,
                          AMD_SPARE_PARTS asp
                    WHERE     asn.loc_sid = a.loc_sid
                          AND a.part_no = asp.part_no
                          AND asp.action_code IN ('A', 'C')
                          AND a.action_code != 'D'
                          AND asn.action_code != 'D'
                          AND asn.spo_location IS NOT NULL
                   UNION ALL
                   SELECT a.part_no, repair_qty qty, asp.nsn
                     FROM AMD_IN_REPAIR a,
                          AMD_SPARE_NETWORKS asn,
                          AMD_SPARE_PARTS asp
                    WHERE     asn.loc_sid = a.loc_sid
                          AND a.part_no = asp.part_no
                          AND asp.action_code IN ('A', 'C')
                          AND a.action_code != 'D'
                          AND asn.action_code != 'D'
                          AND asn.spo_location IS NOT NULL
                   UNION ALL
                   SELECT a.part_no, rsp_inv qty, asp.nsn
                     FROM AMD_RSP a,
                          AMD_SPARE_NETWORKS asn,
                          AMD_SPARE_PARTS asp
                    WHERE     asn.loc_sid = a.loc_sid
                          AND a.part_no = asp.part_no
                          AND asp.action_code IN ('A', 'C')
                          AND a.action_code != 'D'
                          AND asn.action_code != 'D'
                          AND asn.spo_location IS NOT NULL) qtyQ,
                  AMD_NATIONAL_STOCK_ITEMS ansi
            WHERE ansi.nsn = qtyQ.nsn
         GROUP BY ansi.nsn;
   BEGIN
      DBMS_OUTPUT.put_line (
            'updateSpoTotalInventory started at '
         || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MM:SS'));

      BEGIN
         UPDATE AMD_NATIONAL_STOCK_ITEMS
            SET spo_total_inventory = NULL
          WHERE spo_total_inventory IS NOT NULL;
      END;

     <<primePartLoop>>
      -- FOR rec IN partCur LOOP
      OPEN totalSpoInvCur;

      FETCH totalSpoInvCur BULK COLLECT INTO spoInvRecs;

      CLOSE totalSpoInvCur;

      IF spoInvRecs.FIRST IS NOT NULL
      THEN
         FOR indx IN spoInvRecs.FIRST .. spoInvRecs.LAST
         LOOP
            -- dbms_output.put_line('part_no=' || rampRecs(yDex).prime_part_no ); --' qty = ' || rampRecs(yDex).quantity) ;
            BEGIN
               UPDATE AMD_NATIONAL_STOCK_ITEMS
                  SET spo_total_inventory = spoInvRecs (indx).quantity
                WHERE nsn = spoInvRecs (indx).nsn AND action_code != 'D';
            END;
         END LOOP totalSpoInvLoop;
      END IF;

      --END LOOP partCur ;
      DBMS_OUTPUT.put_line (
            'updateSpoTotalInventory ended at '
         || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MM:SS'));
   END updateSpoTotalInventory;

   -- added 9/2/2005
   FUNCTION getParamDate (rawData      IN AMD_PARAM_CHANGES.PARAM_VALUE%TYPE,
                          typeOfDate   IN orderdates)
      RETURN DATE
   IS
      paramDate   DATE;
      params      Amd_Utils.arrayOfWords := Amd_Utils.arrayOfWords ();
      cnt         NUMBER;
   BEGIN
      params := Amd_Utils.splitString (rawData);
      cnt := params.COUNT ();

      IF params.COUNT () > 0
      THEN
         paramDate := TO_DATE (params (typeOfDate), 'MM/DD/YYYY');
      END IF;

      RETURN paramDate;
   END getParamDate;

   PROCEDURE setParamDate (voucher      IN VARCHAR2,
                           theDate      IN DATE,
                           typeOfDate   IN orderdates)
   IS
      params   Amd_Utils.arrayOfwords;
   BEGIN
      params :=
         Amd_Utils.splitString (
            Amd_Defaults.getParamValue (ON_ORDER_DATE || voucher));

      IF params.COUNT () > 0
      THEN
         params (typeOfDate) := theDate;
      END IF;

      Amd_Defaults.setParamValue (LOWER (ON_ORDER_DATE || voucher),
                                  Amd_Utils.joinString (params));
   EXCEPTION
      WHEN STANDARD.NO_DATA_FOUND
      THEN
         Amd_Defaults.setParamValue (LOWER ('on_order_date' || voucher),
                                     NULL);
   END setParamDate;

   FUNCTION getOrderCreateDate (voucher IN VARCHAR2)
      RETURN DATE
   IS
   BEGIN
      RETURN getParamDate (
                Amd_Defaults.GetParamValue (LOWER (ON_ORDER_DATE || voucher)),
                ORDER_CREATE_DATE);
   EXCEPTION
      WHEN STANDARD.NO_DATA_FOUND
      THEN
         RETURN NULL;
   END getOrderCreateDate;


   PROCEDURE setOrderCreateDate (voucher           IN VARCHAR2,
                                 orderCreateDate   IN DATE)
   IS
      theDate   VARCHAR2 (10) := TO_CHAR (orderCreateDate, 'MM/DD/YYYY');
      pos       NUMBER;
      rawData   AMD_PARAM_CHANGES.PARAM_VALUE%TYPE;
      params    Amd_Utils.arrayOfWords;
   BEGIN
      setParamDate (voucher, orderCreateDate, ORDER_CREATE_DATE);
   END setOrderCreateDate;

   FUNCTION getScdeduledReceiptDateFrom (voucher IN VARCHAR2)
      RETURN DATE
   IS
   BEGIN
      RETURN getParamDate (
                Amd_Defaults.GetParamValue (LOWER (ON_ORDER_DATE || voucher)),
                SCHEDULED_RECEIPT_DATE_FROM);
   EXCEPTION
      WHEN STANDARD.NO_DATA_FOUND
      THEN
         RETURN NULL;
   END getScdeduledReceiptDateFrom;

   FUNCTION getScdeduledReceiptDateTo (voucher IN VARCHAR2)
      RETURN DATE
   IS
   BEGIN
      RETURN getParamDate (
                Amd_Defaults.GetParamValue (LOWER (ON_ORDER_DATE || voucher)),
                SCHEDULED_RECEIPT_DATE_TO);
   EXCEPTION
      WHEN STANDARD.NO_DATA_FOUND
      THEN
         RETURN NULL;
   END getScdeduledReceiptDateTo;

   PROCEDURE setScheduledReceiptDate (voucher    IN VARCHAR2,
                                      fromDate   IN DATE,
                                      toDate        DATE)
   IS
      params   Amd_Utils.arrayOfwords;
   BEGIN
      IF fromDate IS NOT NULL AND toDate IS NOT NULL
      THEN
         IF fromDate > toDate
         THEN
            DBMS_OUTPUT.put_line (
                  'setScheduledReceiptDate: voucher='
               || voucher
               || ' fromDate='
               || TO_CHAR (fromDate, 'MM/DD/YYYY')
               || ' toDate='
               || TO_CHAR (toDate, 'MM/DD/YYYY'));
            RAISE sched_receipt_date_exception;
         END IF;
      END IF;

      params :=
         Amd_Utils.splitString (
            Amd_Defaults.getParamValue (ON_ORDER_DATE || voucher));

      IF params.COUNT () = 0
      THEN
         params.EXTEND (SCHEDULED_RECEIPT_DATE_TO);
      ELSIF params.COUNT () = 1
      THEN
         params.EXTEND (2);
      END IF;

      params (SCHEDULED_RECEIPT_DATE_FROM) := fromDate;
      params (SCHEDULED_RECEIPT_DATE_TO) := toDate;
      Amd_Defaults.setParamValue (LOWER (ON_ORDER_DATE || voucher),
                                  Amd_Utils.joinString (params));
   END setScheduledReceiptDate;

   PROCEDURE setScheduledReceiptDateCalDays (voucher   IN VARCHAR2,
                                             days      IN NUMBER)
   IS
      params   Amd_Utils.arrayOfwords;
   BEGIN
      params :=
         Amd_Utils.splitString (
            Amd_Defaults.getParamValue (ON_ORDER_DATE || voucher));

      IF params.COUNT () > 0
      THEN
         params (NUMBER_OF_CALANDER_DAYS) := days;
      END IF;

      Amd_Defaults.setParamValue (LOWER (ON_ORDER_DATE || voucher),
                                  Amd_Utils.joinString (params, ','));
   END setScheduledReceiptDateCalDays;

   FUNCTION getScheduledReceiptDateCalDays (voucher IN VARCHAR2)
      RETURN NUMBER
   IS
      calDays   NUMBER := NULL;
      params    Amd_Utils.arrayOfWords;
   BEGIN
      params :=
         Amd_Utils.splitString (
            Amd_Defaults.GetParamValue (ON_ORDER_DATE || voucher));

      IF params.COUNT () > 0
      THEN
         calDays := TO_NUMBER (params (NUMBER_OF_CALANDER_DAYS));
      END IF;

      RETURN calDays;
   EXCEPTION
      WHEN STANDARD.NO_DATA_FOUND
      THEN
         RETURN NULL;
   END getScheduledReceiptDateCalDays;

   PROCEDURE getOnOrderParams (voucher                IN     VARCHAR2,
                               orderCreateDate           OUT DATE,
                               schedReceiptDateFrom      OUT DATE,
                               schedReceiptDateTo        OUT DATE,
                               schedReceiptCalDays       OUT NUMBER)
   IS
      params   Amd_Utils.arrayOfWords;
   BEGIN
      params :=
         Amd_Utils.splitString (
            Amd_Defaults.GetParamValue (LOWER (ON_ORDER_DATE || voucher)));

      IF params.COUNT () >= NUMBER_OF_CALANDER_DAYS
      THEN
         IF params (NUMBER_OF_CALANDER_DAYS) IS NOT NULL
         THEN
            schedReceiptCalDays :=
               TO_NUMBER (params (NUMBER_OF_CALANDER_DAYS));
         ELSE
            schedReceiptCalDays := NULL;
         END IF;
      ELSE
         schedReceiptCalDays := NULL;
      END IF;

      IF params.COUNT () >= SCHEDULED_RECEIPT_DATE_TO
      THEN
         IF     params (SCHEDULED_RECEIPT_DATE_FROM) IS NOT NULL
            AND LENGTH (params (SCHEDULED_RECEIPT_DATE_FROM)) >= 8
         THEN
            schedReceiptDateFrom :=
               TO_DATE (params (SCHEDULED_RECEIPT_DATE_FROM), 'MM/DD/YYYY');
         ELSE
            schedReceiptDateFrom := NULL;
         END IF;

         IF     params (SCHEDULED_RECEIPT_DATE_TO) IS NOT NULL
            AND LENGTH (params (SCHEDULED_RECEIPT_DATE_TO)) >= 8
         THEN
            schedReceiptDateTo :=
               TO_DATE (params (SCHEDULED_RECEIPT_DATE_TO), 'MM/DD/YYYY');
         ELSE
            schedReceiptDateTo := NULL;
         END IF;
      ELSE
         schedReceiptDateFrom := NULL;
         schedReceiptDateTo := NULL;
      END IF;

      IF params.COUNT () >= ORDER_CREATE_DATE
      THEN
         IF     params (ORDER_CREATE_DATE) IS NOT NULL
            AND LENGTH (params (ORDER_CREATE_DATE)) >= 8
         THEN
            orderCreateDate :=
               TO_DATE (params (ORDER_CREATE_DATE), 'MM/DD/YYYY');
         ELSE
            orderCreateDate := NULL;
         END IF;
      ELSE
         orderCreateDate := NULL;
      END IF;
   END getOnOrderParams;

   PROCEDURE setOnOrderParams (voucher                IN VARCHAR2,
                               orderCreateDate        IN DATE,
                               schedReceiptDateFrom   IN DATE,
                               schedReceiptDateTo     IN DATE,
                               schedReceiptCalDays    IN NUMBER)
   IS
      params   Amd_Utils.arrayOfWords := Amd_Utils.arrayOfWords ();
   BEGIN
      params.EXTEND (4);
      params (ORDER_CREATE_DATE) := TO_CHAR (orderCreateDate, 'MM/DD/YYYY');

      IF schedReceiptDateFrom IS NOT NULL AND schedReceiptDateTo IS NOT NULL
      THEN
         IF schedReceiptDateFrom > schedReceiptDateTo
         THEN
            DBMS_OUTPUT.put_line (
                  'setOnOrderParams: voucher='
               || voucher
               || ' orderCreeateDate='
               || TO_CHAR (orderCreateDate, 'MM/DD/YYYY')
               || ' schedReceiptDateFrom='
               || TO_CHAR (schedReceiptDateFrom, 'MM/DD/YYYY')
               || ' schedReceiptCalDays='
               || schedReceiptCalDays);
            RAISE sched_receipt_date_exception;
         END IF;

         params (SCHEDULED_RECEIPT_DATE_FROM) :=
            TO_CHAR (schedReceiptDateFrom, 'MM/DD/YYYY');
         params (SCHEDULED_RECEIPT_DATE_TO) :=
            TO_CHAR (schedReceiptDateTo, 'MM/DD/YYYY');
         params (NUMBER_OF_CALANDER_DAYS) := NULL;
      ELSE
         IF schedReceiptCalDays IS NOT NULL
         THEN
            params (SCHEDULED_RECEIPT_DATE_FROM) := NULL;
            params (SCHEDULED_RECEIPT_DATE_TO) := NULL;
            params (NUMBER_OF_CALANDER_DAYS) := schedReceiptCalDays;
         ELSE
            params (SCHEDULED_RECEIPT_DATE_FROM) := NULL;
            params (SCHEDULED_RECEIPT_DATE_TO) := NULL;
            params (NUMBER_OF_CALANDER_DAYS) := NULL;
         END IF;
      END IF;

      IF NOT Amd_Defaults.isParamKey (LOWER (ON_ORDER_DATE || voucher))
      THEN
         Amd_Defaults.addParamKey (
            LOWER (ON_ORDER_DATE || voucher),
               'The order create date and scheduled receipt date for the '
            || LOWER (voucher)
            || ' voucher');
      END IF;

      Amd_Defaults.setParamValue (LOWER (ON_ORDER_DATE || voucher),
                                  Amd_Utils.joinString (params));
   END setOnOrderParams;

   FUNCTION isVoucher (voucher IN VARCHAR2)
      RETURN BOOLEAN
   IS
      theVoucher   VARCHAR2 (2);
   BEGIN
      SELECT DISTINCT SUBSTR (gold_order_number, 1, 2)
        INTO theVoucher
        FROM AMD_ON_ORDER
       WHERE LOWER (SUBSTR (gold_order_number, 1, 2)) =
                LOWER (isVoucher.voucher);

      RETURN TRUE;
   EXCEPTION
      WHEN STANDARD.NO_DATA_FOUND
      THEN
         RETURN FALSE;
   END isVoucher;

   PROCEDURE clearOnOrderParams
   IS
      CURSOR onOrderParams
      IS
         SELECT *
           FROM AMD_PARAM_CHANGES outer
          WHERE     param_key LIKE ON_ORDER_DATE || '%'
                AND effective_date = (SELECT MAX (effective_date)
                                        FROM AMD_PARAM_CHANGES
                                       WHERE param_key = outer.param_key);
   BEGIN
      FOR rec IN onOrderParams
      LOOP
         INSERT INTO AMD_PARAM_CHANGES (param_key,
                                        param_value,
                                        effective_date,
                                        user_id)
              VALUES (rec.param_key,
                      ',,,',
                      SYSDATE,
                      USER);
      END LOOP;
   END clearOnOrderParams;

   FUNCTION numberOfOnOrderParams
      RETURN NUMBER
   IS
      cnt   NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO cnt
        FROM AMD_PARAM_CHANGES outer
       WHERE     param_key LIKE ON_ORDER_DATE || '%'
             AND effective_date = (SELECT MAX (effective_date)
                                     FROM AMD_PARAM_CHANGES
                                    WHERE param_key = outer.param_key);

      RETURN cnt;
   EXCEPTION
      WHEN STANDARD.NO_DATA_FOUND
      THEN
         RETURN 0;
   END numberOfOnOrderParams;

   FUNCTION getVouchers
      RETURN ref_cursor
   IS
      vouchers_cursor   ref_cursor;
   BEGIN
      OPEN vouchers_cursor FOR
           SELECT DISTINCT SUBSTR (gold_order_number, 1, 2) voucher
             FROM AMD_ON_ORDER
         ORDER BY voucher;

      RETURN vouchers_cursor;
   END getVouchers;


   PROCEDURE version
   IS
   BEGIN
      writeMsg (pTableName        => 'amd_inventory',
                pError_location   => 620,
                pKey1             => 'amd_inventory',
                pKey2             => '$Revision:   1.121 $');
   END version;

   FUNCTION getVersion
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN '$Revision:   1.121  $';
   END getVersion;

   PROCEDURE setDebug (switch IN VARCHAR2)
   IS
   BEGIN
      debug :=
         UPPER (switch) IN ('Y',
                            'T',
                            'YES',
                            'TRUE');

      IF debug
      THEN
         DBMS_OUTPUT.ENABLE (100000);
      ELSE
         DBMS_OUTPUT.DISABLE;
      END IF;
   END setDebug;
END Amd_Inventory;
/