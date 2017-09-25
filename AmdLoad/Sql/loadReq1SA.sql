/* Formatted on 6/18/2015 2:00:16 PM (QP5 v5.256.13226.35538) */
/* vim: ff=unix:ts=2:sw=2:sts=2:
 */
/*
      $Author:   Douglas S. Elder
    $Revision:   1.0
        $Date:   21 Feb 2017
    $Workfile:   loadReq1SA.sql

*      Rev 1.0   21 Feb 2017 Douglas S. Elder Initial revision.
**/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO ON

EXEC amd_owner.mta_truncate_table('req1sa','reuse storage');


INSERT INTO req1sa (request_id,
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
   SELECT request_id,
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
          purpose_code
     FROM goldsa_req1_v;

EXIT
