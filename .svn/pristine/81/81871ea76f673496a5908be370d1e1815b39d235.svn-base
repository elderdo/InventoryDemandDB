SET DEFINE OFF;
DROP PACKAGE AMD_OWNER.AMD_SPARE_PARTS_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.Amd_Spare_Parts_Pkg AS
    /*
       $Author:   zf297a  $
     $Revision:   1.40  $
         $Date:   27 Mar 2008 12:08:14  $
     $Workfile:   AMD_SPARE_PARTS_PKG.pks  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_spare_parts_pkg.pks-arc  $
   
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

	  SCCSID:	%M%	%I%	Modified: %G%  %U%
      10/02/01 Douglas Elder   Initial implementation
	  03/21/02 Douglas Elder	Added Sleep(5) to insure
	  							a unique key for amd_nsi_parts
	  03/28/02 Douglas Elder	Added insertagain_err code - since the sleep
	  		   		   			is now only executed for insert exceptions
	  04/04/02 Douglas Elder	Added Mic Code to insert and update
	  04/05/02 Douglas Elder    Added return code: unable to chg nsn_type
	  		   		   			and constants for amd_nsns.nsn_type
     */
	-- return values from InsertRow, UpdateRow, and DeleteRow

	SUCCESS							CONSTANT NUMBER := 0 ;
	FAILURE							CONSTANT NUMBER := 4 ;

	-- amd_nsns.nsn_type values

	TEMPORARY_NSN 		 	   		CONSTANT VARCHAR2(1) := 'T' ;
	CURRENT_NSN	  		   			CONSTANT VARCHAR2(1) := 'C' ;

	/* NOTE: Most of these return values should not occur, but
		if they do occur there is probably a coding error that
		needs to be corrected.  The return value should help
		to isolate the section of code that caused the problem.
		The return value and associated data are recorded in the
		amd_load_details table
		*/

	PART_NOT_PRIME					CONSTANT NUMBER := 8 ;
	UNABLE_TO_PRIME_INFO			CONSTANT NUMBER := 12 ;
	UNABLE_TO_INSERT_SPARE_PART		CONSTANT NUMBER := 16 ;
	UNABLE_TO_INSERT_AMD_NSNS		CONSTANT NUMBER := 20 ;
	UNABLE_TO_INSERT_AMD_NSI_PARTS	CONSTANT NUMBER := 24 ;
	CANNOT_UPDT_NSN_NAT_STCK_ITEMS	CONSTANT NUMBER := 28 ;
	cannotGetNsiSid					exception ;
	CANNOT_UPDATE_SPARE_PARTS_NSN	CONSTANT NUMBER := 36 ;
	CANNOT_UPADATE_NAT_STCK_ITEMS 	CONSTANT NUMBER := 40 ;
	CANNOT_UPDATE_AMD_NSNS			CONSTANT NUMBER := 44 ;
	CANNOT_GET_UNIT_COST_CLEANED	CONSTANT NUMBER := 48 ;
	CHK_NSN_AND_PRIME_ERR			CONSTANT NUMBER := 52 ;
	UNABLE_TO_DELT_PART_NOT_FOUND 	CONSTANT NUMBER := 56 ;
	UNABLE_TO_DLET_NAT_STK_ITEM		CONSTANT NUMBER := 60 ;
	UNABLE_TO_RESET_NAT_STK_ITEM	CONSTANT NUMBER := 64 ;
	INSERT_PRIMEPART_ERR			CONSTANT NUMBER := 68 ;
	INS_PRIME_PART_ERR				CONSTANT NUMBER := 72 ;
	UPDATE_NATSTK_ERR				CONSTANT NUMBER := 76 ;
	INS_EQUIV_PART_ERR				CONSTANT NUMBER := 80 ;
	INS_AMD_NSI_PARTS_ERR			CONSTANT NUMBER := 84 ;
	UPD_AMD_SPARE_PARTS_NSN			CONSTANT NUMBER := 88 ;
	LOGICAL_INSERT_FAILED			CONSTANT NUMBER := 92 ;
	partAlreadyExists				exception ;
	INSERTROW_FAILED				CONSTANT NUMBER := 100 ;
	UNASSIGN_PRIME_PART_ERR			CONSTANT NUMBER := 104 ;
	UNASSIGN_OLD_PRIME_PART_ERR		CONSTANT NUMBER := 108 ;
	UPD_NSI_PARTS_ERR				CONSTANT NUMBER := 116 ;
	ASSIGN_NEW_PRIME_PART_ERR		CONSTANT NUMBER := 120 ;
	UPDATE_ERR						CONSTANT NUMBER := 124 ;
	UNABLE_TO_GET_PRIME_PART		CONSTANT NUMBER := 128 ;
	UPDT_PRIME_PART_ERR				CONSTANT NUMBER := 132 ;
	MAKE_NEW_PRIME_PART_ERR			CONSTANT NUMBER := 136 ;
	UNASSIGN_EQUIV_PART_ERR			CONSTANT NUMBER := 140 ;
	UPD_NSN_SPARE_PARTS_ERR			CONSTANT NUMBER := 144 ;
	ASSIGN_PRIME_TO_EQUIV_ERR		CONSTANT NUMBER := 148 ;
	UPD_PRIME_PART_ERR				CONSTANT NUMBER := 152 ;
	UNABLE_TO_GET_NSI_SID			CONSTANT NUMBER := 156 ;
	UNABLE_TO_PREP_DATA				CONSTANT NUMBER := 160 ;
	UNABLE_TO_GET_NUM_ACTIVE_PARTS	CONSTANT NUMBER := 164 ;
	UNABLE_TO_PROC_INS_OR_DLET		CONSTANT NUMBER := 170 ;
	UNABLE_TO_SET_TACTICAL_IND		CONSTANT NUMBER := 174 ;
	UNABLE_TO_SET_SMR_CODE			CONSTANT NUMBER := 178 ;
	UNABLE_TO_SET_UNIT_COST			CONSTANT NUMBER := 182 ;
	ADD_PLANNER_CODE_ERR			CONSTANT NUMBER := 186 ;
	ADD_UOM_CODE_ERR				CONSTANT NUMBER := 190 ;
	UPDT_ERR_NATIONAL_STK_ITEMS		CONSTANT NUMBER := 194 ;
	ASSIGN_NEW_EQUIV_PART_ERR		CONSTANT NUMBER := 198 ;
	UPDT_NULL_PRIME_COLS_ERR		CONSTANT NUMBER := 202 ;
	INSERT_NEW_NSN_ERR				CONSTANT NUMBER := 206 ;
	UPDT_NSN_PRIME_ERR				CONSTANT NUMBER := 210 ;
	CREATE_NATSTKITEM_ERR			CONSTANT NUMBER := 214 ;
	PREP_DATA_FOR_UPDT_ERR			CONSTANT NUMBER := 218 ;
	UPDT_SPAREPART_ERR				CONSTANT NUMBER := 222 ;
	UPDT_PRIMEPART_ERR				CONSTANT NUMBER := 226 ;
	UPDT_NATSTKITEM_ERR				CONSTANT NUMBER := 230 ;
	NEW_NSN_ERR						CONSTANT NUMBER := 234 ;
	GET_NSISID_BY_PART_ERR			CONSTANT NUMBER := 238 ;
	NEW_NSN_ERROR					CONSTANT NUMBER := 242 ;
	CHK_NSN_AND_PRIME_ERR2			CONSTANT NUMBER := 246 ;
	INSERTAGAIN_ERR					CONSTANT NUMBER := 248 ;
	UNABLE_TO_CHG_NSN_TYPE			CONSTANT NUMBER := 252 ;
	UNABLE_TO_UNASSIGN_PART			CONSTANT NUMBER := 256 ;
	UNABLE_TO_GET_PRIME_PART_X		CONSTANT NUMBER := 260 ;
	UPDT_NULL_PRIME_COLS_ERR2		CONSTANT NUMBER := 264 ;
	CANNOT_UPDATE_ORDER_LEAD_TIME   CONSTANT NUMBER := 268 ;
	UPDT_ERRX						CONSTANT NUMBER := 270 ;
	CANNOT_UPDATE_PART_PRICING		CONSTANT NUMBER := 274 ;
	DELETE_ERR						CONSTANT NUMBER := 278 ;

	mDebug boolean := false ; -- allow debugging to be turned on or off at the package level


	FUNCTION InsertRow
                (pPart_no IN VARCHAR2,
                pMfgr IN VARCHAR2,
                pDate_icp IN DATE,
                pDisposal_cost IN NUMBER,
                pErc IN VARCHAR2,
                pIcp_ind IN VARCHAR2,
                pNomenclature IN VARCHAR2,
                pOrder_lead_time IN NUMBER,
				pOrder_quantity IN NUMBER,
                pOrder_uom IN VARCHAR2,
				pPrime_ind IN VARCHAR2,
                pScrap_value IN NUMBER,
                pSerial_flag IN VARCHAR2,
                pShelf_life IN NUMBER,
                pUnit_cost IN NUMBER,
                pUnit_volume IN NUMBER,
                pNsn IN VARCHAR2,
				pNsn_type IN VARCHAR2,
                pItem_type IN VARCHAR2,
                pSmr_code IN VARCHAR2,
                pPlanner_code IN VARCHAR2,
				pMic_code_lowest IN VARCHAR2,
				pAcquisition_advice_code IN VARCHAR2,
				pMmac IN VARCHAR2,
				pUnitOfIssue IN VARCHAR2,
				pMtbdr in number,
				pMtbdr_computed in number,
  				pQpeiWeighted in number,
  				pCondemnAvgCleaned in number,
  				pCriticalityCleaned in number,
  				pMtbdrCleaned in number,
  				pNrtsAvgCleaned in number,
  				pCosToRepairOffBaseCleand in number,
  				pTimeToRepairOffBaseCleand in  number,
  				pOrderLeadTimeCleaned in number,
  				pPlannerCodeCleaned in amd_national_stock_items.planner_code_cleaned%type,
  				pRtsAvgCleaned in number,
  				pSmrCodeCleaned in amd_national_stock_items.smr_code_cleaned%type,
  				pUnitCostCleaned in number,
  				pCondemnAvg in number,
  				pCriticality in number,
  				pNrtsAvg in number,
  				pRtsAvg in number,
				pCostToRepairOffBase in number,
				pTimeToRepairOffBase in number,
                pAmcDemand in number,
                pAmcDemandCleaned in number,
                pWesmIndicator in  varchar2) return number ;



	FUNCTION UpdateRow
                (pPart_no IN VARCHAR2,
                pMfgr IN VARCHAR2,
                pDate_icp IN DATE,
                pDisposal_cost IN NUMBER,
                pErc IN VARCHAR2,
                pIcp_ind IN VARCHAR2,
                pNomenclature IN VARCHAR2,
                pOrder_lead_time IN NUMBER,
				pOrder_quantity IN NUMBER,
                pOrder_uom IN VARCHAR2,
				pPrime_ind IN VARCHAR2,
                pScrap_value IN NUMBER,
                pSerial_flag IN VARCHAR2,
                pShelf_life IN NUMBER,
                pUnit_cost IN NUMBER,
                pUnit_volume IN NUMBER,
                pNsn IN VARCHAR2,
				pNsn_type IN VARCHAR2,
                pItem_type IN VARCHAR2,
                pSmr_code IN VARCHAR2,
                pPlanner_code IN VARCHAR2,
				pMic_code_lowest IN VARCHAR2,
				pAcquisition_advice_code IN VARCHAR2,
				pMmac IN VARCHAR2,
				pUnitOfIssue IN VARCHAR2,
				pMtbdr in number,
				pMtbdr_computed in number,
  				pQpeiWeighted in number,
  				pCondemnAvgCleaned in number,
  				pCriticalityCleaned in number,
  				pMtbdrCleaned in number,
  				pNrtsAvgCleaned in number,
  				pCosToRepairOffBaseCleand in number,
  				pTimeToRepairOffBaseCleand in  number,
  				pOrderLeadTimeCleaned in number,
  				pPlannerCodeCleaned in amd_national_stock_items.planner_code_cleaned%type,
  				pRtsAvgCleaned in number,
  				pSmrCodeCleaned in amd_national_stock_items.smr_code_cleaned%type,
  				pUnitCostCleaned in number,
  				pCondemnAvg in number,
  				pCriticality in number,
  				pNrtsAvg in number,
  				pRtsAvg in number,
				pCostToRepairOffBase in number,
				pTimeToRepairOffBase in number,
                pAmcDemand in number,
                pAmcDemandCleaned in number,
                pWesmIndicator in varchar2) return number ;


	function DeleteRow(
							pPart_no in varchar2,
							pNomenclature in varchar2,
							pMfgr in varchar2 ) return number ;

	procedure loadCurrentBackOrder(debug in boolean := False) ;

    function getQtyDue(primePartNo in varchar2) return number ; -- added 11/20/2007 by dse

	
	-- added 6/9/2006 by dse
	procedure version ;
    
    
    function getVersion return varchar2 ; -- added 4/15/2008 by dse
    
END Amd_Spare_Parts_Pkg ;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_SPARE_PARTS_PKG;

CREATE PUBLIC SYNONYM AMD_SPARE_PARTS_PKG FOR AMD_OWNER.AMD_SPARE_PARTS_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_SPARE_PARTS_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_SPARE_PARTS_PKG TO AMD_WRITER_ROLE;


