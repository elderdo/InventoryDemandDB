CREATE OR REPLACE package amd_test_data as

	/* Cleans out amd_spare_parts and all related tables
		so they are ready for an initial load.
	*/
	function DeleteAmdSpareParts return boolean ;

	/* Cleans out specific amd_spare_parts and all related tables
		so they are ready for an initial load.
	*/
	function DeleteAmdSparePart(pNsi_sid in amd_national_stock_items.nsi_sid%type) return boolean ;

	/* Cleans out the amd_param_changes and amd_params
		table
	*/
	function DeleteParameters return boolean ;

	/* Loads the amd_params and amd_param_changes with some
		initial values.
	*/
	function CreateParameters return boolean ;

	/* Tests InsertRow and UpdateRow of the
		amd_spare_parts_pkg.
	*/
	function test_amd_spare_parts_pkg return boolean ;

	/* This procedure is necessary, since some back to back
		tests could cause a dup key to be produced, when part
		of the key uses the System Data - sysdate.
	*/
	procedure sleep(secs in number) ;
	/* A Pl/SQL specific version of a Diff function
		for amd_spare_parts
		*/
	function Diff return number ;
	function PrimeCheckForTmpAmdSpareParts return boolean ;
	function PrimeCheckForAmdNsiParts return boolean ;


	function TestDefaults return boolean ;

	function TestGetNsiSid return boolean ;

