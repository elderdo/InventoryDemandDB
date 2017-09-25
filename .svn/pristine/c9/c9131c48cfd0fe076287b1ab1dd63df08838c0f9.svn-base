/*
      $Author:   zf297a  $
    $Revision:   1.16  $
        $Date:   26 Nov 2008 00:37:58  $
    $Workfile:   ReplicateGold.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\R
	 eplicateGold.sql.-arc  $
/*
/*      Rev 1.0   Feb 17 2006 13:22:24   zf297a
/*   Latest Prod Version
*/
--
-- SCCSID: %M%  %I%  Modified: %G% %U%
-- 
-- 07/13/01  Fernando F.     Added last_changed_datetime column to ITEM
-- 07/20/01  Fernando F.     Changed gldp to pgoldlb
-- 08/13/01  Fernando F.     Changed pgoldlb back to gldp.
--                           Changed nsn in RAMP to niin.
-- 11/30/01  Thuy Pham	     Added 'I' to column status_3 in Item table.
-- 11/30/01  Fernando F.     Added abbr_part column to select list of CAT1.
-- 12/05/01  Fernando F.     Added selected columns to RAMP and CAT1.
-- 12/10/01  Fernando F.     Added more columns to select to REQ1.
-- 12/11/01  Fernando F.     Linked amd_spare_networks in with REQ1.
-- 02/27/02  Fernando F.     Added RSV1.
-- 11/05/02  Fernando F.     Added prc1.
-- 03/06/03  Thuy Pham	     Added Mlit.
-- 09/30/03  Fernando F.     Added code C172004CTLATLG to prc1.
-- 04/15/04  Thuy Pham 	     Changed Seg Code = 'DEF' in PCR1.
-- 05/07/04  Thuy Pham	     Removed Status_3 and replaced Status_1 and changed Condition in ITEM table.
-- 11/18/04  Thuy Pham	     Added tables amd_use1 & amd_isgp for the TAV project.
-- 12/02/04  Thuy Pham	     Added table NSN1.
-- 08/05/05  Thuy Pham	     Added UIMS
-- 08/09/05  Thuy Pham	     Added WHSE
-- 10/03/05  Thuy Pham	     Added itemsa and whse from pgoldsa . 
--
SET ECHO ON TERMOUT ON AUTOCOMMIT ON TIME ON

exec amd_owner.mta_truncate_table('poi1','reuse storage');
exec amd_owner.mta_truncate_table('ord1','reuse storage');
exec amd_owner.mta_truncate_table('cat1','reuse storage');
exec amd_owner.mta_truncate_table('venc','reuse storage');
exec amd_owner.mta_truncate_table('venn','reuse storage');
exec amd_owner.mta_truncate_table('fedc','reuse storage');
exec amd_owner.mta_truncate_table('ramp','reuse storage');
exec amd_owner.mta_truncate_table('item','reuse storage');
exec amd_owner.mta_truncate_table('mils','reuse storage');
exec amd_owner.mta_truncate_table('chgh','reuse storage');
exec amd_owner.mta_truncate_table('req1','reuse storage');
exec amd_owner.mta_truncate_table('rsv1','reuse storage');
exec amd_owner.mta_truncate_table('tmp1','reuse storage');
exec amd_owner.mta_truncate_table('prc1','reuse storage');
exec amd_owner.mta_truncate_table('mlit','reuse storage');
exec amd_owner.mta_truncate_table('amd_isgp','reuse storage');
exec amd_owner.mta_truncate_table('amd_use1','reuse storage');
exec amd_owner.mta_truncate_table('nsn1','reuse storage');
exec amd_owner.mta_truncate_table('ordv','reuse storage');
exec amd_owner.mta_truncate_table('whse','reuse storage');
exec amd_owner.mta_truncate_table('itemsa','reuse storage');
exec amd_owner.mta_truncate_table('uims','reuse storage');
exec amd_owner.mta_truncate_table('cgvt','reuse storage');
exec amd_owner.mta_truncate_table('lvls','reuse storage');


insert into poi1
(
	order_no,seq,item,qty,item_line,ext_price,part,ccn
)
select 
	trim(order_no),trim(seq),trim(item),trim(qty),trim(item_line),trim(ext_price),trim(part),trim(ccn) 
from poi1@pgoldlb 
where 
	ext_price is not null;

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

insert into cat1
(
	part,nsn,noun,prime,um_show_code,um_issue_code,um_turn_code,
	um_disp_code,um_cap_code,um_mil_code,asset_req_on_receipt,
	record_changed1_yn,record_changed2_yn,record_changed3_yn,
	record_changed4_yn,record_changed5_yn,record_changed6_yn,
	record_changed7_yn,record_changed8_yn,manuf_cage,ims_designator_code,
	source_code,serial_mandatory_b,smrc,isgp_group_no,
	abbr_part,errc,user_ref4,hazardous_material_code,
	user_ref7,mils_auto_process_b,remarks,ave_cap_lead_time
)
select 
    trim(part),trim(nsn),trim(noun),trim(prime),
    case when length(trim(um_show_code)) > 2 then
        substr(trim(um_show_code),1,2)
        else
        trim(um_show_code)        
    end um_show_code,trim(um_issue_code),trim(um_turn_code),
    trim(um_disp_code),
    case when length(trim(um_cap_code)) > 2 then
        substr(trim(um_cap_code),1,2)
         else
        trim(um_cap_code)        
    end um_cap_code,trim(um_mil_code),asset_req_on_receipt,
    record_changed1_yn,record_changed2_yn,record_changed3_yn,
    record_changed4_yn,record_changed5_yn,record_changed6_yn,
    record_changed7_yn,record_changed8_yn,trim(manuf_cage),trim(ims_designator_code),
    trim(source_code),trim(serial_mandatory_b),trim(smrc),trim(isgp_group_no),
    trim(abbr_part),trim(errc),trim(user_ref4),trim(hazardous_material_code),
    trim(user_ref7),mils_auto_process_b,trim(remarks),trim(ave_cap_lead_time)
