/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   20 May 2008 15:01:38  $
    $Workfile:   loadCurrentBackOrder.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadCurrentBackOrder.sql.-arc  $
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

exec amd_spare_parts_pkg.loadCurrentBackOrder;

exit 

