/* supplygroupid added */
/* 02/14/02 accomodate null for mfgr */
select  ',',
	aoo.gold_order_number			as purchaseorderid, ',',
	',',
	'A'					as  syncind, ',',
	''    					as  porelease, ',',
	'PO_GROUP_' || nvl(asp.mfgr, 'UNKNOWN') || '_CTLATL' 	as  supplygroupid, ',',
	nvl(asp.mfgr, 'UNKNOWN')   				as  supplierid, ',',
	''    					as  extendedprice,',',
	',',
	'OPEN'    				as  postatus, ',',
	'CTLATL'   				as  siteid, ',',
	',',
	TO_CHAR(aoo.sched_receipt_date, 'YY-MM-DD HH:MI') as  orderdate, ',',
	',',
	',',
	''    					as  assiginedpoid

from 	amd_on_order aoo,
	amd_spare_parts asp

where  	aoo.part_no  =  asp.part_no and
	aoo.action_code != 'D' and
	asp.action_code != 'D'
