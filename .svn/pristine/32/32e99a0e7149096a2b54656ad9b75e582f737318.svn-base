/*

    $Author:   c402417  $
    $Revision:   1.1  $
        $Date:   17 May 2017
    $Workfile:   loadFmsDemands.sql  $
/*
/*      Rev 1.1   17 May 2017 added set serveroutput
 *                            and select counts  
/*      Rev 1.0   1 Mar 2010  
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

exec   amd_demand.loadFmsdemands;
j
select count(*) from amd_bssm_source ;
select count(*) from tmp_amd_demands ;

exit

