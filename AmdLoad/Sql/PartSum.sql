/*
   vim: ff=unix:ts=2:sw=2:sts=2:expandtab:

      $Author:   c402417  $
    $Revision:   1.2  $
        $Date:   Sep 17 2015
    $Workfile:   PartSum.sql  $
/*   
/*      Rev 1.2   Sep 17 2017 added EZ7436 D.S. Elder
/*      Rev 1.1   Aug 03 2006 10:53:28   c402417
/*   Added date as part of the WHERE CLAUSE .
/*   
/*      Rev 1.0   Feb 17 2006 13:22:24   zf297a
/*   Latest Prod Version
*/
--
-- SCCSID:  PartSum.sql  1.1  Modified:  07/26/04  15:00:55
--

set underline off
set newpage none
set heading off
set pagesize 0
set feedback off
set tab off
set time on

select 
    to_char(n.nsn)|| chr(9) ||
    decode((substr(d.doc_no,1,6)),
        'EY1213','EY1213',
        'FB2029','FB2029',
        'FB2039','FB2039',
        'FB2065','FB2065',
        'EJ4416','EJ4416',
        'EY3279','EY3279',
        'EZ4117','EZ4117',
         'EZ4298','EZ4298',
         'EZ4420','EZ4420',
         'EZ7436','EZ7436',
         s.loc_id)|| chr(9) ||
    to_char(trunc(d.doc_date,'MONTH'), 'mm/dd/yyyy')|| chr(9) ||
    sum(d.quantity)
from
    amd_demands d,
    amd_spare_networks s,
    amd_national_stock_items n
where
    d.loc_sid = s.loc_sid and
    d.nsi_sid = n.nsi_sid and
    n.action_code in('A','C') and
    d.doc_date > to_date('12/31/1999','mm/dd/yyyy')
group by
    n.nsn,
    decode((substr(d.doc_no,1,6)),
        'EY1213','EY1213',
        'FB2029','FB2029',
        'FB2039','FB2039',
        'FB2065','FB2065',
        'EJ4416','EJ4416',
        'EY3279','EY3279',
        'EZ4117','EZ4117',
         'EZ4298','EZ4298',
         'EZ4420','EZ4420',
         'EZ7436','EZ7436',
         s.loc_id),    
    trunc(d.doc_date,'MONTH');

quit
