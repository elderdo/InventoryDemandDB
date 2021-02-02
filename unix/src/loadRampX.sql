/* vim: ff=unix:ts=2:sw=2:sts=2:expandtab:
*
      $Author:   zf297a  $
    $Revision:   1.3
        $Date:   10 Sep 2015
    $Workfile:   loadRamp.sql  $
/*   
/*      Rev 1.3   10 Sep 2015 adjust length check to accomodate 6 char's for sran

/*      Rev 1.2   10 Jun 2015 Improved creation of sran and reformatted the SQL DSE

/*      Rev 1.1   20 Feb 2009 09:19:08   zf297a
/*   Added link variable
/*   
/*      Rev 1.0   20 May 2008 14:30:52   zf297a
/*   Initial revision.
*/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO ON

EXEC amd_owner.mta_truncate_table('ramp','reuse storage');

DEFINE link = &1

INSERT INTO ramp (nsn,
                  sc,
                  sran,
                  serviceable_balance,
                  due_in_balance,
                  due_out_balance,
                  difm_balance,
                  date_processed,
                  avg_repair_cycle_time,
                  percent_base_condem,
                  percent_base_repair,
                  daily_demand_rate,
                  current_stock_number,
                  retention_level,
                  hpmsk_balance,
                  demand_level,
                  unserviceable_balance,
                  suspended_in_stock,
                  wrm_balance,
                  wrm_level,
                  requisition_objective,
                  hpmsk_level_qty,
                  spram_level,
                  spram_balance,
                  delete_indicator,
                  total_inaccessible_qty)
   SELECT TRIM (niin),
          TRIM (sc),
          CASE
             WHEN     LENGTH (TRIM (sc)) >= 8 + 5
                  AND EXISTS
                         (SELECT NULL
                            FROM amd_spare_networks
                           WHERE loc_id =
                                    SUBSTR (TRIM (sc),
                                            8,
                                            6))
             THEN
                SUBSTR (TRIM (sc), 8, 6)
             ELSE
                NULL
          END
             sran,
          serviceable_balance,
          due_in_balance,
          due_out_balance,
          difm_balance,
          date_processed,
          avg_repair_cycle_time,
          percent_base_condem,
          percent_base_repair,
          daily_demand_rate,
          SUBSTR (TRIM (current_stock_number), 1, 16),
          retention_level,
          hpmsk_balance,
          demand_level,
          unserviceable_balance,
          suspended_in_stock,
          wrm_balance,
          wrm_level,
          requisition_objective,
          hpmsk_level_qty,
          spram_level,
          spram_balance,
          TRIM (delete_indicator),
          total_inaccessible_qty
     FROM ramp@&&link
    WHERE delete_indicator IS NULL;

EXIT
