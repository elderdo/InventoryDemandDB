CREATE OR REPLACE package amd_reqs_pkg as
	   -------------------------------------------------------------------
	   --  Date	  		  By			History
	   --  ----			  --			-------
	   --  12/10/01		  ks			initial implementation
	   -------------------------------------------------------------------
	procedure LoadAmdReqs;
end;
/
CREATE OR REPLACE package body amd_reqs_pkg is
	ERRSOURCE constant varchar2(20) := 'amd_req_pkg';
	procedure LoadAmdReqs is
		cursor req1_cur is
			   select
			   		  req1.request_id,
			   		  req1.qty_due,
					  req1.qty_requested,
					  req1.qty_canc,
					  req1.created_datetime,
					  req1.need_date,
					  req1.request_priority,
					  asn.loc_sid,
					  asp.nsn
			   from
			   		  req1,
			   		  amd_spare_parts asp,
					  amd_spare_networks asn
			   where
			   		  req1.status in ('U', 'O', 'R') and
			   		  asn.loc_id = substr(request_id, 1, 6) and
			   		  rtrim(req1.prime) = asp.part_no	and
					  asn.action_code != amd_defaults.DELETE_ACTION and
					  asp.action_code != amd_defaults.DELETE_ACTION;
		nsiSid amd_national_stock_items.nsi_sid%type;
		qtyOrdered number := 0;

	begin
		 for req in req1_cur
		 loop
		 	 begin
			 	 nsiSid := amd_utils.GetNsiSid(pNsn => req.nsn);
				 qtyOrdered := nvl(req.qty_requested, 0) - nvl(req.qty_canc, 0);
				 /* requested, if more cancellations than requests,
				   zero out at this point */
				 if (qtyOrdered < 0) then
				 	qtyOrdered := 0;
				 end if;
				 /* requested to change from need_date to created_date 12/13/01 */
			 	 insert into amd_reqs
				 (
				  	req_id,
					loc_sid,
					nsi_sid,
					quantity_ordered,
					quantity_due,
					need_date,
					priority,
					action_code,
					last_update_dt
				 )
				 values
				 (
				  	rtrim(req.request_id),
					req.loc_sid,
					nsiSid,
					qtyOrdered,
					req.qty_due,
					req.created_datetime,
					req.request_priority,
					amd_defaults.INSERT_ACTION,
					sysdate
				 );
			  exception
			  	 when no_data_found then
				 	  -- thrown by getNsiSid, can ignore
				 	  null;
			  	 when others then
				 	  amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'loadAmdReqs'),req.request_id, nsiSid,req.loc_sid,null,null, substr(SQLCODE || ' ' || SQLERRM,1, 2000));

			  end;
		 end loop;
		 commit;
	end loadAmdReqs;
begin
	null;
end;
/

