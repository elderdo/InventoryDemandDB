/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   04 Aug 2009 00:34:50  $
    $Workfile:   truncRblPairs.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\AmdLoad\Sql\truncRblPairs.sql.-arc  $
/*   
/*      Rev 1.0   04 Aug 2009 00:34:50   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec amd_owner.mta_truncate_table('amd_rbl_pairs','reuse storage') ;

exit 








