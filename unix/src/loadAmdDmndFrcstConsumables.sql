/*
      $Author$ zf297a
    $Revision$ 1.0
        $Date$ 05 Feb 2010 10:19
         $Log$ initial rev
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec amd_owner.mta_truncate_table('amd_dmnd_frcst_consumables','reuse storage');


insert into amd_dmnd_frcst_consumables
(    
    nsn,sran,period,demand_forecast,duplicate
)
select 
nsn,sran, period,demand_forecast,duplicate
from tmp_amd_dmnd_frcst_consumables ;

commit ;

exit 





