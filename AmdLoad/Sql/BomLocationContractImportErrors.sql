/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   10 Apr 2009 13:13:42  $
    $Workfile:   BomLocationContractImportErrors.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\BomLocationContractImportErrors.sql.-arc  $
/*   
/*      Rev 1.1   10 Apr 2009 13:13:42   zf297a
/*   Fixed table name
/*   
/*      Rev 1.0   10 Apr 2009 12:18:46   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set echo off
set time on
set timing on
set linesize 133


column bom format a64
column location format a32
column action format a3
column exception format 9999
column class format a30
column message format a50

set echo on

select bom, location, action, exception, class, message 
from spoc17v2.x_imp_bom_location_contract,
spoc17v2.exception
where exception is not null
and spoc17v2.exception.id = spoc17v2.x_imp_bom_location_contract.exception ;

set echo off

variable ret_val number 

begin
select count(*) into :ret_val 
from spoc17v2.x_imp_bom_location_contract 
where exception is not null ;
end ;
/

print ret_val

exit :ret_val


