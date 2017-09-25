select  ',',
	asi.gold_order_number			as purchaseorderid, ',',
	',',
	'A'					as  syncind, ',',
	''    					as  porelease, ',',
	''    					as  supplygroupid, ',',
	asi.mfgr   				as  supplierid, ',',
	''    					as  extendedprice,',',
	',',
	'OPEN'    				as  postatus, ',',
	'CTLATL'   				as  siteid, ',',
	',',
	TO_CHAR(asi.inv_date, 'YY-MM-DD HH:MM') as  orderdate, ',',
	',',
	',',
	''    					as  assiginedpoid, ',',
	TO_CHAR(asi.inv_date + decode(asp.order_lead_time_cleaned, null, 
					decode(asp.order_lead_time, null, 
						asp.order_lead_time_defaulted, asp.order_lead_time),  
					asp.order_lead_time_cleaned),
			'YY-MM-DD HH:MM')  	as  reqdeliverydate

from 	amd_spare_invs asi,
	amd_spare_parts asp

where  	asi.part_no  =  asp.part_no and
	asi.mfgr  = asp.mfgr and
	asi.inv_type  =  '3' and
	asi.action_code != 'D' and
	asp.action_code != 'D'
