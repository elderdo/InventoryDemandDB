-- amd_benchstock_csv_format.ctl
-- Author: Douglas Elder
-- Date: 02/17/2015
-- Load csv file into amd_benchstock
options (skip=1, rows=2583, readsize=10000000, bindsize=10000000)
load data
truncate into table amd_owner.amd_benchstock
fields terminated by ',' optionally enclosed by '"'
trailing nullcols
(
SRAN,
STOCK_NUMBER,
AUTH_QTY "to_number(replace(:auth_qty,',',''))"
)

