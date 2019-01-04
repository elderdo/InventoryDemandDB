/* 
*      $Author:   Douglas S. Elder
*    $Revision:   1.4
*        $Date:   19 May 2017
*    $Workfile:   Cat1.sql
*
*      Rev 1.4  19 May 2017 DSE added order by and formatted code
*      Rev 1.3   Aug 08 2006 10:34:14   Thuy Pham
*   Added prime_part_no to the select statement.
*   
*      Rev 1.2   Feb 17 2006 13:22:20   zf297a
*   Latest Prod Version
*
* Cat1.sql  1.1   Modified:  07/26/04  14:59:43
*
* Date		By		History
* 07/26/04	ThuyPham	Initial
*
**/


SET HEADING OFF
SET FEEDBACK OFF
SET tab OFF
SET NEWPAGE NONE
SET PAGESIZE 0
SET LINESIZE 200
SET UNDERLINE OFF
SET TIME ON

  SELECT    TO_CHAR (sp.nsn)
         || CHR (9)
         || sp.part_no
         || CHR (9)
         || nsi.prime_part_no
         || CHR (9)
         || nsi.item_type
         || CHR (9)
         || nsi.smr_code
    FROM amd_spare_parts sp, amd_national_stock_items nsi
   WHERE sp.nsn = nsi.nsn AND sp.action_code != 'D' AND nsi.action_code != 'D'
ORDER BY 1;

QUIT
