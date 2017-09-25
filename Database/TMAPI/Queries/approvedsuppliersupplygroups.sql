/* union gets out identical mfgrs in query by amd_spare_parts */
/* 02/14/02 accomodate null for mfgr */
select 	',',
	loc_id	as 	supplierid, ',',
	'PO_GROUP_' || loc_id || '_CTLATL' as supplygroupid, ',',
	',',
	'CTLATL' as	siteid, ',',
	',',
	'A'	as	syncind, ',',
	'PO_GROUP_' || loc_id || '_CTLATL' as suppliergroupname, ',',
	'0'	as 	orderingcost, ',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	'' 	as	minlineitems, ',',
	'0'	as	appvaluelimit, ',',
	',',
	'1'	as	approvalfence, ',',
	',',
	',',
	'2'	as	maxtrucks, ',',
	'3'	as 	mingroupdays, ',',
	'28'	as 	maxgroupdays, ',',
	'N'	as 	roundingpolicy, ',',
	'P'	as 	loadingpolicy, ',',
	'LO'	as	searchflag, ',',
	'X'	as	coderepolicy, ',',
	'ITEM'	as	grouppolicy, ',',
	'30'	as	notdefined, ',',
	'1'	as	gobbypassflag
	
from amd_spare_networks 
where loc_type = 'VEN'
and action_code != 'D'

union

select 
	',',
	nvl(mfgr,'UNKNOWN')	as 	supplierid, ',',
	'PO_GROUP_' || nvl(mfgr,'UNKNOWN') || '_CTLATL' as supplygroupid, ',',
	',',
	'CTLATL' as	siteid, ',',
	',',
	'A'	as	syncind, ',',
	'PO_GROUP_' || nvl(mfgr, 'UNKNOWN') || '_CTLATL' as suppliergroupname, ',',
	'0'	as 	orderingcost, ',',
	',',
	',',
	',',
	',',
	',',
	',',
	',',
	'' 	as	minlineitems, ',',
	'0'	as	appvaluelimit, ',',
	',',
	'1'	as	approvalfence, ',',
	',',
	',',
	'2'	as	maxtrucks, ',',
	'3'	as 	mingroupdays, ',',
	'28'	as 	maxgroupdays, ',',
	'N'	as 	roundingpolicy, ',',
	'P'	as 	loadingpolicy, ',',
	'LO'	as	searchflag, ',',
	'X'	as	coderepolicy, ',',
	'ITEM'	as	grouppolicy, ',',
	'30'	as	notdefined, ',',
	'1'	as	gobbypassflag
from amd_spare_parts
where nvl(mfgr, 'UNKNOWN') not in (select loc_id from amd_spare_networks)
and action_code != 'D'
