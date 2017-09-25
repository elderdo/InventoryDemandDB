SET DEFINE OFF;
DROP PACKAGE AMD_OWNER.AMD_INVENTORY;

CREATE OR REPLACE PACKAGE AMD_OWNER.Amd_Inventory AS
	--
	-- SCCSID: %M%  %I%  Modified: %G% %U%
	--
	-- Date     By     History
	-- -------- -----  ---------------------------------------------------
	-- 10/14/01 FF     Initial implementation
	-- 11/01/01 FF     Changed LoadGoldInventory() to accept parameter as
	--                 char to match item.prime char datatype.
	-- 11/07/01 FF     Implemented WWA mod. Removed GetLocSid().
	-- 11/21/01 FF     Removed references to gold_mfgr_cage.
	-- 11/26/01 FF     Changed action_code to use defaults package.
	-- 01/04/02 FF     Removed "tactical" check from select criteria.
	-- 01/23/02 FF     Added "distinct" keyword to partCur cursor.
	-- 02/20/02 FF     Modified load to be by part not roll up to prime.
	-- 03/05/02 FF     Fixed conditions for insert and rtrim()ed the join
	--                 to the ord1 table.
	-- 09/25/02 FF     Qualified all amd_spare_parts refereneces with
	--                 action_code != 'D'
	-- 10/23/02 FF     Added translation of loc_type='TMP' srans to its MOB val.
	-- 11/18/02 FF     Added exception handler to rampCur.
	-- 06/13/03 TP     Changed order_no prefixes from ord1 table.
	-- 04/05/04 TP	   Removed 'TC' as a valid order prefix for including a
	--                 cap order in inventory.
	-- 05/13/04 TP	   Changed LoadGoldInventory() in On Hand and in Repair .
	-- 06/16/04 TP	   Added conditions in the OnHand and Repair types.
	--
	-- 07/26/04 TL    Added constant numbers for debugging purposes.
   --                Added implementations for insertRow, updateRow, and deleteRow on amd_on_order table
    /*
	    PVCS Keywords

       $Author:   zf297a  $
     $Revision:   1.36  $
         $Date:   16 Feb 2009 17:39:14  $
     $Workfile:   amd_inventory.pks  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_inventory.pks-arc  $
   
      Rev 1.36   16 Feb 2009 17:39:14   zf297a
   Define function interface isInvalidDateYorN
   
      Rev 1.35   16 Jan 2009 22:52:36   zf297a
   Define interfaces for setDateThreshold and getDateThreshold.  dateThreshold will be used to validate dates going into amd_in_repair.  The default for dateThreshold is 1/1/1980l
   
      Rev 1.34   06 Feb 2008 21:24:46   zf297a
   Added interfaces for function getVersion and procedure setDebug.
   
      Rev 1.33   06 Feb 2008 20:27:32   zf297a
   Added loc_sid to getCurrentLine function since that is part of the primary key for amd_on_order
   
      Rev 1.32   29 Oct 2007 12:03:28   zf297a
   Fixed doRspSumDiff interface - moved override_type from the last argument to become the 3rd argument.
   
      Rev 1.31   19 Oct 2007 12:02:08   zf297a
   Added argument override_type to the function doRspSumDiff
   
      Rev 1.30   06 Apr 2007 20:47:52   zf297a
   Fixed getCurLine interface
   
      Rev 1.29   06 Apr 2007 09:11:52   zf297a
   Added interfaces getNextLIne and getCurrentLine.  These functions are for the unique index "line" for the amd_on_order table.
   
      Rev 1.28   Jun 09 2006 11:39:14   zf297a
   added interface version
   
      Rev 1.27   Apr 28 2006 12:37:32   c402417
   Added amd_rsp diff function.
   
      Rev 1.26   Dec 06 2005 12:28:20   zf297a
   Changed deleteRow interface for amd_on_order - passed in additional parameters: part_no, loc_sid, and order_date (gold_order_number was the only parameter previously).

      Rev 1.25   Nov 03 2005 09:35:54   c402417
   Have Procedure UpdateSpoTotalInventory execute after all the Procedure load amd tables .

      Rev 1.24   Oct 13 2005 11:04:52   c402417
   Added fucntion doRepairInvsSumDiff.

      Rev 1.23   Sep 13 2005 12:43:04   zf297a
   added interface for the isVoucher boolean function

      Rev 1.22   Sep 12 2005 11:36:18   zf297a
   added interfaces for one get and one set procedure for all the on order date parameters for a given voucher.

      Rev 1.21   Sep 09 2005 10:56:34   zf297a
   For amd_on_hand_inv_sums changed the site_location column to be the spo_location column.  The spo_location comes from amd_spare_networks.spo_location.

      Rev 1.20   Sep 07 2005 21:00:00   zf297a
   added sched_receipt_date_exception when the from date is 42; than the to date.

      Rev 1.19   Sep 02 2005 15:49:34   zf297a
   Added interfaces for getOrderCreateDate, setOrderCreateDate, getScdeduledReceiptDateFrom, getScdeduledReceiptDateTo, setScheduledReceiptDate, and setScheduledReceiptDateCalDays

      Rev 1.18   Aug 26 2005 12:15:38   zf297a
   Added interfaces for doOnHandInvsSumDiff, loadOnHandInvs, and loadInRepair.

      Rev 1.17   Aug 04 2005 08:04:46   zf297a
   Made insertRow and updateRow for amd_on_order unique for the jdbc interface.

      Rev 1.15   Jul 11 2005 09:30:34   zf297a
   made the loading of tmp_amd_in_transits a separate procedure

      Rev 1.14   Jul 11 2005 09:17:40   zf297a
   made the loading of tmp_amd_on_order a separate procedure

      Rev 1.13   Jul 06 2005 09:30:44   zf297a
   Changed deleteRow for in_repair to have a unique name.

      Rev 1.12   20 Sep 2004 10:17:40   c970183
   Fixed site_location for insertRow of in_transits - it must be varchar(20)

      Rev 1.11   06 Aug 2004 14:09:56   c970183
   removed repair_type

      Rev 1.8   Aug 02 2004 08:08:36   c970183
   Removed inv_date from insertRow, updateRow, and deleteRow for amd_on_hand_invs since diff is done on the summarized qty.  Also, changed parameter names so they would not conflict with the column names.

      Rev 1.7   Jul 30 2004 12:04:56   c970183
   added pvcs comments with keywords
	 */

	 -- added 9/7/2005
	sched_receipt_date_exception EXCEPTION ;

	SUCCESS                   CONSTANT NUMBER :=  0;
	FAILURE                   CONSTANT NUMBER :=  4;
	badActionCode             EXCEPTION ;
        

	PROCEDURE LoadGoldInventory;

	PROCEDURE loadOnOrder ;

	PROCEDURE loadInTransits ;
	
	PROCEDURE loadRsp ;
	

	/* amd_on_order diff functions */
	FUNCTION InsertOnOrderRow(
							PART_NO             IN VARCHAR2,
  							LOC_SID             IN NUMBER,
  							--LINE				IN NUMBER,
							ORDER_DATE			IN DATE,
  							ORDER_QTY           IN NUMBER,
  							GOLD_ORDER_NUMBER   IN VARCHAR2,
							SCHED_RECEIPT_DATE IN  DATE) RETURN NUMBER ;

	FUNCTION UpdateOnOrderRow(
							PART_NO             IN VARCHAR2,
  							LOC_SID             IN NUMBER,
  							--LINE                IN NUMBER,
							ORDER_DATE  		IN DATE,
  							ORDER_QTY           IN NUMBER,
  							GOLD_ORDER_NUMBER   IN VARCHAR2,
							SCHED_RECEIPT_DATE IN  DATE) RETURN NUMBER ;

	FUNCTION deleterow(part_no IN VARCHAR2, 
			 loc_sid IN NUMBER,
             --line in number, 
			 gold_order_number IN VARCHAR2, 
			 order_date IN DATE) RETURN NUMBER ;

	/* amd_on_hand_invs diff functions */
	FUNCTION doOnHandInvsSumDiff(
			 part_no IN VARCHAR2,
			 spo_location VARCHAR2,
			 qty_on_hand IN NUMBER,
			 action_code IN VARCHAR2) RETURN NUMBER ;

	FUNCTION InsertRow(
			 		   		 part_no         IN VARCHAR2,
  							 loc_sid         IN NUMBER,
  							 inv_qty         IN NUMBER) RETURN NUMBER ;
	FUNCTION UpdateRow(
			 		   		 part_no         IN VARCHAR2,
  							 loc_sid         IN NUMBER,
  							 inv_qty         IN NUMBER) RETURN NUMBER ;
	FUNCTION DeleteRow(
			 		   		 part_no         IN VARCHAR2,
  							 loc_sid         IN NUMBER) RETURN NUMBER;
							 
							 
	/* amd_rsp diff functions */
	FUNCTION doRspSumDiff(
			 part_no 	IN VARCHAR2,
			 rsp_location  VARCHAR2,
             override_type in varchar2, /* added 10/29/2007 by dse */
			 qty_on_hand		IN NUMBER,
			 rsp_level			   IN NUMBER,
			 action_code IN VARCHAR2) RETURN NUMBER;  
			 
	FUNCTION RspInsertRow(
			 		   PART_NO IN VARCHAR2,
					   LOC_SID IN NUMBER,
					   RSP_INV IN NUMBER,
					   RSP_LEVEL IN NUMBER) RETURN NUMBER;
					   
	FUNCTION RspUpdateRow(
			 		   PART_NO IN VARCHAR2,
					   LOC_SID IN NUMBER,
					   RSP_INV IN NUMBER,
					   RSP_LEVEL IN NUMBER) RETURN NUMBER;
					 
	FUNCTION RspDeleteRow(
			 			  PART_NO	IN VARCHAR2,
						  LOC_SID  IN NUMBER)RETURN NUMBER; 
						  

    /* amd_in_repair diff functions */
	FUNCTION doRepairInvsSumDiff(
			 part_no IN VARCHAR2,
			 site_location IN VARCHAR2,
			 qty_on_hand IN NUMBER,
			 action_code IN VARCHAR2) RETURN NUMBER ;

	FUNCTION InsertRow(
			 		   PART_NO         IN VARCHAR2,
  					   LOC_SID         IN NUMBER,
  					   REPAIR_DATE     IN DATE,
  					   REPAIR_QTY      IN NUMBER,
  					   ORDER_NO       IN VARCHAR2,
					   REPAIR_NEED_DATE	 IN DATE) RETURN NUMBER ;
	FUNCTION UpdateRow(
			 		   PART_NO         IN VARCHAR2,
  					   LOC_SID         IN NUMBER,
  					   REPAIR_DATE     IN DATE,
  					   REPAIR_QTY      IN NUMBER,
  					   ORDER_NO       IN VARCHAR2,
					   REPAIR_NEED_DATE IN DATE) RETURN NUMBER ;
	FUNCTION inRepairDeleteRow(
			 		   PART_NO         IN VARCHAR2,
  					   LOC_SID         IN NUMBER,
  					   ORDER_NO		   IN VARCHAR2) RETURN NUMBER ;


	/* amd_in_transits diff functions */
	FUNCTION InsertRow(
				 	   TO_LOC_SID	  		IN NUMBER,
					   QUANTITY				IN NUMBER,
					   DOCUMENT_ID			IN VARCHAR2,
					   PART_NO				IN VARCHAR2,
					   FROM_LOCATION		IN VARCHAR2,
					   IN_TRANSIT_DATE		IN DATE,
					   SERVICEABLE_FLAG		IN VARCHAR2) RETURN NUMBER ;
	FUNCTION UpdateRow(
				 	   TO_LOC_SID			IN NUMBER,
					   QUANTITY				IN NUMBER,
					   DOCUMENT_ID			IN VARCHAR2,
					   PART_NO				IN VARCHAR2,
					   FROM_LOCATION		IN VARCHAR2,
					   IN_TRANSIT_DATE		IN DATE,
					   SERVICEABLE_FLAG		IN VARCHAR2) RETURN NUMBER ;
	FUNCTION DeleteRow(
				 	   DOCUMENT_ID			IN VARCHAR2,
					   PART_NO				IN VARCHAR2,
					   TO_LOC_SID			IN NUMBER) RETURN NUMBER ;


	/* amd_in_transits_sum diff function */
	FUNCTION InsertRow(
				 	   PART_NO			   	IN VARCHAR2,
					   SITE_LOCATION			IN VARCHAR2,
					   QUANTITY				IN NUMBER,
					   SERVICEABLE_FLAG		IN VARCHAR2) RETURN NUMBER ;

	FUNCTION UpdateRow(
				 	   PART_NO				IN VARCHAR2,
					   SITE_LOCATION			IN VARCHAR2,
					   QUANTITY				IN NUMBER,
					   SERVICEABLE_FLAG		IN VARCHAR2) RETURN NUMBER ;

	FUNCTION DeleteRow(
				 	   PART_NO				IN VARCHAR2,
					   SITE_LOCATION			IN VARCHAR2,
					   SERVICEABLE_FLAG		IN VARCHAR2) RETURN NUMBER ;


	PROCEDURE loadOnHandInvs ;

	PROCEDURE loadInRepair ;

	PROCEDURE updateSpoTotalInventory;

	-- added 9/2/2005 by dse
	FUNCTION getOrderCreateDate(voucher IN VARCHAR2) RETURN DATE ;
	PROCEDURE setOrderCreateDate(voucher IN VARCHAR2, orderCreateDate IN DATE) ;
	FUNCTION getScdeduledReceiptDateFrom(voucher IN VARCHAR2) RETURN DATE ;
	FUNCTION getScdeduledReceiptDateTo(voucher IN VARCHAR2) RETURN DATE ;
	PROCEDURE setScheduledReceiptDate(voucher IN VARCHAR2, fromDate IN DATE, toDate DATE) ;
	PROCEDURE setScheduledReceiptDateCalDays(voucher IN VARCHAR2, days IN NUMBER) ;
	-- added 9/8/2005 by dse
	FUNCTION getScheduledReceiptDateCalDays(voucher IN VARCHAR2) RETURN NUMBER ;

	-- added 9/10/2005 by dse
	PROCEDURE getOnOrderParams(voucher IN VARCHAR2,
			  orderCreateDate 		  OUT DATE,
			  schedReceiptDateFrom 	  OUT DATE,
			  schedReceiptDateTo 	  OUT DATE,
			  schedReceiptCalDays 	  OUT NUMBER) ;
	PROCEDURE setOnOrderParams(voucher IN VARCHAR2,
			  orderCreateDate 		   IN DATE,
			  schedReceiptDateFrom 	   IN DATE,
			  schedReceiptDateTo 	   IN DATE,
			  schedReceiptCalDays 	   IN NUMBER) ;
	FUNCTION isVoucher(voucher IN VARCHAR2) RETURN BOOLEAN ;
	PROCEDURE clearOnOrderParams ;
	FUNCTION numberOfOnOrderParams RETURN NUMBER ;
	TYPE ref_cursor IS REF CURSOR ;
	FUNCTION getVouchers RETURN ref_cursor ;
	-- added 6/9/2006 by dse
	procedure version ;
    -- added 4/6/2007 by dse
    function getNextLine(gold_order_number in amd_on_order.gold_order_number%type) return number ;
	function getCurrentLine(gold_order_number in amd_on_order.gold_order_number%type, order_date in amd_on_order.order_date%type, loc_sid in amd_on_order.loc_sid%type) return number ; 
     
    -- added 2/6/2008 by dse
    function getVersion return varchar2 ;
    procedure setDebug(switch in varchar2) ;

    procedure setDateThreshold(date_in in varchar2,date_format in varchar2 := 'MM/DD/YYYY') ;
    function getDateThreshold return date ;
    
    function isInvalidDateYorN(date_in in date) return varchar2 ; -- added 2/16/09


END Amd_Inventory;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_INVENTORY;

CREATE PUBLIC SYNONYM AMD_INVENTORY FOR AMD_OWNER.AMD_INVENTORY;


GRANT EXECUTE ON AMD_OWNER.AMD_INVENTORY TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_INVENTORY TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_INVENTORY TO BSRM_LOADER;


