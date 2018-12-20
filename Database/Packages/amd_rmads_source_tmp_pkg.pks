DROP PACKAGE AMD_OWNER.AMD_RMADS_SOURCE_TMP_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.amd_rmads_source_tmp_pkg as
/*
      $Author:   zf297a  $
    $Revision:   1.1  $
     $Date:   Dec 01 2005 09:46:34  $
    $Workfile:   amd_rmads_source_tmp_pkg.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_rmads_source_tmp_pkg.pks-arc  $
/*
/*      Rev 1.1   Dec 01 2005 09:46:34   zf297a
/*   Add pvcs keywords
*/

	procedure LoadRmadsIntoAnsi;

end amd_rmads_source_tmp_pkg;
 
/


DROP PUBLIC SYNONYM AMD_RMADS_SOURCE_TMP_PKG;

CREATE PUBLIC SYNONYM AMD_RMADS_SOURCE_TMP_PKG FOR AMD_OWNER.AMD_RMADS_SOURCE_TMP_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_RMADS_SOURCE_TMP_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_RMADS_SOURCE_TMP_PKG TO AMD_WRITER_ROLE;
