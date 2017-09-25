create or replace package amd_demand as
	--
	-- SCCSID: amd_demand.sql  1.9  Modified: 11/23/04 09:05:30
	--
	-- ------------------------------------------------------------------- 
	-- This program loads demand data into amd_af_reqs table.             
	--                                                                    
	-- Prior to execution of this procedure, we assume that the lcf data  
	-- have been successfully loaded into tmp_lcf_raw table.              
	--                                                                    
	-- The temporary table amd_l67_tmp and tmp_lcf_icp should be truncated     
	-- prior to the execution of the procedure.                           
	-- ------------------------------------------------------------------- 
	-- 							     	       		     
	-- Date     By     History
	-- 10/12/01 FF     Initial implementation
	-- 10/25/01 FF     Removed DedupL67() and moved into InsertL67TmpLcfIcp()
	-- 10/28/01 FF     Added LoadBascUkDemands().
	-- 11/21/01 FF     Removed use of mfgr, manuf_cage as part of key when 
	--                 accessing data from amd_spare_parts
	-- 11/26/01 FF     Changed action_code to use defaults package.
	-- 12/13/01 FF     Added logic in Insertl67TmpLcfIcp() to handle 15-char
	--                 nsn's. MMC is added to NSN if numeric.
	-- 08/06/01 FF     Removed use of CalcReqDate(). Using trans_date instead.
	-- 10/23/02 FF     Added translation of loc_type='TMP' srans to its MOB val.
	-- 11/04/04 TP	   Added EY1213 to Request Id field.
	--

	procedure LoadAmdDemands;
	procedure LoadBascUkDemands;

end amd_demand;
/

