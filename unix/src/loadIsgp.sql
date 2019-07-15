/*
      $Author:   Douglas S Elder
    $Revision:   1.4
        $Date:   22 Nov 2017
    $Workfile:   loadIsgp.sql  $
/*   
/*      Rev 1.4   22 Nov 2017 DSE changed serveroutput to UNLIMITED
/*      Rev 1.3   11 Jan 2013 DSE
/*      Rev 1.2   19 May 2010 16:19   DSE
/*   Added procedures to load the data and to check for bad data
/*      Rev 1.1   20 Feb 2009 09:27:08   DSE
/*   Added link variable
/*   
/*      Rev 1.0   20 May 2008 14:30:50   DSE
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on
set serveroutput on size UNLIMITED 

define link = &1

declare
	procedure loadAmdIsgp is 
		type amd_isgp_tab is table of amd_isgp%rowtype ;
		amd_isgp_recs amd_isgp_tab := amd_isgp_tab() ;
		cursor isgp_data is
		select trim(sc),trim(part),trim(group_no),nvl(sequence_no,'01'),
		trim(group_priority), sysdate 
		from isgp@&&link a
		where not exists (select null from isgp@&&link b
			      where trim(a.sc) = trim(b.sc)
				and trim(a.part) = trim(b.part)
				and trim(a.group_no) <> trim(b.group_no)
				) ;	
	begin
		open isgp_data ;
		fetch isgp_data bulk collect into amd_isgp_recs ;
		close isgp_data ;
		forall i in amd_isgp_recs.first .. amd_isgp_recs.last
			insert into amd_isgp
			values amd_isgp_recs(i) ;
		commit ;
		if amd_isgp_recs.first is not null then
			dbms_output.put_line('loaded ' || amd_isgp_recs.last || ' rows to amd_isgp') ;
		else
			dbms_output.put_line('no records were loaded to amd_isgp') ;			
			amd_warnings_pkg.insertWarningMsg(pData_line_no => 5,
				pData_line => 'loadIsgp.sql',
				pWarning => 'no records were loaded to amd_isgp') ;
		end if ;
	end loadAmdIsgp ;			
	procedure reportBadData is
		cursor bad_isgp is
		select trim(a.sc) sc, 
			trim(a.part) part, 
			trim(a.group_no) a_group_no,
			trim(b.group_no) b_group_no
		from isgp@&&link a, 
		isgp@&&link b
		where trim(a.sc) = trim(b.sc)
		and trim(a.part) = trim(b.part)
		and trim(a.group_no) <> trim(b.group_no) ;
		cnt number := 0 ;
	begin
		for rec in bad_isgp loop
			dbms_output.put_line('Part ' || rec.part || ' is in more than one Group: sc=' || rec.sc 
				|| ' group_no=' || rec.a_group_no || ' and group_no=' || rec.b_group_no) ;
			amd_warnings_pkg.insertWarningMsg(pData_line_no => 10,
				pData_line => 'loadIsgp.sql',
				pWarning => 'Part ' || rec.part || ' is in more than one Group: sc=' || rec.sc 
					|| ' group_no=' || rec.a_group_no || ' and group_no=' || rec.b_group_no) ;
			cnt := cnt + 1 ;
		end loop ;
		if cnt > 0 then
			dbms_output.put_line(cnt || ' rows in isgp had part(s) in more than one group') ;
			amd_warnings_pkg.insertWarningMsg(pData_line_no => 20,
				pData_line => 'loadIsgp.sql',
				pWarning => cnt || ' rows in isgp had part(s) in more than one group') ;
		end if ;
	end reportBadData ;
begin
	amd_owner.mta_truncate_table('amd_isgp','reuse storage');
	loadAmdIsgp ;
	reportBadData ;
end ;
/



exit 
