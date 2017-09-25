CREATE OR REPLACE PACKAGE amd_batch_pkg AS
	/*7
      $Author:   zf297a  $
    $Revision:   1.5  $
	    $Date:   Jun 09 2006 11:34:36  $
    $Workfile:   AMD_BATCH_PKG.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\AMD_BATCH_PKG.pks.-arc  $
/*   
/*      Rev 1.5   Jun 09 2006 11:34:36   zf297a
/*   added interface version
/*   
/*      Rev 1.4   Mar 23 2006 08:19:14   zf297a
/*   Added procedure truncateIfOld
/*   
/*      Rev 1.3   Mar 19 2006 01:48:46   zf297a
/*   Added interface for isStepComplete function
/*   
/*      Rev 1.2   Mar 16 2006 14:24:42   zf297a
/*   Added step procedures and functions
/*   
/*      Rev 1.1   Mar 03 2006 12:32:56   zf297a
/*   Added three functions:
/*   getLastStartTime
/*   getLastEndTime
/*   isJobComplete.
/*   
/*      Rev 1.0   Nov 22 2005 08:02:18   zf297a
/*   Initial revision.
*/
  	   ASSET_MANAGEMENT_DESKTOP constant varchar2(3) := 'AMD' ;
	   
	   procedure start_job(system_id in amd_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP, description in amd_batch_jobs.description%type := null) ;
	   procedure abort_job(batch_job_number in amd_batch_jobs.batch_job_number%type := null, system_id in amd_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) ;
	   procedure end_job(batch_job_number in amd_batch_jobs.batch_job_number%type := null, system_id in amd_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) ;
	   function getActiveJob(system_id in amd_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) return amd_batch_jobs.batch_job_number%type ;
  	   function isJobActive(batch_job_number in amd_batch_jobs.batch_job_number%type := null,
  		   system_id in amd_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) return boolean ;
	   function getLastCompleteJob(system_id in amd_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) return amd_batch_jobs.batch_job_number%type ;
	   function getLastStartTime(batch_job_number in amd_batch_jobs.batch_job_number%type := null, system_id in amd_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP)  
	   			return amd_batch_jobs.START_TIME%type ;
				
  	   function getLastEndTime(batch_job_number in amd_batch_jobs.batch_job_number%type := null,system_id in amd_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) 
	   			return amd_batch_jobs.END_TIME%type ;
				
  	   function isJobComplete(batch_job_number in amd_batch_jobs.BATCH_JOB_NUMBER%type := null, 
	   			system_id in amd_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) return boolean ;
  	   function isJob(batch_job_number in amd_batch_jobs.BATCH_JOB_NUMBER%type, 
	   			system_id in amd_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) return boolean ;
	   
	   procedure start_step(batch_job_number in amd_batch_job_steps.BATCH_JOB_NUMBER%type := null, 
	   			 system_id in amd_batch_job_steps.SYSTEM_ID%type := ASSET_MANAGEMENT_DESKTOP,
				 batch_step_number in amd_batch_job_steps.BATCH_STEP_NUMBER%type := null, 
				 description in amd_batch_job_steps.DESCRIPTION%type := null, 
				 package_name in amd_batch_job_steps.PACKAGE_NAME%type := null, 
				 procedure_name in amd_batch_job_steps.PROCEDURE_NAME%type := null,
				 function_name in amd_batch_job_steps.FUNCTION_NAME%type := null) ;
				 
	   procedure abort_step(batch_job_number in amd_batch_job_steps.batch_job_number%type := null,
	   			 system_id in amd_batch_job_steps.system_id%type := ASSET_MANAGEMENT_DESKTOP,
				 batch_step_number in amd_batch_job_steps.batch_step_number%type := null) ;
				 
				 
	   procedure end_step(batch_job_number in amd_batch_job_steps.BATCH_JOB_NUMBER%type := null, 
				 system_id in amd_batch_job_steps.SYSTEM_ID%type := ASSET_MANAGEMENT_DESKTOP,
	 			 batch_step_number in amd_batch_job_steps.BATCH_STEP_NUMBER%type := null) ;
				 
	
	   function getActiveStep(batch_job_number in amd_batch_job_steps.batch_job_number%type := null,
	   			system_id in amd_batch_job_steps.system_id%type := ASSET_MANAGEMENT_DESKTOP) return amd_batch_job_steps.BATCH_STEP_NUMBER%type ;
	   function getLastCompleteStep(batch_job_number in amd_batch_job_steps.batch_job_number%type := null,
	   			system_id in amd_batch_job_steps.system_id%type := ASSET_MANAGEMENT_DESKTOP) return amd_batch_job_steps.batch_step_number%type ;
	   function getLastStepStartTime(batch_job_number in amd_batch_job_steps.batch_job_number%type := null,
	   			system_id in amd_batch_job_steps.system_id%type := ASSET_MANAGEMENT_DESKTOP) return amd_batch_job_steps.start_time%type ;
	   function getLastStepEndTime(batch_job_number in amd_batch_job_steps.batch_job_number%type := null,
	   			system_id in amd_batch_job_steps.system_id%type := ASSET_MANAGEMENT_DESKTOP) return amd_batch_job_steps.start_time%type;
	   procedure deleteJob(batch_job_number in amd_batch_jobs.batch_job_number%type := null,
	   			 system_id in amd_batch_jobs.SYSTEM_ID%type := ASSET_MANAGEMENT_DESKTOP) ;    
  	   function isStepComplete(batch_job_number in amd_batch_job_steps.batch_job_number%type,
  		   system_id in amd_batch_job_steps.system_id%type := ASSET_MANAGEMENT_DESKTOP,
		   batch_step_number in amd_batch_job_steps.BATCH_STEP_NUMBER%type) return boolean ;
       function isStepComplete(batch_job_number in amd_batch_job_steps.batch_job_number%type := null,
  		   system_id in amd_batch_job_steps.system_id%type := ASSET_MANAGEMENT_DESKTOP,
		   description in amd_batch_job_steps.description%type) return boolean ;
		   
  	   function didStepStart(batch_job_number in amd_batch_job_steps.BATCH_JOB_NUMBER%type := null, 
  		 system_id in amd_batch_job_steps.SYSTEM_ID%type := ASSET_MANAGEMENT_DESKTOP,
		 batch_step_number in amd_batch_job_steps.BATCH_STEP_NUMBER%type := null, 
		 description in amd_batch_job_steps.DESCRIPTION%type := null, 
		 package_name in amd_batch_job_steps.PACKAGE_NAME%type := null, 
		 procedure_name in amd_batch_job_steps.PROCEDURE_NAME%type := null,
		 function_name in amd_batch_job_steps.FUNCTION_NAME%type := null) return boolean ;
		 
  	  procedure truncateIfOld(tablename in varchar2, system_id in amd_batch_jobs.SYSTEM_ID%type := ASSET_MANAGEMENT_DESKTOP) ;
	  
	  -- added 6/9/2006 by DSE
	  procedure version ;
	  
END amd_batch_pkg;
/
