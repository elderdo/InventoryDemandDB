/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   11 Mar 2007 11:47:14  $
    $Workfile:   PlannerLogons.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\PlannerLogons.sql.-arc  $
/*   
/*      Rev 1.0   11 Mar 2007 11:47:14   zf297a
/*   Initial revision.
*/

select count(*) 
from 
(select distinct ims_designator_code planner_code, amd_load.getBemsId(employee_no) logon_id, '1' data_source 
from amd_use1 
where employee_status = 'A' 
and length(ims_designator_code) = 3 
and amd_load.getBemsId(employee_no) is not null 
union 
select designator_code planner_code, amd_load.getBemsId(userid) logon_id, '2' data_source 
from uims 
where length(designator_code) = 3 
and amd_load.getBemsId(userid) is not null) ;
