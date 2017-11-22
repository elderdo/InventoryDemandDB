/*
      $Author:   c402417  $
    $Revision:   1.2  $
        $Date:   Jan 30 2007 09:52:10  $
    $Workfile:   AmdLoad2.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\AmdLoad2.sql.-arc  $
/*   
/*      Rev 1.2   Jan 30 2007 09:52:10   c402417
/*   Add exec amd_load.LoadRblPairs.
/*   
/*      Rev 1.1   Jul 21 2006 12:24:02   zf297a
/*   Fixed prompt statements to match exec statements
/*   
/*      Rev 1.0   Jan 17 2006 08:10:34   zf297a
/*   Loads amd tables
*/
--
-- SCCSID: AmdLoad2.sql  1.12  Modified: 09/24/04 08:42:27
--
-- Date      By   History
-- 11/21/01  FF   Mod order.
-- 12/11/01  FF   Added AmdDpPkg.
-- 12/11/01  FF   Added amd_reqs_pkg.LoadAmdReqs.
-- 08/09/02  TP   Added amd_basic_default_pkg.
-- 08/28/02  FF   Removed amd_basic_default_pkg.
-- 03/18/03  TP   Added insert statements to populate data into table amd_in_transits.
-- 10/20/03  TP   Removed ProcessFlightData.
-- 09/23/04  TP   Moved populate data into table amd_in_transits to amd_inventory.pkg.
-- 06/24/05  DE   Added amd_spare_parts_pkg.load_CurrentbackOrder, amd_load.LoadTempNsns,
--		    amd_spare_networks_pkg.auto_load_spare_networks.
-- 05/01/05  DH   Added amd_load.LoadAmdDemands, LoadBascUkDemands.
-- 08/10/05  KS   Added amd_partprime_pkg, amd_part_loc_forecasts_pkg, amd_part_factor_pkg.
--

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE


set echo on
set time on
set timing on
set serveroutput on size UNLIMITED


prompt amd_part_loc_forecasts_pkg.LoadLatestRblRun()
exec amd_part_loc_forecasts_pkg.LoadLatestRblRun;
commit;


prompt amd_spare_parts_pkg.loadCurrentBackOrder()
exec amd_spare_parts_pkg.loadCurrentBackOrder;
commit;

prompt amd_load.LoadTempNsns()
exec amd_load.loadtempnsns;
commit;

prompt amd_spare_networks_pkg.auto_load_spare_networks()
exec amd_spare_networks_pkg.auto_load_spare_networks;
commit;

prompt amd_demand.loadAmdBssmSourceTmpAmdemands()
exec amd_demand.loadamddemands;
commit;

prompt amd_demand.LoadBascUkDemands()
exec amd_demand.loadBascUkdemands;
commit;

prompt amd_demand.amd_demand_a2a()
exec amd_demand.amd_demand_a2a;
commit;

prompt amd_inventory.LoadGoldInventory()
exec amd_inventory.loadGoldInventory;
commit;


prompt amd_part_locs_load_pkg.LoadAmdPartLocations()
exec amd_part_locs_load_pkg.LoadAmdPartLocations;
commit;

prompt amd_from_bssm_pkg.LoadAmdBaseFromBssmRaw()
exec amd_from_bssm_pkg.LoadAmdBaseFromBssmRaw;
commit;

prompt amd_cleaned_from_bssm_pkg.UpdateAmdAllBaseCleaned()
exec amd_cleaned_from_bssm_pkg.UpdateAmdAllBaseCleaned;
commit;
	

prompt amd_reqs_pkg.LoadAmdReqs()
exec amd_reqs_pkg.LoadAmdReqs;
commit;

prompt amd_part_factors_pkg.LoadTmpAmdPartFactors()
exec amd_part_factors_pkg.LoadTmpAmdPartFactors;
commit;

prompt amd_part_factors_pkg.ProcessA2AVirtualLocs()
exec amd_part_factors_pkg.ProcessA2AVirtualLocs;
commit;


prompt amd_part_loc_forecasts_pkg.LoadTmpAmdPartLocForecasts_Add()
exec amd_part_loc_forecasts_pkg.LoadTmpAmdPartLocForecasts_Add;
commit;

prompt amd_location_part_leadtime_pkg.LoadTmpAmdLocPartLeadtime()
exec amd_location_part_leadtime_pkg.LoadTmpAmdLocPartLeadtime;
commit;

quit
