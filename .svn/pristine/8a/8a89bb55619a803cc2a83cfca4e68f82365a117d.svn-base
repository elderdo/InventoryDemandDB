/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   20 Oct 2016
 $
/*
/*      Rev 1.0   19 Jun 2008 10:27:16   zf297a
/*      Rev 1.1   20 Oct 2016 zf297a added serveroutput
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set serveroutput on size 100000

set time on
set timing on
set echo on

exec  amd_demand.load_amd_demands_table ;

exit

