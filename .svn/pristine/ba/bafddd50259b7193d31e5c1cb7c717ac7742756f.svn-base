/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   19 Jun 2008 10:13:02  $
    $Workfile:   loadTmpAmdPartLocForecasts_Add.sql  $
   
      Rev 1.0   19 Jun 2008 10:13:02   zf297a
   Initial revision.
*/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO ON

EXEC amd_part_loc_forecasts_pkg.LoadTmpAmdPartLocForecasts_Add;

@@analyzeTmpAmdPartLocForecasts.sql

EXIT