from cat1@pgoldlb 
where 
    source_code = 'F77'
    and part not like '% '
    and part not like ' %' ;

insert into venc 
(
	part,seq,vendor_code,user_ref1
)
select 
	trim(part),seq,trim(vendor_code),trim(user_ref1) 
from venc@pgoldlb
where 
	seq=1;

insert into venn
(
	vendor_code,vendor_name,cage_code,user_ref1
) 
select 
	trim(vendor_code),trim(vendor_name),trim(cage_code),trim(user_ref1) 
from venn@pgoldlb
where 
	cage_code is not null;

insert into fedc
(
	part_number,vendor_code,seq_number,gfp_price,nsn
)
select 
	trim(part_number),trim(vendor_code),seq_number,gfp_price,trim(nsn)
from fedc@pgoldlb;

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
	condition not in ('LDD');


	
insert into mils
(
	mils_id,rec_types,created_datetime,status_line,part,default_name
)
select
	trim(mils_id),trim(rec_types),created_datetime,trim(status_line),trim(part),trim(default_name)
from mils@pgoldlb
where
	default_name = 'A0E';
	
	
insert into chgh
(
	chgh_id,
	key_value1,"TO",field,"FROM"
)
select 
	trim(chgh_id),
	key_value1,"TO",field,"FROM"
from chgh@pgoldlb
where 
	field= 'NSN';
	

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
	
	
insert into rsv1
(
	reserve_id,
	form_required_yn,
	remark_move_only_yn,
	created_docdate,
	to_sc,
	item_id,
	status
)
select 
	trim(reserve_id),
	form_required_yn,
	remark_move_only_yn,
	created_docdate,
	trim(to_sc),
	trim(item_id),
	status
from rsv1@pgoldlb;
	

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
	

insert into prc1
(
	sc,part,cap_price,gfp_price
)
select 
	trim(sc),trim(part),cap_price,gfp_price
from prc1@pgoldlb
where
	sc = 'DEF';
	


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



insert into amd_isgp
(
	sc,part,group_no,sequence_no,group_priority
)
select 
	trim(sc),trim(part),trim(group_no),sequence_no,trim(group_priority)
from isgp@pgoldlb;



insert into amd_use1
(
	userid,user_name,employee_no,employee_status,phone,ims_designator_code
)
select 
	trim(userid),trim(user_name),trim(employee_no),employee_status,trim(phone),trim(ims_designator_code)
from use1@pgoldlb
where employee_no is not null;


insert into nsn1
(
	nsn,nsn_smic
)
select
	trim(nsn),trim(nsn_smic)
from nsn1@pgoldlb;


insert into ordv
(
	order_no, site_code, vendor_est_cost, vendor_est_ret_date 
)
select 
	trim(order_no), site_code, vendor_est_cost, vendor_est_ret_date
from ordv@pgoldlb;


insert into whse
(	
	sc, part, prime, user_ref3, created_datetime, created_userid, stock_level, reorder_point, planner_code
)
select 
	trim(sc), trim(part), trim(prime), trim(user_ref3),created_datetime, created_userid, stock_level, 
	case
		when reorder_point < 1 and reorder_point > 0 then
			0 -- Requirement from GOLD that AMD must comply to get data for SPO 3/11/2008
		else reorder_point
	end reorder_point, planner_code
from  whse@pgoldlb
where	sc like 'C17%CODUKBG' or sc like 'C17%CODAUSG' or sc like 'C17%CTLATLG' or sc like 'C17%CODCANG';


insert into whse
(
	sc, part,prime,created_datetime, created_userid, stock_level, reorder_point, planner_code
)
select
	trim(sc), trim(part),trim(prime), created_datetime, created_userid, stock_level, 
	case
		when reorder_point < 1 and reorder_point > 0 then
			0  -- Requirement from GOLD that AMD must comply to get data for SPO 3/11/2008
		else reorder_point
	end reorder_point, planner_code
from 
	whse@pgoldsa
where	sc = 'C17PCAG';


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


insert into uims
(
	userid,designator_code,alt_ims_des_code_b,alt_es_des_code_b,alt_sup_des_code_b
)
select
	trim(userid),designator_code,alt_ims_des_code_b,alt_es_des_code_b,alt_sup_des_code_b
from  uims@pgoldlb;


insert into cgvt
(
	service_code, stock_number, isg_master_stock_number, isg_oou_code
)
select 
	service_code, stock_number, isg_master_stock_number, isg_oou_code
from cgvt@pgoldlb
where  stock_number is not null
and isg_master_stock_number is not null;

insert into lvls
(
	niin, sran, nsn, lvl_document_number, document_datetime, current_stock_number, compatibility_code, date_lvl_loaded,
	reorder_point, economic_order_qty, approved_lvl_qty
)
select 
	trim(niin), trim(sran), replace(substr(trim(current_stock_number),1,16),'-',''), trim(lvl_document_number), document_datetime, substr(trim(current_stock_number),1,16), trim(compatibility_code),
	to_date(date_lvl_loaded,'yyddd')date_lvl_loaded, reorder_point, economic_order_qty, approved_lvl_qty
from lvls@pgoldlb;


exit;
