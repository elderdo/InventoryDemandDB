/*
*
* Ramp.sql  1.2  Modified:  05/19/17 DSE added order by and formatted code
* Ramp.sql  1.1  Modified:  01/18/06  10:52:37
*
* Date		By		History
* 01/17/06	ThuyPham	Initial per Yvonne Van-Herk
*
*
**/


SET NEWPAGE NONE
SET HEADING OFF
SET PAGESIZE 0
SET FEEDBACK OFF
SET tab OFF
SET TIME ON

  SELECT    REPLACE (current_stock_number, '-', '')
         || CHR (9)
         || SUBSTR (sc, 8, 6)
         || CHR (9)
         || percent_base_repair
         || CHR (9)
         || percent_base_condem
         || CHR (9)
         || daily_demand_rate
         || CHR (9)
         || avg_repair_cycle_time
    FROM ramp
   WHERE Delete_Indicator IS NULL
ORDER BY 1;

QUIT
