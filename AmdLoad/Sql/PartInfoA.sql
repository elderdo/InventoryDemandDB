/* Formatted on 5/19/2017 2:07:38 PM (QP5 v5.287) */
/*
      $Author:   Douglas S. Elder
    $Revision:   1.3
        $Date:   Aug 03 2006 10:46:54  $
    $Workfile:   PartInfoA.sql  $
/*   
/*      Rev 1.3   19 May 2017 added order by and reformatted code

/*      Rev 1.2   Aug 03 2006 10:46:54   c402417
/*   Added current_backorder to the query.
/*   
/*      Rev 1.1   Mar 27 2006 16:14:56   c402417
/*   Removed REPLACE at part_no in the select statement.
/*   
/*      Rev 1.0   Feb 17 2006 13:22:22   zf297a
/*   Latest Prod Version
*/

--
-- SCCSID:  PartInfoA.sql  1.1  Modified:  07/26/04  15:00:21
--
-- Date		By		History
-- 07/26/04	ThuyPham	Initial
--

SET UNDERLINE OFF
SET NEWPAGE NONE
SET HEADING OFF
SET FEEDBACK OFF
SET LINESIZE 600
SET tab OFF
SET TIME ON


  SELECT    TO_CHAR (nsi.nsn)
         || CHR (9)
         || nsi.mic_code_lowest
         || CHR (9)
         || nsi.planner_code
         || CHR (9)
         || TO_CHAR (nsi.smr_code)
         || CHR (9)
         || nsi.mtbdr
         || CHR (9)
         || DECODE (nsi.mmac,  'BA', 'BA',  'BE', 'BE',  NULL)
         || CHR (9)
         || sp.part_no
         || CHR (9)
         || TO_CHAR (sp.mfgr)
         || CHR (9)
         || sp.order_lead_time
         || CHR (9)
         || sp.order_uom
         || CHR (9)
         || sp.unit_of_issue
         || CHR (9)
         || sp.unit_cost
         || CHR (9)
         || sp.acquisition_advice_code
         || CHR (9)
         || nsi.current_backorder
    FROM amd_national_stock_items nsi, amd_spare_parts sp
   WHERE     nsi.action_code IN ('A', 'C')
         AND sp.action_code IN ('A', 'C')
         AND nsi.nsn = sp.nsn
         AND nsi.prime_part_no = sp.part_no
ORDER BY 1;

QUIT
