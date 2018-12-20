DROP PACKAGE AMD_OWNER.AMD_SPARE_NETWORKS_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.amd_spare_networks_pkg as
/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   Nov 30 2005 09:34:38  $
    $Workfile:   amd_spare_networks_pkg.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_spare_networks_pkg.pks-arc  $
/*
/*      Rev 1.1   Nov 30 2005 09:34:38   zf297a
/*   added pvcs keywords
*/

  PROCEDURE auto_load_spare_networks;
END amd_spare_networks_pkg;
 
/


DROP PUBLIC SYNONYM AMD_SPARE_NETWORKS_PKG;

CREATE PUBLIC SYNONYM AMD_SPARE_NETWORKS_PKG FOR AMD_OWNER.AMD_SPARE_NETWORKS_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_SPARE_NETWORKS_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_SPARE_NETWORKS_PKG TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_SPARE_NETWORKS_PKG TO BSRM_LOADER;
