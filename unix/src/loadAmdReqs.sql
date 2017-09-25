/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   19 Jun 2008 09:58:08  $
    $Workfile:   loadAmdReqs.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadAmdReqs.sql.-arc  $
/*   
/*      Rev 1.0   19 Jun 2008 09:58:08   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec  amd_reqs_pkg.LoadAmdReqs;

exit 






