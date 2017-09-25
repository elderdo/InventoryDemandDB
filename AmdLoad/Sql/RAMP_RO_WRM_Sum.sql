set pagesize 0 
set linesize 500 
set trimspool on 
set feedback off 
set echo off
set term off

spool &1/RAMP_RO_WRM_Sum.csv

select 'nsn,requisition_objective_sum,serviceable_balance_sum,WRM' from dual
/
select replace(current_stock_number,'-','') || ',' || sum(requisition_objective) || ',' || sum(serviceable_balance) || ',' ||
 sum(wrm_balance + spram_balance + hpmsk_balance) from ramp
group by replace(current_stock_number,'-','')
order by replace(current_stock_number,'-','')
/

spool off
