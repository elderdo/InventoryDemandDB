/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   15 Jul 2008 10:32:58  $
    $Workfile:   spo_import.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\spo_import.sql.-arc  $
/*   
/*      Rev 1.0   15 Jul 2008 10:32:58   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on
exec spoc17v2.pr_imp() ;


quit






