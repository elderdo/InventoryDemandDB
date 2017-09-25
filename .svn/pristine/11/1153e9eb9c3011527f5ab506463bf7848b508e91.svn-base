/* 02/26/02 removed # from part_no */
select 	',',
	aoo.gold_order_number		as		purchaseorderid, ',',
	',',
	',',
	'A' 				as		syncind, ',',
	''				as		porelease, ',',
	asp.nsn				as		item, ',',
	REPLACE(REPLACE(asp.part_no, ',', ' '), '#', '') as		requesteditem, ',',
	aoo.order_qty			as		qtyordered, ',',
	',',
	aoo.order_qty			as 		qtyopen, ',',
	',',
	TO_CHAR(aoo.sched_receipt_date + nvl(amd_preferred_pkg.GetOrderLeadTimeByPart(asp.part_no), 0), 
			'YY-MM-DD HH:MI')  	as  reqdeliverydate, ',',
	TO_CHAR(aoo.sched_receipt_date + nvl(amd_preferred_pkg.GetOrderLeadTimeByPart(asp.part_no),0), 
			'YY-MM-DD HH:MI')  	as  promiseddeliverydate, ',',
	TO_CHAR(aoo.sched_receipt_date + nvl(amd_preferred_pkg.GetOrderLeadTimeByPart(asp.part_no),0), 
			'YY-MM-DD HH:MI')  	as  scheduleddeliverydate, ',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	TO_CHAR(aoo.sched_receipt_date + nvl(amd_preferred_pkg.GetOrderLeadTimeByPart(asp.part_no), 0), 
			'YY-MM-DD HH:MI')  	as  planneddeliverydate, ',',
	aoo.order_qty			as 		qtyplanned
	

from	amd_on_order aoo,
	amd_spare_parts asp

where 	aoo.part_no = asp.part_no and
	aoo.action_code != 'D' and
	asp.action_code != 'D'
