/*
      $Author:   Douglas S Elder
    $Revision:   1.1
        $Date:   25 Jan 2017
    $Workfile:   analyzeTmpAmdLocationPartLeadtime.sql
   
      Rev 1.0   19 Jun 2008 10:09:16   zf297a
      Rev 1.1   25 Jan 2017 DSE add set serveroutput and reformatted code
   Initial revision.
*/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO OFF

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

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
     OwnName           => 'AMD_OWNER'
    ,IndName           => 'TMP_AMD_LOC_PART_LEADTIME_PK'
    ,Estimate_Percent  => 10
    ,Degree            => 4
    ,No_Invalidate  => FALSE);
END;
/

EXIT
