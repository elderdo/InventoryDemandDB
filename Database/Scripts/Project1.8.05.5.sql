-- "Set define off" turns off substitution variables. 
Set define off; 

CREATE OR REPLACE PACKAGE AMD_OWNER.Amd_Location_Part_Override_Pkg AS
 /*
      $Author:   zf297a  $
	$Revision:   1.11  $
        $Date:   Oct 25 2006 10:53:04  $
    $Workfile:   AMD_LOCATION_PART_OVERRIDE_PKG.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_LOCATION_PART_OVERRIDE_PKG.pks.-arc  $
/*   
/*      Rev 1.11   Oct 25 2006 10:53:04   zf297a
/*   Defined constants with anchored declarations using the %type attribute.  Made loadOverrideUsers a public procedure.
/*   
/*      Rev 1.10   Aug 24 2006 10:33:28   zf297a
/*   Added a constant for the loc_sid warehouse value
/*   
/*      Rev 1.9   Jun 09 2006 11:55:42   zf297a
/*   added interface version
/*   
/*      Rev 1.8   Apr 28 2006 13:15:54   zf297a
/*   Added the interface for loadRspZeroTslA2A
/*   
/*      Rev 1.7   Apr 21 2006 13:50:40   zf297a
/*   Added isInTmpA2A, isInTmpA2AYorN, loadZeroTslByDate, and InsertTmpA2ALPO
/*   
/*      Rev 1.6   Feb 24 2006 15:08:32   zf297a
/*   Modified the interfaces for some TSL procedures and load procedures.
/*   
/*      Rev 1.5   Feb 15 2006 21:22:54   zf297a
/*   Added ref cursor's, type's and common process routines.
/*   
/*      Rev 1.4   Jan 03 2006 12:56:26   zf297a
/*   Added date range to procedures loadZeroTslA2AByDate and loadA2AByDate
/*   
/*      Rev 1.3   Jan 03 2006 09:13:06   zf297a
/*   Changed name from loadByDate to loadA2AByDate
/*   
/*      Rev 1.2   Dec 30 2005 01:20:08   zf297a
/*   add loadByDate
/*
/*      Rev 1.1   Nov 10 2005 11:10:46   zf297a
/*   Added interfaces getInsertCnt, getDeleteCnt, and getUpdateCnt.  Changed the interface for LoadAllA2A to have an optional boolean argument that can control the use of "test data".
/*
/*      Rev 1.0   Oct 18 2005 19:12:48   c394547
/*   Initial revision.
		 */

	OVERRIDE_TYPE 	  	 	 CONSTANT tmp_a2a_loc_part_override.OVERRIDE_TYPE%type := 'TSL Fixed' ;
	OVERRIDE_REASON 		 CONSTANT tmp_a2a_loc_part_override.OVERRIDE_REASON%type := 'Fixed TSL Load' ;
	THE_WAREHOUSE 			 CONSTANT amd_spare_networks.spo_location%type := 'FD2090' ;
	THE_WAREHOUSE_LOC_SID 	 CONSTANT amd_spare_networks.LOC_SID%type := 256 ;
	
	BULKLIMIT CONSTANT NUMBER := 100000 ;
	COMMITAFTER CONSTANT NUMBER := 100000 ;
	SUCCESS							CONSTANT NUMBER := 0 ;
	FAILURE							CONSTANT NUMBER := 4 ;
	
	
	TYPE locPartOverrideRec IS RECORD (
		 part_no AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
		 site_location AMD_SPARE_NETWORKS.SPO_LOCATION%TYPE,
		 override_type VARCHAR2(32),
	     override_quantity AMD_LOCATION_PART_OVERRIDE.TSL_OVERRIDE_QTY%TYPE,
		 override_reason VARCHAR2(64),
		 tsl_override_user AMD_LOCATION_PART_OVERRIDE.TSL_OVERRIDE_USER%TYPE,
		 begin_date DATE,
		 end_date DATE,
		 action_code AMD_LOCATION_PART_OVERRIDE.ACTION_CODE%TYPE,
		 last_update_dt AMD_LOCATION_PART_OVERRIDE.LAST_UPDATE_DT%TYPE
	) ;
	
	TYPE tslRec IS RECORD (
		 spo_prime_part_no AMD_SENT_TO_A2A.SPO_PRIME_PART_NO%TYPE,
		 action_code AMD_SENT_TO_A2A.ACTION_CODE%TYPE,
		 transaction_date AMD_SENT_TO_A2A.TRANSACTION_DATE%TYPE,
		 spo_location AMD_SPARE_NETWORKS.SPO_LOCATION%TYPE,
		 nsn AMD_NATIONAL_STOCK_ITEMS.nsn%TYPE,
		 nsi_sid AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE,
		 override_quantity AMD_LOCATION_PART_OVERRIDE.TSL_OVERRIDE_QTY%TYPE
	) ;
	
	TYPE locPartOverrideCur IS REF CURSOR RETURN locPartOverrideRec ;
	TYPE tslCur IS REF CURSOR RETURN tslRec ;
	
	PROCEDURE processLocPartOverride(locPartOverride IN locPartOverrideCur) ;
	PROCEDURE processTsl(tsl IN tslCur, pDoAllA2A IN BOOLEAN) ;
	
	PROCEDURE LoadInitial ;
	PROCEDURE loadA2AByDate( from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE) ;
	PROCEDURE LoadAllA2A (useTestData IN BOOLEAN := FALSE, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE) ;
	PROCEDURE LoadZeroTslA2A(doAllA2A IN BOOLEAN := FALSE, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE) ;
	PROCEDURE LoadTmpAmdLocPartOverride ;
	PROCEDURE LoadZeroTslA2A(pDoAllA2A BOOLEAN, pSpoLocation VARCHAR2, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE)   ;
	
	
	FUNCTION InsertRow(
			pPartNo                      AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			pLocSid                      AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			pTslOverrideQty				 AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE ,
			pTslOverrideUser			 AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE )
			RETURN NUMBER ;
	
	FUNCTION Updaterow(
			pPartNo                      AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			pLocSid                      AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			pTslOverrideQty				 AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE ,
			pTslOverrideUser			 AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE )
			RETURN NUMBER ;
	
	
	
	FUNCTION DeleteRow(
			pPartNo                      AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			pLocSid                      AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			pTslOverrideQty				 AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE ,
			pTslOverrideUser			 AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE )
			RETURN NUMBER ;
	
			-- return Y or N
	FUNCTION IsNumeric(pString VARCHAR2) RETURN VARCHAR2 ;
	PRAGMA RESTRICT_REFERENCES(IsNumeric, WNDS) ;
	
	-- testing
	FUNCTION GetFirstLogonIdForPart(pNsiSid AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE) RETURN AMD_PLANNER_LOGONS.logon_id%TYPE ;
	-- added 11/7/05 dse
	FUNCTION getInsertCnt RETURN NUMBER ;
	FUNCTION getUpdateCnt RETURN NUMBER ;
	FUNCTION getDeleteCnt RETURN NUMBER ;
	
	-- added 02/23/2006 dse
	-- these functions allow  stand alone SQL to use the package constants
	FUNCTION getOVERRIDE_TYPE RETURN VARCHAR2 ;
	FUNCTION getOVERRIDE_REASON RETURN VARCHAR2 ;
	FUNCTION getBULKLIMIT RETURN NUMBER ;
	FUNCTION getCOMMITAFTER RETURN NUMBER ;
	FUNCTION getSUCCESS RETURN NUMBER ;
	FUNCTION getFAILURE RETURN NUMBER ;
	FUNCTION getTHE_WAREHOUSE RETURN VARCHAR2 ;
	FUNCTION isInTmpA2AYorN(part_no IN TMP_A2A_LOC_PART_OVERRIDE.part_no%TYPE, site_location IN TMP_A2A_LOC_PART_OVERRIDE.SITE_LOCATION%TYPE) RETURN VARCHAR2 ;
	FUNCTION isInTmpA2A(part_no IN TMP_A2A_LOC_PART_OVERRIDE.part_no%TYPE, site_location IN TMP_A2A_LOC_PART_OVERRIDE.SITE_LOCATION%TYPE) RETURN BOOLEAN ;
	 
	PROCEDURE loadZeroTslA2APartsWithNoTsls(doAllA2A IN BOOLEAN := FALSE, useTestData IN BOOLEAN := FALSE ) ;
	PROCEDURE loadRspZeroTslA2A(doAllA2A IN BOOLEAN := FALSE, useTestData in boolean := false) ;
	PROCEDURE loadZeroTslA2A4DelSpoPrimParts(doAllA2A IN BOOLEAN := FALSE, useTestData IN BOOLEAN := FALSE) ;
	PROCEDURE loadTslA2AWarehouseParts(doAllA2A IN BOOLEAN := FALSE, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE) ;
	
	PROCEDURE loadZeroTslA2AByDate(pDoAllA2A IN BOOLEAN, 
			  from_dt IN DATE, to_dt IN DATE, pSpolocation IN VARCHAR2) ;
	
	FUNCTION insertedTmpA2ALPO (
				  pPartNo			TMP_A2A_LOC_PART_OVERRIDE.part_no%TYPE,
				  pBaseName			TMP_A2A_LOC_PART_OVERRIDE.site_location%TYPE,
				  pOverrideType		TMP_A2A_LOC_PART_OVERRIDE.override_type%TYPE,
				  pTslOverrideQty	TMP_A2A_LOC_PART_OVERRIDE.override_quantity%TYPE,
				  pOverrideReason	TMP_A2A_LOC_PART_OVERRIDE.override_reason%TYPE,
				  pTslOverrideUser	TMP_A2A_LOC_PART_OVERRIDE.override_user%TYPE,
				  pBeginDate		TMP_A2A_LOC_PART_OVERRIDE.begin_date%TYPE,
				  pActionCode		TMP_A2A_LOC_PART_OVERRIDE.action_code%TYPE,
				  pLastUpdateDt		TMP_A2A_LOC_PART_OVERRIDE.last_update_dt%TYPE
				  ) RETURN BOOLEAN ;
	
	-- added 6/9/2006 by dse
	procedure version ;
	
	-- added 9/1/2006 by dse		
	procedure LoadOverrideUsers ;
		
END Amd_Location_Part_Override_Pkg ;
/

show errors

CREATE OR REPLACE PACKAGE AMD_OWNER.amd_defaults as
    /*

     $Author:   zf297a  $
   $Revision:   1.20  $
       $Date:   Oct 26 2006 12:10:32  $
   $Workfile:   amd_defaults.pks  $
        $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_defaults.pks-arc  $
   
      Rev 1.20   Oct 26 2006 12:10:32   zf297a
   Added boolean flag STRICT.  This will be used to determine if an exception should be raised for certain errors that in most cases are not critical.
   
      Rev 1.19   Jun 09 2006 12:55:24   zf297a
   added interface version
   
      Rev 1.18   Nov 30 2005 10:56:18   zf297a
   added bom_quantity and bom

      Rev 1.17   Nov 01 2005 12:32:52   zf297a
   Added some more "getter" functions for other constants.

      Rev 1.16   Nov 01 2005 12:21:34   zf297a
   Simplified the name of the "getter's" to getCONSTANT where CONSTANT is the identifier for the associated constant.

      Rev 1.15   Nov 01 2005 11:50:32   zf297a
   Added "getter 's" (get functions) for some of the constant's so they can be used in ordinary SQL instead of only in PL/SQL code.

      Rev 1.14   Sep 13 2005 11:04:02   zf297a
   Added interfaces for isParamKey and addParamKey.

      Rev 1.13   Jul 08 2005 09:08:38   zf297a
   added the public function getLogonId

      Rev 1.12   Jul 08 2005 08:58:36   zf297a
   Added the public function getPlannerCode

      Rev 1.11   Jul 05 2005 13:54:12   zf297a
   added $Log$ PVCS keyword

     	10/02/01 Douglas Elder	Initial implementation
	 							Although variables that are CAPITALIZED
								are usually "constant's", these variables
								are quasi-constants, since they rarely change,
								but they are initialized from values stored
								in an Oracle table.  Some values are returned
								via functions, since they are dependent on
								the value of other variables.
		6/07/05	 KS				Add more constants and defaults
     */
	STRICT		 				boolean := false ; -- raise errors when true
	
	CONDEMN_AVG					amd_national_stock_items.condemn_avg%type := null ;
	CONSUMABLE					constant amd_national_stock_items.item_type%type := 'C' ;
	function getCONSUMABLE return varchar2 ;
	DELETE_ACTION				constant amd_spare_parts.action_code%type := 'D' ;
	function getDELETE_ACTION return varchar2 ;
	DISPOSAL_COST				amd_spare_parts.disposal_cost%type := null ;
	DISTRIB_UOM					amd_national_stock_items.distrib_uom%type := null ;
	INSERT_ACTION				constant amd_spare_parts.action_code%type := 'A' ;
	function getINSERT_ACTION return varchar2 ;
	NOT_PRIME_PART				constant amd_nsi_parts.prime_ind%type  := 'N' ;
	NRTS_AVG					amd_national_stock_items.nrts_avg%type := null ;

	OFF_BASE_TURN_AROUND		amd_part_locs.time_to_repair%type := null ;
	function GetOrderLeadTime(pItem_type in amd_national_stock_items.item_type%type) return  amd_spare_parts.order_lead_time_defaulted%type ;
	ORDER_QUANTITY				amd_national_stock_items.order_quantity%type := null ;

	ORDER_UOM					amd_spare_parts.order_uom%type := null ;
	PRIME_PART					constant amd_nsi_parts.prime_ind%type  := 'Y' ;

	QPEI_WEIGHTED				amd_national_stock_items.qpei_weighted%type := null ;
	REPAIRABLE					constant amd_national_stock_items.item_type%type := 'R' ;
	function getREPAIRABLE return varchar2 ;
	RTS_AVG						amd_national_stock_items.rts_avg%type := null ;
	SCRAP_VALUE					amd_spare_parts.scrap_value%type := null ;
    SHELF_LIFE					amd_spare_parts.shelf_life%type := null ;


	TIME_TO_REPAIR_ON_BASE_AVG	amd_national_stock_items.time_to_repair_on_base_avg_df%type := null ;
	
	BOM_QUANTITY				tmp_a2a_bom_detail.quantity%type := 1 ;
	BOM							tmp_a2a_bom_detail.bom%type := 'C17' ;

	function GetUnitCost(
		pNsn in amd_spare_parts.nsn%type,
		pPart_no in amd_spare_parts.part_no%type,
		pMfgr in amd_spare_parts.mfgr%type,
		pSmr_code in amd_national_stock_items.smr_code%type,
		pPlanner_code in amd_national_stock_items.planner_code%type) return amd_spare_parts.unit_cost_defaulted%type ;

	function getPlannerCode(nsn in varchar2) return varchar2 ;

	function getLogonId(nsn in varchar2) return varchar2 ;

	UNIT_VOLUME					amd_spare_parts.unit_volume%type := null ;
	UPDATE_ACTION				constant amd_spare_parts.action_code%type := 'C' ;
	function getUPDATE_ACTION return varchar2 ;
	USE_BSSM_TO_GET_NSLs		varchar2(1) := null ;

	COST_TO_REPAIR_ONBASE amd_part_locs.cost_to_repair%type := null;
	TIME_TO_REPAIR_ONBASE amd_part_locs.time_to_repair%type := null;
	TIME_TO_REPAIR_OFFBASE amd_part_locs.time_to_repair%type := null;
	UNIT_COST_FACTOR_OFFBASE number := 0;

		/* ks add 06/07/05
		-- expose GetParamValue
		-- constants
		*/
	function GetParamValue(key in varchar2) return amd_param_changes.param_value%type ;
	-- added 9/3/2005 dse
	procedure setParamValue(key in varchar2, value in varchar2) ;
	AMD_WAREHOUSE_LOCID CONSTANT amd_spare_networks.loc_id%TYPE := 'CTLATL';
	function getAMD_WAREHOUSE_LOCID return varchar2 ;
	BSSM_WAREHOUSE_SRAN CONSTANT bssm_bases.sran%TYPE := 'W';
	function getBSSM_WAREHOUSE_SRAN return varchar2 ;

	AMD_UK_LOC_ID 	CONSTANT amd_spare_networks.loc_id%TYPE := 'EY8780' ;
	function getAMD_UK_LOC_ID return varchar2 ;
	AMD_BASC_LOC_ID CONSTANT amd_spare_networks.loc_id%TYPE := 'EY1746' ;
	function getAMD_BASC_LOC_ID return varchar2 ;
	AMD_VUB_LOC_ID	CONSTANT amd_spare_networks.loc_id%TYPE := 'FB4490' ;
	function getAMD_VUB_LOC_ID return varchar2 ;
	--AMD_VCD_LOC_ID  CONSTANT amd_spare_networks.loc_id%TYPE :=	'?' ;

	NSN_PLANNER_CODE amd_planners.PLANNER_CODE%type := null ;
	NSN_LOGON_ID amd_planner_logons.LOGON_ID%type := null ;
	NSL_PLANNER_CODE amd_planners.PLANNER_CODE%type := null ;
	NSL_LOGON_ID amd_planner_logons.LOGON_ID%type := null ;

	function isParamKey(key in varchar2) return boolean ;
	procedure addParamKey(key in varchar2, description in varchar2) ;
	
	-- added 6/09/2006 by dse
	procedure version ;

end amd_defaults ;
/

