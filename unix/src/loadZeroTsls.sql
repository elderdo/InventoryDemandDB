/*
      $Author:   zf297a  $
    $Revision:   1.2  $
        $Date:   13 Apr 2007 14:00:28  $
    $Workfile:   loadZeroTsls.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadZeroTsls.sql.-arc  $
/*   
/*      Rev 1.2   13 Apr 2007 14:00:28   zf297a
/*   removed loadZeroRslTsls
/*   
/*      Rev 1.1   12 Apr 2007 15:41:40   zf297a
/*   added invocation of amd_location_part_override_pkg.loadZeroRspTsls
/*   
/*      Rev 1.0   Dec 05 2006 15:24:54   zf297a
/*   Initial revision.
*/

set echo on
set termout on
set time on

prompt amd_location_part_override_pkg.LoadZeroTslA2A()
exec amd_location_part_override_pkg.LoadZeroTslA2A;
commit;

exit 0
