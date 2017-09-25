/*
      $Author:   zf297a  $
    $Revision:   1.2  $
        $Date:   04 Jul 2008 00:35:00  $
    $Workfile:   StartJob.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\StartJob.sql.-arc  $
/*   
/*      Rev 1.2   04 Jul 2008 00:35:00   zf297a
/*   added whenever commands and removed prompt.
/*   
/*      Rev 1.1   Mar 20 2006 09:30:18   zf297a
/*   Added system_id and changed description
/*   
/*      Rev 1.0   Feb 17 2006 13:22:24   zf297a
/*   Latest Prod Version
*/
--
--
--
whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec amd_batch_pkg.start_job(system_id => amd_batch_pkg.ASSET_MANAGEMENT_DESKTOP, description => 'Amd Batch Load');
commit;

quit
