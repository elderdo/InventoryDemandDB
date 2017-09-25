CREATE OR REPLACE package AMD_CLEANED_FROM_BSSM_PKG
is
  	   -------------------------------------------------------------------
	   --  Date	  		  By			History
	   --  ----			  --			-------
	   --  10/10/01		  ks			initial implementation
	   -------------------------------------------------------------------



  	   -- constant name is amd field name, value is corresponding bssm field name.
	   -- more of a visual reference.
  	ADD_INCREMENT 		  		 constant varchar2(30) := 'ADD_INCREMENT';
	AMC_BASE_STOCK				 constant varchar2(30) := 'AMC_BASE_STOCK';
	AMC_DAYS_EXPERIENCE			 constant varchar2(30) := 'AMC_DAYS_EXPERIENCE';
	AMC_DEMAND					 constant varchar2(30) := 'AMC_DEMAND';
	CAPABILITY_REQUIREMENT		 constant varchar2(30) := 'CAPABILITY_REQUIREMENT';  -- CATEGORY
	CONDEMN_AVG					 constant varchar2(30) := 'CONDEMN';
	COST_TO_REPAIR_OFF_BASE		 constant varchar2(30) := 'OFF_BASE_REPAIR_COST';
	CRITICALITY					 constant varchar2(30) := 'CRITICALITY';
	DLA_DEMAND					 constant varchar2(30) := 'DLA_DEMAND';
	DLA_WAREHOUSE_STOCK			 constant varchar2(30) := 'DLA_WAREHOUSE_STOCK';
	FEDC_COST					 constant varchar2(30) := 'FEDC_COST';
	ITEM_TYPE					 constant varchar2(30) := 'ITEM_TYPE';
	MIC_CODE_LOWEST				 constant varchar2(30) := 'MIC_CODE';
	MTBDR						 constant varchar2(30) := 'MTBDR';
	NOMENCLATURE 				 constant varchar2(30) := 'NOMENCLATURE';
	NRTS_AVG					 constant varchar2(30) := 'NRTS';
	ORDER_LEAD_TIME				 constant varchar2(30) := 'ORDER_LEAD_TIME';     -- TCONDEMN
	ORDER_UOM 					 constant varchar2(30) := 'ORDER_UOM'; /* UNITS */
	PLANNER_CODE				 constant varchar2(30) := 'PLANNER_CODE';
	RTS_AVG						 constant varchar2(30) := 'RTS';
	RU_IND						 constant varchar2(30) := 'RU_IND';
	SMR_CODE 					 constant varchar2(30) := 'SMR_CODE';
	TIME_TO_REPAIR_OFF_BASE		 constant varchar2(30) := 'OFF_BASE_TURNAROUND'; -- TDEPOT
	TIME_TO_REPAIR_ON_BASE_AVG	 constant varchar2(30) := 'ON_BASE_TURNAROUND';  -- TBASE
	UNIT_COST					 constant varchar2(30) := 'UNIT_COST';

		-- base specific cleanable fields
	REMOVAL_IND					 constant varchar2(30) := 'REPLACEMENT_INDICATOR';
	REPAIR_LEVEL_CODE			 constant varchar2(30) := 'REPAIR_INDICATOR';

	    -- if field needs to be converted, eg. item_type, criticality, from bssm to
		-- amd, any function in this package will return the converted value that
		-- amd needs.
	type partFields is record (
		 nsn					  amd_national_stock_items.nsn%type,
		 add_increment 		   	  amd_national_stock_items.add_increment%type,
		 amc_base_stock			  amd_national_stock_items.amc_base_stock%type,
		 amc_days_experience 	  amd_national_stock_items.amc_days_experience%type,
		 amc_demand 		   	  amd_national_stock_items.amc_demand%type,
		 capability_requirement   amd_national_stock_items.capability_requirement%type,
		 condemn_avg 		   	  amd_national_stock_items.condemn_avg%type,
		 cost_to_repair_off_base  amd_national_stock_items.cost_to_repair_off_base_cleand%type,
		 criticality 		   	  amd_national_stock_items.criticality%type,
		 dla_demand 		   	  amd_national_stock_items.dla_demand%type,
		 dla_warehouse_stock 	  amd_national_stock_items.dla_warehouse_stock%type,
		 fedc_cost 		   	      amd_national_stock_items.fedc_cost%type,
		 item_type 		   	  	  amd_national_stock_items.item_type%type,
		 mic_code_lowest 	   	  amd_national_stock_items.mic_code_lowest%type,
		 mtbdr 		   	  		  amd_national_stock_items.mtbdr%type,
		 nomenclature 		   	  amd_national_stock_items.nomenclature_cleaned%type,
		 nrts_avg 		   	  	  amd_national_stock_items.nrts_avg%type,
		 order_lead_time 	  	  amd_national_stock_items.order_lead_time_cleaned%type,
		 order_uom				  amd_national_stock_items.order_uom_cleaned%type,
		 planner_code			  amd_national_stock_items.planner_code%type,
		 rts_avg				  amd_national_stock_items.rts_avg%type,
		 ru_ind					  amd_national_stock_items.ru_ind%type,
		 smr_code				  amd_national_stock_items.smr_code%type,
 		 time_to_repair_off_base  amd_national_stock_items.time_to_repair_on_base_avg%type,
		 time_to_repair_on_base_avg	  amd_national_stock_items.time_to_repair_on_base_avg%type,
		 unit_cost				  amd_national_stock_items.unit_cost_cleaned%type
		 );

	type partBaseFields is record (
		 nsn amd_national_stock_items.nsn%type,
		 loc_id amd_spare_networks.loc_id%type,
		 removal_ind amd_part_locs.removal_ind%type,
		 repair_level_code amd_part_locs.repair_level_code%type
	);

		 	 -- part specific

	function GetValues(pNsn bssm_parts.nsn%type) return partFields;
	function GetValues(pNsn bssm_parts.nsn%type, pFieldName varchar2) return varchar2;

			 -- base specific
	function GetBaseValues(pNsn bssm_base_parts.nsn%type, pSran bssm_base_parts.sran%type) return partBaseFields;
	function GetBaseValues(pNsn bssm_base_parts.nsn%type, pSran bssm_base_parts.sran%type, pFieldName varchar2) return varchar2;


			-- update all cleaned by listing all in bssm_parts for lock_sid 2
	procedure UpdateAmdAllPartCleaned;
	procedure UpdateAmdAllBaseCleaned;
	procedure NullAmdAllCleanedFields;
			-- update used by trigger
	procedure UpdateAmdPartByTrigger(pLockSidTwo bssm_parts%rowtype);
	procedure UpdateAmdBaseByTrigger(pLockSidTwo bssm_base_parts%rowtype);
	procedure OnPartResetByTrigger(pLockSidTwo bssm_parts%rowtype);
	procedure OnBaseResetByTrigger(pLockSidTwo bssm_base_parts%rowtype);

