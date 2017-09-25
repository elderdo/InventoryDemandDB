/*
  vim: ff=unix:ts=2:sw=2:sts=2:autoindent:smartindent:expandtab:
      $Author:   Douglas S Elder
    $Revision:   1.0
        $Date:   24 Jan 2017
    $Workfile:   analyzeAmdDemands.sql  $
        
  
      Rev 1.0   24 Jan 2017
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
    ,TabName           => 'AMD_DEMANDS'
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
    ,IndName           => 'AMD_DEMANDS_IDX'
    ,Estimate_Percent  => 10
    ,Degree            => 4
    ,No_Invalidate  => FALSE);
END;
/

BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
     OwnName           => 'AMD_OWNER'
    ,IndName           => 'AMD_DEMANDS_PK'
    ,Estimate_Percent  => 10
    ,Degree            => 4
    ,No_Invalidate  => FALSE);
END;
/

EXIT
