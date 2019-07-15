/*
	  $Author:   Douglas S. Elder
	$Revision:   1.1
	    $Date:   May 19 2017
	$Workfile:   Repair.sql  $
/*   
/*      Rev 1.1   May 19 2017 DSE added order by and formatted code
/*      Rev 1.0   Aug 03 2006 12:57:34   Thuy Pham
/*   Initial revision.
*/


SET NEWPAGE NONE
SET HEADING OFF
SET PAGESIZE 0
SET FEEDBACK OFF
SET tab OFF
SET TIME ON


  SELECT asp.nsn || CHR (9) || SUM (repair_qty)
    FROM amd_in_repair air, amd_spare_parts asp, amd_spare_networks asn
   WHERE     air.part_no = asp.part_no
         AND air.loc_sid = asn.loc_sid
         AND air.action_code != 'D'
         AND asp.action_code != 'D'
         AND asn.action_code != 'D'
         AND SUBSTR (asn.loc_id, 1, 3) NOT IN ('MRC', 'ROT', 'SUP')
GROUP BY asp.nsn
ORDER BY 1;

QUIT
