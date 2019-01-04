-- vim: set ff=unix:

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'ACTIVE_NIINS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_ACMII'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_ACTUAL_AC_USAGES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_ACTUAL_PERFORMANCES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_AC_ASSIGNS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_AIRCRAFTS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_AIRPORTS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_ARCHIVE_FLTOPS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_ARCHIVE_PARTSFC'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_AWARD_FEES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_AWARD_FEE_SCHDS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_BACKORDER_SPO_SUM'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_BACKORDER_SUM'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_BATCH_JOBS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_BATCH_JOB_STEPS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_BENCHSTOCK'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_BODS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_BSSM_RVT'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_BSSM_SOURCE'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_BSSM_S_BASE_PART_PERIODS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_CALENDARS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_CALENDAR_EXCEPTIONS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_CCN_PREFIX'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_COUNTS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_CUR_NSI_LOC_DISTRIBS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_DATA_OWNERS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_DEMANDS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_DEPOT_PARTNERING_LOCATIONS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_DMND_FRCST_CONSUMABLES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_ESCALATION_FACTORS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_FLEET_SIZES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_FLIGHT_STATS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_FORCASTED_AC_USAGES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_FORECASTED_AC_USAGES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_ICAOS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_ICAO_REGIONS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_ICAO_XREF'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_IN_REPAIR'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_IN_TRANSITS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_IN_TRANSITS_SUM'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_ISGP'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_L67_SOURCE'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_LOAD_DETAILS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_LOAD_STATUS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_LOAD_WARNINGS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_LOCATION_PART_LEADTIME'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_LOCATION_PART_OVERRIDE'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_LOCPART_OVERID_CONSUMABLES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_LTD_FLEET_SIZE_MEMBER'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_MAINT_TASK_DISTRIBS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_MISSION_FLIGHTS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_MISSION_TYPES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_NATIONAL_STOCK_ITEMS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_NSI_EFFECTS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_NSI_GROUPS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_NSI_LOC_DISTRIBS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_NSI_PARTS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_NSNS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_ON_BASE_REPAIR_COSTS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_ON_HAND_INVS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_ON_HAND_INVS_SUM'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_ON_ORDER'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_ON_ORDER_DATE_FILTERS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_ON_ORDER_FILTER_NAMES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_ORDER_PREFIXES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_PARAMS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_PARAM_CHANGES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_PART_EFFECTIVITIES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_PART_FACTORS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_PART_LOCATIONS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_PART_LOCS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_PART_LOC_FORECASTS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_PART_LOC_TIME_PERIODS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_PART_NEXT_ASSEMBLIES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_PLANNERS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_PLANNER_LOGONS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_PRICING_FACTORS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_PRODUCT_MODELS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_PRODUCT_STRUCTURE'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_PROJECTED_AC_USAGES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_RBL_PAIRS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_RELATED_NSI_PAIRS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_REPAIR_COST_DETAIL'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_REPAIR_INVS_SUM'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_REQS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_RETROFIT_SCHEDULES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_RETROFIT_SCHED_BLOCKS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_RETROFIT_TCTOS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_RMADS_SOURCE_TMP'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_RSP'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_RSP_SUM'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_SC_INCLUSIONS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_SENT_TO_A2A'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_SENT_TO_A2A_HISTORY'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_SHELF_LIFE_CODES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_SITE_ASSET_MGR'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_SPARE_NETWORKS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_SPARE_PARTS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_SPARE_PIPELINES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_SPO_COUNTS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_SPO_PARTS_HISTORY'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_STORAGE_COSTS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_TAV_LOCATIONS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_TEST_PARTS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_TIME_PERIODS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_TRANSPORT_MODES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_UOMS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_USE1'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_USERS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'AMD_USER_TYPE'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'CAT1'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'CGVT'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'CHGH'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'EXCEPTIONS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'FEDC'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'ITEM'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'ITEMSA'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'L11'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'LRU_BREAKDOWN'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'LVLS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'MILS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'MILS_XE4'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'MLIT'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'NSN1'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'ORD1'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'ORDV'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'POI1'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'PRC1'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'RAMP'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'REQ1'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'RSV1'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TAV_USER'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TEMP_AMD_BASE_PART_SES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TEMP_AMD_PART_NEXT_ASSEMBLIES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TEMP_AMD_PART_USAGES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TEMP_AMD_WORK_UNITS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TEMP_AMD_WUC_EFFECTIVITIES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TEMP_HAM'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TEMP_PRIMS_1'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP1'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_CAUSAL_FACTORS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_DEMANDS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_DMND_FRCST_CONSUMABLES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_EQUIVALENT_PARTS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_ESCALATION_FACTORS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_ICP_SBSS_INTERSECT'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_IN_REPAIR'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_IN_TRANSITS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_LOCATION_PART_LEADTIME'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_LOCATION_PART_OVERRIDE'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_NATIONAL_STOCK_ITEMS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_NSN_WUC_XREFS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_ON_BASE_REPAIR_COSTS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_ON_HAND_INVS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_ON_ORDER'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_PART_COST_SCHEDS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_PART_FACTORS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_PART_LOCS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_PART_LOC_FORECASTS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_PLANNER_PARTS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_REQS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_RSP'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_AMD_SPARE_PARTS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_BRASS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_DAC_RAW'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_FUTUREBASE'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_LCCOST'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_LCF_1'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_LCF_ICP'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_LCF_RAW'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_LOCPART_OVERID_CONSUMABLES'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_MAIN'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TMP_RBL'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'TRHI'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'UIMS'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'VENC'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'VENDOR_MASTER'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'VENN'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'AMD_OWNER'
     ,TabName        => 'WHSE'
    ,Estimate_Percent  => 0
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE 1'
    ,Degree            => 4
    ,Cascade           => FALSE
    ,No_Invalidate     => FALSE);
