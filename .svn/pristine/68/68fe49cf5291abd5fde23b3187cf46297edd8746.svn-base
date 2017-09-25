-- Author: Douglas Elder
-- Date: 12/09/2011
-- Load csv file into amd_repair_cost_detail
-- Rev 1.0 12/09/2011 initial rev
-- Rev 1.1 11/30/2015 added errors=999999
options (errors=999999, skip=1, rows=500, readsize=10000000, bindsize=10000000)
load data
infile 'qryPart_AvgMinMax_Pricing_Source_Data (2011-12-08).csv'
append into table amd_owner.amd_repair_cost_detail
fields terminated by "," optionally enclosed by '"'
(AOD                DATE "MM/DD/YYYY HH24:MI:SS",
FISCAL_YEAR,
CONTRACT_TYPE,
CAWP,
ACTIVITY_ID,
RELEASE_JOB_ORDER,
PURCHASE_REQUEST,
SOURCE_SYSTEM,
PC_RELEASE_DT DATE "MM/DD/YYYY HH24:MI:SS",
PURCHASE_CONTRACT,
PC_ITEM,
PCI_SCHED_DT DATE "MM/DD/YYYY HH24:MI:SS",
PART_NO,
PART_DESCRIPTION,
MFG_PART_NO nullif (MFG_PART_NO="Null"),
PC_HEADING_TYPE,
QTY,
UOM_CODE,
UNIT_PRICE
)

