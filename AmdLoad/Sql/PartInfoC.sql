/*
*      $Author:   Douglas S. Elder
*    $Revision:   1.2
*        $Date:   May 19 2017
*    $Workfile:   PartInfoC.sql
*   
*      Rev 1.2   May 19 2017 DSE added order by and reformatted code
*
*      Rev 1.1   Mar 27 2006 16:14:02   c402417
*   Removed cost_to_repair and Added cost_to_repair_offbase.
*   
*      Rev 1.0   Feb 17 2006 13:22:24   zf297a
*   Latest Prod Version
**/
--
-- SCCSID:  PartInfoC.sql  1.1  Modified:  07/26/04  15:00:45
--
-- Date		By		History
-- 07/26/04	ThuyPham	Initial
--

SET UNDERLINE OFF
SET NEWPAGE NONE
SET HEADING OFF
SET PAGESIZE 0
SET FEEDBACK OFF
SET tab OFF
SET TIME ON

  SELECT    TO_CHAR (nsi.nsn)
         || CHR (9)
         || DECODE (
               LENGTH (nsi.smr_code),
               6, DECODE (SUBSTR (nsi.smr_code, 6, 1),
                          'N', NULL,
                          'P', NULL,
                          'S', NULL,
                          'U', NULL,
                          cost_to_repair_off_base),
               NULL)
         || CHR (9)
         || TO_CHAR (time_to_repair_off_base, '9999999D9999999999')
    FROM amd_national_stock_items nsi
   WHERE nsi.action_code IN ('A', 'C')
ORDER BY 1;

QUIT
