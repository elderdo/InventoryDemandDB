-- amd_benchstock.ctl
-- Author: Douglas Elder
-- Date: 02/10/2015
-- Load tab delimited file into amd_bssm_rvt
options (skip=1, rows=2583, readsize=10000000, bindsize=10000000)
load data
truncate into table amd_owner.amd_bssm_rvt
fields terminated by ',' 
trailing nullcols
(
NSN,
ANNUAL_INDUCTION,
WAREHOUSE_SERVICABLE,
WAREHOUSE_SAFETY_LEVEL,
DEPOT_PIPELINE_EXPECTED,
WAREHOUSE_FSL_LEVEL
)

