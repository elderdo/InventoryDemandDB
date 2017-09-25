CREATE OR REPLACE package amd_utils as
/*
	--
	-- SCCSID: %M%  %I%  Modified: %G% %U%
	--
	-- Date     By     History
	-- -------- -----  ---------------------------------------------------
	-- 10/14/01 FF     Initial implementation
	-- 10/17/01 DSE		Added GetNsiSid functions
	-- 10/24/01 ks		added GetLocSid
	-- 10/28/01 ks		added GetLocType, GetLocId
	-- 10/30/01 dse		added a variation of InsertErrorMsg with all
						the fields for amd_load_details
*/

	function GetLoadNo(
							pSourceName varchar2,
							pTableName varchar2) return number;
	function FormatNsn(
							pNsn varchar2,
							pType varchar2 default 'AMD') return varchar2;
	procedure InsertErrorMsg(
							pLoadNo number,
							pK1 varchar2,
							pK2 varchar2,
							pK3 varchar2,
							pK4 varchar2,
							pK5 varchar2,
							pMsg varchar2);

	procedure InsertErrorMsg (
							pLoad_no in amd_load_details.load_no%type,
							pData_line_no in amd_load_details.data_line_no%type,
							pData_line in amd_load_details.data_line%type,
							pKey_1 in amd_load_details.key_1%type,
							pKey_2 in amd_load_details.key_2%type,
							pKey_3 in amd_load_details.key_3%type,
							pKey_4 in amd_load_details.key_4%type,
							pKey_5 in amd_load_details.key_5%type,
							pComments in amd_load_details.comments%type ) ;

	-- source is amd_nsns
	function GetNsiSid(pNsn in amd_nsns.nsn%type) return amd_nsns.nsi_sid%type ;


	-- source is amd_nsi_parts
	function GetNsiSid(pPart_no in amd_nsi_parts.part_no%type) return amd_nsi_parts.nsi_sid%type ;

	function GetLocSid(pLocId amd_spare_networks.loc_id%type) return amd_spare_networks.loc_sid%type;
	function GetLocType(pLocSid amd_spare_networks.loc_sid%type) return amd_spare_networks.loc_type%type;
	function GetLocId(pLocSid amd_spare_networks.loc_sid%type) return amd_spare_networks.loc_id%type;
end amd_utils;
/
CREATE OR REPLACE package body amd_utils as
	function GetLoadNo(
							pSourceName varchar2,
							pTableName varchar2) return number is
		loadNo   number;
	begin
		select
			amd_load_status_seq.nextval
		into loadNo
		from dual;
		insert into amd_load_status
		(
			load_no,
			source,
			load_date,
			table_name
		)
		values
		(
			loadNo,
			pSourceName,
			sysdate,
			pTableName
		);
		return loadNo;
	end GetLoadNo;
	function FormatNsn(
							pNsn varchar2,
							pType varchar2 default 'AMD') return varchar2 is
		RetVal	varchar2(50);
	begin
		--
		-- AMD uses NSN w/o dashes. GOLD uses NSN w/dashes.
		--
		if (pType = 'AMD') then
			RetVal := replace(pNsn,'-');
		else
			RetVal := substr(pNsn,1,4)||'-'||substr(pNsn,5,2)||'-'||
							substr(pNsn,7,3)||'-'||substr(pNsn,10,4);
		end if;
		return RetVal;
	end;
	procedure InsertErrorMsg (
							pLoadNo number,
							pK1 varchar2,
							pK2 varchar2,
							pK3 varchar2,
							pK4 varchar2,
							pK5 varchar2,
							pMsg varchar2 ) is
	begin
		insert into amd_load_details
		(
			load_no,
			key_1,
			key_2,
			key_3,
			key_4,
			key_5,
			comments
		)
		values
		(
			pLoadNo,
			pK1,
			pK2,
			pK3,
			pK4,
			pK5,
			pMsg
		);
	end InsertErrorMsg;

	procedure InsertErrorMsg (
							pLoad_no in amd_load_details.load_no%type,
							pData_line_no in amd_load_details.data_line_no%type,
							pData_line in amd_load_details.data_line%type,
							pKey_1 in amd_load_details.key_1%type,
							pKey_2 in amd_load_details.key_2%type,
							pKey_3 in amd_load_details.key_3%type,
							pKey_4 in amd_load_details.key_4%type,
							pKey_5 in amd_load_details.key_5%type,
							pComments in amd_load_details.comments%type ) is
	begin
		insert into amd_load_details
		(
			load_no,
			data_line_no,
			data_line,
			key_1,
			key_2,
			key_3,
			key_4,
			key_5,
			comments
		)
		values
		(
			pLoad_no,
			pData_line_no,
			pData_line,
			pKey_1,
			pKey_2,
			pKey_3,
			pKey_4,
			pKey_5,
			pComments
		);
	end InsertErrorMsg;

	function GetNsiSid(pNsn in amd_nsns.nsn%type) return amd_nsns.nsi_sid%type is
		nsi_sid amd_nsns.nsi_sid%type := null ;
	begin
		select nsi_sid into nsi_sid
		from amd_nsns
		where nsn = pNsn ;
		return nsi_sid ;
	end GetNsiSid ;

	function GetNsiSid(pPart_no in amd_nsi_parts.part_no%type) return amd_nsi_parts.nsi_sid%type is
		nsi_sid amd_nsi_parts.nsi_sid%type := null ;
	begin
		select nsi_sid into nsi_sid
		from amd_nsi_parts
		where part_no = pPart_no
		and unassignment_date is null ;
		return nsi_sid ;
	end GetNsiSid ;

	function GetLocSid(pLocId amd_spare_networks.loc_id%type) return amd_spare_networks.loc_sid%type is
		locSid amd_spare_networks.loc_sid%type := null;
		-- locId amd_spare_networks.loc_id%type := null;
	begin
		 /* may not always be applicable, moved to amd_from_bssm_pkg
		 if (pLocId = amd_from_bssm_pkg.BSSM_WAREHOUSE_SRAN) then
	    	   locId := amd_from_bssm_pkg.AMD_WAREHOUSE_LOCID;
		 else
		 	   locId := pLocId;
		 end if;
		 */
		 select loc_sid
		 into locSid
		 from amd_spare_networks
		 where loc_id = pLocId;
		 return locSid;
	exception
		 when no_data_found then
		 	  return null;
	end GetLocSid;

	function GetLocType(pLocSid amd_spare_networks.loc_sid%type) return amd_spare_networks.loc_type%type is
		locType amd_spare_networks.loc_type%type := null;
	begin
		 select loc_type
		 into locType
		 from amd_spare_networks
		 where loc_sid = pLocSid;
		 return locType;
	exception
		 when no_data_found then
		 	  return null;
	end GetLocType;

	function GetLocId(pLocSid amd_spare_networks.loc_sid%type) return amd_spare_networks.loc_id%type is
		locId amd_spare_networks.loc_id%type := null;
	begin
		 select loc_id
		 into locId
		 from amd_spare_networks
		 where loc_sid = pLocSid;
		 return locid;
	exception
		 when no_data_found then
		 	  return null;
	end GetLocId;

end amd_utils;
/

