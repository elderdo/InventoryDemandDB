/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   31 Jul 2012
 $
/*
/*      Rev 1.0   19 Jun 2008 10:27:16   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec  amd_demand.load_amd_demands_table ;

exit