show errors

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.Amd_Location_Part_Override_Pkg AS

 /*
      $Author:   zf297a  $
	$Revision:   1.45  $
        $Date:   Oct 23 2006 11:05:28  $
    $Workfile:   AMD_LOCATION_PART_OVERRIDE_PKG.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_LOCATION_PART_OVERRIDE_PKG.pkb.-arc  $
/*   
/*      Rev 1.45   Oct 23 2006 11:05:28   zf297a
/*   Check pError_location in procedured errorMsg to make sure it is numeric.   Changed dup_val_on_index for insertedTmpA2ALPO to update tmp_a2a_loc_part_override and to record what has changed in amd_load_details.  This may provide the necessary information to eliminate this exception condition.
/*   
/*      Rev 1.44   Oct 19 2006 11:08:26   zf297a
/*   Fixed all tslCur's to use the amd_sent_to_a2a.action_code and created a nested procedure for each unique Open of the tslCur and record the procedure's name in amd_load_details.
/*   
/*      Rev 1.42   Oct 16 2006 08:41:44   zf297a
/*   For function getFirstLogonIdForPart only consider the action_code for amd_planners and amd_planner_logons since the part may have been deleted, but still needs to be sent with the proper logon_id when sending delete A2A transactions.
/*   
/*      Rev 1.41   Oct 11 2006 11:03:46   zf297a
/*   When doing a loadAllA2A and getting data from amd_rsp_sum always use the action_code of amd_sent_to_a2a.spo_prime_part_no and send a zero quantity when the amd_rsp_sum.action_code = 'D' otherwise send the rsp_level.
/*   
/*      Rev 1.40   Oct 09 2006 22:28:04   zf297a
/*   Fixed inner getActionCode function of insertTmpA2A of processTsl - used rsp_location / site_location for search of amd_rsp_sum.  Added additional exception handlers for getActionCode too.
/*   
/*      Rev 1.39   Oct 09 2006 10:34:56   zf297a
/*   For A2A transactions give the action_code belonging to amd_location_part_override or amd_rsp_sum priority when it is a delete action, otherwise use the action_code from the associated amd_sent_to_a2a row.
/*   
/*      Rev 1.38   Sep 05 2006 12:47:08   zf297a
/*   Renumbered pError_location's values
/*   
/*      Rev 1.37   Aug 31 2006 16:02:12   zf297a
/*   Added more exception handlers.  Added dbms_output to version procedure.
/*   
/*      Rev 1.36   Aug 31 2006 15:34:22   zf297a
/*   Replaced errorMsg function with errorMsg procedure
/*   
/*      Rev 1.35   Aug 31 2006 14:56:12   zf297a
/*   Added more when others exceptions
/*   fixed loadAllA2A to use the amd_sent_to_a2a action_code 
/*   
/*      Rev 1.34   Aug 31 2006 12:03:18   zf297a
/*   Used not exists instead of function inInTmpA2AYorN
/*   Used action_code from amd_sent_to_a2a in most cases
/*   
/*   
/*      Rev 1.33   Jul 17 2006 11:21:00   zf297a
/*   Added cursor_spoSum for warehouse.  This amount get subtracted from the spo_total_inventory
/*   
/*      Rev 1.32   Jun 16 2006 09:21:54   zf297a
/*   For LoadWhse added a cursor_rspSum which get summed with cursor_basesSum resulting in substracting out the rsp sum for the final tsl_override_qty that gets put into tmp_amd_location_part_override.
/*   
/*      Rev 1.31   Jun 12 2006 13:22:32   zf297a
/*   use symbolic constants UK_LOCATION and BASC_LOCATION.
/*   
/*      Rev 1.30   Jun 09 2006 11:56:00   zf297a
/*   implemented version
/*   
/*      Rev 1.29   Jun 07 2006 11:11:04   zf297a
/*   For the loadAll unioned amd_rsp_sum with amd_location_part_overrides to get the non zero tsl's.
/*   
/*      Rev 1.28   Jun 07 2006 09:45:06   zf297a
/*   for loadRspZeroTsl fixed the sql for the cursors where amd_location_part_override_pkg.isInTmpA2AYorN(spo_prime_part_no, mob || '_RSP') = 'N' is needed (the value was checked for was not all 'N''s and the mob was not concatenated with the literal '_RSP')
/*   
/*      Rev 1.27   Jun 03 2006 20:25:54   zf297a
/*   enhanced the use of writeMsg
/*   
/*      Rev 1.26   Jun 03 2006 19:09:54   zf297a
/*   added:
/*   and parts.action_code != amd_defaults.getDELETE_ACTION
/*   to the last open tsl cursor of procedure LoadZeroTslA2A
/*   
/*      Rev 1.25   Jun 03 2006 18:59:36   zf297a
/*   fixed procedure amd_location_part_override_pkg.LoadZeroTslA2A(pDoAllA2A BOOLEAN, pSpoLocation VARCHAR2,from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE) 
/*    to use select's similar to the following: 
/*    SELECT distinct primes.spo_prime_part_no,
/*      amd_defaults.getINSERT_ACTION,
/*      sysdate,
/*      theLocation spo_location,
/*      ansi.nsn,
/*      ansi.nsi_sid,
/*      0 override_qty
/*      FROM (select distinct spo_prime_part_no from amd_sent_to_a2a where action_code <> 'D') primes, 
/*      AMD_NATIONAL_STOCK_ITEMS ansi
/*      WHERE amd_location_part_override_pkg.isInTmpA2AYorN(primes.spo_prime_part_no, theLocation) = 'N'
/*      AND ansi.prime_part_no = primes.spo_prime_part_no
/*      AND ansi.action_code != Amd_Defaults.getDELETE_ACTION 
/*     
/*   and procedure amd_location_part_override_pkg.LoadZeroTslA2A(doAllA2A IN BOOLEAN := FALSE, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE) 
/*   
/*   was fixed by adding an additional invocation of 
/*   amd_location_part_override_pkg.LoadZeroTslA2A(pDoAllA2A BOOLEAN, pSpoLocation VARCHAR2,from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE) 
/*   
/*   for pSpoLocation equal to amd_location_part_override_pkg.THE_WAREHOUSE (FD2090).
/*   
/*   
/*      Rev 1.24   Jun 01 2006 22:20:24   zf297a
/*   Fiixed query for loadRspZeroTsl - added qualification for amd_spare_parts - part_no = spo_prime_part_no
/*   
/*      Rev 1.23   Jun 01 2006 12:01:14   zf297a
/*   Added writeMsg to the beginning of processTsl
/*   
/*      Rev 1.22   Jun 01 2006 10:57:52   zf297a
/*   Fixed loadRspZeroTsl's.  use amd_utils.writeMsg instead of dbms_output
/*   
/*      Rev 1.21   May 31 2006 08:20:46   zf297a
/*   Used Mta_Truncate_Table for loadAllA2A instead of truncateIfOld
/*   
/*      Rev 1.20   May 12 2006 14:00:36   zf297a
/*   For loadAllA2A include all action_codes and all parts that are in amd_sent_to_a2a  where the spo_prime_part_no is filled in too.
/*   
/*      Rev 1.19   Apr 28 2006 13:16:24   zf297a
/*   Implemented the loadRspZeroTslA2A
/*   
/*      Rev 1.18   Apr 21 2006 14:02:00   zf297a
/*   Made insertTmpA2ALPO public, so prototype could be removed.  Also made sure that insertTmpA2ALPO never updates an existing tmp_a2a record with a zero quantity.
/*   
/*      Rev 1.17   Apr 20 2006 13:23:00   zf297a
/*   Added an insertTmpA2A routine for the processTsl procedure.  This routine is used only to insert zero tsl's.  If a tmp_a2a row exists already, it is not overwritten.
/*   
/*      Rev 1.16   Mar 23 2006 09:08:56   zf297a
/*   Use truncateIfOld for tmp_a2a_loc_part_override - .  The table will get truncated if there is no active batch job or it will get truncated if there is an active batch job and the table has not changed since the batch job started.
/*   
/*      Rev 1.15   Mar 06 2006 08:37:34   zf297a
/*   Removed unused references to amd_batch_jobs
/*   
/*      Rev 1.14   Mar 05 2006 15:26:36   zf297a
/*   Added debug code.
/*   
/*      Rev 1.13   Mar 05 2006 14:16:24   zf297a
/*   Added amd_utils.debugMsg to record counts and procedure completion.
/*   Added enhanced processing to tsl's.
/*   
/*      Rev 1.12   Mar 03 2006 12:06:22   zf297a
/*   Moved boolean2Varchar2 to amd_utils.  Used amd_batch_pkg.getLastStartTime instead of amd_location_part_leadtime_pkg.getBatchRunStart.  This will retrieve the last batch start time even if the job has finished.  This way any data changed since the last batch job has been run, can have a2a transactions created for it.  (The only other choice with the previous method would be the "send all" method versus what has changed since the last batch start time).
/*   Added more qualification for the tsl cursor in procedure loadZeroTslA2APartsWithNoTsls
/*   
/*   
/*      Rev 1.11   Feb 24 2006 15:07:26   zf297a
/*   Streamlined routines handling TSL's.  Added some additional TSL loads.
/*   
/*      Rev 1.10   Feb 17 2006 09:25:10   zf297a
/*   Changed requisition_objective to demand_level
/*   
/*      Rev 1.9   Feb 15 2006 21:22:52   zf297a
/*   Added ref cursor's, type's and common process routines.
/*   
/*      Rev 1.8   Jan 03 2006 12:56:26   zf297a
/*   Added date range to procedures loadZeroTslA2AByDate and loadA2AByDate
/*   
/*      Rev 1.7   Jan 03 2006 09:13:06   zf297a
/*   Changed name from loadByDate to loadA2AByDate
/*   
/*      Rev 1.6   Dec 30 2005 01:20:08   zf297a
/*   add loadByDate
/*   
/*      Rev 1.5   Dec 15 2005 12:16:44   zf297a
/*   Added truncate table tmp_a2a_loc_part_override to LoadTmpAmdLocPartOverride
/*   
/*      Rev 1.4   Dec 06 2005 09:52:36   zf297a
/*   Fixed display of sysdate in errorMsg - changed to MM/DD/YYYY HH:MM:SS
/*   
/*      Rev 1.3   Nov 15 2005 11:57:26   zf297a
/*   Add additional where clauses to load all the data.  Added return statement for insertedTmpA2ALPO.
/*   
/*      Rev 1.2   Nov 10 2005 11:08:24   zf297a
/*   Added global counters for insert, update, and delete and public getter's.
/*   
/*   Added a testData Cursor.
/*   
/*   Added counters and displaying of start/end messages for all the load routines.
/*   
/*      Rev 1.1   Oct 28 2005 12:46:04   zf297a
/*   Added check for wasPartSent before inserting to tmp_a2a_loc_part_override
/*   
/*      Rev 1.0   Oct 19 2005 12:40:56   zf297a
/*   Initial revision.
/*   
/*      Rev 1.0   Oct 18 2005 13:07:22   zf297a
/*   Initial revision.
		 */

	PKGNAME CONSTANT VARCHAR2(30) := 'AMD_LOCATION_PART_OVERRIDE_PKG' ;
	
	COMMIT_THRESHOLD CONSTANT NUMBER := 250 ;
	
	insertCnt NUMBER := 0 ;
	updateCnt NUMBER := 0 ;
	deleteCnt NUMBER := 0 ;
	
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
				pSourceName => 'amd_location_part_override_pkg',	
				pTableName  => pTableName,
				pError_location => pError_location,
				pKey1 => pKey1,
				pKey2 => pKey2,
				pKey3 => pKey3,
				pKey4 => pKey4,
				pData    => pData,
				pComments => pComments);
	end writeMsg ;
	
	PROCEDURE ErrorMsg(
	    pSqlfunction IN AMD_LOAD_STATUS.SOURCE%TYPE,
	    pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
	    pError_location AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
	    pKey1 IN AMD_LOAD_DETAILS.KEY_1%TYPE := '',
	    pKey2 IN AMD_LOAD_DETAILS.KEY_2%TYPE := '',
	    pKey3 IN AMD_LOAD_DETAILS.KEY_3%TYPE := '',
	    pKey4 IN AMD_LOAD_DETAILS.KEY_4%TYPE := '',
	    pComments IN VARCHAR2 := '') IS
	 
	    key5 AMD_LOAD_DETAILS.KEY_5%TYPE := pComments ;
		error_location number ;
	 
	BEGIN
	  ROLLBACK;
	  IF key5 = '' THEN
	     key5 := pSqlFunction || '/' || pTableName ;
	  ELSE
	   key5 := key5 || ' ' || pSqlFunction || '/' || pTableName ;
	  END IF ;
	  if amd_utils.isNumber(pError_location) then
	  	 error_location := pError_location ;
	  else
	  	 error_location := -9999 ;
	  end if ;
	  -- use substr's to make sure that the input parameters for InsertErrorMsg and GetLoadNo
	  -- do not exceed the length of the column's that the data gets inserted into
	  -- This is for debugging and logging, so efforts to make it not be the source of more
	  -- errors is VERY important
	  Amd_Utils.InsertErrorMsg (
	    pLoad_no => Amd_Utils.GetLoadNo(
	      pSourceName => SUBSTR(pSqlfunction,1,20),
	      pTableName  => SUBSTR(pTableName,1,20)),
	    pData_line_no => error_location,
	    pData_line    => 'amd_location_part_override_pkg',
	    pKey_1 => SUBSTR(pKey1,1,50),
	    pKey_2 => SUBSTR(pKey2,1,50),
	    pKey_3 => SUBSTR(pKey3,1,50),
	    pKey_4 => SUBSTR(pKey4,1,50),
	    pKey_5 => TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS') ||
	         ' ' || substr(key5,1,50),
	    pComments => SUBSTR('sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')',1,2000));
	    COMMIT;
	  
	EXCEPTION WHEN OTHERS THEN
	  if pSqlFunction is not null then dbms_output.put_line('pSqlFunction=' || pSqlfunction) ; end if ;
	  if pTableName is not null then dbms_output.put_line('pTableName=' || pTableName) ; end if ;
	  if pError_location is not null then dbms_output.put_line('pError_location=' || pError_location) ; end if ;
	  if pKey1 is not null then dbms_output.put_line('key1=' || pKey1) ; end if ;
	  if pkey2 is not null then dbms_output.put_line('key2=' || pKey2) ; end if ;
	  if pKey3 is not null then dbms_output.put_line('key3=' || pKey3) ; end if ;
	  if pKey4 is not null then dbms_output.put_line('key4=' || pKey4) ; end if ;
	  if pComments is not null then dbms_output.put_line('pComments=' || pComments) ; end if ;
	  raise ;
	END ErrorMsg;
	
	
	PROCEDURE UpdateAmdLocPartOverride (
	  		  pPartNo 			   		AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			  pLocSid 					AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			  pTslOverrideQty			AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE,
			  pTslOverrideUser			AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE,
			  pActionCode				AMD_LOCATION_PART_OVERRIDE.action_code%TYPE,
			  pLastUpdateDt				AMD_LOCATION_PART_OVERRIDE.last_update_dt%TYPE) IS
	BEGIN
		 	  UPDATE AMD_LOCATION_PART_OVERRIDE
			  SET
			  	  tsl_override_qty 			= pTslOverrideQty,
				  tsl_override_user  		= pTslOverrideUser,
				  action_code				= pActionCode,
				  last_update_dt			= pLastUpdateDt
			  WHERE
			  	  part_no = pPartNo AND
				  loc_sid = pLocSid ;
	exception when others then			  
		 ErrorMsg(
				   pSqlfunction 	  => 'UpdateAmdLocPartOverride',
				   pTableName  	  	  => 'amd_location_part_override',
				   pError_location => 10) ;
		 raise ;	
	END UpdateAmdLocPartOverride ;
	
	PROCEDURE UpdateTmpAmdLocPartOverride (
	  		  pPartNo 			   		AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			  pLocSid 					AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			  pTslOverrideQty			AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE,
			  pTslOverrideUser			AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE,
			  pActionCode				AMD_LOCATION_PART_OVERRIDE.action_code%TYPE,
			  pLastUpdateDt				AMD_LOCATION_PART_OVERRIDE.last_update_dt%TYPE) IS
	BEGIN
		 	  UPDATE TMP_AMD_LOCATION_PART_OVERRIDE
			  SET
			  	  tsl_override_qty 			= pTslOverrideQty,
				  tsl_override_user  		= pTslOverrideUser,
				  action_code				= pActionCode,
				  last_update_dt			= pLastUpdateDt
			  WHERE
			  	  part_no = pPartNo AND
				  loc_sid = pLocSid ;
		 exception when others then			  
		 ErrorMsg(
				   pSqlfunction 	  => 'UpdateTmpAmdLocPartOverride',
				   pTableName  	  	  => 'tmp_amd_location_part_override',
				   pError_location => 20) ;
		 raise ;	
		 END UpdateTmpAmdLocPartOverride ;
	
	
	PROCEDURE InsertTmpAmdLocPartOverride (
			  pPartNo 			   		AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			  pLocSid 					AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			  pTslOverrideQty			AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE,
			  pTslOverrideUser			AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE,
			  pActionCode				AMD_LOCATION_PART_OVERRIDE.action_code%TYPE,
			  pLastUpdateDt				AMD_LOCATION_PART_OVERRIDE.last_update_dt%TYPE) IS
	BEGIN
		 INSERT INTO TMP_AMD_LOCATION_PART_OVERRIDE
		 (
		  		part_no,
				loc_sid,
				tsl_override_qty,
				tsl_override_user,
				action_code,
				last_update_dt
		 )
		 VALUES
		 (
		  		pPartNo,
				pLocSid,
				pTslOverrideQty,
				pTslOverrideUser,
				pActionCode,
				pLastUpdateDt
		 ) ;
	EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
		 	  UpdateTmpAmdLocPartOverride (
		   		  pPartNo,
		 		  pLocSid,
		 		  pTslOverrideQty,
		 		  pTslOverrideUser,
		 		  pActionCode,
		 		  SYSDATE ) ;
	  when others then			  
		 ErrorMsg(
				   pSqlfunction 	  => 'InsertTmpAmdLocPartOverride',
				   pTableName  	  	  => 'tmp_amd_location_part_override',
				   pError_location => 30) ;
		raise ;
	END InsertTmpAmdLocPartOverride ;
	
	PROCEDURE InsertAmdLocPartOverride (
			  pPartNo 			   		AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			  pLocSid 					AMD_SPARE_NETWORKS.loc_sid%TYPE,
			  pTslOverrideQty			NUMBER,
			  pTslOverrideUser			VARCHAR2,
			  pActionCode				VARCHAR2,
			  pLastUpdateDt				DATE) IS
	BEGIN
		 INSERT INTO AMD_LOCATION_PART_OVERRIDE
		 (
		  		part_no,
				loc_sid,
				tsl_override_qty,
				tsl_override_user,
				action_code,
				last_update_dt
		 )
		 VALUES
		 (
		  		pPartNo,
				pLocSid,
				pTslOverrideQty,
				pTslOverrideUser,
				pActionCode,
				pLastUpdateDt
		 ) ;
	EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
		 	  UpdateAmdLocPartOverride (
		   		  pPartNo,
		 		  pLocSid,
		 		  pTslOverrideQty,
		 		  pTslOverrideUser,
		 		  pActionCode,
		 		  SYSDATE ) ;
	 when others then			  
		 ErrorMsg(
				   pSqlfunction 	  => 'InsertAmdLocPartOverride',
				   pTableName  	  	  => 'amd_location_part_override',
				   pError_location => 40) ;
		 raise ;
	END InsertAmdLocPartOverride ;
	
				  
	FUNCTION insertedTmpA2ALPO(rec IN TMP_A2A_LOC_PART_OVERRIDE%ROWTYPE) RETURN BOOLEAN IS
			 rc number ;
	BEGIN
		 RETURN insertedTmpA2ALPO(
				  rec.part_no,
				  rec.site_location,
				  rec.override_type,
				  rec.override_quantity,
				  rec.override_reason,
				  rec.override_user,
				  rec.begin_date,
				  rec.action_code,
				  rec.last_update_dt) ;
				 
	exception when others then
			  
		 ErrorMsg(
				   pSqlfunction 	  => 'insertedTmpA2ALPO',
				   pTableName  	  	  => 'tmp_a2a_loc_part_override',
				   pError_location => 50,
				   pKey1			  => rec.part_no,
	   			   pKey2			  => rec.site_location,
				   pKey3			  => rec.action_code,
				   pComments		  => PKGNAME) ;
		RAISE ;
	END insertedTmpA2ALPO ;
	
	FUNCTION insertedTmpA2ALPO (
				  pPartNo			TMP_A2A_LOC_PART_OVERRIDE.part_no%TYPE,
				  pBaseName			TMP_A2A_LOC_PART_OVERRIDE.site_location%TYPE,
				  pOverrideType		TMP_A2A_LOC_PART_OVERRIDE.override_type%TYPE,
				  pTslOverrideQty	TMP_A2A_LOC_PART_OVERRIDE.override_quantity%TYPE,
				  pOverrideReason	TMP_A2A_LOC_PART_OVERRIDE.override_reason%TYPE,
				  pTslOverrideUser	TMP_A2A_LOC_PART_OVERRIDE.override_user%TYPE,
				  pBeginDate		TMP_A2A_LOC_PART_OVERRIDE.begin_date%TYPE,
				  pActionCode		TMP_A2A_LOC_PART_OVERRIDE.action_code%TYPE,
				  pLastUpdateDt		TMP_A2A_LOC_PART_OVERRIDE.last_update_dt%TYPE
				  ) RETURN BOOLEAN IS
				  
			rc number ;
			
	BEGIN
		BEGIN
			 IF A2a_Pkg.wasPartSent(pPartNo) AND pBaseName IS NOT NULL  THEN
				 INSERT INTO TMP_A2A_LOC_PART_OVERRIDE (
					  part_no,
					  site_location,
					  override_type,
					  override_quantity,
					  override_reason,
					  override_user,
					  begin_date,
					  action_code,
					  last_update_dt
				 )
				 VALUES
				 (
				 	  pPartNo,
					  pBaseName,
					  pOverrideType,
					  pTslOverrideQty,
					  pOverrideReason,
					  pTslOverrideUser,
					  pBeginDate,
					  pActionCode,
					  pLastUpdateDt
				 ) ;
			  RETURN TRUE ;
			ELSE
			  RETURN FALSE ;
			END IF ;
		EXCEPTION 
		  WHEN DUP_VAL_ON_INDEX THEN
		  	 declare
			 		override_type tmp_a2a_loc_part_override.OVERRIDE_TYPE%type ;
					override_quantity tmp_a2a_loc_part_override.OVERRIDE_QUANTITY%type ;
					override_reason tmp_a2a_loc_part_override.OVERRIDE_REASON%type ;
					override_user tmp_a2a_loc_part_override.OVERRIDE_USER%type ;
					begin_date tmp_a2a_loc_part_override.BEGIN_DATE%type ;
					action_code tmp_a2a_loc_part_override.ACTION_CODE%type ;
					last_update_dt tmp_a2a_loc_part_override.LAST_UPDATE_DT%type ;
					
					-- log what's different about this row
					procedure changed (field in varchar2, curfieldValue in varchar2, prevFieldValue in varchar2, 
							  pError_location in number) is
					begin
						writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => pError_Location,
							pKey1 => 'insertedTmpA2ALPO.changed',
							pKey2 => 'part_no=' || pPartNo,
							pKey3 => 'pBaseName=' || pBaseName,
							pKey4 => 'prev ' || field || '=' || nvl(prevfieldValue,'Null'),
							pData => 'cur ' || field || '=' || nvl(curFieldValue,'Null') ) ;
					end changed ;
					
			 begin
			 	
			    select override_type, override_quantity, override_reason, override_user, begin_date, action_code, last_update_dt
				into override_type, override_quantity, override_reason, override_user, begin_date, action_code, last_update_dt
				from tmp_a2a_loc_part_override 
				where part_no = pPartNo
				and site_location = pBaseName ;
				
				if pOverrideType <> override_type or override_quantity <> pTslOverrideQty or override_reason <> pOverrideReason
				or pBeginDate <> begin_date or pActionCode <> action_code or pLastUpdateDt <> last_update_dt then
				
				   if pOverrideType <> override_type then 
				   	  changed('override_type', pOverrideType, override_type, pError_location => 60) ; 
				   end if ;
				   if pTslOverrideQty <> override_quantity then
				   	  changed('override_quantity', to_char(pTslOverrideQty), to_char(override_quantity), pError_location => 70) ;
				   end if ;
				   if pOverrideReason <> override_reason then
				   	  changed('override_reason', pOverrideReason, override_reason,  pError_location => 80) ;
				   end if ; 
				   if pTslOverrideUser <> override_user then
				   	  changed('override_user', pTslOverrideUser, override_user,  pError_location => 90) ;
				   end if ;
				   if pBeginDate <> begin_date then				   
				   	  changed('begin_date', to_char(pBeginDate,'MM/DD/YYYY HH:MI:SS'), to_char(begin_date,'MM/DD/YYYY HH:MI:SS'), pError_location => 100) ;
				   end if ;
				   if pActionCode <> action_code then
				   	  changed('action_code',  pActionCode, action_code, pError_location => 110) ;
				   end if ;
				   if pLastUpdateDt <> last_update_dt then
				   	  changed('last_update_dt', to_char(pLastUpdateDt,'MM/DD/YYYY HH:MI:SS'), to_char(last_update_dt,'MM/DD/YYYY HH:MI:SS'), pError_location => 120) ;
				   end if ;
				   
				   UPDATE TMP_A2A_LOC_PART_OVERRIDE
			 		SET
						  override_type		 = pOverrideType,
						  override_quantity	 = pTslOverrideQty,
						  override_reason	 = pOverrideReason,
						  override_user		 = pTslOverrideUser,
						  begin_date		 = pBeginDate,
						  action_code		 = pActionCode,
						  last_update_dt	 = pLastUpdateDt
					WHERE
						  part_no 			 = pPartNo AND
						  site_location		 = pBaseName ;
				end if ;	
				RETURN TRUE ;
			end ;
		  WHEN others THEN
		  	   ErrorMsg(
				   pSqlfunction 	  	  => 'insertedTmpA2ALPO',
				   pTableName  	  	  => 'tmp_a2a_loc_part_override',
				   pError_location => 130,
				   pKey1			  => pPartNo,
	   			   pKey2			  => pBaseName,
				   pKey3			  => pActionCode,
				   pComments		  => PKGNAME) ;
			RAISE ;
	
		END ;
	END insertedTmpA2ALPO ;
	
	
	
	FUNCTION InsertRow(
			pPartNo                      AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			pLocSid                      AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			pTslOverrideQty				 AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE ,
			pTslOverrideUser			 AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE )
			RETURN NUMBER IS
		 returnCode NUMBER ;
	BEGIN
		 BEGIN
		    InsertAmdLocPartOverride (
		 	  pPartNo,
			  pLocSid,
			  pTslOverrideQty,
			  pTslOverrideUser,
			  Amd_Defaults.INSERT_ACTION,
			  SYSDATE ) ;
	
		 EXCEPTION WHEN OTHERS THEN
		 ErrorMsg(
				   pSqlfunction 	  	  => 'InsertRow.InsertAmdLocPartOverride',
				   pTableName  	  	  => 'amd_location_part_override',
				   pError_location => 140,
				   pKey1			  => pPartNo,
	   			   pKey2			  => pLocSid,
				   pComments		  => PKGNAME) ;
		 RAISE ;
	
		 END ;
		 BEGIN
		  	   IF insertedTmpA2ALPO(
				  pPartNo,
				  Amd_Utils.GetSpoLocation(pLocSid),
				  OVERRIDE_TYPE,
				  pTslOverrideQty,
				  OVERRIDE_REASON,
				  pTslOverrideUser,
				  SYSDATE,
				  Amd_Defaults.INSERT_ACTION,
				  SYSDATE
			    ) THEN
				 insertCnt := insertCnt + 1 ;
			END IF ;
	
	
		  END ;
		  RETURN SUCCESS ;
	EXCEPTION WHEN OTHERS THEN
		 ErrorMsg(
				   pSqlfunction => 'InsertRow.InsertTmpA2A_LPO',
				   pTableName  	  	  => 'tmp_a2a_loc_part_override',
				   pError_location => 150,
				   pKey1			  => pPartNo,
	   			   pKey2			  => pLocSid) ;
		RAISE ;
	END InsertRow ;
	
	
	FUNCTION UpdateRow(
			pPartNo                      AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			pLocSid                      AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			pTslOverrideQty				 AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE ,
			pTslOverrideUser			 AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE )
			RETURN NUMBER IS
			returnCode NUMBER ;
	BEGIN
		 BEGIN
		 	UpdateAmdLocPartOverride (
	  		  pPartNo,
			  pLocSid,
			  pTslOverrideQty,
			  pTslOverrideUser,
			  Amd_Defaults.UPDATE_ACTION,
			  SYSDATE ) ;
		 EXCEPTION WHEN OTHERS THEN
		 ErrorMsg(
				   pSqlfunction 	  	  => 'UpdateRow.InsertTmpA2A_LPO',
				   pTableName  	  	  => 'amd_location_part_override',
				   pError_location => 160,
				   pKey1			  => pPartNo,
	   			   pKey2			  => pLocSid) ;
		 RAISE ;
		 END ;
		 BEGIN
			IF insertedTmpA2ALPO (
				  pPartNo,
				  Amd_Utils.GetSpoLocation(pLocSid),
				  OVERRIDE_TYPE,
				  pTslOverrideQty,
				  OVERRIDE_REASON,
				  pTslOverrideUser,
				  SYSDATE,
				  Amd_Defaults.UPDATE_ACTION,
				  SYSDATE
		   ) THEN
		   	 updateCnt := updateCnt + 1 ;
		 END IF ;
		 END ;
		 RETURN SUCCESS ;
	EXCEPTION WHEN OTHERS THEN
		 ErrorMsg(
				   pSqlfunction 	  	  => 'UpdateRow.InsertTmpA2A_LPO',
				   pTableName  	  	  => 'tmp_a2a_loc_part_override',
				   pError_location => 170,
				   pKey1			  => pPartNo,
	   			   pKey2			  => pLocSid) ;
		RAISE ;
	END UpdateRow ;
	
	
	
	FUNCTION DeleteRow(
			pPartNo                      AMD_LOCATION_PART_OVERRIDE.part_no%TYPE,
			pLocSid                      AMD_LOCATION_PART_OVERRIDE.loc_sid%TYPE,
			pTslOverrideQty				 AMD_LOCATION_PART_OVERRIDE.tsl_override_qty%TYPE ,
			pTslOverrideUser			 AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE )
			RETURN NUMBER IS
			returnCode NUMBER ;
	BEGIN
		 BEGIN
			 UpdateAmdLocPartOverride (
		  		  pPartNo,
				  pLocSid,
				  pTslOverrideQty,
				  pTslOverrideUser,
				  Amd_Defaults.DELETE_ACTION,
				  SYSDATE ) ;
		 EXCEPTION WHEN OTHERS THEN
		 ErrorMsg(
				   pSqlfunction 	  	  => 'DeleteRow.UpdateAmdLocPartOverride',
				   pTableName  	  	  => 'amd_location_part_override',
				   pError_location => 180,
				   pKey1			  => pPartNo,
	   			   pKey2			  => pLocSid) ;
		 RAISE ;
		 END ;
		 BEGIN
		 	  -- deletion of parts handled by part info delete
		 	--IF (NOT amd_location_part_leadtime_pkg.IsPartDeleted(pPartNo)) THEN
		 		IF insertedTmpA2ALPO (
		 			  pPartNo,
		 			  Amd_Utils.GetSpoLocation(pLocSid),
		 			  OVERRIDE_TYPE,
		 			  pTslOverrideQty,
		 			  OVERRIDE_REASON,
		 			  pTslOverrideUser,
		 			  SYSDATE,
		 			  Amd_Defaults.DELETE_ACTION,
		 			  SYSDATE
		 	   ) THEN
			   deleteCnt := deleteCnt + 1 ;
			 END IF ;
			--END IF ;
		 END ;
	  	RETURN SUCCESS ;
	EXCEPTION WHEN OTHERS THEN
		 ErrorMsg(
				   pSqlfunction 	  	  => 'DeleteRow',
				   pTableName  	  	  => 'tmp_a2a_loc_part_override',
				   pError_location => 190,
				   pKey1			  => pPartNo,
	   			   pKey2			  => pLocSid) ;
		RAISE ;
	END DeleteRow ;
	
	FUNCTION IsNumeric(pString VARCHAR2) RETURN VARCHAR2 IS
			 ret VARCHAR2(1) ;
			 I NUMBER ;
	BEGIN
		 BEGIN
		 	  IF pString IS NULL THEN
			  	 ret := 'N' ;
			  ELSE
			     I := TO_NUMBER(pString) ;
			     ret := 'Y' ;
			  END IF ;
		 EXCEPTION WHEN OTHERS THEN
		 	  ret := 'N' ;
		 END ;
		 RETURN ret ;
	END ;
	
	PROCEDURE LoadUK IS
	
		CURSOR cur_cand IS
			SELECT spo_prime_part_no part_no,
				  loc_sid
				  FROM AMD_SENT_TO_A2A asta, AMD_SPARE_NETWORKS asn
				  WHERE asta.part_no = asta.spo_prime_part_no
				  AND asn.loc_id = Amd_Defaults.AMD_UK_LOC_ID
				  AND asta.action_code != Amd_Defaults.DELETE_ACTION ;
	
	 	CURSOR cur_stock IS
			SELECT Amd_Partprime_Pkg.getSuperPrimePart(asp.part_no) part_no,
				   SUM(NVL(stock_level, 0)) tsl_override_qty
				  FROM WHSE w, AMD_SPARE_PARTS asp
				  WHERE w.part = asp.part_no
				  AND w.sc LIKE 'C17%CODUKBG'
		 	      AND asp.action_code != Amd_Defaults.DELETE_ACTION
				  GROUP BY	Amd_Partprime_Pkg.getSuperPrimePart(asp.part_no) ;
	
		returnCode NUMBER ;
		TYPE partNo_stock IS TABLE OF NUMBER INDEX BY AMD_SPARE_PARTS.part_no%TYPE  ;
		partNo_stockLevel partNo_stock ;
		tslOverrideQty AMD_LOCATION_PART_OVERRIDE.TSL_OVERRIDE_QTY%TYPE ;
		I NUMBER := 0 ;
		stock_cnt NUMBER := 0 ;
		cand_cnt NUMBER := 0 ;
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 200,
				pKey1 => 'LoadUK',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		BEGIN
			FOR rec IN cur_stock
			LOOP
				BEGIN
					 IF ( rec.part_no IS NOT NULL ) THEN
					 	partNo_stockLevel(rec.part_no) := rec.tsl_override_qty ;
					 END IF ;
				EXCEPTION WHEN OTHERS THEN
					ErrorMsg(
				   	   pSqlfunction 	  	  => 'LoadUk',
					   pTableName  	  	  => 'tmp_amd_location_part_override',
					   pError_location => 210,
					   pKey1			  => 'partNo: ' || rec.part_no,
		   			   pKey2			  => 'qty: ' || rec.tsl_override_qty) ;
					RAISE ;
			   	END ;
				stock_cnt := stock_cnt + 1 ;
			END LOOP ;
			FOR rec IN cur_cand
			LOOP
				tslOverrideQty := 0 ;
				BEGIN
					tslOverrideQty := partNo_stockLevel(rec.part_no) ;
				EXCEPTION WHEN NO_DATA_FOUND THEN
					tslOverrideQty := 0 ;
				END ;
				BEGIN
					 InsertTmpAmdLocPartOverride(
					 	rec.part_no,
						rec.loc_sid,
						tslOverrideQty,
						NULL,
						Amd_Defaults.INSERT_ACTION,
						SYSDATE
					 ) ;
				EXCEPTION WHEN OTHERS THEN
				  ErrorMsg(
				   pSqlfunction	  	  => 'LoadUk',
					   pTableName  	  	  => 'tmp_amd_location_part_override',
					   pError_location => 220,
					   pKey1			  => 'partNo: ' || rec.part_no,
		   			   pKey2			  => 'locSid: ' || rec.loc_sid) ;
					   RAISE ;
			   	END ;
				IF (I > COMMITAFTER) THEN
				   I := 0 ;
				   COMMIT ;
				END IF ;
				I := I + 1 ;
				cand_cnt := cand_cnt + 1 ;
			END LOOP ;
		END ;
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 230,
				pKey1 => 'LoadUK',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'stock_cnt=' || stock_cnt, 
				pKey4 => 'cand_cnt=' || cand_cnt ) ;
	EXCEPTION WHEN OTHERS THEN
		 ErrorMsg(pSqlfunction => 'LoadUk',pTableName => 'tmp_amd_location_part_override',
					   pError_location => 240 ) ;
		RAISE ;
	END LoadUk ;
	
	
	PROCEDURE LoadBasc IS
		CURSOR cur_cand IS
			SELECT spo_prime_part_no part_no,
				  loc_sid
				  FROM AMD_SENT_TO_A2A asta, AMD_SPARE_NETWORKS asn
				  WHERE asta.part_no = asta.spo_prime_part_no
				  AND asn.loc_id = Amd_Defaults.AMD_BASC_LOC_ID
				  AND asta.action_code != Amd_Defaults.DELETE_ACTION ;
	
	 	CURSOR cur_stock IS
			SELECT Amd_Partprime_Pkg.getSuperPrimePart(asp.part_no) part_no,
				   SUM(NVL(stock_level, 0)) tsl_override_qty
				  FROM WHSE w, AMD_SPARE_PARTS asp
				  WHERE w.part = asp.part_no
				  AND sc = 'C17PCAG'
		 	      AND asp.action_code != Amd_Defaults.DELETE_ACTION
	 			  GROUP BY	Amd_Partprime_Pkg.getSuperPrimePart(asp.part_no) ;
	
		returnCode NUMBER ;
		TYPE partNo_stock IS TABLE OF NUMBER INDEX BY AMD_SPARE_PARTS.part_no%TYPE  ;
		partNo_stockLevel partNo_stock ;
		tslOverrideQty AMD_LOCATION_PART_OVERRIDE.TSL_OVERRIDE_QTY%TYPE ;
		I NUMBER := 0 ;
		stock_cnt NUMBER := 0 ;
		cand_cnt NUMBER := 0 ;
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 250,
				pKey1 => 'LoadBasc',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		BEGIN
			FOR rec IN cur_stock
			LOOP
				BEGIN
					 IF ( rec.part_no IS NOT NULL ) THEN
					 	 partNo_stockLevel(rec.part_no) := rec.tsl_override_qty ;
					 END IF ;
				EXCEPTION WHEN OTHERS THEN
					ErrorMsg(
					   pSqlfunction 	  	  => 'LoadBasc',
					   pTableName  	  	  => 'tmp_amd_location_part_override',
					   pError_location => 260,
					   pKey1			  => 'partNo: ' || rec.part_no,
		   			   pKey2			  => 'qty: ' || rec.tsl_override_qty) ;
					   RAISE ;
			   	END ;
				stock_cnt := stock_cnt + 1 ;
			END LOOP ;
			FOR rec IN cur_cand
			LOOP
				tslOverrideQty := 0 ;
				BEGIN
					tslOverrideQty := partNo_stockLevel(rec.part_no) ;
				EXCEPTION WHEN NO_DATA_FOUND THEN
					tslOverrideQty := 0 ;
				END ;
				BEGIN
					 InsertTmpAmdLocPartOverride(
					 	rec.part_no,
						rec.loc_sid,
						tslOverrideQty,
						NULL,
						Amd_Defaults.INSERT_ACTION,
						SYSDATE
					 ) ;
				EXCEPTION WHEN OTHERS THEN
					ErrorMsg(
					   pSqlfunction 	  	  => 'LoadBasc',
					   pTableName  	  	  => 'tmp_amd_location_part_override',
					   pError_location => 270,
					   pKey1			  => 'partNo: ' || rec.part_no,
		   			   pKey2			  => 'locSid: ' || rec.loc_sid) ;
					RAISE ;
			   	END ;
				IF (I > COMMITAFTER) THEN
				   I := 0 ;
				   COMMIT ;
				END IF ;
				I := I + 1 ;
				cand_cnt := cand_cnt + 1 ;
			END LOOP ;
		END ;
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 280,
				pKey1 => 'LoadBasc',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'stock_cnt=' || stock_cnt,
				pKey4 => 'cand_cnt=' || cand_cnt) ;
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(
		   pSqlfunction 	  	  => 'LoadBasc',
		   pTableName  	  	  => 'tmp_amd_location_part_override',
		   pError_location => 290) ;
		RAISE ;
	END LoadBasc ;
	
	/*
		INSERT INTO tmp_amd_location_part_override
		SELECT amd_utils.GetNsiSidFromPartNo(spo_prime_part_no) nsi_sid,
			   locSid loc_sid, sum(nvl(stock_level, 0)) tsl_override_qty,
			   null tsl_overrid_user,
			   'A' action_code,
			   sysdate last_update_dt
		 	   FROM amd_sent_to_a2a asta
		 	   LEFT OUTER JOIN whse w
		 	   ON asta.part_no = w.part
		 	   AND sc = 'C17PCAG'
		 	   AND asta.action_code != Amd_Defaults.DELETE_ACTION;
			    GROUP BY amd_utils.GetNsiSidFromPartNo(spo_prime_part_no) ;
		commit ;
	*/
	
	/*
	EXCEPTION WHEN OTHERS THEN
		null ;
	*/
	
	
	PROCEDURE LoadFslMob IS
		CURSOR cur IS
			SELECT spo_prime_part_no part_no,
				   loc_sid,
				   0,
				   NULL,
				   Amd_Defaults.INSERT_ACTION,
				   SYSDATE
				   FROM AMD_SENT_TO_A2A asta, AMD_SPARE_NETWORKS asn
				   WHERE asta.spo_prime_part_no = asta.part_no
				   AND asn.loc_type IN ('MOB', 'FSL')
				   AND asta.action_code != Amd_Defaults.DELETE_ACTION
				   AND asn.action_code != Amd_Defaults.DELETE_ACTION;
	
		CURSOR cur_req IS
			SELECT Amd_Partprime_Pkg.getSuperPrimePart(ansi.prime_part_no) part_no,
				   loc_sid,
				   SUM(NVL(r.demand_level,0)) demand_level
				   FROM RAMP r, AMD_NATIONAL_STOCK_ITEMS ansi, AMD_SENT_TO_A2A asta, AMD_SPARE_NETWORKS asn
				   WHERE r.sc LIKE 'C170008%'
				   AND SUBSTR(r.sc, 8, 6) = asn.loc_id
				   AND asn.loc_type IN ('MOB', 'FSL')
				   AND REPLACE(r.current_stock_number, '-') = ansi.nsn
				   AND ansi.prime_part_no = asta.part_no
				   AND Amd_Location_Part_Override_Pkg.IsNumeric(ansi.nsn) = 'Y'
				   AND ansi.action_code != Amd_Defaults.DELETE_ACTION
				   AND asta.action_code != Amd_Defaults.DELETE_ACTION
				   AND asn.action_code != Amd_Defaults.DELETE_ACTION
				   GROUP BY  Amd_Partprime_Pkg.getSuperPrimePart(ansi.prime_part_no) , loc_sid
				   HAVING SUM(NVL(r.demand_level,0))  > 0 ;
	
		TYPE ARRAY IS TABLE OF TMP_AMD_LOCATION_PART_OVERRIDE%ROWTYPE;
		l_data ARRAY;
		returnCode NUMBER ;
		I NUMBER := 0 ;
		cur_cnt NUMBER := 0 ;
		req_cnt NUMBER := 0 ;
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 300,
				pKey1 => 'LoadFslMod',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		BEGIN
			OPEN cur ;
	    	LOOP
			    FETCH cur BULK COLLECT INTO l_data LIMIT BULKLIMIT ;
				cur_cnt := cur_cnt + l_data.COUNT ;
		    	FORALL i IN 1..l_data.COUNT
		    	   INSERT INTO TMP_AMD_LOCATION_PART_OVERRIDE VALUES l_data(i);
				   COMMIT ;
		    	EXIT WHEN cur%NOTFOUND;			
		    END LOOP;
	    	CLOSE cur;
			COMMIT ;
	
		EXCEPTION WHEN OTHERS THEN
					ErrorMsg(
					   pSqlfunction 	  	  => 'LoadFslMob',
				   pTableName  	  	  => 'tmp_amd_location_part_override',
				   pError_location => 310) ;
				   RAISE ;
	  	END ;
		I := 0 ;
		FOR rec IN cur_req
		LOOP
	
			BEGIN
				UPDATE TMP_AMD_LOCATION_PART_OVERRIDE
					SET	   tsl_override_qty = rec.demand_level
					WHERE part_no = rec.part_no
							  AND loc_sid = rec.loc_sid ;
			EXCEPTION WHEN OTHERS THEN
					ErrorMsg(
					   pSqlfunction 	  	  => 'LoadFslMob',
				   pTableName  	  	  => 'tmp_amd_location_part_override',
				   pError_location => 320,
				   pKey1			  => rec.part_no,
	   			   pKey2			  => rec.loc_sid) ;
				   RAISE ;
	  		END ;
			IF (I > COMMITAFTER) THEN
			   COMMIT ;
			   I := 0 ;
			END IF ;
			I := I + 1 ;
			req_cnt := req_cnt + 1 ;
		END LOOP ;
		COMMIT ;
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 330,
				pKey1 => 'LoadFslMod',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'cur_cnt=' || cur_cnt,
				pKey4 => 'req_cnt=' || req_cnt) ;
	exception when others then			  
		 ErrorMsg(
				   pSqlfunction 	  => 'LoadFslMob',
				   pTableName  	  	  => 'tmp_amd_location_part_override',
				   pError_location => 340) ;
		 raise ;	
	END LoadFslMob ;
	
	
	PROCEDURE LoadWhse IS
		TYPE ARRAY IS TABLE OF TMP_AMD_LOCATION_PART_OVERRIDE%ROWTYPE;
		l_data ARRAY;
	
		CURSOR cursor_warehouse_parts IS
			   SELECT spo_prime_part_no part_no,
			   		  loc_sid,
					  0 tsl_override_qty,
					  NULL tsl_override_user,
					  'A' action_code,
					  SYSDATE last_update_dt
				   FROM AMD_SENT_TO_A2A asta, AMD_SPARE_NETWORKS asn
				   WHERE asta.spo_prime_part_no = asta.part_no
				   AND asn.loc_id = Amd_Defaults.AMD_WAREHOUSE_LOCID
				   AND asta.action_code != Amd_Defaults.DELETE_ACTION
				   AND asn.action_code != Amd_Defaults.DELETE_ACTION
				   and asn.SPO_LOCATION is not null ;
	
			 -- get all those whse where the rbl run had 0 value for and
			 --	1) sum all the tsls where FSL, MOB, UAB
			 --	2) from Total Spo Inventory, subtract out those from 1)
	
	
			-- tmp_amd_location_part_override is already by spo prime, no need to determine
		CURSOR cursor_peacetimeBasesSum IS
			  SELECT part_no, SUM(NVL(tsl_override_qty,0)) qty
			  	   FROM TMP_AMD_LOCATION_PART_OVERRIDE t, AMD_SPARE_NETWORKS asn
				   WHERE t.loc_sid = asn.loc_sid
				   AND t.action_code != Amd_Defaults.DELETE_ACTION
				   AND asn.action_code != Amd_Defaults.DELETE_ACTION
				   AND ( loc_type IN ('MOB', 'FSL', 'UAB', 'COD')
				   	     OR
						 loc_id IN (Amd_Defaults.AMD_BASC_LOC_ID, Amd_Defaults.AMD_UK_LOC_ID )
					   )
				   and asn.SPO_LOCATION is not null
				   GROUP BY part_no ;
		
		Cursor cursor_wartimeRspSum is
			   select part_no, sum(nvl(rsp_level,0)) qty
			   from amd_rsp_sum
			   group by part_no ;
	
		Cursor cursor_peacetimeBO_Spo_Sum is
			   select spo_prime_part_no,  qty
			   from amd_backorder_spo_sum
			   order by spo_prime_part_no ;
			   
				  -- get the whole list and the sum to spo prime
		CURSOR cursor_peacetimeSpoInv IS
			  SELECT spo_prime_part_no part_no,
			  		 SUM(NVL(spo_total_inventory,0)) qty
					  FROM AMD_SENT_TO_A2A asta, AMD_NATIONAL_STOCK_ITEMS ansi
					  WHERE asta.part_no = ansi.prime_part_no
					  AND asta.action_code != Amd_Defaults.DELETE_ACTION
					  AND ansi.action_code != Amd_Defaults.DELETE_ACTION
					  GROUP BY spo_prime_part_no ;
	
		TYPE partNo_sum IS TABLE OF NUMBER INDEX BY AMD_SPARE_PARTS.part_no%TYPE  ;
		-- arrays where index is nsi_sid, and the values are the sums
		partNoCandidates_sum partNo_sum ;
		partNoBases_sum partNo_sum ;
		partNoSpoInv_sum partNo_sum ;
		wareHouseLocSid AMD_SPARE_NETWORKS.loc_sid%TYPE ;
		basesTsl_Rsp_Backorder_sum NUMBER ;
		sumOfSpoTotalInv NUMBER ;
		AtlantaWarehouseQty NUMBER ;
		returnCode NUMBER ;
		I NUMBER := 0 ;
		cur_cnt NUMBER := 0 ;
		baseSum_cnt NUMBER := 0 ;
		spoInv_cnt NUMBER := 0 ;
		rsp_cnt number := 0 ;
		spoSum_cnt number := 0 ;
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 350,
				pKey1 => 'LoadWhse',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
			-- Calculation WareHouse TSLs
	
		BEGIN
			 -- load partNoBases_sum array where each partNo index has the sum for the bases
			FOR rec IN cursor_peacetimeBasesSum
			LOOP
				partNoBases_sum(rec.part_no) := rec.qty ;
				baseSum_cnt := baseSum_cnt + 1 ;
			END LOOP ;
			
			for rec in cursor_wartimeRspSum
			loop
				begin
					 partNoBases_sum(rec.part_no) := partNoBases_sum(rec.part_no) + rec.qty ;
				exception when standard.no_data_found then
					 partNoBases_sum(rec.part_no) := rec.qty ;
				end ;
				rsp_cnt := rsp_cnt + 1 ;
			end loop ;
	
			for rec in cursor_peacetimeBO_Spo_Sum
			loop
				begin
					 partNoBases_sum(rec.spo_prime_part_no) := partNoBases_sum(rec.spo_prime_part_no) + rec.qty ;
				exception when standard.no_data_found then
					 partNoBases_sum(rec.spo_prime_part_no) := rec.qty ;
				end ;
				spoSum_cnt := spoSum_cnt + 1 ;
			end loop ;
			 -- load partNoSpoInv_sum array where each partNo index has the total_spo_inventory
			FOR rec IN cursor_peacetimeSpoInv
			LOOP
				partNoSpoInv_sum(rec.part_no) := rec.qty ;
				spoInv_cnt := spoInv_cnt + 1 ;
			END LOOP ;
	
	--		wareHouseLocSid := amd_utils.GetLocSid(amd_defaults.AMD_WAREHOUSE_LOCID) ;
	
			-- cycle thru each of the zero candidates
			-- line up the partNo and do the necessary calculation.
			-- per each partNo
			-- 	   total_spo_inventory minus bases sum
			-- 	   if result negative, make result zero
			I := 0 ;
			FOR rec IN cursor_warehouse_parts
			LOOP
				BEGIN
					BEGIN
						 basesTsl_Rsp_Backorder_sum := partNoBases_sum(rec.part_no) ;
					EXCEPTION WHEN NO_DATA_FOUND THEN
						 basesTsl_Rsp_Backorder_sum := 0 ;
					END ;
					BEGIN
						 sumOfSpoTotalInv := partNoSpoInv_sum(rec.part_no) ;
					EXCEPTION WHEN NO_DATA_FOUND THEN
						 sumOfSpoTotalInv := 0 ;
					END ;
					AtlantaWarehouseQty := sumOfSpoTotalInv - basesTsl_Rsp_Backorder_sum ;
					IF (AtlantaWarehouseQty < 0) THEN
					   AtlantaWarehouseQty := 0 ;
					END IF ;
				    INSERT INTO TMP_AMD_LOCATION_PART_OVERRIDE
		 			    (
						  part_no,
						  loc_sid,
						  tsl_override_qty,
						  tsl_override_user,
						  action_code,
						  last_update_dt
		 				)
		 				VALUES
		 				(
		 				  rec.part_no,
						  rec.loc_sid,
						  AtlantaWarehouseQty,
						  NULL,
						  Amd_Defaults.INSERT_ACTION,
						  SYSDATE
		 				) ;
					   /*
						UPDATE tmp_amd_location_part_override
							SET tsl_override_AtlantaWarehouseQty = AtlantaWarehouseQty
							WHERE part_no = rec.part_no
							AND loc_sid = wareHouseLocSid ;
						*/
				EXCEPTION WHEN OTHERS THEN
					ErrorMsg(
					   pSqlfunction 	  	  => 'LoadWhse',
				   pTableName  	  	  => 'tmp_amd_location_part_override',
				   pError_location => 360,
				   pKey1			  => 'partNo: ' || rec.part_no) ;
				   RAISE ;
			    END ;
				IF (I > COMMITAFTER) THEN
			   	   COMMIT ;
			   	   I := 0 ;
				END IF ;
				I := I + 1 ;
				cur_cnt := cur_cnt + 1 ;
			END LOOP ;
	
		EXCEPTION WHEN OTHERS THEN
					ErrorMsg(
					   pSqlfunction 	  	  => 'LoadWhse',
				   pTableName  	  	  => 'tmp_amd_location_part_override',
				   pError_location => 370) ;
				   RAISE ;
		END ;
	
		COMMIT ;
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 380,
				pKey1 => 'LoadWhse',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'cur_cnt=' || to_char(cur_cnt),
				pKey4 => 'baseSum_cnt=' || to_char(baseSum_cnt),
				pData => 'spoInv_cnt=' || to_char(spoInv_cnt) || ' rsp_cnt=' || to_char(rsp_cnt) || ' spoSum_cnt=' || to_char(spoSum_cnt)) ;
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(
		   pSqlfunction 	  	  => 'LoadWhse',
	   pTableName  	  	  => 'tmp_amd_location_part_override',
	   pError_location => 390) ;
	   RAISE ;
	END LoadWhse ;
	
	
	FUNCTION GetFirstLogonIdForPart(pNsiSid AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE) RETURN AMD_PLANNER_LOGONS.logon_id%TYPE IS
		CURSOR cur( pNsiSid AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE ) IS
			SELECT apl.*
				FROM AMD_PLANNER_LOGONS apl, AMD_PLANNERS ap, AMD_NATIONAL_STOCK_ITEMS ansi
				WHERE ansi.nsi_sid = pNsiSid
				AND Amd_Preferred_Pkg.GetPreferredValue(ansi.planner_code_cleaned, ansi.planner_code) = ap.planner_code
				AND ap.planner_code = apl.planner_code
				AND ap.action_code != Amd_Defaults.DELETE_ACTION
				AND apl.action_code != Amd_Defaults.DELETE_ACTION
				-- AND ansi.action_code != Amd_Defaults.DELETE_ACTION the part may be deleted but we still
				-- need to send data when the a2a_pkg.loadAllA2A is performed and whatever logonId is needed for 
				-- the part should be sent too
				ORDER BY apl.planner_code, data_source, logon_id ;
		 retLogonId AMD_PLANNER_LOGONS%ROWTYPE := NULL ;
	BEGIN
		 IF NOT cur%ISOPEN
		 THEN
		 	OPEN cur(pNsiSid) ;
		 END IF ;
		 FETCH cur INTO retLogonId ;
		 IF cur%NOTFOUND THEN
		 	retLogonId.logon_id := NULL ;
		 END IF ;
		 CLOSE cur ;
		 RETURN retLogonId.logon_id ;
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(
		   pSqlfunction 	  	  => 'GetFirstLogonIdForPart',
	   pTableName  	  	  => 'amd_planner_logons',
	   pError_location => 400) ;
	   RAISE ;
	END GetFirstLogonIdForPart ;
	
	PROCEDURE LoadOverrideUsers IS
		CURSOR cur IS
			 SELECT part_no, nsi_sid, nsn
			 FROM TMP_AMD_LOCATION_PART_OVERRIDE talpo, AMD_NATIONAL_STOCK_ITEMS ansi
			 WHERE talpo.part_no = ansi.prime_part_no AND
			 	   talpo.action_code != Amd_Defaults.DELETE_ACTION AND
			 	   ansi.action_code != Amd_Defaults.DELETE_ACTION
			 ORDER BY nsi_sid;
		lastNsiSid AMD_NATIONAL_STOCK_ITEMS.nsi_sid%TYPE := -9993 ;
		-- TYPE partNo_logonId_tab IS TABLE OF amd_planner_logons.logon_id%TYPE INDEX BY amd_spare_parts.part_no%TYPE  ;
		-- partNo_logonId partNo_logonId_tab ;
		-- rowPartNo amd_spare_parts.part_no%TYPE  ;
		-- defaultUser amd_location_part_override.tsl_override_user%TYPE := Amd_Defaults.GetParamValue('override_user_default');
		tslOverrideUser AMD_LOCATION_PART_OVERRIDE.tsl_override_user%TYPE ;
		returnCode NUMBER ;
		cur_cnt NUMBER := 0 ;
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 410,
				pKey1 => 'LoadOverrideUsers',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
				
		 FOR rec IN cur
		 LOOP
		 	 BEGIN
			 	 IF (lastNsiSid != rec.nsi_sid) THEN
				 	-- partNo_logonId(rec.part_no) := nvl(GetFirstLogonIdForPart(rec.nsi_sid), amd_defaults.GetLogonId(rec.nsn) ) ;
					tslOverrideUser := NVL( GetFirstLogonIdForPart(rec.nsi_sid), Amd_Defaults.GetLogonId(rec.nsn) ) ;
					UPDATE TMP_AMD_LOCATION_PART_OVERRIDE
			 	 	   SET 	tsl_override_user = tslOverrideUser
			 	 	   WHERE	part_no = rec.part_no ;
				 END IF ;
				 lastNsiSid := rec.nsi_sid ;
			 EXCEPTION WHEN OTHERS THEN
					ErrorMsg(
					   pSqlfunction 	  	  => 'LoadOverrideUsers',
				   pTableName  	  	  => 'tmp_amd_location_part_override',
				   pError_location => 420,
				   pKey1			  => 'nsiSid: ' || rec.nsi_sid,
	   			   pKey2			  => 'partNo: ' || rec.part_no) ;
				   RAISE ;
			END ;
			cur_cnt := cur_cnt + 1 ;
		 END LOOP ;
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 430,
				pKey1 => 'LoadOverrideUsers',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'cur_cnt=' || cur_cnt) ;
		COMMIT ;
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(
		   pSqlfunction 	  	  => 'LoadOverrideUsers',
	   pTableName  	  	  => 'tmp_amd_location_part_override',
	   pError_location => 440) ;
	   RAISE ;
	END LoadOverrideUsers ;
	
	PROCEDURE processTsl(tsl IN tslCur, pDoAllA2A IN BOOLEAN) IS
		tslOverrideUser TMP_A2A_LOC_PART_OVERRIDE.OVERRIDE_USER%TYPE ;
		delete_cnt NUMBER := 0 ;
		batch_cnt NUMBER := 0 ;
		insert_cnt NUMBER := 0 ;
		rec_cnt NUMBER := 0 ;
		rec tslRec ;
		batchStart DATE := NVL(Amd_Batch_Pkg.getLastStartTime, TO_DATE('01/01/2100', 'MM/DD/YYYY') );
		returnCode NUMBER ;
		
		FUNCTION insertTmpA2A(spo_prime_part_no IN AMD_SENT_TO_A2A.SPO_PRIME_PART_NO%TYPE,
						  	  site_location IN TMP_A2A_LOC_PART_OVERRIDE.SITE_LOCATION%TYPE,
							  override_user IN TMP_A2A_LOC_PART_OVERRIDE.OVERRIDE_USER%TYPE) RETURN BOOLEAN IS
			
			action_code tmp_a2a_loc_part_override.action_code%type ;
			/*
			function getActionCode return varchar2 is
					 theActionCode amd_sent_to_a2a.action_code%type ;
					 
					procedure getSentA2AActionCode is
				 	begin
					 select action_code into theActionCode 
					 from amd_sent_to_a2a sent
					 where insertTmpA2A.spo_prime_part_no = sent.PART_NO
					 and sent.part_no = sent.spo_prime_part_no ;
					exception
					    when standard.no_data_found then
							 action_code := amd_defaults.INSERT_ACTION ; 
					    when others then
						ErrorMsg(
						   pSqlfunction 	 => 'getActionCode',
						   pTableName  	  	  => 'amd_sent_to_a2a',
						   pError_location => 450,
						   pKey1			  => 'spo_prime_part_no: ' || insertTmpA2A.spo_prime_part_no ) ;
						raise ;
					end getSentA2AActionCode ;
					
			begin
			
				 if instr(site_location,'_RSP') > 0 then
				 	begin
					 	select action_code into theActionCode
						from amd_rsp_sum rsp
						where rsp.part_no = insertTmpA2A.spo_prime_part_no
						and rsp.RSP_LOCATION = insertTmpA2A.site_location ;
					exception 
					    when standard.no_data_found then
							 action_code := amd_defaults.INSERT_ACTION ;
					    when others then
							ErrorMsg(
							   pSqlfunction 	  	  => 'getActionCode',
							   pTableName  	  	  => 'amd_location_part_override',
							   pError_location => 460,
							   pKey1			  => 'spo_prime_part_no: ' || insertTmpA2A.spo_prime_part_no,
							   pKey2 => 'site_location: ' || insertTmpA2A.site_location ) ;
							raise ;
					end ;
				 else
				 	begin
						 select ov.action_code into theActionCode
						 from amd_location_part_override ov,
						 amd_spare_networks netwk
						 where ov.part_no = insertTmpA2A.spo_prime_part_no
						 and netwk.spo_location = insertTmpA2A.site_location
						 and ov.loc_sid = netwk.loc_sid  ;
						 
						 if theActionCode <> amd_defaults.DELETE_ACTION then
						 	getSentA2AActionCode ;
						 end if ;
						 
					exception					    
					    when standard.no_data_found then
							 getSentA2AActionCode ;
						when others then
							ErrorMsg(
							   pSqlfunction 	  	  => 'getActionCode',
							   pTableName  	  	  => 'amd_location_part_override',
							   pError_location => 470,
							   pKey1			  => 'spo_prime_part_no: ' || insertTmpA2A.spo_prime_part_no,
							   pKey2 => 'site_location: ' || insertTmpA2A.site_location ) ;
							raise ;
					end ;
				 end if ;
				 if theActionCode is null then
				 	theActionCode := amd_defaults.INSERT_ACTION ;
				 end if ;				 
				 return theActionCode ;
				 
			exception when others then
				ErrorMsg(
				   pSqlfunction 	  	  => 'getActionCode',
				   pTableName  	  	  => 'getActionCode',
				   pError_location => 480,
				   pKey1	 => 'spo_prime_part_no: ' || insertTmpA2A.spo_prime_part_no ) ;

				   RAISE ;
			
			end getActionCode ;
			*/
		BEGIN
			if a2a_pkg.wasPartSent(spo_prime_part_no) and site_location IS NOT NULL  THEN
			
			     --action_code := getActionCode ;
				 
				 INSERT INTO TMP_A2A_LOC_PART_OVERRIDE (
					  part_no,
					  site_location,
					  override_type,
					  override_quantity,
					  override_reason,
					  override_user,
					  begin_date,
					  action_code,
					  last_update_dt
				 )
				 VALUES
				 (
				 	  insertTmpA2A.spo_prime_part_no,
					  insertTmpA2A.site_location,
					  OVERRIDE_TYPE,
					  0,
					  OVERRIDE_REASON,
					  insertTmpA2A.override_user,
					  SYSDATE,
					  rec.action_code,
					  SYSDATE
				 ) ;
				 RETURN TRUE ;
			END IF ;
			RETURN FALSE ;		
			
		EXCEPTION 
		    WHEN DUP_VAL_ON_INDEX THEN
		    -- a zero tsl quantity should not update an existing AtlantaWarehouseQty
			  RETURN FALSE ;
		    WHEN others THEN
			  ErrorMsg(
			   pSqlfunction 	  => 'insertTmpA2A',
			   pTableName  	  	  => 'tmp_a2a_loc_part_override',
			   pError_location => 490,
				   pKey1	  => 'spo_prime_part: ' || spo_prime_part_no,
	   			   pKey2	  => 'site_location: ' || site_location) ;

				   RAISE ;
			
		END insertTmpA2A ;
		
	BEGIN
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 500,
				pKey1 => 'processTsl',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
		 LOOP
		 	 FETCH tsl INTO rec ;
			 EXIT WHEN tsl%NOTFOUND ;
			 rec_cnt := rec_cnt + 1 ;
			 IF MOD(insert_cnt + delete_cnt + batch_cnt,  COMMIT_THRESHOLD) = 0 THEN
			 	COMMIT ;
			 END IF  ;
			 BEGIN
				tslOverrideUser := NVL(GetFirstLogonIdForPart(rec.nsi_sid), Amd_Defaults.GetLogonId(rec.nsn) ) ;
				IF ( pDoAllA2A AND rec.action_code != Amd_Defaults.DELETE_ACTION) THEN
				    IF rec.override_quantity > 0 THEN 
				   		IF insertedTmpA2ALPO (
						  rec.spo_prime_part_no,
						  rec.spo_location,
						  OVERRIDE_TYPE,
						  rec.override_quantity,
						  OVERRIDE_REASON,
						  tslOverrideUser,
						  SYSDATE,
						  rec.action_code,
						  SYSDATE
						)	THEN
							insert_cnt := insert_cnt + 1 ;
					    END IF ;
					ELSE
						IF insertTmpA2A(rec.spo_prime_part_no,
						  				rec.spo_location,
						  				tslOverrideUser) THEN
							insert_cnt := insert_cnt + 1 ;
						END IF ;
					END IF ;
					-- do change only
				ELSIF ( rec.action_code = Amd_Defaults.INSERT_ACTION
					    AND ( rec.transaction_date >= batchStart ) )THEN
				   IF rec.override_quantity > 0 THEN
					   IF insertedTmpA2ALPO (
						  rec.spo_prime_part_no,
						  rec.spo_location,
						  OVERRIDE_TYPE,
						  rec.override_quantity,
						  OVERRIDE_REASON,
						  tslOverrideUser,
						  SYSDATE,
						  Amd_Defaults.INSERT_ACTION,
						  SYSDATE
						)	THEN
						batch_cnt := batch_cnt + 1 ;
					   END IF ;
					ELSE
						IF insertTmpA2A(rec.spo_prime_part_no,
						  				rec.spo_location,
						  				tslOverrideUser) THEN
							batch_cnt := batch_cnt + 1 ;
						END IF ;
					END IF ;
				ELSIF ( rec.action_code = Amd_Defaults.DELETE_ACTION
					   AND ( rec.transaction_date >= batchStart ) )THEN
					-- if action_code deleted, do nothing since part info deletes part
	
					 IF insertedTmpA2ALPO (
					  rec.spo_prime_part_no,
					  rec.spo_location,
					  OVERRIDE_TYPE,
					  rec.override_quantity,
					  OVERRIDE_REASON,
					  tslOverrideUser,
					  SYSDATE,
					  Amd_Defaults.DELETE_ACTION,
					  SYSDATE
					)	THEN
					  delete_cnt := delete_cnt + 1 ;
				    END IF ;
				ELSE
					-- if action_code changed, do nothing since always default to zero
				   NULL ;
				END IF ;
			EXCEPTION WHEN OTHERS THEN
					ErrorMsg(
					   pSqlfunction 	  	  => 'processTsl',
				   pTableName  	  	  => 'tmp_amd_location_part_override',
				   pError_location => 510,
				   pKey1			  => 'spo_prime_part: ' || rec.spo_prime_part_no,
	   			   pKey2			  => 'action_code: ' || rec.action_code,
				   pKey3			  => 'spo_location: ' || rec.spo_location,
				   pKey4			  => 'icnt:' || insert_cnt || ' dcnt:' || delete_cnt || ' bcnt: ' || batch_cnt) ;

				   RAISE ;
			END ;
			 
		 END LOOP ;
		 
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 520,
				pKey1 => 'processTsl',
				pKey2 => 'rec_cnt=' || rec_cnt,
				pKey3 => 'insert_cnt=' || insert_cnt,
				pKey4 => 'delete_cnt=' || delete_cnt, 
				pData => 'batch_cnt=' || batch_cnt,
				pComments => 'processTsl ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	    COMMIT ;
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(
		   pSqlfunction 	  	  => 'processTsl',
	   pTableName  	  	  => 'tmp_a2a_loc_part_override',
	   pError_location => 530) ;
	   RAISE ;
	END processTsl ;
	
	PROCEDURE loadZeroTslA2AByDate(pDoAllA2A IN BOOLEAN, 
			  from_dt IN DATE, to_dt IN DATE, pSpolocation IN VARCHAR2) IS
			
	BEGIN
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 540,
				pKey1 => 'LoadZeroTslA2AByDate', 
				pKey2 => 'from_dt=' || to_char(from_dt,'MM/DD/YYYY'),
				pKey3 => 'to_dt=' ||  to_char(to_dt,'MM/DD/YYYY'),
				pKey4 => 'pDoAllA2A=' || amd_utils.boolean2Varchar2(pDoAllA2A) || ' pSpoLocation=' || pSpoLocation,
				pData => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
		loadZeroTslA2A(pDoAllA2A, pSpoLocation, from_dt, to_dt) ;
	
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 550,
				pKey1 => 'LoadZeroTslA2AByDate',
				pKey2 => 'from_dt=' || to_char(from_dt,'MM/DD/YYYY'),
				pKey3 => 'to_dt=' || to_char(to_dt,'MM/DD/YYYY'),
				pKey4 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(
		   pSqlfunction 	  	  => 'loadZeroTslA2AByDate',
	   pTableName  	  	  => 'tmp_a2a_loc_part_override',
	   pError_location => 560) ;
	   RAISE ;
	END loadZeroTslA2AByDate ;
	
	PROCEDURE  LoadZeroTslA2A(pDoAllA2A BOOLEAN, pSpoLocation VARCHAR2,from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE)   IS
		
		tsl tslCur ;
		rc number ;
		
		procedure openTestData is
		begin
		  	writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 561,
	 		pKey1 => 'getTestData' ) ;
			commit ;

			   OPEN tsl FOR
			   SELECT distinct sent.spo_prime_part_no,
			   sent.action_code action_code,
			   sysdate,
			   pSpoLocation spo_location,
			   ansi.nsn,
			   ansi.nsi_sid,
			   0 override_AtlantaWarehouseQty
			   FROM  AMD_NATIONAL_STOCK_ITEMS ansi, amd_sent_to_a2a sent, amd_test_parts testParts
			   WHERE ansi.prime_part_no = sent.spo_prime_part_no
			   and sent.part_no = sent.spo_prime_part_no
			   and not exists (
					 SELECT null 
					 FROM TMP_A2A_LOC_PART_OVERRIDE
					 WHERE part_no = sent.spo_prime_part_no
					 AND site_location = pSpoLocation) 
			   AND ansi.action_code != Amd_Defaults.getDELETE_ACTION
			   AND sent.spo_prime_part_no = testParts.PART_NO ; 
		end openTestData ;
		
		procedure getAllData is
		begin
		  	writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 562,
	 		pKey1 => 'getAllData' ) ;
			commit ;

			   OPEN tsl FOR
			   SELECT distinct sent.spo_prime_part_no,
			   sent.action_code action_code,
			   sysdate,
			   pSpoLocation spo_location,
			   ansi.nsn,
			   ansi.nsi_sid,
			   0 override_AtlantaWarehouseQty
			   FROM  AMD_NATIONAL_STOCK_ITEMS ansi, amd_sent_to_a2a sent
			   WHERE ansi.prime_part_no = sent.spo_prime_part_no
			   and sent.part_no = sent.spo_prime_part_no
			   and not exists (
					 SELECT null 
					 FROM TMP_A2A_LOC_PART_OVERRIDE
					 WHERE part_no = sent.spo_prime_part_no
					 AND site_location = pSpoLocation) 
			   AND ansi.action_code != Amd_Defaults.getDELETE_ACTION ;
			   
		end getAllData ;
		
		procedure getDataByLastUpdateDt is
		begin
		  	writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 563,
	 		pKey1 => 'getDataByLastUpdateDt' ) ;
			commit ;
			OPEN tsl FOR
			   SELECT distinct sent.spo_prime_part_no,
			   sent.action_code action_code,
			   sysdate,
			   pSpoLocation spo_location,
			   ansi.nsn,
			   ansi.nsi_sid,
			   0 override_AtlantaWarehouseQty
			   FROM  AMD_NATIONAL_STOCK_ITEMS ansi, amd_sent_to_a2a sent, amd_spare_parts parts
			   WHERE ansi.prime_part_no = sent.spo_prime_part_no
			   and sent.part_no = sent.spo_prime_part_no
			   and ansi.action_code != Amd_Defaults.getDELETE_ACTION			   
			   and parts.part_no = sent.spo_prime_part_no
			   and not exists (
					 SELECT null 
					 FROM TMP_A2A_LOC_PART_OVERRIDE
					 WHERE part_no = sent.spo_prime_part_no
					 AND site_location = pSpoLocation) 
			   and parts.action_code <> amd_defaults.getDELETE_ACTION
			   and ( trunc(ansi.last_update_dt) between trunc(from_dt) and trunc(to_dt)
			   	   or trunc(parts.last_update_dt) between trunc(from_dt) and trunc(to_dt) ) ;					   
		end getDataByLastUpdateDt ;
		
		procedure getDataByTranDtAndBatchTime is
		begin
				-- and then transaction_date >= amd_batch_jobs.start_time
		  	writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 564,
	 		pKey1 => 'getDataByTranDtAndBatchTime' ) ;
			commit ;
			   OPEN tsl FOR
				   SELECT distinct sent.spo_prime_part_no,
				   sent.action_code action_code,
				   sysdate,
				   pSpoLocation spo_location,
				   ansi.nsn,
				   ansi.nsi_sid,
				   0 override_AtlantaWarehouseQty
				   FROM  AMD_NATIONAL_STOCK_ITEMS ansi, amd_sent_to_a2a sent, amd_spare_parts parts
				   where ansi.prime_part_no = sent.spo_prime_part_no
				   and sent.part_no = sent.spo_prime_part_no
				   AND ansi.action_code != Amd_Defaults.getDELETE_ACTION
				   and parts.part_no = sent.spo_prime_part_no
				   and not exists (
						 SELECT null 
						 FROM TMP_A2A_LOC_PART_OVERRIDE
						 WHERE part_no = sent.spo_prime_part_no
						 AND site_location = pSpoLocation) 
				   and parts.action_code != amd_defaults.getDELETE_ACTION
				   and  (  trunc(ansi.last_update_dt) >= TRUNC(Amd_Batch_Pkg.getLastStartTime)
				   	    or trunc(parts.last_update_dt) >= TRUNC(Amd_Batch_Pkg.getLastStartTime) ) ;
		end getDataByTranDtAndBatchTime ;		
		
	BEGIN
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 570,
				pKey1 => 'LoadZeroTslA2A',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'pDoAllA2A=' || amd_utils.boolean2Varchar2(pDoAllA2A),
				pKey4 => 'pSpoLocation=' || pSpoLocation,
				pData => 'from_dt=' || to_char(from_dt,'MM/DD/YYYY'),
				pComments => 'to_dt=' || to_char(to_dt,'MM/DD/YYYY') 
					  || ' useTestData=' || amd_utils.boolean2Varchar2(useTestData) ) ;
	    COMMIT ;
		
		-- pDoAllA2A has the highest priority
		IF pDoAllA2A THEN
		   IF useTestData THEN
		   	  openTestData ;
			ELSE
			  getAllData ;
			END IF ;
		ELSE
			-- then by date range
			IF TRUNC(from_dt) <> TRUNC(A2a_Pkg.start_dt) OR TRUNC(to_dt) <> TRUNC(SYSDATE) THEN
						getDataByLastUpdateDt ;
			ELSIF useTestData THEN
				  openTestData ;
			ELSE
				getDataByTranDtAndBatchTime ;
			END IF ;
		END IF ;
		
		processTsl(tsl, pDoAllA2A) ;
		
		CLOSE tsl ;
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 580,
				pKey1 => 'LoadZeroTslA2A',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
				pKey3 => 'pSpoLocation=' || pSpoLocation) ;
	    COMMIT ;
    exception when others then
		ErrorMsg(
		   pSqlfunction	  	  => 'LoadZeroTslA2A',
	   pTableName  	  	  => 'tmp_a2a_loc_part_override',
	   pError_location => 590) ;
		RAISE ;

	END LoadZeroTslA2A ;
	
	PROCEDURE LoadTmpAmdLocPartOverride IS
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 600,
				pKey1 => 'LoadTmpAmdLocPartOverride',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
				
		 Mta_Truncate_Table('tmp_amd_location_part_override','reuse storage');
		 Amd_Batch_Pkg.truncateIfOld('tmp_a2a_loc_part_override') ; 	 
		 COMMIT ;
		 LoadFslMob ;
		 LoadUk ;
		 LoadBasc ;
		 LoadWhse ;
		 LoadOverrideUsers ;
		 
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 610,
				pKey1 => 'LoadTmpAmdLocPartOverride',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
    exception when others then
		ErrorMsg(
		   pSqlfunction	  	  => 'LoadTmpAmdLocPartOverride',
	   pTableName  	  	  => 'tmp_amd_location_part_override',
	   pError_location => 620) ;
		RAISE ;

	END LoadTmpAmdLocPartOverride;
	
	PROCEDURE LoadZeroTslA2A(doAllA2A IN BOOLEAN := FALSE, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE) IS
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 630,
				pKey1 => 'LoadZeroTslA2A',
				pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
				pKey3 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
				pKey4 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
				pData => 'usesTestData=' || Amd_Utils.boolean2Varchar2(useTestData),
				pComments => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
			-- do Inserts/Deletes only, i.e. not initial load
		loadZeroTslA2APartsWithNoTsls(doAllA2A => doAllA2A, useTestData => useTestData) ;
		loadZeroTslA2A4DelSpoPrimParts(doAllA2A => doAllA2A, useTestData => useTestData) ;
		loadRspZeroTslA2A(doAllA2A => doAllA2A, useTestData => useTestData) ;
		LoadZeroTslA2A( doAllA2A, Amd_Location_Part_Leadtime_Pkg.VIRTUAL_COD_SPO_LOCATION, from_dt, to_dt, useTestData ) ;
		LoadZeroTslA2A( doAllA2A, Amd_Location_Part_Leadtime_Pkg.VIRTUAL_UAB_SPO_LOCATION, from_dt, to_dt, useTestData ) ;
		loadZeroTslA2A( doAllA2A, amd_location_part_override_pkg.THE_WAREHOUSE, from_dt, to_dt, useTestData) ;
	
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 640,
				pKey1 => 'LoadZeroTslA2A',
				pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
				pKey3 => 'from_dt=' ||  TO_CHAR(from_dt,'MM/DD/YYYY'),
				pKey4 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
				pData =>  'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
    exception when others then
		ErrorMsg(
		   pSqlfunction	 => 'LoadZeroTslA2A',
	   pTableName  	  	  => 'tmp_amd_location_part_override',
	   pError_location => 650) ;
		RAISE ;

	END LoadZeroTslA2A ;
	
	PROCEDURE loadA2AByDate( from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE) IS
		returnCode NUMBER ;
		doAllA2A BOOLEAN := TRUE ;
		cnt NUMBER := 0 ;
		lpo TMP_A2A_LOC_PART_OVERRIDE%ROWTYPE ;
		rc NUMBER ;
		dataByDate locPartOverrideCur ;
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 660,
				pKey1 => 'loadA2AByDate',
				pKey2 => 'from_dt=' || to_char(from_dt,'MM/DD/YYYY'),
				pKey3 => 'to_dt='  || to_char(to_dt,'MM/DD/YYYY'),
				pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
		 Amd_Batch_Pkg.truncateIfOld('tmp_a2a_loc_part_override') ;
		 OPEN dataByDate FOR
		 	 SELECT alpo.part_no,
			 		spo_location AS site_location,
					OVERRIDE_TYPE AS override_type,
					tsl_override_qty AS override_quantity,
					OVERRIDE_REASON AS override_reason,
					tsl_override_user,
					SYSDATE AS begin_date,
					NULL AS end_date,
					alpo.action_code AS action_code,
					SYSDATE AS last_update_dt
			 FROM AMD_LOCATION_PART_OVERRIDE alpo, AMD_SPARE_NETWORKS asn
			 WHERE alpo.loc_sid = asn.loc_sid
			 	   AND alpo.action_code != Amd_Defaults.DELETE_ACTION
				   AND TRUNC(alpo.last_update_dt) BETWEEN TRUNC(from_dt) AND TRUNC(to_dt)
				   AND alpo.part_no IN 
				   	   (SELECT DISTINCT spo_prime_part_no 
					    FROM AMD_SENT_TO_A2A 
					    WHERE action_code != Amd_Defaults.DELETE_ACTION) ;
		 processLocPartOverride(dataByDate) ;
		 CLOSE dataByDate ;
		 LoadZeroTslA2A( doAllA2A, from_dt, to_dt ) ;
	
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 670,
				pKey1 => 'loadA2AByDate',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
    exception when others then
		ErrorMsg(
		   pSqlfunction	 => 'LoadA2AByDate',
	   pTableName  	  	  => 'tmp_amd_location_part_override',
	   pError_location => 680) ;
		RAISE ;

	END loadA2AByDate ;
	
	PROCEDURE processLocPartOverride(locPartOverride IN locPartOverrideCur) IS
		cnt NUMBER := 0 ;
		lpo TMP_A2A_LOC_PART_OVERRIDE%ROWTYPE ;
		rec locPartOverrideRec ;
		rc number ;
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 690,
				pKey1 => 'processLocPartOverride',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
		 LOOP
		 	 FETCH locPartOverride INTO rec ;
			 EXIT WHEN locPartOverride%NOTFOUND ;
			 	 lpo.part_no := rec.part_no ;
				 lpo.site_location := rec.site_location ;
				 lpo.override_type := rec.override_type ;
				 lpo.override_quantity := rec.override_quantity ;
				 lpo.override_reason := rec.override_reason ;
				 lpo.override_user := rec.tsl_override_user ;
				 lpo.begin_date := rec.begin_date ;
				 lpo.end_date := rec.end_date ;
				 lpo.action_code := rec.action_code ;
				 lpo.last_update_dt := rec.last_update_dt ;
			 	 IF insertedTmpA2ALPO(lpo) THEN
			 	 	cnt := cnt + 1 ;
					IF MOD(cnt,COMMIT_THRESHOLD) = 0 THEN
					   COMMIT ;
					END IF ;
				 ELSE
				   Amd_Utils.debugMsg(pMsg => 'Part/site_location was not loaded to tmp_a2a_loc_part_override',
				   	  pPackage => 'amd_location_part_override_pkg.processLocPartOverride',
					  pLocation => 222,
					  pMsg2 =>rec.part_no, 
					  pMsg4 => rec.site_location) ;
				 END IF ;		 
		 END LOOP ;	 
		 writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 700,
				pKey1 => 'processLocPartOverride',
				pKey2 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
		 		pKey3 => 'cnt=' || cnt) ;
		 COMMIT ;
	exception when others then
		ErrorMsg(pSqlfunction => 'processLocPartOverride',pTableName => 'tmp_a2a_loc_part_override',
			   pError_location => 710) ;
		RAISE ;
	END processLocPartOverride ;
	
	PROCEDURE LoadAllA2A( useTestData IN BOOLEAN := FALSE, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE) IS
		returnCode NUMBER ;
		doAllA2A BOOLEAN := TRUE ;
		overrides locPartOverrideCur ;
		rc NUMBER ;
		procedure getTestData is
		begin
		  	writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 701,
	 		pKey1 => 'getTestData' ) ;
			commit ;
		 	OPEN overrides FOR
			 	 SELECT alpo.part_no,
				 		spo_location AS site_location,
						OVERRIDE_TYPE AS override_type,
						tsl_override_qty AS override_quantity,
						OVERRIDE_REASON AS override_reason,
						tsl_override_user,
						SYSDATE AS begin_date,
						NULL AS end_date,
						sent.action_code AS action_code,
						SYSDATE AS last_update_dt
				 FROM AMD_LOCATION_PART_OVERRIDE alpo, AMD_SPARE_NETWORKS asn, amd_sent_to_a2a sent
				 WHERE alpo.loc_sid = asn.loc_sid
					   AND alpo.part_no = sent.part_no
					   and sent.SPO_PRIME_PART_NO is not null
					   and sent.PART_NO = sent.SPO_PRIME_PART_NO 
					   AND alpo.part_no IN (SELECT part_no FROM AMD_TEST_PARTS)
				union
				select distinct rsp.part_no,
				rsp_location,
				OVERRIDE_TYPE as override_type,
				case rsp.action_code
					 when amd_defaults.getDELETE_ACTION then
					 	  0
					 else
					 	 rsp_level
				end override_quantity,
				OVERRIDE_REASON as override_reason,
				Amd_Location_Part_Override_Pkg.GetFirstLogonIdForPart(Amd_Utils.GetNsiSidFromPartNo(rsp.part_no)),
				sysdate as begin_date,
				null as end_date,
			   	sent.action_code,
				sysdate as last_update_dt
				from amd_rsp_sum rsp, amd_sent_to_a2a sent
				where rsp.part_no = sent.part_no
				and sent.part_no = sent.spo_prime_part_no
				and sent.SPO_PRIME_PART_NO is not null
				and rsp.part_no in (select part_no from amd_test_parts) ;			
		end getTestData ;
		procedure getDataByLastUpdateDt is
		begin
		  	writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 702,
	 		pKey1 => 'getDataByLastUpdateDt' ) ;
			commit ;
			OPEN overrides FOR
		 	 SELECT alpo.part_no,
			 		spo_location AS site_location,
					OVERRIDE_TYPE AS override_type,
					tsl_override_qty AS override_quantity,
					OVERRIDE_REASON AS override_reason,
					tsl_override_user,
					SYSDATE AS begin_date,
					NULL AS end_date,
					sent.action_code AS action_code,
					SYSDATE AS last_update_dt
			 FROM AMD_LOCATION_PART_OVERRIDE alpo, AMD_SPARE_NETWORKS asn, amd_sent_to_a2a sent
			 WHERE alpo.loc_sid = asn.loc_sid
				   AND TRUNC(alpo.last_update_dt) BETWEEN TRUNC(from_dt) AND TRUNC(to_dt)
				   AND alpo.part_no = sent.part_no
				   and sent.SPO_PRIME_PART_NO is not null
				   and sent.part_no = sent.spo_prime_part_no 
			union
			select distinct rsp.part_no,
			rsp_location,
			OVERRIDE_TYPE as override_type,
			case rsp.action_code
				 when amd_defaults.getDELETE_ACTION then
			 	  0
				 else
				 	 rsp_level
			end override_quantity,
			OVERRIDE_REASON as override_reason,
			Amd_Location_Part_Override_Pkg.GetFirstLogonIdForPart(Amd_Utils.GetNsiSidFromPartNo(rsp.part_no)),
			sysdate as begin_date,
			null as end_date,
		    sent.action_code,
			sysdate as last_update_dt
			from amd_rsp_sum rsp, amd_sent_to_a2a sent
			where trunc(last_update_dt) between trunc(from_dt) and trunc(to_dt) 
			and rsp.part_no = sent.part_no
			and sent.part_no = sent.spo_prime_part_no
			and sent.SPO_PRIME_PART_NO is not null ;						
		end getDataByLastUpdateDt ;

		procedure getAllData is
		begin
		  	writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 703,
	 		pKey1 => 'getAllData' ) ;
			commit ;
			OPEN overrides FOR
		 	 SELECT sent.spo_prime_part_no,
			 		spo_location AS site_location,
					OVERRIDE_TYPE AS override_type,
					tsl_override_qty AS override_quantity,
					OVERRIDE_REASON AS override_reason,
					tsl_override_user,
					SYSDATE AS begin_date,
					NULL AS end_date,
					sent.action_code AS action_code,
					SYSDATE AS last_update_dt
			 FROM AMD_LOCATION_PART_OVERRIDE alpo, AMD_SPARE_NETWORKS asn, amd_sent_to_a2a sent
			 WHERE alpo.loc_sid = asn.loc_sid
			 	   AND alpo.part_no = sent.part_no 
			 	   and sent.SPO_PRIME_PART_NO is not null
				   and sent.spo_prime_part_no = sent.part_no 
			union
			select distinct sent.spo_prime_part_no,
			rsp_location,
			OVERRIDE_TYPE as override_type,
			case rsp.action_code
				 when amd_defaults.getDELETE_ACTION then
				 	  0
				 else
				 	 rsp_level
			end override_quantity,
			OVERRIDE_REASON as override_reason,
			Amd_Location_Part_Override_Pkg.GetFirstLogonIdForPart(Amd_Utils.GetNsiSidFromPartNo(rsp.part_no)),
			sysdate as begin_date,
			null as end_date,
			sent.action_code,
			sysdate as last_update_dt
			from amd_rsp_sum rsp, 
			amd_sent_to_a2a sent
			where  rsp.part_no = sent.part_no
			and sent.spo_prime_part_no = sent.part_no 
			and sent.SPO_PRIME_PART_NO is not null ;
		end getAllData ;

	BEGIN
		 writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 720,
		 		pKey1 => 'LoadAllA2A',
				pKey2 => 'useTestData=' || Amd_Utils.boolean2Varchar2(useTestData),
				pKey3 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
				pKey4 => 'to_dt='  || TO_CHAR(to_dt,'MM/DD/YYYY'),
				pData => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
		 Mta_Truncate_Table('tmp_a2a_loc_part_override','reuse storage');
		 a2a_pkg.setSendAllData(true) ;
		 IF useTestData THEN
			getTestData ;
		ELSE
			IF TRUNC(from_dt) <> TRUNC(A2a_Pkg.start_dt) OR TRUNC(to_dt) <> TRUNC(SYSDATE) THEN
				getDataByLastUpdateDt ;
			ELSE
			 	getAllData ; 
			END IF ;
		END IF ;

		processLocPartOverride(overrides) ;
		CLOSE overrides ;

		loadZeroTslA2A(doAllA2A => TRUE, from_dt => from_dt, to_dt => to_dt, useTestData => useTestData) ;
		
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 760,
		 		pKey1 => 'LoadAllA2A',
				pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
				pKey3 => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
				pKey4 => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
				pData => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
				
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(
		   pSqlfunction 	  	  => 'LoadAllA2A',
		   pTableName  	  	  => 'tmp_a2a_loc_part_override',
		   pError_location => 770,
		   pKey1			  => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
  		   pKey2			  => 'from_dt=' || TO_CHAR(from_dt,'MM/DD/YYYY'),
		   pKey3			  => 'to_dt=' || TO_CHAR(to_dt,'MM/DD/YYYY'),
		   pKey4  		      => 'useTestData=' || Amd_Utils.boolean2Varchar2(useTestData)) ;
		RAISE ;
	END LoadAllA2A ;
	
	PROCEDURE LoadInitial IS
		 returnCode NUMBER ;
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 780,
		 		pKey1 => 'LoadInitial',
				pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
		 
		 LoadTmpAmdLocPartOverride ;
	 	 Mta_Truncate_Table('amd_location_part_override','reuse storage');
		 COMMIT ;
		 INSERT INTO AMD_LOCATION_PART_OVERRIDE
		 	SELECT * FROM TMP_AMD_LOCATION_PART_OVERRIDE ;
		 COMMIT ;
		 LoadAllA2A ;
		 dbms_output.put_line('LoadInitial ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(pSqlfunction => 'LoadInitial', pTableName => 'tmp_amd_location_part_override',
				   pError_location => 790 ) ;
		RAISE ;
	END LoadInitial ;
	
	PROCEDURE loadZeroTslA2APartsWithNoTsls(doAllA2A IN BOOLEAN := FALSE, useTestData IN BOOLEAN := FALSE) IS
			  tsl tslCur ;
			  
			  procedure getTestData is 
			  begin
		  		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 800,
	 			pKey1 => 'getTestData' ) ;
				commit ;
			   OPEN tsl FOR
				SELECT spo_prime_part_no,
				sent.action_code action_code, 
				transaction_date, 
				loc_id spo_location,
				items.nsn,
				nsi_sid,
				0 override_quantity 
				FROM AMD_SENT_TO_A2A sent, AMD_NATIONAL_STOCK_ITEMS items, 
					   ( 
					   SELECT loc_id FROM AMD_SPARE_NETWORKS n 
					   WHERE (n.LOC_TYPE IN ('FSL','MOB') AND n.SPO_LOCATION IS NOT NULL) 
					   OR loc_id IN (amd_location_part_leadtime_pkg.BASC_LOCATION, 
					   	  		     amd_location_part_leadtime_pkg.UK_LOCATION) 
					   ) spo_locations, amd_test_parts testParts 
				WHERE sent.part_no NOT IN (SELECT DISTINCT part_no FROM AMD_LOCATION_PART_OVERRIDE WHERE action_code <> 'D')
				AND not exists (
					 SELECT null 
					 FROM TMP_A2A_LOC_PART_OVERRIDE
					 WHERE part_no = spo_prime_part_no
					 AND site_location = spo_locations.loc_id) 
				AND sent.part_no = testParts.PART_NO
				and sent.part_no = sent.spo_prime_part_no
				AND spo_prime_part_no = items.prime_part_no 
				and items.LAST_UPDATE_DT >= (select max(last_update_dt)
					               from amd_national_stock_items where prime_part_no = spo_prime_part_no) ;				
			  end getTestData ;
			  
			  procedure getAllData is
			  begin
		  		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 810,
	 			pKey1 => 'getAllData' ) ;
				commit ;
			   	OPEN tsl FOR
				SELECT spo_prime_part_no,
				sent.action_code action_code, 
				transaction_date, 
				loc_id spo_location,
				nsn,
				nsi_sid,
				0 override_quantity 
				FROM AMD_SENT_TO_A2A sent, AMD_NATIONAL_STOCK_ITEMS items,  
					   ( 
					   SELECT loc_id FROM AMD_SPARE_NETWORKS n 
					   WHERE (n.LOC_TYPE IN ('FSL','MOB') AND n.SPO_LOCATION IS NOT NULL) 
					   OR loc_id IN (amd_location_part_leadtime_pkg.BASC_LOCATION, 
					   	  		     amd_location_part_leadtime_pkg.UK_LOCATION) 
					   ) spo_locations 
				WHERE part_no NOT IN (SELECT DISTINCT part_no FROM AMD_LOCATION_PART_OVERRIDE WHERE action_code <> 'D')
				AND not exists (
					 SELECT null 
					 FROM TMP_A2A_LOC_PART_OVERRIDE
					 WHERE part_no = spo_prime_part_no
					 AND site_location = spo_locations.loc_id) 
				and sent.part_no = sent.spo_prime_part_no
				AND spo_prime_part_no = items.prime_part_no 
				and items.LAST_UPDATE_DT >= (select max(last_update_dt)
					 from amd_national_stock_items where prime_part_no = spo_prime_part_no) ;				 
			  end getAllData ;
			  
			  procedure getDataByTranDtAndBatchTime is
			  begin
		  		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 820,
	 			pKey1 => 'getDataByTranDtAndBatchTime' ) ;
				commit ;
				
			 	OPEN tsl FOR
					SELECT spo_prime_part_no,
					sent.action_code action_code, 
					transaction_date, 
					loc_id spo_location,
					nsn,
					nsi_sid,
					0 override_quantity 
					FROM AMD_SENT_TO_A2A sent, AMD_NATIONAL_STOCK_ITEMS items,  
						   ( 
						   SELECT loc_id FROM AMD_SPARE_NETWORKS n 
						   WHERE (n.LOC_TYPE IN ('FSL','MOB') AND n.SPO_LOCATION IS NOT NULL) 
						   OR loc_id IN ('EY1746', 'EY8780') 
						   ) spo_locations 
					WHERE part_no NOT IN (SELECT DISTINCT part_no FROM AMD_LOCATION_PART_OVERRIDE WHERE action_code <> 'D') 
					AND not exists (
						 SELECT null 
						 FROM TMP_A2A_LOC_PART_OVERRIDE
						 WHERE part_no = spo_prime_part_no
						 AND site_location = spo_locations.loc_id) 
					AND spo_prime_part_no = items.prime_part_no
					and items.LAST_UPDATE_DT >= (select max(last_update_dt)
					 	from amd_national_stock_items where prime_part_no = spo_prime_part_no)
				    and sent.part_no = sent.spo_prime_part_no
					and sent.ACTION_CODE <> amd_defaults.getDELETE_ACTION 
					AND TRUNC(transaction_date) >= TRUNC(Amd_Batch_Pkg.getLastStartTime) ;
			  end getDataByTranDtAndBatchTime ;
			  
	BEGIN
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 830,
		 		pKey1 => 'loadZeroTslA2APartsWithNoTsls',
				pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
				pKey3 => 'useTestData=' || Amd_Utils.boolean2Varchar2(useTestData),
				pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	    COMMIT ;
		IF doAllA2A THEN
		   IF useTestData THEN
		   	   getTestData ;
		   ELSE
		   	   getAllData ;
		   END IF ;
		ELSE
			IF useTestData THEN
			   getTestData ;
			ELSE
				getDataByTranDtAndBatchTime ;
			END IF ;
		END IF ;
		
			
		processTsl(tsl, doAllA2A) ;
		CLOSE tsl ;
	
		writeMsg(pTableName => 'tmp_amd_location_part_override', pError_location => 840,
		 		pKey1 => 'loadZeroTslA2APartsWithNoTsls',
				pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
				pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	    COMMIT ;
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(pSqlfunction => 'loadZeroTslA2APartsWithNoTsls',pTableName => 'tmp_amd_location_part_override',
				   pError_location => 850 ) ;
		RAISE ;
	END loadZeroTslA2APartsWithNoTsls ;
	
	PROCEDURE loadRspZeroTslA2A(doAllA2A IN BOOLEAN := FALSE, useTestData in boolean := false ) IS 
			  rspTsl tslCur ;
			  
			  procedure getTestData is
			  begin
		  		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 860,
	 			pKey1 => 'getTestData' ) ;
				commit ;
		       -- send all the test data and do NOT filter on the last_update_dt
		       OPEN rspTsl FOR
				 	SELECT DISTINCT spo_prime_part_no, 
						   Amd_Defaults.INSERT_ACTION action_code , 
						   SYSDATE, 
						   mob,
						   nsn,
						   nsi_sid,
						   0 override_quantity   
					FROM 
						 (
					 	 SELECT  distinct spo_prime_part_no , mob || '_RSP' mob, 0 quantity
						 from (SELECT  DISTINCT spo_prime_part_no
						 	   FROM AMD_SENT_TO_A2A 
							   where part_no = spo_prime_part_no 
							   and action_code <> amd_defaults.getDelete_ACTION) primes,
						 AMD_SPARE_NETWORKS net
						 where mob is not null
						 AND not exists (
								 SELECT null 
								 FROM TMP_A2A_LOC_PART_OVERRIDE
								 WHERE part_no = spo_prime_part_no
								 AND site_location = mob || '_RSP') 
					 )  tsl,
					 AMD_NATIONAL_STOCK_ITEMS items 
					 where spo_prime_part_no = items.prime_part_no
					 and items.LAST_UPDATE_DT >= (select max(last_update_dt)
						 from amd_national_stock_items where prime_part_no = spo_prime_part_no)				 
					 and spo_prime_part_no in (select part_no from amd_test_parts)
					 AND items.action_code <> amd_defaults.getDelete_ACTION
					 and items.LAST_UPDATE_DT >= (select max(last_update_dt)
						 from amd_national_stock_items where prime_part_no = spo_prime_part_no) ;
			  end getTestData ;

			  procedure getAllData is
			  begin
		  		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 870,
	 			pKey1 => 'getAllData' ) ;
				commit ;
		       OPEN rspTsl FOR
				 	SELECT DISTINCT spo_prime_part_no, 
						   tsl.action_code , 
						   SYSDATE, 
						   mob,
						   nsn,
						   nsi_sid,
						   0 override_quantity   
					FROM 
						 (
					 	 SELECT  distinct spo_prime_part_no , mob || '_RSP' mob, 0 quantity, primes.action_code
						 from (SELECT  DISTINCT spo_prime_part_no, action_code
						       FROM AMD_SENT_TO_A2A
							   where part_no = spo_prime_part_no) primes,
						      AMD_SPARE_NETWORKS net
						 where mob is not null
						 AND not exists (
								 SELECT null 
								 FROM TMP_A2A_LOC_PART_OVERRIDE
								 WHERE part_no = spo_prime_part_no
								 AND site_location = mob || '_RSP') 
					 )  tsl,
					 AMD_NATIONAL_STOCK_ITEMS items 
				     where spo_prime_part_no = items.prime_part_no
					 and items.LAST_UPDATE_DT >= (select max(last_update_dt)
					 	 from amd_national_stock_items where prime_part_no = spo_prime_part_no)					 
					 and items.LAST_UPDATE_DT >= (select max(last_update_dt)
					 	 					  from amd_national_stock_items where prime_part_no = spo_prime_part_no) ;					 
			  end getAllData ;

			  procedure getDataByLastUpdateDt is
			  begin
		  		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 880,
	 			pKey1 => 'getDataByLastUpdateDt' ) ;
				commit ;
		   	   -- send all data whose last_update_dt >= amd_batch_pkg.getLastStartTime - ie all the 
			   -- data that has been processed by the diff for the lastest batch job  
		       	OPEN rspTsl FOR
				 	SELECT DISTINCT spo_prime_part_no, 
						   tsl.action_code action_code , 
						   SYSDATE, 
						   mob,
						   items.nsn,
						   nsi_sid,
						   0 override_quantity   
					FROM 
						 (
						 	 SELECT  distinct spo_prime_part_no , mob || '_RSP' mob, 0 quantity, primes.last_update_dt last_update_dt, primes.action_code action_code
							 from (SELECT  DISTINCT spo_prime_part_no, transaction_date last_update_dt, action_code
							       FROM AMD_SENT_TO_A2A 
								   where part_no = spo_prime_part_no 
								   and action_code <> amd_defaults.getDELETE_ACTION) primes,
							 AMD_SPARE_NETWORKS net
							 where mob is not null
							 AND not exists (
									 SELECT null 
									 FROM TMP_A2A_LOC_PART_OVERRIDE
									 WHERE part_no = spo_prime_part_no
									 AND site_location = mob || '_RSP') 
					 	 )  tsl,
					 	 AMD_NATIONAL_STOCK_ITEMS items,
						 amd_spare_parts parts 
						 where spo_prime_part_no = items.prime_part_no
						 and items.LAST_UPDATE_DT >= (select max(last_update_dt)
					 	 	 					  from amd_national_stock_items where prime_part_no = spo_prime_part_no)
					 	 and spo_prime_part_no = parts.part_no
						 and items.action_code <> amd_defaults.getDELETE_ACTION
						 and parts.action_code <> amd_defaults.getDELETE_ACTION					
					 	 and (trunc(tsl.last_update_dt) >= trunc(amd_batch_pkg.getLastStartTime)
						 	 or trunc(items.last_update_dt) >= trunc(amd_batch_pkg.getLastStartTime)
							 or trunc(parts.last_update_dt) >= trunc(amd_batch_pkg.getLastStartTime)) ;
			  end getDataByLastUpdateDt ;
			  			  			  
	BEGIN
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 890,
		 		pKey1 => 'loadRspZeroTslA2A',
				pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
				pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
	   if useTestData then
	   	  getTestData ;
	   else
	   	   if doAllA2A then
		   	  getAllData ;
		   else
		   	   getDataByLastUpdateDt ;
			END IF ;
		end if ;
		
		processTsl(tsl => rspTsl, pDoAllA2A => doAllA2A) ;
		CLOSE rspTsl;
		
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(pSqlfunction => 'loadRspZeroTslA2A',pTableName => 'tmp_amd_location_part_override',
				   pError_location => 900 ) ;
		RAISE ;
	END loadRspZeroTslA2A;
					 		
	
	PROCEDURE loadZeroTslA2A4DelSpoPrimParts(doAllA2A IN BOOLEAN := FALSE, useTestData IN BOOLEAN := FALSE) IS
			  tsl tslCur ;
			  
			  procedure getTestData is
			  begin
		  		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 910,
	 			pKey1 => 'getTestData' ) ;
				commit ;
				 OPEN tsl FOR
				 	SELECT DISTINCT sent.spo_prime_part_no,
					 	sent.action_code action_code,
						sent.transaction_date, 
						net.SPO_LOCATION spo_location, 
						i.nsn,
						i.nsi_sid,
						0 override_AtlantaWarehouseQty
					FROM AMD_LOCATION_PART_OVERRIDE o, AMD_SPARE_NETWORKS net, AMD_SENT_TO_A2A sent, AMD_NATIONAL_STOCK_ITEMS i,
					amd_test_parts testParts 
					WHERE o.action_code = Amd_Defaults.DELETE_ACTION
					AND not exists (
							 SELECT null 
							 FROM TMP_A2A_LOC_PART_OVERRIDE
							 WHERE part_no = sent.spo_prime_part_no
							 AND site_location = net.spo_location) 
					AND sent.spo_prime_part_no = testParts.PART_NO
					and sent.spo_prime_part_no = sent.part_no 
					AND o.loc_sid = net.LOC_SID
					AND o.part_no = sent.spo_prime_part_no
					AND o.part_no = i.PRIME_PART_NO ;
			  end getTestData ;
			  
			  procedure getAllData is
			  begin
		  		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 920,
	 			pKey1 => 'getAllData' ) ;
				commit ;
				 OPEN tsl FOR
				 	SELECT DISTINCT sent.spo_prime_part_no,
						sent.action_code action_code,
						sent.transaction_date, 
						net.SPO_LOCATION spo_location, 
						i.nsn,
						i.nsi_sid,
						0 override_AtlantaWarehouseQty
					FROM AMD_LOCATION_PART_OVERRIDE o, AMD_SPARE_NETWORKS net, AMD_SENT_TO_A2A sent, AMD_NATIONAL_STOCK_ITEMS i 
					WHERE o.action_code = Amd_Defaults.DELETE_ACTION
					AND not exists (
							 SELECT null 
							 FROM TMP_A2A_LOC_PART_OVERRIDE
							 WHERE part_no = sent.spo_prime_part_no
							 AND site_location = net.spo_location) 
					AND o.loc_sid = net.LOC_SID
					AND o.part_no = sent.spo_prime_part_no
					AND o.part_no = i.PRIME_PART_NO 
					and sent.spo_prime_part_no = sent.part_no ; 
			  end getAllData ;

			  procedure getDataByTranDtAndBatchTime is
			  begin
		  		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 930,
	 			pKey1 => 'getDataByTranDtAndBatchTime' ) ;
				commit ;
				 OPEN tsl FOR
				 	SELECT DISTINCT sent.spo_prime_part_no, 
						sent.action_code action_code, 
						sent.transaction_date, 
						net.SPO_LOCATION spo_location, 
						i.nsn,
						i.nsi_sid,
						0 override_AtlantaWarehouseQty
					FROM AMD_LOCATION_PART_OVERRIDE o, AMD_SPARE_NETWORKS net, AMD_SENT_TO_A2A sent, AMD_NATIONAL_STOCK_ITEMS i 
					WHERE o.action_code = Amd_Defaults.DELETE_ACTION
					AND not exists (
							 SELECT null 
							 FROM TMP_A2A_LOC_PART_OVERRIDE
							 WHERE part_no = sent.spo_prime_part_no
							 AND site_location = net.spo_location) 
					AND o.loc_sid = net.LOC_SID
					AND o.part_no = sent.spo_prime_part_no
					AND o.part_no = i.PRIME_PART_NO
					and sent.spo_prime_part_no = sent.part_no 
					AND TRUNC(sent.TRANSACTION_DATE) >= TRUNC(Amd_Batch_Pkg.getLastStartTime) ;
			  end getDataByTranDtAndBatchTime ;
			  			  
	BEGIN
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 940,
		 		pKey1 => 'loadZeroTslA2A4DelSpoPrimParts',
				pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
				pKey3 => 'useTestData=' ||  Amd_Utils.boolean2Varchar2(useTestData),
				pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
				
		 
	 	IF useTestData THEN
		 	getTestData ;
		elsif doAllA2A THEN
		 	getAllData ;
		else
		   	getDataByTranDtAndBatchTime ;
		END IF ;
		
		processTsl(tsl, doAllA2A) ;
		CLOSE tsl ;
	
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 950,
		 		pKey1 => 'loadZeroTslA2A4DelSpoPrimParts',
				pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
				pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	    COMMIT ;
	
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(pSqlfunction => 'loadZeroTslA2A4DelSpoPrimParts',pTableName => 'tmp_amd_location_part_override',
				   pError_location => 960 ) ;
		RAISE ;
	END loadZeroTslA2A4DelSpoPrimParts ;
	
	PROCEDURE loadTslA2AWarehouseParts(doAllA2A IN BOOLEAN := FALSE, from_dt IN DATE := A2a_Pkg.start_dt, to_dt IN DATE := SYSDATE, useTestData IN BOOLEAN := FALSE) IS
			  tsl tslCur ;
			  
			  procedure getTestData is
			  begin
		  		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 970,
	 			pKey1 => 'getTestData' ) ;
				commit ;
		 	OPEN tsl FOR
				SELECT 
					spo_prime_part_no,
					spoPrimes.action_code,
					spoPrimes.transaction_date,
					spo_location,
					items.nsn,
					items.nsi_sid,
					override_quantity
				FROM (
					SELECT sent.spo_prime_part_no,
						THE_WAREHOUSE spo_location,
						SUM(NVL(i.SPO_TOTAL_INVENTORY,0)) override_quantity,
						sent.action_code action_code,
						SYSDATE transaction_date
					FROM AMD_SENT_TO_A2A sent, AMD_SPARE_PARTS p, AMD_NATIONAL_STOCK_ITEMS i
					WHERE
					sent.ACTION_CODE <> Amd_Defaults.DELETE_ACTION
					AND not exists (
							 SELECT null 
							 FROM TMP_A2A_LOC_PART_OVERRIDE
							 WHERE part_no = sent.spo_prime_part_no
							 AND site_location = THE_WAREHOUSE) 
					AND spo_prime_part_no IN (SELECT part_no FROM AMD_TEST_PARTS)
					AND p.ACTION_CODE <> Amd_Defaults.DELETE_ACTION
					AND sent.part_no = p.part_no
					and sent.spo_prime_part_no = sent.part_no 
					AND p.nsn = i.NSN
					GROUP BY sent.spo_prime_part_no
					) spoPrimes, 
					AMD_NATIONAL_STOCK_ITEMS items
				WHERE spo_prime_part_no = items.PRIME_PART_NO
				and items.LAST_UPDATE_DT >= (select max(last_update_dt)
					 from amd_national_stock_items where prime_part_no = spo_prime_part_no)	;
			  end getTestData ;
			  
			  procedure getAllValidSpoData is
			  begin
		  		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 980,
	 			pKey1 => 'getAllValidSpoData' ) ;
				commit ;
				OPEN tsl FOR
				SELECT 
					spo_prime_part_no,
					spoPrimes.action_code,
					spoPrimes.transaction_date,
					spo_location,
					items.nsn,
					items.nsi_sid,
					override_quantity
				FROM (
					SELECT sent.spo_prime_part_no,
						THE_WAREHOUSE spo_location,
						SUM(NVL(i.SPO_TOTAL_INVENTORY,0)) override_quantity,
						sent.action_code action_code,
						SYSDATE transaction_date
					FROM AMD_SENT_TO_A2A sent, AMD_SPARE_PARTS p, AMD_NATIONAL_STOCK_ITEMS i
					WHERE
					sent.ACTION_CODE <> Amd_Defaults.DELETE_ACTION -- spo data is valid if  sent.action_code <> delete_action
					AND not exists (
							 SELECT null 
							 FROM TMP_A2A_LOC_PART_OVERRIDE
							 WHERE part_no = sent.spo_prime_part_no
							 AND site_location = THE_WAREHOUSE) 
					AND p.ACTION_CODE <> Amd_Defaults.DELETE_ACTION
					AND sent.part_no = p.part_no
					and sent.spo_prime_part_no = sent.part_no 
					AND p.nsn = i.NSN
					GROUP BY sent.spo_prime_part_no
					) spoPrimes, 
					AMD_NATIONAL_STOCK_ITEMS items
				WHERE spo_prime_part_no = items.PRIME_PART_NO 
				and items.LAST_UPDATE_DT >= (select max(last_update_dt)
					 from amd_national_stock_items where prime_part_no = spo_prime_part_no)	;
			  end getAllValidSpoData ;
			  		  
	BEGIN
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 990,
		 		pKey1 => 'loadTslA2AWarehouseParts',
				pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
				pKey3 => 'useTestData=' || Amd_Utils.boolean2Varchar2(useTestData),
				pKey4 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	
		IF useTestData THEN
		   getTestData ;
		 ELSE
		   getAllValidSpoData ;
		 END IF ;
		  
		 processTsl(tsl, doAllA2A) ;
		 CLOSE tsl ;
	
		writeMsg(pTableName => 'tmp_a2a_loc_part_override', pError_location => 1000,
		 		pKey1 => 'loadTslA2AWarehouseParts',
				pKey2 => 'doAllA2A=' || Amd_Utils.boolean2Varchar2(doAllA2A),
				pKey3 =>  'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	EXCEPTION WHEN OTHERS THEN
		ErrorMsg(pSqlfunction => 'loadTslA2AWarehouseParts',pTableName => 'tmp_amd_location_part_override',
				   pError_location => 1010 ) ;
		RAISE ;
	END loadTslA2AWarehouseParts ;
	
	FUNCTION isInTmpA2AYorN(part_no IN TMP_A2A_LOC_PART_OVERRIDE.part_no%TYPE, site_location IN TMP_A2A_LOC_PART_OVERRIDE.SITE_LOCATION%TYPE) RETURN VARCHAR2 IS
	BEGIN
		 IF isInTmpA2A(part_no, site_location) THEN
		 	RETURN 'Y' ;
		 ELSE
		 	RETURN 'N' ;
		 END IF ; 
	END isInTmpA2AYorN ;
	
	FUNCTION isInTmpA2A(part_no IN TMP_A2A_LOC_PART_OVERRIDE.part_no%TYPE, site_location IN TMP_A2A_LOC_PART_OVERRIDE.SITE_LOCATION%TYPE) RETURN BOOLEAN IS
			 thePartNo TMP_A2A_LOC_PART_OVERRIDE.part_no%TYPE ;
			 rc NUMBER ;
	BEGIN
		 SELECT part_no INTO thePartNo
		 FROM TMP_A2A_LOC_PART_OVERRIDE
		 WHERE part_no = isInTmpA2A.part_no
		 AND site_location = isInTmpA2A.site_location ;
		 RETURN TRUE ;
	EXCEPTION
			 WHEN standard.NO_DATA_FOUND THEN
			 	  RETURN FALSE ;
			 WHEN OTHERS THEN
					ErrorMsg(
					   pSqlfunction 	  	  => 'isInTmpA2A',
				   pTableName  	  	  => 'tmp_a2a_loc_part_override',
				   pError_location => 1020,
				   pKey1			  => part_no,
	   			   pKey2			  => site_location) ;
				   RAISE ;
	END isInTmpA2A ;
	-- added 11/7/05 dse
	FUNCTION getInsertCnt RETURN NUMBER IS 
	BEGIN
		 RETURN insertCnt ;
	END getInsertCnt ;
	
	FUNCTION getUpdateCnt RETURN NUMBER IS
	BEGIN
		 RETURN updateCnt ;
	END getUpdateCnt ;
	
	FUNCTION getDeleteCnt RETURN NUMBER IS
	BEGIN
		 RETURN deleteCnt ;
	END getDeleteCnt ;
	
	FUNCTION getOVERRIDE_TYPE RETURN VARCHAR2 IS
	BEGIN
		 RETURN OVERRIDE_TYPE ;
	END getOVERRIDE_TYPE ;
	
	FUNCTION getOVERRIDE_REASON RETURN VARCHAR2 IS
	BEGIN
		 RETURN OVERRIDE_REASON ;
	END getOVERRIDE_REASON ;
	
	FUNCTION getBULKLIMIT RETURN NUMBER IS
	BEGIN
		 RETURN BULKLIMIT ;
	END getBULKLIMIT ;
	
	FUNCTION getCOMMITAFTER RETURN NUMBER IS
	BEGIN
		 RETURN COMMITAFTER ;
	END getCOMMITAFTER ;
	
	FUNCTION getSUCCESS RETURN NUMBER IS
	BEGIN
		 RETURN SUCCESS ;
	END getSUCCESS ;
	
	FUNCTION getFAILURE RETURN NUMBER IS
	BEGIN
		 RETURN FAILURE ;
	END getFAILURE ;
	
	FUNCTION getTHE_WAREHOUSE RETURN VARCHAR2 IS
	BEGIN
		 RETURN THE_WAREHOUSE ;
	END getTHE_WAREHOUSE ;

	procedure version is
	begin
		 writeMsg(pTableName => 'amd_location_part_override_pkg', 
		 		pError_location => 1030, pKey1 => 'amd_location_part_override_pkg', pKey2 => '$Revision:   1.45  $') ;
		 dbms_output.put_line('amd_location_part_override_pkg: $Revision:   1.45  $') ;
	end version ;
	
END Amd_Location_Part_Override_Pkg ;
/

show errors

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.amd_defaults as

	/*

     $Author:   zf297a  $
   $Revision:   1.29  $
       $Date:   Oct 26 2006 12:13:38  $
   $Workfile:   amd_defaults.pkb  $
       $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_defaults.pkb-arc  $
   
      Rev 1.29   Oct 26 2006 12:13:38   zf297a
   Removed writeMsg - since some of the default functions are used in sql queries there cannot be DML that inserts or updates.   Test the STRICT flag to see if an exception should be raised when default values cannot be verified against amd tables.  Added code to initialize the STRICT flag via the amd_param_changes table.
   
      Rev 1.28   Oct 24 2006 14:19:42   zf297a
   Fixed getNsnLogonId and getNslLogonId to validate the logon_id against amd_planner_logons using a select with an exists clause because more than one row could exist for a give logon_id and planner_code since there are multiple data_sources.
   Changed the dbms_output message to a writeMsg so any error messages get logged to amd_load_details.
   Added dbms_output.put_line to version.
   
      Rev 1.27   Jun 09 2006 12:55:38   zf297a
   implemented version
   
      Rev 1.26   Jan 05 2006 12:23:28   zf297a
   Fixed getNslLogonId - was using the NSN_PLANNER_CODE instead of the NSL_PLANNER_CODE
   
      Rev 1.25   Dec 02 2005 10:18:10   zf297a
   Fixed getNsnPlannerCode, getNslPlannerCode, getNsnLogonId, and getNslLogonId so that they always return a default value. NOTE: if the literal is returned, it may not be a valid planner_code or logon_id.  In that case the data may no go to the SPO correctly unless RJBplanner.xml and RichellBodine.xml is sent manully to the SPO!
   
      Rev 1.24   Nov 30 2005 10:57:38   zf297a
   added getBom, getBomQuantity, and used these new functions to get data from the amd_param_changes table, if there is not data found bom defaults to 'C17' and bom_quantity defaults to 1.
   
      Rev 1.23   Nov 01 2005 12:32:52   zf297a
   Added some more "getter" functions for other constants.
   
      Rev 1.22   Nov 01 2005 12:21:34   zf297a
   Simplified the name of the "getter's" to getCONSTANT where CONSTANT is the identifier for the associated constant.
   
      Rev 1.21   Nov 01 2005 11:50:32   zf297a
   Added "getter 's" (get functions) for some of the constant's so they can be used in ordinary SQL instead of only in PL/SQL code.
   
      Rev 1.20   Sep 13 2005 11:04:22   zf297a
   Implemented interfaces for isParamKey and addParamKey.
   
      Rev 1.19   Aug 15 2005 11:43:36   zf297a
   Removed all debugMsg's since they were causing more trouble than they were worth.
   
      Rev 1.18   Aug 09 2005 11:50:20   zf297a
   Removed debugMsg that reports a missing logon_id / planner_code in amd_planner_logons since this caused an error with DataStage's query since it was inserting data into amd_load_details, which is not allowed for only a DataStage query.
   
      Rev 1.17   Aug 05 2005 11:27:02   zf297a
   Removed raise_application errors and made them into debugMsg's.  This is better than having a hard error here, since  execution should continue and the reported condition can be corrected at another time.
   
      Rev 1.16   Jul 27 2005 10:24:38   zf297a
   Streamlined code for default planner_codes and logon_id's
   
      Rev 1.15   Jul 26 2005 15:10:28   zf297a
   added additional edits for the default logon_id's
   
      Rev 1.14   Jul 08 2005 09:36:32   zf297a
   Added PVCS keyword $Log$ and copied the PVCS history log into the header comments. 

		Rev 1.13
		Locked by:      zf297a
		Checked in:     Jul 08 2005 09:08:36
		Last modified:  Jul 08 2005 09:08:36
		Author id: zf297a     lines deleted/added/moved: 2/11/0
		added the public function getLogonId
		-----------------------------------
		Rev 1.12
		Checked in:     Jul 08 2005 08:58:34
		Last modified:  Jul 08 2005 08:58:34
		Author id: zf297a     lines deleted/added/moved: 6/11/0
		Added the public function getPlannerCode
		-----------------------------------
		Rev 1.11
		Checked in:     Jul 05 2005 13:54:12
		Last modified:  Jul 05 2005 13:54:12
		Author id: zf297a     lines deleted/added/moved: 2/6/0
		added $Log$ PVCS keyword
		-----------------------------------
		Rev 1.10
		Checked in:     Jul 05 2005 13:50:52
		Last modified:  Jul 05 2005 13:50:52
		Author id: zf297a     lines deleted/added/moved: 3/56/0
		Added NSN_PLANNER_CODE and NSL_PLANNER_CODE and their corresponding logon_id's: NSN_LOGON_ID and NSL_LOGON_ID.
		-----------------------------------
		Rev 1.9
		Checked in:     Mar 27 2002 12:22:38
		Last modified:  Mar 27 2002 12:22:38
		Author id: c970183     lines deleted/added/moved: 0/6/0
		Added PVCS keywords
		-----------------------------------
		Rev 1.8
		Checked in:     Nov 30 2001 06:28:40
		Last modified:  Nov 02 2001 10:22:08
		Author id: c372701     lines deleted/added/moved: 26/130/0
		gw - 11/29/01 - Updates due to system problems on the Version Manager NT Server. - Done to reflect latest changes - per Doug Elder
		-----------------------------------
		Rev 1.7
		Checked in:     Oct 28 2001 15:08:28
		Last modified:  Oct 28 2001 12:40:22
		Author id: c378632     lines deleted/added/moved: 0/12/0
		unit_cost_factor_offbase
		time_to_repair_offbase
		-----------------------------------
		Rev 1.6
		Checked in:     Oct 28 2001 11:31:26
		Last modified:  Oct 28 2001 11:21:32
		Author id: c378632     lines deleted/added/moved: 0/12/0
		time_to_repair_onbase,
		cost_to_repair_onbase
		-----------------------------------
		Rev 1.5
		Checked in:     Oct 25 2001 09:57:38
		Last modified:  Oct 25 2001 09:57:04
		Author id: c970183     lines deleted/added/moved: 48/178/0
		Made action codes, consumable, and repairable constants.
		-----------------------------------
		Rev 1.4
		Checked in:     Oct 25 2001 09:48:00
		Last modified:  Oct 25 2001 09:48:00
		Author id: c970183     lines deleted/added/moved: 196/48/0
		Added constants repairable and consumable.
		-----------------------------------
		Rev 1.3
		Checked in:     Oct 25 2001 07:14:08
		Last modified:  Oct 25 2001 07:13:40
		Author id: c970183     lines deleted/added/moved: 2/20/0
		Added routines to initialize the Action Codes from the amd_param_changes table
		-----------------------------------
		Rev 1.2
		Checked in:     Oct 23 2001 14:33:58
		Last modified:  Oct 23 2001 14:28:42
		Author id: c970183     lines deleted/added/moved: 45/175/0
		Made implementation updates
		-----------------------------------
		Rev 1.1
		Checked in:     Oct 18 2001 07:00:10
		Last modified:  Oct 18 2001 06:59:22
		Author id: c970183     lines deleted/added/moved: 172/51/0
		Changed to use new amd_param_changes table
		-----------------------------------
		Rev 1.0
		Checked in:     Oct 11 2001 08:19:52
		Last modified:  Oct 11 2001 07:33:40
		Author id: c372701     lines deleted
		
	  The order_lead_time_........ variables will be initialized by the
	  package body's 'begin' block.  This will happen the first time
	  the package is referenced.
	  */
	order_lead_time_consumable 			amd_spare_parts.order_lead_time_defaulted%type := null ;
	order_lead_time_repairable 			amd_spare_parts.order_lead_time_defaulted%type := null ;
	engine_part_reduction_factor 		number := null ;
	non_engine_part_reductn_factor		number := null ;
	consumable_reduction_factor			number := null ;

	
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
				pSourceName => 'amd_defaults',	
				pTableName  => pTableName,
				pError_location => pError_location,
				pKey1 => pKey1,
				pKey2 => pKey2,
				pKey3 => pKey3,
				pKey4 => pKey4,
				pData    => pData,
				pComments => pComments);
	end writeMsg ;
	
	procedure debugMsg(
					sqlFunction IN VARCHAR2,
					tableName IN VARCHAR2,
					rptLocation IN NUMBER,
					key1 IN VARCHAR2 := '',
			 		key2 IN VARCHAR2 := '',
					key3 IN VARCHAR2 := '',
					key4 IN VARCHAR2 := '',
					key5 in varchar2 := '',					
					keywordValuePairs IN VARCHAR2 := '')  IS
	BEGIN
		Amd_Utils.InsertErrorMsg (
				pLoad_no => Amd_Utils.GetLoadNo(
						pSourceName => sqlFunction,
						pTableName  => tableName),
				pData_line_no => rptLocation,
				pData_line    => 'amd_defaults',
				pKey_1 => key1,
				pKey_2 => key2,
				pKey_3 => key3,
				pKey_4 => key4,
				pKey_5 => key5 || ' ' || to_char(SYSDATE,'MM/DD/YY HH:MM:SS') ||
						   ' ' || keywordValuePairs,
				pComments => 'sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')');
		COMMIT;
		RETURN ;
	END debugMsg;

	-- put a wrapper around debugMsg so it will only write one message to amd_load_details
	procedure displayOnce(
					sqlFunction IN VARCHAR2,
					tableName IN VARCHAR2,
					rptLocation IN NUMBER,
					key1 IN VARCHAR2 := '',
			 		key2 IN VARCHAR2 := '',
					key3 IN VARCHAR2 := '',
					key4 IN VARCHAR2 := '',
					key5 in varchar2 := '',					
					keywordValuePairs IN VARCHAR2 := '')  IS
					
		-- rptLocation must be unique for a given package for this to work
		cursor loadDetails is
			 select load_no
			 from amd_load_details
			 where amd_load_details.DATA_LINE = 'amd_defaults'
			 and amd_load_details.DATA_LINE_NO = rptLocation ;
			 
		recExists boolean := false ;
		
	begin
		 for rec in loadDetails loop
		 	 recExists := true ;
		 	 exit ;
		 end loop ;
		 
		 if not recExists then
			 debugMsg(sqlFunction => sqlFunction,
						tableName => tableName,
						rptLocation => rptLocation,
						key1 => key1,
				 		key2 => key2,
						key3 => key3,
						key4 => key4,
						key5 => key5,					
						keywordValuePairs => keywordValuePairs) ;
		end if ;
		
	end displayOnce ;
	function isParamKey(key in varchar2) return boolean is
			 theKey amd_params.PARAM_KEY%type ;
	begin
		 select param_key into theKey from amd_params where param_key = key ;
		 return true ;
	exception when standard.no_data_found then
		 return false ;
	end isParamKey ;
	
	procedure addParamKey(key in varchar2, description in varchar2) is
	begin
		 insert into amd_params
		 	   (param_key, param_description)
		 values(key, description) ;
	end addParamKey ; 

	procedure setParamValue(key in varchar2, value in varchar2) is
	begin
		 insert into amd_param_changes
		 (param_key, param_value, effective_date, user_id)
		 values (key, value, sysdate, user) ;
	end setParamValue ;
	
	function GetParamValue(key in varchar2) return amd_param_changes.param_value%type is
		value amd_param_changes.param_value%type := null ;
	begin
		select  param_value into value
		from amd_param_changes
		where param_key = key
		and effective_date = (
					select max(effective_date)
					from amd_param_changes
					where param_key = key) ;
		return value ;
	exception when NO_DATA_FOUND then
		return null ;
	end GetParamValue ;

	function GetOrderLeadTime(pItem_type in amd_national_stock_items.item_type%type) return  amd_spare_parts.order_lead_time_defaulted%type is

		function IsConsumable return boolean is
		begin
			return (upper(pItem_type) =  amd_defaults.CONSUMABLE) ;
		end IsConsumable ;

		function IsRepairable return boolean is
		begin
			return (upper(pItem_type) = amd_defaults.REPAIRABLE) ;
		end IsRepairable ;


	begin
			if IsConsumable then
				return order_lead_time_consumable ;
			elsif IsRepairable then
				return order_lead_time_repairable ;
			else
				return null ;
			end if;
	end GetOrderLeadTime ;

	function GetSmrCode(pNsn in varchar2,
		pPart_no in varchar2,
		pMfgr in varchar2,
		pPlanner_code in varchar2) return	varchar2 is
	begin
		return null ; /* todo The field in the
						amd_national_stock_items may not be used
						so this function can be left as is until
						further notice.
						*/
	end GetSmrCode ;

	function GetUnitCost(
		pNsn in amd_spare_parts.nsn%type,
		pPart_no in amd_spare_parts.part_no%type,
		pMfgr in amd_spare_parts.mfgr%type,
		pSmr_code in amd_national_stock_items.smr_code%type,
		pPlanner_code in amd_national_stock_items.planner_code%type) return amd_spare_parts.unit_cost_defaulted%type is

		gfp_price fedc.gfp_price%type := null ;
		unit_cost_defaulted amd_spare_parts.unit_cost_defaulted%type := null ;

		function GetGfpPriceFromFedc(pPart_number in fedc.part_number%type, pVendor_code in fedc.vendor_code%type) return fedc.gfp_price%type is
			min_gfp_price fedc.gfp_price%type := null ;
			max_gfp_price fedc.gfp_price%type := null ;
		begin
			begin
				select min(gfp_price), max(gfp_price)
				into min_gfp_price, max_gfp_price
				from fedc
				where part_number = pPart_number
				and vendor_code = pVendor_code ;
			exception when NO_DATA_FOUND then
				null ;
			end GetViaPartNumberVendorCode ;
			/*
			  If it didn't match on part_number/cage try part_number/nsn
			*/
			if min_gfp_price is null and max_gfp_price is null then
				begin
					select min(gfp_price), max(gfp_price)
					into min_gfp_price, max_gfp_price
					from fedc
					where
						part_number = pPart_number
						and nsn     = amd_utils.FormatNSN(pNsn,'Dash') ;
				exception when NO_DATA_FOUND then
					return null ;
				end GetViaPartNumberNsn ;
			end if ;
			if min_gfp_price != max_gfp_price then
				return null ;
			else
				return min_gfp_price ;
			end if ;
		end GetGfpPriceFromFedc ;

		function IsEnginePart(pPlanner_code in amd_national_stock_items.planner_code%type) return boolean is
		begin
			return (pPlanner_code = 'PSA' or pPlanner_code = 'PSB') ;
		end IsEnginePart ;

		/*
			A quasi-repairable item would be like a frayed rope,
			it can be fixed temporarily but the rope is eventually
			consumed - so in this context the item more closely
			resembles a consumable item.
		*/
		function IsQuasiRepariable(pSmr_code in amd_national_stock_items.smr_code%type) return boolean is
		begin
			if length(pSmr_code) >= 6 then
				return upper(substr(pSmr_code,6,1)) = 'P' ;
			else
				return false ;
			end if ;
		end  IsQuasiRepariable ;

		function IsConsumable(pSmr_code in amd_national_stock_items.smr_code%type) return boolean is
		begin
			if length(pSmr_code) >= 6 then
				return upper(substr(pSmr_code,6,1)) = 'N' ;
			else
				return false ;
			end if ;
		end IsConsumable ;

	begin -- GetUnitCost
		gfp_price := GetGfpPriceFromFedc(pPart_number => pPart_no, pVendor_code => pMfgr) ;

		if gfp_price is not null then
			if IsQuasiRepariable(pSmr_code) or IsConsumable(pSmr_code) then
				unit_cost_defaulted := gfp_price * consumable_reduction_factor ;
			else
				if IsEnginePart(pPlanner_code) then
					unit_cost_defaulted := gfp_price * engine_part_reduction_factor ;
				else
					unit_cost_defaulted := gfp_price * non_engine_part_reductn_factor ;
				end if ;
			end if ;
		end if ;
		return unit_cost_defaulted ; /* defaults to null if there
										isn't a fedc gfp_price.
										*/
	end GetUnitCost ;

	function GetOffBaseRepairCost(
		pUnitCost in number) return number is
	begin
		-- todo
		-- off base repair cost is currently 10% of unit cost.  put the .10 in params table
		return null;
	end GetOffBaseRepairCost;
	
	function getPlannerCode(nsn in varchar2) return varchar2 is
	begin
		 if upper(substr(nsn,1,3)) = 'NSL' then
		 	return nsl_planner_code ;
		 else
		 	return nsn_planner_code ;
		 end if ;
	end getPlannerCode ;
	
	function getLogonId(nsn in varchar2) return varchar2 is
	begin
		 if upper(substr(nsn,1,3)) = 'NSL' then
		 	return nsl_logon_id ;
		 else
		 	return nsn_logon_id ;
		 end if ;
	end getLogonId ;
	
	-- define getter routines for constants so they can be used outside of pl/sql in ordinary sql
	-- dse 11/01/05 
	function getDELETE_ACTION return varchar2 is
	begin
		 return DELETE_ACTION ;
	end getDELETE_ACTION ;
	
	function getINSERT_ACTION return varchar2 is
	begin
		 return INSERT_ACTION ;
	end getINSERT_ACTION ;
	
	function getUPDATE_ACTION return varchar2 is
	begin
		 return UPDATE_ACTION ;
	end getUPDATE_ACTION ;
	
	function getCONSUMABLE return varchar2 is
	begin
		 return CONSUMABLE ;
	end getCONSUMABLE ;
	
	function getREPAIRABLE return varchar2 is
	begin
		 return REPAIRABLE ;
	end getREPAIRABLE ;

	function getAMD_WAREHOUSE_LOCID return varchar2 is
	begin
		 return AMD_WAREHOUSE_LOCID ;
	end getAMD_WAREHOUSE_LOCID ;
	
	function getBSSM_WAREHOUSE_SRAN return varchar2 is
	begin
		 return BSSM_WAREHOUSE_SRAN ;
	end getBSSM_WAREHOUSE_SRAN ;	
	
	function getAMD_UK_LOC_ID return varchar2 is
	begin
		 return AMD_UK_LOC_ID ;
	end getAMD_UK_LOC_ID ;
	
	function getAMD_BASC_LOC_ID return varchar2 is
	begin
		 return AMD_BASC_LOC_ID ;
	end getAMD_BASC_LOC_ID ;
	
	function getAMD_VUB_LOC_ID return varchar2 is
	begin
		 return AMD_VUB_LOC_ID ;
	end getAMD_VUB_LOC_ID ;

	procedure version is
	begin
		 writeMsg(pTableName => 'amd_defaults', 
		 		pError_location => 10, pKey1 => 'amd_defaults', pKey2 => '$Revision:   1.29  $') ;
		 dbms_output.put_line('amd_defaults: $Revision:   1.29  $') ;
	end version ;
	
