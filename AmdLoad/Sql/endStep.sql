/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   27 Aug 2009 16:08:56  $
    $Workfile:   endStep.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\AmdLoad\Sql\endStep.sql.-arc  $
/*   
/*      Rev 1.1   27 Aug 2009 16:08:56   zf297a
/*   Fixed working with the cursor
/*   
/*      Rev 1.0   27 Aug 2009 15:30:52   zf297a
/*   Initial revision.
/*   Initial revision.
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
	and end_time is null ;	
	procedure endStep(theStepName in varchar2,
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
				amd_batch_pkg.end_step(TheJob, theSystemId, theStepNumber) ;
				:ret_val := 0 ;
			end if ;
			close theSteps ;
		else
			dbms_output.put_line('There is no active job.  The end step was not logged') ;
			:ret_val := 8 ;
		end if ;
	end endStep ;
begin
	endStep('&1') ;
end ;
/


exit :ret_val
