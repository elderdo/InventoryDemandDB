-- amd_benchstock.ctl
-- Author: Douglas Elder
-- Date: 07/29/2014
-- Load tab delimited file into amd_benchstock
-- remove row num
-- made stock number 2 fields
-- changed b_s_document_nbr to bench_doc_no - will be primary key
options (skip=1, rows=2583, readsize=10000000, bindsize=10000000)
load data
truncate into table amd_owner.amd_benchstock
fields terminated by X'9' optionally enclosed by '"'
trailing nullcols
(
SRAN,
STOCK_NUMBER,
AUTH_QTY "to_number(replace(:auth_qty,',',''))"
)

