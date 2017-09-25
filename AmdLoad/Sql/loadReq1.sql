/* Formatted on 6/18/2015 2:00:16 PM (QP5 v5.256.13226.35538) */
/* vim: ff=unix:ts=2:sw=2:sts=2:
 */
/*
      $Author:   zf297a  $
    $Revision:   1.5  $
        $Date:   21 Oct 2016
    $Workfile:   loadReq1.sql  $

*      Rev 1.5   21 Oct 2016 added purpose code - Jira LEGACY-36

*      Rev 1.4   10 Sep 2015 adjust length check to accomodate 6 char's
                             for select_from_loc_id

*      Rev 1.3   18 Jun 2015 added from_loc_id

*      Rev 1.2   09 Sep 2009 10:01:58   zf297a
*   Make sure status is not X and it is not C 
*   
*      Rev 1.1   20 Feb 2009 09:22:34   zf297a
*   Added link variable
*   
*      Rev 1.0   20 May 2008 14:30:52   zf297a
*   Initial revision.
**/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO ON

EXEC amd_owner.mta_truncate_table('req1','reuse storage');

DEFINE link = &1

INSERT INTO req1 (request_id,
                  created_datetime,
                  qty_requested,
                  prime,
                  nsn,
                  status,
                  allow_alts_yn,
                  qty_reserved,
                  select_from_part,
                  select_from_sc,
                  select_from_loc_id,
                  qty_canc,
                  mils_source_dic,
                  qty_due,
                  qty_issued,
                  need_date,
                  request_priority,
                  purpose_code)
   SELECT TRIM (request_id),
          created_datetime,
          qty_requested,
          TRIM (prime),
          TRIM (nsn),
          status,
          allow_alts_yn,
          qty_reserved,
          TRIM (select_from_part),
          TRIM (select_from_sc),
          CASE
             WHEN     LENGTH (TRIM (select_from_sc)) >= amd_defaults.getStartLocId + 5
                  AND EXISTS
                         (SELECT NULL
                            FROM amd_spare_networks
                           WHERE loc_id =
                                    SUBSTR (TRIM (select_from_sc),
                                            amd_defaults.getStartLocId,
                                            6))
             THEN
                SUBSTR (TRIM (select_from_sc), 8, 6)
             ELSE
                NULL
          END
             select_from_loc_id,
          qty_canc,
          TRIM (mils_source_dic),
          qty_due,
          qty_issued,
          need_date,
          request_priority,
          purpose_code
     FROM req1@&&link
    WHERE status NOT IN ('X', 'C');



EXIT
