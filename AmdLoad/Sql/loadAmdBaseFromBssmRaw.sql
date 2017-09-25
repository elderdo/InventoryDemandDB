/*
      $Author:   Douglas S Elder
    $Revision:   1.1
        $Date:   25 Jan 2017
    $Workfile:   loadAmdBaseFromBssmRaw.sql  $

      Rev 1.0   19 Jun 2008 10:04:12   zf297a
      Rev 1.1   25 Jan 2017 added analyzeAmdPartLocTimePeriods
                            and set serveroutput to get dbms_output
                            messages  Douglas Elder
   Initial revision.
*/


WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO ON
SET SERVEROUTPUT ON SIZE 100000

EXEC  amd_from_bssm_pkg.LoadAmdBaseFromBssmRaw;

@@analyzeAmdPartLocTimePeriods.sql

EXIT
