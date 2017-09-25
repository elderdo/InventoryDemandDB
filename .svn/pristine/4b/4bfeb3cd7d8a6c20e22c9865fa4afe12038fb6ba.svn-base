CREATE OR REPLACE PACKAGE AMD_PART_LOCS_LOAD_PKG
AS
  	   -------------------------------------------------------------------
	   --  Date	  		  By			History
	   --  ----			  --			-------
	   --  10/10/01		  ks			initial implementation
	   --  12/11/01		  dse			Added named param for amd_preferred_pkg.GetUnitCost(.....
	   -------------------------------------------------------------------
	   -- added ROR to previous part_locations, since table now combines old amd_repair_levels
	   -- too, which had MOB, FSL, ROR. also adding each part to warehouse as part/loc list since
	   -- child table amd_part_loc_time_periods may provide ROP/ROQ info for warehouse, especially
	   -- for consumables.
  OFFBASE_LOCID constant varchar2(30) := 'OFFBASE';
  COMMIT_AFTER constant number := 10000;
  -- data fields match cursor and database field names
  -- wrm relates to rsp
  type rampData_rec is record (
  	   date_processed date,
	   avg_repair_cycle_time number,
	   percent_base_condem number,
	   percent_base_repair number,
	   wrm_level number,
	   wrm_balance number );
  function GetRampData(pNsn ramp.nsn%type, pLocId amd_spare_networks.loc_id%type) return rampData_rec;
  function GetRampData(pNsn ramp.nsn%type, pLocSid amd_spare_networks.loc_sid%type) return rampData_rec;
  procedure LoadAmdPartLocations;
END AMD_PART_LOCS_LOAD_PKG;
/
CREATE OR REPLACE PACKAGE BODY AMD_PART_LOCS_LOAD_PKG
IS
  	ERRSOURCE constant varchar2(20) := 'amdpartlocsloadpkg';

	function GetAmdNsiRec(pNsiSid amd_national_stock_items.nsi_sid%type) return amd_national_stock_items%rowtype is
			amdNsiRec amd_national_stock_items%rowtype := null;
		begin
	    	select *
			into amdNsiRec
			from amd_national_stock_items
			where nsi_sid = pNsiSid;
			return amdNsiRec;
		exception
			when no_data_found then
				 return amdNsiRec;
	end GetAmdNsiRec;

	/* function GetOffBaseRepairCost, logic same as previous load version */
	function  GetOffBaseRepairCost(pPartNo char) return amd_part_locs.cost_to_repair%type is
		offBaseRepairCost   amd_part_locs.cost_to_repair%type := null;
		--
		--    Use only PART   number because POI1 does not have Cage Code.
		--
	begin
		select
			sum(nvl(ext_price,0))/count(*)
		into offBaseRepairCost
		from poi1
		where
			part = pPartNo
			and substr(ccn,1,5) in ( select ccn_prefix from amd_ccn_prefix )
			and nvl(ext_price,0) > 0;
		return(offBaseRepairCost);
	exception
		when no_data_found then
			 return null;
	end GetOffBaseRepairCost;

	/* function get_off_base_tat, logic same as previous load version
	   removed offbasediag time from previous version */
	function GetOffBaseTurnAround (pPartno char) return amd_part_locs.time_to_repair%type is
		-- goldpart      char(50);
		offBaseTurnAroundTime amd_part_locs.time_to_repair%type;

	begin
		select
			avg( completed_docdate  - created_docdate)
		into offBaseTurnAroundTime
		from ord1
		where
			part = pPartNo
			and nvl(action_taken,'*') in ('A', 'B', 'E', 'G', '*' )
			and order_type = 'J'
			and completed_docdate is not null
		group by part;
		return offBaseTurnAroundTime;
	exception
		when no_data_found then
			return null;
	end GetOffBaseTurnAround;

	function  GetOnBaseRepairCost (pPartno   varchar2) return   number is

		--
		-- on base repair cost is to be calculated using data
		-- from tmp_lccost table.
		-- this table will be loaded on a monthly basis from rmads and the result
		-- are stored in amd_on_base_repair_costs.
		--
		-- formular:
		--
		-- on base repair cost = average mhr * average dollars($20)
		--
		-- where average mhr is calculated by add up the manhours for each ajcn,
		--  and then divide by the   number of total ajcn for the part.
		--
		--  average dollars is default to $20 per hour at this time.
		--
		--  note: if no part found, default the on base repair cost to $40.00
		--
		onBaseRepairCost number;
	begin
		begin
			select
				on_base_repair_cost
			into onBaseRepairCost
			from amd_on_base_repair_costs
			where part_no = pPartno;
		exception
			when no_data_found then
				return null;
		end;
		return onBaseRepairCost;
	end GetOnBaseRepairCost;

	function GetRampData(pNsn ramp.nsn%type, pLocSid amd_spare_networks.loc_sid%type) return rampData_rec is
		rampData rampData_rec := null;
		locId amd_spare_networks.loc_id%type;
	begin
		locId := amd_utils.GetLocId(pLocSid);
		if (locId is null) then
		    return rampData;
		else
			return GetRampData(pNsn, locId);
		end if;
	end GetRampData;

   	function GetRampData(pNsn ramp.nsn%type, pLocId amd_spare_networks.loc_id%type) return rampData_rec is
	    cursor rampData_cur (pNsn ramp.nsn%type, pLocId amd_spare_networks.loc_id%type) is
			select
			   date_processed, avg_repair_cycle_time, percent_base_condem, percent_base_repair,
			   wrm_level, wrm_balance
			from
			   ramp
			where
			   current_stock_number = pNsn and
			   substr(sc, 8, 6) = pLocId;
		nsn ramp.current_stock_number%type;
		rampData rampData_cur%rowtype := null;
		-- though currently ramp does not return more than one record, design
		-- of ramp table allows. current_stock_number is not part of key.
		-- use explicit cursor just in case.

 	begin
		nsn := amd_utils.FormatNsn(pNsn, 'GOLD');
	  	if (not rampData_cur%isOpen) then
		   open rampData_cur(nsn, pLocId);
		end if;
		fetch rampData_cur into
			  rampData;
		close rampData_cur;
		return rampData;
  	end GetRampData;

	--
	-- Select all MOB's from AMD then
	-- remove MOB's from BSSM that have 'N''s
	-- and add FSL's from BSSM that have 'Y''s

	-- lifted from current version, modified to go to
	-- amd_national_stock_items table and add 'OFFBASE' parts.
	-- to minimize recoding, made cursor since amd_part_locs needs nsi and not nsn.

	-- Bob Eberlein's note says that bssm will only carry the current part in
	-- bssm_parts (i.e. not all versions of nsn like nsl, ncz, nsn).
	-- implies won't need to determine which one is "live" in his system
	-- and negates the potential for 3 "nsns" in bssm_parts relating to one nsi_sid.
	-- just pull nsi_sid by amd_nsns, in case bssm_parts one step behind (load
	-- currently less frequent than amd load).

	procedure LoadAmdPartLocations is
			amdNsiRec amd_national_stock_items%rowtype := null;
			amdPartLocsRec amd_part_locs%rowtype := null;
			unitCost amd_spare_parts.unit_cost%type := null;
			locId amd_spare_networks.loc_id%type := null;
			partBaseCleanRec amd_cleaned_from_bssm_pkg.partBaseFields := null;
			rampData rampData_rec;
			countRecs number := 0;
		cursor partLocsMobList_cur is
			    --
			    -- MOB SELECTION LOGIC
			    --
				--
				-- Select all MOB's from AMD
				--
				-- the order by is to speed up processing of records.
				-- some info is not location dependent currently and therefore
				-- does not have to be re-retrieved.  saves 80% time for 97k+ records.
				-- based on substr if smr null or < 3 chars will be not part of 1st select,
				-- though mdd would.  confirmed with laurie for now, consistent with previous load.
				select * from (
					select
						ansi.nsi_sid,
						asn.loc_sid
					from
						amd_national_stock_items ansi,
						amd_spare_networks asn
					where
						asn.loc_type = 'MOB'
						and substr(amd_preferred_pkg.GetSmrCode(ansi.nsn),3,1) != 'D'
						and ansi.action_code != amd_defaults.DELETE_ACTION
						and asn.action_code != amd_defaults.DELETE_ACTION
					--
					-- MOB EXCLUSION LOGIC
					--
					minus
					((select
						-- bbp.nsn
						an.nsi_sid,
						asn.loc_sid
					from
						bssm_base_parts bbp,
						amd_spare_networks asn,
						amd_nsns an
					where
						lock_sid         = 0
						and bbp.nsn = an.nsn
						and bbp.sran     = asn.loc_id
						and asn.loc_type = 'MOB'
						and bbp.replacement_indicator = 'N'
						and asn.action_code != amd_defaults.DELETE_ACTION
					minus
					select
						-- bbp.nsn,
						an.nsi_sid,
						asn.loc_sid
					from
						bssm_base_parts bbp,
						amd_spare_networks asn,
						amd_nsns an
					where
						lock_sid         = 2
						and bbp.nsn = an.nsn
						and bbp.sran     = asn.loc_id
						and asn.loc_type = 'MOB'
						and asn.action_code != amd_defaults.DELETE_ACTION
						and bbp.replacement_indicator = 'Y')

					union
					select
						-- bbp.nsn,
						an.nsi_sid,
						asn.loc_sid
					from
						bssm_base_parts bbp,
						amd_spare_networks asn,
						amd_nsns an
					where
						lock_sid         = 2
						and bbp.nsn = an.nsn
						and bbp.sran     = asn.loc_id
						and asn.loc_type = 'MOB'
						and bbp.replacement_indicator = 'N'
						and asn.action_code != amd_defaults.DELETE_ACTION)
				) order by nsi_sid;

				--
				-- FSL SELECTION LOGIC
				--
				--
				-- Select valid combo's using capability logic and valid in
				-- locks 0 and 2
				--
		cursor partLocsFslList_cur is
			   select * from (
				(select
					-- bp.nsn,
					ansi.nsi_sid,
					asn.loc_sid
				from
					bssm_parts bp,
					bssm_bases bb,
					amd_spare_networks asn,
					amd_national_stock_items ansi,
					amd_nsns an
				where
					bp.capability_requirement in (1,2,3)
					and bp.lock_sid         = 0
					and bb.lock_sid         = 0
					and bb.capabilty_level <= bp.capability_requirement
					and bb.capabilty_level >  0
					and bb.sran             = asn.loc_id
					and asn.loc_type        = 'FSL'
					-- and bp.nsn              = ansi.nsn
					and bp.nsn				= an.nsn
					and an.nsi_sid			= ansi.nsi_sid
					and ansi.action_code != amd_defaults.DELETE_ACTION
					and asn.action_code != amd_defaults.DELETE_ACTION
				union
				select
					 -- bbp.nsn,
					ansi.nsi_sid,
					asn.loc_sid
				from
					bssm_base_parts bbp,
					amd_spare_networks asn,
					amd_national_stock_items ansi,
					amd_nsns an
				where
					lock_sid         in (0,2)
					and bbp.sran     = asn.loc_id
					and asn.loc_type = 'FSL'
					and asn.action_code != amd_defaults.DELETE_ACTION
					and ansi.action_code != amd_defaults.DELETE_ACTION
					and bbp.replacement_indicator = 'Y'
					and bbp.nsn      = an.nsn
					and an.nsi_sid = ansi.nsi_sid)
				--
				-- Subtract invalid combo's in locks 2 and 0
				--
				minus
				(select
					-- bbp.nsn,
					an.nsi_sid,
					asn.loc_sid
				from
					bssm_base_parts bbp,
					amd_spare_networks asn,
					amd_nsns an
				where
					lock_sid         = 2
					and bbp.sran     = asn.loc_id
					and asn.loc_type = 'FSL'
					and bbp.replacement_indicator = 'N'
					and bbp.nsn = an.nsn
					and asn.action_code != amd_defaults.DELETE_ACTION
				union
				select
					  -- bbp.nsn
					an.nsi_sid,
					asn.loc_sid
				from
					bssm_base_parts bbp,
					amd_spare_networks asn,
					amd_nsns an
				where
					lock_sid         = 0
					and bbp.sran     = asn.loc_id
					and asn.loc_type = 'FSL'
					and bbp.nsn = an.nsn
					and asn.action_code != amd_defaults.DELETE_ACTION
					and bbp.replacement_indicator = 'N'
					and not exists
						(select 'x'
						from bssm_base_parts bbp2
						where
							lock_sid      = 2
							and bbp2.sran = bbp.sran
							and bbp2.nsn  = bbp.nsn
							and bbp2.replacement_indicator = 'Y'))
				) order by nsi_sid;

		cursor partLocsOffBaseList_cur is
				select
					   ansi.nsi_sid,
					   ansi.prime_part_no,
					   asn.loc_sid
				from
					   amd_national_stock_items ansi,
					   amd_spare_networks asn
				where
					   asn.loc_id = OFFBASE_LOCID and
					   ansi.action_code != amd_defaults.DELETE_ACTION and
					   asn.action_code != amd_defaults.DELETE_ACTION;

		cursor partLocsWareHouse_cur is
			    select
					   ansi.nsi_sid,
					   asn.loc_sid
				from
					   amd_national_stock_items ansi,
					   amd_spare_networks asn
				where
					   asn.loc_id = amd_from_bssm_pkg.AMD_WAREHOUSE_LOCID and
					   ansi.action_code != amd_defaults.DELETE_ACTION and
					   asn.action_code != amd_defaults.DELETE_ACTION;
	-- end cursor definitions


		procedure InsertIntoAmdPartLocs(pRec amd_part_locs%rowtype) is
		begin
			 insert into amd_part_locs
			 		(
					nsi_sid,
					loc_sid,
					awt,
					awt_defaulted,
					cost_to_repair,
					cost_to_repair_defaulted,
					mic,
					mic_defaulted,
					removal_ind,
					removal_ind_defaulted,
					removal_ind_cleaned,
					repair_level_code,
					repair_level_code_defaulted,
					repair_level_code_cleaned,
					time_to_repair,
					time_to_repair_defaulted,
					tactical,
					action_code,
					last_update_dt,
					rsp_on_hand,
					rsp_objective,
					order_cost,
					holding_cost,
					backorder_fixed_cost,
					backorder_variable_cost
					)
			 values (
			 		pRec.nsi_sid,
					pRec.loc_sid,
					pRec.awt,
					pRec.awt_defaulted,
					pRec.cost_to_repair,
					pRec.cost_to_repair_defaulted,
					pRec.mic,
					pRec.mic_defaulted,
					pRec.removal_ind,
					pRec.removal_ind_defaulted,
					pRec.removal_ind_cleaned,
					pRec.repair_level_code,
					pRec.repair_level_code_defaulted,
					pRec.repair_level_code_cleaned,
					pRec.time_to_repair,
					pRec.time_to_repair_defaulted,
					pRec.tactical,
					pRec.action_code,
					pRec.last_update_dt,
					pRec.rsp_on_hand,
					pRec.rsp_objective,
					pRec.order_cost,
					pRec.holding_cost,
					pRec.backorder_fixed_cost,
					pRec.backorder_variable_cost
				);
		end InsertIntoAmdPartLocs;

	begin
			--
			-- load mobs into part locations
			--
		countRecs := 0;

		for partLocsMobRec in partLocsMobList_cur
		loop
			begin
					 -- minimize retrieving of amdNsiRec and onbaserepaircost, note order by in cursor
					 -- all of the hardcoded null assignments related to amdPartLocsRec fields,
					 -- could be taken out, already handled with
					 --	amdPartLocsRec := null.  takes up minimal time, left in for visibility.
				rampData := null;
				if (partLocsMobRec.nsi_sid != amdNsiRec.nsi_sid or amdNsiRec.nsi_sid is null) then
				   amdPartLocsRec := null;
				   amdNsiRec := GetAmdNsiRec(partLocsMobRec.nsi_sid);
				   amdPartLocsRec.nsi_sid := partLocsMobRec.nsi_sid;
				   amdPartLocsRec.cost_to_repair := GetOnBaseRepairCost(amdNsiRec.prime_part_no);
				   if (amdPartLocsRec.cost_to_repair is null) then
				   		-- currently default is 40
				     	   amdPartLocsRec.cost_to_repair_defaulted := amd_defaults.COST_TO_REPAIR_ONBASE;
				   end if;
				end if;

				locId := amd_utils.GetLocId(partLocsMobRec.loc_sid);

				amdPartLocsRec.loc_sid := partLocsMobRec.loc_sid;
				amdPartLocsRec.awt := null;
				amdPartLocsRec.awt_defaulted := null;

				amdPartLocsRec.mic := null;
				amdPartLocsRec.mic_defaulted := null;
					-- Eric Honma, default MOB 'Y'  FSL 'N' for repair_indicator/repair_level_code
					-- and removal indicator.
					-- also part of exception table bssm_base_parts
					-- if removal ind cleaned is 'N' then error in cursor
				amdPartLocsRec.removal_ind := null;
				amdPartLocsRec.removal_ind_defaulted := 'Y';
			        -- will retrieve all cleanable fields for bssm base parts
					-- cleaning done as a post process to speed up
				amdPartLocsRec.removal_ind_cleaned := null;
				amdPartLocsRec.repair_level_code := null;
				amdPartLocsRec.repair_level_code_defaulted := 'Y';
				amdPartLocsRec.repair_level_code_cleaned := null;
				rampData := GetRampData(amdNsiRec.nsn, locId);
				amdPartLocsRec.time_to_repair := rampData.avg_repair_cycle_time;
				 -- lauries "command decision" treat null and 0 as same => need default.
				if (nvl(amdPartLocsRec.time_to_repair,0) = 0) then
				   amdPartLocsRec.time_to_repair := null;
				   amdPartLocsRec.time_to_repair_defaulted := amd_defaults.TIME_TO_REPAIR_ONBASE;
				end if;
				amdPartLocsRec.tactical := 'Y';
				amdPartLocsRec.action_code := amd_defaults.INSERT_ACTION;
				amdPartLocsRec.last_update_dt := SYSDATE;
				amdPartLocsRec.rsp_on_hand := rampData.wrm_balance;
				amdPartLocsRec.rsp_objective := rampData.wrm_level;
					-- filled in afterwards in separate process, bssm only source for now
					-- look in amd_from_bssm_pkg,
					-- null assignment here just to note
				amdPartLocsRec.order_cost := null;
				amdPartLocsRec.holding_cost := null;
				amdPartLocsRec.backorder_fixed_cost := null;
				amdPartLocsRec.backorder_variable_cost := null;
					-- insert record
				InsertIntoAmdPartLocs(amdPartLocsRec);
				if (countRecs > COMMIT_AFTER) then
					commit;
					countRecs := 0;
				else
					countRecs := countRecs + 1;
				end if;
			exception
				when others then
					 amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'mob cursor'),partlocsmobrec.nsi_sid, partlocsmobrec.loc_sid,null,null,null,substr(SQLCODE || ' ' || SQLERRM,1, 2000));
			end;
		end loop;
		commit;


			--
			-- load fsls into part locations
			--
	    amdNsiRec := null;
		for partLocsFslRec in partLocsFslList_cur
		loop
			begin
				rampData := null;
					 -- minimize retrieving of amdNsiRec and onbaserepaircost
				if (partLocsFslRec.nsi_sid != amdNsiRec.nsi_sid or amdNsiRec.nsi_sid is null) then
				   amdPartLocsRec := null;
				   amdNsiRec := GetAmdNsiRec(partLocsFslRec.nsi_sid);
				   amdPartLocsRec.nsi_sid := partLocsFslRec.nsi_sid;
				   amdPartLocsRec.cost_to_repair := GetOnBaseRepairCost(amdNsiRec.prime_part_no);
				   if (amdPartLocsRec.cost_to_repair is null) then
				   		-- currently default is 40
				   		amdPartLocsRec.cost_to_repair_defaulted := amd_defaults.COST_TO_REPAIR_ONBASE;
				   end if;
				end if;


				locId := amd_utils.GetLocId(partLocsFslRec.loc_sid);

				amdPartLocsRec.loc_sid := partLocsFslRec.loc_sid;
				amdPartLocsRec.awt := null;
				amdPartLocsRec.awt_defaulted := null;

				amdPartLocsRec.mic := null;
				amdPartLocsRec.mic_defaulted := null;
					-- Eric Honma, default MOB 'Y'  FSL 'N' for repair_indicator/repair_level_code
					-- and removal indicator.
					-- also part of exception table bssm_base_parts
					-- if removal ind cleaned is 'N' then error in cursor
				amdPartLocsRec.removal_ind := null;
				amdPartLocsRec.removal_ind_defaulted := 'N';
					-- cleaning done as a post process to speed up
				amdPartLocsRec.removal_ind_cleaned := null;
				amdPartLocsRec.repair_level_code := null;
				amdPartLocsRec.repair_level_code_defaulted := 'N';
				amdPartLocsRec.repair_level_code_cleaned := null;
				rampData := GetRampData(amdNsiRec.nsn, locId);
				amdPartLocsRec.time_to_repair := rampData.avg_repair_cycle_time;
				 -- lauries "command decision" treat null and 0 as same => need default.
				if (nvl(amdPartLocsRec.time_to_repair,0) = 0) then
				   amdPartLocsRec.time_to_repair := null;
				   amdPartLocsRec.time_to_repair_defaulted := amd_defaults.TIME_TO_REPAIR_ONBASE;
				end if;
				amdPartLocsRec.tactical := 'Y';
				amdPartLocsRec.action_code := amd_defaults.INSERT_ACTION;
				amdPartLocsRec.last_update_dt := SYSDATE;
				amdPartLocsRec.rsp_on_hand := rampData.wrm_balance;
				amdPartLocsRec.rsp_objective := rampData.wrm_level;
					-- filled in afterwards in separate process, bssm only source for now
					-- look in amd_from_bssm_pkg,
					-- null assignment here just to note
				amdPartLocsRec.order_cost := null;
				amdPartLocsRec.holding_cost := null;
				amdPartLocsRec.backorder_fixed_cost := null;
				amdPartLocsRec.backorder_variable_cost := null;
				InsertIntoAmdPartLocs(amdPartLocsRec);
			exception
				when others then
					 amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'fsl cursor'),partlocsfslrec.nsi_sid, partlocsfslrec.loc_sid,null,null,null, substr(SQLCODE || ' ' || SQLERRM,1, 2000));
			end;
		end loop;
		commit;

			--
			-- load offbase into part locations
			--
		countRecs := 0;
		for partLocsOffBaseRec in partLocsOffBaseList_cur
			-- partLocsOffBaseRec only has nsn and location.
			-- should change defaulted to pull from params table.
			-- cursors all tied to ansi so nsn, partno in cursor will be in ansi
		loop
			begin
				amdPartLocsRec := null;
				amdPartLocsRec.nsi_sid := partLocsOffBaseRec.nsi_sid;
				amdPartLocsRec.loc_sid := partLocsOffBaseRec.loc_sid;
				amdPartLocsRec.awt := null;
				amdPartLocsRec.awt_defaulted := null;
				amdPartLocsRec.cost_to_repair := GetOffBaseRepairCost(partLocsOffBaseRec.prime_part_no);
				if (amdPartLocsRec.cost_to_repair is null) then
				   		-- amd_preferred throws exception
						-- currently unit cost is null.
				    begin
					    unitCost := amd_preferred_pkg.GetUnitCost( pNsi_Sid => partLocsOffBaseRec.nsi_sid);
					    amdPartLocsRec.cost_to_repair_defaulted := unitCost * (amd_defaults.UNIT_COST_FACTOR_OFFBASE);
					exception
						when no_data_found then
							 amdPartLocsRec.cost_to_repair_defaulted := null;
					end;
				end if;
				amdPartLocsRec.mic := null;
					-- no real meaning of following for offbase, set to null
				amdPartLocsRec.removal_ind := null;
				amdPartLocsRec.removal_ind_defaulted := null;
				amdPartLocsRec.removal_ind_cleaned := null;
				amdPartLocsRec.repair_level_code := null;
				amdPartLocsRec.repair_level_code_defaulted := null;
				amdPartLocsRec.repair_level_code_cleaned := null;

				amdPartLocsRec.time_to_repair := GetOffBaseTurnAround(partLocsOffBaseRec.prime_part_no);
				if (amdPartLocsRec.time_to_repair is null) then
				   amdPartLocsRec.time_to_repair_defaulted := amd_defaults.TIME_TO_REPAIR_OFFBASE;
				end if;
				amdPartLocsRec.tactical := 'Y';
				amdPartLocsRec.action_code := amd_defaults.INSERT_ACTION;
				amdPartLocsRec.last_update_dt := SYSDATE;
				amdPartLocsRec.rsp_on_hand := null;
				amdPartLocsRec.rsp_objective := null;
				amdPartLocsRec.order_cost := null;
				amdPartLocsRec.holding_cost := null;
				amdPartLocsRec.backorder_fixed_cost := null;
				amdPartLocsRec.backorder_variable_cost := null;

				  -- insert record
				InsertIntoAmdPartLocs(amdPartLocsRec);
				if (countRecs > COMMIT_AFTER) then
					commit;
					countRecs := 0;
				else
					countRecs := countRecs + 1;
				end if;
			exception
				when others then
					 amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'offbasecursor'),partlocsoffbaserec.nsi_sid, partlocsoffbaserec.loc_sid,null,null,null, substr(SQLCODE || ' ' || SQLERRM,1, 2000));
			end;
		end loop;
		commit;
			--
			-- load warehouse parts
			--
		countRecs := 0;
		for partLocsWhRec in partLocsWareHouse_cur
		loop
			begin
					-- most of the values have no meaning w/respect to the warehouse.
					-- list is just used to accommodate ROP/ROQ in amd_part_loc_time_periods for now.
				amdPartLocsRec := null;
				amdPartLocsRec.nsi_sid := partLocsWhRec.nsi_sid;
				amdPartLocsRec.loc_sid := partLocsWhRec.loc_sid;
				amdPartLocsRec.tactical := 'Y';
				amdPartLocsRec.action_code := amd_defaults.INSERT_ACTION;
				amdPartLocsRec.last_update_dt := SYSDATE;
				   -- insert record
				InsertIntoAmdPartLocs(amdPartLocsRec);
				if (countRecs > COMMIT_AFTER) then
					commit;
					countRecs := 0;
				else
					countRecs := countRecs + 1;
				end if;
			exception
				when others then
					 amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'WH cursor'),partLocsWhRec.nsi_sid, partLocsWhRec.loc_sid,null,null,null, substr(SQLCODE || ' ' || SQLERRM,1, 2000));
			end;
  	    end loop;
		commit;

	end LoadAmdPartLocations;
BEGIN
	 null;
END AMD_PART_LOCS_LOAD_PKG;
/

