CREATE OR REPLACE package amd_spare_parts_pkg as
	--
	-- SCCSID:	%M%	%I%	Modified: %G%  %U%
	--
	/*
     $Author:   c970408  $		
   $Revision:   1.6  $
       $Date:   13 Jun 2003 09:52:24  $
   $Workfile:   amd_spare_parts_pkg.sql  $
        $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\Packages\amd_spare_parts_pkg.sql-arc  $	
/*   
/*      Rev 1.6   13 Jun 2003 09:52:24   c970408
/*   Modified updateAmdSparePartRow() to use it's own nsn and removed call to updateNsnFromPrimeRec(). Modifed nsnChanged() to look at an.nsn instead of asp.nsn. Added call to makeNsnSameForAllParts() to checkNsnAndPrimeInd().
/*   
/*      Rev 1.5   18 Mar 2003 11:07:44   c970408
/*   Modified the code to correctly move a part from one nsn to another if both nsns exist concurrently in CAT1.
/*   
/*      Rev 1.4   05 Mar 2003 13:23:42   c970408
/*   fixed the movement of temp nsns to cat1 and the unassociation that results.
/*   
/*      Rev 1.3   26 Nov 2002 17:04:22   c970408
/*   Added getFedcCost().
/*   
/*      Rev 1.2   04 Nov 2002 16:20:06   c970408
/*   Mod'ed updating of the ansi.action_code = 'D' query in UpdateRow method to be more efficient.
/*   
/*      Rev 1.1   14 Oct 2002 16:03:44   c970408
/*   Added query at end of UpdateRow to update ansi.action_code = 'D' if no active amd_nsi_parts recs are linked to and ansi.nsi_sid.
/*   
/*      Rev 1.0   07 Oct 2002 06:26:18   c372701
/*   Initial revision.
   
      Rev 1.23   30 Aug 2002 11:46:26   c970183
   Fixed updating of the prime_part_no.   When a prime_part_no and its equivalent parts got deleted and reinserted,  the logic caused the amd_national_stock_items.prime_part_no column to get set to a null value.  To accomodate this condition code has been added to the equivalent part section that checks for an existing amd_nsi_parts.part_no with its prime_ind set to 'Y'.  If found it makes sure that the same part_no appears in amd_national_stock_items.prime_part_no.
   
      Rev 1.22   07 Aug 2002 08:58:24   c970183
   Set unassignment_date to sysdate for deleted parts.
   
      Rev 1.21   11 Apr 2002 09:26:18   c970183
   Put SCCS keywords back into the file
   
      Rev 1.20   08 Apr 2002 12:14:48   c970183
   Added acquisition_advice_code
   
      Rev 1.19   05 Apr 2002 09:30:28   c970183
   Added return code: unable to chg nsn_type and constants for amd_nsns.nsn_type
   
      Rev 1.18   04 Apr 2002 13:25:28   c970183
   Added mic_code_lowest to the InsertRow and UpdateRow routines.
   
      Rev 1.17   28 Mar 2002 12:41:58   c970183
   added comment and log regarding sleep/insert exception handler
	
      10/02/01 Douglas Elder   Initial implementation
	  03/21/02 Douglas Elder	Added Sleep(5) to insure
	  							a unique key for amd_nsi_parts
	  03/28/02 Douglas Elder	Added insertagain_err code - since the sleep
	  		   		   			is now only executed for insert exceptions
	  04/04/02 Douglas Elder	Added Mic Code to insert and update
	  04/05/02 Douglas Elder    Added return code: unable to chg nsn_type
	  		   		   			and constants for amd_nsns.nsn_type 
     */
	-- return values from InsertRow, UpdateRow, and DeleteRow

	SUCCESS                    constant number := 0;
	FAILURE                    constant number := 4;
	
	-- amd_nsns.nsn_type values

	TEMPORARY_NSN 		 	         constant varchar2(1) := 'T';
	CURRENT_NSN	  		            constant varchar2(1) := 'C';
	 
	/* NOTE: Most of these return values should not occur, but
		if they do occur there is probably a coding error that
		needs to be corrected.  The return value should help
		to isolate the section of code that caused the problem.
		The return value and associated data are recorded in the
		amd_load_details table
		*/

	PART_NOT_PRIME                   constant number := 8;
	UNABLE_TO_PRIME_INFO             constant number := 12;
	UNABLE_TO_INSERT_SPARE_PART      constant number := 16;
	UNABLE_TO_INSERT_AMD_NSNS        constant number := 20;
	UNABLE_TO_INSERT_AMD_NSI_PARTS   constant number := 24;
	CANNOT_UPDT_NSN_NAT_STCK_ITEMS   constant number := 28;
	CANNOT_GET_NSI_SID               constant number := 32;
	CANNOT_UPDATE_SPARE_PARTS_NSN    constant number := 36;
	CANNOT_UPADATE_NAT_STCK_ITEMS    constant number := 40;
	CANNOT_UPDATE_AMD_NSNS           constant number := 44;
	CANNOT_GET_UNIT_COST_CLEANED     constant number := 48;
	CHK_NSN_AND_PRIME_ERR            constant number := 52;
	UNABLE_TO_DELT_PART_NOT_FOUND    constant number := 56;
	UNABLE_TO_DLET_NAT_STK_ITEM      constant number := 60;
	UNABLE_TO_RESET_NAT_STK_ITEM     constant number := 64;
	INSERT_PRIMEPART_ERR             constant number := 68;
	INS_PRIME_PART_ERR               constant number := 72;
	UPDATE_NATSTK_ERR                constant number := 76;
	INS_EQUIV_PART_ERR               constant number := 80;
	INS_AMD_NSI_PARTS_ERR            constant number := 84;
	UPD_AMD_SPARE_PARTS_NSN          constant number := 88;
	LOGICAL_INSERT_FAILED            constant number := 92;
	PART_ALREADY_EXISTS              constant number := 96;
	INSERTROW_FAILED                 constant number := 100;
	UNASSIGN_PRIME_PART_ERR          constant number := 104;
	UNASSIGN_OLD_PRIME_PART_ERR      constant number := 108;
	UPD_NSI_PARTS_ERR                constant number := 116;
	ASSIGN_NEW_PRIME_PART_ERR        constant number := 120;
	UPDATE_ERR	                     constant number := 124;
	UNABLE_TO_GET_PRIME_PART         constant number := 128;
	UPDT_PRIME_PART_ERR              constant number := 132;
	MAKE_NEW_PRIME_PART_ERR          constant number := 136;
	UNASSIGN_EQUIV_PART_ERR          constant number := 140;
	UPD_NSN_SPARE_PARTS_ERR          constant number := 144;
	ASSIGN_PRIME_TO_EQUIV_ERR        constant number := 148;
	UPD_PRIME_PART_ERR               constant number := 152;
	UNABLE_TO_GET_NSI_SID            constant number := 156;
	UNABLE_TO_PREP_DATA              constant number := 160;
	UNABLE_TO_GET_NUM_ACTIVE_PARTS   constant number := 164;
	UNABLE_TO_PROC_INS_OR_DLET       constant number := 170;
	UNABLE_TO_SET_TACTICAL_IND       constant number := 174;
	UNABLE_TO_SET_SMR_CODE           constant number := 178;
	UNABLE_TO_SET_UNIT_COST          constant number := 182;
	ADD_PLANNER_CODE_ERR             constant number := 186;
	ADD_UOM_CODE_ERR                 constant number := 190;
	UPDT_ERR_NATIONAL_STK_ITEMS      constant number := 194;
	ASSIGN_NEW_EQUIV_PART_ERR        constant number := 198;
	UPDT_NULL_PRIME_COLS_ERR         constant number := 202;
	INSERT_NEW_NSN_ERR               constant number := 206;
	UPDT_NSN_PRIME_ERR               constant number := 210;
	CREATE_NATSTKITEM_ERR            constant number := 214;
	PREP_DATA_FOR_UPDT_ERR           constant number := 218;
	UPDT_SPAREPART_ERR               constant number := 222;
	UPDT_PRIMEPART_ERR               constant number := 226;
	UPDT_NATSTKITEM_ERR              constant number := 230;
	NEW_NSN_ERR	                     constant number := 234;
	GET_NSISID_BY_PART_ERR           constant number := 238;
	NEW_NSN_ERROR                    constant number := 242;
	CHK_NSN_AND_PRIME_ERR2           constant number := 246;
	INSERTAGAIN_ERR                  constant number := 248;
	UNABLE_TO_CHG_NSN_TYPE           constant number := 252;
	UNABLE_TO_GET_PRIME_PART         constant number := 260;
	UPDT_NULL_PRIME_COLS_ERR2        constant number := 264;
	

	function InsertRow(
							pPart_no in varchar2,
							pMfgr in varchar2,
							pDate_icp in date,
							pDisposal_cost in number,
							pErc in varchar2,
							pIcp_ind in varchar2,
							pNomenclature in varchar2,
							pOrder_lead_time in number,
							pOrder_quantity in number,
							pOrder_uom in varchar2,
							pPrime_ind in varchar2,
							pScrap_value in number,
							pSerial_flag in varchar2,
							pShelf_life in number,
							pUnit_cost in number,
							pUnit_volume in number,
							pNsn in varchar2,
							pNsn_type in varchar2,
							pItem_type in varchar2,
							pSmr_code in varchar2,
							pPlanner_code in varchar2,
							pMic_code_lowest in varchar2,
							pAcquisition_advice_code in varchar2) return number;

	function UpdateRow(
							pPart_no in varchar2,
							pMfgr in varchar2,
							pDate_icp in date,
							pDisposal_cost in number,
							pErc in varchar2,
							pIcp_ind in varchar2,
							pNomenclature in varchar2,
							pOrder_lead_time in number,
							pOrder_quantity in number,
							pOrder_uom in varchar2,
							pPrime_ind in varchar2,
							pScrap_value in number,
							pSerial_flag in varchar2,
							pShelf_life in number,
							pUnit_cost in number,
							pUnit_volume in number,
							pNsn in varchar2,
							pNsn_type in varchar2,
							pItem_type in varchar2,
							pSmr_code in varchar2,
							pPlanner_code in varchar2,
							pMic_code_lowest in varchar2,
							pAcquisition_advice_code in varchar2) return number;

	function DeleteRow(
							pPart_no in varchar2,
							pMfgr in varchar2 ) return number;

end amd_spare_parts_pkg;
/


