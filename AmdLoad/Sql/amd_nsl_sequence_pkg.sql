CREATE OR REPLACE package amd_nsl_sequence_pkg as
   --
   -- SCCSID: amd_nsl_sequence_pkg.sql  1.4  Modified: 12/18/01 11:08:07
   --
	/*
		Purpose: Use the following function to sequence
		an NSL.
		Douglas S. Elder	10/14/01	Initial Implementation
		Fernando Fajardo  11/27/01 Added GetNslFromAmd() and 
		                           mod to GetNslFromBssm().
		Fernando Fajardo  11/29/01 Fixed GetNslFromAmd().
		Fernando Fajardo  12/18/01 Added distinct keyword to 'select' statement.
	*/
	function SequenceTheNSL(pPart_no in amd_spare_parts.part_no%type) return amd_spare_parts.nsn%type ;

end amd_nsl_sequence_pkg ;
/

CREATE OR REPLACE package body amd_nsl_sequence_pkg as
	/*
		Purpose: Use the following function to sequence
		an NSL.
		Douglas S. Elder	10/14/01	Initial Implementation
	*/
	function SequenceTheNSL(pPart_no in amd_spare_parts.part_no%type) return amd_spare_parts.nsn%type is

		nsn amd_spare_parts.nsn%type := null ;

		function UseBssmNsls return boolean is
		begin
			if upper(amd_defaults.USE_BSSM_TO_GET_NSLs) = 'Y' then
				return true ;
			else
				return false ;
			end if ;
		exception when NO_DATA_FOUND then
			return false ;
		end UseBssmNsls ;

		function GetNslFromBssm(pPart_no in amd_spare_parts.part_no%type) return amd_spare_parts.nsn%type is
			nsn amd_spare_parts.nsn%type := null ;
			RAW_DATA constant number := 0 ;
		begin
			select distinct
				parts.nsn into nsn
			from bssm_parts parts
			where 
				parts.part_no      = pPart_no
				and parts.lock_sid = RAW_DATA 
				and nsn like 'NSL#%';

			return nsn ;
		exception when NO_DATA_FOUND then
			return null ;
		end GetNslFromBssm;

		function GetNslFromAmd(
							pPart_no in amd_spare_parts.part_no%type) return amd_spare_parts.nsn%type is
			nsn amd_spare_parts.nsn%type := null ;
		begin
			select distinct
				an.nsn
			into nsn
			from 
				amd_nsns an,
				amd_national_stock_items ansi,
				amd_nsi_parts anp
			where 
				anp.part_no      = pPart_no
				and anp.nsi_sid  = ansi.nsi_sid
				and ansi.nsi_sid = an.nsi_sid
				and an.nsn like 'NSL$%';

			return nsn;
		exception
			when NO_DATA_FOUND then
				return null ;
		end GetNslFromAmd;

	begin
		if UseBssmNsls() then
			nsn := GetNslFromBssm(pPart_no) ;
		end if;

		if (nsn is null) then
			nsn := GetNslFromAmd(pPart_no);
		end if;

		if nsn is null then
			-- BSSM and AMD have not assigned an NSL sequence
			-- number for this part, so AMD will generate
			-- one.
			declare
				nsn_seq_no number := 0 ;
			begin
				select amd_nsn_seq_no.nextval into nsn_seq_no from dual;
				nsn := 'NSL$' || lpad(nsn_seq_no,7,'0') ;
			end ;
		end if ;

		return nsn ;

	end SequenceTheNsl ;

end amd_nsl_sequence_pkg ;
/
