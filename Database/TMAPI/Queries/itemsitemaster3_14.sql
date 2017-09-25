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
	to_number(null)		as repaircost, ',',
	to_number(null)		as repairleadtime, ',',
	',', ',', ',', ',', ',', ',',  
	to_number(null) 	as rts, ',',
	to_number(null)		as nrts, ',',
	to_number(null)		as cond, ',',
	'FI'			as sourcetype

from 	
	amd_national_stock_items ansi,
	(select loc_id from amd_spare_networks where loc_type = 'COD') asn

where	
	ansi.action_code != 'D'

