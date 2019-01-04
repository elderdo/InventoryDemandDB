/*
*
* Nins.sql  1.2   Modified:  05/19/17   DSE added order by and formatted code
* Nins.sql  1.1   Modified:  07/26/04   14:59:58
*
* Date		By		History
* 07/26/04	ThuyPham	Initial
*
**/

SET UNDERLINE OFF
SET NEWPAGE NONE
SET HEADING OFF
SET PAGESIZE 0
SET FEEDBACK OFF
SET tab OFF
SET TIME ON

  SELECT SUBSTR (an.nsn, 5, 9)
    FROM amd_nsi_parts anp, amd_spare_parts asp, amd_nsns an
   WHERE     anp.prime_ind = 'Y'
         AND anp.unassignment_date IS NULL
         AND asp.action_code IN ('A', 'C')
         AND an.nsn_type = 'C'
         AND anp.part_no = asp.part_no
         AND anp.nsi_sid = an.nsi_sid
         AND an.nsn = asp.nsn
         AND an.nsn NOT LIKE amd_defaults.getLikeNewNsn
         AND SUBSTR (an.nsn, 5, 1) IN ('0',
                                       '1',
                                       '2',
                                       '3',
                                       '4',
                                       '5',
                                       '6',
                                       '7',
                                       '8',
                                       '9')
ORDER BY 1;

QUIT
