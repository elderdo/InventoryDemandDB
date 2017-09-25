CREATE OR REPLACE package amd_maint_task_distribs_pkg
as

	   -------------------------------------------------------------------
	   --  Date	  		  By			History
	   --  ----			  --			-------
	   --  10/25/01		  ks			initial implementation
	   -------------------------------------------------------------------


   	    -- mob, fsl, ror only, no warehouse
	    -- previous amd RepairRate always defaulted. may be in error. need rereview.
		-- 		  actual and projected may be considered incorrect in this manner too
		--		  since defaults always used. kept consistent with previous load for now.
		-- repair rate requires 5,6 position smr for default from existing system.
		-- if no 6 position smr, no record currently created.

  	   	  -- actual and projected designations for mtd
  	   ACTUAL constant varchar2(1) := 'A';
  	   PROJECTED constant varchar2(1) := 'P';
	   COMMIT_AFTER constant number := 10000;
  	   	  -- loadMtd needs to run after amd_part_locs loading
  	   procedure loadAmdMtd;


end amd_maint_task_distribs_pkg;
/
CREATE OR REPLACE package body amd_maint_task_distribs_pkg
is
  ERRSOURCE constant varchar2(30) := 'Amd Mtd Pkg';
  smrCodeNotAcceptable exception;
    -- ks: below comments lifted from previous package --

    /* ------------------------------------------------------------------- */
	/*  this procedure assigns the produce the values of condemnation,     */
	/*  repair this station and not repair this station rates.             */
	/*           */
	/*  the input will come from percent_base_condem, percent_base_repair  */
	/*  from ramp table in gold system.                                    */
	/*  the default rules are established as below :                       */
	/*  (per mary bacskai)      */
	/*  ------------------------------------------------------------------ */

	/*  ------------------------------------------------------------------

	this is the change required for maint task distribs. it's kinda a big change and it probably isn't quick,
	and i know we are on the hook to start reloading amd on a daily basis.
		sorry - take a look then lets talk about it.  i may be out of the office this afternoon, but will be in
	all day tomorrow if theres any questions.

	***************************************************************************************************************************

	amd_maint_task_distribs table currently only contains entries when there is a ramp record in gold
	for that nsn and segregation code. the model needs a maint task distribs entry for each part and location
	that it could possibly model for.  therefore, a row for every combination of part in amd_spare_parts
	and location in amd_spare_networks (with a location type of mob or fsl) must be created in the
	load process.  currently, these are the locations that require entries
	(use amd_spare_networks to determine the current mobs or fsls):

	loc_id        location_name        loc
	-------------      -------------------------      ---
	fb4418        charleston  afb           mob
	fb4479        mcchord ab                mob
	fb4419        altus afb      mob
	fb6242        jackson ang               mob
	fb4415        anderson afb              fsl
	fb4497        dover ab      fsl
	fb4480        elmendorf ab               fsl
	fb4405        hickam ab                  fsl
	fb4490        howard ab                  fsl
	fb4402        incirlik ab      fsl
	fb4411        kadena ab                  fsl
	fb4400        lajes field      fsl
	fb4484        mcguire ab                 fsl
	fb4488        pope      fsl
	fb4406        raf mildenhall            fsl
	fb4401        ramstein ab               fsl
	fb4403        rhein main ab             fsl
	fb4409        rota ns      fsl
	fb4427        travis      fsl
	fb4408        yokota ab      fsl
	this will increase the size of this table to approximately 20 records per prime in amd_spare_parts.
	to support this, please make the following changes to the load process:

	1.  if the cond, rts, and nrts fields are all present for an nsn/location in ramp, create a amd_maint_task_distribs
	per current process with an act_proj_ind of 'a' (for actual).  all other entries in this table will have an act_proj_ind
	of 'P' (projected), which states that a default was applied to one or more of these fields.
	2.  there should be one record for each of the  locations with a loc_type of 'MOB' or 'FSL' in amd_spare_networks
		for each part   number in amd_spare_parts.  an entire record must be create with an actual/projected indicator of 'P'
	with the appropriate defaults.
	3.  the former defaults no longer apply.  the matrix that was previously used to compensate for missing data has been
		replaced with an approach that relies heavily on the type of part it is (i.e. repairable or consumable).  repairable parts
		are identified by the 6th digit of the smr code (in amd_spare_parts) being equal to 'T'.  consumable parts have
	a 6th position of 'N', and quasi repairable parts have a 6th position of 'p.  the new defaults are as follows.
	parts with a 6th position of the smr code equal to 'T' default to 100% nrts if all three fields are missing.
		if some data is available, any remaining portion is put into nrts and the excess taken from rts.
	parts with a 6th position of the smr code equal to 'N' coded default is 100% cond if all three fields are missing.
		if some data is available, any unaccounted for percentage is added to cond, excess would be taken from cond
		and an error message to that effect should be produced. (consumable parts should not have any rts or nrts,
		so this smr code is probably in error and should be noted as such)
	when the 6th position of the smr code is 'P', the 5th position and the amd_spare_networks location type
		needs to be examined as well.  if characters 5-6 of the smr code are fp and the location is an fsl, the default is
		100% nrts.  if characters 5-6 of the smr code are fp and the location is an mob,
		the default is 95% rts, 5% cond, 0 nrts.  if characters 5-6 of the smr code are op,
		the default is 95% rts, 5% cond, 0 nrts.  if position 6 is 'P' and  5-6 is something other than fp or op,
		use 100% nrts at the fsl, 95% rts, 5% cond, 0 nrts at the  mobs.
	4.  the sum of cond, rts, and nrts must equal one.  if any one of these fields are blank then defaults should be
		applied to the unaccounted for portion.  if there is some available data, and it does not add up to 1,
		the unaccounted for portion should be added or subtracted per the above instructions based on the 6th position
		of the smr code.  if the sum is over 1.5, the following formula should be applied to find the rts:
		the cond would be .005, and the newly calculated rts will give you the ability to find nrts by subtracting
		the two existing   numbers from 1.

		rts = (rts/(nrts + rts)) x .995) and cond would be .005.

	other smr codes that aren't 'T', 'P' or 'N' (afo, xc, and paodd1 smrs are present in amd)
	will require further analysis
	and direction.

	1/31/2000

	per our discussion 5 minutes ago:
		1.  if the sum of the percent base repair and percent base condemn is greater than one,
		do not put a maint task distribs record in the table and send a message to
		the error report saying
		'warning - mtd percentage greater than 1'  with the part and location.
		(this will not keep the part from spare parts,  however)
		2.  nrts field is only calculated from percent base repair and percent base condemn
		fields in gold.
		if both of these fields are present and the total is not greater than 1,
		give that record an actual  projected indicator of 'a'.
		in all other cases the actual projected indicator will be 'P'.

	2/3/2000

	'P' coded parts at the mob when it's an 'a' (actual record - meaning there is a ramp record
	with a value (even zero) in percent base condemn and percent base repair) have an additional
	piece of logic -  to specify what to do with 'extra' percentages for 'P' coded.
	the 'extra' percentages should go into cond up to 5%, and the rest to rts.
	using some of our real life examples:
	ramp % cond = 0,  % repair = 99    in this case, the remaining percentage would go to cond,
	making the mtd nrts 0, rts .99, cond .01
	ramp % cond = 0,  % repair = 0      in this case, the first .05 goes to cond,
	the remaining .95 to rts, nrts still 0

		-------------------------------------------------------------------------------------- */
    -- ks: to avoid rewriting logic, changed all goto end_rep_rate to return.  procedure barely
	-- touched.
	procedure GetRepairRate(
							locType  in   varchar2,
							smr6     in   varchar2,
							smr5     in   varchar2,
							rampRts  in   number,
							rampCond in   number,
							rtsPc   out   number,
							nrtsPc  out   number,
							condPc  out   number) as

		cnt        number;
		temp       varchar2(20);
		lRampRts   number;
		lRampcond  number;
        ws_ramprts   number;
		ws_rampCond  number;

	begin
		--
		--  note:
		--        1) ramp has only rts and condemnation rates
		--        2) smr6 must be 'T', 'N', or 'P'
		--        3) locType must be 'ROR', 'MOB' or 'FSL'


		if smr6 = 'T'  and (locType in ('MOB', 'FSL')) then
            ws_ramprts  := 0;
            ws_rampCond := 0;
			nrtsPc      := 1.0000 ;
			rtsPc       := ws_ramprts;
			condPc      := ws_rampCond;

			return ;      -- goto end_rep_rate;
		end if;

        if smr6 = 'T'  and locType = 'ROR'  then
            ws_ramprts   := 0.995;
            ws_rampCond  := 0.005;
			nrtsPc       := 1.0000 - ws_ramprts - ws_rampCond;
			rtsPc        := ws_ramprts;
			condPc       := ws_rampCond;

			return ;      -- goto end_rep_rate;
		end if;


        if smr6 = 'P'  and locType = 'MOB'  then
            ws_ramprts  := 0.20;
            ws_rampCond := 0.80;
			nrtsPc      := 1.0000 - ws_ramprts - ws_rampCond;
			rtsPc       := ws_ramprts;
			condPc      := ws_rampCond;

			return ;      -- goto end_rep_rate;
		end if;

        if smr6 = 'P'  and locType = 'FSL'  then
            ws_ramprts  := 0;
            ws_rampCond := 1.0000;
			condPc      := 1.0000 - ws_ramprts;
			rtsPc       := ws_ramprts;
			nrtsPc      := 0;

			return ;      -- goto end_rep_rate;
		end if;


		if smr6 = 'P'  and locType = 'ROR'  then
            ws_ramprts   := 0;
            ws_rampCond  := 1.000;
			nrtsPc       := 1.0000 - ws_ramprts - ws_rampCond;
			rtsPc        := ws_ramprts;
			condPc       := ws_rampCond;

			return ;      -- goto end_rep_rate;
		end if;

		if smr6 = 'N' then
		    ws_ramprts  := 0;
            ws_rampCond := 1.0000;
			condPc      := 1.0000 - ws_ramprts;
			rtsPc       := ws_ramprts;
			nrtsPc      := 0;

			return ;      -- goto end_rep_rate;
		end if;

		if smr6 = 'P' and smr5 = 'O' then

			-- use same condition for both ramprts and rampCond for null or 0.00

			lRampRts  := nvl(ws_ramprts,0);   -- use local variable
			lRampcond := nvl(ws_rampCond,0);   -- use local variable

			if    lRampRts = 0 and lRampcond = 0 then
				nrtsPc := 0.00;
				rtsPc  := 0.95;
				condPc := 0.05;
				return ;      -- goto end_rep_rate;

			elsif lRampRts > 0 and lRampcond > 0 then
				rtsPc  := lRampRts;
				condPc := lRampcond;
				nrtsPc := 1 - rtsPc - condPc;
				return ;      -- goto end_rep_rate;

			elsif lRampRts > 0 and lRampcond = 0 then
				rtsPc  := lRampRts;
				if (1 - rtsPc) > 0.05 then
					condPc := 0.05;
					nrtsPc := 1 - rtsPc - condPc;
					return ;      -- goto end_rep_rate;
				else
					condPc := 1 - rtsPc;
					nrtsPc := 1 - rtsPc - condPc;  -- nrtsPc should be 0
					return ;      -- goto end_rep_rate;
				end if;

			elsif lRampRts = 0 and lRampcond > 0 then

				condPc := rampCond;
				if ( 1 - condPc ) > 0.95 then
					rtsPc  := 0.95;
					nrtsPc := 1 - condPc - rtsPc;
					return ;      -- goto end_rep_rate;
				else
					rtsPc  := 1 - condPc;
					nrtsPc := 1 - condPc - rtsPc; -- nrtsPc should be 0
					return ;      -- goto end_rep_rate;
				end if;

			end if;

		elsif smr6 = 'P' and smr5 != 'O' then

			-- for smr6 = 'P' and smr5 != 'O'

			if locType = 'MOB' then

				-- use same condition for both ramprts and rampCond for null or 0.00

				lRampRts  := nvl(ws_ramprts,0);   -- use local variable
				lRampcond := nvl(ws_rampCond,0);  -- use local variable

				if    lRampRts = 0 and lRampcond = 0 then

					nrtsPc := 0.00;
					rtsPc  := 0.95;
					condPc := 0.05;
					return ;      -- goto end_rep_rate;

				elsif lRampRts > 0 and lRampcond > 0 then

					rtsPc  := lRampRts;
					condPc := lRampcond;
					nrtsPc := 1 - rtsPc - condPc;
					return ;      -- goto end_rep_rate;

				elsif lRampRts > 0 and lRampcond = 0 then

					rtsPc  := lRampRts;
					if (1 - rtsPc) > 0.05 then
						condPc := 0.05;
						nrtsPc := 1 - rtsPc - condPc;
						return ;      -- goto end_rep_rate;
					else
						condPc := 1 - rtsPc;
						nrtsPc := 1 - rtsPc - condPc;  -- nrtsPc should be 0
						return ;      -- goto end_rep_rate;
					end if;

				elsif lRampRts = 0 and lRampcond > 0 then

					condPc := ws_rampCond;
					if ( 1 - condPc ) > 0.95 then
						rtsPc  := 0.95;
						nrtsPc := 1 - condPc - rtsPc;
						return ;      -- goto end_rep_rate;
					else
						rtsPc  := 1 - condPc;
						nrtsPc := 1 - condPc - rtsPc; -- nrtsPc should be 0
						return ;      -- goto end_rep_rate;
					end if;
				end if;
			else
				--locType = 'FSL' then

				condPc := nvl(ws_rampCond,0);
				rtsPc  := nvl(ws_ramprts,0);
				nrtsPc := 1.0000 - condPc - rtsPc;
				return ;      -- goto end_rep_rate;
			end if;
		end if;
  end GetRepairRate;


  procedure InsertIntoAmdMtd(pRec amd_maint_task_distribs%rowtype) is
  begin
  	   insert into amd_maint_task_distribs
	   		  (
			  nsi_sid,
			  loc_sid,
			  effective_date,
			  act_proj_ind,
			  cond,
			  cond_defaulted,
			  nrts,
			  nrts_defaulted,
			  rts,
			  rts_defaulted
			  )
	   values (
	   		  pRec.nsi_sid,
			  pRec.loc_sid,
			  pRec.effective_date,
			  pRec.act_proj_ind,
			  pRec.cond,
			  pRec.cond_defaulted,
			  pRec.nrts,
			  pRec.nrts_defaulted,
			  pRec.rts,
			  pRec.rts_defaulted
		);
  exception
  		   -- should not occur
  	   when dup_val_on_index then
	   		amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'AMD_MAINT_TASK_DISTRIBS'),pRec.nsi_sid, pRec.loc_sid, null, null, null, 'dup val on index');

  end InsertIntoAmdMtd;

  procedure loadAmdMtd is
  			-- ks: list will have mob, fsl and all parts to ror (exclude warehouse)
			-- this corresponds with current scope of amd_mtd and amd_repair_levels.
			-- ignore those that are logically deleted from ansi and asn so table is "current".
	 countRecs number := 0;
	 cursor mtdPartLocList_cur is
  		 select ansi.nsi_sid, ansi.nsn, ansi.prime_part_no as part_no, asn.loc_id, asn.loc_type, asn.loc_sid
		 from
		 	  amd_part_locs apl,
		 	  amd_national_stock_items ansi,
			  amd_spare_networks asn
		 where
		 	  apl.nsi_sid = ansi.nsi_sid and
			  apl.loc_sid = asn.loc_sid and
			  asn.loc_type in ('MOB', 'FSL', 'ROR') and
			  ansi.action_code != amd_defaults.DELETE_ACTION and
			  asn.action_code != amd_defaults.DELETE_ACTION;


	 amdMtdRec amd_maint_task_distribs%rowtype;
	 smrCode amd_national_stock_items.smr_code%type;
	 rampData amd_part_locs_load_pkg.rampData_rec;
	 rtsPc number;
	 nrtsPc number;
	 condPc number;
  begin
	 	 for mtdPartLoc in mtdPartLocList_cur
	 	 loop
		 	 begin
			 	  -- initialize those reused in loop
			 	rtsPc := null;
				nrtsPc := null;
				condPc := null;
			 	amdMtdRec := null;
			 	rampData := null;
				smrCode := null;

			 	amdMtdRec.nsi_sid := mtdPartLoc.nsi_sid;
				amdMtdRec.loc_sid := mtdPartLoc.loc_sid;
				 	-- ks: current rampData only has fsl or mob, not ror => don't bother looking if ROR or other
				if (mtdPartLoc.loc_type in ('FSL', 'MOB')) then
				 	rampData := amd_part_locs_load_pkg.GetRampData(mtdPartLoc.nsn, mtdPartLoc.loc_id);
				end if;
				if (rampData.percent_base_repair is not null) then
					amdMtdRec.rts := rampData.percent_base_repair / 100.00;
	  			end if;
				if (rampData.percent_base_condem is not null) then
					amdMtdRec.cond := rampData.percent_base_condem / 100.00;
				end if;

					--
					-- check ramp data, if invdate is null, default to
					-- sysdate and generate the warning message.
					--

				if (rampData.date_processed is null) then
					amdMtdRec.effective_date := trunc(SYSDATE);
					-- ins_err_msg(loadno, partno, locid, '', '', 'gold/spareinv',
					--		'no inv_date/date_processed found in ramp, use sysdate' );
				else
					amdMtdRec.effective_date := rampData.date_processed;
			  	end if;
				 	--
					-- if ramp has both rts and cond, actprojind = 'a',
					-- else actprojind = 'P'
					--

				if  ( (amdMtdRec.rts  is not null) and (amdMtdRec.cond is not null) ) then
					amdMtdRec.act_proj_ind := ACTUAL;
				else
					amdMtdRec.act_proj_ind := PROJECTED;
				end if;

					--
					-- if the sum of rts and cond from ramp is greater than 1,
					-- use default values
					-- and generate the error message
					--

				if (nvl(amdMtdRec.cond,0) + nvl(amdMtdRec.rts,0)) > 1 then
					amdMtdRec.cond := 0;
					amdMtdRec.rts  := 0;
					-- ins_err_msg(loadno, partno, cage, cat1nsn, rampsc,
					--		'gold/spareinv',
					--		'warning: '||cat1nsn||' has rts + cond > 1, use default values.' );
				end if;
				smrCode := amd_preferred_pkg.GetSmrCode(mtdPartLoc.nsn);
				if (Length(smrCode) < 6) then
				   raise smrCodeNotAcceptable;
				end if;
					-- ks: rtsPc, nrtsPc, condPc are OUT parameters
				GetRepairRate(mtdPartLoc.loc_type, substr(smrCode,6,1), substr(smrCode,5,1), amdMtdRec.rts, amdMtdRec.cond, rtsPc, nrtsPc, condPc);
				amdMtdRec.rts := null;
				amdMtdRec.rts_defaulted := rtsPc;
				amdMtdRec.nrts := null;
				amdMtdRec.nrts_defaulted := nrtsPc;
				amdMtdRec.cond := null;
				amdMtdRec.cond_defaulted := condPc;

				InsertIntoAmdMtd(amdMtdRec);
				countRecs := countRecs + 1;
				if (countRecs > COMMIT_AFTER) then
				   commit;
				   countRecs := 0;
				end if;
			exception
					 when smrCodeNotAcceptable then
					 	  -- ks: current direction: default nrts,rts,cond rely on 5th and 6th
						  -- position of smr, exclude creating mtd records if smr < 6 since no
						  -- current default logic for them.
					 	  null;
					 when no_data_found then
					 	  -- can be thrown when smr_code is null
						  null;
					 when others then
					 	  amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'loadamdmtd'),mtdpartloc.nsi_sid, mtdpartloc.loc_sid, null, null, null, substr(SQLCODE || ' ' || SQLERRM,1, 2000));

			end;
	 	 end loop;
		 commit;
  end loadAmdMtd;

begin
	 null;
end amd_maint_task_distribs_pkg;
/

