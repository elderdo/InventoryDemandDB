/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   15 Jul 2011 09:39:44  $
    $Workfile:   loadLRU_Breakdown.sql  $
/*   
/*      Rev 1.0   18 Jul 2011 09:39:44   zf297a
*/
whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

@@loadLRU_Breakdown.sql

@@loadLRU_Breakdown_4.sql

exit
