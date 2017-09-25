--
-- SCCSID:  Nins.sql  1.1   Modified:  07/26/04   14:59:58
--
-- Date		By		History
-- 07/26/04	ThuyPham	Initial
--

set underline off
set newpage none
set heading off
set pagesize 0
set feedback off
set tab off
set time on

select 
	substr(an.nsn,5,9)
from
	amd_nsi_parts anp,
	amd_spare_parts asp,
	amd_nsns an
where
	anp.prime_ind = 'Y' and
	anp.unassignment_date is null and
	asp.action_code in('A','C') and
	an.nsn_type = 'C' and
	anp.part_no = asp.part_no and
	anp.nsi_sid = an.nsi_sid and
	an.nsn = asp.nsn and
	an.nsn not like 'NSL%' and
	substr(an.nsn,5,1) in ('0','1','2','3','4','5','6','7','8','9');
quit


