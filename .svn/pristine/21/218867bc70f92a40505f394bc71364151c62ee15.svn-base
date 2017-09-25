/*
      $Author:   zf297a  $
    $Revision:   1.2  $
        $Date:   20 Feb 2009 09:27:58  $
    $Workfile:   loadUse1.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadUse1.sql.-arc  $
/*	
/*	Rev 1.2   21 May 2009            c402417
/*	Added to employee_status != 'I' to filter of the query.
/*   
/*      Rev 1.1   20 Feb 2009 09:27:58   zf297a
/*   Added link variable
/*   
/*      Rev 1.0   20 May 2008 14:30:54   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec amd_owner.mta_truncate_table('amd_use1','reuse storage');

define link = &1

insert into amd_use1
(
	userid,user_name,employee_no,employee_status,phone,ims_designator_code
)
select 
	trim(userid),trim(user_name),trim(employee_no),employee_status,trim(phone),trim(ims_designator_code)
from use1@&&link
where employee_no is not null and employee_status != 'I';

exit 
