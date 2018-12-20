DROP PACKAGE AMD_OWNER.AMD_DEFAULT_EFFECTIVITY_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.amd_default_effectivity_pkg as
    /*
       $Author:   c372701  $
     $Revision:   1.0  $
         $Date:   15 May 2002 08:18:28  $
     $Workfile:   amd_default_effectivity_pkg.pks  $
	      $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\Packages\amd_default_effectivity_pkg.pks-arc  $
/*
/*      Rev 1.0   15 May 2002 08:18:28   c372701
/*   Initial revision.

	  SCCSID:	amd_default_effectivity_pkg.sql	1.2	Modified: 05/15/02  10:20:46
		  */
	function NewGroup return number ;
	procedure SetNsiEffects(pNsiSid number) ;

end amd_default_effectivity_pkg ;
 
/


DROP PUBLIC SYNONYM AMD_DEFAULT_EFFECTIVITY_PKG;

CREATE PUBLIC SYNONYM AMD_DEFAULT_EFFECTIVITY_PKG FOR AMD_OWNER.AMD_DEFAULT_EFFECTIVITY_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_DEFAULT_EFFECTIVITY_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_DEFAULT_EFFECTIVITY_PKG TO AMD_WRITER_ROLE;
