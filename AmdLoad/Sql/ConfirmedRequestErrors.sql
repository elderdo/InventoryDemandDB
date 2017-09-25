/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   12 Jan 2009 12:50:10  $
    $Workfile:   ConfirmedRequestErrors.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\ConfirmedRequestErrors.sql.-arc  $
/*   
/*      Rev 1.0   12 Jan 2009 12:50:10   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set echo off
set time on
set timing on
set linesize 133


column name format a18
column action format a3
column exception format 9999
column class format a30
column message format a50

set echo on


select name, action, exception, 
spoc17v2.exception.class, spoc17v2.exception.message
from spoc17v2.x_imp_confirmed_request,
spoc17v2.exception
where exception is not null
and exception = spoc17v2.exception.id (+) ;

variable ret_val number

set echo off

begin
select count(*) into :ret_val
from spoc17v2.x_imp_confirmed_request
where exception is not null ;
end ;
/

print ret_val

exit :ret_val
