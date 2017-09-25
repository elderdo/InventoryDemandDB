/* vim: ff=unix:ts=2:sw=2:expandtab:autoindent:smartindent:
      $Author:   zf297a  $
    $Revision:   1.2
        $Date:   24 Jan 2017
    $Workfile:   loadLatestRblRun.sql  $
         
/*      Rev 1.2   24 Jan 2017 analyze the updated table and its index
                  reformatted the code using Toad
/*   
/*      Rev 1.1   04 Jul 2008 00:33:46   zf297a
/*   Fixed package name.
/*   
/*      Rev 1.0   20 May 2008 15:01:38   zf297a
/*   Initial revision.
*/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO ON

EXEC amd_part_loc_forecasts_pkg.LoadLatestRblRun;

/* Optimize the table and index for the amd_bssm_s_base_part_periods
 */

BEGIN
   SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName            => 'AMD_OWNER',
      TabName            => 'AMD_BSSM_S_BASE_PART_PERIODS',
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
      IndName            => 'AMD_BSSM_S_BASE_PART_PDS_PK',
      Estimate_Percent   => 10,
      Degree             => 4,
      No_Invalidate      => FALSE);
END;
/


EXIT
