DROP PACKAGE AMD_OWNER.AMD_DEFAULTS;

CREATE OR REPLACE PACKAGE AMD_OWNER.amd_defaults
AS
   /*

    $Author:   zf297a  $
  $Revision:   1.37 $
      $Date:   21 Sep 2015
  $Workfile:   amd_defaults.pks  $

     Rev 1.37 9/21/2015 added program_id

     Rev 1.36 2/23/2015 added start_loc_id

     Rev 1.35 2/5/2015 added non_stockage_list

     Rev 1.34 2/4/2015 added icp_ind.  source_of_supply new_nsn,, and source_code

     Rev 1.33 fixed bom & bom_quantity definitions since the tmp_a2a_bom_detail table was dropped

     Rev 1.32   09 Jul 2008 14:41:36   zf297a
  Added interfaces:
  function getCONSUMABLE_PLANNER_CODE return  amd_planners.PLANNER_CODE%type ;
  function getCONSUMABLE_LOGON_ID return
   amd_users.BEMS_ID%type ;
  function getREPAIRABLE_PLANNER_CODE return  amd_planners.PLANNER_CODE%type ;
  function getREPAIRABLE_LOGON_ID return  amd_users.BEMS_ID%type ;

     Rev 1.31   22 May 2008 16:47:58   zf297a
  Added interface for getVersion.

     Rev 1.30   22 May 2008 11:00:26   zf297a
  Changed AMD_AUS_SC, AMD_BASC_SC, AMD_CAN_SC, and AMD_UK_SC to variables that wiill either use their default literal or be initialized by data from the amd_param_changes table.  Define a varray to contain all the segment codes used to flag Foreign Military Sales.

     Rev 1.29   14 Nov 2007 12:08:04   zf297a
  Added interface for getTIME_TO_REPAIR_OFFBASE

     Rev 1.28   24 Oct 2007 17:36:16   zf297a
  Added ROP / ROQ default values and the functions to get them.

     Rev 1.27   12 Oct 2007 17:23:22   zf297a
  Added constants: AMD_BASC_LOC_ID, AMD_BASC_SC, AMD_UK_SC, AMD_CAN_LOC_ID, AMD_CAN_SC, AMD_AUS_LOC_ID, AMD_AUS_SC, AMD_WARNER_ROBINS_LOC_ID and related get functions.

     Rev 1.26   11 Oct 2007 23:33:36   zf297a
  Added TSL_CONSUMABL_CALENDAR_DAYS and function getTSL_CONSUMABL_CALENDAR_DAYS

     Rev 1.25   11 Oct 2007 12:42:40   zf297a
  Added Canada loc_id and added interface getAMD_CAN_LOC_ID

     Rev 1.24   28 Jun 2007 12:23:32   zf297a
  Added date_lvl_loaded_modifier and a get function for this number used by the load query for consumable gold.lvls.

     Rev 1.23   12 Apr 2007 09:31:16   zf297a
  defined interfaces for PSMS_COMMIT_TRESHOLD, GOLD_COMMIT_TRESHOLD, TEMP_NSNS_COMMIT_THRESHOLD, MAIN_COMMIT_THRESHOLD, and PARTSTUC_COMMIT_THRESHOLD.

     Rev 1.22   03 Apr 2007 14:32:38   zf297a
  Define interfaces:
  getNSN_LOGON_ID
  getNSL_LOGON_ID
  getNSN_PLANNER_CODE
  getNSL_PLANNER_CODE
  getCLEAN_DATA_DAY
  checkDefaultPlanners
  checkDefaultLogonIds

     Rev 1.21   22 Mar 2007 16:45:58   zf297a
  added constant AMD_AUS_LOC_ID and its get function interface

     Rev 1.20   Oct 26 2006 12:10:32   zf297a
  Added boolean flag STRICT.  This will be used to determine if an exception should be raised for certain errors that in most cases are not critical.

     Rev 1.19   Jun 09 2006 12:55:24   zf297a
  added interface version

     Rev 1.18   Nov 30 2005 10:56:18   zf297a
  added bom_quantity and bom

     Rev 1.17   Nov 01 2005 12:32:52   zf297a
  Added some more "getter" functions for other constants.

     Rev 1.16   Nov 01 2005 12:21:34   zf297a
  Simplified the name of the "getter's" to getCONSTANT where CONSTANT is the identifier for the associated constant.

     Rev 1.15   Nov 01 2005 11:50:32   zf297a
  Added "getter 's" (get functions) for some of the constant's so they can be used in ordinary SQL instead of only in PL/SQL code.

     Rev 1.14   Sep 13 2005 11:04:02   zf297a
  Added interfaces for isParamKey and addParamKey.

     Rev 1.13   Jul 08 2005 09:08:38   zf297a
  added the public function getLogonId

     Rev 1.12   Jul 08 2005 08:58:36   zf297a
  Added the public function getPlannerCode

     Rev 1.11   Jul 05 2005 13:54:12   zf297a
  added $Log$ PVCS keyword

     10/02/01 Douglas Elder Initial implementation
        Although variables that are CAPITALIZED
       are usually "constant's", these variables
       are quasi-constants, since they rarely change,
       but they are initialized from values stored
       in an Oracle table.  Some values are returned
       via functions, since they are dependent on
       the value of other variables.
 6/07/05  KS    Add more constants and defaults
    */



   TYPE fmsSegCodeTab IS VARRAY (4) OF whse.sc%TYPE; -- added 5/22/2008 by dse

   fmsSegCodes                         fmsSegCodeTab; -- added 5/22/2008 by dse

   STRICT                              BOOLEAN := FALSE; -- raise errors when true

   -- added 6/28/2007 by dse
   DATE_LVL_LOADED_MODIFIER            NUMBER := 210;

   FUNCTION getDATE_LVL_LOADED_MODIFIER
      RETURN NUMBER;

   -- added 4/12/2007 by dse
   PSMS_COMMIT_THRESHOLD               NUMBER := 1000;

   FUNCTION getPSMS_COMMIT_THRESHOLD
      RETURN NUMBER;

   -- added 4/12/2007 by dse
   MAIN_COMMIT_THRESHOLD               NUMBER := 1000;

   FUNCTION getMAIN_COMMIT_THRESHOLD
      RETURN NUMBER;

   -- added 4/12/2007 by dse
   TEMP_NSNS_COMMIT_THRESHOLD          NUMBER := 1000;

   FUNCTION getTEMP_NSNS_COMMIT_THRESHOLD
      RETURN NUMBER;

   -- added 4/12/2007 by dse
   GOLD_COMMIT_THRESHOLD               NUMBER := 1000;

   FUNCTION getGOLD_COMMIT_THRESHOLD
      RETURN NUMBER;

   -- added 4/12/2007 by dse
   PARTSTRUC_COMMIT_THRESHOLD          NUMBER := 1000;

   FUNCTION getPARTSTRUC_COMMIT_THRESHOLD
      RETURN NUMBER;

   CONDEMN_AVG                         amd_national_stock_items.condemn_avg%TYPE
                                          := NULL;
   CONSUMABLE                 CONSTANT amd_national_stock_items.item_type%TYPE
                                          := 'C' ;

   FUNCTION getCONSUMABLE
      RETURN VARCHAR2;

   DELETE_ACTION              CONSTANT amd_spare_parts.action_code%TYPE := 'D';

   FUNCTION getDELETE_ACTION
      RETURN VARCHAR2;

   DISPOSAL_COST                       amd_spare_parts.disposal_cost%TYPE := NULL;
   DISTRIB_UOM                         amd_national_stock_items.distrib_uom%TYPE
                                          := NULL;
   INSERT_ACTION              CONSTANT amd_spare_parts.action_code%TYPE := 'A';

   FUNCTION getINSERT_ACTION
      RETURN VARCHAR2;

   NOT_PRIME_PART             CONSTANT amd_nsi_parts.prime_ind%TYPE := 'N';
   NRTS_AVG                            amd_national_stock_items.nrts_avg%TYPE
                                          := NULL;

   OFF_BASE_TURN_AROUND                amd_part_locs.time_to_repair%TYPE := NULL;

   FUNCTION GetOrderLeadTime (
      pItem_type   IN amd_national_stock_items.item_type%TYPE)
      RETURN amd_spare_parts.order_lead_time_defaulted%TYPE;

   ORDER_QUANTITY                      amd_national_stock_items.order_quantity%TYPE
                                          := NULL;

   ORDER_UOM                           amd_spare_parts.order_uom%TYPE := NULL;
   PRIME_PART                 CONSTANT amd_nsi_parts.prime_ind%TYPE := 'Y';

   QPEI_WEIGHTED                       amd_national_stock_items.qpei_weighted%TYPE
                                          := NULL;
   REPAIRABLE                 CONSTANT amd_national_stock_items.item_type%TYPE
                                          := 'R' ;

   FUNCTION getREPAIRABLE
      RETURN VARCHAR2;

   RTS_AVG                             amd_national_stock_items.rts_avg%TYPE := NULL;
   SCRAP_VALUE                         amd_spare_parts.scrap_value%TYPE := NULL;
   SHELF_LIFE                          amd_spare_parts.shelf_life%TYPE := NULL;


   TIME_TO_REPAIR_ON_BASE_AVG          amd_national_stock_items.time_to_repair_on_base_avg_df%TYPE
      := NULL;

   BOM_QUANTITY                        NUMBER := 1;
   BOM                                 VARCHAR2 (8) := 'C17';

   FUNCTION GetUnitCost (
      pNsn            IN amd_spare_parts.nsn%TYPE,
      pPart_no        IN amd_spare_parts.part_no%TYPE,
      pMfgr           IN amd_spare_parts.mfgr%TYPE,
      pSmr_code       IN amd_national_stock_items.smr_code%TYPE,
      pPlanner_code   IN amd_national_stock_items.planner_code%TYPE)
      RETURN amd_spare_parts.unit_cost_defaulted%TYPE;

   FUNCTION getPlannerCode (nsn IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION getLogonId (nsn IN VARCHAR2)
      RETURN VARCHAR2;

   UNIT_VOLUME                         amd_spare_parts.unit_volume%TYPE := NULL;
   UPDATE_ACTION              CONSTANT amd_spare_parts.action_code%TYPE := 'C';

   FUNCTION getUPDATE_ACTION
      RETURN VARCHAR2;

   USE_BSSM_TO_GET_NSLs                VARCHAR2 (1) := NULL;

   COST_TO_REPAIR_ONBASE               amd_part_locs.cost_to_repair%TYPE := NULL;
   TIME_TO_REPAIR_ONBASE               amd_part_locs.time_to_repair%TYPE := NULL;
   TIME_TO_REPAIR_OFFBASE              amd_part_locs.time_to_repair%TYPE := NULL;

   FUNCTION getTIME_TO_REPAIR_OFFBASE
      RETURN amd_part_locs.time_to_repair%TYPE;

   UNIT_COST_FACTOR_OFFBASE            NUMBER := 0;

   /* ks add 06/07/05
   -- expose GetParamValue
   -- constants
   */
   FUNCTION GetParamValue (key IN VARCHAR2)
      RETURN amd_param_changes.param_value%TYPE;

   -- added 9/3/2005 dse
   PROCEDURE setParamValue (key IN VARCHAR2, VALUE IN VARCHAR2);

   AMD_WAREHOUSE_LOCID        CONSTANT amd_spare_networks.loc_id%TYPE := 'CTLATL';

   FUNCTION getAMD_WAREHOUSE_LOCID
      RETURN VARCHAR2;

   BSSM_WAREHOUSE_SRAN        CONSTANT bssm_bases.sran%TYPE := 'W';

   FUNCTION getBSSM_WAREHOUSE_SRAN
      RETURN VARCHAR2;

   AMD_AUS_LOC_ID             CONSTANT amd_spare_networks.loc_id%TYPE := 'EY1258';

   FUNCTION getAMD_AUS_LOC_ID
      RETURN VARCHAR2;

   AMD_AUS_SC                          whse.sc%TYPE := 'C17%CODAUSG'; -- added 100/11/2007 by dse

   FUNCTION getAMD_AUS_SC
      RETURN VARCHAR2;                              -- added 10/11/2007 by dse

   AMD_CAN_LOC_ID             CONSTANT amd_spare_networks.loc_id%TYPE := 'EY1414'; -- added 10/11/2007 by dse

   FUNCTION getAMD_CAN_LOC_ID
      RETURN VARCHAR2;                              -- added 10/11/2007 by dse

   AMD_CAN_SC                          whse.sc%TYPE := 'C17%CODCANG'; -- added 10/11/2007 by dse

   FUNCTION getAMD_CAN_SC
      RETURN VARCHAR2;                              -- added 10/11/2007 by dse

   AMD_UK_LOC_ID              CONSTANT amd_spare_networks.loc_id%TYPE := 'EY8780';

   FUNCTION getAMD_UK_LOC_ID
      RETURN VARCHAR2;

   AMD_UK_SC                           whse.sc%TYPE := 'C17%CODUKBG'; -- added 10/11/2007 by dse

   FUNCTION getAMD_UK_SC
      RETURN VARCHAR2;                              -- added 10/11/2007 by dse

   AMD_BASC_LOC_ID            CONSTANT amd_spare_networks.loc_id%TYPE := 'EY1746';

   FUNCTION getAMD_BASC_LOC_ID
      RETURN VARCHAR2;

   AMD_BASC_SC                         whse.sc%TYPE := 'C17PCAG'; -- added 10/11/2007 by dse

   FUNCTION getAMD_BASC_SC
      RETURN VARCHAR2;                              -- added 10/11/2007 by dse

   AMD_VUB_LOC_ID             CONSTANT amd_spare_networks.loc_id%TYPE := 'FB4490';

   FUNCTION getAMD_VUB_LOC_ID
      RETURN VARCHAR2;

   AMD_WARNER_ROBINS_LOC_ID   CONSTANT amd_spare_networks.loc_id%TYPE
                                          := 'FB2065' ; -- added 10/11/2007 by dse

   FUNCTION getAMD_WARNER_ROBINS_LOC_ID
      RETURN VARCHAR2;                              -- added 10/11/2007 by dse

   --AMD_VCD_LOC_ID  CONSTANT amd_spare_networks.loc_id%TYPE := '?' ;

   NSN_PLANNER_CODE                    amd_planners.PLANNER_CODE%TYPE := NULL;

   FUNCTION getNSN_PLANNER_CODE
      RETURN amd_planners.PLANNER_CODE%TYPE;

   NSN_LOGON_ID                        amd_planner_logons.LOGON_ID%TYPE
                                          := NULL;

   FUNCTION getNSN_LOGON_ID
      RETURN amd_users.BEMS_ID%TYPE;

   NSL_PLANNER_CODE                    amd_planners.PLANNER_CODE%TYPE := NULL;

   FUNCTION getNSL_PLANNER_CODE
      RETURN amd_planners.PLANNER_CODE%TYPE;

   NSL_LOGON_ID                        amd_planner_logons.LOGON_ID%TYPE
                                          := NULL;

   FUNCTION getNSL_LOGON_ID
      RETURN amd_users.BEMS_ID%TYPE;

   CONSUMABLE_PLANNER_CODE             amd_planners.PLANNER_CODE%TYPE := NULL;

   FUNCTION getCONSUMABLE_PLANNER_CODE
      RETURN amd_planners.PLANNER_CODE%TYPE;

   CONSUMABLE_LOGON_ID                 amd_planner_logons.LOGON_ID%TYPE
                                          := NULL;

   FUNCTION getCONSUMABLE_LOGON_ID
      RETURN amd_users.BEMS_ID%TYPE;

   REPAIRABLE_PLANNER_CODE             amd_planners.PLANNER_CODE%TYPE := NULL;

   FUNCTION getREPAIRABLE_PLANNER_CODE
      RETURN amd_planners.PLANNER_CODE%TYPE;

   REPAIRABLE_LOGON_ID                 amd_planner_logons.LOGON_ID%TYPE
                                          := NULL;

   FUNCTION getREPAIRABLE_LOGON_ID
      RETURN amd_users.BEMS_ID%TYPE;


   CLEAN_DATA_DAY                      VARCHAR2 (10) := NULL;

   FUNCTION getCLEAN_DATA_DAY
      RETURN VARCHAR2;

   TSL_CONSUMABL_CALENDAR_DAYS         NUMBER := 210;

   FUNCTION getTSL_CONSUMABL_CALENDAR_DAYS
      RETURN NUMBER;

   FUNCTION isParamKey (key IN VARCHAR2)
      RETURN BOOLEAN;

   PROCEDURE addParamKey (key IN VARCHAR2, description IN VARCHAR2);

   -- added 6/09/2006 by dse
   PROCEDURE version;

   PROCEDURE checkDefaultPlanners;

   PROCEDURE checkDefaultLogonIds;

   ROP                                 NUMBER := -1; -- added 10/18/2007 by dse

   FUNCTION getROP
      RETURN NUMBER;

   ROQ                                 NUMBER := 1;        -- added 10/18/2007

   FUNCTION getROQ
      RETURN NUMBER;

   ICP_IND                             amd_spare_parts.icp_ind%TYPE := 'F77'; -- added 2/4/2005

   FUNCTION getIcpInd
      RETURN VARCHAR2;

   source_code                         CAT1.SOURCE_CODE%TYPE := 'F77'; -- added 2/4/2005

   FUNCTION getSourceCode
      RETURN VARCHAR2;


   source_of_supply                    VARCHAR2 (5) := 'F77'; -- added 2/4/2005

   FUNCTION getSourceOfSupply
      RETURN VARCHAR2;


   NON_STOCKAGE_LIST                   amd_spare_parts.nsn%TYPE := 'NSL'; -- added 2/5/2005

   FUNCTION getNonStockageList
      RETURN VARCHAR2;

   START_LOC_ID                        NUMBER := 8;

   FUNCTION getStartLocId
      RETURN NUMBER;

   PROGRAM_ID                          VARCHAR2 (30) := 'C17'; -- added 9/21/2015

   FUNCTION getProgramId
      RETURN VARCHAR2;

   LIKE_NEW_NSN                        VARCHAR2 (4) := 'NSL%'; -- added 5/19/2017

   FUNCTION getLikeNewNSN
      RETURN VARCHAR2;

   FUNCTION getVersion
      RETURN VARCHAR2;                               -- added 5/22/2008 by dse
END amd_defaults;
/


DROP PUBLIC SYNONYM AMD_DEFAULTS;

CREATE PUBLIC SYNONYM AMD_DEFAULTS FOR AMD_OWNER.AMD_DEFAULTS;


GRANT EXECUTE ON AMD_OWNER.AMD_DEFAULTS TO AMD_WRITER_ROLE;
