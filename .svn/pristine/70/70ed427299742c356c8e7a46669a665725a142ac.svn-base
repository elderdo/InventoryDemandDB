/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   19 Jun 2008 10:24:26  $
    $Workfile:   sendPartInfo.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\sendPartInfo.sql.-arc  $
/*   
/*      Rev 1.1   19 Jun 2008 10:24:26   zf297a
/*   added whenever commands and timing
/*   
/*      Rev 1.0   16 May 2008 17:42:32   zf297a
/*   Initial revision.
*/
	
whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on


var rc number ;

exec :rc := a2a_pkg.initA2APartInfo ;

quit
