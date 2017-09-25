DROP PACKAGE AMD_OWNER.AMD_LOAD_X;

CREATE OR REPLACE PACKAGE AMD_OWNER.amd_load_x as
/*
       $Author:   zf297a  $
     $Revision:   1.0  $
         $Date:   Dec 01 2005 09:33:24  $
     $Workfile:   AMD_LOAD_X.pks  $
	 $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_LOAD_X.pks.-arc  $
/*   
/*      Rev 1.0   Dec 01 2005 09:33:24   zf297a
/*   Initial revision.
*/
	--
	-- SCCSID: amd_load.sql  1.20  Modified: 03/05/03 13:25:37
	--
	-- Date     By     History
	-- -------- -----  ---------------------------------------------------
	-- 09/28/01 FF     Initial implementation
	-- 10/22/01 FF     Removed references to venc, venn from LoadGold().
	-- 10/23/01 FF     Changed exception in LoadTempNsns() and passed GOLD
	--                 smr_code if nothing else.
	-- 10/30/01 FF     Fixed getPrime() to look at all records for a '17P','17B'
	--                 match.
	-- 11/02/01 FF     Fixed logic in LoadTempNsns() to include GetPrime() and
	--                 associate logic.
	-- 11/12/01 FF     Fixed LoadGold() to use the part as prime for ANY NSL
	--                 that gets an nsn from BSSM other than of the form NSL#.
	-- 11/15/01 FF     Mod LoadGold() and LoadMain() to let equiv parts get
	--                 values from prime for item_type,order_quantity,
	--                 planner_code and smr_code.
	-- 11/19/01 FF     Mod LoadTempNsns to ignore the last 2 char's of the nsn
	--                 if they are not numeric.
	-- 11/21/01 FF     Removed references to gold_mfgr_cage.
	-- 11/29/01 FF     Fixed LoadTempNsns() and added lock_sid=0 condition
	--                 to cursor in LoadTempNsns().
	-- 12/10/01 FF     Fixed cursor in LoadTempNsns() to link with
	--                 amd_spare_parts.
	-- 12/21/01 FF     Added acquisition_advice_code.
	-- 01/28/02 FF     Added "FROM" column as temp nsns to LoadTempNsns().
	-- 02/19/02 FF     Added logic for manuf_cage to GetPrime().
	-- 02/25/02 FF     Fixed GetPrime() priority logic.
	-- 03/05/02 FF     Added logic to unit_cost code to look at po's with 9
	--                 characters only.
	-- 03/18/02 FF     The noun field is no longer truncated.
	-- 04/03/02 FF     Populated mic in tmp_amd_spare_parts.
	-- 06/04/02 FF     Removed debug record limiter.
	-- 06/14/02 FF     Changed references to PSMS to use synonyms.
	-- 07/05/02 FF     Changed references to PSMV to use synonyms.
	-- 10/14/02 FF     Mod'ed loadGold() to blindly assign the part as a prime
	--                 only if sequenceTheNsl() returned an nsn of type NSL.
	-- 11/05/02 FF     Get unit_cost from gold.prc1 instead of tmp_main. This
	--                 is now done in loadGold() instead of loadMain().
	-- 02/21/03 FF     Added performLogicalDelete() to allow NSL's to get
	--                 their own sid.
	--

	procedure LoadGold;
	procedure LoadPsms;
	procedure LoadMain;
	procedure LoadTempNsns;

end amd_load_x;
 
/

CREATE OR REPLACE PUBLIC SYNONYM AMD_LOAD_X FOR AMD_OWNER.AMD_LOAD_X;


