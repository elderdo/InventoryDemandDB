DROP PACKAGE AMD_OWNER.AMD_BASIC_DEFAULT_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.amd_basic_default_pkg as
/*
      $Author:   zf297a  $
    $Revision:   1.1  $
     $Date:   Dec 01 2005 09:27:36  $
    $Workfile:   amd_basic_default_pkg.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_basic_default_pkg.pks-arc  $
/*
/*      Rev 1.1   Dec 01 2005 09:27:36   zf297a
/*   added pvcs keywords
*/

--
-- SCCSID: amd_basic_default_pkg.sql  1.2  Modified: 08/14/02 14:10:23
--
---------------------------------------------------------------
--  Date			By		History
--  ----                        --              ------
--  08/09/02			TP	Initial Implementation
--
--------------------------------------------------------------
	procedure setGroup(pNsiSid number);
	procedure setAllGroups ;

end amd_basic_default_pkg ;
 
/


DROP PUBLIC SYNONYM AMD_BASIC_DEFAULT_PKG;

CREATE PUBLIC SYNONYM AMD_BASIC_DEFAULT_PKG FOR AMD_OWNER.AMD_BASIC_DEFAULT_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_BASIC_DEFAULT_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_BASIC_DEFAULT_PKG TO AMD_WRITER_ROLE;
