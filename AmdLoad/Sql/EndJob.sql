/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   Feb 17 2006 13:22:20  $
    $Workfile:   EndJob.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\EndJob.sql.-arc  $
/*   
/*      Rev 1.0   Feb 17 2006 13:22:20   zf297a
/*   Latest Prod Version
*/
-- 
--
--

set echo on
set termout on
set time on

prompt amd_batch_pkg.end_job;
exec amd_batch_pkg.end_job;
commit;

quit
