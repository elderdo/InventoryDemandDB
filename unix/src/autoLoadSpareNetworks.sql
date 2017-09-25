/*
      $Author:   zf297a  $
    $Revision:   1.1  $
        $Date:   04 Jul 2008 00:30:40  $
    $Workfile:   autoLoadSpareNetworks.sql  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\Unix\Sql\autoLoadSpareNetworks.sql.-arc  $
/*   
/*      Rev 1.1   04 Jul 2008 00:30:40   zf297a
/*   Added instance name to package invocation.
/*   
/*      Rev 1.0   20 May 2008 15:01:38   zf297a
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec  amd_spare_networks_pkg.auto_load_spare_networks;

exit 



