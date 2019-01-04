/*
*      $Author:   Douglas S. Elder
*    $Revision:   1.3
*        $Date:   19 May 2017
*    $Workfile:   InventorySranConv.sql  $
*
*      Rev 1.3   May 19 2017 DSE added order by and formatted code
*
*      Rev 1.2   Oct 31 2011    Thuy Pham 
*   Removed FB6322 to be allocated to FB4418 per CR LBPSS00003155 .
*   
*      Rev 1.1   Aug 03 2006 15:36:14   Thuy Pham 
*   Added action_code != 'D' to each UNION CLAUSE.
*   
*      Rev 1.0   Jul 21 2006 10:30:06   Thuy Pham 
*   Initial revision.
*   
*      Rev 1.0   Feb 17 2006 13:22:22   DSE
*   Latest Prod Version
**/
--

SET NEWPAGE NONE
SET HEADING OFF
SET PAGESIZE 0
SET FEEDBACK OFF
SET tab OFF
SET TIME ON


  SELECT    TO_CHAR (asp.nsn)
         || CHR (9)
         || DECODE (asn.loc_id,
                    'FB2373', 'EY1746',
                    'FB4877', 'EY1746',
                    'FB6633', 'EY1746',
                    'FB4400', 'FB4418',
                    'FB4401', 'FB5612',
                    'FB4403', 'FB5621',
                    'FB4402', 'FB5685',
                    'FB4408', 'FB5209',
                    'FB4411', 'FB5270',
                    'FB4415', 'FB5240',
                    'FB4405', 'FB5260',
                    'FB6530', 'FB5260',
                    'FB4480', 'FB5000',
                    'FB4406', 'FB4418',
                    'FB4412', 'FB4418',
                    'FB4417', 'FB4418',
                    'FB4455', 'FB4418',
                    'FB4491', 'FB4418',
                    'FB4528', 'FB4418',
                    'FB4800', 'FB4418',
                    'FB4814', 'FB4418',
                    'FB4819', 'FB4418',
                    'FB5587', 'FB4418',
                    'FB5834', 'FB4418',
                    'FB5846', 'FB4418',
                    'FB5851', 'FB4418',
                    'FB5873', 'FB4418',
                    'FB5874', 'FB4418',
                    'FB5879', 'FB4418',
                    'FB5880', 'FB4418',
                    'FB5881', 'FB4418',
                    'FB5884', 'FB4418',
                    'FB5891', 'FB4418',
                    'FB6181', 'FB4418',
                    'FB6391', 'FB4418',
                    'FB6606', 'FB4418',
                    'FB2027', 'FB4479',
                    'FB2073', 'FB4479',
                    'FB4454', 'FB4479',
                    'FB4486', 'FB4479',
                    'FB4621', 'FB4479',
                    'FB4661', 'FB4479',
                    'FB4801', 'FB4479',
                    'FB5294', 'FB4479',
                    'FB5878', 'FB4479',
                    'FB6151', 'FB4479',
                    asn.loc_id)
         || CHR (9)
         || SUM (invQty)
    FROM (SELECT part_no, loc_sid, repair_qty invQty
            FROM amd_in_repair
           WHERE action_code != 'D'
          UNION ALL
          SELECT part_no, loc_sid, inv_qty invQty
            FROM amd_on_hand_invs
           WHERE action_code != 'D'
          UNION ALL
          SELECT part_no, loc_sid, order_qty invQty
            FROM amd_on_order
           WHERE action_code != 'D'
          UNION ALL
          SELECT RTRIM (part_no), to_loc_sid, quantity invQty
            FROM amd_in_transits
           WHERE action_code != 'D') transQ,
         amd_spare_parts asp,
         amd_spare_networks asn
   WHERE     transQ.part_no = asp.part_no
         AND transQ.loc_sid = asn.loc_sid
         AND SUBSTR (asn.loc_id, 1, 3) NOT IN ('MRC', 'ROT')
         AND asp.action_code != 'D'
GROUP BY asp.nsn,
         DECODE (asn.loc_id,
                 'FB2373', 'EY1746',
                 'FB4877', 'EY1746',
                 'FB6633', 'EY1746',
                 'FB4400', 'FB4418',
                 'FB4401', 'FB5612',
                 'FB4403', 'FB5621',
                 'FB4402', 'FB5685',
                 'FB4408', 'FB5209',
                 'FB4411', 'FB5270',
                 'FB4415', 'FB5240',
                 'FB4405', 'FB5260',
                 'FB6530', 'FB5260',
                 'FB4480', 'FB5000',
                 'FB4406', 'FB4418',
                 'FB4412', 'FB4418',
                 'FB4417', 'FB4418',
                 'FB4455', 'FB4418',
                 'FB4491', 'FB4418',
                 'FB4528', 'FB4418',
                 'FB4800', 'FB4418',
                 'FB4814', 'FB4418',
                 'FB4819', 'FB4418',
                 'FB5587', 'FB4418',
                 'FB5834', 'FB4418',
                 'FB5846', 'FB4418',
                 'FB5851', 'FB4418',
                 'FB5873', 'FB4418',
                 'FB5874', 'FB4418',
                 'FB5879', 'FB4418',
                 'FB5880', 'FB4418',
                 'FB5881', 'FB4418',
                 'FB5884', 'FB4418',
                 'FB5891', 'FB4418',
                 'FB6181', 'FB4418',
                 'FB6391', 'FB4418',
                 'FB6606', 'FB4418',
                 'FB2027', 'FB4479',
                 'FB2073', 'FB4479',
                 'FB4454', 'FB4479',
                 'FB4486', 'FB4479',
                 'FB4621', 'FB4479',
                 'FB4661', 'FB4479',
                 'FB4801', 'FB4479',
                 'FB5294', 'FB4479',
                 'FB5878', 'FB4479',
                 'FB6151', 'FB4479',
                 asn.loc_id)
ORDER BY 1;


QUIT
