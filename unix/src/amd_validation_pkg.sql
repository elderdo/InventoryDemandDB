CREATE OR REPLACE package amd_validation_pkg as
    /*
     	10/01/01 Douglas Elder and Chung Lu  Initial implementation
     */

	SUCCESS					constant number := 0 ;
	FAILURE					constant number := 3 ;
	INSERT_PLANNER_CODE_ERR	constant number := 6 ;
	INSERT_UOM_ERR			constant number := 9 ;

	/* return SUCCESS if planner_code exists in amd_planners
		and return FAILURE if it does not.
	*/
	function IsValidUomCode(pUom_code amd_uoms.uom_code%type) return boolean ;

	/* return SUCCESS if planner_code exists in amd_planners
		and return FAILURE if it does not.
	*/
	function IsValidPlannerCode(pPlanner_code amd_planners.planner_code%type) return boolean ;

	/* return SUCCESS if planner_code is added to amd_planners
		and return FAILURE if it is not.
	*/
    function AddUomCode(pUom_code amd_uoms.uom_code%type ) return number ;
	/* return SUCCESS if planner_code is added to amd_planners
		and return FAILURE if it is not.
	*/
    function AddPlannerCode(pPlanner_code amd_planners.planner_code%type ) return number ;

	/* return Y if the unit_cost and smr_code are not null, else return N */
    function GetTacticalInd(pUnit_cost in amd_spare_parts.unit_cost%type, pSmr_code in amd_national_stock_items.smr_code%type) return amd_spare_parts.tactical%type ;
end amd_validation_pkg ;
/
CREATE OR REPLACE package body amd_validation_pkg as

		function ErrorMsg(pTableName in varchar2, pMsg in varchar2, rc in number, data in varchar2) return number is
		begin
		rollback ;
		amd_utils.InsertErrorMsg(
			amd_utils.GetLoadNo(pSourceName => 'Validation', pTableName => pTableName),
			1,
			'amd_validation_pkg',
			data, null, null, null, to_char(rc), pMsg);
		commit ;
		return rc ;
		end ErrorMsg ;

	function IsValidUomCode(pUom_code amd_uoms.uom_code%type) return boolean is
		uom_code amd_uoms.uom_code%type := null ;
	begin
		select uom_code into uom_code
		from amd_uoms
		where uom_code = pUom_code ;
		return true ;
	exception when NO_DATA_FOUND then
		return false ;
	end IsValidUomCode ;

	function IsValidPlannerCode(pPlanner_code amd_planners.planner_code%type) return boolean is
		planner_code amd_planners.planner_code%type := null ;
	begin
		select planner_code into planner_code
		from amd_planners
		where planner_code = pPlanner_code ;
		return true ;
	exception when NO_DATA_FOUND then
		return false ;
	end IsValidPlannerCode ;

    function AddPlannerCode(pPlanner_code amd_planners.planner_code%type ) return number is
	begin
		insert into amd_planners
		(planner_code, action_code, last_update_dt)
		values (pPlanner_code, amd_defaults.INSERT_ACTION, sysdate ) ;
		return amd_validation_pkg.SUCCESS ;
	exception when others then
		return ErrorMsg('amd_planners', 'sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm,
			amd_validation_pkg.INSERT_PLANNER_CODE_ERR, pPlanner_code ) ;
	end AddPlannerCode ;

    function AddUomCode(pUom_code amd_uoms.uom_code%type ) return number is
	begin
		insert into amd_uoms
		(uom_code, uom_term)
		values (pUom_code, pUom_code ) ;
		return amd_validation_pkg.SUCCESS ;
	exception when others then
		return ErrorMsg('amd_uoms', 'sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm,
			amd_validation_pkg.INSERT_UOM_ERR, pUom_code ) ;
	end AddUomCode ;

	function GetTacticalInd(pUnit_cost in amd_spare_parts.unit_cost%type, pSmr_code in amd_national_stock_items.smr_code%type) return amd_spare_parts.tactical%type is
	begin
		if pUnit_cost is not null and pSmr_code is not null then
			return 'Y' ;
		else
			return 'N' ;
		end if ;
	end GetTacticalInd ;

end amd_validation_pkg ;
/