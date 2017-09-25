create or replace package amd_inventory as
	--
	-- SCCSID: amd_inventory.sql  1.20  Modified: 07/14/04 14:09:25
	--
	-- Date     By     History
	-- -------- -----  ---------------------------------------------------
	-- 10/14/01 FF     Initial implementation
	-- 11/01/01 FF     Changed LoadGoldInventory() to accept parameter as
	--                 char to match item.prime char datatype.
	-- 11/07/01 FF     Implemented WWA mod. Removed GetLocSid().
	-- 11/21/01 FF     Removed references to gold_mfgr_cage.
	-- 11/26/01 FF     Changed action_code to use defaults package.
	-- 01/04/02 FF     Removed "tactical" check from select criteria.
	-- 01/23/02 FF     Added "distinct" keyword to partCur cursor.
	-- 02/20/02 FF     Modified load to be by part not roll up to prime.
	-- 03/05/02 FF     Fixed conditions for insert and rtrim()ed the join
	--                 to the ord1 table.
	-- 09/25/02 FF     Qualified all amd_spare_parts refereneces with
	--                 action_code != 'D'
	-- 10/23/02 FF     Added translation of loc_type='TMP' srans to its MOB val.
	-- 11/18/02 FF     Added exception handler to rampCur.
	-- 06/13/03 TP     Changed order_no prefixes from ord1 table.
	-- 04/05/04 TP	   Removed 'TC' as a valid order prefix for including a 
	--                 cap order in inventory.
	-- 05/13/04 TP	   Changed LoadGoldInventory() in On Hand and in Repair .
	-- 06/16/04 TP	   Added conditions in the OnHand and Repair types. 
	--                 
	--

	procedure LoadGoldInventory;

end amd_inventory;
/

