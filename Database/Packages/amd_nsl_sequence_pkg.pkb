CREATE OR REPLACE package body AMD_OWNER.amd_nsl_sequence_pkg as
/*
      $Author:   zf297a  $
    $Revision:   1.13  $
     $Date:   16 Oct 2007 11:24:38  $
    $Workfile:   amd_nsl_sequence_pkg.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_nsl_sequence_pkg.pkb-arc  $
   
      Rev 1.13   16 Oct 2007 11:24:38   zf297a
   Fixed writeMsg literal
   
      Rev 1.13   16 Oct 2007 11:21:50   zf297a
   Fixed literals in writeMsg
   
      Rev 1.12   16 Oct 2007 10:08:40   zf297a
   Fixed writeMsg in version procedure
   
      Rev 1.11   16 Oct 2007 10:05:52   zf297a
   implemented version interface
   
      Rev 1.10   25 Aug 2007 21:54:52   zf297a
   Added hint to sql statement in function getNslFromAmd to make sure Oracle uses the correct index in its execution plan.  This nested function's parent function, sequenceThsNsl, is invoked by amd_load.loadGold.
   
      Rev 1.9   Dec 01 2005 09:36:48   zf297a
   added pvcs keywords
*/
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
			RAW_DATA constant bssm_parts.lock_sid%type := '0';
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
			select /*+ INDEX(an amd_nsns_nk01) */

				an.nsn
			into nsn
			from
				amd_nsns an,
				amd_nsi_parts anp
			where
				anp.part_no      = pPart_no
				and anp.nsi_sid  = an.nsi_sid
				and anp.unassignment_date is null
				and an.nsn_type = 'C'
				and an.nsn like 'NSL%';

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

    procedure writeMsg( -- added 10/16/2007 by dse
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
                pSourceName => 'amd_nsl_sequence_pkg',    
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
                substr('amd_nsl_sequence_pkg ' 
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
    
    procedure version IS -- added 10/16/2007 by dse
    begin
        writeMsg(pTableName => 'amd_nsl_sequence_pkg', 
             pError_location => 10, pKey1 => 'amd_nsl_sequence_pkg', pKey2 => '$Revision:   1.13  $') ;
        dbms_output.put_line('amd_nsl_sequence_pkg: $Revision:   1.13  $') ;
    end version ;


end amd_nsl_sequence_pkg ;
/
