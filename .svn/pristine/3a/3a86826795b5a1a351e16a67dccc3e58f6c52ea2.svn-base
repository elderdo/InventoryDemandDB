/* ??? many mfgrs not in amd_spare_networks, defaulted them to 5 day work week */
SELECT ',',  
	asn.LOC_ID 	  as 	siteid, ',',
	',', 
	',', 
	'ACTIVE'	  as 	calendartype, ',', 
	',', 
	'A'		  as	syncind, ',', 
	nvl(asn.calendar_name, '5 DAY WORK WEEK') as	calendarname 	
	
FROM AMD_SPARE_NETWORKS   asn
WHERE asn.loc_type not in ('STR', 'ALL', 'VEN') AND 
asn.action_code != 'D'

