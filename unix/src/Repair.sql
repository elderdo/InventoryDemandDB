/*
	  $Author:   c402417  $
	$Revision:   1.0  $
	    $Date:   Aug 03 2006 12:57:34  $
	$Workfile:   Repair.sql  $
	     $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\Repair.sql.-arc  $
/*   
/*      Rev 1.0   Aug 03 2006 12:57:34   c402417
/*   Initial revision.
*/


set newpage none
set heading off
set pagesize 0
set feedback off
set tab off
set time on


select
	asp.nsn || chr(9) ||
	sum(repair_qty)
from
	amd_in_repair air,
	amd_spare_parts asp,
	amd_spare_networks asn
where
	air.part_no = asp.part_no
	and air.loc_sid = asn.loc_sid
	and air.action_code != 'D'
	and asp.action_code != 'D'
	and asn.action_code != 'D'
	and substr(asn.loc_id,1,3) not in ('MRC','ROT','SUP')
group by 
	asp.nsn ;
quit
