DROP PACKAGE AMD_OWNER.AMD_WARNINGS_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.amd_warnings_pkg as
/*
      $Author:   zf297a  $
    $Revision:   1.3  $
     $Date:   30 Jan 2009 09:11:10  $
    $Workfile:   amd_warnings_pkg.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_warnings_pkg.pks.-arc  $
/*
/*      Rev 1.3   30 Jan 2009 09:11:10   zf297a
/*   Add t_array binary indexed array type and the split function interface to split a string into a t_array.
/*
/*      Rev 1.2   29 Jan 2009 15:05:28   zf297a
/*   Added args to sendWarnings with default values.  Added a function sendWarnings that returns the number of warnings for the current batch job.
/*
/*      Rev 1.1   16 Jan 2009 23:25:12   zf297a
/*   Added interface for procedure insertWarningMsg
/*
/*      Rev 1.0   16 Jan 2009 10:56:44   zf297a
/*   Initial revision.

    This package is used to compile warnings during a batch load of AMD.
*/

	TYPE t_array IS TABLE OF VARCHAR2(255)
		INDEX BY BINARY_INTEGER;

	FUNCTION SPLIT (p_in_string VARCHAR2, p_delim VARCHAR2) RETURN t_array;
	procedure addWarnings(warning in varchar2);
	function warningsExistForCurJob return boolean ;
	function warningsExistForCurJobYorN return varchar2 ;

	procedure sendWarnings(toEmailAddr in varchar2,
		subject in varchar2 := 'AMD Load Warnings',
		fromEmailAddr in varchar2 := 'AMDLOAD') ;

	/* do the same thing as sendWarnings and return
	 * the number of messages sent - zero means nothing was sent
	 */
	function sendWarnings(toEmailAddr in varchar2,
		subject in varchar2 := 'AMD Load Warnings',
		fromEmailAddr in varchar2 := 'AMDLOAD') return number ;

	procedure insertWarningMsg (
		pData_line_no IN amd_load_warnings.data_line_no%TYPE := NULL,
		pData_line IN amd_load_warnings.data_line%TYPE := NULL,
		pKey_1 IN amd_load_warnings.key_1%TYPE := NULL,
		pKey_2 IN amd_load_warnings.key_2%TYPE := NULL,
		pKey_3 IN amd_load_warnings.key_3%TYPE := NULL,
		pKey_4 IN amd_load_warnings.key_4%TYPE := NULL,
		pKey_5 IN amd_load_warnings.key_5%TYPE := NULL,
		pWarning IN amd_load_warnings.warning%TYPE := NULL ) ;


end amd_warnings_pkg ;
 
/


DROP PUBLIC SYNONYM AMD_WARNINGS_PKG;

CREATE PUBLIC SYNONYM AMD_WARNINGS_PKG FOR AMD_OWNER.AMD_WARNINGS_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_WARNINGS_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_WARNINGS_PKG TO AMD_WRITER_ROLE;
