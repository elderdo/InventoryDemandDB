/*
      $Author:   Douglas S Elder
    $Revision:   1.2  $
        $Date:   25 Jan 2017
    $Workfile:   loadGoldInventory.sql  $
/*   
/*      Rev 1.0   19 Jun 2008 10:06:50   zf297a
/*      Rev 1.1   24 Jan 2017 Douglas S Elder added analyzeTmpAmdOnHandInvs.sql,
                              analyzeTmpAmdInRepair.sql,
                              set serveroutput
/*      Rev 1.2   25 Jan 2017 Douglas S Elder added analyzeRsp.sql,
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on
set serveroutput on size 100000

exec  amd_inventory.loadGoldInventory;

@@analyzeTmpAmdOnHandInvs.sql
@@analyzeTmpAmdInRepair.sql
@@analyzeTmpAmdInTransits.sql
@@analyzeTmpAmdOnOrder.sql
@@analyzeRsp.sql

exit 


