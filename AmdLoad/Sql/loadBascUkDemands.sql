/*
      $Author:   Douglas S Elder
    $Revision:   1.1  $
        $Date:   24 Jan 2017
    $Workfile:   loadBascUkDemands.sql  $
/*   
/*      Rev 1.0   20 May 2008 15:01:38   zf297a
/*      Rev 1.1   24 Jan 2017 Douglas S Elder added analyzeAmdBssmSource and
                              tmp_amd_demands
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec   amd_demand.loadBascUkdemands;

@@analyzeAmdBssmSource.sql
@@analyzeTmpAmdDemands.sql

exit 





