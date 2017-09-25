CREATE OR REPLACE package body amd_basic_default_pkg as
/*
      $Author:   zf297a  $
    $Revision:   1.1  $
     $Date:   Dec 01 2005 09:27:36  $
    $Workfile:   amd_basic_default_pkg.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\amd_basic_default_pkg.pkb-arc  $
/*   
/*      Rev 1.1   Dec 01 2005 09:27:36   zf297a
/*   added pvcs keywords
*/
procedure setGroup(pNsiSid number) is
	nsigroupsid	number ;

	cursor cur_sel_tail_no is
	select tail_no
	from amd_aircrafts
	where tail_no != 'DUMMY';
begin

	insert into amd_nsi_effects(nsi_sid, tail_no, effect_type, user_defined,		derived)
	select a.nsi_sid, b.tail_no, 'B', 'S', 'N'
	from amd_national_stock_items a, amd_aircrafts b
	where a.nsi_sid = pNsiSid;


	insert into amd_nsi_groups(fleet_size_name, split_effect)
		values('All Aircraft','N');

	select amd_nsi_group_sid_seq.currval into nsigroupsid from dual ;

	update amd_national_stock_items set
		nsi_group_sid = nsigroupsid,
		latest_config = 'Y',
		effect_by = 'S'
		where nsi_sid = pNsiSid;
end ;

procedure setAllGroups is
	cursor cur_sel_nsi_sid is
	select nsi_sid
	from amd_national_stock_items
	where nsi_group_sid is null;
begin
	for rec in cur_sel_nsi_sid  LOOP
		setGroup(rec.nsi_sid);
	end loop;
end;

end amd_basic_default_pkg ;
/
