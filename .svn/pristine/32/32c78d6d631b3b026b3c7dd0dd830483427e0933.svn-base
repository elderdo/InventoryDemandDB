/* Formatted on 6/20/2016 2:39:09 PM (QP5 v5.256.13226.35538) */
/*
      $Author:   zf297a  $
    $Revision:   1.2
        $Date:   6/20/2016
    $Workfile:   loadPsms.sql  $
/*   
/*      Rev 1.0   20 May 2008 14:30:52   zf297a
/*   Initial revision.
/*      Rev 1.1   2 Oct 2015 added alter session to prevent ora-02085 error
/*      Rev 1.2   6/20/2016 added set serveroutput and reformatted code
*/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO ON
SET SERVEROUTPUT ON SIZE 100000

ALTER SESSION SET global_names=FALSE;

EXEC amd_load.loadpsms;

EXIT