GRANT EXECUTE ON AMD_OWNER.AMD_LOAD_X TO BSRM_LOADER;
DROP PACKAGE BODY AMD_OWNER.AMD_LOAD_X;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.amd_load_x as
/*
       $Author:   zf297a  $
     $Revision:   1.0  $
         $Date:   Dec 01 2005 09:33:24  $
     $Workfile:   AMD_LOAD_X.pkb  $
	 $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_LOAD_X.pkb.-arc  $
/*   
/*      Rev 1.0   Dec 01 2005 09:33:24   zf297a
/*   Initial revision.
*/
	--
	-- Local Declarations
	--
	function  GetSmr(
							pPsmsInst varchar2,
							pPart varchar2,
							pCage varchar2) return varchar2;
	function  GetPsmsInstance (
							pPart varchar2,
							pCage varchar2) return varchar2;
	procedure GetPsmsData(
							pPartNo varchar2,
							pCage varchar2,
							pPsmsInst varchar2,
							pSlifeDay out number,
							pUnitVol  out number,
							pSmrCode  out varchar2);
	function  IsValidSmr(
							pSmrCode varchar2) return boolean;
	function  GetPrime(
							pNsn char) return varchar2;
	function  GetItemType(
							pSmrCode varchar2) return varchar2;
	function  getMic(
							pNsn varchar2) return varchar2;
	function  getUnitCost(
							pPartNo varchar2) return number;
	procedure performLogicalDelete(
							pPartNo varchar2);
	function  onNsl(
							pPartNo varchar2) return boolean;




	--
	-- procedure/Function bodies
	--

	function  getUnitCost(
							pPartNo varchar2) return number is
		cursor costCur is
			select cap_price
			from prc1
			where
				part = pPartNo
			order by
				sc desc;

		unitCost     number;
	begin
		for rec in costCur loop
			unitCost := rec.cap_price;
			exit;
		end loop;

		return unitCost;
	end;


	procedure performLogicalDelete(
							pPartNo varchar2) is
		nsiSid    amd_nsns.nsi_sid%type;
		nsnCnt    number;
	begin

		update amd_spare_parts set
			nsn            = NULL,
			action_code    = amd_defaults.DELETE_ACTION,
			last_update_dt = sysdate
		where part_no = pPartNo;

		begin
			select nsi_sid
			into nsiSid
			from amd_nsi_parts
			where part_no = pPartNo
				and unassignment_date is null;

			update amd_nsi_parts set
				unassignment_date = sysdate
			where part_no = pPartNo
				and nsi_sid = nsiSid;

			select count(*)
			into nsnCnt
			from amd_nsi_parts
			where nsi_sid = nsiSid
				and unassignment_date is null;

			if (nsnCnt = 0) then
				update amd_national_stock_items set
					action_code    = amd_defaults.DELETE_ACTION,
					last_update_dt = sysdate
				where nsi_sid = nsiSid;
			end if;

		exception
			when NO_DATA_FOUND then
				NULL;
		end;

	end;


	function onNsl(
							pPartNo varchar2) return boolean is
		recCnt     number;
	begin

		select count(*)
		into recCnt
		from amd_nsns an
		where nsi_sid in
				(select nsi_sid
				from amd_nsi_parts
				where part_no = pPartNo
					and unassignment_date is null)
			and nsn_type = 'C'
			and nsn like 'NSL%';

		if (recCnt != 0) then
			return TRUE;
		else
			return FALSE;
		end if;
	end;


	function  GetSmr(
							pPsmsInst varchar2,
							pPart varchar2,
							pCage varchar2) return varchar2 is

		/* -------------------------------------------------- */
		/* 1) if there is only one smr code found in PSMS,    */
		/*    use that smr Code.                              */
		/* 2) if more than one smr code found:                */
		/*    2.1) Use the most occurrences in HG table which */
		/*         have length of six characters.             */
		/*    2.2) if there is equal   number of occurrences of */
		/*         smr with length of six characters, select  */
		/*         one smr(anyone).                           */
		/*    2.3) if no smr code with length of six char.    */
		/*         found, use the most occurrences in hg.     */
		/* -------------------------------------------------- */

		cursor sel_psmsprod_smr is
			select * from dual ;
            /*
				hg.smrcodhg,
				count(*),
				max(nvl(length(hg.smrcodhg),0))
			from
				slic_hg_v hg,
				slic_ha_v ha
			where
				--hg.ipn          = ha.ipn
				--and ha.refnumha = pPart
				and ha.cagecdxh = pCage
				and HG.smrcodhg is not NULL
			group by
				hg.smrcodhg
			order by
				max(nvl(length(hg.smrcodhg),0)) desc,
				count(*) desc;
*/
		cursor sel_psmsvend_smr is
			select * from dual ;
            /*
				hg.smrcodhg,
				count(*),
				max(nvl(length(hg.smrcodhg),0))
			from
				amd_psmv_ldmhg hg,
				amd_psmv_ldmha ha
			where
				hg.ipn          = ha.ipn
				and ha.refnumha = pPart
				and ha.cagecdxh = pCage
				and hg.smrcodhg is not NULL
			group by
				HG.smrcodhg
			order by
				max(nvl(length(HG.smrcodhg),0)) desc,
				count(*) desc;
*/
		smr   varchar2(6);
		cnt   number;
		len   number;
	begin

		if pPsmsInst = 'PSMSPROD' then
			open sel_psmsprod_smr;
			--fetch sel_psmsprod_smr into smr, cnt, len;
			close sel_psmsprod_smr;
		else
			open sel_psmsvend_smr;
			--fetch sel_psmsvend_smr into smr, cnt, len;
			close sel_psmsvend_smr;
		end if;

		return smr;

	end GetSmr;




	/* ------------------------------------------------------------------- */
	/*  This procedure returns PSMS Instance to be used: */
	/*                                                                     */
	/*  - PSMSVend Instance keeps Generic Engine Parts.(Pratt and Whitneys)*/
	/*             Per Dan Manigavlt.  if we find parts in PSMSVend,      */
	/*             data is more up to date than in PSMSPROD instance      */
	/*  - PSMSPROD Instance keeps other Quick Engine Change Kit Parts      */
	/*                                                                     */
	/* ------------------------------------------------------------------- */
	function GetPsmsInstance (
							pPart varchar2,
							pCage varchar2) return varchar2 is

		cnt        number;
		psmsInst   varchar2(8);
	begin

		select count(*)
		into cnt
		from
			slic_ha_v ha,
			tmp_amd_spare_parts s
		where
			ha.cagecdxh     = s.mfgr
			and ha.refnumha = s.part_no
			and ha.cagecdxh = pCage
			and ha.refnumha = pPart;

		if cnt > 0 then
			psmsInst := 'PSMSVEND';
		else

			select count(*)
			into cnt
			from
				slic_ha_v ha,
				tmp_amd_spare_parts s
			where
				ha.cagecdxh     = s.mfgr
				and ha.refnumha = s.part_no
				and ha.cagecdxh = pCage
				and ha.refnumha = pPart;

			if cnt > 0 then
				psmsInst := 'PSMSPROD';
			else
				psmsInst := NULL;
			end if;

		end if;

		return psmsInst;

	end GetPsmsInstance;


	procedure GetPsmsData (
							pPartNo varchar2,
							pCage varchar2,
							pPsmsInst varchar2,
							pSlifeDay out number,
							pUnitVol  out number,
							pSmrCode  out varchar2) is

		/* ------------------------------------------------------------------- */
		/*  This procedure returns PSMS data for the Part and Cage Code from   */
		/*  the specified PSMS instance. Any integer indicates Shelf Life in Days          */
		/* ------------------------------------------------------------------- */

		sLife   varchar2(2);
	begin

		if (pPsmsInst = 'PSMSVEND') then

			select
				shlifeha,
				(ulengtha * uwidthha * uheighha) / 1728
			into sLife, pUnitVol
			from
				slic_ha_v ha,
				tmp_amd_spare_parts s
			where
				ha.cagecdxh     = s.mfgr
				and ha.refnumha = s.part_no
				and ha.cagecdxh = pCage
				and ha.refnumha = pPartNo;

			if (sLife is not null) then
				select storage_days
				into pSlifeDay
				from amd_shelf_life_codes
				where sl_code = sLife;
			end if;

		elsif (pPsmsInst = 'PSMSPROD') then

			select
				shlifeha,
				(ulengtha * uwidthha * uheighha) / 1728
			into sLife, pUnitVol
			from
				slic_ha_v ha,
				tmp_amd_spare_parts s
			where
				ha.cagecdxh     = s.mfgr
				and ha.refnumha = s.part_no
				and ha.cagecdxh = pCage
				and ha.refnumha = pPartNo;

			if (slife is not null) then
				select storage_days
				into pSlifeDay
				from amd_shelf_life_codes
				where sl_code = sLife;
			end if;

		end if;

		pSmrCode := GetSmr(pPsmsInst, pPartNo, pCage);

	end GetPsmsData;


	function  IsValidSmr(
							pSmrCode varchar2) return boolean is
	begin

		if (substr(pSmrCode,6,1) in ('T','P','N')) then
			return TRUE;
		else
			return FALSE;
		end if;

	end IsValidSmr;


	function GetPrime(
							pNsn char) return varchar2 is
		--
		-- Cursor selects primes w/matching part on same or other rec UNION with
		-- ONE record to use as default if no records satisfy above portion
		--
		cursor primeCur is
			select distinct
				1 qNo,
				decode(part,prime,'1 - Prime','2 - Equivalent') partType,
				rtrim(part) part,
				rtrim(prime) prime,
				rtrim(manuf_cage) manuf_cage
			from cat1 c1
			where c1.nsn = pNsn
				and exists
				(select 'x'
				from cat1 c2
				where c2.nsn = c1.nsn
					and c2.part = c1.prime)
			union
			select distinct
				2 qNo,
				decode(part,prime,'1 - Prime','2 - Equivalent') partType,
				rtrim(part) part,
				rtrim(prime) prime,
				rtrim(manuf_cage) manuf_cage
			from cat1
			where nsn = pNsn
				and rownum =1
			order by
				qNo,
				partType,
				prime,
				part;


		goodPrime   varchar2(50);
		firstPass   boolean:=TRUE;
		primePrefix  varchar2(3);
		char1       varchar2(1);
		char2       varchar2(1);
		char3       varchar2(1);
		priority    number:=0;
	begin

		for rec in primeCur loop
			--
			-- Set part of first rec as good prime in case good prime never shows.
			-- Funky logic used in Best Spares to determine good prime compares
			-- first 3 characters to determine good prime.
			--
			if (firstPass) then
				goodPrime := rec.part;
				firstPass := FALSE;
			end if;

			primePrefix := substr(rec.prime,1,3);
			char1       := substr(rec.prime,1,1);
			char2       := substr(rec.prime,2,1);
			char3       := substr(rec.prime,3,1);

			if (rec.qNo = 1) then
				if (rec.part = rec.prime and rec.manuf_cage = '88277') then
					goodPrime := rec.prime;
					priority := 6;
				end if;

				if (priority < 6 and rec.part = rec.prime) then
					goodPrime := rec.prime;
					priority := 5;
				end if;

				if (priority < 5 and primePrefix = '17B') then
					goodPrime := rec.prime;
					priority  := 4;
				end if;

				if (priority < 4 and primePrefix = '17P') then
					goodPrime := rec.prime;
					priority  := 3;
				end if;

				if (priority < 3 and ((char1 != '1' or char2 != '7' or
							(char3 not in ('P','B')))
							and (char1> '9' or char1< '1' or char2 != 'D'))) then
					goodPrime := rec.prime;
				end if;
			end if;

		end loop;

		return goodPrime;

	end GetPrime;


	function  GetItemType(
							pSmrCode varchar2) return varchar2 is
		itemType   varchar2(1);
		char1      varchar2(1);
		char6      varchar2(1);
	begin

		char1 := substr(pSmrCode,1,1);
		char6 := substr(pSmrCode,6,1);

		-- Consumable when smr is P____N
		-- Repairable when smr is P____P
		--              or smr is P____T
		--
		if (char1 = 'P') then

			if (char6 = 'N') then
				itemType := 'C';
			elsif (char6 in ('P','T'))  then
				itemType := 'R';
			end if;

		end if;

		return itemType;

	end GetItemType;


	function getMic(
							pNsn varchar2) return varchar2 is
		l67Mic   varchar2(1);
	begin
		select min(mic)
		into l67Mic
		from amd_l67_source
		where
			nsn = pNsn
			and mic != '*';

		return l67Mic;
	end;



	procedure LoadGold is
		cursor catCur is
			select
				rtrim(nsn) nsn,
				decode(prime,part,'PRIME','EQUIVALENT') partType,
				rtrim(part) part,
				rtrim(prime) prime,
				rtrim(manuf_cage) manuf_cage,
				rtrim(source_code) source_code,
				rtrim(noun) noun,
				rtrim(serial_mandatory_b) serial_mandatory_b,
				rtrim(ims_designator_code) ims_designator_code,
				rtrim(smrc) smrc,
				rtrim(user_ref7) user_ref7
			from cat1
			where
				source_code = 'F77'
				and nsn not like 'N%'
			union
			select
				rtrim(nsn) nsn,
				decode(prime,part,'PRIME','EQUIVALENT') partType,
				rtrim(part) part,
				rtrim(prime) prime,
				rtrim(manuf_cage) manuf_cage,
				rtrim(source_code) source_code,
				rtrim(noun) noun,
				rtrim(serial_mandatory_b) serial_mandatory_b,
				rtrim(ims_designator_code) ims_designator_code,
				rtrim(smrc) smrc,
				rtrim(user_ref7) user_ref7
			from cat1
			where
				source_code = 'F77'
				and nsn like 'NSL%'
				and part = prime
			order by
				nsn,
				partType desc,
				part;

		loadNo        number;
		nsn           varchar2(50);
		prevNsn       varchar2(50):='prevNsn';
		nsnStripped   varchar2(50);
		goodPrime     varchar2(50);
		primeInd      varchar2(1);
		itemType      varchar2(1);
		smrCode       varchar2(6);
		plannerCode   varchar2(8);
		nsnType       varchar2(1);
		hasPrimeRec   boolean;
		sequenced     boolean;
		l67Mic        varchar2(1);
		unitCost      number;
	begin

		loadNo := amd_utils.GetLoadNo('GOLD','TMP_AMD_SPARE_PARTS');

		for rec in catCur loop

			if (rec.nsn like 'NSL%') then
				sequenced := TRUE;
				nsn := amd_nsl_sequence_pkg.SequenceTheNsl(rec.prime);
			else
				sequenced := FALSE;
				nsn := rec.nsn;
			end if;

			if (nsn != prevNsn) then
				prevNsn     := nsn;
				nsnStripped := amd_utils.FormatNsn(nsn);

				-- If sequenceTheNsl() returned an NSL$ then it is assumed to be
				-- the prime, otherwise, run it through the getPrime() logic.
				--
				if (nsn like 'NSL%') then
					if (not onNsl(rec.part)) then
						-- An NSL starts the part/nsn process so 'delete' the part
						-- so the diff will think it's a brand new part and
						-- assign it its own nsi_sid.
						--
						performLogicalDelete(rec.part);
					end if;
					goodPrime := rec.part;
				else
					goodPrime := GetPrime(nsn);
				end if;

				nsnType     := 'C';
				plannerCode := rec.ims_designator_code;
				itemType    := NULL;
				smrCode     := rec.smrc;

				if (IsValidSmr(smrCode)) then
					itemType := GetItemType(smrCode);
				end if;

			end if;

			-- if GetPrime() returned a null that means that the nsn no longer
			-- exists in Gold. This happens when a part goes from an NCZ to an NSL
			--
			if (goodPrime is null or rec.part = goodPrime) then
				primeInd := 'Y';
			else
				primeInd := 'N';
			end if;

			l67Mic   := getMic(nsnStripped);
			unitCost := getUnitCost(rec.part);

			insert into tmp_amd_spare_parts
			(
				part_no,
				mfgr,
				icp_ind,
				item_type,
				nomenclature,
				nsn,
				nsn_type,
				planner_code,
				prime_ind,
				serial_flag,
				smr_code,
				acquisition_advice_code,
				unit_cost,
				mic
			)
			values
			(
				rec.part,
				rec.manuf_cage,
				rec.source_code,
				itemType,
				rec.noun,
				nsnStripped,
				nsnType,
				plannerCode,
				primeInd,
				rec.serial_mandatory_b,
				smrCode,
				rec.user_ref7,
				unitCost,
				l67Mic
			);

		end loop;

	end LoadGold;



	procedure LoadPsms is
		cursor F77 is
			select
				part_no,
				mfgr,
				smr_code,
				item_type
			from tmp_amd_spare_parts;

		loadNo        number;
		psmsInstance  varchar2(10);
		SLIFEDAY      number;
		UNITVOL       number;
		smrCode       varchar2(6);
		itemType      varchar2(1);
	begin
		dbms_output.enable(30000);
		--
		--     Get the load_no for insert into amd_load_status table
		--
		loadNo := amd_utils.GetLoadNo('PSMS','TMP_AMD_SPARE_PARTS');

		--
		-- select ICP Part/CAGE and check to see if the part is existing in PSMS.
		--
		for rec in F77 loop
            begin
			psmsInstance := GetPsmsInstance(rec.part_no,rec.mfgr);

			if (psmsInstance is not null) then

				GetPsmsData(rec.part_no,rec.mfgr,psmsInstance,
									sLifeDay,unitVol,smrCode);

				if (IsValidSmr(smrCode)) then
					itemType := GetItemType(smrCode);
				else
					smrCode  := rec.smr_code;
					itemType := rec.item_type;
				end if;

				update tmp_amd_spare_parts set
					shelf_life     = sLifeDay,
					unit_volume    = unitVol,
					smr_code       = smrCode,
					item_type      = itemType
				where
					part_no  = rec.part_no;

			end if;
		EXCEPTION
        when NO_DATA_FOUND then
        dbms_output.put_line(rec.part_no||' '||sLifeDay||' '||unitVol||' nodata');	
		when others then
        dbms_output.put_line(rec.part_no||' '||sLifeDay||' '||unitVol||' others');
        end;
		end loop;

	end LoadPsms;



	procedure LoadMain is
		cursor f77Cur is
			select
				nsn,
				part_no,
				prime_ind,
				substr(smr_code,6,1) smrCode6
			from tmp_amd_spare_parts
			order by
				nsn,
				prime_ind desc;


		loadNo         number;
		cnt            number;
		maxPoDate      DATE;
		maxPo          varchar2(20);
		leadTime       number;
		orderUom       varchar2(2);
		orderQuantity  number;
		orderQty       number;
		poAge          number;
		prevNsn        varchar2(15):='prevNsn';
	begin

		--
		--     Get the load_no for insert into amd_load_status table
		--
		loadNo := amd_utils.GetLoadNo('MAIN','TMP_AMD_SPARE_PARTS');

		for aspRec in f77Cur loop

			--
			-- Attempt to get some values from tmp_main.(Only look at po's that
			-- have a length of 9.)
			--
			begin
				--
				-- select the latest PO date.
				--
				select
					max(to_date(po_date,'RRMMDD')) po_date,
					(trunc(sysdate) - max(to_date(po_date,'RRMMDD'))) po_age
				into
					maxPoDate,
					poAge
				from tmp_main
				where
					part_no = aspRec.part_no
					and length(substr(po_no,1,instr(po_no,' ')-1)) = 9;

				--
				-- get latest PO
				--
				select
					max(po_no)
				into maxPo
				from tmp_main
				where
					part_no     = aspRec.part_no
					and po_date = to_char(maxPoDate,'RRMMDD')
					and length(substr(po_no,1,instr(po_no,' ')-1)) = 9;

				select
					total_lead_time,
					order_unit_measure,
					order_qty
				into
					leadTime,
					orderUom,
					orderQuantity
				from tmp_main
				where
					part_no     = aspRec.part_no
					and po_date = to_char(maxPoDate,'RRMMDD')
					and po_no   = maxPo
					and length(substr(po_no,1,instr(po_no,' ')-1)) = 9;

				-- We apply the order_quantity we got from the prime part
				-- to all the equivalent parts so we only set it here when the
				-- prime rec comes in.  The prime rec is the first rec in the
				-- nsn series due to the sort order of the cursor.
				--
				if (aspRec.nsn != prevNsn) then
					prevNsn := aspRec.nsn;
					orderQty := orderQuantity;
				end if;

			exception
				when no_data_found then
					orderQuantity := NULL;
					leadTime      := NULL;
					orderUom      := NULL;
			end;

			update tmp_amd_spare_parts set
				order_lead_time = leadTime,
				order_uom       = orderUom,
				order_quantity  = orderQty
			where
				part_no       = aspRec.part_no;

		end loop;

	end LoadMain;



	procedure LoadTempNsns is
		RAW_DATA  number:=0;

		cursor tempNsnCur is
			-- From MILS table
			select distinct
				asp.part_no part,
				rtrim(substr(m.status_line,8,15)) nsnTemp,
				'MILS' dataSource
			from
				amd_spare_parts asp,
				mils m
			where
				m.default_name  = 'A0E'
				and asp.part_no = rtrim(substr(m.status_line,81,30))
				and asp.nsn    != rtrim(substr(m.status_line,8,15))
				and 'NSL'      != rtrim(substr(m.status_line,8,15))
			union
			-- From CHGH table, "FROM" column
			select distinct
				asp.part_no part,
				rtrim(replace(m."FROM",'-',null)) nsnTemp,
				'CHGH' dataSource
			from
				amd_spare_parts asp,
				chgh m
			where
				m.field         = 'NSN'
				and asp.part_no = m.key_value1
				and asp.nsn    != rtrim(replace(m."FROM",'-',null))
				and 'NSL'      != rtrim(replace(m."FROM",'-',null))
			union
			-- From CHGH table, "TO" column
			select distinct
				asp.part_no part,
				rtrim(replace(m."TO",'-',null)) nsnTemp,
				'CHGH' dataSource
			from
				amd_spare_parts asp,
				chgh m
			where
				m.field         = 'NSN'
				and asp.part_no = m.key_value1
				and asp.nsn    != rtrim(replace(m."TO",'-',null))
				and 'NSL'      != rtrim(replace(m."TO",'-',null))
			union
			-- From BSSM_PARTS table
			select distinct
				bp.part_no,
				bp.nsn nsnTemp,
				'BSSM' dataSource
			from
				bssm_parts bp,
				(select nsn
				from bssm_parts
				where nsn like 'NSL#%'
					and lock_sid = RAW_DATA
				minus
				select nsn
				from amd_nsns
				where nsn like 'NSL#%') nslQ
			where
				bp.nsn = nslQ.nsn
				and bp.lock_sid = RAW_DATA
				and bp.part_no is not null
			order by 1;

		nsn       varchar2(16);
		nsiSid    number;
		loadNo    number;
		mmacCode  number;
	begin
		loadNo := amd_utils.GetLoadNo('MILS','AMD_NSNS');

		for rec in tempNsnCur loop
			begin

				if (rec.nsnTemp = 'NSL') then
					nsn := amd_nsl_sequence_pkg.SequenceTheNsl(rec.part);
				elsif (rec.nsnTemp like 'NSL#%') then
					nsn := rec.nsnTemp;
				else
					-- Need to ignore last 2 char's of nsn from MILS if not numeric.
					-- So if last 2 characters are not numeric an exception will
					-- occur and the nsn will be truncated to 13 characters.
					--
					nsn := rec.nsnTemp;
					if (rec.dataSource = 'MILS') then
						begin
							mmacCode := substr(nsn,14,2);
						exception
							when others then
								nsn := substr(nsn,1,13);
						end;
					end if;
				end if;

				nsiSid := amd_utils.GetNsiSid(pPart_no=>rec.part);

				insert into amd_nsns
				(
					nsn,
					nsn_type,
					nsi_sid,
					creation_date
				)
				values
				(
					nsn,
					'T',
					nsiSid,
					sysdate
				);

			exception
				when no_data_found then
					null;     -- nsiSid not found generates this, just ignore
				when dup_val_on_index then
					null;     -- we don't care if nsn is already there
				when others then
					amd_utils.InsertErrorMsg(pLoad_no => loadNo,pKey_1 => 'amd_load.LoadTempNsns',
							pKey_2 => 'Exception: OTHERS',pKey_3 => 'insert into amd_nsns');
			end;

		end loop;

	end;

end amd_load_x;
/

CREATE OR REPLACE PUBLIC SYNONYM AMD_LOAD_X FOR AMD_OWNER.AMD_LOAD_X;


GRANT EXECUTE ON AMD_OWNER.AMD_LOAD_X TO BSRM_LOADER;

