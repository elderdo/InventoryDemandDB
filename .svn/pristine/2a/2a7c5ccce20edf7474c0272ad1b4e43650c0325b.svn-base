/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   20 Feb 2009 09:19:08  $
    $Workfile:   loadRamp.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadRamp.sql.-arc  $
/*   
/*      Rev 1.1   20 Feb 2009 09:19:08   zf297a
/*   Added link variable
/*   
/*      Rev 1.0   20 May 2008 14:30:52   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec amd_owner.mta_truncate_table('ramp','reuse storage');

define link = &1

insert into ramp 
(
	nsn,sc,sran,serviceable_balance,due_in_balance, due_out_balance, difm_balance,date_processed,
	avg_repair_cycle_time,percent_base_condem,percent_base_repair,
	daily_demand_rate,current_stock_number, retention_level,       
	hpmsk_balance,
	demand_level,
	unserviceable_balance,
	suspended_in_stock,
	wrm_balance,
	wrm_level,requisition_objective,hpmsk_level_qty,spram_level,spram_balance,delete_indicator,
	total_inaccessible_qty
)
select 
	trim(niin),trim(sc),substr(sc,8,6),serviceable_balance,due_in_balance, due_out_balance,difm_balance,date_processed,
	avg_repair_cycle_time,percent_base_condem,percent_base_repair,
	daily_demand_rate,substr(trim(current_stock_number),1,16), retention_level,
	hpmsk_balance,
	demand_level,
	unserviceable_balance,
	suspended_in_stock,
	wrm_balance,
	wrm_level,requisition_objective,hpmsk_level_qty,spram_level,spram_balance,trim(delete_indicator),
	total_inaccessible_qty
from ramp@&&link
where
	delete_indicator is null;

exit 
