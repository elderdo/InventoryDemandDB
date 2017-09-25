/* vim: ff=unix:ts=2:sw=2:sts=2:expandtab:autoindent:smartindent:
      $Author:   Douglas Elder
    $Revision:   1.2  $
        $Date:   04 Jul 2008 00:30:40  $
       Rev 1.2   24 Jan 2017 Douglas Elder added invocation of 
                             analyzeAmdSpareNetworks.sql
                             and reformated code with Toad
       Rev 1.1   04 Jul 2008 00:30:40   zf297a
   Added instance name to package invocation.
   
       Rev 1.0   20 May 2008 15:01:38   zf297a
   Initial revision.
*/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO ON

EXEC  amd_spare_networks_pkg.auto_load_spare_networks;

@@analyzeAmdSpareNetworks.sql

EXIT
