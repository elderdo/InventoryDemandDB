CREATE OR REPLACE package body amd_asCapableFlying_pkg
as
/*
      $Author:   zf297a  $
    $Revision:   1.1  $
     $Date:   Dec 01 2005 09:53:36  $
    $Workfile:   amd_asCapableFlying_pkg.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_asCapableFlying_pkg.pkb-arc  $
/*   
/*      Rev 1.1   Dec 01 2005 09:53:36   zf297a
/*   added pvcs keywords
*/
	no_data_found_timePeriod exception;
	DECREMENT_BY_1 CONSTANT integer := -1;
	INCREMENT_BY_1 CONSTANT integer := 1;
	NO_INCREMENT_CHANGE CONSTANT integer := 0;

		-- should put in defaults table

	function getAltusLocSid return amd_spare_networks.loc_sid%type
	is
		ALTUSLOCID constant varchar2(13) := 'FB4419';
		locSid amd_spare_networks.loc_sid%type;
	begin
		select loc_sid into locSid
		from amd_spare_networks
		where loc_id = ALTUSLOCID;
		return locSid;
	end;

		-- future, modify to add to defaults pkg
	function  getAvgMthlyDefault return amd_retrofit_tctos.avg_monthly_upgrade%type
	is
		avgDefault amd_retrofit_tctos.avg_monthly_upgrade%type;
	begin
		select param_value into avgDefault
		from amd_param_changes
		where lower(param_key) =  'avg_monthly_upgrade';
		return avgDefault;
	end getAvgMthlyDefault;

	function getUserDefAvgMthlyBurn(pTcto amd_retrofit_tctos.tcto_number%type) return amd_retrofit_tctos.avg_monthly_upgrade%type
	is
		avgM amd_retrofit_tctos.avg_monthly_upgrade%type := null;
	begin
		select avg_monthly_upgrade into avgM
		from amd_retrofit_tctos
		where tcto_number = pTcto;
		return avgM;
	end getUserDefAvgMthlyBurn;

	function getNumAcPerLocTimePd(pTimePeriodStart date, pTimePeriodEnd date, pLocSid amd_spare_networks.loc_sid%type, pAircraftOwner varchar2 default AIRFORCEONLY)	return number
	is
		retCount number := 0;
	begin
		select count(distinct aac.tail_no) into retCount
		from
			amd_ac_assigns aac,
			amd_aircrafts aa
		where
			aac.tail_no = aa.tail_no and
			aa.p_no like pAircraftOwner and
			loc_sid = pLocSid and
			(
				(assignment_start >= pTimePeriodStart and
				assignment_start <= pTimePeriodEnd)
			or
				(assignment_start < pTimePeriodStart and assignment_end is null)
			or
				(assignment_start < pTimePeriodStart and assignment_end > pTimePeriodStart)

		);
		return retCount;
	end;

	function getNumAcPerLocTimePd_all(pTimePeriodStart date, pTimePeriodEnd date, pAircraftOwner varchar2 default AIRFORCEONLY ) return number
	is
		retCount number := 0;
	begin
		select count(distinct aac.tail_no) into retCount
		from
			amd_ac_assigns aac,
			amd_aircrafts aa
		where
			aac.tail_no = aa.tail_no and
			aa.p_no like pAircraftOwner and
			(
				(assignment_start >= pTimePeriodStart and
				assignment_start <= pTimePeriodEnd)
			or
				(assignment_start < pTimePeriodStart and assignment_end is null)
			or
				(assignment_start < pTimePeriodStart and assignment_end > pTimePeriodStart)
		);
		return retCount;
	end;


	function getNsiGroupSid(pNsiSid amd_national_stock_items.nsi_sid%type) return amd_nsi_groups.nsi_group_sid%type
	is
		retGroupSid amd_nsi_groups.nsi_group_sid%type;
	begin
		select nsi_group_sid
		into retGroupSid
		from amd_national_stock_items
		where nsi_sid = pNsiSid;
		return retGroupSid;
	end;

	-- raises no_data_found_timePeriod --
	function getTimePdStartAndEnd(pDate date) return r_timePd
	is
		cursor tp_cur(pDate date) is
			select time_period_start, time_period_end
			from amd_time_periods
			where
				pDate >= time_period_start and
				pDate  <= time_period_end;
		retTimePd r_timePd;
	begin
		open tp_cur(pDate);
		fetch tp_cur into retTimePd;
		if (tp_cur%NOTFOUND) then
			raise no_data_found_timePeriod;
		end if;
		close tp_cur;
		return retTimePd;
	end;

	function isLtdFleetSizeMember (pFleetSizeName amd_ltd_fleet_size_member.fleet_size_name%type, pTailNo amd_ltd_fleet_size_member.tail_no%type) return boolean
	is
		x varchar2(1);
	begin
		select 'x'
			into x
		from
			amd_ltd_fleet_size_member
		where
			fleet_size_name = pFleetSizeName and
			tail_no = pTailNo;
		return true;
	exception
		when no_data_found then
			return false;
	end isLtdFleetSizeMember;

	function isParent(pNsiSid amd_product_structure.assy_nsi_sid%type) return boolean
	is
		cursor assy_cur is
			select assy_nsi_sid
				from amd_product_structure
				where assy_nsi_sid = pNsiSid;
		assyRec assy_cur%rowtype := null;
	begin
		open assy_cur;
		fetch assy_cur into assyRec;
		close assy_cur;
		if (assyRec.assy_nsi_sid is not null) then
			return true;
		else
			return false;
		end if;
	end isParent;

	-- check if item is not a child, i.e. parent with kids or single w/o kids.
	function isNotChild(pNsiSid amd_product_structure.comp_nsi_sid%type) return boolean
	is
		cursor child_cur is
			select comp_nsi_sid
				from amd_product_structure
				where comp_nsi_sid = pNsiSid;
		childRec child_cur%rowtype := null;
	begin
		open child_cur;
		fetch child_cur into childRec;
		close child_cur;
		if (childRec.comp_nsi_sid is null) then
			return true;
		else
			return false;
		end if;
	end isNotChild;

	function isPartOnTail(pNsiSid amd_national_stock_items.nsi_sid%type, pTailNo amd_ltd_fleet_size_member.tail_no%type) return boolean
	is
		fleetSizeName amd_nsi_groups.fleet_size_name%type;
		retBool boolean := false;
		groupSid amd_nsi_groups.nsi_group_sid%type;
	begin
		groupSid := getNsiGroupSid(pNsiSid);
		select fleet_size_name
		into fleetSizeName
		from amd_nsi_groups
		where nsi_group_sid = groupSid;
		if (lower(fleetSizeName) = 'all aircraft') then
			retBool := true;
		elsif (isLtdFleetSizeMember(fleetSizeName, pTailNo)) then
			retBool := true;
		else
			retBool := false;
		end if;
		return retBool;
	end isPartOnTail;

	procedure updateAmdAirFlag(pTailNo amd_aircrafts.tail_no%type)
	is
	begin
		update
			amd_aircrafts
		set
			cur_distribs_updated = 'Y'
		where
			tail_no = pTailNo;
	end updateAmdAirFlag;

	procedure updateCurNsiLoc(pNsiSid amd_cur_nsi_loc_distribs.nsi_sid%type, pLocSid amd_cur_nsi_loc_distribs.loc_sid%type, pAssignDate amd_cur_nsi_loc_distribs.last_update_dt%type)
	is
	begin
		update
			amd_cur_nsi_loc_distribs
		set
			quantity = quantity + 1,
			last_update_dt = sysdate,
			last_update_id = substr(user, 1, 8)
		where
			nsi_sid = pNsiSid and
			loc_sid = pLocSid and
			last_update_dt < pAssignDate;
	end;

	procedure updateDistribForNewAc(pDate date DEFAULT sysdate)
	is
	/* order by used to facilitate filtering out if aircraft is
		assigned then reassigned within the same days window.  choose last
		assignment. */
	cursor newAcPerLoc_cur is
		select
			loc_sid,
			assignment_start,
			tail_no
		from
			amd_ac_assigns
		where
			tail_no in (select
							distinct aaa.tail_no
						from
							amd_ac_assigns aaa, amd_aircrafts aa
						where
							aaa.tail_no = aa.tail_no and
							aa.cur_distribs_updated = 'N'
						having
							max(assignment_start) < pDate
						group by  aaa.tail_no)
		order by tail_no, assignment_start desc;

	cursor latestNsi_cur is
		select distinct
			acnld.nsi_sid
		from
			amd_national_stock_items ansi,
			amd_cur_nsi_loc_distribs acnld
		where
			ansi.nsi_sid = acnld.nsi_sid and
			ansi.latest_config = 'Y';
			lastTailNo amd_aircrafts.tail_no%type :='none';
	begin
		for latestPartRec in latestNsi_cur
		loop
			for newAcRec in newAcPerLoc_cur
			loop
				if (newAcRec.tail_no != lastTailNo) then
					if (isNotChild(latestPartRec.nsi_sid) AND isPartOnTail(latestPartRec.nsi_sid, newAcRec.tail_no)) then
						updateCurNsiLoc(latestPartRec.nsi_sid, newAcRec.loc_sid, newAcRec.assignment_start);
						amd_effectivity_tcto_pkg.updateAnsiAudit(latestPartRec.nsi_sid);
					end if;
					updateAmdAirFlag(newAcRec.tail_no);
				end if;
				lastTailNo := newAcRec.tail_no;
			end loop;
			if (isParent(latestPartRec.nsi_sid)) then
				amd_effectivity_pkg.rebuildChildren(latestPartRec.nsi_sid);
			end if;
		end loop;
		commit;
	exception
		when others then
			rollback;
			raise;
	end updateDistribForNewAc;



	procedure updateNsiLocDistribs(rec amd_nsi_loc_distribs%rowtype)
	is
	begin
		update
			amd_nsi_loc_distribs
		set
			as_flying_count = rec.as_flying_count,
			as_flying_percent = rec.as_flying_percent,
			as_capable_count = rec.as_capable_count,
			as_capable_percent =rec.as_capable_percent
		where
			nsi_sid = rec.nsi_sid and
			loc_sid = rec.loc_sid and
			time_period_start = rec.time_period_start and
			time_period_end = rec.time_period_end;
	end;


	procedure updateNsiLocDistribsAsFlying(pRec amd_nsi_loc_distribs%rowtype)
	is
	begin
		update
			amd_nsi_loc_distribs
		set
			as_flying_count = nvl(as_flying_count,0) + pRec.as_flying_count
		where
			nsi_sid = pRec.nsi_sid and
			loc_sid = pRec.loc_sid and
			time_period_start = pRec.time_period_start and
			time_period_end = pRec.time_period_end;
	end updateNsiLocDistribsAsFlying;

	procedure updateNsiLocDistribsPercnt(pRec amd_nsi_loc_distribs%rowtype, pDenom number)
	is
	begin
		update
			amd_nsi_loc_distribs
		set
			as_flying_percent = decode(as_flying_count, null, null, 0, 0, decode(pDenom, 0, 0, as_flying_count*100/pDenom)),
			as_capable_percent = decode(as_capable_count, null, null, 0, 0, decode(pDenom, 0, 0, as_capable_count*100/pDenom))
		where
			nsi_sid = pRec.nsi_sid and
			loc_sid = pRec.loc_sid and
			time_period_start = pRec.time_period_start and
			time_period_end = pRec.time_period_end;
	end updateNsiLocDistribsPercnt;

	procedure updateNsiLocDistribsSubTimePds(pRec amd_nsi_loc_distribs%rowtype)
	is
	begin
		update
			amd_nsi_loc_distribs
		set
			as_flying_count = nvl(as_flying_count,0) + pRec.as_flying_count
		where
			nsi_sid = pRec.nsi_sid and
			loc_sid = pRec.loc_sid and
			time_period_start > pRec.time_period_start;
	end updateNsiLocDistribsSubTimePds;

	function getMaxTctoSchedDate(pTcto amd_retrofit_schedules.tcto_number%type) return date
	is
	cursor tctoMaxSched_cur(pTcto amd_retrofit_schedules.tcto_number%type) is
		select
			max(scheduled_complete_date)
		from
			amd_retrofit_schedules
		where
			tcto_number = pTcto;
		retDate date := null;
	begin
		open tctoMaxSched_cur(pTcto);
		fetch tctoMaxSched_cur into retDate;
		close tctoMaxSched_cur;
		return retDate;
	end getMaxTctoSchedDate;

	procedure adjustForRetrofit(pDate date DEFAULT sysdate)
	is
		-- get candidate tctos and their parts
	cursor tcto_cur is
		select
			tcto_number,
			replaced_nsi_sid,
			replaced_by_nsi_sid
		from
			amd_related_nsi_pairs
		where
			tcto_number in
			(select
				tcto_number
			from
				amd_retrofit_schedules
			having
				(count(scheduled_complete_date) > 0 or
				count(actual_complete_date) > 0)
				and
				count(actual_complete_date) < count(*)
			group by
				tcto_number
		)
		order by tcto_number;

	cursor tctoTail_cur(pTcto amd_retrofit_schedules.tcto_number%type, pDate date) is
		select
			tcto_number,
			ars.tail_no,
			scheduled_complete_date,
			actual_complete_date
		from
			amd_retrofit_schedules ars, amd_aircrafts aa
		where
			tcto_number = pTcto and
			actual_complete_date is null and
			ars.tail_no = aa.tail_no and
			aa.p_no like AIRFORCEONLY
		order by aa.fus;
		burnCount integer;
		periodStartEnd r_timePd;
		periodStartEndBurn  r_timePd;
		periodStartEndInitial r_timePd;
		avgMthly amd_retrofit_tctos.avg_monthly_upgrade%type;
		avgMthlyDefault amd_retrofit_tctos.avg_monthly_upgrade%type;
		anldRec amd_nsi_loc_distribs%rowtype;
		anldRecFrom amd_nsi_loc_distribs%rowtype;
		locSid amd_nsi_loc_distribs.loc_sid%type;
		maxTctoSchedDate date := null;
	begin
		avgMthlyDefault := getAvgMthlyDefault();
		periodStartEndInitial := getTimePdStartAndEnd(pDate);
		for tctoRec in tcto_cur
		loop
			burnCount := 1;
			maxTctoSchedDate := getMaxTctoSchedDate(tctoRec.tcto_number);
			if (maxTctoSchedDate is null) then
			-- starting burn period will be next time period after initial
				periodStartEndBurn := getTimePdStartAndEnd(periodStartEndInitial.timePeriodEnd + 1);
			else
				periodStartEndBurn := getTimePdStartAndEnd(maxTctoSchedDate);
			-- starting burn period will be next time period after maxTctoSchedDate time period
				periodStartEndBurn := getTimePdStartAndEnd(periodStartEndBurn.timePeriodEnd + 1);
			end if;

			avgMthly := getUserDefAvgMthlyBurn(tctoRec.tcto_number);
			if (avgMthly is null) then
				avgMthly := avgMthlyDefault;
			end if;
			if (avgMthly < 1) then
				avgMthly := 1;
			end if;

			-- anldRec will be passed to updateNsiLocDistribsAsFlying which will increment the
			-- the table as_flying_couut value by the as_flying_count in the anldRec
			anldRec := null;
			anldRec.nsi_sid := tctoRec.replaced_by_nsi_sid;
			anldRec.as_flying_count := INCREMENT_BY_1;

			anldRecFrom := null;
			anldRecFrom.nsi_sid := tctoRec.replaced_nsi_sid;
			anldRecFrom.as_flying_count := DECREMENT_BY_1;

			for tctoTailRec in tctoTail_cur(tctoRec.tcto_number, pDate)
			loop
				if (tctoTailRec.scheduled_complete_date is null or tctoTailRec.scheduled_complete_date < pDate) then
					if (burnCount > avgMthly) then
					-- get next time period --
						periodStartEndBurn := getTimePdStartAndEnd(periodStartEndBurn.timePeriodEnd + 1);
						burnCount := 1;
					end if;
					periodStartEnd := periodStartEndBurn;
					-- get location of aircraft at estimate of mid month for time period
					locSid := amd_effectivity_tcto_pkg.getAcAssignLocSid(tctoTailRec.tail_no, periodStartEnd.timePeriodStart + 15);
					burnCount := burnCount + 1;
				else
					locSid := amd_effectivity_tcto_pkg.getAcAssignLocSid(tctoTailRec.tail_no, tctoTailRec.scheduled_complete_date);
					periodStartEnd := getTimePdStartAndEnd(tctoTailRec.scheduled_complete_date);
				end if;

					-- replaced by part
				anldRec.loc_sid := locSid;
				anldRec.time_period_start := periodStartEnd.timePeriodStart;
				anldRec.time_period_end := periodStartEnd.timePeriodEnd;
				updateNsiLocDistribsAsFlying(anldRec);
					-- replaced part
				anldRecFrom.loc_sid := locSid;
				anldRecFrom.time_period_start := periodStartEnd.timePeriodStart;
				anldRecFrom.time_period_end := periodStartEnd.timePeriodEnd;
				updateNsiLocDistribsAsFlying(anldRecFrom);

					-- since aircraft are not reassigned in the "future", the location
					-- should not change for an aircraft => just get sub time periods as opposed
					-- to trying to also figure out where the tail is located in a future time period.

				updateNsiLocDistribsSubTimePds(anldRec);
				updateNsiLocDistribsSubTimePds(anldRecFrom);
			end loop;
		end loop;
		commit;
	end adjustForRetrofit;

	procedure updatePercentages
	is
		cursor anldLocType_cur is
			select anld.*, asn.loc_type
			from
				amd_nsi_loc_distribs anld,
				amd_spare_networks asn
			where
				anld.loc_sid = asn.loc_sid
			order by time_period_start, anld.loc_sid;
		altusLocSid amd_nsi_loc_distribs.loc_sid%type;
		acPerTimePdLoc number := 0;
		acPerTimePdAll number := 0;
		NON_EXISTENT_LOC_SID CONSTANT integer := -99;
		lastLocSid amd_nsi_loc_distribs.loc_sid%type := NON_EXISTENT_LOC_SID ;
		lastTimePdStart amd_nsi_loc_distribs.time_period_start%type := to_date('01/01/1900', 'MM/DD/YYYY');
		anldRec amd_nsi_loc_distribs%rowtype;
	begin
		altusLocSid := getAltusLocSid;
		for anldLocTypeRec in anldLocType_cur
		loop
			anldRec := null;
			anldRec.nsi_sid := anldLocTypeRec.nsi_sid;
			anldRec.loc_sid := anldLocTypeRec.loc_sid;
			anldRec.time_period_start := anldLocTypeRec.time_period_start;
			anldRec.time_period_end := anldLocTypeRec.time_period_end;
			if (lastTimePdStart != anldLocTypeRec.time_period_start) then
				acPerTimePdAll	:= getNumAcPerLocTimePd_all(anldRec.time_period_start, anldRec.time_period_end);
				lastLocSid := NON_EXISTENT_LOC_SID ;
			end if;
			if (lastLocSid != anldRec.loc_sid) then
				acPerTimePdLoc := getNumAcPerLocTimePd(anldRec.time_period_start, anldRec.time_period_end, anldRec.loc_sid);
			end if;
			if (anldRec.loc_sid = altusLocSid or anldLocTypeRec.loc_type = 'FSL') then
					updateNsiLocDistribsPercnt(anldRec, acPerTimePdAll);
			else
					updateNsiLocDistribsPercnt(anldRec, acPerTimePdLoc);
			end if;
			lastTimePdStart := anldRec.time_period_start;
			lastLocSid := anldRec.loc_sid;
		end loop;
		commit;
	end updatePercentages;

end amd_asCapableFlying_pkg;
/
