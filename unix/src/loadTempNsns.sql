/*
      $Author:   Douglas S. Elder
    $Revision:   1.1
        $Date:   Nov 21 2017
    $Workfile:   loadTempNsns.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadTempNsns.sql.-arc  $
/*   
/*      Rev 1.1   21 Nov 2017 DSE added set serveroutput
/*      Rev 1.0   20 May 2008 15:01:38   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on
set serveroutput on size unlimited

exec  amd_load.loadtempnsns;

exit 


