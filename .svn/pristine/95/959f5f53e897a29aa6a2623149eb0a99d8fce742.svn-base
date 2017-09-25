--
-- SCCSID: 	Ramp.sql  1.1  Modified:  01/18/06  10:52:37
--
-- Date		By		History
-- 01/17/06	ThuyPham	Initial per Yvonne Van-Herk
--
--


set newpage none
set heading off
set pagesize 0
set feedback off
set tab off
set time on

select
	replace(current_stock_number,'-','')|| chr(9) ||
	substr(sc,8,6)|| chr(9) ||
	percent_base_repair || chr(9) ||
	percent_base_condem || chr(9) ||
	daily_demand_rate || chr(9) ||
	avg_repair_cycle_time
from
	ramp
where Delete_Indicator is NULL;
quit
