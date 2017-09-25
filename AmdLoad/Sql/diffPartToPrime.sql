/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   25 Sep 2008 10:34:26  $
    $Workfile:   diffPartToPrime.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\diffPartToPrime.sql.-arc  $
/*   
/*      Rev 1.1   25 Sep 2008 10:34:26   zf297a
/*   Added invocation of amd_partPrime_pkg.updataeSpoPrimePart
/*   
/*      Rev 1.0   15 Jul 2008 10:32:56   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec  amd_partprime_pkg.DiffPartToPrime ;
exec  amd_partprime_pkg.updateSpoPrimePart ;

exit 









