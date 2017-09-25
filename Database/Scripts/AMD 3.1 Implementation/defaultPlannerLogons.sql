/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   09 Jul 2008 16:02:24  $
    $Workfile:   defaultPlannerLogons.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Scripts\AMD 3.1 Implementation\defaultPlannerLogons.sql.-arc  $
/*   
/*      Rev 1.0   09 Jul 2008 16:02:24   zf297a
/*   Initial revision.

*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set echo on
set time on
set timing on

spool defaultPlannerLogons.txt

exec amd_defaults.addParamKey('consumable_planner_code','This is the default planner code for a consumable part.') ;
exec amd_defaults.setParamValue('consumable_planner_code','UNC') ;
exec amd_defaults.addParamKey('consumable_logon_id','This is the default bems id for a consumable part.') ;
select last_name, first_name,deptno,stable_email from amd_people_all_v where bems_id  = 1671850 ;
exec amd_defaults.setParamValue('consumable_logon_id','1671850') ;
exec amd_defaults.addParamKey('repairable_planner_code','This is the default planner code for a repairable part.') ;
exec amd_defaults.setParamValue('repairable_planner_code','UNR') ;
exec amd_defaults.addParamKey('repairable_logon_id','This is the default bems id for a repairable part.') ;
select last_name, first_name,deptno,stable_email from amd_people_all_v where bems_id = 0324366 ;
exec amd_defaults.setParamValue('repairable_logon_id','0324366') ;

spool off

quit
