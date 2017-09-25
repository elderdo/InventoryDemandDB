/* vim: ff=unix:ts=2:sw=2:sts=2:expandtab:autoindent:smartindent:
      $Author:   Douglas S Elder
    $Revision:   1.0
        $Date:   24 Jan 2017
    $Workfile:   analyzeAmdSpareNetworks.sql  $
   
        Rev 1.0   24 Jan 2017

*/


WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO OFF

BEGIN
   SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName            => 'AMD_OWNER',
      TabName            => 'AMD_SPARE_NETWORKS',
      Estimate_Percent   => 10,
      Method_Opt         => 'FOR ALL COLUMNS SIZE 1',
      Degree             => 4,
      Cascade            => TRUE,
      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (OwnName            => 'AMD_OWNER',
                                      IndName            => 'AMD_SPARE_NETWORKS_AK01',
                                      Estimate_Percent   => 10,
                                      Degree             => 4,
                                      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (OwnName            => 'AMD_OWNER',
                                      IndName            => 'AMD_SPARE_NETWORKS_AK2',
                                      Estimate_Percent   => 10,
                                      Degree             => 4,
                                      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (OwnName            => 'AMD_OWNER',
                                      IndName            => 'AMD_SPARE_NETWORKS_NK01',
                                      Estimate_Percent   => 10,
                                      Degree             => 4,
                                      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (OwnName            => 'AMD_OWNER',
                                      IndName            => 'AMD_SPARE_NETWORKS_NK03',
                                      Estimate_Percent   => 10,
                                      Degree             => 4,
                                      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (OwnName            => 'AMD_OWNER',
                                      IndName            => 'AMD_SPARE_NETWORKS_NK04',
                                      Estimate_Percent   => 10,
                                      Degree             => 4,
                                      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (OwnName            => 'AMD_OWNER',
                                      IndName            => 'AMD_SPARE_NETWORKS_NK05',
                                      Estimate_Percent   => 10,
                                      Degree             => 4,
                                      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (OwnName            => 'AMD_OWNER',
                                      IndName            => 'AMD_SPARE_NETWORKS_NK06',
                                      Estimate_Percent   => 10,
                                      Degree             => 4,
                                      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (OwnName            => 'AMD_OWNER',
                                      IndName            => 'AMD_SPARE_NETWORKS_NK07',
                                      Estimate_Percent   => 10,
                                      Degree             => 4,
                                      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (OwnName            => 'AMD_OWNER',
                                      IndName            => 'AMD_SPARE_NETWORKS_NK08',
                                      Estimate_Percent   => 10,
                                      Degree             => 4,
                                      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (OwnName            => 'AMD_OWNER',
                                      IndName            => 'AMD_SPARE_NETWORKS_NK09',
                                      Estimate_Percent   => 10,
                                      Degree             => 4,
                                      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (OwnName            => 'AMD_OWNER',
                                      IndName            => 'AMD_SPARE_NETWORKS_NK10',
                                      Estimate_Percent   => 10,
                                      Degree             => 4,
                                      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (OwnName            => 'AMD_OWNER',
                                      IndName            => 'AMD_SPARE_NETWORKS_NK11',
                                      Estimate_Percent   => 10,
                                      Degree             => 4,
                                      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (OwnName            => 'AMD_OWNER',
                                      IndName            => 'AMD_SPARE_NETWORKS_PK2',
                                      Estimate_Percent   => 10,
                                      Degree             => 4,
                                      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (OwnName            => 'AMD_OWNER',
                                      IndName            => 'AMD_SPARE_NET_PK',
                                      Estimate_Percent   => 10,
                                      Degree             => 4,
                                      No_Invalidate      => FALSE);
END;
/

EXIT
