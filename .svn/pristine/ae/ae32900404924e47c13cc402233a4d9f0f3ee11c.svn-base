/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   14 Nov 2008 13:41:20  $
    $Workfile:   LpDemandImportErrors.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\LpDemandImportErrors.sql.-arc  $
/*   
/*      Rev 1.0   14 Nov 2008 13:41:20   zf297a
/*   Initial revision.
/*   
/*      Rev 1.0   12 Nov 2008 12:33:38   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set echo off
set time on
set timing on
set linesize 133


column transaction_id format a20
column location format a6
column part format a30
column action format a3
column exception format 9999
column class format a30
column message format a50

set echo on

select transaction_id, location, part, action, exception, class, message 
from spoc17v2.x_imp_lp_demand,
spoc17v2.exception
where exception is not null
and spoc17v2.exception.id = spoc17v2.x_imp_lp_demand.exception ;

set echo off

variable ret_val number 

begin
select count(*) into :ret_val 
from spoc17v2.x_imp_lp_demand 
where exception is not null ;
end ;
/

print ret_val

exit :ret_val


