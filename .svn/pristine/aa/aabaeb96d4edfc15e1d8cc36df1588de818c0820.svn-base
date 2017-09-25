/*
      $Author:   Douglas S Elder
    $Revision:   1.0  $
        $Date:   25 Jan 2017
    $Workfile:   loadTmpAmdPartFactors.sql  $
   
      Rev 1.0   19 Jun 2008 10:11:12   zf297a
      Rev 1.1   25 Jan 2017 reformated code
   Initial revision.
*/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO ON
SET SERVEROUTPUT ON SIZE 100000

EXEC  amd_part_factors_pkg.LoadTmpAmdPartFactors;
@analyzeAmdPartFactors.sql

EXIT
