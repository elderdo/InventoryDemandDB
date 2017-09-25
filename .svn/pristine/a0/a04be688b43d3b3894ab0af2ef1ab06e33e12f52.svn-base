/* vim: ff=unix:ts=2:sw=2:sts=2:autoindent:smartindent:expandtab:
      $Author:   Douglas S. Elder
    $Revision:   1.0  $
        $Date:   24 Jan 2017
    $Workfile:   analyzeAmdBssmSource.sql  $
       Rev 1.0   24 Jan 2017
*/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO OFF


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

EXIT
