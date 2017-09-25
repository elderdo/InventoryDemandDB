/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   08 Sep 2008 13:54:08  $
    $Workfile:   UserPartImportErrors.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\UserPartImportErrors.sql.-arc  $
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


column spo_user format a8
column part format a30
column action format a3
column exception format 9999
column class format a30
column message format a50

set echo on


select spo_user, part, action, exception, 
spoc17v2.exception.class, spoc17v2.exception.message
from spoc17v2.x_imp_user_part,
spoc17v2.exception
where exception is not null
and spoc17v2.exception.id = exception ;

variable ret_val number

set echo off

begin
select count(*) into :ret_val
from spoc17v2.x_imp_user_part
where exception is not null ;
end ;
/

print ret_val

exit :ret_val
