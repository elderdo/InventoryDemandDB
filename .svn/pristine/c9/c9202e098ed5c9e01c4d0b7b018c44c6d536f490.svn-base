select	',',
	asp.nsn 			as 		item, ',',
	asn.loc_id 			as 		siteid, ',',
	',',
	'A'				as 		syncid, ',',
	',',
	',',
	',',
	sum(asi.inv_qty)		as  		qtyavailable, ',',
	'0'				as		qtyrestricted

from 	amd_spare_parts asp, 
	amd_spare_networks asn, 
	amd_spare_invs asi

where 	asp.part_no = asi.part_no 
	and asp.mfgr = asi.mfgr
	and asi.loc_sid = asn.loc_sid
	and asi.inv_type = 1
	and asi.action_code != 'D'
	and asp.action_code != 'D'
	and asn.action_code != 'D'

group by asp.nsn, asn.loc_id, asi.inv_type

