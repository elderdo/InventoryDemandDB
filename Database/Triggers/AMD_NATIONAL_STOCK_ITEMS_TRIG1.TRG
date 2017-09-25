create or replace trigger amd_national_stock_items_trig1
before insert
on amd_national_stock_items
for each row
--
-- SCCSID:  %M%   %I%   Modified: %G%  %U%
--
--   $Author:   c970408  $
-- $Revision:   1.1  $
--     $Date:   13 Feb 2003 12:11:22  $
-- $Workfile:   AMD_NATIONAL_STOCK_ITEMS_TRIG1.TRG  $
--
-- 02/13/03  FF     Added check to allow user-specific nsi_sids.
--                  Useful when copying data from one db to another.

declare
begin
	if (:new.nsi_sid is null) then
		select amd_nsi_sid_seq.nextval into :new.nsi_sid from dual;
	end if;
end;
/ 
