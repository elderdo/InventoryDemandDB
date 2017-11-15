/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   20 May 2008 14:30:50  $
    $Workfile:   loadMain.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadMain.sql.-arc  $
/*   
/*      Rev 1.0   20 May 2008 14:30:50   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on
set serveroutput on size unlimited

exec amd_load.loadmain;

exit 
