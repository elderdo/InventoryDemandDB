SELECT ',',  
	asn.LOC_ID 	  as 	siteid, ',',
	',', 
	',', 
	'ACTIVE'	  as 	calendartype, ',', 
	',', 
	'A'		  as	syncind, ',', 
	asn.calendar_name as	calendarname 	
	
FROM AMD_SPARE_NETWORKS   asn
WHERE asn.loc_type not in ('OBR', 'STR', 'ALL') AND
asn.action_code != 'D'

union

SELECT  ',',  
	asn.LOC_ID || '_DIFM' as siteid, ',',    
	',', 
	',', 
	'ACTIVE'		as	calendartype, ',',
	',', 
	'A'			as	syncind, ',', 
	'5 DAY WORK WEEK' 	as	calendarname	
	
FROM AMD_SPARE_NETWORKS   asn
WHERE asn.loc_type in ('FSL', 'MOB') AND
asn.action_code != 'D'
