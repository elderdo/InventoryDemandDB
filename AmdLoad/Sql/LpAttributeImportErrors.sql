/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   04 Dec 2008 00:34:12  $
    $Workfile:   LpAttributeImportErrors.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\LpAttributeImportErrors.sql.-arc  $
/*   
/*      Rev 1.1   04 Dec 2008 00:34:12   zf297a
/*   Added code
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

select location, part, action, exception, class, message 
from spoc17v2.x_imp_lp_attribute,
spoc17v2.exception
where exception is not null
and spoc17v2.exception.id = spoc17v2.x_imp_lp_attribute.exception ;

set echo off

variable ret_val number 

begin
select count(*) into :ret_val 
from spoc17v2.x_imp_lp_attribute 
where exception is not null ;
end ;
/

print ret_val

exit :ret_val