SET DEFINE OFF;
DROP PACKAGE BODY AMD_OWNER.AMD_INVENTORY;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.Amd_Inventory AS

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
		
       $Author:   zf297a  $
     $Revision:   1.100  $
         $Date:   05 Jun 2009 09:50:54  $
     $Workfile:   amd_inventory.pkb  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_inventory.pkb-arc  $
   
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
   Added sched_receipt_date & changed in order_date in amd_on_order.
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
	-- 	   		   and DeleteRow functions for the amd_on_hand_invs table
	-- TP	 8/2/04  Added InsertRow, UpdateRow, and DeleteRow for the amd_in_repair table.
	-- TP    8/18/04 Added InsertRow, UpdateRow, and DeleteRow for the amd_in_transits table.
	-- 

    debug boolean := false ;
	dateThreshold date := to_date('01/01/1980','MM/DD/YYYY') ; -- there should not be any repair dates earlier than this
    
	ON_ORDER_DATE CONSTANT AMD_PARAMS.PARAM_KEY%TYPE := 'on_order_date_' ;
		
	SUBTYPE orderdates IS NUMBER ;
	ORDER_CREATE_DATE CONSTANT orderdates := 1 ;
	SCHEDULED_RECEIPT_DATE_FROM CONSTANT orderdates := 2 ;
	SCHEDULED_RECEIPT_DATE_TO CONSTANT orderdates := 3 ;
	NUMBER_OF_CALANDER_DAYS CONSTANT orderdates := 4 ;
	
	type partRec is record (
        part_no amd_spare_parts.part_no%type,
        nsn amd_national_stock_items.nsn%type
    ) ;
    type partTab is table of partRec ;
    partRecs partTab ;
            
	CURSOR partCur IS
		SELECT DISTINCT
			asp.part_no,
			asp.nsn
		FROM
			AMD_SPARE_PARTS asp,
			AMD_NATIONAL_STOCK_ITEMS ansi,
			AMD_NSI_PARTS anp
		WHERE
			icp_ind = 'F77'
			AND asp.part_no   = anp.part_no
			AND anp.prime_ind = 'Y'
			AND anp.unassignment_date IS NULL
			AND asp.nsn = ansi.nsn
			AND asp.action_code != 'D';
				
	-- Type 1,2 Retail
    
    type rampRec is record (
        loc_sid amd_spare_networks.loc_sid%type,
        serviceable_balance ramp.SERVICEABLE_BALANCE%type,
        spram_balance ramp.SPRAM_BALANCE%type,
        wrm_balance ramp.WRM_BALANCE%type,
        hpmsk_balance ramp.HPMSK_BALANCE%type,
        total_inaccessible_qty ramp.TOTAL_INACCESSIBLE_QTY%type,
        difm_balance ramp.DIFM_BALANCE%type,
        unserviceable_balance ramp.UNSERVICEABLE_BALANCE%type,
        spram_level ramp.SPRAM_LEVEL%type,
        wrm_level ramp.WRM_LEVEL%type,
        hpmsk_level_qty ramp.HPMSK_LEVEL_QTY%type,
        suspended_in_stock ramp.SUSPENDED_IN_STOCK%type,
        inv_date ramp.DATE_PROCESSED%type,
        repair_need_date ramp.DATE_PROCESSED%type
    ) ;
    
    
    type rampTab is table of rampRec ;
    rampRecs rampTab ;

    type rampInvQtyRec is record (
        loc_sid amd_spare_networks.loc_sid%type,
        serviceable_balance ramp.SERVICEABLE_BALANCE%type,
        spram_balance ramp.SPRAM_BALANCE%type,
        wrm_balance ramp.WRM_BALANCE%type,
        hpmsk_balance ramp.HPMSK_BALANCE%type,
        total_inaccessible_qty ramp.TOTAL_INACCESSIBLE_QTY%type,
        difm_balance ramp.DIFM_BALANCE%type,
        unserviceable_balance ramp.UNSERVICEABLE_BALANCE%type,
        spram_level ramp.SPRAM_LEVEL%type,
        wrm_level ramp.WRM_LEVEL%type,
        hpmsk_level_qty ramp.HPMSK_LEVEL_QTY%type,
        suspended_in_stock ramp.SUSPENDED_IN_STOCK%type,
        inv_date ramp.DATE_PROCESSED%type,
        repair_need_date ramp.DATE_PROCESSED%type,
        inventory_quantity number,
        action_code TMP_AMD_ON_HAND_INVS.ACTION_CODE%type,
        last_update_dt date
    ) ;
    type rampInvQtyTab is table of rampInvQtyRec ;
    rampInvQtyRecs rampInvQtyTab ; 
    
					
    
	CURSOR rampCurUAB(pNsn VARCHAR2) IS
		SELECT
			DECODE(n.loc_type,'TMP',asn2.loc_sid,n.loc_sid) loc_sid,
			NVL(r.serviceable_balance,0) serviceable_balance,
			NVL(r.spram_balance,0) spram_balance,
			NVL(r.hpmsk_balance,0) hpmsk_balance,
			NVL(r.wrm_balance,0) wrm_balance,
			NVL(r.total_inaccessible_qty,0) total_inaccessible_qty,
			NVL(r.difm_balance,0) difm_balance,
			NVL(r.spram_level,0) spram_level,
			NVL(r.wrm_level,0) wrm_level,
			NVL(r.hpmsk_level_qty,0) hpmsk_level_qty,
			TRUNC(NVL(r.date_processed,SYSDATE)) inv_date,
			TRUNC((r.date_processed) + NVL(avg_repair_cycle_time,0)) repair_need_date
		FROM
			(SELECT * FROM RAMP
			WHERE current_stock_number = pNsn ) r,
			--AMD_SPARE_PARTS asp,
			AMD_SPARE_NETWORKS n,
			AMD_SPARE_NETWORKS asn2
		WHERE
			n.loc_id = SUBSTR(r.sc(+),8,6)
			AND SUBSTR(r.sc,8,2) = 'FB'
			--AND asp.nsn = pNsn
			AND n.loc_type = 'UAB'
			AND n.mob = asn2.loc_id(+);
			
        type rampFBrec is record (
			loc_sid amd_spare_networks.loc_sid%type,
			serviceable_balance ramp.SERVICEABLE_BALANCE%type,
			spram_balance ramp.SPRAM_BALANCE%type,
			wrm_balance ramp.WRM_BALANCE%type,
		    hpmsk_balance ramp.HPMSK_BALANCE%type,
			total_inaccessible_qty ramp.TOTAL_INACCESSIBLE_QTY%type,
			difm_balance ramp.DIFM_BALANCE%type,
			spram_level ramp.SPRAM_LEVEL%type,
			wrm_level ramp.WRM_LEVEL%type,
			hpmsk_level_qty ramp.HPMSK_LEVEL_QTY%type,
			inv_date ramp.DATE_PROCESSED%type,
			repair_need_date ramp.DATE_PROCESSED%type        
        ) ;		
        type rampFBtab is table of rampFBrec ;
        rampFBrecs rampFBtab ;
        
			
    
    type tmpAmdOnHandInvsTab is table of tmp_amd_on_hand_invs%rowtype ;
    tmpAmdOnHandInvsRecs tmpAmdOnHandInvsTab ;
    
    
				
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
				pSourceName => 'amd_inventory',	
				pTableName  => pTableName,
				pError_location => pError_location,
				pKey1 => pKey1,
				pKey2 => pKey2,
				pKey3 => pKey3,
				pKey4 => pKey4,
				pData    => pData,
				pComments => pComments);
	END writeMsg ;
	

	procedure warningMsg(pWarning_Location IN NUMBER,
		key1 IN VARCHAR2 := '',
 		key2 IN VARCHAR2 := '',
		key3 IN VARCHAR2 := '',
		key4 IN VARCHAR2 := '',
		key5 IN VARCHAR2 := '',					
		msg IN VARCHAR2 := '') IS

         	pragma autonomous_transaction ;
	BEGIN
		Amd_warnings_pkg.insertWarningMsg (
				pData_line_no => pWarning_Location,
				pData_line    => 'amd_inventory',
				pKey_1 => key1,
				pKey_2 => key2,
				pKey_3 => key3,
				pKey_4 => key4,
				pKey_5 => key5,
				pWarning => msg) ;
		COMMIT;
		RETURN ;
	END warningMsg ;

	PROCEDURE errorMsg(
					sqlFunction IN VARCHAR2,
					tableName IN VARCHAR2,
					pError_Location IN NUMBER,
					key1 IN VARCHAR2 := '',
			 		key2 IN VARCHAR2 := '',
					key3 IN VARCHAR2 := '',
					key4 IN VARCHAR2 := '',
					key5 IN VARCHAR2 := '',					
					keywordValuePairs IN VARCHAR2 := '') IS
         	pragma autonomous_transaction ;
	BEGIN
		Amd_Utils.InsertErrorMsg (
				pLoad_no => Amd_Utils.GetLoadNo(
						pSourceName => sqlFunction,
						pTableName  => tableName),
				pData_line_no => pError_Location,
				pData_line    => 'amd_inventory',
				pKey_1 => key1,
				pKey_2 => key2,
				pKey_3 => key3,
				pKey_4 => key4,
				pKey_5 => key5 || ' ' || keywordValuePairs,
				pComments => SqlFunction || '/' || TableName || ' sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')');
		COMMIT;
		RETURN ;
	END ErrorMsg;
	
	FUNCTION ErrorMsg(
					pSqlFunction IN VARCHAR2,
					pTableName IN VARCHAR2,
					pError_Location IN NUMBER,
					pReturn_code IN NUMBER,
					pKey_1 IN VARCHAR2,
			 		pKey_2 IN VARCHAR2 := '',
					pKey_3 IN VARCHAR2 := '',
					pKey_4 IN VARCHAR2 := '',					
					pKeywordValuePairs IN VARCHAR2 := '') RETURN NUMBER IS
         	pragma autonomous_transaction ;
	BEGIN
		Amd_Utils.InsertErrorMsg (
				pLoad_no => Amd_Utils.GetLoadNo(
						pSourceName => pSqlFunction,
						pTableName  => pTableName),
				pData_line_no => pError_Location,
				pData_line    => 'amd_inventory',
				pKey_1 => pKey_1,
				pKey_2 => pKey_2,
				pKey_3 => pKey_3,
				pKey_4 => pKey_4,
				pKey_5 => 'rc=' || TO_CHAR(pReturn_code) ||
					   ' ' || pKeywordValuePairs,
				pComments => pSqlFunction || '/' || pTableName || ' sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')');
		COMMIT;
		RETURN pReturn_code;
	END ErrorMsg;
	

	PROCEDURE LoadGoldInventory IS

		nsnDashed      VARCHAR2(16);
		orderSid       NUMBER;

		pn          VARCHAR2(50);
		loc_sid     NUMBER;
		inv_date    DATE;
		invQty      NUMBER;

		result NUMBER ;
		
	
	
	BEGIN

        writeMsg(pTableName => 'tmp_amd_...', pError_location => 10,
            pKey1 => 'loadGoldInventory',
            pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;

		loadOnHandInvs ;

		loadInRepair ;

		loadOnOrder ;
		
		loadInTransits ;
		
		loadRsp;

		
        writeMsg(pTableName => 'tmp_amd_...', pError_location => 20,
            pKey1 => 'loadGoldInventory',
            pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
			
	EXCEPTION
		 WHEN OTHERS THEN 
            ErrorMsg(sqlFunction => 'loadGoldInventory',
                tableName => 'inventory tables',
                pError_Location => 20) ; 
		    RAISE ;
	END LoadGoldInventory;
	

	PROCEDURE loadOnOrder IS
        type tmpAmdOnOrderTab is table of tmp_amd_on_order%rowtype ;
        tmpAmdOnOrderRecs tmpAmdOnOrderTab ;
        
        	
		CURSOR itemType3aCur IS
		SELECT 
	   		    asp.part_no part_no,
	  		    DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
	   			invQ.inv_date inv_date,
	  			SUM(invQ.inv_qty) inv_qty,
	  			invQ.order_no order_no,
				TRUNC(invQ.receipt_date) receipt_date,
                amd_defaults.INSERT_ACTION action_code,
                sysdate last_update_dt	  
		FROM (				
                 SELECT
                       o.part part_no,
                       SUBSTR(sc,8,6) loc_id,
                       TRUNC(o.created_datetime) inv_date,
                       NVL(o.qty_due,0) inv_qty,
                       o.order_no order_no,
                       DECODE(ecd, NULL, need_date, ecd) receipt_date
                FROM
                       ORD1 o
                WHERE
                       o.status = 'O'
                       AND o.order_type = 'M'
                       and o.created_datetime is not null
                UNION ALL 
                SELECT
                      part part_no,
                      SUBSTR(sc,8,6) loc_id,
                      TRUNC(o.created_datetime) inv_date,
                      NVL(o.qty_due,0) inv_qty,
                      o.order_no order_no,
                      DECODE(o.ecd, NULL, o.need_date, o.ecd) receipt_date
                FROM
                      ORD1 o
                WHERE
                       o.status = 'O'
                       AND o.order_type = 'C'
                       AND SUBSTR(o.order_no,1,2) IN ('FC','BA','AM','RS','SE','BR','BN','LB','DU','CF','NF','WF')
                       and o.created_datetime is not null
                UNION ALL
                SELECT 	
                    part part_no,
                    SUBSTR(sc,8,6) loc_id,
                    TRUNC(o.created_datetime) inv_date,
                    NVL(o.qty_due,0) inv_qty,
                    o.order_no order_no,
                    DECODE(o.ecd, NULL, o.need_date, o.ecd) receipt_date
                FROM
                    ORD1 o, amd_spare_networks asp                
                WHERE
                     o.status = 'O'
                     AND o.order_type = 'C'
                     AND substr(order_no,1,3) = substr(asp.loc_id,4,3)
                     and substr(asp.loc_id,1,2) in ('FB','EY')
                     and o.created_datetime is not null
                ) invQ,
			    AMD_SPARE_NETWORKS  asn,
				AMD_SPARE_PARTS  asp,
				AMD_SPARE_NETWORKS  asnLink
		WHERE
	 		 asp.part_no = invQ.part_no
			 AND asn.loc_id = invQ.loc_id
			 AND asp.action_code != 'D'
			 AND asn.mob = asnLink.loc_id(+)
             and invQ.inv_date is not null
		GROUP BY 
	  	 	asp.part_no,
			DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid),
			invQ.inv_date,
			invQ.order_no,
			TRUNC(invQ.receipt_date)
        having SUM(invQ.inv_qty) > 0 ;
            

				   
        CURSOR itemType3bCur IS	   
        SELECT 
              i.part part_no,
              DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
              TRUNC(i.created_datetime) inv_date,
              SUM(i.qty) inv_qty,
              i.receipt_order_no order_no,
              DECODE(TRUNC(o.ecd), NULL, SYSDATE, TRUNC(o.ecd))  receipt_date,
              amd_defaults.INSERT_ACTION action_code,
              sysdate last_update_dt
        FROM
              ITEM i,
              ORD1 o,
              AMD_SPARE_NETWORKS  asn,
              AMD_SPARE_PARTS  asp,
              AMD_SPARE_NETWORKS asnLink
        WHERE
              i.receipt_order_no = o.order_no
              AND o.status = 'O'
              AND i.condition = 'B170-ATL' 
              AND asp.part_no = i.part
              AND asn.loc_id = SUBSTR(i.sc,8,6) 
              AND asp.action_code != 'D'
              AND asn.mob = asnLink.loc_id(+)
              and i.created_datetime is not null
        GROUP BY 
              i.part,
              DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid),
              TRUNC(i.created_datetime),
              i.receipt_order_no,
              DECODE(TRUNC(o.ecd), NULL, SYSDATE, TRUNC(o.ecd))
        having SUM(i.qty) > 0 ;              
				  
            type itemType3cRec is record (
                part_no tmp1.FROM_PART%type,
                loc_sid amd_spare_networks.loc_sid%type,
                inv_date date,
                inv_qty number,
                order_no tmp1.TEMP_OUT_ID%type,
                receipt_date date
            ) ;			
            type itemType3cTab is table of itemType3cRec ;
            itemType3cRecs itemType3cTab ;
            
			CURSOR itemType3cCur IS
			SELECT
				 from_part part_no,
				 DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
				 TRUNC(from_datetime) inv_date,
				 SUM(qty_due) inv_qty,
				 temp_out_id order_no,
				DECODE(est_return_date, NULL, NULL,est_return_date) receipt_date,
                amd_defaults.INSERT_ACTION action_code,
                sysdate last_update_dt            
			FROM
				 TMP1,
				 AMD_SPARE_NETWORKS  asn,
				 AMD_SPARE_PARTS  asp,
				 AMD_SPARE_NETWORKS asnLink
			WHERE
				  returned_voucher IS NULL
				  AND status = 'O'
				  AND tcn = 'LNI'
	 			  AND  asp.part_no = from_part
			 	  AND asn.loc_id = SUBSTR(from_sc,8,6)
			 	  AND asp.action_code != 'D'
				  AND asn.mob = asnLink.loc_id(+)
                  and from_datetime is not null
		GROUP BY 
	  	 	from_part,
			DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid),
			TRUNC(from_datetime),
			temp_out_id,
			est_return_date
        having SUM(qty_due) > 0 ;            
			
		
	BEGIN
        writeMsg(pTableName => 'tmp_amd_on_order', pError_location => 30,
            pKey1 => 'loadOnOrder',
            pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
        Mta_Truncate_Table('TMP_AMD_ON_ORDER','reuse storage');
        Mta_Truncate_Table('TMP_A2A_ORDER_INFO_LINE','reuse storage');
		
        open itemType3aCur ;
        fetch itemType3aCur bulk collect into tmpAmdOnOrderRecs ;
        close itemType3aCur ;
        
        if tmpAmdOnOrderRecs.first is not null then
            -- type3aWholeSale
            FORALL indx in tmpAmdOnOrderRecs.first .. tmpAmdOnOrderRecs.last 
                    -- Type_3a
                        INSERT INTO TMP_AMD_ON_ORDER
                        VALUES tmpAmdOnOrderRecs(indx) ;
            writeMsg(pTableName => 'tmp_amd_on_order', pError_location => 40,
                pKey1 => 'itemType3a',
                pKey2 => 'loaded at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => '# of recs = ' || to_char(sql%rowcount) ) ;
            commit ;                
        end if ;             
	
        open itemType3bCur ;
        fetch itemType3bCur bulk collect into tmpAmdOnOrderRecs ;
        close itemtype3bCur ;
        
        if tmpAmdOnOrderRecs.first is not null then
            --type3bWholesale
            FORALL indx in tmpAmdOnOrderRecs.first .. tmpAmdOnOrderRecs.last 
                -- Type_3b
                INSERT INTO TMP_AMD_ON_ORDER
                VALUES tmpAmdOnOrderRecs(indx) ;
                
            writeMsg(pTableName => 'tmp_amd_on_order', pError_location => 50,
                pKey1 => 'itemType3b',
                pKey2 => 'loaded at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => '# recs = '  || to_char(sql%rowcount) ) ;
            commit ;                
		end if ;
        
        open itemType3cCur ;
        fetch itemType3cCur bulk collect into tmpAmdOnOrderRecs ;
        close itemType3cCur ;
        
        if tmpAmdOnOrderRecs.first is not null then
            -- type3cWholeSale
            FORALL indx in tmpAmdOnOrderRecs.first .. tmpAmdOnOrderRecs.last 
                --Type_3c
                INSERT INTO TMP_AMD_ON_ORDER
                VALUES tmpAmdOnOrderRecs(indx) ;
                
            writeMsg(pTableName => 'tmp_amd_on_order', pError_location => 60,
                pKey1 => 'itemType3c',
                pKey2 => 'loaded at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => '# recs = ' || to_char(sql%rowcount)) ;
            commit ;                
        end if ;              

        writeMsg(pTableName => 'tmp_amd_on_order', pError_location => 70,
            pKey1 => 'loadOnOrder',
            pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM')) ;
		
	END loadOnOrder ;
	
	
	
	PROCEDURE loadInTransits IS
	BEGIN
		
        writeMsg(pTableName => 'tmp_amd_in_transits', pError_location => 80,
            pKey1 => 'loadInTransits',
            pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
        Mta_Truncate_Table('TMP_AMD_IN_TRANSITS','reuse storage');
        Mta_Truncate_Table('TMP_A2A_IN_TRANSITS','reuse storage');
		
		-- Populate data into table amd_in_transits
		<<insertInTransits1>>
		BEGIN 
			INSERT INTO TMP_AMD_IN_TRANSITS
			(
				   to_loc_sid,
				   quantity,
				   action_code,
				   last_update_dt,
				   document_id,
				   part_no,
				   from_location,
				   in_transit_date,
				   serviceable_flag
			)
			SELECT 
				   loc_sid,
				   (NVL(m.ship_qty,0) - NVL(m.receipt_qty,0)) quantity,
				   'A',
				   SYSDATE,
				   m.document_id,
				   m.part,
				   m.in_tran_from,
				   TO_DATE(m.create_date),
				   DECODE(m.mils_condition,'A','Y','B','Y','C','Y','D','Y','N') mils_condition
			FROM
				MLIT m,
				AMD_SPARE_NETWORKS a
			WHERE
				 (NVL(m.ship_qty,0) - NVL(m.receipt_qty,0)) > 0 
				 AND m.in_tran_to NOT LIKE 'FE%'
				 AND (DECODE(m.in_tran_to,'FD2090','CTLATL','FB' || SUBSTR(in_tran_to,3)) = a.loc_id
				 OR DECODE(m.in_tran_to,'EY3571','CODALT','FB' || SUBSTR(in_tran_to,3)) = a.loc_id
				 OR DECODE(m.in_tran_to,'EY7739','CODCHS','FB' || SUBSTR(in_tran_to,3)) = a.loc_id
				 OR DECODE(m.in_tran_to,'EY8388','CODMCD','FB' || SUBSTR(in_tran_to,3)) = a.loc_id);
			COMMIT;
		END insertInTransits1 ;
		
		<<insertInTransits2>>
		BEGIN
			 INSERT INTO TMP_AMD_IN_TRANSITS
			 (
			  		to_loc_sid,
					quantity,
					action_code,
					last_update_dt,
					document_id,
					part_no,
					from_location,
					in_transit_date,
					serviceable_flag
			)
			SELECT
				  a.loc_sid,
				  i.qty,
				  'A',
				  SYSDATE,
				  i.item_id,
				  i.part,
				  SUBSTR(i.sc,8,6),
				  r.created_docdate,
				  i.status_servicable
			FROM
				ITEM i, RSV1 r, AMD_SPARE_NETWORKS a
				WHERE i.status_3 = 'I'
				AND i.condition != 'B170-ATL'
				AND i.status_servicable = 'Y'
				AND i.status_new_order = 'N'
				AND i.status_accountable = 'Y'
				AND i.status_active = 'Y'
				AND i.status_mai = 'N'
				AND NOT EXISTS (SELECT 1 FROM ITEM i2 
								    WHERE i2.status_avail = 'N' 
									AND   i2.receipt_order_no IS NULL
									AND   i2.item_id = i.item_id)
				AND r.status = 'O'
				AND i.item_id = r.item_id
				AND SUBSTR(r.to_sc,8,6) = a.loc_id
				AND i.qty IS NOT NULL;			
			COMMIT;
		END insertInTransits2 ;
		

        writeMsg(pTableName => 'tmp_amd_in_transits', pError_location => 90,
            pKey1 => 'loadInTransits',
            pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	END loadInTransits ;
	
	
	PROCEDURE loadRsp IS
			  nsnDashed					VARCHAR2(16) := NULL;
			  RspQty  						 NUMBER := 0;
			  RspLevel					   NUMBER := 0;
			  cntRsp						  NUMBER := 0;
			  cntType1						  NUMBER := 0;
			  cntType2						  NUMBER := 0;
			  result						  NUMBER := 0;
			  
	    type tmpAmdRspTab is table of tmp_amd_rsp%rowtype ;
        tmpAmdRspRecs tmpAmdRspTab ;
    
		CURSOR rampCurFB(pNsn VARCHAR2, pPartNo varchar2) IS
		SELECT
            pPartNo part_no,
			DECODE(n.loc_type,'TMP',asn2.loc_sid,n.loc_sid) loc_sid,
            nvl(r.spram_balance,0) + nvl(r.hpmsk_balance,0) + nvl(r.wrm_balance,0) rsp_inv,
            nvl(r.spram_level,0) + nvl(r.wrm_level,0) + nvl(r.hpmsk_level_qty,0) rsp_level,
            amd_defaults.INSERT_ACTION action_code,
            sysdate last_update_dt
		FROM
			(SELECT * FROM RAMP
			WHERE current_stock_number = pNsn ) r,
			--AMD_SPARE_PARTS asp,
			AMD_SPARE_NETWORKS n,
			AMD_SPARE_NETWORKS asn2
		WHERE
			n.loc_id = SUBSTR(r.sc(+),8,6)
			AND n.loc_type in ('MOB','FSL','UAB')
			AND substr(r.sc,8,2) like 'FB%'
			AND n.mob = asn2.loc_id(+)
            and ( nvl(r.spram_balance,0) + nvl(r.hpmsk_balance,0) + nvl(r.wrm_balance,0) > 0
                 or  nvl(r.spram_level,0) + nvl(r.wrm_level,0) + nvl(r.hpmsk_level_qty,0) > 0
                 ) ;
                 
        rspCnt number := 0 ;                 
            
	BEGIN
		
        writeMsg(pTableName => 'tmp_amd_rsp', pError_location => 100,
            pKey1 => 'loadRsp',
            pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
        Mta_Truncate_Table('TMP_AMD_RSP','reuse storage');
		Amd_Batch_Pkg.truncateIfOld('tmp_a2a_loc_part_override') ;
		COMMIT;
		
        open partCur ;
        fetch partCur bulk collect into partRecs ;
        close partCur ;
        
        -- Populate data into table tmp_amd_rsp
        if partRecs.first is not null then		
            FOR indx in partRecs.first .. partRecs.last LOOP
        		
                        nsnDashed := Amd_Utils.FormatNsn(partRecs(indx).nsn, 'GOLD');
                        open rampCurFB(nsnDashed, partRecs(indx).part_no) ;
                        fetch rampCurFB bulk collect into tmpAmdRspRecs ;
                        close rampCurFB ;
                        
                        if tmpAmdRspRecs.first is not null then
                            --rspUABRampLoop
                            FORALL yDex in tmpAmdRspRecs.first .. tmpAmdRspRecs.last 
                                INSERT INTO TMP_AMD_RSP
                                VALUES tmpAmdRspRecs(yDex) ;
                            commit ;
                            rspCnt := rspCnt + sql%rowcount ;                                                                
                        end if ;        
            end loop ;
        end if ;            
                			
        writeMsg(pTableName => 'tmp_amd_rsp', pError_location => 110,
            pKey1 => 'loadRsp',
            pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
            pKey3 => '# recs = ' || to_char(rspCnt)) ;
    END loadRsp;
										  
	
	FUNCTION getSiteLocation(loc_sid IN AMD_SPARE_NETWORKS.loc_sid%TYPE) RETURN
			 AMD_SPARE_NETWORKS.loc_id%TYPE IS
			 
			 loc_id AMD_SPARE_NETWORKS.loc_id%TYPE ;
			 result NUMBER ;
	BEGIN
		SELECT loc_id INTO loc_id 
		FROM AMD_SPARE_NETWORKS
		WHERE loc_sid = getSiteLocation.loc_sid ;
		
		RETURN loc_id ;
	EXCEPTION WHEN OTHERS THEN
		result := ErrorMsg(pSqlFunction => 'select',
		pTableName => 'amd_spare_networks',
		pError_Location => 80 , 
		pReturn_code => FAILURE,
		pKey_1 => 'loc_sid') ;
		RAISE ;
	END getSiteLocation ;
	
	
	FUNCTION doRepairInvsSumDiff(
			 part_no IN VARCHAR2, 
			 site_location IN VARCHAR2,
			 qty_on_hand IN NUMBER, 
			 action_code IN VARCHAR2) RETURN NUMBER IS

	    badActionCode             EXCEPTION ;
		
		FUNCTION InsertRow RETURN NUMBER IS
	
		BEGIN
		  	<<insertAmdRepairInvsSums>> 
			DECLARE
				   PROCEDURE doUpdate IS
				   BEGIN
				   		<<getActionCode>>
						DECLARE
							   action_code AMD_IN_REPAIR.action_code%TYPE ;
							   badInsert EXCEPTION ;
						BEGIN
							 SELECT action_code 
							 INTO action_code 
							 FROM AMD_REPAIR_INVS_SUM 
							 WHERE part_no = doRepairInvsSumDiff.part_no 
							 AND site_location = doRepairInvsSumDiff.site_location ;
							 
							 IF action_code != Amd_Defaults.DELETE_ACTION THEN
							 	RAISE badInsert ;
							 END IF ;
						EXCEPTION WHEN OTHERS THEN
							errorMsg(SqlFunction => 'select',
										TableName => 'amd_repair_invs_sum',
										pError_Location => 90, 
										key1 => doRepairInvsSumDiff.part_no,
										key2 => doRepairInvsSumDiff.site_location);
						
						END getActionCode ;
						UPDATE AMD_REPAIR_INVS_SUM
						SET qty_on_hand = doRepairInvsSumDiff.qty_on_hand,
						action_code = Amd_Defaults.INSERT_ACTION,
						last_update_dt = SYSDATE
						WHERE part_no = doRepairInvsSumDiff.part_no AND site_location = doRepairInvsSumDiff.site_location ;
				   END doUpdate ;
			BEGIN
				 INSERT INTO AMD_REPAIR_INVS_SUM
				(
					part_no,
					site_location,
					qty_on_hand,
					action_code,
					last_update_dt
				)
				VALUES
				(
				    part_no,
					site_location,
					qty_on_hand,
					Amd_Defaults.INSERT_ACTION,
					SYSDATE
				);
				
				EXCEPTION
						WHEN standard.DUP_VAL_ON_INDEX THEN
							 doUpdate ;
						WHEN OTHERS THEN
            				ErrorMsg(sqlFunction => 'insert',
            						tableName => 'amd_on_order',
									pError_Location => 100, 
								    key1 => part_no,
									key2 => site_location ) ;
                        raise ;
		     END insertAmdRepairInvs ;
			 
			A2a_Pkg.insertRepairInvInfo(part_no, site_location, qty_on_hand, Amd_Defaults.INSERT_ACTION);
			 
			 RETURN SUCCESS;
		END InsertRow ;
		
		FUNCTION UpdateRow RETURN NUMBER IS
			-- get the detail for the summarized inv_qty
			result NUMBER ;
			 
		BEGIN
			<<updateAmdRepairInvs>> 
			BEGIN
				UPDATE AMD_REPAIR_INVS_SUM SET
		            qty_on_hand 	   = doRepairInvsSumDiff.qty_on_hand,
					action_code    = Amd_Defaults.UPDATE_ACTION,
					last_update_dt = SYSDATE
				WHERE part_no  = doRepairInvsSumDiff.part_no
				      AND site_location  = doRepairInvsSumDiff.site_location ;
				EXCEPTION
						WHEN OTHERS THEN
							ErrorMsg(SqlFunction => 'update',
										TableName => 'amd_repair_invs_sum',
										pError_Location => 110, 
										key1 => part_no,
										key2 => site_location) ;
                            raise ;
			END updateAmdRepairInvs ;
			
			
			A2a_Pkg.insertRepairInvInfo(part_no,site_location,qty_on_hand, Amd_Defaults.UPDATE_ACTION) ;
			RETURN SUCCESS;
	
		END UpdateRow ;
	
		FUNCTION DeleteRow RETURN NUMBER IS
		BEGIN
		     
			<<updateAmdRepairInvs>> -- logically delete all records for the part_no and loc_sid
			BEGIN
			 UPDATE AMD_REPAIR_INVS_SUM SET
				action_code    = Amd_Defaults.DELETE_ACTION,
				last_update_dt = SYSDATE
			WHERE    part_no  = doRepairInvsSumDiff.part_no
				 AND site_location  = doRepairInvsSumDiff.site_location ;
			
			
			EXCEPTION
					WHEN OTHERS THEN
						ErrorMsg(SqlFunction => 'update',
									TableName => 'amd_repair_invs_sum',
									pError_Location => 120, 
									key1 => part_no,
									key2 => site_location) ;
                        raise ;
			 END updateAmdRepairInvs;
			 
			
			A2a_Pkg.insertRepairInvInfo(part_no, site_location,0, Amd_Defaults.DELETE_ACTION) ;
			RETURN SUCCESS;
			
		END DeleteRow ;
	BEGIN
		 IF action_code = Amd_Defaults.INSERT_ACTION THEN
		 	RETURN insertRow ;
		ELSIF action_code = Amd_Defaults.UPDATE_ACTION THEN
			RETURN updateRow ;
		ELSIF action_code = Amd_Defaults.DELETE_ACTION THEN
			RETURN deleteRow ;
		ELSE
			errorMsg(action_code,'amd_repair_invs_sum',68,part_no, site_location) ;
			RAISE badActionCode ;
			RETURN FAILURE ;
		END IF ;
	END doRepairInvsSumDiff ;


    function getDateThreshold return date is
    begin
        return dateThreshold ;
    end getDateThreshold ;
    
	procedure setDateThreshold(date_in in varchar2,date_format in varchar2 := 'MM/DD/YYYY') is
	begin
		dateThreshold := to_date(date_in,date_format) ;
	end setDateThreshold ;
	

	function isInvalidDate(date_in in date) return boolean is
	begin
		return trunc(date_in) < trunc(dateThreshold) ;
	end isInvalidDate ;
    
    function isInvalidDateYorN(date_in in date) return varchar2 is
    begin
        if isInvalidDate(date_in) then
            return 'Y' ;
        else
            return 'N' ;
        end if ;
    end isInvalidDateYorN ;                        

	procedure dateWarningMsg(date_in in date, part_no in varchar2, loc_sid in number, order_no in varchar2,
		date_name in varchar2, warning_location in number, rec_status in varchar2 := '') is
	begin
		warningMsg(pWarning_Location => warning_location, key1 => part_no, key2 => loc_sid, key3 => order_no,
			msg => to_char(date_in,'MM/DD/YYYY') || ' occurs before ' || to_char(dateThreshold,'MM/DD/YYYY')
			|| ' for ' || date_name || ' ' || rec_status) ;
	end dateWarningMsg ;

	
	/* amd_in_repair diff functions */
	FUNCTION InsertRow(
							PART_NO             IN VARCHAR2,
  							LOC_SID             IN NUMBER,
							REPAIR_DATE		  IN DATE,
  							REPAIR_QTY          IN NUMBER,
  							ORDER_NO		  IN VARCHAR2,
							REPAIR_NEED_DATE  IN DATE) RETURN NUMBER IS

        wk_repair_need_date date := repair_need_date ;                            
			
	BEGIN
		if isInvalidDate(repair_need_date) then
			dateWarningMsg(repair_need_date, part_no, loc_sid, order_no, 'amd_in_repair.repair_need_date',10,
                rec_status => 'Date set to null') ;
			wk_repair_need_date := null ;
		end if ;
		if isInvalidDate(repair_date) then
			dateWarningMsg(repair_date, part_no, loc_sid, order_no,'amd_in_repair.repair_date',20, 
                rec_status => 'Record rejected') ;
			return SUCCESS ; -- warning allows the app to continue and will be reported later
		end if ;

		 <<insertAmdInRepair>>
		 DECLARE
		 		PROCEDURE doUpdate IS
				BEGIN
					 <<getActionCode>>
					 DECLARE
					 		action_code AMD_IN_REPAIR.action_code%TYPE ;
							badInsert EXCEPTION ;
					 BEGIN
					 	  SELECT action_code 
						  INTO action_code 
						  FROM AMD_IN_REPAIR 
						  WHERE part_no = insertRow.part_no 
						  AND loc_sid = insertRow.loc_sid 
						  AND order_no = insertRow.order_no ;
						  IF action_code != Amd_Defaults.DELETE_ACTION THEN
						  	 RAISE badInsert ;
						  END IF ;
					 EXCEPTION WHEN OTHERS THEN 
						errorMsg(sqlFunction => 'select',
							     tableName => 'amd_in_repair',
								 pError_Location => 130, 
								 key1 => part_no,
								 key2 => loc_sid,
								 key3 => order_no);
					 END getActionCode ;
					 
					 UPDATE AMD_IN_REPAIR
					 SET
					 		     part_no = insertRow.part_no,
					 			 loc_sid = insertRow.loc_sid, 
					  			repair_date = insertRow.repair_date,
					 			repair_qty = insertRow.repair_qty,
					 			order_no= insertRow.order_no,
					 			repair_need_date = insertRow.wk_repair_need_date,
								 action_code = Amd_Defaults.INSERT_ACTION,
								  last_update_dt = SYSDATE
					 WHERE part_no = insertRow.part_no 
					 AND loc_sid = insertRow.loc_sid 
					 AND order_no = insertRow.order_no ;
				END doUpdate ;
		 BEGIN
			 INSERT INTO AMD_IN_REPAIR
			(
				part_no,
				loc_sid,
				repair_date,
				repair_qty,
				order_no,
				repair_need_date,
				action_code,
				last_update_dt
			)
			VALUES
			(
				part_no,
				loc_sid,
				repair_date,
				repair_qty,
				order_no,
				wk_repair_need_date,
				Amd_Defaults.INSERT_ACTION,
				SYSDATE
			);
			
			EXCEPTION
					WHEN standard.DUP_VAL_ON_INDEX THEN
						 doUpdate ;
					WHEN OTHERS THEN
						ErrorMsg(SqlFunction => 'insert',
									TableName => 'amd_in_repair',
									pError_Location => 140, 
									key1 => part_no,
									key2 => loc_sid,
									key3 => order_no);
                        raise ;
	     END insertAmdInRepair ;
		 
		 A2a_Pkg.insertRepairInfo(part_no,loc_sid,order_no,repair_date,A2a_Pkg.OPEN_STATUS,repair_qty,
              repair_need_date, Amd_Defaults.INSERT_ACTION) ;		 																							
		 
		 RETURN SUCCESS;
	END InsertRow ;

	FUNCTION UpdateRow(
							PART_NO             IN VARCHAR2,
  							LOC_SID             IN NUMBER,
							REPAIR_DATE		  IN DATE,
							REPAIR_QTY		  IN NUMBER,
  							ORDER_NO		  IN VARCHAR2,
							REPAIR_NEED_DATE  IN DATE) RETURN NUMBER IS
            wk_repair_need_date date := repair_need_date ;                            
	BEGIN
		if isInvalidDate(repair_need_date) then
			dateWarningMsg(repair_need_date, part_no, loc_sid, order_no,'amd_in_repair.repair_need_date',10,
                rec_status => 'Date set to null') ;
			wk_repair_need_date := null ;
		end if ;
		if isInvalidDate(repair_date) then
			dateWarningMsg(repair_date, part_no, loc_sid,order_no,'amd_in_repair.repair_date',20,
                rec_status => 'Record rejected') ;
			return SUCCESS ; -- warning allows the app to continue and will be reported later
		end if ;

		<<updateAmdInRepair>>  
		BEGIN
			UPDATE AMD_IN_REPAIR SET
					repair_date		=	UpdateRow.repair_date,
					repair_qty 		= 	UpdateRow.repair_qty,
					repair_need_date =  UpdateRow.repair_need_date,
					action_code    = Amd_Defaults.UPDATE_ACTION,
					last_update_dt = SYSDATE
			WHERE part_no = UpdateRow.part_no
			AND loc_sid = UpdateRow.loc_sid
			AND order_no = UpdateRow.order_no;

			EXCEPTION
					WHEN OTHERS THEN
						ErrorMsg(SqlFunction => 'update',
									TableName => 'amd_in_repair',
									pError_Location => 150, 
									key1 => part_no,
									key2 => loc_sid,
									key3 => order_no);
                        raise ;
		END updateAmdInRepair;
		
		 A2a_Pkg.insertRepairInfo(part_no,loc_sid,order_no,repair_date,A2a_Pkg.OPEN_STATUS,repair_qty,
               repair_need_date,Amd_Defaults.UPDATE_ACTION) ;		 																							
		RETURN SUCCESS ;
	END UpdateRow ;

	FUNCTION inRepairDeleteRow(
				 		   			PART_NO	  IN VARCHAR2,
									LOC_SID	  IN NUMBER,
									ORDER_NO  IN VARCHAR2) RETURN NUMBER IS
			repair_qty AMD_IN_REPAIR.repair_qty%TYPE;
			repair_date AMD_IN_REPAIR.repair_date%TYPE;
			repair_need_date AMD_IN_REPAIR. repair_need_date%TYPE ;
	BEGIN
		 <<updateAmdInRepair>>		 
		 BEGIN
			 UPDATE AMD_IN_REPAIR SET
				action_code    = Amd_Defaults.DELETE_ACTION,
				last_update_dt = SYSDATE
			WHERE PART_NO = inRepairDeleteRow.part_no
			AND LOC_SID = inRepairDeleteRow.LOC_SID
			AND ORDER_NO = inRepairDeleteRow.ORDER_NO ;
	
			EXCEPTION
					WHEN OTHERS THEN
						ErrorMsg(SqlFunction => 'update',
									TableName => 'amd_in_repair',
									pError_Location => 160, 
									key1 => part_no,
									key2 => loc_sid,
									key3 => order_no);
                        raise ;
		 END updateAmdInRepair;
		 <<selectAmdInRepair>>
		 BEGIN
			SELECT repair_qty, repair_date, repair_need_date  INTO repair_qty, repair_date, repair_need_date
			FROM AMD_IN_REPAIR
			WHERE part_no = inRepairDeleteRow.part_no
			AND loc_sid = inRepairDeleteRow.loc_sid
			AND order_no = inRepairDeleteRow.order_no;
	
			EXCEPTION
					WHEN OTHERS THEN
						ErrorMsg(SqlFunction => 'select',
									TableName => 'amd_in_repair',
									pError_Location => 170, 
									key1 => part_no,
									key2 => loc_sid,
									key3 => order_no);
                        raise ;
		 END selectAmdInRepair; 
		 
		 A2a_Pkg.insertRepairInfo(part_no,loc_sid,order_no,repair_date,A2a_Pkg.OPEN_STATUS,repair_qty,
               repair_need_date,Amd_Defaults.DELETE_ACTION) ;		 																							
		RETURN SUCCESS ;
	END inRepairDeleteRow ;


	/* amd_on_order diff functions */
	
	FUNCTION getNextLine(gold_order_number in amd_on_order.gold_order_number%type) 
			 return number is
			 maxLine number;
	BEGIN
   		 select max(line) into maxLine
   		 from amd_on_order
   		 where gold_order_number = getNextLine.gold_order_number;
         if maxLine is null then
            maxLine := 0 ;
         end if ;
   		 return maxLine + 1  ;
	END getNextLine;

	FUNCTION getCurrentLine(gold_order_number in amd_on_order.gold_order_number%type,
        order_date in amd_on_order.order_date%type, loc_sid in amd_on_order.loc_sid%type) 
			 return number is
			 curLine number := null ;
	BEGIN
   		 select line into curLine
   		 from amd_on_order
   		 where gold_order_number = getCurrentLine.gold_order_number
         and order_date = getCurrentLine.order_date 
         and loc_sid = getCurrentLine.loc_sid ;
   		 return curLine ;
    EXCEPTION
          WHEN OTHERS THEN				
            errorMsg(sqlFunction => 'select',
                     tableName => 'amd_on_order',
                     pError_Location => 175,
                     key1 => gold_order_number,
                     key2 => TO_CHAR(order_date,'MM/DD/YYYY'),
                     key3 => loc_sid) ;
            RAISE ;
	END getCurrentLine ;
	
	FUNCTION insertOnOrderRow(
							PART_NO             IN VARCHAR2,
  							LOC_SID             IN NUMBER,
							ORDER_DATE          IN DATE,
  							ORDER_QTY           IN NUMBER,
  							GOLD_ORDER_NUMBER   IN VARCHAR2,
							SCHED_RECEIPT_DATE IN  DATE) RETURN NUMBER IS
	
 		-- site_location TMP_A2A_ORDER_INFO_LINE.SITE_LOCATION%TYPE := getSiteLocation(loc_sid) ;
		nextLine amd_on_order.line%type := getNextLine(gold_order_number);
		
		
		PROCEDURE doUpdate IS
		
		BEGIN
			 <<getActionCode>>
			 DECLARE
				  action_code AMD_ON_ORDER.action_code%TYPE ;
				  badInsert EXCEPTION ;
			 BEGIN
			 	  SELECT action_code INTO action_code FROM AMD_ON_ORDER 
				  WHERE gold_order_number = insertOnOrderRow.gold_order_number
				  AND order_date = insertOnOrderRow.order_date 
                  AND loc_sid = insertOnOrderRow.loc_sid ;
				  
				  IF action_code != Amd_Defaults.DELETE_ACTION THEN
				  	 RAISE badInsert ;
				  END IF ;
			 EXCEPTION
			 		  WHEN OTHERS THEN				
						errorMsg(sqlFunction => 'select',
								 tableName => 'amd_on_order',
								 pError_Location => 180,
								 key1 => gold_order_number,
								 key2 => TO_CHAR(order_date,'MM/DD/YYYY')) ;
					  	RAISE ;
			 END getActionCode ;
			 
			 
			 
			 UPDATE AMD_ON_ORDER
				 SET part_no = insertOnOrderRow.part_no,
				 order_qty = insertOnOrderRow.order_qty,
                 sched_receipt_date = insertOnOrderRow.sched_receipt_date,
				 action_code = Amd_Defaults.INSERT_ACTION,
				 last_update_dt = SYSDATE
			 WHERE gold_order_number = insertOnOrderRow.gold_order_number
			 AND order_date = insertOnOrderRow.order_date 
             AND loc_sid = insertOnOrderRow.loc_sid ;
	    EXCEPTION WHEN OTHERS THEN
				errorMsg(sqlFunction => 'update',
						 tableName => 'amd_on_order',
						 pError_Location => 190,
						 key1 => gold_order_number,
						 key2 => TO_CHAR(order_date,'MM/DD/YYYY')) ;
			 
		END doUpdate ;
		
	BEGIN
		 <<insertAmdOnOrder>>
				
		 BEGIN            
			 INSERT INTO AMD_ON_ORDER
			(
				part_no,
				loc_sid,
				order_date,
				order_qty,
				gold_order_number,
				action_code,
				last_update_dt,
				sched_receipt_date,
                line
			)
			VALUES
			(
				part_no,
				loc_sid,
				order_date,
				order_qty,
				gold_order_number,
				Amd_Defaults.INSERT_ACTION,
				SYSDATE,
				sched_receipt_date,
                nextline
			);
			EXCEPTION
					WHEN standard.DUP_VAL_ON_INDEX THEN
						 doUpdate ;
					WHEN OTHERS THEN
						ErrorMsg(SqlFunction => 'insert',
									TableName => 'amd_on_order',
									pError_Location => 200, 
									key1 => gold_order_number,
									key2 => TO_CHAR(order_date,'MM/DD/YYYY HH:MM:SS'));
                                  --  key3 => to_char(line) ) ;
                        raise ;
	     END insertAmdOnOrder ;
		 

        A2a_Pkg.insertTmpA2AOrderInfoLine(gold_order_number,
              loc_sid,
              order_date,
              part_no,
              order_qty,
              sched_receipt_date,
              amd_defaults.INSERT_ACTION,
              nextline) ;
		 
		 RETURN SUCCESS ;
	END insertOnOrderRow ;

	FUNCTION updateOnOrderRow(
							PART_NO             IN VARCHAR2,
  							LOC_SID             IN NUMBER,
							ORDER_DATE          IN DATE,
  							ORDER_QTY           IN NUMBER,
  							GOLD_ORDER_NUMBER   IN VARCHAR2,
							SCHED_RECEIPT_DATE IN  DATE) RETURN NUMBER IS
							
	   -- site_location TMP_A2A_ORDER_INFO_LINE.site_location%TYPE := getSiteLocation(loc_sid) ;
	   
	BEGIN
		<<updateAmdOnOrder>> 
		BEGIN
			UPDATE AMD_ON_ORDER SET
				part_no        		= 	UpdateOnOrderRow.part_no,
	            order_qty 			= 	UpdateOnOrderRow.order_qty,
				action_code         = Amd_Defaults.UPDATE_ACTION,
                sched_receipt_date = updateOnOrderRow.sched_receipt_date,
				last_update_dt      = SYSDATE
			WHERE gold_order_number = UpdateOnOrderRow.gold_order_number
			AND order_date = UpdateOnOrderRow.order_date
            AND loc_sid = UpdateOnOrderRow.loc_sid ;
        
	
			EXCEPTION
					WHEN OTHERS THEN
						RETURN ErrorMsg(pSqlFunction => 'update',
									pTableName => 'amd_on_order',
									pError_Location => 210, 
									pReturn_code => FAILURE,
									pKey_1 => UpdateOnOrderRow.gold_order_number,
									pKey_2 => TO_CHAR(UpdateOnOrderRow.order_date,'MM/DD/YYYY HH:MM:SS'));
		END updateAmdOnOrder;

        A2a_Pkg.insertTmpA2AOrderInfoLine(gold_order_number,
              loc_sid,
              order_date,
              part_no,
              order_qty,
              sched_receipt_date,
              amd_defaults.UPDATE_ACTION,
              getCurrentLine(gold_order_number, order_date, loc_sid)) ;
		
		RETURN SUCCESS ;
	END updateOnOrderRow ;

	FUNCTION deleterow(part_no IN VARCHAR2, loc_sid IN NUMBER, gold_order_number IN VARCHAR2, order_date IN DATE) RETURN NUMBER IS
	BEGIN
		 <<updateAmdOnOrder>>
		 BEGIN
			 UPDATE AMD_ON_ORDER SET
				action_code    = Amd_Defaults.DELETE_ACTION,
				last_update_dt = SYSDATE
			WHERE GOLD_ORDER_NUMBER = DeleteRow.gold_order_number
			AND order_date = DeleteRow.order_date 
            AND loc_sid = DeleteRow.loc_sid ;
	
			EXCEPTION WHEN OTHERS THEN
						RETURN ErrorMsg(pSqlFunction => 'update',
									pTableName => 'amd_on_order',
									pError_Location => 220, 
									pReturn_code => FAILURE,
									pKey_1 => gold_order_number,
									pKey_2 => TO_CHAR(order_date,'MM/DD/YYYY HH:MM:SS'));
		 END updateAmdOnOrder;
		
        A2a_Pkg.insertTmpA2AOrderInfoLine(gold_order_number,
              loc_sid,
              order_date,
              part_no,
              0,
              null,
              amd_defaults.DELETE_ACTION,
              getCurrentLine(gold_order_number, order_date, loc_sid)) ;
				
		
		RETURN SUCCESS ;
	END DeleteRow ;
	
	FUNCTION doOnHandInvsSumDiff(
			 part_no IN VARCHAR2, 
			 spo_location IN VARCHAR2,
			 qty_on_hand IN NUMBER, 
			 action_code IN VARCHAR2) RETURN NUMBER IS

		badActionCode EXCEPTION ;
		
		FUNCTION InsertRow RETURN NUMBER IS
	
		BEGIN
		  	<<insertAmdOnHandInvsSums>> 
			DECLARE
				   PROCEDURE doUpdate IS
				   BEGIN
				   		<<getActionCode>>
						DECLARE
							   action_code AMD_ON_HAND_INVS.action_code%TYPE ;
							   badInsert EXCEPTION ;
						BEGIN
							 SELECT action_code 
							 INTO action_code 
							 FROM AMD_ON_HAND_INVS_SUM 
							 WHERE part_no = doOnHandInvsSumDiff.part_no 
							 AND spo_location = doOnHandInvsSumDiff.spo_location ;
							 
							 IF action_code != Amd_Defaults.DELETE_ACTION THEN
							 	RAISE badInsert ;
							 END IF ;
						EXCEPTION WHEN OTHERS THEN
							errorMsg(SqlFunction => 'select',
										TableName => 'amd_on_hand_invs_sum',
										pError_Location => 230, 
										key1 => doOnHandInvsSumDiff.part_no,
										key2 => doOnHandInvsSumDiff.spo_location);
						
						END getActionCode ;
						UPDATE AMD_ON_HAND_INVS_SUM
						SET qty_on_hand = doOnHandInvsSumDiff.qty_on_hand,
						action_code = Amd_Defaults.INSERT_ACTION,
						last_update_dt = SYSDATE
						WHERE part_no = doOnHandInvsSumDiff.part_no 
						AND spo_location = doOnHandInvsSumDiff.spo_location ;
				   END doUpdate ;
			BEGIN
				 INSERT INTO AMD_ON_HAND_INVS_SUM
				(
					part_no,
					spo_location,
					qty_on_hand,
					action_code,
					last_update_dt
				)
				VALUES
				(
				    part_no,
					spo_location,
					qty_on_hand,
					Amd_Defaults.INSERT_ACTION,
					SYSDATE
				);
				
				EXCEPTION
						WHEN standard.DUP_VAL_ON_INDEX THEN
							 doUpdate ;
						WHEN OTHERS THEN
							RETURN ErrorMsg(pSqlFunction => 'insert',
										pTableName => 'amd_on_hand_invs_sum',
										pError_Location => 240, 
										pReturn_code => FAILURE,
										pKey_1 => part_no,
										pKey_2 => spo_location ) ;
		     END insertAmdOnHandInvs ;
			 				 
			 A2a_Pkg.insertInvInfo(part_no, spo_location,qty_on_hand, Amd_Defaults.INSERT_ACTION) ;
			 
	         RETURN SUCCESS ;
		END InsertRow ;
	
		FUNCTION UpdateRow RETURN NUMBER IS
			-- get the detail for the summarized inv_qty
			result NUMBER ;
			 
		BEGIN
			<<updateAmdOnHandInvs>> 
			BEGIN
				UPDATE AMD_ON_HAND_INVS_SUM SET
		            qty_on_hand 	   = doOnHandInvsSumDiff.qty_on_hand,
					action_code    = Amd_Defaults.UPDATE_ACTION,
					last_update_dt = SYSDATE
				WHERE part_no  = doOnHandInvsSumDiff.part_no
				      AND spo_location  = doOnHandInvsSumDiff.spo_location ;
				EXCEPTION
						WHEN OTHERS THEN
							RETURN ErrorMsg(pSqlFunction => 'update',
										pTableName => 'amd_on_hand_invs_sum',
										pError_Location => 250, 
										pReturn_code => FAILURE,
										pKey_1 => part_no,
										pKey_2 => spo_location) ;
			END updateAmdOnHandInvs ;
			
			
			A2a_Pkg.insertInvInfo(part_no,spo_location,qty_on_hand, Amd_Defaults.UPDATE_ACTION) ;
			RETURN SUCCESS;
	
		END UpdateRow ;
	
		FUNCTION DeleteRow RETURN NUMBER IS
		BEGIN
		     
			<<updateAmdOnHandInvs>> -- logically delete all records for the part_no and loc_sid
			BEGIN
			 UPDATE AMD_ON_HAND_INVS_SUM SET
				action_code    = Amd_Defaults.DELETE_ACTION,
				last_update_dt = SYSDATE
			WHERE    part_no  = doOnHandInvsSumDiff.part_no
				 AND spo_location  = doOnHandInvsSumDiff.spo_location ;
			
			
			EXCEPTION
					WHEN OTHERS THEN
						RETURN ErrorMsg(pSqlFunction => 'update',
									pTableName => 'amd_on_hand_invs_sum',
									pError_Location => 260, 
									pReturn_code => FAILURE,
									pKey_1 => part_no,
									pKey_2 => spo_location) ;
			 END updateAmdOnHandInvs;
			 
			
			A2a_Pkg.insertInvInfo(part_no, spo_location,0, Amd_Defaults.DELETE_ACTION) ;
			RETURN SUCCESS;
			
		END DeleteRow ;
	BEGIN
		 IF action_code = Amd_Defaults.INSERT_ACTION THEN
		 	RETURN insertRow ;
		ELSIF action_code = Amd_Defaults.UPDATE_ACTION THEN
			RETURN updateRow ;
		ELSIF action_code = Amd_Defaults.DELETE_ACTION THEN
			RETURN deleteRow ;
		ELSE
			errorMsg(action_code,'amd_on_hand_invs_sum',330,part_no, spo_location) ;
			RAISE badActionCode ;
			RETURN FAILURE ;
		END IF ;
	END doOnHandInvsSumDiff ;
	
		/* amd_on_hand_invs diff functions */
	FUNCTION InsertRow(
			 		   		 part_no        IN VARCHAR2,
  							 loc_sid        IN NUMBER,
  							 inv_qty        IN NUMBER) RETURN NUMBER IS
		

	BEGIN
	  	<<insertAmdOnHandInvs>> 
		DECLARE
			   PROCEDURE doUpdate IS
			   BEGIN
			   		<<getActionCode>>
					DECLARE
						   action_code AMD_ON_HAND_INVS.action_code%TYPE ;
						   badInsert EXCEPTION ;
					BEGIN
						 SELECT action_code INTO action_code FROM AMD_ON_HAND_INVS WHERE part_no = insertRow.part_no AND loc_sid = insertRow.loc_sid ;
						 IF action_code != Amd_Defaults.DELETE_ACTION THEN
						 	RAISE badInsert ;
						 END IF ;
					EXCEPTION WHEN OTHERS THEN
						errorMsg(SqlFunction => 'select',
									TableName => 'amd_on_hand_invs',
									pError_Location => 270, 
									key1 => insertRow.part_no,
									key2 => insertRow.loc_sid);
					
					END getActionCode ;
					UPDATE AMD_ON_HAND_INVS
					SET inv_qty = insertRow.inv_qty,
					action_code = Amd_Defaults.INSERT_ACTION,
					last_update_dt = SYSDATE
					WHERE part_no = insertRow.part_no AND loc_sid = insertRow.loc_sid ;
			   END doUpdate ;
		BEGIN
			 INSERT INTO AMD_ON_HAND_INVS
			(
				part_no,
				loc_sid,
				inv_qty,
				action_code,
				last_update_dt
			)
			VALUES
			(
			    part_no,
				InsertRow.loc_sid,
				inv_qty,
				Amd_Defaults.INSERT_ACTION,
				SYSDATE
			);
			
			EXCEPTION
					WHEN standard.DUP_VAL_ON_INDEX THEN
						 doUpdate ;
					WHEN OTHERS THEN
						RETURN ErrorMsg(pSqlFunction => 'insert',
									pTableName => 'amd_on_hand_invs',
									pError_Location => 280, 
									pReturn_code => FAILURE,
									pKey_1 => part_no,
									pKey_2 => TO_CHAR(InsertRow.loc_sid) ) ;
	     END insertAmdOnHandInvs ;
		 				 
		 
         RETURN SUCCESS ;
	END InsertRow ;

	FUNCTION UpdateRow(
			 		   		 part_no         IN VARCHAR2,
  							 loc_sid         IN NUMBER,
  							 inv_qty         IN NUMBER) RETURN NUMBER IS                       
		-- get the detail for the summarized inv_qty
		result NUMBER ;
		 
	BEGIN
		<<updateAmdOnHandInvs>> 
		BEGIN
			UPDATE AMD_ON_HAND_INVS SET
	            inv_qty 	   = UpdateRow.inv_qty,
				action_code    = Amd_Defaults.UPDATE_ACTION,
				last_update_dt = SYSDATE
			WHERE part_no  = UpdateRow.part_no
			      AND loc_sid  = UpdateRow.loc_sid ;
			EXCEPTION
					WHEN OTHERS THEN
						RETURN ErrorMsg(pSqlFunction => 'update',
									pTableName => 'amd_on_hand_invs',
									pError_Location => 290, 
									pReturn_code => FAILURE,
									pKey_1 => part_no,
									pKey_2 => TO_CHAR(loc_sid)) ;
		END updateAmdOnHandInvs ;
		
		
		RETURN SUCCESS;

	END UpdateRow ;

	FUNCTION DeleteRow(
			 		   		 part_no         IN VARCHAR2,
  							 loc_sid         IN NUMBER) RETURN NUMBER IS
	BEGIN
	     
		<<updateAmdOnHandInvs>> -- logically delete all records for the part_no and loc_sid
		BEGIN
		 UPDATE AMD_ON_HAND_INVS SET
			action_code    = Amd_Defaults.DELETE_ACTION,
			last_update_dt = SYSDATE
		WHERE    part_no  = DeleteRow.part_no
			 AND loc_sid  = DeleteRow.loc_sid ;
		
		
		EXCEPTION
				WHEN OTHERS THEN
					RETURN ErrorMsg(pSqlFunction => 'update',
								pTableName => 'amd_on_hand_invs',
								pError_Location => 300, 
								pReturn_code => FAILURE,
								pKey_1 => part_no,
								pKey_2 => TO_CHAR(loc_sid)) ;
		 END updateAmdOnHandInvs;
		 
		
		RETURN SUCCESS;
		
	END DeleteRow ;	
	
	/*amd_rsp diff functions */
	
	FUNCTION RspInsertRow(		 
			 				   	 	part_no		IN VARCHAR2,
									loc_sid		IN NUMBER,
									rsp_inv		IN NUMBER,
									rsp_level	   IN NUMBER) RETURN NUMBER IS
									
						PROCEDURE doUpdate IS	
						BEGIN
							 	  <<getActionCode>>
							  	  DECLARE
						   		  		 		   action_code AMD_RSP.action_code%TYPE;
								  				   badInsert EXCEPTION;
								  BEGIN
								  	   			   SELECT action_code INTO action_code 
												   FROM AMD_RSP 
								 				   WHERE part_no = RspInsertRow.part_no 
								 				   AND loc_sid = RspInsertRow.loc_sid ;
															   
														 IF action_code != Amd_Defaults.DELETE_ACTION THEN
								 						 	RAISE badInsert ;
														 END IF ;
							   					
								  EXCEPTION 
								  						 	 WHEN OTHERS THEN
									  	   		  	  		 	  		 errorMsg(SqlFunction => 'select',
										   					 			 TableName => 'amd_rsp',
																		  pError_Location => 310,
																		  key1 => RspInsertRow.part_no,
																		  key2 => RspInsertRow.loc_sid );
															RAISE ;
								  END getActionCode ;
													
								  UPDATE AMD_RSP
								  		 		SET rsp_inv = RspInsertRow.rsp_inv,
									  			rsp_level = RspInsertRow.rsp_level,
									  			action_code = Amd_Defaults.INSERT_ACTION,
									  			last_update_dt = SYSDATE
												WHERE part_no = RspInsertRow.part_no 
												AND loc_sid = RspInsertRow.loc_sid ;
								  EXCEPTION WHEN OTHERS THEN
											  	   		  	  					   errorMsg(sqlFunction => 'update',
																				   tableName => 'amd_rsp',
																				   pError_Location => 320,
																				   key1 => RspInsertRow.part_no,
																				   key2 => RspInsertRow.loc_sid );																			   
							
						END doUpdate ;
	
				 		BEGIN
							 		 <<insertAmdRsp>>
									 BEGIN
			 	 	  				 	  			 INSERT INTO AMD_RSP
					  								 (	  
					  	  							 	  part_no,
					  	 								  loc_sid,
					 	  								  rsp_inv,
					  	  								  rsp_level,
					  	  								  action_code,
					  	  								  last_update_dt
													 )
													 VALUES
					 								 (
				 	  	   							  	   part_no,
					  	   								   RspInsertRow.loc_sid,
					  	   								   rsp_inv,
					  	   								   rsp_level,
					  	   								   Amd_Defaults.INSERT_ACTION,
					  	   								   SYSDATE
													  );
				 
		 		 									 EXCEPTION 
				 		   	 					 	 		   WHEN standard.DUP_VAL_ON_INDEX THEN
												 	  						doUpdate ;
																WHEN OTHERS THEN
													 				 			RETURN ErrorMsg(pSqlFunction => 'insert',
																				pTableName => 'amd_rsp',
																				pError_Location => 330,
																				pReturn_code => FAILURE,
																				pKey_1 => part_no,
																				pkey_2 => TO_CHAR(RspInsertRow.loc_sid)) ;
															
									 END insertAmdRsp;											
									RETURN SUCCESS;
				        END RspInsertRow;
						
		
						FUNCTION RspUpdateRow(
				 		   	   	 							part_no								   IN VARCHAR2,
						   									loc_sid								   IN NUMBER,
						   									rsp_inv								   IN NUMBER,
						  									rsp_level							 IN NUMBER) RETURN NUMBER IS
															 
								result  NUMBER ;
					
						BEGIN
					 			<<updateAmdRsp>>
								BEGIN
									 			UPDATE AMD_RSP SET
													   		   rsp_inv		= RspUpdateRow.rsp_inv,
															   rsp_level  = RspUpdateRow.rsp_level,
															   action_code = Amd_Defaults.UPDATE_ACTION,
															   last_update_dt = SYSDATE
												WHERE		   
															   part_no = RspUpdateRow.part_no
															   AND loc_sid = RspUpdateRow.loc_sid ;
												EXCEPTION
														 	   WHEN OTHERS THEN
															   			   RETURN ErrorMsg(pSqlFunction => 'update',
																		   		  						pTableName => 'amd_rsp',
																										pError_Location => 340,
																										pReturn_code => FAILURE,
																										pKey_1 => RspUpdateRow.part_no,
																										pKey_2 => TO_CHAR(RspUpdateRow.loc_sid));
								END updateAmdRsp ;
								RETURN SUCCESS;
						END RspUpdateRow ;
		
						FUNCTION RspDeleteRow(
				 		   				   	   	  					part_no			IN VARCHAR2,
																	loc_sid			IN NUMBER) RETURN NUMBER IS
						BEGIN
							 		<<updateAmdRsp>> -- logically delete all records for the part_no and loc_sid
									BEGIN
										 UPDATE AMD_RSP SET
										 		action_code = Amd_Defaults.DELETE_ACTION,
												last_update_dt = SYSDATE
										WHERE
											 	part_no = RspDeleteRow.part_no
												AND loc_sid = RspDeleteRow.loc_sid ;
												
								        EXCEPTION 
												  			  			WHEN OTHERS THEN
																			 			RETURN ErrorMsg(pSqlFunction => 'update',
																							   						pTableName => 'amd_rsp',
																													pError_Location => 350,
																													pReturn_code => FAILURE,
																													pKey_1 => part_no,
																													pKey_2 => TO_CHAR(loc_sid)) ;
									END updateAmdRsp ;									
									RETURN SUCCESS ;
					    END RspDeleteRow ;
																											

    
	/* amd_rsp_sum diff functions */
	
	FUNCTION doRspSumDiff (
			 part_no IN VARCHAR2, 
			 rsp_location IN VARCHAR2,
             override_type in varchar2, /* added 10/29/2007 by dse */
			 qty_on_hand IN NUMBER, 
			 rsp_level	 	IN NUMBER,
			 action_code IN VARCHAR2) RETURN NUMBER IS

		badActionCode EXCEPTION ;
        
		
		PROCEDURE InsertRow IS
		
				   PROCEDURE doUpdate IS
							   action_code AMD_RSP_SUM.action_code%TYPE ;
							   badInsert EXCEPTION ;
				   BEGIN
				   		<<getActionCode>>
						BEGIN
							 SELECT action_code 
							 INTO action_code 
							 FROM AMD_RSP_SUM 
							 WHERE part_no = doRspSumDiff.part_no 
							 AND rsp_location = doRspSumDiff.rsp_location
                             and override_type = doRspSumDiff.override_type ;
							 
							 IF action_code != Amd_Defaults.DELETE_ACTION THEN
							 	RAISE badInsert ;
							 END IF ;
						EXCEPTION WHEN OTHERS THEN
							errorMsg(SqlFunction => 'select',
										TableName => 'amd_rsp_sum',
										pError_Location => 360, 
										key1 => doRspSumDiff.part_no,
										key2 => doRspSumDiff.rsp_location,
                                        key3 => doRspSumDiff.override_type);
										RAISE ;						
						END getActionCode ;
						
						UPDATE AMD_RSP_SUM
						SET qty_on_hand = doRspSumDiff.qty_on_hand,
							rsp_level = doRspSumDiff.rsp_level,
							action_code = Amd_Defaults.INSERT_ACTION,
							last_update_dt = SYSDATE
						WHERE part_no = doRspSumDiff.part_no AND rsp_location = doRspSumDiff.rsp_location
                        and override_type = doRspSumDiff.override_type ;
						
				   END doUpdate ;
				   
		BEGIN
		
					  <<insertAmdRspSum>>
					   BEGIN
							 INSERT INTO AMD_RSP_SUM
							(
								part_no,
								rsp_location,
                                override_type,
								qty_on_hand,
								rsp_level,
								action_code,
								last_update_dt
							)
							VALUES
							(
							    part_no,
								rsp_location,
                                override_type,
								qty_on_hand,
								rsp_level,
								Amd_Defaults.INSERT_ACTION,
								SYSDATE
							);
					
					EXCEPTION
									WHEN standard.DUP_VAL_ON_INDEX THEN
										 doUpdate ;
									WHEN OTHERS THEN
										 ErrorMsg(sqlFunction => 'insert',
													tableName => 'amd_rsp_sum',
													pError_Location => 370, 
													key1 => part_no,
													key2 => rsp_location,
                                                    key3 => override_type ) ;
										 RAISE; 
													
					END insertAmdRspSum;
		END InsertRow ;
	
		PROCEDURE UpdateRow IS
			-- get the detail for the summarized inv_qty
			result NUMBER ;
			 
		BEGIN
			<<updateAmdRspSum>> 
			BEGIN
				UPDATE AMD_RSP_SUM SET
		            qty_on_hand 	   = doRspSumDiff.qty_on_hand,
					rsp_level  = doRspSumDiff.rsp_level,
					action_code    = Amd_Defaults.UPDATE_ACTION,
					last_update_dt = SYSDATE
				WHERE part_no  = doRspSumDiff.part_no
				      AND rsp_location  = doRspSumDiff.rsp_location
                      and override_type = doRspSumDiff.override_type ;
				EXCEPTION
						WHEN OTHERS THEN
							 ErrorMsg(SqlFunction => 'update',
										TableName => 'amd_rsp_sum',
										pError_Location => 380, 
									     key1 => part_no,
										key2 => rsp_location,
                                        key3 => override_type) ;
							 RAISE ;
			END updateAmdRspSum ;
					

		END UpdateRow ;
	
		PROCEDURE DeleteRow IS
		BEGIN
		     
			<<updateAmdRspSum>> -- logically delete all records for the part_no and loc_sid
			BEGIN
			 UPDATE AMD_RSP_SUM SET
				action_code    = Amd_Defaults.DELETE_ACTION,
				last_update_dt = SYSDATE
			WHERE    part_no  = doRspSumDiff.part_no
				 AND rsp_location  = doRspSumDiff.rsp_location
                 and override_type = doRspSumDiff.override_type ;
					
			EXCEPTION
					WHEN OTHERS THEN
						   ErrorMsg(SqlFunction => 'update',
									TableName => 'amd_rsp_sum',
									pError_Location => 390, 
									key1 => part_no,
									key2 => rsp_location,
                                    key3 => override_type) ;
							RAISE ;
			 END updateAmdRspSum;
			 
			
			
			
		END DeleteRow ;
	BEGIN
        
                            
		 IF action_code = Amd_Defaults.INSERT_ACTION THEN
		     insertRow ;
		ELSIF action_code = Amd_Defaults.UPDATE_ACTION THEN
		 	  updateRow ;
		ELSIF action_code = Amd_Defaults.DELETE_ACTION THEN
			 deleteRow ;
		ELSE
			 errorMsg(action_code,'rsp_sum',331,part_no, rsp_location) ;
			 RAISE badActionCode ;
		END IF ;
		
        
                                        
		A2a_Pkg.insertInvInfo(part_no, rsp_location,nvl(qty_on_hand,0) , action_code) ;
			
		<<insertTmpA2ALocPartOverride>>
		declare 
				qty number ;
				a2a_action_code tmp_a2a_loc_part_override.action_code%type ;
		begin
			 if action_code = amd_defaults.DELETE_ACTION then
			 	qty := 0 ;
				a2a_action_code := amd_defaults.UPDATE_ACTION ;
			 else
                if override_type = amd_lp_override_consumabl_pkg.ROP_TYPE then 
                    if rsp_level is null or rsp_level = 0 then
                        qty := amd_defaults.ROP ;
                    else
                        qty := rsp_level - 1 ; -- spec page 15 of rev #26 Oct 11 says ROP gets 1 substracted from it
                    end if ;
                else
                    qty := rsp_level ;
                end if ;
        
				a2a_action_code := action_code ;
                
			 end if ;

		end insertTmpA2ALocPartOverride ;

		RETURN SUCCESS;
	 EXCEPTION WHEN OTHERS THEN
			   ErrorMsg(SqlFunction => 'doRspSumDiff(' || action_code || ')',
									TableName => 'amd_rsp_sum / tmp_a2a_loc_part_override',
									pError_Location => 400) ; 
	 		   RETURN FAILURE ;
	END doRspSumDiff ;
	
	
	
	
	
	/* amd_in_transits diff functions */
	FUNCTION InsertRow(
			 		   		to_loc_sid	   	  IN NUMBER,
							quantity		  IN NUMBER,
							document_id		  IN VARCHAR2,
							part_no				 	IN VARCHAR2,
							from_location 			IN VARCHAR2,
							in_transit_date			IN DATE,
							serviceable_flag		IN VARCHAR2) RETURN NUMBER IS 
			result NUMBER;
			
			--site_location TMP_IN_TRANSITS_DIFF.site_location%TYPE := getSiteLocation(to_loc_sid) ;
			
	PROCEDURE doUpdate IS
	BEGIN
	     <<GetActionCode>>
		 DECLARE
		   action_code AMD_IN_TRANSITS.action_code%TYPE ;
		   badInsert EXCEPTION ;
		 BEGIN
			SELECT action_code INTO action_code
			FROM AMD_IN_TRANSITS 
			WHERE document_id = insertRow.document_id ;
			IF action_code != Amd_Defaults.DELETE_ACTION THEN
				RAISE badInsert ;
			END IF ;
		 EXCEPTION WHEN OTHERS THEN
							ErrorMsg(sqlFunction => 'select',
									tableName => 'amd_in_transits',
									pError_Location => 410, 
									key1 => insertRow.document_id) ;
		END getActionCode ;
					
		UPDATE AMD_IN_TRANSITS
		SET to_loc_sid = insertRow.to_loc_sid,
			quantity = insertRow.quantity,
			action_code = Amd_Defaults.INSERT_ACTION,
			last_update_dt = SYSDATE,
			part_no = insertRow.part_no,
			from_location = insertRow.from_location,
			in_transit_date = insertRow.in_transit_date,
			serviceable_flag = insertRow.serviceable_flag 
		WHERE document_id = insertRow.document_id ;
	END doUpdate ;
			  	
	BEGIN 
	  <<insertAmdInTransits>>
	  BEGIN
			INSERT INTO  AMD_IN_TRANSITS
					(
					to_loc_sid,
					quantity,
					action_code,
					last_update_dt,
					document_id,
					part_no,
					from_location,
					in_transit_date,
					serviceable_flag
					)
				VALUES
					(
					to_loc_sid,
					quantity,
					Amd_Defaults.INSERT_ACTION,
					SYSDATE,
					document_id,
					part_no,
					from_location,
					in_transit_date,
					serviceable_flag
					);
			EXCEPTION
			 	WHEN standard.DUP_VAL_ON_INDEX THEN
					 doUpdate ; 
				WHEN OTHERS THEN
					RETURN ErrorMsg(pSqlFunction => 'insert',
					pTableName => 'amd_in_transits',
					pError_Location => 420,
					pReturn_code => FAILURE,
					pKey_1 =>document_id,
					pKey_2 => part_no,
					pKey_3 => to_loc_sid,
					pKey_4 => in_transit_date) ;
		END insertAmdInTransits;
		RETURN SUCCESS;				
	
    END InsertRow ;
			
	FUNCTION UpdateRow(
					   TO_LOC_SID				IN NUMBER,
					   QUANTITY					IN NUMBER,
					   DOCUMENT_ID				IN VARCHAR2,
					   PART_NO					IN VARCHAR2,
					   FROM_LOCATION			IN VARCHAR2,
					   IN_TRANSIT_DATE			IN  DATE,
					   SERVICEABLE_FLAG			IN VARCHAR2) RETURN  NUMBER IS 
	BEGIN
	    <<updateAmdInTransits>>
		BEGIN
		 UPDATE AMD_IN_TRANSITS SET
					quantity		 = UpdateRow.quantity,
					action_code	 = Amd_Defaults.UPDATE_ACTION,
					last_update_dt	 = SYSDATE,
					from_location	 = UpdateRow.from_location,
					in_transit_date = UpdateRow.in_transit_date
		 WHERE document_id = UpdateRow.document_id
		 AND part_no = UpdateRow.part_no
		 AND to_loc_sid = UpdateRow.to_loc_sid;
						
		 EXCEPTION
				WHEN OTHERS THEN
					RETURN ErrorMsg(pSqlFunction =>'update',
							  		 pTableName =>'amd_in_transits',
									 pError_Location => 430,
									 pReturn_code => FAILURE,
									 pKey_1 => document_id,
									 pKey_2 => part_no,
									 pKey_3 => TO_CHAR(to_loc_sid));
		END updateAmdInTransit;
				
		
	    RETURN SUCCESS ;
					
		EXCEPTION WHEN OTHERS THEN
			  	   RETURN ErrorMsg(pSqlFunction => 'updateRow',
				   		  pTableName => 'amd_in_transits',
						  pError_Location => 440,
						  pReturn_code => FAILURE,
						  pKey_1 => part_no);
	END UpdateRow ;
				
	FUNCTION DeleteRow(
						 DOCUMENT_ID	 IN VARCHAR2,
						 PART_NO		 IN 		 VARCHAR2,
						 TO_LOC_SID	 IN NUMBER) RETURN NUMBER IS 
						 
			quantity AMD_IN_TRANSITS.quantity%TYPE;
			from_location AMD_IN_TRANSITS.from_location%TYPE;
			in_transit_date AMD_IN_TRANSITS.in_transit_date%TYPE;
	BEGIN
	  <<updateAmdInTransit>>
	  BEGIN
		UPDATE AMD_IN_TRANSITS SET
					quantity = DeleteRow.quantity,
					from_location = DeleteRow.from_location,
					in_transit_date = DeleteRow.in_transit_date,
					action_code = Amd_Defaults.DELETE_ACTION,
					last_update_dt = SYSDATE
		WHERE DOCUMENT_ID = DeleteRow.DOCUMENT_ID
		AND PART_NO = Deleterow.PART_NO
		AND TO_LOC_SID = DeleteRow.TO_LOC_SID ;
						 
		EXCEPTION
			WHEN OTHERS THEN
					RETURN ErrorMsg(pSqlFunction => 'update',
									pTableName => 'amd_in_transits',
									pError_Location => 450,
									pReturn_code =>FAILURE,
									pKey_1 => document_id,
									pKey_2 => part_no,
									pKey_3 => TO_CHAR(to_loc_sid)) ;														
	  END updateAmdInTransit;
	  <<selectAmdInTransit>>
	  BEGIN
			SELECT quantity, from_location, in_transit_date 
			INTO quantity, from_location, in_transit_date
			FROM AMD_IN_TRANSITS
			WHERE document_id = DeleteRow.document_id
			AND part_no = DeleteRow.part_no
			AND to_loc_sid = DeleteRow.to_loc_sid;
						
	  EXCEPTION
		 WHEN OTHERS THEN 
		      RETURN ErrorMsg(pSqlFunction => 'select',
							pTableName => 'amd_in_transits',
							pError_Location => 460,
							pReturn_code => FAILURE,
							pKey_1 => document_id,
							pKey_2 => part_no,
							pKey_3 => TO_CHAR(to_loc_sid) );
	  END selectAmdInTransit;
	  RETURN SUCCESS;
   END DeleteRow;
   
   FUNCTION InsertRow(
   					  part_no	   	  IN VARCHAR2,
					  site_location	  IN VARCHAR2,
					  quantity			  IN NUMBER,
					  serviceable_flag	 IN VARCHAR2) RETURN NUMBER IS
			
			result NUMBER;
		 FUNCTION doUpdate RETURN NUMBER IS
		    action_code AMD_IN_TRANSITS_SUM.action_code%TYPE;
			badInsert EXCEPTION;
		 BEGIN
		 
		    UPDATE AMD_IN_TRANSITS_SUM
			SET quantity = InsertRow.quantity,
			    action_code = Amd_Defaults.INSERT_ACTION,
				last_update_dt = SYSDATE	
			WHERE  part_no = InsertRow.part_no 
			AND site_location = InsertRow.site_location
			and serviceable_flag = InsertRow.serviceable_flag; 
			RETURN SUCCESS;
		 EXCEPTION  WHEN OTHERS THEN
		 			result := ErrorMsg(pSqlFunction => 'update',
					                   pTableName => 'amd_in_transits_sum',
									   pError_Location => 470,
									   pReturn_code => FAILURE,
									   pKey_1 => part_no,
									   pKey_2 => site_location,
                                       pKey_3 => serviceable_flag) ;
					RAISE;
		 END doUpdate ;
	  BEGIN
	   IF (quantity > 0) THEN
	   BEGIN
	      INSERT INTO AMD_IN_TRANSITS_SUM
		  (
		   part_no,
		   site_location,
		   quantity,
		   serviceable_flag,
		   action_code,
		   last_update_dt
		  )
		  VALUES
		  (
		   InsertRow.part_no,
		   InsertRow.site_location,
		   InsertRow.quantity,
		   InsertRow.serviceable_flag,
		   Amd_Defaults.INSERT_ACTION,
		   SYSDATE
		  ) ;
		  EXCEPTION WHEN standard.DUP_VAL_ON_INDEX THEN
		  				 result := doUpdate ;
					WHEN OTHERS THEN
						 result := ErrorMsg(pSqlFunction => 'insert',
						 		   			  pTableName => 'amd_in_transits_sum',
											  pError_Location => 480,
											  pReturn_code => FAILURE,
											  pKey_1 => part_no,
											  pKey_2 => site_location,
                                              pKey_3 => serviceable_flag,
											  pKey_4 => quantity) ;
					RAISE;
		  END insertAmdIntransitSum;
		-- END IF ;
		 
		A2a_Pkg.insertTmpA2AInTransits(
			  insertRow.part_no,
			  insertRow.site_location,
			  insertRow.quantity,
			  insertRow.serviceable_flag,
			  Amd_Defaults.INSERT_ACTION) ;
		END IF ;
		RETURN SUCCESS;
	END InsertRow;
	
	FUNCTION UpdateRow(
			 		   part_no	   		 IN VARCHAR2,
					   site_location  	   	 IN VARCHAR2,
					   quantity	   		 IN NUMBER,
					   serviceable_flag	 IN VARCHAR2) RETURN NUMBER IS
			 result NUMBER;
	BEGIN
		<<updateAmdInTransitsSum>>
		BEGIN
		  UPDATE AMD_IN_TRANSITS_SUM SET
		  		 quantity = UpdateRow.quantity,
				 action_code = Amd_Defaults.UPDATE_ACTION,
				 last_update_dt = SYSDATE
		  WHERE part_no = UpdateRow.part_no
		  AND site_location = UpdateRow.site_location
          and serviceable_flag = updateRow.serviceable_flag ;
		END updateAmdInTransitsSum ;
		
		A2a_Pkg.insertTmpA2AInTransits(
			  updateRow.part_no,
			  updateRow.site_location,
			  updateRow.quantity,
			  updateRow.serviceable_flag,
			  Amd_Defaults.UPDATE_ACTION) ;
			  RETURN SUCCESS;
			  
	END UpdateRow;
	
	FUNCTION DeleteRow(
			 		   part_no	   	IN VARCHAR2,
					   site_location	IN VARCHAR2,
					   serviceable_flag		  IN VARCHAR2) RETURN NUMBER IS
	
	BEGIN
		<<updateAmdInTransits>>
		BEGIN
			 UPDATE AMD_IN_TRANSITS_SUM SET
			 	action_code = Amd_Defaults.DELETE_ACTION,
				last_update_dt = SYSDATE
			 WHERE part_no = DeleteRow.part_no
			 AND   site_location = DeleteRow.site_location 
             and serviceable_flag = DeleteRow.serviceable_flag; 
		END updateAmdInTransits ;
		
		A2a_Pkg.insertTmpA2AInTransits(
			  deleteRow.part_no,
			  deleteRow.site_location,
			  0,
			  deleteRow.serviceable_flag,
			  Amd_Defaults.DELETE_ACTION) ;
			  RETURN SUCCESS;

	END DeleteRow ;	 
	
	PROCEDURE loadOnHandInvs IS
		nsnDashed      		 VARCHAR2(16) := NULL;
		invQty         		 NUMBER := 0 ;
		cntOnHandInvs 	   	 NUMBER := 0 ;
		cntType1 	  		 NUMBER := 0 ;
		cntType2			 NUMBER := 0 ;
		result 				 NUMBER := 0 ;
		cntType1WholeSale 	 NUMBER := 0 ;
            
        
	    CURSOR onHandCur(pNsn VARCHAR2, pPartNo varchar2) IS
		SELECT
            pPartNo part_no,
			DECODE(n.loc_type,'TMP',asn2.loc_sid,n.loc_sid) loc_sid,
			TRUNC(NVL(r.date_processed,SYSDATE)) inv_date,
            NVL(r.serviceable_balance,0) +  NVL(r.difm_balance,0) inv_qty,
            amd_defaults.INSERT_ACTION action_code,
            sysdate last_update_dt
		FROM
			(SELECT * FROM RAMP
			WHERE current_stock_number = pNsn ) r,
			--AMD_SPARE_PARTS asp,
			AMD_SPARE_NETWORKS n,
			AMD_SPARE_NETWORKS asn2
		WHERE
			n.loc_id = SUBSTR(r.sc(+),8,6)
			--AND asp.nsn = pNsn
			AND n.loc_type IN ('MOB', 'FSL')
			AND n.mob = asn2.loc_id(+)
            and (NVL(r.serviceable_balance,0) +  NVL(r.difm_balance,0)) > 0 ;
            
        -- Type 1 Wholesale from ITEM and TMP1
        CURSOR itemType1Cur IS
        SELECT
            asp.part_no,
            DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
            invQ.inv_date inv_date,
            SUM(invQ.inv_qty) inv_qty,
            amd_defaults.INSERT_ACTION action_code,
            sysdate last_update_dt
        FROM
            (SELECT
                part part_no,
                SUBSTR(i.sc,8,6) loc_id,
                TRUNC(DECODE(i.created_datetime, NULL, i.last_changed_datetime,i.created_datetime)) inv_date,
                '1' inv_type,
                SUM(NVL(i.qty,0)) inv_qty
            FROM
                ITEM i
            WHERE
                i.status_3 != 'I'
                AND i.status_servicable = 'Y'
                AND i.status_new_order = 'N'
                AND i.status_accountable = 'Y'
                AND i.status_active = 'Y'
                AND i.status_mai = 'N'
                AND i.condition != 'B170-ATL'
                AND NOT EXISTS (SELECT 1 FROM ITEM ii
                                WHERE ii.status_avail = 'N' 
                                AND   ii.receipt_order_no IS NULL
                                AND   ii.item_id = i.item_id)
                GROUP BY 
                      part,
                      SUBSTR(i.sc,8,6) ,
                      TRUNC(DECODE(i.created_datetime, NULL, i.last_changed_datetime,i.created_datetime))  
                UNION 
            (SELECT
                part part_no,
                DECODE(i.sc,'C17PCAG','EY1746') loc_id,
                TRUNC(DECODE(i.created_datetime, NULL, i.last_changed_datetime,i.created_datetime)) inv_date,
                '1' inv_type,
                SUM(NVL(i.qty,0)) inv_qty
            FROM
                ITEMSA i
            WHERE
                i.status_3 != 'I'
                AND i.status_servicable = 'Y'
                AND i.status_new_order = 'N'
                AND i.status_accountable = 'Y'
                AND i.status_active = 'Y'
                AND i.status_mai = 'N'
                AND i.condition != 'B170-ATL'
                AND NOT EXISTS (SELECT 1 FROM ITEMSA ii
                                WHERE ii.status_avail = 'N' 
                                AND   ii.receipt_order_no IS NULL
                                AND   ii.item_id = i.item_id)
                GROUP BY 
                      part,
                      DECODE(i.sc,'C17PCAG','EY1746') ,
                      TRUNC(DECODE(i.created_datetime, NULL, i.last_changed_datetime,i.created_datetime)) )) invQ,
            AMD_SPARE_NETWORKS asn,
            AMD_SPARE_PARTS asp,
            AMD_SPARE_NETWORKS asnLink
        WHERE
            asp.part_no = invQ.part_no
            AND asn.loc_id = invQ.loc_id
            AND asp.action_code != 'D'
            AND asn.mob = asnLink.loc_id(+)
        GROUP BY  asp.part_no,
        DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) , invQ.inv_date
        having  SUM(invQ.inv_qty) > 0 ;
        
        onHandCnt number := 0 ;
     
	BEGIN
        writeMsg(pTableName => 'tmp_amd_on_hand_invs', pError_location => 120,
            pKey1 => 'loadOnHandInvs',
            pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	   dbms_output.put_line('loadOnHandInvs started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS')) ;
        Mta_Truncate_Table('TMP_AMD_ON_HAND_INVS','reuse storage');
        Mta_Truncate_Table('TMP_A2A_INV_INFO','reuse storage');
	
        open partCur ;
        fetch partCur bulk collect into partRecs ;
        close partCur ;
        
        if partRecs.first is not null then	
            FOR indx in partRecs.first .. partRecs.last LOOP

                nsnDashed := Amd_Utils.FormatNsn(partRecs(indx).nsn,'GOLD');

                --
                -- For each part, extract inventory data from ramp and item tables.
                --
                open onHandCur(nsnDashed, partRecs(indx).part_no) ;
                fetch onHandCur bulk collect into tmpAmdOnHandInvsRecs ;
                close onHandCur ;
                
                if tmpAmdOnHandInvsRecs.first is not null then
                    FORALL yDex in tmpAmdOnHandInvsRecs.first .. tmpAmdOnHandInvsRecs.last
                        insert into tmp_amd_on_hand_invs
                        values tmpAmdOnHandInvsRecs(yDex) ;
                end if ;
                onHandCnt := onHandCnt + sql%rowcount ;
                                    
            END LOOP f77PartLoop;
            
            writeMsg(pTableName => 'tmp_amd_on_hand_invs', pError_location => 130,
                pKey1 => 'loadOnHandInvs.f77PartLoop',
                pKey2 => 'loaded at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => '# of rows=' || to_char(onHandCnt) ) ;
            commit ;                
        end if ;            
		
	
		open itemType1Cur ;
        fetch itemType1Cur bulk collect into tmpAmdOnHandInvsRecs ;
        close itemType1Cur ;
        
        
        if tmpAmdOnHandInvsRecs.first is not null then
            FORALL indx in tmpAmdOnHandInvsRecs.first .. tmpAmdOnHandInvsRecs.last
                    -- Type 1
                insert into tmp_amd_on_hand_invs
                values tmpAmdOnHandInvsRecs(indx) ;

            writeMsg(pTableName => 'tmp_amd_on_hand_invs', pError_location => 140,
                pKey1 => 'type1WholeSale',
                pKey2 => 'loaded at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => '# of rows=' || to_char(sql%rowcount) ) ;
            commit ;                
        end if ;            
		
		
        writeMsg(pTableName => 'tmp_amd_on_hand_invs', pError_location => 150,
            pKey1 => 'loadOnHandInvs',
            pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
			pkey3 => TO_CHAR(cntOnHandInvs),
			pkey4 => TO_CHAR(cntType1),
			pData => TO_CHAR(cntType1WholeSale)) ;
			
	EXCEPTION
		WHEN OTHERS THEN
			 ErrorMsg(sqlFunction => 'select',
				tableName => 'tmp_amd_on_hand_invs',
				pError_Location => 520) ; 
		RAISE ;
	END loadOnHandInvs ;
	
	PROCEDURE loadInRepair IS
		nsnDashed      		 VARCHAR2(16) := NULL;
		invQty         		 NUMBER := 0 ;
		cntType2 	  		 NUMBER := 0 ;
		cntInRepair   		 NUMBER := 0 ;
		result				 NUMBER := 0 ;
		cntType4WholeSale	 NUMBER :=  0 ;
		cntTypeBASCWholeSale NUMBER := 0 ;
		cntType5WholeSale	 NUMBER := 0 ;
        
        type tmpAmdInRepairTab is table of tmp_amd_in_repair%rowtype ;
        tmpAmdInRepairRecs tmpAmdInRepairTab ;
        
        
	    CURSOR inRepairCur(pNsn VARCHAR2, pPartNo varchar2) IS
		SELECT
            pPartNo,
			DECODE(n.loc_type,'TMP',asn2.loc_sid,n.loc_sid) loc_sid,
			TRUNC(NVL(r.date_processed,SYSDATE)) inv_date,
            NVL(r.unserviceable_balance,0) + NVL(r.suspended_in_stock,0) inv_qty,
            'Retail' order_no,
			TRUNC((r.date_processed) + NVL(avg_repair_cycle_time,0)) repair_need_date,
            amd_defaults.INSERT_ACTION action_code,
            sysdate last_update_dt
		FROM
			(SELECT * FROM RAMP
			WHERE current_stock_number = pNsn ) r,
			--AMD_SPARE_PARTS asp,
			AMD_SPARE_NETWORKS n,
			AMD_SPARE_NETWORKS asn2
		WHERE
			n.loc_id = SUBSTR(r.sc(+),8,6)
			--AND asp.nsn = pNsn
			AND n.loc_type IN ('MOB', 'FSL')
			AND n.mob = asn2.loc_id(+)
            and ( NVL(r.unserviceable_balance,0) + NVL(r.suspended_in_stock,0) ) > 0 ;
            
		-- Type 4 Wholesale
	    CURSOR itemMCur IS
		SELECT
			asp.part_no,
			DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
			TRUNC(i.created_datetime) inv_date,
			SUM(NVL(i.qty,0)) inv_qty,
			i.item_id item_id,
			TRUNC(i.created_datetime + ansi.time_to_repair_off_base) repair_need_date,
            amd_defaults.INSERT_ACTION action_code,
            sysdate last_update_dt
		FROM
			ITEM i,
			AMD_NATIONAL_STOCK_ITEMS ansi,
			AMD_SPARE_NETWORKS asn,
			AMD_SPARE_PARTS asp,
			AMD_SPARE_NETWORKS asnLink
		WHERE
			asp.part_no = i.part
			and i.prime = ansi.prime_part_no
			AND ansi.nsn = asp.nsn
			AND i.status_3 != 'I'
			AND i.status_servicable = 'N'
			AND i.status_new_order = 'N'
			AND i.status_accountable = 'Y'
			AND i.status_active = 'Y'
			AND i.status_mai = 'N'
			AND asn.loc_id = SUBSTR(i.sc,8,6)
			AND asp.action_code != 'D'
			AND asn.mob = asnLink.loc_id(+)
            and i.created_datetime is not null
		GROUP BY
			asp.part_no,
			DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid),
			i.item_id,
			DECODE(i.created_datetime,NULL,TRUNC(i.last_changed_datetime),
			      TRUNC(i.created_datetime)),
			TRUNC(i.created_datetime),
			TRUNC(i.created_datetime + ansi.time_to_repair_off_base)
        having SUM(NVL(i.qty,0)) > 0 ;   
        
        inRepairCnt number := 0 ;
        
		CURSOR itemACur IS
		SELECT
			asp.part_no,
			DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
			TRUNC(i.created_datetime) repair_date,
			SUM(NVL(i.qty,0)) inv_qty,
			i.item_id item_id,
			TRUNC(i.created_datetime + NVL(ansi.time_to_repair_off_base,0)) repair_need_date,
            amd_defaults.INSERT_ACTION action_code,
            sysdate last_update_dt
		FROM
			ITEMSA i,
			AMD_NATIONAL_STOCK_ITEMS ansi,
			AMD_SPARE_NETWORKS asn,
			AMD_SPARE_PARTS asp,
			AMD_SPARE_NETWORKS asnLink
		WHERE
			asp.part_no = i.part
			AND i.prime = ansi.prime_part_no
			AND ansi.nsn = asp.nsn
			AND i.status_3 != 'I'
			AND i.status_servicable = 'N'
			AND i.status_new_order = 'N'
			AND i.status_accountable = 'Y'
			AND i.status_active = 'Y'
			AND i.status_mai = 'N'
            and i.created_datetime is not null
			AND asn.loc_id = 'EY1746'
			AND asp.action_code != 'D'
			AND asn.mob = asnLink.loc_id(+)
		GROUP BY
			asp.part_no,
			DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid),
			i.item_id,
			DECODE(i.created_datetime, NULL, TRUNC(i.last_changed_datetime), TRUNC(i.created_datetime)),
			TRUNC(i.created_datetime),
			TRUNC(i.created_datetime + NVL(ansi.time_to_repair_off_base,0))
        having SUM(NVL(i.qty,0)) > 0 ;
            
        CURSOR itemType5Cur IS	
        SELECT
            asp.part_no,
            DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
            o.created_datetime inv_date,
            NVL(o.qty_due,0) inv_qty,
            o.order_no order_no,
            DECODE(ov.vendor_est_ret_date,NULL, o.ecd, ov.vendor_est_ret_date) repair_need_date,
            amd_defaults.INSERT_ACTION action_code,
            sysdate last_update_dt
        FROM
            ORD1 o,
            ORDV ov,
            AMD_SPARE_NETWORKS asn,
            AMD_SPARE_PARTS asp,
            AMD_SPARE_NETWORKS asnLink
        WHERE
            o.order_no = ov.order_no
            AND asp.part_no  = o.part
            AND o.status IN ('O', 'U')
            AND o.order_type = 'J'
            AND o.accountable_yn = 'Y'
            AND asn.loc_id = SUBSTR(o.sc,8,6)
            AND asp.action_code != 'D'
            AND asn.mob = asnLink.loc_id(+)
            and o.created_datetime is not null 
            and NVL(o.qty_due,0) > 0 ;
                 
            
	BEGIN
        writeMsg(pTableName => 'tmp_amd_in_repair', pError_location => 160,
            pKey1 => 'loadInRepair',
            pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
        Mta_Truncate_Table('TMP_AMD_IN_REPAIR','reuse storage');
        Mta_Truncate_Table('TMP_A2A_REPAIR_INFO','reuse storage');
        Mta_Truncate_Table('tmp_a2a_repair_inv_info','reuse storage');
		
        open partCur ;
        fetch partCur bulk collect into partRecs ;
        close partCur ;
        
        if partRecs.first is not null then
            <<f77PartLoop>> 
            FOR indx in partRecs.first .. partRecs.last LOOP

                nsnDashed := Amd_Utils.FormatNsn(partRecs(indx).nsn,'GOLD');

                --
                -- For each part, extract inventory data from ramp and item tables.
                --
                open inRepairCur(nsnDashed, partRecs(indx).part_no) ;
                fetch inRepairCur bulk collect into tmpAmdInRepairRecs ;
                close  inRepairCur ;
                
                if tmpAmdInRepairRecs.first is not null then
                    FORALL yDex in tmpAmdInRepairRecs.first .. tmpAmdInRepairRecs.last 
                        -- type 2    
                        INSERT INTO TMP_AMD_IN_REPAIR
                        VALUES tmpAmdInRepairRecs(yDex) ;

                end if ;         
                
                inRepairCnt := inRepairCnt + sql%rowcount ;           

            END LOOP f77PartLoop;
            writeMsg(pTableName => 'tmp_amd_on_hand_invs', pError_location => 170,
                pKey1 => 'loadInRepair.f77PartLoop',
                pKey2 => 'loaded at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => '# recs = ' || to_char(inRepairCnt) ) ;
            commit ;                
        end if ;            
		
        open itemMCur ;
        fetch itemMcur bulk collect into tmpAmdInRepairRecs ;
        close itemMcur ;
        
        if tmpAmdInRepairRecs.first is not null then
            FORALL indx in tmpAmdInRepairRecs.first .. tmpAmdInRepairRecs.last 
                -- Type 4
                INSERT INTO TMP_AMD_IN_REPAIR
                VALUES tmpAmdInRepairRecs(indx) ;

            writeMsg(pTableName => 'tmp_amd_on_hand_invs', pError_location => 180,
                pKey1 => 'loadInRepair.type4WholeSale',
                pKey2 => 'loaded at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => '# of recs = ' || to_char(sql%rowcount)) ;                
            commit ;                
        end if ;            

        open itemAcur ;
        fetch itemAcur bulk collect into tmpAmdInRepairRecs ;
        close itemAcur ;
        
        if tmpAmdInRepairRecs.first is not null then
            --typeBASCWholeSale
            FORALL indx in tmpAmdInRepairRecs.first .. tmpAmdInRepairRecs.last 
                INSERT INTO TMP_AMD_IN_REPAIR
                VALUES tmpAmdInRepairRecs(indx) ;
                
            writeMsg(pTableName => 'tmp_amd_on_hand_invs', pError_location => 190,
                pKey1 => 'loadInRepair.typeBASCWholeSale',
                pKey2 => 'loaded at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => '# of recs = ' || to_char(sql%rowcount)) ;
            commit ;                
        end if ;            
		
        open itemType5Cur ;
        fetch itemType5Cur bulk collect into tmpAmdInRepairRecs ;
        close itemType5Cur ;

        if tmpAmdInRepairRecs.first is not null then
            -- itemType5WholeSale       
            FORALL indx in tmpAmdInRepairRecs.first .. tmpAmdInRepairRecs.last
                INSERT INTO TMP_AMD_IN_REPAIR
                VALUES tmpAmdInRepairRecs(indx) ;
                
            writeMsg(pTableName => 'tmp_amd_on_hand_invs', pError_location => 190,
                pKey1 => 'loadInRepair.itemType5WholeSale',
                pKey2 => 'loaded at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                pKey3 => '# of recs = ' || to_char(sql%rowcount)) ;
            commit ;                
        end if ;    
				
        writeMsg(pTableName => 'tmp_amd_in_repair', pError_location => 200,
            pKey1 => 'loadInRepair',
            pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM')) ;
			
	EXCEPTION
		WHEN OTHERS THEN
			 ErrorMsg(sqlFunction => 'select',
				tableName => 'tmp_amd_in_repair',
				pError_Location => 580) ; 
		RAISE ;
	END loadInRepair ;
	
	
	PROCEDURE updateSpoTotalInventory IS
	
			CURSOR partCur IS
				   SELECT DISTINCT
				   		prime_part_no
				   FROM AMD_NATIONAL_STOCK_ITEMS ansi,
				    	AMD_SPARE_PARTS asp
				   WHERE 
				   		 ansi.nsn = asp.nsn
						 AND ansi.action_code != 'D' ;
								
            type spoInvRec is record (
                nsn amd_national_stock_items.nsn%type,
                quantity number
            ) ;
            type spoInvTab is table of spoInvRec ;
            spoInvRecs spoInvTab ;
            					   
			CURSOR  totalSpoInvCur IS
					SELECT ansi.nsn,  SUM(qty) quantity 
               		 FROM
					 	 (SELECT a.part_no,quantity qty, nsn
						 FROM AMD_IN_TRANSITS a,
						 	  		   AMD_SPARE_NETWORKS asn,
						 	  		   AMD_SPARE_PARTS asp
						 WHERE asn.loc_sid = a.to_loc_sid
						 AND a.part_no = asp.part_no
						 AND asp.action_code IN ('A', 'C')
						 AND a.action_code != 'D'
						 AND asn.action_code != 'D'
						 AND asn.spo_location IS NOT NULL
						 UNION ALL
						 SELECT a.part_no,order_qty qty, asp.nsn
						 FROM AMD_ON_ORDER a, 
						 	  		   AMD_SPARE_NETWORKS asn,
			    					   AMD_SPARE_PARTS asp
				 		WHERE asn.loc_sid = a.loc_sid 
						AND a.part_no = asp.part_no
						AND asp.action_code IN ('A', 'C')
						AND a.action_code != 'D'
						AND asn.action_code != 'D'
						AND asn.spo_location IS NOT NULL				 
						UNION ALL
						SELECT a.part_no,inv_qty qty, asp.nsn
						FROM AMD_ON_HAND_INVS a, 
							 		 AMD_SPARE_NETWORKS asn,
									 AMD_SPARE_PARTS asp
						WHERE asn.loc_sid = a.loc_sid 
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
						WHERE asn.loc_sid = a.loc_sid 
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
						WHERE asn.loc_sid = a.loc_sid
						AND a.part_no = asp.part_no
						AND asp.action_code IN ('A','C')
						AND a.action_code != 'D'
						AND asn.action_code != 'D'
						AND asn.spo_location IS NOT NULL) qtyQ,
						AMD_NATIONAL_STOCK_ITEMS  ansi
						WHERE  ansi.nsn = qtyQ.nsn
						GROUP BY ansi.nsn ;
						
	BEGIN
		 		
		 dbms_output.put_line('updateSpoTotalInventory started at ' || TO_CHAR(SYSDATE,  'MM/DD/YYYY HH:MM:SS') ) ;	
		 
		 BEGIN
		 	  	UPDATE AMD_NATIONAL_STOCK_ITEMS
				SET spo_total_inventory = NULL
				WHERE spo_total_inventory IS NOT NULL ;
		END ;
				
		 <<primePartLoop>>
		-- FOR rec IN partCur LOOP
		 	 open totalSpoInvCur ;
             fetch totalSpoInvCur bulk collect into spoInvRecs ;
             close totalSpoInvCur ;
             
             if spoInvRecs.first is not null then
                 FOR indx in spoInvRecs.first .. spoInvRecs.last LOOP
                -- dbms_output.put_line('part_no=' || rampRecs(yDex).prime_part_no ); --' qty = ' || rampRecs(yDex).quantity) ;
                     BEGIN
                          UPDATE AMD_NATIONAL_STOCK_ITEMS
                          SET spo_total_inventory = spoInvRecs(indx).quantity
                          WHERE nsn  = spoInvRecs(indx).nsn
                          AND action_code != 'D' ;				  
                     END;
                 END LOOP totalSpoInvLoop ; 
            end if ;                 
		--END LOOP partCur ;
		 dbms_output.put_line('updateSpoTotalInventory ended at ' || TO_CHAR(SYSDATE,  'MM/DD/YYYY HH:MM:SS') ) ;	
	
	END updateSpoTotalInventory ; 
	
	-- added 9/2/2005
	FUNCTION getParamDate(rawData IN AMD_PARAM_CHANGES.PARAM_VALUE%TYPE, typeOfDate IN orderdates) RETURN DATE IS
			 paramDate DATE ;
			 params Amd_Utils.arrayOfWords := Amd_Utils.arrayOfWords() ;
			 cnt NUMBER ;
	BEGIN
		 params := Amd_Utils.splitString(rawData) ;
		 cnt := params.COUNT() ;
		 IF params.COUNT() > 0 THEN
		 	paramDate := TO_DATE(params(typeOfDate),'MM/DD/YYYY') ;
		 END IF ;		
		 RETURN paramDate ;
	END getParamDate ; 
	
	PROCEDURE setParamDate(voucher IN VARCHAR2, theDate IN DATE, typeOfDate IN orderdates) IS
			  params Amd_Utils.arrayOfwords ; 
	BEGIN
		 params := Amd_Utils.splitString(Amd_Defaults.getParamValue(ON_ORDER_DATE || voucher)) ;
		 IF params.COUNT() > 0 THEN
		 	params(typeOfDate) := theDate ;
		 END IF ;
		 Amd_Defaults.setParamValue(LOWER(ON_ORDER_DATE || voucher), Amd_Utils.joinString(params) ) ;
	EXCEPTION
			 WHEN standard.NO_DATA_FOUND THEN
			 	  Amd_Defaults.setParamValue(LOWER('on_order_date' || voucher), NULL) ;
	END setParamDate ;

	FUNCTION getOrderCreateDate(voucher IN VARCHAR2) RETURN DATE IS
	BEGIN
		 RETURN getParamDate(Amd_Defaults.GetParamValue(LOWER(ON_ORDER_DATE || voucher)), ORDER_CREATE_DATE) ;
	EXCEPTION
		WHEN standard.NO_DATA_FOUND THEN
			 RETURN NULL ;
	END getOrderCreateDate ;
	
	
	PROCEDURE setOrderCreateDate(voucher IN VARCHAR2, orderCreateDate IN DATE) IS
			  theDate VARCHAR2(10) := TO_CHAR(orderCreateDate,'MM/DD/YYYY') ;
			  pos NUMBER ;
			  rawData AMD_PARAM_CHANGES.PARAM_VALUE%TYPE ;
			  params Amd_Utils.arrayOfWords ;
	BEGIN
		 setParamDate(voucher, orderCreateDate, ORDER_CREATE_DATE) ;
	END setOrderCreateDate ;
		 
	FUNCTION getScdeduledReceiptDateFrom(voucher IN VARCHAR2) RETURN DATE IS
	BEGIN
		 RETURN getParamDate(Amd_Defaults.GetParamValue(LOWER(ON_ORDER_DATE || voucher)), SCHEDULED_RECEIPT_DATE_FROM) ;
	EXCEPTION
		WHEN standard.NO_DATA_FOUND THEN
			 RETURN NULL ;
	END getScdeduledReceiptDateFrom ;
	
	FUNCTION getScdeduledReceiptDateTo(voucher IN VARCHAR2) RETURN DATE IS
	BEGIN
		 RETURN getParamDate(Amd_Defaults.GetParamValue(LOWER(ON_ORDER_DATE || voucher)), SCHEDULED_RECEIPT_DATE_TO) ;
	EXCEPTION
		WHEN standard.NO_DATA_FOUND THEN
			 RETURN NULL ;
	END getScdeduledReceiptDateTo ;

	PROCEDURE setScheduledReceiptDate(voucher IN VARCHAR2, fromDate IN DATE, toDate DATE) IS
			  params Amd_Utils.arrayOfwords ; 
	BEGIN
		 IF fromDate IS NOT NULL AND toDate IS NOT NULL THEN
			 IF fromDate > toDate THEN
			 	RAISE sched_receipt_date_exception ;
			 END IF ;
		 END IF ;
		 params := Amd_Utils.splitString(Amd_Defaults.getParamValue(ON_ORDER_DATE || voucher)) ;
		 IF params.COUNT() = 0 THEN
		 	params.extend(SCHEDULED_RECEIPT_DATE_TO) ;
		 ELSIF params.COUNT() = 1 THEN
		 	params.extend(2) ;
		 END IF ;
		 params(SCHEDULED_RECEIPT_DATE_FROM) := fromDate ;
		 params(SCHEDULED_RECEIPT_DATE_TO) := toDate ;
		 Amd_Defaults.setParamValue(LOWER(ON_ORDER_DATE || voucher), Amd_Utils.joinString(params) ) ;
	END setScheduledReceiptDate ;
	
	PROCEDURE setScheduledReceiptDateCalDays(voucher IN VARCHAR2, days IN NUMBER) IS 
			  params Amd_Utils.arrayOfwords ; 
	BEGIN
		 params := Amd_Utils.splitString(Amd_Defaults.getParamValue(ON_ORDER_DATE || voucher)) ;
		 IF params.COUNT() > 0 THEN
		 	params(NUMBER_OF_CALANDER_DAYS) := days ;
		 END IF ;
		 Amd_Defaults.setParamValue(LOWER(ON_ORDER_DATE || voucher), Amd_Utils.joinString(params,',') ) ;
	END setScheduledReceiptDateCalDays ;
	
   	FUNCTION getScheduledReceiptDateCalDays(voucher IN VARCHAR2) RETURN NUMBER IS
			 calDays NUMBER := NULL ;
			 params Amd_Utils.arrayOfWords ;
	BEGIN
		 params := Amd_Utils.splitString(Amd_Defaults.GetParamValue(ON_ORDER_DATE || voucher)) ;
		 IF params.COUNT() > 0 THEN
		 	calDays := TO_NUMBER(params(NUMBER_OF_CALANDER_DAYS)) ;
		 END IF ;		
		 RETURN calDays ;
	EXCEPTION WHEN standard.NO_DATA_FOUND THEN
		RETURN NULL ;
	END getScheduledReceiptDateCalDays ;

	PROCEDURE getOnOrderParams(voucher IN VARCHAR2, 
		  orderCreateDate 		  OUT DATE, 
		  schedReceiptDateFrom 	  OUT DATE, 
		  schedReceiptDateTo 	  OUT DATE, 
		  schedReceiptCalDays 	  OUT NUMBER) IS
		 params Amd_Utils.arrayOfWords ;
	BEGIN
		 params := Amd_Utils.splitString(Amd_Defaults.GetParamValue(LOWER(ON_ORDER_DATE || voucher))) ;
		 IF params.COUNT() >= NUMBER_OF_CALANDER_DAYS THEN
		    IF params(NUMBER_OF_CALANDER_DAYS) IS NOT NULL THEN
		 	   schedReceiptCalDays := TO_NUMBER(params(NUMBER_OF_CALANDER_DAYS)) ;
			ELSE
			   schedReceiptCalDays := NULL ;
			END IF ;
		 ELSE
		 	schedReceiptCalDays := NULL ;
		 END IF ;		
		 IF params.COUNT() >= SCHEDULED_RECEIPT_DATE_TO THEN
		    IF params(SCHEDULED_RECEIPT_DATE_FROM) IS NOT NULL AND LENGTH(params(SCHEDULED_RECEIPT_DATE_FROM)) >= 8 THEN
			   schedReceiptDateFrom := TO_DATE(params(SCHEDULED_RECEIPT_DATE_FROM),'MM/DD/YYYY') ;
			ELSE
				schedReceiptDateFrom := NULL ;
			END IF ;
			IF params(SCHEDULED_RECEIPT_DATE_TO) IS NOT NULL AND LENGTH(params(SCHEDULED_RECEIPT_DATE_TO)) >= 8 THEN
		 	   schedReceiptDateTo   := TO_DATE(params(SCHEDULED_RECEIPT_DATE_TO),'MM/DD/YYYY') ;
			ELSE
				schedReceiptDateTo := NULL ;
			END IF ;
			
		 ELSE
		 	schedReceiptDateFrom := NULL ;
		 	schedReceiptDateTo   := NULL ;
		 END IF ;		
		 IF params.COUNT() >= ORDER_CREATE_DATE THEN
		    IF params(ORDER_CREATE_DATE) IS NOT NULL AND LENGTH(params(ORDER_CREATE_DATE)) >= 8 THEN
		 	   orderCreateDate := TO_DATE(params(ORDER_CREATE_DATE),'MM/DD/YYYY') ;
			ELSE
		 	   orderCreateDate := NULL ;
			END IF ;
		 ELSE
		 	orderCreateDate := NULL ;
		 END IF ;		
	END getOnOrderParams ;
	
	PROCEDURE setOnOrderParams(voucher IN VARCHAR2, 
		  orderCreateDate 		   IN DATE, 
		  schedReceiptDateFrom 	   IN DATE, 
		  schedReceiptDateTo 	   IN DATE, 
		  schedReceiptCalDays 	   IN NUMBER) IS
		params Amd_Utils.arrayOfWords := Amd_Utils.arrayOfWords() ; 
	BEGIN
		 params.extend(4) ;
		 params(ORDER_CREATE_DATE) := TO_CHAR(orderCreateDate,'MM/DD/YYYY') ;
		 IF schedReceiptDateFrom IS NOT NULL AND schedReceiptDateTo IS NOT NULL THEN
		 	IF schedReceiptDateFrom > schedReceiptDateTo THEN
			   RAISE sched_receipt_date_exception ;
			END IF ;
			params(SCHEDULED_RECEIPT_DATE_FROM) := TO_CHAR(schedReceiptDateFrom,'MM/DD/YYYY') ;
			params(SCHEDULED_RECEIPT_DATE_TO) := TO_CHAR(schedReceiptDateTo,'MM/DD/YYYY') ; 
		    params(NUMBER_OF_CALANDER_DAYS) := NULL ;
		ELSE
			IF schedReceiptCalDays IS NOT NULL THEN
			   params(SCHEDULED_RECEIPT_DATE_FROM) := NULL ;
			   params(SCHEDULED_RECEIPT_DATE_TO) := NULL ; 
		 	   params(NUMBER_OF_CALANDER_DAYS) := schedReceiptCalDays ; 			
			ELSE
			   params(SCHEDULED_RECEIPT_DATE_FROM) := NULL ;
			   params(SCHEDULED_RECEIPT_DATE_TO) := NULL ;
			   params(NUMBER_OF_CALANDER_DAYS) := NULL ;
			END IF ;
		END IF ;
		IF NOT Amd_Defaults.isParamKey(LOWER(ON_ORDER_DATE || voucher)) THEN
		   Amd_Defaults.addParamKey(LOWER(ON_ORDER_DATE || voucher),'The order create date and scheduled receipt date for the ' || LOWER(voucher) || ' voucher') ; 
		END IF ;
		Amd_Defaults.setParamValue(LOWER(ON_ORDER_DATE || voucher), Amd_Utils.joinString(params) ) ;	
	END setOnOrderParams ;   
   
	FUNCTION isVoucher(voucher IN VARCHAR2) RETURN BOOLEAN IS
			theVoucher VARCHAR2(2) ; 
	BEGIN
         SELECT DISTINCT SUBSTR(gold_order_number,1,2) INTO theVoucher FROM AMD_ON_ORDER
         WHERE LOWER(SUBSTR(gold_order_number,1,2)) = LOWER(isVoucher.voucher) ;
         RETURN TRUE ;
    EXCEPTION WHEN standard.NO_DATA_FOUND THEN
         RETURN FALSE ;         
    END isVoucher ;  

    PROCEDURE clearOnOrderParams IS
        CURSOR onOrderParams IS
            SELECT * FROM AMD_PARAM_CHANGES outer WHERE param_key LIKE ON_ORDER_DATE || '%'  
            AND effective_date = (
                    SELECT MAX(effective_date)
                    FROM AMD_PARAM_CHANGES
                    WHERE param_key = outer.param_key) ;
    BEGIN
         FOR rec IN onOrderParams LOOP
              INSERT INTO AMD_PARAM_CHANGES
             (param_key, param_value, effective_date, user_id)
             VALUES (rec.param_key, ',,,', SYSDATE, USER) ;
         END LOOP ;
    END clearOnOrderParams ;
    
    FUNCTION numberOfOnOrderParams RETURN NUMBER IS
             cnt NUMBER ;
    BEGIN
        SELECT COUNT(*) INTO cnt FROM AMD_PARAM_CHANGES outer WHERE param_key LIKE ON_ORDER_DATE || '%'  
        AND effective_date = (
                SELECT MAX(effective_date)
                FROM AMD_PARAM_CHANGES
                WHERE param_key = outer.param_key) ;
        RETURN cnt ;
    EXCEPTION WHEN standard.NO_DATA_FOUND THEN
        RETURN 0 ;
    END numberOfOnOrderParams ;
        
    FUNCTION getVouchers RETURN ref_cursor IS
         vouchers_cursor ref_cursor ;
    BEGIN
         OPEN vouchers_cursor FOR 
         SELECT DISTINCT SUBSTR(gold_order_number,1,2) voucher 
         FROM AMD_ON_ORDER 
         ORDER BY voucher ;
         RETURN vouchers_cursor ;               
    END getVouchers ;

      
    PROCEDURE version IS
    BEGIN
         writeMsg(pTableName => 'amd_inventory', 
                 pError_location => 210, pKey1 => 'amd_inventory', pKey2 => '$Revision:   1.100  $') ;
    END version ;
    
    function getVersion return varchar2 is
    begin
        return '$Revision:   1.100  $' ;
    end getVersion ;
    
    procedure setDebug(switch in varchar2) is
    begin
        debug := upper(switch) in ('Y','T','YES','TRUE') ;
        if debug then
            dbms_output.ENABLE(100000) ;
        else
            dbms_output.DISABLE ;
        end if ;                    
    end setDebug ;
    
                                                                              
END Amd_Inventory;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_INVENTORY;

CREATE PUBLIC SYNONYM AMD_INVENTORY FOR AMD_OWNER.AMD_INVENTORY;


GRANT EXECUTE ON AMD_OWNER.AMD_INVENTORY TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_INVENTORY TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_INVENTORY TO BSRM_LOADER;


