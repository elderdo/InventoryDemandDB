CREATE OR REPLACE package amd_clean_data as

/*
 *	These routines will make it easy to retrieve cleaned data from BSSM
 *	Douglas S. Elder and Chung D. Lu  10/03/01  Initial implementation
 */
   	-- ks - base specific clean fields, not in pkg body yet
	function RemovalInd(pNsn in varchar2, pLocSid in number ) return varchar2;
	function RepairLevelCode(pNsn in varchar2, pLocSid in number) return varchar2;
	--

	function GetAddIncrement(pNsn in varchar2) return amd_national_stock_items.add_increment_cleaned%type ;
	function GetAmcBaseStock(pNsn in varchar2) return amd_national_stock_items.amc_base_stock_cleaned%type ;
	function GetAmcDaysExperience(pNsn in varchar2) return amd_national_stock_items.amc_days_experience_cleaned%type ;
	function GetAmcDemand(pNsn in varchar2) return amd_national_stock_items.amc_demand_cleaned%type ;
	function GetCapabilityRequirement(pNsn in varchar2) return amd_national_stock_items.capability_requirement_cleaned%type ;
	function GetCondemnAvg(pNsn in varchar2) return amd_national_stock_items.condemn_avg_cleaned%type ;
	function GetCostToRepairOffBase(pNsn in varchar2) return amd_national_stock_items.cost_to_repair_off_base_cleand%type ;
	function GetCriticality(pNsn in varchar2) return amd_national_stock_items.criticality_cleaned%type ;
	function GetDlaDemand(pNsn in varchar2) return amd_national_stock_items.dla_demand_cleaned%type ;
	function GetDlaWarehouseStock(pNsn in varchar2) return amd_national_stock_items.dla_warehouse_stock_cleaned%type ;
	function GetFedcCost(pNsn in varchar2) return amd_national_stock_items.fedc_cost_cleaned%type ;
	function GetItemType(pNsn in varchar2) return amd_national_stock_items.item_type_cleaned%type ;
	function GetMicCodeLowest(pNsn in varchar2) return amd_national_stock_items.mic_code_lowest_cleaned%type ;
	function GetMtbdr(pNsn in varchar2) return amd_national_stock_items.mtbdr_cleaned%type ;
	function GetNomenclature(pNsn in varchar2) return amd_national_stock_items.nomenclature_cleaned%type ;
	function GetNrtsAvg(pNsn in varchar2) return amd_national_stock_items.nrts_avg_cleaned%type ;
	function GetOrderLeadTime(pNsn in varchar2) return amd_national_stock_items.order_lead_time_cleaned%type ;
	function GetOrderUom(pNsn in varchar2) return amd_national_stock_items.order_uom_cleaned%type ;
	function GetPlannerCode(pNsn in varchar2) return amd_national_stock_items.planner_code_cleaned%type ;
	function GetPrimeInd(pNsn in varchar2, pPart_no in varchar2, pMfgr in varchar2) return amd_nsi_parts.prime_ind_cleaned%type ;
	function GetRuInd(pNsn in varchar2) return amd_national_stock_items.ru_ind_cleaned%type ;
	function GetRtsAvg(pNsn in varchar2) return amd_national_stock_items.rts_avg_cleaned%type ;
	function GetSmrCode(pNsn in varchar2) return amd_national_stock_items.smr_code_cleaned%type ;
	function GetTimeToRepairOffBase(pNsn in varchar2) return amd_national_stock_items.time_to_repair_off_base_cleand%type ;
	function GetTimeToRepairOnBaseAvg(pNsn in varchar2) return amd_national_stock_items.time_to_repair_on_base_avg_cl%type ;
	function GetUnitCost(pNsn in varchar2) return amd_national_stock_items.unit_cost_cleaned%type ;
end amd_clean_data ;
/
CREATE OR REPLACE package body amd_clean_data as

/*
 	These routines will make it easy to retrieve cleaned data from BSSM
 	Douglas S. Elder and Chung D. Lu  	10/03/01	Initial implementation

	Douglas S. Elder					11/6/01		The cache will work best
		when the data is sorted by nsn asc, prime_ind desc
 */

 	cleanRec		amd_cleaned_from_bssm_pkg.partFields := null ;
	procedure CheckCache(pNsn in varchar2) is
	begin
		if cleanRec.nsn != pNsn then
			cleanRec := amd_cleaned_from_bssm_pkg.GetValues(pNsn) ;
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
	function GetCondemnAvg(pNsn in varchar2) return amd_national_stock_items.condemn_avg_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.condemn_avg ;
	end ;
	function GetCostToRepairOffBase(pNsn in varchar2) return amd_national_stock_items.cost_to_repair_off_base_cleand%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.cost_to_repair_off_base ;
	end ;
	function GetCriticality(pNsn in varchar2) return amd_national_stock_items.criticality_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.criticality ;
	end ;
	function GetDlaDemand(pNsn in varchar2) return amd_national_stock_items.dla_demand_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.dla_demand ;
	end ;
	function GetDlaWarehouseStock(pNsn in varchar2) return amd_national_stock_items.dla_warehouse_stock_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.dla_warehouse_stock ;
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
	function GetMtbdr(pNsn in varchar2) return amd_national_stock_items.mtbdr_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.mtbdr ;
	end ;
	function GetNomenclature(pNsn in varchar2) return amd_national_stock_items.nomenclature_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.nomenclature ;
	end ;
	function GetNrtsAvg(pNsn in varchar2) return amd_national_stock_items.nrts_avg_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.nrts_avg ;
	end ;
	function GetOrderLeadTime(pNsn in varchar2) return amd_national_stock_items.order_lead_time_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.order_lead_time ;
	end ;
	function GetOrderUom(pNsn in varchar2) return amd_national_stock_items.order_uom_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.order_uom ;
	end ;

	function GetPlannerCode(pNsn in varchar2) return amd_national_stock_items.planner_code_cleaned%type is
	begin
		--return	amd_cleaned_from_bssm_pkg.GetValues(pNsn => pNsn, pFieldName => amd_cleaned_from_bssm_pkg.PLANNER_CODE) ;
		return null ; -- todo
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
	function GetRtsAvg(pNsn in varchar2) return amd_national_stock_items.rts_avg_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.rts_avg ;
	end ;
	function GetSmrCode(pNsn in varchar2) return amd_national_stock_items.smr_code_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.smr_code ;
	end ;
	function GetTimeToRepairOffBase(pNsn in varchar2) return amd_national_stock_items.time_to_repair_off_base_cleand%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.time_to_repair_off_base ;
	end ;
	function GetTimeToRepairOnBaseAvg(pNsn in varchar2) return amd_national_stock_items.time_to_repair_on_base_avg_cl%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.time_to_repair_on_base_avg ;
	end ;
	function GetUnitCost(pNsn in varchar2) return amd_national_stock_items.unit_cost_cleaned%type is
	begin
		CheckCache(pNsn) ;
		return	cleanRec.unit_cost ;
	end ;
end amd_clean_data ;
/
