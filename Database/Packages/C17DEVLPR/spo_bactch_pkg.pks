CREATE OR REPLACE PACKAGE C17DEVLPR.spo_batch_pkg AS
    /*7
      $Author:   c970984  $
    $Revision:   1.1  $
        $Date:   Dec 11 2007 16:46:38  $
    $Workfile:   spo_bactch_pkg.pks  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Packages\C17DEVLPR\spo_bactch_pkg.pks.-arc  $
/*   
/*      Rev 1.1   Dec 11 2007 16:46:38   c970984
/*   12/07
/*   
/*      Rev 1.0   Oct 02 2007 11:14:30   c970984
/*   Initial revision.

/*   Initial revision. Copied from AMD_OWNER.amd_batch_pkg
*/
         ASSET_MANAGEMENT_DESKTOP constant varchar2(3) := 'SPO' ;
       
       procedure start_job(system_id in spo_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP, description in spo_batch_jobs.description%type := null) ;
       procedure abort_job(batch_job_number in spo_batch_jobs.batch_job_number%type := null, system_id in spo_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) ;
       procedure end_job(batch_job_number in spo_batch_jobs.batch_job_number%type := null, system_id in spo_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) ;
       function getActiveJob(system_id in spo_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) return spo_batch_jobs.batch_job_number%type ;
         function isJobActive(batch_job_number in spo_batch_jobs.batch_job_number%type := null,
             system_id in spo_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) return boolean ;
       function getLastCompleteJob(system_id in spo_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) return spo_batch_jobs.batch_job_number%type ;
       function getLastStartTime(batch_job_number in spo_batch_jobs.batch_job_number%type := null, system_id in spo_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP)  
                   return spo_batch_jobs.START_TIME%type ;
                
         function getLastEndTime(batch_job_number in spo_batch_jobs.batch_job_number%type := null,system_id in spo_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) 
                   return spo_batch_jobs.END_TIME%type ;
                
         function isJobComplete(batch_job_number in spo_batch_jobs.BATCH_JOB_NUMBER%type := null, 
                   system_id in spo_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) return boolean ;
         function isJob(batch_job_number in spo_batch_jobs.BATCH_JOB_NUMBER%type, 
                   system_id in spo_batch_jobs.system_id%type := ASSET_MANAGEMENT_DESKTOP) return boolean ;
       
       procedure start_step(batch_job_number in spo_batch_job_steps.BATCH_JOB_NUMBER%type := null, 
                    system_id in spo_batch_job_steps.SYSTEM_ID%type := ASSET_MANAGEMENT_DESKTOP,
                 batch_step_number in spo_batch_job_steps.BATCH_STEP_NUMBER%type := null, 
                 description in spo_batch_job_steps.DESCRIPTION%type := null, 
                 package_name in spo_batch_job_steps.PACKAGE_NAME%type := null, 
                 procedure_name in spo_batch_job_steps.PROCEDURE_NAME%type := null,
                 function_name in spo_batch_job_steps.FUNCTION_NAME%type := null) ;
                 
       procedure abort_step(batch_job_number in spo_batch_job_steps.batch_job_number%type := null,
                    system_id in spo_batch_job_steps.system_id%type := ASSET_MANAGEMENT_DESKTOP,
                 batch_step_number in spo_batch_job_steps.batch_step_number%type := null) ;
                 
                 
       procedure end_step(batch_job_number in spo_batch_job_steps.BATCH_JOB_NUMBER%type := null, 
                 system_id in spo_batch_job_steps.SYSTEM_ID%type := ASSET_MANAGEMENT_DESKTOP,
                  batch_step_number in spo_batch_job_steps.BATCH_STEP_NUMBER%type := null) ;
                 
    
       function getActiveStep(batch_job_number in spo_batch_job_steps.batch_job_number%type := null,
                   system_id in spo_batch_job_steps.system_id%type := ASSET_MANAGEMENT_DESKTOP) return spo_batch_job_steps.BATCH_STEP_NUMBER%type ;
       function getLastCompleteStep(batch_job_number in spo_batch_job_steps.batch_job_number%type := null,
                   system_id in spo_batch_job_steps.system_id%type := ASSET_MANAGEMENT_DESKTOP) return spo_batch_job_steps.batch_step_number%type ;
       function getLastStepStartTime(batch_job_number in spo_batch_job_steps.batch_job_number%type := null,
                   system_id in spo_batch_job_steps.system_id%type := ASSET_MANAGEMENT_DESKTOP) return spo_batch_job_steps.start_time%type ;
       function getLastStepEndTime(batch_job_number in spo_batch_job_steps.batch_job_number%type := null,
                   system_id in spo_batch_job_steps.system_id%type := ASSET_MANAGEMENT_DESKTOP) return spo_batch_job_steps.start_time%type;
       procedure deleteJob(batch_job_number in spo_batch_jobs.batch_job_number%type := null,
                    system_id in spo_batch_jobs.SYSTEM_ID%type := ASSET_MANAGEMENT_DESKTOP) ;    
         function isStepComplete(batch_job_number in spo_batch_job_steps.batch_job_number%type,
             system_id in spo_batch_job_steps.system_id%type := ASSET_MANAGEMENT_DESKTOP,
           batch_step_number in spo_batch_job_steps.BATCH_STEP_NUMBER%type) return boolean ;
       function isStepComplete(batch_job_number in spo_batch_job_steps.batch_job_number%type := null,
             system_id in spo_batch_job_steps.system_id%type := ASSET_MANAGEMENT_DESKTOP,
           description in spo_batch_job_steps.description%type) return boolean ;
           
         function didStepStart(batch_job_number in spo_batch_job_steps.BATCH_JOB_NUMBER%type := null, 
           system_id in spo_batch_job_steps.SYSTEM_ID%type := ASSET_MANAGEMENT_DESKTOP,
         batch_step_number in spo_batch_job_steps.BATCH_STEP_NUMBER%type := null, 
         description in spo_batch_job_steps.DESCRIPTION%type := null, 
         package_name in spo_batch_job_steps.PACKAGE_NAME%type := null, 
         procedure_name in spo_batch_job_steps.PROCEDURE_NAME%type := null,
         function_name in spo_batch_job_steps.FUNCTION_NAME%type := null) return boolean ;
         
        procedure truncateIfOld(tablename in varchar2, system_id in spo_batch_jobs.SYSTEM_ID%type := ASSET_MANAGEMENT_DESKTOP) ;
      
      -- added 6/9/2006 by DSE
      procedure version ;
      
END spo_batch_pkg;
/