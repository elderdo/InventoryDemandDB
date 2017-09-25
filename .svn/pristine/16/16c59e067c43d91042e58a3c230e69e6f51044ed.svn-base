set serveroutput off
set trim on
set pause off
set term on
set echo off
set feedback off
set verify off
set wrap off
set pagesize 50
set linesize 150
set recsep off
column table_name format a40 heading 'Table Name'
column count format 999,999,999 heading 'Rows'
column last_update_dt format a22 heading 'Max Last Update Date'
column batch_job_number format a5
set heading off
select 'job:', trim(batch_job_number) batch_job_number,  'start time:', to_char(start_time,'MM/DD/YYYY HH:MI:SS AM'), 'end time:', nvl(to_char(end_time,'MM/DD/YYYY HH:MI:SS AM'),'(not finished)') from amd_batch_jobs where batch_job_number in (select  max(batch_job_number) from amd_batch_jobs where description = 'Amd Batch Load') and description = 'Amd Batch Load' ;
set heading on
select 'tmp_a2a_spo_users INS/UPD' table_name, count(*) count, to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_spo_users where action_code <> 'D'
union
select 'tmp_a2a_spo_users DELETES' table_name, count(*) count, to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_spo_users where action_code = 'D'
union
select 'tmp_a2a_site_resp_asset_mgr INS/UPD' table_name, count(*) count, to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_site_resp_asset_mgr where action_code <> 'D' 
union
select 'tmp_a2a_site_resp_asset_mgr DELETES' table_name, count(*) count, to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_site_resp_asset_mgr where action_code = 'D' 
union
select 'tmp_a2a_part_info INS/UPD' table_name, count(*) count, to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_part_info where action_code <> 'D'
union
select 'tmp_a2a_part_info DELETES' table_name, count(*) count, to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_part_info where action_code = 'D'
union
select 'tmp_a2a_part_lead_time INS/UPD' table_name, count(*) count,to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_part_lead_time where action_code <> 'D'
union
select 'tmp_a2a_part_lead_time DELETES' table_name, count(*) count,to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_part_lead_time where action_code = 'D'
union
select 'tmp_a2a_part_factors INS/UPD' table_name, count(*) count, to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_part_factors where action_code <> 'D' 
union
select 'tmp_a2a_part_factors DELETES' table_name, count(*) count, to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_part_factors where action_code = 'D' 
union
select 'tmp_a2a_loc_part_lead_time INS/UPD' table_name, count(*) count, to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_loc_part_lead_time where action_code <> 'D' 
union
select 'tmp_a2a_loc_part_lead_time DELETES' table_name, count(*) count, to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_loc_part_lead_time where action_code = 'D' 
union
select 'tmp_a2a_demands INS/UPD' table_name, count(*) count, to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_demands where action_code <> 'D'
union
select 'tmp_a2a_demands DELETES' table_name, count(*) count, to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_demands where action_code = 'D'
union
select 'tmp_a2a_repair_info INS/UPD' table_name, count(*) count,to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_repair_info where action_code <> 'D' 
union
select 'tmp_a2a_repair_info DELETES' table_name, count(*) count,to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_repair_info where action_code = 'D' 
union
select 'tmp_a2a_inv_info INS/UPD' table_name, count(*) count, to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_inv_info where action_code <> 'D' 
union
select 'tmp_a2a_inv_info DELETES' table_name, count(*) count, to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_inv_info where action_code = 'D' 
union
select 'tmp_a2a_in_transits INS/UPD' table_name, count(*) count, to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_in_transits where action_code <> 'D' 
union
select 'tmp_a2a_in_transits DELETES' table_name, count(*) count, to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_in_transits where action_code = 'D' 
union
select 'tmp_a2a_backorder_info INS/UPD' table_name, count(*) count,to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_backorder_info where action_code <> 'D' 
union
select 'tmp_a2a_backorder_info DELETES' table_name, count(*) count,to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_backorder_info where action_code = 'D' 
union
select 'tmp_a2a_bom_detail INS/UPD' table_name, count(*) count,to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_bom_detail where action_code <> 'D' 
union
select 'tmp_a2a_bom_detail DELETES' table_name, count(*) count,to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_bom_detail where action_code = 'D' 
union
select 'tmp_a2a_order_info_line INS/UPD' table_name, count(*) count,to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_order_info_line where action_code <> 'D' 
union
select 'tmp_a2a_order_info_line DELETES' table_name, count(*) count,to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_order_info_line where action_code = 'D' 
union
select 'tmp_a2a_ext_forecast INS/UPD' table_name, count(*) count,to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_ext_forecast where action_code <> 'D' 
union
select 'tmp_a2a_ext_forecast DELETES' table_name, count(*) count,to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_ext_forecast where action_code = 'D' 
union
select 'tmp_a2a_loc_part_override INS/UPD' table_name, count(*) count,to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_loc_part_override where action_code <> 'D' 
union
select 'tmp_a2a_loc_part_override DELETES' table_name, count(*) count,to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_loc_part_override where action_code = 'D' 
union
select 'tmp_a2a_org_flight_acty INS/UPD' table_name, count(*) count,to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_org_flight_acty where action_code <> 'D' 
union
select 'tmp_a2a_org_flight_acty DELETES' table_name, count(*) count,to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_org_flight_acty where action_code = 'D' 
union
select 'tmp_a2a_org_flight_acty_frecst INS/UPD' table_name, count(*) count,to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_org_flight_acty_frecst  where action_code <> 'D' 
union
select 'tmp_a2a_org_flight_acty_frecst DELETES' table_name, count(*) count,to_char(max(last_update_dt),'MM/DD/YYYY HH:MI:SS AM') last_update_dt from tmp_a2a_org_flight_acty_frecst  where action_code = 'D' order by table_name ;
set heading off
select 'job:', trim(batch_job_number) batch_job_number,  'start time:', to_char(start_time,'MM/DD/YYYY HH:MI:SS AM'), 'end time:', nvl(to_char(end_time,'MM/DD/YYYY HH:MI:SS AM'),'(not finished)') from amd_batch_jobs where batch_job_number in (select  max(batch_job_number) from amd_batch_jobs where description = 'Amd Batch Load') and description = 'Amd Batch Load' ;
quit
/
