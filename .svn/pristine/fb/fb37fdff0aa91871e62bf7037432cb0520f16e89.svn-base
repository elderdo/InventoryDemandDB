CREATE OR REPLACE PACKAGE BODY "AMD_VALIDATION_PKG"    AS
/*
      $Author:   zf297a  $
    $Revision:   1.4  $
     $Date:   Dec 06 2005 10:45:32  $
    $Workfile:   amd_validation_pkg.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_validation_pkg.pkb-arc  $
   
      Rev 1.4   Dec 06 2005 10:45:32   zf297a
   Fixed display of sysdate in errorMsg - changed to MM/DD/YYYY HH:MM:SS
   
      Rev 1.3   Dec 01 2005 09:50:48   zf297a
   added pvcs keywords
*/

		FUNCTION ErrorMsg(pTableName IN VARCHAR2, pMsg IN VARCHAR2, rc IN NUMBER, data IN VARCHAR2) RETURN NUMBER IS
		BEGIN
		ROLLBACK ;
		Amd_Utils.InsertErrorMsg(
			Amd_Utils.GetLoadNo(pSourceName => 'Validation', pTableName => pTableName),
			1,
			'amd_validation_pkg',
			data, NULL, NULL, TO_CHAR(rc),to_char(sysdate,'MM/DD/YYYY HH:MM:SS'), pMsg);
		COMMIT ;
		RETURN rc ;
		END ErrorMsg ;

	FUNCTION IsValidUomCode(pUom_code AMD_UOMS.uom_code%TYPE) RETURN BOOLEAN IS
		uom_code AMD_UOMS.uom_code%TYPE := NULL ;
	BEGIN
		SELECT uom_code INTO uom_code
		FROM AMD_UOMS
		WHERE uom_code = pUom_code ;
		RETURN TRUE ;
	EXCEPTION WHEN NO_DATA_FOUND THEN
		RETURN FALSE ;
	END IsValidUomCode ;

	FUNCTION IsValidPlannerCode(pPlanner_code AMD_PLANNERS.planner_code%TYPE) RETURN BOOLEAN IS
		planner_code AMD_PLANNERS.planner_code%TYPE := NULL ;
	BEGIN
		SELECT planner_code INTO planner_code
		FROM AMD_PLANNERS
		WHERE planner_code = pPlanner_code ;
		RETURN TRUE ;
	EXCEPTION WHEN NO_DATA_FOUND THEN
		RETURN FALSE ;
	END IsValidPlannerCode ;

    FUNCTION AddPlannerCode(pPlanner_code AMD_PLANNERS.planner_code%TYPE ) RETURN NUMBER IS
	BEGIN
		INSERT INTO AMD_PLANNERS
		(planner_code, action_code, last_update_dt)
		VALUES (pPlanner_code, Amd_Defaults.INSERT_ACTION, SYSDATE ) ;
		RETURN Amd_Validation_Pkg.SUCCESS ;
	EXCEPTION WHEN OTHERS THEN
		RETURN ErrorMsg('amd_planners', 'sqlcode=' || SQLCODE || ' sqlerrm=' || SQLERRM,
			Amd_Validation_Pkg.INSERT_PLANNER_CODE_ERR, pPlanner_code ) ;
	END AddPlannerCode ;

    FUNCTION AddUomCode(pUom_code AMD_UOMS.uom_code%TYPE ) RETURN NUMBER IS
	BEGIN
		INSERT INTO AMD_UOMS
		(uom_code, uom_term)
		VALUES (pUom_code, pUom_code ) ;
		RETURN Amd_Validation_Pkg.SUCCESS ;
	EXCEPTION WHEN OTHERS THEN
		RETURN ErrorMsg('amd_uoms', 'sqlcode=' || SQLCODE || ' sqlerrm=' || SQLERRM,
			Amd_Validation_Pkg.INSERT_UOM_ERR, pUom_code ) ;
	END AddUomCode ;

	FUNCTION GetTacticalInd(pUnit_cost IN AMD_SPARE_PARTS.unit_cost%TYPE, pSmr_code IN AMD_NATIONAL_STOCK_ITEMS.smr_code%TYPE) RETURN AMD_SPARE_PARTS.tactical%TYPE IS
	BEGIN
		IF pUnit_cost IS NOT NULL AND pSmr_code IS NOT NULL THEN
			RETURN 'Y' ;
		ELSE
			RETURN 'N' ;
		END IF ;
	END GetTacticalInd ;

END Amd_Validation_Pkg ;
/
