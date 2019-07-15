/*
      $Author:   Douglas S Elder
    $Revision:   1.2
        $Date:   21 Nov 2017
    $Workfile:   genDuplicateForConsumables.sql  $
/*   
/*      Rev 1.2l  21 Nov 2017 DSE added set serveroutput
/*      Rev 1.1   06 Sep 2007 11:58:50   zf297a
/*   Added quit command to script
/*   
/*      Rev 1.0   06 Aug 2007 14:26:36   zf297a
/*   Initial revision.
*/

set echo on
set termout on
set time on
set serveroutput on size unlimited

prompt exec amd_demand.genDuplicateForConsumables;
exec amd_demand.genDuplicateForConsumables;
commit;

quit
