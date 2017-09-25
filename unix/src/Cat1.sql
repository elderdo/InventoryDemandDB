/*
      $Author:   c402417  $
    $Revision:   1.1  $
        $Date:   Aug 08 2006 10:34:14  $
    $Workfile:   Cat1.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Cat1.sql.-arc  $
/*   
/*      Rev 1.1   Aug 08 2006 10:34:14   c402417
/*   Added prime_part_no to the select statement.
/*   
/*      Rev 1.0   Feb 17 2006 13:22:20   zf297a
/*   Latest Prod Version
*/
--
-- SCCSID: Cat1.sql  1.1   Modified:  07/26/04  14:59:43
--
-- Date		By		History
-- 07/26/04	ThuyPham	Initial
--


set heading off
set feedback off
set tab off
set newpage none
set pagesize 0
set linesize 200
set underline off
set time on

select
	to_char(sp.nsn)|| chr(9)||
	sp.part_no|| chr(9)||
	nsi.prime_part_no|| chr(9) ||
	nsi.item_type|| chr(9)||
	nsi.smr_code
from
	amd_spare_parts sp,
	amd_national_stock_items nsi
where
	sp.nsn = nsi.nsn
	and sp.action_code != 'D'
	and nsi.action_code != 'D';
quit
