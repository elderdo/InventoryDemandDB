/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   05 Feb 2010 09:40  $
    $Workfile:   truncateInterfaceBatch.sql  $
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec spoc17v2.pkg_escmspo.truncate_table('spoc17v2.interface_batch') ;

exit 








