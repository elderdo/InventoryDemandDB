/*
		$Author:   c402417  $
	 $Revision:   1.2  $
		  $Date:   Aug 09 2006 10:39:50  $
	 $Workfile:   Inventory.sql  $
			$Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Inventory.sql.-arc  $
/*   
/*      Rev 1.2   Aug 09 2006 10:39:50   c402417
/*   Initial file.

*/

--
-- SCCSID:  Inventory.sql  1.3  Modified:  01/17/06  12:49:11
--
-- Date		By		History
-- 07/26/04	ThuyPham	Initial
-- 08/10/04	ThuyPham	Remove TransDate
-- 01/17/06	ThuyPham	Add action_code != 'D' to the query 
--

set newpage none
set heading off
set pagesize 0
set feedback off
set tab off
set time on


select
   to_char(asp.nsn)|| chr(9) ||
   asn.loc_id|| chr(9) ||
   sum(invQty)
from
   (select
      part_no,
      loc_sid,
      repair_qty         invQty
   from amd_in_repair
   where action_code != 'D'
   union all
   select
      part_no,
      loc_sid,
      inv_qty  invQty
   from amd_on_hand_invs
   where action_code != 'D'
   union all
   select
      part_no,
      loc_sid,
      order_qty          invQty
   from amd_on_order
   where action_code != 'D'
   union all
   select
      rtrim(part_no),
      to_loc_sid,
      quantity           invQty
   from amd_in_transits
   where action_code != 'D')  transQ,
   amd_spare_parts asp,
   amd_spare_networks asn
where
   transQ.part_no     = asp.part_no
   and transQ.loc_sid = asn.loc_sid
   and substr(asn.loc_id,1,3) not in ('MRC','ROT','SUP')
   and asp.action_code != 'D'
group by
   asp.nsn,
   asn.loc_id;
quit
