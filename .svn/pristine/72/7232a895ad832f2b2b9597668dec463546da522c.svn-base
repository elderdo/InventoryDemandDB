/*
      $Author:   c402417  $
    $Revision:   1.2  $
        $Date:   Aug 03 2006 10:46:54  $
    $Workfile:   PartInfoA.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\PartInfoA.sql.-arc  $
/*   
/*      Rev 1.2   Aug 03 2006 10:46:54   c402417
/*   Added current_backorder to the query.
/*   
/*      Rev 1.1   Mar 27 2006 16:14:56   c402417
/*   Removed REPLACE at part_no in the select statement.
/*   
/*      Rev 1.0   Feb 17 2006 13:22:22   zf297a
/*   Latest Prod Version
*/
--
-- SCCSID:  PartInfoA.sql  1.1  Modified:  07/26/04  15:00:21
--
-- Date		By		History
-- 07/26/04	ThuyPham	Initial
--

set underline off
set newpage none
set heading off
set feedback off
set linesize 600
set tab off
set time on


select 
	to_char(nsi.nsn)|| chr(9) ||
	nsi.mic_code_lowest|| chr(9) ||
	nsi.planner_code|| chr(9) ||
	to_char(nsi.smr_code)|| chr(9) ||
	nsi.mtbdr|| chr(9) ||
	decode(nsi.mmac,'BA','BA','BE','BE',NULL) || chr(9) ||
	sp.part_no|| chr(9) ||
	to_char(sp.mfgr)|| chr(9) ||
	sp.order_lead_time|| chr(9) ||
	sp.order_uom|| chr(9) ||
	sp.unit_of_issue|| chr(9) ||
	sp.unit_cost || chr(9) ||
	sp.acquisition_advice_code || chr(9) ||
	nsi.current_backorder 
from
	amd_national_stock_items nsi,
	amd_spare_parts sp
where
	nsi.action_code in('A','C')
	and sp.action_code in ('A','C')
	and nsi.nsn = sp.nsn
	and nsi.prime_part_no = sp.part_no;
quit



