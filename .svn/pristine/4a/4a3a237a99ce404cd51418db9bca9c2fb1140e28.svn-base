/*
		$Author:   c402417  $
	 $Revision:   1.2  $
		  $Date:   Mar 05 2007 12:29:24  $
	 $Workfile:   Capability.sql  $
			$Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\Capability.sql.-arc  $
/*   
/*      Rev 1.2   Mar 05 2007 12:29:24   c402417
/*   Removed 'FB4497' from the query
/*   
/*      Rev 1.1   Aug 09 2006 13:47:20   c402417
/*   The loc_id should be  FB4497 NOT FB4479. Was typo
/*   
/*      Rev 1.0   Aug 09 2006 09:56:20   c402417
/*   Initial revision.

*/


set underline off
set newpage none
set heading off
set feedback off
set tab off 
set pagesize 0
set time on

select distinct n.nsn || chr(9) || '4'
from
	amd_demands d,
	amd_national_stock_items n,
	amd_spare_networks asn
where
	d.action_code != 'D'
	and asn.action_code != 'D'
	and n.action_code != 'D'
	and d.nsi_sid = n.nsi_sid
	and d.loc_sid = asn.loc_sid
	and d.quantity > 0
	and asn.loc_id in ('FB4488');
quit
