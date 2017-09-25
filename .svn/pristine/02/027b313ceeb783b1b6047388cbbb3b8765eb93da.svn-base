/* vim: ff=unix:ts=2:sw=2:sts=2:expandtab:

        $Author:        c402417        $
    $Revision :        1.5
         $Date:        28 Apr 2016        $
    $Workfile:        loadTrhi.sql
    Rev 1.1 Formatted on 6/9/2015 4:48:24 PM (QP5 v5.256.13226.35538) & added loc_id
    Rev 1.2 on 9/4/2015 added vim modeline
    Rev 1.3 on 9/10/2015 checked length in subquery using
                         amd_defaults.getStartLocId + 5
    Rev 1.4 on 4/28/2016 ChangeRequest  LBPSS00003522 Submitted Add TCNs DSC and DSG TRHI records to AMD GOLD table
    Rev 1.5 on 12/09/2016 Add columns user_ref10 and remarks per Jira Ticket LEGACY-49 - Note: qty, created_datetime and order_no were already being retrieved
*/


WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO ON

EXEC amd_owner.mta_truncate_table('trhi','reuse storage');

DEFINE link=&1

INSERT INTO trhi (tran_id,
                  created_datetime,
                  document_datetime,
                  qty,
                  part,
                  created_userid,
                  sc,
                  loc_id,
                  minus_datetime,
                  item_id,
                  order_no,
                  received_item_id,
                  ft_from_location,
                  tcn,
                  change_type,
                  voucher,
                  user_ref10,
                  remarks,
                  request_id)
   SELECT TRIM (tran_id),
          TO_CHAR (trhi.created_datetime),
          document_datetime,
          trhi.qty,
          TRIM (trhi.part),
          TRIM (trhi.created_userid),
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
                SUBSTR (trim(sc), amd_defaults.getStartLocId, 6)
             ELSE
                NULL
          END
             loc_id,
          TO_CHAR (minus_datetime),
          TRIM (item_id),
          TRIM (order_no),
          TRIM (received_item_id),
          TRIM (ft_from_location),
          TRIM (tcn),
          TRIM (change_type),
          TRIM (voucher),
          TRIM (trhi.user_ref10) user_ref10,
          TRIM (trhi.remarks) remarks,
          TRIM (trhi.request_id) request_id
     FROM trhi@&&link trhi, cat1@&&link cat1
    WHERE ( 
            (trhi.tcn =  'DII' AND trhi.minus_datetime IS NULL) 
            or (trhi.tcn in ('DSC','DSG'))
          ) 
          AND trhi.part = cat1.part
          AND cat1.source_code = 'F77';

EXIT