end amd_test_data ;
/
CREATE OR REPLACE package body amd_test_data as
	subtype data_source  is number  ;

	NSI_PARTS		constant data_source := 1 ;
	TMP_SPARE_PARTS constant data_source := 2 ;


	function DeleteParameters return boolean is
	begin
		begin
			delete from amd_param_changes ;
		exception when others then
			null ; -- ignore
		end ;
		delete from amd_params ;
		commit ;
		return true ;
	end DeleteParameters ;
	function CreateParameters return boolean is

		init_error exception ;

		procedure InsertAmdParam(pParam_key in amd_params.param_key%type,
			pParam_description in amd_params.param_description%type,
			pParam_value in amd_param_changes.param_value%type,
			pUser_id in amd_param_changes.user_id%type default 'c970183')  is
			procedure ErrorMsg(pTableName in varchar2, pMsg in varchar2) is
			begin
				rollback ;
				amd_utils.InsertErrorMsg(
					amd_utils.GetLoadNo(pSourceName => 'amd_test_data', pTableName => pTableName),
					pParam_key, pParam_description, pParam_value, pUser_id, null, pMsg);
				commit ;
			end ErrorMsg ;

		begin
			begin
				insert into amd_params
				(param_key, param_description)
				values (pParam_key, pParam_description) ;
			exception when others then
				ErrorMsg('amd_params', 'Could not insert') ;
				raise init_error ;
			end ;

			begin
				insert into amd_param_changes
				(param_key, effective_date, param_value, user_id)
				values (pParam_key, sysdate, pParam_value, pUser_id) ;
			exception when others then
				ErrorMsg('amd_param_changes', 'Could not insert') ;
				raise init_error ;
			end ;
		end ;
	begin
		InsertAmdParam(pParam_key => 'use_bssm_to_get_nsls',
			pParam_description => 'The amd_spare_parts_pkg uses this. If the value is Y it will retrieve NSN''s with keys like NSL#nnnnnn from the BSSM tables, when the value gets set to N it will generate its own sequence number for NSL''s.',
			pParam_value => 'Y') ;
		InsertAmdParam(pParam_key => 'consumable_reduction_factor',
			pParam_description => 'The amd_defaults package uses this.  It is applied to the gfp_price returned from FEDC when the item is QuasiRepairable (smr6=P) or Consumable (smr6=N).',
			pParam_value => '0.60') ;
		InsertAmdParam(pParam_key => 'engine_part_reduction_factor',
			pParam_description => 'The amd_defaults package uses this.  It is applied to the gfp_price returned from FEDC when the item is an Engine Part (planner_code = PSA or PSB).',
			pParam_value => '0.92') ;
		InsertAmdParam(pParam_key => 'non_engine_part_reductn_factor',
			pParam_description => 'The amd_defaults package uses this.  It is applied to the gfp_price returned from FEDC when the item is a Non-Engine Part (planner_code is not = PSA and planner_code is not = PSB).',
			pParam_value => '0.79') ;
		InsertAmdParam(pParam_key => 'order_lead_time_consumable',
			pParam_description => 'This is used by the amd_defaults package, which is used by amd_spare_parts_pkg.',
			pParam_value => '270') ;
		InsertAmdParam(pParam_key => 'order_lead_time_repairable',
			pParam_description => 'This is used by the amd_defaults package, which is used by amd_spare_parts_pkg.',
			pParam_value => '540') ;
		InsertAmdParam(pParam_key => 'order_quantity',
			pParam_description => 'This is used by the amd_defaults package, which is used by the amd_spare_parts_pkg.',
			pParam_value => '1') ;
		InsertAmdParam(pParam_key => 'order_uom',
			pParam_description => 'This is used by the amd_defaults package, which is used by the amd_spare_parts_pkg.',
			pParam_value => 'PC') ;
		InsertAmdParam(pParam_key => 'shelf_life',
			pParam_description => 'This is used by the amd_defaults package, which is used by the amd_spare_parts_pkg.',
			pParam_value => '999998') ;
		InsertAmdParam(pParam_key => 'condemn_avg',
			pParam_description => 'todo - needs to be set to a valid value.',
			pParam_value => '0') ;
		InsertAmdParam(pParam_key => 'distrib_uom',
			pParam_description => 'todo - needs to be set to a valid value.',
			pParam_value => '0') ;
		InsertAmdParam(pParam_key => 'nrts_avg',
			pParam_description => 'todo - needs to be set to a valid value.',
			pParam_value => '0') ;
		InsertAmdParam(pParam_key => 'disposal_cost',
			pParam_description => 'todo - needs to be set to a valid value.',
			pParam_value => '0') ;
		InsertAmdParam(pParam_key => 'off_base_turn_around',
			pParam_description => 'todo - needs to be set to a valid value.',
			pParam_value => '0') ;
		InsertAmdParam(pParam_key => 'qpei_weighted',
			pParam_description => 'todo - needs to be set to a valid value.',
			pParam_value => '0') ;
		InsertAmdParam(pParam_key => 'rts_avg',
			pParam_description => 'todo - needs to be set to a valid value.',
			pParam_value => '0') ;
		InsertAmdParam(pParam_key => 'scrap_value',
			pParam_description => 'todo - needs to be set to a valid value.',
			pParam_value => '0') ;
		InsertAmdParam(pParam_key => 'time_to_repair_on_base_avg',
			pParam_description => 'todo - needs to be set to a valid value.',
			pParam_value => '0') ;
		InsertAmdParam(pParam_key => 'unit_volume',
			pParam_description => 'todo - needs to be set to a valid value.',
			pParam_value => '0') ;
		commit ;
		return true ;
	exception when init_error then
		return false ;
	end ;

	function TestInsertNewPrimePart return boolean is
		RetVal1 number ;
	begin
		RetVal1 := AMD_OWNER.AMD_SPARE_PARTS_PKG.INSERTROW ( '17P1A7006-502', '88277', NULL, NULL, NULL,  'F77', 'Test the insertion of a new Prime Part', NULL, NULL, NULL, 'Y', NULL, NULL, NULL, NULL, 191.809780092593, '1560013353279', 'C', 'R', 'PAODDT', 'AFA' );
		commit ;
		dbms_output.put_line('RetVal1 = ' || RetVal1) ;
		if RetVal1 = amd_spare_parts_pkg.SUCCESS then
			return true ;
		else
			return false ;
		end if ;
	end TestInsertNewPrimePart ;

	function TestUpdEquivToPrime return boolean is
		RetVal2 number ;
	begin
		RetVal2 := AMD_OWNER.AMD_SPARE_PARTS_PKG.UPDATEROW ( '17P1A7006-501', '88277', NULL, NULL, NULL,  'F77', 'Test Change from Equiv to Prime', NULL, NULL, NULL, 'Y', NULL, NULL, NULL, NULL, 191.809780092593, '1560013353279', 'C', 'R', 'PAODDT', 'AFA' );
		commit ;
		dbms_output.put_line('RetVal2 = ' || RetVal2) ;
		if RetVal2 = amd_spare_parts_pkg.SUCCESS then
			return true ;
		else
			return false ;
		end if ;
	end TestUpdEquivToPrime ;

	procedure sleep(secs in number) is
		ss varchar2(2) ;
	begin
		ss := to_char(sysdate,'ss') ;
		while to_number(ss) + secs > to_number(to_char(sysdate,'ss'))
		loop
			null ;
		end loop ;
	end ;
	function test_amd_spare_parts_pkg return boolean is
		result boolean ;
		RetVal2 number ;
	begin
		if TestInsertNewPrimePart() then
			dbms_output.put_line('TestInsertNewPrimePart OK') ;
			-- must sleep for a couple of sec's otherwise
			-- the generated key with the timestamp
			-- might match a previous one - this acutally
			-- happened that is why I, DSE, put this here
			sleep(5) ;
			if TestUpdEquivToPrime() then
				dbms_output.put_line('TestUpdEquivToPrime OK') ;
			else
				return false ;
			end if ;
		else
			return false ;
		end if ;
		return true ;
	end test_amd_spare_parts_pkg ;

	function DeleteAmdSparePart(pNsi_sid in amd_national_stock_items.nsi_sid%type) return boolean is
	begin
		begin
			delete from amd_demands where nsi_sid = pNsi_sid ;
		exception
			when no_data_found then
				null ; -- do nothing
			when others then
				dbms_output.put_line('amd_demands: sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm) ;
				return false ;
		end ;

		begin
			delete from amd_maint_task_distribs where nsi_sid = pNsi_sid ;
		exception
			when no_data_found then
				null ; -- do nothing
			when others then
				dbms_output.put_line('amd_maint_task_distribs: sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm) ;
				return false ;
		end ;

		begin
			delete from amd_part_locs where nsi_sid = pNsi_sid ;
		exception
			when no_data_found then
				null ; -- do nothing
			when others then
				dbms_output.put_line('amd_part_locs: sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm) ;
				return false ;
		end ;

		begin
			delete from amd_national_stock_items where nsi_sid = pNsi_sid ;
		exception
			when no_data_found then
				null ; -- do nothing
			when others then
				dbms_output.put_line('amd_national_stock_items: sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm) ;
				return false ;
		end ;

		begin
			delete from amd_on_hand_invs
			where part_no in
				(select part_no from amd_spare_parts
				 where nsn in
				 (select nsn from amd_nsns
				 where nsi_sid = pNsi_sid)) ;
		exception
			when no_data_found then
				null ; -- do nothing
			when others then
				dbms_output.put_line('amd_spare_invs: sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm) ;
				return false ;
		end ;

		begin
			delete from amd_in_repair
			where part_no in
				(select part_no from amd_spare_parts
				 where nsn in
				 (select nsn from amd_nsns
				 where nsi_sid = pNsi_sid)) ;
		exception
			when no_data_found then
				null ; -- do nothing
			when others then
				dbms_output.put_line('amd_spare_invs: sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm) ;
				return false ;
		end ;

		begin
			delete from amd_on_order
			where part_no in
				(select part_no from amd_spare_parts
				 where nsn in
				 (select nsn from amd_nsns
				 where nsi_sid = pNsi_sid)) ;
		exception
			when no_data_found then
				null ; -- do nothing
			when others then
				dbms_output.put_line('amd_spare_invs: sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm) ;
				return false ;
		end ;

		begin
			delete from amd_spare_parts where nsn in (select nsn from amd_nsns where nsi_sid = pNsi_sid) ;
		exception
			when no_data_found then
				null ; -- do nothing
			when others then
				dbms_output.put_line('amd_spare_parts: sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm) ;
				return false ;
		end ;

		begin
			delete amd_nsns where nsi_sid = pNsi_sid ;
		exception
			when no_data_found then
				null ; -- do nothing
			when others then
				dbms_output.put_line('amd_nsns: sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm) ;
				return false ;
		end ;

		commit ;

		return true ;
	end DeleteAmdSparePart ;

	function DeleteAmdSpareParts return boolean is
	begin
		delete from amd_demands ;
		delete from amd_maint_task_distribs ;
		delete from amd_part_locs ;
		delete from amd_national_stock_items ;
		delete from amd_on_hand_invs ;
		delete from amd_in_repair ;
		delete from amd_on_order ;
		delete from amd_spare_parts ;
		delete from amd_nsns ;
		delete from amd_nsi_parts ;
		commit ;
		return true ;
	exception when others then
		dbms_output.put_line('SQLCODE = ' || sqlcode || ' SQLERRM = ' || sqlerrm ) ;
		return false ;
	end DeleteAmdSpareParts ;

	/* This function can be used in place of the Java diff routine.
	  However, it is less generic tham the Java diff routine, but
	  it could be adapted to other data that require this functionality.
	  */
	function Diff return number is

		/* Return codes */
		SUCCESS						constant number := 0 ;
		FAILURE						constant number := 4 ;
		CANNOT_GET_NSI_SID			constant number := 8 ;
		CANNOT_GET_ITEM_DATA		constant number := 12 ;
		CANNOT_GET_NSI_PARTS_DATA	constant number := 16 ;
		GET_PART_DATA_ERROR			constant number := 20 ;
		GET_CURRENT_DATA_ERROR		constant number := 24 ;
		CURRENT_DATA_NOT_FOUND		constant number := 30 ;

		rows_read					number := 0 ;
		rows_inserted				number := 0 ;
		rows_updated				number := 0 ;
		rows_deleted				number := 0 ;

		cursor newData is
			select *
			from tmp_amd_spare_parts
			order by nsn asc, prime_ind desc ;

		oldParts	amd_spare_parts%rowtype := null ;

		result 			number := null ;
		nsi_sid			amd_national_stock_items.nsi_sid%type := null ;
		nsn_type		amd_nsns.nsn_type%type := null ;
		item_type 		amd_national_stock_items.item_type%type := null ;
		order_quantity 	amd_national_stock_items.order_quantity%type := null ;
		planner_code 	amd_national_stock_items.planner_code%type := null ;
		smr_code 		amd_national_stock_items.planner_code%type := null ;
		prime_ind		amd_nsi_parts.prime_ind%type := null ;

		function ErrorMsg(pMsg in varchar2, pTableName in varchar2, pData_line_no in amd_load_details.data_line_no%type, pPart_no in amd_spare_parts.part_no%type, pMfgr in amd_spare_parts.mfgr%type, pNsn in amd_spare_parts.nsn%type, pReturnCode in number) return number is
		begin
			rollback ;
			dbms_output.put_line(pMsg) ;
			dbms_output.put_line('TableName=' || pTableName) ;
			dbms_output.put_line('Data_line_no=' || pData_line_no) ;
			dbms_output.put_line('part_no=' || pPart_no || ' mfgr=' || pMfgr || ' nsn=' || pNsn || ' ReturnCode=' || pReturnCode) ;
			amd_utils.InsertErrorMsg (
				pLoad_no => amd_utils.GetLoadNo(pSourceName => 'Diff', pTableName => pTableName),
				pData_line_no => pData_line_no,
				pData_line => 'amd_test_data',
				pKey_1 => pPart_no,
				pKey_2 => pMfgr,
				pKey_3 => pNsn,
				pKey_4 => pReturnCode,
				pKey_5 => sysdate,
				pComments => pMsg) ;
			commit ;
			return  pReturnCode ;
		end ;

		function InsertRow(newRec in tmp_amd_spare_parts%rowtype) return number is
		begin
			return amd_spare_parts_pkg.InsertRow(newRec.part_no,
				newRec.mfgr,
				newRec.date_icp,
				newRec.disposal_cost,
				newRec.erc,
				newRec.icp_ind,
				newRec.nomenclature,
				newRec.order_lead_time,
				newRec.order_quantity,
				newRec.order_uom,
				newRec.prime_ind,
				newRec.scrap_value,
				newRec.serial_flag,
				newRec.shelf_life,
				newRec.unit_cost,
				newRec.unit_volume,
				newRec.nsn,
				newRec.nsn_type,
				newRec.item_type,
				newRec.smr_code,
				newRec.planner_code) ;
		end InsertRow ;

		function UpdateRow(newRec in tmp_amd_spare_parts%rowtype) return number is
		begin
			return amd_spare_parts_pkg.UpdateRow
             	(newRec.part_no,
                newRec.mfgr,
                newRec.date_icp,
                newRec.disposal_cost,
                newRec.erc,
                newRec.icp_ind,
                newRec.nomenclature,
                newRec.order_lead_time,
				newRec.order_quantity,
                newRec.order_uom,
				newRec.prime_ind,
                newRec.scrap_value,
                newRec.serial_flag,
                newRec.shelf_life,
                newRec.unit_cost,
                newRec.unit_volume,
                newRec.nsn,
				newRec.nsn_type,
                newRec.item_type,
                newRec.smr_code,
                newRec.planner_code) ;
		end UpdateRow ;

		function IsDifferent(pOldParts in amd_spare_parts%rowtype,
			pItem_type in amd_national_stock_items.item_type%type,
			pOrder_quantity in amd_national_stock_items.order_quantity%type,
			pPlanner_code in amd_national_stock_items.planner_code%type,
			pSmr_code in amd_national_stock_items.smr_code%type,
			pNsn_type in amd_nsns.nsn_type%type,
			pPrime_ind in amd_nsi_parts.prime_ind%type,
			pNewRec in tmp_amd_spare_parts%rowtype) return boolean is
			result boolean := false ;
		begin
                result := (pNewRec.date_icp = pOldParts.date_icp) ;
                result := (result and (pNewRec.disposal_cost = pOldParts.disposal_cost)) ;
                result := (result and (pNewRec.erc = pOldParts.erc)) ;
                result := (result and (pNewRec.icp_ind = pOldParts.icp_ind)) ;
                result := (result and (pNewRec.nomenclature = pOldParts.nomenclature)) ;
                result := (result and (pNewRec.order_lead_time = pOldParts.order_lead_time)) ;
                result := (result and (pNewRec.order_uom = pOldParts.order_uom)) ;
				result := (result and (pNewRec.prime_ind = pPrime_ind)) ;
                result := (result and (pNewRec.scrap_value = pOldParts.scrap_value)) ;
                result := (result and (pNewRec.serial_flag = pOldParts.serial_flag)) ;
                result := (result and (pNewRec.shelf_life = pOldParts.shelf_life)) ;
                result := (result and (pNewRec.unit_cost = pOldParts.unit_cost)) ;
                result := (result and (pNewRec.unit_volume = pOldParts.unit_volume)) ;
				if result and pNewRec.prime_ind = 'Y' then
	                result := (result and (pNewRec.nsn = pOldParts.nsn)) ;
					result := (result and (pNewRec.order_quantity = pOrder_quantity)) ;
					result := (result and (pNewRec.nsn_type = pNsn_type)) ;
	                result := (result and (pNewRec.item_type = pItem_type)) ;
	                result := (result and (pNewRec.smr_code = pSmr_code)) ;
	                result := (result and (pNewRec.planner_code = pPlanner_code)) ;
				end if ;
				return result ;
		end IsDifferent ;

		function DeleteRows return number is
			cursor deleteData is
				select part_no, mfgr
				from amd_spare_parts
				where action_code != amd_defaults.DELETE_ACTION
				minus
				select part_no, mfgr
				from tmp_amd_spare_parts parts ;
		begin
			for oldRec in deleteData loop
				result := amd_spare_parts_pkg.DeleteRow(oldRec.part_no, oldRec.mfgr) ;
				if result != amd_spare_parts_pkg.SUCCESS then
					return result ;
				end if ;
				rows_deleted := rows_deleted + 1 ;
				commit ;
			end loop ;
			return Diff.SUCCESS ;
		end DeleteRows ;

		function GetCurrentData(pNewRec in tmp_amd_spare_parts%rowtype) return number is

			function GetPartData(pNewRec in tmp_amd_spare_parts%rowtype) return number is

				function GetDataFromOtherTables return number is
					result number := null ;

					function GetNsiSid(pNsn in amd_nsns.nsn%type) return number is
					begin
						select nsi_sid, nsn_type
						into nsi_sid, nsn_type
						from amd_nsns
						where nsn = pNsn ;
						return Diff.SUCCESS ;
					exception
						when no_data_found then
							nsi_sid := null ;
							nsn_type := null ;
							return Diff.SUCCESS ;
						when others then
							return ErrorMsg(pMsg => 'sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm ,
								pTableName => 'amd_nsns',
								pData_line_no => 1,
								pPart_no => null,
								pMfgr => null, pNsn => pNsn,
								pReturnCode => Diff.CANNOT_GET_NSI_SID)  ;
					end GetNsiSid ;

					function GetItemData return number is
					begin
						select item_type, order_quantity, planner_code, smr_code
						into item_type, order_quantity, planner_code, smr_code
						from amd_national_stock_items
						where nsi_sid = Diff.nsi_sid ;
						return Diff.SUCCESS ;
					exception
						when no_data_found then
							item_type := null ;
							order_quantity := null ;
							planner_code := null ;
							smr_code := null ;
							return Diff.SUCCESS ;
						when others then
							return ErrorMsg(pMsg => 'sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm ,
								pTableName => 'amd_nsns',
								pData_line_no => 2,
								pPart_no => null,
								pMfgr => null,
								pNsn =>  null,
								pReturnCode => Diff.CANNOT_GET_ITEM_DATA)  ;
					end GetItemData;

					function GetNsiPartsData(pPart_no in amd_nsi_parts.part_no%type) return number is
					begin
						select prime_ind into prime_ind
						from amd_nsi_parts
						where nsi_sid = Diff.nsi_sid
						and part_no = pPart_no
						and unassignment_date is null ;
						return Diff.SUCCESS ;
					exception
						when no_data_found then
							prime_ind := null ;
							return Diff.SUCCESS ;
						when others then
							return ErrorMsg(pMsg => 'sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm ,
								pTableName => 'amd_nsns',
								pData_line_no => 3,
								pPart_no => pPart_no,
								pMfgr => null,
								pNsn => to_char(nsi_sid),
								pReturnCode => Diff.CANNOT_GET_NSI_PARTS_DATA)  ;
					end GetNsiPartsData;

				begin
					result := GetNsiSid(pNewRec.nsn) ;
					if result = Diff.SUCCESS then
						result := GetItemData() ;
					end if ;
					if result = Diff.SUCCESS then
						result := GetNsiPartsData(pPart_no => pNewRec.part_no ) ;
					end if ;
					return result ;
				end GetDataFromOtherTables ;

			begin
				select * into oldParts
				from amd_spare_parts
				where part_no = pNewRec.part_no
				and mfgr = pNewRec.mfgr ;
				return GetDataFromOtherTables() ;
			exception
				when NO_DATA_FOUND then
					return Diff.CURRENT_DATA_NOT_FOUND ;
				when others then
					return ErrorMsg(pMsg => 'sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm ,
						pTableName => 'amd_nsns',
						pData_line_no => 4,
						pPart_no => pNewRec.part_no,
						pMfgr => pNewRec.mfgr,
						pNsn => pNewRec.nsn,
						pReturnCode => Diff.GET_PART_DATA_ERROR)  ;
			end GetPartData ;

		begin
			return GetPartData(pNewRec => pNewRec) ;
		exception when others then
			return ErrorMsg(pMsg => 'sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm ,
				pTableName => 'amd_nsns',
				pData_line_no => 5,
				pPart_no => pNewRec.part_no,
				pMfgr => pNewRec.mfgr,
				pNsn => pNewRec.nsn,
				pReturnCode => Diff.GET_CURRENT_DATA_ERROR)  ;
		end GetCurrentData;

	begin --<<<-- Diff
		for newRec in newData loop
			rows_read := rows_read + 1 ;
			result := GetCurrentData(pNewRec => newRec) ;
			if result = Diff.CURRENT_DATA_NOT_FOUND then
				result := InsertRow(newRec) ;
				if result = amd_spare_parts_pkg.SUCCESS then
					rows_inserted := rows_inserted + 1 ;
					commit ;
					result := Diff.SUCCESS ;
				end if ;
			elsif result = Diff.SUCCESS then
				if IsDifferent(oldParts, item_type, order_quantity,
					planner_code, smr_code, nsn_type, prime_ind,
					newRec ) then
					result := UpdateRow(newRec) ;
					if result = amd_spare_parts_pkg.SUCCESS then
						rows_updated := rows_updated + 1 ;
						commit ;
						result := Diff.SUCCESS ;
					end if ;
				end if ;
			end if ;
			exit when result != Diff.SUCCESS ;
		end loop ;
		dbms_output.put_line('rows_read=' || rows_read || ' rows_inserted=' || rows_inserted || ' rows_updated=' || rows_updated) ;
		if result = Diff.SUCCESS then
			result := DeleteRows() ;
		end if ;
		dbms_output.put_line('rows_deleted=' || rows_deleted) ;
		amd_utils.InsertErrorMsg (
			pLoad_no => amd_utils.GetLoadNo(pSourceName => 'Diff',
			pTableName => 'Diff'),
			pData_line_no => 6,
			pData_line => 'amd_test_data',
			pKey_1 => rows_read,
			pKey_2 => rows_inserted,
			pKey_3 => rows_updated,
			pKey_4 => rows_deleted,
			pKey_5 => sysdate,
			pComments => 'rows_read=' || rows_read ||' rows_inserted=' || rows_inserted || ' rows_updated=' || rows_updated || ' rows_deleted=' || rows_deleted) ;
		commit ;
		return result ;
	exception when others then
		if result is null then
			result := Diff.FAILURE ;
		end if ;
		return ErrorMsg(pMsg => 'sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm ,
			pTableName => 'amd_spare_parts',
			pData_line_no => 7,
			pPart_no => null,
			pMfgr => null,
			pNsn => null,
			pReturnCode => result)  ;
	end Diff ;

	function PrimeExistForEachNsn(pDataSource in data_source) return boolean is


		result boolean := true ;

		function IsGoodPartList return boolean is
			result boolean := true ;

			nsi_sid amd_nsi_parts.nsi_sid%type := null ;
			prime_cnt number := 0 ;
			tactical_cnt number := 0 ;
			error_cnt number := 0 ;

			cursor partList is
				select
					nsi_sid,
					part_no,
					prime_ind
				from amd_nsi_parts
				where unassignment_date is null
				order by nsi_sid ;
			procedure reportError(pNsi_sid in amd_nsi_parts.nsi_sid%type, pPrime_cnt in number) is
				cursor nsns is
					select nsn
					from amd_nsns
					where nsi_sid = pNsi_sid ;

				nsn amd_nsns.nsn%type := null ;
				tactical amd_national_stock_items.tactical%type ;
				cursor sourceData is
					select
						nsn,
						part_no,
						mfgr,
						prime_ind,
						unit_cost,
						smr_code
					from tmp_amd_spare_parts
					where nsn = reportError.nsn ;
			begin
				if pPrime_cnt = 0 then
					dbms_output.put('No prime for nsi_sid=' || pNsi_sid) ;
				else
					dbms_output.put('Multiple primes for nsi_sid=' || pNsi_sid) ;
				end if ;
				for nsnRec in nsns loop
					reportError.nsn := nsnRec.nsn ;
					for rec in sourceData loop
						select tactical
						into reportError.tactical
						from amd_national_stock_items
						where nsi_sid = pNsi_sid ;
						if reportError.tactical = 'Y' then
							tactical_cnt := tactical_cnt + 1 ;
						end if ;
						dbms_output.put_line(' part_no=' || rec.part_no || ' mfgr=' || rec.mfgr || ' nsn=' || rec.nsn ) ;
					end loop ;
				end loop ;
			end reportError ;
		begin
			for partList_rec in partList loop
				if nsi_sid is null then
					nsi_sid := partList_rec.nsi_sid ;
				end if ;
				if nsi_sid != partList_rec.nsi_sid then
					if prime_cnt = 1 then
						null ;
					else
						result := false ;
						error_cnt := error_cnt + 1 ;
						reportError(pNsi_sid => nsi_sid, pPrime_cnt => prime_cnt) ;
					end if ;
					nsi_sid := partList_rec.nsi_sid ;
					prime_cnt := 0 ;
				end if ;
				if partList_rec.prime_ind = amd_defaults.PRIME_PART then
					prime_cnt := prime_cnt + 1 ;
				end if ;
			end loop ;
			if error_cnt > 0 then
				dbms_output.put_line('There were ' || error_cnt || ' errors. ' || tactical_cnt || ' were marked as tactical.') ;
			end if ;
			return result ;
		end IsGoodPartList ;

		function IsGoodSourceData return boolean is
			result boolean := true ;
			prime_cnt number := 0 ;
			error_cnt number := 0 ;

			cursor sourceData is
				select *
				from tmp_amd_spare_parts
				order by nsn, part_no, mfgr ;
			nsn tmp_amd_spare_parts.nsn%type := null ;

			procedure reportError(pNsn tmp_amd_spare_parts.nsn%type, pPrime_cnt in number) is
			begin
				if pPrime_cnt = 0 then
					dbms_output.put_line('No prime for nsn=' || pNsn) ;
				else
					dbms_output.put_line(prime_cnt || ' primes for nsn=' || pNsn) ;
				end if ;
			end reportError ;
		begin
			for rec in sourceData loop
				if nsn is null then
					nsn := rec.nsn ;
				end if ;
				if nsn != rec.nsn then
					if prime_cnt = 1 then
						null ;
					else
						result := false ;
						error_cnt := error_cnt + 1 ;
						reportError(pNsn => nsn,pPrime_cnt => prime_cnt) ;
					end if ;
					nsn := rec.nsn ;
					prime_cnt := 0 ;
				end if ;
				if rec.prime_ind = amd_defaults.PRIME_PART then
					prime_cnt := prime_cnt + 1 ;
				end if ;
			end loop ;
 			if error_cnt > 0 then
				dbms_output.put_line('There were ' || error_cnt || ' errors.') ;
			end if ;
 			return result ;
		end IsGoodSourceData ;
	begin
		if pDataSource = NSI_PARTS then
			result := IsGoodPartList() ;
		else
			result := IsGoodSourceData() ;
		end if ;
		if result then
			dbms_output.put_line('Only 1 prime/nsi_sid in amd_nsi_parts - the system is correct.') ;
		end if ;
		return result ;
	end PrimeExistForEachNsn ;

	function PrimeCheckForTmpAmdSpareParts return boolean is
	begin
		return PrimeExistForEachNsn(pDataSource => TMP_SPARE_PARTS ) ;
	end PrimeCheckForTmpAmdSpareParts ;

	function PrimeCheckForAmdNsiParts return boolean is
	begin
		return PrimeExistForEachNsn(pDataSource => NSI_PARTS ) ;
	end PrimeCheckForAmdNsiParts ;

	function TestDefaults return boolean is
	begin
		dbms_output.put_line('CONDEMN_AVG=' || amd_defaults.CONDEMN_AVG) ;
		dbms_output.put_line('CONSUMABLE=' || amd_defaults.CONSUMABLE) ;
		dbms_output.put_line('DELETE_ACTION=' || amd_defaults.DELETE_ACTION) ;
		dbms_output.put_line('DISPOSAL_COST=' || amd_defaults.DISPOSAL_COST) ;
		dbms_output.put_line('DISTRIB_UOM=' || amd_defaults.DISTRIB_UOM) ;
		dbms_output.put_line('INSERT_ACTION=' || amd_defaults.INSERT_ACTION) ;
		dbms_output.put_line('NOT_PRIME_PART=' || amd_defaults.NOT_PRIME_PART) ;
		dbms_output.put_line('NRTS_AVG=' || amd_defaults.NRTS_AVG) ;
		dbms_output.put_line('OFF_BASE_TURN_AROUND=' || amd_defaults.OFF_BASE_TURN_AROUND) ;
		dbms_output.put_line('ORDER_LEAD_TIME (repairable)=' || amd_defaults.GetOrderLeadTime(amd_defaults.REPAIRABLE)) ;
		dbms_output.put_line('ORDER_LEAD_TIME (consumable)=' || amd_defaults.GetOrderLeadTime(amd_defaults.CONSUMABLE)) ;
		dbms_output.put_line('ORDER_QUANTITY=' || amd_defaults.ORDER_QUANTITY) ;
		dbms_output.put_line('ORDER_UOM=' || amd_defaults.ORDER_UOM) ;
		dbms_output.put_line('PRIME_PART=' || amd_defaults.PRIME_PART ) ;
		dbms_output.put_line('QPEI_WEIGHTED=' || amd_defaults.QPEI_WEIGHTED) ;
		dbms_output.put_line('REPAIRABLE=' || amd_defaults.REPAIRABLE) ;
		dbms_output.put_line('RTS_AVG=' || amd_defaults.RTS_AVG ) ;
		dbms_output.put_line('SCRAP_VALUE=' || amd_defaults.SCRAP_VALUE) ;
	    dbms_output.put_line('SHELF_LIFE=' || amd_defaults.SHELF_LIFE) ;
		dbms_output.put_line('TIME_TO_REPAIR_ON_BASE_AVG=' || amd_defaults.TIME_TO_REPAIR_ON_BASE_AVG) ;
		dbms_output.put_line('UNIT_COST=' || amd_defaults.GetUnitCost(
			pNsn => '1660014172839',
			pPart_no => '174081-13',
			pMfgr => '49315',
			pSmr_code => 'P2345N',
			pPlanner_code => 'PSA')) ;

		dbms_output.put_line('UNIT_VOLUME=' || amd_defaults.UNIT_VOLUME) ;
		dbms_output.put_line('UPDATE_ACTION=' || amd_defaults.UPDATE_ACTION) ;
		dbms_output.put_line('USE_BSSM_TO_GET_NSLs=' || amd_defaults.USE_BSSM_TO_GET_NSLs) ;
		dbms_output.put_line('COST_TO_REPAIR_ONBASE=' || amd_defaults.COST_TO_REPAIR_ONBASE) ;
		dbms_output.put_line('TIME_TO_REPAIR_ONBASE=' || amd_defaults.TIME_TO_REPAIR_ONBASE) ;
		dbms_output.put_line('TIME_TO_REPAIR_OFFBASE=' || amd_defaults.TIME_TO_REPAIR_OFFBASE) ;
		dbms_output.put_line('UNIT_COST_FACTOR_OFFBASE=' || amd_defaults.UNIT_COST_FACTOR_OFFBASE) ;
		return true ;
	end TestDefaults ;

	function TestGetNsiSid return boolean is
		nsn amd_nsns.nsn%type := '12424242' ;
		nsi_sid amd_nsns.nsi_sid%type ;
		part_no amd_nsi_parts.part_no%type := '123434' ;
	begin
		begin
			nsi_sid := amd_utils.GetNsiSid(pNsn => nsn) ;
		exception when no_data_found then
			dbms_output.put_line('no data found') ;
		end ;
		begin
			nsi_sid := amd_utils.GetNsiSid(pPart_no => part_no) ;
		exception when no_data_found then
			dbms_output.put_line('no data found') ;
		end ;
		return true ;
	end TestGetNsiSid ;
end amd_test_data ;
/

