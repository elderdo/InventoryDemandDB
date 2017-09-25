/* vim: ff=unix:ts=2:sw=2:sts=2:expandtab:
*
          Rev 1.3
          Rev 1.0 init rev
          Rev 1.1 added loc_id 6/10/15
          Rev 1.2 added modeline 9/4/15
          Rev 1.3 added check of length using 
                  amd_defaults.getStartLocId + 5 9/10/15
**/
/* Formatted on 6/10/2015 1:21:41 PM (QP5 v5.256.13226.35538) */
WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO ON

EXEC amd_owner.mta_truncate_table('item','reuse storage');

DEFINE link = &1

INSERT INTO item (item_id,
                  received_item_id,
                  sc,
                  loc_id,
                  part,
                  prime,
                  condition,
                  status_del_when_gone,
                  status_servicable,
                  status_new_order,
                  status_accountable,
                  status_avail,
                  status_frozen,
                  status_active,
                  status_mai,
                  status_receiving_susp,
                  status_2,
                  status_3,
                  last_changed_datetime,
                  status_1,
                  created_datetime,
                  vendor_code,
                  qty,
                  order_no,
                  receipt_order_no)
   SELECT TRIM (item_id),
          TRIM (received_item_id),
          TRIM (sc),
          CASE
             WHEN     LENGTH (TRIM (sc)) >= amd_defaults.getStartLocId + 5
                  AND EXISTS
                         (SELECT NULL
                            FROM amd_spare_networks
                           WHERE loc_id =
                                    SUBSTR (TRIM (sc),
                                            amd_defaults.getStartLocId,
                                            6))
             THEN
                SUBSTR (TRIM (sc), amd_defaults.getStartLocId, 6)
             ELSE
                NULL
          END
             loc_id,
          TRIM (part),
          TRIM (prime),
          TRIM (condition),
          status_del_when_gone,
          status_servicable,
          status_new_order,
          status_accountable,
          status_avail,
          status_frozen,
          status_active,
          status_mai,
          status_receiving_susp,
          status_2,
          status_3,
          last_changed_datetime,
          status_1,
          created_datetime,
          TRIM (vendor_code),
          qty,
          TRIM (order_no),
          TRIM (receipt_order_no)
     FROM item@&&link
    WHERE     status_1 != 'D'
          AND condition NOT IN ('LDD')
          AND (   last_changed_datetime IS NOT NULL
               OR created_datetime IS NOT NULL);


@@scanItem.sql &&link

EXIT