CREATE OR REPLACE package body amd_spare_parts_pkg as
	--
	-- SCCSID:   %M%   %I%   Modified: %G%  %U%
	--
	/*
       $Author:   c970408  $		
     $Revision:   1.6  $
         $Date:   13 Jun 2003 09:52:24  $
     $Workfile:   amd_spare_parts_pkg.sql  $
	       $Log:$	
   
      Rev 1.39   02 Oct 2002 12:30:06   c970408
   Added updateNsnFromPrimeRec() to resolve issue with amd_spare_parts.nsn not updating correctly on non-primes. Removed the nsi_sid qualification in UnassignPrimePart() to resolve issue when a part moves from one nsi_sid to another AND changes from a prime to a non-prime.
   
      Rev 1.38   30 Aug 2002 11:46:26   c970183
   Fixed updating of the prime_part_no.   When a prime_part_no and its equivalent parts got deleted and reinserted,  the logic caused the amd_national_stock_items.prime_part_no column to get set to a null value.  To accomodate this condition code has been added to the equivalent part section that checks for an existing amd_nsi_parts.part_no with its prime_ind set to 'Y'.  If found it makes sure that the same part_no appears in amd_national_stock_items.prime_part_no.
   
      Rev 1.37   28 Aug 2002 09:56:04   c970183
   Added the latest_config column for amd_national_stock_items with a value of 'Y'
   
      Rev 1.35   23 Aug 2002 12:10:54   c970183
   Stripped out ErrorMsg as a nested procedure and made it global to eliminate some redundant code.  Stripped out the updating of amd_national_stock_items to eliminate some redundant code.  Stripped out the routine for making all the equivalent parts have the same nsn as the prime part to eliminate some redundant code. 
   Added the invocation of the routine to make nsn's same for equivalent parts for a part that was equivalent, but is now prime.
   
      Rev 1.34   08 Aug 2002 13:58:58   c970183
   Fixed InsertNewNsn's no_data_found exception: made sure it returned a value.
   
      Rev 1.33   08 Aug 2002 13:49:14   c970183
   Made the InsertNatStkItem function global to the package.  Wrap all the code needed to create the amd_national_stock_items and amd_nsns rows in a global procedure called CreateNationalStockItem.  
   Changed the UpdateRow.InsertNewNsn to accomodate not finding a nsi_sid via the part_no (after having attempted to get it by the Nsn) to create a new Amd_National_Stock_Item/Amd_Nsns pair.
   
      Rev 1.32   07 Aug 2002 08:58:22   c970183
   Set unassignment_date to sysdate for deleted parts.
      	 		 
				 29 July 2002 fixed code so that a part that will be used a prime
				  	is unassigned no matter what nsn it is currently assigned and
					regardless of its current prime_ind 
				 
   
      	 		 22 July 2002 fixed code so that only one current 'C', nsn_type will
				 exist in amd_nsns for a given nsi_sid
				 
      Rev 1.30   22 May 2002 06:41:16   c970183
   Added routines to create an NsiGroup for new Nsn's and to create NsiEffects for new Nsn's using the amd_default_effectivity_pkg
   
      Rev 1.29   16 May 2002 09:59:28   c970183
   Qualifed two updates of amd_nsns with the nsn so that only one will be CURRENT. 
   
      Rev 1.28   11 Apr 2002 10:02:08   c970183
   Added 2nd SUCCESS return code for the exception handler of insertNsiPart when it recovers without a problem.
   
      Rev 1.27   11 Apr 2002 09:51:08   c970183
   Added SUCCESS return code to insertNsiParts
   
      Rev 1.26   11 Apr 2002 08:32:22   c970183
   Added ONE routine that inserts the amd_nsi_parts row and handles the dup key problem by sleeping one second and then doing the insert again.
   
      Rev 1.25   11 Apr 2002 08:09:20   c970183
   Added $Log$ keyword

      10/02/01 Douglas Elder   Initial implementation
	  03/28/02 Douglas Elder   Made application sleep when a duplicate insert
	  		   		   		   occurs and then retry the insert.
	  04/04/02 Douglas Elder	Added Mic Code to insert and update
	  04/05/02 Douglas Elder	Added code to update the nsn_type for
	  		   		   			a given nsi_sid to
	  		   		   			the amd_spare_parts_pkg.TEMPORARY_NSN
								whenever the nsn_type is
								amd_spare_parts_pkg.CURRENT_NSN
	   04/11/02 Douglas Elder   Added ONE routine that inserts the
	   							amd_nsi_parts row and handles the dup key
								problem by sleeping one second and then doing
								the insert again.
	   04/11/12 Douglas Elder   Added SUCCESS return code to insertNsiParts
     */


	UNIT_COST_CLEANED_VIA_NSN   exception;
	CANNOT_FIND_PART            exception;

	
	---------------------------------------------------------------
	-- Private declarations
	--

	function  getFedcCost(
							pPartNo varchar2) return number;
	procedure updateNsnFromPrimeRec(
							pPartNo amd_spare_parts.part_no%type,
							pNsn amd_spare_parts.nsn%type);
	function hasPartMoved(
							pPartNo varchar2,
							pNsn varchar2) return boolean;
	procedure unassignPart(
							pPartNo varchar2);

	--
	-- End Private declarations
	---------------------------------------------------------------



	procedure debugMsg(
							pMsg varchar2) is
	begin
		dbms_output.put_line(substr(pMsg,1,255));
	end;


	procedure insertLoadDetail(
							pPartNo varchar2,
							pNsn varchar2,
							pPrimeInd varchar2,
							pAction varchar2) is
		aspNsn     amd_spare_parts.nsn%type;
		aspAction  amd_spare_parts.action_code%type;
		anpNsiSid  amd_nsi_parts.nsi_sid%type;
		anNsiSid   amd_nsns.nsi_sid%type;
		anNsn      amd_nsns.nsn%type;
		anNsn2     amd_nsns.nsn%type;
		anNsnType  amd_nsns.nsn_type%type;
		anNsnType2 amd_nsns.nsn_type%type;
		anpPrime   amd_nsi_parts.prime_ind%type;
	begin
		begin
			select anp.prime_ind,an.nsn,an.nsn_type,anp.nsi_sid,
				asp.action_code,asp.nsn
			into anpPrime,anNsn,anNsnType,anpNsiSid,aspAction,aspNsn
			from amd_spare_parts asp,
				amd_nsi_parts anp,
				amd_nsns an
			where asp.part_no = pPartNo
				and asp.part_no = anp.part_no
				and anp.nsi_sid = an.nsi_sid
				and anp.unassignment_date is null
				and an.nsn_type = 'C';
		exception when others then NULL; end;
	
		begin
			select nsi_sid,nsn,nsn_type 
			into anNsiSid,anNsn2,anNsnType2
			from amd_nsns
			where nsn = pNsn;
		exception when others then NULL; end;

		amd_utils.InsertErrorMsg (
				pLoad_no => amd_utils.GetLoadNo(
					pSourceName => 'amd_spare_parts_pkg', 
					pTableName  => 'amd_spare_parts'),
				pData_line_no => 1,
				pData_line    => 'D: '||pAction||'- Curr View - pPartNo('||pPartNo||') pNsn('||pNsn||') pPrimeInd('||pPrimeInd||') - anNsn('||anNsn||') anNsnType('||anNsnType||') aspAction('||aspAction||') anpPrime('||anpPrime||') anpNsiSid('||anpNsiSid||')',
				pKey_1 => 'anNsn2('||anNsiSid||')',
				pKey_2 => 'anNsnType2('||anNsnType2||')',
				pKey_3 => 'aspNsn('||aspNsn||')',
				pKey_4 => 'anNsiSid('||anNsiSid||')',
				pKey_5 => '',
				pComments => to_char(sysdate,'yyyymmdd hh:mi:ss am'));

		commit;
	end;


	procedure unassociateTmpNsn(
							pNsn varchar2) is
	begin
		debugMsg('unassociateTmpNsn('||pNsn||')');
		-- We do this when a temp nsn now appears in CAT1. This will remove
		-- the association to the current nsn and will set up the process
		-- to create a new nsi_sid for this formerly temp nsn.
		--
		delete from amd_nsns
		where nsn = pNsn
			and nsn_type = 'T';
	end;


	function hasPartMoved(
							pPartNo varchar2,
							pNsn varchar2) return boolean is
		nsn    amd_nsns.nsn%type;
	begin
		debugMsg('hasPartMoved('||pPartNo||')');

		-- A part has moved from one nsn to another if the new and old nsns
		-- appear in tmp_amd_spare_parts at the same time.
		--
		select distinct 'Part has moved.' 
		into nsn
		from tmp_amd_spare_parts
		where
			nsn =
				(select an.nsn
				from
					amd_nsi_parts anp,
					amd_nsns an
				where anp.part_no = pPartNo
					and anp.nsi_sid = an.nsi_sid
					and anp.unassignment_date is null
					and an.nsn_type = 'C'
					and an.nsn != pNsn)
		union
		select 'Part has moved.'
		from amd_nsns an,
			amd_nsi_parts anp
		where anp.part_no = pPartNo
			and an.nsi_sid != anp.nsi_sid
			and anp.unassignment_date is null
			and an.nsn_type = 'C'
			and an.nsn = pNsn;

		return TRUE;
	exception
		when NO_DATA_FOUND then
			return FALSE;
	end;


	function  getFedcCost(
							pPartNo varchar2) return number is
		cursor costCur is
			select gfp_price
			from prc1
			where 
				part = pPartNo
				and gfp_price is not null
			order by sc desc;

		fedcCost    number;
	begin
		for rec in costCur loop
			fedcCost := rec.gfp_price;
			exit;
		end loop;

		return fedcCost;
	end;


	procedure updateNsnFromPrimeRec(
							pPartNo amd_spare_parts.part_no%type,
							pNsn amd_spare_parts.nsn%type) is
		primeNsn   amd_spare_parts.nsn%type;
	begin
		select asp.nsn
		into primeNsn
		from 
			amd_nsi_parts anpEquiv,
			amd_nsi_parts anpPrime,
			amd_spare_parts asp
		where 
			anpEquiv.part_no     = pPartNo
			and anpEquiv.nsi_sid = anpPrime.nsi_sid
			and anpEquiv.unassignment_date is null
			and anpPrime.unassignment_date is null
			and anpPrime.prime_ind = 'Y'
			and anpPrime.part_no   = asp.part_no;

		update amd_spare_parts set
			nsn = primeNsn
		where part_no = pPartNo;

	exception
		when NO_DATA_FOUND then
			update amd_spare_parts set
				nsn = pNsn
			where part_no = pPartNo;
	end;


	procedure unassignPart(
							pPartNo varchar2) is
	begin
		debugMsg('unassignPart('||pPartNo||')');
		update amd_nsi_parts set
			unassignment_date = sysdate
		where 
			part_no = pPartNo
			and unassignment_date is null;
	end;


	function IsPrimePart(
						pPrime_ind in amd_nsi_parts.prime_ind%type) return boolean is
	begin
		debugMsg('isPrimePart()');
		return (Upper(pPrime_ind) = amd_defaults.PRIME_PART);
	end IsPrimePart;


	procedure sleep(
							secs in number) is
		ss varchar2(2);
	begin
		ss := to_char(sysdate,'ss');
		while to_number(ss) + secs > to_number(to_char(sysdate,'ss'))
		loop
			null;
		end loop;
	end;
	

	/* 8/23/02 DSE added ErrorMsg to eliminate some redundant code
	 * and to give the error messages a std structure.
	 */
	function ErrorMsg(
							pSourceName in varchar2,
							pTableName in varchar2,
							pError_location in number,
							pReturn_code in number,
							pPart_no in varchar2 := '',
							pNsi_sid in varchar2 := '',
							pKeywordValuePairs in varchar2 := '') return number is
	begin
		rollback;
		amd_utils.InsertErrorMsg (
				pLoad_no => amd_utils.GetLoadNo(
						pSourceName => pSourceName, 
						pTableName  => pTableName),
				pData_line_no => pError_location,
				pData_line    => 'amd_spare_parts_pkg',
				pKey_1 => pPart_no,
				pKey_2 => pNsi_sid,
				pKey_3 => pKeywordValuePairs,
				pKey_4 => to_char(pReturn_code),
				pKey_5 => sysdate,
				pComments => 'sqlcode('||sqlcode||') sqlerrm('||sqlerrm||')');
	
		commit;
		return pReturn_code;
	end;


	function insertNsiParts(
							pNsi_sid in amd_nsi_parts.nsi_sid%type,
							pPart_no in amd_nsi_parts.part_no%type,
							pPrime_ind in amd_nsi_parts.prime_ind%type,
							pPrime_ind_cleaned in amd_nsi_parts.prime_ind_cleaned%type,
							pBadRc in number) return number is
		currDate   date:=sysdate;
	begin
		debugMsg('insertNsiParts('||pNsi_sid||','||pPart_no||','||pPrime_ind||','||pPrime_ind_cleaned||','||pBadRc||')');

		insert into amd_nsi_parts
		(
			nsi_sid, 
			assignment_date, 
			part_no, 
			prime_ind
		)
		values 
		(
			pNsi_sid, 
			currDate, 
			pPart_no, 
			pPrime_ind
		);

		-- This is a safeguard to ensure all other records are unassigned
		update amd_nsi_parts set
			unassignment_date = sysdate
		where 
			part_no = pPart_no
			and unassignment_date is null
			and assignment_date < currDate;

		return SUCCESS;
	exception 
		when dup_val_on_index then
			begin
				sleep(1);
				insert into amd_nsi_parts
				(
					nsi_sid, 
					assignment_date, 
					part_no, 
					prime_ind
				)
				values 
				(
					pNsi_sid, 
					sysdate, 
					pPart_no, 
					pPrime_ind
				);
				return SUCCESS;
			exception 
				when others then
					return ErrorMsg(
						pSourceName => 'insertNsiPart', 
						pTableName => 'amd_nsi_parts',
						pError_location => 10,
						pPart_no => pPart_no,
						pNsi_sid => to_char(pNsi_sid),
						pKeywordValuePairs => 'prime_ind='||pPrime_ind,
						pReturn_code => amd_spare_parts_pkg.INSERTAGAIN_ERR + pBadRC);
			end InsertAgainAfterOneSecond;
		when others then
			 return ErrorMsg(
						pSourceName => 'insertNsiPart', 
						pTableName => 'amd_nsi_parts',
						pError_location => 20,
						pPart_no => pPart_no,
						pNsi_sid => to_char(pNsi_sid),
						pKeywordValuePairs => 'prime_ind='||pPrime_ind,
						pReturn_code => pBadRc);
	end insertNsiParts;


	/* 8/22/02 DSE added MakeNsnSameForAllParts to eliminate some
	 * redundant code.\
	 */
	function MakeNsnSameForAllParts(
							pNsi_sid in amd_nsi_parts.nsi_sid%type,
							pNsn in amd_national_stock_items.nsn%type) return number is
		cursor partList is
			select
				part_no
			from amd_nsi_parts
			where nsi_sid = pNsi_sid
			and unassignment_date is null;
	begin
		for partList_rec in partList loop
			update amd_spare_parts parts set 
				nsn = pNsn
			where part_no = partList_rec.part_no;
		end loop;
		return SUCCESS;
	exception 
		when others then
			return ErrorMsg(
						pSourceName => 'MakeNsnSameForAllParts',
						pTableName => 'amd_spare_parts',
						pError_location => 30,
						pNsi_sid => to_char(pNsi_sid),
						pKeywordValuePairs => 'nsn='||pNsn,
						pReturn_code => amd_spare_parts_pkg.UPD_NSN_SPARE_PARTS_ERR);
	end MakeNsnSameForAllParts;


	/*
		For a given nsn if all related parts are marked
		as deleted, then its associated nsn in the
		amd_national_stock_items should be marked as DELETED.
		For a given nsn if any related part is not marked
		DELETED and its associated nsn is marked DELETED,
		then mark the nsn as either INSERTED or UPDATED depending
		on the current action
	  */
	function UpdateNatStkItem(
							pNsn in amd_spare_parts.nsn%type, 
							pAction in varchar2,
							pPartNo varchar2 default null) return number is

		nsi_sid     amd_nsi_parts.nsi_sid%type := null;

		function NumberOfActiveParts return number is
			cnt number := 0;
			result number := SUCCESS;
		begin

			select count(*) 
			into cnt
			from  amd_nsi_parts nsi, amd_spare_parts parts
			where nsi.nsi_sid = UpdateNatStkItem.nsi_sid
			and nsi.part_no = parts.part_no
			and nsi.unassignment_date is null
			and parts.action_code != amd_defaults.DELETE_ACTION;

			return cnt;
		exception
			when NO_DATA_FOUND then
				return 0;
			when others then
				result := ErrorMsg( 
							  		pSourceName => 'NumberOfActiveParts',
									pTableName => 'amd_nsi_parts',
									pError_location => 40,
									pReturn_code => FAILURE);
				raise;
		end NumberOfActiveParts;


		function IsNsnMarkedDeleted return boolean is
			action_code amd_national_stock_items.action_code%type := null;
			result number;
		begin
			select action_code 
			into action_code
			from amd_national_stock_items items
			where items.nsi_sid = UpdateNatStkItem.nsi_sid;
			return (action_code = amd_defaults.DELETE_ACTION);
		exception 
			when others then
				result := ErrorMsg(
								pSourceName => 'IsNsnMarkedDeleted',
								pTableName => 'amd_national_stock_items',
								pError_location => 80,
								pReturn_code => FAILURE,
								pNsi_sid => nsi_sid);
				raise;
		end IsNsnMarkedDeleted;

	begin -- UpdateNatStkItem
		begin
			/*
				use the nsi_sid to get a row from the
				amd_national_stock_items since it is always
				better than the Nsn - even though this Nsn
				should be the current Nsn for the prime part
				and its equivalent parts.
			*/
			nsi_sid := amd_utils.GetNsiSid(pNsn => pNsn);
		exception 
			when NO_DATA_FOUND then
				return amd_spare_parts_pkg.UNABLE_TO_GET_NSI_SID;
		end GetNsiSid;

		if pAction = amd_defaults.DELETE_ACTION then
			begin
				if NumberOfActiveParts() = 0 then
						update amd_national_stock_items set 
							action_code    = amd_defaults.DELETE_ACTION,
							last_update_dt = sysdate
						where nsi_sid = UpdateNatStkItem.nsi_sid;
				end if;
			exception 
				when others then
					return amd_spare_parts_pkg.UNABLE_TO_GET_NUM_ACTIVE_PARTS;
			end NumberOfActivePartsGt0;
		else
			/* must be an INSERT_ACTION or an UPDATE_ACTION */
			begin
				if (NumberOfActiveParts() > 0 and IsNsnMarkedDeleted() ) then
					update amd_national_stock_items set 
						action_code    = pAction,
						last_update_dt = sysdate
					where nsi_sid = UpdateNatStkItem.nsi_sid;
				end if;
			exception 
				when others then
					return amd_spare_parts_pkg.UNABLE_TO_PROC_INS_OR_DLET;
			end ProcessInsertOrDelete;
		end if;

		return SUCCESS;
	exception 
		when others then
			return ErrorMsg(
				   pSourceName => 'UpdateNatStkItem',
				   pTableName => 'amd_national_stock_items',
				   pError_location => 80,
				   pReturn_code => amd_spare_parts_pkg.UPDT_NATSTKITEM_ERR);
	end UpdateNatStkItem;


	/* 8/22/02 DSE added UpdtNsiPrimePartData to eliminate some 
	 * redundant code.
	 */
	function UpdtNsiPrimePartData(
							pPrime_ind in amd_nsi_parts.prime_ind%type,
							pNsi_sid in amd_national_stock_items.nsi_sid%type,
							pPartNo in amd_national_stock_items.prime_part_no%type,
							pNsn in amd_national_stock_items.nsn%type,
							pItem_type in amd_national_stock_items.item_type%type,
							pOrder_quantity in amd_national_stock_items.order_quantity%type,
							pPlannerCode in amd_national_stock_items.planner_code%type,
							pSmr_code in amd_national_stock_items.smr_code%type,
							pMic_code_lowest in amd_national_stock_items.mic_code_lowest%type,
							pAction_code in amd_national_stock_items.action_code%type,
							pReturn_code in number) return number is
		fedcCost   number;
	begin 
		if (IsPrimePart(pPrime_ind)) then
			fedcCost := getFedcCost(pPartNo);

			update amd_national_stock_items set 
				prime_part_no   = pPartNo,
				fedc_cost       = fedcCost,
				nsn             = pNsn,
				item_type       = pItem_type,
				order_quantity  = pOrder_quantity,
				planner_code    = pPlannerCode,
				smr_code        = pSmr_code,
				mic_code_lowest = pMic_code_lowest,
				last_update_dt  = sysdate,
				action_code     = pAction_code
			where nsi_sid = pNsi_sid;
		end if;
		
		return SUCCESS;
		
	exception 
		when others then
			return ErrorMsg(
					 pSourceName => 'UpdtNsiPrimePartData',
					 pTableName => 'amd_national_stock_items',
					 pError_location => 90,
					 pReturn_code => pReturn_code,
					 pPart_no => pPartNo,
					 pNsi_sid => to_char(pNsi_sid),
					 pKeywordValuePairs => 'nsn='||pNsn);
	end UpdtNsiPrimePartData;


	function InsertNatStkItem(
							pNsi_sid out amd_national_stock_items.nsi_sid%type,
							pNsn in amd_spare_parts.nsn%type,
							pItem_type in amd_national_stock_items.item_type%type,
							pOrder_quantity in amd_national_stock_items.order_quantity%type,
							pPlanner_code in amd_national_stock_items.planner_code%type,
							pSmr_code in amd_national_stock_items.smr_code%type,
							pTactical in amd_national_stock_items.tactical%type,
							pMic_code_lowest in amd_national_stock_items.mic_code_lowest%type) return number is

		result number := SUCCESS;
		nsiGroupSid number;
		
		function GetNsiSid return amd_national_stock_items.nsi_sid%type is
			nsi_sid amd_national_stock_items.nsi_sid%type := null;
		begin
			select amd_nsi_sid_seq.CURRVAL 
			into nsi_sid
			from dual;
			return nsi_sid;
		end GetNsiSid;

	begin -- InsertNatStkItem
		nsiGroupSid := amd_default_effectivity_pkg.NewGroup;

		begin
			insert into amd_national_stock_items
			( 	
				nsn,
				add_increment_cleaned,
				amc_base_stock_cleaned,
				amc_days_experience_cleaned,
				amc_demand_cleaned,
				capability_requirement_cleaned,
				criticality_cleaned,
				distrib_uom_defaulted,
				dla_demand_cleaned,
				dla_warehouse_stock_cleaned,
				fedc_cost_cleaned,
				item_type,
				item_type_cleaned,
				mic_code_lowest_cleaned,
				mtbdr_cleaned,
				nomenclature_cleaned,
				order_lead_time_cleaned,
				order_quantity,
				order_quantity_defaulted,
				order_uom_cleaned,
				planner_code,
				planner_code_cleaned,
				prime_part_no,
				qpei_weighted_defaulted,
				ru_ind_cleaned,
				smr_code,
				smr_code_cleaned,
				unit_cost_cleaned,
				condemn_avg_defaulted,
				condemn_avg_cleaned,
				nrts_avg_defaulted,
				nrts_avg_cleaned,
				rts_avg_defaulted,
				rts_avg_cleaned,
				cost_to_repair_off_base_cleand,
				time_to_repair_off_base_cleand,
				time_to_repair_on_base_avg_df,
				time_to_repair_on_base_avg_cl,
				tactical,
				action_code,
				last_update_dt,
				mic_code_lowest,
				nsi_group_sid,
				latest_config,
				effect_by
			)
			values 
			(
				null, -- nsn
				amd_clean_data.GetAddIncrement(pNsn),
				amd_clean_data.GetAmcBaseStock(pNsn),
				amd_clean_data.GetAmcDaysExperience(pNsn),
				amd_clean_data.GetAmcDemand(pNsn),
				amd_clean_data.GetCapabilityRequirement(pNsn),
				amd_clean_data.GetCriticality(pNsn),
				amd_defaults.DISTRIB_UOM,
				amd_clean_data.GetDlaDemand(pNsn),
				amd_clean_data.GetDlaWarehouseStock(pNsn),
				amd_clean_data.GetFedcCost(pNsn),
				pItem_type,
				amd_clean_data.GetItemType(pNsn),
				amd_clean_data.GetMicCodeLowest(pNsn),
				amd_clean_data.GetMtbdr(pNsn),
				amd_clean_data.GetNomenclature(pNsn),
				amd_clean_data.GetOrderLeadTime(pNsn),
				pOrder_Quantity,
				amd_defaults.ORDER_QUANTITY,
				amd_clean_data.GetOrderUom(pNsn),
				pPlanner_code,
				amd_clean_data.GetPlannerCode(pNsn),
				null, -- prime_part_no
				amd_defaults.QPEI_WEIGHTED,
				amd_clean_data.GetRuInd(pNsn),
				pSmr_code,
				amd_clean_data.GetSmrCode(pNsn),
				amd_clean_data.GetUnitCost(pNsn),
				amd_defaults.CONDEMN_AVG,
				amd_clean_data.GetCondemnAvg(pNsn),
				amd_defaults.NRTS_AVG,
				amd_clean_data.GetNrtsAvg(pNsn),
				amd_defaults.RTS_AVG,
				amd_clean_data.GetRtsAvg(pNsn),
				amd_clean_data.GetCostToRepairOffBase(pNsn),
				amd_clean_data.GetTimeToRepairOffBase(pNsn),
				amd_defaults.TIME_TO_REPAIR_ONBASE,
				amd_clean_data.GetTimeToRepairOnBaseAvg(pNsn),
				pTactical,
				amd_defaults.INSERT_ACTION,
				sysdate,
				pMic_code_lowest,
				nsiGroupSid,
				'Y',
				'S'
			);
		exception 
			when others then
				return ErrorMsg(
		   			pSourceName => 'InsertNsi',
						pTableName => 'amd_national_stock_items',
						pError_location => 90, 
		   			pReturn_code => amd_spare_parts_pkg.CREATE_NATSTKITEM_ERR);
		end InsertNsi;

		pNsi_sid := GetNsiSid();

		return SUCCESS;
	end InsertNatStkItem;

	
	function ChgCurNsn2TempNsn(
							pNsiSid in amd_nsns.nsi_sid%type) return number is
	begin
		update amd_nsns set 
			nsn_type = amd_spare_parts_pkg.TEMPORARY_NSN
		where nsi_sid = pNsiSid and nsn_type = amd_spare_parts_pkg.CURRENT_NSN;
		return SUCCESS;
	exception
		when others then	
			return ErrorMsg(
						pSourceName => 'ChgCurNsn2TempNsn',
						pTableName => 'amd_nsns',
						pError_location => 100,
						pReturn_code => amd_spare_parts_pkg.UNABLE_TO_CHG_NSN_TYPE);
	end ChgCurNsn2TempNsn;

	
	function InsertAmdNsn(
							pNsi_sid in amd_nsns.nsi_sid%type,
							pNsn in amd_nsns.nsn%type,
							pNsn_type in amd_nsns.nsn_type%type ) return number is
		
		result number ;
		
	begin
	    if pNsn_type = amd_spare_parts_pkg.CURRENT_NSN then
		   result:= ChgCurNsn2TempNsn(pNsiSid => pNsi_sid);
		end if;
		if result = SUCCESS then
			insert into amd_nsns
			(
				nsn, 
				nsn_type, 
				nsi_sid, 
				creation_date
			)
			values
			(
				pNsn, 
				pNsn_type, 
				pNsi_sid, 
				sysdate
			);
			return SUCCESS;
		end if;
		return result;
	exception 
		when others then
	 		return ErrorMsg(
			   	pSourceName => 'InsertAmdNsn',
					pTableName => 'amd_nsns',
					pError_location => 110,
					pNsi_sid => to_char(pNsi_sid),
					pKeywordValuePairs => 'nsn='||pNsn||' nsn_type='||pNsn_type,
			   	pReturn_code =>amd_spare_parts_pkg.UNABLE_TO_INSERT_AMD_NSNS);
	end InsertAmdNsn;


	function UpdateAmdNsn(
							pNsi_sid in amd_nsns.nsi_sid%type,
							pNsn in amd_nsns.nsn%type,
							pNsn_type in amd_nsns.nsn_type%type ) return number is
		result number;
	begin
		if pNsn_type = amd_spare_parts_pkg.CURRENT_NSN then
		   result:= ChgCurNsn2TempNsn(pNsiSid => pNsi_sid);
		end if ; 
		if result = SUCCESS then
			update amd_nsns set 
				nsn_type = pNsn_type
			where nsi_sid = pNsi_sid and nsn = pNsn;
			return SUCCESS;
		end if;
		return result;
		
	exception 
		when others then
	 		return ErrorMsg(
	   				 pSourceName => 'UpdateAmdNsn',
						 pTableName => 'amd_nsns',
						 pError_location => 120,
						 pNsi_sid => to_char(pNsi_sid),
						 pKeywordValuePairs => 'nsn='||pNsn||' nsn_type='||pNsn_type,
						 pReturn_code=>amd_spare_parts_pkg.UNABLE_TO_INSERT_AMD_NSNS);
	end UpdateAmdNsn;


	function CreateNationalStockItem(
							pNsi_sid out amd_national_stock_items.nsi_sid%type,
							pNsn in amd_spare_parts.nsn%type,
							pItem_type in amd_national_stock_items.item_type%type,
							pOrder_quantity in amd_national_stock_items.order_quantity%type,
							pPlanner_code in amd_national_stock_items.planner_code%type,
							pSmr_code in amd_national_stock_items.smr_code%type,
							pTactical in amd_national_stock_items.tactical%type,
							pMic_code_lowest in amd_national_stock_items.mic_code_lowest%type,
							pNsn_type in amd_nsns.nsn_type%type) return number is
			 
		result number := SUCCESS;
			 
	begin
		result := InsertNatStkItem(pNsi_sid => pNsi_sid,
					 pNsn => pNsn,
					 pItem_type => pItem_type,
					 pOrder_quantity => pOrder_quantity,
					 pPlanner_code => pPlanner_code,
					 pSmr_code => pSmr_code,
					 pTactical => pTactical,
					 pMic_code_lowest => pMic_code_lowest);

		if result = SUCCESS then
		   amd_default_effectivity_pkg.SetNsiEffects(pNsi_sid);
		   if pNsn_type = amd_spare_parts_pkg.CURRENT_NSN then 
		   	  result := amd_spare_parts_pkg.ChgCurNsn2TempNsn(
							pNsiSid => pNsi_sid);
		   end if;
		   if result = SUCCESS then
		   	  result := InsertAmdNsn(pNsi_sid => pNsi_sid, pNsn => pNsn, pNsn_type => pNsn_type);
		   end if;
		end if;
		
		return result;
		
	end CreateNationalStockItem;


	function InsertRow(
							pPart_no in varchar2,
							pMfgr in varchar2,
							pDate_icp in date,
							pDisposal_cost in number,
							pErc in varchar2,
							pIcp_ind in varchar2,
							pNomenclature in varchar2,
							pOrder_lead_time in number,
							pOrder_quantity in number,
							pOrder_uom in varchar2,
							pPrime_ind in varchar2,
							pScrap_value in number,
							pSerial_flag in varchar2,
							pShelf_life in number,
							pUnit_cost in number,
							pUnit_volume in number,
							pNsn in varchar2,
							pNsn_type in varchar2,
							pItem_type in varchar2,
							pSmr_code in varchar2,
							pPlanner_code in varchar2,
							pMic_code_lowest in varchar2,
							pAcquisition_advice_code in varchar2) return number is

		/* Although the following variables are local to the InsertRow
		  procedure, you will see them referenced as InsertRow.variable_name.
		  This was done to improve readability.  A similar approach is used
		  for package constants: package_name.constant_name.
		 */
		prime_ind_cleaned    amd_nsi_parts.prime_ind_cleaned%type := null;
		result               number := SUCCESS;
		smr_code_cleaned     amd_national_stock_items.smr_code_cleaned%type := null;
		tactical             amd_spare_parts.tactical%type := 'N';
		unit_cost_cleaned    amd_national_stock_items.unit_cost_cleaned%type := null;
		unit_cost_defaulted  amd_spare_parts.unit_cost_defaulted%type := null;


		/* Put a wrapper on the amd_utils.InsertErrorMsg procedure, so it is
			more specific to the InsertRow function.  Output gets stored
			into amd_load_details and amd_load_status.
		*/
		function ErrorMsg(
							pTableName in varchar2, 
							rc in number) return number is
		begin
			return amd_spare_parts_pkg.ErrorMsg(
				   	pTableName => pTableName,
						pSourceName => 'InsertRow',
						pError_location => 130,
						pReturn_code => rc,
						pPart_no => pPart_no,
						pKeywordValuePairs => 'nsn='||pNsn||' nsn_type='||pNsn_type);
		end ErrorMsg;


		function InsertAmdNsiParts(
							pNsi_sid in amd_nsi_parts.nsi_sid%type) return number is

			result number := SUCCESS;
		begin
			return insertNsiParts(pNsi_sid => pNsi_sid, 
				   	   pPart_no => pPart_no, 
				   	   pPrime_ind => pPrime_ind, 
					   pPrime_ind_cleaned => prime_ind_cleaned, 
				   	   pBadRc => amd_spare_parts_pkg.UNABLE_TO_INSERT_AMD_NSI_PARTS);
		end InsertAmdNsiParts;


		function InsertEquivalentPartData(
							pNsi_sid in amd_nsi_parts.nsi_sid%type) return number is
		begin
			return InsertAmdNsiParts(pNsi_sid);
		end InsertEquivalentPartData;


		function DoPhysicalInsert return number is

			nsi_sid amd_national_stock_items.nsi_sid%type := null;

			function IsPrimeReplacingExistingOne(
							pNsi_sid in amd_nsi_parts.nsi_sid%type,
							pCurrent_prime_part_no out amd_nsi_parts.part_no%type) return boolean is

				prime_ind amd_nsi_parts.prime_ind%type := null;
			begin
				begin
					select 
						part_no,  
						prime_ind
					into pCurrent_prime_part_no, prime_ind
					from amd_nsi_parts
					where nsi_sid = pNsi_sid
					and prime_ind = amd_defaults.PRIME_PART
					and unassignment_date is null;
					return true;
				exception
					when no_data_found then
						return false;
				end;
			end IsPrimeReplacingExistingOne;


			function PrepareDataForInsert return number is
			begin

				begin
					InsertRow.smr_code_cleaned := amd_clean_data.GetSmrCode(pNsn);
				exception 
					when others then
						return InsertRow.ErrorMsg('SetSmrCode',
						amd_spare_parts_pkg.UNABLE_TO_SET_SMR_CODE);
				end SetSmrCode;

				-- todo prime_ind_cleaned will be set in a separate routine since it is
				-- so complicated
				-- InsertRow.prime_ind_cleaned := amd_clean_data.prime_ind(nsn);
				begin
					InsertRow.unit_cost_cleaned   :=amd_clean_data.GetUnitCost(pNsn);
					InsertRow.unit_cost_defaulted :=amd_defaults.GetUnitCost(
								pNsn, pPart_no, pMfgr, pSmr_code, pPlanner_code);
				exception 
					when others then
						return InsertRow.ErrorMsg('SetUnitCost',
								amd_spare_parts_pkg.UNABLE_TO_SET_UNIT_COST);
				end SetUnitCost;

				begin
					InsertRow.tactical :=
							amd_validation_pkg.GetTacticalInd(
								amd_preferred_pkg.GetPreferredValue(InsertRow.unit_cost_cleaned,
										  pUnit_cost,
										  InsertRow.unit_cost_defaulted),
								amd_preferred_pkg.GetPreferredValue(InsertRow.smr_code_cleaned,
										 pSmr_code)
								 );
				exception 
					when others then
						return InsertRow.ErrorMsg('GetTacticalInd',
								amd_spare_parts_pkg.UNABLE_TO_SET_TACTICAL_IND);
				end GetTacticalInd;

				if pPlanner_code is not null then
					if not amd_validation_pkg.IsValidPlannerCode(pPlanner_code) then
						if amd_validation_pkg.AddPlannerCode(pPlanner_code) != amd_validation_pkg.SUCCESS then
							return amd_spare_parts_pkg.ADD_PLANNER_CODE_ERR;
						end if;
					end if;
				end if;

				if pOrder_uom is not null then
					if not amd_validation_pkg.IsValidUomCode(pOrder_uom) then
						if amd_validation_pkg.AddUomCode(pOrder_uom) != amd_validation_pkg.SUCCESS then
							return amd_spare_parts_pkg.ADD_UOM_CODE_ERR;
						end if;
					end if;
				end if;
				return SUCCESS;
			exception 
				when others then
					return InsertRow.ErrorMsg('PrepareDataForInsert',
							amd_spare_parts_pkg.UNABLE_TO_PREP_DATA);
			end PrepareDataForInsert;


			function NatStkItemExists(
							pNsn in amd_spare_parts.nsn%type,
							pNsi_sid out amd_nsns.nsi_sid%type) return boolean is
			begin
				select nsi_sid 
				into pNsi_sid
				from amd_nsns
				where nsn = pNsn
				and nsi_sid is not null;
				return true;
			exception
				when no_data_found then
					return false;
			end NatStkItemExists;


			function InsertSparePart return number is
			begin
				insert into amd_spare_parts
				(
					part_no,
					mfgr,
					date_icp,
					disposal_cost,
					disposal_cost_defaulted,
					erc,
					icp_ind,
					nomenclature ,
					order_lead_time,
					order_lead_time_defaulted,
					order_uom,
					order_uom_defaulted,
					scrap_value,
					scrap_value_defaulted,
					serial_flag,
					shelf_life,
					shelf_life_defaulted,
					unit_cost,
					unit_cost_defaulted,
					unit_volume,
					unit_volume_defaulted,
					nsn,
					tactical,
					action_code,
					last_update_dt,
					acquisition_advice_code
				)
				values
				(
					pPart_no,
					pMfgr,
					pDate_icp,
					pDisposal_cost,
					amd_defaults.DISPOSAL_COST,
					pErc,
					pIcp_ind,
					pNomenclature ,
					pOrder_lead_time,
					amd_defaults.GetOrderLeadTime(pItem_type),
					pOrder_uom,
					amd_defaults.ORDER_UOM,
					pScrap_value,
					amd_defaults.SCRAP_VALUE,
					pSerial_flag,
					pShelf_life,
					amd_defaults.SHELF_LIFE,
					pUnit_cost,
					InsertRow.unit_cost_defaulted,
					pUnit_volume,
					amd_defaults.UNIT_VOLUME,
					pNsn,
					InsertRow.tactical,
					amd_defaults.INSERT_ACTION,
					sysdate,
					pAcquisition_advice_code
				);
				return SUCCESS;
			exception
				when DUP_VAL_ON_INDEX then
					return InsertRow.ErrorMsg('amd_spare_parts', 
							'action_code('||amd_defaults.INSERT_ACTION||') '||amd_spare_parts_pkg.PART_ALREADY_EXISTS);
				when others then
					return InsertRow.ErrorMsg('amd_spare_parts',
							amd_spare_parts_pkg.UNABLE_TO_INSERT_SPARE_PART);
			end InsertSparePart;


			function UpdatePrimePartData(
							pNsi_sid in amd_national_stock_items.nsi_sid%type) return number is

				result number := SUCCESS;


			begin -- UpdatePrimePartData
				begin
					result := InsertAmdNsiParts(pNsi_sid);
				exception 
					when others then
						result := InsertRow.ErrorMsg('InsertAmdNsiParts',
								INS_AMD_NSI_PARTS_ERR);
				end;
				if result = SUCCESS then
					result := UpdtNsiPrimePartData (pPrime_ind => pPrime_ind,
		 					  pNsi_sid => pNsi_sid,
		 					  pPartNo => pPart_no,
		 					  pNsn => pNsn,
							  pItem_type => pItem_type,
							  pOrder_quantity => pOrder_quantity,
							  pPlannerCode => pPlanner_code,
							  pSmr_code => pSmr_code,
							  pMic_code_lowest => pMic_code_lowest,
							  pAction_code => amd_defaults.INSERT_ACTION,
							  pReturn_code => amd_spare_parts_pkg.UNABLE_TO_PRIME_INFO);
				end if;
				return result;
			exception 
				when others then
					return InsertRow.ErrorMsg('UpdatePrimePartData',INSERT_PRIMEPART_ERR);
			end UpdatePrimePartData;


			function UpdatePrimePartData(
							pNsn in amd_national_stock_items.nsn%type,
							pNsi_sid in amd_nsns.nsi_sid%type,
							pCurrent_prime_part_no in amd_nsi_parts.part_no%type) return number is

				result number := SUCCESS;

				function MakePrimeAnEquivalentPart return number is
				begin

					update amd_nsi_parts set 
						unassignment_date = sysdate
					where 
						nsi_sid = pNsi_sid
						and (prime_ind             = amd_defaults.PRIME_PART 
								or prime_ind_cleaned = amd_defaults.PRIME_PART)
						and unassignment_date is null;

					return insertNsiParts(pNsi_sid => pNsi_sid,
						    pPart_no => pCurrent_prime_part_no,
							pPrime_ind => amd_defaults.NOT_PRIME_PART,
							pPrime_ind_cleaned => null,
							pBadRc => amd_spare_parts_pkg.UNASSIGN_OLD_PRIME_PART_ERR);

				end MakePrimeAnEquivalentPart;


			begin -- UpdatePrimePartData
				result := UpdtNsiPrimePartData (pPrime_ind => pPrime_ind,
	 					  pNsi_sid => pNsi_sid,
	 					  pPartNo => pPart_no,
	 					  pNsn => pNsn,
						  pItem_type => pItem_type,
						  pOrder_quantity => pOrder_quantity,
						  pPlannerCode => pPlanner_code,
						  pSmr_code => pSmr_code,
						  pMic_code_lowest => pMic_code_lowest,
						  pAction_code => amd_defaults.UPDATE_ACTION,
						  pReturn_code => amd_spare_parts_pkg.CANNOT_UPADATE_NAT_STCK_ITEMS);

				if result != SUCCESS then
				   return result;
				end if;

				if pNsn_type = amd_spare_parts_pkg.CURRENT_NSN then
					result := amd_spare_parts_pkg.ChgCurNsn2TempNsn(pNsiSid => pNsi_sid);
					if result != SUCCESS then
						return result;
					end if;
				end if;

				begin
					result := amd_spare_parts_pkg.UpdateAmdNsn(pNsn_Type => pNsn_Type,
													 pNsi_Sid => pNsi_sid,
													 pNsn => pNsn ) ; 
				exception 
					when others then
						return InsertRow.ErrorMsg('amd_nsns',
								amd_spare_parts_pkg.CANNOT_UPDATE_AMD_NSNS);
				end update_amd_nsns;

				result := MakePrimeAnEquivalentPart();
				if result = SUCCESS then
					result := insertNsiParts(pNsi_sid => pNsi_sid,
				   	  			pPart_no => pPart_no,
								pPrime_ind => pPrime_ind,
								pPrime_ind_cleaned => null,
								pBadRc => amd_spare_parts_pkg.MAKE_NEW_PRIME_PART_ERR);
				end if;
				if result = SUCCESS then
					result := MakeNsnSameForAllParts(pNsi_sid => pNsi_sid, pNsn => pNsn );
				end if;
				return result;
			end UpdatePrimePartData;

		begin -- DoPhysicalInsert
			result := PrepareDataForInsert;

			if result = SUCCESS then
				if NatStkItemExists(pNsn => pNsn, pNsi_sid => DoPhysicalInsert.nsi_sid) then
					null ; -- OK do nothing
				else -- create one
				    result := CreateNationalStockItem(pNsi_sid => DoPhysicalInsert.nsi_sid,
			 			   	  pNsn => pNsn,
			 				  pItem_type => pItem_type,
			 				  pOrder_quantity => pOrder_quantity,
			 				  pPlanner_code => pPlanner_code,
			 				  pSmr_code => pSmr_code,
			 				  pTactical => InsertRow.tactical,
			 				  pMic_code_lowest => InsertRow.pMic_code_lowest,
							  pNsn_type => pNsn_type);
				end if;
			end if;

			if result = SUCCESS then
				result := InsertSparePart();
			end if;

			if result = SUCCESS then
				if IsPrimePart(pPrime_ind) then
					declare
						current_prime_part_no amd_nsi_parts.part_no%type := null;
					begin
						if IsPrimeReplacingExistingOne(pNsi_sid => DoPhysicalInsert.nsi_sid,
								pCurrent_prime_part_no 	=> current_prime_part_no) then
							begin
								result := UpdatePrimePartData(pNsn => pNsn,
											pNsi_sid => DoPhysicalInsert.nsi_sid,
											pCurrent_prime_part_no => current_prime_part_no);
							exception when others then
								result := InsertRow.ErrorMsg('UpdatePrimePartData',
									UPD_PRIME_PART_ERR);
							end UpdatePrimePartData;
						else
							begin
								result := UpdatePrimePartData(pNsi_sid => DoPhysicalInsert.nsi_sid);
							exception when others then
								result := InsertRow.ErrorMsg('UpdatePrimePartData',
									INS_PRIME_PART_ERR);
							end UpdatePrimePartData;
						end if;
					end CheckForExistingPrime;
				else
					begin
						result := InsertEquivalentPartData(pNsi_sid => DoPhysicalInsert.nsi_sid);
					exception when others then
						result := InsertRow.ErrorMsg('InsertEquivalentPartData',
							INS_EQUIV_PART_ERR);
					end;
				end if;
			end if ;
			if result = SUCCESS then
				if pNsn is not null then
					begin
						result := UpdateNatStkItem(pNsn, amd_defaults.INSERT_ACTION,pPart_no);
					exception when others then
						result := InsertRow.ErrorMsg('UpdateNatStkItem',
							UPDATE_NATSTK_ERR);
					end;
				end if;
			end if;

			return result;
		end DoPhysicalInsert;


		function DoLogicalInsert return number is
		begin

			result := UpdateRow
						(pPart_no,
						pMfgr,
						pDate_icp,
						pDisposal_cost,
						pErc,
						pIcp_ind,
						pNomenclature,
						pOrder_lead_time,
						pOrder_quantity,
						pOrder_uom,
						pPrime_ind,
						pScrap_value,
						pSerial_flag,
						pShelf_life,
						pUnit_cost,
						pUnit_volume,
						pNsn,
						pNsn_type,
						pItem_type,
						pSmr_code,
						pPlanner_code,
						pMic_code_lowest,
						pAcquisition_advice_code);

			if result = SUCCESS then
				begin
					-- Make it look like an insert was just
					-- done.
					update amd_spare_parts set 
						action_code = amd_defaults.INSERT_ACTION
					where part_no = pPart_no;
				exception 
					when others then
						result := InsertRow.ErrorMsg('LogicalInsert',LOGICAL_INSERT_FAILED);
				end LogicalInsert;
			end if;
			return result;
		end DoLogicalInsert;


		function IsPartMarkedAsDeleted return boolean is

			function GetActionCode return varchar2 is
				action_code varchar2(1);
			begin
				select action_code 
				into action_code
				from amd_spare_parts
				where		part_no = pPart_no;
				return action_code;
			exception 
				when NO_DATA_FOUND then
					return null;
			end GetActionCode;

		begin
			return (GetActionCode() = amd_defaults.DELETE_ACTION);
		end IsPartMarkedAsDeleted;

    begin -- <<<---- InsertRow
