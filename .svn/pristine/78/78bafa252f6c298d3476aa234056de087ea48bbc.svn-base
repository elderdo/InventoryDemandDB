/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   20 Feb 2009 09:13:20  $
    $Workfile:   loadFedc.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadFedc.sql.-arc  $
/*   
/*      Rev 1.1   20 Feb 2009 09:13:20   zf297a
/*   Added link variable
/*   
/*      Rev 1.0   20 May 2008 14:30:48   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec amd_owner.mta_truncate_table('fedc','reuse storage');

define link=&1

insert into fedc
(
	part_number,vendor_code,seq_number,gfp_price,nsn
)
select 
	trim(part_number),trim(vendor_code),seq_number,gfp_price,trim(nsn)
from fedc@&&link ;


exit 
