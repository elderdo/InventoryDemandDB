/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   27 Aug 2009 15:30:54  $
    $Workfile:   startStep.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\AmdLoad\Sql\startStep.sql.-arc  $
/*   
/*      Rev 1.0   27 Aug 2009 15:30:54   zf297a
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
set serveroutput on size 100000

variable ret_val number


declare
	procedure startStep(stepName varchar2, 
		theJob amd_batch_job_steps.batch_job_number%type := amd_batch_pkg.getActiveJob,
       		theSystemId amd_batch_job_steps.system_id%type := amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP) is
	begin
		if theJob is not null then
			if Amd_Batch_Pkg.isStepComplete(batch_job_number => theJob,
				system_id => theSystemId,
	                        description => stepName) THEN
				:ret_val := 4 ;
			else
				Amd_Batch_Pkg.start_step(batch_job_number => theJob, 
				    	system_id => theSystemId,
       	                     		description => stepName) ; 
				:ret_val := 0 ;
			end if ;
		else
			dbms_output.put_line('There is no active job.  The step was not logged') ;				
			:ret_val := 8 ;
		end if ;
	end startStep ;
begin
	startStep('&1') ;
	dbms_output.put_line('&1 step started') ;
end ;
/

exit :ret_val



