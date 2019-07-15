/* 
*
* PartInfo2.sql  1.2  Modified:  05/19/17 DSE added order by and 
                                              reformatted code
* PartInfo2.sql  1.1  Modified:  07/26/04 15:00:10
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

  SELECT    TO_CHAR (ansi.nsn)
         || CHR (9)
         || asn.loc_id
         || CHR (9)
         || (  NVL (wrm_balance, 0)
             + NVL (spram_balance, 0)
             + NVL (hpmsk_balance, 0))
         || CHR (9)
         || (  NVL (wrm_level, 0)
             + NVL (spram_level, 0)
             + NVL (hpmsk_level_qty, 0))
    FROM ramp r, amd_national_stock_items ansi, amd_spare_networks asn
   WHERE     SUBSTR (r.sc, 8, 6) = asn.loc_id
         AND asn.loc_type IN ('MOB', 'FSL')
         AND REPLACE (r.current_stock_number, '-') = ansi.nsn
         AND asn.action_code != 'D'
         AND ansi.action_code != 'D'
         AND (   (  NVL (wrm_balance, 0)
                  + NVL (spram_balance, 0)
                  + NVL (hpmsk_balance, 0)) > 0
              OR (  NVL (wrm_level, 0)
                  + NVL (spram_level, 0)
                  + NVL (hpmsk_level_qty, 0)) > 0)
ORDER BY 1;

QUIT
