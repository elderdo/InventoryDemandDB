/*
      $Author:   Douglas S Elder
    $Revision:   1.1
        $Date:   21 Nov 2017
    $Workfile:   amdDemandA2A.sql  $
/*   
/*      Rev 1.1   21 Nov 2017 DSE added set serveroutput
/*      Rev 1.0   19 Jun 2008 10:27:16   Douglas S. Elder
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on
set serveroutput on size unlimited

exec  amd_demand.amd_demand_a2a;

exit 

