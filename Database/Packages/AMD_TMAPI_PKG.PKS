DROP PACKAGE AMD_OWNER.AMD_TMAPI_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.amd_tmapi_pkg as
/*
      $Author:   zf297a  $
    $Revision:   1.2  $
     $Date:   Dec 01 2005 09:48:18  $
    $Workfile:   amd_tmapi_pkg.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_TMAPI_PKG.PKS-arc  $

      Rev 1.2   Dec 01 2005 09:48:18   zf297a
   added pvcs keywords
*/
	   -------------------------------------------------------------------
	   --  Date	  		  By			History
	   --  ----			  --			-------
	   --  12/03/01		  ks			initial implementation
	   -------------------------------------------------------------------

	   -- when need extra help for sql queries for tmapi

	function GetPriority(pNsn amd_spare_parts.nsn%type, pPartNo amd_spare_parts.part_no%type) return number;
	pragma restrict_references(DEFAULT,WNDS) ;
end amd_tmapi_pkg;
 
/


DROP PUBLIC SYNONYM AMD_TMAPI_PKG;

CREATE PUBLIC SYNONYM AMD_TMAPI_PKG FOR AMD_OWNER.AMD_TMAPI_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_TMAPI_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_TMAPI_PKG TO AMD_WRITER_ROLE;
