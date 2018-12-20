DROP PACKAGE AMD_OWNER.AMD_CLEAN_DATA;

CREATE OR REPLACE PACKAGE AMD_OWNER.amd_clean_data as
    /*
	    PVCS Keywords

       $Author:   zf297a  $
     $Revision:   1.5  $
         $Date:   Jun 09 2006 12:42:42  $
     $Workfile:   amd_clean_data.pks  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_clean_data.pks-arc  $

      Rev 1.5   Jun 09 2006 12:42:42   zf297a
   added interface version

      Rev 1.5   Aug 23 2005 12:20:02   zf297a
   Added part_no to the interfaces of the cleaned data that is being retrived via the amd_load / diff process.  This will allow the routine to attempt to retrieve the cleaned_data via the part_no if it is not found via the nsn.

      Rev 1.4   May 06 2005 08:15:38   c970183
   changed dla_warehouse_stock and dla_warehouse_stock_cleaned to current_backorder and current_backorder_cleaned.  added pvcs keywords
   	  */

/*
 *	These routines will make it easy to retrieve cleaned data from BSSM
 *	Douglas S. Elder and Chung D. Lu  10/03/01  Initial implementation
 */
   	-- ks - base specific clean fields, not in pkg body yet
	function RemovalInd(pNsn in varchar2, pLocSid in number ) return varchar2;
	function RepairLevelCode(pNsn in varchar2, pLocSid in number) return varchar2;
	--
	function GetCondemnAvg(pNsn in varchar2, pPartNo in varchar2) return amd_national_stock_items.condemn_avg_cleaned%type ;
	function GetNrtsAvg(pNsn in varchar2, pPartNo in varchar2) return amd_national_stock_items.nrts_avg_cleaned%type ;
	function GetCriticality(pNsn in varchar2, pPartNo in varchar2) return amd_national_stock_items.criticality_cleaned%type ;
	function GetMtbdr(pNsn in varchar2, pPartNo in varchar2) return amd_national_stock_items.mtbdr_cleaned%type ;
	function GetRtsAvg(pNsn in varchar2, pPartNo in varchar2) return amd_national_stock_items.rts_avg_cleaned%type ;
	function GetOrderLeadTime(pNsn in varchar2, pPartNo in varchar2) return amd_national_stock_items.order_lead_time_cleaned%type ;
	function GetPlannerCode(pNsn in varchar2, pPartNo in varchar2) return amd_national_stock_items.planner_code_cleaned%type ;
	function GetSmrCode(pNsn in varchar2, pPartNo in varchar2) return amd_national_stock_items.smr_code_cleaned%type ;
	function GetUnitCost(pNsn in varchar2, pPartNo in varchar2) return amd_national_stock_items.unit_cost_cleaned%type ;
	function GetCostToRepairOffBase(pNsn in varchar2, pPartNo in varchar2) return amd_national_stock_items.cost_to_repair_off_base_cleand%type ;
	function GetTimeToRepairOffBase(pNsn in varchar2, pPartNo in varchar2) return amd_national_stock_items.time_to_repair_off_base_cleand%type ;

	function GetAddIncrement(pNsn in varchar2) return amd_national_stock_items.add_increment_cleaned%type ;
	function GetAmcBaseStock(pNsn in varchar2) return amd_national_stock_items.amc_base_stock_cleaned%type ;
	function GetAmcDaysExperience(pNsn in varchar2) return amd_national_stock_items.amc_days_experience_cleaned%type ;
	function GetAmcDemand(pNsn in varchar2) return amd_national_stock_items.amc_demand_cleaned%type ;
	function GetCapabilityRequirement(pNsn in varchar2) return amd_national_stock_items.capability_requirement_cleaned%type ;
	function GetDlaDemand(pNsn in varchar2) return amd_national_stock_items.dla_demand_cleaned%type ;
	function GetCurrentBackorder(pNsn in varchar2) return amd_national_stock_items.current_backorder_cleaned%type ;
	function GetFedcCost(pNsn in varchar2) return amd_national_stock_items.fedc_cost_cleaned%type ;
	function GetItemType(pNsn in varchar2) return amd_national_stock_items.item_type_cleaned%type ;
	function GetMicCodeLowest(pNsn in varchar2) return amd_national_stock_items.mic_code_lowest_cleaned%type ;
	function GetNomenclature(pNsn in varchar2) return amd_national_stock_items.nomenclature_cleaned%type ;
	function GetOrderUom(pNsn in varchar2) return amd_national_stock_items.order_uom_cleaned%type ;
	function GetPrimeInd(pNsn in varchar2, pPart_no in varchar2, pMfgr in varchar2) return amd_nsi_parts.prime_ind_cleaned%type ;
	function GetRuInd(pNsn in varchar2) return amd_national_stock_items.ru_ind_cleaned%type ;
	function GetTimeToRepairOnBaseAvg(pNsn in varchar2) return amd_national_stock_items.time_to_repair_on_base_avg_cl%type ;

	-- added 6/9/2006 by dse
	procedure version ;

end amd_clean_data ;
 
/


DROP PUBLIC SYNONYM AMD_CLEAN_DATA;

CREATE PUBLIC SYNONYM AMD_CLEAN_DATA FOR AMD_OWNER.AMD_CLEAN_DATA;


GRANT EXECUTE ON AMD_OWNER.AMD_CLEAN_DATA TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_CLEAN_DATA TO AMD_WRITER_ROLE;
