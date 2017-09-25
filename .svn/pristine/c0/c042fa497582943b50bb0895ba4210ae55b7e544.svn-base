/*
      $Author:   Douglas S. Elder
    $Revision:   1.1
        $Date:   19 Jun 2008 09:58:08  $
    $Workfile:   loadAmdReqs.sql  $
   
      Rev 1.0   19 Jun 2008 09:58:08   zf297a
      Rev 1.1   25 Jan 2017 Douglas S Elder reformatted code
                            added analyzeAmdReqs.sql
   Initial revision.
*/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO ON
SET SERVEROUTPUT ON SIZE 100000

EXEC  amd_reqs_pkg.LoadAmdReqs;

@@analyzeAmdReqs.sql

EXIT
