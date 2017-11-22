/*
      $Author:   Douglas S Elder
    $Revision:   1.1
        $Date:   21 Nov 2017
 $
/*
/*      Rev 1.1   21 Nov 2017 DSE added set serveroutput
/*      Rev 1.0   19 Jun 2008 10:27:16   DSE
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on
set serveroutput on size unlimited

exec  amd_demand.load_amd_demands_table ;

exit

