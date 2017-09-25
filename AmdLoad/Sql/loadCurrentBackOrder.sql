/* vim: ff=unix:ts=2:sw=2:sts=2:expandtab:autoindent:smartindent:
      $Author:   Douglas S Elder
    $Revision:   1.1
        $Date:   25 Jan 2017
    $Workfile:   loadCurrentBackOrder.sql  $
   
        Rev 1.0   20 May 2008 15:01:38   Initial Rev
        Rev 1.0   25 Jan 2017 Douglas Elder invoked 
                              analyzeAmdNationalStocktItems.sql to optimize
                              the table and indexes after the update by
                              loadCurrentBackOrder

*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec amd_spare_parts_pkg.loadCurrentBackOrder;

@@analyzeAmdNationalStockItems.sql

exit 

