CREATE OR REPLACE PACKAGE AMD_OWNER.AMD_CLEANED_FROM_BSSM_PKG
IS
   /*
    PVCS Keywords

      $Author:   zf297a  $
    $Revision:   1.9  $
        $Date:   11 May 2007 12:09:38  $
    $Workfile:   AMD_CLEANED_FROM_BSSM_PKG.pks  $
      $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_cleaned_from_bssm_pkg.pks-arc  $

     Rev 1.9   11 May 2007 12:09:38   zf297a
  Renamed gold_mfgr_cage to pbl_flag for BSSM V604

     Rev 1.8   Jun 09 2006 12:47:12   zf297a
  added interface version

     Rev 1.8   Aug 23 2005 12:27:14   zf297a
  Added funciont GetValuesX - it retireves bssm via the nsn or the part_no.  If the data is not found via the nsn, the routine attempts to find it via the part_no.

     Rev 1.7   May 17 2005 11:05:56   c970183
  added new cleaned fields.  added fields that are not part of amd, but could provide an easy way to get field from bssm

     Rev 1.6   May 17 2005 10:26:48   c970183
  Changed dla_wareshouse_stock to current_backorder

     Rev 1.5   May 06 2005 07:36:58   c970183
  changed dla_warehouse_stcok to current_backorder.  added pvcs keywords
   */



   -- constant name is amd field name, value is corresponding bssm field name.
   -- more of a visual reference.
   ACQUISITION_ADVICE_CODE      CONSTANT VARCHAR2 (30)
                                            := 'ACQUISITION_ADVICE_CODE' ;
   ADD_INCREMENT                CONSTANT VARCHAR2 (30) := 'ADD_INCREMENT';
   AMC_BASE_STOCK               CONSTANT VARCHAR2 (30) := 'AMC_BASE_STOCK';
   AMC_DAYS_EXPERIENCE          CONSTANT VARCHAR2 (30) := 'AMC_DAYS_EXPERIENCE';
   AMC_DEMAND                   CONSTANT VARCHAR2 (30) := 'AMC_DEMAND';
   CAPABILITY_REQUIREMENT       CONSTANT VARCHAR2 (30)
                                            := 'CAPABILITY_REQUIREMENT' ; -- CATEGORY
   CONDEMN_AVG                  CONSTANT VARCHAR2 (30) := 'CONDEMN';
   COST_TO_REPAIR_OFF_BASE      CONSTANT VARCHAR2 (30) := 'OFF_BASE_REPAIR_COST';
   CRITICALITY                  CONSTANT VARCHAR2 (30) := 'CRITICALITY';
   DLA_DEMAND                   CONSTANT VARCHAR2 (30) := 'DLA_DEMAND';
   CURRENT_BACKORDER            CONSTANT VARCHAR2 (30) := 'CURRENT_BACKORDER';
   FEDC_COST                    CONSTANT VARCHAR2 (30) := 'FEDC_COST';
   PBL_FLAG                     CONSTANT VARCHAR2 (30) := 'GOLD_MFGR_CAGE'; -- not an amd fiueld
   ITEM_TYPE                    CONSTANT VARCHAR2 (30) := 'ITEM_TYPE';
   MFGR                         CONSTANT VARCHAR2 (30) := 'MFGR'; -- not cleaned in amd
   MIC_CODE_LOWEST              CONSTANT VARCHAR2 (30) := 'MIC_CODE';
   MTBDR                        CONSTANT VARCHAR2 (30) := 'MTBDR';
   MIN_PURCHASE_QUANTITY        CONSTANT VARCHAR2 (30)
                                            := 'MIN_PURCHASE_QUANTITY' ;
   MONTHLY_DEMAND_RATE          CONSTANT VARCHAR2 (30) := 'MONTHLY_DEMAND_RATE';
   NOMENCLATURE                 CONSTANT VARCHAR2 (30) := 'NOMENCLATURE';
   NRTS_AVG                     CONSTANT VARCHAR2 (30) := 'NRTS';
   ORDER_LEAD_TIME              CONSTANT VARCHAR2 (30) := 'ORDER_LEAD_TIME'; -- TCONDEMN
   ORDER_UOM                    CONSTANT VARCHAR2 (30) := 'ORDER_UOM'; /* UNITS */
   PLANNER_CODE                 CONSTANT VARCHAR2 (30) := 'PLANNER_CODE';
   RTS_AVG                      CONSTANT VARCHAR2 (30) := 'RTS';
   RU_IND                       CONSTANT VARCHAR2 (30) := 'RU_IND';
   SMR_CODE                     CONSTANT VARCHAR2 (30) := 'SMR_CODE';
   TIME_TO_REPAIR_OFF_BASE      CONSTANT VARCHAR2 (30) := 'OFF_BASE_TURNAROUND'; -- TDEPOT
   TIME_TO_REPAIR_ON_BASE_AVG   CONSTANT VARCHAR2 (30)
                                            := 'ON_BASE_TURNAROUND' ; -- TBASE
   UNIT_COST                    CONSTANT VARCHAR2 (30) := 'UNIT_COST';
   WUC                          CONSTANT VARCHAR2 (30) := 'WUC'; -- not an amd field

   -- base specific cleanable fields
   REMOVAL_IND                  CONSTANT VARCHAR2 (30)
                                            := 'REPLACEMENT_INDICATOR' ;
   REPAIR_LEVEL_CODE            CONSTANT VARCHAR2 (30) := 'REPAIR_INDICATOR';

   -- if field needs to be converted, eg. item_type, criticality, from bssm to
   -- amd, any function in this package will return the converted value that
   -- amd needs.
   TYPE partFields IS RECORD
   (
      nsn                          amd_national_stock_items.nsn%TYPE,
      part_no                      amd_spare_parts.PART_NO%TYPE,
      add_increment                amd_national_stock_items.add_increment%TYPE,
      amc_base_stock               amd_national_stock_items.amc_base_stock%TYPE,
      amc_days_experience          amd_national_stock_items.amc_days_experience%TYPE,
      amc_demand                   amd_national_stock_items.amc_demand%TYPE,
      capability_requirement       amd_national_stock_items.capability_requirement%TYPE,
      condemn_avg                  amd_national_stock_items.condemn_avg%TYPE,
      cost_to_repair_off_base      amd_national_stock_items.cost_to_repair_off_base_cleand%TYPE,
      criticality                  amd_national_stock_items.criticality%TYPE,
      dla_demand                   amd_national_stock_items.dla_demand%TYPE,
      current_backorder            amd_national_stock_items.current_backorder%TYPE,
      fedc_cost                    amd_national_stock_items.fedc_cost%TYPE,
      item_type                    amd_national_stock_items.item_type%TYPE,
      mic_code_lowest              amd_national_stock_items.mic_code_lowest%TYPE,
      mtbdr                        amd_national_stock_items.mtbdr%TYPE,
      min_purchase_quantity        amd_national_stock_items.min_purchase_quantity%TYPE,
      nomenclature                 amd_national_stock_items.nomenclature_cleaned%TYPE,
      nrts_avg                     amd_national_stock_items.nrts_avg%TYPE,
      order_lead_time              amd_national_stock_items.order_lead_time_cleaned%TYPE,
      acquisition_advice_code      bssm_owner.bssm_parts.ACQUISITION_ADVICE_CODE%TYPE,
      order_uom                    amd_national_stock_items.order_uom_cleaned%TYPE,
      planner_code                 amd_national_stock_items.planner_code%TYPE,
      rts_avg                      amd_national_stock_items.rts_avg%TYPE,
      ru_ind                       amd_national_stock_items.ru_ind%TYPE,
      smr_code                     amd_national_stock_items.smr_code%TYPE,
      time_to_repair_off_base      amd_national_stock_items.time_to_repair_on_base_avg%TYPE,
      time_to_repair_on_base_avg   amd_national_stock_items.time_to_repair_on_base_avg%TYPE,
      unit_cost                    amd_national_stock_items.unit_cost_cleaned%TYPE,
      mfgr                         amd_spare_parts.MFGR%TYPE,
      pbl_flag                     bssm_owner.bssm_parts.PBL_FLAG%TYPE
   );

   TYPE partBaseFields IS RECORD
   (
      nsn                 amd_national_stock_items.nsn%TYPE,
      loc_id              amd_spare_networks.loc_id%TYPE,
      removal_ind         amd_part_locs.removal_ind%TYPE,
      repair_level_code   amd_part_locs.repair_level_code%TYPE
   );

   -- part specific

   FUNCTION GetValues (pNsn bssm_parts.nsn%TYPE)
      RETURN partFields;

   FUNCTION GetValuesX (pNsn       bssm_parts.nsn%TYPE,
                        pPartNo    bssm_parts.part_no%TYPE)
      RETURN partFields;

   FUNCTION GetValues (pNsn bssm_parts.nsn%TYPE, pFieldName VARCHAR2)
      RETURN VARCHAR2;

   -- base specific
   FUNCTION GetBaseValues (pNsn     bssm_base_parts.nsn%TYPE,
                           pSran    bssm_base_parts.sran%TYPE)
      RETURN partBaseFields;

   FUNCTION GetBaseValues (pNsn          bssm_base_parts.nsn%TYPE,
                           pSran         bssm_base_parts.sran%TYPE,
                           pFieldName    VARCHAR2)
      RETURN VARCHAR2;


   -- update all cleaned by listing all in bssm_parts for lock_sid 2
   PROCEDURE UpdateAmdAllPartCleaned;

   PROCEDURE UpdateAmdAllBaseCleaned;

   PROCEDURE NullAmdAllCleanedFields;

   -- update used by trigger
   PROCEDURE UpdateAmdPartByTrigger (pLockSidTwo bssm_parts%ROWTYPE);

   PROCEDURE UpdateAmdBaseByTrigger (pLockSidTwo bssm_base_parts%ROWTYPE);

   PROCEDURE OnPartResetByTrigger (pLockSidTwo bssm_parts%ROWTYPE);

   PROCEDURE OnBaseResetByTrigger (pLockSidTwo bssm_base_parts%ROWTYPE);

   -- added 6/9/2006 by dse
   PROCEDURE version;
END AMD_CLEANED_FROM_BSSM_PKG;
/