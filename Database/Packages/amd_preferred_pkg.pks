DROP PACKAGE AMD_OWNER.AMD_PREFERRED_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.amd_preferred_pkg
is
    /*
	    PVCS Keywords

       $Author:   zf297a  $
     $Revision:   1.11  $
         $Date:   12 Aug 2008 08:49:44  $
     $Workfile:   amd_preferred_pkg.pks  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_preferred_pkg.pks-arc  $

      Rev 1.11   12 Aug 2008 08:49:44   zf297a
   Added interfaces for function getVersion and procedure version.

      Rev 1.10   31 Jul 2008 11:21:56   zf297a
   Added interface for getPlannerCodeByPart

      Rev 1.9   May 06 2005 08:07:42   c970183
   changed dla_warehouse_stock and dla_warehouse_stock_cleaned to current_backorder and current_backorder_cleaned.  added pvcs keywords
   	  */
 	  /*
		Purpose: Provide a set of API's to retrieve data that
		has, cleaned or defaulted or both values.  The
		cleaned data is preferred over the raw data and the
		raw data is preferred over the defaulted data.

		Douglas S. Elder / Chung D. Lu	10/14/01	Initial Implementation

		Douglas S. Elder 				12/11/01	Removed mfgr column from all routines

		Douglas S. Elder 				12/11/01	Added ByNsn and ByPart suffixed
		functions for GetOrderLeadTime and GetUnitCost to be used in SQL statements:
		Select GetUnitCostByPart(.....) from dual
		Douglas S. Elder 				01/14/02	Eliminated Pragma statement


	*/

	function GetAddIncrement(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.add_increment%type;
	function GetAddIncrement(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.add_increment%type;
	function GetAmcBaseStock(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.amc_base_stock%type;
	function GetAmcBaseStock(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.amc_base_stock%type;
	function GetAmcDaysExperience(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.amc_days_experience%type;
	function GetAmcDaysExperience(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.amc_days_experience%type;
	function GetAmcDemand(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.amc_demand%type;
	function GetAmcDemand(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.amc_demand%type;
	function GetCapabilityRequirement(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.capability_requirement%type;
	function GetCapabilityRequirement(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.capability_requirement%type;
	function GetCondemnAvg(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.condemn_avg%type;
	function GetCondemnAvg(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.condemn_avg%type;
	function GetCostToRepairOffBase(pNsi_sid in amd_part_locs.nsi_sid%type, pLoc_sid in amd_part_locs.loc_sid%type) return amd_part_locs.cost_to_repair%type;
	function GetCostToRepairOffBase(pNsn in amd_nsns.nsn%type, pLoc_id in amd_spare_networks.loc_id%type) return amd_part_locs.cost_to_repair%type ;
	function GetCurrentPrimeInd(pNsi_sid in amd_nsi_parts.nsi_sid%type, pPart_no in amd_nsi_parts.part_no%type) return amd_nsi_parts.prime_ind%type;
	function GetCurrentPrimeInd(pNsn in amd_nsns.nsn%type, pPart_no in amd_nsi_parts.part_no%type) return amd_nsi_parts.prime_ind%type;
	function GetCriticality(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.criticality%type;
	function GetCriticality(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.criticality%type;
	function GetDistribUom(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.distrib_uom%type;
	function GetDistribUom(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.distrib_uom%type;
	function GetDlaDemand(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.dla_demand%type;
	function GetDlaDemand(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.dla_demand%type;
	function GetDlaWarehouseStock(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.current_backorder%type;
	function GetDlaWarehouseStock(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.current_backorder%type;
	function GetFedcCost(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.fedc_cost%type;
	function GetFedcCost(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.fedc_cost%type;
	function GetItemType(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.item_type%type;
	function GetItemType(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.item_type%type;
	function GetMicCodeLowest(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.mic_code_lowest%type;
	function GetMicCodeLowest(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.mic_code_lowest%type;
	function GetMtbdr(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.mtbdr%type;
	function GetMtbdr(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.mtbdr%type;
	function GetNomenclature(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_spare_parts.nomenclature%type;
	function GetNomenclature(pNsn in amd_nsns.nsn%type) return amd_spare_parts.nomenclature%type;
	function GetNrtsAvg(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.nrts_avg%type;
	function GetNrtsAvg(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.nrts_avg%type;
	function GetOrderLeadTime(pNsn in amd_spare_parts.nsn%type) return amd_spare_parts.order_lead_time%type ;
	function GetOrderLeadTimeByNsn(pNsn in amd_spare_parts.nsn%type) return amd_spare_parts.order_lead_time%type ;
	function GetOrderLeadTime(pPart_no in amd_spare_parts.part_no%type) return amd_spare_parts.order_lead_time%type ;
	function GetOrderLeadTimeByPart(pPart_no in amd_spare_parts.part_no%type) return amd_spare_parts.order_lead_time%type ;
	function GetOrderQuantity(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.order_quantity%type;
	function GetOrderQuantity(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.order_quantity%type;
	function GetOrderUom(pPart_no in amd_spare_parts.part_no%type) return amd_spare_parts.order_uom%type ;
	function GetPlannerCode(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.planner_code%type;
	function GetPlannerCode(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.planner_code%type;
    function getPlannerCodeByPart(part_no in amd_spare_parts.part_no%type) return amd_national_stock_items.planner_code%type ;
	function GetPrimeInd(pNsi_sid in amd_nsi_parts.nsi_sid%type, pPart_no in amd_nsi_parts.part_no%type) return amd_nsi_parts.prime_ind%type;
	function GetPrimeInd(pNsn in amd_nsns.nsn%type, pPart_no in amd_nsi_parts.part_no%type) return amd_nsi_parts.prime_ind%type;
	function GetQpeiWeighted(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.qpei_weighted%type;
	function GetQpeiWeighted(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.qpei_weighted%type;
	function GetRtsAvg(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.rts_avg%type;
	function GetRtsAvg(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.rts_avg%type;
	function GetRuInd(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.ru_ind%type;
	function GetRuInd(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.ru_ind%type;
	function GetScrapValue(pPart_no in amd_spare_parts.part_no%type) return amd_spare_parts.scrap_value%type ;
	function GetShelfLife(pPart_no in amd_spare_parts.part_no%type) return amd_spare_parts.shelf_life%type ;
	function GetSmrCode(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.smr_code%type;
	function GetSmrCode(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.smr_code%type;
	function GetTimeToRepairOffBase(pNsi_sid in amd_part_locs.nsi_sid%type, pLoc_sid in amd_part_locs.loc_sid%type) return amd_part_locs.time_to_repair%type;
	function GetTimeToRepairOffBase(pNsn in amd_nsns.nsn%type, pLoc_id in amd_spare_networks.loc_id%type) return amd_part_locs.time_to_repair%type ;
	function GetTimeToRepairOnBaseAvg(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.time_to_repair_on_base_avg%type;
	function GetTimeToRepairOnBaseAvg(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.time_to_repair_on_base_avg%type;
	function GetUnitCost(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_spare_parts.unit_cost%type;
	function GetUnitCost(pNsn in amd_nsns.nsn%type) return amd_spare_parts.unit_cost%type;
	function GetUnitCostByNsn(pNsn in amd_nsns.nsn%type) return amd_spare_parts.unit_cost%type;
	function GetUnitCost(pPart_no in amd_spare_parts.part_no%type) return amd_spare_parts.unit_cost%type;
	function GetUnitCostByPart(pPart_no in amd_spare_parts.part_no%type) return amd_spare_parts.unit_cost%type;
	function GetUnitVolume(pPart_no in amd_spare_parts.part_no%type) return amd_spare_parts.unit_volume%type ;

	-- pPreferred1 takes priority over pPreferred2 and pPreferred2 takes priority over pPreferred3
	function GetPreferredValue(pPreferred1 in varchar2, pPreferred2 in varchar2) return varchar2 ;
	function GetPreferredValue(pPreferred1 in varchar2, pPreferred2 in varchar2, pPreferred3 in varchar2) return varchar2 ;
	function GetPreferredValue(pPreferred1 in number, pPreferred2 in number) return number ;
	function GetPreferredValue(pPreferred1 in number, pPreferred2 in number, pPreferred3 in number) return number ;
      function getVersion return varchar2 ; -- added 8/12/2008 by dse
      PROCEDURE version ; -- added 8/12/2008 by dse

end amd_preferred_pkg ;
 
/


DROP PUBLIC SYNONYM AMD_PREFERRED_PKG;

CREATE PUBLIC SYNONYM AMD_PREFERRED_PKG FOR AMD_OWNER.AMD_PREFERRED_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_PREFERRED_PKG TO AMD_WRITER_ROLE;
