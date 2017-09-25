set define off

DROP PACKAGE AMD_OWNER.AMD_PART_LOCS_LOAD_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.AMD_PART_LOCS_LOAD_PKG
AS
    /*

       $Author:   zf297a  $
     $Revision:   1.0  $
         $Date:   12 Sep 2007 16:16:20  $
     $Workfile:   amd_part_locs_load_pkg.sql  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Scripts\AMD 2.0 Implementation\amd_part_locs_load_pkg.sql.-arc  $
/*   
/*      Rev 1.0   12 Sep 2007 16:16:20   zf297a
/*   Initial revision.
   
      Rev 1.7   Jun 09 2006 12:12:08   zf297a
   added interface version

      Rev 1.6   Jun 13 2005 09:19:04   c970183
   Added PVCS keywords

*/

  	   	-------------------------------------------------------------------
		--
		-- SCCSID: amd_part_locs_load_pkg.sql  1.1  Modified: 08/14/02 17:11:22
		--
	   	--  Date	  	  By			History
	   	--  ----		  --			-------
	   	--  10/10/01	  	  ks		initial implementation
	   	--  12/11/01	  	  dse		Added named param for amd_preferred_pkg.GetUnitCost(.....
	   	--  8/14/02		  ks            change fsl query to be more efficient.
		--  6/01/05		  ks		changes to support AMD 1.7.1 - change to RSP_ON_HAND, RSP_OBJECTIVE
		--					change rampData_rec to be whole record,
		--					mod to queries for bssm, eg. lock_sid use '0' instead of 0
		-------------------------------------------------------------------


		-- added ROR to previous part_locations, since table now combines old amd_repair_levels
	   	-- too, which had MOB, FSL, ROR. also adding each part to warehouse as part/loc list since
	   	-- child table amd_part_loc_time_periods may provide ROP/ROQ info for warehouse, especially
	   	-- for consumables.
  OFFBASE_LOCID constant varchar2(30) := 'OFFBASE';
  COMMIT_AFTER constant number := 10000;
  -- data fields match cursor and database field names
  -- wrm relates to rsp
  /*
  type rampData_rec is record (
  	   date_processed date,
	   avg_repair_cycle_time number,
	   percent_base_condem number,
	   percent_base_repair number,
	   wrm_level number,
	   wrm_balance number );
  function GetRampData(pNsn ramp.nsn%type, pLocId amd_spare_networks.loc_id%type) return rampData_rec;
  function GetRampData(pNsn ramp.nsn%type, pLocSid amd_spare_networks.loc_sid%type) return rampData_rec;
  */

  function GetRampData(pNsn ramp.nsn%type, pLocId amd_spare_networks.loc_id%type) return ramp%ROWTYPE ;
  function GetRampData(pNsn ramp.nsn%type, pLocSid amd_spare_networks.loc_sid%type) return ramp%ROWTYPE ;
  procedure LoadAmdPartLocations;
  
  -- added 6/9/2006 by dse
  procedure version ;
  
END AMD_PART_LOCS_LOAD_PKG;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_PART_LOCS_LOAD_PKG;

CREATE PUBLIC SYNONYM AMD_PART_LOCS_LOAD_PKG FOR AMD_OWNER.AMD_PART_LOCS_LOAD_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_PART_LOCS_LOAD_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_PART_LOCS_LOAD_PKG TO AMD_WRITER_ROLE;


DROP PACKAGE BODY AMD_OWNER.AMD_PART_LOCS_LOAD_PKG;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.AMD_PART_LOCS_LOAD_PKG
IS
    /*   				
		
       $Author:   zf297a  $
     $Revision:   1.0  $
         $Date:   12 Sep 2007 16:16:20  $
     $Workfile:   amd_part_locs_load_pkg.sql  $
	      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_part_locs_load_pkg.pkb-arc  $
   
      Rev 1.10   12 Sep 2007 15:39:36   zf297a
   Removed commits from for loops.
   
      Rev 1.9   15 May 2007 09:33:30   zf297a
   Eliminated writing "unique constraint" errors to amd_load_details when the procedure does not stop.  Added using mod to check for commit points.  Used enhanced writeMsg and errorMsg to write messages and errors to amd_load_details.  Added recording of "start" and "end" times to amd_load_details.
   
      Rev 1.8   Jun 09 2006 12:12:20   zf297a
   implemented version
   
      Rev 1.7   Dec 06 2005 10:33:56   zf297a
   Fixed display of sysdate in errorMsg - changed to MM/DD/YYYY HH:MM:SS
   
      Rev 1.4.1.1   Jun 13 2005 09:19:06   c970183
   Added PVCS keywords
   
*/
/*
	--  Date	  	  By			History
   	--  ----		  --			-------
   	--  10/10/01	  	  ks		initial implementation
   	--  12/11/01	  	  dse		Added named param for amd_preferred_pkg.GetUnitCost(.....
   	--  8/14/02		  ks            change fsl query to be more efficient.
	--  6/01/05		  ks		changes to support AMD 1.7.1 - change to RSP_ON_HAND, RSP_OBJECTIVE
	--					mod to queries for bssm, eg. lock_sid use '0' instead of 0
*/
  	ERRSOURCE constant varchar2(20) := 'amdpartlocsloadpkg';
    dups number := 0 ;
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
				pSourceName => 'amd_part_locs_load_pkg',	
				pTableName  => pTableName,
				pError_location => pError_location,
				pKey1 => pKey1,
				pKey2 => pKey2,
				pKey3 => pKey3,
				pKey4 => pKey4,
				pData    => pData,
				pComments => pComments);
    exception when others then
        -- trying to rollback or commit from trigger
        if sqlcode = 4092 then
            raise_application_error(-20010,
                substr('amd_part_locs_load_pkg ' 
                    || sqlcode || ' '
                    || pError_Location || ' ' 
                    || pTableName || ' ' 
                    || pKey1 || ' ' 
                    || pKey2 || ' ' 
                    || pKey3 || ' ' 
                    || pKey4 || ' '
                    || pData, 1,2000)) ;
        else
            raise ;
        end if ;
	end writeMsg ;
	
	PROCEDURE ErrorMsg(
	    pSqlfunction IN AMD_LOAD_STATUS.SOURCE%TYPE,
	    pTableName IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
	    pError_location AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
	    pKey1 IN AMD_LOAD_DETAILS.KEY_1%TYPE := '',
	    pKey2 IN AMD_LOAD_DETAILS.KEY_2%TYPE := '',
	    pKey3 IN AMD_LOAD_DETAILS.KEY_3%TYPE := '',
	    pKey4 IN AMD_LOAD_DETAILS.KEY_4%TYPE := '',
        pComments IN VARCHAR2 := '') IS
     
        key5 AMD_LOAD_DETAILS.KEY_5%TYPE := pComments ;
        error_location number ;
     
    BEGIN
      ROLLBACK;
      IF key5 = '' THEN
         key5 := pSqlFunction || '/' || pTableName ;
      ELSE
       key5 := key5 || ' ' || pSqlFunction || '/' || pTableName ;
      END IF ;
      if amd_utils.isNumber(pError_location) then
           error_location := pError_location ;
      else
           error_location := -9999 ;
      end if ;
      -- use substr's to make sure that the input parameters for InsertErrorMsg and GetLoadNo
      -- do not exceed the length of the column's that the data gets inserted into
      -- This is for debugging and logging, so efforts to make it not be the source of more
      -- errors is VERY important
      Amd_Utils.InsertErrorMsg (
        pLoad_no => Amd_Utils.GetLoadNo(
          pSourceName => SUBSTR(pSqlfunction,1,20),
          pTableName  => SUBSTR(pTableName,1,20)),
        pData_line_no => error_location,
        pData_line    => 'amd_part_locs_load_pkg',
        pKey_1 => SUBSTR(pKey1,1,50),
        pKey_2 => SUBSTR(pKey2,1,50),
        pKey_3 => SUBSTR(pKey3,1,50),
        pKey_4 => SUBSTR(pKey4,1,50),
        pKey_5 => TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS') ||
             ' ' || substr(key5,1,50),
        pComments => SUBSTR('sqlcode('||SQLCODE||') sqlerrm('||SQLERRM||')',1,2000));
        COMMIT;
      
    EXCEPTION WHEN OTHERS THEN
	  if pSqlFunction is not null then dbms_output.put_line('pSqlFunction=' || pSqlfunction) ; end if ;
	  if pTableName is not null then dbms_output.put_line('pTableName=' || pTableName) ; end if ;
	  if pError_location is not null then dbms_output.put_line('pError_location=' || pError_location) ; end if ;
	  if pKey1 is not null then dbms_output.put_line('key1=' || pKey1) ; end if ;
	  if pkey2 is not null then dbms_output.put_line('key2=' || pKey2) ; end if ;
	  if pKey3 is not null then dbms_output.put_line('key3=' || pKey3) ; end if ;
	  if pKey4 is not null then dbms_output.put_line('key4=' || pKey4) ; end if ;
	  if pComments is not null then dbms_output.put_line('pComments=' || pComments) ; end if ;
       raise_application_error(-20030,
            substr('amd_part_locs_load_pkg ' 
                || sqlcode || ' '
                || pError_location || ' '
                || pSqlFunction || ' ' 
                || pTableName || ' ' 
                || pKey1 || ' ' 
                || pKey2 || ' ' 
                || pKey3 || ' ' 
                || pKey4 || ' '
                || pComments,1, 2000)) ;
	END ErrorMsg;
    
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
	
		/* kcs change to ramp%ROWTYPE from rampData_rec */
	function GetRampData(pNsn ramp.nsn%type, pLocSid amd_spare_networks.loc_sid%type) return ramp%ROWTYPE is
		/* rampData rampData_rec := null; */
		rampData ramp%ROWTYPE := null;
		locId amd_spare_networks.loc_id%type;
	begin
		locId := amd_utils.GetLocId(pLocSid);
		if (locId is null) then
		    return rampData;
		else
			return GetRampData(pNsn, locId);
		end if;
	end GetRampData;

		/* kcs change to ramp%ROWTYPE from rampData_rec */
   	function GetRampData(pNsn ramp.nsn%type, pLocId amd_spare_networks.loc_id%type) return ramp%ROWTYPE is
	    cursor rampData_cur (pNsn ramp.nsn%type, pLocId amd_spare_networks.loc_id%type) is
			select * 
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
			/* kcs rampData rampData_rec; */
			rampData ramp%ROWTYPE ;
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
						and ansi.action_code in ('A', 'C')
						and asn.action_code in ('A', 'C')
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
						lock_sid         = '0'
						and bbp.nsn = an.nsn
						and bbp.sran     = asn.loc_id
						and asn.loc_type = 'MOB'
						and bbp.replacement_indicator = 'N'
						and asn.action_code in ('A', 'C')
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
						lock_sid         = '2'
						and bbp.nsn = an.nsn
						and bbp.sran     = asn.loc_id
						and asn.loc_type = 'MOB'
						and asn.action_code in ('A', 'C')
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
						lock_sid         = '2'
						and bbp.nsn = an.nsn
						and bbp.sran     = asn.loc_id
						and asn.loc_type = 'MOB'
						and bbp.replacement_indicator = 'N'
						and asn.action_code in ('A', 'C'))
				) order by nsi_sid;

				--
				-- FSL SELECTION LOGIC
				--b1
				--
				-- Select valid combo's using capability logic and valid in
				-- locks 0 and 2
				--
		cursor partLocsFslList_cur is
			  select * from (
				(
				select
				-- bp.nsn,
					an.nsi_sid,
					asn.loc_sid
				from
					bssm_parts bp,
					bssm_bases bb,
					amd_spare_networks asn,
					amd_national_stock_items ansi,
					amd_nsns an
				where
					bp.capability_requirement > 0
					and bp.lock_sid         = '0'
					and bb.lock_sid         = '0'
					and sign((bp.capability_requirement - bb.capabilty_level)) != -1
					and bb.sran             = asn.loc_id
					and asn.loc_type        = 'FSL'
					-- and bp.nsn              = ansi.nsn
					and bp.nsn				= an.nsn
					and an.nsi_sid			= ansi.nsi_sid
					and ansi.action_code in ('A', 'C')
					and asn.action_code in ('A', 'C')

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
					lock_sid         in ('0','2')
					and bbp.sran     = asn.loc_id
					and asn.loc_type = 'FSL'
					and asn.action_code in ('A', 'C')
					and ansi.action_code in ('A', 'C')
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
					lock_sid         = '2'
					and bbp.sran     = asn.loc_id
					and asn.loc_type = 'FSL'
					and bbp.replacement_indicator = 'N'
					and bbp.nsn = an.nsn
					and asn.action_code in ('A', 'C')
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
					lock_sid         = '0'
					and bbp.sran     = asn.loc_id
					and asn.loc_type = 'FSL'
					and bbp.nsn = an.nsn
					and asn.action_code in ('A', 'C')
					and bbp.replacement_indicator = 'N'
					and not exists
						(select 'x'
						from bssm_base_parts bbp2
						where
							lock_sid      = '2'
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
					   ansi.action_code in ('A', 'C') and
					   asn.action_code in ('A', 'C');
		/* changed to insert statement --			   
		cursor partLocsWareHouse_cur is
			    select
					   ansi.nsi_sid,
					   asn.loc_sid
				from
					   amd_national_stock_items ansi,
					   amd_spare_networks asn
				where
					   asn.loc_id = amd_from_bssm_pkg.AMD_WAREHOUSE_LOCID and
					   ansi.action_code in ('A', 'C') and
					   asn.action_code in ('A', 'C');
		*/			   
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
        writeMsg(pTableName => 'amd_part_locs', pError_location => 10,
            pKey1 => 'LoadAmdPartLocations',
            pKey3 => 'started at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') ) ;
            

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
				/* kcs changes to support bssm 603 and amd1.7.1 
				amdPartLocsRec.rsp_on_hand := rampData.wrm_balance;
				amdPartLocsRec.rsp_objective := rampData.wrm_level;
				*/
				amdPartLocsRec.rsp_on_hand := nvl(rampData.wrm_balance, 0) + nvl(rampData.spram_balance, 0) + nvl(rampData.hpmsk_balance, 0) ;
				amdPartLocsRec.rsp_objective := nvl(rampData.wrm_level, 0) + nvl(rampData.spram_level, 0) + nvl(rampData.hpmsk_level_qty, 0) ;
					-- filled in afterwards in separate process, bssm only source for now
					-- look in amd_from_bssm_pkg,
					-- null assignment here just to note
				amdPartLocsRec.order_cost := null;
				amdPartLocsRec.holding_cost := null;
				amdPartLocsRec.backorder_fixed_cost := null;
				amdPartLocsRec.backorder_variable_cost := null;
					-- insert record
				InsertIntoAmdPartLocs(amdPartLocsRec);
				countRecs := countRecs + 1;
			exception
                when standard.DUP_VAL_ON_INDEX then
                    dups := dups + 1 ; 
				when others then
                    ErrorMsg(pSqlfunction => 'insert',
                        pTableName => 'amd_part_locs',
                        pError_location => 20,
                        pKey1 => amdPartLocsRec.nsi_sid,
                        pKey2 => amdPartLocsRec.loc_sid) ;
	
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
				/* kcs changes to support bssm 603 and amd1.7.1 
				amdPartLocsRec.rsp_on_hand := rampData.wrm_balance;
				amdPartLocsRec.rsp_objective := rampData.wrm_level;
				*/
				amdPartLocsRec.rsp_on_hand := nvl(rampData.wrm_balance, 0) + nvl(rampData.spram_balance, 0) + nvl(rampData.hpmsk_balance, 0) ;
				amdPartLocsRec.rsp_objective := nvl(rampData.wrm_level, 0) + nvl(rampData.spram_level, 0) + nvl(rampData.hpmsk_level_qty, 0) ;	-- filled in afterwards in separate process, bssm only source for now
					-- look in amd_from_bssm_pkg,
					-- null assignment here just to note
				amdPartLocsRec.order_cost := null;
				amdPartLocsRec.holding_cost := null;
				amdPartLocsRec.backorder_fixed_cost := null;
				amdPartLocsRec.backorder_variable_cost := null;
				InsertIntoAmdPartLocs(amdPartLocsRec);
				countRecs := countRecs + 1;
			exception
                when standard.DUP_VAL_ON_INDEX then
                    dups := dups + 1 ; 
				when others then
                    ErrorMsg(pSqlfunction => 'insert',
                        pTableName => 'amd_part_locs',
                        pError_location => 30,
                        pKey1 => amdPartLocsRec.nsi_sid,
                        pKey2 => amdPartLocsRec.loc_sid) ;
			end;
		end loop;
		commit;

			--
			-- load offbase into part locations
			--
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
				countRecs := countRecs + 1;
			exception
                when standard.DUP_VAL_ON_INDEX then
                    dups := dups + 1 ; 
				when others then
                    ErrorMsg(pSqlfunction => 'insert',
                        pTableName => 'amd_part_locs',
                        pError_location => 40,
                        pKey1 => amdPartLocsRec.nsi_sid,
                        pKey2 => amdPartLocsRec.loc_sid) ;
			end;
		end loop;
        
		commit;
			--
			-- load warehouse parts
			--
		begin
			 insert into amd_part_locs 
			 (nsi_sid, loc_sid, tactical, action_code, last_update_dt)
			 	select
					   ansi.nsi_sid,
					   asn.loc_sid,
					   'Y',
					   amd_defaults.INSERT_ACTION,
					   SYSDATE					   
				from
					   amd_national_stock_items ansi,
					   amd_spare_networks asn
				where
					   asn.loc_id = amd_from_bssm_pkg.AMD_WAREHOUSE_LOCID and
					   ansi.action_code in ('A', 'C') and
					   asn.action_code in ('A', 'C') ;
		exception
                when standard.DUP_VAL_ON_INDEX then
                    dups := dups + 1 ; 
				when others then
                    ErrorMsg(pSqlfunction => 'insert',
                        pTableName => 'amd_part_locs',
                        pError_location => 50) ;
		end ;
        writeMsg(pTableName => 'amd_part_locs', pError_location => 60,
            pKey1 => 'LoadAmdPartLocations',
            pKey2 => 'dups=' || dups,
            pKey3 => 'ended at ' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM'),
            pKey4 => 'countRecs=' || countRecs ) ;
            
		commit;

	end LoadAmdPartLocations;

	procedure version is
	begin
		 writeMsg(pTableName => 'amd_part_locs_load_pkg', 
		 		pError_location => 70, pKey1 => 'amd_part_locs_load_pkg', pKey2 => '$Revision:   1.0  $') ;
	end version ;
	
BEGIN
	 null;
END AMD_PART_LOCS_LOAD_PKG;
/

SHOW ERRORS;


DROP PUBLIC SYNONYM AMD_PART_LOCS_LOAD_PKG;

CREATE PUBLIC SYNONYM AMD_PART_LOCS_LOAD_PKG FOR AMD_OWNER.AMD_PART_LOCS_LOAD_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_PART_LOCS_LOAD_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_PART_LOCS_LOAD_PKG TO AMD_WRITER_ROLE;


