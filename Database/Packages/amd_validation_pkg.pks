DROP PACKAGE AMD_OWNER.AMD_VALIDATION_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.amd_validation_pkg as
/*
      $Author:   zf297a  $
    $Revision:   1.3  $
     $Date:   Dec 01 2005 09:50:48  $
    $Workfile:   amd_validation_pkg.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_validation_pkg.pks-arc  $

      Rev 1.3   Dec 01 2005 09:50:48   zf297a
   added pvcs keywords
*/
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


DROP PUBLIC SYNONYM AMD_VALIDATION_PKG;

CREATE PUBLIC SYNONYM AMD_VALIDATION_PKG FOR AMD_OWNER.AMD_VALIDATION_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_VALIDATION_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_VALIDATION_PKG TO AMD_WRITER_ROLE;