/*
 The following begin block is executed the first time this package is
 referenced.  It initialializes all the default variables from a table.
 The package will stay in memory until the application using it is finished.
 */
begin
	declare
		function getStrict return boolean is
	  	 		 param AMD_PARAM_CHANGES.PARAM_VALUE%TYPE ;
		begin
			 param := getParamValue('strictDefaults') ;
			 return (param = '1' or upper(param) = 'Y') ;
		end getStrict ;
		
		function GetCondemnAvg return amd_national_stock_items.condemn_avg%type is
		begin
			return to_number(GetParamValue('condemn_avg')) ;
		end GetCondemnAvg ;

		function GetConsumableReductionFactor return consumable_reduction_factor%type is
		begin
			return to_number(GetParamValue('consumable_reduction_factor')) ;
		end GetConsumableReductionFactor ;

		function GetDisposalCost return amd_spare_parts.disposal_cost%type is
		begin
			return to_number(GetParamValue('disposal_cost')) ;
		end GetDisposalCost ;

		function GetDistribUom return amd_national_stock_items.distrib_uom%type is
		begin
			return GetParamValue('distrib_uom') ;
		end GetDistribUom ;

		function GetEnginePartReductionFactor return engine_part_reduction_factor%type is
		begin
			return to_number(GetParamValue('engine_part_reduction_factor')) ;
		end GetEnginePartReductionFactor ;

		function GetNonEnginePartReductnFactor return engine_part_reduction_factor%type is
		begin
			return to_number(GetParamValue('non_engine_part_reductn_factor')) ;
		end GetNonEnginePartReductnFactor ;

		function GetNrtsAvg return amd_national_stock_items.nrts_avg%type is
		begin
			return GetParamValue('nrts_avg') ;
		end GetNrtsAvg ;

		function GetOffBaseTurnAround return amd_part_locs.time_to_repair%type is
		begin
			return GetParamValue('off_base_turn_around') ;
		end GetOffBaseTurnAround ;

		function GetOrderLeadTimeConsumable return amd_spare_parts.order_lead_time_defaulted%type is
		begin
			return to_number(GetParamValue('order_lead_time_consumable')) ;
		end GetOrderLeadTimeConsumable ;

		function GetOrderLeadTimeRepairable return amd_spare_parts.order_lead_time_defaulted%type is
		begin
			return to_number(GetParamValue('order_lead_time_repairable')) ;
		end GetOrderLeadTimeRepairable ;

		function GetOrderQuantity return amd_national_stock_items.order_quantity%type is
		begin
			return to_number(GetParamValue('order_quantity')) ;
		end GetOrderQuantity;

		function GetOrderUom return amd_spare_parts.order_uom%type is
		begin
			return GetParamValue('order_uom') ;
		end GetOrderUom ;

		function GetQpeiWeighted return amd_national_stock_items.qpei_weighted%type is
		begin
			return to_number(GetParamValue('qpei_weighted')) ;
		end GetQpeiWeighted ;

		function GetRtsAvg return amd_national_stock_items.rts_avg%type is
		begin
			return to_number(GetParamValue('rts_avg')) ;
		end GetRtsAvg ;

		function GetScrapValue return amd_spare_parts.scrap_value%type is
		begin
			return to_number(GetParamValue('scrap_value')) ;
		end GetScrapValue ;

		function GetShelfLife return  amd_spare_parts.shelf_life%type is
		begin
			return to_number(GetParamValue('shelf_life')) ;
		end GetShelfLife ;

		function GetTimeToRepairOnBaseAvg return amd_national_stock_items.time_to_repair_on_base_avg_df%type is
		begin
			return to_number(GetParamValue('time_to_repair_on_base_avg')) ;
		end GetTimeToRepairOnBaseAvg ;

		function GetUnitVolume return	amd_spare_parts.unit_volume%type is
		begin
			return to_number(GetParamValue('unit_volume')) ;
		end GetUnitVolume ;

		function GetUseBssmToGetNsls return varchar2 is
		begin
			return GetParamValue('use_bssm_to_get_nsls') ;
		end GetUseBssmToGetNsls ;

		function GetCostToRepairOnbase return varchar2 is
		begin
			 return GetParamValue('cost_to_repair_onbase');
		end GetCostToRepairOnbase;

		function GetTimeToRepairOnbase return varchar2 is
		begin
			 return GetParamValue('time_to_repair_onbase');
		end GetTimeToRepairOnbase;

		function GetUnitCostFactorOffbase return varchar2 is
		begin
			 return GetParamValue('unit_cost_factor_offbase');
		end GetUnitCostFactorOffbase;

		function GetTimeToRepairOffbase return varchar2 is
		begin
			 return GetParamValue('time_to_repair_offbase');
		end GetTimeToRepairOffbase;
		
		function getNsnPlannerCode return amd_planners.PLANNER_CODE%type is
				 wk_planner_code amd_planners.planner_code%type := null ;
				 planner_code amd_planners.planner_code%type := null ;
		begin
			 wk_planner_code := trim(GetParamValue('nsn_planner_code')) ;
			 
			 if wk_planner_code is null then
			 	wk_planner_code := 'RJB' ; -- this may not be in amd_planners, but this is the current default
			 end if ;
			 
		     <<validatePlannerCode>>
		     begin
				 select planner_code into getNsnPlannerCode.planner_code
				 from amd_planners
				 where planner_code =  wk_planner_code ;
			 exception when standard.no_data_found then
	  		 	 dbms_output.put_line('amd_defaults 10: Default NSN Planner_code ' || wk_planner_code || ' is not in amd_planners.') ;
				 if STRICT then
				 	raise_application_error(-20000, 'amd_defaults: Default NSN Planner_code ' || wk_planner_code || ' is not in amd_planners.') ;
				 end if ;
			 end validatePlannerCode ;
			 
			 return wk_planner_code ;
			 
		end getNsnPlannerCode ;
		
		function getNslPlannerCode return amd_planners.PLANNER_CODE%type is
				 wk_planner_code amd_planners.PLANNER_CODE%type := null ;
				 planner_code amd_planners.PLANNER_CODE%type := null ;
	    begin
			 wk_planner_code := trim(GetParamValue('nsl_planner_code')) ;
			 if wk_planner_code is null then
			 	wk_planner_code := 'NSD' ;
			 end if ;
			 <<validatePlannerCode>>
			 begin
				 select planner_code into getNslPlannerCode.planner_code
				 from amd_planners
				 where planner_code =  wk_planner_code ;
			 exception when no_data_found then
		  	   dbms_output.put_line('amd_defaults 20: Default NSL Planner_code ' || wk_planner_code || ' is not in amd_planners.') ;
			   if STRICT then
				 	raise_application_error(-20001, 'amd_defaults: Default NSL Planner_code ' || wk_planner_code || ' is not in amd_planners.') ;
				end if ;
			 end validatePlannerCode ;
			 
			 return wk_planner_code ;
			 
		end getNslPlannerCode ;

		function getNsnLogonId return amd_planner_logons.LOGON_ID%type is
				 logon_id amd_planner_logons.logon_id%type ;
				 wk_logon_id amd_planner_logons.logon_id%type ;
				 result number ;
		begin
			 wk_logon_id := trim(GetParamValue('nsn_logon_id')) ;
			 
			 if wk_logon_id is null then
			 	wk_logon_id := '0334080' ; -- this user may not exist in amd_users, but this is the current default 
			 end if ;
			 
		    <<validateLogonId>>
		 	begin
				select 1 into result
				from dual where exists (
				 	select null
					from amd_planner_logons
				 	where logon_id = wk_logon_id
				 	and planner_code = NSL_PLANNER_CODE
				 	and action_code <> DELETE_ACTION ) ;
			exception when standard.NO_DATA_FOUND then
				dbms_output.put_line('amd_defaults 30: Default NSN Logon_id, ' || wk_logon_id || ' does not exist in amd_planner_logons for planner ' || NSN_PLANNER_CODE) ;
				if STRICT then
				   raise_application_error(-20002,'amd_defaults: Default NSN Logon_id, ' || wk_logon_id || ' does not exist in amd_planner_logons for planner ' || NSN_PLANNER_CODE) ;
				end if ;
			end validateLogonId ;
			 
			 return wk_logon_id ;
			 
		end getNsnLogonId ;

		function getNslLogonId return amd_planner_logons.LOGON_ID%type is
				 logon_id amd_planner_logons.logon_id%type ;
				 wk_logon_id amd_planner_logons.logon_id%type ;
				 result number ;
		begin
			 wk_logon_id := trim(GetParamValue('nsl_logon_id')) ;
			 if wk_logon_id is null then
			 	wk_logon_id := '0235143' ;
			 end if ;
			 
		    <<validateLogonId>>
		 	begin
				select 1 into result
				from dual where exists (
				 	select null
					from amd_planner_logons
				 	where logon_id = wk_logon_id
				 	and planner_code = NSL_PLANNER_CODE
				 	and action_code <> DELETE_ACTION ) ;
			exception when standard.NO_DATA_FOUND then
				dbms_output.put_line('amd_defaults 40: Default NSL Logon_id, ' || wk_logon_id || ' does not exist in amd_planner_logons for planner ' || NSL_PLANNER_CODE) ;
				if STRICT then
				   raise_application_error(-20003,'amd_defaults: Default NSL Logon_id, ' || wk_logon_id || ' does not exist in amd_planner_logons for planner ' || NSL_PLANNER_CODE) ;
				end if ;
			end validateLogonId ;
			
			return wk_logon_id ;
			
		end getNslLogonId ;
		
		function getBom return tmp_a2a_bom_detail.bom%type is
				 bom tmp_a2a_bom_detail.bom%type ;
		begin
			 bom := trim(getParamValue('bom')) ;
			 if bom is null then
			 	return 'C17' ;
			 else
			 	return bom ;
			 end if ;
		end getBom ;
		
		function getBomQuantity return tmp_a2a_bom_detail.quantity%type is
				 quantity tmp_a2a_bom_detail.quantity%type ;
		begin
			 quantity := trim(GetParamValue('bom_quantity'));
			 if quantity is null then
			 	return 1 ;
			 else
			 	 return quantity ;
			 end if ;
		end getBomQuantity ;

	begin
		amd_defaults.CONDEMN_AVG := GetCondemnAvg() ;
		amd_defaults.consumable_reduction_factor := GetConsumableReductionFactor() ;
		amd_defaults.DISPOSAL_COST := GetDisposalCost() ;
		amd_defaults.DISTRIB_UOM := GetDistribUom() ;
		amd_defaults.engine_part_reduction_factor := GetEnginePartReductionFactor() ;
		amd_defaults.non_engine_part_reductn_factor := GetNonEnginePartReductnFactor() ;
		amd_defaults.NRTS_AVG := GetNrtsAvg() ;
		amd_defaults.OFF_BASE_TURN_AROUND := GetOffBaseTurnAround() ;
		amd_defaults.ORDER_QUANTITY := GetOrderQuantity() ;
		amd_defaults.ORDER_UOM := GetOrderUom() ;
		amd_defaults.QPEI_WEIGHTED :=	GetQpeiWeighted() ;
		amd_defaults.RTS_AVG := GetRtsAvg() ;
		amd_defaults.SCRAP_VALUE := GetScrapValue() ;
		amd_defaults.SHELF_LIFE := GetShelfLife() ;
		amd_defaults.order_lead_time_consumable := GetOrderLeadTimeConsumable() ;
		amd_defaults.order_lead_time_repairable := GetOrderLeadTimeRepairable() ;
		amd_defaults.TIME_TO_REPAIR_ON_BASE_AVG := GetTimeToRepairOnBaseAvg() ;
		amd_defaults.UNIT_VOLUME := GetUnitVolume() ;
		amd_defaults.USE_BSSM_TO_GET_NSLs := GetUseBssmToGetNsls() ;
		amd_defaults.TIME_TO_REPAIR_ONBASE := GetTimeToRepairOnbase();
		amd_defaults.TIME_TO_REPAIR_OFFBASE := GetTimeToRepairOffbase();
		amd_defaults.COST_TO_REPAIR_ONBASE := GetCostToRepairOnbase();
		amd_defaults.UNIT_COST_FACTOR_OFFBASE := GetUnitCostFactorOffbase();
		amd_defaults.NSL_PLANNER_CODE := getNslPlannerCode() ;
		amd_defaults.NSN_PLANNER_CODE := getNsnPlannerCode() ;
		amd_defaults.NSN_LOGON_ID := getNsnLogonId() ; -- assumes NSN_PLANNER_CODe has a valid value
		amd_defaults.NSL_LOGON_ID := getNslLogonId() ; -- assumes NSL_PLANNER_CODE has a valid value
		amd_defaults.BOM := getBom() ;
		amd_defaults.BOM_QUANTITY := getBomQuantity() ;
		amd_defaults.STRICT := getStrict() ; 
	end ;
