/*
      $Author:   Douglas S. Elder
    $Revision:   1.1
        $Date:   21 Nov 2017
    $Workfile:   PlannerLogons.sql  $
/*   
/*      Rev 1.2   22 Nov 2017 DSE removed set's only output should be the count
/*      Rev 1.1   21 Nov 2017 DSE added set serveroutput
/*      Rev 1.0   11 Mar 2007 11:47:14   DSE
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
