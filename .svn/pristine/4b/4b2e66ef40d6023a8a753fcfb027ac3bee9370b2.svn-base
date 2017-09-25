create or replace TRIGGER AMD_TRG_RETROFIT_SCHEDULES_RT
after update of scheduled_complete_date on amd_retrofit_schedules
	--
        -- SCCSID: trigAmdRetrofitScheds.sql  1.3  Modified: 06/04/02 15:48:57
        --
        -- Date      By             History
        -- 05/22/02  kcs	    Initial
	-- 05/25/02  kcs	    change access of user
        --                                
for each row
declare
begin
	 update amd_retrofit_tctos 
			set last_sched_update_dt = SYSDATE, 		
			    last_sched_update_id=substr(user, 1, 8)
	 		where tcto_number = :old.tcto_number;
end AMD_TRG_RETROFIT_SCHEDULES_RT;
/
