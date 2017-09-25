/* Formatted on 1/25/2017 6:54:40 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY AMD_OWNER.AMD_PART_LOC_FORECASTS_PKG
AS
   /*
        $Author:   Douglas S Elder
   $Revision:   1.33
          $Date:   25 Jan 2017
      $Workfile:   AMD_PART_LOC_FORECASTS_PKG.pkb  $
  /*
          Rev 1.33 25 Jan 2017 DSE reformatted code added dbms_output for inserts


          Rev 1.32.1 17 Jan 2012 zf297a
          implemented getVersion function

  /*      Rev 1.32   24 Feb 2009 13:56:52   zf297a
  /*   Removed a2a code
  /*
  /*      Rev 1.31   07 Nov 2007 16:54:54   zf297a
  /*   Use bulk collect for all cursors.
  /*
  /*      Rev 1.30   Oct 03 2007 11:54:46   c402417
  /*   Added a check for either part is consumable or repairable before insert into tmp_a2a_ext_forecast.
  /*
  /*      Rev 1.29   Oct 02 2007 16:23:54   c402417
  /*   Removed the filter FD2090 when insert into tmp_a2a_ext_forecast
  /*
  /*      Rev 1.28   12 Sep 2007 13:53:36   zf297a
  /*   Removed commits from for loops.
  /*
  /*      Rev 1.27   07 Feb 2007 09:36:00   zf297a
  /*   Filter out locations FD2090
  /*
  /*      Rev 1.26   31 Jan 2007 12:01:26   zf297a
  /*   Modified hasValidDate to insist on a full month name beginning at the begining of the column NAME - ie MONTH DD, DDDD where DD is a two digit day and DDDD is a two digit year.
  /*
  /*      Rev 1.25   19 Jan 2007 14:02:44   zf297a
  /*   Made the "duplicates" a single CONSTANT to gaurantee that the value is the same for every location it is used within the package.
  /*
  /*      Rev 1.24   17 Jan 2007 14:43:10   zf297a
  /*   Chaned the pDuplicate value from 60 to 66.
  /*
  /*      Rev 1.23   Nov 28 2006 14:46:10   zf297a
  /*   fixed insertTmpA2A_EF - for INSERT_ACTION or UPDATE_ACTION check to see if the part is in amd_sent_to_a2a with action_code <> DELETE_ACTION then insert it into tmp_a2a_ext_forecast.  For DELETE_ACTION's check to see if the part is in amd_sent_to_a2a with any action_code then insert it into tmp_a2a_ext_forecast.
  /*
  /*      Rev 1.22   Nov 01 2006 11:39:12   zf297a
  /*   Implemented hasValidDate and hasValidDateYorN.  Used these new functions to filter out bad date formats in the name column of bssm_locks.
  /*
  /*      Rev 1.21   Sep 26 2006 16:22:12   zf297a
  /*   Fixed insert into amd_bssm__s_base_part_periods
  /*
  /*      Rev 1.20   Sep 14 2006 10:07:30   zf297a
  /*   Raise an applicaton error when no date is found for the latest Rbl Run from BSSM.
  /*
  /*      Rev 1.19   Sep 05 2006 12:52:00   zf297a
  /*   Added dbms_output to version
  /*
  /*      Rev 1.18   Aug 18 2006 15:45:10   zf297a
  /*   Implemented doExtForecast.
  /*
  /*      Rev 1.17   Aug 14 2006 14:13:50   zf297a
  /*   Fixed code to generated ExtForecast deletes.
  /*
  /*      Rev 1.16   Aug 01 2006 12:15:00   zf297a
  /*   Removed redundant getLatestRblRunBssm from for loop
  /*
  /*      Rev 1.15   Aug 01 2006 12:01:00   zf297a
  /*   Fixed LoadLatestRblRun so that it will use the most recent date contained in the name field of bssm_locks.  Used Raise_Application_Error when no date is found in the name field.
  /*
  /*      Rev 1.14   Jul 26 2006 10:11:40   zf297a
  /*   Implemented function getLatestRblRunBssm
  /*
  /*      Rev 1.13   Jul 26 2006 09:34:10   zf297a
  /*   Made duplicate field a required field for all tmp_a2a's
  /*
  /*      Rev 1.12   Jun 12 2006 13:10:42   zf297a
  /*   Fixed error messages.  Resequenced pError_location.  Enhanced use of writeMsg.  Fixed to_char format for minutes MI.
  /*
  /*      Rev 1.11   Jun 09 2006 12:17:28   zf297a
  /*   implemented version
  /*
  /*      Rev 1.10   Jun 04 2006 21:47:58   zf297a
  /*   Make sure LoadTmpAmdPartLocForecasts uses non-null spo_prime_part_no
  /*
  /*      Rev 1.9   Jun 01 2006 12:20:38   zf297a
  /*   switched from dbms_output to amd_utils.writeMsg.
  /*
  /*      Rev 1.8   May 12 2006 14:41:56   zf297a
  /*   Changed all loadAll routines to use all action_codes and to use the action_code data to create the A2A transactions.  Also use the SendAllData property of the a2a_pkg in conjunction with the isPartValid and the wasPartSent functions.
  /*
  /*      Rev 1.7   Apr 05 2006 12:42:38   zf297a
  /*   Limitied loop of 60 periods to just 1 with a duplicate value of 60.
  /*
  /*      Rev 1.6   Feb 15 2006 21:52:08   zf297a
  /*   Added a ref cursor, a type, and a common process routine.
  /*
  /*      Rev 1.4   Jan 03 2006 07:56:40   zf297a
  /*   Added procedure loadA2AByDate
  /*
  /*      Rev 1.3   Dec 16 2005 14:29:38   zf297a
  /*   Moved the truncate of tmp_a2a_ext_forecast from LoadTmpAmdPartLocForecast to LoadTmpAmdPartLocForecasts_Add.
  /*
  /*      Rev 1.2   Dec 15 2005 12:11:00   zf297a
  /*   Added truncate of tmp_a2a_ext_forecast to LoadTmpAmdPartLocForecasts
  /*
  /*      Rev 1.1   Dec 06 2005 10:36:52   zf297a
  /*   Fixed display of sysdate in errorMsg - changed to MM/DD/YYYY HH:MM:SS
  /*
  /*      Rev 1.0   Dec 01 2005 09:44:12   zf297a
  /*   Initial revision.
  */



   -- will need to constantly diff after all to check for new and deleted parts --

   PKGNAME      CONSTANT VARCHAR2 (30) := 'AMD_PART_LOC_FORECASTS_PKG';
   DUPLICATES   CONSTANT NUMBER := 66;

   -- REALLY_OLD_DATE CONSTANT DATE := TO_DATE('06/10/1965', 'MM/DD/YYYY') ;

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
      Amd_Utils.writeMsg (pSourceName       => 'amd_part_loc_forecasts_pkg',
                          pTableName        => pTableName,
                          pError_location   => pError_location,
                          pKey1             => pKey1,
                          pKey2             => pKey2,
                          pKey3             => pKey3,
                          pKey4             => pKey4,
                          pData             => pData,
                          pComments         => pComments);
   END writeMsg;

   FUNCTION ErrorMsg (
      pSourceName       IN amd_load_status.SOURCE%TYPE,
      pTableName        IN amd_load_status.TABLE_NAME%TYPE,
      pError_location   IN amd_load_details.DATA_LINE_NO%TYPE,
      pReturn_code      IN NUMBER,
      pKey1             IN VARCHAR2 := '',
      pKey2             IN VARCHAR2 := '',
      pKey3             IN VARCHAR2 := '',
      pData             IN VARCHAR2 := '',
      pComments         IN VARCHAR2 := '')
      RETURN NUMBER
   IS
   BEGIN
      ROLLBACK; -- rollback may not be complete if running with mDebug set to true
      amd_utils.InsertErrorMsg (
         pLoad_no        => amd_utils.GetLoadNo (pSourceName   => pSourceName,
                                                 pTableName    => pTableName),
         pData_line_no   => pError_location,
         pData_line      => pData,
         pKey_1          => SUBSTR (pKey1, 1, 50),
         pKey_2          => SUBSTR (pKey2, 1, 50),
         pKey_3          => pKey3,
         pKey_4          => TO_CHAR (pReturn_code),
         pKey_5          => TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS'),
         pComments       =>    'sqlcode('
                            || SQLCODE
                            || ') sqlerrm('
                            || SQLERRM
                            || ') '
                            || pComments);
      COMMIT;
      RETURN pReturn_code;
   END;

   /*
   FUNCTION IsTableEmpty(pTableName VARCHAR2) RETURN NUMBER IS
      returnCode NUMBER ;
      sql_stmt varchar2(1000) ;
   BEGIN
      IF pTableName IS NULL THEN
        returnCode := -1 ;
      END IF ;
      sql_stmt := 'SELECT count(*) FROM ' || pTableName || ' where rownum < 2' ;
      EXECUTE IMMEDIATE sql_stmt INTO returnCode ;
      RETURN returnCode ;
   EXCEPTION WHEN OTHERS THEN
      RETURN -1 ;
   END ;
   */


   FUNCTION GetFirstDateOfMonth (pDate DATE)
      RETURN DATE
   IS
   BEGIN
      IF (pDate IS NULL)
      THEN
         RETURN NULL;
      END IF;

      RETURN (LAST_DAY (ADD_MONTHS (pDate, -1)) + 1);
   END GetFirstDateOfMonth;

   FUNCTION getLatestRblRunBssm (lockName IN bssm_locks.NAME%TYPE)
      RETURN DATE
   IS
      str   VARCHAR2 (100);
   BEGIN
      /* spec denotes specific format of month Mon DD, YYYY  that will be in best spares
      text field */
      str := lockName;

      IF OWA_PATTERN.match (str, '(\w \d{2}, \d{4})(.*)')
      THEN
         OWA_PATTERN.CHANGE (str, '(\w \d{2}, \d{4})(.*)', '\1');
         RETURN TO_DATE (str, 'Mon DD, YYYY');
      END IF;

      raise_application_error (-20001,
                               'No date found for the latest RBL Run.');
   END getLatestRblRunBssm;

   FUNCTION hasValidDate (lockName IN bssm_locks.NAME%TYPE)
      RETURN BOOLEAN
   IS
      str       VARCHAR2 (100);
      theDate   DATE;
      result    BOOLEAN;
      sp        NUMBER;
   BEGIN
      /* spec denotes specific format of month Mon DD, YYYY  that will be in best spares
      text field */
      result := FALSE;
      str := TRIM (lockName);

      sp := INSTR (str, ' ');

      IF sp > 1
      THEN
         IF SUBSTR (UPPER (str), 1, sp - 1) IN ('JANUARY',
                                                'FEBRUARY',
                                                'MARCH',
                                                'APRIL',
                                                'MAY',
                                                'JUNE',
                                                'JULY',
                                                'AUGUST',
                                                'SEPTEMBER',
                                                'OCTOBER',
                                                'NOVEMBER',
                                                'DECEMBER')
         THEN
            IF OWA_PATTERN.match (str, '(\w \d{2}, \d{4})(.*)')
            THEN
               OWA_PATTERN.CHANGE (str, '(\w \d{2}, \d{4})(.*)', '\1');

               BEGIN
                  theDate := TO_DATE (str, 'MONTH DD, YYYY');
                  result := TRUE;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     result := FALSE;
               END;
            END IF;
         END IF;
      END IF;

      RETURN result;
   END hasValidDate;

   FUNCTION hasValidDateYorN (lockName IN bssm_locks.NAME%TYPE)
      RETURN VARCHAR2
   IS
   BEGIN
      IF hasValidDate (lockName)
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   END hasValidDateYorN;


   FUNCTION getLatestRblRunAmd
      RETURN DATE
   IS
      -- for initial run --
      retLatestRblRun   DATE := NULL;
      returnCode        NUMBER;
   BEGIN
      retLatestRblRun :=
         TO_DATE (amd_defaults.GetParamValue (PARAMS_LATEST_RBL_RUN_DATE),
                  'MM/DD/YYYY');
      --IF ( retLatestRblRun IS null ) THEN
      --   retLatestRblRun := REALLY_OLD_DATE ;
      --END IF ;
      RETURN retLatestRblRun;
   EXCEPTION
      WHEN OTHERS
      THEN
         returnCode :=
            ErrorMsg (
               pSourceName       => 'getLatestRblRunAmd',
               pTableName        => 'amd_params - problem getting latest Rbl run',
               pError_location   => 10,
               pReturn_code      => 99,
               pKey1             => '',
               pKey2             => '',
               pKey3             => '',
               pData             => '',
               pComments         => PKGNAME);
         RAISE;
   END getLatestRblRunAmd;

   FUNCTION getCurrentPeriod
      RETURN DATE
   IS
      retCurPeriod   DATE := NULL;
      returnCode     NUMBER;
   BEGIN
      retCurPeriod :=
         TO_DATE (amd_defaults.GetParamValue (PARAMS_CURRENT_PERIOD_DATE),
                  'MM/DD/YYYY');
      --IF ( retCurPeriod IS null ) THEN
      --   retCurPeriod := REALLY_OLD_DATE ;
      --END IF ;
      /* make sure 1st day of month */
      retCurPeriod := getFirstDateOfMonth (retCurPeriod);
      RETURN retCurPeriod;
   EXCEPTION
      WHEN OTHERS
      THEN
         returnCode :=
            ErrorMsg (
               pSourceName       => 'getCurrentPeriod',
               pTableName        => 'amd_params - problem getting current period',
               pError_location   => 20,
               pReturn_code      => 99,
               pKey1             => '',
               pKey2             => '',
               pKey3             => '',
               pData             => '',
               pComments         => PKGNAME);
         RAISE;
   END getCurrentPeriod;


   PROCEDURE setLatestRblRunAmd (pRblRunDate DATE)
   IS
   BEGIN
      UPDATE amd_param_changes
         SET param_value = TO_CHAR (pRblRunDate, 'MM/DD/YYYY'),
             effective_date = SYSDATE,
             user_id = PARAM_USER
       WHERE param_key = PARAMS_LATEST_RBL_RUN_DATE;

      COMMIT;
   END setLatestRblRunAmd;


   PROCEDURE setCurrentPeriod (pCurrentPeriodDate DATE)
   IS
   BEGIN
      UPDATE amd_param_changes
         SET param_value =
                TO_CHAR (getFirstDateOfMonth (pCurrentPeriodDate),
                         'MM/DD/YYYY'),
             effective_date = SYSDATE,
             user_id = PARAM_USER
       WHERE param_key = PARAMS_CURRENT_PERIOD_DATE;

      COMMIT;
   END setCurrentPeriod;



   PROCEDURE LoadAmdBssmSBasePartPeriods (
      pLockSid        bssm_s_base_part_periods.lock_sid%TYPE,
      pScenarioSid    bssm_s_base_part_periods.scenario_sid%TYPE)
   IS
      returnCode     NUMBER;
      recordExists   VARCHAR2 (1) := NULL;
   BEGIN
      -- make sure data exists before deleting local amd copy
      BEGIN
         SELECT 'x'
           INTO recordExists
           FROM bssm_s_base_part_periods
          WHERE     scenario_sid = pScenarioSid
                AND lock_sid = pLockSid
                AND ROWNUM = 1;
      EXCEPTION
         WHEN OTHERS
         THEN
            returnCode :=
               ErrorMsg (
                  pSourceName       => 'LoadAmdBssmSBasePartPeriods',
                  pTableName        => 'amd_bssm_s_base_part_periods',
                  pError_location   => 40,
                  pReturn_code      => 99,
                  pKey1             => 'lock_sid:' || pLockSid,
                  pKey2             => 'scenario_sid:' || pScenarioSid,
                  pKey3             => '',
                  pData             => '',
                  pComments         =>    PKGNAME
                                       || 'bssm locks indicates new run but problem retrieving bssm_s_base_part_periods.');
            RAISE;
      END;

      BEGIN
         mta_truncate_table ('amd_bssm_s_base_part_periods', 'reuse storage');
         COMMIT;

         INSERT INTO amd_bssm_s_base_part_periods
            SELECT LOCK_SID,
                   SCENARIO_SID,
                   SCENARIO_PERIOD,
                   NSN,
                   SRAN,
                   TARGET_STOCK01,
                   TARGET_STOCK02,
                   TARGET_STOCK03,
                   TARGET_STOCK04,
                   TARGET_STOCK05,
                   DEMAND_RATE01,
                   DEMAND_RATE02,
                   DEMAND_RATE03,
                   DEMAND_RATE04,
                   DEMAND_RATE05,
                   STOCK_LEVEL01,
                   STOCK_LEVEL02,
                   STOCK_LEVEL03,
                   STOCK_LEVEL04,
                   STOCK_LEVEL05,
                   PERCENT_REPLACE01,
                   PERCENT_REPLACE02,
                   PERCENT_REPLACE03,
                   PERCENT_REPLACE04,
                   PERCENT_REPLACE05,
                   REORDER_QUANT01,
                   REORDER_QUANT02,
                   REORDER_QUANT03,
                   REORDER_QUANT04,
                   REORDER_QUANT05,
                   SYSDATE
              FROM bssm_s_base_part_periods
             WHERE scenario_sid = pScenarioSid AND lock_sid = pLockSid;

         DBMS_OUTPUT.put_line (
            'LoadAmdBssmSBasePartPeriods: rows insert ' || SQL%ROWCOUNT);
         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            returnCode :=
               ErrorMsg (pSourceName       => 'LoadAmdBssmSBasePartPeriods',
                         pTableName        => 'amd_bssm_s_base_part_periods',
                         pError_location   => 50,
                         pReturn_code      => 99,
                         pKey1             => '',
                         pKey2             => '',
                         pKey3             => '',
                         pData             => '',
                         pComments         => PKGNAME);
            RAISE;
      END;
   END;

   --  amd_bssm_s_base_part_periods only can hold one rbl run, do not need to query by lock_sid scenario_sid
   PROCEDURE LoadTmpAmdPartLocForecasts
   IS
      returnCode   NUMBER;
   BEGIN
      writeMsg (
         pTableName        => 'tmp_amd_part_loc_forecasts',
         pError_location   => 60,
         pKey1             => 'LoadTmpAmdPartLocForecasts',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      mta_truncate_table ('tmp_amd_part_loc_forecasts', 'reuse storage');
      COMMIT;

      INSERT INTO tmp_amd_part_loc_forecasts (loc_sid,
                                              part_no,
                                              forecast_qty,
                                              action_code,
                                              last_update_dt)
           SELECT loc_sid,
                  spo_prime_part_no,
                  ROUND (SUM (NVL (demand_rate01, 0)), DP) forecast_qty,
                  Amd_Defaults.INSERT_ACTION,
                  SYSDATE
             FROM amd_bssm_s_base_part_periods bsbpp,
                  amd_nsns an,
                  amd_spare_networks asn,
                  amd_national_stock_items ansi,
                  amd_spare_parts parts
            WHERE     parts.is_spo_part = 'Y'
                  AND parts.part_no = parts.spo_prime_part_no
                  AND bsbpp.nsn = an.nsn
                  AND an.nsi_sid = ansi.nsi_sid
                  AND ansi.prime_part_no = parts.part_no
                  AND DECODE (
                         asn.loc_id,
                         Amd_Defaults.AMD_WAREHOUSE_LOCID, Amd_Defaults.BSSM_WAREHOUSE_SRAN,
                         asn.loc_id) = bsbpp.sran
                  AND ansi.action_code != Amd_Defaults.DELETE_ACTION
                  AND asn.action_code != Amd_Defaults.DELETE_ACTION
         GROUP BY spo_prime_part_no, loc_sid
           HAVING ROUND (SUM (NVL (demand_rate01, 0)), DP) > 0;

      DBMS_OUTPUT.put_line (
         'LoadTmpAmdPartLocForecasts: rows inserted ' || SQL%ROWCOUNT);

      writeMsg (
         pTableName        => 'tmp_amd_part_loc_forecasts',
         pError_location   => 70,
         pKey1             => 'LoadTmpAmdPartLocForecasts',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
   EXCEPTION
      WHEN OTHERS
      THEN
         returnCode :=
            ErrorMsg (pSourceName       => 'LoadTmpAmdPartLocForecasts',
                      pTableName        => 'tmp_amd_part_loc_forecasts',
                      pError_location   => 80,
                      pReturn_code      => 99,
                      pKey1             => '',
                      pKey2             => '',
                      pKey3             => '',
                      pData             => '',
                      pComments         => PKGNAME);
         RAISE;
   END LoadTmpAmdPartLocForecasts;

   PROCEDURE LoadLatestRblRun
   IS
      TYPE rblRec IS RECORD
      (
         lock_sid           bssm_locks.lock_sid%TYPE,
         rbl_scenario_sid   bssm_locks.RBL_SCENARIO_SID%TYPE,
         latestRblRunBssm   DATE,
         last_data_date     bssm_locks.LAST_DATA_DATE%TYPE
      );

      TYPE rblTab IS TABLE OF rblRec;

      rblRecs            rblTab;

      CURSOR rbl_cur
      IS
           SELECT lock_sid,
                  rbl_scenario_sid,
                  getLatestRblRunBssm (name) latestRblRunBssm,
                  last_data_date
             FROM bssm_locks
            WHERE     last_data_date = (SELECT MAX (last_data_date)
                                          FROM bssm_locks
                                         WHERE rbl_scenario_sid IS NOT NULL)
                  AND rbl_scenario_sid IS NOT NULL
                  AND hasValidDateYorN (name) = 'Y'
         ORDER BY getLatestRblRunBssm (name);

      latestRblRunAmd    DATE;
      latestRblRunBssm   DATE := NULL;
      lockSid            bssm_locks.lock_sid%TYPE;
      scenarioSid        VARCHAR2 (5);
      str                VARCHAR2 (100);
      rec                rbl_cur%ROWTYPE;
      returnCode         NUMBER;
      errorComment       VARCHAR2 (100) := NULL;
   BEGIN
      latestRblRunAmd := getLatestRblRunAmd;

      -- use the last row with the most recent date for latestRblRunBssm
      OPEN rbl_cur;

      FETCH rbl_cur BULK COLLECT INTO rblRecs;

      CLOSE rbl_cur;

      IF rblRecs.FIRST IS NOT NULL
      THEN
         FOR indx IN rblRecs.FIRST .. rblRecs.LAST
         LOOP
            latestRblRunBssm := rblRecs (indx).latestRblRunBssm;
            scenarioSid := rblRecs (indx).rbl_scenario_sid;
            lockSid := rblRecs (indx).lock_sid;
         END LOOP;
      END IF;

      IF latestRblRunBssm IS NULL
      THEN
         Raise_Application_Error (
            -20000,
            'latestRblRunBssm date is null. Perhaps the pattern to match the date changed or bssm locks has no rbl run.');
      ELSIF (TRUNC (latestRblRunBssm) > TRUNC (latestRblRunAmd))
      THEN
         -- keep amd copy since runs can be accidently deleted from bssm side
         LoadAmdBssmSBasePartPeriods (lockSid, scenarioSid);
         setLatestRblRunAmd (latestRblRunBssm);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         returnCode :=
            ErrorMsg (
               pSourceName       => 'LoadExtForecastAndLatestRblRun',
               pTableName        => 'amd_bssm_s_base_part_periods',
               pError_location   => 90,
               pReturn_code      => 99,
               pKey1             => 'latestRblRunAmd:' || latestRblRunAmd,
               pKey2             => 'latestRblRunBssm:' || latestRblRunBssm,
               pKey3             => '',
               pData             => '',
               pComments         => PKGNAME || ': ' || errorComment);
         RAISE;
   END LoadLatestRblRun;

   PROCEDURE LoadTmpAmdPartLocForecasts_Add
   IS
      currentPeriodAmd   DATE := getCurrentPeriod;
      currentPeriod      DATE := getFirstDateOfMonth (SYSDATE);
      returnCode         NUMBER;
   BEGIN
      setCurrentPeriod (currentPeriod);
      -- though rbl only quarterly run, parts can be added or deleted during each run
      -- which may be part of the last rbl run.  Load tmp_amd_part_loc_forecasts
      -- for subsequent diff whether new rbl run or not.
      LoadTmpAmdPartLocForecasts;
   EXCEPTION
      WHEN OTHERS
      THEN
         returnCode :=
            ErrorMsg (
               pSourceName       => 'LoadTmpAmdPartLocForecasts_Add',
               pTableName        => 'tmp_amd_part_loc_forecasts',
               pError_location   => 100,
               pReturn_code      => 99,
               pKey1             => 'currentPeriod:' || currentPeriod,
               pKey2             => 'currentPeriodAmd:' || currentPeriodAmd,
               pKey3             => '',
               pData             => '',
               pComments         => PKGNAME);
         RAISE;
   END LoadTmpAmdPartLocForecasts_Add;

   PROCEDURE UpdateAmdPartLocForecasts (
      pPartNo          amd_part_loc_forecasts.part_no%TYPE,
      pLocSid          amd_part_loc_forecasts.loc_sid%TYPE,
      pForecastQty     amd_part_loc_forecasts.forecast_qty%TYPE,
      pActionCode      amd_part_loc_forecasts.action_code%TYPE,
      pLastUpdateDt    amd_part_loc_forecasts.last_update_dt%TYPE)
   IS
   BEGIN
      UPDATE amd_part_loc_forecasts
         SET forecast_qty = pForecastQty,
             action_code = pActionCode,
             last_update_dt = pLastUpdateDt
       WHERE part_no = pPartNo AND loc_sid = pLocSid;
   END UpdateAmdPartLocForecasts;

   PROCEDURE InsertAmdPartLocForecasts (
      pPartNo          amd_part_loc_forecasts.part_no%TYPE,
      pLocSid          amd_part_loc_forecasts.loc_sid%TYPE,
      pForecastQty     amd_part_loc_forecasts.forecast_qty%TYPE,
      pActionCode      amd_part_loc_forecasts.action_code%TYPE,
      pLastUpdateDt    amd_part_loc_forecasts.last_update_dt%TYPE)
   IS
   BEGIN
      INSERT INTO amd_part_loc_forecasts (part_no,
                                          loc_sid,
                                          forecast_qty,
                                          action_code,
                                          last_update_dt)
           VALUES (pPartNo,
                   pLocSid,
                   pForecastQty,
                   pActionCode,
                   pLastUpdateDt);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         UpdateAmdPartLocForecasts (pPartNo,
                                    pLocSid,
                                    pForecastQty,
                                    pActionCode,
                                    pLastUpdateDt);
   END InsertAmdPartLocForecasts;



   FUNCTION InsertRow (
      pPartNo         amd_part_loc_forecasts.part_no%TYPE,
      pLocSid         amd_part_loc_forecasts.loc_sid%TYPE,
      pForecastQty    amd_part_loc_forecasts.forecast_qty%TYPE)
      RETURN NUMBER
   IS
      returnCode   NUMBER;
   BEGIN
      BEGIN
         InsertAmdPartLocForecasts (pPartNo,
                                    pLocSid,
                                    pForecastQty,
                                    Amd_Defaults.INSERT_ACTION,
                                    SYSDATE);
      EXCEPTION
         WHEN OTHERS
         THEN
            returnCode :=
               ErrorMsg (
                  pSourceName       => 'InsertRow.InsertAmdPartLocForecasts',
                  pTableName        => 'amd_part_loc_forecasts',
                  pError_location   => 110,
                  pReturn_code      => 99,
                  pKey1             => pPartNo,
                  pKey2             => pLocSid,
                  pKey3             => '',
                  pData             => '',
                  pComments         => PKGNAME);
            RAISE;
      END;

      RETURN SUCCESS;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FAILURE;
   END InsertRow;



   FUNCTION UpdateRow (
      pPartNo         amd_part_loc_forecasts.part_no%TYPE,
      pLocSid         amd_part_loc_forecasts.loc_sid%TYPE,
      pForecastQty    amd_part_loc_forecasts.forecast_qty%TYPE)
      RETURN NUMBER
   IS
      returnCode   NUMBER;
   BEGIN
      BEGIN
         UpdateAmdPartLocForecasts (pPartNo,
                                    pLocSid,
                                    pForecastQty,
                                    Amd_Defaults.UPDATE_ACTION,
                                    SYSDATE);
      EXCEPTION
         WHEN OTHERS
         THEN
            returnCode :=
               ErrorMsg (
                  pSourceName       => 'UpdateRow.UpdateAmdPartLocForecasts',
                  pTableName        => 'amd_part_loc_forecasts',
                  pError_location   => 130,
                  pReturn_code      => 99,
                  pKey1             => pPartNo,
                  pKey2             => pLocSid,
                  pKey3             => '',
                  pData             => '',
                  pComments         => PKGNAME);
            RAISE;
      END;

      RETURN SUCCESS;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FAILURE;
   END UpdateRow;


   FUNCTION DeleteRow (
      pPartNo         amd_part_loc_forecasts.part_no%TYPE,
      pLocSid         amd_part_loc_forecasts.loc_sid%TYPE,
      pForecastQty    amd_part_loc_forecasts.forecast_qty%TYPE)
      RETURN NUMBER
   IS
      returnCode   NUMBER;
   BEGIN
      BEGIN
         UpdateAmdPartLocForecasts (pPartNo,
                                    pLocSid,
                                    pForecastQty,
                                    Amd_Defaults.DELETE_ACTION,
                                    SYSDATE);
      EXCEPTION
         WHEN OTHERS
         THEN
            returnCode :=
               ErrorMsg (
                  pSourceName       => 'DeleteRow.UpdateAmdPartLocForecasts',
                  pTableName        => 'amd_part_loc_forecasts',
                  pError_location   => 150,
                  pReturn_code      => 99,
                  pKey1             => pPartNo,
                  pKey2             => pLocSid,
                  pKey3             => '',
                  pData             => '',
                  pComments         => PKGNAME);
            RAISE;
      END;

      RETURN SUCCESS;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FAILURE;
   END DeleteRow;



   PROCEDURE LoadInitial
   IS
      returnCode   NUMBER;
   BEGIN
      writeMsg (
         pTableName        => 'tmp_amd_part_loc_forecasts',
         pError_location   => 250,
         pKey1             => 'LoadInitial',
         pKey2             =>    'started at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

      LoadTmpAmdPartLocForecasts;
      mta_truncate_table ('amd_part_loc_forecasts', 'reuse storage');

      BEGIN
         INSERT INTO amd_part_loc_forecasts
            SELECT *
              FROM tmp_amd_part_loc_forecasts
             WHERE action_code != Amd_Defaults.DELETE_ACTION;
      EXCEPTION
         WHEN OTHERS
         THEN
            returnCode :=
               ErrorMsg (
                  pSourceName       => 'LoadInitial',
                  pTableName        => 'amd_part_loc_forecasts',
                  pError_location   => 260,
                  pReturn_code      => 99,
                  pKey1             => '',
                  pKey2             => '',
                  pKey3             => '',
                  pData             => '',
                  pComments         =>    PKGNAME
                                       || ': Insert into amd_part_loc_forecasts');
            RAISE;
      END;

      writeMsg (
         pTableName        => 'tmp_amd_part_loc_forecasts',
         pError_location   => 270,
         pKey1             => 'LoadInitial',
         pKey2             =>    'ended at '
                              || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
   END LoadInitial;

   PROCEDURE doExtForecast
   IS
   BEGIN
      LoadLatestRblRun;
      LoadTmpAmdPartLocForecasts_Add;
   END doExtForecast;

   PROCEDURE version
   IS
   BEGIN
      writeMsg (pTableName        => 'amd_part_loc_forecasts_pkg',
                pError_location   => 280,
                pKey1             => 'amd_part_loc_forecasts_pkg',
                pKey2             => '$Revision:   1.33  $');
      DBMS_OUTPUT.put_line (
         'amd_part_loc_forecasts_pkg: $Revision:   1.33  $');
   END version;

   FUNCTION getVersion
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN '$Revision:   1.33  $';
   END getVersion;
END AMD_PART_LOC_FORECASTS_PKG;
/