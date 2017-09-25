/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   19 Jun 2008 10:15:34  $
    $Workfile:   pr_imp.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\pr_imp.sql.-arc  $
/*   
/*      Rev 1.0   19 Jun 2008 10:15:34   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on
exec spoc17v2.pr_imp() ;


quit






