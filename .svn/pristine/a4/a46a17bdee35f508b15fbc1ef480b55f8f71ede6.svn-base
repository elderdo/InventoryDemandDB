/*
	$Author:   zf297a  $
      $Revision:   1.1  $
          $Date:   02 May 2008 18:25:06  $
      $Workfile:   CompareAmdAndSpoForLpOverride.sql  $
           $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Sql\CompareAmdAndSpoForLpOverride.sql.-arc  $
/*   
/*      Rev 1.1   02 May 2008 18:25:06   zf297a
/*   Added timing and fixed queries making sure that the sum of the quantity did not equal zero for a given location/part pair.
/*   
/*      Rev 1.0   02 May 2008 16:28:26   zf297a
/*   Initial revision.
*/

set serveroutput on size 1000000
set term off
set echo off
set feedback off
set time on
set timing on

spool compareAmdAndSpoForLpOverride.txt

declare
	cursor recs_that_dont_match is 
	select x.location location, x.part part, x.override_type override_type, 
	x.quantity AMD_QTY, spo.quantity SPO_QTY,
	x.override_user AMD_USER, spo.override_user SPO_USER
	from x_lp_override_v x,
	spo_lp_override_v spo
	where (x.location = spo.location and x.part = spo.part and x.override_type = spo.override_type)
	and (x.quantity <> spo.quantity or x.override_reason <> spo.override_reason or x.override_user <> spo.override_user) ;

	amdCount number ;
	spoCount number ;
	missingInSpo number ;
	dontMatchCount number ;

	cursor missing_from_spo is
	select location, part, override_type from x_lp_override_v lpo
        where exists (select null from x_lp_override_v 
		      where lpo.location = location and lpo.part = part
		      and override_type in ('TSL Fixed','ROP Fixed','ROQ Fixed')
		      group by location, part
		      having sum(quantity) <> 0) 
	minus
	select location, part, override_type from spo_lp_override_v spo
	where exists (select null from spo_lp_override_v 
	      		where spo.location = location and spo.part = part
			and override_type 
				in ('TSL Fixed','ROP Fixed','ROQ Fixed')
			group by location, part
			having sum(quantity) <> 0);	

	cursor should_delete_from_spo is
	select location, part, override_type from spo_lp_override_v spo
	where exists (select null from spo_lp_override_v 
	      		where spo.location = location and spo.part = part
			and override_type 
				in ('TSL Fixed','ROP Fixed','ROQ Fixed')
			group by location, part
			having sum(quantity) <> 0)	
	minus
	select location, part, override_type from x_lp_override_v lpo
        where exists (select null from x_lp_override_v 
		      where lpo.location = location and lpo.part = part
		      and override_type in ('TSL Fixed','ROP Fixed','ROQ Fixed')
		      group by location, part
		      having sum(quantity) <> 0) ; 
begin
	select amd_count, spo_count, amd_count - spo_count MissingInSpo, dont_match_cnt 
	into amdCount, spoCount, missingInSpo, dontMatchCount
	from 	(select count(*) amd_count from x_lp_override_v lpo
		 where exists (select null from x_lp_override_v 
		      		where lpo.location = location and lpo.part = part
				and override_type in ('TSL Fixed','ROP Fixed','ROQ Fixed')
				group by location, part
				having sum(quantity) <> 0)
		) amd,
		(select count(*) spo_count 
		 from spo_lp_override_v spo
		 where exists (select null 
   	               	from spo_lp_override_v 
	      		where spo.location = location and spo.part = part
			and override_type 
				in ('TSL Fixed','ROP Fixed','ROQ Fixed')
			group by location, part
			having sum(quantity) <> 0)
		) spo,
		(select count(*) dont_match_cnt 
		from x_lp_override_v x,
		spo_lp_override_v spo
		where (x.location = spo.location and x.part = spo.part and x.override_type = spo.override_type)
		and exists  (select null 
   	               	from spo_lp_override_v 
	      		where spo.location = location and spo.part = part
			and override_type 
				in ('TSL Fixed','ROP Fixed','ROQ Fixed')
			group by location, part
			having sum(quantity) <> 0)
		and (x.quantity <> spo.quantity or x.override_reason <> spo.override_reason or x.override_user <> spo.override_user)
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
			dbms_output.put_line(rec.location || ' ' || rec.part || ' ' || rec.override_type || ' '
				|| rec.amd_qty || ' ' || rec.spo_qty || ' '
				|| rec.amd_user || ' ' || rec.spo_user ) ;
		end loop ;
	end if;

	if missingInSPo = 0 then
		dbms_output.put_line('AMD and SPO have the same number of rows') ;
	elsif missingInSpo > 0 then
		dbms_output.put_line('********* Missing In Spo **********') ;
		for rec in missing_from_spo loop
			dbms_output.put_line(rec.location || ' ' || rec.part || ' ' || rec.override_type) ;
		end loop ;
	elsif missingInSpo < 0 then
		dbms_output.put_line('********* Should delete from Spo **********') ;
		for rec in should_delete_from_spo loop
			dbms_output.put_line(rec.location || ' ' || rec.part || ' ' || rec.override_type) ;
		end loop ;		
	end if ;
end ;
/

spool off
host notepad compareAmdAndSpoForLpOverride.txt
