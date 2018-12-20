DROP PACKAGE BODY AMD_OWNER.AMD_BATCH_PKG;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.Amd_Batch_Pkg AS
	/*7
      $Author:   zf297a  $
    $Revision:   1.14  $
	    $Date:   23 Mar 2007 13:18:22  $
    $Workfile:   AMD_BATCH_PKG.pkb  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_BATCH_PKG.pkb.-arc  $
/*
/*      Rev 1.14   23 Mar 2007 13:18:22   zf297a
/*   Do a commit after every insert and update so that this information is immediately available to anyone checking on a job status.
/*
/*      Rev 1.13   Jul 11 2006 09:04:10   zf297a
/*   Changed start_job to view any job with an job_abort field that is not null as being "terminated".
/*
/*      Rev 1.12   Jun 09 2006 11:34:48   zf297a
/*   implemented version
/*
/*      Rev 1.11   May 05 2006 09:24:34   zf297a
/*   Fixed invocation of getLastStartTime to used the named parameter notation for system_id since the batch_job_number is not available, otherwise Oracle will issue a
/*   "ORA-06502: PL/SQL: numeric or value error: character to number conversion error"  when the system_id is passed as the first positional parameter - i.e. it thinks it is the batch_job_number, but it is NOT, hence the number conversion error since system_id is always a VARCHAR2.
/*
/*      Rev 1.10   May 01 2006 12:10:02   zf297a
/*   Fixed isJobComplete
/*
/*      Rev 1.9   Apr 05 2006 14:09:42   zf297a
/*   Fixed getLastStartTime - will return null if there are no jobs in the system.
/*
/*      Rev 1.8   Mar 23 2006 10:52:06   zf297a
/*   Added an exception handler to truncateIfOld and updated the error location numbers.
/*
/*      Rev 1.7   Mar 23 2006 08:21:20   zf297a
/*   Implemented procedure truncateIfOld - this procedure will only truncate a table if there is no active batch job for the given system_id or if  there is an active job and the table has been updated since the job started.
/*
/*      Rev 1.6   Mar 21 2006 08:38:12   zf297a
/*   Fixed getLastStartData
/*
/*      Rev 1.5   Mar 19 2006 01:49:06   zf297a
/*   Implemented isStepComplete function
/*
/*      Rev 1.3   Mar 16 2006 14:25:00   zf297a
/*   Implemented step functions and procedures
/*
/*      Rev 1.2   Mar 03 2006 12:33:58   zf297a
/*   Implemented functions getLastStartTime, getLastEndTime, and isJobComplete.
/*
/*      Rev 1.1   Nov 22 2005 08:09:22   zf297a
/*   Restored body using previous package dump.
*/

	procedure ErrorMsg(
					pSqlfunction in amd_load_status.SOURCE%type,
					pTableName in amd_load_status.TABLE_NAME%type := '',
					pError_location amd_load_details.DATA_LINE_NO%type,
					pKey_1 in amd_load_details.KEY_1%type := '',
			 		pKey_2 in amd_load_details.KEY_2%type := '',
					pKey_3 in amd_load_details.KEY_3%type := '',
					pKey_4 in amd_load_details.KEY_4%type := '',
					pKeywordValuePairs in varchar2 := '') is
		key5 amd_load_details.KEY_5%type := pKeywordValuePairs ;
	begin
		rollback;
		if key5 = '' then
		   key5 := pSqlFunction || '/' || pTableName ;
		else
			key5 := key5 || ' ' || pSqlFunction || '/' || pTableName ;
		end if ;
		-- use substr's to make sure that the input parameters for InsertErrorMsg and GetLoadNo
		-- do not exceed the length of the column's that the data gets inserted into
		-- This is for debugging and logging, so efforts to make it not be the source of more
		-- errors is VERY important
		Amd_Utils.InsertErrorMsg (
				pLoad_no => Amd_Utils.GetLoadNo(
						pSourceName => substr(pSqlfunction,1,20),
						pTableName  => substr(pTableName,1,20)),
				pData_line_no => pError_location,
				pData_line    => 'amd_batch_pkg.',
				pKey_1 => substr(pKey_1,1,50),
				pKey_2 => substr(pKey_2,1,50),
				pKey_3 => substr(pKey_3,1,50),
				pKey_4 => substr(pKey_4,1,50),
				pKey_5 => to_char(sysdate,'MM/DD/YYYY HH:MM:SS') ||
						   ' ' || substr(key5,1,50),
				pComments => substr('sqlcode('||sqlcode||') sqlerrm('||sqlerrm||')',1,2000));
		commit;
	end ErrorMsg;

  procedure validateJob(batch_job_number in out amd_batch_jobs.BATCH_JOB_NUMBER%type, system_id in amd_batch_jobs.SYSTEM_ID%type) is

  begin
  	   if batch_job_number is null then
	   	  batch_job_number := getActiveJob(system_id) ;
		  if batch_job_number is null then
		  	 batch_job_number := getLastCompleteJob(system_id) ;
		  end if ;
	   else
	   	   if not isJob(batch_job_number, system_id) then
		   	  	  RAISE_APPLICATION_ERROR(-20130,'Job ' || batch_job_number || ',' || system_id || ' is not a valid job.') ;
		   end if ;
	   end if ;
  end validateJob ;

  procedure validateActiveJob(batch_job_number in out amd_batch_jobs.BATCH_JOB_NUMBER%type, system_id in amd_batch_jobs.SYSTEM_ID%type ) is
  begin

  	   if batch_job_number is null then
	   	  batch_job_number := getActiveJob(system_id) ;
		  if batch_job_number is null then
		  	 RAISE_APPLICATION_ERROR(-20140,'There is no active job for system_id=' || system_id || '.') ;
		  end if ;
	  else
	   	   if isJob(batch_job_number, system_id) then
		   	  if not isJobActive(batch_job_number, system_id) then
		   	  	  RAISE_APPLICATION_ERROR(-20150,'Job ' || batch_job_number || ',' || system_id || ' is not an active job.') ;
			  end if ;
		   else
		   	  RAISE_APPLICATION_ERROR(-20160,'Job ' || batch_job_number || ',' || system_id || ' is not a valid job.') ;
		   end if ;
	  end if ;

  end validateActiveJob ;

  procedure start_job(system_id in amd_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP, description in amd_batch_jobs.description%type := null) is  			job_number NUMBER ;
  BEGIN
  	   SELECT MAX(batch_job_number) INTO job_number
	   FROM AMD_BATCH_JOBS
	   WHERE start_time IS NOT NULL
	   AND (end_time IS NOT NULL or job_aborted is not null)
	   and system_id = start_job.system_id ;
	   IF job_number IS NULL THEN
	   	  job_number := 0 ;
	   ELSE
	   	   job_number := job_number + 1 ;
	   END IF ;
	   INSERT INTO AMD_BATCH_JOBS
	   (batch_job_number, system_id, description, start_time)
	   VALUES (job_number, start_job.system_id, start_job.description, SYSDATE) ;

       commit ;

  EXCEPTION
  		   WHEN standard.DUP_VAL_ON_INDEX THEN
		   	 RAISE_APPLICATION_ERROR(-20170,'Job ' || job_number || ',' || system_id || ' must be ended before another job can start') ;
  END start_job ;

  procedure abort_job(batch_job_number in amd_batch_jobs.batch_job_number%type := null, system_id in amd_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) is
  			theJob amd_batch_jobs.BATCH_JOB_NUMBER%type := abort_job.batch_job_number ;
  begin
  	   validateActiveJob(theJob, system_id) ;

	   <<abortActiveStep>>
	   begin
	   		abort_step(theJob, system_id) ;
	   exception when standard.no_data_found then
	   			 null ; -- no steps for job
	   end abortActiveStep ;

	   -- can only abort an active job
	   update amd_batch_jobs
	   set end_time = sysdate,
	   job_aborted = 'Y'
	   where batch_job_number = theJob
	   and system_id = abort_job.system_id
	   and start_time is not null
	   and end_time is null
	   and job_aborted is null ;

       commit ;

  exception
  			when others then
			  	 ErrorMsg(pSqlfunction => 'update',
						pTableName => 'amd_batch_jobs',
						pError_location => 10,
						pKey_1 => to_char(theJob),
						pKey_2 => system_id ) ;
				 raise ;
  end abort_job ;

  function isJob(batch_job_number in amd_batch_jobs.BATCH_JOB_NUMBER%type,
  			system_id in amd_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) return boolean is
			theJob amd_batch_jobs.BATCH_JOB_NUMBER%type ;
  begin
  	   select batch_job_number into theJob
	   from amd_batch_jobs
	   where batch_job_number = isJob.batch_job_number
	   and system_id = isJob.system_id ;

	   return true ;

  exception
  	   when standard.no_data_found then
	   		return false ;
	   when others then
	  	 ErrorMsg(pSqlfunction => 'select',
				pTableName => 'amd_batch_jobs',
				pError_location => 20,
				pKey_1 => to_char(batch_job_number),
				pKey_2 => system_id ) ;
		 raise ;
  end isJob ;

  function hasActiveSteps(batch_job_number in amd_batch_jobs.BATCH_JOB_NUMBER%type,
	   		system_id in amd_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) return boolean is

			theJob amd_batch_jobs.BATCH_JOB_NUMBER%type := hasActiveSteps.batch_job_number ;
			numberOfSteps number := 0 ;

  begin
  	   validateActiveJob(theJob, system_id) ;

	   SELECT COUNT(*) INTO numberOfSteps
	   FROM AMD_BATCH_JOB_STEPS
	   WHERE batch_job_number = theJob
	   and system_id = hasActiveSteps.system_id
	   and start_time is not null
	   AND end_time IS NULL
	   and step_aborted is null ;

	   return numberOfSteps > 0 ;

  exception
  		   when standard.no_data_found then
		   		return false ;
		   when others then
		  	 ErrorMsg(pSqlfunction => 'select',
					pTableName => 'amd_batch_job_steps',
					pError_location => 30,
					pKey_1 => to_char(theJob),
					pKey_2 => system_id ) ;
			 raise ;
  end hasActiveSteps ;

  function isJobActive(batch_job_number in amd_batch_jobs.batch_job_number%type := null,
  		   system_id in amd_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) return boolean is
  begin
  	   return not isJobComplete(batch_job_number, system_id) ;
  end isJobActive ;

  function getLastCompleteJob(system_id in amd_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) return amd_batch_jobs.batch_job_number%type is
  		   theJob amd_batch_jobs.batch_job_number%type ;
  begin
  	   select max(batch_job_number) into theJob
	   from amd_batch_jobs
	   where system_id = getLastCompleteJob.system_id
	   and start_time is not null
	   and end_time is not null
	   and job_aborted is null ;
	   return theJob ;
  exception
  			when standard.no_data_found then
				 return null ;
			when others then
			  	 ErrorMsg(pSqlfunction => 'select',
						pTableName => 'amd_batch_jobs',
						pError_location => 40,
						pKey_1 => system_id) ;
				 raise ;
  end getLastCompleteJob ;

  function getActiveJob(system_id in amd_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) return amd_batch_jobs.batch_job_number%type is
  		   theJob amd_batch_jobs.BATCH_JOB_NUMBER%type ;
  begin
  	   -- any system is allowed only one active job
  	   select max(batch_job_number) into theJob
	   from   amd_batch_jobs
	   where  system_id = getActiveJob.system_id
	   and start_time is not null
	   and end_time is null
	   and job_aborted is null ;

	   return theJob ;
  exception
     when standard.no_data_found then
	 	  return null ; -- no job active
     when others then
	  	 ErrorMsg(pSqlfunction => 'select',
				pTableName => 'amd_batch_jobs',
				pError_location => 50,
				pKey_1 => system_id ) ;
		 raise ;
  end getActiveJob ;

  procedure end_job(batch_job_number in amd_batch_jobs.batch_job_number%type := null, system_id in amd_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) is
  			theJob amd_batch_jobs.BATCH_JOB_NUMBER%type := end_job.batch_job_number ;
			active_steps NUMBER ;
  BEGIN
  	   validateActiveJob(theJob, system_id) ;

	   IF hasActiveSteps(theJob, system_id) then
	   	   end_step(theJob, system_id) ;
	   end if ;

	   UPDATE AMD_BATCH_JOBS
	   SET end_time = SYSDATE
	   WHERE batch_job_number = theJob
	   and system_id = end_job.system_id
	   and start_time is not null
	   and end_time is null
	   and job_aborted is null ;

       commit ;

  exception
  	when others then
	  	 ErrorMsg(pSqlfunction => 'update',
				pTableName => 'amd_batch_jobs',
				pError_location => 60,
				pKey_1 => to_char(theJob),
				pKey_2 => system_id ) ;
		 raise ;
  END end_job ;

  -- if there is no job in the system it will return a null value
  function getLastStartTime(batch_job_number in amd_batch_jobs.batch_job_number%type := null, system_id in amd_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP)
	   			return amd_batch_jobs.START_TIME%type is

				theJob amd_batch_jobs.BATCH_JOB_NUMBER%type := getLastStartTime.batch_job_number ;
				theTime amd_batch_jobs.START_TIME%type := null ;
  begin
  	   validateJob(theJob, system_id) ;
	   if theJob is not null then
	  	   select start_time into theTime
		   from amd_batch_jobs
		   where batch_job_number = theJob
		   and system_id = getLastStartTime.system_id
		   and start_time is not null
		   and job_aborted is  null ;
	   end if ;
	   return theTime ;
  exception
  			when standard.NO_DATA_FOUND then
				 return null ;
			when others then
			  	 ErrorMsg(pSqlfunction => 'select',
						pTableName => 'amd_batch_jobs',
						pError_location => 70,
						pKey_1 => to_char(theJob),
						pKey_2 => system_id ) ;
				 raise ;
  end getLastStartTime ;

  function getLastEndTime(batch_job_number in amd_batch_jobs.batch_job_number%type := null,system_id in amd_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP)
  			return amd_batch_jobs.END_TIME%type is
  			theJob amd_batch_jobs.BATCH_JOB_NUMBER%type := getLastEndTime.batch_job_number ;
			theTime amd_batch_jobs.END_TIME%type ;
  begin
  	   validateJob(theJob, system_id) ;

  	   select end_time into theTime
	   from amd_batch_jobs
	   where batch_job_number = theJob
	   and system_id = getLastEndTime.system_id
	   and start_time is not null
	   and end_time is not null
	   and job_aborted is null ;

	   return theTime ;

  exception
  			when standard.NO_DATA_FOUND then
				 return null ;
			when others then
			  	 ErrorMsg(pSqlfunction => 'select',
						pTableName => 'amd_batch_jobs',
						pError_location => 80,
						pKey_1 => to_char(theJob),
						pKey_2 => system_id ) ;
				 raise ;
  end getLastEndTime ;

  function isJobComplete(batch_job_number in amd_batch_jobs.BATCH_JOB_NUMBER%type := null,
	   			system_id in amd_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) return boolean is
		   theJob amd_batch_jobs.BATCH_JOB_NUMBER%type := isJobComplete.batch_job_number ;
  		   isComplete boolean := false ;
		   completeJob amd_batch_jobs.BATCH_JOB_NUMBER%type ;
  begin
       validateJob(theJob, system_id) ;

	   if theJob is null then
	   	  return true ;
	   else
	   	   if isJob(batch_job_number => theJob, system_id => system_id) then
		 	   select batch_job_number into completeJob
			   from amd_batch_jobs
			   where batch_job_number = theJob
			   and system_id = isJobComplete.system_id
			   and start_time is not null
			   and end_time is not null
			   and job_aborted is null ;
		   else
		   	  return true ;
		   end if ;
	  end if ;

	  return true ;

  exception
  		   when standard.no_data_found then
		   		return false ;
		   when others then
		  	 ErrorMsg(pSqlfunction => 'select',
					pTableName => 'amd_batch_jobs',
					pError_location => 90,
					pKey_1 => to_char(theJob),
					pKey_2 => system_id ) ;
			 raise ;
  end isJobComplete ;

  function didStepStart(batch_job_number in amd_batch_job_steps.BATCH_JOB_NUMBER%type := null,
  		 system_id in amd_batch_job_steps.SYSTEM_ID%type := ASSET_MANAGEMENT_DESKTOP,
		 batch_step_number in amd_batch_job_steps.BATCH_STEP_NUMBER%type := null,
		 description in amd_batch_job_steps.DESCRIPTION%type := null,
		 package_name in amd_batch_job_steps.PACKAGE_NAME%type := null,
		 procedure_name in amd_batch_job_steps.PROCEDURE_NAME%type := null,
		 function_name in amd_batch_job_steps.FUNCTION_NAME%type := null) return boolean is

		 theJob amd_batch_job_steps.BATCH_JOB_NUMBER%type := didStepStart.batch_job_number ;
		 theStep amd_batch_job_steps.BATCH_STEP_NUMBER%type := didStepStart.batch_step_number ;
  begin
  	   validateActiveJob(theJob, system_id) ;

  	   if description is not null then
	      -- only start the step if it has not yet completed
	   	  if isStepComplete(theJob, system_id, description) then
		  	 return false ;
		  else
		  	 start_step(batch_job_number => batch_job_number, system_id => system_id,
			   batch_step_number => batch_step_number, description => description,
			   package_name => package_name, procedure_name => procedure_name,
			   function_name => function_name) ;
		  end if ;
	   else
	  	 start_step(batch_job_number => batch_job_number, system_id => system_id,
		   batch_step_number => batch_step_number,
		   package_name => package_name, procedure_name => procedure_name,
		   function_name => function_name) ;
	   end if ;
  	   return true ;
  end didStepStart ;

  procedure start_step(batch_job_number in amd_batch_job_steps.BATCH_JOB_NUMBER%type := null,
  		 system_id in amd_batch_job_steps.SYSTEM_ID%type := ASSET_MANAGEMENT_DESKTOP,
		 batch_step_number in amd_batch_job_steps.BATCH_STEP_NUMBER%type := null,
		 description in amd_batch_job_steps.DESCRIPTION%type := null,
		 package_name in amd_batch_job_steps.PACKAGE_NAME%type := null,
		 procedure_name in amd_batch_job_steps.PROCEDURE_NAME%type := null,
		 function_name in amd_batch_job_steps.FUNCTION_NAME%type := null) is

		 theJob amd_batch_job_steps.BATCH_JOB_NUMBER%type := start_step.batch_job_number ;
		 theStep amd_batch_job_steps.BATCH_STEP_NUMBER%type := start_step.batch_step_number ;
  begin
  	  validateActiveJob(theJob, system_id) ;

	  if theStep is null then
		  <<getNextStep>>
		 begin
		 	 theStep := getActiveStep(theJob, system_id) ;
			 -- there was an activeStep that did not complete
			 -- show that it was aborted
			 if theStep is not null then
			 	abort_step(theJob, system_id, theStep) ;
			 end if ;

		  	 select nvl(max(batch_step_number),0) into theStep
			 from amd_batch_job_steps
			 where batch_job_number = theJob
			 and system_id = start_step.system_id
			 and start_time is not null
			 and end_time is not null
			 and step_aborted is null ;

			 theStep := theStep + 1 ;
	     exception
		 		  when standard.no_data_found then
				  	   theStep := 1 ;
				  when others then
				  	 ErrorMsg(pSqlfunction => 'select',
							pTableName => 'amd_batch_job_steps',
							pError_location => 100,
							pKey_1 => to_char(theJob),
							pKey_2 => system_id,
							pKey_3 => to_char(theStep) ) ;
					 raise ;
   		 end getNextStep ;
	  end if ;

  	   insert into amd_batch_job_steps
	   (batch_job_number, system_id, batch_step_number, description, package_name, procedure_name, function_name, start_time)
	   values (theJob, start_step.system_id, theStep, start_step.description, start_step.package_name, start_step.procedure_name, start_step.function_name, sysdate) ;

       commit ;

  exception
  		   when standard.DUP_VAL_ON_INDEX then
			  	 ErrorMsg(pSqlfunction => 'insert',
						pTableName => 'amd_batch_job_steps',
						pError_location => 110,
						pKey_1 => to_char(theJob),
						pKey_2 => system_id,
						pKey_3 => to_char(theStep) ) ;
				raise ;
			when others then
			  	 ErrorMsg(pSqlfunction => 'insert',
						pTableName => 'amd_batch_jobs',
						pError_location => 120,
						pKey_1 => to_char(theJob),
						pKey_2 => system_id) ;
				raise ;
  end start_step ;

  procedure abort_step(batch_job_number in amd_batch_job_steps.batch_job_number%type := null,
  			 system_id in amd_batch_job_steps.system_id%type := ASSET_MANAGEMENT_DESKTOP,
		 batch_step_number in amd_batch_job_steps.batch_step_number%type := null) is
		 theJob amd_batch_job_steps.batch_job_number%type := abort_step.batch_job_number ;
		 theStep amd_batch_job_steps.batch_step_number%type := abort_step.batch_step_number ;
  begin
  	   validateActiveJob(theJob, system_id) ;

	   if theStep is null then
  	   	  theStep := getActiveStep(batch_job_number, system_id) ;
		  if theStep is null then
		  	 return ; -- no step active
		  end if ;
	   end if ;

	   update amd_batch_job_steps
	   set step_aborted = 'Y',
	   end_time = sysdate
	   where batch_job_number = theJob
	   and system_id = abort_step.system_id
	   and batch_step_number = theStep ;

       commit ;

  exception
  		   when others then
			  	 ErrorMsg(pSqlfunction => 'update',
						pTableName => 'amd_batch_job_steps',
						pError_location => 130,
						pKey_1 => to_char(theJob),
						pKey_2 => system_id,
						pKey_3 => to_char(theStep) ) ;
				raise ;
  end abort_step ;

  procedure end_step(batch_job_number in amd_batch_job_steps.BATCH_JOB_NUMBER%type := null,
		 	 system_id in amd_batch_job_steps.SYSTEM_ID%type := ASSET_MANAGEMENT_DESKTOP,
			 batch_step_number in amd_batch_job_steps.BATCH_STEP_NUMBER%type := null) is

		theJob amd_batch_job_steps.batch_job_number%type := end_step.batch_job_number ;
		theStep amd_batch_job_steps.BATCH_STEP_NUMBER%type := end_step.batch_step_number ;
  begin
  	   validateActiveJob(theJob, system_id) ;

  	   if theStep is null then
	   	  theStep := getActiveStep(theJob, system_id) ;
		  if theStep is null then
		  	 return ;
		  end if ;
	   end if;
  	   update amd_batch_job_steps
	   set end_time = sysdate
	   where batch_job_number = theJob
	   and system_id = end_step.system_id
	   and batch_step_number = theStep
	   and end_time is null ;

       commit ;
  exception
    when standard.no_data_found then
		 return ; -- no step to end
  	when others then
	  	 ErrorMsg(pSqlfunction => 'update',
				pTableName => 'amd_batch_job_steps',
				pError_location => 140,
				pKey_1 => batch_job_number,
				pKey_2 => system_id) ;
		 raise ;

  end end_step ;

  function getActiveStep(batch_job_number in amd_batch_job_steps.batch_job_number%type := null,
   			system_id in amd_batch_job_steps.system_id%type := ASSET_MANAGEMENT_DESKTOP) return amd_batch_job_steps.BATCH_STEP_NUMBER%type is

			theJob amd_batch_job_steps.batch_job_number%type := getActiveStep.batch_job_number ;
			theStep amd_batch_job_steps.BATCH_STEP_NUMBER%type ;
  begin
  	   validateActiveJob(theJob, system_id) ;

	   select batch_step_number into theStep
	   from amd_batch_job_steps
	   where batch_job_number = theJob
	   and system_id = getActiveStep.system_id
	   and start_time is not null
	   and end_time is null
	   and step_aborted is null ;

  	   return theStep ;

  exception
  		   when standard.no_data_found then
		   		return null ;
		   when others then
		  	 ErrorMsg(pSqlfunction => 'select',
					pTableName => 'amd_batch_job_steps',
					pError_location => 150,
					pKey_1 => to_char(theJob),
					pKey_2 => system_id,
					pKey_3 => to_char(theStep)) ;
			 raise ;
  end getActiveStep ;

  function isStepComplete(batch_job_number in amd_batch_job_steps.batch_job_number%type,
  		   system_id in amd_batch_job_steps.system_id%type := ASSET_MANAGEMENT_DESKTOP,
		   batch_step_number in amd_batch_job_steps.BATCH_STEP_NUMBER%type) return boolean is

			theStep amd_batch_job_steps.batch_step_number%type ;
  begin
  	   select batch_step_number into theStep
	   from amd_batch_job_steps
	   where batch_job_number = isStepComplete.batch_job_number
	   and system_id = isStepComplete.system_id
	   and batch_step_number = isStepComplete.batch_step_number
	   and start_time is not null
	   and end_time is not null
	   and step_aborted is null ;
	   return true ;
  exception
	   when no_data_found then
	   		return false ;
	   when others then
	  	 ErrorMsg(pSqlfunction => 'select',
				pTableName => 'amd_batch_job_steps',
				pError_location => 160,
				pKey_1 => to_char(batch_job_number),
				pKey_2 => system_id,
				pKey_3 => to_char(batch_step_number)) ;
		 raise ;
  end isStepComplete ;

  function isStepComplete(batch_job_number in amd_batch_job_steps.batch_job_number%type,
  		   system_id in amd_batch_job_steps.system_id%type := ASSET_MANAGEMENT_DESKTOP,
		   description in amd_batch_job_steps.description%type) return boolean is

	   theJob amd_batch_job_steps.BATCH_JOB_NUMBER%type := isStepComplete.batch_job_number ;

	   cursor completedSteps  is
		   select batch_step_number
		   from amd_batch_job_steps
		   where batch_job_number = theJob
		   and system_id = isStepComplete.system_id
		   and description = isStepComplete.description
		   and start_time is not null
		   and end_time is not null
		   and step_aborted is null ;


  begin
  	   if theJob is null then
	   	  -- assumption - there is an active job running
	   	  validateActiveJob(theJob, system_id) ;
	   end if ;

	   -- assumption - description is unique per each step
	   -- step may have been run more than once
	   for rec in completedSteps loop
	   	   return true ;
	   end loop ;
	   return false ;
  exception
	   when others then
	  	 ErrorMsg(pSqlfunction => 'select',
				pTableName => 'amd_batch_job_steps',
				pError_location => 170,
				pKey_1 => to_char(batch_job_number),
				pKey_2 => system_id,
				pKey_3 => description) ;
		 raise ;
  end isStepComplete ;

  function getLastCompleteStep(batch_job_number in amd_batch_job_steps.batch_job_number%type := null,
  			system_id in amd_batch_job_steps.system_id%type := ASSET_MANAGEMENT_DESKTOP) return amd_batch_job_steps.batch_step_number%type is

			theJob amd_batch_job_steps.batch_job_number%type := getLastCompleteStep.batch_job_number ;
			theStep amd_batch_job_steps.batch_step_number%type ;
  begin
  	   validateJob(theJob, system_id) ;

  	   select max(batch_step_number) into theStep
	   from amd_batch_job_steps
	   where batch_job_number = theJob
	   and system_id = getLastCompleteStep.system_id
	   and start_time is not null
	   and end_time is not null
	   and step_aborted is null ;
  exception
  		   when standard.no_data_found then
		   		return null ;
		   when others then
		  	 ErrorMsg(pSqlfunction => 'select',
					pTableName => 'amd_batch_job_steps',
					pError_location => 180,
					pKey_1 => to_char(theJob),
					pKey_2 => system_id) ;
			 raise ;
  end getLastCompleteStep ;

  function getLastStepStartTime(batch_job_number in amd_batch_job_steps.batch_job_number%type := null,
  			system_id in amd_batch_job_steps.system_id%type := ASSET_MANAGEMENT_DESKTOP) return amd_batch_job_steps.start_time%type is

		theJob amd_batch_job_steps.batch_job_number%type := getLastStepStartTime.batch_job_number ;
		theStep amd_batch_job_steps.batch_step_number%type  ;
		theTime amd_batch_job_steps.START_TIME%type ;
  begin
  	   validateJob(theJob, system_id) ;

	   theStep := getActiveStep(theJob, system_id) ;
	   if theStep is null then
	   	  theStep := getLastCompleteStep(theJob, system_id) ;
		  if theStep is null then
		  	 return null ;
		  end if ;
	   end if ;

  	   select start_time into theTime
	   from amd_batch_job_steps
	   where batch_job_number = theJob
	   and system_id = getLastStepStartTime.system_id
	   and batch_step_number = theStep
	   and start_time is not null
	   and step_aborted is null ;
	   return theTime ;
  exception
  		   when standard.no_data_found then
		   		return null ;
		   when others then
		  	 ErrorMsg(pSqlfunction => 'select',
					pTableName => 'amd_batch_job_steps',
					pError_location => 190,
					pKey_1 => to_char(theJob),
					pKey_2 => system_id,
					pKey_3 => to_char(theStep) ) ;
			 raise ;
  end getLastStepStartTime ;

  function getLastStepEndTime(batch_job_number in amd_batch_job_steps.batch_job_number%type := null,
   			system_id in amd_batch_job_steps.system_id%type := ASSET_MANAGEMENT_DESKTOP) return amd_batch_job_steps.start_time%type is

			theJob amd_batch_job_steps.batch_job_number%type := getLastStepEndTime.batch_job_number ;
			theStep amd_batch_job_steps.BATCH_STEP_NUMBER%type ;
			theTime amd_batch_job_steps.END_TIME%type ;
  begin
  	  validateJob(theJob, system_id) ;

	  theStep := getActiveStep(theJob, system_id) ;
	  if theStep is null then
	  	 theStep := getLastCompleteStep(theJob, system_id) ;
		 if theStep is null then
		 	return null ; -- no steps for this job!
		 end if ;
	 end if ;
	 select end_time into theTime
	 from amd_batch_job_steps
	 where batch_job_number = theJob
	 and system_id = getLastStepEndTime.system_id
	 and batch_step_number = theStep
	 and start_time is not null
	 and end_time is not null
	 and step_aborted is null ;
	 return theTime ;
  exception
  		   when standard.no_data_found then
		   		return null ;
		   when others then
		  	 ErrorMsg(pSqlfunction => 'select',
					pTableName => 'amd_batch_job_steps',
					pError_location => 200,
					pKey_1 => to_char(theJob),
					pKey_2 => system_id,
					pKey_3 => to_char(theStep) ) ;
			 raise ;
  end getLastStepEndTime ;

  procedure deleteJob(batch_job_number in amd_batch_jobs.batch_job_number%type := null,
  			 system_id in amd_batch_jobs.SYSTEM_ID%type := ASSET_MANAGEMENT_DESKTOP) is

		theJob amd_batch_jobs.BATCH_JOB_NUMBER%type := deleteJob.batch_job_number ;
  begin
  	   validateJob(theJob, system_id) ;

	  <<deleteSteps>>
	  begin
		  delete from amd_batch_job_steps
		  where batch_job_number = theJob
		  and system_id = deleteJob.system_id ;
	  exception
	  		   when standard.no_data_found then
			   		return ;
			   when others then
			  	 ErrorMsg(pSqlfunction => 'delete',
						pTableName => 'amd_batch_job_steps',
						pError_location => 210,
						pKey_1 => to_char(theJob),
						pKey_2 => system_id ) ;
				 raise ;
	  end deleteSteps ;

	  delete from  amd_batch_jobs
	  where batch_job_number = theJob
	  and system_id = deleteJob.system_id ;
  exception
			   when others then
			  	 ErrorMsg(pSqlfunction => 'delete',
						pTableName => 'amd_batch_jobs',
						pError_location => 220,
						pKey_1 => to_char(theJob),
						pKey_2 => system_id ) ;
				 raise ;
  end deleteJob ;

  procedure truncateIfOld(tablename in varchar2, system_id in amd_batch_jobs.SYSTEM_ID%type := ASSET_MANAGEMENT_DESKTOP) is
  			type cv_type is ref cursor ;
			cv cv_type ;
			maxDate date ;
  begin
  	   if getActiveJob(system_id) is null then
	   	  	 Mta_Truncate_Table(tablename,'reuse storage');
	   else
	   	   open cv for
		   		'select max(last_update_dt) from ' || tablename ;
		   fetch cv into maxDate ;
		   if maxDate is null or getLastStartTime(system_id => system_id) > maxDate then
		   	  Mta_Truncate_Table(tablename,'reuse storage');
		   end if ;
		   close cv ;
	   end if ;
  exception
			   when others then
			  	 ErrorMsg(pSqlfunction => 'fetch',
						pTableName => tablename,
						pError_location => 230,
						pKey_1 => system_id ) ;
				 raise ;
  end truncateIfOld ;

  procedure version is
  begin
		 amd_utils.writeMsg(pSourceName => 'amd_batch_pkg', pTableName => 'amd_batch_pkg',
		 		pError_location => 240, pKey1 => 'amd_batch_pkg', pKey2 => '$Revision:   1.14  $') ;
  end version ;

END Amd_Batch_Pkg;

/


DROP PUBLIC SYNONYM AMD_BATCH_PKG;

CREATE PUBLIC SYNONYM AMD_BATCH_PKG FOR AMD_OWNER.AMD_BATCH_PKG;


GRANT EXECUTE ON AMD_OWNER.AMD_BATCH_PKG TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.AMD_BATCH_PKG TO AMD_WRITER_ROLE;
