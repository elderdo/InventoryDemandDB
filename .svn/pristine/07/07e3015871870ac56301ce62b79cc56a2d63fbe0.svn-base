/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   11 Mar 2007 11:47:14  $
    $Workfile:   Users.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\Users.sql.-arc  $
/*   
/*      Rev 1.0   11 Mar 2007 11:47:14   zf297a
/*   Initial revision.
*/

select count(*) from 
(Select distinct amd_load.getBemsId(employee_NO) bems_id, stable_email, last_name, first_name from amd_use1, amd_people_all_v where employee_status = 'A'  and length(ims_designator_code) = 3 and amd_load.getBemsId(employee_no) = bems_id union select amd_load.getBemsId(userid) bems_id, stable_email, last_name, first_name 
from uims, amd_people_all_v 
where length(designator_code) = 3  and amd_load.getBemsId(userid) = bems_id ) ;
