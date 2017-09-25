--
-- SCCSID:  PartInfoB.sql  1.1  Modified:  07/26/04  15:00:33
--
-- Date		By		History
-- 07/26/04	ThuyPham	Initial
--

set newpage none
set heading off
set pagesize 0
set feedback off
set tab off
set time on

select
	to_char(nsi.nsn)|| chr(9) ||
	substr(replace(sp.nomenclature,chr(13),' '),1,40)
from
	amd_national_stock_items nsi,
	amd_spare_parts sp
where
	nsi.action_code in('A','C') and
	nsi.nsn = sp.nsn and
	sp.action_code in('A','C') and
	nsi.prime_part_no = sp.part_no;
quit
