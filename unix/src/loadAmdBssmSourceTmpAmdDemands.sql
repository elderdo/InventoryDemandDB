/*
      $Author:   Douglas S. Elder
    $Revision:   1.1  $
        $Date:   17 May 2017
/*   
	
/*      Rev 1.1   17 May 2017 DSE added select of counts for tables updated by this procedure
/*      Rev 1.0   31 Jul 2012
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

prompt rows in amd_bssm_source ;
select count(*) from amd_bssm_source where action_code <> 'D' 

and trunc(last_update_dt) = trunc(sysdate) ;
exec   amd_owner.mta_truncate_table('tmp_amd_demands','reuse storage');
exec   amd_demand.loadAmdBssmSourceTmpAmdDemands ;

prompt rows in tmp_amd_demands
select count(*) from tmp_amd_demands ;

prompt rows in tmp_lcf_1
select count(*) from tmp_lcf_1 ;

prompt rows in tmp_lcf_icp
select count(*) from tmp_lcf_icp ;

prompt rows inserted to amd_bssm_source ;
select count(*) from amd_bssm_source where action_code = 'A' 
and trunc(last_update_dt) = trunc(sysdate) ;

prompt rows updated for amd_bssm_source ;
select count(*) from amd_bssm_source where action_code = 'U' 
and trunc(last_update_dt) = trunc(sysdate) ;

prompt rows marked deleted for amd_bssm_source ;
select count(*) from amd_bssm_source where action_code = 'D' 
and trunc(last_update_dt) = trunc(sysdate) ;
exit 




