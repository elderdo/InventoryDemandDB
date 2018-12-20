DROP PACKAGE BODY AMD_OWNER.AMD_DEFAULT_EFFECTIVITY_PKG;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.amd_default_effectivity_pkg as
    /*
       $Author:   c970183  $
     $Revision:   1.1  $
         $Date:   15 May 2002 10:12:24  $
     $Workfile:   amd_default_effectivity_pkg.pkb  $
	      $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\Packages\amd_default_effectivity_pkg.pkb-arc  $
/*
/*      Rev 1.1   15 May 2002 10:12:24   c970183
/*   eliminated select of nextval and added select of currval for the sequence.

	  SCCSID:	amd_default_effectivity_pkg.sql	1.2	Modified: 05/15/02  10:20:46
		  */

    function newGroup return number is

	    nsiGroupSid  number;

    begin


	    insert into amd_nsi_groups(nsi_group_sid, fleet_size_name, split_effect)
		    values(nsiGroupSid, 'All Aircraft', 'N') ;

	    select amd_nsi_group_sid_seq.currval
		    into nsiGroupSid
		    from dual;

	    return nsiGroupSid ;
	    /*
	    update amd_national_stock_items set
		    nsi_group_sid = nsigroupsid
		    effect_by = 'S'
		    where nsi_sid = pNsiSid;
	    */

    end;

    procedure setNsiEffects(pNsiSid number) is
	    cursor cur_sel_tail_no is
		    select tail_no
		    from amd_aircrafts
		    where tail_no != 'DUMMY' ;
    begin
	    for rec in cur_sel_tail_no LOOP
		    insert into amd_nsi_effects(nsi_sid, tail_no, effect_type,
					    user_defined, derived)
		    values (pNsiSid, rec.tail_no, 'B','S','N') ;
	    end loop;
    end ;

end amd_default_effectivity_pkg ;
/


DROP PUBLIC SYNONYM AMD_DEFAULT_EFFECTIVITY_PKG;

CREATE PUBLIC SYNONYM AMD_DEFAULT_EFFECTIVITY_PKG FOR AMD_OWNER.AMD_DEFAULT_EFFECTIVITY_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_DEFAULT_EFFECTIVITY_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_DEFAULT_EFFECTIVITY_PKG TO AMD_WRITER_ROLE;
