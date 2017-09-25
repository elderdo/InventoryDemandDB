CREATE OR REPLACE package body amd_effectivity_tcto_pkg
is
/*
      $Author:   zf297a  $
    $Revision:   1.1  $
	    $Date:   Nov 30 2005 12:24:06  $
    $Workfile:   amd_effectivity_tcto_pkg.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_effectivity_tcto_pkg.pkb-arc  $
/*   
/*      Rev 1.1   Nov 30 2005 12:24:06   zf297a
/*   added PVCS keywords
*/	
  DECREMENT_BY_1 CONSTANT integer := -1;
  INCREMENT_BY_1 CONSTANT integer := 1;
  e_updateAsFlyAsCapable EXCEPTION;

  function getAcAssignLocSid(pTailNo amd_ac_assigns.tail_no%type, pDate date) return amd_spare_networks.loc_sid%type
  is
  	   locSid amd_spare_networks.loc_sid%type;
       -- sample data had tail with 2 assignment_end dates of null, get latest one
       cursor ac_cur is
            select loc_sid
     	    from amd_ac_assigns
	        where tail_no = pTailNo and
	   		    assignment_start <= pDate and (assignment_end is null or assignment_end >= pDate)
            order by assignment_start desc;
       acRec ac_cur%rowtype;
  begin
       open ac_cur;
       fetch ac_cur into acRec;
       close ac_cur;
       if (acRec.loc_sid is null) then
            raise no_data_found;
       else
            return acRec.loc_sid;
       end if;
  end getAcAssignLocSid;

  procedure updateWhenEffectByS(rec amd_nsi_effects%rowtype)
  is
  begin
  	   update amd_nsi_effects set
	   		  user_defined = decode(rec.user_defined, null, user_defined, rec.user_defined),
			  effect_type  = decode(rec.effect_type, null, effect_type, rec.effect_type),
			  derived  = decode(rec.derived, null, derived, rec.derived)
	   where
	   		  nsi_sid = rec.nsi_sid and
			  tail_no = rec.tail_no;
  end updateWhenEffectByS;

  procedure updateWhenEffectByF(rec amd_cur_nsi_loc_distribs%rowtype)
  is
  begin
  	   update amd_cur_nsi_loc_distribs set
	   		  quantity = nvl(quantity,0) + rec.quantity
	   where
	   		  nsi_sid = rec.nsi_sid and
			  loc_sid = rec.loc_sid;
  end updateWhenEffectByF;

  procedure updateAsFlyAsCapable(pFieldName varchar2, pFieldValue varchar2, pTailNo amd_aircrafts.tail_no%type, pDate date)
  is
  	   cursor curBlkToTcto(pFieldValue varchar2) is
	   		  select
			  		 tcto_number
			  from
			  		 amd_retrofit_schedules
			  where
			  		 block_name = pFieldValue and
					 tail_no = pTailNo;
  begin
  	   if (lower(pFieldName) = 'block_name') then
	   	  	 for rec in curBlkToTcto(pFieldValue) loop
			 	 updateAsFlyAsCapable(rec.tcto_number, pTailNo, pDate);
			 end loop;
	   elsif (lower(pFieldName) = 'tcto_number') then
	   		 updateAsFlyAsCapable(pFieldValue, pTailNo, pDate);
	   end if;
	   commit;
  exception
  	   when others then
	   		rollback;
			raise;
  end updateAsFlyAsCapable;

  procedure updateAnsiAudit(pNsiSid amd_national_stock_items.nsi_sid%type)
  is
  begin
  	   update
	   		  amd_national_stock_items
	   set
	   	  	  effect_last_update_id = substr(user, 1, 8),
			  effect_last_update_dt = sysdate
	   where
	   	   	  nsi_sid = pNsiSid;

  end;

  procedure updateAsFlyAsCapable(pTcto amd_retrofit_schedules.tcto_number%type, pTailNo amd_retrofit_schedules.tail_no%type, pDate date)
  is
  		cursor effCur (pTcto amd_retrofit_schedules.tcto_number%type) is
			   select
			   	   arnp.replaced_nsi_sid as fromSid,
				   arnp.replaced_by_nsi_sid as toSid,
				   ansi.effect_by as fromEffectBy,
				   ansiTo.effect_by as toEffectBy
			   from

			   	   amd_related_nsi_pairs arnp,
	   			   amd_national_stock_items ansi,
				   amd_national_stock_items ansiTo
	   		   where
			   	   arnp.tcto_number = pTcto and
				   arnp.replaced_nsi_sid = ansi.nsi_sid and
				   arnp.replaced_by_nsi_sid = ansiTo.nsi_sid;
		effInfo effCur%rowtype;
		aneRec amd_nsi_effects%rowtype;
		acnldRec amd_cur_nsi_loc_distribs%rowtype;
		locSid amd_spare_networks.loc_sid%type;
		foundRec boolean := false;
  begin
   			-- will throw error if no location found

  	   	for rec in effCur(pTcto) loop
   			foundRec := true;
            begin
           	    locSid := getAcAssignLocSid(pTailNo, pDate);
            exception
                when no_data_found then
                   locSid := null;
            end;
          			-- to Sid --
  	    	aneRec := null;
    	   	acnldRec := null;
   		   	if (rec.toEffectBy = 'F') then
                if (locSid is not null) then
  	    	       acnldRec.nsi_sid := rec.toSid;
       	    	   acnldRec.loc_sid := locSid;
       		   	   acnldRec.quantity := INCREMENT_BY_1;
        	       updateWhenEffectByF(acnldRec);
                end if;
       		else -- effect by 'S'
                if (amd_ascapableflying_pkg.isPartOnTail(rec.toSid, pTailNo)) then
        	       aneRec.nsi_sid := rec.toSid;
    		       aneRec.tail_no := pTailNo;
        		   aneRec.effect_type := 'B';
            	   aneRec.user_defined := 'Y';
	               updateWhenEffectByS(aneRec);
                end if;
   		   	end if;
            if (aneRec.nsi_sid is not null or acnldRec.nsi_sid is not null) then
              	amd_effectivity_pkg.rebuildChildren(rec.toSid);                                            updateAnsiAudit(rec.toSid);
            end if;
			   	-- from sid --
            if (amd_ascapableflying_pkg.isPartOnTail(rec.fromSid, pTailNo)) then
    			aneRec := null;
    			acnldRec := null;
	    		if (rec.fromEffectBy = 'F') then
		    	   acnldRec.nsi_sid := rec.fromSid;
    			   acnldRec.loc_sid := locSid;
	    		   acnldRec.quantity := DECREMENT_BY_1;
		    	   updateWhenEffectByF(acnldRec);
    			else
	    			aneRec.nsi_sid := rec.fromSid;
		    	    aneRec.tail_no := pTailNo;
			    	aneRec.user_defined := 'N';
		    		updateWhenEffectByS(aneRec);
                /* procedure to update as capable will be run subsequent to this procedure */
		    	end if;
		        updateAnsiAudit(rec.fromSid);
		    	amd_effectivity_pkg.rebuildChildren(rec.fromSid);
             end if;
		end loop;
		if (not foundRec) then
		   raise no_data_found;
		end if;
  end updateAsFlyAsCapable;
  function getNsiLocDistribs(pNsiSid integer) return ref_cursor
  is
	refCursor ref_cursor;
  begin
	open refCursor for
		select
			nsn,
			prime_part_no,
			location_name,
			loc_id,
			to_char(time_period_start, 'MM/DD/YY') as time_period_start,
			to_char(time_period_end, 'MM/DD/YY') as time_period_end,
			as_flying_count,
			as_flying_percent,
			as_capable_count,
			as_capable_percent
		from
			amd_nsi_loc_distribs anld,
			amd_national_stock_items ansi,
			amd_spare_networks asn
		where
			anld.nsi_sid=ansi.nsi_sid and
			anld.loc_sid=asn.loc_sid and anld.nsi_sid = pNsiSid
		order by loc_id, anld.time_period_start;
	return refCursor;
  end;
end amd_effectivity_tcto_pkg;
/