END;
/


BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ACTIVE_NIINS_PK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ACT_PERF__AMD_UOMS_FK_I'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMDLOCPARTOVERIDCONSUMABLES_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ACMII_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ACTUAL_AC_USAGES_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ACTUAL_PERFORMANCES_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_AC_ASSIGNS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_AIRCRAFTS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_AIRCRAFTS_UC01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_AIRCRAFTS_UC02'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_AIRCRAFTS_UC03'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_AIRCRAFTS_UC04'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_AIRCRAFTS_UC05'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_AIRPORTS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ARCHIVE_FLTOPS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ARCHIVE_PARTSFC_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_AWARD_FEES_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_BACKORDER_SPO_SUM_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_BACKORDER_SUM_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_BATCH_JOBS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_BATCH_JOB_STEPS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_BODS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_BSSM_RVT_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_BSSM_S_BASE_PART_PDS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_CALENDARS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_CALENDAR_EXCEPTIONS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_COUNTS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_CUR_NSI_LOC_DISTRIBS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_DATA_OWNERS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_DEMANDS_IDX'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_DEMANDS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_DEPOT_PARTNER_LOCS_PK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_DMND_FRCST_CONSUMABLES_NK5'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_DMND_FRCST_CONSUMABL_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ESCALATION_FACTORS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_FLEET_SIZES_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_FLEET_SIZE_MEMBER_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_FLIGHT_STATS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_FORCASTED_AC_USAGES_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_FOR_AC_USAGES_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_FOR__AMD_UOM_FK01_FK_I'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_FOR__FK_I'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ICAOS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ICAO_REGIONS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ICAO_XREF_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_IN_REPAIR_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_IN_REPAIR_NK02'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_IN_REPAIR_NK03'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_IN_REPAIR_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_IN_TRANSITS_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_IN_TRANSITS_NK02'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_IN_TRANSITS_NK03'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_IN_TRANSITS_NK04'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_IN_TRANSITS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_IN_TRANSITS_SUM_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ISGP_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_L67_SOURCE_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_LOAD_DETAILS_KEY_1_I'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_LOAD_DETAILS_LOAD_NO_I'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_LOAD_STATUS_LOAD_DATE_I'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_LOAD_WARNINGS_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_LOCATION_PART_LEADTIME_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_LOCATION_PART_OVERRIDE_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_MAINT_TASK_DISTRIBS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_MISSION_FLIGHTS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_MISSION_TYPES_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_NATIONAL_STOCK_ITEMS_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_NATIONAL_STOCK_ITEMS_NK02'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_NATIONAL_STOCK_ITEMS_NK03'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_NATIONAL_STOCK_ITEMS_NK04'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_NATIONAL_STOCK_ITEMS_NK05'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_NATIONAL_STOCK_ITEMS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_NATIONAL_STOCK_ITEMS_UC01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_NSI_EFFECTS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_NSI_GROUPS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_NSI_LOC_DISTRIBS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_NSI_PARTS_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_NSI_PARTS_NK02'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_NSI_PARTS_NK03'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_NSI_PARTS_NK04'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_NSI_PARTS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_NSNS_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_NSNS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ON_BASE_REPAIR_COSTS_UK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ON_HAND_INVS_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ON_HAND_INVS_NK02'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ON_HAND_INVS_NK03'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ON_HAND_INVS_NK04'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ON_HAND_INVS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ON_HAND_INVS_SUM_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ON_ORDER_DATE_FILTER_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ON_ORDER_FILTER_NAMES_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ON_ORDER_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ON_ORDER_NK02'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ON_ORDER_NK03'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ON_ORDER_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ON_ORDER_U01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ORDER_PREFIXES_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_PARAMS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_PARAM_CHANGES_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_PART_EFF_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_PART_FACTORS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_PART_LOCATIONS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_PART_LOCS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_PART_LOC_FORECASTS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_PART_LOC_TIME_PERIODS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_PART_NEXT_ASSEMBLIES_PK2'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_PART_NEXT_ASSM_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_PLANNERS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_PLANNER_LOGONS_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_PLANNER_LOGONS_NK02'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_PLANNER_LOGONS_NK03'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_PLANNER_LOGONS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_PRICING_FACTORS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_PRODUCT_MODELS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_PRODUCT_STRUCTURE_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_PROJ_AC_USAGES_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_RBL_PAIRS_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_RBL_PAIRS_NK02'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_RBL_PAIRS_NK03'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_RBL_PAIRS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_RELATED_NSI_PAIRS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_REPAIR_COST_DETAILS_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_REPAIR_COST_DETAIL_NK02'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_REPAIR_INVS_SUM_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_REPIAR_COST_DETAIL_NK03'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_REQS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_RETROFIT_SCHEDULES_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_RETROFIT_SCHED_BLOCKS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_RLB_PAIRS_NK04'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_RMADS_SOURCE_TMP_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_RSP_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_RSP_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_RSP_SUM_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SC_INCLUSIONS_I01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SENT_TO_A2A_HISTORY_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SENT_TO_A2A_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SENT_TO_A2A_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SHELF_LIFE_CODES_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SITE_ASSET_MGR_PK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_NETWORKS_AK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_NETWORKS_AK2'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_NETWORKS_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_NETWORKS_NK03'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_NETWORKS_NK04'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_NETWORKS_NK05'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_NETWORKS_NK06'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_NETWORKS_NK07'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_NETWORKS_NK08'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_NETWORKS_NK09'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_NETWORKS_PK2'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_NET_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_PARTS_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_PARTS_NK02'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_PARTS_NK03'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_PARTS_NK04'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_PARTS_NK07'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_PARTS_NK08'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_PARTS_NK09'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_PARTS_NK10'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_PARTS_NK11'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_PARTS_NK12'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_PARTS_NK13'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_PARTS_NK14'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_PARTS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPARE_PIPELINES_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPO_COUNTS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPO_PARTS_HISTORY_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPO_PARTS_HISTORY_NK02'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_SPO_PARTS_HISTORY_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_STORAGE_COSTS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_TAV_LOCATIONS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_TCTOS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_TEST_PARTS_NSN_I'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_TEST_PARTS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_TIME_PERIODS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_TIME_PERIODS_UC01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_TRANSPORT_MODES_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_UOMS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_UOMS_UC01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_USE1_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_USE1_NK02'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_USE1_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_USE1_UK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_USER1_NK03'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_USERS_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_USERS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_USER_TYPE_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AWARD__FK_I'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'CAT1I2'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'CAT1I3'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'CAT1P1'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'CAT1_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'CAT1_NK02'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'CAT1_NK03'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'CAT1_NK05'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'CAT1_NK06'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'CAT1_NK07'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'CAT1_NK08'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'CAT1_NK10'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'CAT1_NK11'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'CAT1_TEMP'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'CAT1_TEMP1'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'FEDCP1'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'FEESCHD_AWARD_FK_I'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'FEESCHD_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEMC22'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEMI17'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEMI18'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEMI19'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEMI21'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEMI7'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEMI8'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEMI9'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEMP1'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEMSA_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEMSA_NK02'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEMSA_NK03'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEMSA_NK04'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEMSA_NK05'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEMSA_NK06'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEMSA_NK07'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEMSA_NK08'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEMSA_NK09'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEMSA_NK10'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEMSA_NK11'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEM_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEM_NK02'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEM_NK03'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEM_NK04'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEM_NK05'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEM_NK06'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEM_NK07'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEM_NK08'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEM_NK09'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEM_NK10'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEM_NK11'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEM_NK12'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEM_NK13'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ITEM_NK14'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'L11_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'L11_NK02'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'L11_NK03'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'LCCOST_MID'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'LCCOST_PN'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'LCCOST_WUC'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'LRU_BREAKDOWN_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'LRU_BREAKDOWN_NK02'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'LRU_BREAKDOWN_NK03'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'LRU_BREAKDOWN_NK04'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'LRU_BREAKDOWN_NK05'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'LRU_BREAKDOWN_NK06'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'LRU_BREAKDOWN_NK07'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'LRU_BREAKDOWN_NK08'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'LRU_BREAKDOWN_NK09'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'LRU_BREAKDOWN_NK10'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'LRU_BREAKDOWN_NK11'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'LRU_BREAKDOWN_NK12'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'LVLS_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'LVLS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'MILSI2'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'MILSI3'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'MILSI4'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'MILSI5'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'MILSI6'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'MILSP1'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'MLITP1'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'MLIT_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'NSN1P1'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ORD1I01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ORD1I02'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ORD1I03'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ORD1I04'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ORD1I05'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ORD1I06'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ORD1I07'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ORD1I08'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ORD1I09'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ORD1I10'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ORD1P1'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ORD1_PART_INDEX'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ORDVP1'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'POI1P1'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'POI1_PART_INDEX'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'PRC1I2_NEW_IDX'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'PRC1P1'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'RAMPP1'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'RAMP_CSN_SC'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'RAMP_FCN_CSN_SC'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'RAMP_IDX01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'RAMP_IDX02'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'RAMP_IDX04'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'RSV1_FCN_TO_SC'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'RSV1_ITEM_ID_IDX'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'RSV1_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TEMP_AMD_BASE_PART_SES_UK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TEMP_AMD_BASE_PART_SES_UK02'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TM8_PN'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMP1_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMP1_NK02'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMP1_NK03'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMP1_NK04'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMP1_NK05'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMP1_NK06'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMP8_PO'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMP8_PO_DATE'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMPAMD_NSN_WUC_XREF_I'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMPAMD_PART_COST_SCHED_PART_I'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMPAMD_PLANNER_PARTS_I'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMPAMD_SPARE_PART_CAGE_I'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMPAMD_SPARE_PART_NSN_I'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMPLOCPARTOVERIDCONSUMABLES_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMP_AMD_DEMANDS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMP_AMD_DMND_FRCST_CONSUMBL_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMP_AMD_LOC_PART_LEADTIME_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMP_AMD_LOC_PART_OVERRIDE_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMP_AMD_ON_HAND_INVS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMP_AMD_ON_ORDER_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMP_AMD_PART_FACTORS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMP_AMD_PART_LOCS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMP_AMD_PART_LOC_FORECASTS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMP_DAC_RAW_FK1'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMP_LCF_1_NK1'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMP_LCF_1_NK2'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TMP_LCF_ICP_NK1'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII1'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII10'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII11'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII12'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII13'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII14'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII15'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII16'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII17'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII18'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII19'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII2'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII20'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII21'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII22'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII23'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII24'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII25'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII26'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII27'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII28'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII29'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII3'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII30'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII4'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII5'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII6'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHII9'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'TRHIP1'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'UIMS_NK01'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'UIMS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'VENCI2'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'VENCP1'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'VENNP1'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'VENN_CAGE_INDEX'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'WHSE_PART'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'WHSE_PART_SC'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'WHSE_SC'
    ,Estimate_Percent  => 0
    ,Degree            => 4
    ,No_Invalidate     => FALSE);
END;
/

quit
