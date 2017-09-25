/*
      $Author:   Douglas S Elder
    $Revision:   1.0
        $Date:   25 Jan 2017
         File:   analyzeTmpLcfIcp.sql	
      Rev 1.0   25 Jan 2017
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
    ,TabName           => 'TMP_LCF_ICP'
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
    ,IndName           => 'TMP_LCF_ICP_NK1'
    ,Estimate_Percent  => 10
    ,Degree            => 4
    ,No_Invalidate  => FALSE);
END;
/

EXIT
