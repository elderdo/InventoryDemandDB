DROP PACKAGE BODY AMD_OWNER.AMD_FROM_BSSM_PKG;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.AMD_FROM_BSSM_PKG AS
    /*
	    PVCS Keywords

       $Author:   zf297a  $
     $Revision:   1.12  $
         $Date:   Jun 09 2006 11:20:30  $
     $Workfile:   amd_from_bssm_pkg.pkb  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_from_bssm_pkg.pkb-arc  $	  *

      Rev 1.12   Jun 09 2006 11:20:30   zf297a
   Implemented version + used writeMsg for all loadAmd... public procedures

      Rev 1.11   Jun 09 2006 10:29:00   zf297a
   got rid of cannot convert message going to amd_load_details

      Rev 1.10   Dec 06 2005 09:42:40   zf297a
   Fixed display of sysdate in errorMsg - changed to MM/DD/YYYY HH:MM:SS

      Rev 1.9   Aug 04 2005 14:35:44   zf297a
   Changed all queries using lock_sid to use a character string so it will search via the index.

      Rev 1.8   Jun 20 2005 15:11:50   c970183
   fixed update of criticality (it is a number in amd_national_stock_items)

      Rev 1.7   May 17 2005 10:08:20   c970183
   Updated InsertErrorMessage to new interface

      Rev 1.6   May 06 2005 07:31:18   c970183
   changed dla_warehouse_stcok to current_backorder fro amd_national_stock_items.  added PVCS keywords
		  */
	   ERRSOURCE constant varchar2(20) := 'AmdFromBssmPkg';
	   NOT_ACCEPTABLE_BSSM_PLTP_REC exception;


	procedure writeMsg(
				pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
				pError_location IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
				pKey1 IN VARCHAR2 := '',
				pKey2 IN VARCHAR2 := '',
				pKey3 IN VARCHAR2 := '',
				pKey4 in varchar2 := '',
				pData IN VARCHAR2 := '',
				pComments IN VARCHAR2 := '')  IS
	BEGIN
		Amd_Utils.writeMsg (
				pSourceName => 'amd_from_bssm_pkg',
				pTableName  => pTableName,
				pError_location => pError_location,
				pKey1 => pKey1,
				pKey2 => pKey2,
				pKey3 => pKey3,
				pKey4 => pKey4,
				pData    => pData,
				pComments => pComments);
	end writeMsg ;

		procedure errorMsg(
						sqlFunction in varchar2,
						tableName in varchar2,
						errorLocation in number,
						key1 in varchar2 := '',
				 		key2 in varchar2 := '',
						key3 in varchar2 := '',
						key4 in varchar2 := '',
						key5 in varchar2 := '',
						keywordvaluepairs in varchar2 := '') is
		begin
			rollback;
			amd_utils.inserterrormsg (
					pload_no => amd_utils.getloadno(
							psourcename => sqlfunction,
							ptablename  => tablename),
					pdata_line_no => errorlocation,
					pdata_line    => 'amd_from_bssm_pkg',
					pkey_1 => key1,
					pkey_2 => key2,
					pkey_3 => key3,
					pkey_4 => key4,
					pkey_5 => key5 || ' ' || to_char(sysdate,'MM/DD/YYYY HH:MM:SS') ||
							   ' ' || keywordvaluepairs,
					pcomments => sqlfunction || '/' || tablename || ' sqlcode('||sqlcode||') sqlerrm('||sqlerrm||')');
			commit;
			return ;
		end errorMsg;

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
				null ; -- if out of range return null
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
			   itemType := pItemType; -- cannot convert return what was passed
			end if;
			return itemType;
	   end ConvertItemType;

       function GetCurrentBssmNsn(pNsn bssm_parts.nsn%type) return bssm_parts.nsn%type is
	   		cursor bssmNsn_cur(pNsiSid amd_nsns.nsi_sid%type) is
				   select bp.nsn
				   	   from bssm_parts bp, amd_nsns an
				   	   where bp.nsn = an.nsn and
					   		 bp.lock_sid = '0' and
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
						 bp.lock_sid = '0';
						 /*
						 (bp.repair_indicator is not null or
						  bp.replacement_indicator is not null or
						  );*/
				cnt number := 0 ;
	   begin
			writeMsg(pTableName => 'amd_part_locs', pError_location => 10,
					pKey1 => 'LoadAmdBaseFromBssmRaw',
					pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	   		for bssmBaseRec in bssmBase_cur
			loop
				begin
					 UpdateAmdPartLocs(bssmBaseRec);
					 cnt := cnt + 1 ;
				exception
				 	 when others then
					 	  errorMsg(sqlFunction => 'update', tablename => 'amd_part_locs',
						  	errorLocation => 10,
						  	key1 => bssmBaseRec.nsn, key2 => bssmBaseRec.sran) ;
						  raise ;
				end;
			end loop;
			writeMsg(pTableName => 'amd_part_locs', pError_location => 20,
					pKey1 => 'LoadAmdBaseFromBssmRaw',
					pKey2 => 'cnt=' || to_char(cnt),
					pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
			commit ;
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
						  lock_sid = '0';
				 UpdateAmdPartLocs(bssmBaseRec);
	   exception
	   			when no_data_found then
					 null;
				when others then
					 errorMsg(sqlFunction => 'select', tablename => 'bssmBaseRec',
					 	ErrorLocation => 20,
					 	key1 => vNsn, key2 => pSran) ;
					 raise ;
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
				   		 bp.lock_sid = '0' 	 and
						 bp.nsn = an.nsn	 and
						 an.nsi_sid = ansi.nsi_sid;
			cnt number := 0 ;
	   begin
			writeMsg(pTableName => 'amd_national_stock_items', pError_location => 30,
					pKey1 => 'LoadAmdPartFromBssmRaw',
					pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
	   		for bssmPartRec in bssmParts_cur
			loop
				begin
					 UpdateAmdNsi(bssmPartRec);
					 cnt := cnt + 1 ;
				exception
					 when others then
					 	  errorMsg(sqlFunction => 'update', tablename => 'amd_national_stock_items',
						    errorLocation => 30,
						  	key1 => bssmPartRec.nsn) ;
						  raise ;
				end;
			end loop;
			writeMsg(pTableName => 'amd_national_stock_items', pError_location => 40,
					pKey1 => 'LoadAmdPartFromBssmRaw',
					pKey2 => 'cnt=' || to_char(cnt),
					pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
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
					and lock_sid = '0';
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
			cnt number := 0 ;
	   begin
			writeMsg(pTableName => 'amd_part_loc_time_periods', pError_location => 50,
					pKey1 => 'LoadAmdPartLocTimePeriods',
					pKey2 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
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
					cnt := cnt + 1 ;
				exception
					when NOT_ACCEPTABLE_BSSM_PLTP_REC then
						 -- missing info which is not nullable for amd counterpart
						 null;
					when others then
					 	  errorMsg(sqlFunction => 'insert', tablename => 'amd_part_loc_time_periods',
						    errorLocation => 40,
						    key1 => partLocRec.nsn, key2 => partLocRec.nsi_sid, key3 => partLocRec.loc_sid) ;
						  raise ;
				end;
			end loop;
			writeMsg(pTableName => 'amd_part_loc_time_periods', pError_location => 60,
					pKey1 => 'LoadAmdPartLocTimePeriods',
					pKey2 => 'cnt=' || to_char(cnt),
					pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
			commit;
	   end LoadAmdPartLocTimePeriods;


	   procedure UpdateAmdNsi (pBssmPartsRec bssm_parts%rowtype) is
	   		nsiSid amd_national_stock_items.nsi_sid%type;
			procedure validateData is
					  item amd_national_stock_items%rowtype ;
					  line_no number := 0 ;
			begin
				 line_no := line_no + 1; item.add_increment       := pBssmPartsRec.add_increment ;
				 line_no := line_no + 1; item.amc_base_stock      := pBssmPartsRec.amc_base_stock ;
				 line_no := line_no + 1; item.amc_days_experience := pBssmPartsRec.amc_days_experience ;
				 line_no := line_no + 1; item.amc_demand		  := pBssmPartsRec.amc_demand ;
				 line_no := line_no + 1; item.capability_requirement := pBssmPartsRec.capability_requirement ;
				 line_no := line_no + 1; item.condemn_avg 	  		 := pBssmPartsRec.condemn ;
				 line_no := line_no + 1; item.criticality 	  		 := pBssmPartsRec.criticality  ;
				 line_no := line_no + 1; item.demand_variance 	  	 := pBssmPartsRec.demand_variance ;
				 line_no := line_no + 1; item.dla_demand 	  		 := pBssmPartsRec.dla_demand ;
				 line_no := line_no + 1; item.current_backorder 	 := pBssmPartsRec.current_backorder ;
				 line_no := line_no + 1; item.min_purchase_quantity  := pBssmPartsRec.min_purchase_quantity ;
				 line_no := line_no + 1; item.nrts_avg 	 			 := pBssmPartsRec.nrts ;
				 line_no := line_no + 1; item.rts_avg 	  			 := pBssmPartsRec.rts ;
				 line_no := line_no + 1; item.ru_ind 	  			 := pBssmPartsRec.ru_ind ;
				 line_no := line_no + 1; item.time_to_repair_on_base_avg := pBssmPartsRec.on_base_turnaround ;
				 line_no := line_no + 1; item.user_comment 	  		 := pBssmPartsRec.user_comment ;
			exception when others then
					  errorMsg(sqlFunction => 'validate', tablename => 'amd_national_stock_items',
					    errorLocation => 50,
					  	key1 => to_char(line_no) ) ;
					  raise ;
			end validateData ;

	   begin
	   			-- will throw exception if not found
		    validateData ;
	   		nsiSid := amd_utils.GetNsiSid(pNsn => pBssmPartsRec.nsn);
	   		update amd_national_stock_items
					 set
					 		add_increment  = pBssmPartsRec.add_increment,
					 		amc_base_stock = pBssmPartsRec.amc_base_stock,
							amc_days_experience = pBssmPartsRec.amc_days_experience,
							amc_demand = pBssmPartsRec.amc_demand,
							capability_requirement = pBssmPartsRec.capability_requirement,
							condemn_avg = pBssmPartsRec.condemn,
							criticality = pBssmPartsRec.criticality,
							demand_variance = pBssmPartsRec.demand_variance,
							dla_demand = pBssmPartsRec.dla_demand,
							current_backorder = pBssmPartsRec.current_backorder,
							-- fedc_cost = pBssmPartsRec.fedc_cost,
							-- 			 now mic pulled from amd_l67_tmp directly
					 		-- mic_code_lowest = pBssmPartsRec.mic_code,
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
			 when others then
				errorMsg(sqlFunction => 'update', tablename => 'amd_national_stock_items',
				    errorLocation => 60,
					key1 => nsiSid) ;
			    raise ;

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
			when others then
				errorMsg(sqlFunction => 'update', tablename => 'amd_part_locs',
					errorLocation => 70,
					key1 => nsiSid, key2 => locSid) ;
				raise ;

	   end UpdateAmdPartLocs;

	procedure version is
	begin
		 writeMsg(pTableName => 'amd_from_bssm_pkg',
		 		pError_location => 80, pKey1 => 'amd_from_bssm_pkg', pKey2 => '$Revision:   1.12  $') ;
	end version ;

END AMD_FROM_BSSM_PKG;
/


DROP PUBLIC SYNONYM AMD_FROM_BSSM_PKG;

CREATE PUBLIC SYNONYM AMD_FROM_BSSM_PKG FOR AMD_OWNER.AMD_FROM_BSSM_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_FROM_BSSM_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_FROM_BSSM_PKG TO AMD_WRITER_ROLE;
