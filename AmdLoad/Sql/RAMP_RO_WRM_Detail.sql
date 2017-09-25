set pagesize 0 
set linesize 500 
set trimspool on 
set feedback off 
set echo off
set term off

spool &1/RAMP_RO_WRM_Detail.csv

select 'nsn,sc,requisition_objective,serviceable_balance,WRM' from dual
/
select replace(current_stock_number,'-','') || ',' || substr(sc,8,6) || ',' || requisition_objective || ',' || serviceable_balance || ',' ||
 (wrm_balance + spram_balance + hpmsk_balance) from ramp
order by replace(current_stock_number,'-','')
/

spool off
