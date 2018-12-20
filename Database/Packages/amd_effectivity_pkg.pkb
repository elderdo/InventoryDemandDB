DROP PACKAGE BODY AMD_OWNER.AMD_EFFECTIVITY_PKG;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.amd_effectivity_pkg as
/*
      $Author:   zf297a  $
    $Revision:   1.1  $
	    $Date:   Nov 30 2005 12:24:06  $
    $Workfile:   amd_effectivity_pkg.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_effectivity_pkg.pkb-arc  $
/*
/*      Rev 1.1   Nov 30 2005 12:24:06   zf297a
/*   added PVCS keywords
*/

	NUM_TIME_PERIODS   constant number:=60;
	FOREVER            constant date  :=add_months(sysdate,NUM_TIME_PERIODS);



	procedure genFlyingAltus(
							pNsiSid number);
	procedure genFlyingByShip(
							pNsiSid number);
	procedure genFlyingByFleet(
							pNsiSid number);
	procedure updateFsls(
							pRec amd_nsi_loc_distribs%rowtype);
	procedure processLatestConfig(
							pNsiSid number);
	procedure processNonLatestConfig(
							pNsiSid number);
	procedure insertNsiLocDistribs(
							pRec amd_nsi_loc_distribs%rowtype);
	procedure genFlyingDerived(
							pNsiSid number);
	function getAssignedQuantity(
							pTimePeriod date,
							pLocSid number) return number;
	procedure genCapable(
							pNsiSid number);
	function getCountByShip(
							pNsiSid number) return number;
	function getCountByFleet(
							pNsiSid number) return number;
	procedure displayMsg(
							pMsg varchar2);
	function isOrphan(
							pNsiSid number) return boolean;
	procedure updateOrphanStatus(
							pNsiSid number);



	procedure displayMsg(
							pMsg varchar2) is
	begin
		dbms_output.put_line(pMsg);
	end;


	procedure updateChildS(
							pChildRec amd_nsi_effects%rowtype) is
	begin
		update amd_nsi_effects set
			derived      = pChildRec.derived
		where
			nsi_sid     = pChildRec.nsi_sid
			and tail_no = pChildRec.tail_no;

	end;

	procedure updateChildF(
							pChildRec amd_cur_nsi_loc_distribs%rowtype) is
	begin
		update amd_cur_nsi_loc_distribs set
			quantity       = pChildRec.quantity,
			derived        = pChildRec.derived,
			last_update_id = substr(user,1,8),
			last_update_dt = sysdate
		where
			nsi_sid     = pChildRec.nsi_sid
			and loc_sid = pChildRec.loc_sid;

	end;


	--
	-- Generates A_C_N_L_D records as a default if they don't exist.
	--
	procedure genLocRecs(
							pChildSid number) is
		cursor locCur is
			select
				loc_sid
			from
				amd_spare_networks
			where
				loc_type = 'MOB';

		locRec    amd_cur_nsi_loc_distribs%rowtype;
	begin

		for rec in locCur loop
			locRec.nsi_sid      := pChildSid;
			locRec.loc_sid      := rec.loc_sid;
			locRec.quantity     := 0;
			locRec.user_defined := 'N';
			locRec.derived      := 'N';

			begin
				insert into amd_cur_nsi_loc_distribs
				(
					nsi_sid,
					loc_sid,
					user_defined,
					derived,
					quantity,
					last_update_id,
					last_update_dt
				)
				values
				(
					locRec.nsi_sid,
					locRec.loc_sid,
					locRec.user_defined,
					locRec.derived,
					locRec.quantity,
					substr(user,1,8),
					sysdate
				);
			exception
				when dup_val_on_index then NULL;
			end;
		end loop;

	end;

	procedure rebuildChild(
							pChildSid number,
							pType varchar2 default 'S') is
		cursor sParentCur(pSid number) is
			select distinct
				ane.tail_no
			from
				amd_product_structure aps,
				amd_nsi_effects ane,
				amd_national_stock_items ansi,
				amd_nsi_groups ang,
				amd_ltd_fleet_size_member alfsm
			where
				aps.comp_nsi_sid     = pSid
				and aps.assy_nsi_sid = ane.nsi_sid
				and ane.effect_type  = 'B'
				and ane.user_defined in ('Y','S')
				and aps.assy_nsi_sid    = ansi.nsi_sid
				and ansi.nsi_group_sid  = ang.nsi_group_sid
				and ang.fleet_size_name = alfsm.fleet_size_name
				and alfsm.tail_no       = ane.tail_no;

		cursor fParentCur(pSid number) is
			select
				acnld.loc_sid,
				sum(acnld.quantity) quantity
			from
				amd_product_structure aps,
				amd_cur_nsi_loc_distribs acnld
			where
				aps.comp_nsi_sid     = pSid
				and aps.assy_nsi_sid = acnld.nsi_sid
			group by
				acnld.loc_sid;

		sChildRec    amd_nsi_effects%rowtype;
		fChildRec    amd_cur_nsi_loc_distribs%rowtype;
		userDefinedCnt   number;

	begin
		update amd_national_stock_items set
			effect_by             = upper(pType),
			effect_last_update_id = substr(user,1,8),
			effect_last_update_dt = sysdate
		where nsi_sid = pChildsid;

		-- Process ansi.effect_by = 'S'|'F' different ways
		--
		if (upper(pType) = 'S') then
			update amd_nsi_effects set
				derived = 'N'
			where
				nsi_sid = pChildSid
				and derived = 'Y';

			for rec in sParentCur(pChildSid) loop
				sChildRec.nsi_sid      := pChildSid;
				sChildRec.tail_no      := rec.tail_no;
				sChildRec.derived      := 'Y';

				updateChildS(sChildRec);
			end loop;
		elsif (upper(pType) = 'F') then
			genLocRecs(pChildSid);

			update amd_cur_nsi_loc_distribs set
				quantity = 0,
				derived = 'N'
			where
				nsi_sid = pChildSid
				and derived = 'Y';

			for rec in fParentCur(pChildSid) loop
				fChildRec.nsi_sid  := pChildSid;
				fChildRec.loc_sid  := rec.loc_sid;
				fChildRec.quantity := rec.quantity;
				fChildRec.derived  := 'Y';

				updateChildF(fChildRec);
			end loop;

		end if;

		if (isOrphan(pChildSid)) then
			updateOrphanStatus(pChildSid);
		end if;
	end;

	procedure rebuildChildren(
							pParentSid number) is
		cursor childCur(pSid number) is
			select
				comp_nsi_sid
			from
				amd_product_structure
			where
				assy_nsi_sid = pSid;

		effectBy    varchar2(1);
	begin

		select effect_by
		into effectBy
		from amd_national_stock_items
		where nsi_sid = pParentSid;

		for rec in childCur(pParentSid) loop
			rebuildChild(rec.comp_nsi_sid,effectBy);
		end loop;

	end;


	procedure genDistribution(
							pNsn varchar2,
							pType varchar2) is
		nsiSid     number;
	begin
		displayMsg('genDistribution('||pNsn||','||pType||')');

		select nsi_sid
		into nsiSid
		from amd_nsns
		where nsn = pNsn;

		genDistribution(nsiSid,pType);
	end;


	procedure genDistribution(
							pNsiSid number,
							pType varchar2) is
		effectBy     varchar2(1);
	begin
		displayMsg('genDistribution('||pNsiSid||','||pType||')');

		select effect_by
		into effectBy
		from amd_national_stock_items
		where nsi_sid = pNsiSid;

		-- pType -
		-- 'F'=calculate asFlying values
		-- 'C'=calculate asCapable values
		-- 'A'=calculate asFlying values for Altus only
		--
		if (pType = 'F') then
			delete from amd_nsi_loc_distribs
			where
				nsi_sid = pNsiSid
				and time_period_start >= trunc(sysdate,'mm');

			if (effectBy = 'S') then
				genFlyingByShip(pNsiSid);
			elsif (effectBy = 'F') then
				genFlyingByFleet(pNsiSid);
			end if;

		elsif (pType = 'C') then
			genCapable(pNsiSid);
		elsif (pType = 'A') then
			genFlyingAltus(pNsiSid);
		elsif (pType = 'DERIVED' and effectBy = 'F') then
			genFlyingDerived(pNsiSid);
		end if;
	end;


	procedure genFlyingByShip(
							pNsiSid number) is
	begin
		displayMsg('genFlyingByShip('||pNsiSid||')');

		insert into amd_nsi_loc_distribs
		(
			nsi_sid,
			loc_sid,
			time_period_start,
			time_period_end,
			as_flying_count
		)
			select
				header.nsi_sid,
				header.loc_sid,
				header.tpStart tpStart,
				last_day(header.tpStart+.99999) tpEnd,
				nvl(flying.acCount,0)
			from
				(select
					 pNsiSid nsi_sid,
					loc_sid,
					tp.tpStart
				from
					amd_spare_networks,
					(select
						add_months(trunc(sysdate,'mm'),rownum-1) tpStart
					from amd_spare_parts
					where rownum <=60) tp
				where
					loc_type = 'MOB') Header,
				(select
					asFlying.loc_sid,
					tpQ.TPStart,
					count(*) acCount
				from
					(select
						add_months(trunc(sysdate,'mm'),rownum-1) TPStart,
						add_months(trunc(sysdate,'mm')+14,rownum-1) TPMid,
						last_day(add_months(trunc(sysdate,'mm'),rownum-1)) TPEnd
					from amd_spare_parts
					where rownum <= NUM_TIME_PERIODS) tpQ,
					(select
						aaa.tail_no,
						aaa.loc_sid,
						decode(aaa.assignment_start,aaa2.deliveryDt,
							trunc(aaa.assignment_start,'mm'),
							aaa.assignment_start) startDate,
						nvl(aaa.assignment_end,
							add_months(trunc(sysdate,'mm'),NUM_TIME_PERIODS)) endDate
					from
						amd_nsi_effects ane,
						amd_ac_assigns aaa,
						(select
							tail_no,
							min(assignment_start) deliveryDt
						from amd_ac_assigns
						group by tail_no) aaa2,
						amd_national_stock_items ansi,
						amd_nsi_groups ang,
						amd_ltd_fleet_size_member alfsm
					where
						ane.nsi_sid = pNsiSid
						and ((ane.user_defined in ('Y','S') and ane.effect_type = 'B')
							or ane.derived = 'Y')
						and ane.tail_no = aaa.tail_no
						and aaa.tail_no = aaa2.tail_no(+)
						and aaa.assignment_start = aaa2.deliveryDt(+)
						and ane.nsi_sid          = ansi.nsi_sid
						and ansi.nsi_group_sid   = ang.nsi_group_sid
						and ang.fleet_size_name  = alfsm.fleet_size_name
						and alfsm.tail_no        = ane.tail_no) AsFlying
				where
					TPq.TPMid between asFlying.startDate and asFlying.endDate
					and asFlying.endDate > (asFlying.startDate+14)
				group by
					asFlying.loc_sid,
					tpQ.tpStart) flying
			where
				header.loc_sid     = flying.loc_sid(+)
				and header.tpStart = flying.tpStart(+);

	exception
		when others then
			displayMsg('EXCEPTION: genFlyingByShip('||sqlerrm||')');
			raise;
	end genFlyingByShip;


	procedure genCapable(
							pNsiSid number) is
		cursor dataCur is
			select
				time_period_start,
				time_period_end,
				anld.loc_sid,
				asn.location_name,
				as_flying_count
			from amd_nsi_loc_distribs anld,
				amd_spare_networks asn
			where nsi_sid = pNsiSid
				and time_period_start >= trunc(sysdate,'mm')
				and anld.loc_sid = asn.loc_sid
				and asn.loc_type = 'MOB';

		relatedCnt             number;
		relatedLimitedCnt      number;
		adjCapableCnt          number;
		fleetSize              number;
		locRec                 amd_nsi_loc_distribs%rowtype;
	begin
		displayMsg('genCapable('||pNsiSid||')');

		--
		-- The asCapable count of an nsn is equal to the sum of the following:
		--   it's own asFlying count
		--   asFlying count of all related nsns with a 1-way or 2-way relationship
		--   asCapable count of all related nsns with a limited relationship
		--
		for rec in dataCur loop

			-- Get count of related nsns asFlying count.
			--
			select
				nvl(sum(anldL.as_flying_count),0)
			into relatedCnt
			from
				amd_related_nsi_pairs arnp,
				amd_nsi_loc_distribs anldL
			where
				arnp.replaced_by_nsi_sid    = pNsiSid
				and arnp.replaced_nsi_sid   = anldL.nsi_sid
				and arnp.interchange_type in ('1-way','2-way')
				and anldL.time_period_start = rec.time_period_start
				and anldL.loc_sid           = rec.loc_sid;

			-- Get count of limited nsns asCapable count.
			--
			if (rec.location_name = 'ALTUS') then
				select
					count(distinct aneR.tail_no)
				into relatedLimitedCnt
	         from
	            amd_related_nsi_pairs arnp,
	            amd_nsi_effects aneL,
					amd_national_stock_items ansiL,
					amd_nsi_groups angL,
					amd_ltd_fleet_size_member alfsmL,
					amd_nsi_effects aneR,
					amd_national_stock_items ansiR,
					amd_nsi_groups angR,
					amd_ltd_fleet_size_member alfsmR
	         where
	            arnp.replaced_by_nsi_sid  = pNsiSid
	            and arnp.replaced_by_nsi_sid = aneL.nsi_sid
					and arnp.replaced_by_nsi_sid = ansiL.nsi_sid
					and ansiL.nsi_group_sid   = angL.nsi_group_sid
					and angL.fleet_size_name  = alfsmL.fleet_size_name
					and alfsmL.tail_no        = aneL.tail_no
	            and arnp.interchange_type = 'limited'
	            and aneL.effect_type      = 'C'
	            and aneL.user_defined     = 'Y'
					and arnp.replaced_nsi_sid = aneR.nsi_sid
					and arnp.replaced_nsi_sid = ansiR.nsi_sid
					and ansiR.nsi_group_sid   = angR.nsi_group_sid
					and angR.fleet_size_name  = alfsmR.fleet_size_name
					and alfsmR.tail_no        = aneR.tail_no
					and aneR.effect_type      = 'B'
					and aneR.user_defined     = 'Y'
					and aneR.tail_no          = aneL.tail_no;
			else
				-- Get count of limited nsns asCapable count.
				--
				select
					count(*)
				into relatedLimitedCnt
				from amd_ac_assigns aaa1
				where
					tail_no in
						(select
							aneR.tail_no
			         from
			            amd_related_nsi_pairs arnp,
			            amd_nsi_effects aneL,
							amd_national_stock_items ansiL,
							amd_nsi_groups angL,
							amd_ltd_fleet_size_member alfsmL,
							amd_nsi_effects aneR,
							amd_national_stock_items ansiR,
							amd_nsi_groups angR,
							amd_ltd_fleet_size_member alfsmR
			         where
			            arnp.replaced_by_nsi_sid  = pNsiSid
			            and arnp.replaced_by_nsi_sid = aneL.nsi_sid
							and arnp.replaced_by_nsi_sid = ansiL.nsi_sid
							and ansiL.nsi_group_sid   = angL.nsi_group_sid
							and angL.fleet_size_name  = alfsmL.fleet_size_name
							and alfsmL.tail_no        = aneL.tail_no
			            and arnp.interchange_type = 'limited'
			            and aneL.effect_type      = 'C'
			            and aneL.user_defined     = 'Y'
							and arnp.replaced_nsi_sid = aneR.nsi_sid
							and arnp.replaced_nsi_sid = ansiR.nsi_sid
							and ansiR.nsi_group_sid   = angR.nsi_group_sid
							and angR.fleet_size_name  = alfsmR.fleet_size_name
							and alfsmR.tail_no        = aneR.tail_no
							and aneR.effect_type      = 'B'
							and aneR.user_defined     = 'Y'
							and aneR.tail_no          = aneL.tail_no)
					and rec.time_period_start
						between trunc(assignment_start,'mm') and nvl(assignment_end,FOREVER)
					and loc_sid = rec.loc_sid;
			end if;

			-- This is a boundary check only.
			--
			select count(*)
			into fleetSize
			from
				amd_national_stock_items ansi,
				amd_nsi_groups ang,
				amd_ltd_fleet_size_member alfsm
			where
				ansi.nsi_sid = pNsiSid
				and ansi.nsi_group_sid = ang.nsi_group_sid
				and ang.fleet_size_name = alfsm.fleet_size_name;

			-- Add the related asFlying and limited asCapable counts
			-- to its own asFlying count obtained in the loop cursor.
			--
			adjCapableCnt := rec.as_flying_count + relatedCnt + relatedLimitedCnt;

			if (adjCapableCnt > fleetSize) then
				adjCapableCnt := adjCapableCnt - relatedLimitedCnt;
			end if;

			update amd_nsi_loc_distribs set
				as_capable_count = adjCapableCnt
			where
				nsi_sid               = pNsiSid
				and loc_sid           = rec.loc_sid
				and time_period_start = rec.time_period_start;

			if (rec.location_name = 'ALTUS') then
				-- update fsls
				locRec.nsi_sid           := pNsiSid;
				locRec.time_period_start := rec.time_period_start;
				locRec.time_period_end   := rec.time_period_end;
				locRec.as_capable_count  := adjCapableCnt;

				updateFsls(locRec);
			end if;
		end loop;

	end genCapable;


	procedure genFlyingAltus(pNsiSid number) is
		cursor timeCur(pSid number) is
			select distinct
				time_period_start,
				time_period_end
			from amd_nsi_loc_distribs
			where nsi_sid = pSid
				and time_period_start >= trunc(sysdate,'mm');

		adjFlyingCnt    number;
		locRec          amd_nsi_loc_distribs%rowtype;
	begin
		displayMsg('genFlyingAltus('||pNsiSid||')');

		for rec in timeCur(pNsiSid) loop
			select
				sum(as_flying_count)
			into adjFlyingCnt
			from amd_nsi_loc_distribs
			where nsi_sid = pNsiSid
				and time_period_start = rec.time_period_start;

			update amd_nsi_loc_distribs set
				as_flying_count  = adjFlyingCnt
			where nsi_sid = pNsiSid
				and time_period_start = rec.time_period_start
				and loc_sid =
					(select loc_sid
					from amd_spare_networks
					where location_name = 'ALTUS');

			locRec.nsi_sid           := pNsiSid;
			locRec.time_period_start := rec.time_period_start;
			locRec.time_period_end   := rec.time_period_end;
			locRec.as_flying_count   := adjFlyingCnt;

			updateFsls(locRec);
		end loop;

	end genFlyingAltus;


	procedure updateFsls(
							pRec amd_nsi_loc_distribs%rowtype) is
		cursor locCur is
			select distinct
				loc_sid
			from amd_spare_networks asn
			where loc_type = 'FSL'
			order by loc_sid;

	begin
		displayMsg('updateFsls()');

		for locRec in locCur loop
			begin
				insert into amd_nsi_loc_distribs
				(
					nsi_sid,
					loc_sid,
					time_period_start,
					time_period_end,
					as_flying_count,
					as_flying_percent,
					as_capable_count,
					as_capable_percent
				)
				values
				(
					pRec.nsi_sid,
					locRec.loc_sid,
					pRec.time_period_start,
					pRec.time_period_end,
					pRec.as_flying_count,
					pRec.as_flying_percent,
					pRec.as_capable_count,
					pRec.as_capable_percent
				);
			exception
				when dup_val_on_index then
					update amd_nsi_loc_distribs set
						as_capable_count = pRec.as_capable_count
					where
						nsi_sid               = pRec.nsi_sid
						and loc_sid           = locRec.loc_sid
						and time_period_start = pRec.time_period_start
						and time_period_end   = pRec.time_period_end;
			end;
		end loop;

	end updateFsls;


	procedure genFlyingByFleet(
							pNsiSid number) is
		latestConfig   varchar2(1);
	begin
		displayMsg('genFlyingByFleet('||pNsiSid||')');

		select latest_config
		into latestConfig
		from amd_national_stock_items
		where nsi_sid = pNsiSid;

		if (latestConfig = 'Y') then
			processLatestConfig(pNsiSid);
		else
			processNonLatestConfig(pNsiSid);
			null;
		end if;
	end;


	procedure processLatestConfig(
							pNsiSid number) is
		cursor timeLocCur(pSid number) is
			select
				atp.time_period_start,
				atp.time_period_end,
				acnld.loc_sid,
				acnld.quantity
			from
				amd_cur_nsi_loc_distribs acnld,
				amd_time_periods atp
			where
				acnld.nsi_sid = pSid
				and atp.time_period_start >= trunc(sysdate,'mm')
			order by
				atp.time_period_start,
				acnld.loc_sid;

		locRec     amd_nsi_loc_distribs%rowtype;
		flyingCnt  number;
		newDels    number:=0;
	begin
		displayMsg('processLatestConfig('||pNsiSid||')');
		for rec in timeLocCur(pNsiSid) loop
			newDels := getAssignedQuantity(
						rec.time_period_start,
						rec.loc_sid);
			locRec.nsi_sid            := pNsiSid;
			locRec.loc_sid            := rec.loc_sid;
			locRec.time_period_start  := rec.time_period_start;
			locRec.time_period_end    := rec.time_period_end;
			locRec.as_flying_count    := rec.quantity + newDels;

			insertNsiLocDistribs(locRec);
		end loop;
	end;

	procedure processNonLatestConfig(
							pNsiSid number) is
		cursor locCur(pSid number) is
			select
				acnld.loc_sid,
				atp.time_period_start,
				atp.time_period_end,
				acnld.quantity
			from
				amd_cur_nsi_loc_distribs acnld,
				amd_time_periods atp
			where
				nsi_sid = pSid
				and atp.time_period_start >= trunc(sysdate,'mm');

		locRec     amd_nsi_loc_distribs%rowtype;
		flyingCnt  number;
	begin
		displayMsg('processNonLatestConfig('||pNsiSid||')');

		for rec in locCur(pNsiSid) loop
			locRec.nsi_sid           := pNsiSid;
			locRec.loc_sid           := rec.loc_sid;
			locRec.time_period_start := rec.time_period_start;
			locRec.time_period_end   := rec.time_period_end;
			locRec.as_flying_count   := rec.quantity;
			insertNsiLocDistribs(locRec);
		end loop;

	end processNonLatestConfig;


	procedure insertNsiLocDistribs(
							pRec amd_nsi_loc_distribs%rowtype) is
	begin
			insert into amd_nsi_loc_distribs
			(
				nsi_sid,
				loc_sid,
				time_period_start,
				time_period_end,
				as_flying_count,
				as_flying_percent,
				as_capable_count,
				as_capable_percent
			)
			values
			(
				pRec.nsi_sid,
				pRec.loc_sid,
				pRec.time_period_start,
				pRec.time_period_end,
				pRec.as_flying_count,
				pRec.as_flying_percent,
				pRec.as_capable_count,
				pRec.as_capable_percent
			);
	end;


	function getAssignedQuantity(
							pTimePeriod date,
							pLocSid number) return number is
		newDels    number;
	begin
		select count(*)
		into newDels
		from amd_ac_assigns aaa1
		where
			loc_sid = pLocSid
			and assignment_start >= SYSDATE
			and trunc(pTimePeriod,'mm') between trunc(assignment_start,'mm')
				and nvl(assignment_end,FOREVER)
			and not exists
				(select 'x'
				from amd_ac_assigns aaa2
				where aaa2.tail_no = aaa1.tail_no
					and aaa2.assignment_start < aaa1.assignment_start);

		return newDels;
	end;


	procedure genDistribution(
							pType varchar2) is
		cursor nsnCur is
			(select
				nsi_sid
			from
				amd_national_stock_items
			where nsi_group_sid in
				(select nsi_group_sid
				from amd_nsi_groups
				where split_effect = 'Y'))
			union
			(select
				nsi_sid
			from amd_national_stock_items
			where nsi_group_sid in
				(select nsi_group_sid
				from amd_national_stock_items
				group by nsi_group_sid
				having count(*) >1))
			union
			(select
				nsi_sid
			from amd_national_stock_items
			where nsi_group_sid in
				(select nsi_group_sid
				from amd_nsi_groups
				where fleet_size_name != 'All Aircraft'))
			minus
			(select
				nsi_sid
			from amd_national_stock_items
			where asset_mgmt_status is null);

	begin
		displayMsg('genDistribution('||pType||')');

		buildTimePeriods(NUM_TIME_PERIODS);

		for rec in nsnCur loop
			genDistribution(rec.nsi_sid,pType);
		end loop;

	end;

	procedure buildTimePeriods(
							pCount number) is
		cntr    number;
	begin
		select max(tactical_bucket_id)+1
		into cntr
		from amd_time_periods;

		for i in 0..pCount loop
			begin
				cntr := cntr + 1;
				insert into amd_time_periods
				(
					time_period_start,
					time_period_end,
					tactical_bucket_name,
					tactical_bucket_id,
					action_code,
					last_update_dt
				)
				values
				(
					add_months(trunc(sysdate,'mm'),i),
					last_day(add_months(trunc(sysdate,'mm'),i))+.99999,
					'FORECAST_BUCKET',
					cntr,
					'A',
					sysdate
				);
			exception
				when dup_val_on_index then NULL;
			end;
		end loop;
	end;


	procedure updateAssetMgmtStatus(
							pGroupSid number) is
		cursor nsiSidCur(pSid number) is
			select
				nsi_sid,
				effect_by
			from amd_national_stock_items
			where nsi_group_sid = pSid;

		fleetSize  number;
		acCnt      number:=0;
	begin

		select count(*)
		into fleetSize
		from amd_ltd_fleet_size_member
		where
			fleet_size_name =
				(select fleet_size_name
				from amd_nsi_groups
				where nsi_group_sid = pGroupSid);

		for rec in nsiSidCur(pGroupSid) loop
			if (rec.effect_by = 'S') then
				acCnt := acCnt + getCountByShip(rec.nsi_sid);
			elsif (rec.effect_by = 'F') then
				acCnt := acCnt + getCountByFleet(rec.nsi_sid);
			end if;
		end loop;

		if (acCnt = fleetSize) then
			update amd_national_stock_items set
				asset_mgmt_status = 'COMPLETE'
			where nsi_group_sid = pGroupSid;
		else
			update amd_national_stock_items set
				asset_mgmt_status = NULL
			where nsi_group_sid = pGroupSid;
		end if;
	end;


	function getCountByShip(
							pNsiSid number) return number is
		acCnt     number;
	begin
		displayMsg('getCountByShip('||pNsiSid||')');

		select nvl(count(*),0)
		into acCnt
		from
			amd_nsi_effects ane,
			amd_national_stock_items ansi,
			amd_nsi_groups ang,
			amd_ltd_fleet_size_member alfsm
		where
			ane.nsi_sid = pNsiSid
			and ane.effect_type = 'B'
			and ane.user_defined in ('Y','S')
			and ansi.nsi_sid = ane.nsi_sid
			and ang.nsi_group_sid = ansi.nsi_group_sid
			and alfsm.fleet_size_name = ang.fleet_size_name
			and ane.tail_no = alfsm.tail_no;

		return acCnt;
	end;


	function getCountByFleet(
							pNsiSid number) return number is
		acCnt     number;
	begin
		displayMsg('getCountByFleet('||pNsiSid||')');

		select nvl(sum(quantity),0)
		into acCnt
		from amd_cur_nsi_loc_distribs
		where nsi_sid = pNsiSid
			and user_defined in ('Y','S');

		return acCnt;
	end;


	procedure genFlyingDerived(
							pNsiSid number) is
		cursor timeCur is
			select
				acnld.loc_sid,
				acnld.time_period_start,
				sum(acnld.as_flying_count) derivedQty
			from
				amd_product_structure aps,
				amd_nsi_loc_distribs acnld
			where
				aps.comp_nsi_sid     = pNsiSid
				and aps.assy_nsi_sid = acnld.nsi_sid
				and acnld.time_period_start >= trunc(sysdate,'mm')
			group by
				acnld.loc_sid,
				acnld.time_period_start;

	begin
		displayMsg('getFlyingDerived('||pNsiSid||')');

		for rec in timeCur loop
			update amd_nsi_loc_distribs set
				as_flying_count = as_flying_count + rec.derivedQty
			where
				nsi_sid = pNsiSid
				and loc_sid = rec.loc_sid
				and time_period_start = rec.time_period_start;
		end loop;

	end;


	function isOrphan(
							pNsiSid number) return boolean is
		parentCnt  number;
	begin
		select count(*)
		into parentCnt
		from amd_product_structure
		where comp_nsi_sid = pNsiSid;

		return (parentCnt = 0);
	end;


	procedure updateOrphanStatus(
							pNsiSid number) is
	begin

		update amd_national_stock_items set
			effect_by = 'S',
			asset_mgmt_status = NULL
		where nsi_sid = pNsiSid;

		update amd_nsi_effects set
			user_defined = 'S',
			derived      = 'N'
		where nsi_sid = pNsiSid;
	end;


	procedure batchProcess is
	begin
		amd_ascapableflying_pkg.updateDistribForNewAc;
		amd_effectivity_pkg.genDistribution('F');
		amd_ascapableflying_pkg.adjustForRetrofit;
		amd_effectivity_pkg.genDistribution('A');
		amd_effectivity_pkg.genDistribution('C');
		amd_ascapableflying_pkg.updatePercentages;
		amd_effectivity_pkg.genDistribution('DERIVED');
	end;

end;
/


DROP PUBLIC SYNONYM AMD_EFFECTIVITY_PKG;

CREATE PUBLIC SYNONYM AMD_EFFECTIVITY_PKG FOR AMD_OWNER.AMD_EFFECTIVITY_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_EFFECTIVITY_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_EFFECTIVITY_PKG TO AMD_WRITER_ROLE;