--		insertLoadDetail(pPart_No,pNsn,pPrime_Ind,'Insert');

		if IsPartMarkedAsDeleted() then
			result := DoLogicalInsert();
		else
			unassociateTmpNsn(pNsn);

			result := DoPhysicalInsert();
		end if;

		if result != SUCCESS then
			rollback ;  /* this is probably overkill since
							the ErrorMsg function does a rollback,
							but it is always a good idea to have a
							backup parachute
							*/
		end if;
		return result;

	exception 
		when others then
			return InsertRow.ErrorMsg('amd_spare_parts',
					amd_spare_parts_pkg.INSERTROW_FAILED);
	end InsertRow;


	function UpdateRow(
							pPart_no in varchar2,
							pMfgr in varchar2,
							pDate_icp in date,
							pDisposal_cost in number,
							pErc in varchar2,
							pIcp_ind in varchar2,
							pNomenclature in varchar2,
							pOrder_lead_time in number,
							pOrder_quantity in number,
							pOrder_uom in varchar2,
							pPrime_ind in varchar2,
							pScrap_value in number,
							pSerial_flag in varchar2,
							pShelf_life in number,
							pUnit_cost in number,
							pUnit_volume in number,
							pNsn in varchar2,
							pNsn_type in varchar2,
							pItem_type in varchar2,
							pSmr_code in varchar2,
							pPlanner_code in varchar2,
							pMic_code_lowest in varchar2,
							pAcquisition_advice_code in varchar2) return number is

		/* Although the following variables are local to the UpdateRow
		  procedure, you will see them referenced as UpdateRow.variable_name.
		  This was done to improve readability.  A similar approach is used
		  for package constants: package_name.constant_name.
		 */
		nsiSid      amd_national_stock_items.nsi_sid%type := null;
		result      number := SUCCESS;
		tactical    amd_spare_parts.tactical%type := 'N';


		/* Put a wrapper on the amd_utils.InsertErrorMsg procedure, so it is
			more specific to the UpdateRow function.  Output gets stored
			into amd_load_details and amd_load_status.
		*/
		function ErrorMsg(
							pTableName in varchar2, 
							rc in number) return number is
		begin
			 return amd_spare_parts_pkg.ErrorMsg(
			 									pSourceName => 'UpdateRow',
												pTableName => pTableName,
												pError_location => 130,
												pPart_no => pPart_no,
												pKeywordValuePairs => 'nsn='||pNsn||' nsn_type='||pNsn_type,
												pReturn_code => rc);
		end ErrorMsg;


		function PrepareDataForUpdate return number is
			function GetSmrCode
				return amd_national_stock_items.smr_code%type is
				smr_code_cleaned	amd_national_stock_items.smr_code_cleaned%type;
			begin
				select smr_code_cleaned
				into smr_code_cleaned
				from amd_national_stock_items items
				where nsi_sid = nsiSid;
				return amd_preferred_pkg.GetPreferredValue(smr_code_cleaned,
					pSmr_code);
			exception 
				when NO_DATA_FOUND then
					return null;
			end GetSmrCode;


			function GetUnitCost return amd_spare_parts.unit_cost%type is
				unit_cost_cleaned amd_national_stock_items.unit_cost_cleaned%type;
				unit_cost_defaulted amd_spare_parts.unit_cost_defaulted%type;
			begin
				begin
					select unit_cost_cleaned, unit_cost_defaulted
					into unit_cost_cleaned, unit_cost_defaulted
					from amd_national_stock_items
					where nsn = pNsn;
				exception
					when NO_DATA_FOUND then
						unit_cost_cleaned := null;
					when others then
						raise amd_spare_parts_pkg.UNIT_COST_CLEANED_VIA_NSN;
				end get_unit_cost_cleaned;
				return amd_preferred_pkg.GetPreferredValue(unit_cost_cleaned,
					pUnit_cost, unit_cost_defaulted);
			end GetUnitCost;

		begin -- PrepareDataForUpdate
			begin
				UpdateRow.tactical :=
					amd_validation_pkg.GetTacticalInd(GetUnitCost(),GetSmrCode() );
			exception 
				when amd_spare_parts_pkg.UNIT_COST_CLEANED_VIA_NSN then
					return UpdateRow.ErrorMsg('setTactical',
							amd_spare_parts_pkg.CANNOT_GET_UNIT_COST_CLEANED);
			end setTactical;

			if pPlanner_code is not null then
				if not amd_validation_pkg.IsValidPlannerCode(pPlanner_code) then
					if amd_validation_pkg.AddPlannerCode(pPlanner_code) != amd_validation_pkg.SUCCESS then
						return amd_spare_parts_pkg.ADD_PLANNER_CODE_ERR;
					end if;
				end if;
			end if;

			if pOrder_uom is not null then
				if not amd_validation_pkg.IsValidUomCode(pOrder_uom) then
					if amd_validation_pkg.AddUomCode(pOrder_uom) != amd_validation_pkg.SUCCESS then
						return amd_spare_parts_pkg.ADD_UOM_CODE_ERR;
					end if;
				end if;
			end if;

			return SUCCESS;
		exception when others then
			return UpdateRow.ErrorMsg('PrepareDataForUpdate',
				amd_spare_parts_pkg.PREP_DATA_FOR_UPDT_ERR);
		end PrepareDataForUpdate;


		function UpdateAmdSparePartRow(
							pPartNo amd_spare_parts.part_no%type,
							pNsn amd_spare_parts.nsn%type) return number is
		begin
			debugMsg('updateAmdSparePartRow('||pPartNo||','||pNsn||')');
			update amd_spare_parts set 
				date_icp        = pDate_icp,
				disposal_cost   = pDisposal_cost,
           	erc             = pErc,
           	icp_ind         = pIcp_ind,
           	nomenclature    = pNomenclature ,
           	order_lead_time = pOrder_lead_time,
           	order_uom       = pOrder_uom,
           	scrap_value     = pScrap_value,
           	serial_flag     = pSerial_flag,
           	shelf_life      = pShelf_life,
           	unit_cost       = pUnit_cost,
           	unit_volume     = pUnit_volume,
				tactical        = UpdateRow.tactical,
				action_code     = amd_defaults.UPDATE_ACTION,
				last_update_dt  = sysdate,
				nsn             = pNsn,
				acquisition_advice_code = pAcquisition_advice_code
			where part_no = pPartNo;

			return SUCCESS;
		exception when others then
			return UpdateRow.ErrorMsg('UpdateAmdSparePartRow',
				amd_spare_parts_pkg.UPDT_SPAREPART_ERR);
		end UpdateAmdSparePartRow;


		function UpdatePrimePartData return number is
		begin

			begin
				result := amd_spare_parts_pkg.UpdateAmdNsn(
					   pNsn_type => pNsn_type,
					   pNsi_sid => nsiSid,
					   pNsn => pNsn);
			exception when others then
				return UpdateRow.ErrorMsg('amd_nsns',
					amd_spare_parts_pkg.CANNOT_UPDATE_AMD_NSNS);
			end update_amd_nsns;

			return SUCCESS;
		exception when others then
			return UpdateRow.ErrorMsg('UpdatePrimePartData',
				amd_spare_parts_pkg.UPDT_PRIMEPART_ERR);
		end UpdatePrimePartData;


		function NsnChanged(
							pPartNo varchar2,
							pNsn varchar2) return boolean is
			nsn amd_nsns.nsn%type;
		begin
			debugMsg('nsnChanged('||pPartNo||','||pNsn||')');
			select an.nsn 
			into nsn
			from
				amd_nsi_parts anp,
				amd_nsns an
			where
				anp.nsi_sid = an.nsi_sid
				and anp.part_no = pPartNo
				and anp.unassignment_date is null
				and an.nsn_type = 'C';

			if nsn != pNsn then
				return true;
			else
				return false;
			end if;

		exception 
			when NO_DATA_FOUND then
				return TRUE;
		end NsnChanged;


		function PrimeIndChanged return boolean is
			prime_ind amd_nsi_parts.prime_ind%type := null;
		begin
			debugMsg('primeIndChanged()');

			select prime_ind 
			into prime_ind
			from amd_nsi_parts
			where nsi_sid = nsiSid
			and part_no = pPart_no
			and unassignment_date is null;

			return (prime_ind != pPrime_ind);
		exception 
			when no_data_found then
				return true;
		end;


		function UpdateNsnForPrimePart return number is
		/*
		IMPORTANT:  The prime part controls the value of
		the nsn column in amd_spare_parts. Whenever the value
		of the amd_spare_parts nsn column changes for a prime part, the
		following will happen:
				1.	Update the nsn column of amd_national_stock_items.
				2.	Using the amd_nsi_parts linked via nsi_sid update the
					nsn column of amd_spare_parts with the new value -
					i.e. update the prime part and its equivalent parts.
		*/
			result number := SUCCESS;

			function UpdtNsnOfNationalStockItems(
							pNsiSid number) return number is
			begin
				debugMsg('updtNsnOfNationalStockItems('||pNsn||','||pNsiSid||')');
				update amd_national_stock_items set 
					nsn = pNsn
				where nsi_sid = pNsiSid;
				return SUCCESS;
			exception when others then
				return UpdateRow.ErrorMsg('amd_national_stock_items',
					amd_spare_parts_pkg.CANNOT_UPDT_NSN_NAT_STCK_ITEMS);
			end UpdtNsnOfNationalStockItems;

		begin -- UpdateNsnForPrimePart

			if result = SUCCESS then
				result := UpdtNsnOfNationalStockItems(nsiSid);
			end if;

			if result = SUCCESS then
				result := MakeNsnSameForAllParts(pNsi_sid => nsiSid,
					   	  						   pNsn => pNsn);
			end if;
			return result;
		exception when others then
			return UpdateRow.ErrorMsg('UpdateNsnForPrimePart',
				amd_spare_parts_pkg.UPDT_NSN_PRIME_ERR);
		end UpdateNsnForPrimePart;


		function UpdatePrimeInd return number is
			result number := SUCCESS;

			function UnassignPrimePart(
							pPart_no in amd_nsi_parts.part_no%type) return number is
			begin
				debugMsg('unassignPrimePart()');

				update amd_nsi_parts set 
					unassignment_date = sysdate
				where 
					part_no = pPart_no
					and (prime_ind             = amd_defaults.PRIME_PART 
							or prime_ind_cleaned = amd_defaults.PRIME_PART)
					and unassignment_date is null;

				return SUCCESS;
			end UnassignPrimePart;

			function MakeCurrentPrimeIntoEquiv return number is
				result   number := SUCCESS;
				part_no  amd_nsi_parts.part_no%type := null;
			begin
				begin
					-- get the current Prime Part
					select part_no
					into part_no
					from amd_nsi_parts
					where nsi_sid = nsiSid
					and (prime_ind = amd_defaults.PRIME_PART 
						or prime_ind_cleaned = amd_defaults.PRIME_PART)
					and unassignment_date is null;
				exception
					when no_data_found then
						/* This can occur when a prime has alreay become an 
							equivalent part, before the NEW prime is processed.
							*/
						return SUCCESS;
					when others then
						return UpdateRow.ErrorMsg('GetCurrentPrimePart',
							amd_spare_parts_pkg.UNABLE_TO_GET_PRIME_PART);
				end GetCurrentPrimePart;

				result := UnassignPrimePart(pPart_no => part_no);

				if result = SUCCESS then
					 result := insertNsiParts(pNsi_sid => nsiSid,
								pPart_no => part_no,
							   pPrime_ind => amd_defaults.NOT_PRIME_PART,
							   pPrime_ind_cleaned => null,
							   pBadRc =>amd_spare_parts_pkg.ASSIGN_PRIME_TO_EQUIV_ERR);
				end if;

				return result;

			end MakeCurrentPrimeIntoEquiv;


			function UpdatePrimePartNo return number is
				temp_prime_part_no amd_national_stock_items.prime_part_no%type := null;
			begin
				begin
				    -- check if the prime part has been set yet 
					select part_no 
					into temp_prime_part_no
					from amd_nsi_parts
					where nsi_sid = nsiSid
					and unassignment_date is null
					and (prime_ind = amd_defaults.PRIME_PART or prime_ind_cleaned = amd_defaults.PRIME_PART);
				exception 
					when no_data_found then
				  	   null ; -- OK the prime_part_no has not been set yet 
					when others then
				  	   return UpdateRow.ErrorMsg('UpdatePrimePartNo (1)',
					   		  amd_spare_parts_pkg.UNABLE_TO_GET_PRIME_PART);
				end;
				if temp_prime_part_no != null then
				   begin
					   select prime_part_no 
						into temp_prime_part_no 
					   from amd_national_stock_items
					   where nsi_sid = nsiSid
					   and prime_part_no = temp_prime_part_no;
				   exception 
					   when no_data_found then
							begin
							    /* This should not happen, but just in
								 * case this will gaurantee that the
								 * prime_part_no = part_no in 
								 * amd_nsi_parts with prime_ind = 'Y'
								 */
								update amd_national_stock_items set 
									prime_part_no  = temp_prime_part_no,
									last_update_dt = sysdate,
									action_code    = amd_defaults.UPDATE_ACTION 
								where nsi_sid = nsiSid;
							exception when others then
								return UpdateRow.ErrorMsg('UpdateNationalStockItems',
									amd_spare_parts_pkg.UPDT_NULL_PRIME_COLS_ERR);
							end UpdateNationalStockItems;
					   when others then
					  	   return UpdateRow.ErrorMsg('UpdatePrimePartNo (2)',
						   		  amd_spare_parts_pkg.UNABLE_TO_GET_PRIME_PART);
				   end;
				else
					-- the prime part is null, but it should get
					-- set with subsequent data
					begin
						update amd_national_stock_items set 
							prime_part_no  = temp_prime_part_no,
							last_update_dt = sysdate,
							action_code    = amd_defaults.UPDATE_ACTION 
						where nsi_sid = nsiSid;
					exception when others then
						return UpdateRow.ErrorMsg('UpdateNationalStockItems',
							amd_spare_parts_pkg.UPDT_NULL_PRIME_COLS_ERR2);
					end UpdateNationalStockItems;
				end if ; 
				return SUCCESS;
			end UpdatePrimePartNo;
			
		begin --  UpdatePrimeInd
			debugMsg('updatePrimeInd()');
			if IsPrimePart(pPrime_ind) then 
				result := MakeCurrentPrimeIntoEquiv();
				if result = SUCCESS then

					unassignPart(pPart_no);

					begin
						result := insertNsiParts(pNsi_sid => nsiSid,
							   	      pPart_no => pPart_no,
									  pPrime_ind => pPrime_ind,
									  pPrime_ind_cleaned => null,
									  pBadRc => amd_spare_parts_pkg.ASSIGN_NEW_PRIME_PART_ERR);
					end AssignNewPrimePart;

					begin
						update amd_national_stock_items set 
							prime_part_no = pPart_no,
							nsn           = pNsn
						where nsi_sid = nsiSid;
					exception when others then
						result := UpdateRow.ErrorMsg('UpdateNationalStockItems',
							amd_spare_parts_pkg.UPDT_ERR_NATIONAL_STK_ITEMS);
					end UpdateNationalStockItems;

					if result = SUCCESS then
					    /* added invocation of MakeNsnSameForAllParts to
						 * to fix bug where equiv parts did not have the same
						 * nsn as the prime part.
						 */
						result := MakeNsnSameForAllParts(pNsi_sid => nsiSid,
							   	  									pNsn => pNsn);
					end if;

				end if;

			else
				result := UnassignPrimePart(pPart_no => pPart_no);
				if result = SUCCESS then
					begin
					   result := insertNsiParts(pNsi_sid => nsiSid,
					   		  	    pPart_no => pPart_no,
									pPrime_ind => pPrime_ind,
									pPrime_ind_cleaned => null,
									pBadRc => amd_spare_parts_pkg.ASSIGN_NEW_EQUIV_PART_ERR);
					end AssignNewEquivPart;
					
					result := UpdatePrimePartNo;

				end if;
			end if;

		return result;

		exception when others then
			return UpdateRow.ErrorMsg('amd_nsi_parts',
				amd_spare_parts_pkg.UPD_NSI_PARTS_ERR);
		end UpdatePrimeInd;


		function InsertNewNsn(
							pNsi_sid out amd_nsns.nsi_sid%type) return number is
			result number := SUCCESS;

			/* Get the nsi_sid using the part_no */
			function GetNsiSid return number is
			begin
				pNsi_sid := amd_utils.GetNsiSid(pPart_no => pPart_no);
				return SUCCESS;
			exception 
				when no_data_found then
					 raise;
			    when others then
					pNsi_sid := null;
					return UpdateRow.ErrorMsg('GetNsiSid',
						amd_spare_parts_pkg.GET_NSISID_BY_PART_ERR);
			end GetNsiSid;

		begin -- InsertNewNsn
			result := GetNsiSid();

			if result = SUCCESS then
				result := InsertAmdNsn(pNsi_sid => pNsi_sid,
					   pNsn => pNsn,
					   pNsn_type => pNsn_type);
			end if;
			return result;
		exception 
		    when no_data_found then
			    return CreateNationalStockItem(pNsi_sid => pNsi_sid,
	 			   	  pNsn => pNsn,
		 				  pItem_type => pItem_type,
		 				  pOrder_quantity => pOrder_quantity,
		 				  pPlanner_code => pPlanner_code,
		 				  pSmr_code => pSmr_code,
		 				  pTactical => UpdateRow.tactical,
		 				  pMic_code_lowest => pMic_code_lowest,
						  pNsn_type => pNsn_type);
			
		    when others then
				pNsi_sid := null;
				return UpdateRow.ErrorMsg('GetNsiSid',
					amd_spare_parts_pkg.NEW_NSN_ERROR);
		end InsertNewNsn;


		function GetNsiSid(
							pNsi_sid out amd_nsns.nsi_sid%type) return number is

		begin
			debugMsg('getNsiSid()');
			pNsi_sid := amd_utils.GetNsiSid(pNsn => pNsn);
			return SUCCESS;
		exception
			when no_data_found then
				raise ; -- must be a new nsn

			when others then
				pNsi_sid := null;
				return UpdateRow.ErrorMsg('amd_nsi_parts',
					amd_spare_parts_pkg.NEW_NSN_ERR);
		end GetNsiSid;


		function CheckNsnAndPrimeInd return number is
			result number := SUCCESS;
		begin
			debugMsg('checkNsnAndPrimeInd()');

			-- Nsn Changes should only be considered for Prime Parts
			if NsnChanged(pPart_no,pNsn) and IsPrimePart(pPrime_ind) then
				if PrimeIndChanged() then
					result := UpdatePrimeInd();
					if result = SUCCESS then
						result := UpdateNsnForPrimePart();
					end if;
				else
					result := UpdateNsnForPrimePart();
				end if;

				result := MakeNsnSameForAllParts(nsiSid,pNsn);
			else
				if PrimeIndChanged() then
					result := UpdatePrimeInd();
				end if;
			end if;
			return result;
		exception
			when amd_spare_parts_pkg.CANNOT_FIND_PART then
				return UpdateRow.ErrorMsg('CheckNsnAndPrimeInd',
					amd_spare_parts_pkg.CHK_NSN_AND_PRIME_ERR);
			when others then
				return UpdateRow.ErrorMsg('CheckNsnAndPrimeInd',
					amd_spare_parts_pkg.CHK_NSN_AND_PRIME_ERR2);
		end CheckNsnAndPrimeInd;

	begin -- <<<---- UpdateRow

		debugMsg('updateRow('||pPart_no||','||pPrime_ind||','||pNsn||')');
