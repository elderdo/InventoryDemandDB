SET DEFINE OFF;
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

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_PREFERRED_PKG;

CREATE PUBLIC SYNONYM AMD_PREFERRED_PKG FOR AMD_OWNER.AMD_PREFERRED_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_PREFERRED_PKG TO AMD_WRITER_ROLE;


SET DEFINE OFF;
DROP PACKAGE BODY AMD_OWNER.AMD_PREFERRED_PKG;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER."AMD_PREFERRED_PKG"  is

    /*   				
	    PVCS Keywords
		
       $Author:   zf297a  $
     $Revision:   1.12  $
         $Date:   12 Aug 2008 08:52:06  $
     $Workfile:   amd_preferred_pkg.pkb  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_preferred_pkg.pkb-arc  $
   
      Rev 1.12   12 Aug 2008 08:52:06   zf297a
   Added writeMsg to be used by procedure version.  Implemented the public function getVersion and public procedure version.
   
      Rev 1.11   31 Jul 2008 11:26:06   zf297a
   Changed the implementation of getPlannerCode(nsi_sid) so that it also may return the default planner code based on part_no (consumable or repairable).
   
   Add new function getPlannerCodeByPart 
   
      Rev 1.10   May 06 2005 08:07:42   c970183
   changed dla_warehouse_stock and dla_warehouse_stock_cleaned to current_backorder and current_backorder_cleaned.  added pvcs keywords
   	  */	  
	function GetPreferredValue(pPreferred1 in varchar2, pPreferred2 in varchar2) return varchar2 is
	begin
		if pPreferred1 is not null then
			return pPreferred1 ;
		else
			return pPreferred2 ;
		end if ;
	end GetPreferredValue ;

	function GetPreferredValue(pPreferred1 in varchar2, pPreferred2 in varchar2, pPreferred3 in varchar2) return varchar2 is
	begin
		if pPreferred1 is not null then
			return pPreferred1 ;
		elsif pPreferred2 is not null then
			return pPreferred2 ;
		else
			return pPreferred3 ;
		end if ;
	end GetPreferredValue ;

	function GetPreferredValue(pPreferred1 in number, pPreferred2 in number) return number is
	begin
		if pPreferred1 is not null then
			return pPreferred1 ;
		else
			return pPreferred2 ;
		end if ;
	end GetPreferredValue ;

	function GetPreferredValue(pPreferred1 in number, pPreferred2 in number,  pPreferred3 in number) return number is
	begin
		if pPreferred1 is not null then
			return pPreferred1 ;
		elsif pPreferred2 is not null then
			return pPreferred2 ;
		else
			return pPreferred3 ;
		end if ;
	end GetPreferredValue ;

	function GetLocSid(pLoc_id in amd_spare_networks.loc_id%type) return amd_spare_networks.loc_sid%type is
		loc_sid amd_spare_networks.loc_sid%type := null ;
	begin
		select loc_sid into loc_sid
		from amd_spare_networks
		where loc_id = pLoc_id ;
		return loc_sid ;
	end GetLocSid ;

	function GetAddIncrement(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.add_increment%type is
		add_increment amd_national_stock_items.add_increment%type ;
		add_increment_cleaned amd_national_stock_items.add_increment_cleaned%type ;
	begin
		select add_increment, add_increment_cleaned
		into add_increment, add_increment_cleaned
		from amd_national_stock_items
		where nsi_sid = pNsi_sid ;
		return GetPreferredValue(add_increment_cleaned, add_increment) ;
	end GetAddIncrement ;

	function GetAddIncrement(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.add_increment%type is
	begin
		return GetAddIncrement(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetAddIncrement ;

	function GetAmcBaseStock(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.amc_base_stock%type is
		amc_base_stock amd_national_stock_items.amc_base_stock%type ;
		amc_base_stock_cleaned amd_national_stock_items.amc_base_stock_cleaned%type ;
	begin
		select amc_base_stock, amc_base_stock_cleaned
		into amc_base_stock, amc_base_stock_cleaned
		from amd_national_stock_items
		where nsi_sid = pNsi_sid ;
		return GetPreferredValue(amc_base_stock_cleaned, amc_base_stock) ;
	end GetAmcBaseStock ;

	function GetAmcBaseStock(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.amc_base_stock%type is
	begin
		return GetAmcBaseStock(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetAmcBaseStock ;

	function GetAmcDaysExperience(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.amc_days_experience%type is
		amc_days_experience amd_national_stock_items.amc_days_experience%type ;
		amc_days_experience_cleaned amd_national_stock_items.amc_days_experience_cleaned%type ;
	begin
		select amc_days_experience, amc_days_experience_cleaned
		into amc_days_experience, amc_days_experience_cleaned
		from amd_national_stock_items
		where nsi_sid = pNsi_sid ;
		return GetPreferredValue(amc_days_experience_cleaned, amc_days_experience) ;
	end GetAmcDaysExperience ;

	function GetAmcDaysExperience(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.amc_days_experience%type is
	begin
		return GetAmcDaysExperience(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetAmcDaysExperience ;

	function GetAmcDemand(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.amc_demand%type is
		amc_demand amd_national_stock_items.amc_demand%type ;
		amc_demand_cleaned amd_national_stock_items.amc_demand_cleaned%type ;
	begin
		select amc_demand, amc_demand_cleaned
		into amc_demand, amc_demand_cleaned
		from amd_national_stock_items
		where nsi_sid = pNsi_sid ;
		return GetPreferredValue(amc_demand_cleaned, amc_demand) ;
	end GetAmcDemand ;

	function GetAmcDemand(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.amc_demand%type is
	begin
		return GetAmcDaysExperience(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetAmcDemand ;

	function GetCapabilityRequirement(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.capability_requirement%type is
		capability_requirement amd_national_stock_items.capability_requirement%type ;
		capability_requirement_cleaned amd_national_stock_items.capability_requirement_cleaned%type ;
	begin
		select capability_requirement, capability_requirement_cleaned
		into capability_requirement, capability_requirement_cleaned
		from amd_national_stock_items
		where nsi_sid = pNsi_sid ;
		return GetPreferredValue(capability_requirement_cleaned, capability_requirement) ;
	end GetCapabilityRequirement ;

	function GetCapabilityRequirement(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.capability_requirement%type is
	begin
		return GetCapabilityRequirement(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetCapabilityRequirement ;

	function GetCondemnAvg(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.condemn_avg%type is
		condemn_avg amd_national_stock_items.condemn_avg%type ;
		condemn_avg_cleaned amd_national_stock_items.condemn_avg_cleaned%type ;
	begin
		select condemn_avg, condemn_avg_cleaned
		into condemn_avg, condemn_avg_cleaned
		from amd_national_stock_items
		where nsi_sid = pNsi_sid ;
		return GetPreferredValue(condemn_avg_cleaned, condemn_avg) ;
	end GetCondemnAvg;

	function GetCondemnAvg(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.condemn_avg%type is
	begin
		return GetCondemnAvg(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetCondemnAvg ;

	function GetCostToRepairOffBase(pNsi_sid in amd_part_locs.nsi_sid%type, pLoc_sid in amd_part_locs.loc_sid%type) return amd_part_locs.cost_to_repair%type is
		cost_to_repair_off_base amd_national_stock_items.cost_to_repair_off_base_cleand%type ;
		cost_to_repair_off_base_defltd amd_national_stock_items.cost_to_repair_off_base_cleand%type ;
		cost_to_repair_off_base_cleand amd_national_stock_items.cost_to_repair_off_base_cleand%type ;
	begin
		-- todo verify if this is the correct way to get
		-- these fields
		select cost_to_repair_off_base_cleand, cost_to_repair, cost_to_repair_defaulted
		into cost_to_repair_off_base_cleand, cost_to_repair_off_base, cost_to_repair_off_base_defltd
		from amd_national_stock_items items, amd_part_locs locs
		where locs.nsi_sid = pNsi_sid
		and locs.loc_sid = pLoc_sid
		and locs.nsi_sid = items.nsi_sid ;
		return GetPreferredValue(cost_to_repair_off_base_cleand, cost_to_repair_off_base, cost_to_repair_off_base_defltd) ;
	end GetCostToRepairOffBase ;

	function GetCostToRepairOffBase(pNsn in amd_nsns.nsn%type, pLoc_id in amd_spare_networks.loc_id%type) return amd_part_locs.cost_to_repair%type is
	begin
		return GetCostToRepairOffBase(amd_utils.GetNsiSid(pNsn => pNsn), GetLocSid(pLoc_id)) ;
	end GetCostToRepairOffBase ;

	function GetCurrentPrimeInd(pNsi_sid in amd_nsi_parts.nsi_sid%type, pPart_no in amd_nsi_parts.part_no%type) return amd_nsi_parts.prime_ind%type is
		prime_ind amd_nsi_parts.prime_ind%type := null ;
		prime_ind_cleaned amd_nsi_parts.prime_ind_cleaned%type := null ;
	begin
		select prime_ind, prime_ind_cleaned
		into prime_ind, prime_ind_cleaned
		from amd_nsi_parts
		where nsi_sid = pNsi_sid
		and part_no = pPart_no
		and assignment_date = (select max(assignment_date) from amd_nsi_parts where nsi_sid = pNsi_sid and part_no = pPart_no ) ;
		return GetPreferredValue(prime_ind_cleaned, prime_ind) ;
	end GetCurrentPrimeInd ;

	function GetCurrentPrimeInd(pNsn in amd_nsns.nsn%type, pPart_no in amd_nsi_parts.part_no%type ) return amd_nsi_parts.prime_ind%type is
	begin
		return GetCurrentPrimeInd(amd_utils.GetNsiSid(pNsn => pNsn), pPart_no) ;
	end GetCurrentPrimeInd ;

	function GetCriticality(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.criticality%type is
		criticality amd_national_stock_items.criticality%type ;
		criticality_cleaned amd_national_stock_items.criticality_cleaned%type ;
	begin
		select criticality, criticality_cleaned
		into criticality, criticality_cleaned
		from amd_national_stock_items
		where nsi_sid = pNsi_sid ;
		return GetPreferredValue(criticality_cleaned, criticality) ;
	end GetCriticality ;

	function GetCriticality(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.criticality%type is
	begin
		return GetCriticality(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetCriticality ;

	function GetDistribUom(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.distrib_uom%type is
		distrib_uom amd_national_stock_items.distrib_uom%type ;
		distrib_uom_defaulted amd_national_stock_items.distrib_uom_defaulted%type ;
	begin
		select distrib_uom, distrib_uom_defaulted
		into distrib_uom, distrib_uom_defaulted
		from amd_national_stock_items
		where nsi_sid = pNsi_sid ;
		return GetPreferredValue(distrib_uom, distrib_uom_defaulted) ;
	end GetDistribUom ;

	function GetDistribUom(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.distrib_uom%type is
	begin
		return GetDistribUom(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetDistribUom ;

	function GetDlaDemand(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.dla_demand%type is
		dla_demand amd_national_stock_items.dla_demand%type ;
		dla_demand_cleaned amd_national_stock_items.dla_demand_cleaned%type ;
	begin
		select dla_demand, dla_demand_cleaned
		into dla_demand, dla_demand_cleaned
		from amd_national_stock_items
		where nsi_sid = pNsi_sid ;
		return GetPreferredValue(dla_demand_cleaned, dla_demand) ;
	end GetDlaDemand ;

	function GetDlaDemand(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.dla_demand%type is
	begin
		return GetDlaDemand(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetDlaDemand ;

	function GetDlaWarehouseStock(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.current_backorder%type is
		dla_warehouse_stock amd_national_stock_items.current_backorder%type ;
		dla_warehouse_stock_cleaned amd_national_stock_items.current_backorder_cleaned%type ;
	begin
		select dla_warehouse_stock, dla_warehouse_stock_cleaned
		into dla_warehouse_stock, dla_warehouse_stock_cleaned
		from amd_national_stock_items
		where nsi_sid = pNsi_sid ;
		return GetPreferredValue(dla_warehouse_stock_cleaned, dla_warehouse_stock) ;
	end GetDlaWarehouseStock ;

	function GetDlaWarehouseStock(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.current_backorder%type is
	begin
		return GetDlaWarehouseStock(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetDlaWarehouseStock ;

	function GetFedcCost(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.fedc_cost%type is
		fedc_cost amd_national_stock_items.fedc_cost%type ;
		fedc_cost_cleaned amd_national_stock_items.fedc_cost_cleaned%type ;
	begin
		select fedc_cost, fedc_cost_cleaned
		into fedc_cost, fedc_cost_cleaned
		from amd_national_stock_items
		where nsi_sid = pNsi_sid ;
		return GetPreferredValue(fedc_cost_cleaned, fedc_cost) ;
	end GetFedcCost ;

	function GetFedcCost(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.fedc_cost%type is
	begin
		return GetFedcCost(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetFedcCost ;

	function GetItemType(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.item_type%type is
		item_type amd_national_stock_items.item_type%type ;
		item_type_cleaned amd_national_stock_items.item_type_cleaned%type ;
	begin
		select item_type, item_type_cleaned
		into item_type, item_type_cleaned
		from amd_national_stock_items
		where nsi_sid = pNsi_sid ;
		return GetPreferredValue(item_type_cleaned, item_type) ;
	end GetItemType ;

	function GetItemType(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.item_type%type is
	begin
		return GetItemType(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetItemType ;

	function GetMicCodeLowest(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.mic_code_lowest%type is
		mic_code_lowest amd_national_stock_items.mic_code_lowest%type ;
		mic_code_lowest_cleaned amd_national_stock_items.mic_code_lowest_cleaned%type ;
	begin
		select mic_code_lowest, mic_code_lowest_cleaned
		into mic_code_lowest, mic_code_lowest_cleaned
		from amd_national_stock_items
		where nsi_sid = pNsi_sid ;
		return GetPreferredValue(mic_code_lowest_cleaned, mic_code_lowest) ;
	end GetMicCodeLowest ;

	function GetMicCodeLowest(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.mic_code_lowest%type is
	begin
		return GetMicCodeLowest(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetMicCodeLowest ;

	function GetMtbdr(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.mtbdr%type is
		mtbdr amd_national_stock_items.mtbdr%type ;
		mtbdr_cleaned amd_national_stock_items.mtbdr_cleaned%type ;
        mtbdr_computed amd_national_stock_items.mtbdr_computed%type ;
	begin
		select mtbdr, mtbdr_cleaned, mtbdr_computed
		into mtbdr, mtbdr_cleaned, mtbdr_computed
		from amd_national_stock_items
		where nsi_sid = pNsi_sid ;
		return GetPreferredValue(mtbdr_cleaned, mtbdr_computed, mtbdr) ;
	end GetMtbdr ;

	function GetMtbdr(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.mtbdr%type is
	begin
		return GetMtbdr(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetMtbdr ;

	function GetNomenclature(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_spare_parts.nomenclature%type is
		nomenclature amd_spare_parts.nomenclature%type ;
		nomenclature_cleaned amd_national_stock_items.nomenclature_cleaned%type ;
	begin
		select nomenclature, nomenclature_cleaned
		into nomenclature, nomenclature_cleaned
		from amd_national_stock_items,
		amd_spare_parts parts
		where nsi_sid = pNsi_sid and
		prime_part_no = parts.part_no ;
		return GetPreferredValue(nomenclature_cleaned, nomenclature) ;
	end GetNomenclature ;

	function GetNomenclature(pNsn in amd_nsns.nsn%type) return amd_spare_parts.nomenclature%type is
	begin
		return GetNomenclature(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetNomenclature ;

	function GetNrtsAvg(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.nrts_avg%type is
		nrts_avg amd_national_stock_items.nrts_avg%type ;
		nrts_avg_cleaned amd_national_stock_items.nrts_avg_cleaned%type ;
	begin
		select nrts_avg, nrts_avg_cleaned
		into nrts_avg, nrts_avg_cleaned
		from amd_national_stock_items
		where nsi_sid = pNsi_sid ;
		return GetPreferredValue(nrts_avg_cleaned, nrts_avg) ;
	end GetNrtsAvg ;

	function GetNrtsAvg(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.nrts_avg%type is
	begin
		return GetNrtsAvg(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetNrtsAvg ;

	function GetOrderLeadTime(pNsn in amd_spare_parts.nsn%type) return amd_spare_parts.order_lead_time%type is
		nsi_sid amd_national_stock_items.nsi_sid%type := null ;
		prime_part_no amd_national_stock_items.prime_part_no%type := null ;
	begin
		nsi_sid := amd_utils.GetNsiSid(pNsn => pNsn) ;
		select prime_part_no
		into prime_part_no
		from amd_national_stock_items
		where nsi_sid = GetOrderLeadTime.nsi_sid ;
		return GetOrderLeadTime(pPart_no => prime_part_no) ;
	end GetOrderLeadTime ;

	function GetOrderLeadTimeByNsn(pNsn in amd_spare_parts.nsn%type) return amd_spare_parts.order_lead_time%type is
	begin
		return GetOrderLeadTime(pNsn => pNsn) ;
	end GetOrderLeadTimeByNsn ;

	function GetOrderLeadTime(pPart_no in amd_spare_parts.part_no%type) return amd_spare_parts.order_lead_time%type is
		order_lead_time amd_spare_parts.order_lead_time%type ;
		order_lead_time_defaulted amd_spare_parts.order_lead_time_defaulted%type ;
		order_lead_time_cleaned amd_national_stock_items.order_lead_time_cleaned%type ;
	begin
		select order_lead_time, order_lead_time_defaulted, order_lead_time_cleaned
		into order_lead_time, order_lead_time_defaulted, order_lead_time_cleaned
		from amd_spare_parts
		where part_no = pPart_no ;
		return GetPreferredValue(order_lead_time_cleaned, order_lead_time_defaulted, order_lead_time) ;
	end GetOrderLeadTime ;

	function GetOrderLeadTimeByPart(pPart_no in amd_spare_parts.part_no%type) return amd_spare_parts.order_lead_time%type is
	begin
		return GetOrderLeadTime(pPart_no => pPart_no) ;
	end GetOrderLeadTimeByPart ;

	function GetOrderQuantity(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.order_quantity%type is
		order_quantity amd_national_stock_items.order_quantity%type := null ;
		order_quantity_defaulted amd_national_stock_items.order_quantity_defaulted%type := null ;
	begin
		select order_quantity, order_quantity_defaulted
		into order_quantity, order_quantity_defaulted
		from amd_national_stock_items
		where nsi_sid = pNsi_sid ;
		return GetPreferredValue(order_quantity, order_quantity_defaulted) ;
	end GetOrderQuantity ;

	function GetOrderQuantity(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.order_quantity%type is
	begin
		return GetOrderQuantity(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetOrderQuantity ;

	function GetOrderUom(pPart_no in amd_spare_parts.part_no%type) return amd_spare_parts.order_uom%type is
		order_uom amd_spare_parts.order_uom%type := null ;
		order_uom_defaulted amd_spare_parts.order_uom_defaulted%type := null ;
		order_uom_cleaned amd_national_stock_items.order_uom_cleaned%type := null ;
	begin
		select order_uom, order_uom_defaulted, order_uom_cleaned
		into order_uom, order_uom_defaulted, order_uom_cleaned
		from amd_spare_parts
		where part_no = pPart_no ;
		return GetPreferredValue(order_uom_cleaned, order_uom, order_uom_defaulted) ;
	end GetOrderUom ;

	function GetPlannerCode(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.planner_code%type is
		planner_code amd_national_stock_items.planner_code%type := null ;
		planner_code_cleaned amd_national_stock_items.planner_code_cleaned%type := null ;
        planner_code_default amd_national_stock_items.planner_code%type := null ;
	begin
		select planner_code, planner_code_cleaned, amd_defaults.getplannerCode(nsn)
		into planner_code, planner_code_cleaned, planner_code_default
		from amd_national_stock_items
		where nsi_sid = pNsi_sid ;
		return GetPreferredValue(planner_code_cleaned, planner_code, planner_code_default) ;
	end GetPlannerCode ;

	function GetPlannerCode(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.planner_code%type is
	begin
		return GetPlannerCode(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetPlannerCode ;
    
    function getPlannerCodeByPart(part_no in amd_spare_parts.part_no%type) return amd_national_stock_items.planner_code%type is
    begin
        return getPlannerCode(pNsi_sid => amd_utils.GetNsiSid(pNsn => amd_utils.GETNSN(part_no))) ;
    end getPlannerCodeByPart ;

	function GetPrimeInd(pNsi_sid in amd_nsi_parts.nsi_sid%type, pPart_no in amd_nsi_parts.part_no%type) return amd_nsi_parts.prime_ind%type is
		prime_ind amd_nsi_parts.prime_ind%type := null ;
		prime_ind_cleaned amd_nsi_parts.prime_ind_cleaned%type := null ;
	begin
		select prime_ind, prime_ind_cleaned
		into prime_ind, prime_ind_cleaned
		from amd_nsi_parts
		where nsi_sid = pNsi_sid
		and part_no = pPart_no
		and assignment_date =
			(select max(assignment_date) from amd_nsi_parts where nsi_sid = pNsi_sid and part_no = pPart_no)
		and unassignment_date is null ;
		return GetPreferredValue(prime_ind_cleaned, prime_ind) ;
	end GetPrimeInd ;

	function GetPrimeInd(pNsn in amd_nsns.nsn%type, pPart_no in amd_nsi_parts.part_no%type) return amd_nsi_parts.prime_ind%type is
	begin
		return GetPrimeInd(amd_utils.GetNsiSid(pNsn => pNsn), pPart_no) ;
	end GetPrimeInd ;


	function GetQpeiWeighted(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.qpei_weighted%type is
		qpei_weighted amd_national_stock_items.qpei_weighted%type := null ;
		qpei_weighted_defaulted amd_national_stock_items.qpei_weighted_defaulted%type := null ;
	begin
		select qpei_weighted, qpei_weighted_defaulted
		into qpei_weighted, qpei_weighted_defaulted
		from amd_national_stock_items
		where nsi_sid = pNsi_sid ;
		return GetPreferredValue(qpei_weighted, qpei_weighted_defaulted) ;
	end GetQpeiWeighted ;

	function GetQpeiWeighted(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.qpei_weighted%type is
	begin
		return GetQpeiWeighted(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetQpeiWeighted ;

	function GetRtsAvg(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.rts_avg%type is
		rts_avg amd_national_stock_items.rts_avg%type := null ;
		rts_avg_defaulted amd_national_stock_items.rts_avg_defaulted%type := null ;
		rts_avg_cleaned amd_national_stock_items.rts_avg_cleaned%type := null ;
	begin
		select rts_avg, rts_avg_defaulted, rts_avg_cleaned
		into rts_avg, rts_avg_defaulted, rts_avg_cleaned
		from amd_national_stock_items
		where nsi_sid = pNsi_sid ;
		return GetPreferredValue(rts_avg_cleaned, rts_avg, rts_avg_defaulted) ;
	end GetRtsAvg ;

	function GetRtsAvg(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.rts_avg%type is
	begin
		return GetRtsAvg(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetRtsAvg ;

	function GetRuInd(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.ru_ind%type is
		ru_ind amd_national_stock_items.ru_ind%type := null ;
		ru_ind_cleaned amd_national_stock_items.ru_ind_cleaned%type := null ;
	begin
		select ru_ind, ru_ind_cleaned
		into ru_ind, ru_ind_cleaned
		from amd_national_stock_items
		where nsi_sid = pNsi_sid ;
		return GetPreferredValue(ru_ind_cleaned, ru_ind) ;
	end GetRuInd ;

	function GetRuInd(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.ru_ind%type is
	begin
		return GetRuInd(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetRuInd ;

	function GetScrapValue(pPart_no in amd_spare_parts.part_no%type) return amd_spare_parts.scrap_value%type is
		scrap_value amd_spare_parts.scrap_value%type := null ;
		scrap_value_defaulted amd_spare_parts.scrap_value_defaulted%type := null ;
	begin
		select scrap_value, scrap_value_defaulted
		into scrap_value, scrap_value_defaulted
		from amd_spare_parts
		where part_no = pPart_no ;
		return GetPreferredValue(scrap_value, scrap_value_defaulted) ;
	end GetScrapValue ;

	function GetShelfLife(pPart_no in amd_spare_parts.part_no%type) return amd_spare_parts.shelf_life%type is
		shelf_life amd_spare_parts.shelf_life%type := null ;
		shelf_life_defaulted amd_spare_parts.shelf_life_defaulted%type := null ;
	begin
		select shelf_life, shelf_life_defaulted
		into shelf_life, shelf_life_defaulted
		from amd_spare_parts
		where part_no = pPart_no ;
		return GetPreferredValue(shelf_life, shelf_life_defaulted) ;
	end GetShelfLife ;

	function GetSmrCode(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.smr_code%type is
		smr_code amd_national_stock_items.smr_code%type := null ;
		smr_code_cleaned amd_national_stock_items.smr_code_cleaned%type := null ;
		smr_code_defaulted amd_national_stock_items.smr_code_defaulted%type := null ;
	begin
		select smr_code, smr_code_cleaned, smr_code_defaulted
		into smr_code, smr_code_cleaned, smr_code_defaulted
		from amd_national_stock_items
		where nsi_sid = pNsi_sid ;
		return GetPreferredValue(smr_code_cleaned, smr_code, smr_code_defaulted) ;
	end GetSmrCode ;

	function GetSmrCode(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.smr_code%type is
	begin
		return GetSmrCode(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetSmrCode ;

	function GetTimeToRepairOffBase(pNsi_sid in amd_part_locs.nsi_sid%type, pLoc_sid in amd_part_locs.loc_sid%type) return amd_part_locs.time_to_repair%type is
		time_to_repair_off_base amd_part_locs.time_to_repair%type := null ;
		time_to_repair_off_base_cleand amd_national_stock_items.time_to_repair_off_base_cleand%type := null ;
		time_to_repair_off_base_defltd amd_part_locs.time_to_repair_defaulted%type := null ;
	begin
		select time_to_repair, time_to_repair_off_base_cleand, time_to_repair_defaulted
		into time_to_repair_off_base, time_to_repair_off_base_cleand, time_to_repair_off_base_defltd
		from amd_national_stock_items items, amd_part_locs locs
		where locs.nsi_sid = pNsi_sid
		and locs.loc_sid = pLoc_sid
		and locs.nsi_sid = items.nsi_sid ;
		return GetPreferredValue(time_to_repair_off_base_cleand, time_to_repair_off_base, time_to_repair_off_base_defltd) ;
	end GetTimeToRepairOffBase ;

	function GetTimeToRepairOffBase(pNsn in amd_nsns.nsn%type, pLoc_id in amd_spare_networks.loc_id%type) return amd_part_locs.time_to_repair%type is
	begin
		return GetTimeToRepairOffBase(amd_utils.GetNsiSid(pNsn => pNsn), GetLocSid(pLoc_id)) ;
	end GetTimeToRepairOffBase ;

	function GetTimeToRepairOnBaseAvg(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.time_to_repair_on_base_avg%type is
		time_to_repair_on_base_avg amd_national_stock_items.time_to_repair_on_base_avg%type := null ;
		time_to_repair_on_base_avg_cl amd_national_stock_items.time_to_repair_on_base_avg_cl%type := null ;
		time_to_repair_on_base_avg_df amd_national_stock_items.time_to_repair_on_base_avg_df%type := null ;
	begin
		select time_to_repair_on_base_avg, time_to_repair_on_base_avg_cl, time_to_repair_on_base_avg_df
		into time_to_repair_on_base_avg, time_to_repair_on_base_avg_cl, time_to_repair_on_base_avg_df
		from amd_national_stock_items
		where nsi_sid = pNsi_sid ;
		return GetPreferredValue(time_to_repair_on_base_avg_cl, time_to_repair_on_base_avg, time_to_repair_on_base_avg_df) ;
	end GetTimeToRepairOnBaseAvg ;

	function GetTimeToRepairOnBaseAvg(pNsn in amd_nsns.nsn%type) return amd_national_stock_items.time_to_repair_on_base_avg%type is
	begin
		return GetTimeToRepairOnBaseAvg(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetTimeToRepairOnBaseAvg ;

	function GetUnitCost(pNsi_sid in amd_national_stock_items.nsi_sid%type) return amd_spare_parts.unit_cost%type is
		unit_cost amd_spare_parts.unit_cost%type := null ;
		unit_cost_defaulted amd_spare_parts.unit_cost_defaulted%type := null ;
		unit_cost_cleaned amd_national_stock_items.unit_cost_cleaned%type := null ;
	begin
		select unit_cost, unit_cost_cleaned, unit_cost_defaulted
		into unit_cost, unit_cost_cleaned, unit_cost_defaulted
		from amd_spare_parts parts, amd_national_stock_items items
		where nsi_sid = pNsi_sid
		and items.prime_part_no = parts.part_no ;
		return GetPreferredValue(unit_cost_cleaned, unit_cost, unit_cost_defaulted) ;
	end GetUnitCost ;

	function GetUnitCost(pNsn in amd_nsns.nsn%type) return amd_spare_parts.unit_cost%type is
	begin
		return GetUnitCost(amd_utils.GetNsiSid(pNsn => pNsn)) ;
	end GetUnitCost ;

	function GetUnitCostByNsn(pNsn in amd_nsns.nsn%type) return amd_spare_parts.unit_cost%type is
	begin
		return GetUnitCost(pNsn => pNsn) ;
	end GetUnitCostByNsn ;

	function GetUnitCost(pPart_no in amd_spare_parts.part_no%type) return amd_spare_parts.unit_cost%type is
		unit_cost amd_spare_parts.unit_cost%type := null ;
		unit_cost_defaulted amd_spare_parts.unit_cost_defaulted%type := null ;
		unit_cost_cleaned amd_national_stock_items.unit_cost_cleaned%type := null ;
	begin
		select unit_cost, unit_cost_cleaned, unit_cost_defaulted
		into unit_cost, unit_cost_cleaned, unit_cost_defaulted
		from amd_spare_parts parts, amd_national_stock_items items
		where part_no = pPart_no
		and items.nsn = parts.nsn ;
		return GetPreferredValue(unit_cost_cleaned, unit_cost, unit_cost_defaulted) ;
	end GetUnitCost ;

	function GetUnitCostByPart(pPart_no in amd_spare_parts.part_no%type) return amd_spare_parts.unit_cost%type is
	begin
		return GetUnitCost(pPart_no => pPart_no) ;
	end GetUnitCostByPart ;

	function GetUnitVolume(pPart_no in amd_spare_parts.part_no%type) return amd_spare_parts.unit_volume%type is
		unit_volume amd_spare_parts.unit_volume%type := null ;
		unit_volume_defaulted amd_spare_parts.unit_volume_defaulted%type := null ;
	begin
		select unit_volume, unit_volume_defaulted
		into unit_volume, unit_volume_defaulted
		from amd_spare_parts
		where part_no = pPart_no ;
		return GetPreferredValue(unit_volume, unit_volume_defaulted) ;
	end GetUnitVolume ;

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
                pSourceName => 'amd_preferred_pkg',    
                pTableName  => pTableName,
                pError_location => pError_location,
                pKey1 => pKey1,
                pKey2 => pKey2,
                pKey3 => pKey3,
                pKey4 => pKey4,
                pData    => pData,
                pComments => pComments);
    exception when others then
        --  ignoretrying to rollback or commit from trigger
        if sqlcode <> -4092 then
            raise_application_error(-20010,
                substr('amd_preferred_pkg ' 
                    || sqlcode || ' '
                    || pError_Location || ' ' 
                    || pTableName || ' ' 
                    || pKey1 || ' ' 
                    || pKey2 || ' ' 
                    || pKey3 || ' ' 
                    || pKey4 || ' '
                    || pData, 1,2000)) ;
        end if ;
    END writeMsg ;

        function getVersion return varchar2 is
        begin
            dbms_output.put_line('$Revision:   1.12  $') ;
            return '$Revision:   1.12  $' ;
        end getVersion ;

        PROCEDURE version IS
        BEGIN
             writeMsg(pTableName => 'amd_preferred_pkg', 
                     pError_location => 10, pKey1 => 'amd_preferred_pkg', pKey2 => '$Revision:   1.12  $') ;
              dbms_output.put_line('amd_preferred_pkg: $Revision:   1.12  $') ;
        END version ;

end amd_preferred_pkg ;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_PREFERRED_PKG;

CREATE PUBLIC SYNONYM AMD_PREFERRED_PKG FOR AMD_OWNER.AMD_PREFERRED_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_PREFERRED_PKG TO AMD_WRITER_ROLE;


