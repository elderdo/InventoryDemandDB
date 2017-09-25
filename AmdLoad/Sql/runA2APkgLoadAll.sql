-- this script loads all the a2a transaction data from AMD
-- 3 tables are truncated to make sure they get loaded completely
-- otherwise tmp_a2a_ext_forecast and tmp_a2a_loc_part_override may
-- not get loaded completely by a2a_pkg.loadAll.
-- NOTE: a2a_pkg.loadAll creates a job in amd_batch_jobs and tracks
-- the start and end time of each step in amd_batch_job_steps
begin
amd_owner.mta_truncate_table('tmp_a2a_ext_forecast','reuse storage');
amd_owner.mta_truncate_table('tmp_a2a_loc_part_override','reuse storage');
amd_owner.mta_truncate_table('amd_part_loc_forecasts','reuse storage');
a2a_pkg.loadAll ;
end ;
/
