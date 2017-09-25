/*
      $Author:   c402417  $
    $Revision:   1.1  $
        $Date:   Mar 27 2006 16:14:02  $
    $Workfile:   PartInfoC.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\PartInfoC.sql.-arc  $
/*   
/*      Rev 1.1   Mar 27 2006 16:14:02   c402417
/*   Removed cost_to_repair and Added cost_to_repair_offbase.
/*   
/*      Rev 1.0   Feb 17 2006 13:22:24   zf297a
/*   Latest Prod Version
*/
--
-- SCCSID:  PartInfoC.sql  1.1  Modified:  07/26/04  15:00:45
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
	to_char(nsi.nsn)|| chr(9) ||
	decode(length(nsi.smr_code),6,
		decode(substr(nsi.smr_code,6,1),'N',null,'P',null,'S',null, 'U', null, cost_to_repair_off_base), null)|| chr(9) ||
	to_char(time_to_repair_off_base,'9999999D9999999999')
from
	amd_national_stock_items nsi
where
	nsi.action_code in('A','C');
quit
