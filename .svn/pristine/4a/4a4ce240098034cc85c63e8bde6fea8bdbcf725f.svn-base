CREATE OR REPLACE package body AmdDPPkg as
/*
      $Author:   c970183  $
    $Revision:   1.0  $
	    $Date:   May 17 2005 11:26:10  $
    $Workfile:   AMDDPPKG.pkb  $
         $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\Packages\AMDDPPKG.pkb-arc  $
/*   
/*      Rev 1.0   May 17 2005 11:26:10   c970183
/*   Initial revision.
*/

	type plane_t is record
	(
		loc_sid number,
		mob_sid number,
		tailNo  varchar2(7),
		TP      number,
		hours   number
	);

	type planeArr_t is table of plane_t
		index by binary_integer;


	type percent_t is record
	(
		loc_sid     number,
		mob_sid     number,
		timeP       number,
		FHval       number,
		HSval       number,
		FHpct       number,
		HSpct       number
	);

	type percentArr_t is table of percent_t
		index by binary_integer;

	cumArr       percentArr_t;
	percentArr   percentArr_t;
	NUMPERIODS   number:=72;

	function  GetMobSid(
							pFslSid number) return number;
	function  TranslateId(
							pLoc varchar2) return number;
	procedure ProcessFH;
	procedure ProcessHS;
	procedure ProcessLD;
	procedure CalcPctFH;
	procedure CalcAmcFH;
	procedure CalcAlcFH;
	procedure CalcAmcHS;
	procedure CalcAlcHS;
	procedure CalcAmcLD;
	procedure CalcAlcLD;
	procedure Msg(
							pString varchar2);


	procedure Msg(
							pString varchar2) is
	begin
		dbms_output.put_line(to_char(sysdate,'hh:mi:ss')||':'||pString);
	end;




	--
	-- FLIGHT HOURS
	--
	procedure CalcPctFH is

		cursor PercentFHCur is
			select
				decode(FH.location_name,
					'MOB', Assignments.loc_sid,
					asn.loc_sid) Location,
				FH.TimePeriod TP,
				FH.Hours qVal
			from
				(select
					nvl(asn.loc_id,aix.location_name) location_name,
					substr(amf.tail_no,1,5) TailNo,
					months_between(trunc(actual_arrive_time,'mm'),
						trunc(to_date('19961001','yyyymmdd'),'mm'))+1 TimePeriod,
					sum((amf.ACTUAL_ARRIVE_TIME-amf.ACTUAL_DEPART_TIME)*24) Hours
				from
					amd_mission_flights amf,
					amd_icao_xref aix,
					amd_spare_networks asn
				where
					aix.icao = substr(amf.arrival_icao,1,1)
					and amf.arrival_icao = asn.icao(+)
					and aix.location_name != 'TBD'
					and amf.actual_arrive_time >= amf.actual_depart_time
					and amf.actual_arrive_time >= to_date('19961001','yyyymmdd')
				group by
					nvl(asn.loc_id,aix.location_name),
					amf.tail_no,
					months_between(trunc(actual_arrive_time,'mm'),
						trunc(to_date('19961001','yyyymmdd'),'mm'))+1) FH,
				(select
					substr(aaa.tail_no,2,5) TailNo,
					asn.loc_sid,
					location_name,
					months_between(trunc(assignment_start,'mm'),
						trunc(to_date('19961001','yyyymmdd'),'mm'))+1 StartPeriod,
					months_between(trunc(nvl(assignment_end,sysdate),'mm'),
						trunc(to_date('19961001','yyyymmdd'),'mm'))+1 EndPeriod
				from
					amd_ac_assigns aaa,
					amd_spare_networks asn
				where
					aaa.loc_sid = asn.loc_sid
					and asn.loc_type in ('FSL','MOB')
					and asn.loc_sid != 5
					and aaa.assignment_start <= sysdate
					and nvl(aaa.assignment_end,sysdate) >= to_date('19961001','yyyymmdd')
					and aaa.tail_no != 'DUMMY') Assignments,
				(select
					loc_sid,
					loc_id,
					location_name
				from amd_spare_networks
				where loc_type in ('FSL','MOB')
					and loc_sid != 5) asn
			where
				FH.TailNo          = Assignments.TailNo
				and FH.TimePeriod >= Assignments.StartPeriod
				and FH.TimePeriod <= Assignments.EndPeriod
				and ((FH.location_name = 'MOB'
						and Assignments.loc_sid = asn.loc_sid)
					or
						(FH.location_name = asn.loc_id));

		cursor PercentHSCur is
			select
				decode(FH.location_name,
					'MOB', Assignments.loc_sid,
					asn.loc_sid) Location,
				FH.TimePeriod TP,
				FH.Hours qVal
			from
				(select
					nvl(asn.loc_id,aix.location_name) location_name,
					substr(amf.tail_no,1,5) TailNo,
					months_between(trunc(actual_arrive_time,'mm'),
						trunc(to_date('19961001','yyyymmdd'),'mm'))+1 TimePeriod,
					count((amf.ACTUAL_ARRIVE_TIME-amf.ACTUAL_DEPART_TIME)*24) Hours
				from
					amd_mission_flights amf,
					amd_icao_xref aix,
					amd_spare_networks asn
				where
					aix.icao = substr(amf.arrival_icao,1,1)
					and amf.arrival_icao = asn.icao(+)
					and aix.location_name != 'TBD'
					and amf.actual_arrive_time >= amf.actual_depart_time
					and amf.actual_arrive_time >= to_date('19961001','yyyymmdd')
				group by
					nvl(asn.loc_id,aix.location_name),
					amf.tail_no,
					months_between(trunc(actual_arrive_time,'mm'),
						trunc(to_date('19961001','yyyymmdd'),'mm'))+1) FH,
				(select
					substr(aaa.tail_no,2,5) TailNo,
					asn.loc_sid,
					location_name,
					months_between(trunc(assignment_start,'mm'),
						trunc(to_date('19961001','yyyymmdd'),'mm'))+1 StartPeriod,
					months_between(trunc(nvl(assignment_end,sysdate),'mm'),
						trunc(to_date('19961001','yyyymmdd'),'mm'))+1 EndPeriod
				from
					amd_ac_assigns aaa,
					amd_spare_networks asn
				where
					aaa.loc_sid = asn.loc_sid
					and asn.loc_type in ('FSL','MOB')
					and asn.loc_sid != 5
					and aaa.assignment_start <= sysdate
					and nvl(aaa.assignment_end,sysdate) >= to_date('19961001','yyyymmdd')
					and aaa.tail_no != 'DUMMY') Assignments,
				(select
					loc_sid,
					loc_id,
					location_name
				from amd_spare_networks
				where loc_type in ('FSL','MOB')
					and loc_sid != 5) asn
			where
				FH.TailNo          = Assignments.TailNo
				and FH.TimePeriod >= Assignments.StartPeriod
				and FH.TimePeriod <= Assignments.EndPeriod
				and ((FH.location_name = 'MOB'
						and Assignments.loc_sid = asn.loc_sid)
					or
						(FH.location_name = asn.loc_id));

		cursor locCur is
			select
				mob.loc_sid mob,
				fsl.loc_sid fsl
			from
				amd_spare_networks mob,
				(select
					nvl(mob,loc_id) mob,
					loc_sid
				from amd_spare_networks
				where loc_type in ('FSL','MOB')
					and location_name != 'ALTUS') fsl
			where
				fsl.mob = mob.loc_id
			order by
				mob.loc_sid,
				fsl.loc_sid;

		totFHval     number;
		totHSval     number;
		i            number;
		j            number;
		ix           number;
		tpIx         number;
		offset       number;
		numCells     number;
	begin

		Msg('CalcPctFH()');

		percentArr.delete;
		cumArr.delete;
		j := 0;
		numCells := 0;
		for rec in locCur loop
			for i in 1..NUMPERIODS loop
				offset := (j*NUMPERIODS)+i;
				percentArr(offset).loc_sid := rec.fsl;
				percentArr(offset).mob_sid := rec.mob;
				percentArr(offset).timeP  := i;
				percentArr(offset).FHval  := 0;
				percentArr(offset).FHpct  := 0;
				percentArr(offset).HSval  := 0;
				percentArr(offset).HSpct  := 0;
				cumArr(i).FHval := 0;
				cumArr(i).HSval := 0;
				numCells := numCells + 1;
			end loop;
			j := j+1;
		end loop;

		Msg('Collecting FH data');
		for rec in PercentFHCur loop

			offset := 0;
			while (percentArr(offset+1).loc_sid != rec.location) loop
				offset := offset + NUMPERIODS;
				if (offset >= numCells) then
					Msg('rec.location:'||rec.location);
					exit;
				end if;
			end loop;

			tpIx := offset+rec.TP;
			percentArr(tpIx).FHval  := percentArr(tpIx).FHval + rec.qVal;

			-- Sum total FHval
			cumArr(rec.TP).FHval := cumArr(rec.TP).FHval + rec.qVal;

		end loop;

		Msg('Collecting HS data');
		for rec in PercentHSCur loop

			offset := 0;
			while (percentArr(offset+1).loc_sid != rec.location) loop
				offset := offset + NUMPERIODS;
				if (offset >= numCells) then
					Msg('rec.location:'||rec.location);
					exit;
				end if;
			end loop;

			tpIx := offset+rec.TP;
			percentArr(tpIx).HSval  := percentArr(tpIx).HSval + 1;

			-- Sum total FHval
			cumArr(rec.TP).HSval := cumArr(rec.TP).HSval + 1;

		end loop;

		Msg('Calculating percents');
		i := percentArr.first;
		while i is not null loop
			totFHval := cumArr(percentArr(i).timeP).FHval;
			totHSval := cumArr(percentArr(i).timeP).HSval;
			if (totFHval > 0) then
				percentArr(i).FHpct := percentArr(i).FHval/totFHval;
			else
				percentArr(i).FHpct := 0;
			end if;

			if (totHSval > 0) then
				percentArr(i).HSpct := percentArr(i).HSval/totHSval;
			else
				percentArr(i).HSpct := 0;
			end if;

			Msg(i||':'||percentArr(i).loc_sid||':'||percentArr(i).timeP||':'||
				round(percentArr(i).FHval,4)||':'||
				round(cumArr(percentArr(i).timeP).FHval,4)||':'||
				round(percentArr(i).FHpct,4));
			Msg(i||':'||percentArr(i).loc_sid||':'||percentArr(i).timeP||':'||
				round(percentArr(i).HSval,4)||':'||
				round(cumArr(percentArr(i).timeP).HSval,4)||':'||
				round(percentArr(i).HSpct,4));

			i := percentArr.next(i);
		end loop;

	exception
		when others then
			Msg(sqlerrm);
			Msg('offset:'||offset||':tpIx:'||tpIx);
	end;


	procedure CalcAmcFH is

		cursor amcCur is
			SELECT
				aaau.tail_no TailNo,
				months_between(trunc(aaau.effective_date,'mm'),
					trunc(to_date('19961001','yyyymmdd'),'mm'))+1 TimePeriod,
				last_day(trunc(aaau.effective_date,'MM')) FHTimeBucket,
				SUM(aaau.usage) qValue
			FROM
				amd_aircrafts aa,
				amd_spare_networks asn,
				amd_ac_assigns aaa,
				amd_actual_ac_usages aaau
			WHERE
				aa.p_no like 'P%'
				and asn.loc_type in ('FSL','MOB')
				and aa.tail_no = aaau.tail_no
				and aa.tail_no = aaa.tail_no
				and aaa.loc_sid = asn.loc_sid
				and aaau.tail_no = aaa.tail_no
				and asn.location_name != 'ALTUS'
				and aaau.effective_date
					between aaa.assignment_start and nvl(aaa.assignment_end,sysdate)
				and trunc(aaau.effective_date) >= to_date('19961001','yyyymmdd')
				AND upper(aaau.uom_code)    = 'FH'
			GROUP BY
				aaau.tail_no,
				aaau.effective_Date;

		prevTail    number:=-101;
		i           number:=0;
		k           number;
		ix          number;
		tpix        number;
		hours       number;
		percent     number;
		amcArr      planeArr_t;
		locSid      number;
	begin
		Msg('CalcAmcFH()');

		Msg('Calculating AMC hours');
		amcArr.delete;
		for rec in amcCur loop
			if (prevTail != rec.TailNo) then
				ix        :=( i*NUMPERIODS);
				i         := i + 1;
				prevTail  := rec.TailNo;

				for j in 1..(NUMPERIODS) loop
					amcArr(ix+j).tailNo := rec.tailNo;
					amcArr(ix+j).tP     := j;
					amcArr(ix+j).hours  := 0;
				end loop;
			end if;

			tpIx := ix+rec.timePeriod;
			amcArr(tpIx).hours  := amcArr(tpIx).hours + rec.qValue;

		end loop;

		Msg('Applying percentages to AMC hours');
		for i in 1..amcArr.count loop

			k := 0;
			loop
				tpix := (k*NUMPERIODS)+amcArr(i).tP;
				exit when not percentArr.exists(tpix);
				percent := percentArr(tpix).FHpct;
				hours   := amcArr(i).hours * percent;
