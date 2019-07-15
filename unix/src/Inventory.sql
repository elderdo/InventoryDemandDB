/*
*		$Author:   Douglas S. Elder
*	 $Revision:   1.5
*		  $Date:    May 19 2017
*	 $Workfile:   Inventory.sql
*   
*      Rev 1.5   May 19 2017 DSE added order by and formatted code
*      Rev 1.4   Aug 09 2006 10:39:50   Thuy Pham
*   Initial file.
*
*
* Inventory.sql  1.3  Modified:  01/17/06  12:49:11
*
* Date		By		History
* 07/26/04	ThuyPham	Initial
* 08/10/04	ThuyPham	Remove TransDate
* 01/17/06	ThuyPham	Add action_code != 'D' to the query
*
**/




SET NEWPAGE NONE
SET HEADING OFF
SET PAGESIZE 0
SET FEEDBACK OFF
SET tab OFF
SET TIME ON


  SELECT TO_CHAR (asp.nsn) || CHR (9) || asn.loc_id || CHR (9) || SUM (invQty)
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
         AND SUBSTR (asn.loc_id, 1, 3) NOT IN ('MRC', 'ROT', 'SUP')
         AND asp.action_code != 'D'
GROUP BY asp.nsn, asn.loc_id
ORDER BY 1;

QUIT