end AMD_CLEANED_FROM_BSSM_PKG;
/
CREATE OR REPLACE package body AMD_CLEANED_FROM_BSSM_PKG
is
  	ERRSOURCE constant varchar2(20) := 'amdCleanedFromBssm';
  	type tab_modflag is table of varchar2(50) index by binary_integer;
	gModflag1Map tab_modflag;
	gModflag2Map tab_modflag;
	gSetflagBaseMap tab_modflag;

	procedure CheckPartModFlag(pModflagMap tab_modflag, pModflagValue bssm_parts.modflag1%type, pBssmParts bssm_parts%rowtype, pOutCleanable IN OUT partFields);
	function GetBaseCleanable(pLockSidTwo bssm_base_parts%rowtype) return partBaseFields;
	function GetCleanable(pLockSidTwo bssm_parts%rowtype) return partFields;
  	-- function GetCleanable(pLockSidZero bssm_parts%rowtype, pLockSidTwo bssm_parts%rowtype) return partFields;
	function GetCurrentAmdNsn(pNsiSid amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.nsn%type;
  	function NotEqual(pField1 varchar2, pField2 varchar2) return boolean;
	procedure UpdateAmdPartCleaned(pNsn amd_national_stock_items.nsn%type, pCleanable partFields);
	procedure UpdateAmdBaseCleaned(pNsn bssm_base_parts.nsn%type, pSran bssm_base_parts.sran%type, pCleanable partBaseFields);


	procedure CheckPartModFlag(pModflagMap tab_modflag, pModflagValue bssm_parts.modflag1%type, pBssmParts bssm_parts%rowtype, pOutCleanable IN OUT partFields) is
		bitNumber binary_integer;
	begin
		bitNumber := pModflagMap.FIRST;
		while (bitNumber is not null)
		loop
			if (BITAND(pModflagValue, bitNumber) > 0) then
  				if (pModflagMap(bitNumber) = ADD_INCREMENT) then
					pOutCleanable.add_increment := pBssmParts.add_increment;
				elsif (pModflagMap(bitNumber) = AMC_BASE_STOCK) then
					pOutCleanable.amc_base_stock := pBssmParts.amc_base_stock;
				elsif (pModflagMap(bitNumber) = AMC_DAYS_EXPERIENCE) then
					pOutCleanable.amc_days_experience := pBssmParts.amc_days_experience;
				elsif (pModflagMap(bitNumber) = AMC_DEMAND) then
					pOutCleanable.amc_demand := pBssmParts.amc_demand;
				elsif (pModflagMap(bitNumber) = CAPABILITY_REQUIREMENT) then
					pOutCleanable.capability_requirement := pBssmParts.capability_requirement;
				elsif (pModflagMap(bitNumber) = CONDEMN_AVG) then
					pOutCleanable.condemn_avg := pBssmParts.condemn;
				elsif (pModflagMap(bitNumber) = CRITICALITY) then
					pOutCleanable.criticality := amd_from_bssm_pkg.ConvertCriticality(pBssmParts.criticality);
				elsif (pModflagMap(bitNumber) = DLA_DEMAND) then
					pOutCleanable.dla_demand := pBssmParts.dla_demand;
				elsif (pModflagMap(bitNumber) = DLA_WAREHOUSE_STOCK) then
					pOutCleanable.dla_warehouse_stock := pBssmParts.dla_warehouse_stock;
				elsif (pModflagMap(bitNumber) = FEDC_COST) then
					pOutCleanable.fedc_cost := pBssmParts.fedc_cost;
				elsif (pModflagMap(bitNumber) = ITEM_TYPE) then
					pOutCleanable.item_type := amd_from_bssm_pkg.ConvertItemType(pBssmParts.item_type);
				elsif (pModflagMap(bitNumber) = MIC_CODE_LOWEST) then
					pOutCleanable.mic_code_lowest := pBssmParts.mic_code;
				elsif (pModflagMap(bitNumber) = MTBDR) then
					pOutCleanable.mtbdr := pBssmParts.mtbdr;
				elsif (pModflagMap(bitNumber) = NOMENCLATURE) then
					pOutCleanable.nomenclature := pBssmParts.nomenclature;
				elsif (pModflagMap(bitNumber) = NRTS_AVG) then
					pOutCleanable.nrts_avg := pBssmParts.nrts;
				elsif (pModflagMap(bitNumber) = COST_TO_REPAIR_OFF_BASE) then
					pOutCleanable.cost_to_repair_off_base := pBssmParts.off_base_repair_cost;
				elsif (pModflagMap(bitNumber) = TIME_TO_REPAIR_OFF_BASE) then
					pOutCleanable.time_to_repair_off_base := pBssmParts.off_base_turnaround;
				elsif (pModflagMap(bitNumber) = TIME_TO_REPAIR_ON_BASE_AVG) then
					pOutCleanable.time_to_repair_on_base_avg := pBssmParts.on_base_turnaround;
				elsif (pModflagMap(bitNumber) = ORDER_LEAD_TIME) then
					pOutCleanable.order_lead_time := pBssmParts.order_lead_time;
				elsif (pModflagMap(bitNumber) = ORDER_UOM) then
					pOutCleanable.order_uom := pBssmParts.order_uom;
				elsif (pModflagMap(bitNumber) = RTS_AVG) then
					pOutCleanable.rts_avg := pBssmParts.rts;
				elsif (pModflagMap(bitNumber) = RU_IND) then
					pOutCleanable.ru_ind := pBssmParts.ru_ind;
				elsif (pModflagMap(bitNumber) = SMR_CODE) then
					pOutCleanable.smr_code := pBssmParts.smr_code;
				elsif (pModflagMap(bitNumber) = UNIT_COST) then
					pOutCleanable.unit_cost := pBssmParts.unit_cost;
				end if;
			end if;
			bitNumber := pModflagMap.NEXT(bitNumber);
		end loop;
	end CheckPartModflag;

	function GetCleanable(pLockSidTwo bssm_parts%rowtype) return partFields is
		cleanable partFields := null;
	begin
		CheckPartModFlag(gModflag1Map, pLockSidTwo.modflag1, pLockSidTwo, cleanable);
		CheckPartModFlag(gModflag2Map, pLockSidTwo.modflag2, pLockSidTwo, cleanable);
		return cleanable;
	end GetCleanable;

	/*
	-- not used currently, switched back to other methodology of using bit comparisons
	-- order important when passing to this function, lockSidTwo must be second
  	function GetCleanable(pLockSidZero bssm_parts%rowtype, pLockSidTwo bssm_parts%rowtype) return partFields is
		recPart partFields := null;
	begin
		if (NotEqual(pLockSidTwo.add_increment, pLockSidZero.add_increment)) then
			recPart.add_increment := pLockSidTwo.add_increment;
		end if;
		if (NotEqual(pLockSidTwo.amc_base_stock,pLockSidZero.amc_base_stock)) then
			recPart.amc_base_stock := pLockSidTwo.amc_base_stock;
		end if;
		if (NotEqual(pLockSidTwo.amc_days_experience, pLockSidZero.amc_days_experience)) then
			recPart.amc_days_experience := pLockSidTwo.amc_days_experience;
		end if;
		if (NotEqual(pLockSidTwo.amc_demand, pLockSidZero.amc_demand)) then
			recPart.amc_demand := pLockSidTwo.amc_demand;
		end if;
		if (NotEqual(pLockSidTwo.capability_requirement,pLockSidZero.capability_requirement)) then
			recPart.capability_requirement := pLockSidTwo.capability_requirement;
		end if;
		if (NotEqual(pLockSidTwo.condemn, pLockSidZero.condemn)) then
			recPart.condemn_avg := pLockSidTwo.condemn;
		end if;
		if (NotEqual(pLockSidTwo.criticality,pLockSidZero.criticality)) then
			recPart.criticality := amd_from_bssm_pkg.ConvertCriticality(pLockSidTwo.criticality);
		end if;
		if (NotEqual(pLockSidTwo.dla_demand,pLockSidZero.dla_demand)) then
			recPart.dla_demand := pLockSidTwo.dla_demand;
		end if;
		if (NotEqual(pLockSidTwo.dla_warehouse_stock, pLockSidZero.dla_warehouse_stock)) then
			recPart.dla_warehouse_stock := pLockSidTwo.dla_warehouse_stock;
		end if;
		if (NotEqual(pLockSidTwo.fedc_cost,pLockSidZero.fedc_cost)) then
			recPart.fedc_cost := pLockSidTwo.fedc_cost;
		end if;
		if (NotEqual(pLockSidTwo.item_type,pLockSidZero.item_type)) then
			recPart.item_type := amd_from_bssm_pkg.ConvertItemType(pLockSidTwo.item_type);
		end if;
		if (NotEqual(pLockSidTwo.mic_code, pLockSidZero.mic_code)) then
			recPart.mic_code_lowest := pLockSidTwo.mic_code;
		end if;
		if (NotEqual(pLockSidTwo.mtbdr,pLockSidZero.mtbdr)) then
			recPart.mtbdr := pLockSidTwo.mtbdr;
		end if;
		if (NotEqual(pLockSidTwo.nomenclature, pLockSidZero.nomenclature)) then
			recPart.nomenclature := pLockSidTwo.nomenclature;
		end if;
		if (NotEqual(pLockSidTwo.nrts, pLockSidZero.nrts)) then
			recPart.nrts_avg := pLockSidTwo.nrts;
		end if;
		if (NotEqual(pLockSidTwo.off_base_repair_cost, pLockSidZero.off_base_repair_cost)) then
			recPart.cost_to_repair_off_base := pLockSidTwo.off_base_repair_cost;
		end if;
		if (NotEqual(pLockSidTwo.off_base_turnaround, pLockSidZero.off_base_turnaround)) then
			recPart.time_to_repair_off_base := pLockSidTwo.off_base_turnaround;
		end if;
		if (NotEqual(pLockSidTwo.on_base_turnaround, pLockSidZero.on_base_turnaround)) then
			recPart.time_to_repair_on_base_avg := pLockSidTwo.on_base_turnaround;
		end if;
		if (NotEqual(pLockSidTwo.order_lead_time, pLockSidZero.order_lead_time)) then
			recPart.order_lead_time := pLockSidTwo.order_lead_time;
		end if;
		if (NotEqual(pLockSidTwo.order_uom, pLockSidZero.order_uom)) then
			recPart.order_uom := pLockSidTwo.order_uom;
		end if;
		if (NotEqual(pLockSidTwo.planner_code, pLockSidZero.planner_code)) then
			recPart.planner_code := pLockSidTwo.planner_code;
		end if;
		if (NotEqual(pLockSidTwo.rts, pLockSidZero.rts)) then
			recPart.rts_avg := pLockSidTwo.rts;
		end if;
		if (NotEqual(pLockSidTwo.ru_ind, pLockSidZero.ru_ind)) then
			recPart.ru_ind := pLockSidTwo.ru_ind;
		end if;
		if (NotEqual(pLockSidTwo.smr_code, pLockSidZero.smr_code)) then
			recPart.smr_code := pLockSidTwo.smr_code;
		end if;
		if (NotEqual(pLockSidTwo.unit_cost, pLockSidZero.unit_cost)) then
			recPart.unit_cost := pLockSidTwo.unit_cost;
   		end if;
		return recPart;
	end GetCleanable;
	*/

	function GetBaseCleanable(pLockSidTwo bssm_base_parts%rowtype) return partBaseFields is
	  -- prior to today 11/12/01, bob said even for bssm_base_parts table, cannot
	  -- have lock_sid 2 w/o lock_sid 0.  however test with today demonstrated a lock_sid 2
	  -- was created w/o lock_sid 0. may have to abort comparison of lock_sid 2 to lock_sid 0.
	  -- all base specific fields are in gSetflagBaseMap
	  	 cleanable partBaseFields := null;
		 bitNumber binary_integer;
	begin
		bitNumber := gSetflagBaseMap.FIRST;
		while (bitNumber is not null)
		loop
			if (BITAND(pLockSidTwo.setflag, bitNumber) > 0) then
			   	if (gSetflagBaseMap(bitNumber) = REPAIR_LEVEL_CODE) then
					cleanable.repair_level_code := pLockSidTwo.repair_indicator;
				elsif (gSetflagBaseMap(bitNumber) = REMOVAL_IND) then
					cleanable.removal_ind := pLockSidTwo.replacement_indicator;
				end if;
			end if;
			bitNumber := gSetflagBaseMap.NEXT(bitNumber);
		end loop;
		return cleanable;
	end GetBaseCleanable;


	function GetBaseValues(pNsn bssm_base_parts.nsn%type, pSran bssm_base_parts.sran%type) return partBaseFields is
		 -- lockSidZero bssm_base_parts%rowtype := null;
		 lockSidTwo bssm_base_parts%rowtype := null;
		 recBase partBaseFields := null;
		 currentBssmNsn bssm_parts.nsn%type;
	begin
		 -- will throw exception if not found, important when nsn coming from amd
		currentBssmNsn := amd_from_bssm_pkg.GetCurrentBssmNsn(pNsn);
		select bbp.*
		 		into lockSidTwo
				from bssm_base_parts bbp
				where
		 	   		  lock_sid = 2   	 	and
		 	   		  sran = pSran 	 	 	and
			   		  bbp.nsn = currentBssmNsn;
		recBase := GetBaseCleanable(lockSidTwo);
		/*
		 select bbp.*
		 		into lockSidZero
				from bssm_base_parts bbp
				where
		 	   		  lock_sid = 0   	 	and
		 	   		  sran = pSran 	 	 	and
					  bbp.nsn = currentBssmNsn;
		 if (NotEqual(lockSidTwo.replacement_indicator,lockSidZero.replacement_indicator)) then
			recBase.removal_ind := lockSidTwo.replacement_indicator;
		 end if;
		 if (NotEqual(lockSidTwo.repair_indicator, lockSidZero.repair_indicator)) then
			recBase.repair_level_code := lockSidTwo.repair_indicator;
		 end if;
		 */
		 return recBase;
	exception
		 when no_data_found then
		 	  return recBase;
	end GetBaseValues;

				-- below not really used, just for convenience if want to query by field name
	function GetBaseValues(pNsn bssm_base_parts.nsn%type, pSran bssm_base_parts.sran%type, pFieldName varchar2) return varchar2 is
		recBase partBaseFields := null;
	begin
		recBase := GetBaseValues(pNsn, pSran);
		if (pFieldName = REMOVAL_IND) then
		 	return recBase.removal_ind;
		elsif (pFieldName = REPAIR_LEVEL_CODE) then
			return recBase.repair_level_code;
		end if;
	end GetBaseValues;

  	function GetCurrentAmdNsn(pNsiSid amd_national_stock_items.nsi_sid%type) return amd_national_stock_items.nsn%type is
		currentNsn amd_national_stock_items.nsn%type;
	begin
		 select nsn
		 into currentNsn
		 from amd_national_stock_items
		 where nsi_sid = pNsiSid;
		 return currentNsn;
		 -- let it throw exception if not found
	end GetCurrentAmdNsn;

    	-- if field not cleaned, GetBssmPartsRec return value will be null for that particular field.
	function GetValues(pNsn bssm_parts.nsn%type) return partFields is
		recPart partFields := null;
		-- lockSidZero bssm_parts%rowtype := null;
		lockSidTwo bssm_parts%rowtype := null;
		currentBssmNsn bssm_parts.nsn%type;
	begin
			   -- pNsn comes from amd or bssm,amd may be ahead of nsn in bssm_parts => get current bssm nsn
			   -- will throw exception if not available
		currentBssmNsn := amd_from_bssm_pkg.GetCurrentBssmNsn(pNsn);
		select bp.*
			   into lockSidTwo
			   from bssm_parts bp
			   where
			   		 bp.nsn = currentBssmNsn and
			   		 lock_sid = 2;
		recPart := GetCleanable(lockSidTwo);
		/*
		select bp.*
			   into lockSidZero
			   from bssm_parts bp
			   where
			   		 bp.nsn = currentBssmNsn and
			   		 lock_sid = 0;

		recPart := GetCleanable(lockSidZero, lockSidTwo);
		*/
		return recPart;
	exception
			 -- will occur if cannot current bssm nsn or no lock_sid 2 entry
		when no_data_found then
		 	 	-- return null record
			 return recPart;
	end GetValues;

		-- not really used anymore, here for convenience
	function GetValues(pNsn bssm_parts.nsn%type, pFieldName varchar2) return varchar2 is
		recPart partFields := null;
	begin
		 -- implicit conversion of numbers, dates to return type of varchar2.
		 -- gets all cleaned values as a group, will be null if not cleaned
		recPart := GetValues(pNsn);
		if (pFieldName = ADD_INCREMENT) then
		 	return recPart.add_increment;
		elsif (pFieldName = AMC_BASE_STOCK) then
			return recPart.amc_base_stock;
		elsif (pFieldName = AMC_DAYS_EXPERIENCE) then
			return recPart.amc_days_experience;
		elsif (pFieldName = AMC_DEMAND) then
			return recPart.amc_demand;
		elsif (pFieldName = CAPABILITY_REQUIREMENT) then
			return recPart.capability_requirement;
		elsif (pFieldName = CONDEMN_AVG) then
			return recPart.condemn_avg;
		elsif (pFieldName = CRITICALITY) then
			return recPart.criticality;
		elsif (pFieldName = DLA_DEMAND) then
			return recPart.dla_demand;
		elsif (pFieldName = DLA_WAREHOUSE_STOCK) then
			return recPart.dla_warehouse_stock;
		elsif (pFieldName = FEDC_COST) then
			return recPart.fedc_cost;
		elsif (pFieldName = ITEM_TYPE) then
			return recPart.item_type;
		elsif (pFieldName = MIC_CODE_LOWEST) then
			return recPart.mic_code_lowest;
		elsif (pFieldName = MTBDR) then
			return recPart.mtbdr;
		elsif (pFieldName = NOMENCLATURE) then
			return recPart.nomenclature;
		elsif (pFieldName = NRTS_AVG) then
			return recPart.nrts_avg;
		elsif (pFieldName = COST_TO_REPAIR_OFF_BASE) then
			return recPart.cost_to_repair_off_base;
		elsif (pFieldName = TIME_TO_REPAIR_OFF_BASE) then
			return recPart.time_to_repair_off_base;
		elsif (pFieldName = TIME_TO_REPAIR_ON_BASE_AVG) then
			return recPart.time_to_repair_on_base_avg;
		elsif (pFieldName = ORDER_LEAD_TIME) then
			return recPart.order_lead_time;
		elsif (pFieldName = ORDER_UOM) then
			return recPart.order_uom;
		elsif (pFieldName = PLANNER_CODE) then
			return recPart.planner_code;
		elsif (pFieldName = RTS_AVG) then
			return recPart.rts_avg;
		elsif (pFieldName = RU_IND) then
			return recPart.ru_ind;
		elsif (pFieldName = SMR_CODE) then
			return recPart.smr_code;
		elsif (pFieldName = UNIT_COST) then
			return recPart.unit_cost;
		else
			-- asking for field that is not cleanable
			return null;
		end if;
	end GetValues;



	function NotEqual(pField1 varchar2, pField2 varchar2) return boolean is
	begin
		 if ((pField1 is null) and (pField2 is null)) then
		 	return FALSE;
		 elsif ( pField1 = pField2) then
		 	return FALSE;
		 else
		 	return  TRUE;
		 end if;
	end NotEqual;


		-- thought below approach would be faster than cursor and reusing above procedures
	procedure NullAmdAllCleanedFields is
	begin
		 update amd_national_stock_items
		 set
			add_increment_cleaned = null,
			amc_base_stock_cleaned = null,
			amc_days_experience_cleaned = null,
			amc_demand_cleaned = null,
			capability_requirement_cleaned = null,
			condemn_avg_cleaned = null,
			criticality_cleaned = null,
			dla_demand_cleaned = null,
			dla_warehouse_stock_cleaned = null,
			fedc_cost_cleaned = null,
			item_type_cleaned = null,
			mic_code_lowest_cleaned = null,
			mtbdr_cleaned = null,
			nomenclature_cleaned = null,
			nrts_avg_cleaned = null,
			order_lead_time_cleaned = null,
	 		order_uom_cleaned = null,
			cost_to_repair_off_base_cleand = null,
			time_to_repair_off_base_cleand = null,
			time_to_repair_on_base_avg_cl = null,
			planner_code_cleaned = null,
			rts_avg_cleaned = null,
			ru_ind_cleaned = null,
			smr_code_cleaned = null,
			unit_cost_cleaned = null,
			last_update_dt = SYSDATE;

		update amd_part_locs
		set
			removal_ind_cleaned = null,
			repair_level_code = null,
			last_update_dt = SYSDATE;
	exception
		when others then
			amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'nullAllAmdCleaned'),null, null, null, null, null, substr(SQLCODE || ' ' || SQLERRM,1, 2000));
	end NullAmdAllCleanedFields;

	procedure NullAmdBaseCleanedFields(pNsn bssm_base_parts.nsn%type, pSran bssm_base_parts.sran%type) is
		cleanableNull partBaseFields := null;
	begin
		UpdateAmdBaseCleaned(pNsn, pSran, cleanableNull);
	exception
		when others then
			amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'nullBaseByNsnSran'),pNsn, pSran, null, null, null, substr(SQLCODE || ' ' || SQLERRM,1, 2000));
	end NullAmdBaseCleanedFields;

	procedure NullAmdPartCleanedFields(pNsn bssm_parts.nsn%type) is
		cleanableNull partFields := null;
	begin
		UpdateAmdPartCleaned(pNsn, cleanableNull);
	exception
		when others then
			amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'nullPartByNsn'),pNsn, null, null, null, null, substr(SQLCODE || ' ' || SQLERRM,1, 2000));
	end NullAmdPartCleanedFields;

	procedure UpdateAmdAllBaseCleaned is
	    -- appears lots of lock_sid 2 recs created with no change of info.
		-- to speed up, only list those that have a change for our
		-- fields of concern (testing went from 4500 records to 88).
		cursor nsnSranListFromBssm_cur is
			select nsn, sran, repair_indicator, replacement_indicator
			from bssm_base_parts where lock_sid = 2
				 minus
			select nsn, sran, repair_indicator, replacement_indicator
			from bssm_base_parts where lock_sid = 0;
		cleanableBase partBaseFields := null;
	begin
		for nsnSranBssm in nsnSranListFromBssm_cur
		loop
			begin
		 	   cleanableBase := GetBaseValues(nsnSranBssm.nsn, nsnSranBssm.sran);
			   UpdateAmdBaseCleaned(nsnSranBssm.nsn, nsnSranBssm.sran, cleanableBase);
			exception
		       when others then
			   		amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'upallbasecleaned'),nsnSranBssm.nsn, nsnSranBssm.sran, null, null, null, substr(SQLCODE || ' ' || SQLERRM,1, 2000));
			end;
		end loop;
		commit;
	end UpdateAmdAllBaseCleaned;

	procedure UpdateAmdBaseCleaned(pNsn bssm_base_parts.nsn%type, pSran bssm_base_parts.sran%type, pCleanable partBaseFields) is
		nsiSid amd_national_stock_items.nsi_sid%type;
		locSid amd_spare_networks.loc_sid%type;
	begin
			-- removal indicator be cleaned.  amd_part_locs is determined by this and therefore current
			-- (i.e. no action_code delete).  since dropped and reloaded, reloading will take into
			-- account when cleaned.  choose not to delete record on fly when cleaned - affects
			-- quite a few children.
			-- i.e. wait till next load
		nsiSid := amd_utils.GetNsiSid(pNsn => pNsn);
			-- associate warehouse to 'W' in GetLocSid
		locSid := amd_from_bssm_pkg.GetLocSid(pSran);
		if (nsiSid is not null and locSid is not null) then
			update amd_part_locs
				set repair_level_code_cleaned = pCleanable.repair_level_code,
					removal_ind_cleaned = pCleanable.removal_ind,
					last_update_dt = SYSDATE
				where
					nsi_sid = nsiSid and
					loc_sid = locSid;
		end if;
	exception
		when no_data_found then
			 null;
	end UpdateAmdBaseCleaned;

	procedure UpdateAmdAllPartCleaned is
		cursor listFromBssm_cur is
			select *
			from bssm_parts
			where lock_sid = 2;
		cleanablePart partFields := null;
		-- lockSidZero bssm_parts%rowtype;
	begin
			-- do those from bssm_parts.
			-- kind of slow so not using GetValues

		for lockSidTwo in listFromBssm_cur
		loop
			begin
				cleanablePart := GetCleanable(lockSidTwo);
				UpdateAmdPartCleaned(lockSidTwo.nsn, cleanablePart);
			/*
				begin
					select *
					   into lockSidZero
					   from bssm_parts
					   where nsn = lockSidTwo.nsn
					   and lock_sid = 0;
					   -- order important for GetCleanable parameters
					cleanablePart := GetCleanable(lockSidZero, lockSidTwo);
					UpdateAmdPartCleaned(lockSidTwo.nsn, cleanablePart);
				exception
						 -- possibilities occur where lock_sid 2 record and no lock_sid 0 record.
					when no_data_found then
						 null;
				end;
			*/
			exception
		       when others then
			   		amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'upallpartcleaned'),lockSidTwo.nsn, null, null, null, null, substr(SQLCODE || ' ' || SQLERRM,1, 2000));
			end;
		end loop;
		commit;
	end UpdateAmdAllPartCleaned;

	procedure UpdateAmdPartCleaned(pNsn amd_national_stock_items.nsn%type, pCleanable partFields) is
		nsiSid amd_national_stock_items.nsi_sid%type;
		currentNsn amd_national_stock_items.nsn%type;
	begin
		nsiSid := amd_utils.GetNsiSid(pNsn => pNsn);
				-- some or most maybe null
		update amd_national_stock_items
		set
			add_increment_cleaned = pCleanable.add_increment,
			amc_base_stock_cleaned = pCleanable.amc_base_stock,
			amc_days_experience_cleaned = pCleanable.amc_days_experience,
			amc_demand_cleaned = pCleanable.amc_demand,
			capability_requirement_cleaned = pCleanable.capability_requirement,
			condemn_avg_cleaned = pCleanable.condemn_avg,
			criticality_cleaned = pCleanable.criticality,
			dla_demand_cleaned = pCleanable.dla_demand,
			dla_warehouse_stock_cleaned = pCleanable.dla_warehouse_stock,
			fedc_cost_cleaned = pCleanable.fedc_cost,
			item_type_cleaned = pCleanable.item_type,
			mic_code_lowest_cleaned = pCleanable.mic_code_lowest,
			mtbdr_cleaned = pCleanable.mtbdr,
			nomenclature_cleaned = pCleanable.nomenclature,
			nrts_avg_cleaned = pCleanable.nrts_avg,
			order_lead_time_cleaned = pCleanable.order_lead_time,
	 		order_uom_cleaned = pCleanable.order_uom,
			cost_to_repair_off_base_cleand = pCleanable.cost_to_repair_off_base,
			time_to_repair_off_base_cleand = pCleanable.time_to_repair_off_base,
			time_to_repair_on_base_avg_cl = pCleanable.time_to_repair_on_base_avg,
			planner_code_cleaned = pCleanable.planner_code,
			rts_avg_cleaned = pCleanable.rts_avg,
			ru_ind_cleaned = pCleanable.ru_ind,
			smr_code_cleaned = pCleanable.smr_code,
			unit_cost_cleaned = pCleanable.unit_cost,
			last_update_dt = SYSDATE
		where nsi_sid = nsiSid;

	exception
		when no_data_found then
			 -- this would occur when cannot find nsi_sid or current nsn
			 null;
	end UpdateAmdPartCleaned;

		------- trigger oriented procedures ---------
	procedure UpdateAmdPartByTrigger(pLockSidTwo bssm_parts%rowtype) is
		cleanablePart partFields := null;
	begin
		cleanablePart := GetCleanable(pLockSidTwo);
		UpdateAmdPartCleaned(pLockSidTwo.nsn, cleanablePart);
	exception
			  -- part of trigger, don't want to fail
		when others then
			amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'partByTrigger'),pLockSidTwo.nsn, null, null, null, null, substr(SQLCODE || ' ' || SQLERRM,1, 2000));
	end UpdateAmdPartByTrigger;


	procedure UpdateAmdBaseByTrigger(pLockSidTwo bssm_base_parts%rowtype) is
		cleanable partBaseFields := null;
	begin
		cleanable := GetBaseCleanable(pLockSidTwo);
		UpdateAmdBaseCleaned(pLockSidTwo.nsn, pLockSidTwo.sran, cleanable);
	exception
			  -- part of trigger, don't want to fail
		when others then
			amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'partByTrigger'),pLockSidTwo.nsn, pLockSidTwo.sran, null, null, null, substr(SQLCODE || ' ' || SQLERRM,1, 2000));
	end UpdateAmdBaseByTrigger;


	procedure OnPartResetByTrigger(pLockSidTwo bssm_parts%rowtype) is
		-- bob's code on reset deletes lock_sid 2 then updates lock_sid 0
		 bssmPartRec bssm_parts%rowtype;
	begin
		 -- on reset, values are not considered "cleaned" anymore, source systems caught up.
		 NullAmdPartCleanedFields(pLockSidTwo.nsn);
		 -- since amd should catch up at the same time of it's load,
		 -- grab only those that currently bssm is the only source for (may be off by 10%).
		 -- if want to be safer run amd_from_bssm_pkg.loadamdfrombssmraw to alleviate
		 -- possible off by 10%.
		  amd_from_bssm_pkg.UpdateAmdNsi(pLockSidTwo);
	exception
		when no_data_found then
			 amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'OnPartResetByTrigger'),pLockSidTwo.nsn,2, null, null, null, 'no data found, error in trigger');
		when others then
			 amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'OnPartResetByTrigger'),pLockSidTwo.nsn,2, null, null, null, substr(SQLCODE || ' ' || SQLERRM,1, 2000));
	end OnPartResetByTrigger;

	procedure OnBaseResetByTrigger(pLockSidTwo bssm_base_parts%rowtype) is
		-- bob's code on reset deletes lock_sid 2 then updates lock_sid 0
		 bssmBaseRec bssm_base_parts%rowtype;
	begin
		 -- on reset, values are not considered "cleaned" anymore, source systems caught up.
		 NullAmdBaseCleanedFields(pLockSidTwo.nsn, pLockSidTwo.sran);
		 -- since amd should catch up at the same time of it's load,
		 -- grab only those that currently bssm is the only source for (may be off by 10%).
		 -- if want to be safer run amd_from_bssm_pkg.loadamdfrombssmraw to alleviate
		 -- possible off by 10%.
		 amd_from_bssm_pkg.UpdateAmdPartLocs(pLockSidTwo);
	exception
		when no_data_found then
			 amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'OnPartResetByTrigger'),pLockSidTwo.nsn,pLockSidTwo.sran, null, null, null, 'no data found, error in trigger');
		when others then
			 amd_utils.InsertErrorMsg(amd_utils.GetLoadNo(ERRSOURCE, 'OnPartResetByTrigger'),pLockSidTwo.nsn,pLockSidTwo.sran, null, null, null, substr(SQLCODE || ' ' || SQLERRM,1, 2000));
	end OnBaseResetByTrigger;
