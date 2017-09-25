/* Formatted on 1/25/2017 6:03:32 PM (QP5 v5.287) */
/*
      $Author:   Douglas S Elder
    $Revision:   1.1
        $Date:   25 Jan 2017
    $Workfile:   loadTmpAmdLocPartLeadTime.sql
   
      Rev 1.0   19 Jun 2008 10:09:16   zf297a
      Rev 1.1   25 Jan 2017 DSE add set serveroutput and reformatted code
   Initial revision.
*/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO ON
SET SERVEROUTPUT ON SIZE 100000

EXEC amd_location_part_leadtime_pkg.LoadTmpAmdLocPartLeadtime;

@@analyzeTmpAmdLocationPartLeadtime.sql

EXIT
