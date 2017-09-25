/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   12 Sep 2008 14:07:12  $
    $Workfile:   PartCausalTypeImportErrors.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\PartCausalTypeImportErrors.sql.-arc  $
/*   
/*      Rev 1.0   12 Sep 2008 14:07:12   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set echo off
set time on
set timing on
set linesize 133


column part format a30
column causal_type format a32
column quantity format 99
column action format a3
column exception format 9999
column class format a30
column message format a50

set echo on


select part, causal_type, quantity, action, exception, 
spoc17v2.exception.class, spoc17v2.exception.message
from spoc17v2.x_imp_part_causal_type,
spoc17v2.exception
where exception is not null
and spoc17v2.exception.id = exception ;

variable ret_val number

set echo off

begin
select count(*) into :ret_val
from spoc17v2.x_imp_part_causal_type
where exception is not null ;
end ;
/

print ret_val

exit :ret_val
