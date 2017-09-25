set pagesize 0 
set linesize 500 
set trimspool on 
set feedback off 
set echo off
set term off

spool &1/AMD_On_Hand_Inv_Detail_no_FMS_BASC.csv

select 'nsn,loc_id,inv_qty_sum' from dual
/
select p.nsn || ',' || l.loc_id || ',' || sum(i.inv_qty) 
  from amd_on_hand_invs i, amd_spare_networks l, amd_spare_parts p
where p.action_code != 'D' and
p.part_no = i.part_no and
i.action_code != 'D' and
i.loc_sid = l.loc_sid and
loc_type != 'FMS' and
loc_id not like '%SAC' and
loc_id not like '%QAT' and
loc_id not like '%KLY' and
loc_id not like '%LGB' and
loc_id not like '%NAT' and
loc_id not like '%WRO' and
loc_id not like '%OKC' and
loc_id != 'EY1746' 
group by p.nsn, l.loc_id
order by p.nsn, l.loc_id
/

spool off
