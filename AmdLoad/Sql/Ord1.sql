/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   Feb 17 2006 13:22:22  $
    $Workfile:   Ord1.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Ord1.sql.-arc  $
/*   
/*      Rev 1.0   Feb 17 2006 13:22:22   zf297a
/*   Latest Prod Version
*/
set heading off
set feedback off
set tab off 
set newpage none
set pagesize 0

select 
	substr(o.part,1,20) || chr(9) ||
	to_char(completed_docdate,'mm/dd/yyyy HH:MM:SS AM') || chr(9) ||
	to_char(created_docdate,'mm/dd/yyyy hh:mm:ss AM') || chr(9) ||
	action_taken
from
	cat1 c, ord1 o
where
	c.source_code = 'F77'
	and c.part = o.part
	and action_taken in ('A','B','E','F','G',null)  
	and order_type = 'J'
order by
	substr(o.part,1,20);
quit
