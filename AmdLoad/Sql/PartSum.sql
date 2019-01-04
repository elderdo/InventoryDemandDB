/* 
*  vim: ff=unix:ts=2:sw=2:sts=2:expandtab:
*
*      $Author:   Douglas S. Elder
*    $Revision:   1.4
*        $Date:   May 19 2017
*    $Workfile:   PartSum.sql  $
*   
*      Rev 1.4   May 19 2017 DSE added order by and reformatted code
*      Rev 1.3   Sep 17 2017 DSE added EZ7436
*      Rev 1.2   Aug 03 2006 Thuy Pham Added date as part of the WHERE CLAUSE
*   
*      Rev 1.1   Feb 17 2006 13:22:24   DSE
*
*      Rev 1.0  Modified:  07/26/04  15:00:55
*
*   Latest Prod Version
**/


SET UNDERLINE OFF
SET NEWPAGE NONE
SET HEADING OFF
SET PAGESIZE 0
SET FEEDBACK OFF
SET tab OFF
SET TIME ON

  SELECT    TO_CHAR (n.nsn)
         || CHR (9)
         || DECODE ( (SUBSTR (d.doc_no, 1, 6)),
                    'EY1213', 'EY1213',
                    'FB2029', 'FB2029',
                    'FB2039', 'FB2039',
                    'FB2065', 'FB2065',
                    'EJ4416', 'EJ4416',
                    'EY3279', 'EY3279',
                    'EZ4117', 'EZ4117',
                    'EZ4298', 'EZ4298',
                    'EZ4420', 'EZ4420',
                    'EZ7436', 'EZ7436',
                    s.loc_id)
         || CHR (9)
         || TO_CHAR (TRUNC (d.doc_date, 'MONTH'), 'mm/dd/yyyy')
         || CHR (9)
         || SUM (d.quantity)
    FROM amd_demands d, amd_spare_networks s, amd_national_stock_items n
   WHERE     d.loc_sid = s.loc_sid
         AND d.nsi_sid = n.nsi_sid
         AND n.action_code IN ('A', 'C')
         AND d.doc_date > TO_DATE ('12/31/1999', 'mm/dd/yyyy')
GROUP BY n.nsn,
         DECODE ( (SUBSTR (d.doc_no, 1, 6)),
                 'EY1213', 'EY1213',
                 'FB2029', 'FB2029',
                 'FB2039', 'FB2039',
                 'FB2065', 'FB2065',
                 'EJ4416', 'EJ4416',
                 'EY3279', 'EY3279',
                 'EZ4117', 'EZ4117',
                 'EZ4298', 'EZ4298',
                 'EZ4420', 'EZ4420',
                 'EZ7436', 'EZ7436',
                 s.loc_id),
         TRUNC (d.doc_date, 'MONTH')
ORDER BY 1;


QUIT
