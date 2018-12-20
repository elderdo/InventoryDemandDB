DROP PACKAGE AMD_OWNER.USER_PLANNER_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.USER_PLANNER_PKG AS

 /*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   01 Dec 2008 12:05:46  $
    $Workfile:   USER_PLANNER_PKG.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\USER_PLANNER_PKG.pks.-arc  $
/*
/*      Rev 1.1   01 Dec 2008 12:05:46   zf297a
/*   Planner_code was removed from amd_site_asset_mgr.
/*
/*      Rev 1.0   02 Oct 2008 14:22:20   zf297a
/*   Initial revision.
*/
    ACTIVE_STATUS constant varchar2(1)  := 'A' ;
    DUPLICATE constant number := 4 ;
    INVALID_ACTION_CODE constant number := 8 ;
    INVALID_BEMS_ID constant number := 12 ;
    INVALID_PLANNER_CODE constant number := 16 ;
    SUCCESS constant number := 0 ;
    return_code number ;

    function isValidPlannerCode(planner_code in amd_planners.planner_code%type) return boolean ;
    function isValidPlannerCodeYorN(planner_code in amd_planners.planner_code%type) return varchar2 ;

    function isValidBemsId(bems_id in amd_people_all_v.bems_id%type) return boolean ;
    function isValidBemsIdYorN(bems_id in amd_people_all_v.bems_id%type) return varchar2 ;

    function insertAmdUse1Row(userid in amd_use1.userid%type,
                user_name in amd_use1.user_name%type,
                employee_no in amd_use1.employee_no%type,
                phone in amd_use1.phone%type,
                ims_designator_code in amd_use1.ims_designator_code%type,
                employee_status in amd_use1.employee_status%type) return number ;

    function insertUimsRow(userid in uims.userid%type,
                designator_code in uims.designator_code%type,
                alt_ims_des_code_b in uims.alt_ims_des_code_b%type,
                alt_es_des_code_b in uims.alt_es_des_code_b%type,
                alt_sup_des_code_b in uims.alt_sup_des_code_b%type) return number ;

   function insertSiteAssetMgr(bems_id in amd_site_asset_mgr.bems_id%type) return number ;

   function deleteSiteAssetMgr(bems_id in amd_site_asset_mgr.bems_id%type) return number ;

    procedure version ;

    function getVersion return varchar2 ;


END USER_PLANNER_PKG ;
 
/


DROP PUBLIC SYNONYM USER_PLANNER_PKG;

CREATE PUBLIC SYNONYM USER_PLANNER_PKG FOR AMD_OWNER.USER_PLANNER_PKG;


GRANT EXECUTE ON AMD_OWNER.USER_PLANNER_PKG TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.USER_PLANNER_PKG TO BSRM_LOADER;
