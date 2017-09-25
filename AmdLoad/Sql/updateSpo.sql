/*
	$Author:   zf297a  $
      $Revision:   1.2  $
          $Date:   06 Apr 2007 13:17:02  $
      $Workfile:   updateSpo.sql  $
           $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\updateSpo.sql.-arc  $
/*   
/*      Rev 1.2   06 Apr 2007 13:17:02   zf297a
/*   Added exit 0 instead of quit
/*   
/*      Rev 1.1   07 Feb 2007 11:34:40   zf297a
/*   Added sqlplus set's, prompt and quit commands
/*   
/*      Rev 1.0   07 Feb 2007 10:13:20   zf297a
/*   Initial revision.
*/

set echo on
set termout on
set time on

prompt spoc17v2.pr_imp() ;
exec spoc17v2.pr_imp() ;
commit ;

exit 0
