-- analyzeGold.sql
-- Author: Douglas S. Elder
-- Date: 1/25/2017
-- Rev: 1.1
-- Rev 1.0 7/11/2014 initial rev
-- Rev 1.1 1/25/2017 turned echo off
-- Description: This script analyzes the tables and indexes for tables
-- loaded from GOLD

whenever oserror exit FAILURE
whenever sqlerror exit FAILURE

set time on
set timing on
set echo off
set sqlprompt "_USER'@'_CONNECT_IDENTIFIER > "

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
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'FEDCP1'
    ,Estimate_Percent  => 0
    ,Degree            => 4
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
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'NSN1P1'
    ,Estimate_Percent  => 0
    ,Degree            => 4
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
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'AMD_ISGP_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
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
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'ORDVP1'
    ,Estimate_Percent  => 0
    ,Degree            => 4
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
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName        => 'AMD_OWNER'
     ,IndName        => 'UIMS_PK'
    ,Estimate_Percent  => 0
    ,Degree            => 4
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
     ,TabName        => 'LVLS'
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

quit
