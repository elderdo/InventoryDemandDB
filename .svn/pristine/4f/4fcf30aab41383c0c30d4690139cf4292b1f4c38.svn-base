-- vim: set ff=unix:
whenever sqlerror CONTINUE
whenever oserror exit FAILURE

set time on
set timing on
set echo off

set sqlprompt "_USER'@'_CONNECT_IDENTIFIER > "


BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'ACTIVE_NIINS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_ACMII'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_ACTUAL_AC_USAGES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_ACTUAL_PERFORMANCES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_AC_ASSIGNS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_AIRCRAFTS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_AIRPORTS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_ARCHIVE_FLTOPS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_ARCHIVE_PARTSFC'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_AWARD_FEES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_AWARD_FEE_SCHDS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_BACKORDER_SPO_SUM'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_BACKORDER_SUM'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_BATCH_JOBS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_BATCH_JOB_STEPS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_BENCHSTOCK'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_BODS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_BSSM_RVT'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_BSSM_SOURCE'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_BSSM_S_BASE_PART_PERIODS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_CALENDARS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_CALENDAR_EXCEPTIONS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_CCN_PREFIX'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_COUNTS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_CUR_NSI_LOC_DISTRIBS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_DATA_OWNERS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_DEMANDS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_DEPOT_PARTNERING_LOCATIONS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_DMND_FRCST_CONSUMABLES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_ESCALATION_FACTORS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_FLEET_SIZES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_FLIGHT_STATS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_FORCASTED_AC_USAGES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_FORECASTED_AC_USAGES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_ICAOS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_ICAO_REGIONS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_ICAO_XREF'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_IN_REPAIR'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_IN_TRANSITS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_IN_TRANSITS_SUM'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_ISGP'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_L67_SOURCE'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_LOAD_DETAILS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_LOAD_STATUS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_LOAD_WARNINGS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_LOCATION_PART_LEADTIME'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_LOCATION_PART_OVERRIDE'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_LOCPART_OVERID_CONSUMABLES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_LTD_FLEET_SIZE_MEMBER'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_MAINT_TASK_DISTRIBS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_MISSION_FLIGHTS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_MISSION_TYPES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_NATIONAL_STOCK_ITEMS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_NSI_EFFECTS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_NSI_GROUPS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_NSI_LOC_DISTRIBS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_NSI_PARTS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_NSNS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_ON_BASE_REPAIR_COSTS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_ON_HAND_INVS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_ON_HAND_INVS_SUM'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_ON_ORDER'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_ON_ORDER_DATE_FILTERS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_ON_ORDER_FILTER_NAMES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_ORDER_PREFIXES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_PARAMS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_PARAM_CHANGES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_PART_EFFECTIVITIES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_PART_FACTORS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_PART_LOCATIONS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_PART_LOCS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_PART_LOC_FORECASTS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_PART_LOC_TIME_PERIODS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_PART_NEXT_ASSEMBLIES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_PLANNERS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_PLANNER_LOGONS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_PRICING_FACTORS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_PRODUCT_MODELS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_PRODUCT_STRUCTURE'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_PROJECTED_AC_USAGES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_RBL_PAIRS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_RELATED_NSI_PAIRS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_REPAIR_COST_DETAIL'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_REPAIR_INVS_SUM'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_REQS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_RETROFIT_SCHEDULES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_RETROFIT_SCHED_BLOCKS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_RETROFIT_TCTOS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_RMADS_SOURCE_TMP'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_RSP'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_RSP_SUM'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_SC_INCLUSIONS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_SENT_TO_A2A'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_SENT_TO_A2A_HISTORY'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_SHELF_LIFE_CODES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_SITE_ASSET_MGR'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_SPARE_NETWORKS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_SPARE_PARTS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_SPARE_PIPELINES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_SPO_COUNTS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_SPO_PARTS_HISTORY'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_STORAGE_COSTS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_TAV_LOCATIONS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_TEST_PARTS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_TIME_PERIODS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_TRANSPORT_MODES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_UOMS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_USE1'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_USERS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'AMD_USER_TYPE'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'CAT1'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'CGVT'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'CHGH'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'EXCEPTIONS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'FEDC'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'ITEM'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'ITEMSA'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'L11'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'LRU_BREAKDOWN'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'LVLS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'MILS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'MILS_XE4'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'MLIT'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'NSN1'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'ORD1'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'ORDV'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'POI1'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'PRC1'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'RAMP'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'REQ1'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'RSV1'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TAV_USER'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TEMP_AMD_BASE_PART_SES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TEMP_AMD_PART_NEXT_ASSEMBLIES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TEMP_AMD_PART_USAGES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TEMP_AMD_WORK_UNITS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TEMP_AMD_WUC_EFFECTIVITIES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TEMP_HAM'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TEMP_PRIMS_1'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP1'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_CAUSAL_FACTORS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_DEMANDS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_DMND_FRCST_CONSUMABLES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_EQUIVALENT_PARTS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_ESCALATION_FACTORS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_ICP_SBSS_INTERSECT'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_IN_REPAIR'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_IN_TRANSITS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_LOCATION_PART_LEADTIME'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_LOCATION_PART_OVERRIDE'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_NATIONAL_STOCK_ITEMS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_NSN_WUC_XREFS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_ON_BASE_REPAIR_COSTS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_ON_HAND_INVS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_ON_ORDER'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_PART_COST_SCHEDS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_PART_FACTORS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_PART_LOCS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_PART_LOC_FORECASTS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_PLANNER_PARTS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_REQS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_RSP'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_AMD_SPARE_PARTS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_BRASS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_DAC_RAW'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_FUTUREBASE'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_LCCOST'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_LCF_1'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_LCF_ICP'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_LCF_RAW'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_LOCPART_OVERID_CONSUMABLES'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_MAIN'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TMP_RBL'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'TRHI'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'UIMS'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'VENC'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'VENDOR_MASTER'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'VENN'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
     OwnName           => 'AMD_OWNER'
    ,TabName           => 'WHSE'
    ,Estimate_Percent  => 10
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;
/
/

quit
