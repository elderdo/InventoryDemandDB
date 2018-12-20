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
    -- 04/05/04 TP       Removed 'TC' as a valid order prefix for including a
    --                 cap order in inventory.
    -- 05/13/04 TP       Changed LoadGoldInventory() in On Hand and in Repair .
    -- 06/16/04 TP       Added conditions in the OnHand and Repair types.
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
                              --LINE                IN NUMBER,
                            ORDER_DATE            IN DATE,
                              ORDER_QTY           IN NUMBER,
                              GOLD_ORDER_NUMBER   IN VARCHAR2,
                            SCHED_RECEIPT_DATE IN  DATE) RETURN NUMBER ;

    FUNCTION UpdateOnOrderRow(
                            PART_NO             IN VARCHAR2,
                              LOC_SID             IN NUMBER,
                              --LINE                IN NUMBER,
                            ORDER_DATE          IN DATE,
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
             part_no     IN VARCHAR2,
             rsp_location  VARCHAR2,
             override_type in varchar2, /* added 10/29/2007 by dse */
             qty_on_hand        IN NUMBER,
             rsp_level               IN NUMBER,
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
                           PART_NO    IN VARCHAR2,
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
                       REPAIR_NEED_DATE     IN DATE) RETURN NUMBER ;
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
                         ORDER_NO           IN VARCHAR2) RETURN NUMBER ;


    /* amd_in_transits diff functions */
    FUNCTION InsertRow(
                        TO_LOC_SID              IN NUMBER,
                       QUANTITY                IN NUMBER,
                       DOCUMENT_ID            IN VARCHAR2,
                       PART_NO                IN VARCHAR2,
                       FROM_LOCATION        IN VARCHAR2,
                       IN_TRANSIT_DATE        IN DATE,
                       SERVICEABLE_FLAG        IN VARCHAR2) RETURN NUMBER ;
    FUNCTION UpdateRow(
                        TO_LOC_SID            IN NUMBER,
                       QUANTITY                IN NUMBER,
                       DOCUMENT_ID            IN VARCHAR2,
                       PART_NO                IN VARCHAR2,
                       FROM_LOCATION        IN VARCHAR2,
                       IN_TRANSIT_DATE        IN DATE,
                       SERVICEABLE_FLAG        IN VARCHAR2) RETURN NUMBER ;
    FUNCTION DeleteRow(
                        DOCUMENT_ID            IN VARCHAR2,
                       PART_NO                IN VARCHAR2,
                       TO_LOC_SID            IN NUMBER) RETURN NUMBER ;


    /* amd_in_transits_sum diff function */
    FUNCTION InsertRow(
                        PART_NO                   IN VARCHAR2,
                       SITE_LOCATION            IN VARCHAR2,
                       QUANTITY                IN NUMBER,
                       SERVICEABLE_FLAG        IN VARCHAR2) RETURN NUMBER ;

    FUNCTION UpdateRow(
                        PART_NO                IN VARCHAR2,
                       SITE_LOCATION            IN VARCHAR2,
                       QUANTITY                IN NUMBER,
                       SERVICEABLE_FLAG        IN VARCHAR2) RETURN NUMBER ;

    FUNCTION DeleteRow(
                        PART_NO                IN VARCHAR2,
                       SITE_LOCATION            IN VARCHAR2,
                       SERVICEABLE_FLAG        IN VARCHAR2) RETURN NUMBER ;


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
              orderCreateDate           OUT DATE,
              schedReceiptDateFrom       OUT DATE,
              schedReceiptDateTo       OUT DATE,
              schedReceiptCalDays       OUT NUMBER) ;
    PROCEDURE setOnOrderParams(voucher IN VARCHAR2,
              orderCreateDate            IN DATE,
              schedReceiptDateFrom        IN DATE,
              schedReceiptDateTo        IN DATE,
              schedReceiptCalDays        IN NUMBER) ;
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


DROP PUBLIC SYNONYM AMD_INVENTORY;

CREATE PUBLIC SYNONYM AMD_INVENTORY FOR AMD_OWNER.AMD_INVENTORY;


GRANT EXECUTE ON AMD_OWNER.AMD_INVENTORY TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_INVENTORY TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_INVENTORY TO BSRM_LOADER;
