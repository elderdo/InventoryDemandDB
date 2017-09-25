/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   11 Feb 2010 10:40  $
    $Workfile:   truncateSpoC17v2Table.sql  $
/*   Initial revision.
*/

whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

set time on
set timing on
set echo on

exec spoc17v2.pkg_escmspo.truncate_table('spoc17v2.&1') ;

exit 








