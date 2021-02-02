/* vim: ff=unix:ts=2:sw=2:sts=2:expandtab:
*
*
*
      $Author:   zf297a  $
    $Revision:   1.4  $
        $Date:   10 Sep 2015
    $Workfile:   loadTmp1.sql  $
*   
*      Rev 1.4   10 Sep 2015 adjusted subquery to check length using
                             amd_defaults.getStartLocId + 5 to 
                             accomodate 6 char from_loc_id and
                             to_loc_id
*      Rev 1.3   12 Jun 2015 added to_loc_id
*      Rev 1.2   10 Jun 2015 added from_loc_id

*      Rev 1.1   20 Feb 2009 09:23:50   zf297a
*   Added link variable
*   
*      Rev 1.0   20 May 2008 14:30:54   zf297a
*   Initial revision.
***/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO ON

EXEC amd_owner.mta_truncate_table('tmp1','reuse storage');

DEFINE link = &1

INSERT INTO tmp1 (qty_due,
                  returned_voucher,
                  status,
                  tcn,
                  from_sc,
                  from_loc_id,
                  to_sc,
                  to_loc_id,
                  from_datetime,
                  temp_out_id,
                  from_part,
                  est_return_date)
   SELECT qty_due,
          TRIM (returned_voucher),
          status,
          TRIM (tcn),
          TRIM (from_sc),
          CASE
             WHEN     LENGTH (TRIM (from_sc)) >= 8 + 5
                  AND EXISTS
                         (SELECT NULL
                            FROM amd_spare_networks
                           WHERE loc_id =
                                    SUBSTR (TRIM (from_sc),
                                            8,
                                            6))
             THEN
                SUBSTR (TRIM (from_sc), 8, 6)
             ELSE
                NULL
          END
             from_loc_id,
          TRIM (to_sc),
          CASE
             WHEN     LENGTH (TRIM (to_sc)) >= 8 + 5
                  AND EXISTS
                         (SELECT NULL
                            FROM amd_spare_networks
                           WHERE loc_id =
                                    SUBSTR (TRIM (to_sc),
                                            8,
                                            6))
             THEN
                SUBSTR (TRIM (to_sc), 8, 6)
             ELSE
                NULL
          END
             to_loc_id,
          from_datetime,
          TRIM (temp_out_id),
          TRIM (from_part),
          est_return_date
     FROM tmp1@&&link
    WHERE returned_voucher IS NULL AND status = 'O' AND tcn IN ('LNI', 'LBR');

EXIT
