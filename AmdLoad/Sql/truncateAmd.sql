/*
      $Author:   zf297a  $
    $Revision:   1.2  $
        $Date:   23 May 2014
    $Workfile:   truncateAmd.sql  $
/*   
/*      Rev 1.1   24 Sep 2009 11:02:16   zf297a
/*   Thuy Pham added a truncate of amd_demands
/*   
/*      Rev 1.0   07 Jul 2008 23:20:52   zf297a
/*   Initial revision.
/*   
/*      Rev 1.2   Nov 02 2007 13:55:32   c402417
/*   Added truncate of tmp_a2a_part_alt.
/*   
/*      Rev 1.1   13 Aug 2007 10:17:32   zf297a
/*   Added PVCS keywords and added a truncate of tmp_amd_dmnd_frcst_consumables.
*/
--
-- SCCSID: AmdTruncate.sql  1.16  Modified: 12/15/05 13:09:08
--
-- Date      Who            Purpose
-- --------  -------------  --------------------------------------------------
-- 11/20/01  Fernando F.    Initial Implementation
-- 12/12/01  Fernando F.    Removed references to RSP_* and added references
--                          to AMD_ITEM_*.
-- 12/12/01  Fernando F.    Added amd_flight_stats to truncate.
-- 04/03/02  Fernando F.    Amd_l67_tmp has been dropped. Removed.
-- 06/06/02  Fernando F.    Removed references to AMD_ITEM_*.
-- 12/18/02  Fernando F.    Removed amd_in_transits_fk02.
-- 07/29/04  Thuy Pham	    Added tmp_amd_on_order, tmp_a2a_on_order, 
--			    tmp_a2a_parts to truncate.
-- 11/23/05  Thuy Pham	    Removed truncate amd_demands,amd_on_hand_invs,
--			    amd_in_repair,amd_on_order,amd_in_transits.
--			    From Amd1.8 we use the diff algorithm on these tables.
-- 12/05/05  T Pham	    Added tmp_a2a_bom_detail to truncate .
-- 12/05/05  T Pham	    Removed truncate amd_part_loc_forecasts .
-- 12/09/05  T Pham         Added tmp_a2a_ext_forecast to truncate .
-- 12/15/05  T Pham	    Added tmp_a2a_org_flight_acty & tmp_a2a_org_flight_acty_frecst to truncate .
-- 12/15/05  T Pham	    Added tmp_a2a_part_effectivity to truncate.
-- 12/15/05  T Pham	    Added tmp_a2a_spo_users and  tmp_a2a_site_resp_asset_mgr to truncate.
-- 05/23/14  D Elder	    removed all truncates of a2a tables that are no longer used
--
--
set echo on
set termout on
set time on

prompt Disabling Constraints
exec amd_owner.mta_disable_constraint('amd_part_loc_time_periods','amd_part_loc_time_periods_fk01');
exec amd_owner.mta_disable_constraint('amd_part_locs','amd_part_locs_fk01');
exec amd_owner.mta_disable_constraint('amd_part_locs','amd_part_locs_fk02');
exec amd_owner.mta_disable_constraint('amd_maint_task_distribs','amd_maint_task_distribs_fk01');
exec amd_owner.mta_disable_constraint('amd_bods','amd_bods_fk02');
exec amd_owner.mta_disable_constraint('amd_part_next_assemblies','amd_part_next_assemblies_fk01');
exec amd_owner.mta_disable_constraint('amd_demands','amd_demands_fk01');
exec amd_owner.mta_disable_constraint('amd_demands','amd_demands_fk02');
exec amd_owner.mta_disable_constraint('amd_demands','amd_demands_pk');


prompt Truncating Tables
exec amd_owner.mta_truncate_table('tmp_amd_demands','reuse storage');
exec amd_owner.mta_truncate_table('amd_demands','reuse storage');
exec amd_owner.mta_truncate_table('tmp_amd_part_locs','reuse storage');
exec amd_owner.mta_truncate_table('tmp_amd_spare_parts','reuse storage');
exec amd_owner.mta_truncate_table('tmp_lcf_icp','reuse storage');
exec amd_owner.mta_truncate_table('amd_bssm_source','reuse storage');
exec amd_owner.mta_truncate_table('amd_maint_task_distribs','reuse storage');
exec amd_owner.mta_truncate_table('amd_part_loc_time_periods','reuse storage');
exec amd_owner.mta_truncate_table('amd_flight_stats','reuse storage');
exec amd_owner.mta_truncate_table('tmp_amd_dmnd_frcst_consumables','reuse storage');


prompt Enabling Constraints
exec amd_owner.mta_enable_constraint('amd_part_loc_time_periods','amd_part_loc_time_periods_fk01');
exec amd_owner.mta_enable_constraint('amd_part_locs','amd_part_locs_fk01');
exec amd_owner.mta_enable_constraint('amd_part_locs','amd_part_locs_fk02');
exec amd_owner.mta_enable_constraint('amd_maint_task_distribs','amd_maint_task_distribs_fk01');
exec amd_owner.mta_enable_constraint('amd_bods','amd_bods_fk02');
exec amd_owner.mta_enable_constraint('amd_part_next_assemblies','amd_part_next_assemblies_fk01');
exec amd_owner.mta_enable_constraint('amd_demands','amd_demands_fk01');
exec amd_owner.mta_enable_constraint('amd_demands','amd_demands_fk02');
exec amd_owner.mta_enable_constraint('amd_demands','amd_demands_pk');

quit
