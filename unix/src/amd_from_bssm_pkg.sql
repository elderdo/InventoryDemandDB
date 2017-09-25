CREATE OR REPLACE PACKAGE AMD_FROM_BSSM_PKG AS

   	   -------------------------------------------------------------------
	   --  Date	  		  By			History
	   --  ----			  --			-------
	   --  10/10/01		  ks			initial implementation
	   -------------------------------------------------------------------


 	   	 -- those values where bssm is currently the only source
	   procedure LoadAmdPartFromBssmRaw;
	   procedure LoadAmdBaseFromBssmRaw;
	   procedure LoadAmdPartFromBssmRaw(pNsn bssm_parts.nsn%type);
   	   procedure LoadAmdBaseFromBssmRaw(pNsn bssm_base_parts.nsn%type,pSran bssm_base_parts.sran%type);
	   procedure LoadAmdPartLocTimePeriods;
	   procedure UpdateAmdNsi(pBssmPartsRec bssm_parts%rowtype);
	   procedure UpdateAmdPartLocs (pBssmBaseRec bssm_base_parts%rowtype);
	   function GetCurrentBssmNsn(pNsn bssm_parts.nsn%type) return bssm_parts.nsn%type;
       function ConvertCriticality(pCriticality bssm_parts.criticality%type) return varchar2;
	   function ConvertItemType(pItemType bssm_parts.item_type%type) return amd_national_stock_items.item_type%type;
	   function GetLocSid(pLocId amd_spare_networks.loc_id%type) return amd_spare_networks.loc_sid%type;
	   AMD_WAREHOUSE_LOCID constant varchar2(30) := 'CTLATL';
	   BSSM_WAREHOUSE_SRAN constant varchar2(1) := 'W';
