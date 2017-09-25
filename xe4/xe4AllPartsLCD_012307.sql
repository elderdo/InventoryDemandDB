/*
	$Author:   zf297a  $
      $Revision:   1.3  $
          $Date:   25 Feb 2008 15:30:34  $
      $Workfile:   xe4AllPartsLCD_012307.sql  $
           $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\xe4\xe4AllPartsLCD_012307.sql.-arc  $
/*   
/*      Rev 1.3   25 Feb 2008 15:30:34   zf297a
/*   Added check for repairable parts.
/*   
/*      Rev 1.2   01 Oct 2007 16:21:28   zf297a
/*   Added locations FB5612 and FB5270
/*   
/*      Rev 1.1   04 Jun 2007 10:04:56   zf297a
/*   Eric Honma says to remove FB4400, FB4405, and FB4480  from the XE4 file.  This should be done for the July RBL.
/*   
/*      Rev 1.0   04 Jun 2007 09:56:18   zf297a
/*   Initial revision.

	This script is used to produce an xe4 file.
*/
prompt Truncating table mils_xe4.......
exec amd_owner.mta_truncate_table('mils_xe4','reuse storage');
set echo off pagesize 0 linesize 210 feed off

define n_from = '05021'
define n_to = '07023'
accept n_from char format 99999 default 05021 prompt 'Enter from julian date YYDDD (&n_from)'
accept n_to char format 99999 default 07023 prompt 'Enter to julian date YYDDD (&n_to)'

prompt Loading mils_xe4.............
insert into mils_xe4 
select distinct
	substr(status_line,12,9)         nsn, -- last 9 char's of nsn
--	substr(status_line,8,13)         nsn, 
	substr(status_line,68,6)         sran, 
	substr(status_line,23,8)         doc_id,
	substr(status_line,33,1)         code1,
	substr(status_line,66,1)         code2,
	substr(status_line,67,1)         code3,
	substr(status_line,7,1)          level_justification,
	substr(status_line,76,5)         timestamp,
	substr(status_line,1,20)||'  '||	substr(status_line,23) 
from mils@pgoldlb m, cat1@pgoldlb c
where default_name = 'XE4' 
	and substr(status_line,76,5) > '&n_from' 
	and substr(status_line,76,5) < '&n_to'
	and substr(status_line,33,1) in ('D','C','L') 
	and substr(status_line,68,6) in 
		('FB4401','FB4402', 'FB4403',
		'FB4406','FB4408','FB4409','FB4411','FB4415','FB5612', 'FB5270')
        and substr(status_line,8,13) = rtrim(replace(c.nsn,'-',''))
	and substr(c.smrc,6,1) = 'T';  -- get repairable data only

commit ;

-- Creating file with raw data
--
prompt Creating file0.txt
set term off
spool file0.txt

select
	status_line
from mils_xe4
order by
	substr(status_line,8,13),
	substr(status_line,68,6),
	substr(status_line,23,8);

/* Order by nsn, sran and doc_id */

spool off
set term on


-- Creating XE4 file for Eric
--
prompt Creating file1.txt
set term off
spool file1.txt

select distinct
-- 	m1.nsn,
-- 	m1.sran,
-- 	m1.doc_id,
-- 	m1.timestamp,
-- 	m1.code1,
-- 	m1.code2,
-- 	m1.code3,
	m1.status_line
-- 	substr(m1.status_line,1,55) || replace(substr(m1.status_line,56,10),' ','0') || substr(m1.status_line,66,15)
from 
	mils_xe4 m1, 
	(select 
		nsn, 
		sran, 
		doc_id, 
		max(timestamp) latest_date
	from mils_xe4 
	group by 
		nsn, 
		sran, 
		doc_id ) m2,
   (select nsn,sran,doc_id,timestamp,'L' reccode
   from mils_xe4
   where code1 = 'L'
   union
   (select nsn,sran,doc_id,timestamp,'C' reccode
   from mils_xe4
	where code1 = 'C'
   minus
   select nsn,sran,doc_id,timestamp,'C' reccode
   from mils_xe4
   where code1 = 'L')
   union
   (select nsn,sran,doc_id,timestamp,'D' reccode
   from mils_xe4
	where code1 = 'D'
   minus
   select nsn,sran,doc_id,timestamp,'D' reccode
   from mils_xe4
   where code1 in ('L','C') ) ) m3,
   (select nsn,sran,doc_id,timestamp,code1,'A' reccode
   from mils_xe4
   where code2 = 'A'
   union
   (select nsn,sran,doc_id,timestamp,code1,'T' reccode
   from mils_xe4
	where code2 = 'T'
   minus
   select nsn,sran,doc_id,timestamp,code1,'T' reccode
   from mils_xe4
   where code2 = 'A') ) m4,
   (select nsn,sran,doc_id,timestamp,code1,code2,' ' reccode
   from mils_xe4
   where code3 = ' '
   union
   (select nsn,sran,doc_id,timestamp,code1,code2,'I' reccode
   from mils_xe4
	where code3 = 'I'
   minus
   select nsn,sran,doc_id,timestamp,code1,code2,'I' reccode
   from mils_xe4
   where code3 = ' ') ) m5,
   (select nsn,sran,doc_id,'3' level_just
   from mils_xe4
	where level_justification = '3'
   union
   (select nsn,sran,doc_id,'8' level_just
   from mils_xe4
	where level_justification = '8'
   minus
   select nsn,sran,doc_id,'8' level_just
   from mils_xe4
   where level_justification = '3') ) m6
