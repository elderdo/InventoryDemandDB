/*
      $Author:   Douglas S Elder
    $Revision:   1.1
        $Date:   21 Nov 2017
    $Workfile:   Users.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\Users.sql.-arc  $
/*   
/*      Rev 1.2   22 Nov 2017 DSE removed set commands only output should be the count
/*      Rev 1.1   21 Nov 2017 DSE added set serveroutput, time, timing
/*      Rev 1.0   11 Mar 2007 11:47:14   zf297a
/*   Initial revision.
*/


select count(*) from 
(Select distinct amd_load.getBemsId(employee_NO) bems_id, stable_email, last_name, first_name from amd_use1, amd_people_all_v where employee_status = 'A'  and length(ims_designator_code) = 3 and amd_load.getBemsId(employee_no) = bems_id union select amd_load.getBemsId(userid) bems_id, stable_email, last_name, first_name 
from uims, amd_people_all_v 
where length(designator_code) = 3  and amd_load.getBemsId(userid) = bems_id ) ;
