/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   2 Oct 2015
    $Workfile:   loadPsms.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadPsms.sql.-arc  $
/*   
/*      Rev 1.0   20 May 2008 14:30:52   zf297a
/*      Rev 1.1   2 Oct 2015 added alter session to prevent ora-02085 error
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

alter session set global_names=false;

exec amd_load.loadpsms;

exit 
