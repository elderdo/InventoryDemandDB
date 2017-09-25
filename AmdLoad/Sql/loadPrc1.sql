/*
      $Author:   zf297a  $
    $Revision:   1.2  $
        $Date:   20 Feb 2009 09:28:34  $
    $Workfile:   loadPrc1.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadPrc1.sql.-arc  $
/*   
/*      Rev 1.2   20 Feb 2009 09:28:34   zf297a
/*   Added link variable
/*   
/*      Rev 1.1   17 Jul 2008 11:26:18   zf297a
/*   Skip parts with leading or trailing blanks.
/*   
/*      Rev 1.0   20 May 2008 14:30:52   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec amd_owner.mta_truncate_table('prc1','reuse storage');

define link = &1

insert into prc1
(
	sc,part,cap_price,gfp_price
)
select 
	trim(sc),trim(part),cap_price,gfp_price
from prc1@&&link
where
	sc = 'DEF'
	and part not like '% '
	and part not like ' %' ;

exit 
