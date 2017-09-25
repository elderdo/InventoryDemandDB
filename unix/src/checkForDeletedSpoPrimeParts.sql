/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   13 Jun 2007 20:08:10  $
    $Workfile:   checkForDeletedSpoPrimeParts.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\checkForDeletedSpoPrimeParts.sql.-arc  $
/*   
/*      Rev 1.0   13 Jun 2007 20:08:10   zf297a
/*   Initial revision.
*/

set echo on
set termout on
set time on

prompt amd_location_part_override_pkg.checkForDeletedSpoPrimeParts()
exec amd_location_part_override_pkg.checkForDeletedSpoPrimeParts;
commit;

exit 0
