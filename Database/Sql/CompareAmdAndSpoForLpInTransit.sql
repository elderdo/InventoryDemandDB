/*
	$Author:   zf297a  $
      $Revision:   1.0  $
          $Date:   02 May 2008 16:28:26  $
      $Workfile:   CompareAmdAndSpoForLpInTransit.sql  $
           $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Sql\CompareAmdAndSpoForLpInTransit.sql.-arc  $
/*   
/*      Rev 1.0   02 May 2008 16:28:26   zf297a
/*   Initial revision.
*/

set serveroutput on size 1000000
set term off
set echo off
set feedback off

spool compareAmdAndSpoForLpInTransit.txt

declare
	cursor recs_that_dont_match is 
	select  x.part part,x.location location, x.in_transit_type, 
	x.quantity AMD_QTY, spo.quantity SPO_QTY
	from amd_owner.x_lp_in_transit_v x,
	amd_owner.spo_lp_in_transit_v spo
	where ( x.part = spo.part and x.location = spo.location and x.in_transit_type = spo.in_transit_type)
	and (x.quantity <> spo.quantity) ;

	amdCount number ;
	spoCount number ;
	missingInSpo number ;
	dontMatchCount number ;

	cursor missing_from_spo is
	select part, location, in_transit_type  from amd_owner.x_lp_in_transit_v 
	minus
	select part, location, in_transit_type from amd_owner.spo_lp_in_transit_v ;
	
	cursor should_delete_from_spo is
	select part, location, in_transit_type from amd_owner.spo_lp_in_transit_v 
	minus
	select part, location, in_transit_type  from amd_owner.x_lp_in_transit_v ; 
begin
	select amd_count, spo_count, amd_count - spo_count MissingInSpo, dont_match_cnt 
	into amdCount, spoCount, missingInSpo, dontMatchCount
	from 	(select count(*) amd_count from amd_owner.x_lp_in_transit_v) amd,
		(select count(*) spo_count from amd_owner.spo_lp_in_transit_v) spo,
		(select count(*) dont_match_cnt 
		from amd_owner.x_lp_in_transit_v x,
		amd_owner.spo_lp_in_transit_v spo
		where (x.part = spo.part and x.location = spo.location and x.in_transit_type = spo.in_transit_type)
		and (x.quantity <> spo.quantity)
		) amd_spo ;

	dbms_output.put_line('******** Counts ********') ;
	dbms_output.put_line('amdCount=' || amdCount) ;		
	dbms_output.put_line('spoCount=' || spoCount) ;		
	dbms_output.put_line('missingInSpo=' || missingInSpo) ;		
	dbms_output.put_line('dontMatchCount=' || dontMatchCount) ;		

	if dontMatchCount = 0 then
		dbms_output.put_line('AMD and SPO rows match') ;		
	else
		dbms_output.put_line('********* recs that don''t match **********') ;
		for rec in recs_that_dont_match loop
			dbms_output.put_line(rec.part || ' ' || rec.location || ' ' || rec.in_transit_type || ' '
				|| rec.amd_qty || ' ' || rec.spo_qty ) ; 
		end loop ;
	end if;

	if missingInSPo = 0 then
		dbms_output.put_line('AMD and SPO have the same number of rows') ;
	elsif missingInSpo > 0 then
		dbms_output.put_line('********* Missing In Spo **********') ;
		for rec in missing_from_spo loop
			dbms_output.put_line(rec.part || ' ' || rec.location || ' ' || rec.in_transit_type) ;
		end loop ;
	elsif missingInSpo < 0 then
		dbms_output.put_line('********* Should delete from Spo **********') ;
		for rec in should_delete_from_spo loop
			dbms_output.put_line(rec.location || ' ' || rec.part || ' ' || rec.in_transit_type) ;
		end loop ;
	end if ;
end ;
/

spool off
host notepad compareAmdAndSpoForLpInTransit.txt