--				Msg(amcArr(i).tailNo||':'||amcArr(i).tP||':'||
--					percentArr(tpix).loc_sid||':'||round(amcArr(i).hours,2)||':'||
--					round(percentArr(tpix).FHpct,2)||':'||hours);

				insert into amd_flight_stats
				(
					base,
					fsl,
					tail_no,
					time_period,
					uom,
					uom_value
				)
				values
				(
					percentArr(tpIx).mob_sid,
					percentArr(tpIx).loc_sid,
					amcArr(i).tailNo,
					percentArr(tpix).timeP,
					'FH',
					hours
				);

				k := k + 1;
			end loop;

		end loop;


	end;


	procedure CalcAlcFH is
		cursor alcCur is
			SELECT
				asn.loc_sid,
				aaau.tail_no TailNo,
				months_between(trunc(aaau.effective_date,'mm'),
					trunc(to_date('19961001','yyyymmdd'),'mm'))+1 TimePeriod,
				last_day(trunc(aaau.effective_date,'MM')) FHTimeBucket,
				SUM(aaau.usage) qValue
			FROM
				amd_aircrafts aa,
				amd_spare_networks asn,
				amd_ac_assigns aaa,
				amd_actual_ac_usages aaau
			WHERE
				aa.p_no like 'P%'
				and asn.loc_type in ('FSL','MOB')
				and aa.tail_no = aaau.tail_no
				and aa.tail_no = aaa.tail_no
				and aaa.loc_sid = asn.loc_sid
				and aaau.tail_no = aaa.tail_no
				and asn.location_name = 'ALTUS'
				and aaau.effective_date
					between aaa.assignment_start and nvl(aaa.assignment_end,sysdate)
				and trunc(aaau.effective_date) >= to_date('19961001','yyyymmdd')
				AND upper(aaau.uom_code)    = 'FH'
			GROUP BY
				asn.loc_sid,
				aaau.tail_no,
				aaau.effective_Date;

		i           number;
		ix          number;
		tpix        number;
		prevTail    varchar2(20):='INITIAL';
		alcArr      planeArr_t;
		locSid      number;
	begin
		Msg('CalcAlcFH()');
		alcArr.delete;
		i := 0;
		for rec in alcCur loop
			if (prevTail != rec.TailNo) then
				ix        :=( i*NUMPERIODS);
				i         := i + 1;
				prevTail  := rec.TailNo;

				for j in 1..(NUMPERIODS) loop
					alcArr(ix+j).loc_sid := rec.loc_sid;
					alcArr(ix+j).tailNo := rec.tailNo;
					alcArr(ix+j).tP     := j;
					alcArr(ix+j).hours  := 0;
				end loop;
			end if;

			tpIx := ix+rec.timePeriod;
			alcArr(tpIx).hours  := alcArr(tpIx).hours + rec.qValue;

		end loop;

		Msg('Applying percentages to ALC hours');
		for i in 1..alcArr.count loop

			insert into amd_flight_stats
			(
				base,
				fsl,
				tail_no,
				time_period,
				uom,
				uom_value
			)
			values
			(
				alcArr(i).loc_sid,
				alcArr(i).loc_sid,
				alcArr(i).tailNo,
				alcArr(i).tP,
				'FH',
				alcArr(i).hours
			);

		end loop;
	end;



	--
	-- HARD STOPS
	--
	procedure CalcAmcHS is

		cursor amcCur is
			SELECT
				aaau.tail_no TailNo,
				months_between(trunc(aaau.effective_date,'mm'),
					trunc(to_date('19961001','yyyymmdd'),'mm'))+1 TimePeriod,
				last_day(trunc(aaau.effective_date,'MM')) FHTimeBucket,
				SUM(aaau.usage) qValue
			FROM
				amd_aircrafts aa,
				amd_spare_networks asn,
				amd_ac_assigns aaa,
				amd_actual_ac_usages aaau
			WHERE
				aa.p_no like 'P%'
				and asn.loc_type in ('FSL','MOB')
				and aa.tail_no = aaau.tail_no
				and aa.tail_no = aaa.tail_no
				and aaa.loc_sid = asn.loc_sid
				and aaau.tail_no = aaa.tail_no
				and asn.location_name != 'ALTUS'
				and aaau.effective_date
					between aaa.assignment_start and nvl(aaa.assignment_end,sysdate)
				and trunc(aaau.effective_date) >= to_date('19961001','yyyymmdd')
				AND upper(aaau.uom_code)    = 'HS'
			GROUP BY
				aaau.tail_no,
				aaau.effective_Date;

		prevTail    varchar2(20):='INITIAL';
		i           number:=0;
		k           number;
		ix          number;
		tpix        number;
		hours       number;
		percent     number;
		amcArr      planeArr_t;
		totalHours  number:=0;
		locSid      number;
	begin
		Msg('CalcAmcHS()');

		Msg('Calculating AMC hours');
		amcArr.delete;
		for rec in amcCur loop
			if (prevTail != rec.TailNo) then
				ix        :=( i*NUMPERIODS);
				i         := i + 1;
				prevTail  := rec.TailNo;

				for j in 1..(NUMPERIODS) loop
					amcArr(ix+j).tailNo := rec.tailNo;
					amcArr(ix+j).tP     := j;
					amcArr(ix+j).hours  := 0;
				end loop;
			end if;

			tpIx := ix+rec.timePeriod;
			amcArr(tpIx).hours  := amcArr(tpIx).hours + rec.qValue;

			if (rec.timePeriod = 4) then
				totalHours := totalHours + rec.qValue;
			end if;

		end loop;

		Msg('Applying percentages to AMC hours');
		for i in 1..amcArr.count loop

			k := 0;
			loop
				tpix := (k*NUMPERIODS)+amcArr(i).tP;
				exit when not percentArr.exists(tpix);
				percent := percentArr(tpix).HSpct;
				hours   := amcArr(i).hours * percent;
