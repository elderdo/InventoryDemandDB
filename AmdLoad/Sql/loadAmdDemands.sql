/*
      $Author:   Douglas S Elder
    $Revision:   1.1
        $Date:   21 Nov 2017
    $Workfile:   loadAmdDemands.sql  $
/*   
/*      Rev 1.1   21 Nov 2017 DSE added set serveroutput
/*      Rev 1.0   20 May 2008 15:01:38   DSE
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on
set serveroutput on size unlimited

exec   amd_demand.loadamddemands;

exit 




