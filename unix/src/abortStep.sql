/*
      $Author$
    $Revision$
        $Date$
    $Workfile$
         $Log$
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set echo off
set time on
set timing on
set linesize 133
set show off
set verify off


variable ret_val number

declare
	cursor theSteps(theJob in number, theSystemId varchar2, theDescription varchar2) is
	select batch_step_number from amd_batch_job_steps
	where batch_job_number = theJob
	and system_id = theSystemId
	and description = theDescription
	and start_time is not null
	and step_aborted is null ;	
	procedure abortStep(theStepName in varchar2,
		theJob amd_batch_job_steps.batch_job_number%type := amd_batch_pkg.getActiveJob,
       		theSystemId amd_batch_job_steps.system_id%type := amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP) is
		theStepNumber number ;
	begin
		if theJob is not null then
			open theSteps(theJob, theSystemId, theStepName) ;
			fetch theSteps into theStepNumber ;
			if theSteps%NOTFOUND then
				:ret_val := 4 ;
			else
				amd_batch_pkg.abort_step(TheJob, theSystemId, theStepNumber) ;
				:ret_val := 0 ;
			end if ;
			close theSteps ;
		else
			dbms_output.put_line('There is no active job.  The end step was not logged') ;
			:ret_val := 8 ;
		end if ;
	end abortStep ;
begin
	abortStep('&1') ;
end ;
/


exit :ret_val