where 
	m1.nsn             = m2.nsn 
	and m1.sran        = m2.sran 
	and m1.doc_id      = m2.doc_id 
	and m1.timestamp   = m2.latest_date
	and m1.nsn         = m3.nsn
	and m1.sran        = m3.sran
	and m1.doc_id      = m3.doc_id
	and m1.timestamp   = m3.timestamp
	and m1.code1       = m3.reccode
	and m1.nsn         = m4.nsn
	and m1.sran        = m4.sran
	and m1.doc_id      = m4.doc_id
	and m1.timestamp   = m4.timestamp
	and m1.code1       = m4.code1
	and m1.code2       = m4.reccode
	and m1.nsn         = m5.nsn
	and m1.sran        = m5.sran
	and m1.doc_id      = m5.doc_id
	and m1.timestamp   = m5.timestamp
	and m1.code1       = m5.code1
	and m1.code2       = m5.code2
	and m1.code3       = m5.reccode
	and m1.nsn         = m6.nsn
	and m1.sran        = m6.sran
	and m1.doc_id      = m6.doc_id
	and m1.level_justification = m6.level_just
order by
	substr(m1.status_line,8,13),
	substr(m1.status_line,68,6),
	substr(m1.status_line,23,8);

/* order by nsn, sran, and doc_id */

spool off
term on


-- Creating file for Eric of counts by nsn,sran, and doc_id
--
prompt Creating file2.txt
term off
spool file2.txt

select * from (
select distinct
	m1.nsn,
	m1.sran,
	m1.doc_id, 
--	m1.status_line ,
	count(*)
from 
	mils_xe4 m1, 
	(select 
		nsn, 
		sran, 
		doc_id, 
		max(timestamp) latest_date
	from mils_xe4 
	group by 
		nsn, 
		sran, 
		doc_id ) m2, 
   (select nsn,sran,doc_id,'L' reccode
   from mils_xe4
   where code1 = 'L'
   union
   (select nsn,sran,doc_id,'C' reccode
   from mils_xe4
	where code1 = 'C'
   minus
   select nsn,sran,doc_id,'C' reccode
   from mils_xe4
   where code1 = 'L')
   union
   (select nsn,sran,doc_id,'D' reccode
   from mils_xe4
	where code1 = 'D'
   minus
   select nsn,sran,doc_id,'D' reccode
   from mils_xe4
   where code1 in ('L','C') ) ) m3,
   (select nsn,sran,doc_id,timestamp,code1,'A' reccode
   from mils_xe4
   where code2 = 'A'
   union
   (select nsn,sran,doc_id,timestamp,code1,'T' reccode
   from mils_xe4
	where code2 = 'T'
   minus
   select nsn,sran,doc_id,timestamp,code1,'T' reccode
   from mils_xe4
   where code2 = 'A') ) m4,
   (select nsn,sran,doc_id,timestamp,code1,code2,' ' reccode
   from mils_xe4
   where code3 = ' '
   union
   (select nsn,sran,doc_id,timestamp,code1,code2,'I' reccode
   from mils_xe4
	where code3 = 'I'
   minus
   select nsn,sran,doc_id,timestamp,code1,code2,'I' reccode
   from mils_xe4
   where code3 = ' ') ) m5,
   (select nsn,sran,doc_id,'3' level_just
   from mils_xe4
	where level_justification = '3'
   union
   (select nsn,sran,doc_id,'8' level_just
   from mils_xe4
	where level_justification = '8'
   minus
   select nsn,sran,doc_id,'8' level_just
   from mils_xe4
   where level_justification = '3') ) m6
where 
	m1.nsn             = m2.nsn 
	and m1.sran        = m2.sran 
	and m1.doc_id      = m2.doc_id 
	and m1.timestamp   = m2.latest_date 
	and m1.nsn         = m3.nsn
	and m1.sran        = m3.sran
	and m1.doc_id      = m3.doc_id
	and m1.code1       = m3.reccode 
	and m1.nsn         = m4.nsn
	and m1.sran        = m4.sran
	and m1.doc_id      = m4.doc_id
	and m1.timestamp   = m4.timestamp
	and m1.code1       = m4.code1
	and m1.code2       = m4.reccode
	and m1.nsn         = m5.nsn
	and m1.sran        = m5.sran
	and m1.doc_id      = m5.doc_id
	and m1.timestamp   = m5.timestamp
	and m1.code1       = m5.code1
	and m1.code2       = m5.code2
	and m1.code3       = m5.reccode
	and m1.nsn         = m6.nsn
	and m1.sran        = m6.sran
	and m1.doc_id      = m6.doc_id
	and m1.level_justification = m6.level_just
	and m1.code1 != 'L'
group by m1.nsn,m1.sran,m1.doc_id
) where amd_uti

spool off
term on

prompt sqlplus processing completed
quit
