/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   15 Jan 2009 13:38:18  $
    $Workfile:   ConfirmedRequestLineImportErrors.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\ConfirmedRequestLineImportErrors.sql.-arc  $
/*   
/*      Rev 1.0   15 Jan 2009 13:38:18   zf297a
/*   Initial revision.
/*   
/*      Rev 1.0   12 Jan 2009 12:45:46   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set echo off
set time on
set timing on
set linesize 133


column confirmed_request format a18
column line format 9999
column action format a3
column exception format 9999
column class format a30
column message format a50

set echo on


select confirmed_request, line, action, exception, 
spoc17v2.exception.class, spoc17v2.exception.message
from spoc17v2.x_imp_confirmed_request_line,
spoc17v2.exception
where exception is not null
and exception = spoc17v2.exception.id (+) ;

variable ret_val number

set echo off

begin
select count(*) into :ret_val
from spoc17v2.x_imp_confirmed_request_line
where exception is not null ;
end ;
/

print ret_val

exit :ret_val