SET DEFINE OFF;
DROP PACKAGE BODY AMD_OWNER.AMD_SPARE_PARTS_PKG;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.amd_spare_parts_pkg as
	--
	-- SCCSID:   %M%   %I%   Modified: %G%  %U%
	--
	/*
       $Author:   zf297a  $
     $Revision:   1.94  $
         $Date:   27 Jun 2008 11:59:22  $
     $Workfile:   amd_spare_parts_pkg.pkb  $
	     $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_spare_parts_pkg.pkb-arc  $	
   
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
	  04/04/02 Douglas Elder	Added Mic Code to insert and update
	  04/05/02 Douglas Elder	Added code to update the nsn_type for
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


	UNIT_COST_CLEANED_VIA_NSN   exception;
	CANNOT_FIND_PART            exception;
	
	-- package member variables
	mRc		   		  		   	  number := FAILURE ;
	mArgs	   		  		      varchar2(2000) ;
	mMtbdr	   		              amd_national_stock_items.mtbdr%type ;
	mMtbdr_computed				  amd_national_stock_items.mtbdr_computed%type ;
	mQpeiWeighted	  			  amd_national_stock_items.qpei_weighted%type ;
	mCondemnAvgCleaned			  amd_national_stock_items.condemn_avg_cleaned%type ;
  	mCriticalityCleaned			  amd_national_stock_items.criticality%type ;
    mMtbdrCleaned       		  amd_national_stock_items.mtbdr_cleaned%type ;
  	mNrtsAvgCleaned     		  amd_national_stock_items.nrts_avg_cleaned%type ;
  	mCostToRepairOffBaseCleand    amd_national_stock_items.cost_to_repair_off_base_cleand%type ;
  	mTimeToRepairOffBaseCleand    amd_national_stock_items.time_to_repair_off_base_cleand%type ;
  	mOrderLeadTimeCleaned         amd_national_stock_items.order_lead_time_cleaned%type ;
  	mPlannerCodeCleaned           amd_national_stock_items.planner_code_cleaned%type ;
  	mRtsAvgCleaned                amd_national_stock_items.rts_avg_cleaned%type ;
  	mSmrCodeCleaned               amd_national_stock_items.smr_code_cleaned%type ;
  	mUnitCostCleaned              amd_national_stock_items.unit_cost_cleaned%type ;
  	mCondemnAvg                   amd_national_stock_items.condemn_avg%type ;
  	mCriticality                  amd_national_stock_items.criticality%type ;
  	mNrtsAvg                      amd_national_stock_items.nrts_avg%type ;
  	mRtsAvg                       amd_national_stock_items.rts_avg%type ;
	mCostToRepairOffBase		  amd_national_stock_items.cost_to_repair_off_base%type ;
	mTimeToRepairOffBase		  amd_national_stock_items.time_to_repair_off_base%type ;
    mAmcDemand                    amd_national_stock_items.amc_demand%type ;
    mAmcDemandCleaned             amd_national_stock_items.amc_demand_cleaned%type ;
    mWesmIndicator                amd_national_stock_items.WESM_INDICATOR%type ;
	

	---------------------------------------------------------------
	-- Private declarations
	--

	function  getFedcCost(
							pPartNo varchar2) return number;
	function hasPartMoved(
							pPartNo varchar2,
							pNsn varchar2) return boolean;
	procedure unassignPart(
							pPartNo varchar2);

	function ErrorMsg(
							pSourceName in amd_load_status.SOURCE%type,
							pTableName in amd_load_status.TABLE_NAME%type,
							pError_location in amd_load_details.DATA_LINE_NO%type,
							pReturn_code in number,
							pPart_no in varchar2 := '',
							pNsi_sid in varchar2 := '',
							pKeywordValuePairs in varchar2 := '',
							pComments in varchar2 := '') return number ;
	--
	-- End Private declarations
	---------------------------------------------------------------

	debugThreshold number := 1000 ;
	debugCnt	   number := 0 ;
	
	procedure writeMsg(
				pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
				pError_location IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
				pKey1 IN VARCHAR2 := '',
				pKey2 IN VARCHAR2 := '',
				pKey3 IN VARCHAR2 := '',
				pKey4 in varchar2 := '',
				pData IN VARCHAR2 := '',
				pComments IN VARCHAR2 := '')  IS
	BEGIN
		Amd_Utils.writeMsg (
				pSourceName => 'amd_spare_parts_pkg',	
				pTableName  => pTableName,
				pError_location => pError_location,
				pKey1 => pKey1,
				pKey2 => pKey2,
				pKey3 => pKey3,
				pKey4 => pKey4,
				pData    => pData,
				pComments => pComments);
	end writeMsg ;
	
	function ErrorMsg(
				pSqlfunction in amd_load_status.SOURCE%type,
				pTableName in amd_load_status.TABLE_NAME%type,
				pError_location amd_load_details.DATA_LINE_NO%type,
				pReturn_code in number,
				pKey_1 in amd_load_details.KEY_1%type,
		 		pKey_2 in amd_load_details.KEY_2%type := '',
				pKey_3 in amd_load_details.KEY_3%type := '',
				pKey_4 in amd_load_details.KEY_4%type := '',					
				pKeywordValuePairs in varchar2 := '') return number is
	key5 amd_load_details.KEY_5%type := pKeywordValuePairs ;
	begin
		rollback;
		if key5 = '' then
		   key5 := pSqlFunction || '/' || pTableName ;
		else
			key5 := key5 || ' ' || pSqlFunction || '/' || pTableName ;
		end if ;
		-- use substr's to make sure that the input parameters for InsertErrorMsg and GetLoadNo
		-- do not exceed the length of the column's that the data gets inserted into
		-- This is for debugging and logging, so efforts to make it not be the source of more
		-- errors is VERY important
		Amd_Utils.InsertErrorMsg (
				pLoad_no => Amd_Utils.GetLoadNo(
						pSourceName => substr(pSqlfunction,1,20),
						pTableName  => substr(pTableName,1,20)),
				pData_line_no => pError_location,
				pData_line    => 'amd_spare_parts_pkg.' || mArgs,
				pKey_1 => substr(pKey_1,1,50),
				pKey_2 => substr(pKey_2,1,50),
				pKey_3 => substr(pKey_3,1,50),
				pKey_4 => substr(pKey_4,1,50),
				pKey_5 => substr('rc=' || to_char(pReturn_code) ||
					       ' ' || to_char(sysdate,'MM/DD/YYYY HH:MI:SS AM') ||
						   ' ' || key5,1,50),
				pComments => substr('sqlcode('||sqlcode||') sqlerrm('||sqlerrm||')',1,2000));
		commit;
		return pReturn_code;
	exception when others then
			  commit ;
	end ErrorMsg;

	procedure ErrorMsg(
					pSqlfunction in amd_load_status.SOURCE%type,
					pTableName in amd_load_status.TABLE_NAME%type := '',
					pError_location amd_load_details.DATA_LINE_NO%type,
					pKey_1 in amd_load_details.KEY_1%type := '',
			 		pKey_2 in amd_load_details.KEY_2%type := '',
					pKey_3 in amd_load_details.KEY_3%type := '',
					pKey_4 in amd_load_details.KEY_4%type := '',					
					pKeywordValuePairs in varchar2 := '') is
		result number ;
	begin
		 result := ErrorMsg(pSqlfunction => pSqlfunction,
							pTableName => pTableName,
							pError_location => pError_location,
							pReturn_code => a2a_pkg.FAILURE,
						    pKey_1 => pKey_1,
							pKey_2 => pKey_2,
							pKey_3 => pKey_3,
							pKey_4 => pKey_4,
							pKeywordValuePairs => pKeywordValuePairs) ;
							
	exception when others then
			  commit ;
	end ErrorMsg;

	-- add wrapper for amd_utils.debugMsg
	procedure debugMsg(pMsg in varchar2,pLineNo in number) is
		result number ;
	begin
		-- is debugging turned on for this package?
		if mDebug then
		   amd_utils.debugMsg(pMsg => pMsg,pPackage => 'amd_spare_parts', pLocation => pLineNo) ;
		   commit ; -- make sure the trace is kept
		end if ;
	end;

	function getCriticalityChangedInd(nsi_sid in amd_national_stock_items.nsi_sid%type) 
			 return amd_national_stock_items.criticality_changed%type  is
			 oldCriticality amd_national_stock_items.CRITICALITY%type ;
			 oldCriticalityCleaned amd_national_stock_items.CRITICALITY_CLEANED%type ;
	begin
		 <<getOldValues>>
		 begin
			 select criticality, criticality_cleaned into oldCriticality, oldCriticalityCleaned
			 from amd_national_stock_items
			 where nsi_sid = getCriticalityChangedInd.nsi_sid ;
		 exception
		 		  when standard.NO_DATA_FOUND then
				  	   oldCriticality := null ;
					   oldCriticalityCleaned := null ;
				  when others then
				  	   ErrorMsg(pSqlfunction => 'select',
							pTableName => 'amd_national_stock_items',
							pError_location => 10, 
							pKey_1 => to_char(getCriticalityChangedInd.nsi_sid)) ;
				  		raise ;
		 end getOldValues ;
		 if amd_preferred_pkg.GetPreferredValue(mCriticalityCleaned, mCriticality) !=
		 	amd_preferred_pkg.GetPreferredValue(oldCriticalityCleaned, oldCriticality) then
			return 'Y' ;
		 else
		 	 return 'N' ;
		 end if ;
	end getCriticalityChangedInd ; 

	function getNrtsAvgChangedInd(nsi_sid in amd_national_stock_items.nsi_sid%type) return 
			 							  amd_national_stock_items.nrts_avg_changed%type is
			 oldNrtsAvg amd_national_stock_items.Nrts_Avg%type ;
			 oldNrtsAvgCleaned amd_national_stock_items.Nrts_Avg_CLEANED%type ;
	begin
		 <<getOldValues>>
		 begin
			 select Nrts_Avg, Nrts_Avg_cleaned into oldNrtsAvg, oldNrtsAvgCleaned
			 from amd_national_stock_items
			 where nsi_sid = getNrtsAvgChangedInd.nsi_sid ;
		 exception
		 		  when standard.NO_DATA_FOUND then
				  	   oldNrtsAvg := null ;
					   oldNrtsAvgCleaned := null ;
				  when others then
				  	   ErrorMsg(pSqlfunction => 'select',
							pTableName => 'amd_national_stock_items',
							pError_location => 20, 
							pKey_1 => to_char(getNrtsAvgChangedInd.nsi_sid)) ;
				  		raise ;
		 end getOldValues ;
		 if amd_preferred_pkg.GetPreferredValue(mNrtsAvgCleaned, mNrtsAvg) !=
		 	amd_preferred_pkg.GetPreferredValue(oldNrtsAvgCleaned, oldNrtsAvg) then
			return 'Y' ;
		 else
		 	 return 'N' ;
		 end if ;
	end getNrtsAvgChangedInd ; 

	function getRtsAvgChangedInd(nsi_sid in amd_national_stock_items.nsi_sid%type) return 
			  amd_national_stock_items.rts_avg_changed%type  is
			 oldRtsAvg amd_national_stock_items.Rts_Avg%type ;
			 oldRtsAvgCleaned amd_national_stock_items.Rts_Avg_CLEANED%type ;
	begin
		 <<getOldValues>>
		 begin
			 select Rts_Avg, Rts_Avg_cleaned into oldRtsAvg, oldRtsAvgCleaned
			 from amd_national_stock_items
			 where nsi_sid = getRtsAvgChangedInd.nsi_sid ;
		 exception
		 		  when standard.NO_DATA_FOUND then
				  	   oldRtsAvg := null ;
					   oldRtsAvgCleaned := null ;
				  when others then
				  	   ErrorMsg(pSqlfunction => 'select',
							pTableName => 'amd_national_stock_items',
							pError_location => 30, 
							pKey_1 => to_char(getRtsAvgChangedInd.nsi_sid)) ;
				  		raise ;
		 end getOldValues ;
		 if amd_preferred_pkg.GetPreferredValue(mRtsAvgCleaned, mRtsAvg) !=
		 	amd_preferred_pkg.GetPreferredValue(oldRtsAvgCleaned, oldRtsAvg) then
			return 'Y' ;
		 else
		 	 return 'N' ;
		 end if ;
	end getRtsAvgChangedInd ; 

	function getCondemnAvgChangedInd(nsi_sid in amd_national_stock_items.nsi_sid%type) return 
			 	amd_national_stock_items.condemn_avg_changed%type is
			 oldCondemnAvg amd_national_stock_items.Condemn_Avg%type ;
			 oldCondemnAvgCleaned amd_national_stock_items.Condemn_Avg_CLEANED%type ;
	begin
		 <<getOldValues>>
		 begin
			 select Condemn_Avg, Condemn_Avg_cleaned into oldCondemnAvg, oldCondemnAvgCleaned
			 from amd_national_stock_items
			 where nsi_sid = getCondemnAvgChangedInd.nsi_sid ;
		 exception
		 		  when standard.NO_DATA_FOUND then
				  	   oldCondemnAvg := null ;
					   oldCondemnAvgCleaned := null ;
				  when others then
				  	   ErrorMsg(pSqlfunction => 'select',
							pTableName => 'amd_national_stock_items',
							pError_location => 40, 
							pKey_1 => to_char(getCondemnAvgChangedInd.nsi_sid)) ;
				  		raise ;
		 end getOldValues ;
		 if amd_preferred_pkg.GetPreferredValue(mCondemnAvgCleaned, mCondemnAvg) !=
		 	amd_preferred_pkg.GetPreferredValue(oldCondemnAvgCleaned, oldCondemnAvg) then
			return 'Y' ;
		 else
		 	 return 'N' ;
		 end if ;
	end getCondemnAvgChangedInd ; 

	function getCostToRepairOffBaseChgedInd(nsi_sid in amd_national_stock_items.nsi_sid%type) return 
			 	amd_national_stock_items.cost_to_repair_off_base_chged%type is
			 oldCostToRepairOffBase amd_national_stock_items.cost_to_repair_off_base%type ;
			 oldCostToRepairOffBaseCleand amd_national_stock_items.cost_to_repair_off_base_cleand%type ;
	begin
		 <<getOldValues>>
		 begin
			 select cost_to_repair_off_base, cost_to_repair_off_base_cleand into oldCostToRepairOffBase, oldCostToRepairOffBaseCleand
			 from amd_national_stock_items
			 where nsi_sid = getCostToRepairOffBaseChgedInd.nsi_sid ;
		 exception
		 		  when standard.NO_DATA_FOUND then
				  	   oldCostToRepairOffBase := null ;
					   oldCostToRepairOffBaseCleand := null ;
				  when others then
				  	   ErrorMsg(pSqlfunction => 'select',
							pTableName => 'amd_national_stock_items',
							pError_location => 50, 
							pKey_1 => to_char(getCostToRepairOffBaseChgedInd.nsi_sid)) ;
				  		raise ;
		 end getOldValues ;
		 if amd_preferred_pkg.GetPreferredValue(mCostToRepairOffBaseCleand, mCostToRepairOffBase) !=
		 	amd_preferred_pkg.GetPreferredValue(oldCostToRepairOffBaseCleand, oldCostToRepairOffBase) then
			return 'Y' ;
		 else
		 	 return 'N' ;
		 end if ;
	end getCostToRepairOffBaseChgedInd ; 

	function getTimeToRepairOffBaseChgedInd(nsi_sid in amd_national_stock_items.nsi_sid%type) return 
			 	amd_national_stock_items.time_to_repair_off_base_chged%type is
			 oldTimeToRepairOffBase amd_national_stock_items.time_to_repair_off_base%type ;
			 oldTimeToRepairOffBaseCleand amd_national_stock_items.time_to_repair_off_base_cleand%type ;
	begin
		 <<getOldValues>>
		 begin
			 select time_to_repair_off_base, time_to_repair_off_base_cleand into oldTimeToRepairOffBase, oldTimeToRepairOffBaseCleand
			 from amd_national_stock_items
			 where nsi_sid = getTimeToRepairOffBaseChgedInd.nsi_sid ;
		 exception
		 		  when standard.NO_DATA_FOUND then
				  	   oldTimeToRepairOffBase := null ;
					   oldTimeToRepairOffBaseCleand := null ;
				  when others then
				  	   ErrorMsg(pSqlfunction => 'select',
							pTableName => 'amd_national_stock_items',
							pError_location => 60, 
							pKey_1 => to_char(getTimeToRepairOffBaseChgedInd.nsi_sid)) ;
				  		raise ;
		 end getOldValues ;
		 if amd_preferred_pkg.GetPreferredValue(mTimeToRepairOffBaseCleand, mTimeToRepairOffBase) !=
		 	amd_preferred_pkg.GetPreferredValue(oldTimeToRepairOffBaseCleand, oldTimeToRepairOffBase) then
			return 'Y' ;
		 else
		 	 return 'N' ;
		 end if ;
	end getTimeToRepairOffBaseChgedInd ; 

	procedure insertLoadDetail(
							pPartNo varchar2,
							pNsn varchar2,
							pPrimeInd varchar2,
							pAction varchar2) is
		aspNsn     amd_spare_parts.nsn%type;
		aspAction  amd_spare_parts.action_code%type;
		anpNsiSid  amd_nsi_parts.nsi_sid%type;
		anNsiSid   amd_nsns.nsi_sid%type;
		anNsn      amd_nsns.nsn%type;
		anNsn2     amd_nsns.nsn%type;
		anNsnType  amd_nsns.nsn_type%type;
		anNsnType2 amd_nsns.nsn_type%type;
		anpPrime   amd_nsi_parts.prime_ind%type;
	begin
		begin
			select anp.prime_ind,an.nsn,an.nsn_type,anp.nsi_sid,
				asp.action_code,asp.nsn
			into anpPrime,anNsn,anNsnType,anpNsiSid,aspAction,aspNsn
			from amd_spare_parts asp,
				amd_nsi_parts anp,
				amd_nsns an
			where asp.part_no = pPartNo
				and asp.part_no = anp.part_no
				and anp.nsi_sid = an.nsi_sid
				and anp.unassignment_date is null
				and an.nsn_type = 'C';
		exception when others then 
				  NULL; 
		end;

		begin
			select nsi_sid,nsn,nsn_type
			into anNsiSid,anNsn2,anNsnType2
			from amd_nsns
			where nsn = pNsn;
		exception when others then
				  null ; 
		end;

		amd_utils.InsertErrorMsg (
				pLoad_no => amd_utils.GetLoadNo(
					pSourceName => 'amd_spare_parts_pkg',
					pTableName  => 'amd_spare_parts'),
				pData_line_no => 1,
				pData_line    => substr('D: '||pAction||'- Curr View - pPartNo('||pPartNo||') pNsn('||pNsn||') pPrimeInd('||pPrimeInd||') - anNsn('||anNsn||') anNsnType('||anNsnType||') aspAction('||aspAction||') anpPrime('||anpPrime||') anpNsiSid('||anpNsiSid||')',1,2000),
				pKey_1 => 'anNsn2('||anNsiSid||')',
				pKey_2 => 'anNsnType2('||anNsnType2||')',
				pKey_3 => 'aspNsn('||aspNsn||')',
				pKey_4 => 'anNsiSid('||anNsiSid||')',
				pKey_5 => '',
				pComments => to_char(sysdate,'yyyymmdd hh:mi:ss am'));

		commit;
	end insertLoadDetail ;


	procedure unassociateTmpNsn(
							pNsn varchar2) is
	begin
		debugMsg('unassociateTmpNsn('||pNsn||')', pLineNo => 10);
		-- We do this when a temp nsn now appears in CAT1. This will remove
		-- the association to the current nsn and will set up the process
		-- to create a new nsi_sid for this formerly temp nsn.
		--
		delete from amd_nsns
		where nsn = pNsn
			and nsn_type = 'T';
	end;


	function hasPartMoved(
							pPartNo varchar2,
							pNsn varchar2) return boolean is
		nsn    amd_nsns.nsn%type;
	begin
		debugMsg('hasPartMoved('||pPartNo||')', pLineNo => 20);

		-- A part has moved from one nsn to another if the new and old nsns
		-- appear in tmp_amd_spare_parts at the same time.
		--
		select distinct 'Part has moved.'
		into nsn
		from tmp_amd_spare_parts
		where
			nsn =
				(select an.nsn
				from
					amd_nsi_parts anp,
					amd_nsns an
				where anp.part_no = pPartNo
					and anp.nsi_sid = an.nsi_sid
					and anp.unassignment_date is null
					and an.nsn_type = 'C'
					and an.nsn != pNsn)
		union
		select 'Part has moved.'
		from amd_nsns an,
			amd_nsi_parts anp
		where anp.part_no = pPartNo
			and an.nsi_sid != anp.nsi_sid
			and anp.unassignment_date is null
			and an.nsn_type = 'C'
			and an.nsn = pNsn;

		return TRUE;
	exception
		when NO_DATA_FOUND then
			return FALSE;
	end;


	function  getFedcCost(
							pPartNo varchar2) return number is
		cursor costCur is
			select gfp_price
			from prc1
			where
				part = pPartNo
				and gfp_price is not null
			order by sc desc;

		fedcCost    number;
	begin
		debugMsg('getFedcCost(' || pPartNo || ')', pLineNo => 30) ;
		for rec in costCur loop
			fedcCost := rec.gfp_price;
			exit;
		end loop;

		return fedcCost;
	exception when others then
  	   ErrorMsg(pSqlfunction => 'select',
			pTableName => 'prcl',
			pError_location => 80, 
			pKey_1 => pPartNo) ;
  		raise ;
	end getFedcCost ;



	procedure unassignPart(
							pPartNo varchar2) is
	begin
		debugMsg('unassignPart('||pPartNo||')', pLineNo => 40);
		update amd_nsi_parts set
			unassignment_date = sysdate
		where
			part_no = pPartNo
			and unassignment_date is null;
	end unassignPart ;


	function IsPrimePart(
						pPrime_ind in amd_nsi_parts.prime_ind%type) return boolean is
	begin
		debugMsg('isPrimePart(' || pPrime_ind || ')', pLineNo => 50);
		return (Upper(pPrime_ind) = amd_defaults.PRIME_PART);
	exception when others then
  	   ErrorMsg(pSqlfunction => 'isPrimeInd',
			pTableName => '',
			pError_location => 90, 
			pKey_1 => pPrime_ind) ;
  		raise ;
	end IsPrimePart;


	procedure sleep(
							secs in number) is
		ss varchar2(2);
	begin
		ss := to_char(sysdate,'ss');
		while to_number(ss) + secs > to_number(to_char(sysdate,'ss'))
		loop
			null;
		end loop;
	end;


	/* 8/23/02 DSE added ErrorMsg to eliminate some redundant code
	 * and to give the error messages a std structure.
	 */
	 -- 9/3/04 DSE add stronger typing for Source and Table_name + add substr's to make
	 -- certain that the key_1 to key_5 never exceed 50 characters
	function ErrorMsg(
							pSourceName in amd_load_status.SOURCE%type,
							pTableName in amd_load_status.TABLE_NAME%type,
							pError_location in amd_load_details.DATA_LINE_NO%type,
							pReturn_code in number,
							pPart_no in varchar2 := '',
							pNsi_sid in varchar2 := '',
							pKeywordValuePairs in varchar2 := '',
							pComments in varchar2 := '') return number is
	begin
		rollback; -- rollback may not be complete if running with mDebug set to true
		amd_utils.InsertErrorMsg (
				pLoad_no => amd_utils.GetLoadNo(
						pSourceName => pSourceName,
						pTableName  => pTableName),
				pData_line_no => pError_location,
				pData_line    => 'amd_spare_parts_pkg.' || mArgs,
				pKey_1 => substr(pPart_no,1,50),
				pKey_2 => substr(pNsi_sid,1,50),
				pKey_3 => pKeywordValuePairs,
				pKey_4 => to_char(pReturn_code),
				pKey_5 => sysdate,
				pComments => 'sqlcode('||sqlcode||') sqlerrm('||sqlerrm||') ' || pComments);

		commit;
		return pReturn_code;
	end;


	function insertNsiParts(
							pNsi_sid in amd_nsi_parts.nsi_sid%type,
							pPart_no in amd_nsi_parts.part_no%type,
							pPrime_ind in amd_nsi_parts.prime_ind%type,
							pPrime_ind_cleaned in amd_nsi_parts.prime_ind_cleaned%type,
							pBadRc in number) return number is
		currDate   date:=sysdate;
	begin
		debugMsg('insertNsiParts('||pNsi_sid||','||pPart_no||','||pPrime_ind||','||pPrime_ind_cleaned||','||pBadRc||')', pLineNo => 60);

		insert into amd_nsi_parts
		(
			nsi_sid,
			assignment_date,
			part_no,
			prime_ind
		)
		values
		(
			pNsi_sid,
			currDate,
			pPart_no,
			pPrime_ind
		);

		-- This is a safeguard to ensure all other records are unassigned
		update amd_nsi_parts set
			unassignment_date = sysdate
		where
			part_no = pPart_no
			and unassignment_date is null
			and assignment_date < currDate;

		return SUCCESS;
	exception
		when dup_val_on_index then
		    <<InsertAgainAfterOneSecond>>
			begin
				sleep(1);
				insert into amd_nsi_parts
				(
					nsi_sid,
					assignment_date,
					part_no,
					prime_ind
				)
				values
				(
					pNsi_sid,
					sysdate,
					pPart_no,
					pPrime_ind
				);
				return SUCCESS;
			exception
				when others then
				   mRc := amd_spare_parts_pkg.INSERTAGAIN_ERR + pBadRC ;
			  	   ErrorMsg(pSqlfunction => 'insert',
						pTableName => 'amd_nsi_parts',
						pError_location => 100, 
						pKey_1 => pPart_no,
						pKey_2 => to_char(pNsi_sid),
						pKey_3 => 'prime_ind=' || pPrime_ind) ;
			  		raise ;
			end InsertAgainAfterOneSecond;
		when others then
			   mRC := pBadRc ;
		  	   ErrorMsg(pSqlfunction => 'update',
					pTableName => 'amd_nsi_parts',
					pError_location => 110, 
					pKey_1 => pPart_no) ;
		  		raise ;
	end insertNsiParts;


	/* 8/22/02 DSE added MakeNsnSameForAllParts to eliminate some
	 * redundant code.\
	 */
	function MakeNsnSameForAllParts(
							pNsi_sid in amd_nsi_parts.nsi_sid%type,
							pNsn in amd_national_stock_items.nsn%type) return number is
        type partNoTab is table of amd_nsi_parts.PART_NO%type ;        
        partNos PartNoTab ;    
        type nsnTab is table of amd_national_stock_items.nsn%type ;
        nsns NsnTab ;
                                
		cursor partList is
			select
				part_no, pNsn
			from amd_nsi_parts
			where nsi_sid = pNsi_sid
			and unassignment_date is null;
	begin
        open partList ;
        fetch partList bulk collect into partNos, nsns ;
        close partList ;
        if partNos.first is not null then
            forall indx in partNos.first .. partNos.last
                update amd_spare_parts parts set nsn = nsns(indx)
                where part_no = partNos(indx) ;
		end if ;
        commit ;
		return SUCCESS;
	exception
		when others then
		   mRC := amd_spare_parts_pkg.UPD_NSN_SPARE_PARTS_ERR ;
	  	   ErrorMsg(pSqlfunction => 'select',
				pTableName => 'amd_nsi_parts',
				pError_location => 120, 
				pKey_1 => to_char(pNsi_sid)) ;
	  		raise ;
	end MakeNsnSameForAllParts;


	/*
		For a given nsn if all related parts are marked
		as deleted, then its associated nsn in the
		amd_national_stock_items should be marked as DELETED.
		For a given nsn if any related part is not marked
		DELETED and its associated nsn is marked DELETED,
		then mark the nsn as either INSERTED or UPDATED depending
		on the current action
	  */
	function UpdateNatStkItem(
							pNsn in amd_spare_parts.nsn%type,
							pAction in varchar2,
							pPartNo varchar2 default null) return number is

		nsi_sid     amd_nsi_parts.nsi_sid%type := null;

		function NumberOfActiveParts return number is
			cnt number := 0;
			result number := SUCCESS;
		begin

			select count(*)
			into cnt
			from  amd_nsi_parts nsi, amd_spare_parts parts
			where nsi.nsi_sid = UpdateNatStkItem.nsi_sid
			and nsi.part_no = parts.part_no
			and nsi.unassignment_date is null
			and parts.action_code != amd_defaults.DELETE_ACTION;

			return cnt;
		exception
			when NO_DATA_FOUND then
				return 0;
			when others then
		  	   ErrorMsg(pSqlfunction => 'select',
					pTableName => 'amd_nsi_parts',
					pError_location => 130, 
					pKey_1 => to_char(UpdateNatStkItem.nsi_sid)) ;
		  		raise ;
		end NumberOfActiveParts;


		function IsNsnMarkedDeleted return boolean is
			action_code amd_national_stock_items.action_code%type := null;
			result number;
		begin
			select action_code
			into action_code
			from amd_national_stock_items items
			where items.nsi_sid = UpdateNatStkItem.nsi_sid;
			return (action_code = amd_defaults.DELETE_ACTION);
		exception
			when others then
		  	   ErrorMsg(pSqlfunction => 'select',
					pTableName => 'amd_national_stock_items',
					pError_location => 140, 
					pKey_1 => to_char(UpdateNatStkItem.nsi_sid)) ;
		  		raise ;
		end IsNsnMarkedDeleted;

	begin -- UpdateNatStkItem
	    debugMsg('UpdateNatStkItem(' || pNsn || ', ' || pAction || ', ' || pPartNo || ')', pLineNo => 70) ;
		
		<<GetNsiSid>>
		begin
			/*
				use the nsi_sid to get a row from the
				amd_national_stock_items since it is always
				better than the Nsn - even though this Nsn
				should be the current Nsn for the prime part
				and its equivalent parts.
			*/
			nsi_sid := amd_utils.GetNsiSid(pNsn => pNsn);
		exception
			when NO_DATA_FOUND then
				return amd_spare_parts_pkg.UNABLE_TO_GET_NSI_SID;
		end GetNsiSid;

		if pAction = amd_defaults.DELETE_ACTION then
		
		    <<numberOfActivePartsGt0>>
			begin
				if NumberOfActiveParts() = 0 then
						update amd_national_stock_items set
							action_code    = amd_defaults.DELETE_ACTION,
							last_update_dt = sysdate
						where nsi_sid = UpdateNatStkItem.nsi_sid;
				end if;
			exception
				when others then
					return amd_spare_parts_pkg.UNABLE_TO_GET_NUM_ACTIVE_PARTS;
			end numberOfActivePartsGt0;
			
		else
			/* must be an INSERT_ACTION or an UPDATE_ACTION */
			<<processInsertOrDelete>>
			begin
				if (NumberOfActiveParts() > 0 and IsNsnMarkedDeleted() ) then
					update amd_national_stock_items set
						action_code    = pAction,
						last_update_dt = sysdate
					where nsi_sid = UpdateNatStkItem.nsi_sid;
				end if;
			exception
				when others then
					return amd_spare_parts_pkg.UNABLE_TO_PROC_INS_OR_DLET;
			end processInsertOrDelete;
		end if;

		return SUCCESS;
	exception
		when others then
			mRC := amd_spare_parts_pkg.UPDT_NATSTKITEM_ERR ;
			ErrorMsg(pSqlfunction => 'updateNatStkItem',
				pTableName => 'amd_national_stock_items',
				pError_location => 150) ;
			raise ;
	end UpdateNatStkItem;


	/* 8/22/02 DSE added UpdtNsiPrimePartData to eliminate some
	 * redundant code.
	 */
	function UpdtNsiPrimePartData(
							pPrime_ind in amd_nsi_parts.prime_ind%type,
							pNsi_sid in amd_national_stock_items.nsi_sid%type,
							pPartNo in amd_national_stock_items.prime_part_no%type,
							pNsn in amd_national_stock_items.nsn%type,
							pItem_type in amd_national_stock_items.item_type%type,
							pOrder_quantity in amd_national_stock_items.order_quantity%type,
							pPlannerCode in amd_national_stock_items.planner_code%type,
							pSmr_code in amd_national_stock_items.smr_code%type,
							pMic_code_lowest in amd_national_stock_items.mic_code_lowest%type,
							pAction_code in amd_national_stock_items.action_code%type,
							pReturn_code in number,
							pMmac in amd_national_stock_items.mmac%type) RETURN NUMBER is
		fedcCost   number;
		procedure verifyData is
				  rec amd_national_stock_items%rowtype ;
				  x number := 0 ;
		begin
		    debugMsg('verifyData', pLineNo => 80) ;
		 	x:=x+1;rec.prime_part_no := pPartNo ;
		 	x:=x+1;rec.fedc_cost := fedcCost ;
		 	x:=x+1;rec.nsn := pNsn ;
		 	x:=x+1;rec.item_type := pItem_type ;
		 	x:=x+1;rec.order_quantity := pOrder_quantity ;
		 	x:=x+1;rec.planner_code := pPlannerCode ;
		 	x:=x+1;rec.smr_code := pSmr_Code ;
		 	x:=x+1;rec.mic_code_lowest := pMic_code_lowest ;
			x:=x+1;rec.last_update_dt := sysdate ;
		 	x:=x+1;rec.mmac := pMmac ;
		 	x:=x+1;rec.mtbdr := mMtbdr ;
			x:=x+1;rec.mtbdr_computed := mMtbdr_computed ;
		 	x:=x+1;rec.qpei_weighted := mQpeiWeighted ;
			 
			x:=x+1;rec.condemn_avg_cleaned 		 := mCondemnAvgCleaned ;
			x:=x+1;rec.criticality_cleaned   		   := mCriticalityCleaned ;
			x:=x+1;rec.mtbdr_cleaned 		  		   := mMtbdrCleaned ;
			x:=x+1;rec.nrts_avg_cleaned 	  		   := mNrtsAvgCleaned ;
			x:=x+1;rec.cost_to_repair_off_base_cleand := mCostToRepairOffBaseCleand ;
			x:=x+1;rec.time_to_repair_off_base_cleand := mTimeToRepairOffBaseCleand ;
            x:=x+1;rec.amc_demand := mAmcDemand ;
            x:=x+1;rec.amc_demand_cleaned := mAmcDemandCleaned ;
            x:=x+1;rec.wesm_indicator := mWesmIndicator ;
			x:=x+1;rec.order_lead_time_cleaned 	   := mOrderLeadTimeCleaned ;
			x:=x+1;rec.planner_code_cleaned 		   := mPlannerCodeCleaned ;
			x:=x+1;rec.rts_avg_cleaned 			   := mRtsAvgCleaned ;
			x:=x+1;rec.smr_code_cleaned 			   := mSmrCodeCleaned ;
			x:=x+1;rec.unit_cost_cleaned 			   := mUnitCostCleaned ;
			x:=x+1;rec.condemn_avg 				   := mCondemnAvg ;
			x:=x+1;rec.criticality 				   := mCriticality ;
			x:=x+1;rec.nrts_avg 					   := mNrtsAvg ;
			x:=x+1;rec.rts_avg 					   := mRtsAvg ;
			x:=x+1;rec.cost_to_repair_off_base	   := mCostToRepairOffBase ;
			x:=x+1;rec.time_to_repair_off_base	   := mTimeToRepairOffBase ;
			x:=x+1;rec.action_code := pAction_code ;
		exception when others then
			ErrorMsg(pSqlfunction => 'verifyData',
				pTableName => 'amd_national_stock_items',
				pError_location => 160) ;
			raise ;
		end verifyData ;
		
		procedure doUpdate(planner_code_cleaned in varchar2, planner_code in varchar2) is
				  criticality_changed amd_national_stock_items.CRITICALITY_CHANGED%type 
				   :=  getCriticalityChangedInd(pNsi_sid) ;
				  nrts_avg_changed amd_national_stock_items.NRTS_AVG_CHANGED%type 
				    := getNrtsAvgChangedInd(pNsi_sid) ;
				  rts_avg_changed amd_national_stock_items.RTS_AVG_CHANGED%type 
				    := getRtsAvgChangedInd(pNsi_sid) ;
				  condemn_avg_changed amd_national_stock_items.CONDEMN_AVG_CHANGED%type
				    := getCondemnAvgChangedInd(pNsi_sid) ;
				  cost_to_repair_off_base_chged amd_national_stock_items.COST_TO_REPAIR_OFF_BASE_CHGED%type 
				    := getCostToRepairOffBaseChgedInd(pNsi_sid) ;
				  time_to_repair_off_base_chged amd_national_stock_items.time_to_repair_off_base_chged%type
				    := getTimeToRepairOffBaseChgedInd(PNsi_sid) ;
					
				procedure deleteAnyRblPairs is
				begin
					 
					 delete from amd_rbl_pairs where 
					 		(old_nsn in (select nsn from amd_national_stock_items where nsi_sid = pNsi_sid)
							 and old_nsn <> pNsn)
					 or (new_nsn in (select nsn from amd_national_stock_items where nsi_sid = pNsi_sid) 
					 	 and new_nsn <> pNsn) ;
					 
				end deleteAnyRblPairs ;
				
				   	    
		begin
			debugMsg('doUpdate', pLineNo => 90) ;
			
			deleteAnyRblPairs ;
			
			update amd_national_stock_items set
			    criticality_changed = doUpdate.criticality_changed,
				nrts_avg_changed = doUpdate.nrts_avg_changed,
				rts_avg_changed = doUpdate.rts_avg_changed,
				condemn_avg_changed = doUpdate.condemn_avg_changed,
				cost_to_repair_off_base_chged = doUpdate.cost_to_repair_off_base_chged,
				time_to_repair_off_base_chged = doUpdate.time_to_repair_off_base_chged,
				prime_part_no   = pPartNo,
				fedc_cost       = fedcCost,
				nsn             = pNsn,
				item_type       = pItem_type,
				order_quantity  = pOrder_quantity,
				planner_code    = doUpdate.planner_code,
				smr_code        = pSmr_code,
				mic_code_lowest = pMic_code_lowest,
				last_update_dt  = sysdate,
				mmac			= pMmac,
				mtbdr			= mMtbdr,
				mtbdr_computed  = mMtbdr_computed,
				qpei_weighted	= mQpeiWeighted,
				condemn_avg_cleaned 		   = mCondemnAvgCleaned,
				criticality_cleaned   		   = mCriticalityCleaned,
				mtbdr_cleaned 		  		   = mMtbdrCleaned,
				nrts_avg_cleaned 	  		   = mNrtsAvgCleaned,
				cost_to_repair_off_base_cleand = mCostToRepairOffBaseCleand,
				time_to_repair_off_base_cleand = mTimeToRepairOffBaseCleand,
                amc_demand                     = mAmcDemand,
                amc_demand_cleaned             = mAmcDemandCleaned,
                wesm_indicator                 = mWesmIndicator,
				order_lead_time_cleaned 	   = mOrderLeadTimeCleaned,
				planner_code_cleaned 		   = doUpdate.planner_code_cleaned,
				rts_avg_cleaned 			   = mRtsAvgCleaned,
				smr_code_cleaned 			   = mSmrCodeCleaned,
				unit_cost_cleaned 			   = mUnitCostCleaned,
				condemn_avg 				   = mCondemnAvg,
				criticality 				   = mCriticality,
				nrts_avg 					   = mNrtsAvg,
				rts_avg 					   = mRtsAvg,
				cost_to_repair_off_base		   = mCostToRepairOffBase,
				time_to_repair_off_base		   = mTimeToRepairOffBase,
				action_code     			   = pAction_code
			where nsi_sid = pNsi_sid;
		end doUpdate ;
		
	begin
		debugMsg('UpdtNsiPrimePartData',pLineNo => 100) ;
		if (IsPrimePart(pPrime_ind)) then
			fedcCost := getFedcCost(pPartNo);
			
			verifyData ;
			

			begin
				 doUpdate (planner_code_cleaned => mPlannerCodeCleaned, planner_code => pPlannerCode);
			exception when others then
				if sqlcode = -2291 then
				   <<constraintError>>
				   declare
				   		  msg varchar2(50) ;
						  planner_code amd_planners.planner_code%type ;
				   begin
				       -- figurr out which foreign key does not have a parent
					   if instr(sqlerrm,'FK04') > 0  then
						  if substr(pNsn,1,3) = 'NSL' then
						  	 mPlannerCodeCleaned := amd_defaults.NSL_PLANNER_CODE ;
						  else
						     mPlannerCodeCleaned := amd_defaults.NSN_PLANNER_CODE ;
						  end if ;
						  doUpdate (planner_code_cleaned => mPlannerCodeCleaned, planner_code => pPlannerCode) ;
						  return SUCCESS ;
					   elsif instr(sqlerrm,'FK03') > 0 then
						  if substr(pNsn,1,3) = 'NSL' then
						  	 planner_code := amd_defaults.NSL_PLANNER_CODE ;
						  else
						     planner_code := amd_defaults.NSN_PLANNER_CODE ;
						  end if ;
						  doUpdate(planner_code_cleaned => mPlannerCodeCleaned, planner_code => planner_code) ;
					   	  return SUCCESS ;
					   elsif instr(sqlerrm,'FK02') > 0 then
					   	  msg := 'no parent for partNo=' || pPartNo ;
					   elsif instr(sqlerrm,'FK01') > 0 then
					   	  msg := 'no parent for nsn=' || pNsn ;
					   else
					   	   msg := 'Unknown' ;
					   end if ;
					   mRC := pReturn_code ;
					   ErrorMsg(pSqlfunction => 'UpdtNsiPrimePartData',
							pTableName => 'amd_national_stock_items',
							pError_location => 170,
							pKey_1 => pPartNo,
							pKey_2 => to_char(pNsi_sid),
							pKey_3 => msg) ;
						raise ;
					end constraintError ;
				else
				   mRC := pReturn_code ;
				   ErrorMsg(pSqlfunction => 'UpdtNsiPrimePartData',
						pTableName => 'amd_national_stock_items',
						pError_location => 180,
						pKey_1 => pPartNo,
						pKey_2 => to_char(pNsi_sid),
						pKey_3 => 'plannerCodeCleaned=' || mPlannerCodeCleaned) ;
					raise ;
				end if ;
			end ;
		end if;

		return SUCCESS;

	exception
		when others then
		   mRC := pReturn_code ;
		   ErrorMsg(pSqlfunction => 'UpdtNsiPrimePartData',
				pTableName => 'amd_national_stock_items',
				pError_location => 190,
				pKey_1 => pPartNo,
				pKey_2 => to_char(pNsi_sid),
				pKey_3 => 'nsn=' || pNsn) ;
			raise ;
	end UpdtNsiPrimePartData;


	function InsertNatStkItem(
							pNsi_sid out amd_national_stock_items.nsi_sid%type,
							pNsn in amd_spare_parts.nsn%type,
							pItem_type in amd_national_stock_items.item_type%type,
							pOrder_quantity in amd_national_stock_items.order_quantity%type,
							pPlanner_code in amd_national_stock_items.planner_code%type,
							pSmr_code in amd_national_stock_items.smr_code%type,
							pTactical in amd_national_stock_items.tactical%type,
							pMic_code_lowest in amd_national_stock_items.mic_code_lowest%type,
							pMmac in amd_national_stock_items.mmac%type) RETURN NUMBER is

		result number := SUCCESS;
		nsiGroupSid number;

		function GetNsiSid return amd_national_stock_items.nsi_sid%type is
			nsi_sid amd_national_stock_items.nsi_sid%type := null;
		begin
			select amd_nsi_sid_seq.CURRVAL
			into nsi_sid
			from dual;
			return nsi_sid;
		end GetNsiSid;

	begin -- InsertNatStkItem
	    debugMsg('InsertNatStkItem', pLineNo => 110) ;
		nsiGroupSid := amd_default_effectivity_pkg.NewGroup;

		begin
			INSERT INTO AMD_NATIONAL_STOCK_ITEMS
			(
				nsn,
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
                wesm_indicator
			)
			VALUES
			(
				NULL, -- nsn
				Amd_Clean_Data.GetAddIncrement(pNsn),
				Amd_Clean_Data.GetAmcBaseStock(pNsn),
				Amd_Clean_Data.GetAmcDaysExperience(pNsn),
                mAmcDemand,
                mAmcDemandCleaned,
				Amd_Clean_Data.GetCapabilityRequirement(pNsn),
				mCriticalityCleaned,
				Amd_Defaults.DISTRIB_UOM,
				Amd_Clean_Data.GetDlaDemand(pNsn),
				Amd_Clean_Data.GetCurrentBackorder(pNsn),
				Amd_Clean_Data.GetFedcCost(pNsn),
				pItem_type,
				Amd_Clean_Data.GetItemType(pNsn),
				Amd_Clean_Data.GetMicCodeLowest(pNsn),
				mMtbdrCleaned,
				Amd_Clean_Data.GetNomenclature(pNsn),
				mOrderLeadTimeCleaned,
				pOrder_Quantity,
				Amd_Defaults.ORDER_QUANTITY,
				Amd_Clean_Data.GetOrderUom(pNsn),
				pPlanner_code,
				mPlannerCodeCleaned,
				NULL, -- prime_part_no
				Amd_Defaults.QPEI_WEIGHTED,
				Amd_Clean_Data.GetRuInd(pNsn),
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
				Amd_Clean_Data.GetTimeToRepairOnBaseAvg(pNsn),
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
                mWesmIndicator
			);
		exception
			when others then
			   mRC := amd_spare_parts_pkg.CREATE_NATSTKITEM_ERR ;
			   ErrorMsg(pSqlfunction => 'insert',
					pTableName => 'amd_national_stock_items',
					pError_location => 200) ;
			   raise ;
		end InsertNsi;

		pNsi_sid := GetNsiSid();

		return SUCCESS;
	end InsertNatStkItem;


	function ChgCurNsn2TempNsn(
							pNsiSid in amd_nsns.nsi_sid%type) return number is
	begin
	    debugMsg('ChgCurNsn2TempNsn(' || pNsiSid || ')', pLineNo => 120) ;
		update amd_nsns set
			nsn_type = amd_spare_parts_pkg.TEMPORARY_NSN
		where nsi_sid = pNsiSid and nsn_type = amd_spare_parts_pkg.CURRENT_NSN;
		return SUCCESS;
	exception
		when others then
		   mRC := amd_spare_parts_pkg.UNABLE_TO_CHG_NSN_TYPE ;
		   ErrorMsg(pSqlfunction => 'update',
				pTableName => 'amd_nsns',
				pError_location => 210,
				pKey_1 => to_char(pNsiSid)) ;
		   raise ;
	end ChgCurNsn2TempNsn;


	function InsertAmdNsn(
							pNsi_sid in amd_nsns.nsi_sid%type,
							pNsn in amd_nsns.nsn%type,
							pNsn_type in amd_nsns.nsn_type%type ) return number is

		result number ;

	begin
	    debugMsg('InsertAmdNsn(' || pNsi_sid || ', ' || pNsn || ', ' || pNsn_type, pLineNo => 130) ;
	    if pNsn_type = amd_spare_parts_pkg.CURRENT_NSN then
		   result:= ChgCurNsn2TempNsn(pNsiSid => pNsi_sid);
		end if;
		if result = SUCCESS then
			insert into amd_nsns
			(
				nsn,
				nsn_type,
				nsi_sid,
				creation_date
			)
			values
			(
				pNsn,
				pNsn_type,
				pNsi_sid,
				sysdate
			);
			return SUCCESS;
		end if;
		return result;
	exception
		when others then
		   mRC := amd_spare_parts_pkg.UNABLE_TO_INSERT_AMD_NSNS ;
		   ErrorMsg(pSqlfunction => 'insert',
				pTableName => 'amd_nsns',
				pError_location => 220,
				pKey_1 => to_char(pNsi_Sid),
				pKey_2 => pNsn,
				pKey_3 => pNsn_type) ;
		   raise ;
	end InsertAmdNsn;


	function UpdateAmdNsn(
							pNsi_sid in amd_nsns.nsi_sid%type,
							pNsn in amd_nsns.nsn%type,
							pNsn_type in amd_nsns.nsn_type%type ) return number is
		result number;
	begin
		debugMsg('UpdateAmdNsn(' || pNsi_sid || ', ' || pNsn || ', ' || pNsn_type || ')', pLineNo => 140) ;
		if pNsn_type = amd_spare_parts_pkg.CURRENT_NSN then
		   result:= ChgCurNsn2TempNsn(pNsiSid => pNsi_sid);
		end if ;
		if result = SUCCESS then
			update amd_nsns set
				nsn_type = pNsn_type
			where nsi_sid = pNsi_sid and nsn = pNsn;
			return SUCCESS;
		end if;
		return result;

	exception
		when others then
		   mRC := amd_spare_parts_pkg.UNABLE_TO_INSERT_AMD_NSNS ;
		   ErrorMsg(pSqlfunction => 'update',
				pTableName => 'amd_nsns',
				pError_location => 230,
				pKey_1 => to_char(pNsi_Sid),
				pKey_2 => pNsn) ;
		   raise ;
	end UpdateAmdNsn;


	function CreateNationalStockItem(
							pNsi_sid out amd_national_stock_items.nsi_sid%type,
							pNsn in amd_spare_parts.nsn%type,
							pItem_type in amd_national_stock_items.item_type%type,
							pOrder_quantity in amd_national_stock_items.order_quantity%type,
							pPlanner_code in amd_national_stock_items.planner_code%type,
							pSmr_code in amd_national_stock_items.smr_code%type,
							pTactical in amd_national_stock_items.tactical%type,
							pMic_code_lowest in amd_national_stock_items.mic_code_lowest%type,
							pNsn_type in amd_nsns.nsn_type%type,
							pMmac in amd_national_stock_items.mmac%type) RETURN NUMBER is
		result number := SUCCESS;

	begin
		result := InsertNatStkItem(pNsi_sid => pNsi_sid,
					 pNsn => pNsn,
					 pItem_type => pItem_type,
					 pOrder_quantity => pOrder_quantity,
					 pPlanner_code => pPlanner_code,
					 pSmr_code => pSmr_code,
					 pTactical => pTactical,
					 pMic_code_lowest => pMic_code_lowest,
					 pMmac => pMmac) ;					 

		if result = SUCCESS then
		   amd_default_effectivity_pkg.SetNsiEffects(pNsi_sid);
		   if pNsn_type = amd_spare_parts_pkg.CURRENT_NSN then
		   	  result := amd_spare_parts_pkg.ChgCurNsn2TempNsn(
							pNsiSid => pNsi_sid);
		   end if;
		   if result = SUCCESS then
		   	  result := InsertAmdNsn(pNsi_sid => pNsi_sid, pNsn => pNsn, pNsn_type => pNsn_type);
		   end if;
		end if;

		return result;

	end CreateNationalStockItem;

	-- forward declare the old insertRow method, which is now private, so it can be used in
	-- the new public insertRow method
	FUNCTION InsertRow
                (pPart_no IN VARCHAR2,
                pMfgr IN VARCHAR2,
                pDate_icp IN DATE,
                pDisposal_cost IN NUMBER,
                pErc IN VARCHAR2,
                pIcp_ind IN VARCHAR2,
                pNomenclature IN VARCHAR2,
                pOrder_lead_time IN NUMBER,
				pOrder_quantity IN NUMBER,
                pOrder_uom IN VARCHAR2,
				pPrime_ind IN VARCHAR2,
                pScrap_value IN NUMBER,
                pSerial_flag IN VARCHAR2,
                pShelf_life IN NUMBER,
                pUnit_cost IN NUMBER,
                pUnit_volume IN NUMBER,
                pNsn IN VARCHAR2,
				pNsn_type IN VARCHAR2,
                pItem_type IN VARCHAR2,
                pSmr_code IN VARCHAR2,
                pPlanner_code IN VARCHAR2,
				pMic_code_lowest IN VARCHAR2,
				pAcquisition_advice_code IN VARCHAR2,
				pMmac IN VARCHAR2,
				pUnitOfIssue IN VARCHAR2) return number ;
				
	FUNCTION InsertRow
                (pPart_no IN VARCHAR2,
                pMfgr IN VARCHAR2,
                pDate_icp IN DATE,
                pDisposal_cost IN NUMBER,
                pErc IN VARCHAR2,
                pIcp_ind IN VARCHAR2,
                pNomenclature IN VARCHAR2,
                pOrder_lead_time IN NUMBER,
				pOrder_quantity IN NUMBER,
                pOrder_uom IN VARCHAR2,
				pPrime_ind IN VARCHAR2,
                pScrap_value IN NUMBER,
                pSerial_flag IN VARCHAR2,
                pShelf_life IN NUMBER,
                pUnit_cost IN NUMBER,
                pUnit_volume IN NUMBER,
                pNsn IN VARCHAR2,
				pNsn_type IN VARCHAR2,
                pItem_type IN VARCHAR2,
                pSmr_code IN VARCHAR2,
                pPlanner_code IN VARCHAR2,
				pMic_code_lowest IN VARCHAR2,
				pAcquisition_advice_code IN VARCHAR2,
				pMmac IN VARCHAR2,
				pUnitOfIssue IN VARCHAR2,
				pMtbdr in number,
				pMtbdr_computed in number,
  				pQpeiWeighted in number,
  				pCondemnAvgCleaned in number,
  				pCriticalityCleaned in number,
  				pMtbdrCleaned in number,
  				pNrtsAvgCleaned in number,
  				pCosToRepairOffBaseCleand in number,
  				pTimeToRepairOffBaseCleand in  number,
  				pOrderLeadTimeCleaned in number,
  				pPlannerCodeCleaned in amd_national_stock_items.planner_code_cleaned%type,
  				pRtsAvgCleaned in number,
  				pSmrCodeCleaned in amd_national_stock_items.smr_code_cleaned%type,
  				pUnitCostCleaned in number,
  				pCondemnAvg in number,
  				pCriticality in number,
  				pNrtsAvg in number,
  				pRtsAvg in number,
				pCostToRepairOffBase in number,
				pTimeToRepairOffBase in number,
                pAmcDemand in number,
                pAmcDemandCleaned in number,
                pWesmIndicator in varchar2) return number is
	begin
		 -- By overriding the insertRow and updateRow routines all that needs to be done
		 -- is to set the member variables to the values passed in and then invoke
		 -- the old insertRow method, which is now private, That way I don't have to pass parameters just get the data
		 -- from these global member variables.
		 mArgs := 'insertRow(' || pPart_no || ', ' ||
                pMfgr || ', ' ||
                pDate_icp || ', ' ||
                pDisposal_cost || ', ' ||
                pErc || ', ' ||
                pIcp_ind || ', ' ||
                pNomenclature || ', ' ||
                pOrder_lead_time || ', ' ||
				pOrder_quantity || ', ' ||
                pOrder_uom || ', ' ||
				pPrime_ind || ', ' ||
                pScrap_value || ', ' ||
                pSerial_flag || ', ' ||
                pShelf_life || ', ' ||
                pUnit_cost || ', ' ||
                pUnit_volume || ', ' ||
                pNsn || ', ' ||
				pNsn_type || ', ' ||
                pItem_type || ', ' ||
                pSmr_code || ', ' ||
                pPlanner_code || ', ' ||
				pMic_code_lowest || ', ' ||
				pAcquisition_advice_code || ', ' ||
				pMmac || ', ' ||
				pUnitOfIssue || ', ' ||
				pMtbdr || ', ' ||
				pMtbdr_computed || ', ' ||
  				pQpeiWeighted || ', ' ||
  				pCondemnAvgCleaned || ', ' ||
  				pCriticalityCleaned || ', ' ||
  				pMtbdrCleaned || ', ' ||
  				pNrtsAvgCleaned || ', ' ||
  				pCosToRepairOffBaseCleand || ', ' ||
  				pTimeToRepairOffBaseCleand || ', ' ||
  				pOrderLeadTimeCleaned || ', ' ||
  				pPlannerCodeCleaned || ', ' ||
  				pRtsAvgCleaned || ', ' ||
  				pSmrCodeCleaned || ', ' ||
  				pUnitCostCleaned || ', ' ||
  				pCondemnAvg || ', ' ||
  				pCriticality || ', ' ||
  				pNrtsAvg || ', ' ||
  				pRtsAvg || ', ' ||
                pAmcDemand || ', ' ||
                pAmcDemandCleaned || ',' ||
                pWesmIndicator || ')' ;
		 mMtbdr 		   		   	:= pMtbdr ;
		 mMtbdr_computed			:= pMtbdr_computed ;
  		 mQpeiWeighted 	   		   	:= pQpeiWeighted ;
  		 mCondemnAvgCleaned 		:= pCondemnAvgCleaned ;
  		 mCriticalityCleaned   		:= pCriticalityCleaned ;
  		 mMtbdrCleaned 		 		:= pMtbdrCleaned ;
		 mNrtsAvgCleaned  			:= pNrtsAvgCleaned ;
		 mCostToRepairOffBaseCleand := pCosToRepairOffBaseCleand ;
  		 mTimeToRepairOffBaseCleand := pTimeToRepairOffBaseCleand ;
         mAmcDemand                 := pAmcDemand ;
         mAmcDemandCleaned          := pAmcDemandCleaned ;
         mWesmIndicator             := pWesmIndicator ;
  		 mOrderLeadTimeCleaned 		:= pOrderLeadTimeCleaned ;
  		 mPlannerCodeCleaned   		:= pPlannerCodeCleaned ;
		 mRtsAvgCleaned 	 		:= pRtsAvgCleaned ;
  		 mSmrCodeCleaned 			:= pSmrCodeCleaned ;
  		 mUnitCostCleaned			:= pUnitCostCleaned ;
  		 mCondemnAvg				:= pCondemnAvg ;
  		 mCriticality				:= pCriticality ;
  		 mNrtsAvg					:= pNrtsAvg ;
  		 mRtsAvg					:= pRtsAvg ;
		 mCostToRepairOffBase		:= pCostToRepairOffBase ;
		 mTimeToRepairOffBase		:= pTimeToRepairOffBase ;
		 
		 return InsertRow
                (pPart_no,
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
				pUnitOfIssue) ;
				
	end InsertRow ;

	-- forward declare the old updateRow method, which is now private, so it can be used in
	-- the new public updateRow method
	FUNCTION UpdateRow
                (pPart_no IN VARCHAR2,
                pMfgr IN VARCHAR2,
                pDate_icp IN DATE,
                pDisposal_cost in number,
                pErc IN VARCHAR2,
                pIcp_ind IN VARCHAR2,
                pNomenclature IN VARCHAR2,
                pOrder_lead_time IN NUMBER,
				pOrder_quantity IN NUMBER,
                pOrder_uom IN VARCHAR2,
				pPrime_ind IN VARCHAR2,
                pScrap_value IN NUMBER,
                pSerial_flag IN VARCHAR2,
                pShelf_life IN NUMBER,
                pUnit_cost IN NUMBER,
                pUnit_volume IN NUMBER,
                pNsn IN VARCHAR2,
				pNsn_type IN VARCHAR2,
                pItem_type IN VARCHAR2,
                pSmr_code IN VARCHAR2,
                pPlanner_code IN VARCHAR2,
				pMic_code_lowest IN VARCHAR2,
				pAcquisition_advice_code IN VARCHAR2,
				pMmac IN VARCHAR2,
				pUnitOfIssue IN VARCHAR2) return number ;

	FUNCTION UpdateRow
                (pPart_no IN VARCHAR2,
                pMfgr IN VARCHAR2,
                pDate_icp IN DATE,
                pDisposal_cost IN NUMBER,
                pErc IN VARCHAR2,
                pIcp_ind IN VARCHAR2,
                pNomenclature IN VARCHAR2,
                pOrder_lead_time IN NUMBER,
				pOrder_quantity IN NUMBER,
                pOrder_uom IN VARCHAR2,
				pPrime_ind IN VARCHAR2,
                pScrap_value IN NUMBER,
                pSerial_flag IN VARCHAR2,
                pShelf_life IN NUMBER,
                pUnit_cost IN NUMBER,
                pUnit_volume IN NUMBER,
                pNsn IN VARCHAR2,
				pNsn_type IN VARCHAR2,
                pItem_type IN VARCHAR2,
                pSmr_code IN VARCHAR2,
                pPlanner_code IN VARCHAR2,
				pMic_code_lowest IN VARCHAR2,
				pAcquisition_advice_code IN VARCHAR2,
				pMmac IN VARCHAR2,
				pUnitOfIssue IN VARCHAR2,
				pMtbdr in number,
				pMtbdr_computed in number,
  				pQpeiWeighted in number,
  				pCondemnAvgCleaned in number,
  				pCriticalityCleaned in number,
  				pMtbdrCleaned in number,
  				pNrtsAvgCleaned in number,
  				pCosToRepairOffBaseCleand in number,
  				pTimeToRepairOffBaseCleand in  number,
  				pOrderLeadTimeCleaned in number,
  				pPlannerCodeCleaned in amd_national_stock_items.planner_code_cleaned%type,
  				pRtsAvgCleaned in number,
  				pSmrCodeCleaned in amd_national_stock_items.smr_code_cleaned%type,
  				pUnitCostCleaned in number,
  				pCondemnAvg in number,
  				pCriticality in number,
  				pNrtsAvg in number,
  				pRtsAvg in number,
				pCostToRepairOffBase in number,
				pTimeToRepairOffBase in number,
                pAmcDemand in number,
                pAmcDemandCleaned in number,
                pWesmIndicator in varchar2) return number is
				
				lineNo number := 0 ;
				result number ;
	begin
		 -- By overriding the updateRow andinsertRow routines all that needs to be done
		 -- is to set the member variables to the values passed in and then invoke
		 -- the old updateRow method, which is now private, That way I don't have to pass parameters just get the data
		 -- from these global member variables.
		 mArgs := 'UpdateRow(' || pPart_no || ', ' ||
                pMfgr || ', ' ||
                pDate_icp || ', ' ||
                pDisposal_cost || ', ' ||
                pErc || ', ' ||
                pIcp_ind || ', ' ||
                pNomenclature || ', ' ||
                pOrder_lead_time || ', ' ||
				pOrder_quantity || ', ' ||
                pOrder_uom || ', ' ||
				pPrime_ind || ', ' ||
                pScrap_value || ', ' ||
                pSerial_flag || ', ' ||
                pShelf_life || ', ' ||
                pUnit_cost || ', ' ||
                pUnit_volume || ', ' ||
                pNsn || ', ' ||
				pNsn_type || ', ' ||
                pItem_type || ', ' ||
                pSmr_code || ', ' ||
                pPlanner_code || ', ' ||
				pMic_code_lowest || ', ' ||
				pAcquisition_advice_code || ', ' ||
				pMmac || ', ' ||
				pUnitOfIssue || ', ' ||
				pMtbdr || ', ' ||
				pMtbdr_computed || ', ' ||
  				pQpeiWeighted || ', ' ||
  				pCondemnAvgCleaned || ', ' ||
  				pCriticalityCleaned || ', ' ||
  				pMtbdrCleaned || ', ' ||
  				pNrtsAvgCleaned || ', ' ||
  				pCosToRepairOffBaseCleand || ', ' ||
  				pTimeToRepairOffBaseCleand || ', ' ||
  				pOrderLeadTimeCleaned || ', ' ||
  				pPlannerCodeCleaned || ', ' ||
  				pRtsAvgCleaned || ', ' ||
  				pSmrCodeCleaned || ', ' ||
  				pUnitCostCleaned || ', ' ||
  				pCondemnAvg || ', ' ||
  				pCriticality || ', ' ||
  				pNrtsAvg || ', ' ||
  				pRtsAvg || ', ' ||
				pCostToRepairOffBase || ', ' ||
				pTimeToRepairOffBase || ', ' ||
                pAmcDemand || ', ' ||
                pAmcDemandCleaned || ')' ;
		 lineNo := lineNo + 1 ;mMtbdr 		   		   	:= pMtbdr ;
		 lineNo := lineNo + 1 ;mMtbdr_computed			:= pMtbdr_computed ;
  		 lineNo := lineNo + 1 ;mQpeiWeighted 	   		   	:= pQpeiWeighted ;
  		 lineNo := lineNo + 1 ;mCondemnAvgCleaned 		:= pCondemnAvgCleaned ;
  		 lineNo := lineNo + 1 ;mCriticalityCleaned   		:= pCriticalityCleaned ;
  		 lineNo := lineNo + 1 ;mMtbdrCleaned 		 		:= pMtbdrCleaned ;
		 lineNo := lineNo + 1 ;mNrtsAvgCleaned  			:= pNrtsAvgCleaned ;
		 lineNo := lineNo + 1 ;mCostToRepairOffBaseCleand := pCosToRepairOffBaseCleand ;
  		 lineNo := lineNo + 1 ;mTimeToRepairOffBaseCleand := pTimeToRepairOffBaseCleand ;
         lineNo := lineNo + 1 ;mAmcDemand   := pAmcDemand ;
         lineNo := lineNo + 1 ;mAmcDemandCleaned := pAmcDemandCleaned ;
         lineNo := lineNo + 1 ;mWesmIndicator := pWesmIndicator ;
  		 lineNo := lineNo + 1 ;mOrderLeadTimeCleaned 		:= pOrderLeadTimeCleaned ;
  		 lineNo := lineNo + 1 ;mPlannerCodeCleaned   		:= pPlannerCodeCleaned ;
		 lineNo := lineNo + 1 ;mRtsAvgCleaned 	 		:= pRtsAvgCleaned ;
  		 lineNo := lineNo + 1 ;mSmrCodeCleaned 			:= pSmrCodeCleaned ;
  		 lineNo := lineNo + 1 ;mUnitCostCleaned			:= pUnitCostCleaned ;
  		 lineNo := lineNo + 1 ;mCondemnAvg				:= pCondemnAvg ;
  		 lineNo := lineNo + 1 ;mCriticality				:= pCriticality ;
  		 lineNo := lineNo + 1 ;mNrtsAvg					:= pNrtsAvg ;
  		 lineNo := lineNo + 1 ;mRtsAvg					:= pRtsAvg ;
		 lineNo := lineNo + 1 ;mCostToRepairOffBase		:= pCostToRepairOffBase ;
		 lineNo := lineNo + 1 ;mTimeToRepairOffBase		:= pTimeToRepairOffBase ;
		 
		 return UpdateRow
                (pPart_no,
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
				pUnitOfIssue) ;
	exception when others then
		   ErrorMsg(pSqlfunction => 'updateRow',
				pTableName => '',
				pError_location => 240) ;
		   return UPDT_ERRX ;
	end UpdateRow ;

	function InsertRow(
							pPart_no in varchar2,
							pMfgr in varchar2,
							pDate_icp in date,
							pDisposal_cost in number,
							pErc in varchar2,
							pIcp_ind in varchar2,
							pNomenclature in varchar2,
							pOrder_lead_time in number,
							pOrder_quantity in number,
							pOrder_uom in varchar2,
							pPrime_ind in varchar2,
							pScrap_value in number,
							pSerial_flag in varchar2,
							pShelf_life in number,
							pUnit_cost in number,
							pUnit_volume in number,
							pNsn in varchar2,
							pNsn_type in varchar2,
							pItem_type in varchar2,
							pSmr_code in varchar2,
							pPlanner_code in varchar2,
							pMic_code_lowest in varchar2,
							pAcquisition_advice_code in varchar2,
							pMmac in varchar2,
							pUnitOfIssue in varchar2) RETURN NUMBER is

		/* Although the following variables are local to the InsertRow
		  procedure, you will see them referenced as InsertRow.variable_name.
		  This was done to improve readability.  A similar approach is used
		  for package constants: package_name.constant_name.
		 */
		prime_ind_cleaned    amd_nsi_parts.prime_ind_cleaned%type := null;
		result               number := SUCCESS;
		tactical             amd_spare_parts.tactical%type := 'N';
		unit_cost_defaulted  amd_spare_parts.unit_cost_defaulted%type := null;
		part_already_exists	 exception ;


		/* Put a wrapper on the amd_utils.InsertErrorMsg procedure, so it is
			more specific to the InsertRow function.  Output gets stored
			into amd_load_details and amd_load_status.
		*/

		function InsertAmdNsiParts(
							pNsi_sid in amd_nsi_parts.nsi_sid%type) return number is

			result number := SUCCESS;
		begin
			return insertNsiParts(pNsi_sid => pNsi_sid,
				   	   pPart_no => pPart_no,
				   	   pPrime_ind => pPrime_ind,
					   pPrime_ind_cleaned => prime_ind_cleaned,
				   	   pBadRc => amd_spare_parts_pkg.UNABLE_TO_INSERT_AMD_NSI_PARTS);
		end InsertAmdNsiParts;


		function InsertEquivalentPartData(
							pNsi_sid in amd_nsi_parts.nsi_sid%type) return number is
		begin
			return InsertAmdNsiParts(pNsi_sid);
		end InsertEquivalentPartData;


		function DoPhysicalInsert return number is

			nsi_sid amd_national_stock_items.nsi_sid%type := null;

			function IsPrimeReplacingExistingOne(
							pNsi_sid in amd_nsi_parts.nsi_sid%type,
							pCurrent_prime_part_no out amd_nsi_parts.part_no%type) return boolean is

				prime_ind amd_nsi_parts.prime_ind%type := null;
			begin
				begin
					select
						part_no,
						prime_ind
					into pCurrent_prime_part_no, prime_ind
					from amd_nsi_parts
					where nsi_sid = pNsi_sid
					and prime_ind = amd_defaults.PRIME_PART
					and unassignment_date is null;
					return true;
				exception
					when no_data_found then
						return false;
				end;
			end IsPrimeReplacingExistingOne;


			function PrepareDataForInsert return number is
			begin

				-- todo prime_ind_cleaned will be set in a separate routine since it is
				-- so complicated
				-- InsertRow.prime_ind_cleaned := amd_clean_data.prime_ind(nsn);

				<<getTacticalInd>>
				begin
					InsertRow.tactical :=
							amd_validation_pkg.GetTacticalInd(
								amd_preferred_pkg.GetPreferredValue(mUnitCostCleaned,
										  pUnit_cost,
										  InsertRow.unit_cost_defaulted),
								amd_preferred_pkg.GetPreferredValue(mSmrCodeCleaned,
										 pSmr_code)
								 );
				exception
					when others then
					   ErrorMsg(pSqlfunction => 'getTacticalInd',
							pError_location => 270) ;
					   raise ;
				end getTacticalInd;

				if pPlanner_code is not null then
					if not amd_validation_pkg.IsValidPlannerCode(pPlanner_code) then
						if amd_validation_pkg.AddPlannerCode(pPlanner_code) != amd_validation_pkg.SUCCESS then
							return amd_spare_parts_pkg.ADD_PLANNER_CODE_ERR;
						end if;
					end if;
				end if;

				if pOrder_uom is not null then
					if not amd_validation_pkg.IsValidUomCode(pOrder_uom) then
						if amd_validation_pkg.AddUomCode(pOrder_uom) != amd_validation_pkg.SUCCESS then
							return amd_spare_parts_pkg.ADD_UOM_CODE_ERR;
						end if;
					end if;
				end if;
				return SUCCESS;
			exception
				when others then
				       mRC := amd_spare_parts_pkg.UNABLE_TO_PREP_DATA ;
					   ErrorMsg(pSqlfunction => 'prepareDataForInsert',
							pError_location => 280) ;
					   raise ;
			end prepareDataForInsert;


			function NatStkItemExists(
							pNsn in amd_spare_parts.nsn%type,
							pNsi_sid out amd_nsns.nsi_sid%type) return boolean is
			begin
				select nsi_sid
				into pNsi_sid
				from amd_nsns
				where nsn = pNsn
				and nsi_sid is not null;
				return true;
			exception
				when no_data_found then
					return false;
			end NatStkItemExists;


			function InsertSparePart return number is
			begin
				insert into amd_spare_parts
				(
					part_no,
					mfgr,
					date_icp,
					disposal_cost,
					disposal_cost_defaulted,
					erc,
					icp_ind,
					nomenclature ,
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
					unit_of_issue
				)
				values
				(
					pPart_no,
					pMfgr,
					pDate_icp,
					pDisposal_cost,
					amd_defaults.DISPOSAL_COST,
					pErc,
					pIcp_ind,
					pNomenclature ,
					pOrder_lead_time,
					amd_defaults.GetOrderLeadTime(pItem_type),
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
					sysdate,
					pAcquisition_advice_code,
					pUnitOfIssue
				);
				return SUCCESS;
			exception
				when DUP_VAL_ON_INDEX then	   
					   writeMsg(pTableName => 'amd_spare_parts', pError_location => 290,
								pKey1 => 'pPart_no=' || pPart_no,
								pKey2 => 'tried to insert a part that was already there' ) ;
					   return UpdateRow
									(pPart_no,
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
									pUnitOfIssue) ;
				when others then
					   ErrorMsg(pSqlfunction => 'insert',
							pTableName => 'amd_spare_parts',
							pError_location => 300,
							pKey_1 => pPart_no) ;
					   raise ;
			end InsertSparePart;


			function UpdatePrimePartData(
							pNsi_sid in amd_national_stock_items.nsi_sid%type) return number is

				result number := SUCCESS;


			begin -- UpdatePrimePartData
			    <<insertNsiParts>>
				begin
					result := InsertAmdNsiParts(pNsi_sid);
				exception
					when others then
					   mRC := INS_AMD_NSI_PARTS_ERR ;
					   ErrorMsg(pSqlfunction => 'insert',
							pTableName => 'amd_nsi_parts',
							pError_location => 310,
							pKey_1 => to_char(pNsi_sid)) ;
					   raise ;
				end insertNsiParts;
				
				if result = SUCCESS then
					result := UpdtNsiPrimePartData (pPrime_ind => pPrime_ind,
		 					  pNsi_sid => pNsi_sid,
		 					  pPartNo => pPart_no,
		 					  pNsn => pNsn,
							  pItem_type => pItem_type,
							  pOrder_quantity => pOrder_quantity,
							  pPlannerCode => pPlanner_code,
							  pSmr_code => pSmr_code,
							  pMic_code_lowest => pMic_code_lowest,
							  pAction_code => amd_defaults.INSERT_ACTION,
							  pReturn_code => amd_spare_parts_pkg.UNABLE_TO_PRIME_INFO,
							  pMmac => pMmac) ;					 
				end if;
				return result;
			exception
				when others then
					   mRC := INSERT_PRIMEPART_ERR ;
					   ErrorMsg(pSqlfunction => 'updatePrimePartData',
							pError_location => 320) ;
					   raise ;
			end UpdatePrimePartData;


			function UpdatePrimePartData(
							pNsn in amd_national_stock_items.nsn%type,
							pNsi_sid in amd_nsns.nsi_sid%type,
							pCurrent_prime_part_no in amd_nsi_parts.part_no%type) return number is

				result number := SUCCESS;

				function MakePrimeAnEquivalentPart return number is
						 curPrime amd_nsi_parts.PART_NO%type ;
						 
				begin
					-- first make sure the prime_part is flagged as logically deleted 
					update amd_national_stock_items
					set action_code = amd_defaults.DELETE_ACTION,
					last_update_dt = sysdate
					where nsi_sid = pNsi_sid
					and prime_part_no =
						  (select part_no from amd_nsi_parts
						   where nsi_sid = pNsi_sid
						   and (prime_ind = amd_defaults.PRIME_PART or prime_ind_cleaned = amd_defaults.PRIME_PART)
						   and unassignment_date is null ) ;
						  
						    
					update amd_nsi_parts set
						unassignment_date = sysdate
					where
						nsi_sid = pNsi_sid
						and (prime_ind             = amd_defaults.PRIME_PART
								or prime_ind_cleaned = amd_defaults.PRIME_PART)
						and unassignment_date is null;

					return insertNsiParts(pNsi_sid => pNsi_sid,
						    pPart_no => pCurrent_prime_part_no,
							pPrime_ind => amd_defaults.NOT_PRIME_PART,
							pPrime_ind_cleaned => null,
							pBadRc => amd_spare_parts_pkg.UNASSIGN_OLD_PRIME_PART_ERR);

				end MakePrimeAnEquivalentPart;


			begin -- UpdatePrimePartData
				result := UpdtNsiPrimePartData (pPrime_ind => pPrime_ind,
	 					  pNsi_sid => pNsi_sid,
	 					  pPartNo => pPart_no,
	 					  pNsn => pNsn,
						  pItem_type => pItem_type,
						  pOrder_quantity => pOrder_quantity,
						  pPlannerCode => pPlanner_code,
						  pSmr_code => pSmr_code,
						  pMic_code_lowest => pMic_code_lowest,
						  pAction_code => amd_defaults.UPDATE_ACTION,
						  pReturn_code => amd_spare_parts_pkg.CANNOT_UPADATE_NAT_STCK_ITEMS,
						  pMmac => pMmac) ;					 

				if result != SUCCESS then
				   return result;
				end if;

				if pNsn_type = amd_spare_parts_pkg.CURRENT_NSN then
					result := amd_spare_parts_pkg.ChgCurNsn2TempNsn(pNsiSid => pNsi_sid);
					if result != SUCCESS then
						return result;
					end if;
				end if;

				begin
					result := amd_spare_parts_pkg.UpdateAmdNsn(pNsn_Type => pNsn_Type,
													 pNsi_Sid => pNsi_sid,
													 pNsn => pNsn ) ;
				exception
					when others then
					   mRC := CANNOT_UPDATE_AMD_NSNS ;
					   ErrorMsg(pSqlfunction => 'updateAmdNsn',
							pError_location => 330,
							pKey_1 => pNsn_Type,
							pKey_2 => to_char(pNsi_sid),
							pKey_3 => pNsn) ;
					   raise ;
				end update_amd_nsns;

				result := MakePrimeAnEquivalentPart();
				if result = SUCCESS then
					result := insertNsiParts(pNsi_sid => pNsi_sid,
				   	  			pPart_no => pPart_no,
								pPrime_ind => pPrime_ind,
								pPrime_ind_cleaned => null,
								pBadRc => amd_spare_parts_pkg.MAKE_NEW_PRIME_PART_ERR);
				end if;
				if result = SUCCESS then
					result := MakeNsnSameForAllParts(pNsi_sid => pNsi_sid, pNsn => pNsn );
				end if;
				return result;
			end UpdatePrimePartData;

		begin -- DoPhysicalInsert
			debugMsg('DoPhysicalInsert', pLineNo => 150) ;
			result := PrepareDataForInsert;

			if result = SUCCESS then
				if NatStkItemExists(pNsn => pNsn, pNsi_sid => DoPhysicalInsert.nsi_sid) then
					null ; -- OK do nothing
				else -- create one
				    result := CreateNationalStockItem(pNsi_sid => DoPhysicalInsert.nsi_sid,
			 			   	  pNsn => pNsn,
			 				  pItem_type => pItem_type,
			 				  pOrder_quantity => pOrder_quantity,
			 				  pPlanner_code => pPlanner_code,
			 				  pSmr_code => pSmr_code,
			 				  pTactical => InsertRow.tactical,
			 				  pMic_code_lowest => InsertRow.pMic_code_lowest,
							  pNsn_type => pNsn_type,
							  pMmac => pMmac) ;					 
				end if;
			end if;

			if result = SUCCESS then
				result := InsertSparePart();
			end if;

			if result = SUCCESS then
				if IsPrimePart(pPrime_ind) then
					declare
						current_prime_part_no amd_nsi_parts.part_no%type := null;
					begin
						if IsPrimeReplacingExistingOne(pNsi_sid => DoPhysicalInsert.nsi_sid,
								pCurrent_prime_part_no 	=> current_prime_part_no) then
							begin
								result := UpdatePrimePartData(pNsn => pNsn,
											pNsi_sid => DoPhysicalInsert.nsi_sid,
											pCurrent_prime_part_no => current_prime_part_no);
							exception when others then
							   mRC := UPD_PRIME_PART_ERR ;
							   ErrorMsg(pSqlfunction => 'updatePrimePartData',
									pError_location => 340,
									pKey_1 => pNsn,
									pKey_2 => to_char(DoPhysicalInsert.nsi_sid),
									pKey_3 => current_prime_part_no) ;
							   raise ;
							end UpdatePrimePartData;
						else
							begin
								result := UpdatePrimePartData(pNsi_sid => DoPhysicalInsert.nsi_sid);
							exception when others then
							   ErrorMsg(pSqlfunction => 'updatePrimePartData',
									pError_location => 350,
									pKey_1 => to_char(DoPhysicalInsert.nsi_sid)) ;
							   raise ;
							end UpdatePrimePartData;
						end if;
					end CheckForExistingPrime;
				else
					begin
						result := InsertEquivalentPartData(pNsi_sid => DoPhysicalInsert.nsi_sid);
					exception when others then
					   mRC := UPD_PRIME_PART_ERR ;
					   ErrorMsg(pSqlfunction => 'insertEquiivalentPartData',
							pError_location => 360,
							pKey_1 => to_char(DoPhysicalInsert.nsi_sid)) ;
					   raise ;
					end;
				end if;
			end if ;
			if result = SUCCESS then
				if pNsn is not null then
					begin
						result := UpdateNatStkItem(pNsn, amd_defaults.INSERT_ACTION,pPart_no);
					exception when others then
					   mRC := UPDATE_NATSTK_ERR ;
					   ErrorMsg(pSqlfunction => 'updateNatStkItem',
							pError_location => 370,
							pKey_1 => pNsn,
							pKey_2 => pPart_no) ;
					   raise ;
					end;
				end if;
			end if;

			return result;
		end DoPhysicalInsert;


		function DoLogicalInsert return number is
		begin

			result := UpdateRow
						(pPart_no,
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
						pUnitOfIssue) ;
						
			if result = SUCCESS then
				begin
					-- Make it look like an insert was just
					-- done.
					update amd_spare_parts set
						action_code = amd_defaults.INSERT_ACTION
					where part_no = pPart_no;
				exception
					when others then
					   mRC := LOGICAL_INSERT_FAILED ;
					   ErrorMsg(pSqlfunction => 'update',
					   		pTablename => 'amd_spare_parts',
							pError_location => 380,
							pKey_1 => pPart_no) ;
					   raise ;
				end LogicalInsert;
			end if;
			return result;
		end DoLogicalInsert;


		function IsPartMarkedAsDeleted return boolean is

			function GetActionCode return varchar2 is
				action_code varchar2(1);
			begin
				select action_code
				into action_code
				from amd_spare_parts
				where		part_no = pPart_no;
				return action_code;
			exception
				when NO_DATA_FOUND then
					return null;
			end GetActionCode;

		begin
			return (GetActionCode() = amd_defaults.DELETE_ACTION);
		end IsPartMarkedAsDeleted;

    begin -- <<<---- InsertRow
		amd_spare_parts_pkg.mDebug := true ;
		amd_utils.mDebugThreshold := 100000 ;
		debugMsg(mArgs, pLineNo => 5) ;

