create or replace TRIGGER AMD_TRG_RELATED_NSI_PAIRS_RT
after update of tcto_number on amd_related_nsi_pairs
	--
        -- SCCSID: trigAmdRelatedNsiPairs.sql  1.3  Modified: 06/04/02 15:48:41
        --
       -- Date      By             History
        -- 05/22/02  kcs	    Initial
	-- 05/25/02  kcs	    change access of user
        --                                                                       

for each row
declare
begin
	 if (:new.tcto_number is null) then
 		 update amd_retrofit_tctos 
			set last_nsi_pairs_update_dt = SYSDATE, last_nsi_pairs_update_id=substr(user, 1, 8)
	 		where tcto_number = :old.tcto_number;
	 elsif (:old.tcto_number is null) then
	 	 update amd_retrofit_tctos i
			set last_nsi_pairs_update_dt = SYSDATE, last_nsi_pairs_update_id=substr(user, 1, 8)
	 		where tcto_number = :new.tcto_number;
	 elsif (:old.tcto_number != :new.tcto_number) then
 	 	 update amd_retrofit_tctos 
			set last_nsi_pairs_update_dt = SYSDATE, last_nsi_pairs_update_id=substr(user, 1, 8)
	 		where tcto_number in (:old.tcto_number, :new.tcto_number);
	 end if;
end AMD_TRG_RELATED_NSI_PAIRS_RT;
/
