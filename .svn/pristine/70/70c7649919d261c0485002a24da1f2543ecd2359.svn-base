/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   26 Jan 2007 14:30:28  $
    $Workfile:   createAmdOnOrderInserts.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Scripts\createAmdOnOrderInserts.sql.-arc  $
/*   
/*      Rev 1.1   26 Jan 2007 14:30:28   zf297a
/*   added sqlplus "set define off" command
/*   
/*      Rev 1.0   26 Jan 2007 11:49:54   zf297a
/*   Initial revision.
*/   


set define off

set echo off newpage 0 space 0 pagesize 0 feed off head off trimspool on
set linesize 400
spool loadAmdOnOrder.sql

select 'insert into amd_on_order (part_no, loc_sid, order_date, order_qty, gold_order_number, action_code, last_update_dt, sched_receipt_date) values (''' 
|| part_no || ''',' 
|| loc_sid || ', to_date(''' 
|| to_char(order_date,'MM/DD/YYYY HH:MI:SS') || ''',''MM/DD/YYYY HH:MI:SS''),' 
|| order_qty || ',''' 
|| gold_order_number || ''',''' 
|| action_code || ''', to_date(''' 
|| to_char(last_update_dt,'MM/DD/YYYY HH:MI:SS') || ''',''MM/DD/YYYY HH:MI:SS''), to_date(''' 
|| to_char(sched_receipt_date,'MM/DD/YYYY HH:MI:SS') || ''',''MM/DD/YYYY HH:MI:SS''));' 
from amd_on_order ;

spool off

