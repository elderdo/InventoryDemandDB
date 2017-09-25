/*
      $Author:   Douglas S Elder
    $Revision:   1.0
        $Date:   24 Jan 2017
         File:	 analyzeTmpAmdInTransits.sql
      Rev 1.0   24 Jan 2017
   Initial revision.
*/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO ON

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


BEGIN
  SYS.DBMS_STATS.GATHER_INDEX_STATS (
     OwnName           => 'AMD_OWNER'
    ,IndName           => 'TMP_AMD_IN_TRANSITS_PK'
    ,Estimate_Percent  => 10
    ,Degree            => 4
    ,No_Invalidate  => FALSE);
END;
/

EXIT
