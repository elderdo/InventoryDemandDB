/*
vim: set ff=unix:
Author:   Laurie Compton
Rev:   1.3
Date:  5/19/2017 

  Rev 1.0   Laurie Compton 1/6/2014    Initial Rev
  Rev 1.1   Douglas Elder 9/11/2014    setup for batch processing
  Rev 1.2   Douglas Elder 9/12/2014    added header record
  Rev 1.3   Douglas Elder 5/19/2017    added order by and formatted code

*/



WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET NEWPAGE NONE
SET HEADING OFF
SET PAGESIZE 0
SET FEEDBACK OFF
SET tab OFF
SET TIME ON
SET ECHO OFF
SET TERM OFF


SPOOL &1

SELECT RPAD ('NSN', 13) || CHR (9) || 'SRAN' || CHR (9) || 'INVENTORY'
  FROM DUAL;

  SELECT TO_CHAR (asp.nsn) || CHR (9) || 'W' || CHR (9) || SUM (invQty)
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
         AND (   loc_id LIKE 'FB%'
              OR loc_id LIKE 'EY%'
              OR loc_id IN (SELECT cod
                              FROM bssm_cods
                             WHERE lock_sid = 0))
GROUP BY asp.nsn, 'W'
ORDER BY 1;

SPOOL OFF

QUIT
