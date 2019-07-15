/* vim: ff=unix:ts=2:sw=2:sts=2:expandtab:

      $Author:   zf297a  $
    $Revision:   1.7  $
        $Date:   4 Jan 2016
    $Workfile:   loadOrd1.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadOrd1.sql.-arc  $
/*
/*          Rev 1.7   7 Jan 2016           zf297a added delete of duplicates
/*          Rev 1.6   4 Jan 2016           zf297a added serial
/*          Rev 1.5   10 Sep 2015           zf297a fixed subquery's length check

/*          Rev 1.4   9 Jun 2015           zf297a added loc_id

/*          Rev 1.3   22 Oct 2012           zf297a
/*                added complete_datetime
/*          Rev 1.2   13 Dec 2010           c402417
/*      Added user_ref4 to the query per Laurie's request.
/*       
/*      Rev 1.1   20 Feb 2009 09:12:44   zf297a
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

EXEC amd_owner.mta_truncate_table('ord1','reuse storage');

DEFINE link = &1

INSERT INTO ord1 (order_no,
                  order_type,
                  sc,
                  loc_id,
                  part,
                  completed_docdate,
                  created_docdate,
                  action_taken,
                  original_location,
                  qty_due,
                  qty_completed,
                  completed_datetime,
                  need_date,
                  created_datetime,
                  condition,
                  ecd,
                  vendor_code,
                  accountable_yn,
                  user_ref4,
                  status,
                  qty_ordered,
                  unit_price,
                  po_price,
                  serial)
   SELECT TRIM (order_no),
          order_type,
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
          END,
          TRIM (part),
          completed_docdate,
          created_docdate,
          action_taken,
          TRIM (original_location),
          qty_due,
          qty_completed,
          completed_datetime,
          need_date,
          created_datetime,
          TRIM (condition),
          ecd,
          TRIM (vendor_code),
          accountable_yn,
          user_ref4,
          status,
          qty_ordered,
          unit_price,
          po_price,
          trim(serial)
     FROM ord1@&&link;

/* delete duplicates */
/* Formatted on 1/6/2016 5:10:04 PM (QP5 v5.256.13226.35538) */
DELETE FROM ord1
      WHERE order_no IN (      
      SELECT order_no
                           FROM (SELECT o.order_no,
                                        o.part,
                                        o.serial,
                                        o.created_docdate,
                                        ROW_NUMBER ()
                                        OVER (PARTITION BY o.part, o.serial
                                              ORDER BY o.created_docdate)
                                           RANK
                                   FROM ord1@amd_pgoldlb_link o
                                  WHERE o.action_taken = 'D')
                          WHERE RANK > 1) ;

EXIT;
