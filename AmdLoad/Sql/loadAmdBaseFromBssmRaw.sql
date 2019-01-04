/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   19 Jun 2008 10:04:12  $
    $Workfile:   loadAmdBaseFromBssmRaw.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadAmdBaseFromBssmRaw.sql.-arc  $
/*   
/*      Rev 1.0   19 Jun 2008 10:04:12   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec  amd_from_bssm_pkg.LoadAmdBaseFromBssmRaw;

exit 




