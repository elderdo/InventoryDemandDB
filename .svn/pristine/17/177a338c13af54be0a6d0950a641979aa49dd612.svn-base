/* Formatted on 1/25/2017 2:36:44 PM (QP5 v5.287) */
/*
      $Author:   Douglas S Elder
    $Revision:   1.2
        $Date:   25 Jan 2017
    $Workfile:   loadAmdPartLocations.sql  $
/*
      Rev 1.0   19 Jun 2008 09:55:08   zf297a
      Rev 1.1   24 Jan 2017 Douglas S Elder added analyzeAmdPartLocs.sql
      Rev 1.2   25 Jan 2017 Douglas S Elder added set serveroutput and reformatted code
   Initial revision.
*/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO ON
SET SERVEROUTPUT ON SIZE 100000

EXEC  amd_part_locs_load_pkg.LoadAmdPartLocations;

@@analyzeAmdPartLocs.sql

EXIT
