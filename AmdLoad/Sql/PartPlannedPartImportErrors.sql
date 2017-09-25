/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   27 Oct 2008 10:03:28  $
    $Workfile:   PartPlannedPartImportErrors.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\PartPlannedPartImportErrors.sql.-arc  $
/*   
/*      Rev 1.1   27 Oct 2008 10:03:28   zf297a
/*   For exception 1060 apply a special query to see if there are really any delete errors or that all the referenced part/planned_part's are deleted.
/*   
/*      Rev 1.0   08 Sep 2008 13:54:08   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set echo off
set time on
set timing on
set linesize 133


column part format a30
column planned_part format a30
column action format a3
column exception format 9999
column class format a30
column message format a50

set echo on


select part, planned_part, action, exception, 
spoc17v2.exception.class, spoc17v2.exception.message
from spoc17v2.x_imp_part_planned_part,
spoc17v2.exception
where exception is not null
and exception <> 1060
and spoc17v2.exception.id = exception ;

select x.part, x.planned_part, x.action, x.exception,
spoc17v2.exception.class, spoc17v2.exception.message
from spoc17v2.x_imp_part_planned_part x,
spoc17v2.exception
where action = 'DEL'
and exists (select part 
from spoc17v2.v_part_planned_part v
where x.part=v.part
and x.planned_part=v.planned_part) 
and spoc17v2.exception.id = x.exception ;


variable ret_val number
variable delete_problems number

set echo off

begin
select count(*) into :delete_problems
from spoc17v2.x_imp_part_planned_part x 
where action = 'DEL'
and exception <> 1003
and exists (select part 
from spoc17v2.v_part_planned_part v
where x.part=v.part
and x.planned_part=v.planned_part) ;
select count(*) into :ret_val
from spoc17v2.x_imp_part_planned_part
where exception is not null
and exception not in (1060,1003) ;
if :delete_problems > 0 then
	:ret_val := :delete_problems ;
else
  -- check for dependent records
  -- for this type of DEL error
  select count(*) into :delete_problems
  from spoc17v2.x_imp_part_planned_part x,
  spoc17v2.v_part_planned_part v
  where x.exception is not null
  and x.exception = 1003
  and x.action = 'DEL' 
  and x.part = v.part
  and x.planned_part = v.planned_part ;
  if :delete_problems > 0 then
    :ret_val := :delete_problems ;
  end if ;  
end if ;	
end ;
/

print ret_val

exit :ret_val
