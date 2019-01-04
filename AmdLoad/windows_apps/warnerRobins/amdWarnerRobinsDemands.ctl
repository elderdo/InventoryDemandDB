-- amdWarnerRobinsDemands.ctl
-- Author: Douglas Elder
-- Date: 08/13/2017
-- Load tab delimited file into amd_warner_robins_demads
options (skip=1, rows=2583, readsize=10000000, bindsize=10000000, errors=1000)
load data
append into table amd_owner.amd_warner_robins_files
fields terminated by "," optionally enclosed by '"'
trailing nullcols
(
excel_row,
source_code,
transaction_date "trunc(to_date(substr(:transaction_date,1,2),'yy')  ,'yy') + substr(:transaction_date,3,3)-1",
nsn,
doc_no,
demand_quantity,
filename
)

