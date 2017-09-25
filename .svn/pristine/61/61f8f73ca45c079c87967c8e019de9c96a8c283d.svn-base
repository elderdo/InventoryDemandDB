/*
      $Author:   zf297a  $
    $Revision:   1.3  $
        $Date:   20 Aug 2009 08:56:22  $
    $Workfile:   loadPoi1.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\loadPoi1.sql.-arc  $
/*   
/*      Rev 1.3   20 Aug 2009 08:56:22   zf297a
/*   Change to use v_poi1 was requested via ClearQuest LBPSS00002264 
/*   
/*      Rev 1.2   20 Aug 2009 08:52:18   zf297a
/*   Use the v_poi1@pgoldlb as the data source
/*   
/*      Rev 1.1   20 Feb 2009 09:12:44   zf297a
/*   Added link variable
/*   
/*      Rev 1.0   20 May 2008 14:30:52   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec amd_owner.mta_truncate_table('poi1','reuse storage');

define link=&1

insert into poi1
(
	order_no,seq,item,qty,item_line,ext_price,part,ccn,delivery_date
)
select 
	trim(order_no),trim(seq),trim(item),trim(qty),trim(item_line),trim(ext_price),trim(part),trim(ccn),trim(delivery_date) 
from v_poi1@&&link 
where 
	ext_price is not null;

exit ;