create or replace package body amd_inventory as

	/* ------------------------------------------------------------------- */
	/*  this program extracts data from gold and generate records for the  */
	/*  amd_spare_invs table for the boeing icp parts which have been      */
	/*  loaded in the amd_spare_parts.                                     */
	/*                                                                     */
	/*  this program also generates data for amd_repair_levels and         */
	/*  amd_main_task_distribs table.                                      */
	/* ------------------------------------------------------------------- */
	procedure LoadGoldInventory is

		loadNo         number;
		nsnDashed      varchar2(16);
		orderSid       number;

		pn          varchar2(50);
		loc_sid     number;
		inv_date    date;
		invQty      number;
	
		cursor partCur is
			select distinct
				asp.part_no, 
				asp.nsn
			from 
				amd_spare_parts asp,
				amd_national_stock_items ansi,
				amd_nsi_parts anp
			where 
				icp_ind = 'F77'
				and asp.part_no   = anp.part_no
				and anp.prime_ind = 'Y'
				and anp.unassignment_date is null
				and asp.nsn = ansi.nsn
				and asp.action_code != 'D';
	
		-- Type 1,2 Retail
		cursor rampCur(pNsn varchar2) is
			select
				decode(n.loc_type,'TMP',asn2.loc_sid,n.loc_sid) loc_sid,
				nvl(r.serviceable_balance,0) serviceable_balance,
				nvl(r.hpmsk_balance,0) hpmsk_balance,
				nvl(r.difm_balance,0) difm_balance,
				nvl(r.unserviceable_balance,0) unserviceable_balance,
				nvl(r.suspended_in_stock,0) suspended_in_stock,
				trunc(nvl(r.date_processed,sysdate)) inv_date
			from
				(select * from ramp
				where current_stock_number = pNsn ) r,
				amd_spare_networks n,
				amd_spare_networks asn2
			where
				n.loc_id = substr(r.sc(+),8,6)
				and n.loc_type in ('MOB', 'FSL', 'ROR','TMP')
				and n.mob = asn2.loc_id(+);
	
		-- Type 1 Wholesale from ITEM and TMP1
		cursor itemType1Cur is
			select
				asp.part_no,
				decode(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
				'1' inv_type,
				invQ.inv_date inv_date,
				sum(invQ.inv_qty) inv_qty
			from
				(select
					rtrim(part) part_no,
					substr(i.sc,8,6) loc_id,
					'1' inv_type,
					trunc(decode(i.created_datetime,null,i.last_changed_datetime,
							i.created_datetime)) inv_date,
					nvl(i.qty,0) inv_qty
				from
					item i
				where
					i.status_3 != 'I'
					and i.status_servicable = 'Y'
					and i.status_new_order = 'N'
					and i.status_accountable = 'Y'
					and i.status_active = 'Y'
				union all
				select
					rtrim(from_part) part_no,
					substr(from_sc,8,6) loc_id,
					'1' inv_type,
					trunc(t.from_datetime) inv_date,
					nvl(t.qty_due,0) inv_qty
				from
					tmp1 t
				where
					t.returned_voucher is null
					and t.status = 'O'
					and t.tcn = 'LNI') invQ,
				amd_spare_networks asn,
				amd_spare_parts asp,
				amd_spare_networks asnLink
			where
				asp.part_no = invQ.part_no
				and asn.loc_id = invQ.loc_id
				and asp.action_code != 'D'
				and asn.mob = asnLink.loc_id(+)
			group by
				asp.part_no,
				decode(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid),
				invQ.inv_date;


		-- Type 3 Wholesale
		cursor itemType3Cur is
			select
				asp.part_no,
				decode(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
				'3' inv_type,
				o.created_datetime inv_date,
				nvl(o.qty_due,0) inv_qty,
				rtrim(o.order_no) order_no
			from 
				ord1 o,
				amd_spare_networks asn,
				amd_spare_parts asp,
				amd_spare_networks asnLink
			where
				asp.part_no  = rtrim(o.part)
				and o.status = 'O'
				and o.order_type = 'M'
				and asn.loc_id = substr(o.sc,8,6)
				and asp.action_code != 'D'
				and asn.mob = asnLink.loc_id(+)
			union all	
			select
				asp.part_no,
				decode(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
				'3' inv_type,
				o.created_datetime inv_date,
				nvl(o.qty_due,0) inv_qty,
				rtrim(o.order_no) order_no
			from 
				ord1 o,
				amd_spare_networks asn,
				amd_spare_parts asp,
				amd_spare_networks asnLink
			where
				asp.part_no  = rtrim(o.part)
				and o.status = 'O'
				and o.order_type = 'C'
				and substr(o.order_no,1,2) in 
						('FC','AM','RS','SE','BR','BN','LB')
				and asn.loc_id = substr(o.sc,8,6)
				and asp.action_code != 'D'
				and asn.mob = asnLink.loc_id(+);

		-- Type 4 Wholesale
		cursor itemMCur is
			select
				asp.part_no,
				decode(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid) loc_sid,
				'4' inv_type,
				decode(i.created_datetime,null,trunc(i.last_changed_datetime),
				      trunc(i.created_datetime)) inv_date,
				sum(nvl(i.qty,0)) inv_qty
			from 
				item i,
				amd_spare_networks asn,
				amd_spare_parts asp,
				amd_spare_networks asnLink
			where
				asp.part_no = rtrim(i.part)
				and i.status_3 != 'I'
				and i.status_servicable = 'N'
				and i.status_new_order = 'N'
				and i.status_accountable = 'Y'
				and i.status_active = 'Y'
				and asn.loc_id = substr(i.sc,8,6)
				and asp.action_code != 'D'
				and asn.mob = asnLink.loc_id(+)
			group by
				asp.part_no,
				decode(asn.loc_type,'TMP',asnLink.loc_sid,asn.loc_sid),
				decode(i.created_datetime,null,trunc(i.last_changed_datetime),
				      trunc(i.created_datetime));
	
	begin

		loadNo := amd_utils.GetLoadNo('GOLD/RAMP/ITEM','AMD_SPARE_INVS');
		
		--
		--   select f77 parts from amd_spare_parts
		--
		for rec in partCur loop

			nsnDashed := amd_utils.FormatNsn(rec.nsn,'GOLD');
		
			--
			-- For each part, extract inventory data from ramp and item tables.
			--
			for rRec in rampCur(nsnDashed) loop
		
				invQty := rRec.serviceable_balance + rRec.hpmsk_balance;

				if (invQty > 0) then
					-- Type 1
					begin
						insert into amd_on_hand_invs
						(
							part_no,
							loc_sid,
							inv_date,
							inv_qty,
							action_code,
							last_update_dt
						)
						values
						(
							rec.part_no,
							rRec.loc_sid,
							rRec.inv_date,
							invQty,
							amd_defaults.INSERT_ACTION,
							sysdate
						);
					exception
						when dup_val_on_index then
							pn := rec.part_no;
							loc_sid := rRec.loc_sid;
							inv_date:= rRec.inv_date;
							dbms_output.put_line('rRec');
							dbms_output.put_line('nsn('||nsnDashed||')');
							dbms_output.put_line('pn('||rec.part_no||')');
							dbms_output.put_line('loc_sid('||rRec.loc_sid||')');
							dbms_output.put_line('inv_date('||rRec.inv_date||')');
					end;
				end if;

				invQty := rRec.difm_balance + rRec.unserviceable_balance + rRec.suspended_in_stock;

				if (invQty > 0) then
					-- Type 2
					begin
						insert into amd_in_repair
						(
							part_no,
							loc_sid,
							repair_date,
							repair_type,
							repair_qty,
							order_sid,
							action_code,
							last_update_dt
						)
						values
						(
							rec.part_no,
							rRec.loc_sid,
							rRec.inv_date,
							'2',
							invQty,
							amd_order_sid_seq.nextval,
							amd_defaults.INSERT_ACTION,
							sysdate
						);
					exception
						when dup_val_on_index then
							dbms_output.put_line('rampCur: nsnDashed('||nsnDashed||')');
							dbms_output.put_line('rampCur: repair_type(2)');
					end;
				end if;

			end loop;

		end loop;

		for iRec in itemType1Cur loop
		
			if (iRec.inv_date is null) then
				amd_utils.InsertErrorMsg(loadNo,iRec.part_no,iRec.loc_sid,'','',
						'GOLD/SPAREINV',
						'No inventory date found' );
			else
				
				-- Type 1
				if iRec.inv_qty > 0 then
				
					begin
					insert into amd_on_hand_invs
					(
						part_no,
						loc_sid,
						inv_date,
						inv_qty,
						action_code,
						last_update_dt
					)
					values
					(
						iRec.part_no,
						iRec.loc_sid,
						iRec.inv_date,
						iRec.inv_qty,
						amd_defaults.INSERT_ACTION,
						sysdate
					);
					exception
						when others then
							pn := iRec.part_no;
							loc_sid := iRec.loc_sid;
							inv_date:= iRec.inv_date;
							dbms_output.put_line('iRec');
							dbms_output.put_line('pn('||iRec.part_no||')');
							dbms_output.put_line('loc_sid('||iRec.loc_sid||')');
							dbms_output.put_line('inv_date('||iRec.inv_date||')');
					end;
				
				end if;
			end if;
	
		end loop;

		for iRec3 in itemType3Cur loop
		
			if (iRec3.inv_date is null) then
				amd_utils.InsertErrorMsg(loadNo,iRec3.part_no,iRec3.loc_sid,'','',
						'GOLD/SPAREINV',
						'No inventory date found' );
			else
				
				if iRec3.inv_qty > 0 then
				
					-- Type 3
				begin
					insert into amd_on_order
					(
						part_no,
						loc_sid,
						sched_receipt_date,
						order_qty,
						gold_order_number,
						action_code,
						last_update_dt
					)
					values
					(
						iRec3.part_no,
						iRec3.loc_sid,
						iRec3.inv_date,
						iRec3.inv_qty,
						iRec3.order_no,
						amd_defaults.INSERT_ACTION,
						sysdate
					);
				exception
					when others then
						dbms_output.put_line('part:'||iRec3.part_no);
				end;
				
				end if;
			end if;
	
		end loop;
		

		for imRec in itemMCur loop
		
			if (imRec.inv_date is null) then
				amd_utils.InsertErrorMsg(loadNo,imRec.part_no,imRec.loc_sid,
						'', '', 'GOLD/SPAREINV',
						'No inventory date found' );
			else
				
				if imRec.inv_qty > 0 then
		
					select amd_order_sid_seq.nextval
					into orderSid
					from dual;

					-- Type 4
					insert into amd_in_repair
					(
						part_no,
						loc_sid,
						repair_date,
						repair_type,
						repair_qty,
						order_sid,
						action_code,
						last_update_dt
					)
					values
					(
						imRec.part_no,
						imRec.loc_sid,
						imRec.inv_date,
						imRec.inv_type,
						imRec.inv_qty,
						orderSid,
						amd_defaults.INSERT_ACTION,
						sysdate
					);
		
				end if;
			end if;
	
		end loop;
		
	end LoadGoldInventory;

end amd_inventory;
/
