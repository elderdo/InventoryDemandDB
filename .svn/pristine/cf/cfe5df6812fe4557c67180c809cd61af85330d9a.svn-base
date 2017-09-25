/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   08 Sep 2008 15:23:24  $
    $Workfile:   LpOverrideImportErrors.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\LpOverrideImportErrors.sql.-arc  $
/*   
/*      Rev 1.0   08 Sep 2008 15:23:24   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set echo off
set time on
set timing on
set linesize 133


column part format a30
column lead_time_type format a16
column action format a3
column exception format 9999
column class format a30
column message format a50

set echo on

select location, part, override_type, action, exception, class, message 
from spoc17v2.x_imp_lp_override,
spoc17v2.exception
where exception is not null
and spoc17v2.exception.id = spoc17v2.x_imp_lp_override.exception ;

set echo off

variable ret_val number 

begin
select count(*) into :ret_val 
from spoc17v2.x_imp_lp_override 
where exception is not null
and exception <> 1806 ;
end ;
/

print ret_val

exit :ret_val


