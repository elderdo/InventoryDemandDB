
SET ECHO ON TERMOUT ON AUTOCOMMIT ON TIME ON

exec amd_owner.mta_truncate_table('item','reuse storage');
exec amd_owner.mta_truncate_table('itemsa','reuse storage');
exec amd_owner.mta_truncate_table('mlit','reuse storage');
exec amd_owner.mta_truncate_table('ord1','reuse storage');
exec amd_owner.mta_truncate_table('ordv','reuse storage');
exec amd_owner.mta_truncate_table('ramp','reuse storage');
exec amd_owner.mta_truncate_table('req1','reuse storage');
exec amd_owner.mta_truncate_table('tmp1','reuse storage');

insert into item
(
   item_id,received_item_id,sc,part,prime,condition,status_del_when_gone,
   status_servicable,status_new_order,status_accountable,status_avail,
   status_frozen,status_active,status_mai,status_receiving_susp,status_2,status_3,
   last_changed_datetime,status_1,
   created_datetime,vendor_code,
   qty,order_no,receipt_order_no
)
select
   trim(item_id),trim(received_item_id),trim(sc),trim(part),trim(prime),trim(condition),status_del_when_gone,
   status_servicable,status_new_order,status_accountable,status_avail,
   status_frozen,status_active,status_mai,status_receiving_susp,status_2,status_3,
   last_changed_datetime,status_1,
   created_datetime,trim(vendor_code),
   qty,trim(order_no),trim(receipt_order_no)
from item@pgoldlb
where
   status_1 != 'D' and
   condition not in ('LDD');)

insert into itemsa
(
   item_id,received_item_id,sc,part,prime,condition,location,status_del_when_gone,
   status_servicable,status_new_order,status_accountable,status_avail,
   status_frozen,status_active,status_mai,status_receiving_susp,status_2,status_3,
   last_changed_datetime,status_1,
   created_datetime,vendor_code,
   qty,order_no,receipt_order_no
)
select
   trim(item_id),trim(received_item_id),trim(sc),trim(part),trim(prime),condition,location,status_del_when_gone,
   status_servicable,status_new_order,status_accountable,status_avail,
   status_frozen,status_active,status_mai,status_receiving_susp,status_2,status_3,
   last_changed_datetime,status_1,
   created_datetime,vendor_code,
   qty,trim(order_no),trim(receipt_order_no)
from item@pgoldsa
where status_1 != 'D'
      and condition not in ('LDD', 'B170-ATL')
      and sc = 'C17PCAG';

insert into mlit
(
   document_id, customer, mils_activity, mils_ownership_code,
   mils_profile,
   in_tran_from, in_tran_to, in_tran_type,
   part, abbr_part, create_date, ship_date,
   receipt_date, start_date_time, create_qty, ship_qty,
   receipt_qty, mils_condition, status_ind
)
select
   trim(document_id), trim(customer), trim(mils_activity), trim(mils_ownership_code),
   trim(mils_profile), trim(in_tran_from), trim(in_tran_to), trim(in_tran_type),
   trim(part), trim(abbr_part), create_date, ship_date,
   receipt_date, start_date_time, create_qty, ship_qty,
   receipt_qty, mils_condition, status_ind
from mlit@pgoldlb
where
   trim(part) != trim(abbr_part)
   and status_ind = 'I'
   or trim(abbr_part) is null
   and status_ind = 'I';



insert into ord1
(
   order_no,order_type,sc,part,completed_docdate,created_docdate,
   action_taken,original_location,qty_due, qty_completed,need_date,
   created_datetime,condition,ecd,vendor_code,accountable_yn,
   status
)
select
   trim(order_no),order_type,trim(sc),trim(part),completed_docdate,created_docdate,
   action_taken,trim(original_location),qty_due, qty_completed,need_date,
   created_datetime,trim(condition),ecd,trim(vendor_code),accountable_yn,
   status
from ord1@pgoldlb;



insert into ordv
(
   order_no, site_code, vendor_est_cost, vendor_est_ret_date
)
select
   trim(order_no), site_code, vendor_est_cost, vendor_est_ret_date
from ordv@pgoldlb;


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
from ramp@pgoldlb
where
   delete_indicator is null;


insert into req1
(
   request_id,created_datetime,qty_requested,prime,nsn,status,
   allow_alts_yn,qty_reserved,select_from_part,select_from_sc,
   qty_canc,mils_source_dic,
   qty_due,qty_issued,
   need_date,
   request_priority
)
select
   trim(request_id),created_datetime,qty_requested,trim(prime),trim(nsn),status,
   allow_alts_yn,qty_reserved,trim(select_from_part),trim(select_from_sc),
   qty_canc,trim(mils_source_dic),
   qty_due,qty_issued,
   need_date,
   request_priority
from req1@pgoldlb
where
   status != 'X';


insert into tmp1
(
   qty_due,returned_voucher,status,tcn,from_sc, to_sc, from_datetime,
   temp_out_id,from_part,est_return_date
)
select
   qty_due,trim(returned_voucher),status,trim(tcn),trim(from_sc), trim(to_sc), from_datetime,
   trim(temp_out_id),trim(from_part),est_return_date
from tmp1@pgoldlb
where
   returned_voucher is null
   and status = 'O'
   and tcn in ('LNI','LBR');


exit;
