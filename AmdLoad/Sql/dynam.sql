/*
	  $Author:   zf297a  $
	$Revision:   1.0  $
	    $Date:   28 Feb 2007 13:14:48  $
	$Workfile:   dynam.sql  $
	     $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\dynam.sql.-arc  $
/*   
/*      Rev 1.0   28 Feb 2007 13:14:48   zf297a
/*   Initial revision.
*/

prompt exec amd_location_part_override_pkg.loadAllA2A(false) ;
exec amd_location_part_override_pkg.loadAllA2A(false) ;

commit ;
quit
