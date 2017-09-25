/*

    $Author:   c402417  $
    $Revision:   1.0  $
        $Date:   1 Mar 2010  $
    $Workfile:   loadFmsDemands.sql  $
/*
/*      Rev 1.0   1 Mar 2010  
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec   amd_demand.loadFmsdemands;

@@amalyzeAmdBssmSource.sql
@@amalyzeTmpAmdDemands.sql

exit