--		insertLoadDetail(pPart_No,pNsn,pPrime_Ind,'Insert');

		if IsPartMarkedAsDeleted() then
			result := DoLogicalInsert();
		else
			unassociateTmpNsn(pNsn);

			result := DoPhysicalInsert();
		end if;
		if result = SUCCESS then
		   declare
		   		  rc number ;
		   		  smrCodePreferred amd_national_stock_items.SMR_CODE%type :=
				            amd_preferred_pkg.GetPreferredValue(mSmrCodeCleaned, pSmr_code) ;
				  mtbdrPreferred amd_national_stock_items.MTBDR%type := 
                            amd_preferred_pkg.GetPreferredValue(mMtbdrCleaned,mMtbdr_computed, mMtbdr) ;
				  plannerCodePreferred amd_national_stock_items.PLANNER_CODE%type := 
                            amd_preferred_pkg.GetPreferredValue(mPlannerCodeCleaned,pPlanner_code) ;
				  indenture tmp_a2a_part_info.indenture%type := a2a_pkg.getIndenture(smrCodePreferred) ;
begin
		   		rc := a2a_pkg.InsertPartInfo(mfgr => pMfgr, part_no => pPart_no, unit_issue => pUnitOfIssue, 
				   	  				nomenclature => PNomenclature, smr_code => smrCodePreferred, nsn => pNsn, 
									planner_code => plannerCodePreferred, third_party_flag => a2a_pkg.THIRD_PARTY_FLAG, 
									mtbdr => mtbdrPreferred, indenture => indenture,
									price => amd_preferred_pkg.GetPreferredValue(mUnitCostCleaned,pUnit_cost) ) ;
				if rc = SUCCESS then
                    if amd_utils.ISSPOPRIMEPART(pPart_no) then
					    rc := a2a_pkg.InsertPartLeadTime(pPart_no,a2a_pkg.NEW_BUY,amd_preferred_pkg.GetPreferredValue( mOrderLeadTimeCleaned, pOrder_lead_time, amd_defaults.GetOrderLeadTime(pItem_type)) );
                        a2a_pkg.insertPartLeadTime(part_no => pPart_no, 
                            lead_time_type => a2a_pkg.REPAIR,
                            lead_time => amd_preferred_pkg.GetPreferredValue(mTimeToRepairOffBaseCleand, mTimeToRepairOffBase, amd_defaults.TIME_TO_REPAIR_OFFBASE), 
                            action_code => amd_defaults.INSERT_ACTION); 
                    else
					    rc := a2a_pkg.InsertPartLeadTime(pPart_no,a2a_pkg.NEW_BUY,amd_preferred_pkg.GetPreferredValue( pOrder_lead_time, amd_defaults.GetOrderLeadTime(pItem_type)) );
                    end if ;                        
				end if ;
				if rc = SUCCESS then
				   result := a2a_pkg.InsertPartPricing(pPart_no,a2a_pkg.AN_ORDER,amd_preferred_pkg.GetPreferredValue(mUnitCostCleaned,pUnit_cost)) ; -- used for SCM 4.2
				end if ;
		   end ;
 	    end if ;

		mDebug := false ;
		return result;

	exception
		when part_already_exists then
			 return SUCCESS ; -- ignore this error
		when others then
		   ErrorMsg(pSqlfunction => 'insertRow',
				pError_location => 390 ) ;
		   return mRC ;
	end InsertRow;


	function UpdateRow(
							pPart_no in varchar2,
							pMfgr in varchar2,
							pDate_icp in date,
							pDisposal_cost in number,
							pErc in varchar2,
							pIcp_ind in varchar2,
							pNomenclature in varchar2,
							pOrder_lead_time in number,
							pOrder_quantity in number,
							pOrder_uom in varchar2,
							pPrime_ind in varchar2,
							pScrap_value in number,
							pSerial_flag in varchar2,
							pShelf_life in number,
							pUnit_cost in number,
							pUnit_volume in number,
							pNsn in varchar2,
							pNsn_type in varchar2,
							pItem_type in varchar2,
							pSmr_code in varchar2,
							pPlanner_code in varchar2,
							pMic_code_lowest in varchar2,
							pAcquisition_advice_code in varchar2,
							pMmac in varchar2,
							pUnitOfIssue in varchar2) RETURN NUMBER is
                            

		/* Although the following variables are local to the UpdateRow
		  procedure, you will see them referenced as UpdateRow.variable_name.
		  This was done to improve readability.  A similar approach is used
		  for package constants: package_name.constant_name.
		 */
		nsiSid      amd_national_stock_items.nsi_sid%type := null;
		result      number := SUCCESS;
		tactical    amd_spare_parts.tactical%type := 'N';
        lineNumber  number := 0 ;


		/* Put a wrapper on the amd_utils.InsertErrorMsg procedure, so it is
			more specific to the UpdateRow function.  Output gets stored
			into amd_load_details and amd_load_status.
		*/


		function PrepareDataForUpdate return number is
			function GetSmrCode
				return amd_national_stock_items.smr_code%type is
				smr_code_cleaned	amd_national_stock_items.smr_code_cleaned%type;
			begin
				select smr_code_cleaned
				into smr_code_cleaned
				from amd_national_stock_items items
				where nsi_sid = nsiSid;
				return amd_preferred_pkg.GetPreferredValue(smr_code_cleaned,
					pSmr_code);
			exception
				when NO_DATA_FOUND then
					return null;
			end GetSmrCode;


			function GetUnitCost return amd_spare_parts.unit_cost%type is
				unit_cost_cleaned amd_national_stock_items.unit_cost_cleaned%type;
				unit_cost_defaulted amd_spare_parts.unit_cost_defaulted%type;
			begin
				begin
					select unit_cost_cleaned, unit_cost_defaulted
					into unit_cost_cleaned, unit_cost_defaulted
					from amd_national_stock_items
					where nsn = pNsn;
				exception
					when NO_DATA_FOUND then
						unit_cost_cleaned := null;
					when others then
						raise amd_spare_parts_pkg.UNIT_COST_CLEANED_VIA_NSN;
				end get_unit_cost_cleaned;
				return amd_preferred_pkg.GetPreferredValue(unit_cost_cleaned,
					pUnit_cost, unit_cost_defaulted);
			end GetUnitCost;

		begin -- PrepareDataForUpdate
			begin
				UpdateRow.tactical :=
					amd_validation_pkg.GetTacticalInd(GetUnitCost(),GetSmrCode() );
			exception
				when amd_spare_parts_pkg.UNIT_COST_CLEANED_VIA_NSN then
				   mRC := amd_spare_parts_pkg.CANNOT_GET_UNIT_COST_CLEANED ;
				   ErrorMsg(pSqlfunction => 'getTacticalInd',
						pError_location => 400 ) ;
				   raise ;
			end setTactical;

			if pPlanner_code is not null then
				if not amd_validation_pkg.IsValidPlannerCode(pPlanner_code) then
					if amd_validation_pkg.AddPlannerCode(pPlanner_code) != amd_validation_pkg.SUCCESS then
						return amd_spare_parts_pkg.ADD_PLANNER_CODE_ERR;
					end if;
				end if;
			end if;

			if pOrder_uom is not null then
				if not amd_validation_pkg.IsValidUomCode(pOrder_uom) then
					if amd_validation_pkg.AddUomCode(pOrder_uom) != amd_validation_pkg.SUCCESS then
						return amd_spare_parts_pkg.ADD_UOM_CODE_ERR;
					end if;
				end if;
			end if;

			return SUCCESS;
		exception when others then
		   mRC := amd_spare_parts_pkg.PREP_DATA_FOR_UPDT_ERR ;
		   ErrorMsg(pSqlfunction => 'prepareDataForUpdate',
				pError_location => 410 ) ;
		   raise ;
		end PrepareDataForUpdate;


		function UpdateAmdSparePartRow(
							pPartNo amd_spare_parts.part_no%type,
							pNsn amd_spare_parts.nsn%type) return number is
		begin
			debugMsg('updateAmdSparePartRow('||pPartNo||','||pNsn||')', pLineNo => 160);
			update amd_spare_parts set
				mfgr            = pMfgr,
				date_icp        = pDate_icp,
				disposal_cost   = pDisposal_cost,
           	erc             = pErc,
           	icp_ind         = pIcp_ind,
           	nomenclature    = pNomenclature ,
           	order_lead_time = pOrder_lead_time,
            order_lead_time_defaulted = amd_defaults.GETORDERLEADTIME(pItem_type),
           	order_uom       = pOrder_uom,
           	scrap_value     = pScrap_value,
           	serial_flag     = pSerial_flag,
           	shelf_life      = pShelf_life,
           	unit_cost       = pUnit_cost,
           	unit_volume     = pUnit_volume,
				tactical        = UpdateRow.tactical,
				action_code     = amd_defaults.UPDATE_ACTION,
				last_update_dt  = sysdate,
				nsn             = pNsn,
				acquisition_advice_code = pAcquisition_advice_code,
				unit_of_issue = pUnitOfIssue
			where part_no = pPartNo;

			return SUCCESS;
		exception when others then
		   mRC := amd_spare_parts_pkg.UPDT_SPAREPART_ERR ;
		   ErrorMsg(pSqlfunction => 'updateAmdSparePartRow',
				pError_location => 420 ) ;
		   raise ;
		end UpdateAmdSparePartRow;


		function UpdatePrimePartData return number is
		begin
		
			<<update_amd_nsns>>
			begin
				result := amd_spare_parts_pkg.UpdateAmdNsn(
					   pNsn_type => pNsn_type,
					   pNsi_sid => nsiSid,
					   pNsn => pNsn);
			exception when others then
			   mRC := amd_spare_parts_pkg.CANNOT_UPDATE_AMD_NSNS ;
			   ErrorMsg(pSqlfunction => 'updateAmdNsn',
					pError_location => 430 ) ;
		   	   raise ;
			end update_amd_nsns;

			return SUCCESS;
		exception when others then
		   mRC := amd_spare_parts_pkg.UPDT_PRIMEPART_ERR ;
		   ErrorMsg(pSqlfunction => 'updatePrimePartData',
				pError_location => 440 ) ;
	   	   raise ;
		end UpdatePrimePartData;


		function NsnChanged(
							pPartNo varchar2,
							pNsn varchar2) return boolean is
			nsn amd_nsns.nsn%type;
		begin
			debugMsg('nsnChanged('||pPartNo||','||pNsn||')', pLineNo => 170);
			select an.nsn
			into nsn
			from
				amd_nsi_parts anp,
				amd_nsns an
			where
				anp.nsi_sid = an.nsi_sid
				and anp.part_no = pPartNo
				and anp.unassignment_date is null
				and an.nsn_type = 'C';

			if nsn != pNsn then
				return true;
			else
				return false;
			end if;

		exception
			when NO_DATA_FOUND then
				return TRUE;
		end NsnChanged;


		function PrimeIndChanged return boolean is
			prime_ind amd_nsi_parts.prime_ind%type := null;
		begin
			debugMsg('primeIndChanged(' || prime_ind || ')', pLineNo => 180);

			select prime_ind
			into prime_ind
			from amd_nsi_parts
			where nsi_sid = nsiSid
			and part_no = pPart_no
			and unassignment_date is null;

			return (prime_ind != pPrime_ind);
		exception
			when no_data_found then
				return true;
		end;


		function UpdateNsnForPrimePart return number is
		/*
		IMPORTANT:  The prime part controls the value of
		the nsn column in amd_spare_parts. Whenever the value
		of the amd_spare_parts nsn column changes for a prime part, the
		following will happen:
				1.	Update the nsn column of amd_national_stock_items.
				2.	Using the amd_nsi_parts linked via nsi_sid update the
					nsn column of amd_spare_parts with the new value -
					i.e. update the prime part and its equivalent parts.
		*/
			result number := SUCCESS;

			function UpdtNsnOfNationalStockItems(
							pNsiSid number) return number is
			begin
				debugMsg('updtNsnOfNationalStockItems('||pNsn||','||pNsiSid||')', pLineNo => 190);
				update amd_national_stock_items set
					nsn = pNsn
				where nsi_sid = pNsiSid;
				return SUCCESS;
			exception when others then
			   mRC := amd_spare_parts_pkg.CANNOT_UPDT_NSN_NAT_STCK_ITEMS ;
			   ErrorMsg(pSqlfunction => 'update', pTableName => 'amd_national_stock_items',
					pError_location => 450 ) ;
		   	   raise ;
			end UpdtNsnOfNationalStockItems;

		begin -- UpdateNsnForPrimePart

			if result = SUCCESS then
				result := UpdtNsnOfNationalStockItems(nsiSid);
			end if;

			if result = SUCCESS then
				result := MakeNsnSameForAllParts(pNsi_sid => nsiSid,
					   	  						   pNsn => pNsn);
			end if;
			return result;
		exception when others then
		   mRC := amd_spare_parts_pkg.UPDT_NSN_PRIME_ERR ;
		   ErrorMsg(pSqlfunction => 'updateNsnForPrimePart',
				pError_location => 460 ) ;
	   	   raise ;
		end UpdateNsnForPrimePart;


		function UpdatePrimeInd return number is
			result number := SUCCESS;

			function UnassignPrimePart(
							pPart_no in amd_nsi_parts.part_no%type) return number is
			begin
				debugMsg('unassignPrimePart(' || pPart_no || ')', pLineNo => 200);

				update amd_nsi_parts set
					unassignment_date = sysdate
				where
					part_no = pPart_no
					and (prime_ind             = amd_defaults.PRIME_PART
							or prime_ind_cleaned = amd_defaults.PRIME_PART)
					and unassignment_date is null;
					
				-- Since this prime_part is unassigned logically delete the 
				-- national_stock_item
				update amd_national_stock_items
				set action_code = amd_defaults.DELETE_ACTION,
				last_update_dt = sysdate				
				where prime_part_no = pPart_no ;

				return SUCCESS;
			end UnassignPrimePart;

			function MakeCurrentPrimeIntoEquiv return number is
				result   number := SUCCESS;
				part_no  amd_nsi_parts.part_no%type := null;
			begin
				begin
					-- get the current Prime Part
					select part_no
					into part_no
					from amd_nsi_parts
					where nsi_sid = nsiSid
					and (prime_ind = amd_defaults.PRIME_PART
						or prime_ind_cleaned = amd_defaults.PRIME_PART)
					and unassignment_date is null;
				exception
					when no_data_found then
						/* This can occur when a prime has alreay become an
							equivalent part, before the NEW prime is processed.
							*/
						return SUCCESS;
					when others then
					   mRC := amd_spare_parts_pkg.UNABLE_TO_GET_PRIME_PART_X ;
					   ErrorMsg(pSqlfunction => 'select', pTableName => 'amd_nsi_parts',
							pError_location => 470,
							pKey_1 => to_char(nsiSid)) ;
		   	   		   raise ;
				end GetCurrentPrimePart;

				result := UnassignPrimePart(pPart_no => part_no);

				if result = SUCCESS then
					 result := insertNsiParts(pNsi_sid => nsiSid,
								pPart_no => part_no,
							   pPrime_ind => amd_defaults.NOT_PRIME_PART,
							   pPrime_ind_cleaned => null,
							   pBadRc =>amd_spare_parts_pkg.ASSIGN_PRIME_TO_EQUIV_ERR);
				end if;

				return result;

			end MakeCurrentPrimeIntoEquiv;


			function UpdatePrimePartNo return number is
				temp_prime_part_no amd_national_stock_items.prime_part_no%type := null;
			begin
				<<getPrimePart>>
				begin
				    -- check if the prime part has been set yet
					select part_no
					into temp_prime_part_no
					from amd_nsi_parts
					where nsi_sid = nsiSid
					and unassignment_date is null
					and (prime_ind = amd_defaults.PRIME_PART or prime_ind_cleaned = amd_defaults.PRIME_PART);
				exception
					when no_data_found then
				  	   null ; -- OK the prime_part_no has not been set yet
					when others then
					   mRC := amd_spare_parts_pkg.UNABLE_TO_GET_PRIME_PART ;
					   ErrorMsg(pSqlfunction => 'select', pTableName => 'amd_nsi_parts',
							pError_location => 480,
							pKey_1 => to_char(nsiSid)) ;
		   	   		   raise ;
				end getPrimePart ;
				
				if temp_prime_part_no != null then
				   begin
					   select prime_part_no
						into temp_prime_part_no
					   from amd_national_stock_items
					   where nsi_sid = nsiSid
					   and prime_part_no = temp_prime_part_no;
				   exception
					   when no_data_found then
							begin
							    /* This should not happen, but just in
								 * case this will gaurantee that the
								 * prime_part_no = part_no in
								 * amd_nsi_parts with prime_ind = 'Y'
								 */
								update amd_national_stock_items set
									prime_part_no  = temp_prime_part_no,
									last_update_dt = sysdate,
									action_code    = amd_defaults.UPDATE_ACTION
								where nsi_sid = nsiSid;
							exception when others then
							   mRC := amd_spare_parts_pkg.UPDT_NULL_PRIME_COLS_ERR ;
							   ErrorMsg(pSqlfunction => 'update', 
							   		pTableName => 'amd_national_stock_items',
									pError_location => 490,
									pKey_1 => to_char(nsiSid)) ;
				   	   		   raise ;
							end UpdateNationalStockItems;
					   when others then
						   mRC := amd_spare_parts_pkg.UNABLE_TO_GET_PRIME_PART ;
						   ErrorMsg(pSqlfunction => 'updatePrimePartNo', 
								pError_location => 500)  ;
			   	   		   raise ;
				   end;
				else
					-- the prime part is null, but it should get
					-- set with subsequent data
					begin
						update amd_national_stock_items set
							prime_part_no  = temp_prime_part_no,
							last_update_dt = sysdate,
							action_code    = amd_defaults.UPDATE_ACTION
						where nsi_sid = nsiSid;
					exception when others then
					   mRC := amd_spare_parts_pkg.UPDT_NULL_PRIME_COLS_ERR2 ;
					   ErrorMsg(pSqlfunction => 'update',
					   		pTableName => 'amd_national_stock_items', 
							pError_location => 510,
							pKey_1 => to_char(nsiSid))  ;
		   	   		   raise ;
					end UpdateNationalStockItems;
				end if ;
				return SUCCESS;
			end UpdatePrimePartNo;

		begin --  UpdatePrimeInd
			debugMsg('updatePrimeInd()', pLineNo => 210);
			if IsPrimePart(pPrime_ind) then
				result := MakeCurrentPrimeIntoEquiv();
				if result = SUCCESS then

					unassignPart(pPart_no);

					begin
						result := insertNsiParts(pNsi_sid => nsiSid,
							   	      pPart_no => pPart_no,
									  pPrime_ind => pPrime_ind,
									  pPrime_ind_cleaned => null,
									  pBadRc => amd_spare_parts_pkg.ASSIGN_NEW_PRIME_PART_ERR);
					end AssignNewPrimePart;

					begin
					    -- make sure action_code and last_update_dt get set too
						update amd_national_stock_items set
							prime_part_no = pPart_no,
							nsn           = pNsn,
							last_update_dt = sysdate,
							action_code = amd_defaults.UPDATE_ACTION
						where nsi_sid = nsiSid;
					exception when others then
					   mRC := amd_spare_parts_pkg.UPDT_ERR_NATIONAL_STK_ITEMS ;
					   ErrorMsg(pSqlfunction => 'update',
					   		pTableName => 'amd_national_stock_items', 
							pError_location => 520,
							pKey_1 => to_char(nsiSid))  ;
		   	   		   raise ;
					end UpdateNationalStockItems;

					if result = SUCCESS then
					    /* added invocation of MakeNsnSameForAllParts to
						 * to fix bug where equiv parts did not have the same
						 * nsn as the prime part.
						 */
						result := MakeNsnSameForAllParts(pNsi_sid => nsiSid,
							   	  									pNsn => pNsn);
					end if;

				end if;

			else
				result := UnassignPrimePart(pPart_no => pPart_no);
				if result = SUCCESS then
					begin
					   result := insertNsiParts(pNsi_sid => nsiSid,
					   		  	    pPart_no => pPart_no,
									pPrime_ind => pPrime_ind,
									pPrime_ind_cleaned => null,
									pBadRc => amd_spare_parts_pkg.ASSIGN_NEW_EQUIV_PART_ERR);
					end AssignNewEquivPart;

					result := UpdatePrimePartNo;

				end if;
			end if;

		return result;

		exception when others then
		   mRC := amd_spare_parts_pkg.UPD_NSI_PARTS_ERR ;
		   ErrorMsg(pSqlfunction => 'updatePrimeInd',
				pError_location => 530) ;
  	   	   raise ;
		end UpdatePrimeInd;


		function InsertNewNsn(
							pNsi_sid out amd_nsns.nsi_sid%type) return number is
			result number := SUCCESS;

			/* Get the nsi_sid using the part_no */
			function GetNsiSid return number is
			begin
				pNsi_sid := amd_utils.GetNsiSid(pPart_no => pPart_no);
				return SUCCESS;
			exception
				when no_data_found then
					 raise;
			    when others then
				   pNsi_sid := null;
				   mRC := amd_spare_parts_pkg.GET_NSISID_BY_PART_ERR ;
				   ErrorMsg(pSqlfunction => 'getNsiSid',
						pError_location => 540) ;
		  	   	   raise ;
			end GetNsiSid;

		begin -- InsertNewNsn
			result := GetNsiSid();

			if result = SUCCESS then
				result := InsertAmdNsn(pNsi_sid => pNsi_sid,
					   pNsn => pNsn,
					   pNsn_type => pNsn_type);
			end if;
			return result;
		exception
		    when no_data_found then
			    return CreateNationalStockItem(pNsi_sid => pNsi_sid,
	 			   	  pNsn => pNsn,
		 				  pItem_type => pItem_type,
		 				  pOrder_quantity => pOrder_quantity,
		 				  pPlanner_code => pPlanner_code,
		 				  pSmr_code => pSmr_code,
		 				  pTactical => UpdateRow.tactical,
		 				  pMic_code_lowest => pMic_code_lowest,
						  pNsn_type => pNsn_type,
						  pMmac => pMmac) ;					 

		    when others then
			   pNsi_sid := null;
			   mRC := amd_spare_parts_pkg.NEW_NSN_ERROR ;
			   ErrorMsg(pSqlfunction => 'insertNewNsn',
					pError_location => 550) ;
	  	   	   raise ;
		end InsertNewNsn;


		function GetNsiSid(
							pNsi_sid out amd_nsns.nsi_sid%type) return number is

		begin
			debugMsg('getNsiSid()', pLineNo => 220);
			pNsi_sid := amd_utils.GetNsiSid(pNsn => pNsn);
			debugMsg('pNsi_sid=' || pNsi_sid, pLineNo => 230) ;
			return SUCCESS;
		exception
			when no_data_found then
				raise ; -- must be a new nsn

			when others then
			   pNsi_sid := null;
			   ErrorMsg(pSqlfunction => 'getNsiSid',
					pError_location => 560) ;
	  	   	   raise ;
		end GetNsiSid;


		function CheckNsnAndPrimeInd return number is
			result number := SUCCESS;
		begin
			debugMsg('checkNsnAndPrimeInd()',pLineNo => 240);

			if NsnChanged(pPart_no,pNsn) then
			   if IsPrimePart(pPrime_ind) then
					if PrimeIndChanged() then
						result := UpdatePrimeInd();
						if result = SUCCESS then
							result := UpdateNsnForPrimePart();
						end if;
					else
						result := UpdateNsnForPrimePart();
					end if;
	
					result := MakeNsnSameForAllParts(nsiSid,pNsn);
				else
					unassignPart(pPart_no);
					
					result := insertNsiParts(pNsi_sid => nsiSid,
						   	      pPart_no => pPart_no,
								  pPrime_ind => pPrime_ind,
								  pPrime_ind_cleaned => null,
								  pBadRc => amd_spare_parts_pkg.ASSIGN_NEW_PRIME_PART_ERR);
				
					if PrimeIndChanged() then
						result := UpdatePrimeInd();
					end if;
				end if ;
			else
				if PrimeIndChanged() then
					result := UpdatePrimeInd();
				end if;
			end if;
			return result;
		exception
			when amd_spare_parts_pkg.CANNOT_FIND_PART then
			   ErrorMsg(pSqlfunction => 'CheckNsnAndPrimeInd',
					pError_location => 570) ;
	  	   	   raise ;
			when others then
			   mRC := amd_spare_parts_pkg.CHK_NSN_AND_PRIME_ERR2 ;
			   ErrorMsg(pSqlfunction => 'CheckNsnAndPrimeInd',
					pError_location => 580) ;
	  	   	   raise ;
		end CheckNsnAndPrimeInd;

		function updatePartLeadTime return number is
				 result number := SUCCESS ;
				 order_lead_time amd_spare_parts.order_lead_time%type ;
				 order_lead_time_cleaned amd_national_stock_items.order_lead_time_cleaned%type ;
                 time_to_repair_off_base amd_national_stock_items.TIME_TO_REPAIR_OFF_BASE%type ;
                 time_to_repair_off_base_cleand amd_national_stock_items.TIME_TO_REPAIR_OFF_BASE_CLEAND%type ;
		begin
			 select parts.order_lead_time, items.order_lead_time_cleaned, 
                items.TIME_TO_REPAIR_OFF_BASE, items.TIME_TO_REPAIR_OFF_BASE_CLEAND 
			 into order_lead_time, order_lead_time_cleaned,
             time_to_repair_off_base, time_to_repair_off_base_cleand
			 from amd_spare_parts parts, amd_national_stock_items items
			 where parts.part_no = pPart_no
			 and parts.nsn = items.nsn ;
			 
			 if amd_utils.isDiff(order_lead_time,pOrder_lead_time)
			 or amd_utils.isDiff(order_lead_time_cleaned,mOrderLeadTimeCleaned) then
			 	result := a2a_pkg.UpdatePartLeadTime(pPart_no,a2a_pkg.NEW_BUY,amd_preferred_pkg.GetPreferredValue(mOrderLeadTimeCleaned, pOrder_lead_time, amd_defaults.GetOrderLeadTime(pItem_type))) ;
			 end if ;
        
            if amd_utils.ISSPOPRIMEPART(pPart_no) 
            and ( amd_utils.isDiff(time_to_repair_off_base,mTimeToRepairOffBase)
                  or amd_utils.isDiff(time_to_repair_off_base_cleand, mTimeToRepairOffBaseCleand)
                )
            then
                /* update the REPAIR */
                a2a_pkg.insertPartLeadTime(part_no => pPart_no,
                    lead_time_type => a2a_pkg.REPAIR,
                    lead_time => amd_preferred_pkg.GetPreferredValue(mTimeToRepairOffBaseCleand, mTimeToRepairOffBase, amd_defaults.TIME_TO_REPAIR_OFFBASE),
                    action_code => amd_defaults.UPDATE_ACTION);             
            end if ;
			 
			 return result ;
		exception
			when standard.NO_DATA_FOUND then
				 return result ;
			when others then
			   ErrorMsg(pSqlfunction => 'updatePartLeadTime',
					pError_location => 590,
					pKey_1 => pPart_no,
					pKey_2 => pNsn) ;
				raise ;
		end updatePartLeadTime ;
		
		function updatePartPricing return number is
				 unit_cost amd_spare_parts.unit_cost%type ;
				 unit_cost_cleaned amd_national_stock_items.unit_cost_cleaned%type ;
		begin
			 select unit_cost, unit_cost_cleaned into unit_cost, unit_cost_cleaned
			 from amd_spare_parts parts, amd_national_stock_items items
			 where parts.part_no = pPart_no
			 and parts.nsn = items.nsn ;
			 
			 if amd_utils.isDiff(unit_cost,pUnit_Cost)
			 or amd_utils.isDiff(unit_cost_cleaned, pUnit_cost) then
			 	result := a2a_pkg.UpdatePartPricing(pPart_no,a2a_pkg.AN_ORDER,amd_preferred_pkg.GetPreferredValue(mUnitCostCleaned, pUnit_Cost)) ;
			 end if ;
			 return result ;
		exception
			when standard.no_data_found then
				 return result ; 
			when others then
			   mRC := amd_spare_parts_pkg.CANNOT_UPDATE_PART_PRICING ; 
			   ErrorMsg(pSqlfunction => 'updatePartPricing',
					pError_location => 600) ;
			   raise ;
		end updatePartPricing ;
		
		procedure validateInput is
	                part_no amd_spare_parts.part_no%type ;
                mfgr amd_spare_parts.mfgr%type ;
                date_icp  amd_spare_parts.DATE_ICP%type ;
                disposal_cost amd_spare_parts.DISPOSAL_COST%type ;
                erc amd_spare_parts.ERC%type ; 
                icp_ind amd_spare_parts.ICP_IND%type ; 
                nomenclature amd_spare_parts.NOMENCLATURE%type ;
                order_lead_time amd_spare_parts.ORDER_LEAD_TIME%type ;
				order_quantity amd_national_stock_items.ORDER_QUANTITY%type ;
                order_uom amd_spare_parts.ORDER_UOM%type ;
				prime_ind amd_nsi_parts.PRIME_IND%type ;
                scrap_value amd_spare_parts.SCRAP_VALUE%type ;
                serial_flag amd_spare_parts.SERIAL_FLAG%type ;
                shelf_life amd_spare_parts.SHELF_LIFE%type ;
                unit_cost amd_spare_parts.UNIT_COST%type ;
                unit_volume amd_spare_parts.UNIT_VOLUME%type ;
                nsn amd_spare_parts.NSN%type ;
				nsn_type amd_nsns.NSN_TYPE%type ;
                item_type amd_national_stock_items.ITEM_TYPE%type ;
                smr_code amd_national_stock_items.SMR_CODE%type ;
                planner_code amd_national_stock_items.PLANNER_CODE%type ;
				mic_code_lowest amd_national_stock_items.MIC_CODE_LOWEST%type ;
				acquisition_advice_code amd_spare_parts.ACQUISITION_ADVICE_CODE%type ;
				mmac amd_national_stock_items.MMAC%type ;
				unit_Of_Issue amd_spare_parts.UNIT_OF_ISSUE%type ;
				mtbdr amd_national_stock_items.MTBDR%type ;
				mtbdr_computed amd_national_stock_items.mtbdr_computed%type ;
  				qpei_weighted amd_national_stock_items.QPEI_WEIGHTED%type ;
  				condemn_avg_cleaned amd_national_stock_items.CONDEMN_AVG_CLEANED%type ;
  				criticality_cleaned amd_national_stock_items.CRITICALITY_CLEANED%type ;
  				mtbdr_cleaned amd_national_stock_items.MTBDR_CLEANED%type ;
  				nrts_avg_cleaned amd_national_stock_items.NRTS_AVG_CLEANED%type ;
  				cost_to_repair_off_base_cleand amd_national_stock_items.COST_TO_REPAIR_OFF_BASE_CLEAND%type ;
  				time_to_repair_off_base_cleand amd_national_stock_items.TIME_TO_REPAIR_OFF_BASE_CLEAND%type ;
  				order_Lead_Time_cleaned amd_national_stock_items.ORDER_LEAD_TIME_CLEANED%type ;
  				planner_code_cleaned amd_national_stock_items.planner_code_cleaned%type ;
  				rts_avg_cleaned amd_national_stock_items.RTS_AVG_CLEANED%type ;
  				smr_code_cleaned amd_national_stock_items.smr_code_cleaned%type ;
  				unit_cost_cleaned amd_national_stock_items.UNIT_COST_CLEANED%type ;
  				condemn_avg amd_national_stock_items.CONDEMN_AVG%type ;
  				criticality amd_national_stock_items.CRITICALITY%type ;
  				nrts_avg amd_national_stock_items.NRTS_AVG%type ;
  				rts_avg amd_national_stock_items.RTS_AVG%type ;
				lineNo number := 0 ;
				result number ;
		begin
			lineNo := lineNo + 1;part_no := pPart_no ;
			lineNo := lineNo + 1;mfgr :=   pMfgr ;
			lineNo := lineNo + 1;date_icp := pDate_icp ;
			lineNo := lineNo + 1;disposal_cost := pDisposal_cost ;
			lineNo := lineNo + 1;erc := pErc ;
			lineNo := lineNo + 1;icp_ind :=  pIcp_ind ;
			lineNo := lineNo + 1;nomenclature :=  pNomenclature ;
			lineNo := lineNo + 1;order_lead_time := pOrder_lead_time ;
			lineNo := lineNo + 1;order_quantity :=	pOrder_quantity ;
            lineNo := lineNo + 1;order_uom :=    pOrder_uom ;
			lineNo := lineNo + 1;prime_ind :=	pPrime_ind ;
            lineNo := lineNo + 1;scrap_value :=    pScrap_value ;
            lineNo := lineNo + 1;serial_flag :=    pSerial_flag ;
            lineNo := lineNo + 1;shelf_life := pShelf_life ;
            lineNo := lineNo + 1;unit_cost :=    pUnit_cost ;
            lineNo := lineNo + 1;unit_volume :=    pUnit_volume ;
            lineNo := lineNo + 1;nsn :=    pNsn ;
			lineNo := lineNo + 1;nsn_type :=	pNsn_type ;
            lineNo := lineNo + 1;item_type :=    pItem_type ;
            lineNo := lineNo + 1;smr_code :=    pSmr_code ;
            lineNo := lineNo + 1;planner_code :=    pPlanner_code ;
			lineNo := lineNo + 1;mic_code_lowest :=	pMic_code_lowest ;
			lineNo := lineNo + 1;acquisition_advice_code :=	pAcquisition_advice_code ;
			lineNo := lineNo + 1;mmac :=	pMmac ;
			lineNo := lineNo + 1;unit_of_issue :=	pUnitOfIssue ;
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
		exception when others then
		   ErrorMsg(pSqlfunction => 'validateInput',
				pError_location => 610) ;
		   raise ;
		end validateInput ;
		
	begin -- <<<---- UpdateRow
		validateInput ;
		debugMsg(mArgs  || ')',pLineNo => 250);
