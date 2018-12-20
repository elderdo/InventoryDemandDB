DROP PACKAGE BODY AMD_OWNER.AMD_CLEAN_DATA;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.amd_clean_data as
    /*
	    PVCS Keywords

       $Author:   zf297a  $
     $Revision:   1.6  $
         $Date:   Jun 09 2006 12:42:54  $
     $Workfile:   amd_clean_data.pkb  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_clean_data.pkb-arc  $

      Rev 1.6   Jun 09 2006 12:42:54   zf297a
   implemented version

      Rev 1.6   Aug 23 2005 12:22:38   zf297a
   Implemented interfaces using the nsn and part_no  that is retrieving cleaned data via the amd_load / diff process.  This will allow the routine to attempt to retrieve the cleaned_data via the part_no if it is not found via the nsn.

      Rev 1.5   Aug 03 2005 10:33:58   zf297a
   Fixed CheckCache - checked if nsn is NULL

      Rev 1.4   May 06 2005 08:15:38   c970183
   changed dla_warehouse_stock and dla_warehouse_stock_cleaned to current_backorder and current_backorder_cleaned.  added pvcs keywords
   	  */

/*
 	These routines will make it easy to retrieve cleaned data from BSSM
 	Douglas S. Elder and Chung D. Lu  	10/03/01	Initial implementation

	Douglas S. Elder					11/6/01		The cache will work best
		when the data is sorted by nsn asc, prime_ind desc
 */

 	cleanRec		amd_cleaned_from_bssm_pkg.partFields := null ;

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
				pSourceName => 'amd_clean_data',
				pTableName  => pTableName,
				pError_location => pError_location,
				pKey1 => pKey1,
				pKey2 => pKey2,
				pKey3 => pKey3,
				pKey4 => pKey4,
				pData    => pData,
				pComments => pComments);
	end writeMsg ;

	procedure CheckCache(pNsn in varchar2) is
	begin
		if cleanRec.nsn != pNsn or cleanRec.nsn is null then
			cleanRec := amd_cleaned_from_bssm_pkg.GetValues(pNsn) ;
		end if ;
	exception when NO_DATA_FOUND then
		cleanRec := null ;
	end CheckCache ;

	procedure checkCache(pNsn in varchar2, pPartNo in varchar2) is
	begin
		if (cleanRec.nsn != pNsn and cleanRec.part_no != pPartNo)  or cleanRec.nsn is null then
			cleanRec := amd_cleaned_from_bssm_pkg.GetValuesX(pNsn, pPartNo) ;
		end if ;
	exception when NO_DATA_FOUND then
		cleanRec := null ;
	end CheckCache ;

   	-- ks - base specific clean fields, not in pkg body yet
	function RemovalInd(pNsn in varchar2, pLocSid in number ) return varchar2 is
	begin
		return null ; -- todo
	end ;

	function RepairLevelCode(pNsn in varchar2, pLocSid in number) return varchar2 is
	begin
		return null ; -- todo
	end ;
	--

	function GetAddIncrement(pNsn in varchar2) return amd_national_stock_items.add_increment_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.add_increment ;
	end ;
	function GetAmcBaseStock(pNsn in varchar2) return amd_national_stock_items.amc_base_stock_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.amc_base_stock ;
	end ;
	function GetAmcDaysExperience(pNsn in varchar2) return amd_national_stock_items.amc_days_experience_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.amc_days_experience ;
	end ;
	function GetAmcDemand(pNsn in varchar2) return amd_national_stock_items.amc_demand_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.amc_demand ;
	end ;
	function GetCapabilityRequirement(pNsn in varchar2) return amd_national_stock_items.capability_requirement_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.capability_requirement ;
	end ;
	function GetCondemnAvg(pNsn in varchar2, pPartNo in varchar2) return amd_national_stock_items.condemn_avg_cleaned%type is
	begin
		CheckCache(pNsn, pPartNo) ;
		return	cleanRec.condemn_avg ;
	end ;
	function GetCostToRepairOffBase(pNsn in varchar2, pPartNo in varchar2) return amd_national_stock_items.cost_to_repair_off_base_cleand%type is
	begin
		CheckCache(pNsn, pPartNo) ;
		return	cleanRec.cost_to_repair_off_base ;
	end ;
	function GetCriticality(pNsn in varchar2, pPartNo in varchar2) return amd_national_stock_items.criticality_cleaned%type is
	begin
		CheckCache(pNsn, pPartNo) ;
		return	cleanRec.criticality ;
	end ;
	function GetDlaDemand(pNsn in varchar2) return amd_national_stock_items.dla_demand_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.dla_demand ;
	end ;
	function GetCurrentBackorder(pNsn in varchar2) return amd_national_stock_items.current_backorder_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.current_backorder ;
	end ;
	function GetFedcCost(pNsn in varchar2) return amd_national_stock_items.fedc_cost_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.fedc_cost ;
	end ;
	function GetItemType(pNsn in varchar2) return amd_national_stock_items.item_type_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return cleanRec.item_type ;
	end ;
	function GetMicCodeLowest(pNsn in varchar2) return amd_national_stock_items.mic_code_lowest_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.mic_code_lowest ;
	end ;
	function GetMtbdr(pNsn in varchar2, pPartNo in varchar2) return amd_national_stock_items.mtbdr_cleaned%type is
	begin
		CheckCache(pNsn, pPartNo) ;
		return	cleanRec.mtbdr ;
	end ;
	function GetNomenclature(pNsn in varchar2) return amd_national_stock_items.nomenclature_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.nomenclature ;
	end ;
	function GetNrtsAvg(pNsn in varchar2, pPartNo in varchar2) return amd_national_stock_items.nrts_avg_cleaned%type is
	begin
		CheckCache(pNsn, pPartNo) ;
		return	cleanRec.nrts_avg ;
	end ;
	function GetOrderLeadTime(pNsn in varchar2, pPartNo in varchar2) return amd_national_stock_items.order_lead_time_cleaned%type is
	begin
		CheckCache(pNsn, pPartNo) ;
		return	cleanRec.order_lead_time ;
	end ;
	function GetOrderUom(pNsn in varchar2) return amd_national_stock_items.order_uom_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.order_uom ;
	end ;

	function GetPlannerCode(pNsn in varchar2, pPartNo in varchar2) return amd_national_stock_items.planner_code_cleaned%type is
	begin
		--return	amd_cleaned_from_bssm_pkg.GetValues(pNsn => pNsn, pFieldName => amd_cleaned_from_bssm_pkg.PLANNER_CODE) ;
		CheckCache(pNsn, pPartNo) ;
		return cleanRec.planner_code ; -- todo
	end ;
	function GetPrimeInd(pNsn in varchar2, pPart_no in varchar2, pMfgr in varchar2) return amd_nsi_parts.prime_ind_cleaned%type is
	begin
		-- return	amd_cleaned_from_bssm_pkg.GetValues(pNsn => pNsn, pFieldName => amd_cleaned_from_bssm_pkg.PRIME_IND) ;
		return null ; -- todo
	end ;
	function GetRuInd(pNsn in varchar2) return amd_national_stock_items.ru_ind_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.ru_ind ;
	end ;
	function GetRtsAvg(pNsn in varchar2, pPartNo in varchar2) return amd_national_stock_items.rts_avg_cleaned%type is
	begin
		CheckCache(pNsn, pPartNo) ;
		return	cleanRec.rts_avg ;
	end ;
	function GetSmrCode(pNsn in varchar2, pPartNo in varchar2) return amd_national_stock_items.smr_code_cleaned%type is
	begin
		CheckCache(pNsn, pPartNo) ;
		return	cleanRec.smr_code ;
	end ;
	function GetTimeToRepairOffBase(pNsn in varchar2, pPartNo in varchar2) return amd_national_stock_items.time_to_repair_off_base_cleand%type is
	begin
		CheckCache(pNsn, pPartNo) ;
		return	cleanRec.time_to_repair_off_base ;
	end ;
	function GetTimeToRepairOnBaseAvg(pNsn in varchar2) return amd_national_stock_items.time_to_repair_on_base_avg_cl%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.time_to_repair_on_base_avg ;
	end ;
	function GetUnitCost(pNsn in varchar2, pPartNo in varchar2) return amd_national_stock_items.unit_cost_cleaned%type is
	begin
		CheckCache(pNsn, pPartNo) ;
		return	cleanRec.unit_cost ;
	end ;

	procedure version is
	begin
		 writeMsg(pTableName => 'amd_clean_data',
		 		pError_location => 10, pKey1 => 'amd_clean_data', pKey2 => '$Revision:   1.6  $') ;
	end version ;

end amd_clean_data ;
/


DROP PUBLIC SYNONYM AMD_CLEAN_DATA;

CREATE PUBLIC SYNONYM AMD_CLEAN_DATA FOR AMD_OWNER.AMD_CLEAN_DATA;


GRANT EXECUTE ON AMD_OWNER.AMD_CLEAN_DATA TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_CLEAN_DATA TO AMD_WRITER_ROLE;
