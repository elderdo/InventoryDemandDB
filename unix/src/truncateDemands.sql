-- truncateDemands.sql
-- Author: Douglas S. Elder
-- Date: 7/12/2013
-- Desc: Empty the talbes that are
-- to be loaded by the execLoadDemands.ksh script
--
-- 8/15/2013 rev - added truncate of amd_demands - d. elder

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec amd_owner.mta_truncate_table('amd_demands','reuse storage');
exec amd_owner.mta_truncate_table('tmp_amd_demands','reuse storage');
exec amd_owner.mta_truncate_table('amd_bssm_source','reuse storage');
exec amd_owner.mta_truncate_table('tmp_lcf_icp','reuse storage');

quit
