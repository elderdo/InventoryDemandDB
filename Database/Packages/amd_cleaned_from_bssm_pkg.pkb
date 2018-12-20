DROP PACKAGE BODY AMD_OWNER.AMD_CLEANED_FROM_BSSM_PKG;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.AMD_CLEANED_FROM_BSSM_PKG
IS
   /*
    PVCS Keywords

      $Author:   Douglas S. Elder
    $Revision:   1.19
        $Date:   14 Nov 2017
    $Workfile:   amd_cleaned_from_bssm_pkg.pkb  $
      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_cleaned_from_bssm_pkg.pkb-arc  $

     rev 1.19   14 Nov 2017 added exception handlers for select's of bssm_parts which one of the select was returning more
                            than one row
     Rev 1.18   03 Jul 2008 23:34:22   zf297a
  Removed unnecessary dbms_output

     Rev 1.17   11 May 2007 12:09:38   zf297a
  Renamed gold_mfgr_cage to pbl_flag for BSSM V604

     Rev 1.16   14 Feb 2007 13:55:02   zf297a
  removed dbms_output from checkPartModFlag

     Rev 1.15   09 Feb 2007 11:15:06   zf297a
  For all cleaned fields only return a value if ilock sid 2 data is different from lock sid 1 data.

     Rev 1.14   Jul 11 2006 11:30:04   zf297a
  Removed quotes from package name.

     Rev 1.13   Jun 09 2006 12:47:26   zf297a
  implemented version

     Rev 1.12   Dec 06 2005 09:35:34   zf297a
  Fixed display of sysdate in errorMsg - changed to MM/DD/YYYY HH:MM:SS

     Rev 1.11   Oct 06 2005 10:09:10   zf297a
  added code to return planner_code

     Rev 1.10   Aug 04 2005 14:23:52   zf297a
  Made sure all queries using lock_sid compare against a character string versus a number so that the index is used.

     Rev 1.9   Jun 21 2005 07:58:32   c970183
  Added more excepton handlers.  Terminated the routine for all critical exceptions that should not occur.

     Rev 1.8   May 17 2005 11:05:56   c970183
  added new cleaned fields.  added fields that are not part of amd, but could provide an easy way to get field from bssm

     Rev 1.7   May 17 2005 10:26:46   c970183
  Changed dla_wareshouse_stock to current_backorder

     Rev 1.6   May 06 2005 07:45:26   c970183
  Changed dla_warehouse_stock to current_backorder.  added pvcs keywords.
     */



   ERRSOURCE   CONSTANT VARCHAR2 (20) := 'amdCleanedFromBssm';

   TYPE tab_modflag IS TABLE OF VARCHAR2 (50)
      INDEX BY BINARY_INTEGER;

   gModflag1Map         tab_modflag;
   gModflag2Map         tab_modflag;
   gSetflagBaseMap      tab_modflag;

   PROCEDURE CheckPartModFlag (
      pModflagMap     IN     tab_modflag,
      pModflagValue   IN     bssm_parts.modflag1%TYPE,
      pLockSidTwo     IN     bssm_parts%ROWTYPE,
      pOutCleanable   IN OUT partFields);

   FUNCTION GetBaseCleanable (pLockSidTwo bssm_base_parts%ROWTYPE)
      RETURN partBaseFields;

   FUNCTION GetCleanable (pLockSidTwo IN bssm_parts%ROWTYPE)
      RETURN partFields;

   -- function GetCleanable(pLockSidZero bssm_parts%rowtype, pLockSidTwo bssm_parts%rowtype) return partFields;
   FUNCTION GetCurrentAmdNsn (pNsiSid amd_national_stock_items.nsi_sid%TYPE)
      RETURN amd_national_stock_items.nsn%TYPE;

   FUNCTION NotEqual (pField1 VARCHAR2, pField2 VARCHAR2)
      RETURN BOOLEAN;

   PROCEDURE UpdateAmdPartCleaned (pNsn          amd_national_stock_items.nsn%TYPE,
                                   pCleanable    partFields);

   PROCEDURE UpdateAmdBaseCleaned (pNsn          bssm_base_parts.nsn%TYPE,
                                   pSran         bssm_base_parts.sran%TYPE,
                                   pCleanable    partBaseFields);


   PROCEDURE writeMsg (
      pTableName        IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
      pError_location   IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
      pKey1             IN VARCHAR2 := '',
      pKey2             IN VARCHAR2 := '',
      pKey3             IN VARCHAR2 := '',
      pKey4             IN VARCHAR2 := '',
      pData             IN VARCHAR2 := '',
      pComments         IN VARCHAR2 := '')
   IS
   BEGIN
      Amd_Utils.writeMsg (pSourceName       => 'amd_cleaned_from_bssm_pkg',
                          pTableName        => pTableName,
                          pError_location   => pError_location,
                          pKey1             => pKey1,
                          pKey2             => pKey2,
                          pKey3             => pKey3,
                          pKey4             => pKey4,
                          pData             => pData,
                          pComments         => pComments);
   END writeMsg;

   PROCEDURE errorMsg (sqlFunction         IN VARCHAR2,
                       tableName           IN VARCHAR2,
                       errorLocation       IN NUMBER,
                       key1                IN VARCHAR2 := '',
                       key2                IN VARCHAR2 := '',
                       key3                IN VARCHAR2 := '',
                       key4                IN VARCHAR2 := '',
                       key5                IN VARCHAR2 := '',
                       keywordvaluepairs   IN VARCHAR2 := '')
   IS
   BEGIN
      ROLLBACK;
      amd_utils.inserterrormsg (
         pload_no        => amd_utils.getloadno (psourcename   => sqlfunction,
                                                 ptablename    => tablename),
         pdata_line_no   => errorlocation,
         pdata_line      => 'amd_cleaned_from_bssm_pkg',
         pkey_1          => key1,
         pkey_2          => key2,
         pkey_3          => key3,
         pkey_4          => key4,
         pkey_5          =>    key5
                            || ' '
                            || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS')
                            || ' '
                            || keywordvaluepairs,
         pcomments       =>    sqlfunction
                            || '/'
                            || tablename
                            || ' sqlcode('
                            || SQLCODE
                            || ') sqlerrm('
                            || SQLERRM
                            || ')');
      COMMIT;
      RETURN;
   END errorMsg;

   PROCEDURE CheckPartModFlag (
      pModflagMap     IN     tab_modflag,
      pModflagValue   IN     bssm_parts.modflag1%TYPE,
      pLockSidTwo     IN     bssm_parts%ROWTYPE,
      pOutCleanable   IN OUT partFields)
   IS
      bitNumber    BINARY_INTEGER;
      lockSidOne   bssm_parts%ROWTYPE;

      FUNCTION equal (fld1 IN VARCHAR2, fld2 IN VARCHAR2)
         RETURN BOOLEAN
      IS
         result   BOOLEAN := FALSE;
      BEGIN
         IF fld1 IS NULL
         THEN
            result := fld2 IS NULL;
         ELSE
            IF fld2 IS NOT NULL
            THEN
               result := fld1 = fld2;
            END IF;
         END IF;

         RETURN result;
      END equal;

      FUNCTION equal (num1 IN NUMBER, num2 IN NUMBER)
         RETURN BOOLEAN
      IS
         result   BOOLEAN := FALSE;
      BEGIN
         IF num1 IS NULL
         THEN
            result := num2 IS NULL;
         ELSE
            IF num2 IS NOT NULL
            THEN
               result := num1 = num2;
            END IF;
         END IF;

         RETURN result;
      END equal;
   BEGIN
      SELECT bp.*
        INTO lockSidOne
        FROM bssm_parts bp
       WHERE bp.nsn = pLockSidTwo.nsn AND bp.lock_sid = '1';

      bitNumber := pModflagMap.FIRST;

      WHILE (bitNumber IS NOT NULL)
      LOOP
         IF (BITAND (pModflagValue, bitNumber) > 0)
         THEN
            IF (    pModflagMap (bitNumber) = ACQUISITION_ADVICE_CODE
                AND NOT equal (lockSidOne.acquisition_advice_code,
                               pLockSidTwo.acquisition_advice_code))
            THEN
               pOutCleanable.acquisition_advice_code :=
                  pLockSidTwo.acquisition_advice_code;
            ELSIF (    pModflagMap (bitNumber) = ADD_INCREMENT
                   AND NOT equal (lockSidOne.add_increment,
                                  pLockSidtwo.add_increment))
            THEN
               pOutCleanable.add_increment := pLockSidTwo.add_increment;
            ELSIF (    pModflagMap (bitNumber) = AMC_BASE_STOCK
                   AND NOT equal (lockSidOne.amc_base_stock,
                                  pLockSidTwo.amc_base_stock))
            THEN
               pOutCleanable.amc_base_stock := pLockSidTwo.amc_base_stock;
            ELSIF (    pModflagMap (bitNumber) = AMC_DAYS_EXPERIENCE
                   AND NOT equal (lockSidOne.amc_days_experience,
                                  pLockSidTwo.amc_days_experience))
            THEN
               pOutCleanable.amc_days_experience :=
                  pLockSidTwo.amc_days_experience;
            ELSIF (    pModflagMap (bitNumber) = AMC_DEMAND
                   AND NOT equal (lockSidOne.amc_demand,
                                  pLockSidTwo.amc_demand))
            THEN
               pOutCleanable.amc_demand := pLockSidTwo.amc_demand;
            ELSIF (    pModflagMap (bitNumber) = CAPABILITY_REQUIREMENT
                   AND NOT equal (lockSidOne.capability_requirement,
                                  pLockSidTwo.capability_requirement))
            THEN
               pOutCleanable.capability_requirement :=
                  pLockSidTwo.capability_requirement;
            ELSIF (    pModflagMap (bitNumber) = CONDEMN_AVG
                   AND NOT equal (lockSidOne.condemn, pLockSidTwo.condemn))
            THEN
               pOutCleanable.condemn_avg := pLockSidTwo.condemn;
            ELSIF (    pModflagMap (bitNumber) = CRITICALITY
                   AND NOT equal (lockSidOne.criticality,
                                  pLockSidTwo.criticality))
            THEN
               pOutCleanable.criticality := pLockSidTwo.criticality;
            ELSIF (    pModflagMap (bitNumber) = DLA_DEMAND
                   AND NOT equal (lockSidOne.dla_demand,
                                  pLockSidTwo.dla_demand))
            THEN
               pOutCleanable.dla_demand := pLockSidTwo.dla_demand;
            ELSIF (    pModflagMap (bitNumber) = CURRENT_BACKORDER
                   AND NOT equal (lockSidOne.current_backorder,
                                  pLockSidTwo.current_backorder))
            THEN
               pOutCleanable.current_backorder :=
                  pLockSidTwo.CURRENT_BACKORDER;
            ELSIF (    pModflagMap (bitNumber) = FEDC_COST
                   AND NOT equal (lockSidOne.fedc_cost,
                                  pLockSidTwo.fedc_cost))
            THEN
               pOutCleanable.fedc_cost := pLockSidTwo.fedc_cost;
            ELSIF (    pModflagMap (bitNumber) = pbl_flag
                   AND NOT equal (lockSidOne.pbl_flag, pLockSidTwo.pbl_flag))
            THEN
               pOutCleanable.pbl_flag := pLockSidTwo.pbl_flag;
            ELSIF (    pModflagMap (bitNumber) = ITEM_TYPE
                   AND NOT equal (lockSidOne.item_type,
                                  pLockSidTwo.item_type))
            THEN
               pOutCleanable.item_type :=
                  amd_from_bssm_pkg.ConvertItemType (pLockSidTwo.item_type);
            ELSIF (    pModflagMap (bitNumber) = MFGR
                   AND NOT equal (lockSidOne.mfgr, pLockSidTwo.mfgr))
            THEN
               pOutCleanable.mfgr := pLockSidTwo.mfgr;
            ELSIF (    pModflagMap (bitNumber) = MIC_CODE_LOWEST
                   AND NOT equal (lockSidOne.mic_code, pLockSidTwo.mic_code))
            THEN
               pOutCleanable.mic_code_lowest := pLockSidTwo.mic_code;
            ELSIF (    pModflagMap (bitNumber) = MTBDR
                   AND NOT equal (lockSidOne.mtbdr, pLockSidTwo.mtbdr))
            THEN
               pOutCleanable.mtbdr := pLockSidTwo.mtbdr;
            ELSIF (    pModflagMap (bitNumber) = MIN_PURCHASE_QUANTITY
                   AND NOT equal (lockSidOne.min_purchase_quantity,
                                  pLockSidTwo.min_purchase_quantity))
            THEN
               pOutCleanable.min_purchase_quantity :=
                  pLockSidTwo.min_purchase_quantity;
            ELSIF (    pModflagMap (bitNumber) = NOMENCLATURE
                   AND NOT equal (lockSidOne.nomenclature,
                                  pLockSidTwo.nomenclature))
            THEN
               pOutCleanable.nomenclature := pLockSidTwo.nomenclature;
            ELSIF (    pModflagMap (bitNumber) = NRTS_AVG
                   AND NOT equal (lockSidOne.nrts, pLockSidTwo.nrts))
            THEN
               pOutCleanable.nrts_avg := pLockSidTwo.nrts;
            ELSIF (    pModflagMap (bitNumber) = COST_TO_REPAIR_OFF_BASE
                   AND NOT equal (lockSidOne.off_base_repair_cost,
                                  pLockSidTwo.off_base_repair_cost))
            THEN
               pOutCleanable.cost_to_repair_off_base :=
                  pLockSidTwo.off_base_repair_cost;
            ELSIF (    pModflagMap (bitNumber) = TIME_TO_REPAIR_OFF_BASE
                   AND NOT equal (lockSidOne.off_base_turnaround,
                                  pLockSidTwo.off_base_turnaround))
            THEN
               pOutCleanable.time_to_repair_off_base :=
                  pLockSidTwo.off_base_turnaround;
            ELSIF (    pModflagMap (bitNumber) = TIME_TO_REPAIR_ON_BASE_AVG
                   AND NOT equal (lockSidOne.on_base_turnaround,
                                  pLockSidTwo.on_base_turnaround))
            THEN
               pOutCleanable.time_to_repair_on_base_avg :=
                  pLockSidTwo.on_base_turnaround;
            ELSIF (    pModflagMap (bitNumber) = ORDER_LEAD_TIME
                   AND NOT equal (lockSidOne.order_lead_time,
                                  pLockSidTwo.order_lead_time))
            THEN
               pOutCleanable.order_lead_time := pLockSidTwo.order_lead_time;
            ELSIF (    pModflagMap (bitNumber) = ORDER_UOM
                   AND NOT equal (lockSidOne.order_uom,
                                  pLockSidTwo.order_uom))
            THEN
               pOutCleanable.order_uom := pLockSidTwo.order_uom;
            ELSIF (    pModflagMap (bitNumber) = PLANNER_CODE
                   AND NOT equal (lockSidOne.planner_code,
                                  pLockSidTwo.planner_code))
            THEN
               pOutCleanable.planner_code := pLockSidTwo.planner_code;
            ELSIF (    pModflagMap (bitNumber) = RTS_AVG
                   AND NOT equal (lockSidOne.rts, pLockSidTwo.rts))
            THEN
               pOutCleanable.rts_avg := pLockSidTwo.rts;
            ELSIF (    pModflagMap (bitNumber) = RU_IND
                   AND NOT equal (lockSidOne.ru_ind, pLockSidTwo.ru_ind))
            THEN
               pOutCleanable.ru_ind := pLockSidTwo.ru_ind;
            ELSIF (    pModflagMap (bitNumber) = SMR_CODE
                   AND NOT equal (lockSidOne.smr_code, pLockSidTwo.smr_code))
            THEN
               pOutCleanable.smr_code := pLockSidTwo.smr_code;
            ELSIF (    pModflagMap (bitNumber) = UNIT_COST
                   AND NOT equal (lockSidOne.unit_cost,
                                  pLockSidTwo.unit_cost))
            THEN
               pOutCleanable.unit_cost := pLockSidTwo.unit_cost;
            END IF;
         END IF;

         bitNumber := pModflagMap.NEXT (bitNumber);
      END LOOP;
   END CheckPartModflag;

   FUNCTION GetCleanable (pLockSidTwo IN bssm_parts%ROWTYPE)
      RETURN partFields
   IS
      cleanable   partFields := NULL;
   BEGIN
      CheckPartModFlag (gModflag1Map,
                        pLockSidTwo.modflag1,
                        pLockSidTwo,
                        cleanable);
      CheckPartModFlag (gModflag2Map,
                        pLockSidTwo.modflag2,
                        pLockSidTwo,
                        cleanable);
      RETURN cleanable;
   END GetCleanable;

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

   FUNCTION GetBaseCleanable (pLockSidTwo bssm_base_parts%ROWTYPE)
      RETURN partBaseFields
   IS
      -- prior to today 11/12/01, bob said even for bssm_base_parts table, cannot
      -- have lock_sid 2 w/o lock_sid 0.  however test with today demonstrated a lock_sid 2
      -- was created w/o lock_sid 0. may have to abort comparison of lock_sid 2 to lock_sid 0.
      -- all base specific fields are in gSetflagBaseMap
      cleanable   partBaseFields := NULL;
      bitNumber   BINARY_INTEGER;
   BEGIN
      bitNumber := gSetflagBaseMap.FIRST;

      WHILE (bitNumber IS NOT NULL)
      LOOP
         IF (BITAND (pLockSidTwo.setflag, bitNumber) > 0)
         THEN
            IF (gSetflagBaseMap (bitNumber) = REPAIR_LEVEL_CODE)
            THEN
               cleanable.repair_level_code := pLockSidTwo.repair_indicator;
            ELSIF (gSetflagBaseMap (bitNumber) = REMOVAL_IND)
            THEN
               cleanable.removal_ind := pLockSidTwo.replacement_indicator;
            END IF;
         END IF;

         bitNumber := gSetflagBaseMap.NEXT (bitNumber);
      END LOOP;

      RETURN cleanable;
   END GetBaseCleanable;


   FUNCTION GetBaseValues (pNsn     bssm_base_parts.nsn%TYPE,
                           pSran    bssm_base_parts.sran%TYPE)
      RETURN partBaseFields
   IS
      -- lockSidZero bssm_base_parts%rowtype := null;
      lockSidTwo       bssm_base_parts%ROWTYPE := NULL;
      recBase          partBaseFields := NULL;
      currentBssmNsn   bssm_parts.nsn%TYPE;
   BEGIN
      -- will throw exception if not found, important when nsn coming from amd
      currentBssmNsn := amd_from_bssm_pkg.GetCurrentBssmNsn (pNsn);

      SELECT bbp.*
        INTO lockSidTwo
        FROM bssm_base_parts bbp
       WHERE lock_sid = '2' AND sran = pSran AND bbp.nsn = currentBssmNsn;

      recBase := GetBaseCleanable (lockSidTwo);
      /*
       select bbp.*
         into lockSidZero
        from bssm_base_parts bbp
        where
               lock_sid = 0      and
               sran = pSran      and
           bbp.nsn = currentBssmNsn;
       if (NotEqual(lockSidTwo.replacement_indicator,lockSidZero.replacement_indicator)) then
       recBase.removal_ind := lockSidTwo.replacement_indicator;
       end if;
       if (NotEqual(lockSidTwo.repair_indicator, lockSidZero.repair_indicator)) then
       recBase.repair_level_code := lockSidTwo.repair_indicator;
       end if;
       */
      RETURN recBase;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN recBase;
   END GetBaseValues;

   -- below not really used, just for convenience if want to query by field name
   FUNCTION GetBaseValues (pNsn          bssm_base_parts.nsn%TYPE,
                           pSran         bssm_base_parts.sran%TYPE,
                           pFieldName    VARCHAR2)
      RETURN VARCHAR2
   IS
      recBase   partBaseFields := NULL;
   BEGIN
      recBase := GetBaseValues (pNsn, pSran);

      IF (pFieldName = REMOVAL_IND)
      THEN
         RETURN recBase.removal_ind;
      ELSIF (pFieldName = REPAIR_LEVEL_CODE)
      THEN
         RETURN recBase.repair_level_code;
      END IF;
   END GetBaseValues;

   FUNCTION GetCurrentAmdNsn (pNsiSid amd_national_stock_items.nsi_sid%TYPE)
      RETURN amd_national_stock_items.nsn%TYPE
   IS
      currentNsn   amd_national_stock_items.nsn%TYPE;
   BEGIN
      SELECT nsn
        INTO currentNsn
        FROM amd_national_stock_items
       WHERE nsi_sid = pNsiSid;

      RETURN currentNsn;
   -- let it throw exception if not found
   END GetCurrentAmdNsn;

   FUNCTION GetValuesX (pNsn       bssm_parts.nsn%TYPE,
                        pPartNo    bssm_parts.part_no%TYPE)
      RETURN partFields
   IS
      recPart          partFields := NULL;
      -- lockSidZero bssm_parts%rowtype := null;
      lockSidTwo       bssm_parts%ROWTYPE := NULL;
      currentBssmNsn   bssm_parts.nsn%TYPE;
   BEGIN
      -- pNsn comes from amd or bssm,amd may be ahead of nsn in bssm_parts => get current bssm nsn
      -- will throw exception if not available
      currentBssmNsn := amd_from_bssm_pkg.GetCurrentBssmNsn (pNsn);

      SELECT bp.*
        INTO lockSidTwo
        FROM bssm_parts bp
       WHERE bp.nsn = currentBssmNsn AND lock_sid = '2';


      recPart := GetCleanable (lockSidTwo);
      /*
      select bp.*
          into lockSidZero
          from bssm_parts bp
          where
             bp.nsn = currentBssmNsn and
             lock_sid = 0;

      recPart := GetCleanable(lockSidZero, lockSidTwo);
      */



      recPart.part_no := pPartNo;
      RETURN recPart;
   EXCEPTION
      -- will occur if cannot current bssm nsn or no lock_sid 2 entry
      WHEN NO_DATA_FOUND
      THEN
         recPart := NULL;

        <<getViaPart>>
         DECLARE
            nsn   bssm_parts.nsn%TYPE := NULL;
            cnt   NUMBER := 0;

            CURSOR bssmPartInfoOriginal (partNo VARCHAR2)
            IS
               SELECT nsn
                 INTO getViaPart.nsn
                 FROM bssm_parts
                WHERE part_no = pPartNo AND lock_sid = '0';
         BEGIN
           <<locksid0>>
            BEGIN
               FOR rec IN bssmPartInfoOriginal (pPartNo)
               LOOP
                  cnt := cnt + 1;

                  IF cnt = 1
                  THEN
                     getViaPart.nsn := rec.nsn;
                  END IF;
               END LOOP;

               IF cnt > 1
               THEN
                  DBMS_OUTPUT.put_line (
                        'GetValuesX: part_no='
                     || pPartNo
                     || ' lock_sid=0'
                     || ' returned '
                     || cnt
                     || ' rows');
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  errorMsg (sqlFunction     => 'select',
                            tablename       => 'bssm_parts',
                            key1            => pPartNo,
                            key2            => '0',
                            errorLocation   => 1);
                  DBMS_OUTPUT.put_line (
                        'GetValuesX: part_no='
                     || pPartNo
                     || ' lock_sid=0'
                     || ' sqlcode('
                     || SQLCODE
                     || ') sqlerrm('
                     || SQLERRM
                     || ')');
                  RETURN recpart;
            END locksid0;

            DECLARE
               cnt   NUMBER := 0;

               CURSOR bssmPartInfoCleaned (nsnParam VARCHAR2)
               IS
                  SELECT acquisition_advice_code,
                         add_increment,
                         amc_base_stock,
                         amc_days_experience,
                         amc_demand,
                         capability_requirement,
                         condemn,
                         criticality,
                         current_backorder,
                         dla_demand,
                         fedc_cost,
                         item_type,
                         mfgr,
                         mic_code,
                         min_purchase_quantity,
                         mtbdr,
                         nomenclature,
                         nrts,
                         nsn,
                         order_lead_time,
                         order_uom,
                         part_no,
                         pbl_flag,
                         planner_code,
                         rts,
                         ru_ind,
                         smr_code,
                         unit_cost
                    FROM bssm_parts bp
                   WHERE bp.nsn = nsnParam AND lock_sid = '2';
            BEGIN
               FOR rec IN bssmPartInfoCleaned (getViaPart.nsn)
               LOOP
                  IF cnt = 1
                  THEN
                     recPart.acquisition_advice_code :=
                        rec.acquisition_advice_code;
                     recPart.add_increment := rec.add_increment;
                     recPart.amc_base_stock := rec.amc_base_stock;
                     recPart.amc_days_experience := rec.amc_days_experience;
                     recPart.amc_demand := rec.amc_demand;
                     recPart.capability_requirement :=
                        rec.capability_requirement;
                     recPart.condemn_avg := rec.condemn;
                     recPart.criticality := rec.criticality;
                     recPart.current_backorder := rec.current_backorder;
                     recPart.dla_demand := rec.dla_demand;
                     recPart.fedc_cost := rec.fedc_cost;
                     recPart.item_type := rec.item_type;
                     recPart.mfgr := rec.mfgr;
                     recPart.mic_code_lowest := rec.mic_code;
                     recPart.min_purchase_quantity :=
                        rec.min_purchase_quantity;
                     recPart.mtbdr := rec.mtbdr;
                     recPart.nomenclature := rec.nomenclature;
                     recPart.nrts_avg := rec.nrts;
                     recPart.nsn := rec.nsn;
                     recPart.order_lead_time := rec.order_lead_time;
                     recPart.order_uom := rec.order_uom;
                     recPart.part_no := rec.part_no;
                     recPart.pbl_flag := rec.pbl_flag;
                     recPart.planner_code := rec.planner_code;
                     recPart.rts_avg := rec.rts;
                     recPart.ru_ind := rec.ru_ind;
                     recPart.smr_code := rec.smr_code;
                     recPart.unit_cost := rec.unit_cost;
                  END IF;
               END LOOP;

               IF cnt > 1
               THEN
                  DBMS_OUTPUT.put_line (
                        'GetValuesX: nsn='
                     || getViaPart.nsn
                     || ' lock_sid=2'
                     || ' returned '
                     || cnt
                     || ' rows.');
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  errorMsg (sqlFunction     => 'select',
                            tablename       => 'bssm_parts',
                            key1            => pPartNo,
                            key2            => '2',
                            errorLocation   => 2);
                  DBMS_OUTPUT.put_line (
                        'GetValuesX: part_no='
                     || pPartNo
                     || ' lock_sid=2'
                     || ' sqlcode('
                     || SQLCODE
                     || ') sqlerrm('
                     || SQLERRM
                     || ')');
                  RETURN recpart;
            END locksid2;


            recPart := GetCleanable (lockSidTwo);

            recPart.nsn := pNsn;
            recPart.part_no := pPartNo;

            RETURN recPart;
         EXCEPTION
            WHEN STANDARD.NO_DATA_FOUND
            THEN
               RETURN recPart;
         END getViaPart;
   END GetValuesX;

   -- if field not cleaned, GetBssmPartsRec return value will be null for that particular field.
   FUNCTION GetValues (pNsn bssm_parts.nsn%TYPE)
      RETURN partFields
   IS
      recPart          partFields := NULL;
      -- lockSidZero bssm_parts%rowtype := null;
      lockSidTwo       bssm_parts%ROWTYPE := NULL;
      currentBssmNsn   bssm_parts.nsn%TYPE;
   BEGIN
      -- pNsn comes from amd or bssm,amd may be ahead of nsn in bssm_parts => get current bssm nsn
      -- will throw exception if not available
      currentBssmNsn := amd_from_bssm_pkg.GetCurrentBssmNsn (pNsn);

      SELECT bp.*
        INTO lockSidTwo
        FROM bssm_parts bp
       WHERE bp.nsn = currentBssmNsn AND lock_sid = '2';

      recPart := GetCleanable (lockSidTwo);
      /*
      select bp.*
          into lockSidZero
          from bssm_parts bp
          where
             bp.nsn = currentBssmNsn and
             lock_sid = 0;

      recPart := GetCleanable(lockSidZero, lockSidTwo);
      */



      RETURN recPart;
   EXCEPTION
      -- will occur if cannot current bssm nsn or no lock_sid 2 entry
      WHEN NO_DATA_FOUND
      THEN
         -- return null record
         RETURN recPart;
   END GetValues;

   -- not really used anymore, here for convenience
   FUNCTION GetValues (pNsn bssm_parts.nsn%TYPE, pFieldName VARCHAR2)
      RETURN VARCHAR2
   IS
      recPart   partFields := NULL;
   BEGIN
      -- implicit conversion of numbers, dates to return type of varchar2.
      -- gets all cleaned values as a group, will be null if not cleaned
      recPart := GetValues (pNsn);

      IF (pFieldName = ADD_INCREMENT)
      THEN
         RETURN recPart.add_increment;
      ELSIF (pFieldName = AMC_BASE_STOCK)
      THEN
         RETURN recPart.amc_base_stock;
      ELSIF (pFieldName = AMC_DAYS_EXPERIENCE)
      THEN
         RETURN recPart.amc_days_experience;
      ELSIF (pFieldName = AMC_DEMAND)
      THEN
         RETURN recPart.amc_demand;
      ELSIF (pFieldName = CAPABILITY_REQUIREMENT)
      THEN
         RETURN recPart.capability_requirement;
      ELSIF (pFieldName = CONDEMN_AVG)
      THEN
         RETURN recPart.condemn_avg;
      ELSIF (pFieldName = CRITICALITY)
      THEN
         RETURN recPart.criticality;
      ELSIF (pFieldName = DLA_DEMAND)
      THEN
         RETURN recPart.dla_demand;
      ELSIF (pFieldName = CURRENT_BACKORDER)
      THEN
         RETURN recPart.current_backorder;
      ELSIF (pFieldName = FEDC_COST)
      THEN
         RETURN recPart.fedc_cost;
      ELSIF (pFieldName = ITEM_TYPE)
      THEN
         RETURN recPart.item_type;
      ELSIF (pFieldName = MIC_CODE_LOWEST)
      THEN
         RETURN recPart.mic_code_lowest;
      ELSIF (pFieldName = MTBDR)
      THEN
         RETURN recPart.mtbdr;
      ELSIF (pFieldName = MIN_PURCHASE_QUANTITY)
      THEN
         RETURN recPart.min_purchase_quantity;
      ELSIF (pFieldName = NOMENCLATURE)
      THEN
         RETURN recPart.nomenclature;
      ELSIF (pFieldName = NRTS_AVG)
      THEN
         RETURN recPart.nrts_avg;
      ELSIF (pFieldName = COST_TO_REPAIR_OFF_BASE)
      THEN
         RETURN recPart.cost_to_repair_off_base;
      ELSIF (pFieldName = TIME_TO_REPAIR_OFF_BASE)
      THEN
         RETURN recPart.time_to_repair_off_base;
      ELSIF (pFieldName = TIME_TO_REPAIR_ON_BASE_AVG)
      THEN
         RETURN recPart.time_to_repair_on_base_avg;
      ELSIF (pFieldName = ORDER_LEAD_TIME)
      THEN
         RETURN recPart.order_lead_time;
      ELSIF (pFieldName = ACQUISITION_ADVICE_CODE)
      THEN
         RETURN recPart.acquisition_advice_code;
      ELSIF (pFieldName = ORDER_UOM)
      THEN
         RETURN recPart.order_uom;
      ELSIF (pFieldName = PLANNER_CODE)
      THEN
         RETURN recPart.planner_code;
      ELSIF (pFieldName = RTS_AVG)
      THEN
         RETURN recPart.rts_avg;
      ELSIF (pFieldName = RU_IND)
      THEN
         RETURN recPart.ru_ind;
      ELSIF (pFieldName = SMR_CODE)
      THEN
         RETURN recPart.smr_code;
      ELSIF (pFieldName = UNIT_COST)
      THEN
         RETURN recPart.unit_cost;
      ELSE
         -- asking for field that is not cleanable
         RETURN NULL;
      END IF;
   END GetValues;



   FUNCTION NotEqual (pField1 VARCHAR2, pField2 VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      IF ( (pField1 IS NULL) AND (pField2 IS NULL))
      THEN
         RETURN FALSE;
      ELSIF (pField1 = pField2)
      THEN
         RETURN FALSE;
      ELSE
         RETURN TRUE;
      END IF;
   END NotEqual;


   -- thought below approach would be faster than cursor and reusing above procedures
   PROCEDURE NullAmdAllCleanedFields
   IS
   BEGIN
     <<updateAmdNationalStockItems>>
      BEGIN
         UPDATE amd_national_stock_items
            SET add_increment_cleaned = NULL,
                amc_base_stock_cleaned = NULL,
                amc_days_experience_cleaned = NULL,
                amc_demand_cleaned = NULL,
                capability_requirement_cleaned = NULL,
                condemn_avg_cleaned = NULL,
                criticality_cleaned = NULL,
                dla_demand_cleaned = NULL,
                current_backorder_cleaned = NULL,
                fedc_cost_cleaned = NULL,
                item_type_cleaned = NULL,
                mic_code_lowest_cleaned = NULL,
                mtbdr_cleaned = NULL,
                nomenclature_cleaned = NULL,
                nrts_avg_cleaned = NULL,
                order_lead_time_cleaned = NULL,
                order_uom_cleaned = NULL,
                cost_to_repair_off_base_cleand = NULL,
                time_to_repair_off_base_cleand = NULL,
                time_to_repair_on_base_avg_cl = NULL,
                planner_code_cleaned = NULL,
                rts_avg_cleaned = NULL,
                ru_ind_cleaned = NULL,
                smr_code_cleaned = NULL,
                unit_cost_cleaned = NULL,
                last_update_dt = SYSDATE;
      EXCEPTION
         WHEN OTHERS
         THEN
            errorMsg (sqlFunction     => 'update',
                      tablename       => 'amd_national_stock_items',
                      errorLocation   => 10);
            RAISE;
      END updateAmdNationalStockItems;

      BEGIN
         UPDATE amd_part_locs
            SET removal_ind_cleaned = NULL,
                repair_level_code = NULL,
                last_update_dt = SYSDATE;
      EXCEPTION
         WHEN OTHERS
         THEN
            errorMsg (sqlFunction     => 'update',
                      tablename       => 'amd_national_stock_items',
                      errorLocation   => 20);
            RAISE;
      END updatePartLocs;
   EXCEPTION
      WHEN OTHERS
      THEN
         errorMsg (sqlFunction     => 'update',
                   tablename       => 'amd_national_stock_items/amd_part_locs',
                   errorLocation   => 30);
         RAISE;
   END NullAmdAllCleanedFields;

   PROCEDURE NullAmdBaseCleanedFields (pNsn     bssm_base_parts.nsn%TYPE,
                                       pSran    bssm_base_parts.sran%TYPE)
   IS
      cleanableNull   partBaseFields := NULL;
   BEGIN
      UpdateAmdBaseCleaned (pNsn, pSran, cleanableNull);
   EXCEPTION
      WHEN OTHERS
      THEN
         errorMsg (sqlFunction     => 'update',
                   tableName       => 'amd_part_locs',
                   errorLocation   => 40,
                   key1            => pNsn,
                   key2            => pSran);
         RAISE;
   END NullAmdBaseCleanedFields;

   PROCEDURE NullAmdPartCleanedFields (pNsn bssm_parts.nsn%TYPE)
   IS
      cleanableNull   partFields := NULL;
   BEGIN
      UpdateAmdPartCleaned (pNsn, cleanableNull);
   EXCEPTION
      WHEN OTHERS
      THEN
         errorMsg (sqlFunction     => 'update',
                   tableName       => 'amd_national_stock_items',
                   errorLocation   => 50,
                   key1            => pNsn);
         RAISE;
   END NullAmdPartCleanedFields;

   PROCEDURE UpdateAmdAllBaseCleaned
   IS
      -- appears lots of lock_sid 2 recs created with no change of info.
      -- to speed up, only list those that have a change for our
      -- fields of concern (testing went from 4500 records to 88).
      CURSOR nsnSranListFromBssm_cur
      IS
         SELECT nsn,
                sran,
                repair_indicator,
                replacement_indicator
           FROM bssm_base_parts
          WHERE lock_sid = '2'
         MINUS
         SELECT nsn,
                sran,
                repair_indicator,
                replacement_indicator
           FROM bssm_base_parts
          WHERE lock_sid = '0';

      cleanableBase   partBaseFields := NULL;
   BEGIN
      FOR nsnSranBssm IN nsnSranListFromBssm_cur
      LOOP
         BEGIN
            cleanableBase := GetBaseValues (nsnSranBssm.nsn, nsnSranBssm.sran);
            UpdateAmdBaseCleaned (nsnSranBssm.nsn,
                                  nsnSranBssm.sran,
                                  cleanableBase);
         EXCEPTION
            WHEN OTHERS
            THEN
               errorMsg (sqlFunction     => 'update',
                         tablename       => 'amd_part_locs',
                         errorLocation   => 60);
               RAISE;
         END;
      END LOOP;

      COMMIT;
   END UpdateAmdAllBaseCleaned;

   PROCEDURE UpdateAmdBaseCleaned (pNsn          bssm_base_parts.nsn%TYPE,
                                   pSran         bssm_base_parts.sran%TYPE,
                                   pCleanable    partBaseFields)
   IS
      nsiSid   amd_national_stock_items.nsi_sid%TYPE;
      locSid   amd_spare_networks.loc_sid%TYPE;
   BEGIN
      -- removal indicator be cleaned.  amd_part_locs is determined by this and therefore current
      -- (i.e. no action_code delete).  since dropped and reloaded, reloading will take into
      -- account when cleaned.  choose not to delete record on fly when cleaned - affects
      -- quite a few children.
      -- i.e. wait till next load
      nsiSid := amd_utils.GetNsiSid (pNsn => pNsn);
      -- associate warehouse to 'W' in GetLocSid
      locSid := amd_from_bssm_pkg.GetLocSid (pSran);

      IF (nsiSid IS NOT NULL AND locSid IS NOT NULL)
      THEN
         UPDATE amd_part_locs
            SET repair_level_code_cleaned = pCleanable.repair_level_code,
                removal_ind_cleaned = pCleanable.removal_ind,
                last_update_dt = SYSDATE
          WHERE nsi_sid = nsiSid AND loc_sid = locSid;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
      WHEN OTHERS
      THEN
         errorMsg (sqlFunction     => 'update',
                   tablename       => 'amd_part_locs',
                   errorLocation   => 70);
         RAISE;
   END UpdateAmdBaseCleaned;

   PROCEDURE UpdateAmdAllPartCleaned
   IS
      CURSOR listFromBssm_cur
      IS
         SELECT *
           FROM bssm_parts
          WHERE lock_sid = '2';

      cleanablePart   partFields := NULL;
   -- lockSidZero bssm_parts%rowtype;
   BEGIN
      -- do those from bssm_parts.
      -- kind of slow so not using GetValues

      FOR lockSidTwo IN listFromBssm_cur
      LOOP
         BEGIN
            cleanablePart := GetCleanable (lockSidTwo);
            UpdateAmdPartCleaned (lockSidTwo.nsn, cleanablePart);
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
         EXCEPTION
            WHEN OTHERS
            THEN
               errorMsg (sqlFunction     => 'update',
                         tablename       => 'amd_national_stock_items',
                         errorLocation   => 80,
                         key1            => lockSidTwo.nsn);
               RAISE;
         END;
      END LOOP;

      COMMIT;
   END UpdateAmdAllPartCleaned;

   PROCEDURE UpdateAmdPartCleaned (pNsn          amd_national_stock_items.nsn%TYPE,
                                   pCleanable    partFields)
   IS
      nsiSid       amd_national_stock_items.nsi_sid%TYPE;
      currentNsn   amd_national_stock_items.nsn%TYPE;
   BEGIN
      nsiSid := amd_utils.GetNsiSid (pNsn => pNsn);

      -- some or most maybe null
      UPDATE amd_national_stock_items
         SET add_increment_cleaned = pCleanable.add_increment,
             amc_base_stock_cleaned = pCleanable.amc_base_stock,
             amc_days_experience_cleaned = pCleanable.amc_days_experience,
             amc_demand_cleaned = pCleanable.amc_demand,
             capability_requirement_cleaned =
                pCleanable.capability_requirement,
             condemn_avg_cleaned = pCleanable.condemn_avg,
             criticality_cleaned = pCleanable.criticality,
             dla_demand_cleaned = pCleanable.dla_demand,
             current_backorder = pCleanable.current_backorder,
             fedc_cost_cleaned = pCleanable.fedc_cost,
             item_type_cleaned = pCleanable.item_type,
             mic_code_lowest_cleaned = pCleanable.mic_code_lowest,
             mtbdr_cleaned = pCleanable.mtbdr,
             nomenclature_cleaned = pCleanable.nomenclature,
             nrts_avg_cleaned = pCleanable.nrts_avg,
             order_lead_time_cleaned = pCleanable.order_lead_time,
             order_uom_cleaned = pCleanable.order_uom,
             cost_to_repair_off_base_cleand =
                pCleanable.cost_to_repair_off_base,
             time_to_repair_off_base_cleand =
                pCleanable.time_to_repair_off_base,
             time_to_repair_on_base_avg_cl =
                pCleanable.time_to_repair_on_base_avg,
             planner_code_cleaned = pCleanable.planner_code,
             rts_avg_cleaned = pCleanable.rts_avg,
             ru_ind_cleaned = pCleanable.ru_ind,
             smr_code_cleaned = pCleanable.smr_code,
             unit_cost_cleaned = pCleanable.unit_cost,
             last_update_dt = SYSDATE
       WHERE nsi_sid = nsiSid;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         -- this would occur when cannot find nsi_sid or current nsn
         NULL;
      WHEN OTHERS
      THEN
         errorMsg (sqlFunction     => 'update',
                   tableName       => 'amd_national_stock_items',
                   errorLocation   => 70,
                   key1            => pNsn,
                   key2            => TO_CHAR (nsiSid));
         RAISE;
   END UpdateAmdPartCleaned;

   ------- trigger oriented procedures ---------
   PROCEDURE UpdateAmdPartByTrigger (pLockSidTwo bssm_parts%ROWTYPE)
   IS
      cleanablePart   partFields := NULL;
   BEGIN
      cleanablePart := GetCleanable (pLockSidTwo);
      UpdateAmdPartCleaned (pLockSidTwo.nsn, cleanablePart);
   EXCEPTION
      -- part of trigger, don't want to fail
      WHEN OTHERS
      THEN
         errorMsg (sqlFunction     => 'update',
                   tablename       => 'amd_national_stock_items',
                   errorLocation   => 80,
                   key1            => pLockSidTwo.nsn);
         RAISE;
   END UpdateAmdPartByTrigger;


   PROCEDURE UpdateAmdBaseByTrigger (pLockSidTwo bssm_base_parts%ROWTYPE)
   IS
      cleanable   partBaseFields := NULL;
   BEGIN
      cleanable := GetBaseCleanable (pLockSidTwo);
      UpdateAmdBaseCleaned (pLockSidTwo.nsn, pLockSidTwo.sran, cleanable);
   EXCEPTION
      -- part of trigger, don't want to fail
      WHEN OTHERS
      THEN
         errorMsg (sqlFunction     => 'update',
                   tableName       => 'amd_part_locs',
                   errorLocation   => 90,
                   key1            => pLockSidTwo.nsn,
                   key2            => pLockSidTwo.sran);
         RAISE;
   END UpdateAmdBaseByTrigger;


   PROCEDURE OnPartResetByTrigger (pLockSidTwo bssm_parts%ROWTYPE)
   IS
      -- bob's code on reset deletes lock_sid 2 then updates lock_sid 0
      bssmPartRec   bssm_parts%ROWTYPE;
   BEGIN
      -- on reset, values are not considered "cleaned" anymore, source systems caught up.
      NullAmdPartCleanedFields (pLockSidTwo.nsn);
      -- since amd should catch up at the same time of it's load,
      -- grab only those that currently bssm is the only source for (may be off by 10%).
      -- if want to be safer run amd_from_bssm_pkg.loadamdfrombssmraw to alleviate
      -- possible off by 10%.
      amd_from_bssm_pkg.UpdateAmdNsi (pLockSidTwo);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         errorMsg (sqlFunction     => 'update',
                   tableName       => 'amd_national_stock_items',
                   errorLocation   => 100,
                   key1            => pLockSidTwo.nsn);
         RAISE;
      WHEN OTHERS
      THEN
         errorMsg (sqlFunction     => 'update',
                   tableName       => 'amd_national_stock_items',
                   errorLocation   => 110,
                   key1            => pLockSidTwo.nsn);
         RAISE;
   END OnPartResetByTrigger;

   PROCEDURE OnBaseResetByTrigger (pLockSidTwo bssm_base_parts%ROWTYPE)
   IS
      -- bob's code on reset deletes lock_sid 2 then updates lock_sid 0
      bssmBaseRec   bssm_base_parts%ROWTYPE;
   BEGIN
      -- on reset, values are not considered "cleaned" anymore, source systems caught up.
      NullAmdBaseCleanedFields (pLockSidTwo.nsn, pLockSidTwo.sran);
      -- since amd should catch up at the same time of it's load,
      -- grab only those that currently bssm is the only source for (may be off by 10%).
      -- if want to be safer run amd_from_bssm_pkg.loadamdfrombssmraw to alleviate
      -- possible off by 10%.
      amd_from_bssm_pkg.UpdateAmdPartLocs (pLockSidTwo);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         errorMsg (sqlFunction     => 'update',
                   tableName       => 'amd_part_locs',
                   errorLocation   => 120,
                   key1            => pLockSidTwo.nsn);
         RAISE;
      WHEN OTHERS
      THEN
         errorMsg (sqlFunction     => 'update',
                   tableName       => 'amd_part_locs',
                   errorLocation   => 130,
                   key1            => pLockSidTwo.nsn);
         RAISE;
   END OnBaseResetByTrigger;

   PROCEDURE version
   IS
   BEGIN
      writeMsg (pTableName        => 'amd_cleaned_from_bssm_pkg',
                pError_location   => 140,
                pKey1             => 'amd_cleaned_from_bssm_pkg',
                pKey2             => '$Revision:   1.19  $');
   END version;
BEGIN
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
   gModflag1Map (POWER (2, 9)) := pbl_flag; -- no cleaned spot in amd, but still get it
   gModflag1Map (POWER (2, 10)) := MFGR; -- no cleaned spot in amd, but still get it
   gModflag1Map (POWER (2, 11)) := ADD_INCREMENT;
   gModflag1Map (POWER (2, 12)) := COST_TO_REPAIR_OFF_BASE; -- OFF_BASE_REPAIR_COST
   gModflag1Map (POWER (2, 13)) := ORDER_UOM;                      /* UNITS */
   gModflag1Map (POWER (2, 14)) := PLANNER_CODE;
   gModflag1Map (POWER (2, 15)) := MIC_CODE_LOWEST;
   gModflag1Map (POWER (2, 16)) := SMR_CODE;
   gModflag1Map (POWER (2, 19)) := MONTHLY_DEMAND_RATE;    -- not an amd field
   gModflag1Map (POWER (2, 21)) := NOMENCLATURE;
   gModflag1Map (POWER (2, 22)) := WUC;  -- no cleaned spot in amd, but get it
   gModflag1Map (POWER (2, 23)) := CURRENT_BACKORDER;
   gModflag1Map (POWER (2, 24)) := DLA_DEMAND;
   gModflag1Map (POWER (2, 25)) := AMC_DEMAND;
   gModflag1Map (POWER (2, 26)) := AMC_DAYS_EXPERIENCE;
   gModflag1Map (POWER (2, 27)) := AMC_BASE_STOCK;
   gModflag1Map (POWER (2, 28)) := MTBDR;
   gModflag1Map (POWER (2, 29)) := MIN_PURCHASE_QUANTITY;


   -- modflag2
   gModflag2Map (POWER (2, 10)) := UNIT_COST;
   gModflag2Map (POWER (2, 11)) := FEDC_COST;
   gModflag2Map (POWER (2, 12)) := RU_IND;
   gModflag2Map (POWER (2, 13)) := ITEM_TYPE;
   gModflag2Map (POWER (2, 14)) := CAPABILITY_REQUIREMENT;         -- CATEGORY
   gModflag2Map (POWER (2, 15)) := CRITICALITY;
   gModflag2Map (POWER (2, 16)) := RTS_AVG;                             -- RTS
   gModflag2Map (POWER (2, 17)) := NRTS_AVG;                           -- NRTS
   gModflag2Map (POWER (2, 18)) := CONDEMN_AVG;                     -- CONDEMN
   gModflag2Map (POWER (2, 19)) := TIME_TO_REPAIR_ON_BASE_AVG; -- ON_BASE_TURNAROUND, TBASE
   gModflag2Map (POWER (2, 20)) := TIME_TO_REPAIR_OFF_BASE; -- OFF_BASE_TURNAROUND,TDEPOT
   gModflag2Map (POWER (2, 21)) := ORDER_LEAD_TIME;                -- TCONDEMN
   gModflag2Map (POWER (2, 26)) := ACQUISITION_ADVICE_CODE;


   -- decide to separate base specific into their own array,
   -- but still matches bob's "power".
   gSetflagBaseMap (POWER (2, 0)) := REPAIR_LEVEL_CODE;
   gSetflagBaseMap (POWER (2, 1)) := REMOVAL_IND;
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



END AMD_CLEANED_FROM_BSSM_PKG;
/


DROP PUBLIC SYNONYM AMD_CLEANED_FROM_BSSM_PKG;

CREATE PUBLIC SYNONYM AMD_CLEANED_FROM_BSSM_PKG FOR AMD_OWNER.AMD_CLEANED_FROM_BSSM_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_CLEANED_FROM_BSSM_PKG TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_CLEANED_FROM_BSSM_PKG TO BSSM_OWNER WITH GRANT OPTION;
