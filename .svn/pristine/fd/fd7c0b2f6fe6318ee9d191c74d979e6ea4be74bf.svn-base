CREATE OR REPLACE PACKAGE AMD_OWNER.Amd_Spare_Parts_Pkg
AS
   /*
      $Author:   zf297a  $
    $Revision:   1.45  $
        $Date:   17 Jun 2016
    $Workfile:   AMD_SPARE_PARTS_PKG.pks  $

     Rev 1.45 17 Jun 2016 reformatted code
    
     Rev 1.44 26 Jul 2013 removed a2a dependencies

     Rev 1.43   24 Oct 2008 10:43:50   zf297a
  Made mDebug private by putting it in the package body.
  Added interfaces setDebug and getDebugYorN.

     Rev 1.42   23 Oct 2008 21:28:50   zf297a
  Added out parameter is_spo_part to the interface of updateFlags.

     Rev 1.41   22 Sep 2008 15:47:14   zf297a
  Made updateFlags public

     Rev 1.40   27 Mar 2008 12:08:14   zf297a
  Made constant unable_to_get_prime_part unique for Oracle 10g

     Rev 1.39   20 Nov 2007 10:24:46   zf297a
  Added wesm_indicator as the last argument for insertRow and updateRow.  Made function getQtyDue public so it can be used in an SQL statement - in particular so it can be used in cursor curDue of procedure loadCurrentBackorder.

     Rev 1.38   14 Feb 2007 13:57:08   zf297a
  Added amcDemand and amcDemandCleaned to the interface of insertRow and updateRow.

     Rev 1.37   Jun 09 2006 12:29:34   zf297a
  added interface version

     Rev 1.36   Mar 08 2006 09:26:18   zf297a
  Added mtbdr_computed.

     Rev 1.35   Jun 16 2005 15:53:18   c970183
  Changed errorMsg to be the same as the errorMsg in the a2a_pkg: this uses a unique pError_location number to pinpoint the block of code that has the exception.  Also, added some user defined exception instead of return codes.

     Rev 1.34   Jun 03 2005 12:50:10   c970183
  Added the procedure loadCurrentBackOrder for amd_national_stock_items.current_backorder

     Rev 1.33   May 16 2005 11:59:52   c970183
  Moved time_to_repair_off_base and cost_to_repair_off_base from amd_part_locs to amd_national_stock_items.  Created "changed indicators" for both of these fields.

     Rev 1.32   May 02 2005 12:53:12   c970183
  Added error code for 'deleteRow'

     Rev 1.30   Apr 22 2005 08:09:26   c970183
  added addtional debug code

     Rev 1.29   Apr 18 2005 10:54:44   c970183
  Added new parameters to insertRow and updateRow.  Leveraged the old routines by just defining the new parameters as global member variables and invoking the old insertRow and updateRow methods.   Change the insert and update of amd_national_stock_items to use the new global member variables.

     Rev 1.28   Mar 24 2005 14:37:06   c970183
  added ver 1.40 - 1.45 changes.  Plus fixed a2a trans

     Rev 1.27   Mar 24 2005 09:36:22   c970183
  Added qpei_weighted, order_lead_time_cleaned, unit_cost_cleaned, planner_code_cleaned, smr_code_cleaned, cost_to_repair_off_base_cleand to InsertRow and UpdateRow

     Rev 1.23   30 Aug 2002 11:46:26   c970183
  Fixed updating of the prime_part_no.   When a prime_part_no and its equivalent parts got deleted and reinserted,  the logic caused the amd_national_stock_items.prime_part_no column to get set to a null value.  To accomodate this condition code has been added to the equivalent part section that checks for an existing amd_nsi_parts.part_no with its prime_ind set to 'Y'.  If found it makes sure that the same part_no appears in amd_national_stock_items.prime_part_no.

     Rev 1.22   07 Aug 2002 08:58:24   c970183
  Set unassignment_date to sysdate for deleted parts.

     Rev 1.21   11 Apr 2002 09:26:18   c970183
  Put SCCS keywords back into the file

     Rev 1.20   08 Apr 2002 12:14:48   c970183
  Added acquisition_advice_code

     Rev 1.19   05 Apr 2002 09:30:28   c970183
  Added return code: unable to chg nsn_type and constants for amd_nsns.nsn_type

     Rev 1.18   04 Apr 2002 13:25:28   c970183
  Added mic_code_lowest to the InsertRow and UpdateRow routines.

     Rev 1.17   28 Mar 2002 12:41:58   c970183
  added comment and log regarding sleep/insert exception handler

  SCCSID: %M% %I% Modified: %G%  %U%
     10/02/01 Douglas Elder   Initial implementation
  03/21/02 Douglas Elder Added Sleep(5) to insure
         a unique key for amd_nsi_parts
  03/28/02 Douglas Elder Added insertagain_err code - since the sleep
               is now only executed for insert exceptions
  04/04/02 Douglas Elder Added Mic Code to insert and update
  04/05/02 Douglas Elder    Added return code: unable to chg nsn_type
               and constants for amd_nsns.nsn_type
    */
   -- return values from InsertRow, UpdateRow, and DeleteRow

   SUCCESS                          CONSTANT NUMBER := 0;
   FAILURE                          CONSTANT NUMBER := 4;

   -- amd_nsns.nsn_type values

   TEMPORARY_NSN                    CONSTANT VARCHAR2 (1) := 'T';
   CURRENT_NSN                      CONSTANT VARCHAR2 (1) := 'C';

   /* NOTE: Most of these return values should not occur, but
    if they do occur there is probably a coding error that
    needs to be corrected.  The return value should help
    to isolate the section of code that caused the problem.
    The return value and associated data are recorded in the
    amd_load_details table
    */

   PART_NOT_PRIME                   CONSTANT NUMBER := 8;
   UNABLE_TO_PRIME_INFO             CONSTANT NUMBER := 12;
   UNABLE_TO_INSERT_SPARE_PART      CONSTANT NUMBER := 16;
   UNABLE_TO_INSERT_AMD_NSNS        CONSTANT NUMBER := 20;
   UNABLE_TO_INSERT_AMD_NSI_PARTS   CONSTANT NUMBER := 24;
   CANNOT_UPDT_NSN_NAT_STCK_ITEMS   CONSTANT NUMBER := 28;
   cannotGetNsiSid                           EXCEPTION;
   CANNOT_UPDATE_SPARE_PARTS_NSN    CONSTANT NUMBER := 36;
   CANNOT_UPADATE_NAT_STCK_ITEMS    CONSTANT NUMBER := 40;
   CANNOT_UPDATE_AMD_NSNS           CONSTANT NUMBER := 44;
   CANNOT_GET_UNIT_COST_CLEANED     CONSTANT NUMBER := 48;
   CHK_NSN_AND_PRIME_ERR            CONSTANT NUMBER := 52;
   UNABLE_TO_DELT_PART_NOT_FOUND    CONSTANT NUMBER := 56;
   UNABLE_TO_DLET_NAT_STK_ITEM      CONSTANT NUMBER := 60;
   UNABLE_TO_RESET_NAT_STK_ITEM     CONSTANT NUMBER := 64;
   INSERT_PRIMEPART_ERR             CONSTANT NUMBER := 68;
   INS_PRIME_PART_ERR               CONSTANT NUMBER := 72;
   UPDATE_NATSTK_ERR                CONSTANT NUMBER := 76;
   INS_EQUIV_PART_ERR               CONSTANT NUMBER := 80;
   INS_AMD_NSI_PARTS_ERR            CONSTANT NUMBER := 84;
   UPD_AMD_SPARE_PARTS_NSN          CONSTANT NUMBER := 88;
   LOGICAL_INSERT_FAILED            CONSTANT NUMBER := 92;
   partAlreadyExists                         EXCEPTION;
   INSERTROW_FAILED                 CONSTANT NUMBER := 100;
   UNASSIGN_PRIME_PART_ERR          CONSTANT NUMBER := 104;
   UNASSIGN_OLD_PRIME_PART_ERR      CONSTANT NUMBER := 108;
   UPD_NSI_PARTS_ERR                CONSTANT NUMBER := 116;
   ASSIGN_NEW_PRIME_PART_ERR        CONSTANT NUMBER := 120;
   UPDATE_ERR                       CONSTANT NUMBER := 124;
   UNABLE_TO_GET_PRIME_PART         CONSTANT NUMBER := 128;
   UPDT_PRIME_PART_ERR              CONSTANT NUMBER := 132;
   MAKE_NEW_PRIME_PART_ERR          CONSTANT NUMBER := 136;
   UNASSIGN_EQUIV_PART_ERR          CONSTANT NUMBER := 140;
   UPD_NSN_SPARE_PARTS_ERR          CONSTANT NUMBER := 144;
   ASSIGN_PRIME_TO_EQUIV_ERR        CONSTANT NUMBER := 148;
   UPD_PRIME_PART_ERR               CONSTANT NUMBER := 152;
   UNABLE_TO_GET_NSI_SID            CONSTANT NUMBER := 156;
   UNABLE_TO_PREP_DATA              CONSTANT NUMBER := 160;
   UNABLE_TO_GET_NUM_ACTIVE_PARTS   CONSTANT NUMBER := 164;
   UNABLE_TO_PROC_INS_OR_DLET       CONSTANT NUMBER := 170;
   UNABLE_TO_SET_TACTICAL_IND       CONSTANT NUMBER := 174;
   UNABLE_TO_SET_SMR_CODE           CONSTANT NUMBER := 178;
   UNABLE_TO_SET_UNIT_COST          CONSTANT NUMBER := 182;
   ADD_PLANNER_CODE_ERR             CONSTANT NUMBER := 186;
   ADD_UOM_CODE_ERR                 CONSTANT NUMBER := 190;
   UPDT_ERR_NATIONAL_STK_ITEMS      CONSTANT NUMBER := 194;
   ASSIGN_NEW_EQUIV_PART_ERR        CONSTANT NUMBER := 198;
   UPDT_NULL_PRIME_COLS_ERR         CONSTANT NUMBER := 202;
   INSERT_NEW_NSN_ERR               CONSTANT NUMBER := 206;
   UPDT_NSN_PRIME_ERR               CONSTANT NUMBER := 210;
   CREATE_NATSTKITEM_ERR            CONSTANT NUMBER := 214;
   PREP_DATA_FOR_UPDT_ERR           CONSTANT NUMBER := 218;
   UPDT_SPAREPART_ERR               CONSTANT NUMBER := 222;
   UPDT_PRIMEPART_ERR               CONSTANT NUMBER := 226;
   UPDT_NATSTKITEM_ERR              CONSTANT NUMBER := 230;
   NEW_NSN_ERR                      CONSTANT NUMBER := 234;
   GET_NSISID_BY_PART_ERR           CONSTANT NUMBER := 238;
   NEW_NSN_ERROR                    CONSTANT NUMBER := 242;
   CHK_NSN_AND_PRIME_ERR2           CONSTANT NUMBER := 246;
   INSERTAGAIN_ERR                  CONSTANT NUMBER := 248;
   UNABLE_TO_CHG_NSN_TYPE           CONSTANT NUMBER := 252;
   UNABLE_TO_UNASSIGN_PART          CONSTANT NUMBER := 256;
   UNABLE_TO_GET_PRIME_PART_X       CONSTANT NUMBER := 260;
   UPDT_NULL_PRIME_COLS_ERR2        CONSTANT NUMBER := 264;
   CANNOT_UPDATE_ORDER_LEAD_TIME    CONSTANT NUMBER := 268;
   UPDT_ERRX                        CONSTANT NUMBER := 270;
   CANNOT_UPDATE_PART_PRICING       CONSTANT NUMBER := 274;
   DELETE_ERR                       CONSTANT NUMBER := 278;



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
      RETURN NUMBER;


   FUNCTION DeleteRow (pPart_no        IN VARCHAR2,
                       pNomenclature   IN VARCHAR2,
                       pMfgr           IN VARCHAR2)
      RETURN NUMBER;

   PROCEDURE loadCurrentBackOrder (debug IN BOOLEAN := FALSE);

   FUNCTION getQtyDue (primePartNo IN VARCHAR2)
      RETURN NUMBER;                                -- added 11/20/2007 by dse


   -- added 6/9/2006 by dse
   PROCEDURE version;


   FUNCTION getVersion
      RETURN VARCHAR2;                               -- added 4/15/2008 by dse

   PROCEDURE updateFlags (
      pPart_no      IN     amd_spare_parts.part_no%TYPE,
      is_spo_part      OUT amd_spare_parts.is_spo_part%TYPE); -- added 9/22/2008

   PROCEDURE setDebug (switch IN VARCHAR2);         -- added 10/24/2008 by dse

   FUNCTION getDebugYorN
      RETURN VARCHAR2;                              -- added 10/24/2008 by dse

   -- 4/6/2012 DSE added former a2a functions
   FUNCTION isValidRepairablePart (
      partNo                 IN VARCHAR2,
      preferredSmrCode       IN VARCHAR2,
      preferredMtbdr         IN NUMBER,
      preferredPlannerCode   IN VARCHAR2,
      showReason             IN BOOLEAN := FALSE)
      RETURN BOOLEAN;

   FUNCTION isValidRepairablePart (partNo       IN AMD_SPARE_PARTS.part_no%TYPE,
                                   showReason   IN BOOLEAN := FALSE)
      RETURN BOOLEAN;

   FUNCTION isValidConsumablePart (part_no IN VARCHAR2)
      RETURN BOOLEAN;
END Amd_Spare_Parts_Pkg;
/