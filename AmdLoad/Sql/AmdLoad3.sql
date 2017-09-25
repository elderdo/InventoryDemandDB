/*
      $Author:   zf297a  $
    $Revision:   1.2  $
        $Date:   18 Jul 2007 16:31:22  $
    $Workfile:   AmdLoad3.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\AmdLoad3.sql.-arc  $
/*   
/*      Rev 1.2   18 Jul 2007 16:31:22   zf297a
/*   Added invocation of amd_lp_override_consumabl_pkg.LoadLocPartOverrides to load the tmp_locpart_overid_consumables table for the LPOverrideConsumables diff.
/*   
/*      Rev 1.1   Dec 05 2006 15:26:06   zf297a
/*   Removed the invocation of amd_location_part_override_pkg.LoadZeroTslA2A since it should be performed after the diff for the amd_location_part_override table.
/*   
/*      Rev 1.0   Feb 17 2006 13:22:20   zf297a
/*   Latest Prod Version
*/
--
-- SCCSID: AmdLoad3.sql  1.2  Modified:  11/29/05  21:40:38
--
-- Date		By	History
-- 10/01/05	T Pham	Support AMD v1.8 .
-- 11/29/05	T Pham	Added amd_location_part_override_pkg.
--
--

set echo on
set termout on
set time on


prompt amd_inventory.UpdateSpoTotalInventory()
exec amd_inventory.UpdateSpoTotalInventory;
commit;

prompt amd_location_part_override_pkg.LoadTmpAmdLocPartOverride()
exec amd_location_part_override_pkg.LoadTmpAmdLocPartOverride;
commit;

-- load the tmp_locpart_overid_consumables table
prompt amd_lp_override_consumabl_pkg.LoadLocPartOverrides ;
exec amd_lp_override_consumabl_pkg.LoadLocPartOverrides ;
commit;

quit