create or replace package body amd_demand as

	function CalcQuantity(
							pDocNo varchar2, 
							pDic varchar2) return number;
	function CalcBadQuantity(
							pDocNo varchar2, 
							pDic varchar2) return number;
	procedure InsertTmpLcf1;
	procedure InsertTmpLcfIcp;
	procedure InsertL67TmpLcfIcp;







	function CalcQuantity(
							pDocNo varchar2, 
							pDic varchar2) return number is
		qty     number := 0;
		qtyd1   number := 0;
		qtyd2	  number := 0;
	begin
	
		if pDic = 'TIN' then
			begin
				select 
					nvl(sum(action_qty),0)
				into qty
				from tmp_lcf_icp
				where doc_no = pDocNo
					and dic = 'TIN'
					and ttpc = '1B'
					and reason in ('B','C','J','V','X','A','D','F','G','K','L','Z',
						'1','2','3','4','5','6','7','8','9');
			exception
				when no_data_found then 
					qty := 0;
			end;
		elsif pDic = 'TRN' then
			begin
				select 
					nvl(sum(action_qty),0)
				into qty
				from tmp_lcf_icp
				where doc_no = pDocNo
					and dic = 'TRN'
					and ttpc = '4S'
					and dmd_cd in ('A','F','G','K','L','Z');
			exception
				when no_data_found then 
					qty := 0;
			end;
		elsif pDic = 'ISU' then
			begin
				select 
					nvl(sum(action_qty),0)
				into qty
				from tmp_lcf_icp
				where doc_no = pDocNo
					and dic = 'ISU'
					and ttpc in ('1A','3P','3Q');
			exception
				when no_data_found then 
					qty := 0;
			end;
		elsif pDic = 'MSI' then
			begin
				select 
					nvl(sum(action_qty),0)
				into qty
				from tmp_lcf_icp
				where doc_no = pDocNo
					and dic = 'MSI'
					and ttpc in ('1C','1G','1O','1Q','2I','2K','3P');
			exception
				when no_data_found then 
					qty := 0;
			end;
		elsif pDic = 'DUO' then
			begin
				select 
					nvl(sum(action_qty),0)
				into qty
				from tmp_lcf_icp
				where doc_no = pDocNo
					and dic = 'DUO'
					and ttpc in ('2D','4W');
			exception
				when no_data_found then 
					qty := 0;
			end;
		elsif pDic = 'DOC' then
			begin
				select 
					nvl(sum(action_qty),0)
				into qtyd1
				from tmp_lcf_icp
				where doc_no = pDocNo
					and dic = 'DOC'
					and ttpc in ('2A','2C')
					and reason in ('B','C','J','V','X');
			exception
				when no_data_found then 
					qtyd1 := 0;
			end;

			begin
				select 
					nvl(sum(action_qty),0)
				into qtyd2
				from tmp_lcf_icp
				where doc_no = pDocNo
					and dic = 'DOC'
					and ttpc not in ('2A','2C')
					and reason in ('A','F','G','K','L','Z');
				exception
			when no_data_found then 
				qtyd2 := 0;
			end;

			qty := qtyd1 + qtyd2;
		end if;				 
		 
		return(qty);

	end CalcQuantity;


	function CalcBadQuantity(
							pDocNo varchar2, 
							pDic varchar2) return number is
		qty      number := 0;
	begin
	
		if pDic = 'TIN' then
			begin
				select 
					nvl(sum(action_qty),0)
				into qty
				from tmp_lcf_icp
				where doc_no = pDocNo
					and dic = 'TIN'
					and ttpc = '1B'
					and reason not in ('B','C','J','V','X','A','D','F','G','K',
										'L','Z','1','2','3','4','5','6','7','8','9');
			exception
				when no_data_found then 
					qty := 0;
			end;
		elsif pDic = 'TRN' then
			begin
				select 
					nvl(sum(action_qty),0)
				into qty
				from tmp_lcf_icp
				where doc_no = pDocNo
					and dic = 'TRN'
					and ttpc = '4S'
					and dmd_cd not in ('A','F','G','K','L','Z');
			exception
				when no_data_found then 
					qty := 0;
			end;
		end if;					
			
		return(qty);

	end CalcBadQuantity;


	procedure InsertTmpLcf1 is
	begin
	
		insert into tmp_lcf_1
		(
			stock_no,
			erc,
			dic,
			ttpc,
			dmd_cd,
			reason,
			doc_no,
			trans_date,
			trans_ser,
			action_qty,
			sran,
			nomenclature,
			marked_for,
			date_of_last_demand,
			unit_of_issue,
			supplemental_address
		)
		select
			stock_no,
			erc,
			dic,
			ttpc,
			dmd_cd,
			reason,
			doc_no,
			to_date(trans_date,'yyyyddd'),
			trans_ser,
			action_qty,
			sran,
			nomenclature,
			marked_for,
			to_date(date_of_last_demand,'yyyyddd'),
			unit_of_issue,
			supplemental_address
		from tmp_lcf_raw
		where substr(doc_no,1,1) in ('X','J','R','B','S')
		group by
			stock_no,
			erc,
			dic,
			ttpc,
			dmd_cd,
			reason,
			doc_no,
			to_date(trans_date,'yyyyddd'),
			trans_ser,
			action_qty,
			sran,
			nomenclature,
			marked_for,
			to_date(date_of_last_demand,'yyyyddd'),
			unit_of_issue,
			supplemental_address;

		commit;

		update tmp_lcf_1 set
			nsn = substr(stock_no,1,13),
			mmc = substr(stock_no,14,2),
			sran = 'FB'||sran;

		commit;

	end InsertTmpLcf1;


	procedure InsertTmpLcfIcp is
	begin

		insert into tmp_lcf_icp
		( 
			nsn, 
			mmc, 
			stock_no, 
			erc, 
			dic, 
			ttpc, 
			dmd_cd, 
			reason,
			doc_no, 
			trans_date, 
			trans_ser, 
			action_qty,  
			sran,
			nomenclature, 
			marked_for, 
			date_of_last_demand,
			supplemental_address 
		)
		select 
			nsn, 
			mmc, 
			stock_no, 
			erc, 
			dic, 
			ttpc, 
			dmd_cd, 
			reason,
			doc_no, 
			trans_date, 
			trans_ser, 
			action_qty, 
			decode(asn.loc_type,'TMP',asn.mob,sran) sran,
			nomenclature, 
			marked_for, 
			date_of_last_demand,
			supplemental_address
		from 
			tmp_lcf_1 tl1,
			amd_spare_networks asn
		where
			tl1.sran = asn.loc_id;

		commit;

	end InsertTmpLcfIcp;



	procedure InsertL67TmpLcfIcp is
		cursor l67Cur is
			select distinct
				nsn, 
				mmc, 
				erc, 
				tric, 
				ttpc, 
				dmd_cd, 
				reason,
				doc_no, 
				trans_date, 
				trans_ser, 
				action_qty, 
				decode(asn.loc_type,'TMP',asn.mob,sran) sran,
				nomenclature, 
				marked_for, 
				dold,
				supp_address
			from 
				amd_l67_source als,
				amd_spare_networks asn
			where
				substr(als.doc_no,1,1) in ('X','J','R','B','S')
				and als.sran = asn.loc_id;

		nsn         varchar2(20);
		mmacCode    number;
	begin

		for rec in l67Cur loop
			begin
				mmacCode := rec.mmc;
				nsn      := rec.nsn||rec.mmc;
			exception
				when others then
					nsn := rec.nsn;
			end;

			insert into tmp_lcf_icp
			( 
				nsn, 
				mmc, 
				stock_no, 
				erc, 
				dic, 
				ttpc, 
				dmd_cd, 
				reason,
				doc_no, 
				trans_date, 
				trans_ser, 
				action_qty,  
				sran,
				nomenclature, 
				marked_for, 
				date_of_last_demand,
				supplemental_address 
			)
			values
			(
				nsn, 
				rec.mmc, 
				nsn, 
				rec.erc, 
				rec.tric, 
				rec.ttpc, 
				rec.dmd_cd, 
				rec.reason,
				rec.doc_no, 
				rec.trans_date, 
				rec.trans_ser, 
				rec.action_qty, 
				rec.sran,
				rec.nomenclature, 
				rec.marked_for, 
				rec.dold,
				rec.supp_address
			);

		end loop;

		commit;

	end;



	--
	-- LoadAmdDemands -
	--
	-- procedure to load amd_af_reqs from lcf data.
	--
	-- currently, we manually load lcf data into tmp_lcf_raw, tmp_lcf_1, 
	-- tmp_lcf_icp tables manually.  we do not know at this time how we would
	-- receive the lcf data in the future.
	--
	-- assume we have data loaded into tmp_lcf_icp, the follows are processes
	-- to be perform to load data into amd_af_reqs table.
	--
	-- 1) loop for each doc_no.
	-- 2) for each doc_no:
	-- 	2.1) select sum of qualified tin into goodtin
	-- 	2.2) select sum of non-qualified tin into badtin
	-- 	2.3) select sum of qualified trn into goodtrn
	-- 	2.4) select sum of non-qualified trn into badtrn
	-- 	2.5) calculate tin quantity:
	-- 						tinqty = goodtin + goodtrn
	-- 	2.6) calculate badtin quantity:
	-- 			badtinqty = badtin + badtrn
	-- 2.7) select sum of qualified isu
	-- 2.8) select sum of qualified msi
	-- 2.9) select sum of qualified duo
	-- 2.10)select sum of qualified doc
	-- 2.11)calculate duo quantity:
	-- 			duoqty = duo - doc.
	-- 		  note: if duoqty is negative, set duoqty = 0.
	-- 2.12)calculate non tin quantity:
	-- 			ntinqty = isu + msi + duoqty - badtinqty
	-- 	2.13)calculate other quantity:
	-- 			otherqty = ntinqty - tinqty
	-- 2.14)calculate requisition quantity:
	-- 				if otherqty > 0 then
	-- 							qty		= tinqty + otherqty
	--					else
	--                      qty		= tinqty
	--					end if
	--	2.15) if the qty = 0, do not insert the requisition.
	--
	-- 3) select nsn of the doc_no and select prime part from amd_spare_parts
	-- 4) use trans_date as requistion_date
	-- 5) insert into amd_demands table.
	--
	procedure LoadAmdDemands is
		vNsn         varchar2(20);
		tinqty       number := 0;
		ntinqty      number := 0;
		otherqty     number := 0;
		qty	       number := 0;
		goodtin      number := 0;
		badtin       number := 0;
		goodtrn      number := 0;
		badtrn       number := 0;
		badtinqty    number := 0;
		isu          number := 0;
		msi          number := 0;
		duo          number := 0;
		doc          number := 0;
		duoqty       number := 0;
		reqDate      date;
		lcf1cnt      number;
		nsiSid       number;
		loadNo       number;
		
		cursor docCur is
			select 
				tli.doc_no, 
				asn.loc_sid, 
				min(tli.trans_date) trans_date
			from 
				tmp_lcf_icp tli, 
				amd_spare_networks asn
			where 
				tli.sran = asn.loc_id
			group by 
				tli.doc_no, 
				asn.loc_sid;


	begin
		loadNo := amd_utils.GetLoadNo('AMD_DEMAND','AMD_DEMANDS');

		--
		-- if there are no records in tmp_lcf_1 then
		-- insert them from tmp_lcf_raw
		--
		select count(*)
		into lcf1cnt
		from tmp_lcf_1;

		if (lcf1cnt = 0) then
			InsertTmpLcf1;
		end if;

		InsertTmpLcfIcp;
		InsertL67TmpLcfIcp;

		for rec in docCur loop

			goodtin   := CalcQuantity(rec.doc_no, 'TIN');
			badtin    := CalcBadQuantity(rec.doc_no, 'TIN');
			goodtrn   := CalcQuantity(rec.doc_no, 'TRN');
			badtrn    := CalcBadQuantity(rec.doc_no, 'TRN');
			tinqty    := goodtin + goodtrn;
			badtinqty := badtin  + badtrn;
	
			isu       := CalcQuantity(rec.doc_no, 'ISU');
			msi       := CalcQuantity(rec.doc_no, 'MSI');
			duo       := CalcQuantity(rec.doc_no, 'DUO');
			doc       := CalcQuantity(rec.doc_no, 'DOC');
	
			duoqty    := duo - doc;
	
			if duoqty < 0 then
				duoqty := 0;
			end if;
	
			ntinqty   := isu + msi + duoqty - badtinqty;
			otherqty  := ntinqty - tinqty;
	
			if otherqty > 0 then
				qty    := tinqty + otherqty;
			else
				qty    := tinqty;
			end if;
	
			if qty != 0 then
		
				--
				--  Get the NSN to use for BSSM
				--
				if tinqty > 0 then
					select max(nsn)
					into vNsn
					from tmp_lcf_icp
					where doc_no = rec.doc_no
						and dic in ('TIN', 'TRN');
				else
					select max(nsn)
					into vNsn
					from tmp_lcf_icp
					where doc_no = rec.doc_no
						and dic not in ('TIN', 'TRN');
				end if;
		
				if (vNsn is not null) then
					reqDate := rec.trans_date;
		
					--
					-- send data to bssm table for extract to bssm
					--
					insert into amd_bssm_source
					(
						requisition_no,
						requisition_date,
						quantity,
						loc_sid,
						nsn
					)
					values
					(
						rec.doc_no,
						reqDate,
						qty,
						rec.loc_sid,
						vNsn
					);
			
					begin
						nsiSid := amd_utils.GetNsiSid(pNsn=>vNsn);
		
						insert into amd_demands
						( 
							doc_no, 
							doc_date, 
							nsi_sid,
							loc_sid, 
							quantity, 
							action_code,
							last_update_dt
						) 
						values
						( 
							rec.doc_no,			 
							reqDate,			 
							nsiSid,
							rec.loc_sid,  
							qty,
							amd_defaults.INSERT_ACTION,
							sysdate
						);
					exception
						when no_data_found then
							null;      -- nsiSid not found generates this, just ignore
						when others then
							amd_utils.InsertErrorMsg(loadNo,'AMD_DEMAND.LoadAmdDemands',
									'Exception: OTHERS','insert into amd_demands',null,sysdate,
									pMsg=>substr(sqlerrm,1,2000));
					end;

				end if;

			end if;
	
		end loop;

	end LoadAmdDemands;



	procedure LoadBascUkDemands is
		cursor demandCur is
			select
				rtrim(c.nsn) nsn,
				rtrim(r.request_id) request_id,
				r.created_datetime,
				r.qty_requested,
				asn.loc_sid,
				rtrim(r.prime) prime
			from
				req1 r,
				cat1 c,
				(select
					decode(asn1.loc_type,'TMP',asn2.loc_sid,asn1.loc_sid) loc_sid,
					decode(asn1.loc_type,'TMP',asn2.loc_id ,asn1.loc_id ) loc_id
				from
					amd_spare_networks asn1,
					amd_spare_networks asn2
				where
					asn1.mob = asn2.loc_id(+)) asn
			where
				r.prime = c.part
				and r.nsn is not null
				and c.source_code = 'F77'
				and r.request_id like 'EY1746%'
				and substr(request_id,11,1) != 'S'
				and r.status != 'X'
				and substr(r.request_id,1,6) = asn.loc_id
			union
			select
				rtrim(c.nsn) nsn,
				rtrim(r.request_id) request_id,
				r.created_datetime,
				r.qty_requested,
				asn.loc_sid,
				rtrim(r.prime) prime
			from 
				req1 r,
				cat1 c,
				(select
					decode(asn1.loc_type,'TMP',asn2.loc_sid,asn1.loc_sid) loc_sid,
					decode(asn1.loc_type,'TMP',asn2.loc_id,asn1.loc_id ) loc_id
				from
					amd_spare_networks asn1,
					amd_spare_networks asn2
				where
					asn1.mob = asn2.loc_id(+)) asn
			where
				r.prime = c.part
				and r.nsn is not null
				and c.source_code = 'F77'
				and r.request_id like 'EY1213%'
				and substr(request_id,11,1) != 'S'
				and r.status != 'X'
				and substr(r.request_id,1,6) = asn.loc_id
			union
			select
				rtrim(c.nsn) nsn,
				rtrim(r.request_id) request_id,
				r.created_datetime,
				r.qty_requested,
				asn.loc_sid,
				rtrim(r.prime) prime
			from
				req1 r,
				cat1 c,
				(select
					decode(asn1.loc_type,'TMP',asn2.loc_sid,asn1.loc_sid) loc_sid,
					decode(asn1.loc_type,'TMP',asn2.loc_id ,asn1.loc_id ) loc_id
				from
					amd_spare_networks asn1,
					amd_spare_networks asn2
				where
					asn1.mob = asn2.loc_id(+)) asn
			where
				r.prime = c.part
				and r.nsn is not null
				and c.source_code = 'F77'
				and r.request_id like 'EY8780%'
				and r.status != 'X'
				and substr(r.request_id,1,6) = asn.loc_id
			order by
				1;

		loadNo    number;
		nsiSid    number;
		nsnAmd    varchar2(20);
	begin
		loadNo := amd_utils.GetLoadNo('REQ1','AMD_DEMANDS');

		for rec in demandCur loop

			nsnAmd := amd_utils.FormatNsn(rec.nsn,'AMD');

			insert into amd_bssm_source
			(
				requisition_no,
				requisition_date,
				quantity,
				loc_sid,
				nsn
			)
			values
			(
				rec.request_id,
				rec.created_datetime,
				rec.qty_requested,
				rec.loc_sid,
				nsnAmd
			);
			
			begin
				nsiSid := amd_utils.GetNsiSid(pPart_no=>rec.prime);

				insert into amd_demands
				( 
					doc_no, 
					doc_date, 
					nsi_sid,
					loc_sid, 
					quantity, 
					action_code,
					last_update_dt
				) 
				values
				( 
					rec.request_id,			 
					rec.created_datetime,			 
					nsiSid,
					rec.loc_sid,  
					rec.qty_requested,
					amd_defaults.INSERT_ACTION,
					sysdate
				);
			exception
				when no_data_found then
					null;      -- nsiSid not found generates this, just ignore
				when others then
					amd_utils.InsertErrorMsg(loadNo,'AMD_DEMAND.LoadBascUkDemands',
							'Exceptions: OTHERS','insert into amd_demands',null,sysdate,
							pMsg=>substr(sqlerrm,1,2000));
			end;
					
		end loop;

	end;

end amd_demand;
/
