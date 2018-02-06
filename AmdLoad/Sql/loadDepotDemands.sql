/*
      $Author:   Douglas S. Elder
    $Revision:   1.2
        $Date:   05 Feb 2017
    $Workfile:   loadBascUkDemands.sql  $
/*   
/*      Rev 1.2   05 Feb 2018 renamed loadBascUkDemands related to TFS 52919
/*      Rev 1.1   17 May 2017 added set serveroutput
 *                            and select counts
/*      Rev 1.0   20 May 2008 15:01:38   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on
set serveroutput on size unlimited

select count(*) from tmp_amd_demands ;
select count(*) from amd_bssm_source ;

exec   amd_demand.loadDepotDemands ;;

select count(*) from tmp_amd_demands ;
select count(*) from amd_bssm_source ;

exit 





