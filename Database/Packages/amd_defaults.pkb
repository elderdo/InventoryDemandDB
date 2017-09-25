CREATE OR REPLACE PACKAGE BODY AMD_OWNER.amd_defaults
AS
   /*

       $Author:   zf297a  $
     $Revision:   1.46
         $Date:   19 May 2017
     $Workfile:   amd_defaults.pkb  $

       Rev 1.46 5/19/17 dse added getLikeNewNsn

       Rev 1.45 9/21/15 dse added getProgramId

       Rev 1.44 2/23/15 dse added getStartLocId

       rev 1.43 2/4/15 dse added getIcpInd, getSourceCode, getSourceOfSupply, and getNonStockageList

       rev 1.42 removed a2a dependencies

        Rev 1.41   09 Jul 2008 14:43:06   zf297a
     Implemented interfaces:
     function getCONSUMABLE_PLANNER_CODE return  amd_planners.PLANNER_CODE%type ;
     function getCONSUMABLE_LOGON_ID return
      amd_users.BEMS_ID%type ;
     function getREPAIRABLE_PLANNER_CODE return  amd_planners.PLANNER_CODE%type ;
     function getREPAIRABLE_LOGON_ID return  amd_users.BEMS_ID%type ;

     and initialized CONSUMABLE_PLANNER_CODE,
     CONSUMABLE_LOGON_ID,
     REPAIRABLE_PLANNER_CODE,
     and REPAIRABLE_LOGON_ID.

        Rev 1.40   22 May 2008 16:48:26   zf297a
     Implemeted interface for getVersion.

        Rev 1.39   22 May 2008 11:02:26   zf297a
     For variables AMD_AUS_SC, AMD_BASC_SC, AMD_CAN_SC, and AMD_UK_SC use their default literal or initialize by getting data from the amd_param_changes table.  Load the fmsSegCodes varray with these values.

        Rev 1.38   14 Nov 2007 12:08:22   zf297a
     implemented interface for getTIME_TO_REPAIR_OFFBASE

        Rev 1.37   24 Oct 2007 17:36:58   zf297a
     Implemnted ROP / ROQ get functions

        Rev 1.36   12 Oct 2007 17:23:58   zf297a
     implemented get functions for new constants.

        Rev 1.35   11 Oct 2007 23:35:06   zf297a
     Check for TSL_CONSUMABL_CALENDAR_DAYS in amd_param_changes using name tsl_consumabl_calendar_days, if not found default to 210.
     Implemented function getTSL_CONSUMABL_CALENDAR_DAYS.

        Rev 1.34   11 Oct 2007 12:43:10   zf297a
     implemented interface getAMD_CAN_LOC_ID

        Rev 1.33   28 Jun 2007 12:25:16   zf297a
     Implemented getDATE_LVL_LOAED_MODIFIER: this number is used by the load query for consumable gold.lvls.

        Rev 1.32   12 Apr 2007 09:31:36   zf297a
     implemented interfaces for PSMS_COMMIT_TRESHOLD, GOLD_COMMIT_TRESHOLD, TEMP_NSNS_COMMIT_THRESHOLD, MAIN_COMMIT_THRESHOLD, and PARTSTUC_COMMIT_THRESHOLD.

        Rev 1.31   03 Apr 2007 14:33:30   zf297a
     Implemented the following interfaces:
     getNSN_LOGON_ID
     getNSL_LOGON_ID
     getNSN_PLANNER_CODE
     getNSL_PLANNER_CODE
     getCLEAN_DATA_DAY
     checkDefaultPlanners
     checkDefaultLogonIds

        Rev 1.30   22 Mar 2007 16:46:14   zf297a
     Implemented getAMD_AUS_LOC_ID  function

        Rev 1.29   Oct 26 2006 12:13:38   zf297a
     Removed writeMsg - since some of the default functions are used in sql queries there cannot be DML that inserts or updates.   Test the STRICT flag to see if an exception should be raised when default values cannot be verified against amd tables.  Added code to initialize the STRICT flag via the amd_param_changes table.

        Rev 1.28   Oct 24 2006 14:19:42   zf297a
     Fixed getNsnLogonId and getNslLogonId to validate the logon_id against amd_planner_logons using a select with an exists clause because more than one row could exist for a give logon_id and planner_code since there are multiple data_sources.
     Changed the dbms_output message to a writeMsg so any error messages get logged to amd_load_details.
     Added dbms_output.put_line to version.

        Rev 1.27   Jun 09 2006 12:55:38   zf297a
     implemented version

        Rev 1.26   Jan 05 2006 12:23:28   zf297a
     Fixed getNslLogonId - was using the NSN_PLANNER_CODE instead of the NSL_PLANNER_CODE

        Rev 1.25   Dec 02 2005 10:18:10   zf297a
     Fixed getNsnPlannerCode, getNslPlannerCode, getNsnLogonId, and getNslLogonId so that they always return a default value. NOTE: if the literal is returned, it may not be a valid planner_code or logon_id.  In that case the data may no go to the SPO correctly unless RJBplanner.xml and RichellBodine.xml is sent manully to the SPO!

        Rev 1.24   Nov 30 2005 10:57:38   zf297a
     added getBom, getBomQuantity, and used these new functions to get data from the amd_param_changes table, if there is not data found bom defaults to 'C17' and bom_quantity defaults to 1.

        Rev 1.23   Nov 01 2005 12:32:52   zf297a
     Added some more "getter" functions for other constants.

        Rev 1.22   Nov 01 2005 12:21:34   zf297a
     Simplified the name of the "getter's" to getCONSTANT where CONSTANT is the identifier for the associated constant.

        Rev 1.21   Nov 01 2005 11:50:32   zf297a
     Added "getter 's" (get functions) for some of the constant's so they can be used in ordinary SQL instead of only in PL/SQL code.

        Rev 1.20   Sep 13 2005 11:04:22   zf297a
     Implemented interfaces for isParamKey and addParamKey.

        Rev 1.19   Aug 15 2005 11:43:36   zf297a
     Removed all debugMsg's since they were causing more trouble than they were worth.

        Rev 1.18   Aug 09 2005 11:50:20   zf297a
     Removed debugMsg that reports a missing logon_id / planner_code in amd_planner_logons since this caused an error with DataStage's query since it was inserting data into amd_load_details, which is not allowed for only a DataStage query.

        Rev 1.17   Aug 05 2005 11:27:02   zf297a
     Removed raise_application errors and made them into debugMsg's.  This is better than having a hard error here, since  execution should continue and the reported condition can be corrected at another time.

        Rev 1.16   Jul 27 2005 10:24:38   zf297a
     Streamlined code for default planner_codes and logon_id's

        Rev 1.15   Jul 26 2005 15:10:28   zf297a
     added additional edits for the default logon_id's

        Rev 1.14   Jul 08 2005 09:36:32   zf297a
     Added PVCS keyword $Log$ and copied the PVCS history log into the header comments.

    Rev 1.13
    Locked by:      zf297a
    Checked in:     Jul 08 2005 09:08:36
    Last modified:  Jul 08 2005 09:08:36
    Author id: zf297a     lines deleted/added/moved: 2/11/0
    added the public function getLogonId
    -----------------------------------
    Rev 1.12
    Checked in:     Jul 08 2005 08:58:34
    Last modified:  Jul 08 2005 08:58:34
    Author id: zf297a     lines deleted/added/moved: 6/11/0
    Added the public function getPlannerCode
    -----------------------------------
    Rev 1.11
    Checked in:     Jul 05 2005 13:54:12
    Last modified:  Jul 05 2005 13:54:12
    Author id: zf297a     lines deleted/added/moved: 2/6/0
    added $Log$ PVCS keyword
    -----------------------------------
    Rev 1.10
    Checked in:     Jul 05 2005 13:50:52
    Last modified:  Jul 05 2005 13:50:52
    Author id: zf297a     lines deleted/added/moved: 3/56/0
    Added NSN_PLANNER_CODE and NSL_PLANNER_CODE and their corresponding logon_id's: NSN_LOGON_ID and NSL_LOGON_ID.
    -----------------------------------
    Rev 1.9
    Checked in:     Mar 27 2002 12:22:38
    Last modified:  Mar 27 2002 12:22:38
    Author id: c970183     lines deleted/added/moved: 0/6/0
    Added PVCS keywords
    -----------------------------------
    Rev 1.8
    Checked in:     Nov 30 2001 06:28:40
    Last modified:  Nov 02 2001 10:22:08
    Author id: c372701     lines deleted/added/moved: 26/130/0
    gw - 11/29/01 - Updates due to system problems on the Version Manager NT Server. - Done to reflect latest changes - per Doug Elder
    -----------------------------------
    Rev 1.7
    Checked in:     Oct 28 2001 15:08:28
    Last modified:  Oct 28 2001 12:40:22
    Author id: c378632     lines deleted/added/moved: 0/12/0
    unit_cost_factor_offbase
    time_to_repair_offbase
    -----------------------------------
    Rev 1.6
    Checked in:     Oct 28 2001 11:31:26
    Last modified:  Oct 28 2001 11:21:32
    Author id: c378632     lines deleted/added/moved: 0/12/0
    time_to_repair_onbase,
    cost_to_repair_onbase
    -----------------------------------
    Rev 1.5
    Checked in:     Oct 25 2001 09:57:38
    Last modified:  Oct 25 2001 09:57:04
    Author id: c970183     lines deleted/added/moved: 48/178/0
    Made action codes, consumable, and repairable constants.
    -----------------------------------
    Rev 1.4
    Checked in:     Oct 25 2001 09:48:00
    Last modified:  Oct 25 2001 09:48:00
    Author id: c970183     lines deleted/added/moved: 196/48/0
    Added constants repairable and consumable.
    -----------------------------------
    Rev 1.3
    Checked in:     Oct 25 2001 07:14:08
    Last modified:  Oct 25 2001 07:13:40
    Author id: c970183     lines deleted/added/moved: 2/20/0
    Added routines to initialize the Action Codes from the amd_param_changes table
    -----------------------------------
    Rev 1.2
    Checked in:     Oct 23 2001 14:33:58
    Last modified:  Oct 23 2001 14:28:42
    Author id: c970183     lines deleted/added/moved: 45/175/0
    Made implementation updates
    -----------------------------------
    Rev 1.1
    Checked in:     Oct 18 2001 07:00:10
    Last modified:  Oct 18 2001 06:59:22
    Author id: c970183     lines deleted/added/moved: 172/51/0
    Changed to use new amd_param_changes table
    -----------------------------------
    Rev 1.0
    Checked in:     Oct 11 2001 08:19:52
    Last modified:  Oct 11 2001 07:33:40
    Author id: c372701     lines deleted

     The order_lead_time_........ variables will be initialized by the
     package body's 'begin' block.  This will happen the first time
     the package is referenced.
     */



   order_lead_time_consumable       amd_spare_parts.order_lead_time_defaulted%TYPE
      := NULL;
   order_lead_time_repairable       amd_spare_parts.order_lead_time_defaulted%TYPE
      := NULL;
   engine_part_reduction_factor     NUMBER := NULL;
   non_engine_part_reductn_factor   NUMBER := NULL;
   consumable_reduction_factor      NUMBER := NULL;

   FUNCTION getLikeNewNSN
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN LIKE_NEW_NSN;
   END getLikeNewNSN;

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
      Amd_Utils.writeMsg (pSourceName       => 'amd_defaults',
                          pTableName        => pTableName,
                          pError_location   => pError_location,
                          pKey1             => pKey1,
                          pKey2             => pKey2,
                          pKey3             => pKey3,
                          pKey4             => pKey4,
                          pData             => pData,
                          pComments         => pComments);
   END writeMsg;

   PROCEDURE debugMsg (sqlFunction         IN VARCHAR2,
                       tableName           IN VARCHAR2,
                       rptLocation         IN NUMBER,
                       key1                IN VARCHAR2 := '',
                       key2                IN VARCHAR2 := '',
                       key3                IN VARCHAR2 := '',
                       key4                IN VARCHAR2 := '',
                       key5                IN VARCHAR2 := '',
                       keywordValuePairs   IN VARCHAR2 := '')
   IS
   BEGIN
      Amd_Utils.InsertErrorMsg (
         pLoad_no        => Amd_Utils.GetLoadNo (pSourceName   => sqlFunction,
                                                 pTableName    => tableName),
         pData_line_no   => rptLocation,
         pData_line      => 'amd_defaults',
         pKey_1          => key1,
         pKey_2          => key2,
         pKey_3          => key3,
         pKey_4          => key4,
         pKey_5          =>    key5
                            || ' '
                            || TO_CHAR (SYSDATE, 'MM/DD/YY HH:MM:SS')
                            || ' '
                            || keywordValuePairs,
         pComments       =>    'sqlcode('
                            || SQLCODE
                            || ') sqlerrm('
                            || SQLERRM
                            || ')');
      COMMIT;
      RETURN;
   END debugMsg;

   -- put a wrapper around debugMsg so it will only write one message to amd_load_details
   PROCEDURE displayOnce (sqlFunction         IN VARCHAR2,
                          tableName           IN VARCHAR2,
                          rptLocation         IN NUMBER,
                          key1                IN VARCHAR2 := '',
                          key2                IN VARCHAR2 := '',
                          key3                IN VARCHAR2 := '',
                          key4                IN VARCHAR2 := '',
                          key5                IN VARCHAR2 := '',
                          keywordValuePairs   IN VARCHAR2 := '')
   IS
      -- rptLocation must be unique for a given package for this to work
      CURSOR loadDetails
      IS
         SELECT load_no
           FROM amd_load_details
          WHERE     amd_load_details.DATA_LINE = 'amd_defaults'
                AND amd_load_details.DATA_LINE_NO = rptLocation;

      recExists   BOOLEAN := FALSE;
   BEGIN
      FOR rec IN loadDetails
      LOOP
         recExists := TRUE;
         EXIT;
      END LOOP;

      IF NOT recExists
      THEN
         debugMsg (sqlFunction         => sqlFunction,
                   tableName           => tableName,
                   rptLocation         => rptLocation,
                   key1                => key1,
                   key2                => key2,
                   key3                => key3,
                   key4                => key4,
                   key5                => key5,
                   keywordValuePairs   => keywordValuePairs);
      END IF;
   END displayOnce;

   FUNCTION isParamKey (key IN VARCHAR2)
      RETURN BOOLEAN
   IS
      theKey   amd_params.PARAM_KEY%TYPE;
   BEGIN
      SELECT param_key
        INTO theKey
        FROM amd_params
       WHERE param_key = key;

      RETURN TRUE;
   EXCEPTION
      WHEN STANDARD.NO_DATA_FOUND
      THEN
         RETURN FALSE;
   END isParamKey;

   PROCEDURE addParamKey (key IN VARCHAR2, description IN VARCHAR2)
   IS
      PROCEDURE doUpdate
      IS
      BEGIN
         UPDATE amd_params
            SET param_description = description
          WHERE param_key = key;
      EXCEPTION
         WHEN OTHERS
         THEN
            writeMsg (pTableName        => 'amd_params',
                      pError_location   => 4,
                      pKey1             => key,
                      pKey2             => description);
            RAISE;
      END doUpdate;
   BEGIN
      INSERT INTO amd_params (param_key, param_description)
           VALUES (key, description);
   EXCEPTION
      WHEN STANDARD.DUP_VAL_ON_INDEX
      THEN
         doUpdate;
      WHEN OTHERS
      THEN
         writeMsg (pTableName        => 'amd_params',
                   pError_location   => 4,
                   pKey1             => key,
                   pKey2             => description);
         RAISE;
   END addParamKey;

   PROCEDURE setParamValue (key IN VARCHAR2, VALUE IN VARCHAR2)
   IS
   BEGIN
      INSERT INTO amd_param_changes (param_key,
                                     param_value,
                                     effective_date,
                                     user_id)
           VALUES (key,
                   VALUE,
                   SYSDATE,
                   USER);
   END setParamValue;

   FUNCTION GetParamValue (key IN VARCHAR2)
      RETURN amd_param_changes.param_value%TYPE
   IS
      VALUE   amd_param_changes.param_value%TYPE := NULL;
   BEGIN
      SELECT param_value
        INTO VALUE
        FROM amd_param_changes
       WHERE     param_key = key
             AND effective_date = (SELECT MAX (effective_date)
                                     FROM amd_param_changes
                                    WHERE param_key = key);

      RETURN VALUE;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END GetParamValue;

   FUNCTION GetOrderLeadTime (
      pItem_type   IN amd_national_stock_items.item_type%TYPE)
      RETURN amd_spare_parts.order_lead_time_defaulted%TYPE
   IS
      FUNCTION IsConsumable
         RETURN BOOLEAN
      IS
      BEGIN
         RETURN (UPPER (pItem_type) = amd_defaults.CONSUMABLE);
      END IsConsumable;

      FUNCTION IsRepairable
         RETURN BOOLEAN
      IS
      BEGIN
         RETURN (UPPER (pItem_type) = amd_defaults.REPAIRABLE);
      END IsRepairable;
   BEGIN
      IF IsConsumable
      THEN
         RETURN order_lead_time_consumable;
      ELSIF IsRepairable
      THEN
         RETURN order_lead_time_repairable;
      ELSE
         RETURN NULL;
      END IF;
   END GetOrderLeadTime;

   FUNCTION GetSmrCode (pNsn            IN VARCHAR2,
                        pPart_no        IN VARCHAR2,
                        pMfgr           IN VARCHAR2,
                        pPlanner_code   IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN NULL; /* todo The field in the
         amd_national_stock_items may not be used
         so this function can be left as is until
         further notice.
         */
   END GetSmrCode;

   FUNCTION GetUnitCost (
      pNsn            IN amd_spare_parts.nsn%TYPE,
      pPart_no        IN amd_spare_parts.part_no%TYPE,
      pMfgr           IN amd_spare_parts.mfgr%TYPE,
      pSmr_code       IN amd_national_stock_items.smr_code%TYPE,
      pPlanner_code   IN amd_national_stock_items.planner_code%TYPE)
      RETURN amd_spare_parts.unit_cost_defaulted%TYPE
   IS
      gfp_price             fedc.gfp_price%TYPE := NULL;
      unit_cost_defaulted   amd_spare_parts.unit_cost_defaulted%TYPE := NULL;

      FUNCTION GetGfpPriceFromFedc (pPart_number   IN fedc.part_number%TYPE,
                                    pVendor_code   IN fedc.vendor_code%TYPE)
         RETURN fedc.gfp_price%TYPE
      IS
         min_gfp_price   fedc.gfp_price%TYPE := NULL;
         max_gfp_price   fedc.gfp_price%TYPE := NULL;
      BEGIN
         BEGIN
            SELECT MIN (gfp_price), MAX (gfp_price)
              INTO min_gfp_price, max_gfp_price
              FROM fedc
             WHERE part_number = pPart_number AND vendor_code = pVendor_code;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END GetViaPartNumberVendorCode;

         /*
           If it didn't match on part_number/cage try part_number/nsn
         */
         IF min_gfp_price IS NULL AND max_gfp_price IS NULL
         THEN
            BEGIN
               SELECT MIN (gfp_price), MAX (gfp_price)
                 INTO min_gfp_price, max_gfp_price
                 FROM fedc
                WHERE     part_number = pPart_number
                      AND nsn = amd_utils.FormatNSN (pNsn, 'Dash');
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  RETURN NULL;
            END GetViaPartNumberNsn;
         END IF;

         IF min_gfp_price != max_gfp_price
         THEN
            RETURN NULL;
         ELSE
            RETURN min_gfp_price;
         END IF;
      END GetGfpPriceFromFedc;

      FUNCTION IsEnginePart (
         pPlanner_code   IN amd_national_stock_items.planner_code%TYPE)
         RETURN BOOLEAN
      IS
      BEGIN
         RETURN (pPlanner_code = 'PSA' OR pPlanner_code = 'PSB');
      END IsEnginePart;

      /*
       A quasi-repairable item would be like a frayed rope,
       it can be fixed temporarily but the rope is eventually
       consumed - so in this context the item more closely
       resembles a consumable item.
      */
      FUNCTION IsQuasiRepariable (
         pSmr_code   IN amd_national_stock_items.smr_code%TYPE)
         RETURN BOOLEAN
      IS
      BEGIN
         IF LENGTH (pSmr_code) >= 6
         THEN
            RETURN UPPER (SUBSTR (pSmr_code, 6, 1)) = 'P';
         ELSE
            RETURN FALSE;
         END IF;
      END IsQuasiRepariable;

      FUNCTION IsConsumable (
         pSmr_code   IN amd_national_stock_items.smr_code%TYPE)
         RETURN BOOLEAN
      IS
      BEGIN
         IF LENGTH (pSmr_code) >= 6
         THEN
            RETURN UPPER (SUBSTR (pSmr_code, 6, 1)) = 'N';
         ELSE
            RETURN FALSE;
         END IF;
      END IsConsumable;
   BEGIN                                                        -- GetUnitCost
      gfp_price :=
         GetGfpPriceFromFedc (pPart_number => pPart_no, pVendor_code => pMfgr);

      IF gfp_price IS NOT NULL
      THEN
         IF IsQuasiRepariable (pSmr_code) OR IsConsumable (pSmr_code)
         THEN
            unit_cost_defaulted := gfp_price * consumable_reduction_factor;
         ELSE
            IF IsEnginePart (pPlanner_code)
            THEN
               unit_cost_defaulted := gfp_price * engine_part_reduction_factor;
            ELSE
               unit_cost_defaulted :=
                  gfp_price * non_engine_part_reductn_factor;
            END IF;
         END IF;
      END IF;

      RETURN unit_cost_defaulted; /* defaults to null if there
             isn't a fedc gfp_price.
             */
   END GetUnitCost;

   FUNCTION GetOffBaseRepairCost (pUnitCost IN NUMBER)
      RETURN NUMBER
   IS
   BEGIN
      -- todo
      -- off base repair cost is currently 10% of unit cost.  put the .10 in params table
      RETURN NULL;
   END GetOffBaseRepairCost;

   FUNCTION getPlannerCode (nsn IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      IF amd_utils.isPartConsumable (
            amd_utils.getPartNo (amd_utils.getNsiSid (pNsn => nsn)))
      THEN
         RETURN CONSUMABLE_PLANNER_CODE;
      ELSIF amd_utils.isPartRepairable (
               amd_utils.getPartNo (amd_utils.getNsiSid (pNsn => nsn)))
      THEN
         RETURN REPAIRABLE_PLANNER_CODE;
      ELSE
         RETURN NULL;
      END IF;
   END getPlannerCode;

   FUNCTION getLogonId (nsn IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      IF amd_utils.isPartConsumable (
            amd_utils.getPartNo (amd_utils.getNsiSid (pNsn => nsn)))
      THEN
         RETURN CONSUMABLE_LOGON_ID;
      ELSIF amd_utils.isPartRepairable (
               amd_utils.getPartNo (amd_utils.getNsiSid (pNsn => nsn)))
      THEN
         RETURN REPAIRABLE_LOGON_ID;
      ELSE
         RETURN NULL;
      END IF;
   END getLogonId;

   -- define getter routines for constants so they can be used outside of pl/sql in ordinary sql
   -- dse 11/01/05
   FUNCTION getDELETE_ACTION
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN DELETE_ACTION;
   END getDELETE_ACTION;

   FUNCTION getINSERT_ACTION
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN INSERT_ACTION;
   END getINSERT_ACTION;

   FUNCTION getUPDATE_ACTION
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN UPDATE_ACTION;
   END getUPDATE_ACTION;

   FUNCTION getCONSUMABLE
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN CONSUMABLE;
   END getCONSUMABLE;

   FUNCTION getREPAIRABLE
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN REPAIRABLE;
   END getREPAIRABLE;

   FUNCTION getAMD_WAREHOUSE_LOCID
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN AMD_WAREHOUSE_LOCID;
   END getAMD_WAREHOUSE_LOCID;

   FUNCTION getBSSM_WAREHOUSE_SRAN
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN BSSM_WAREHOUSE_SRAN;
   END getBSSM_WAREHOUSE_SRAN;

   FUNCTION getAMD_UK_LOC_ID
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN AMD_UK_LOC_ID;
   END getAMD_UK_LOC_ID;

   FUNCTION getAMD_UK_SC
      RETURN VARCHAR2
   IS                                               -- added 10/11/2007 by dse
   BEGIN
      RETURN AMD_UK_SC;
   END getAMD_UK_SC;

   FUNCTION getAMD_CAN_SC
      RETURN VARCHAR2
   IS                                               -- added 10/11/2007 by dse
   BEGIN
      RETURN AMD_CAN_SC;
   END getAMD_CAN_SC;

   FUNCTION getAMD_AUS_SC
      RETURN VARCHAR2
   IS                                               -- added 10/11/2007 by dse
   BEGIN
      RETURN AMD_AUS_SC;
   END getAMD_AUS_SC;

   FUNCTION getAMD_AUS_LOC_ID
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN AMD_AUS_LOC_ID;
   END getAMD_AUS_LOC_ID;

   FUNCTION getAMD_CAN_LOC_ID
      RETURN VARCHAR2
   IS                                               -- added 10/11/2007 by dse
   BEGIN
      RETURN AMD_CAN_LOC_ID;
   END getAMD_CAN_LOC_ID;


   FUNCTION getAMD_BASC_LOC_ID
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN AMD_BASC_LOC_ID;
   END getAMD_BASC_LOC_ID;

   FUNCTION getAMD_BASC_SC
      RETURN VARCHAR2
   IS                                               -- added 10/11/2007 by dse
   BEGIN
      RETURN AMD_BASC_SC;
   END getAMD_BASC_SC;

   FUNCTION getAMD_WARNER_ROBINS_LOC_ID
      RETURN VARCHAR2
   IS                                               -- added 10/11/2007 by dse
   BEGIN
      RETURN AMD_WARNER_ROBINS_LOC_ID;
   END getAMD_WARNER_ROBINS_LOC_ID;

   FUNCTION getAMD_VUB_LOC_ID
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN AMD_VUB_LOC_ID;
   END getAMD_VUB_LOC_ID;

   PROCEDURE version
   IS
   BEGIN
      writeMsg (pTableName        => 'amd_defaults',
                pError_location   => 10,
                pKey1             => 'amd_defaults',
                pKey2             => '$Revision:   1.46  $');
      DBMS_OUTPUT.put_line ('amd_defaults: $Revision:   1.46  $');
   END version;

   FUNCTION getVersion
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN '$Revision:   1.46  $';
   END getVersion;

   PROCEDURE checkDefaultPlanners
   IS
      planner_code   amd_planners.PLANNER_CODE%TYPE;
      work           NUMBER;
      msg            VARCHAR2 (2000);
      work_msg       VARCHAR2 (2000);

      error          BOOLEAN := FALSE;
   BEGIN
      BEGIN
         SELECT planner_code
           INTO planner_code
           FROM amd_planners
          WHERE     planner_code = NSN_PLANNER_CODE
                AND action_code <> amd_defaults.DELETE_ACTION;
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            work_msg :=
                  'The default nsn planner code of '
               || NSN_PLANNER_CODE
               || ' does not exist in amd_planners.';
            DBMS_OUTPUT.put_line (work_msg);
            msg := work_msg;
            error := TRUE;
      END;

      BEGIN
         SELECT planner_code
           INTO planner_code
           FROM amd_planners
          WHERE     planner_code = NSL_PLANNER_CODE
                AND action_code <> amd_defaults.DELETE_ACTION;
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            work_msg :=
                  'The default nsl planner code of '
               || NSL_PLANNER_CODE
               || ' does not exist in amd_planners.';
            DBMS_OUTPUT.put_line (work_msg);
            msg := msg || '.  ' || work_msg;
            error := TRUE;
      END;

      BEGIN
         SELECT 1
           INTO work
           FROM DUAL
          WHERE EXISTS
                   (SELECT NULL
                      FROM amd_planner_logons
                     WHERE     planner_code = NSN_PLANNER_CODE
                           AND action_code <> amd_defaults.DELETE_ACTION);
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            work_msg :=
                  'The default nsn planner code of '
               || NSN_PLANNER_CODE
               || ' does not exist in amd_planner_logons.';
            DBMS_OUTPUT.put_line (work_msg);
            msg := msg || '.  ' || work_msg;
            error := TRUE;
      END;

      BEGIN
         SELECT 1
           INTO work
           FROM DUAL
          WHERE EXISTS
                   (SELECT NULL
                      FROM amd_planner_logons
                     WHERE     planner_code = NSL_PLANNER_CODE
                           AND action_code <> amd_defaults.DELETE_ACTION);
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            work_msg :=
                  'The default nsl planner code of '
               || NSL_PLANNER_CODE
               || ' does not exist in amd_planner_logons.';
            DBMS_OUTPUT.put_line (work_msg);
            msg := msg || '.  ' || work_msg;
            error := TRUE;
      END;

      IF error
      THEN
         raise_application_error (-20010, msg);
      END IF;
   END checkDefaultPlanners;

   PROCEDURE checkDefaultLogonIds
   IS
      bems_id    amd_users.bems_id%TYPE;
      work       NUMBER;
      msg        VARCHAR2 (2000);
      work_msg   VARCHAR2 (2000);

      error      BOOLEAN := FALSE;
   BEGIN
      BEGIN
         SELECT bems_id
           INTO bems_id
           FROM amd_users
          WHERE     bems_id = NSN_LOGON_ID
                AND action_code <> amd_defaults.DELETE_ACTION;
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            work_msg :=
                  'The default nsn logon id of '
               || NSN_LOGON_ID
               || ' does not exist in amd_users.';
            DBMS_OUTPUT.put_line (work_msg);
            msg := work_msg;
            error := TRUE;
      END;

      BEGIN
         SELECT bems_id
           INTO bems_id
           FROM amd_users
          WHERE     bems_id = NSL_LOGON_ID
                AND action_code <> amd_defaults.DELETE_ACTION;
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            work_msg :=
                  'The default nsl logon id of '
               || NSL_LOGON_ID
               || ' does not exist in amd_users.';
            DBMS_OUTPUT.put_line (work_msg);
            msg := msg || '.  ' || work_msg;
            error := TRUE;
      END;

      BEGIN
         SELECT 1
           INTO work
           FROM DUAL
          WHERE EXISTS
                   (SELECT NULL
                      FROM amd_planner_logons
                     WHERE     logon_id = NSN_LOGON_ID
                           AND action_code <> amd_defaults.DELETE_ACTION);
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            work_msg :=
                  'The default nsn logon id of '
               || NSN_LOGON_ID
               || ' does not exist in amd_planner_logons.';
            DBMS_OUTPUT.put_line (work_msg);
            msg := msg || '.  ' || work_msg;
            error := TRUE;
      END;

      BEGIN
         SELECT 1
           INTO work
           FROM DUAL
          WHERE EXISTS
                   (SELECT NULL
                      FROM amd_planner_logons
                     WHERE     logon_id = NSL_LOGON_ID
                           AND action_code <> amd_defaults.DELETE_ACTION);
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            work_msg :=
                  'The default nsl logon id of '
               || NSL_LOGON_ID
               || ' does not exist in amd_planner_logons.';
            DBMS_OUTPUT.put_line (work_msg);
            msg := msg || '.  ' || work_msg;
            error := TRUE;
      END;

      IF error
      THEN
         raise_application_error (-20020, msg);
      END IF;
   END checkDefaultLogonIds;

   FUNCTION getNSN_PLANNER_CODE
      RETURN amd_planners.PLANNER_CODE%TYPE
   IS
   BEGIN
      RETURN NSN_PLANNER_CODE;
   END getNSN_PLANNER_CODE;

   FUNCTION getNSN_LOGON_ID
      RETURN amd_users.BEMS_ID%TYPE
   IS
   BEGIN
      RETURN NSN_LOGON_ID;
   END getNSN_LOGON_ID;

   FUNCTION getNSL_PLANNER_CODE
      RETURN amd_planners.PLANNER_CODE%TYPE
   IS
   BEGIN
      RETURN NSL_PLANNER_CODE;
   END getNSL_PLANNER_CODE;

   FUNCTION getNSL_LOGON_ID
      RETURN amd_users.BEMS_ID%TYPE
   IS
   BEGIN
      RETURN NSL_LOGON_ID;
   END getNSL_LOGON_ID;

   FUNCTION getCONSUMABLE_PLANNER_CODE
      RETURN amd_planners.PLANNER_CODE%TYPE
   IS
   BEGIN
      RETURN CONSUMABLE_PLANNER_CODE;
   END getCONSUMABLE_PLANNER_CODE;

   FUNCTION getCONSUMABLE_LOGON_ID
      RETURN amd_users.BEMS_ID%TYPE
   IS
   BEGIN
      RETURN CONSUMABLE_LOGON_ID;
   END getCONSUMABLE_LOGON_ID;

   FUNCTION getREPAIRABLE_PLANNER_CODE
      RETURN amd_planners.PLANNER_CODE%TYPE
   IS
   BEGIN
      RETURN REPAIRABLE_PLANNER_CODE;
   END getREPAIRABLE_PLANNER_CODE;

   FUNCTION getREPAIRABLE_LOGON_ID
      RETURN amd_users.BEMS_ID%TYPE
   IS
   BEGIN
      RETURN REPAIRABLE_LOGON_ID;
   END getREPAIRABLE_LOGON_ID;


   FUNCTION getCLEAN_DATA_DAY
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN CLEAN_DATA_DAY;
   END getCLEAN_DATA_DAY;

   -- added 4/12/2007 by dse
   FUNCTION getPSMS_COMMIT_THRESHOLD
      RETURN NUMBER
   IS
   BEGIN
      RETURN PSMS_COMMIT_THRESHOLD;
   END getPSMS_COMMIT_THRESHOLD;

   -- added 4/12/2007 by dse
   FUNCTION getMAIN_COMMIT_THRESHOLD
      RETURN NUMBER
   IS
   BEGIN
      RETURN MAIN_COMMIT_THRESHOLD;
   END getMAIN_COMMIT_THRESHOLD;

   -- added 4/12/2007 by dse
   FUNCTION getTEMP_NSNS_COMMIT_THRESHOLD
      RETURN NUMBER
   IS
   BEGIN
      RETURN TEMP_NSNS_COMMIT_THRESHOLD;
   END getTEMP_NSNS_COMMIT_THRESHOLD;

   -- added 4/12/2007 by dse
   FUNCTION getGOLD_COMMIT_THRESHOLD
      RETURN NUMBER
   IS
   BEGIN
      RETURN GOLD_COMMIT_THRESHOLD;
   END getGOLD_COMMIT_THRESHOLD;

   -- added 4/12/2007 by dse
   FUNCTION getPARTSTRUC_COMMIT_THRESHOLD
      RETURN NUMBER
   IS
   BEGIN
      RETURN PARTSTRUC_COMMIT_THRESHOLD;
   END getPARTSTRUC_COMMIT_THRESHOLD;

   -- added 6/28/2007 by dse
   FUNCTION getDATE_LVL_LOADED_MODIFIER
      RETURN NUMBER
   IS
   BEGIN
      RETURN DATE_LVL_LOADED_MODIFIER;
   END getDATE_LVL_LOADED_MODIFIER;

   FUNCTION getTSL_CONSUMABL_CALENDAR_DAYS
      RETURN NUMBER
   IS                                               -- added 10/11/2007 by dse
   BEGIN
      RETURN TSL_CONSUMABL_CALENDAR_DAYS;
   END getTSL_CONSUMABL_CALENDAR_DAYS;

   FUNCTION getROP
      RETURN NUMBER
   IS
   BEGIN
      RETURN ROP;
   END getROP;

   FUNCTION getROQ
      RETURN NUMBER
   IS
   BEGIN
      RETURN ROQ;
   END getROQ;

   FUNCTION getTIME_TO_REPAIR_OFFBASE
      RETURN amd_part_locs.time_to_repair%TYPE
   IS
   BEGIN
      RETURN TIME_TO_REPAIR_OFFBASE;
   END getTIME_TO_REPAIR_OFFBASE;

   FUNCTION getIcpInd
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN ICP_IND;
   END getIcpInd;

   FUNCTION getSourceCode
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN SOURCE_CODE;
   END getSourceCode;

   FUNCTION getSourceOfSupply
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN SOURCE_of_Supply;
   END getSourceOfSupply;



   FUNCTION getNonStockageList
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN NON_STOCKAGE_LIST;
   END getNonStockageList;

   FUNCTION getStartLocId
      RETURN NUMBER
   IS
   BEGIN
      RETURN START_LOC_ID;
   END getStartLocId;

   FUNCTION getProgramId
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN PROGRAM_ID;
   END getProgramId;
/*
 The following begin block is executed the first time this package is
 referenced.  It initialializes all the default variables from a table.
 The package will stay in memory until the application using it is finished.
 */
BEGIN
   DECLARE
      FUNCTION getStrict
         RETURN BOOLEAN
      IS
         param   AMD_PARAM_CHANGES.PARAM_VALUE%TYPE;
      BEGIN
         param := getParamValue ('strictDefaults');
         RETURN (param = '1' OR UPPER (param) = 'Y');
      END getStrict;

      FUNCTION GetCondemnAvg
         RETURN amd_national_stock_items.condemn_avg%TYPE
      IS
      BEGIN
         RETURN TO_NUMBER (GetParamValue ('condemn_avg'));
      END GetCondemnAvg;

      FUNCTION GetConsumableReductionFactor
         RETURN consumable_reduction_factor%TYPE
      IS
      BEGIN
         RETURN TO_NUMBER (GetParamValue ('consumable_reduction_factor'));
      END GetConsumableReductionFactor;

      FUNCTION GetDisposalCost
         RETURN amd_spare_parts.disposal_cost%TYPE
      IS
      BEGIN
         RETURN TO_NUMBER (GetParamValue ('disposal_cost'));
      END GetDisposalCost;

      FUNCTION GetDistribUom
         RETURN amd_national_stock_items.distrib_uom%TYPE
      IS
      BEGIN
         RETURN GetParamValue ('distrib_uom');
      END GetDistribUom;

      FUNCTION GetEnginePartReductionFactor
         RETURN engine_part_reduction_factor%TYPE
      IS
      BEGIN
         RETURN TO_NUMBER (GetParamValue ('engine_part_reduction_factor'));
      END GetEnginePartReductionFactor;

      FUNCTION GetNonEnginePartReductnFactor
         RETURN engine_part_reduction_factor%TYPE
      IS
      BEGIN
         RETURN TO_NUMBER (GetParamValue ('non_engine_part_reductn_factor'));
      END GetNonEnginePartReductnFactor;

      FUNCTION GetNrtsAvg
         RETURN amd_national_stock_items.nrts_avg%TYPE
      IS
      BEGIN
         RETURN GetParamValue ('nrts_avg');
      END GetNrtsAvg;

      FUNCTION GetOffBaseTurnAround
         RETURN amd_part_locs.time_to_repair%TYPE
      IS
      BEGIN
         RETURN GetParamValue ('off_base_turn_around');
      END GetOffBaseTurnAround;

      FUNCTION GetOrderLeadTimeConsumable
         RETURN amd_spare_parts.order_lead_time_defaulted%TYPE
      IS
      BEGIN
         RETURN TO_NUMBER (GetParamValue ('order_lead_time_consumable'));
      END GetOrderLeadTimeConsumable;

      FUNCTION GetOrderLeadTimeRepairable
         RETURN amd_spare_parts.order_lead_time_defaulted%TYPE
      IS
      BEGIN
         RETURN TO_NUMBER (GetParamValue ('order_lead_time_repairable'));
      END GetOrderLeadTimeRepairable;

      FUNCTION GetOrderQuantity
         RETURN amd_national_stock_items.order_quantity%TYPE
      IS
      BEGIN
         RETURN TO_NUMBER (GetParamValue ('order_quantity'));
      END GetOrderQuantity;

      FUNCTION GetOrderUom
         RETURN amd_spare_parts.order_uom%TYPE
      IS
      BEGIN
         RETURN GetParamValue ('order_uom');
      END GetOrderUom;

      FUNCTION GetQpeiWeighted
         RETURN amd_national_stock_items.qpei_weighted%TYPE
      IS
      BEGIN
         RETURN TO_NUMBER (GetParamValue ('qpei_weighted'));
      END GetQpeiWeighted;

      FUNCTION GetRtsAvg
         RETURN amd_national_stock_items.rts_avg%TYPE
      IS
      BEGIN
         RETURN TO_NUMBER (GetParamValue ('rts_avg'));
      END GetRtsAvg;

      FUNCTION GetScrapValue
         RETURN amd_spare_parts.scrap_value%TYPE
      IS
      BEGIN
         RETURN TO_NUMBER (GetParamValue ('scrap_value'));
      END GetScrapValue;

      FUNCTION GetShelfLife
         RETURN amd_spare_parts.shelf_life%TYPE
      IS
      BEGIN
         RETURN TO_NUMBER (GetParamValue ('shelf_life'));
      END GetShelfLife;

      FUNCTION GetTimeToRepairOnBaseAvg
         RETURN amd_national_stock_items.time_to_repair_on_base_avg_df%TYPE
      IS
      BEGIN
         RETURN TO_NUMBER (GetParamValue ('time_to_repair_on_base_avg'));
      END GetTimeToRepairOnBaseAvg;

      FUNCTION GetUnitVolume
         RETURN amd_spare_parts.unit_volume%TYPE
      IS
      BEGIN
         RETURN TO_NUMBER (GetParamValue ('unit_volume'));
      END GetUnitVolume;

      FUNCTION GetUseBssmToGetNsls
         RETURN VARCHAR2
      IS
      BEGIN
         RETURN GetParamValue ('use_bssm_to_get_nsls');
      END GetUseBssmToGetNsls;

      FUNCTION GetCostToRepairOnbase
         RETURN VARCHAR2
      IS
      BEGIN
         RETURN GetParamValue ('cost_to_repair_onbase');
      END GetCostToRepairOnbase;

      FUNCTION GetTimeToRepairOnbase
         RETURN VARCHAR2
      IS
      BEGIN
         RETURN GetParamValue ('time_to_repair_onbase');
      END GetTimeToRepairOnbase;

      FUNCTION GetUnitCostFactorOffbase
         RETURN VARCHAR2
      IS
      BEGIN
         RETURN GetParamValue ('unit_cost_factor_offbase');
      END GetUnitCostFactorOffbase;

      FUNCTION GetTimeToRepairOffbase
         RETURN VARCHAR2
      IS
      BEGIN
         RETURN GetParamValue ('time_to_repair_offbase');
      END GetTimeToRepairOffbase;

      FUNCTION getNsnPlannerCode
         RETURN amd_planners.PLANNER_CODE%TYPE
      IS
         wk_planner_code   amd_planners.planner_code%TYPE := NULL;
         planner_code      amd_planners.planner_code%TYPE := NULL;
      BEGIN
         wk_planner_code := TRIM (GetParamValue ('nsn_planner_code'));

         IF wk_planner_code IS NULL
         THEN
            wk_planner_code := 'RJB'; -- this may not be in amd_planners, but this is the current default
         END IF;

        <<validatePlannerCode>>
         BEGIN
            SELECT planner_code
              INTO getNsnPlannerCode.planner_code
              FROM amd_planners
             WHERE planner_code = wk_planner_code;
         EXCEPTION
            WHEN STANDARD.NO_DATA_FOUND
            THEN
               DBMS_OUTPUT.put_line (
                     'amd_defaults 10: Default NSN Planner_code '
                  || wk_planner_code
                  || ' is not in amd_planners.');

               IF STRICT
               THEN
                  raise_application_error (
                     -20000,
                        'amd_defaults: Default NSN Planner_code '
                     || wk_planner_code
                     || ' is not in amd_planners.');
               END IF;
         END validatePlannerCode;

         RETURN wk_planner_code;
      END getNsnPlannerCode;

      FUNCTION getNslPlannerCode
         RETURN amd_planners.PLANNER_CODE%TYPE
      IS
         wk_planner_code   amd_planners.PLANNER_CODE%TYPE := NULL;
         planner_code      amd_planners.PLANNER_CODE%TYPE := NULL;
      BEGIN
         wk_planner_code := TRIM (GetParamValue ('nsl_planner_code'));

         IF wk_planner_code IS NULL
         THEN
            wk_planner_code := 'NSD';
         END IF;

        <<validatePlannerCode>>
         BEGIN
            SELECT planner_code
              INTO getNslPlannerCode.planner_code
              FROM amd_planners
             WHERE planner_code = wk_planner_code;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               DBMS_OUTPUT.put_line (
                     'amd_defaults 20: Default NSL Planner_code '
                  || wk_planner_code
                  || ' is not in amd_planners.');

               IF STRICT
               THEN
                  raise_application_error (
                     -20001,
                        'amd_defaults: Default NSL Planner_code '
                     || wk_planner_code
                     || ' is not in amd_planners.');
               END IF;
         END validatePlannerCode;

         RETURN wk_planner_code;
      END getNslPlannerCode;

      FUNCTION getConsumablePlannerCode
         RETURN amd_planner_logons.planner_code%TYPE
      IS
         planner_code   amd_planner_logons.PLANNER_CODE%TYPE;
      BEGIN
         SELECT planner_code
           INTO getConsumablePlannerCode.PLANNER_CODE
           FROM amd_default_planners_v
          WHERE default_type = 'CONSUMABLE';

         RETURN planner_code;
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            RETURN 'UNC';
      END getConsumablePlannerCode;

      FUNCTION getRepairablePlannerCode
         RETURN amd_planner_logons.planner_code%TYPE
      IS
         planner_code   amd_planner_logons.PLANNER_CODE%TYPE;
      BEGIN
         SELECT planner_code
           INTO getRepairablePlannerCode.PLANNER_CODE
           FROM amd_default_planners_v
          WHERE default_type = 'REPAIRABLE';

         RETURN planner_code;
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            RETURN 'UNR';
      END getRepairablePlannerCode;

      FUNCTION getConsumableLogonId
         RETURN amd_planner_logons.LOGON_ID%TYPE
      IS
         logon_id   amd_planner_logons.LOGON_ID%TYPE;
      BEGIN
         SELECT bems_id
           INTO getConsumableLogonId.logon_id
           FROM amd_default_users_v
          WHERE default_type = 'CONSUMABLE';

         RETURN logon_id;
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            RETURN '1671850';
      END getConsumableLogonId;

      FUNCTION getRepairableLogonId
         RETURN amd_planner_logons.LOGON_ID%TYPE
      IS
         logon_id   amd_planner_logons.LOGON_ID%TYPE;
      BEGIN
         SELECT bems_id
           INTO getRepairableLogonId.logon_id
           FROM amd_default_users_v
          WHERE default_type = 'REPAIRABLE';

         RETURN logon_id;
      EXCEPTION
         WHEN STANDARD.NO_DATA_FOUND
         THEN
            RETURN '0324366';
      END getRepairableLogonId;

      FUNCTION getNsnLogonId
         RETURN amd_planner_logons.LOGON_ID%TYPE
      IS
         logon_id      amd_planner_logons.logon_id%TYPE;
         wk_logon_id   amd_planner_logons.logon_id%TYPE;
         result        NUMBER;
      BEGIN
         wk_logon_id := TRIM (GetParamValue ('nsn_logon_id'));

         IF wk_logon_id IS NULL
         THEN
            wk_logon_id := '0334080'; -- this user may not exist in amd_users, but this is the current default
         END IF;

        <<validateLogonId>>
         BEGIN
            SELECT 1
              INTO result
              FROM DUAL
             WHERE EXISTS
                      (SELECT NULL
                         FROM amd_planner_logons
                        WHERE     logon_id = wk_logon_id
                              AND planner_code = NSN_PLANNER_CODE
                              AND action_code <> DELETE_ACTION);
         EXCEPTION
            WHEN STANDARD.NO_DATA_FOUND
            THEN
               DBMS_OUTPUT.put_line (
                     'amd_defaults 30: Default NSN Logon_id, '
                  || wk_logon_id
                  || ' does not exist in amd_planner_logons for planner '
                  || NSN_PLANNER_CODE);

               IF STRICT
               THEN
                  raise_application_error (
                     -20002,
                        'amd_defaults: Default NSN Logon_id, '
                     || wk_logon_id
                     || ' does not exist in amd_planner_logons for planner '
                     || NSN_PLANNER_CODE);
               END IF;
         END validateLogonId;

         RETURN wk_logon_id;
      END getNsnLogonId;

      FUNCTION getNslLogonId
         RETURN amd_planner_logons.LOGON_ID%TYPE
      IS
         logon_id      amd_planner_logons.logon_id%TYPE;
         wk_logon_id   amd_planner_logons.logon_id%TYPE;
         result        NUMBER;
      BEGIN
         wk_logon_id := TRIM (GetParamValue ('nsl_logon_id'));

         IF wk_logon_id IS NULL
         THEN
            wk_logon_id := '0235143';
         END IF;

        <<validateLogonId>>
         BEGIN
            SELECT 1
              INTO result
              FROM DUAL
             WHERE EXISTS
                      (SELECT NULL
                         FROM amd_planner_logons
                        WHERE     logon_id = wk_logon_id
                              AND planner_code = NSL_PLANNER_CODE
                              AND action_code <> DELETE_ACTION);
         EXCEPTION
            WHEN STANDARD.NO_DATA_FOUND
            THEN
               DBMS_OUTPUT.put_line (
                     'amd_defaults 40: Default NSL Logon_id, '
                  || wk_logon_id
                  || ' does not exist in amd_planner_logons for planner '
                  || NSL_PLANNER_CODE);

               IF STRICT
               THEN
                  raise_application_error (
                     -20003,
                        'amd_defaults: Default NSL Logon_id, '
                     || wk_logon_id
                     || ' does not exist in amd_planner_logons for planner '
                     || NSL_PLANNER_CODE);
               END IF;
         END validateLogonId;

         RETURN wk_logon_id;
      END getNslLogonId;



      FUNCTION getCleanDataDay
         RETURN VARCHAR2
      IS
         dayOfTheWeek   VARCHAR2 (10);
      BEGIN
         dayOfTheWeek := UPPER (TRIM (getParamValue ('clean_data_day')));

         IF dayOfTheWeek IS NULL
         THEN
            RETURN 'SATURDAY';
         ELSE
            RETURN dayOfTheWeek;
         END IF;
      END getCleanDataDay;

      FUNCTION getPsmsCommitThreshold
         RETURN VARCHAR2
      IS
         threshold   NUMBER;
      BEGIN
         threshold :=
            TO_NUMBER (TRIM (getParamValue ('psms_commit_threshold')));

         IF threshold IS NULL
         THEN
            RETURN 1000;
         ELSE
            RETURN threshold;
         END IF;
      END getPsmsCommitThreshold;

      FUNCTION getMainCommitThreshold
         RETURN VARCHAR2
      IS
         threshold   NUMBER;
      BEGIN
         threshold :=
            TO_NUMBER (TRIM (getParamValue ('main_commit_threshold')));

         IF threshold IS NULL
         THEN
            RETURN 1000;
         ELSE
            RETURN threshold;
         END IF;
      END getMainCommitThreshold;

      FUNCTION getTempNsnsCommitThreshold
         RETURN VARCHAR2
      IS
         threshold   NUMBER;
      BEGIN
         threshold :=
            TO_NUMBER (TRIM (getParamValue ('temp_nsns_commit_threshold')));

         IF threshold IS NULL
         THEN
            RETURN 1000;
         ELSE
            RETURN threshold;
         END IF;
      END getTempNsnsCommitThreshold;

      FUNCTION getGoldCommitThreshold
         RETURN VARCHAR2
      IS
         threshold   NUMBER;
      BEGIN
         threshold :=
            TO_NUMBER (TRIM (getParamValue ('gold_commit_threshold')));

         IF threshold IS NULL
         THEN
            RETURN 1000;
         ELSE
            RETURN threshold;
         END IF;
      END getGoldCommitThreshold;

      FUNCTION getPartStrucCommitThreshold
         RETURN VARCHAR2
      IS
         threshold   NUMBER;
      BEGIN
         threshold :=
            TO_NUMBER (TRIM (getParamValue ('partstruc_commit_threshold')));

         IF threshold IS NULL
         THEN
            RETURN 1000;
         ELSE
            RETURN threshold;
         END IF;
      END getPartStrucCommitThreshold;

      FUNCTION getDateLvlLoadedModifier
         RETURN VARCHAR2
      IS
         dateLvlLoadedModifier   NUMBER;
      BEGIN
         dateLvlLoadedModifier :=
            TO_NUMBER (TRIM (getParamValue ('date_lvl_loaded_modifier')));

         IF dateLvlLoadedModifier IS NULL
         THEN
            RETURN 210;
         ELSE
            RETURN dateLvlLoadedModifier;
         END IF;
      END getDateLvlLoadedModifier;

      FUNCTION getTslConsumablCalendarDays
         RETURN NUMBER
      IS
         tslConsumablCalendarDays   NUMBER;
      BEGIN
         tslConsumablCalendarDays :=
            TO_NUMBER (TRIM (getParamValue ('tsl_consumabl_calendar_days')));

         IF tslConsumablCalendarDays IS NULL
         THEN
            RETURN 210;
         ELSE
            RETURN tslConsumablCalendarDays;
         END IF;
      END getTslConsumablCalendarDays;

      FUNCTION getTheROQ
         RETURN NUMBER
      IS
         roq   NUMBER;
      BEGIN
         roq := TO_NUMBER (TRIM (getParamValue ('roq')));

         IF roq IS NULL
         THEN
            RETURN amd_defaults.ROQ;
         ELSE
            RETURN roq;
         END IF;
      END getTheROQ;

      FUNCTION getTheROP
         RETURN NUMBER
      IS
         rop   NUMBER;
      BEGIN
         rop := TO_NUMBER (TRIM (getParamValue ('rop')));

         IF rop IS NULL
         THEN
            RETURN amd_defaults.ROP;
         ELSE
            RETURN rop;
         END IF;
      END getTheROP;

      FUNCTION getTheIcpInd
         RETURN VARCHAR2
      IS
         icp_ind   amd_spare_parts.icp_ind%TYPE;
      BEGIN
         icp_ind := getParamValue ('icp_ind');

         IF icp_ind IS NULL
         THEN
            RETURN amd_defaults.ICP_IND;
         ELSE
            RETURN icp_ind;
         END IF;
      END getTheIcpInd;

      FUNCTION getTheSourceCode
         RETURN VARCHAR2
      IS
         source_code   cat1.source_code%TYPE;
      BEGIN
         source_code := getParamValue ('source_code');

         IF source_code IS NULL
         THEN
            RETURN amd_defaults.SOURCE_CODE;
         ELSE
            RETURN source_code;
         END IF;
      END getTheSourceCode;

      FUNCTION getTheSourceOfSupply
         RETURN VARCHAR2
      IS
         source_of_supply   VARCHAR2 (5);
      BEGIN
         source_of_supply := getParamValue ('source_of_supply');

         IF source_of_supply IS NULL
         THEN
            RETURN amd_defaults.SOURCE_OF_SUPPLY;
         ELSE
            RETURN source_of_supply;
         END IF;
      END getTheSourceOfSupply;


      FUNCTION getTheNonStockageList
         RETURN VARCHAR2
      IS
         non_stockage_list   amd_spare_parts.nsn%TYPE;
      BEGIN
         non_stockage_list := getParamValue ('non_stockage_list');

         IF non_stockage_list IS NULL
         THEN
            RETURN amd_defaults.NON_STOCKAGE_LIST;
         ELSE
            RETURN non_stockage_list;
         END IF;
      END getTheNonStockageList;

      -- get the Foriegn Military Sale segment code for Austrailia
      FUNCTION getFmsSegCodeForAUS
         RETURN whse.sc%TYPE
      IS
         sc   whse.sc%TYPE;
      BEGIN
         sc := TRIM (getParamValue ('fms_aus'));

         IF sc IS NULL
         THEN
            RETURN amd_defaults.AMD_AUS_SC;
         ELSE
            RETURN sc;
         END IF;
      END getFmsSegCodeForAUS;

      FUNCTION getFmsSegCodeForBASC
         RETURN whse.sc%TYPE
      IS
         sc   whse.sc%TYPE;
      BEGIN
         sc := TRIM (getParamValue ('fms_basc'));

         IF sc IS NULL
         THEN
            RETURN amd_defaults.AMD_BASC_SC;
         ELSE
            RETURN sc;
         END IF;
      END getFmsSegCodeForBASC;


      -- get the Foriegn Military Sale segment code for Canada
      FUNCTION getFmsSegCodeForCAN
         RETURN whse.sc%TYPE
      IS
         sc   whse.sc%TYPE;
      BEGIN
         sc := TRIM (getParamValue ('fms_can'));

         IF sc IS NULL
         THEN
            RETURN amd_defaults.AMD_CAN_SC;
         ELSE
            RETURN sc;
         END IF;
      END getFmsSegCodeForCAN;

      FUNCTION getFmsSegCodeForUK
         RETURN whse.sc%TYPE
      IS
         sc   whse.sc%TYPE;
      BEGIN
         sc := TRIM (getParamValue ('fms_uk'));

         IF sc IS NULL
         THEN
            RETURN amd_defaults.AMD_UK_SC;
         ELSE
            RETURN sc;
         END IF;
      END getFmsSegCodeForUK;

      FUNCTION getTheStartLocId
         RETURN NUMBER
      IS
         startLocId   whse.sc%TYPE;
      BEGIN
         startLocId := TO_NUMBER (TRIM (getParamValue ('start_loc_id')));

         IF startLocId IS NULL
         THEN
            RETURN amd_defaults.START_LOC_ID;
         ELSE
            RETURN startLocId;
         END IF;
      END getTheStartLocId;

      FUNCTION getTheProgramId
         RETURN VARCHAR2
      IS
         programId   VARCHAR2 (30);
      BEGIN
         programId := TRIM (getParamValue ('program_id'));

         IF programId IS NULL
         THEN
            RETURN amd_defaults.PROGRAM_ID;
         ELSE
            RETURN programId;
         END IF;
      END getTheProgramId;
   BEGIN
      amd_defaults.CONDEMN_AVG := GetCondemnAvg ();
      amd_defaults.consumable_reduction_factor :=
         GetConsumableReductionFactor ();
      amd_defaults.DISPOSAL_COST := GetDisposalCost ();
      amd_defaults.DISTRIB_UOM := GetDistribUom ();
      amd_defaults.engine_part_reduction_factor :=
         GetEnginePartReductionFactor ();
      amd_defaults.non_engine_part_reductn_factor :=
         GetNonEnginePartReductnFactor ();
      amd_defaults.NRTS_AVG := GetNrtsAvg ();
      amd_defaults.OFF_BASE_TURN_AROUND := GetOffBaseTurnAround ();
      amd_defaults.ORDER_QUANTITY := GetOrderQuantity ();
      amd_defaults.ORDER_UOM := GetOrderUom ();
      amd_defaults.QPEI_WEIGHTED := GetQpeiWeighted ();
      amd_defaults.RTS_AVG := GetRtsAvg ();
      amd_defaults.SCRAP_VALUE := GetScrapValue ();
      amd_defaults.SHELF_LIFE := GetShelfLife ();
      amd_defaults.order_lead_time_consumable := GetOrderLeadTimeConsumable ();
      amd_defaults.order_lead_time_repairable := GetOrderLeadTimeRepairable ();
      amd_defaults.TIME_TO_REPAIR_ON_BASE_AVG := GetTimeToRepairOnBaseAvg ();
      amd_defaults.UNIT_VOLUME := GetUnitVolume ();
      amd_defaults.USE_BSSM_TO_GET_NSLs := GetUseBssmToGetNsls ();
      amd_defaults.TIME_TO_REPAIR_ONBASE := GetTimeToRepairOnbase ();
      amd_defaults.TIME_TO_REPAIR_OFFBASE := GetTimeToRepairOffbase ();
      amd_defaults.COST_TO_REPAIR_ONBASE := GetCostToRepairOnbase ();
      amd_defaults.UNIT_COST_FACTOR_OFFBASE := GetUnitCostFactorOffbase ();
      amd_defaults.NSL_PLANNER_CODE := getNslPlannerCode ();
      amd_defaults.NSN_PLANNER_CODE := getNsnPlannerCode ();
      amd_defaults.NSN_LOGON_ID := getNsnLogonId (); -- assumes NSN_PLANNER_CODe has a valid value
      amd_defaults.NSL_LOGON_ID := getNslLogonId (); -- assumes NSL_PLANNER_CODE has a valid value
      amd_defaults.STRICT := getStrict ();
      amd_defaults.CLEAN_DATA_DAY := getCleanDataDay ();
      amd_defaults.PSMS_COMMIT_THRESHOLD := getPsmsCommitThreshold ();
      amd_defaults.MAIN_COMMIT_THRESHOLD := getMainCommitThreshold ();
      amd_defaults.TEMP_NSNS_COMMIT_THRESHOLD := getTempNsnsCommitThreshold ();
      amd_defaults.GOLD_COMMIT_THRESHOLD := getGoldCommitThreshold ();
      amd_defaults.PARTSTRUC_COMMIT_THRESHOLD :=
         getPartStrucCommitThreshold ();
      amd_defaults.DATE_LVL_LOADED_MODIFIER := getDateLvlLoadedModifier ();
      amd_defaults.TSL_CONSUMABL_CALENDAR_DAYS :=
         getTslConsumablCalendarDays ();
      amd_defaults.ROQ := getTheROQ ();
      amd_defaults.ROP := getTheROP ();
      amd_defaults.ICP_IND := getTheIcpInd ();
      amd_defaults.START_LOC_ID := getTheStartLocId ();
      amd_defaults.PROGRAM_ID := getTheProgramId ();
      amd_defaults.NON_STOCKAGE_LIST := getTheNonStockageList ();
      amd_defaults.SOURCE_OF_SUPPLY := getTheSourceOfSupply ();
      amd_defaults.AMD_AUS_SC := getFmsSegCodeForAUS ();
      amd_defaults.AMD_BASC_SC := getFmsSegCodeForBASC ();
      amd_defaults.AMD_CAN_SC := getFmsSegCodeForCAN ();
      amd_defaults.AMD_UK_SC := getFmsSegCodeForUK ();
      fmsSegCodes :=
         fmsSegCodeTab (AMD_AUS_SC,
                        AMD_BASC_SC,
                        AMD_CAN_SC,
                        AMD_UK_SC);
      amd_defaults.CONSUMABLE_LOGON_ID := getConsumableLogonId;
      amd_defaults.REPAIRABLE_LOGON_ID := getRepairableLogonId;
      amd_defaults.REPAIRABLE_PLANNER_CODE := getRepairablePlannerCode;
      amd_defaults.CONSUMABLE_PLANNER_CODE := getConsumablePlannerCode;
   END;
END amd_defaults;
/