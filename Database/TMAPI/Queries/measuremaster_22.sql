select ',',
	'HISTORY' 	as measurename, ',',
	',',
	'A'	  	as syncind,	',',
	'ACTUAL_SALES'	as measuredesc, ',',
	'BUCKETED'	as measuretype, ',',
	'NUMBER'	as measureuom
from dual
	
UNION

select ',',
	'BASELINE_FORECAST' 	as measurename, ',',
	',',
	'A'	  	as syncind,	',',
	'FORECAST'	as measuredesc, ',',
	'BUCKETED'	as measuretype, ',',
	'NUMBER'	as measureuom
from dual

UNION

select ',',
	'N_A' 	as measurename, ',',
	',',
	'A'	  	as syncind,	',',
	'FORECAST'	as measuredesc, ',',
	'BUCKETED'	as measuretype, ',',
	'NUMBER'	as measureuom
from dual

UNION

select ',',
	'MTBF' 	as measurename, ',',
	',',
	'A'	  	as syncind,	',',
	'MTBF'	as measuredesc, ',',
	'SCALAR'	as measuretype, ',',
	'NUMBER'	as measureuom
from dual