--				Msg(amcArr(i).tailNo||':'||amcArr(i).tP||':'||
--					percentArr(tpix).loc_sid||':'||round(amcArr(i).hours,2)||':'||
--					round(percentArr(tpix).HSpct,2)||':'||hours);

				insert into amd_flight_stats
				(
					base,
					fsl,
					tail_no,
					time_period,
					uom,
					uom_value
				)
				values
				(
					percentArr(tpix).mob_sid,
					percentArr(tpix).loc_sid,
					amcArr(i).tailNo,
					percentArr(tpix).timeP,
					'HS',
					hours
				);

				k := k + 1;
			end loop;

		end loop;


	end;


	procedure CalcAlcHS is
		cursor alcCur is
			SELECT
				asn.loc_sid,
				aaau.tail_no TailNo,
				months_between(trunc(aaau.effective_date,'mm'),
					trunc(to_date('19961001','yyyymmdd'),'mm'))+1 TimePeriod,
				last_day(trunc(aaau.effective_date,'MM')) FHTimeBucket,
				SUM(aaau.usage) qValue
			FROM
				amd_aircrafts aa,
				amd_spare_networks asn,
				amd_ac_assigns aaa,
				amd_actual_ac_usages aaau
			WHERE
				aa.p_no like 'P%'
				and asn.loc_type in ('FSL','MOB')
				and aa.tail_no = aaau.tail_no
				and aa.tail_no = aaa.tail_no
				and aaa.loc_sid = asn.loc_sid
				and aaau.tail_no = aaa.tail_no
				and asn.location_name = 'ALTUS'
				and aaau.effective_date
					between aaa.assignment_start and nvl(aaa.assignment_end,sysdate)
				and trunc(aaau.effective_date) >= to_date('19961001','yyyymmdd')
				AND upper(aaau.uom_code)    = 'HS'
			GROUP BY
				asn.loc_sid,
				aaau.tail_no,
				aaau.effective_Date;

		i           number;
		ix          number;
		tpix        number;
		prevTail    varchar2(20):='INITIAL';
		alcArr      planeArr_t;
		totalHours  number:=0;
		locSid      number;
	begin
		Msg('CalcAlcHS()');
		alcArr.delete;
		i := 0;
		for rec in alcCur loop
			if (prevTail != rec.TailNo) then
				ix        :=( i*NUMPERIODS);
				i         := i + 1;
				prevTail  := rec.TailNo;

				for j in 1..(NUMPERIODS) loop
					alcArr(ix+j).loc_sid := rec.loc_sid;
					alcArr(ix+j).tailNo := rec.tailNo;
					alcArr(ix+j).tP     := j;
					alcArr(ix+j).hours  := 0;
				end loop;
			end if;

			tpIx := ix+rec.timePeriod;
			alcArr(tpIx).hours  := alcArr(tpIx).hours + rec.qValue;

			if (rec.timePeriod = 4) then
				totalHours := totalHours + rec.qValue;
			end if;

		end loop;

		Msg('tp4 cum hours:'||totalHours);

		Msg('Applying percentages to ALC hours');
		for i in 1..alcArr.count loop

			insert into amd_flight_stats
			(
				base,
				fsl,
				tail_no,
				time_period,
				uom,
				uom_value
			)
			values
			(
				alcArr(i).loc_sid,
				alcArr(i).loc_sid,
				alcArr(i).tailNo,
				alcArr(i).tP,
				'HS',
				alcArr(i).hours
			);

		end loop;
	end;



	--
	-- LANDINGS
	--
	procedure CalcAmcLD is

		cursor amcCur is
			select
				aaa.loc_sid,
				usageQ.tail_no,
				trunc(months_between(usageQ.time_period,to_date('19961001','yyyymmdd')))+1 time_period,
				usageQ.usage-statsQ.usage usageDelta
			from
				(SELECT
					aaau.tail_no,
					effective_date time_period,
					SUM(usage) usage
				FROM
					amd_actual_ac_usages aaau,
					amd_ac_assigns aaa
				WHERE
					trunc(effective_date) >= to_date('10011996','mmddyyyy')
					AND upper(uom_code) = 'LD'
					and aaa.loc_sid != 5
					and aaau.tail_no = aaa.tail_no
					and aaau.effective_date between
						aaa.assignment_start and nvl(aaa.assignment_end,sysdate)
				GROUP BY
					aaau.tail_no,
					effective_Date)	UsageQ,
				(SELECT
					tail_no,
					Time_period,
					SUM(uom_value) usage
				FROM amd_flight_stats
				WHERE
					upper(uom) = 'HS'
					and base != 5
				GROUP BY
					tail_no,
					time_period)	StatsQ,
				amd_ac_assigns aaa
			where
				usageQ.tail_no = statsQ.tail_no
				and trunc(months_between(usageQ.time_period,to_date('19961001','yyyymmdd')))+1 = statsQ.time_period
				and usageQ.time_period between aaa.assignment_start and nvl(assignment_end,sysdate)
				and usageQ.tail_no	  = aaa.tail_no;


		i           number:=0;
		k           number;
		ix          number;
		tpix        number;
		hours       number;
		percent     number;
		amcArr      planeArr_t;
	begin
		Msg('CalcAmcLD()');

		Msg('Inserting HS values into LD');
		--
		-- Insert LANDINGS records with exact values as HARD STOPS
		-- only for the records where the fsl does not equal the base.
		--
		insert into amd_flight_stats
			select
				base,
				destination_icao,
				fsl,
				tail_no,
				time_period,
				'LD',
				uom_value
			from
				amd_flight_stats afs,
				amd_spare_networks asn
			where
				uom = 'HS'
				and afs.base = asn.loc_sid
				and asn.location_name != 'ALTUS';

		Msg('Adding delta landings at the base level');
		for rec in amcCur loop
			update amd_flight_stats afs set
				uom_value =  uom_value + rec.usageDelta
			where
				base            = fsl
				and base        = rec.loc_sid
				and tail_no     = rec.tail_no
				and time_period = rec.time_period
				and uom         = 'LD';

		end loop;

	end;


	procedure CalcAlcLD is
		cursor alcCur is
			SELECT
				asn.loc_sid,
				aaau.tail_no TailNo,
				months_between(trunc(aaau.effective_date,'mm'),
					trunc(to_date('19961001','yyyymmdd'),'mm'))+1 TimePeriod,
				last_day(trunc(aaau.effective_date,'MM')) FHTimeBucket,
				SUM(aaau.usage) qValue
			FROM
				amd_aircrafts aa,
				amd_spare_networks asn,
				amd_ac_assigns aaa,
				amd_actual_ac_usages aaau
			WHERE
				aa.p_no like 'P%'
				and asn.loc_type in ('FSL','MOB')
				and aa.tail_no = aaau.tail_no
				and aa.tail_no = aaa.tail_no
				and aaa.loc_sid = asn.loc_sid
				and aaau.tail_no = aaa.tail_no
				and asn.location_name = 'ALTUS'
				and aaau.effective_date
					between aaa.assignment_start and nvl(aaa.assignment_end,sysdate)
				and trunc(aaau.effective_date) >= to_date('19961001','yyyymmdd')
				AND upper(aaau.uom_code)    = 'LD'
			GROUP BY
				asn.loc_sid,
				aaau.tail_no,
				aaau.effective_Date;

		i           number;
		ix          number;
		tpix        number;
		prevTail    varchar2(20):='INITIAL';
		alcArr      planeArr_t;
		locSid      number;
	begin
		Msg('CalcAlcLD()');
		alcArr.delete;
		i := 0;
		for rec in alcCur loop
			if (prevTail != rec.TailNo) then
				ix        :=( i*NUMPERIODS);
				i         := i + 1;
				prevTail  := rec.TailNo;

				for j in 1..(NUMPERIODS) loop
					alcArr(ix+j).loc_sid := rec.loc_sid;
					alcArr(ix+j).tailNo := rec.tailNo;
					alcArr(ix+j).tP     := j;
					alcArr(ix+j).hours  := 0;
				end loop;
			end if;

			tpIx := ix+rec.timePeriod;
			alcArr(tpIx).hours  := alcArr(tpIx).hours + rec.qValue;

		end loop;

		Msg('Applying percentages to ALC hours');
		for i in 1..alcArr.count loop

			insert into amd_flight_stats
			(
				base,
				fsl,
				tail_no,
				time_period,
				uom,
				uom_value
			)
			values
			(
				alcArr(i).loc_sid,
				alcArr(i).loc_sid,
				alcArr(i).tailNo,
				alcArr(i).tP,
				'LD',
				alcArr(i).hours
			);

		end loop;
	end;


	function  TranslateId(
							pLoc varchar2) return number is
		locSid    number;
	begin
		select loc_sid
		into locSid
		from amd_spare_networks
		where loc_id = pLoc;

		return locSid;
	end;


	function  GetMobSid(
							pFslSid number) return number is
		mobSid    number;
	begin
		select
			mob.loc_sid mob
		into mobSid
		from
			(select
				nvl(mob,loc_id) mob,
				loc_sid
			from amd_spare_networks
			where loc_type in ('FSL','MOB')) fsl,
			amd_spare_networks mob
		where
			fsl.mob = mob.loc_id
			and fsl.loc_sid = pFslSid;

		return mobSid;
	end;



	procedure ProcessFH is
	begin
		CalcPctFH;
		CalcAmcFH;
		CalcAlcFH;
	end;


	procedure ProcessHS is
	begin
		CalcAmcHS;
		CalcAlcHS;
	end;


	procedure ProcessLD is
	begin
		CalcAmcLD;
		CalcAlcLD;
	end;


	procedure ProcessFlightData is
	begin
		Msg('ProcessFlightData() Begin');

		processFH;
		processHS;
		processLD;

		Msg('ProcessFlightData() End');
	end;


end;
/
