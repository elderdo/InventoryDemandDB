/* vim: ff=unix:ts=2:sw=2:sts=2:expandtab:autoindent:smartindent:
      $Author:   Douglas S Elder
    $Revision:   1.0
        $Date:   24 Jan 2017
    $Workfile:   analyzeTmpAmdSpareParts.sql  $

      Rev 1.0   24 Jan 2017 Douglas Elder - optimize by analyzing the table 
                            and its indexes
*/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO OFF

BEGIN
   SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName            => 'AMD_OWNER',
      TabName            => 'TMP_AMD_SPARE_PARTS',
      Estimate_Percent   => 10,
      Method_Opt         => 'FOR ALL COLUMNS SIZE 1',
      Degree             => 4,
      Cascade            => TRUE,
      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (OwnName            => 'AMD_OWNER',
                                      IndName            => 'TMPAMD_SPARE_PART_CAGE_I',
                                      Estimate_Percent   => 10,
                                      Degree             => 4,
                                      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (OwnName            => 'AMD_OWNER',
                                      IndName            => 'TMPAMD_SPARE_PART_NSN_I',
                                      Estimate_Percent   => 10,
                                      Degree             => 4,
                                      No_Invalidate      => FALSE);
END;
/

EXIT