--		insertLoadDetail(pPart_No,pNsn,pPrime_Ind,'Update');

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
        lineNumber := 10 ;
		if (hasPartMoved(pPart_no,pNsn)) then
			unassociateTmpNsn(pNsn);
			unassignPart(pPart_no);
		end if;

		-- retrieve the nsi_sid right away, since it will be make
		-- retrieving data from the amd_national_stock_items,
		-- amd_nsns, and amd_nsi_parts easier
        lineNumber := 20 ;
		begin
			result := GetNsiSid(pNsi_sid => nsiSid);
			if result != SUCCESS then
				return result;
			end if;
		exception
			when no_data_found then
				/* This must be a new nsn - add it to amd_nsns
					using part_no to get the current nsi_sid
				*/
				result := InsertNewNsn(pNsi_sid => nsiSid);
				if result != SUCCESS then
					return result;
				end if;
		end;

		/* The nsi_sid should not be null, but just leave this code in
			as a backup parachute!
			*/
        lineNumber := 30 ;
		if nsiSid is null then
		   ErrorMsg(pSqlfunction => 'getNsiSid',
				pError_location => 620) ;
		   raise cannotGetNsiSid ;
		end if;

        lineNumber := 40 ;
		if result = SUCCESS then
			result := CheckNsnAndPrimeInd();
		end if;

        lineNumber := 50 ;
		if result = SUCCESS then
			result := PrepareDataForUpdate();
		end if;

        lineNumber := 60 ;
		if result = SUCCESS then
			result := UpdateAmdSparePartRow(pPart_no,pNsn);
		end if;

        lineNumber := 60 ;
		if result = SUCCESS then
			result := UpdtNsiPrimePartData (pPrime_ind => pPrime_ind,
 					  pNsi_sid => nsiSid,
 					  pPartNo => pPart_no,
 					  pNsn => pNsn,
					  pItem_type => pItem_type,
					  pOrder_quantity => pOrder_quantity,
					  pPlannerCode => pPlanner_code,
					  pSmr_code => pSmr_code,
					  pMic_code_lowest => pMic_code_lowest,
					  pAction_code => amd_defaults.UPDATE_ACTION,
					  pReturn_code => amd_spare_parts_pkg.UPDATE_NATSTK_ERR,
					  pMmac => pMmac) ;					 
		end if ;
        lineNumber := 80 ;
		if result = SUCCESS then
			result := amd_spare_parts_pkg.UpdateAmdNsn(
				   pNsn_type => pNsn_type,
				   pNsi_sid => nsiSid,
				   pNsn => pNsn);
		end if;

        lineNumber := 90 ;
		if result = SUCCESS then
			if pNsn is not null then
				result:= UpdateNatStkItem(pNsn,amd_defaults.UPDATE_ACTION,pPart_no);
			end if;
		end if;

		-- Update amd_national_stock_items.action_code = 'D' for any other
		-- nsi_sid this part came off of that has no parts assigned to it.
		-- An nsi_sid w/o assigned parts is a "deleted" nsi_sid.
		--
        lineNumber := 100 ;
		debugMsg('updating action code to D',pLineNo => 260) ;
		update amd_national_stock_items set
			action_code    = 'D',
			last_update_dt = sysdate
		where
			action_code != 'D'
			and nsi_sid in
				(select nsi_sid
				from amd_nsi_parts
				where part_no = pPart_no
					and nsi_sid != nsiSid
				minus
				select nsi_sid
				from amd_nsi_parts
				where
					nsi_sid in
						(select nsi_sid from amd_nsi_parts
						where part_no = pPart_no)
					and unassignment_date is null);

        lineNumber := 110 ;
		if result = SUCCESS then
		   declare
		   		  rc number ;
				  smrCodePreferred amd_national_stock_items.SMR_CODE%type := amd_preferred_pkg.GetPreferredValue(mSmrCodeCleaned,pSmr_code) ;
				  plannerCodePreferred amd_national_stock_items.PLANNER_CODE%type := amd_preferred_pkg.GetPreferredValue(mPlannerCodeCleaned,pPlanner_code) ;
				  mtbdrPreferred amd_national_stock_items.MTBDR%type := amd_preferred_pkg.GetPreferredValue(mMtbdrCleaned,mMtbdr_computed,mMtbdr) ;
				  indenture tmp_a2a_part_info.indenture%type := a2a_pkg.getIndenture(smrCodePreferred) ;
		   begin
		        lineNumber := 120 ;
                if mDebug then
           	        a2a_pkg.setDebug('Y') ; -- turn on debugging for a2a
                else
                    a2a_pkg.setDebug('N') ;                    
                end if ;                    
			    rc := a2a_pkg.UpdatePartInfo(mfgr => pMfgr, part_no => pPart_no, 
							unit_issue => pUnitOfIssue, nomenclature => pNomenclature, 
							smr_code => smrCodePreferred, nsn => pNsn, planner_code => plannerCodePreferred, 
							third_party_flag => a2a_pkg.THIRD_PARTY_FLAG, mtbdr => mtbdrPreferred, indenture => indenture,
							price => amd_preferred_pkg.GetPreferredValue(mUnitCostCleaned, pUnit_Cost)) ;
		        lineNumber := 130 ;
			   if rc = SUCCESS then	
			   	  rc := updatePartLeadTime ;
			   end if ;
		        lineNumber := 140 ;
			   if rc = SUCCESS then
				   result:= updatePartPricing ; -- used for SCM 4.2
			   end if ;
		   end ;
		
		end if ;
        lineNumber := 150 ;
		return result;
	exception
		when others then
		   ErrorMsg(pSqlfunction => 'updateRow',
				pError_location => 630,
                pKey_1  => lineNumber) ;
			return mRC ;
	end UpdateRow;


	function DeleteRow(
							pPart_no in varchar2,
							pNomenclature in varchar2,
							pMfgr in varchar2 ) return number is

		result number := SUCCESS ;
		nsn amd_spare_parts.nsn%type := null;

		/* Put a wrapper on the amd_utils.InsertErrorMsg procedure, so it is
			more specific to the DeleteRow function.  Output gets stored
			into amd_load_details and amd_load_status.
		*/

		function GetNsn return amd_spare_parts.nsn%type is
			nsn amd_spare_parts.nsn%type := null;
		begin
			select nsn
			into nsn
			from amd_spare_parts
			where part_no = pPart_no;
			return nsn;
		end GetNsn;

	begin
        if mDebug then
            writeMsg(pTableName => 'amd_spare_parts', pError_location => 631,
                    pKey1 => 'deleteRow',
                    pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                    pKey3 => pPart_no ) ;
        end if ;                    
                
		mArgs := 'DeleteRow(' || pPart_no || ', ' || pMfgr || ', ' || pNomenclature || ')' ;
               
        if amd_utils.ISSPOPRIMEPART(pPart_no) then
            /* delete the REPAIR */
            a2a_pkg.insertPartLeadTime(part_no => pPart_no,
                    lead_time_type => a2a_pkg.REPAIR,
                    lead_time => 0,
                    action_code => amd_defaults.DELETE_ACTION);
        end if ;                    
                             
		result := a2a_pkg.DeletePartLeadTime(pPart_no) ;
		if result = SUCCESS and a2a_pkg.wasPartSentYorN(pPart_no) = 'Y' then
		   result := a2a_pkg.DeletePartPricing(pPart_no) ; -- used for SCM 4.2
		end if ;
		insertLoadDetail(pPart_No,'nsn','pPrimeInd','Delete');
		nsn := GetNsn();

		-- nsn is NULLed to facilitate temp nsns turning into current nsns. When a
		-- temp nsn becomes current the nsn/nsi_sid association needs to be broken
		-- and this helps facilitate that when it may happen at a later time.
		--
		<<updateAmdSpareParts>>
		begin
			update amd_spare_parts set
				action_code    = amd_defaults.DELETE_ACTION,
				nsn            = NULL,
				last_update_dt = sysdate
			where part_no = pPart_no;
		exception when others then
		   ErrorMsg(pSqlfunction => 'update', pTableName => 'amd_spare_parts',
				pError_location => 640, pKey_1 => pPart_no) ;
		   raise ;
		end updateAmdSpareParts ;

		unassignPart(pPart_no);

		if nsn is not null then
		   result := UpdateNatStkItem(nsn, amd_defaults.DELETE_ACTION);
		else
			result := SUCCESS;
		end if;
		if result = SUCCESS then
	        result := a2a_pkg.DeletePartInfo(pPart_no, pNomenclature) ;
		end if ;
        if mDebug then
            writeMsg(pTableName => 'amd_spare_parts', pError_location => 632,
                    pKey1 => 'deleteRow',
                    pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
                    pKey3 => pPart_no ) ;
        end if ;                    
		return result ;
	exception when others then
		   ErrorMsg(pSqlfunction => 'deleteRow',
				pError_location => 650) ;
			return mRC ;
	end DeleteRow ;
    
    function getQtyDue(primePartNo in varchar2) return number is
        qtyDue number ;
        thePrime cat1.PRIME%type ;
    begin
        select sum(qty_due) qty_due, prime_part_no into qtyDue, thePrime
        from tmp1,  amd_national_stock_items, amd_spare_parts
        where 
        returned_voucher is null
        and status = 'O' 
        and tcn = 'LBR'
        and upper(substr(to_sc,1,3)) = 'C17'
        and upper(substr(to_sc,8,3)) not in ('MRC','SUP','TST') 
        and upper(substr(to_sc,8,6)) not in ('CODLGB','ROTLGB') 
        and tmp1.from_part = amd_spare_parts.part_no 
        and amd_spare_parts.action_code in ('A','C') 
        and amd_spare_parts.nsn = amd_national_stock_items.nsn
        and amd_national_stock_items.action_code in ('A','C')
        group by prime_part_no
        having prime_part_no = primePartNo ;
    			
        return qtyDue ;
    exception
        when standard.NO_DATA_FOUND then
             return 0 ;
    end getQtyDue ;
    

	procedure loadCurrentBackOrder(debug in boolean := False) is
    
            type qtyDueRec is record  (
                primePartNo   cat1.prime%type,
                qtyDue number
            ) ;
            
            type primePartNoTab is table of cat1.prime%type ;
            primePartNos primePartNoTab ;
            
            type qtyDueTab is table of number ;
            quantitiesDue qtyDueTab ;
            
			TB constant varchar2(1) := chr(9);   -- tab character
			  
			curDueCnt number := 0 ;
			curTmpCnt number := 0 ;

			
			  cursor curDue is
			  select cat1.prime primePartNo, 
				sum(nvl(req1.qty_due,0) + nvl(req1.qty_reserved,0)) + getQtyDue(cat1.prime) DUE 
				from req1, cat1 
				where
				req1.select_from_part = cat1.part and 
				req1.request_id not like 'KIT%' and 
				req1.mils_source_dic is not null and 
				req1.select_from_sc like 'C17%' and 
				req1.status in ('U','H','O','R') and 
				req1.request_priority <= 5 and
				upper(substr(req1.select_from_sc,8,6)) not in ('CODLGB','ROTLGB') and
				upper(substr(req1.select_from_sc,8,3)) not in ('MRC','SUP','TST') and
				cat1.SOURCE_CODE = 'F77'
				group by cat1.prime ;

			  cursor curTmp1QtyDue is
				select prime_part_no primePartNo, qty_due qtyDue   from 
				(
				select sum(qty_due) qty_due, prime prime_part_no 
				from tmp1, cat1, amd_national_stock_items, amd_spare_parts
				where from_part = cat1.PART
				and returned_voucher is null
				and status = 'O' 
				and tcn = 'LBR'
			    and upper(substr(to_sc,1,3)) = 'C17'
				and upper(substr(to_sc,8,3)) not in ('MRC','SUP','TST') 
				and upper(substr(to_sc,8,6)) not in ('CODLGB','ROTLGB') 
				and from_part = amd_spare_parts.part_no 
				and amd_spare_parts.action_code in ('A','C') 
				and amd_spare_parts.nsn = amd_national_stock_items.nsn
				group by prime)
				where prime_part_no not in ( 
				  select distinct cat1.prime primePartNo 
					from req1, cat1 
					where
					req1.select_from_part = cat1.part and 
					req1.request_id not like 'KIT%' and 
					req1.mils_source_dic is not null and 
					req1.select_from_sc like 'C17%' and 
					req1.status in ('U','H','O','R') and 
					req1.request_priority <= 5 and
					cat1.SOURCE_CODE = 'F77') ;

		
			  
	begin
		writeMsg(pTableName => 'amd_spare_parts', pError_location => 660,
				pKey1 => 'loadCurrentBackorder',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
				
	    update amd_national_stock_items
	    set current_backorder = null ;
		
		writeMsg(pTableName => 'amd_spare_parts', pError_location => 670,
			pKey1 => 'curDue',
			pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
            
	    commit ;
            
        open curDue ;
        fetch curDue bulk collect into primePartNos, quantitiesDue ;
        close curDue ;
                    
        if primePartNos.first is not null then
            FORALL indx IN primePartNos.first .. primePartNos.last
                    update amd_national_stock_items
                    set current_backorder =	quantitiesDue(indx) 
                    where prime_part_no = primePartNos(indx) ;
        end if ;
        
        curDueCnt := sql%rowcount ;
                    
		writeMsg(pTableName => 'amd_spare_parts', pError_location => 690,
			pKey1 => 'curDue',
			pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
            pKey3 => 'curDueCnt=' || to_char(curDueCnt) ) ;
        commit ;            
		
		writeMsg(pTableName => 'amd_spare_parts', pError_location => 700,
			pKey1 => 'curTmp1QtyDue',
			pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
            
        open curTmp1QtyDue ;
        fetch curTmp1QtyDue bulk collect into primePartNos, quantitiesDue ;
        close curTmp1QtyDue ;
        
        if primePartNos.first is not null then
            forall indx in primePartNos.first .. primePartNos.last
                update amd_national_stock_items
                set current_backorder =	quantitiesDue(indx)
                where prime_part_no = primePartNos(indx) ;
        end if ;
        
        curTmpCnt := sql%rowcount ;
            
		writeMsg(pTableName => 'amd_spare_parts', pError_location => 720,
			pKey1 => 'curTmp1QtyDue',
			pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
            pKey3 => 'curTmpCnt=' || to_char(curTmpCnt) ) ;
			
		writeMsg(pTableName => 'amd_spare_parts', pError_location => 730,
				pKey1 => 'loadCurrentBackorder',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'curDueCnt=' || to_char(curDueCnt),
				pKey4 => 'curTmpCnt=' || to_char(curTmpCnt))  ;
				
		commit ;
	end loadCurrentBackOrder ;

	procedure version is
	begin
		 writeMsg(pTableName => 'amd_spare_parts_pkg', 
		 		pError_location => 740, pKey1 => 'amd_spare_parts_pkg', pKey2 => '$Revision:   1.94  $') ;
		 dbms_output.put_line('amd_spare_parts_pkg: $Revision:   1.94  $') ;
	end version ;

    function getVersion return varchar2 is
    begin
        return '$Revision:   1.94  $' ;
    end getVersion ;
    
begin
	 <<getDebug>>
	 declare
	 		param amd_param_changes.PARAM_VALUE%type ;
	 begin
	 		select param_value into param from amd_param_changes where param_key = 'debugSpareParts' ;
			mDebug := (param = '1') ;  
	 exception when others then
	 		   mDebug := false ;
	 end getDebug ;
	 
end amd_spare_parts_pkg;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_SPARE_PARTS_PKG;

CREATE PUBLIC SYNONYM AMD_SPARE_PARTS_PKG FOR AMD_OWNER.AMD_SPARE_PARTS_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_SPARE_PARTS_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_SPARE_PARTS_PKG TO AMD_WRITER_ROLE;