begin
	 /*  this is an alternative method than comparing lock_sid 2 with lock_sid 0
  to determine cleaned data.  marginally more difficult to maintain as not as intuitive
  as comparing lock_sids - best spares uses this approach of reading modflag1 and modflag2
  to determine if something has been cleaned.  this is here because a trigger, for
  example on bssm_parts, cannot requery the table to get the lock_sid 0 value
  used for comparison - get mutating error.  this and associated functions
  can go away if triggers not used for update of cleaned data - or everything can be updated
  to use this and skip the lock_sid 2 vs lock_sid 0 comparison.

       2 fields, modflag1 and modflag2 contain the bits of those fields that
  have been cleaned. Created 2 pl/sql arrays to relate this.
  Using characteristic of sparseness in pl/sql array to hold
  "power" values to their associated field names (probably could've used
  constants instead).
  This means the indexvalue of pl/sql array is also the bit value
  related to the field as defined in best spares application. Little
  easier to cycle thru list this way.
  When bitAnd'ed with corresponding modflag1 or modflag2, will note
  cleaned field. the definitions of the modflag1 and modflag2 come from
  the SparesCommon.h file.
  Changed SparesCommon.h definition names to match database field names.
  Easier to read/maintain than hardcode calculated values by
  using power function - will match up well with SparesCommon.h if needed
  updated or added.
  eg. mtbdr    from sparesCommon.h
  	  		   		#define MOD1_MTBRD (1 << 28)
			   below
			   		gModflag1Map(POWER(2,28)) := MTBDR

*/
  		  -- modflag1
