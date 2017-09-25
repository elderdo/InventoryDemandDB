/* Formatted on 1/24/2017 2:13:47 PM (QP5 v5.287) */
/* vim: ff=unix:ts=2:sw=2:sts=2:autoindent:smartindent:expandtab:
      $Author:   Douglas S. Elder
    $Revision:   1.0  $
        $Date:   25 Jan 2017
    $Workfile:   analyzeAmdNationalStockItems.sql  $
       Rev 1.0   25 Jan 2017
*/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO OFF

BEGIN
   SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName            => 'AMD_OWNER',
      TabName            => 'AMD_NATIONAL_STOCK_ITEMS',
      Estimate_Percent   => 10,
      Method_Opt         => 'FOR ALL COLUMNS SIZE 1',
      Degree             => 4,
      Cascade            => TRUE,
      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName            => 'AMD_OWNER',
      IndName            => 'AMD_NATIONAL_STOCK_ITEMS_NK01',
      Estimate_Percent   => 10,
      Degree             => 4,
      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName            => 'AMD_OWNER',
      IndName            => 'AMD_NATIONAL_STOCK_ITEMS_NK02',
      Estimate_Percent   => 10,
      Degree             => 4,
      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName            => 'AMD_OWNER',
      IndName            => 'AMD_NATIONAL_STOCK_ITEMS_NK03',
      Estimate_Percent   => 10,
      Degree             => 4,
      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName            => 'AMD_OWNER',
      IndName            => 'AMD_NATIONAL_STOCK_ITEMS_NK04',
      Estimate_Percent   => 10,
      Degree             => 4,
      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName            => 'AMD_OWNER',
      IndName            => 'AMD_NATIONAL_STOCK_ITEMS_NK05',
      Estimate_Percent   => 10,
      Degree             => 4,
      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName            => 'AMD_OWNER',
      IndName            => 'AMD_NATIONAL_STOCK_ITEMS_NK06',
      Estimate_Percent   => 10,
      Degree             => 4,
      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName            => 'AMD_OWNER',
      IndName            => 'AMD_NATIONAL_STOCK_ITEMS_PK',
      Estimate_Percent   => 10,
      Degree             => 4,
      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName            => 'AMD_OWNER',
      IndName            => 'AMD_NATIONAL_STOCK_ITEMS_UC01',
      Estimate_Percent   => 10,
      Degree             => 4,
      No_Invalidate      => FALSE);
END;
/

BEGIN
   SYS.DBMS_STATS.GATHER_INDEX_STATS (
      OwnName            => 'AMD_OWNER',
      IndName            => 'AMD_NATIONAL_STOCK_ITESM_NK06',
      Estimate_Percent   => 10,
      Degree             => 4,
      No_Invalidate      => FALSE);
END;
/

EXIT
