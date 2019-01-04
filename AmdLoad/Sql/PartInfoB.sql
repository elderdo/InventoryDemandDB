/*
* PartInfoB.sql  1.2  Modified:  05/19/17 DSE added order by and 
*                                             reformatted code
* PartInfoB.sql  1.1  Modified:  07/26/04  15:00:33
*
* Date		By		History
* 07/26/04	ThuyPham	Initial
*
**/

SET NEWPAGE NONE
SET HEADING OFF
SET PAGESIZE 0
SET FEEDBACK OFF
SET tab OFF
SET TIME ON

  SELECT    TO_CHAR (nsi.nsn)
         || CHR (9)
         || SUBSTR (REPLACE (sp.nomenclature, CHR (13), ' '), 1, 40)
    FROM amd_national_stock_items nsi, amd_spare_parts sp
   WHERE     nsi.action_code IN ('A', 'C')
         AND nsi.nsn = sp.nsn
         AND sp.action_code IN ('A', 'C')
         AND nsi.prime_part_no = sp.part_no
ORDER BY 1;

QUIT
