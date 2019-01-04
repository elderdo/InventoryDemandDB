/*
		$Author:   Douglas S. Elder
	 $Revision:   1.3
		  $Date:   May 19 2017
	 $Workfile:   Capability.sql  $
*   
*      Rev 1.3   May 19 2017 DSE added order by and formatted code
*      Rev 1.2   Mar 05 2007 12:29:24   Thuy Pham
*   Removed 'FB4497' from the query
*   
*      Rev 1.1   Aug 09 2006 13:47:20   Thuy Pham
*   The loc_id should be  FB4497 NOT FB4479. Was typo
*   
*      Rev 1.0   Aug 09 2006 09:56:20   Thuy Pham / c402417
*   Initial revision.
**/


SET UNDERLINE OFF
SET NEWPAGE NONE
SET HEADING OFF
SET FEEDBACK OFF
SET tab OFF
SET PAGESIZE 0
SET TIME ON

  SELECT DISTINCT n.nsn || CHR (9) || '4'
    FROM amd_demands d, amd_national_stock_items n, amd_spare_networks asn
   WHERE     d.action_code != 'D'
         AND asn.action_code != 'D'
         AND n.action_code != 'D'
         AND d.nsi_sid = n.nsi_sid
         AND d.loc_sid = asn.loc_sid
         AND d.quantity > 0
         AND asn.loc_id IN ('FB4488')
ORDER BY 1;

QUIT
