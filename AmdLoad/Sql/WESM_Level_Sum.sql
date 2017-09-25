set pagesize 0 
set linesize 500 
set trimspool on 
set feedback off 
set echo off
set term off

spool &1/WESM_Level_Sum.csv

select 'nsn,boeing_base_max_level_sum' from dual
/
select nsn || ',' || sum(boeing_base_max_level) from  l11  
where 
sran != '1746'
group  by nsn
order by nsn
/

spool off
