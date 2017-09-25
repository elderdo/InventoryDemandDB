CREATE OR REPLACE package amd_defaults as
    /*
     	10/02/01 Douglas Elder	Initial implementation
	 							Although variables that are CAPITALIZED
								are usually "constant's", these variables
								are quasi-constants, since they rarely change,
								but they are initialized from values stored
								in an Oracle table.  Some values are returned
								via functions, since they are dependent on
								the value of other variables.
     */

	CONDEMN_AVG					amd_national_stock_items.condemn_avg%type := null ;
	CONSUMABLE					constant amd_national_stock_items.item_type%type := 'C' ;
	DELETE_ACTION				constant amd_spare_parts.action_code%type := 'D' ;
	DISPOSAL_COST				amd_spare_parts.disposal_cost%type := null ;
	DISTRIB_UOM					amd_national_stock_items.distrib_uom%type := null ;
	INSERT_ACTION				constant amd_spare_parts.action_code%type := 'A' ;
	NOT_PRIME_PART				constant amd_nsi_parts.prime_ind%type  := 'N' ;
	NRTS_AVG					amd_national_stock_items.nrts_avg%type := null ;

	OFF_BASE_TURN_AROUND		amd_part_locs.time_to_repair%type := null ;
	function GetOrderLeadTime(pItem_type in amd_national_stock_items.item_type%type) return  amd_spare_parts.order_lead_time_defaulted%type ;
	ORDER_QUANTITY				amd_national_stock_items.order_quantity%type := null ;

	ORDER_UOM					amd_spare_parts.order_uom%type := null ;
	PRIME_PART					constant amd_nsi_parts.prime_ind%type  := 'Y' ;

	QPEI_WEIGHTED				amd_national_stock_items.qpei_weighted%type := null ;
	REPAIRABLE					constant amd_national_stock_items.item_type%type := 'R' ;
	RTS_AVG						amd_national_stock_items.rts_avg%type := null ;
	SCRAP_VALUE					amd_spare_parts.scrap_value%type := null ;
    SHELF_LIFE					amd_spare_parts.shelf_life%type := null ;


	TIME_TO_REPAIR_ON_BASE_AVG	amd_national_stock_items.time_to_repair_on_base_avg_df%type := null ;

	function GetUnitCost(
		pNsn in amd_spare_parts.nsn%type,
		pPart_no in amd_spare_parts.part_no%type,
		pMfgr in amd_spare_parts.mfgr%type,
		pSmr_code in amd_national_stock_items.smr_code%type,
		pPlanner_code in amd_national_stock_items.planner_code%type) return amd_spare_parts.unit_cost_defaulted%type ;

	UNIT_VOLUME					amd_spare_parts.unit_volume%type := null ;
	UPDATE_ACTION				constant amd_spare_parts.action_code%type := 'C' ;
	USE_BSSM_TO_GET_NSLs		varchar2(1) := null ;

	COST_TO_REPAIR_ONBASE amd_part_locs.cost_to_repair%type := null;
	TIME_TO_REPAIR_ONBASE amd_part_locs.time_to_repair%type := null;
	TIME_TO_REPAIR_OFFBASE amd_part_locs.time_to_repair%type := null;
	UNIT_COST_FACTOR_OFFBASE number := 0;
end amd_defaults ;
/
CREATE OR REPLACE package body amd_defaults as

	/*
	  The order_lead_time_........ variables will be initialized by the
	  package body's 'begin' block.  This will happen the first time
	  the package is referenced.
	  */
	order_lead_time_consumable 			amd_spare_parts.order_lead_time_defaulted%type := null ;
	order_lead_time_repairable 			amd_spare_parts.order_lead_time_defaulted%type := null ;
	engine_part_reduction_factor 		number := null ;
	non_engine_part_reductn_factor		number := null ;
	consumable_reduction_factor			number := null ;

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

/*
 The following begin block is executed the first time this package is
 referenced.  It initialializes all the default variables from a table.
 The package will stay in memory until the application using it is finished.
 */
begin
	declare
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
	end ;
end amd_defaults ;
/