END AMD_FROM_BSSM_PKG;
/
CREATE OR REPLACE PACKAGE BODY AMD_FROM_BSSM_PKG AS
	   ERRSOURCE constant varchar2(20) := 'AmdFromBssmPkg';
	   NOT_ACCEPTABLE_BSSM_PLTP_REC exception;


	   function ConvertCriticality(pCriticality bssm_parts.criticality%type) return varchar2 is
	   		-- criticality is bssm is a number, criticality in amd is 1 char
			criticality varchar2(1) := null;
	   begin
	   		-- from Tony Maingot of i2 - if criticality null, then consider as 'M'.
			-- however, will do this on outbound thru tmapi and leave as null in db.
			if (pCriticality is null) then
			    criticality	:= null;
	   		elsif (pCriticality <= .33 and pCriticality >= 0) then
			   	criticality := 'M';
			elsif (pCriticality <= .67) then
				criticality := 'D';
			elsif (pCriticality <= 1.0) then
				criticality := 'C';
			else
					-- if out of range return null
				amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'ConvertCriticality'),null, null, null, null, null, 'cannot convert criticality from bssm <' || pCriticality || '> using null for now');
			end if;
			return criticality;
	   end ConvertCriticality;

	   function ConvertItemType(pItemType bssm_parts.item_type%type) return amd_national_stock_items.item_type%type is
	   		itemType varchar2(1) := null;
	   /* -- email from laurie when asked for mapping of bssm to amd
	   	 Sent:	Thursday, October 25, 2001 2:38 PM
	   	 In AMD today, T and P are Repairable, N is Consumable.  */

	   begin
	   				-- if not listed below, return as is
			if (pItemType is null) then
			   itemType := null;
	   		elsif ( pItemType in ('P', 'T') ) then
			   itemType := 'R';
			elsif (pItemType = 'N') then
			   itemType := 'C';
			else
			   itemType := pItemType;
			   amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'ConvertItemType'),null, null, null, null, null, 'cannot convert item type from bssm <' || pItemType || '> return what was passed');
			end if;
			return itemType;
	   end ConvertItemType;

       function GetCurrentBssmNsn(pNsn bssm_parts.nsn%type) return bssm_parts.nsn%type is
	   		cursor bssmNsn_cur(pNsiSid amd_nsns.nsi_sid%type) is
				   select bp.nsn
				   	   from bssm_parts bp, amd_nsns an
				   	   where bp.nsn = an.nsn and
					   		 bp.lock_sid = 0 and
					   		 an.nsi_sid = pNsiSid
					   order by bp.nsn;
			rNsn_rec bssmNsn_cur%rowtype;
			nsiSid amd_nsns.nsi_sid%type;
	   begin
		   		-- nsn is likely to come from amd, this function will be updated when amd_nsns.creation_date
				-- usable, bssm_nsn_revisions data available, or not important as bob eberlein noted
				-- bssm_parts will contain current only.
				-- below just in case and to handle current data situation which has all versions
				-- of the "nsn", i.e. multiple bssm_parts lock_sid 0 records relate to one nsi_sid in amd.
			nsiSid := amd_utils.GetNsiSid(pNsn => pNsn);
			if (not bssmNsn_cur%ISOPEN) then
			   open bssmNsn_cur(nsiSid);
			end if;
			fetch bssmNsn_cur into rNsn_rec;
			if (bssmNsn_cur%NOTFOUND) then
			   close bssmNsn_cur;
			   raise no_data_found;
			end if;
			close bssmNsn_cur;
			return rNsn_rec.nsn;
	   end GetCurrentBssmNsn;

	   function GetLocSid(pLocId amd_spare_networks.loc_id%type) return amd_spare_networks.loc_sid%type is
	   	    locId amd_spare_networks.loc_id%type := null;
	   begin
			if (pLocId = BSSM_WAREHOUSE_SRAN) then
		       locId := AMD_WAREHOUSE_LOCID;
			else
			   locId := pLocId;
			end if;
			return amd_utils.GetLocSid(locId);
	   end GetLocSid;

	   procedure LoadAmdBaseFromBssmRaw is
	   			 -- to get all of them
	   		cursor bssmBase_cur is
				   select
				   		bp.*
				   from
				   		bssm_base_parts bp,
						amd_nsns an
				   where
				   		 bp.nsn = an.nsn   and
						 bp.lock_sid = 0;
						 /*
						 (bp.repair_indicator is not null or
						  bp.replacement_indicator is not null or
						  );*/
	   begin
	   		for bssmBaseRec in bssmBase_cur
			loop
				begin
					 UpdateAmdPartLocs(bssmBaseRec);
				exception
				 	 when others then
					 	  amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'LdAmdBaseFromBssmRaw'),bssmBaseRec.nsn, bssmBaseRec.lock_sid, null, null, null, substr(SQLCODE || ' ' || SQLERRM,1, 2000));
				end;
			end loop;
	   end LoadAmdBaseFromBssmRaw;

	   procedure LoadAmdBaseFromBssmRaw(pNsn bssm_base_parts.nsn%type, pSran bssm_base_parts.sran%type) is
	   			 bssmBaseRec bssm_base_parts%rowtype;

				 -- current bssm can have not current parts in bssm_parts,
				 vNsn bssm_base_parts.nsn%type;
	   begin
					 -- nsn can come from any direction, from bssm or from amd
					 -- still assuming bob eberlein in that his is only holding latest.
				 vNsn := GetCurrentBssmNsn(pNsn);
				 select *
				 	into bssmBaseRec
				 	from bssm_base_parts
					where nsn = vNsn and
						  sran = pSran and
						  lock_sid = 0;
				 UpdateAmdPartLocs(bssmBaseRec);
	   exception
	   			when no_data_found then
					 null;
       end LoadAmdBaseFromBssmRaw;

	   procedure LoadAmdPartFromBssmRaw is
 	   		-- bssm_parts will only have latest part, now can
			-- go thru amd_nsns table.
			-- bob eberlein said only current part will be in bssm_parts
			-- so should not be a problem.  for foolproof, would go to
			-- bssm_nsn_revisions, but currently there is no data.
			/*
	   		 cursor bssmParts_cur is
				   select
				   		  bp.*
 				   from
				   		 bssm_parts bp,
				   		 amd_national_stock_items ansi,
						 amd_nsns an
				   where
				   		 bp.lock_sid = 0 	 and
						 bp.nsn = an.nsn	 and
						 bp.nsn = GetCurrentBssmNsn(an.nsn) and
						 an.nsi_sid = ansi.nsi_sid; */
			cursor bssmParts_cur is
				   select
				   		  bp.*
 				   from
				   		 bssm_parts bp,
				   		 amd_national_stock_items ansi,
						 amd_nsns an
				   where
				   		 bp.lock_sid = 0 	 and
						 bp.nsn = an.nsn	 and
						 an.nsi_sid = ansi.nsi_sid;
	   begin
	   		for bssmPartRec in bssmParts_cur
			loop
				begin
					 UpdateAmdNsi(bssmPartRec);
				exception
					 when others then
					 	  amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'LdAmdPartFromBssmRaw'),bssmPartRec.nsn, bssmPartRec.lock_sid, null, null, null, substr(SQLCODE || ' ' || SQLERRM,1, 2000));
				end;
			end loop;
			commit;
	   end LoadAmdPartFromBssmRaw;


   	   procedure LoadAmdPartFromBssmRaw(pNsn bssm_parts.nsn%type) is
	   			 bssmPartRec bssm_parts%rowtype;

				 -- current bssm can have not current parts in bssm_parts,
				 vNsn bssm_parts.nsn%type;
	   begin
					 -- nsn can come from any direction, from bssm or from amd
					 -- still assuming bob eberlein in that his is only holding latest.
				 vNsn := GetCurrentBssmNsn(pNsn);
				 select *
				 	into bssmPartRec
				 	from bssm_parts
					where nsn = vNsn
					and lock_sid = 0;
				 UpdateAmdNsi(bssmPartRec);
	   exception
	   			when no_data_found then
					 null;
       end LoadAmdPartFromBssmRaw;


	   procedure LoadAmdPartLocTimePeriods is
	   		cursor partLoc_cur is
				   select apl.nsi_sid, apl.loc_sid, bpltp.*
				   from
				   		bssm_part_loc_time_periods bpltp,
						amd_nsns an,
						amd_part_locs apl,
						amd_spare_networks asn
				   where
				   		 bpltp.nsn = an.nsn 	   and
						 an.nsi_sid = apl.nsi_sid  and
						 apl.loc_sid = asn.loc_sid and
						 asn.loc_id = decode(bpltp.sran, BSSM_WAREHOUSE_SRAN, AMD_WAREHOUSE_LOCID, bpltp.sran);
	   begin
	   		for partLocRec in partLoc_cur
			loop
				begin
					 -- bssm_part_loc_time_periods allows nullable fields
					 -- amd_part_loc_time_periods has no fields nullable

					 if (partLocRec.time_period_end   is null or
					 	 partLocRec.reorder_point 	  is null or
						 partLocRec.reorder_quantity  is null) then
					 	 	raise NOT_ACCEPTABLE_BSSM_PLTP_REC;
					 end if;
					 if (partLocRec.last_update_date is null) then
					 	 partLocRec.last_update_date := SYSDATE;
					 end if;
					 insert into amd_part_loc_time_periods
						 		(nsi_sid,
								 loc_sid,
								 time_period_start,
								 time_period_end,
								 reorder_point,
								 reorder_quantity,
								 se_target,
								 action_code,
								 last_update_dt)
							 values(
							 	 partLocRec.nsi_sid,
								 partLocRec.loc_sid,
						 		 partLocRec.time_period_start,
								 partLocRec.time_period_end,
								 partLocRec.reorder_point,
						 		 partLocRec.reorder_quantity,
								 partLocRec.se_target,
						 		 amd_defaults.INSERT_ACTION,
						 		 partLocRec.last_update_date);
				exception
					when NOT_ACCEPTABLE_BSSM_PLTP_REC then
						 -- missing info which is not nullable for amd counterpart
						 null;
					when others then
						 amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'partloctimeperiods'),partLocRec.nsi_sid, partLocRec.loc_sid, partLocRec.time_period_start, null, null, substr(SQLCODE || ' ' || SQLERRM,1, 2000));
				end;
			end loop;
			commit;
	   end LoadAmdPartLocTimePeriods;


	   procedure UpdateAmdNsi (pBssmPartsRec bssm_parts%rowtype) is
	   		nsiSid amd_national_stock_items.nsi_sid%type;
	   begin
	   			-- will throw exception if not found
	   		nsiSid := amd_utils.GetNsiSid(pNsn => pBssmPartsRec.nsn);
	   		update amd_national_stock_items
					 set
					 		add_increment  = pBssmPartsRec.add_increment,
					 		amc_base_stock = pBssmPartsRec.amc_base_stock,
							amc_days_experience = pBssmPartsRec.amc_days_experience,
							amc_demand = pBssmPartsRec.amc_demand,
							capability_requirement = pBssmPartsRec.capability_requirement,
							condemn_avg = pBssmPartsRec.condemn,
							criticality = convertCriticality(pBssmPartsRec.criticality),
							demand_variance = pBssmPartsRec.demand_variance,
							dla_demand = pBssmPartsRec.dla_demand,
							dla_warehouse_stock = pBssmPartsRec.dla_warehouse_stock,
							-- fedc_cost = pBssmPartsRec.fedc_cost,
					 		mic_code_lowest = pBssmPartsRec.mic_code,
							min_purchase_quantity = pBssmPartsRec.min_purchase_quantity,
							nrts_avg = pBssmPartsRec.nrts,
							rts_avg = pBssmPartsRec.rts,
							ru_ind = pBssmPartsRec.ru_ind,
							time_to_repair_on_base_avg = pBssmPartsRec.on_base_turnaround,
							user_comment = pBssmPartsRec.user_comment,
							last_update_dt = SYSDATE
			 where  nsi_sid = nsiSid;
	   exception
	   		 when no_data_found then
			 	  -- cannot find nsiSid
			 	  null;
	   end UpdateAmdNsi;


	   procedure UpdateAmdPartLocs(pBssmBaseRec bssm_base_parts%rowtype) is
	   	   		nsiSid amd_national_stock_items.nsi_sid%type;
				locSid amd_spare_networks.loc_sid%type;
	   begin
	   			-- nsi_sid will throw exception if not found
	   		nsiSid := amd_utils.GetNsiSid(pNsn => pBssmBaseRec.nsn);
			locSid := GetLocSid(pBssmBaseRec.sran);
			if (locSid is not null) then
			    update amd_part_locs
					   set repair_level_code = pBssmBaseRec.repair_indicator,
					   	   removal_ind 		 = pbssmbaserec.replacement_indicator,
						  -- 		 will come from ramp
						  -- rsp_on_hand  	 = pBssmBaseRec.rsp_on_hand,
  						  -- rsp_objective 	 = pBssmBaseRec.rsp_objective,
						   order_cost 		 = pBssmBaseRec.order_cost,
						   holding_cost 	 = pBssmBaseRec.holding_cost,
						   backorder_fixed_cost = pBssmBaseRec.backorder_fixed_cost,
						   backorder_variable_cost = pBssmBaseRec.backorder_variable_cost,
						   last_update_dt = SYSDATE
				where
					   nsi_sid = nsiSid		 and
				   	   loc_sid = locSid;
			end if;
	   exception
	   		when no_data_found then
 			 	  -- cannot find nsiSid
				 null;
	   end UpdateAmdPartLocs;

END AMD_FROM_BSSM_PKG;
/