--		insertLoadDetail(pPart_No,pNsn,pPrime_Ind,'Update');

		-- if part has moved to a different nsn then unassign existing part to
		-- break it's relation to old nsn so it can get associated with a
		-- different sid(new nsn). Also break any current/temp nsn relation of
		-- old nsn(current) with incoming(new) nsn(temp).
		--
		-- "moved" means old nsn and new nsn appear in CAT1 at the same time or
		-- both nsns are already in AMD on different sids, 
		-- therefore, they are no longer related regardless of what amd_nsns says.
		-- that's why the part needs to be unassigned from the old nsn.
		--
		if (hasPartMoved(pPart_no,pNsn)) then
			unassociateTmpNsn(pNsn);
			unassignPart(pPart_no);
		end if;

		-- retrieve the nsi_sid right away, since it will be make
		-- retrieving data from the amd_national_stock_items,
		-- amd_nsns, and amd_nsi_parts easier
		begin
			result := GetNsiSid(pNsi_sid => nsiSid);
			if result != SUCCESS then
				return result;
			end if;
		exception 
			when no_data_found then
				/* This must be a new nsn - add it to amd_nsns
					using part_no to get the current nsi_sid
				*/
				result := InsertNewNsn(pNsi_sid => nsiSid);
				if result != SUCCESS then
					return result;
				end if;
		end;

		/* The nsi_sid should not be null, but just leave this code in
			as a backup parachute!
			*/
		if nsiSid is null then
			return UpdateRow.ErrorMsg('GetNsiSid',
				amd_spare_parts_pkg.CANNOT_GET_NSI_SID);
		end if;

		if result = SUCCESS then
			result := CheckNsnAndPrimeInd();
		end if;

		if result = SUCCESS then
			result := PrepareDataForUpdate();
		end if;

		if result = SUCCESS then
			result := UpdateAmdSparePartRow(pPart_no,pNsn);
		end if;

		if result = SUCCESS then
			result := UpdtNsiPrimePartData (pPrime_ind => pPrime_ind,
 					  pNsi_sid => nsiSid,
 					  pPartNo => pPart_no,
 					  pNsn => pNsn,
					  pItem_type => pItem_type,
					  pOrder_quantity => pOrder_quantity,
					  pPlannerCode => pPlanner_code,
					  pSmr_code => pSmr_code,
					  pMic_code_lowest => pMic_code_lowest,
					  pAction_code => amd_defaults.UPDATE_ACTION,
					  pReturn_code => amd_spare_parts_pkg.UPDATE_NATSTK_ERR);
		end if ;
		if result = SUCCESS then
			result := amd_spare_parts_pkg.UpdateAmdNsn(
				   pNsn_type => pNsn_type,
				   pNsi_sid => nsiSid,
				   pNsn => pNsn);
		end if;

		if result = SUCCESS then
			if pNsn is not null then
				result:= UpdateNatStkItem(pNsn,amd_defaults.UPDATE_ACTION,pPart_no);
			end if;
		end if;

		if result != SUCCESS then
			rollback ;  /* this is probably overkill since
							the ErrorMsg function does a rollback,
							but it is always a good idea to have a
							backup parachute
							*/
		end if;

		-- Update amd_national_stock_items.action_code = 'D' for any other
		-- nsi_sid this part came off of that has no parts assigned to it.
		-- An nsi_sid w/o assigned parts is a "deleted" nsi_sid.
		--
		update amd_national_stock_items set
			action_code    = 'D',
			last_update_dt = sysdate
		where 
			action_code != 'D'
			and nsi_sid in 
				(select nsi_sid
				from amd_nsi_parts
				where part_no = pPart_no
					and nsi_sid != nsiSid
				minus
				select nsi_sid
				from amd_nsi_parts
				where 
					nsi_sid in
						(select nsi_sid from amd_nsi_parts
						where part_no = pPart_no)
					and unassignment_date is null);

		return result;
	exception 
		when others then
			return UpdateRow.ErrorMsg('UpdateRow',
					amd_spare_parts_pkg.UPDATE_ERR);
	end UpdateRow;


	function DeleteRow(
							pPart_no in varchar2,
							pMfgr in varchar2 ) return number is

		nsn amd_spare_parts.nsn%type := null;

		/* Put a wrapper on the amd_utils.InsertErrorMsg procedure, so it is
			more specific to the DeleteRow function.  Output gets stored
			into amd_load_details and amd_load_status.
		*/
		function ErrorMsg(
							pTableName in varchar2, 
							rc in number) return number is
		begin
			 return amd_spare_parts_pkg.ErrorMsg(
			 									pSourceName => 'UpdateRow',
												pTableName => pTableName,
												pError_location => 140,
												pPart_no => pPart_no,
												pReturn_code => rc);
		end ErrorMsg;

		function GetNsn return amd_spare_parts.nsn%type is
			nsn amd_spare_parts.nsn%type := null;
		begin
			select nsn 
			into nsn
			from amd_spare_parts
			where part_no = pPart_no;
			return nsn;
		end GetNsn;

	begin
--		insertLoadDetail(pPart_No,'nsn','pPrimeInd','Delete');

		nsn := GetNsn();

		-- nsn is NULLed to facilitate temp nsns turning into current nsns. When a
		-- temp nsn becomes current the nsn/nsi_sid association needs to be broken
		-- and this helps facilitate that when it may happen at a later time.
		--
		update amd_spare_parts set 
			action_code    = amd_defaults.DELETE_ACTION,
			nsn            = NULL,
			last_update_dt = sysdate
		where part_no = pPart_no;

		unassignPart(pPart_no);

		if nsn is not null then
			return UpdateNatStkItem(nsn, amd_defaults.DELETE_ACTION);
		else
			return SUCCESS;
		end if;

	end;
end amd_spare_parts_pkg;
/
