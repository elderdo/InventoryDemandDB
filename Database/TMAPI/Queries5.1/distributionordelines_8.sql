select 	',',
	asi.part_no||asi.mfgr||asi.loc_sid||asi.inv_date||asi.inv_type	as	distributionorderid, ',',
	'1'			as 	distributionlineid, ',',
	',',	
	'A'			as 	syncind, ',',
	decode(asi.inv_type, '2', asn.loc_id || '_DIFM', OBRC.loc_id) 
				as	fromsiteid, ',',
	decode(asi.inv_type, '2', asn.loc_id, 'CTLATL') 		as	tositeid, ',',
	asp.nsn			as	item, ',',	
	asp.nsn			as	requesteditem, ',',
	',',
	',',
	asi.inv_qty		as	quantityshipped, ',',
	',',
	',',
	TO_CHAR( (TRUNC(asi.inv_date) + decode(apl.time_to_repair, null, apl.time_to_repair_defaulted, apl.time_to_repair)), 'YY-MM-DD HH:MM') 
				as	scheduleddeliverydate, ',',
	TO_CHAR(TRUNC(asi.inv_date), 'YY-MM-DD HH:MM')
		 		as	scheduledshipdate, ',',
	',',
	'Courier Land'		as	transagentid, ',',
	',',
	'LAND'			as	transportmode, ',',	
	'LAND'			as	transporttype 
from 	amd_spare_invs 			asi,
	amd_national_stock_items	ansi,
	amd_spare_networks		asn,
	amd_spare_parts			asp,
	amd_part_locs			apl,
	(select loc_id from amd_spare_networks where loc_type = 'ROR') OBRC
where	asi.inv_type in ('2', '4') 	and
	asi.loc_sid 	= asn.loc_sid	and 
	asi.part_no 	= asp.part_no	and
	asi.mfgr	= asp.mfgr	and
	asp.nsn 	= ansi.nsn	and
	ansi.nsi_sid	= apl.nsi_sid	and
	asi.loc_sid	= apl.loc_sid	and
	ansi.tactical 	= 'Y'		and
	asp.action_code != 'D'		and
	ansi.action_code != 'D'		and
	asn.action_code != 'D'		and
	decode(ansi.item_type_cleaned, null, ansi.item_type, ansi.item_type_cleaned) = 'R' 
	

	

