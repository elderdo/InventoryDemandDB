CREATE OR REPLACE TRIGGER AMD_OWNER.AMD_PARAM_CHANGES_BEFORE_TRIG
BEFORE INSERT OR UPDATE
ON AMD_OWNER.AMD_PARAM_CHANGES 
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
	/*

     $Author:   zf297a  $
   $Revision:   1.3  $
       $Date:   Jul 27 2005 10:08:24  $
   $Workfile:   AMD_PARAM_CHANGES_BEFORE_TRIG.trg  $
       $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\Triggers\AMD_PARAM_CHANGES_BEFORE_TRIG.trg-arc  $
/*   
/*      Rev 1.3   Jul 27 2005 10:08:24   zf297a
/*   Trying to fix PVCS keywords

*/
	   
/*
  	   REV 1.2
	   	   Streamlined code and added automatic defaults for the logon_id or planner_code
		   	      
      REV 1.1   JUL 26 2005 15:05:48   ZF297A
   ADDED ADDITIONAL CHECKS FOR BOTH THE DEFAULT PLANNER_CODE AND DEFAULT LOGON_ID. 
   
      REV 1.0   JUL 05 2005 13:28:02   ZF297A
   INITIAL REVISION.
*/

	   NSN_PLANNER constant varchar(16) := 'nsn_planner_code' ;
	   NSL_PLANNER constant varchar(16) := 'nsl_planner_code' ;
	   NSN_LOGON   constant varchar(12) := 'nsn_logon_id' ;
	   NSL_LOGON   constant varchar(12) := 'nsl_logon_id' ;
	   
		procedure errorMsg(sqlFunction in varchar2, 
				  location in number) is
		begin
			dbms_output.put_line('sqlcode('||sqlcode||') sqlerrm('|| sqlerrm||')') ;
			Amd_Utils.InsertErrorMsg (
					pLoad_no => Amd_Utils.GetLoadNo(pSourceName => sqlFunction,
							                        pTableName  => 'amd_param_changes'),
					pData_line_no => location,
					pData_line    => 'AMD_PARAM_CHANGES_BEFORE_TRIG', 
					pKey_1 => substr(:new.param_key,1,50),
					pKey_2 => substr(:new.param_value,1,50),
					pKey_5 => to_char(sysdate,'MM/DD/YYYY HH:MM:SS'),
					pComments => substr('sqlcode('||sqlcode||') sqlerrm('||sqlerrm||')',1,2000));
		end ErrorMsg;

	   procedure getLogonId(paramKey in amd_params.param_key%type, plannerCode in amd_planners.planner_code%type) is
	   			 cursor users is
				 select logon_id from amd_planner_logons
				 where planner_code = plannerCode ;
				 
				 foundLogonId boolean := false ;
				 
				 cursor use1Users is
				 select amd_load.getBemsId(employee_no) logon_id 
				 from amd_use1
				 where ims_designator_code = plannerCode ;
				 
				 procedure insertDefaultLogonId(logon_id in varchar2) is
				 begin
					insert into amd_param_changes 
					(param_key, effective_date, param_value, user_id)
					values(paramKey, sysdate, logon_id, user) ;
				 exception when others then
					errorMsg(sqlFunction => 'insert', location => 5) ;
					raise ;
				 end insertDefaultLogonId ;
				  
	   begin
	   		for rec in users loop
			    -- there should be only one, but use a cursor and get the first one
				-- it can be changed later
				insertDefaultLogonId(rec.logon_id) ;
				foundLogonId := true ;
				exit ;
			end loop ;
			if not foundLogonId then
			   <<tryAmdUse1>>
			   for rec in use1Users loop
				   	insertDefaultLogonId(rec.logon_id) ;
					foundLogonId := true ;
					exit ;
			   end loop ;
			end if ;
			if not foundLogonId then
			   -- Since there is no match, get rid of the default logon_id
			   <<deleteDefaultLogonId>>
			   begin
			   		delete from amd_param_changes where param_key = paramKey ;
			   exception when others then
		   			 errorMsg(sqlFunction => 'delete', location => 10) ;
					 raise ;
			   end deleteDefaultLogonId ;
			end if ;
	   end getLogonId ;
	   
	   procedure getPlanner(paramKey in amd_params.param_key%type, logonId amd_planner_logons.logon_id%type) is
	   			 cursor planners is
				 select planner_code from amd_planner_logons
				 where logon_id = logonId ;
				 
				 foundPlanner boolean := false ;
				 
				 cursor use1Planners is
				 select ims_designator_code planner_code 
				 from amd_use1
				 where amd_load.getBemsId(employee_no) = logonId ;

				 procedure insertDefaultPlannerCode(plannerCode in amd_planners.planner_code%type) is
				 begin
					insert into amd_param_changes 
					(param_key, effective_date, param_value, user_id)
					values(paramKey, sysdate, plannerCode, user) ;
				 exception when others then
					errorMsg(sqlFunction => 'insert', location => 15) ;
					raise ;
				 end insertDefaultPlannerCode ;
				 
	   begin
	   		for rec in planners loop
			    -- there should be only one, but use a cursor and get the first one
				-- it can be changed later
				insertDefaultPlannerCode(rec.planner_code) ;
				foundPlanner := true ;
				exit ;
			end loop ;
			if not foundPlanner then
			   <<tryAmdUse1>>
			   for rec in use1Planners loop
				   	insertDefaultPlannerCode(rec.planner_code) ;
					foundPlanner := true ;
					exit ;
			   end loop ;
			end if ;
			if not foundPlanner then
			   -- Since there is no match, get rid of the default planner_code
			   <<deleteDefaultPlannerCode>>
			   begin
			   		delete from amd_param_changes 
					where param_key = paramKey ;
					
			   exception
			   			when standard.no_data_found then
							 null ; -- do nothing 
			   			when others then
				   			 errorMsg(sqlFunction => 'delete', location => 20) ;
							 raise ;
			   end deleteDefaultPlannerCode ;
			end if ;
			
	   end getPlanner ;
	   
		function isValidPlannerAndLogon(plannerCode in amd_planners.planner_code%type,
		 					    logonId in amd_planner_logons.logon_id%type) return boolean is
								
			 result boolean := false ;
			 wk_planner_code amd_planners.planner_code%type ;
			 
		begin
			<<tryAmdPlannerLogons>>
			begin
			  select planner_code into wk_planner_code
			  from amd_planner_logons
			  where logon_id = logonId
			  and planner_code = plannerCode ;
			  
			  result := true ;
			  
			exception when standard.no_data_found then
			
				<<tryAmdUse1>>
				begin
					 select ims_designator_code into wk_planner_code
					 from amd_use1
					 where ims_designator_code = plannerCode
					 and amd_load.getBemsId(employee_no) = logonId ;
				
					 result := true ;
				
				exception when standard.no_data_found then
					 null ; -- do nothing 
				end tryAmdUse1 ;
			
			end tryAmdPlannerLogons ;
		
			return result ;
		
		end isValidPlannerAndLogon ;
		
	   
	   function isValidPlanner(plannerCode in amd_planners.planner_code%type) return boolean is
	   			
				wk_planner_code amd_planners.planner_code%type ;
				
				result boolean := false ;
	   begin
	        <<tryAmdPlanners>>
			begin
				select planner_code into wk_planner_code 
				from amd_planners
				where planner_code = plannerCode ;
				
				result := true ;
				
			exception when standard.no_data_found then
			    
				<<tryAmdUse1>>
				declare
					   one number ;
				begin
					 select 1 into one 
					 from dual 
					 where exists 
					 	   (select ims_designator_code 
						    from amd_use1 
							where ims_designator_code = plannerCode) ;
							
					result := true ;
					
				exception when standard.no_data_found then
	        		null ; -- do nothing
				end tryAmdUse1 ;
				
			end tryAmdPlanners ;
			
	   		return result ;
			
	   end isValidPlanner ;
	   
	procedure verifyPlanner is
		logonId amd_planner_logons.logon_id%type ;
		paramKey amd_params.PARAM_KEY%type ;
	begin
		if isValidPlanner(:new.param_value) then
			if :new.param_key = NSL_PLANNER then
				paramKey := NSL_LOGON ;
			else
				paramKey := NSN_LOGON ;
			end if ;
			
			logonId := amd_defaults.getParamValue(paramKey) ;
		
			if logonId is not null then
				if isValidPlannerAndLogon(plannerCode => :new.param_value, logonId => logonId) then
					null ; -- do nothing
				else
					-- try to find a logon_id for this planner_code
					getLogonId(paramKey => paramKey, plannerCode => :new.param_value) ;
				end if ;
			end if ;
		end if ;			
	end verifyPlanner ;
		


	function isValidLogonId(logonId in amd_planner_logons.logon_id%type) return boolean is
		result boolean := false ;
		wk_bems_id amd_users.bems_id%type ;
	begin
	  <<tryAmdUsers>>
	  begin
	  	select bems_id into wk_bems_id 
		from amd_users
		where bems_id = logonId ;
		
		result := true ;
		
	  exception when standard.no_data_found then
		 
		  	<<tryAmdUse1>>
			declare
				   one number ;
			begin
				 select 1 into one
				 from dual
				 where exists (select employee_no 
				 	           from amd_use1
							   where amd_load.getBemsId(employee_no) = isValidLogonId.logonId ) ;
				result := true ;
			exception when standard.no_data_found then
					  if amd_load.getBemsId(logonId) is not null then
					  	 result := true ;
					  end if ;
			end tryAmdUse1 ;
										 
	  end tryAmdUsers ;
	  
	  return result ;
	  
	end isValidLogonId ;
				
	procedure verifyLogon is
		plannerCode amd_planners.planner_code%type  ;
		paramKey amd_params.param_key%type ;
	begin
		if isValidLogonId(:new.param_value) then
			if :new.param_key = NSL_LOGON then
			   paramKey := NSL_PLANNER ;
			else
			   paramKey := NSN_PLANNER ;
			end if;
			plannerCode := amd_defaults.GetParamValue(paramKey) ;
			
			if plannerCode is not null then
		   	  if isValidPlannerAndLogon(plannerCode => plannerCode, logonId => :new.param_value) then
			  	 null ; -- do nothing
			  else
			     -- try to find a planner for this logon_id
			  	 getPlanner(paramKey => paramKey, logonId => :new.param_value) ;
			  end if ;
			end if ;
			
		else
			raise_application_error(-20350,:new.param_value || ' is not a valid logon_id.') ;
		end if ;
	end verifyLogon ;	   
		
begin

	if :new.param_key in (NSN_PLANNER, NSL_PLANNER) then
	   verifyPlanner ;	
	elsif :new.param_key in (NSL_LOGON, NSN_LOGON) then
	   verifyLogon ;
	end if ;
	
end amd_param_changes_before_trig;
/
