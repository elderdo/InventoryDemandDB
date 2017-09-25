select	',',
	asp.nsn 			as 		item, ',',
	asn.loc_id 			as 		siteid, ',',
	',',
	',',
	',',
	',',
	',',
	'A'				as 		syncid, ',',
	',',
	',',
	',',
	',',
	',',
	sum(aohi.inv_qty) + nvl(apl.rsp_on_hand,0) 
					as  		qtyavailable, ',',
	',',
	apl.rsp_on_hand			as		qtyrestricted, ',',
	',',
	',',
	',',
	',',
	''				as		salesquantity

from 	amd_spare_parts asp, 
	amd_spare_networks asn, 
	amd_on_hand_invs aohi,
	amd_part_locs apl,
	amd_nsns an
	

where 	
	aohi.part_no	= asp.part_no	and 
	asp.nsn		= an.nsn	and
	an.nsi_sid	= apl.nsi_sid	and	
	aohi.loc_sid 	= asn.loc_sid	and
	aohi.loc_sid 	= apl.loc_sid	and

	apl.action_code != 'D'	and
	aohi.action_code != 'D' and
	asp.action_code != 'D' and
	asn.action_code != 'D'


group by asp.nsn, asn.loc_id, apl.rsp_on_hand

union

select	',',
	asp.nsn || '-JOB'		as 		item, ',',
	asn.loc_id 			as 		siteid, ',',
	',',
	',',
	',',
	',',
	',',
	'A'				as 		syncid, ',',
	',',
	',',
	',',
	',',
	',',
	to_number(null)			as  		qtyavailable, ',',
	',',
	to_number(null)			as		qtyrestricted, ',',
	',',
	',',
	',',
	',',
	''				as		salesquantity

from 	
	amd_in_repair air,
	amd_spare_parts asp,
	amd_spare_networks asn
	
where 	
	air.repair_type = '6'  and
	air.part_no = asp.part_no and
	air.loc_sid = asn.loc_sid and	
	air.action_code != 'D' and
	asn.action_code != 'D' and
	asp.action_code != 'D' 

group by asp.nsn, asn.loc_id

