/*
	  $Author:   zf297a  $
	$Revision:   1.1  $
	    $Date:   12 Mar 2007 11:53:24  $
	$Workfile:   Planner.sql  $
	     $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\Planner.sql.-arc  $
/*   
/*      Rev 1.1   12 Mar 2007 11:53:24   zf297a
/*   Added PVCS keywords
*/
select count(*) 
from 
(Select distinct ims_designator_code planner_code 
from amd_use1 
where employee_status = 'A' 
and substr(employee_no,1,1) in ('1','2','3','4','5','6','7','8','9','0') 
and ims_designator_code is not null 
and length(ims_designator_code) = 3 
union 
select uims.DESIGNATOR_CODE planner_code 
from uims 
where 
length(designator_code) = 3 ) ;
