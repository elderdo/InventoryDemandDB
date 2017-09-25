/*
	$Author:   zf297a  $
      $Revision:   1.0  $
          $Date:   06 May 2008 11:06:12  $
      $Workfile:   loadLocPartOverride.sql  $
           $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Sql\loadLocPartOverride.sql.-arc  $
/*   
/*      Rev 1.0   06 May 2008 11:06:12   zf297a
/*   Initial revision.

	This script does a complete reload of amd_location_part_override
	and amd_locpart_overid_consumables and also generates all the A2A
	transactions.
*/

set time on
set timing on
set feedback on
set term on
set echo on

exec amd_location_part_override_pkg.loadInitial ;

exec amd_lp_override_consumabl_pkg.initialize ;

quit
