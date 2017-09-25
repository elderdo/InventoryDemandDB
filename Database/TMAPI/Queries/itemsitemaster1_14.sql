/*      
	amd_part_locs currently only has mob, fsl, ROR, warehouse (CTLATL),
	need to associate all parts with all cods, onbase, heldrepair also.
	this should not include vendors either.
	offbase loc_sid is 23
	held repair (CTL-ATL) and OBR for repairables only
	??? repair lead time open issue
	??? default item type and 'FI'

	repairable 	cwh, cod, onbase => FI
			mob, fsl, offbase => I
			held repair	=> FIR
			if not loc above FI	
*/
select 	',',
	ansi.nsn		as	item, 	',',
	asn.loc_id		as	siteid, ',',
	',',
	'A'			as 	syncind, ',',
	',',
	''			as	itemclass, ',',
	',',
	',',
	',',
	',',
	',',
	''			as 	lotsizemax, ',',
	''			as 	lotsizemin, ',',
	''			as	lotsizeincrement, ',',
	',',
	',',
	',',
	',',
	''			as	releasefence, ',',
	',', ',', ',', ',', ',', 
	',', ',', ',', ',', ',', 
	',', ',', ',', ',', ',', 
	',',
	decode(apl.loc_sid, 23, amd_preferred_pkg.GetCostToRepairOffBase(apl.nsi_sid, apl.loc_sid), 
		decode(apl.cost_to_repair, null, apl.cost_to_repair_defaulted, apl.cost_to_repair))
				as repaircost, ',',
	decode(apl.loc_sid, 23, amd_preferred_pkg.GetTimeToRepairOffBase(apl.nsi_sid, apl.loc_sid), 
		decode(apl.time_to_repair, null, apl.time_to_repair_defaulted, apl.time_to_repair))
				as repairleadtime, ',',
	',', ',', ',', ',', ',', ',',  
	decode(amtd.rts,  null, amtd.rts_defaulted, amtd.rts)	as rts,  ',',
	decode(amtd.nrts, null, amtd.nrts_defaulted, amtd.nrts)	as nrts, ',',
	decode(amtd.cond, null, amtd.cond_defaulted, amtd.cond)	as cond, ',',
	nvl(decode(amd_preferred_pkg.GetItemType(ansi.nsn), 'C', 'FI', 'R', 
				decode(asn.loc_type, 'CWH', 'FI', 'I')), 'FI')	as sourcetype

from 	amd_part_locs apl, 
	amd_maint_task_distribs amtd,
	amd_national_stock_items ansi,
	amd_spare_networks asn 

where	apl.nsi_sid = ansi.nsi_sid	and
	apl.loc_sid = asn.loc_sid	and 
	apl.nsi_sid = amtd.nsi_sid (+)	and
	apl.loc_sid = amtd.loc_sid (+)	and
	ansi.action_code != 'D'		and
	asn.action_code != 'D'

