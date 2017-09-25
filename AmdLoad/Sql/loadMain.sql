/* Formatted on 6/20/2016 2:40:24 PM (QP5 v5.256.13226.35538) */
/*
      $Author:   zf297a  $
    $Revision:   1.1
        $Date:   6/20/2016
    $Workfile:   loadMain.sql  $
/*   
/*      Rev 1.0   20 May 2008 14:30:50   zf297a
/*   Initial revision.
/*      Rev 1.1   6/20/2016 added set serveroutput and reformatted code
*/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO ON
SET SERVEROUTPUT ON SIZE 100000

EXEC amd_load.loadmain;

EXIT