end amd_defaults ;
/

show errors

CREATE OR REPLACE PACKAGE BODY Amd_Inventory AS

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
		
       $Author:   c402417  $
     $Revision:   1.72  $
         $Date:   Nov 03 2006 12:13:12  $
     $Workfile:   amd_inventory.pkb  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_inventory.pkb-arc  $
   
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
   updated pErrorLocation numbers (10, 20, 30,.........400)
   
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

	ON_ORDER_DATE CONSTANT AMD_PARAMS.PARAM_KEY%TYPE := 'on_order_date_' ;
		
	SUBTYPE orderdates IS NUMBER ;
	ORDER_CREATE_DATE CONSTANT orderdates := 1 ;
	SCHEDULED_RECEIPT_DATE_FROM CONSTANT orderdates := 2 ;
	SCHEDULED_RECEIPT_DATE_TO CONSTANT orderdates := 3 ;
	NUMBER_OF_CALANDER_DAYS CONSTANT orderdates := 4 ;
	
	
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
	CURSOR rampCur(pNsn VARCHAR2) IS
		SELECT
			DECODE(n.loc_type,'TMP',asn2.loc_sid,n.loc_sid) loc_sid,
			NVL(r.serviceable_balance,0) serviceable_balance,
			NVL(r.spram_balance,0) spram_balance,
			NVL(r.wrm_balance,0) wrm_balance,
			NVL(r.hpmsk_balance,0) hpmsk_balance,
			NVL(r.total_inaccessible_qty,0) total_inaccessible_qty,
			NVL(r.difm_balance,0) difm_balance,
			NVL(r.unserviceable_balance,0) unserviceable_balance,
			NVL(r.spram_level,0) spram_level,
			NVL(r.wrm_level,0) wrm_level,
			NVL(r.hpmsk_level_qty,0) hpmsk_level_qty,
			NVL(r.suspended_in_stock,0) suspended_in_stock,
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
			--AND asp.nsn = pNsn
			AND n.loc_type IN ('MOB', 'FSL')
			AND n.mob = asn2.loc_id(+);
					
			
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
			
			
		CURSOR rampCurFB(pNsn VARCHAR2) IS
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
			AND n.mob = asn2.loc_id(+);
			
				
	-- Type 1 Wholesale from ITEM and TMP1
	CURSOR itemType1Cur IS
		SELECT
			asp.part_no,
			DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
			invQ.inv_date inv_date,
			'1' inv_type,
			SUM(invQ.inv_qty) inv_qty
		FROM
			(SELECT
				RTRIM(part) part_no,
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
					  RTRIM(part),
					  SUBSTR(i.sc,8,6) ,
					  TRUNC(DECODE(i.created_datetime, NULL, i.last_changed_datetime,i.created_datetime))  
				UNION 
			(SELECT
				RTRIM(part) part_no,
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
				 	  RTRIM(part),
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
	 DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) ,
	 invQ.inv_date;

		-- Type 4 Wholesale
	CURSOR itemMCur IS
		SELECT
			asp.part_no,
			DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
			'4' inv_type,
			RTRIM(i.item_id) item_id,
			DECODE(i.created_datetime,NULL,TRUNC(i.last_changed_datetime),
			      TRUNC(i.created_datetime)) inv_date,
			TRUNC(i.created_datetime) repair_date,
			TRUNC(i.created_datetime + ansi.time_to_repair_off_base) repair_need_date,
			SUM(NVL(i.qty,0)) inv_qty
		FROM
			ITEM i,
			AMD_NATIONAL_STOCK_ITEMS ansi,
			AMD_SPARE_NETWORKS asn,
			AMD_SPARE_PARTS asp,
			AMD_SPARE_NETWORKS asnLink
		WHERE
			asp.part_no = RTRIM(i.part)
			AND RTRIM(i.prime) = RTRIM(ansi.prime_part_no)
			AND i.status_3 != 'I'
			AND i.status_servicable = 'N'
			AND i.status_new_order = 'N'
			AND i.status_accountable = 'Y'
			AND i.status_active = 'Y'
			AND i.status_mai = 'N'
			AND asn.loc_id = SUBSTR(i.sc,8,6)
			AND asp.action_code != 'D'
			AND asn.mob = asnLink.loc_id(+)
		GROUP BY
			asp.part_no,
			DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid),
			RTRIM(i.item_id),
			DECODE(i.created_datetime,NULL,TRUNC(i.last_changed_datetime),
			      TRUNC(i.created_datetime)),
			TRUNC(i.created_datetime),
			TRUNC(i.created_datetime + ansi.time_to_repair_off_base);
	 
		CURSOR itemACur IS
		SELECT
			asp.part_no,
			DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
			'4' inv_type,
			RTRIM(i.item_id) item_id,
			DECODE(i.created_datetime, NULL, TRUNC(i.last_changed_datetime), TRUNC(i.created_datetime)) inv_date,
			TRUNC(i.created_datetime) repair_date,
			TRUNC(i.created_datetime + NVL(ansi.time_to_repair_off_base,0)) repair_need_date,
			SUM(NVL(i.qty,0)) inv_qty
		FROM
			ITEMSA i,
			AMD_NATIONAL_STOCK_ITEMS ansi,
			AMD_SPARE_NETWORKS asn,
			AMD_SPARE_PARTS asp,
			AMD_SPARE_NETWORKS asnLink
		WHERE
			RTRIM(asp.part_no) = RTRIM(i.part)
			AND RTRIM(i.prime) = RTRIM(ansi.prime_part_no)
			AND i.status_3 != 'I'
			AND i.status_servicable = 'N'
			AND i.status_new_order = 'N'
			AND i.status_accountable = 'Y'
			AND i.status_active = 'Y'
			AND i.status_mai = 'N'
			AND asn.loc_id = 'EY1746'
			AND asp.action_code != 'D'
			AND asn.mob = asnLink.loc_id(+)
		GROUP BY
			asp.part_no,
			DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid),
			RTRIM(i.item_id),
			DECODE(i.created_datetime, NULL, TRUNC(i.last_changed_datetime), TRUNC(i.created_datetime)),
			TRUNC(i.created_datetime),
			TRUNC(i.created_datetime + NVL(ansi.time_to_repair_off_base,0));
				
	CURSOR itemType5Cur IS	
	SELECT
		asp.part_no,
		DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
		'3' inv_type,
		o.created_datetime inv_date,
		NVL(o.qty_due,0) inv_qty,
		RTRIM(o.order_no) order_no,
		DECODE(ov.vendor_est_ret_date,NULL, o.ecd, ov.vendor_est_ret_date) repair_need_date
	FROM
		ORD1 o,
		ORDV ov,
		AMD_SPARE_NETWORKS asn,
		AMD_SPARE_PARTS asp,
		AMD_SPARE_NETWORKS asnLink
	WHERE
		RTRIM(o.order_no) = RTRIM(ov.order_no)
		AND asp.part_no  = RTRIM(o.part)
		AND o.status IN ('O', 'U')
		AND o.order_type = 'J'
		AND o.accountable_yn = 'Y'
		AND asn.loc_id = SUBSTR(o.sc,8,6)
		AND asp.action_code != 'D'
		AND asn.mob = asnLink.loc_id(+);
				
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
	
	PROCEDURE infoMsg(
					sqlFunction IN VARCHAR2,
					tableName IN VARCHAR2,
					pErrorLocation IN NUMBER,
					key1 IN VARCHAR2 := '',
			 		key2 IN VARCHAR2 := '',
					key3 IN VARCHAR2 := '',
					key4 IN VARCHAR2 := '',
					key5 IN VARCHAR2 := '',					
					keywordValuePairs IN VARCHAR2 := '')  IS
	BEGIN
		Amd_Utils.InsertErrorMsg (
				pLoad_no => Amd_Utils.GetLoadNo(
						pSourceName => sqlFunction,
						pTableName  => tableName),
				pData_line_no => pErrorLocation,
				pData_line    => 'amd_inventory',
				pKey_1 => key1,
				pKey_2 => key2,
				pKey_3 => key3,
				pKey_4 => key4,
				pKey_5 => key5 || ' ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ||
						   ' ' || keywordValuePairs,
				pComments => 'sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')');
	END infoMsg ;

	PROCEDURE errorMsg(
					sqlFunction IN VARCHAR2,
					tableName IN VARCHAR2,
					pErrorLocation IN NUMBER,
					key1 IN VARCHAR2 := '',
			 		key2 IN VARCHAR2 := '',
					key3 IN VARCHAR2 := '',
					key4 IN VARCHAR2 := '',
					key5 IN VARCHAR2 := '',					
					keywordValuePairs IN VARCHAR2 := '') IS
	BEGIN
		ROLLBACK;
		Amd_Utils.InsertErrorMsg (
				pLoad_no => Amd_Utils.GetLoadNo(
						pSourceName => sqlFunction,
						pTableName  => tableName),
				pData_line_no => pErrorLocation,
				pData_line    => 'amd_inventory',
				pKey_1 => key1,
				pKey_2 => key2,
				pKey_3 => key3,
				pKey_4 => key4,
				pKey_5 => key5 || ' ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ||
						   ' ' || keywordValuePairs,
				pComments => SqlFunction || '/' || TableName || ' sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')');
		COMMIT;
		RETURN ;
	END ErrorMsg;
	
	FUNCTION ErrorMsg(
					pSqlFunction IN VARCHAR2,
					pTableName IN VARCHAR2,
					pErrorLocation IN NUMBER,
					pReturn_code IN NUMBER,
					pKey_1 IN VARCHAR2,
			 		pKey_2 IN VARCHAR2 := '',
					pKey_3 IN VARCHAR2 := '',
					pKey_4 IN VARCHAR2 := '',					
					pKeywordValuePairs IN VARCHAR2 := '') RETURN NUMBER IS
	BEGIN
		ROLLBACK;
		Amd_Utils.InsertErrorMsg (
				pLoad_no => Amd_Utils.GetLoadNo(
						pSourceName => pSqlFunction,
						pTableName  => pTableName),
				pData_line_no => pErrorLocation,
				pData_line    => 'amd_inventory',
				pKey_1 => pKey_1,
				pKey_2 => pKey_2,
				pKey_3 => pKey_3,
				pKey_4 => pKey_4,
				pKey_5 => 'rc=' || TO_CHAR(pReturn_code) ||
					       ' ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ||
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
		cntOnHandInvs NUMBER := 0 ;
		cntInRepair   NUMBER := 0 ;
		cntOnOrder NUMBER := 0 ;
		cntInTransits NUMBER := 0 ;
		cntlnRsp  NUMBER := 0;
		
	
	
	BEGIN

		dbms_output.put_line('loadGoldInventory started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS')) ;

		loadOnHandInvs ;
		SELECT COUNT(*) INTO cntOnHandInvs FROM TMP_AMD_ON_HAND_INVS ;

		loadInRepair ;
		SELECT COUNT(*) INTO cntInRepair FROM TMP_AMD_IN_REPAIR ;

		loadOnOrder ;
		SELECT COUNT(*) INTO cntOnOrder FROM TMP_AMD_ON_ORDER ;
		
		loadInTransits ;
		SELECT COUNT(*) INTO cntInTransits FROM TMP_AMD_IN_TRANSITS ;
		
		loadRsp;
		SELECT COUNT(*) INTO cntlnRsp FROM TMP_AMD_RSP ;			

		dbms_output.put_line('loadGoldInventory ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ) ;
		dbms_output.put_line('cntOnHandInvs=' || cntOnHandInvs) ;
		dbms_output.put_line('cntInRepair=' || cntInRepair) ;
		dbms_output.put_line('cntOnOrder=' || cntOnOrder) ;
		dbms_output.put_line('cntInTransits=' || cntInTransits) ;
		dbms_output.put_line('cntInRsp=' || cntlnRsp) ;
		
		infoMsg(sqlFunction => 'end of proc',
			tableName => 'tmp_amd_spare_parts',
			pErrorLocation => 10, 
			key1 => TO_CHAR(cntOnHandInvs),
			key2 => TO_CHAR(cntInRepair),
			key3 => TO_CHAR(cntOnOrder),
			key4 => TO_CHAR(cntInTransits),
			key5 => TO_CHAR(cntlnRsp)) ;
			
	EXCEPTION
		 WHEN OTHERS THEN 
					ErrorMsg(sqlFunction => 'loadGoldInventory',
						tableName => 'inventory tables',
						pErrorLocation => 20) ; 
					dbms_output.put_line('loadGoldIntentory had an error - check amd_load_details. cntOnHandInvs=' || cntOnHandInvs || ' cntInRepair=' || cntInRepair || ' cntInTransits=' || cntInTransits) ;
				RAISE ;
	END LoadGoldInventory;
	

	PROCEDURE loadOnOrder IS
		-- Type 3 Wholesale
			   		  			
		CURSOR itemType3aCur IS
		SELECT 
	   		   RTRIM(asp.part_no) part_no,
	  		    DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
	   			invQ.inv_date inv_date,
	  			SUM(invQ.inv_qty) inv_qty,
	  			invQ.order_no order_no,
				TRUNC(invQ.receipt_date) receipt_date	  
		FROM (				
			 /*SELECT
				   RTRIM(o.part) part_no,
				   SUBSTR(sc,8,6) loc_id,
				   TRUNC(o.created_datetime) inv_date,
				   NVL(o.qty_due,0) inv_qty,
				   RTRIM(o.order_no) order_no,
				   DECODE(ecd, NULL, need_date, ecd) receipt_date
			FROM
				   ORD1 o
			WHERE
				   o.status = 'O'
				   AND o.order_type = 'M'
			UNION ALL */
			SELECT
				  RTRIM(part) part_no,
				  SUBSTR(sc,8,6) loc_id,
				  TRUNC(o.created_datetime) inv_date,
				  NVL(o.qty_due,0) inv_qty,
				  RTRIM(o.order_no) order_no,
				  DECODE(o.ecd, NULL, o.need_date, o.ecd) receipt_date
			FROM
				  ORD1 o
			WHERE
				   o.status = 'O'
				   AND o.order_type = 'C'
				   AND SUBSTR(o.order_no,1,2) IN ('FC','BA','AM','RS','SE','BR','BN','LB')) invQ,
			    AMD_SPARE_NETWORKS  asn,
				AMD_SPARE_PARTS  asp,
				AMD_SPARE_NETWORKS  asnLink
		WHERE
	 		 RTRIM(asp.part_no) = invQ.part_no
			 AND asn.loc_id = invQ.loc_id
			 AND asp.action_code != 'D'
			 AND asn.mob = asnLink.loc_id(+)
		GROUP BY 
	  	 	RTRIM(asp.part_no),
			DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid),
			invQ.inv_date,
			invQ.order_no,
			TRUNC(invQ.receipt_date);
						   
				   
			CURSOR itemType3bCur IS	   
			SELECT 
				  RTRIM(i.part) part_no,
				  DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
				  TRUNC(i.created_datetime) inv_date,
				  SUM(i.qty) inv_qty,
				  RTRIM(i.receipt_order_no) order_no,
				  DECODE(TRUNC(o.ecd), NULL, SYSDATE, TRUNC(o.ecd))  receipt_date
			FROM
				  ITEM i,
				  ORD1 o,
				  AMD_SPARE_NETWORKS  asn,
				  AMD_SPARE_PARTS  asp,
				  AMD_SPARE_NETWORKS asnLink
			WHERE
				  RTRIM(i.receipt_order_no) = RTRIM(o.order_no)
				  AND i.condition = 'B170-ATL' 
				  AND RTRIM(asp.part_no) = RTRIM(i.part)
			      AND asn.loc_id = SUBSTR(i.sc,8,6) 
			      AND asp.action_code != 'D'
				  AND asn.mob = asnLink.loc_id(+)
		    GROUP BY 
				  RTRIM(i.part),
				  DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid),
				  TRUNC(i.created_datetime),
				  RTRIM(i.receipt_order_no),
				  DECODE(TRUNC(o.ecd), NULL, SYSDATE, TRUNC(o.ecd));
				  
			
			CURSOR itemType3cCur IS
			SELECT
				 RTRIM(from_part) part_no,
				 DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
				 TRUNC(from_datetime) inv_date,
				 SUM(qty_due) inv_qty,
				 RTRIM(temp_out_id) order_no,
				DECODE(est_return_date, NULL, NULL,est_return_date) receipt_date            
			FROM
				 TMP1,
				 AMD_SPARE_NETWORKS  asn,
				 AMD_SPARE_PARTS  asp,
				 AMD_SPARE_NETWORKS asnLink
			WHERE
				  returned_voucher IS NULL
				  AND status = 'O'
				  AND tcn = 'LNI'
	 			  AND  RTRIM(asp.part_no) = RTRIM(from_part)
			 	  AND asn.loc_id = SUBSTR(from_sc,8,6)
			 	  AND asp.action_code != 'D'
				  AND asn.mob = asnLink.loc_id(+)
		GROUP BY 
	  	 	RTRIM(from_part),
			DECODE(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid),
			TRUNC(from_datetime),
			RTRIM(temp_out_id),
			est_return_date; 
			
		cntOnOrdera	  NUMBER := 0 ;
		cntOnOrderb	  NUMBER := 0;
		cntOnOrderc   NUMBER := 0;
		
	BEGIN
		dbms_output.put_line('loadOnOrder started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ) ;
		EXECUTE IMMEDIATE 'truncate table TMP_AMD_ON_ORDER' ;
		EXECUTE IMMEDIATE 'truncate table TMP_A2A_ORDER_INFO_LINE' ;
		EXECUTE IMMEDIATE 'truncate table tmp_a2a_order_info' ;
		
		<<type3aWholeSale>>
		FOR iRec3a IN itemType3aCur LOOP

			IF (iRec3a.inv_date IS NULL) THEN
				Amd_Utils.InsertErrorMsg(pLoad_no => Amd_Utils.GetLoadNo('GOLD/RAMP/ITEM','AMD_SPARE_INVS'),pKey_1 => iRec3a.part_no,pKey_2 => iRec3a.loc_sid,
						pKey_3 => 'GOLD/SPAREINV',
						pKey_4 => 'No inventory date found' );
			ELSE

				IF iRec3a.inv_qty > 0 THEN

				<<Type_3a>>
				BEGIN
					INSERT INTO TMP_AMD_ON_ORDER
					(
						part_no,
						loc_sid,
						order_date,
						order_qty,
						gold_order_number,
						action_code,
						last_update_dt,
						sched_receipt_date
					)
					VALUES
					(
						iRec3a.part_no,
						iRec3a.loc_sid,
						iRec3a.inv_date,
						iRec3a.inv_qty,
						iRec3a.order_no,
						Amd_Defaults.INSERT_ACTION,
						SYSDATE,
						iRec3a.receipt_date
					);
					cntOnOrdera := cntOnOrdera + 1 ;
				EXCEPTION
					WHEN DUP_VAL_ON_INDEX THEN
						DECLARE
							   result NUMBER := 0 ;
						BEGIN
							result := ErrorMsg(pSqlFunction => 'insert',
									pTableName => 'tmp_amd_on_order',
									pErrorLocation => 30, 
									pReturn_code => FAILURE,
									pKey_1 => iRec3a.part_no,
									pKey_2 => iRec3a.loc_sid,
									pKey_3 => iRec3a.inv_date,
									pKey_4 => iRec3a.order_no,
									pKeywordValuePairs => 'inv_qty=' || iRec3a.inv_qty) ;
						END ;
						RAISE ;
				END Type_3a;			
			END IF;
			END IF;
		END LOOP type3aWholeSale; 
	
		<<type3bWholesale>>
		FOR iRec3b IN itemType3bCur LOOP

			IF (iRec3b.inv_date IS NULL) THEN
				Amd_Utils.InsertErrorMsg(pLoad_no => Amd_Utils.GetLoadNo('GOLD/RAMP/ITEM','AMD_SPARE_INVS'),pKey_1 => iRec3b.part_no,pKey_2 => iRec3b.loc_sid,
						pKey_3 => 'GOLD/SPAREINV',
						pKey_4 => 'No inventory date found' );
			ELSE
             
				IF iRec3b.inv_qty > 0 THEN
				<<Type_3b>>
				BEGIN
					INSERT INTO TMP_AMD_ON_ORDER
					(
						part_no,
						loc_sid,
						order_date,
						order_qty,
						gold_order_number,
						action_code,
						last_update_dt,
						sched_receipt_date
					)
					VALUES
					(
						iRec3b.part_no,
						iRec3b.loc_sid,
						iRec3b.inv_date,
						iRec3b.inv_qty,
						iRec3b.order_no,
						Amd_Defaults.INSERT_ACTION,
						SYSDATE,
						iRec3b.receipt_date
					);
					cntOnOrderb := cntOnOrderb + 1 ;
				EXCEPTION
					WHEN DUP_VAL_ON_INDEX THEN
						DECLARE
							   result NUMBER := 0 ;
						BEGIN
							result := ErrorMsg(pSqlFunction => 'insert',
									pTableName => 'tmp_amd_on_order',
									pErrorLocation => 40, 
									pReturn_code => FAILURE,
									pKey_1 => iRec3b.part_no,
									pKey_2 => iRec3b.loc_sid,
									pKey_3 => iRec3b.inv_date,
									pKey_4 => iRec3b.order_no,
									pKeywordValuePairs => 'inv_qty=' || iRec3b.inv_qty) ;
						END ;
						RAISE ;
				END Type_3b;			
				END IF;
			END IF;
		END LOOP type3bWholeSale;
		
		<<type3cWholeSale>>
		FOR iRec3c IN itemType3cCur LOOP

			IF (iRec3c.inv_date IS NULL) THEN
				Amd_Utils.InsertErrorMsg(pLoad_no => Amd_Utils.GetLoadNo('GOLD/RAMP/ITEM','AMD_SPARE_INVS'),pKey_1 => iRec3c.part_no,pKey_2 => iRec3c.loc_sid,
						pKey_3 => 'GOLD/SPAREINV',
						pKey_4 => 'No inventory date found' );
			ELSE

				IF iRec3c.inv_qty > 0 THEN
				<<Type_3c>>
				BEGIN
					INSERT INTO TMP_AMD_ON_ORDER
					(
						part_no,
						loc_sid,
						order_date,
						order_qty,
						gold_order_number,
						action_code,
						last_update_dt,
						sched_receipt_date
					)
					VALUES
					(
						iRec3c.part_no,
						iRec3c.loc_sid,
						iRec3c.inv_date,
						iRec3c.inv_qty,
						iRec3c.order_no,
						Amd_Defaults.INSERT_ACTION,
						SYSDATE,
						iRec3c.receipt_date
					);
					cntOnOrderc := cntOnOrderc + 1 ;
				EXCEPTION
					WHEN DUP_VAL_ON_INDEX THEN
						DECLARE
							   result NUMBER := 0 ;
						BEGIN
							result := ErrorMsg(pSqlFunction => 'insert',
									pTableName => 'tmp_amd_on_order',
									pErrorLocation => 50, 
									pReturn_code => FAILURE,
									pKey_1 => iRec3c.part_no,
									pKey_2 => iRec3c.loc_sid,
									pKey_3 => iRec3c.inv_date,
									pKey_4 => iRec3c.order_no,
									pKeywordValuePairs => 'inv_qty=' || iRec3c.inv_qty) ;
						END ;
						RAISE ;
				END Type_3c;			
				END IF;
			END IF;
		END LOOP type3cWholeSale;  

		dbms_output.put_line('loadOnOrder ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ) ;	
		dbms_output.put_line('cntOnOrdera=' || cntOnOrdera) ;
		
	END loadOnOrder ;
	
	
	
	PROCEDURE loadInTransits IS
	BEGIN
		
		dbms_output.put_line('loadInTransits started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ) ;
		EXECUTE IMMEDIATE 'truncate table TMP_AMD_IN_TRANSITS' ; 
		EXECUTE IMMEDIATE 'truncate table TMP_A2A_IN_TRANSITS' ;
		
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
				   RTRIM(m.part),
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
				  RTRIM(i.part),
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
		
		<<insertInTransits3>>
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
				  RTRIM(i.part),
				  SUBSTR(i.sc,8,6),
				  r.created_docdate,
				  i.status_servicable
			FROM
				ITEM i, RSV1 r, AMD_SPARE_NETWORKS a
				WHERE i.status_3 = 'I'
				AND i.condition != 'B170-ATL'
				AND i.status_servicable = 'N'
				AND i.status_new_order = 'N'
				AND i.status_accountable = 'Y'
				AND i.status_active = 'Y'
				AND i.status_mai = 'N'
				AND r.status = 'O'
				AND i.item_id = r.item_id
				AND SUBSTR(r.to_sc,8,6) = a.loc_id
				AND i.qty IS NOT NULL;
				EXCEPTION 
						  WHEN standard.DUP_VAL_ON_INDEX THEN 
						   NULL;	 -- Ignore duplicate record.		
			COMMIT;
		END insertInTransits3;

		dbms_output.put_line('loadInTransits ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ) ;
	END loadInTransits ;
	
	
	PROCEDURE loadRsp IS
			  nsnDashed					VARCHAR2(16) := NULL;
			  RspQty  						 NUMBER := 0;
			  RspLevel					   NUMBER := 0;
			  cntRsp						  NUMBER := 0;
			  cntType1						  NUMBER := 0;
			  cntType2						  NUMBER := 0;
			  result						  NUMBER := 0;
			  
	
	BEGIN
		
		dbms_output.put_line('loadRsp started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ) ;
		EXECUTE IMMEDIATE 'truncate table TMP_AMD_RSP' ; 
		Amd_Batch_Pkg.truncateIfOld('tmp_a2a_loc_part_override') ;
		COMMIT;
		
		
		
		-- Populate data into table tmp_amd_rsp
		   FOR rec IN partCur LOOP
		   
		   	   	   nsnDashed := Amd_Utils.FormatNsn(rec.nsn, 'GOLD');
				   
				   --
				   -- For each part, extract inventory data from ramp and item tables.
				   --
				   FOR rRec IN rampCur (nsnDashed) LOOP
				   	   		RspQty := rRec.spram_balance + rRec.hpmsk_balance + rRec.wrm_balance + rRec.total_inaccessible_qty;
				 	   		RspLevel := rRec.spram_level+ rRec.wrm_level + rRec.hpmsk_level_qty ;
				 
				 IF RspQty > 0 THEN
				 <<insertRsp>>
				 			  BEGIN 
							  		INSERT INTO TMP_AMD_RSP
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
									 	  rec.part_no,
										  rRec.loc_sid,
										  RspQty,
										  RspLevel,
										  Amd_Defaults.INSERT_ACTION,
										  SYSDATE
									);
									cntType1 := cntType1 + 1;
									cntRsp := cntRsp + 1;
							EXCEPTION
									 	   WHEN	DUP_VAL_ON_INDEX THEN
										   result := ErrorMsg(pSqlFunction => 'insert',
										   		  	 						pTableName => 'tmp_amd_rsp',
																			pErrorLocation => 60,
																			pReturn_code => FAILURE,
																			pKey_1 => rec.part_no,
																			pKey_2 => rRec.loc_sid,
																			pKey_3 => nsnDashed);
											RAISE;
									END TYPE_1;
						END IF ;
					END LOOP;
			END LOOP f77PartLoop;
			
	FOR rec IN partCur LOOP
		
				nsnDashed := Amd_Utils.FormatNsn(rec.nsn, 'GOLD');
				<<rspUABRampLoop>>
				FOR uRec IN rampCurFB(nsnDashed) LOOP
				
							RspQty := uRec.spram_balance + uRec.hpmsk_balance + uRec.wrm_balance + uRec.total_inaccessible_qty ;
				 	   		RspLevel := uRec.spram_level+ uRec.wrm_level + uRec.hpmsk_level_qty ;
							
							IF RspQty > 0 OR RspLevel > 0 THEN
							   BEGIN
							   		  	INSERT INTO TMP_AMD_RSP
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
									 	 		 	  rec.part_no,
													  uRec.loc_sid,
										  			  RspQty,
										 			  RspLevel,
										  			   Amd_Defaults.INSERT_ACTION,
										 			    SYSDATE
									);
									cntType2 := cntType2 + 1;
									cntRsp := cntRsp + 1;
							EXCEPTION
									 	   WHEN	DUP_VAL_ON_INDEX THEN
										   result := ErrorMsg(pSqlFunction => 'insert',
										   		  	 						pTableName => 'tmp_amd_rsp',
																			pErrorLocation => 70,
																			pReturn_code => FAILURE,
																			pKey_1 => rec.part_no,
																			pKey_2 => uRec.loc_sid,
																			pKey_3 => nsnDashed);
											RAISE;
								END Type_2;
							END IF;
						END LOOP rspUABRampLoop;
				END LOOP f77PartLoop; 
			
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
		pErrorLocation => 80 , 
		pReturn_code => FAILURE,
		pKey_1 => 'loc_sid') ;
		RAISE ;
	END getSiteLocation ;
	
	
	FUNCTION doRepairInvsSumDiff(
			 part_no IN VARCHAR2, 
			 site_location IN VARCHAR2,
			 qty_on_hand IN NUMBER, 
			 action_code IN VARCHAR2) RETURN NUMBER IS

		badActionCode EXCEPTION ;
		
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
										pErrorLocation => 90, 
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
							RETURN ErrorMsg(pSqlFunction => 'insert',
										pTableName => 'amd_repair_invs_sum',
										pErrorLocation => 100, 
										pReturn_code => FAILURE,
										pKey_1 => part_no,
										pKey_2 => site_location ) ;
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
							RETURN ErrorMsg(pSqlFunction => 'update',
										pTableName => 'amd_repair_invs_sum',
										pErrorLocation => 110, 
										pReturn_code => FAILURE,
										pKey_1 => part_no,
										pKey_2 => site_location) ;
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
						RETURN ErrorMsg(pSqlFunction => 'update',
									pTableName => 'amd_repair_invs_sum',
									pErrorLocation => 120, 
									pReturn_code => FAILURE,
									pKey_1 => part_no,
									pKey_2 => site_location) ;
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
		
	
	/* amd_in_repair diff functions */
	FUNCTION InsertRow(
							PART_NO             IN VARCHAR2,
  							LOC_SID             IN NUMBER,
							REPAIR_DATE		  IN DATE,
  							REPAIR_QTY          IN NUMBER,
  							ORDER_NO		  IN VARCHAR2,
							REPAIR_NEED_DATE  IN DATE) RETURN NUMBER IS
			
	BEGIN
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
								 pErrorLocation => 130, 
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
					 			repair_need_date = insertRow.repair_need_date,
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
				repair_need_date,
				Amd_Defaults.INSERT_ACTION,
				SYSDATE
			);
			
			EXCEPTION
					WHEN standard.DUP_VAL_ON_INDEX THEN
						 doUpdate ;
					WHEN OTHERS THEN
						RETURN ErrorMsg(pSqlFunction => 'insert',
									pTableName => 'amd_in_repair',
									pErrorLocation => 140, 
									pReturn_code => FAILURE,
									pKey_1 => part_no,
									pKey_2 => loc_sid,
									pKey_3 => order_no);
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
	BEGIN
		<<updateAmdInRepair>>  
		BEGIN
			UPDATE AMD_IN_REPAIR SET
					repair_date		=	UpdateRow.repair_date,
					repair_qty 		= 	UpdateRow.repair_qty,
					repair_need_date =  UpdateRow.repair_need_date,
					action_code    = Amd_Defaults.UPDATE_ACTION,
					last_update_dt = SYSDATE
			WHERE part_no = part_no
			AND loc_sid = UpdateRow.loc_sid
			AND order_no = UpdateRow.order_no;

			EXCEPTION
					WHEN OTHERS THEN
						RETURN ErrorMsg(pSqlFunction => 'update',
									pTableName => 'amd_in_repair',
									pErrorLocation => 150, 
									pReturn_code => FAILURE,
									pKey_1 => part_no,
									pKey_2 => loc_sid,
									pKey_3 => order_no);
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
						RETURN ErrorMsg(pSqlFunction => 'update',
									pTableName => 'amd_in_repair',
									pErrorLocation => 160, 
									pReturn_code => FAILURE,
									pKey_1 => part_no,
									pKey_2 => loc_sid,
									pKey_3 => order_no);
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
						RETURN ErrorMsg(pSqlFunction => 'select',
									pTableName => 'amd_in_repair',
									pErrorLocation => 170, 
									pReturn_code => FAILURE,
									pKey_1 => part_no,
									pKey_2 => loc_sid,
									pKey_3 => order_no);
		 END selectAmdInRepair; 
		 
		 A2a_Pkg.insertRepairInfo(part_no,loc_sid,order_no,repair_date,A2a_Pkg.OPEN_STATUS,repair_qty,
               repair_need_date,Amd_Defaults.DELETE_ACTION) ;		 																							
		RETURN SUCCESS ;
	END inRepairDeleteRow ;


	/* amd_on_order diff functions */
	FUNCTION insertOnOrderRow(
							PART_NO             IN VARCHAR2,
  							LOC_SID             IN NUMBER,
							ORDER_DATE          IN DATE,
  							ORDER_QTY           IN NUMBER,
  							GOLD_ORDER_NUMBER   IN VARCHAR2,
							SCHED_RECEIPT_DATE IN  DATE) RETURN NUMBER IS
	
 		site_location TMP_A2A_ORDER_INFO_LINE.SITE_LOCATION%TYPE := getSiteLocation(loc_sid) ;
		
		PROCEDURE doUpdate IS
		BEGIN
			 <<getActionCode>>
			 DECLARE
				  action_code AMD_ON_ORDER.action_code%TYPE ;
				  badInsert EXCEPTION ;
			 BEGIN
			 	  SELECT action_code INTO action_code FROM AMD_ON_ORDER 
				  WHERE gold_order_number = insertOnOrderRow.gold_order_number
				  AND order_date = insertOnOrderRow.order_date ;
				  
				  IF action_code != Amd_Defaults.DELETE_ACTION THEN
				  	 RAISE badInsert ;
				  END IF ;
			 EXCEPTION
			 		  WHEN OTHERS THEN				
						errorMsg(sqlFunction => 'select',
								 tableName => 'amd_on_order',
								 pErrorLocation => 180,
								 key1 => gold_order_number,
								 key2 => TO_CHAR(order_date,'MM/DD/YYYY')) ;
					  	RAISE ;
			 END getActionCode ;
			 
			 UPDATE AMD_ON_ORDER
				 SET part_no = insertOnOrderRow.part_no,
				 loc_sid = insertOnOrderRow.loc_sid,
				 order_qty = insertOnOrderRow.order_qty,
				 action_code = Amd_Defaults.INSERT_ACTION,
				 last_update_dt = SYSDATE
			 WHERE gold_order_number = insertOnOrderRow.gold_order_number
			 AND order_date = insertOnOrderRow.order_date ;
	    EXCEPTION WHEN OTHERS THEN
				errorMsg(sqlFunction => 'update',
						 tableName => 'amd_on_order',
						 pErrorLocation => 190,
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
				sched_receipt_date
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
				sched_receipt_date
			);
			
			EXCEPTION
					WHEN standard.DUP_VAL_ON_INDEX THEN
						 doUpdate ;
					WHEN OTHERS THEN
						RETURN ErrorMsg(pSqlFunction => 'insert',
									pTableName => 'amd_on_order',
									pErrorLocation => 200, 
									pReturn_code => FAILURE,
									pKey_1 => gold_order_number,
									pKey_2 => TO_CHAR(order_date,'MM/DD/YYYY HH:MM:SS'));
	     END insertAmdOnOrder ;
		 
		 A2a_Pkg.insertTmpA2AOrderInfo(insertOnOrderRow.gold_order_number,
			  insertOnOrderRow.loc_sid,
			  insertOnOrderRow.order_date,
			  insertOnOrderRow.part_no,
	 		  insertOnOrderRow.order_qty,
			  insertOnOrderRow.sched_receipt_date,
			  Amd_Defaults.INSERT_ACTION) ;
		 
		 RETURN SUCCESS ;
	END insertOnOrderRow ;

	FUNCTION updateOnOrderRow(
							PART_NO             IN VARCHAR2,
  							LOC_SID             IN NUMBER,
							ORDER_DATE          IN DATE,
  							ORDER_QTY           IN NUMBER,
  							GOLD_ORDER_NUMBER   IN VARCHAR2,
							SCHED_RECEIPT_DATE IN  DATE) RETURN NUMBER IS
							
	   site_location TMP_A2A_ORDER_INFO_LINE.site_location%TYPE := getSiteLocation(loc_sid) ;
	   
	BEGIN
		<<updateAmdOnOrder>> 
		BEGIN
			UPDATE AMD_ON_ORDER SET
				part_no        		= 	UpdateOnOrderRow.part_no,
				loc_sid    			= 	UpdateOnOrderRow.loc_sid,
	            order_qty 			= 	UpdateOnOrderRow.order_qty,
				action_code         = Amd_Defaults.UPDATE_ACTION,
				last_update_dt      = SYSDATE
			WHERE gold_order_number = UpdateOnOrderRow.gold_order_number
			AND order_date = UpdateOnOrderRow.order_date;
	
			EXCEPTION
					WHEN OTHERS THEN
						RETURN ErrorMsg(pSqlFunction => 'update',
									pTableName => 'amd_on_order',
									pErrorLocation => 210, 
									pReturn_code => FAILURE,
									pKey_1 => UpdateOnOrderRow.gold_order_number,
									pKey_2 => TO_CHAR(UpdateOnOrderRow.order_date,'MM/DD/YYYY HH:MM:SS'));
		END updateAmdOnOrder;
		
		A2a_Pkg.insertTmpA2AOrderInfo(updateOnOrderRow.gold_order_number,
			  updateOnOrderRow.loc_sid,
			  updateOnOrderRow.order_date,
			  updateOnOrderRow.part_no,
	 		  updateOnOrderRow.order_qty,
			  updateOnOrderRow.sched_receipt_date,
			  Amd_Defaults.UPDATE_ACTION) ;

		
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
			AND order_date = DeleteRow.order_date ;
	
			EXCEPTION WHEN OTHERS THEN
						RETURN ErrorMsg(pSqlFunction => 'update',
									pTableName => 'amd_on_order',
									pErrorLocation => 220, 
									pReturn_code => FAILURE,
									pKey_1 => gold_order_number,
									pKey_2 => TO_CHAR(order_date,'MM/DD/YYYY HH:MM:SS'));
		 END updateAmdOnOrder;
		
				
		A2a_Pkg.insertTmpA2AOrderInfo(deleteRow.gold_order_number,
			  deleteRow.loc_sid,
			  deleteRow.order_date,
			  deleteRow.part_no,
			  0,
			  SYSDATE,
			  Amd_Defaults.DELETE_ACTION) ;
		
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
										pErrorLocation => 230, 
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
										pErrorLocation => 240, 
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
										pErrorLocation => 250, 
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
									pErrorLocation => 260, 
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
									pErrorLocation => 270, 
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
									pErrorLocation => 280, 
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
									pErrorLocation => 290, 
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
								pErrorLocation => 300, 
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
																		  pErrorLocation => 310,
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
																				   pErrorLocation => 320,
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
																				pErrorLocation => 330,
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
																										pErrorLocation => 340,
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
																													pErrorLocation => 350,
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
							 AND rsp_location = doRspSumDiff.rsp_location ;
							 
							 IF action_code != Amd_Defaults.DELETE_ACTION THEN
							 	RAISE badInsert ;
							 END IF ;
						EXCEPTION WHEN OTHERS THEN
							errorMsg(SqlFunction => 'select',
										TableName => 'amd_rsp_sum',
										pErrorLocation => 360, 
										key1 => doRspSumDiff.part_no,
										key2 => doRspSumDiff.rsp_location);
										RAISE ;						
						END getActionCode ;
						
						UPDATE AMD_RSP_SUM
						SET qty_on_hand = doRspSumDiff.qty_on_hand,
							rsp_level = doRspSumDiff.rsp_level,
							action_code = Amd_Defaults.INSERT_ACTION,
							last_update_dt = SYSDATE
						WHERE part_no = doRspSumDiff.part_no AND rsp_location = doRspSumDiff.rsp_location ;
						
				   END doUpdate ;
				   
		BEGIN
		
					  <<insertAmdRspSum>>
					   BEGIN
							 INSERT INTO AMD_RSP_SUM
							(
								part_no,
								rsp_location,
								qty_on_hand,
								rsp_level,
								action_code,
								last_update_dt
							)
							VALUES
							(
							    part_no,
								rsp_location,
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
													pErrorLocation => 370, 
													key1 => part_no,
													key2 => rsp_location ) ;
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
				      AND rsp_location  = doRspSumDiff.rsp_location ;
				EXCEPTION
						WHEN OTHERS THEN
							 ErrorMsg(SqlFunction => 'update',
										TableName => 'amd_rsp_sum',
										pErrorLocation => 380, 
									     key1 => part_no,
										key2 => rsp_location) ;
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
				 AND rsp_location  = doRspSumDiff.rsp_location ;
					
			EXCEPTION
					WHEN OTHERS THEN
						   ErrorMsg(SqlFunction => 'update',
									TableName => 'amd_rsp_sum',
									pErrorLocation => 390, 
									key1 => part_no,
									key2 => rsp_location) ;
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
		
		A2a_Pkg.insertInvInfo(part_no, rsp_location,NVL(qty_on_hand,0), action_code) ;
			
		IF Amd_Location_Part_Override_Pkg.insertedTmpA2ALPO(part_no, rsp_location,
					                                     'TSL Fixed', rsp_level, 
														 'Fixed TSL Load',
														  Amd_Location_Part_Override_Pkg.GetFirstLogonIdForPart(Amd_Utils.GetNsiSidFromPartNo(part_no)),
														   SYSDATE,
														  action_code,
														   SYSDATE)  THEN							
						NULL ; -- do nothing
		 END IF ;
		RETURN SUCCESS;
	 EXCEPTION WHEN OTHERS THEN
			   ErrorMsg(SqlFunction => 'doRspSumDiff(' || action_code || ')',
									TableName => 'amd_rsp_sum / tmp_a2a_loc_part_override',
									pErrorLocation => 400) ; 
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
									pErrorLocation => 410, 
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
					pErrorLocation => 420,
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
									 pErrorLocation => 430,
									 pReturn_code => FAILURE,
									 pKey_1 => document_id,
									 pKey_2 => part_no,
									 pKey_3 => TO_CHAR(to_loc_sid));
		END updateAmdInTransit;
				
		
	    RETURN SUCCESS ;
					
		EXCEPTION WHEN OTHERS THEN
			  	   RETURN ErrorMsg(pSqlFunction => 'updateRow',
				   		  pTableName => 'amd_in_transits',
						  pErrorLocation => 440,
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
									pErrorLocation => 450,
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
							pErrorLocation => 460,
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
			    serviceable_flag = InsertRow.serviceable_flag,
			    action_code = Amd_Defaults.INSERT_ACTION,
				last_update_dt = SYSDATE	
			WHERE  part_no = InsertRow.part_no 
			AND site_location = InsertRow.site_location;
			RETURN SUCCESS;
		 EXCEPTION  WHEN OTHERS THEN
		 			result := ErrorMsg(pSqlFunction => 'update',
					                   pTableName => 'amd_in_transits_sum',
									   pErrorLocation => 470,
									   pReturn_code => FAILURE,
									   pKey_1 => part_no,
									   pKey_2 => site_location) ;
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
		   quantity,
		   serviceable_flag,
		   Amd_Defaults.INSERT_ACTION,
		   SYSDATE
		  ) ;
		  EXCEPTION WHEN standard.DUP_VAL_ON_INDEX THEN
		  				 result := doUpdate ;
					WHEN OTHERS THEN
						 result := ErrorMsg(pSqlFunction => 'insert',
						 		   			  pTableName => 'amd_in_transits_sum',
											  pErrorLocation => 480,
											  pReturn_code => FAILURE,
											  pKey_1 => part_no,
											  pKey_2 => site_location,
											  pKey_3 => quantity) ;
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
		  AND site_location = UpdateRow.site_location;
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
			 AND   site_location = DeleteRow.site_location ;
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
	BEGIN
	   dbms_output.put_line('loadOnHandInvs started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS')) ;
	   EXECUTE IMMEDIATE 'truncate table TMP_AMD_ON_HAND_INVS';
	   EXECUTE IMMEDIATE 'truncate table TMP_A2A_INV_INFO' ;
		
		FOR rec IN partCur LOOP

			nsnDashed := Amd_Utils.FormatNsn(rec.nsn,'GOLD');

			--
			-- For each part, extract inventory data from ramp and item tables.
			--
			<<invRampLoop>> 
			FOR rRec IN rampCur(nsnDashed) LOOP

				invQty := rRec.serviceable_balance +  rRec.difm_balance ;

				IF invQty > 0 THEN
				    <<Type_1>>					
					BEGIN
						INSERT INTO TMP_AMD_ON_HAND_INVS
						(
							part_no,
							loc_sid,
							inv_date,
							inv_qty,
							action_code,
							last_update_dt
						)
						VALUES
						(
							rec.part_no,
							rRec.loc_sid,
							rRec.inv_date,
							invQty,
							Amd_Defaults.INSERT_ACTION,
							SYSDATE
						);
						cntType1 := cntType1 + 1 ;
						cntOnhandInvs := cntOnHandInvs + 1 ;
					EXCEPTION
						WHEN DUP_VAL_ON_INDEX THEN
						 result := ErrorMsg(pSqlFunction => 'insert',
									pTableName => 'tmp_amd_on_hand_invs',
									pErrorLocation => 490, 
									pReturn_code => FAILURE,
									pKey_1 => rec.part_no,
									pKey_2 => rRec.loc_sid,
									pKey_3 => rRec.inv_date,
									pKey_4 => nsnDashed);
							RAISE ;
					END Type_1;
				END IF;
			END LOOP invRampLoop ;
		END LOOP f77PartLoop;
		
	
		
		<<type1WholeSale>>
		FOR iRec IN itemType1Cur LOOP

			IF (iRec.inv_date IS NULL) THEN
				Amd_Utils.InsertErrorMsg(pLoad_no => Amd_Utils.GetLoadNo('GOLD/RAMP/ITEM','AMD_SPARE_INVS'),pKey_1 => iRec.part_no,
						pKey_2 => iRec.loc_sid, pKey_3 => 'GOLD/SPAREINV',
						pKey_4 => 'No inventory date found' );
			ELSE

				-- Type 1
				IF iRec.inv_qty > 0 THEN
                    <<insertTmpAmdOnHandInvs>>   
					BEGIN
						INSERT INTO TMP_AMD_ON_HAND_INVS
						(
							part_no,
							loc_sid,
							inv_date,
							inv_qty,
							action_code,
							last_update_dt
						)
						VALUES
						(
							iRec.part_no,
							iRec.loc_sid,
							iRec.inv_date,
							iRec.inv_qty,
							Amd_Defaults.INSERT_ACTION,
							SYSDATE
						);
						cntType1WholeSale := cntType1WholeSale + 1 ;
						cntOnHandInvs := cntOnHandInvs + 1 ;
					EXCEPTION
						WHEN OTHERS THEN
							result := ErrorMsg(pSqlFunction => 'insert',
									pTableName => 'tmp_amd_on_hand_invs',
									pErrorLocation => 500, 
									pReturn_code => FAILURE,
									pKey_1 => iRec.part_no,
									pKey_2 => iRec.loc_sid,
									pKey_3 => iRec.inv_date) ;
							RAISE ;
					END insertTmpAmdOnHandInvs ;

				END IF;
			END IF;

		END LOOP type1WholeSale ;
		
		dbms_output.put_line('loadOnHandInvs ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ) ;
		dbms_output.put_line('cntOnHandInvs=' || cntOnHandInvs) ;
		dbms_output.put_line('cntType1=' || cntType1) ;
		dbms_output.put_line('cntType1WholeSale=' || cntType1WholeSale) ;
		
		infoMsg(sqlFunction => 'loadOnHandInvs',
			tableName => 'tmp_amd_on_hand_invs',
			pErrorLocation => 510, 
			key1 => TO_CHAR(cntOnHandInvs),
			key2 => TO_CHAR(cntType1),
			key3 => TO_CHAR(cntType1WholeSale)) ;
			
	EXCEPTION
		WHEN OTHERS THEN
			 ErrorMsg(sqlFunction => 'select',
				tableName => 'tmp_amd_on_hand_invs',
				pErrorLocation => 520) ; 
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
	BEGIN
		dbms_output.put_line('loadInRepair started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS')) ;
		EXECUTE IMMEDIATE 'truncate table TMP_AMD_IN_REPAIR' ;
		EXECUTE IMMEDIATE 'truncate table TMP_A2A_REPAIR_INFO' ;
		EXECUTE IMMEDIATE 'truncate table tmp_a2a_repair_inv_info' ;
		
		<<f77PartLoop>> 
		FOR rec IN partCur LOOP

			nsnDashed := Amd_Utils.FormatNsn(rec.nsn,'GOLD');

			--
			-- For each part, extract inventory data from ramp and item tables.
			--
			<<invRampLoop>> 
			FOR rRec IN rampCur(nsnDashed) LOOP

				invQty := rRec.unserviceable_balance + rRec.suspended_in_stock;

				IF invQty > 0  THEN
					<<Type_2>>
					BEGIN
						INSERT INTO TMP_AMD_IN_REPAIR
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
							rec.part_no,
							rRec.loc_sid,
							rRec.inv_date,
							invQty,
							'Retail',
							rRec.repair_need_date,
							Amd_Defaults.INSERT_ACTION,
							SYSDATE
						);
						cntType2 := cntType2 + 1 ;
						cntInRepair := cntInRepair + 1 ;
					EXCEPTION
						WHEN DUP_VAL_ON_INDEX THEN
							result := ErrorMsg(pSqlFunction => 'insert',
									pTableName => 'tmp_amd_in_repair',
									pErrorLocation => 530, 
									pReturn_code => FAILURE,
									pKey_1 => rec.part_no,
									pKey_2 => rRec.loc_sid,
									pKey_3 => rRec.inv_date,
									pKey_4 => rRec.repair_need_date) ;
							RAISE ;
								
					END Type_2;
				END IF;

			END LOOP invRampLoop ;

		END LOOP f77PartLoop;
		
		<<type4WholeSale>>
		FOR imRec IN itemMCur LOOP

			IF (imRec.inv_date IS NULL) THEN
				Amd_Utils.InsertErrorMsg(pLoad_no => Amd_Utils.GetLoadNo('GOLD/RAMP/ITEM','AMD_SPARE_INVS'),pKey_1 => imRec.part_no, pKey_2 => imRec.loc_sid,
						pKey_3 => 'GOLD/SPAREINV', pKey_4 => 'No inventory date found' );
			ELSE

				IF imRec.inv_qty > 0 THEN
				
				<<insertTmpAmdInRepair>>
				DECLARE
					   result NUMBER ;
				BEGIN
					--SELECT amd_order_sid_seq.NEXTVAL
					--INTO orderSid
					--FROM dual;

					-- Type 4
					INSERT INTO TMP_AMD_IN_REPAIR
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
						imRec.part_no,
						imRec.loc_sid,
						imRec.inv_date,
						imRec.inv_qty,
						imRec.item_id,
						imRec.repair_need_date,
						Amd_Defaults.INSERT_ACTION,
						SYSDATE
					);
					cntType4WholeSale := cntType4WholeSale + 1 ;
					cntInRepair := cntInRepair + 1 ;
				EXCEPTION WHEN OTHERS THEN
					 result := ErrorMsg(
						pSqlFunction => 'insert' ,
						pTableName => 'tmp_amd_in_repair',
						pErrorLocation => 540,
						pReturn_code => FAILURE,
						pKey_1 => imRec.part_no,
						pKey_2 => TO_CHAR(imRec.loc_sid),
						pKey_3 => TO_CHAR(imRec.inv_date,'DD/MON/YYYY'),
						pKey_4 => imRec.inv_type) ;					
					
					RAISE ;

				END insertTmpAmdInRepair ;
				
				END IF;
			END IF;

		END LOOP type4WholeSale ;

		<<typeBASCWholeSale>>
		FOR iaRec IN itemACur LOOP

			IF (iaRec.repair_date IS NULL) THEN
				Amd_Utils.InsertErrorMsg(pLoad_no => Amd_Utils.GetLoadNo('GOLD/RAMP/ITEM','AMD_SPARE_INVS'),pKey_1 => iaRec.part_no, pKey_2 => iaRec.loc_sid,
						pKey_3 => 'GOLD/SPAREINV', pKey_4 => 'No inventory date found' );
			ELSE

				IF iaRec.inv_qty > 0 THEN
				
				<<insertTmpAmdInRepair>>
				DECLARE
					   result NUMBER ;
				BEGIN
					
					INSERT INTO TMP_AMD_IN_REPAIR
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
						iaRec.part_no,
						iaRec.loc_sid,
						iaRec.repair_date,
						iaRec.inv_qty,
						iaRec.item_id,
						iaRec.repair_need_date,
						Amd_Defaults.INSERT_ACTION,
						SYSDATE
					);
					cntTypeBASCWholeSale := cntTypeBASCWholeSale + 1 ;
					cntInRepair := cntInRepair + 1 ;
				EXCEPTION WHEN OTHERS THEN
					 result := ErrorMsg(
						pSqlFunction => 'insert' ,
						pTableName => 'tmp_amd_in_repair',
						pErrorLocation => 550,
						pReturn_code => FAILURE,
						pKey_1 => iaRec.part_no,
						pKey_2 => TO_CHAR(iaRec.loc_sid),
						pKey_3 => TO_CHAR(iaRec.repair_date,'DD/MON/YYYY'));				
					
					RAISE ;

				END insertTmpAmdInRepair ;
				
				END IF;
			END IF;

		END LOOP typeBASCWholeSale ;
		
		<<itemType5WholeSale>>
		FOR oRec IN itemType5Cur LOOP

			IF (oRec.inv_date IS NULL) THEN
				Amd_Utils.InsertErrorMsg(pLoad_no => Amd_Utils.GetLoadNo('GOLD/RAMP/ITEM','AMD_SPARE_INVS'),pKey_1 => oRec.part_no, pKey_2 => oRec.loc_sid,
						pKey_3 => 'GOLD/SPAREINV', pKey_4 => 'No inventory date found' );
			ELSE

				IF oRec.inv_qty > 0 THEN
				
				<<insertTmpAmdInRepair>>
				DECLARE
					   result NUMBER ;
				BEGIN
					
					INSERT INTO TMP_AMD_IN_REPAIR
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
						oRec.part_no,
						oRec.loc_sid,
						oRec.inv_date,
						oRec.inv_qty,
						oRec.order_no,
						oRec.repair_need_date,
						Amd_Defaults.INSERT_ACTION,
						SYSDATE
					);
					cntType5WholeSale := cntType5WholeSale + 1 ;
					cntInRepair := cntInRepair + 1 ;
				EXCEPTION WHEN OTHERS THEN
					 result := ErrorMsg(
						pSqlFunction => 'insert' ,
						pTableName => 'tmp_amd_in_repair',
						pErrorLocation => 560,
						pReturn_code => FAILURE,
						pKey_1 => oRec.part_no,
						pKey_2 => TO_CHAR(oRec.loc_sid),
						pKey_3 => TO_CHAR(oRec.inv_date,'DD/MON/YYYY'));				
					
					RAISE ;

				END insertTmpAmdInRepair ;
				
				END IF;
			END IF;

		END LOOP itemType5WholeSale ;
		
		dbms_output.put_line('loadInRepair ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MM:SS') ) ;
		dbms_output.put_line('cntInRepair=' || cntInRepair) ;
		dbms_output.put_line('cntType2=' || cntType2) ;
		dbms_output.put_line('cntType4WholeSale=' || cntType4WholeSale) ;
		dbms_output.put_line('cntTypeBASCWholeSale=' || cntTypeBASCWholeSale) ;
		dbms_output.put_line('cntType5WholeSale=' || cntType5WholeSale) ;
		
		infoMsg(sqlFunction => 'loadOnHandPlusInRepair',
			tableName => 'tmp_amd_in_repair',
			pErrorLocation => 570, 
			key1 => TO_CHAR(cntInRepair),
			key2 => TO_CHAR(cntType2),
			key3 => TO_CHAR(cntType4WholeSale),
			key4 => TO_CHAR(cntTypeBASCWholeSale),
			key5 => TO_CHAR(cntType5WholeSale)) ;
			
	EXCEPTION
		WHEN OTHERS THEN
			 ErrorMsg(sqlFunction => 'select',
				tableName => 'tmp_amd_in_repair',
				pErrorLocation => 580) ; 
		RAISE ;
	END loadInRepair ;
	
	
	PROCEDURE updateSpoTotalInventory IS
	
			CURSOR partCur IS
				   SELECT DISTINCT
				   		prime_part_no
				   FROM AMD_NATIONAL_STOCK_ITEMS ansi,
				    	AMD_SPARE_PARTS asp
				   WHERE 
				   		 RTRIM(ansi.nsn) = RTRIM(asp.nsn)
						 AND ansi.action_code != 'D' ;
													   
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
						AND RTRIM(a.part_no) = RTRIM(asp.part_no)
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
		 	 
			 FOR rRec IN totalSpoInvCur LOOP
			-- dbms_output.put_line('part_no=' || rRec.prime_part_no ); --' qty = ' || rRec.quantity) ;
			 	 BEGIN
				 	  UPDATE AMD_NATIONAL_STOCK_ITEMS
					  SET spo_total_inventory = rRec.quantity
					  WHERE nsn  = rRec.nsn
					  AND action_code != 'D' ;				  
				 END;
			 END LOOP totalSpoInvLoop ; 
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
		 		pError_location => 590, pKey1 => 'amd_inventory', pKey2 => '$Revision:   1.72  $') ;
	END version ;
	
			 										 					    
END Amd_Inventory;
/

show errors

CREATE PUBLIC SYNONYM AMD_DEFAULTS FOR AMD_OWNER.AMD_DEFAULTS;


CREATE PUBLIC SYNONYM AMD_LOCATION_PART_OVERRIDE_PKG FOR AMD_OWNER.AMD_LOCATION_PART_OVERRIDE_PKG;


GRANT EXECUTE ON  AMD_OWNER.AMD_LOCATION_PART_OVERRIDE_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON  AMD_OWNER.AMD_LOCATION_PART_OVERRIDE_PKG TO AMD_WRITER_ROLE;

GRANT EXECUTE ON  AMD_OWNER.AMD_DEFAULTS TO AMD_WRITER_ROLE;


