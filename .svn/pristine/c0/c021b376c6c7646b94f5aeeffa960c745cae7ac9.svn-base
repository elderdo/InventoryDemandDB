/* Formatted on 1/25/2017 5:43:35 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE AMD_OWNER.AMD_PART_LOC_FORECASTS_PKG
AS
   /*
        $Author:   Douglas S Elder
   $Revision:   1.13
          $Date:   25 Jan 2017
      $Workfile:   AMD_PART_LOC_FORECASTS_PKG.pks  $

           Rev 1.13 25 Jan 2017 DSE reformatted code

           Rev 1.12 added getVersion interface
  /*
  /*      Rev 1.11   24 Feb 2009 13:56:40   zf297a
  /*   Removed A2A code
  /*
  /*      Rev 1.10   07 Nov 2007 17:07:28   zf297a
  /*   Added type partLocForecastsTab.
  /*
  /*      Rev 1.9   Nov 01 2006 11:37:44   zf297a
  /*   Added interfaces for hasValidDate and hasValidDateYorN
  /*
  /*      Rev 1.8   Aug 18 2006 15:44:40   zf297a
  /*   Added interface doExtforecast and made insertTmpA2A_EF_AllPeriods public.
  /*
  /*      Rev 1.7   Jul 26 2006 10:10:42   zf297a
  /*   Made getLatestRblRunBssm public.  Made getCurrentPeriod, setCurrentPeriod, getLatestRblRunAmd, and setLatestRblRunAmd public.
  /*
  /*      Rev 1.6   Jul 26 2006 09:43:34   zf297a
  /*   Made getCurrentPeriod a public routine.
  /*
  /*      Rev 1.5   Jun 09 2006 12:16:58   zf297a
  /*   added interface version
  /*
  /*      Rev 1.4   May 12 2006 14:38:56   zf297a
  /*   added action_code to type partLocForecastsRec.
  /*
  /*      Rev 1.3   Feb 15 2006 21:52:10   zf297a
  /*   Added a ref cursor, a type, and a common process routine.
  /*
  /*      Rev 1.1   Jan 03 2006 07:56:40   zf297a
  /*   Added procedure loadA2AByDate
  /*
  /*      Rev 1.0   Dec 01 2005 09:44:12   zf297a
  /*   Initial revision.
  */
   PARAMS_LATEST_RBL_RUN_DATE       VARCHAR2 (50)
                                       := 'ext_forecast_last_rbl_run_date';
   PARAMS_CURRENT_PERIOD_DATE       VARCHAR2 (50)
                                       := 'ext_forecast_current_period';
   ROLLING_PERIOD_MONTHS   CONSTANT NUMBER := 60;
   PARAM_USER                       VARCHAR2 (50) := 'bsrm_loader';
   DEMAND_FORECAST_TYPE             VARCHAR2 (10) := 'External';
   -- decimal precision for forecast_qty --
   DP                      CONSTANT NUMBER := 4;

   SUCCESS                 CONSTANT NUMBER := 0;
   FAILURE                 CONSTANT NUMBER := 4;

   TYPE partLocForecastsRec IS RECORD
   (
      part_no        amd_part_loc_forecasts.PART_NO%TYPE,
      spo_location   amd_spare_networks.SPO_LOCATION%TYPE,
      forecast_qty   amd_part_loc_forecasts.FORECAST_QTY%TYPE,
      action_code    amd_part_loc_forecasts.action_code%TYPE
   );

   TYPE partLocForecastsTab IS TABLE OF partLocForecastsRec;

   TYPE partLocForecastsCur IS REF CURSOR RETURN partLocForecastsRec;

   FUNCTION getLatestRblRunBssm (lockName IN bssm_locks.NAME%TYPE)
      RETURN DATE;

   FUNCTION getLatestRblRunAmd
      RETURN DATE;

   PROCEDURE setLatestRblRunAmd (pRblRunDate DATE);

   FUNCTION getCurrentPeriod
      RETURN DATE;

   PROCEDURE setCurrentPeriod (pCurrentPeriodDate DATE);

   FUNCTION GetFirstDateOfMonth (pDate DATE)
      RETURN DATE;

   PRAGMA RESTRICT_REFERENCES (GetFirstDateOfMonth, WNDS);

   /*
    returns 1 if not empty, 0 if empty, -1 if any problem e.g.table not oracle table
   */
   -- FUNCTION IsTableEmpty(pTableName VARCHAR2) RETURN NUMBER  ;

   FUNCTION InsertRow (
      pPartNo         amd_part_loc_forecasts.part_no%TYPE,
      pLocSid         amd_part_loc_forecasts.loc_sid%TYPE,
      pForecastQty    amd_part_loc_forecasts.forecast_qty%TYPE)
      RETURN NUMBER;

   FUNCTION Updaterow (
      pPartNo         amd_part_loc_forecasts.part_no%TYPE,
      pLocSid         amd_part_loc_forecasts.loc_sid%TYPE,
      pForecastQty    amd_part_loc_forecasts.forecast_qty%TYPE)
      RETURN NUMBER;


   FUNCTION DeleteRow (
      pPartNo         amd_part_loc_forecasts.part_no%TYPE,
      pLocSid         amd_part_loc_forecasts.loc_sid%TYPE,
      pForecastQty    amd_part_loc_forecasts.forecast_qty%TYPE)
      RETURN NUMBER;

   PROCEDURE LoadInitial;

   PROCEDURE LoadLatestRblRun;

   PROCEDURE LoadTmpAmdPartLocForecasts_Add;

   -- added 8/17/2006
   PROCEDURE doExtForecast;

   -- added 6/9/2006 by dse
   PROCEDURE version;

   -- added 1/17/2012 by dse
   FUNCTION getVersion
      RETURN VARCHAR2;

   -- added 11/1/2006 by dse
   FUNCTION hasValidDate (lockName IN bssm_locks.NAME%TYPE)
      RETURN BOOLEAN;

   -- added 11/1/2006 by dse
   FUNCTION hasValidDateYorN (lockName IN bssm_locks.NAME%TYPE)
      RETURN VARCHAR2;
END AMD_PART_LOC_FORECASTS_PKG;
/