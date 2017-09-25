/*
      $Author:   Douglas S. Elder
    $Revision:   1.1
        $Date:   19 Oct 2015
    $Workfile:   loadRblPairs.sql  $
/*   
/*      Rev 1.0   20 May 2008 14:30:52   zf297a
/*   Initial revision.
/*      Rev 1.1   19 Oct 2015 Douglas S. Elder added set serveroutput
                                               since dbms_output has been
                                               added to this procedure to
                                               report duplicates and insertion
                                               counts
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on
set serveroutput on size 100000

exec amd_load.loadrblpairs ;

exit 








