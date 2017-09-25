/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   Dec 22 2005 12:31:38  $
    $Workfile:   loadDemands.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Scripts\loadDemands.sql.-arc  $
/*   
/*      Rev 1.0   Dec 22 2005 12:31:38   zf297a
/*   Initial revision.
   
*/
begin
prompt Deleting demand tables
delete from amd_owner.amd_demands ;
commit ;
delete from amd_owner.tmp_amd_demands ;
commit ;
delete from amd_owner.tmp_a2a_demands ;
commit ;
delete amd_owner.tmp_lcf_icp ;
commit ;

prompt running amd_demand.loadamddemands
amd_owner.amd_demand.LoadAmdDemands;
commit ;

prompt running amd_demand.loadBascUkdemands
amd_owner.amd_demand.loadBascUkdemands;
commit;

prompt running amd_demand.amd_demand_a2a
amd_owner.amd_demand.amd_demand_a2a;
commit;

prompt demands loaded
end ;
/
