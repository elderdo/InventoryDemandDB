--
-- SCCSID:  PartInfo2.sql  1.1  Modified:  07/26/04 15:00:10
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
	to_char(ansi.nsn)|| chr(9) ||
	asn.loc_id|| chr(9) ||
	(nvl(wrm_balance, 0) + nvl(spram_balance, 0) + nvl(hpmsk_balance, 0))|| chr(9) ||
	(nvl(wrm_level, 0) + nvl(spram_level, 0) + nvl(hpmsk_level_qty, 0))  
from
	ramp r,	
	amd_national_stock_items ansi,
	amd_spare_networks asn
where
	substr(r.sc,8,6) = asn.loc_id
	and asn.loc_type in ('MOB','FSL')
	and replace(r.current_stock_number, '-') = ansi.nsn
	and asn.action_code != 'D'
	and ansi.action_code != 'D'
	and ((nvl(wrm_balance, 0) + nvl(spram_balance, 0) + nvl(hpmsk_balance, 0)) > 0 or
	 (nvl(wrm_level, 0 ) + nvl(spram_level, 0) + nvl(hpmsk_level_qty,0) ) > 0 ) ;
quit