-- 	gModflag1Map(POWER(2,9))  := GOLD_MFGR_CAGE;   		 -- no cleaned spot in amd
-- 	gModflag1Map(POWER(2,10)) := MFGR; 					 -- no cleaned spot in amd
	gModflag1Map(POWER(2,11)) := ADD_INCREMENT;
	gModflag1Map(POWER(2,12)) := COST_TO_REPAIR_OFF_BASE; -- OFF_BASE_REPAIR_COST
	gModflag1Map(POWER(2,13)) := ORDER_UOM; /* UNITS */
    gModflag1Map(POWER(2,14)) := PLANNER_CODE; 		   	 -- no cleaned spot in amd
	gModflag1Map(POWER(2,15)) := MIC_CODE_LOWEST;
	gModflag1Map(POWER(2,16)) := SMR_CODE;
	gModflag1Map(POWER(2,21)) := NOMENCLATURE;
-- 	gModflag1Map(POWER(2,22)) := WUC;  		 			 -- no cleaned spot in amd
	gModflag1Map(POWER(2,23)) := DLA_WAREHOUSE_STOCK;
	gModflag1Map(POWER(2,24)) := DLA_DEMAND;
	gModflag1Map(POWER(2,25)) := AMC_DEMAND;
	gModflag1Map(POWER(2,26)) := AMC_DAYS_EXPERIENCE;
	gModflag1Map(POWER(2,27)) := AMC_BASE_STOCK;
	gModflag1Map(POWER(2,28)) := MTBDR;


	 	-- modflag2
	gModflag2Map(POWER(2,10)) := UNIT_COST;
	gModflag2Map(POWER(2,11)) := FEDC_COST;
	gModflag2Map(POWER(2,12)) := RU_IND;
	gModflag2Map(POWER(2,13)) := ITEM_TYPE;
	gModflag2Map(POWER(2,14)) := CAPABILITY_REQUIREMENT; 	  -- CATEGORY
	gModflag2Map(POWER(2,15)) := CRITICALITY;
	gModflag2Map(POWER(2,16)) := RTS_AVG;	 			  	  -- RTS
	gModflag2Map(POWER(2,17)) := NRTS_AVG;				  	  -- NRTS
	gModflag2Map(POWER(2,18)) := CONDEMN_AVG;			  	  -- CONDEMN
	gModflag2Map(POWER(2,19)) := TIME_TO_REPAIR_ON_BASE_AVG;  -- ON_BASE_TURNAROUND, TBASE
	gModflag2Map(POWER(2,20)) := TIME_TO_REPAIR_OFF_BASE;  	  -- OFF_BASE_TURNAROUND,TDEPOT
	gModflag2Map(POWER(2,21)) := ORDER_LEAD_TIME;     	  	  -- TCONDEMN

		-- decide to separate base specific into their own array,
		-- but still matches bob's "power".
	gSetflagBaseMap(POWER(2,0)) := REPAIR_LEVEL_CODE;
	gSetflagBaseMap(POWER(2,1)) := REMOVAL_IND;
	-- following not passed on to amd at this time, i.e. no cleaned hole in amd
	/*
		gSetflagBaseMap(POWER(2,2)) := MAXIMUM_STOCK;
		gSetflagBaseMap(POWER(2,3)) := MINIMUM_STOCK;
		gSetflagBaseMap(POWER(2,8)) := RSP_ON_HAND;
		gSetflagBaseMap(POWER(2,9)) := RSP_OBJECTIVE;

		gSetflagBaseMap(POWER(2,22) := HOLDING_COST;
		gSetflagBaseMap(POWER(2,23) := BACKORDER_FIXED_COST;
		gSetflagBaseMap(POWER(2,24) := BACKORDER_VARIABLE_COST;
		gSetflagBaseMap(POWER(2,25) := ORDER_COST;
	*/
end AMD_CLEANED_FROM_BSSM_PKG;
/

