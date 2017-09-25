 /*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   27 Apr 2007 12:47:20  $
    $Workfile:   project1.8.06.6.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Scripts\project1.8.06.6.sql.-arc  $
/*   
/*      Rev 1.0   27 Apr 2007 12:47:20   zf297a
/*   Initial revision.
*/

set define off

@@amd_in_transits_sum.sql

@@datasys_planner_v.sql

@@fixPKs.sql

@@amd_demands_idx.sql

@@ordv.sql

@@venn.sql

@@venc.sql

@@tmp1.sql

@@rsv1.sql

@@req1.sql

@@poi1.sql

@@cat1.sql

@@ord1.sql

@@fedc.sql

@@item.sql

-- define view of data systems's part table
@@datasys_part_v.sql

show errors

-- define view of data systems's transactions_processed table
@@datasys_trans_processed_v.sql


-- new key order #, order date, and line
@@amd_on_order.sql

show errors

-- define part_no as key for tmp_amd_spare_parts
@@tmp_amd_spare_parts.sql

show errors

-- redefine amd_sent_to_a2a_history
@@amd_sent_to_a2a_history.sql

show errors

-- table to record counts
@@amd_counts.sql

show errors

-- make ave_cap_lead_time bigger from number(3) to number(5) to the cat1 table
@@cat1.sql

show errors

-- drop this table since tmp_a2a_order_info_line now has all the data
@@tmp_a2a_order_info.sql

show errors

-- redefine tmp_a2a_order_info_line with new key order #, order date and line
-- add cage code
@@tmp_a2a_order_info_line.sql

show errors

-- new key order #, order date, and line
@@tmp_amd_on_order.sql

show errors

-- Make sure a commit is done after ever insert and update so that the job status
-- is immediately available to anyone access to the amd_batch_jobs and amd_batch_job_steps
@@amd_batch_pkg.sql

show errors

-- fix months2CalendarDays
-- moved before a2a_pkg compilation because it depends on many utils routines
@@amd_utils.sql

show errors

-- fixed loadAll for PartInfo to use 
-- new amd_partprime_pkg routine + load rbl pairs
@@a2a_pkg.sql

show errors

-- add constant AMD_AUS_LOC_ID and its get function
@@amd_defaults.sql

show errors

-- remove reference to amd_sent_to_a2a_history:
@@a2a_part_info_after_trig.sql

show errors

-- record changes to amd_sent_to_a2a in amd_sent_to_a2a_history
@@amd_sent_to_a2a_after_trig.sql

show errors

-- add procedure to zero out tsl's for prime parts that change
@@amd_location_part_override_pkg.sql

-- invoke in amd_location_part_override_pkg procedure 
-- to zero out tsl's for prime parts that change
@@amd_partprime_pkg.sql

show errors

-- fix updateRow to update the order_lead_time_defaulted
@@amd_spare_parts_pkg.sql

show errors

-- get order_lead_time from cat1 instead of tmp_main
@@amd_load.sql

show errors

-- au demand added
@@amd_demand.sql

show errors

-- removed insertTmpA2AOrderInfo.  amd_on_order_aft_insupd_trig will
-- create a2a transactions now
@@amd_inventory.sql

show errors

-- For all cleaned fields only return a value if lock sid 2 data is different from lock sid 1 data.
@@amd_cleaned_from_bssm_pkg.sql

-- removed rtrim's and trim's
@@amd_reqs_pkg.sql

show errors

