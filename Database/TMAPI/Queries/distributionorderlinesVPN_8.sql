/* ???: 
item_type = 'R'
vpn is only respect to offbase => type 4, ken g 12/3
since told amd_spare_invs current, can go use ansi
	changed to order sid
	REPLACE(air.part_no||air.loc_sid||air.repair_date||air.repair_type, ',', ' ')	as	distributionorderid, ',',
*/
/* 02/26/02 removed # from part_no */
select 	',',
	air.order_sid		as	distributionorderid, ',',
	'1'			as 	distributionlineid, ',',
	',',	
	'A'			as 	syncind, ',',
	decode(air.repair_type, '4', OBRC.loc_id, '2', OnBase.loc_id) 
				as	fromsiteid, ',',
	decode(air.repair_type, '2', asn.loc_id, 'CTLATL') 		as	tositeid, ',',
	asp.nsn			as	item, ',',	
	asp.nsn			as	requesteditem, ',',
	',',
	',',
	air.repair_qty		as	quantityshipped, ',',
	',',
	',',
	TO_CHAR( TRUNC(air.repair_date) + nvl(decode(air.repair_type, '4', amd_preferred_pkg.GetTimeToRepairOffbase(ansi.nsi_sid, asn.loc_sid), '2', amd_preferred_pkg.GetTimeToRepairOnBaseAvg(ansi.nsi_sid)), 0), 'YY-MM-DD HH:MI') 
				as	scheduleddeliverydate, ',',
	TO_CHAR(TRUNC(air.repair_date), 'YY-MM-DD HH:MI')
		 		as	scheduledshipdate, ',',
	',',
	'Courier Land'		as	transagentid, ',',
	'LAND'			as	servicename, ',',
	'LAND'			as	transportmode, ',',	
	'LAND'			as	transporttype 
from 	amd_in_repair			air,
	amd_national_stock_items	ansi,
	amd_spare_networks		asn,
	amd_spare_parts			asp,	
	(select loc_id from amd_spare_networks where loc_type = 'ROR') OBRC,
	(select loc_id from amd_spare_networks where loc_type = 'OBR') OnBase
where	air.repair_type in ('2', '4') 	and
	air.loc_sid 	= asn.loc_sid	and 
	air.part_no 	= asp.part_no	and
	asp.nsn 	= ansi.nsn	and
	asp.action_code != 'D'		and
	asn.action_code != 'D'		and
	amd_preferred_pkg.GetItemType(ansi.nsi_sid) = 'R' 

union

select 	',',
	air.order_sid		as	distributionorderid, ',',
	'1'			as 	distributionlineid, ',',
	',',	
	'A'			as 	syncind, ',',
	OBRC.loc_id		as	fromsiteid, ',',
	'CTLATL' 		as	tositeid, ',',
	REPLACE(REPLACE(asp.part_no, ',', ' '), '#', '')		as	item, ',',	
	REPLACE(REPLACE(asp.part_no, ',', ' '), '#', '')		as	requesteditem, ',',
	',',
	',',
	air.repair_qty		as	quantityshipped, ',',
	',',
	',',
	TO_CHAR( TRUNC(air.repair_date) +  nvl(amd_preferred_pkg.GetTimeToRepairOffbase(ansi.nsi_sid, asn.loc_sid), 0), 'YY-MM-DD HH:MI') 
				as	scheduleddeliverydate, ',',
	TO_CHAR(TRUNC(air.repair_date), 'YY-MM-DD HH:MI')
		 		as	scheduledshipdate, ',',
	',',
	'Courier Land'		as	transagentid, ',',
	'LAND'			as	servicename, ',',
	'LAND'			as	transportmode, ',',	
	'LAND'			as	transporttype 
from 	amd_in_repair			air,
	amd_national_stock_items	ansi,
	amd_spare_networks		asn,
	amd_spare_parts			asp,	
	(select loc_id from amd_spare_networks where loc_type = 'ROR') OBRC
where	air.repair_type = '4' 	and
	air.loc_sid 	= asn.loc_sid	and 
	air.part_no 	= asp.part_no	and
	asp.nsn 	= ansi.nsn	and
	asp.action_code != 'D'		and
	asn.action_code != 'D'		and
	amd_preferred_pkg.GetItemType(ansi.nsi_sid) = 'R' 
