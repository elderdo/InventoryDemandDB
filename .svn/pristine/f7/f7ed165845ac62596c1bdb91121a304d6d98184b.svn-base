/*
      $Author:   zf297a  $
    $Revision:   1.2
        $Date:   17 May 2017
    $Workfile:   loadLatestRblRun.sql  $
/*   
/*      Rev 1.2   17 May 2017 added set serveroutput DSE
/*      Rev 1.1   04 Jul 2008 00:33:46   zf297a
/*   Fixed package name.
/*   
/*      Rev 1.0   20 May 2008 15:01:38   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on
set serveroutput on size unlimited

exec amd_part_loc_forecasts_pkg.LoadLatestRblRun;

exit 
