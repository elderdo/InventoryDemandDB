set define off

DROP PACKAGE AMD_OWNER.AMD_DEFAULTS;

CREATE OR REPLACE PACKAGE AMD_OWNER.amd_defaults as
    /*

     $Author:   zf297a  $
   $Revision:   1.29  $
       $Date:   14 Nov 2007 12:08:04  $
   $Workfile:   amd_defaults.pks  $
        $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_defaults.pks-arc  $
   
      Rev 1.29   14 Nov 2007 12:08:04   zf297a
   Added interface for getTIME_TO_REPAIR_OFFBASE
   
      Rev 1.28   24 Oct 2007 17:36:16   zf297a
   Added ROP / ROQ default values and the functions to get them.
   
      Rev 1.27   12 Oct 2007 17:23:22   zf297a
   Added constants: AMD_BASC_LOC_ID, AMD_BASC_SC, AMD_UK_SC, AMD_CAN_LOC_ID, AMD_CAN_SC, AMD_AUS_LOC_ID, AMD_AUS_SC, AMD_WARNER_ROBINS_LOC_ID and related get functions.
   
      Rev 1.26   11 Oct 2007 23:33:36   zf297a
   Added TSL_CONSUMABL_CALENDAR_DAYS and function getTSL_CONSUMABL_CALENDAR_DAYS
   
      Rev 1.25   11 Oct 2007 12:42:40   zf297a
   Added Canada loc_id and added interface getAMD_CAN_LOC_ID
   
      Rev 1.24   28 Jun 2007 12:23:32   zf297a
   Added date_lvl_loaded_modifier and a get function for this number used by the load query for consumable gold.lvls.
   
      Rev 1.23   12 Apr 2007 09:31:16   zf297a
   defined interfaces for PSMS_COMMIT_TRESHOLD, GOLD_COMMIT_TRESHOLD, TEMP_NSNS_COMMIT_THRESHOLD, MAIN_COMMIT_THRESHOLD, and PARTSTUC_COMMIT_THRESHOLD.
   
      Rev 1.22   03 Apr 2007 14:32:38   zf297a
   Define interfaces:
   getNSN_LOGON_ID
   getNSL_LOGON_ID
   getNSN_PLANNER_CODE
   getNSL_PLANNER_CODE
   getCLEAN_DATA_DAY
   checkDefaultPlanners
   checkDefaultLogonIds
   
      Rev 1.21   22 Mar 2007 16:45:58   zf297a
   added constant AMD_AUS_LOC_ID and its get function interface
   
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
    
    -- added 6/28/2007 by dse
    DATE_LVL_LOADED_MODIFIER    number := 210 ;
    function getDATE_LVL_LOADED_MODIFIER return number ;
	
    -- added 4/12/2007 by dse
    PSMS_COMMIT_THRESHOLD       number := 1000 ;
    function getPSMS_COMMIT_THRESHOLD return number ;
    
    -- added 4/12/2007 by dse
    MAIN_COMMIT_THRESHOLD       number := 1000 ;
    function getMAIN_COMMIT_THRESHOLD return number ;
    
    -- added 4/12/2007 by dse
    TEMP_NSNS_COMMIT_THRESHOLD       number := 1000 ;
    function getTEMP_NSNS_COMMIT_THRESHOLD return number ;
    
    -- added 4/12/2007 by dse
    GOLD_COMMIT_THRESHOLD       number := 1000 ;
    function getGOLD_COMMIT_THRESHOLD return number ;
    
    -- added 4/12/2007 by dse
    PARTSTRUC_COMMIT_THRESHOLD number := 1000 ;
    function getPARTSTRUC_COMMIT_THRESHOLD return number ;
    
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
    function getTIME_TO_REPAIR_OFFBASE return amd_part_locs.time_to_repair%type ;
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

	AMD_AUS_LOC_ID 	CONSTANT amd_spare_networks.loc_id%TYPE := 'EY1258' ;
	function getAMD_AUS_LOC_ID return varchar2 ;
    
    AMD_AUS_SC      CONSTANT whse.sc%type := 'C17%CODAUSG' ; -- added 100/11/2007 by dse
    function getAMD_AUS_SC return varchar2 ; -- added 10/11/2007 by dse

	AMD_CAN_LOC_ID 	CONSTANT amd_spare_networks.loc_id%TYPE := 'EY1414' ; -- added 10/11/2007 by dse
	function getAMD_CAN_LOC_ID return varchar2 ; -- added 10/11/2007 by dse
    
    AMD_CAN_SC      CONSTANT whse.sc%type := 'C17%CODCANG' ; -- added 10/11/2007 by dse
    function getAMD_CAN_SC return varchar2 ; -- added 10/11/2007 by dse

	AMD_UK_LOC_ID 	CONSTANT amd_spare_networks.loc_id%TYPE := 'EY8780' ;
	function getAMD_UK_LOC_ID return varchar2 ; 
    
    AMD_UK_SC       CONSTANT whse.sc%type := 'C17%CODUKBG' ; -- added 10/11/2007 by dse
    function getAMD_UK_SC return varchar2 ; -- added 10/11/2007 by dse
    
	AMD_BASC_LOC_ID CONSTANT amd_spare_networks.loc_id%TYPE := 'EY1746' ;
	function getAMD_BASC_LOC_ID return varchar2 ;
    
    AMD_BASC_SC     CONSTANT whse.sc%type := 'C17PCAG' ; -- added 10/11/2007 by dse
    function getAMD_BASC_SC return varchar2 ; -- added 10/11/2007 by dse
    
	AMD_VUB_LOC_ID	CONSTANT amd_spare_networks.loc_id%TYPE := 'FB4490' ;
	function getAMD_VUB_LOC_ID return varchar2 ;
    
    AMD_WARNER_ROBINS_LOC_ID CONSTANT amd_spare_networks.loc_id%type := 'FB2065' ; -- added 10/11/2007 by dse
    function getAMD_WARNER_ROBINS_LOC_ID return varchar2 ; -- added 10/11/2007 by dse
    
	--AMD_VCD_LOC_ID  CONSTANT amd_spare_networks.loc_id%TYPE :=	'?' ;

	NSN_PLANNER_CODE amd_planners.PLANNER_CODE%type := null ;
    function getNSN_PLANNER_CODE return amd_planners.PLANNER_CODE%type ;
	NSN_LOGON_ID amd_planner_logons.LOGON_ID%type := null ;
    function getNSN_LOGON_ID return amd_users.BEMS_ID%type ;
	NSL_PLANNER_CODE amd_planners.PLANNER_CODE%type := null ;
    function getNSL_PLANNER_CODE return amd_planners.PLANNER_CODE%type ;
	NSL_LOGON_ID amd_planner_logons.LOGON_ID%type := null ;
    function getNSL_LOGON_ID return amd_users.BEMS_ID%type ;
    
    CLEAN_DATA_DAY varchar2(10) := null ;
    function getCLEAN_DATA_DAY return varchar2 ;

    TSL_CONSUMABL_CALENDAR_DAYS number := 210 ;
    function getTSL_CONSUMABL_CALENDAR_DAYS return number ;

	function isParamKey(key in varchar2) return boolean ;
	procedure addParamKey(key in varchar2, description in varchar2) ;
	
	-- added 6/09/2006 by dse
	procedure version ;
    procedure checkDefaultPlanners ;
    procedure checkDefaultLogonIds ;
    
    ROP number := -1 ; -- added 10/18/2007 by dse
    function getROP return number ;
    
    ROQ number := 1 ; -- added 10/18/2007
    function getROQ return number ;

end amd_defaults ;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_DEFAULTS;

CREATE PUBLIC SYNONYM AMD_DEFAULTS FOR AMD_OWNER.AMD_DEFAULTS;


GRANT EXECUTE ON AMD_OWNER.AMD_DEFAULTS TO AMD_WRITER_ROLE;


DROP PACKAGE BODY AMD_OWNER.AMD_DEFAULTS;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.amd_defaults as

	/*

     $Author:   zf297a  $
   $Revision:   1.38  $
       $Date:   14 Nov 2007 12:08:22  $
   $Workfile:   amd_defaults.pkb  $
       $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_defaults.pkb-arc  $
   
      Rev 1.38   14 Nov 2007 12:08:22   zf297a
   implemented interface for getTIME_TO_REPAIR_OFFBASE
   
      Rev 1.37   24 Oct 2007 17:36:58   zf297a
   Implemnted ROP / ROQ get functions
   
      Rev 1.36   12 Oct 2007 17:23:58   zf297a
   implemented get functions for new constants.
   
      Rev 1.35   11 Oct 2007 23:35:06   zf297a
   Check for TSL_CONSUMABL_CALENDAR_DAYS in amd_param_changes using name tsl_consumabl_calendar_days, if not found default to 210. 
   Implemented function getTSL_CONSUMABL_CALENDAR_DAYS.
   
      Rev 1.34   11 Oct 2007 12:43:10   zf297a
   implemented interface getAMD_CAN_LOC_ID
   
      Rev 1.33   28 Jun 2007 12:25:16   zf297a
   Implemented getDATE_LVL_LOAED_MODIFIER: this number is used by the load query for consumable gold.lvls.
   
      Rev 1.32   12 Apr 2007 09:31:36   zf297a
   implemented interfaces for PSMS_COMMIT_TRESHOLD, GOLD_COMMIT_TRESHOLD, TEMP_NSNS_COMMIT_THRESHOLD, MAIN_COMMIT_THRESHOLD, and PARTSTUC_COMMIT_THRESHOLD.
   
      Rev 1.31   03 Apr 2007 14:33:30   zf297a
   Implemented the following interfaces:
   getNSN_LOGON_ID
   getNSL_LOGON_ID
   getNSN_PLANNER_CODE
   getNSL_PLANNER_CODE
   getCLEAN_DATA_DAY
   checkDefaultPlanners
   checkDefaultLogonIds
   
      Rev 1.30   22 Mar 2007 16:46:14   zf297a
   Implemented getAMD_AUS_LOC_ID  function
   
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
    
    function getAMD_UK_SC return varchar2 is -- added 10/11/2007 by dse
    begin
        return AMD_UK_SC ;
    end getAMD_UK_SC ;
	
    function getAMD_CAN_SC return varchar2 is -- added 10/11/2007 by dse
    begin
        return AMD_CAN_SC ;
    end getAMD_CAN_SC ;
    
    function getAMD_AUS_SC return varchar2 is  -- added 10/11/2007 by dse
    begin
        return AMD_AUS_SC ;
    end getAMD_AUS_SC ;        
    
	function getAMD_AUS_LOC_ID return varchar2 is
	begin
		 return AMD_AUS_LOC_ID ;
	end getAMD_AUS_LOC_ID ;

	function getAMD_CAN_LOC_ID return varchar2 is -- added 10/11/2007 by dse
    begin
        return AMD_CAN_LOC_ID ;
    end getAMD_CAN_LOC_ID ;        


	function getAMD_BASC_LOC_ID return varchar2 is
	begin
		 return AMD_BASC_LOC_ID ;
	end getAMD_BASC_LOC_ID ;
    
    function getAMD_BASC_SC return varchar2 is -- added 10/11/2007 by dse
    begin
        return AMD_BASC_SC ;
    end getAMD_BASC_SC ;        
	
    function getAMD_WARNER_ROBINS_LOC_ID return varchar2 is -- added 10/11/2007 by dse
    begin
        return AMD_WARNER_ROBINS_LOC_ID ;
    end getAMD_WARNER_ROBINS_LOC_ID ;
    
	function getAMD_VUB_LOC_ID return varchar2 is
	begin
		 return AMD_VUB_LOC_ID ;
	end getAMD_VUB_LOC_ID ;

	procedure version is
	begin
		 writeMsg(pTableName => 'amd_defaults', 
		 		pError_location => 10, pKey1 => 'amd_defaults', pKey2 => '$Revision:   1.38  $') ;
		 dbms_output.put_line('amd_defaults: $Revision:   1.38  $') ;
	end version ;

    procedure checkDefaultPlanners is
        planner_code amd_planners.PLANNER_CODE%type ;
        work number ;
        msg varchar2(2000) ;
        work_msg varchar2(2000) ;
        
        error boolean := false ;
    begin
        begin
            select planner_code into planner_code 
            from amd_planners 
            where planner_code = NSN_PLANNER_CODE 
            and action_code <> amd_defaults.DELETE_ACTION ;
        exception when standard.no_data_found then
            work_msg := 'The default nsn planner code of ' || NSN_PLANNER_CODE || ' does not exist in amd_planners.' ; 
            dbms_output.put_line(work_msg) ;
            msg := work_msg ;
            error := true ;  
        end ;
        
        begin
            select planner_code into planner_code 
            from amd_planners 
            where planner_code = NSL_PLANNER_CODE 
            and action_code <> amd_defaults.DELETE_ACTION ;            
        exception when standard.no_data_found then
            work_msg := 'The default nsl planner code of ' || NSL_PLANNER_CODE || ' does not exist in amd_planners.' ;
            dbms_output.put_line(work_msg) ;
            msg := msg || '.  ' || work_msg ;
            error := true ;  
        end ;
        
        begin
            select 1 into work 
            from dual 
            where exists (select null 
                          from amd_planner_logons 
                          where planner_code = NSN_PLANNER_CODE
                          and action_code <> amd_defaults.DELETE_ACTION) ;
        exception when standard.no_data_found then
            work_msg := 'The default nsn planner code of ' || NSN_PLANNER_CODE || ' does not exist in amd_planner_logons.' ;
            dbms_output.put_line(work_msg) ;
            msg := msg || '.  ' || work_msg ;
            error := true ;  
        end ;

        begin
            select 1 into work 
            from dual 
            where exists (select null 
                          from amd_planner_logons 
                          where planner_code = NSL_PLANNER_CODE
                          and action_code <> amd_defaults.DELETE_ACTION) ;
        exception when standard.no_data_found then
            work_msg := 'The default nsl planner code of ' || NSL_PLANNER_CODE || ' does not exist in amd_planner_logons.' ;
            dbms_output.put_line(work_msg) ;
            msg := msg || '.  ' || work_msg ; 
            error := true ;  
        end ;
        
        if error then
            raise_application_error(-20010,msg) ;
        end if ;
    end checkDefaultPlanners ;
    
    procedure checkDefaultLogonIds is
        bems_id amd_users.bems_id%type ;
        work number ;
        msg varchar2(2000) ;
        work_msg varchar2(2000) ;
        
        error boolean := false ;
    begin
        begin
            select bems_id into bems_id 
            from amd_users 
            where bems_id = NSN_LOGON_ID
            and action_code <> amd_defaults.DELETE_ACTION ;
        exception when standard.no_data_found then
            work_msg := 'The default nsn logon id of ' || NSN_LOGON_ID || ' does not exist in amd_users.' ;
            dbms_output.put_line(work_msg) ;
            msg := work_msg ;
            error := true ;  
        end ;
        
        begin
            select bems_id into bems_id 
            from amd_users 
            where bems_id = NSL_LOGON_ID 
            and action_code <> amd_defaults.DELETE_ACTION ;
        exception when standard.no_data_found then
            work_msg := 'The default nsl logon id of ' || NSL_LOGON_ID || ' does not exist in amd_users.' ;
            dbms_output.put_line(work_msg) ;
            msg := msg || '.  ' || work_msg ;
            error := true ;  
        end ;
        
        begin
            select 1 into work 
            from dual where exists (select null 
                                    from amd_planner_logons 
                                    where logon_id = NSN_LOGON_ID 
                                    and action_code <> amd_defaults.DELETE_ACTION) ;
        exception when standard.no_data_found then
            work_msg := 'The default nsn logon id of ' || NSN_LOGON_ID || ' does not exist in amd_planner_logons.' ;
            dbms_output.put_line(work_msg) ;
            msg := msg || '.  ' || work_msg ;
            error := true ;  
        end ;

        begin
            select 1 into work 
            from dual where exists (select null 
                                    from amd_planner_logons 
                                    where logon_id = NSL_LOGON_ID
                                    and action_code <> amd_defaults.DELETE_ACTION ) ; 
        exception when standard.no_data_found then
            work_msg := 'The default nsl logon id of ' || NSL_LOGON_ID || ' does not exist in amd_planner_logons.' ;
            dbms_output.put_line(work_msg) ;
            msg := msg || '.  ' || work_msg ; 
            error := true ;  
        end ;
        
        if error then
            raise_application_error(-20020,msg) ;
        end if ;
    end checkDefaultLogonIds ;

    function getNSN_PLANNER_CODE return amd_planners.PLANNER_CODE%type is
    begin
        return NSN_PLANNER_CODE ;
    end getNSN_PLANNER_CODE ;

    function getNSN_LOGON_ID return amd_users.BEMS_ID%type is
    begin
        return NSN_LOGON_ID ;
    end getNSN_LOGON_ID ;
    
    function getNSL_PLANNER_CODE return amd_planners.PLANNER_CODE%type is
    begin
        return NSL_PLANNER_CODE ;
    end getNSL_PLANNER_CODE ;
    
    function getNSL_LOGON_ID return amd_users.BEMS_ID%type is
    begin
        return NSL_LOGON_ID ;
    end getNSL_LOGON_ID ;
    
    function getCLEAN_DATA_DAY return varchar2 is
    begin
        return CLEAN_DATA_DAY ;
    end getCLEAN_DATA_DAY ;
    -- added 4/12/2007 by dse
    function getPSMS_COMMIT_THRESHOLD return number is
    begin
        return PSMS_COMMIT_THRESHOLD ;
    end getPSMS_COMMIT_THRESHOLD ;
	
    -- added 4/12/2007 by dse
    function getMAIN_COMMIT_THRESHOLD return number is
    begin
        return MAIN_COMMIT_THRESHOLD ;
    end getMAIN_COMMIT_THRESHOLD ;

    -- added 4/12/2007 by dse
    function getTEMP_NSNS_COMMIT_THRESHOLD return number is
    begin
        return TEMP_NSNS_COMMIT_THRESHOLD ;
    end getTEMP_NSNS_COMMIT_THRESHOLD ;

    -- added 4/12/2007 by dse
    function getGOLD_COMMIT_THRESHOLD return number is
    begin
        return GOLD_COMMIT_THRESHOLD ;
    end getGOLD_COMMIT_THRESHOLD ;

    -- added 4/12/2007 by dse
    function getPARTSTRUC_COMMIT_THRESHOLD return number is
    begin
        return PARTSTRUC_COMMIT_THRESHOLD ;
    end getPARTSTRUC_COMMIT_THRESHOLD ;
    
    -- added 6/28/2007 by dse
    function getDATE_LVL_LOADED_MODIFIER return number is
    begin
        return DATE_LVL_LOADED_MODIFIER ;
    end getDATE_LVL_LOADED_MODIFIER ;
   
    function getTSL_CONSUMABL_CALENDAR_DAYS return number is -- added 10/11/2007 by dse
    begin
        return TSL_CONSUMABL_CALENDAR_DAYS ;
    end getTSL_CONSUMABL_CALENDAR_DAYS ;
    
    function getROP return number is
    begin
        return ROP ;
    end getROP ;
    
    function getROQ return number is
    begin
        return ROQ ;
    end getROQ ;                
    function getTIME_TO_REPAIR_OFFBASE return amd_part_locs.time_to_repair%type is
    begin
        return TIME_TO_REPAIR_OFFBASE ;
    end getTIME_TO_REPAIR_OFFBASE ;
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
				 	and planner_code = NSN_PLANNER_CODE
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
        
        function getCleanDataDay return varchar2 is
            dayOfTheWeek varchar2(10) ;
        begin
            dayOfTheWeek := upper(trim(getParamValue('clean_data_day'))) ;
            if dayOfTheWeek is null then
                return 'SATURDAY' ;
            else
                return dayOfTheWeek ;
            end if ;
        end getCleanDataDay ;

        function getPsmsCommitThreshold return varchar2 is
            threshold number ;
        begin
            threshold := to_number(trim(getParamValue('psms_commit_threshold'))) ;
            if threshold is null then
                return 1000 ;
            else
                return threshold ;
            end if ;
        end getPsmsCommitThreshold ;
        
        function getMainCommitThreshold return varchar2 is
            threshold number ;
        begin
            threshold := to_number(trim(getParamValue('main_commit_threshold'))) ;
            if threshold is null then
                return 1000 ;
            else
                return threshold ;
            end if ;
        end getMainCommitThreshold ;
        
        function getTempNsnsCommitThreshold return varchar2 is
            threshold number ;
        begin
            threshold := to_number(trim(getParamValue('temp_nsns_commit_threshold'))) ;
            if threshold is null then
                return 1000 ;
            else
                return threshold ;
            end if ;
        end getTempNsnsCommitThreshold ;
        
        function getGoldCommitThreshold return varchar2 is
            threshold number ;
        begin
            threshold := to_number(trim(getParamValue('gold_commit_threshold'))) ;
            if threshold is null then
                return 1000 ;
            else
                return threshold ;
            end if ;
        end getGoldCommitThreshold ;
        
             function getPartStrucCommitThreshold return varchar2 is
            threshold number ;
        begin
            threshold := to_number(trim(getParamValue('partstruc_commit_threshold'))) ;
            if threshold is null then
                return 1000 ;
            else
                return threshold ;
            end if ;
        end getPartStrucCommitThreshold ;
        
       function getDateLvlLoadedModifier return varchar2 is
            dateLvlLoadedModifier number ;
        begin
            dateLvlLoadedModifier := to_number(trim(getParamValue('date_lvl_loaded_modifier'))) ;
            if dateLvlLoadedModifier is null then
                return 210 ;
            else
                return dateLvlLoadedModifier ;
            end if ;
        end getDateLvlLoadedModifier ;
        
        function getTslConsumablCalendarDays return number is
            tslConsumablCalendarDays number ;
        begin
            tslConsumablCalendarDays := to_number(trim(getParamValue('tsl_consumabl_calendar_days'))) ;
            if tslConsumablCalendarDays is null then
                return 210 ;
            else
                return tslConsumablCalendarDays ;
            end if ;
        end getTslConsumablCalendarDays ;

        function getTheROQ return number is
            roq number ;
        begin
            roq := to_number(trim(getParamValue('roq'))) ;
            if roq is null then
                return amd_defaults.ROQ ;
            else
                return roq ;
            end if ;
        end getTheROQ ;
        
        function getTheROP return number is
            rop number ;
        begin
            rop := to_number(trim(getParamValue('rop'))) ;
            if rop is null then
                return amd_defaults.ROP ;
            else
                return rop ;
            end if ;
        end getTheROP ;

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
        amd_defaults.CLEAN_DATA_DAY := getCleanDataDay() ;
        amd_defaults.PSMS_COMMIT_THRESHOLD := getPsmsCommitThreshold() ; 
        amd_defaults.MAIN_COMMIT_THRESHOLD := getMainCommitThreshold() ; 
        amd_defaults.TEMP_NSNS_COMMIT_THRESHOLD := getTempNsnsCommitThreshold() ; 
        amd_defaults.GOLD_COMMIT_THRESHOLD := getGoldCommitThreshold() ; 
        amd_defaults.PARTSTRUC_COMMIT_THRESHOLD := getPartStrucCommitThreshold() ;
        amd_defaults.DATE_LVL_LOADED_MODIFIER := getDateLvlLoadedModifier() ;
        amd_defaults.TSL_CONSUMABL_CALENDAR_DAYS := getTslConsumablCalendarDays() ;
        amd_defaults.ROQ := getTheROQ() ;
        amd_defaults.ROP := getTheROP() ; 
	end ;
end amd_defaults ;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_DEFAULTS;

CREATE PUBLIC SYNONYM AMD_DEFAULTS FOR AMD_OWNER.AMD_DEFAULTS;


GRANT EXECUTE ON AMD_OWNER.AMD_DEFAULTS TO AMD_WRITER_ROLE;


